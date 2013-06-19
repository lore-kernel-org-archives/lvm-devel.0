From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 Jun 2013 11:24:36 +0200
Subject: [PATCH 6/9] pvremove: Avoid using pv_read in favour of scanning.
In-Reply-To: <1371633879-8879-1-git-send-email-prockai@redhat.com>
References: <1371633879-8879-1-git-send-email-prockai@redhat.com>
Message-ID: <1371633879-8879-6-git-send-email-prockai@redhat.com>
	(sfid-20130619_112452_150007_6ED0FCA7)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 tools/pvremove.c | 69 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 35 insertions(+), 34 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index 2c8f5c6..1d5fe18 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -21,52 +21,53 @@
  */
 static int pvremove_check(struct cmd_context *cmd, const char *name)
 {
-	struct physical_volume *pv;
+	struct device *dev;
+	struct label *label;
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
+
+	struct physical_volume *pv = NULL;
+	int r = 0;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
+	if (!(dev = dev_cache_get(name, cmd->filter))) {
+		log_error("Device %s not found", name);
+		return 0;
+	}
+
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, 1, 0))) {
+	if (!label_read(dev, &label, 0)) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
-		log_error("Physical Volume %s not found", name);
+		log_error("No PV label found on %s.", name);
 		return 0;
 	}
 
-	/*
-	 * If a PV has no MDAs it may appear to be an
-	 * orphan until the metadata is read off
-	 * another PV in the same VG.  Detecting this
-	 * means checking every VG by scanning every
-	 * PV on the system.
-	 */
-	if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use) &&
-	    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
-		if (!scan_vgs_for_pvs(cmd, 0)) {
-			log_error("Rescan for PVs without metadata areas "
-				  "failed.");
-			goto bad;
-		}
-		free_pv_fid(pv);
-		if (!(pv = pv_read(cmd, name, 1, 0))) {
-			log_error("Failed to read physical volume %s", name);
-			goto bad;
-		}
+	lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!(pvslist = get_pvs(cmd)))
+		return_0;
+
+	dm_list_iterate_items(pvl, pvslist)
+		if (pvl->pv->dev == dev)
+			pv = pvl->pv;
+
+	if (!pv) {
+		log_error("Physical Volume %s not found through scanning.", name);
+		goto out; /* better safe than sorry */
 	}
 
-	/* orphan ? */
 	if (is_orphan(pv)) {
-		free_pv_fid(pv);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
-	/* Allow partial & exported VGs to be destroyed. */
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
 		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
 		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
-		goto bad;
+		goto out;
 	}
 
 	/* prompt */
@@ -75,7 +76,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 			  "of volume group \"%s\" [y/n]? ",
 			  name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume label not removed", name);
-		goto bad;
+		goto out;
 	}
 
 	if (arg_count(cmd, force_ARG)) {
@@ -86,12 +87,12 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
-	free_pv_fid(pv);
-	return 1;
-
-bad:
-	free_pv_fid(pv);
-	return 0;
+	r = 1;
+out:
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+	return r;
 }
 
 static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-- 
1.8.2


