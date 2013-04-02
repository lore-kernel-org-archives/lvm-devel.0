From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  2 Apr 2013 16:16:31 -0500
Subject: [PATCH 1/3] lvm2app: Implement lvm_pv_remove
Message-ID: <1364937393-12997-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Code move and changes to support calling code from
command line and from library interface.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.h |   4 ++
 lib/metadata/pv_manip.c | 130 ++++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm2app.h        |  16 +++++-
 liblvm/lvm_pv.c         |   8 +++
 tools/pvremove.c        | 135 +++---------------------------------------------
 5 files changed, 163 insertions(+), 130 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0c13a97..35be923 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -341,6 +341,10 @@ int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
+int pvremove_single(struct cmd_context *cmd, const char *pv_name,
+			   void *handle __attribute__((unused)), unsigned force_count,
+			   unsigned prompt);
+
 /* Manipulate PV structures */
 int pv_add(struct volume_group *vg, struct physical_volume *pv);
 int pv_remove(struct volume_group *vg, struct physical_volume *pv);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 4a65a3e..3823f76 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -19,6 +19,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "defaults.h"
+#include "lvmetad.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -542,3 +543,132 @@ int pv_resize(struct physical_volume *pv,
 
 	return 1;
 }
+
+const char _really_wipe[] =
+    "Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ";
+
+/*
+ * Decide whether it is "safe" to wipe the labels on this device.
+ * 0 indicates we may not.
+ */
+static int pvremove_check(struct cmd_context *cmd, const char *name,
+		unsigned force_count, unsigned prompt)
+{
+	struct physical_volume *pv;
+
+	/* FIXME Check partition type is LVM unless --force is given */
+
+	/* Is there a pv here already? */
+	/* If not, this is an error unless you used -f. */
+	if (!(pv = pv_read(cmd, name, 1, 0))) {
+		if (force_count)
+			return 1;
+		log_error("Physical Volume %s not found", name);
+		return 0;
+	}
+
+	/*
+	 * If a PV has no MDAs it may appear to be an
+	 * orphan until the metadata is read off
+	 * another PV in the same VG.  Detecting this
+	 * means checking every VG by scanning every
+	 * PV on the system.
+	 */
+	if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use) &&
+	    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
+		if (!scan_vgs_for_pvs(cmd, 0)) {
+			log_error("Rescan for PVs without metadata areas "
+				  "failed.");
+			goto bad;
+		}
+		free_pv_fid(pv);
+		if (!(pv = pv_read(cmd, name, 1, 0))) {
+			log_error("Failed to read physical volume %s", name);
+			goto bad;
+		}
+	}
+
+	/* orphan ? */
+	if (is_orphan(pv)) {
+		free_pv_fid(pv);
+		return 1;
+	}
+
+	/* Allow partial & exported VGs to be destroyed. */
+	/* we must have -ff to overwrite a non orphan */
+	if (force_count < 2) {
+		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
+		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
+		goto bad;
+	}
+
+	/* prompt */
+	if (!prompt &&
+	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
+		log_error("%s: physical volume label not removed", name);
+		goto bad;
+	}
+
+	if (force_count) {
+		log_warn("WARNING: Wiping physical volume label from "
+			  "%s%s%s%s", name,
+			  !is_orphan(pv) ? " of volume group \"" : "",
+			  !is_orphan(pv) ? pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? "\"" : "");
+	}
+
+	free_pv_fid(pv);
+	return 1;
+
+bad:
+	free_pv_fid(pv);
+	return 0;
+}
+
+int pvremove_single(struct cmd_context *cmd, const char *pv_name,
+			   void *handle __attribute__((unused)), unsigned force_count,
+			   unsigned prompt)
+{
+	struct device *dev;
+	int ret = ECMD_FAILED;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
+	if (!pvremove_check(cmd, pv_name, force_count, prompt))
+		goto out;
+
+	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  pv_name);
+		goto out;
+	}
+
+	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper is still using the device */
+		log_error("Can't open %s exclusively - not removing. "
+			  "Mounted filesystem?", dev_name(dev));
+		goto out;
+	}
+
+	/* Wipe existing label(s) */
+	if (!label_remove(dev)) {
+		log_error("Failed to wipe existing label(s) on %s", pv_name);
+		goto out;
+	}
+
+	if (!lvmetad_pv_gone_by_dev(dev, NULL))
+		goto_out;
+
+	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
+				pv_name);
+
+	ret = ECMD_PROCESSED;
+
+out:
+	unlock_vg(cmd, VG_ORPHANS);
+
+	return ret;
+}
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index a17d5ac..5fe41ac 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -544,14 +544,15 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg);
  * \return
  * A list of lvm_pv_list structures containing pv handles for all physical
  * volumes. If no PVs exist or a global lock was unable to be obtained a
- * NULL is returned.
+ * NULL is returned.  Do not attempt to remove one of the PVs until after the
+ * call to lvm_list_pvs_free has been made.
  */
 struct dm_list *lvm_list_pvs(lvm_t libh);
 
 /**
  * Free the resources used by acquiring the pvlist.  This should be called as
  * soon as possible after processing the needed information from the pv list as
- * a global locks are held.
+ * a global lock is held.
  *
  * \param	pvlist
  * PV list to be freed
@@ -562,6 +563,17 @@ struct dm_list *lvm_list_pvs(lvm_t libh);
 int lvm_list_pvs_free(struct dm_list *pvlist);
 
 /**
+ *  Remove a physical volume.
+ *  Note: You cannot remove a PV while iterating through the list of PVs as
+ *  locks are held for the PV list.
+ *  \param	libh	Library handle
+ *  \param	pv_name	The physical volume name
+ *  \return
+ *  0 on success, else -1 with library errno and text set.
+ */
+int lvm_pv_remove(lvm_t libh, const char *pv_name);
+
+/**
  * Return a list of PV handles for a given VG handle.
  *
  * \memberof vg_t
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index dcb1a29..390c2b7 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -75,6 +75,14 @@ struct lvm_list_wrapper
 	struct dm_list vgslist;
 };
 
+int lvm_pv_remove(lvm_t libh, const char *pv_name)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	if ( 1 != pvremove_single(cmd, pv_name, NULL, 0, 0)) {
+		return -1;
+	}
+	return 0;
+}
 
 struct dm_list *lvm_list_pvs(lvm_t libh)
 {
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 823c069..798e91c 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -14,150 +14,29 @@
  */
 
 #include "tools.h"
+#include "metadata.h"
 
-const char _really_wipe[] =
-    "Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ";
-
-/*
- * Decide whether it is "safe" to wipe the labels on this device.
- * 0 indicates we may not.
- */
-static int pvremove_check(struct cmd_context *cmd, const char *name)
-{
-	struct physical_volume *pv;
-
-	/* FIXME Check partition type is LVM unless --force is given */
-
-	/* Is there a pv here already? */
-	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, 1, 0))) {
-		if (arg_count(cmd, force_ARG))
-			return 1;
-		log_error("Physical Volume %s not found", name);
-		return 0;
-	}
-
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
-	}
-
-	/* orphan ? */
-	if (is_orphan(pv)) {
-		free_pv_fid(pv);
-		return 1;
-	}
-
-	/* Allow partial & exported VGs to be destroyed. */
-	/* we must have -ff to overwrite a non orphan */
-	if (arg_count(cmd, force_ARG) < 2) {
-		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
-		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
-		goto bad;
-	}
-
-	/* prompt */
-	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
-		log_error("%s: physical volume label not removed", name);
-		goto bad;
-	}
-
-	if (arg_count(cmd, force_ARG)) {
-		log_warn("WARNING: Wiping physical volume label from "
-			  "%s%s%s%s", name,
-			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? pv_vg_name(pv) : "",
-			  !is_orphan(pv) ? "\"" : "");
-	}
-
-	free_pv_fid(pv);
-	return 1;
-
-bad:
-	free_pv_fid(pv);
-	return 0;
-}
-
-static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-			   void *handle __attribute__((unused)))
-{
-	struct device *dev;
-	int ret = ECMD_FAILED;
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
-	if (!pvremove_check(cmd, pv_name))
-		goto out;
-
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("%s: Couldn't find device.  Check your filters?",
-			  pv_name);
-		goto out;
-	}
-
-	if (!dev_test_excl(dev)) {
-		/* FIXME Detect whether device-mapper is still using the device */
-		log_error("Can't open %s exclusively - not removing. "
-			  "Mounted filesystem?", dev_name(dev));
-		goto out;
-	}
-
-	/* Wipe existing label(s) */
-	if (!label_remove(dev)) {
-		log_error("Failed to wipe existing label(s) on %s", pv_name);
-		goto out;
-	}
-
-	if (!lvmetad_pv_gone_by_dev(dev, NULL))
-		goto_out;
-
-	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
-				pv_name);
-
-	ret = ECMD_PROCESSED;
-
-out:
-	unlock_vg(cmd, VG_ORPHANS);
-
-	return ret;
-}
 
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, r;
 	int ret = ECMD_PROCESSED;
+	unsigned force_count;
+	unsigned prompt;
 
 	if (!argc) {
 		log_error("Please enter a physical volume path");
 		return EINVALID_CMD_LINE;
 	}
 
+	force_count = arg_count(cmd, force_ARG);
+	prompt = arg_count(cmd, yes_ARG);
+
 	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		r = pvremove_single(cmd, argv[i], NULL);
+		r = pvremove_single(cmd, argv[i], NULL, force_count, prompt);
 		if (r > ret)
 			ret = r;
 	}
-
 	return ret;
 }
-- 
1.8.1.4


