From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Aug 2016 22:49:58 +0000 (UTC)
Subject: master - raid: Pass list of LVs to remove into more fns.
Message-ID: <20160806224958.3760260E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba0c26a078119f5a7d551e047189f23bdd76e2be
Commit:        ba0c26a078119f5a7d551e047189f23bdd76e2be
Parent:        30884208d47f9b26543134ef3d87e51422a66a85
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Aug 6 23:46:45 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Aug 6 23:46:45 2016 +0100

raid: Pass list of LVs to remove into more fns.

---
 lib/metadata/raid_manip.c |  108 +++++++++++++++++++++++++++-----------------
 1 files changed, 66 insertions(+), 42 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c46802a..f5a800b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -678,8 +678,15 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 
 	dm_list_init(&allocatable_pvs);
 
-	if (!allocate_pvs)
+	if (!allocate_pvs) {
 		allocate_pvs = &allocatable_pvs;
+		if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
+					data_lv, &allocatable_pvs)) {
+			log_error("Failed to build list of PVs for %s/%s",
+				  data_lv->vg->name, data_lv->name);
+			return 0;
+		}
+	}
 
 	if (!seg_is_linear(seg)) {
 		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
@@ -691,17 +698,10 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	if ((p = strstr(base_name, "_mimage_")))
 		*p = '\0';
 
-	if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
-				data_lv, &allocatable_pvs)) {
-		log_error("Failed to build list of PVs for %s/%s",
-			  data_lv->vg->name, data_lv->name);
-		return 0;
-	}
-
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
 				    seg->region_size,
 				    1 /*RAID_METADATA_AREA_LEN*/,
-				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
+				    allocate_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
 	if (!(*meta_lv = _alloc_image_component(data_lv, base_name, ah, 0, RAID_META))) {
@@ -714,10 +714,9 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	return 1;
 }
 
-static int _raid_add_images(struct logical_volume *lv,
-			    uint32_t new_count, struct dm_list *pvs)
+static int _raid_add_images_without_commit(struct logical_volume *lv,
+					   uint32_t new_count, struct dm_list *pvs)
 {
-	int rebuild_flag_cleared = 0;
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
 	uint32_t count = new_count - old_count;
@@ -894,6 +893,35 @@ to be left for these sub-lvs.
 	dm_list_iterate_items(lvl, &data_lvs)
 		lv_set_hidden(lvl->lv);
 
+	return 1;
+
+fail:
+	/* Cleanly remove newly-allocated LVs that failed insertion attempt */
+	dm_list_iterate_items(lvl, &meta_lvs)
+		if (!lv_remove(lvl->lv))
+			return_0;
+
+	dm_list_iterate_items(lvl, &data_lvs)
+		if (!lv_remove(lvl->lv))
+			return_0;
+
+	return 0;
+}
+
+static int _raid_add_images(struct logical_volume *lv,
+			    uint32_t new_count, struct dm_list *pvs,
+			    int commit)
+{
+	int rebuild_flag_cleared = 0;
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t s;
+
+	if (!_raid_add_images_without_commit(lv, new_count, pvs))
+		return_0;
+
+	if (!commit)
+		return 1;
+
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
@@ -921,18 +949,6 @@ to be left for these sub-lvs.
 	}
 
 	return 1;
-
-fail:
-	/* Cleanly remove newly-allocated LVs that failed insertion attempt */
-	dm_list_iterate_items(lvl, &meta_lvs)
-		if (!lv_remove(lvl->lv))
-			return_0;
-
-	dm_list_iterate_items(lvl, &data_lvs)
-		if (!lv_remove(lvl->lv))
-			return_0;
-
-	return 0;
 }
 
 /*
@@ -979,6 +995,7 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	seg_type(seg, idx) = AREA_UNASSIGNED;
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
 
+	/* FIXME Remove duplicated prefix? */
 	if (!(data_lv->name = _generate_raid_name(data_lv, "_extracted", -1)))
 		return_0;
 
@@ -1111,18 +1128,22 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 }
 
 static int _raid_remove_images(struct logical_volume *lv,
-			       uint32_t new_count, struct dm_list *pvs)
+			       uint32_t new_count, struct dm_list *allocate_pvs,
+			       struct dm_list *removal_lvs, int commit)
 {
-	struct dm_list removal_lvs;
+	struct dm_list removed_lvs;
 	struct lv_list *lvl;
 
+	dm_list_init(&removed_lvs);
+
 	if (!archive(lv->vg))
 		return_0;
 
-	dm_list_init(&removal_lvs);
+	if (!removal_lvs)
+		removal_lvs = &removed_lvs;
 
-	if (!_raid_extract_images(lv, new_count, pvs, 1,
-				 &removal_lvs, &removal_lvs)) {
+	if (!_raid_extract_images(lv, new_count, allocate_pvs, 1,
+				 removal_lvs, removal_lvs)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1130,7 +1151,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 
 	/* Convert to linear? */
 	if (new_count == 1) {
-		if (!_raid_remove_top_layer(lv, &removal_lvs)) {
+		if (!_raid_remove_top_layer(lv, removal_lvs)) {
 			log_error("Failed to remove RAID layer"
 				  " after linear conversion");
 			return 0;
@@ -1139,6 +1160,9 @@ static int _raid_remove_images(struct logical_volume *lv,
 		first_seg(lv)->writebehind = 0;
 	}
 
+	if (!commit)
+		return 1;
+
 	if (!vg_write(lv->vg)) {
 		log_error("Failed to write changes to %s in %s",
 			  lv->name, lv->vg->name);
@@ -1163,7 +1187,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	 * and won't conflict with the remaining (possibly shifted)
 	 * sub-LVs.
 	 */
-	dm_list_iterate_items(lvl, &removal_lvs) {
+	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
 			log_error("Failed to resume extracted LVs");
 			return 0;
@@ -1185,13 +1209,9 @@ static int _raid_remove_images(struct logical_volume *lv,
 	/*
 	 * Eliminate the extracted LVs
 	 */
-	if (!dm_list_empty(&removal_lvs)) {
-		dm_list_iterate_items(lvl, &removal_lvs) {
-			if (!deactivate_lv(lv->vg->cmd, lvl->lv))
-				return_0;
-			if (!lv_remove(lvl->lv))
-				return_0;
-		}
+	if (!dm_list_empty(removal_lvs)) {
+		if (!_deactivate_and_remove_lvs(lv->vg, removal_lvs))
+			return_0;
 
 		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 			return_0;
@@ -1214,7 +1234,8 @@ static int _raid_remove_images(struct logical_volume *lv,
  * the results.
  */
 static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
-				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs)
+				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
+				       int commit)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
 
@@ -1235,15 +1256,15 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 	}
 
 	if (old_count > new_count)
-		return _raid_remove_images(lv, new_count, allocate_pvs);
+		return _raid_remove_images(lv, new_count, allocate_pvs, removal_lvs, commit);
 
-	return _raid_add_images(lv, new_count, allocate_pvs);
+	return _raid_add_images(lv, new_count, allocate_pvs, commit);
 }
 
 int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
 			       struct dm_list *allocate_pvs)
 {
-	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL);
+	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL, 1);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -2105,6 +2126,9 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 	return 1;
 }
 
+/*
+ * Convert a RAID0 set to striped
+ */
 static int _convert_raid0_to_striped(struct logical_volume *lv,
 				     int update_and_reload,
 				     struct dm_list *removal_lvs)


