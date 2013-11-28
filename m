From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Nov 2013 12:22:18 +0000 (UTC)
Subject: master - pvcreate: do not issue warning about any existing PV
Message-ID: <20131128122218.5E3EF60D36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a1957badcb95a5f2815436e64798b48ed85ca0c
Commit:        6a1957badcb95a5f2815436e64798b48ed85ca0c
Parent:        ce8ebda3fc0e8275d15f8cdc7f6f21162c7c1636
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 28 13:14:46 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 28 13:14:46 2013 +0100

pvcreate: do not issue warning about any existing PV

If we're calling pvcreate on a device that already has a PV label,
the blkid detects the existing PV and then we consider it for wiping
before we continue creating the new PV label and we issue a warning
with a prompt whether such old PV label should be removed. We don't
do this with native signature detection code. Let's make it consistent
with old behaviour.

But still keep this "PV" (identified as "LVM1_member" or "LVM2_member"
by blkid) detection when creating new LVs to avoid unexpected PV label
appeareance inside LV.
---
 lib/device/dev-type.c   |   20 ++++++++++++++------
 lib/device/dev-type.h   |    3 ++-
 lib/metadata/lv_manip.c |    2 +-
 lib/metadata/metadata.c |    2 +-
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 04b555b..78b093c 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -449,8 +449,8 @@ out:
 
 #ifdef BLKID_WIPING_SUPPORT
 
-static int _blkid_wipe(blkid_probe probe, struct device *dev,
-		       const char *name, int yes, force_t force)
+static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
+		       int exclude_lvm_member, int yes, force_t force)
 {
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
@@ -458,6 +458,9 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev,
 	size_t len;
 
 	if (!blkid_probe_lookup_value(probe, "TYPE", &type, NULL)) {
+		if (exclude_lvm_member &&
+		    (!strcmp(type, "LVM1_member") || !strcmp(type, "LVM2_member")))
+			return 1;
 		if (!blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL) &&
 		     blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len))
 			return_0;
@@ -495,6 +498,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev,
 }
 
 static int _wipe_known_signatures_with_blkid(struct device *dev, const char *name,
+					     int exclude_lvm_member,
 					     int yes, force_t force)
 {
 	blkid_probe probe = NULL;
@@ -522,7 +526,7 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 
 	while (!blkid_do_probe(probe)) {
 		found++;
-		if (_blkid_wipe(probe, dev, name, yes, force))
+		if (_blkid_wipe(probe, dev, name, exclude_lvm_member, yes, force))
 			wiped++;
 	}
 
@@ -576,6 +580,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 }
 
 static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
+					   int exclude_lvm_member,
 					   int yes, force_t force)
 {
 	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
@@ -587,13 +592,16 @@ static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 }
 
 int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
-			  const char *name, int yes, force_t force)
+			  const char *name, int exclude_lvm_member,
+			  int yes, force_t force)
 {
 #ifdef BLKID_WIPING_SUPPORT
 	if (find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL))
-		return _wipe_known_signatures_with_blkid(dev, name, yes, force);
+		return _wipe_known_signatures_with_blkid(dev, name,
+				exclude_lvm_member, yes, force);
 #endif
-	return _wipe_known_signatures_with_lvm(dev, name, yes, force);
+	return _wipe_known_signatures_with_lvm(dev, name,
+			exclude_lvm_member, yes, force);
 }
 
 #ifdef __linux__
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 39d947b..284280e 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -60,7 +60,8 @@ int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
 
 /* Signature wiping. */
-int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const char *name, int yes, force_t force);
+int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const char *name,
+			  int exclude_lvm_member, int yes, force_t force);
 
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fe9e656..c67dd38 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5415,7 +5415,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
 			     lv->vg->name, lv->name);
-		if (!wipe_known_signatures(lv->vg->cmd, dev, name, wp.yes, wp.force))
+		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0, wp.yes, wp.force))
 			stack;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d55dba1..f075c21 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1328,7 +1328,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		goto bad;
 	}
 
-	if (!wipe_known_signatures(cmd, dev, name, pp->yes, pp->force)) {
+	if (!wipe_known_signatures(cmd, dev, name, 1, pp->yes, pp->force)) {
 		log_error("Aborting pvcreate on %s.", name);
 		goto bad;
 	}


