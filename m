From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Aug 2016 22:49:56 +0000 (UTC)
Subject: master - raid: Move two functions.
Message-ID: <20160806224956.2588660E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30884208d47f9b26543134ef3d87e51422a66a85
Commit:        30884208d47f9b26543134ef3d87e51422a66a85
Parent:        802bd34562f810b9f183c5b20cd24fc5675e2f98
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Aug 6 23:29:27 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Aug 6 23:29:27 2016 +0100

raid: Move two functions.

---
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/raid_manip.c |   63 +++++++++++++++++++++++----------------------
 2 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d74c571..cb7e6b7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3281,7 +3281,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
 		  total_extents, existing_extents, total_extents + existing_extents);
 	if (ah->log_len)
-		log_debug("Mirror log of %" PRIu32 " extents of size %" PRIu32 "sectors needed for region size %" PRIu32  ".",
+		log_debug("Mirror log of %" PRIu32 " extents of size %" PRIu32 " sectors needed for region size %" PRIu32  ".",
 			  ah->log_len, extent_size, ah->region_size);
 
 	if (mirrors || stripes)
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4498f2f..c46802a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -190,6 +190,38 @@ static void _clear_allocation_prohibited(struct dm_list *pvs)
 			pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
 }
 
+/* FIXME Move this out */
+/* Write, commit and optionally backup metadata of vg */
+static int _vg_write_commit_backup(struct volume_group *vg)
+{
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to commit VG %s metadata.", vg->name);
+		return 0;
+	}
+
+	if (!backup(vg))
+		log_warn("WARNING: Backup of VG %s metadata failed. Continuing.", vg->name);
+
+	return 1;
+}
+
+/*
+ * Deactivate and remove the LVs on removal_lvs list from vg.
+ */
+static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
+{
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, removal_lvs) {
+		if (!deactivate_lv(vg->cmd, lvl->lv))
+			return_0;
+		if (!lv_remove(lvl->lv))
+			return_0;
+	}
+
+	return 1;
+}
+
 /*
  * _raid_in_sync
  * @lv
@@ -1495,21 +1527,6 @@ int lv_raid_merge(struct logical_volume *image_lv)
 }
 
 /*
- * Deactivate and remove the LVs on removal_lvs list from vg.
- */
-static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
-{
-	struct lv_list *lvl;
-
-	dm_list_iterate_items(lvl, removal_lvs)
-		if (!deactivate_lv(vg->cmd, lvl->lv) ||
-		    !lv_remove(lvl->lv))
-			return_0;
-
-	return 1;
-}
-
-/*
  * Allocate metadata devs for all @new_data_devs and link them to list @new_meta_lvs
  */
 static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
@@ -1769,22 +1786,6 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 	return 1;
 }
 
-
-/* FIXME Move this out */
-/* Write, commit and optionally backup metadata of vg */
-static int _vg_write_commit_backup(struct volume_group *vg)
-{
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Failed to commit VG %s metadata.", vg->name);
-		return 0;
-	}
-
-	if (!backup(vg))
-		log_warn("WARNING: Backup of VG %s metadata failed. Continuing.", vg->name);
-
-	return 1;
-}
-
 /*
  * Eliminate the extracted LVs on @removal_lvs from @vg incl. vg write, commit and backup 
  */


