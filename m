From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Aug 2014 00:33:08 +0000 (UTC)
Subject: master - pvcreate: Fix cache state with filters/sig wiping.
Message-ID: <20140814003308.7DFC561137@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf78e55ef311b0bea7993c5405d637e46a1b8394
Commit:        bf78e55ef311b0bea7993c5405d637e46a1b8394
Parent:        20503ff0675616823bcc9aa67f3e6d14a4172277
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 14 01:30:01 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 14 01:30:01 2014 +0100

pvcreate: Fix cache state with filters/sig wiping.

_pvcreate_check() has two missing requirements:
  After refreshing filters there must be a rescan.
    (Otherwise the persistent filter may remain empty.)
  After wiping a signature, the filters must be refreshed.
    (A device that was previously excluded by the filter due to
     its signature might now need to be included.)

If several devices are added at once, the repeated scanning isn't
strictly needed, but we can address that later as part of the command
processing restructuring (by grouping the devices).

Replace the new pvcreate code added by commit
54685c20fc9dfb155a2e5bc9d8cf5f0aad944305 "filters: fix regression caused
by commit e80884cd080cad7e10be4588e3493b9000649426"
with this change to _pvcreate_check().

The filter refresh problem dates back to commit
acb4b5e4de3c49d36fe756f6fb9997ec179b89c2 "Fix pvcreate device check."
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   48 ++++++++++++++++++++++++++++------------------
 tools/pvcreate.c        |    9 --------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 28f7e36..0ca0485 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Fix pvcreate_check() to update cache correctly after signature wiping.
   Fix primary device lookup failure for partition when processing mpath filter.
   If LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln.
   Remove spurious "Skipping mirror LV" message on pvmove of clustered mirror.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6f88fd8..d483225 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1329,11 +1329,14 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
  */
-static int pvcreate_check(struct cmd_context *cmd, const char *name,
-			  struct pvcreate_params *pp)
+static int _pvcreate_check(struct cmd_context *cmd, const char *name,
+			   struct pvcreate_params *pp)
 {
 	struct physical_volume *pv;
 	struct device *dev;
+	int r = 0;
+	int scan_needed = 0;
+	int filter_refresh_needed = 0;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -1345,7 +1348,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
 		log_error("Can't initialize physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
-		goto bad;
+		goto out;
 	}
 
 	/* prompt */
@@ -1353,28 +1356,29 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	    yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ",
 			  name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume not initialized", name);
-		goto bad;
+		goto out;
 	}
 
 	if (sigint_caught())
-		goto_bad;
+		goto_out;
 
 	dev = dev_cache_get(name, cmd->filter);
 
 	/* Is there an md superblock here? */
-	/* FIXME: still possible issues here - rescan cache? */
 	if (!dev && md_filtering()) {
 		if (!refresh_filters(cmd))
-			goto_bad;
+			goto_out;
 
 		init_md_filtering(0);
 		dev = dev_cache_get(name, cmd->filter);
 		init_md_filtering(1);
+
+		scan_needed = 1;
 	}
 
 	if (!dev) {
 		log_error("Device %s not found (or ignored by filtering).", name);
-		goto bad;
+		goto out;
 	}
 
 	/*
@@ -1384,33 +1388,39 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",
 			  name);
-		goto bad;
+		goto out;
 	}
 
 	if (!wipe_known_signatures(cmd, dev, name,
 				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
 				   0, pp->yes, pp->force)) {
 		log_error("Aborting pvcreate on %s.", name);
-		goto bad;
-	}
+		goto out;
+	} else
+		filter_refresh_needed = scan_needed = 1;
+	
 
 	if (sigint_caught())
-		goto_bad;
+		goto_out;
 
-	if (pv && !is_orphan(pv) && pp->force) {
+	if (pv && !is_orphan(pv) && pp->force)
 		log_warn("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
 			  pv_vg_name(pv),
 			  !is_orphan(pv) ? "\"" : "");
-	}
 
-	free_pv_fid(pv);
-	return 1;
+	r = 1;
+
+out:
+	if (filter_refresh_needed)
+		refresh_filters(cmd);
+
+	if (scan_needed)
+		lvmcache_label_scan(cmd, 2);
 
-bad:
 	free_pv_fid(pv);
-	return 0;
+	return r;
 }
 
 void pvcreate_params_set_defaults(struct pvcreate_params *pp)
@@ -1542,7 +1552,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 		}
 	}
 
-	if (!pvcreate_check(cmd, pv_name, pp))
+	if (!_pvcreate_check(cmd, pv_name, pp))
 		goto_bad;
 
 	if (sigint_caught())
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 67ecd41..958e353 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -105,15 +105,6 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/*
-	 * Make sure we don't overwrite any existing signature
-	 * that may have been created after last time we did filtering.
-	 */
-	if (!(refresh_filters(cmd))) {
-		log_error("Failed to refresh filters before pvcreate.");
-		return ECMD_FAILED;
-	}
-
 	for (i = 0; i < argc; i++) {
 		if (sigint_caught())
 			return_ECMD_FAILED;


