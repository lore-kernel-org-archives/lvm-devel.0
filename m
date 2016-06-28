From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 22:46:23 +0000 (UTC)
Subject: master - lvconvert: Conversions between striped and raid0.
Message-ID: <20160628224623.50CEC6032F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=686acce23fed6bd72af63201e4cc56bc5958379e
Commit:        686acce23fed6bd72af63201e4cc56bc5958379e
Parent:        6f216692b47b38f480e50d213de5c513a309d9e0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 28 23:44:15 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 23:44:15 2016 +0100

lvconvert: Conversions between striped and raid0.

---
 WHATS_NEW                 |    1 +
 lib/metadata/lv.c         |   30 ++-
 lib/metadata/lv_manip.c   |    3 +-
 lib/metadata/metadata.h   |    4 +
 lib/metadata/raid_manip.c |  595 +++++++++++++++++++++++++++++++++++++++++----
 lib/metadata/segtype.c    |   13 +
 lib/metadata/segtype.h    |    2 +
 lib/misc/util.h           |    2 +
 8 files changed, 593 insertions(+), 57 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3184412..619c64d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.159 - 
 =================================
+  Support conversions between striped and raid0 segment types.
   Add infrastructure for raid takeover lvconvert options.
 
 Version 2.02.158 - 25th June 2016
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index cdf658e..e7a56cf 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -577,14 +577,14 @@ char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-        char lvfullname[NAME_LEN * 2 + 2];
+	char lvfullname[NAME_LEN * 2 + 2];
 
-        if (dm_snprintf(lvfullname, sizeof(lvfullname), "%s/%s", lv->vg->name, lv->name) < 0) {
-                log_error("lvfullname snprintf failed");
-                return NULL;
-        }
+	if (dm_snprintf(lvfullname, sizeof(lvfullname), "%s/%s", lv->vg->name, lv->name) < 0) {
+		log_error("lvfullname snprintf failed");
+		return NULL;
+	}
 
-        return dm_pool_strdup(mem, lvfullname);
+	return dm_pool_strdup(mem, lvfullname);
 }
 
 struct logical_volume *lv_parent(const struct logical_volume *lv)
@@ -930,7 +930,7 @@ char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (!*lv->vg->name)
 		return dm_pool_strdup(mem, "");
 
-        if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
+	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
 		log_error("dm_build_dm_name failed");
 		return NULL;
 	}
@@ -1581,3 +1581,19 @@ struct profile *lv_config_profile(const struct logical_volume *lv)
 {
 	return lv->profile ? : lv->vg->profile;
 }
+
+int lv_has_constant_stripes(struct logical_volume *lv)
+{
+	uint32_t previous_area_count = 0;
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (!seg_is_striped(seg))
+			return 0;
+		if (previous_area_count && previous_area_count != seg->area_count)
+			return 0;
+		previous_area_count = seg->area_count;
+	}
+
+	return 1;
+}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 40c1c1a..db71939 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3301,7 +3301,8 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 void alloc_destroy(struct alloc_handle *ah)
 {
-	dm_pool_destroy(ah->mem);
+	if (ah)
+		dm_pool_destroy(ah->mem);
 }
 
 /*
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 31c9346..e6dc14a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -415,6 +415,10 @@ struct logical_volume *alloc_lv(struct dm_pool *mem);
  */
 int check_lv_segments(struct logical_volume *lv, int complete_vg);
 
+/*
+ * Does every LV segment have the same number of stripes?
+ */
+int lv_has_constant_stripes(struct logical_volume *lv);
 
 /*
  * Checks that a replicator segment is correct.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2cef777..71334b5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -116,16 +116,16 @@ static int _raid_in_sync(struct logical_volume *lv)
 /*
  * _raid_remove_top_layer
  * @lv
- * @removal_list
+ * @removal_lvs
  *
  * Remove top layer of RAID LV in order to convert to linear.
  * This function makes no on-disk changes.  The residual LVs
- * returned in 'removal_list' must be freed by the caller.
+ * returned in 'removal_lvs' must be freed by the caller.
  *
  * Returns: 1 on succes, 0 on failure
  */
 static int _raid_remove_top_layer(struct logical_volume *lv,
-				  struct dm_list *removal_list)
+				  struct dm_list *removal_lvs)
 {
 	struct lv_list *lvl_array, *lvl;
 	struct lv_segment *seg = first_seg(lv);
@@ -147,19 +147,19 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl))))
 		return_0;
 
-	/* Add last metadata area to removal_list */
+	/* Add last metadata area to removal_lvs */
 	lvl_array[0].lv = seg_metalv(seg, 0);
 	lv_set_visible(seg_metalv(seg, 0));
 	if (!remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg))
 		return_0;
 	seg_metatype(seg, 0) = AREA_UNASSIGNED;
-	dm_list_add(removal_list, &(lvl_array[0].list));
+	dm_list_add(removal_lvs, &(lvl_array[0].list));
 
-	/* Remove RAID layer and add residual LV to removal_list*/
+	/* Remove RAID layer and add residual LV to removal_lvs*/
 	seg_lv(seg, 0)->status &= ~RAID_IMAGE;
 	lv_set_visible(seg_lv(seg, 0));
 	lvl_array[1].lv = seg_lv(seg, 0);
-	dm_list_add(removal_list, &(lvl_array[1].list));
+	dm_list_add(removal_lvs, &(lvl_array[1].list));
 
 	if (!remove_layer_from_lv(lv, seg_lv(seg, 0)))
 		return_0;
@@ -377,13 +377,6 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 	struct logical_volume *tmp_lv;
 	const struct segment_type *segtype;
 
-	if (!ah) {
-		log_error(INTERNAL_ERROR
-			  "Stand-alone %s area allocation not implemented",
-			  (type == RAID_META) ? "metadata" : "data");
-		return 0;
-	}
-
 	switch (type) {
 	case RAID_META:
 		type_suffix = "rmeta";
@@ -409,12 +402,14 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
+	if (ah) {
+		if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+			return_0;
 
-	if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
-		log_error("Failed to add segment to LV, %s", img_name);
-		return 0;
+		if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
+			log_error("Failed to add segment to LV, %s", img_name);
+			return 0;
+		}
 	}
 
 	lv_set_visible(tmp_lv);
@@ -432,7 +427,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 	uint32_t extents;
 	struct lv_segment *seg = first_seg(lv);
 	const struct segment_type *segtype;
-	struct alloc_handle *ah;
+	struct alloc_handle *ah = NULL;
 	struct dm_list *parallel_areas;
 	struct lv_list *lvl_array;
 
@@ -473,7 +468,9 @@ static int _alloc_image_components(struct logical_volume *lv,
 			   (lv->le_count / (seg->area_count - segtype->parity_devs)) :
 			   lv->le_count;
 
-	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
+	/* Do we need to allocate any extents? */
+	if (pvs && !dm_list_empty(pvs) &&
+	    !(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
 				    region_size, extents, pvs,
 				    lv->alloc, 0, parallel_areas)))
 		return_0;
@@ -485,19 +482,25 @@ static int _alloc_image_components(struct logical_volume *lv,
 		 * allocated areas.  Thus, the metadata areas are pulled
 		 * from 's + count'.
 		 */
-		if (!(lvl_array[s + count].lv =
-		      _alloc_image_component(lv, NULL, ah, s + count, RAID_META))) {
-			alloc_destroy(ah);
-			return_0;
+
+		/* new_meta_lvs are optional for raid0 */
+		if (new_meta_lvs) {
+			if (!(lvl_array[s + count].lv =
+			      _alloc_image_component(lv, NULL, ah, s + count, RAID_META))) {
+				alloc_destroy(ah);
+				return_0;
+			}
+			dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
 		}
-		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
 
-		if (!(lvl_array[s].lv =
-		      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE))) {
-			alloc_destroy(ah);
-			return_0;
+		if (new_data_lvs) {
+			if (!(lvl_array[s].lv =
+			      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE))) {
+				alloc_destroy(ah);
+				return_0;
+			}
+			dm_list_add(new_data_lvs, &(lvl_array[s].list));
 		}
-		dm_list_add(new_data_lvs, &(lvl_array[s].list));
 	}
 
 	alloc_destroy(ah);
@@ -955,16 +958,16 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 static int _raid_remove_images(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs)
 {
-	struct dm_list removal_list;
+	struct dm_list removal_lvs;
 	struct lv_list *lvl;
 
 	if (!archive(lv->vg))
 		return_0;
 
-	dm_list_init(&removal_list);
+	dm_list_init(&removal_lvs);
 
 	if (!_raid_extract_images(lv, new_count, pvs, 1,
-				 &removal_list, &removal_list)) {
+				 &removal_lvs, &removal_lvs)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -972,7 +975,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 
 	/* Convert to linear? */
 	if (new_count == 1) {
-		if (!_raid_remove_top_layer(lv, &removal_list)) {
+		if (!_raid_remove_top_layer(lv, &removal_lvs)) {
 			log_error("Failed to remove RAID layer"
 				  " after linear conversion");
 			return 0;
@@ -1005,7 +1008,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	 * and won't conflict with the remaining (possibly shifted)
 	 * sub-LVs.
 	 */
-	dm_list_iterate_items(lvl, &removal_list) {
+	dm_list_iterate_items(lvl, &removal_lvs) {
 		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
 			log_error("Failed to resume extracted LVs");
 			return 0;
@@ -1027,8 +1030,8 @@ static int _raid_remove_images(struct logical_volume *lv,
 	/*
 	 * Eliminate the extracted LVs
 	 */
-	if (!dm_list_empty(&removal_list)) {
-		dm_list_iterate_items(lvl, &removal_list) {
+	if (!dm_list_empty(&removal_lvs)) {
+		dm_list_iterate_items(lvl, &removal_lvs) {
 			if (!deactivate_lv(lv->vg->cmd, lvl->lv))
 				return_0;
 			if (!lv_remove(lvl->lv))
@@ -1089,14 +1092,14 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs)
 {
 	struct lv_list *lvl;
-	struct dm_list removal_list, data_list;
+	struct dm_list removal_lvs, data_list;
 	struct cmd_context *cmd = lv->vg->cmd;
 	uint32_t old_count = lv_raid_image_count(lv);
 	struct logical_volume *tracking;
 	struct dm_list tracking_pvs;
 	int historical;
 
-	dm_list_init(&removal_list);
+	dm_list_init(&removal_lvs);
 	dm_list_init(&data_list);
 
 	if (is_lockd_type(lv->vg->lock_type)) {
@@ -1151,14 +1154,14 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	}
 
 	if (!_raid_extract_images(lv, new_count, splittable_pvs, 1,
-				 &removal_list, &data_list)) {
+				 &removal_lvs, &data_list)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
 	/* Convert to linear? */
-	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_list)) {
+	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_lvs)) {
 		log_error("Failed to remove RAID layer after linear conversion");
 		return 0;
 	}
@@ -1197,7 +1200,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
 
-	dm_list_iterate_items(lvl, &removal_list)
+	dm_list_iterate_items(lvl, &removal_lvs)
 		if (!activate_lv_excl_local(cmd, lvl->lv))
 			return_0;
 
@@ -1217,7 +1220,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	/*
 	 * Eliminate the residual LVs
 	 */
-	dm_list_iterate_items(lvl, &removal_list) {
+	dm_list_iterate_items(lvl, &removal_lvs) {
 		if (!deactivate_lv(cmd, lvl->lv))
 			return_0;
 
@@ -1365,6 +1368,9 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	return 1;
 }
 
+/*
+ * General conversion functions
+ */
 static int _convert_mirror_to_raid1(struct logical_volume *lv,
 				    const struct segment_type *new_segtype)
 {
@@ -1460,6 +1466,470 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	return 1;
 }
 
+/* Add new @lvs to @lv at @area_offset */
+static int _add_image_component_list(struct lv_segment *seg, int delete_from_list,
+				     uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)
+{
+	uint32_t s = area_offset;
+	struct lv_list *lvl, *tmp;
+
+	dm_list_iterate_items_safe(lvl, tmp, lvs) {
+		if (delete_from_list)
+			dm_list_del(&lvl->list);
+
+		if (lv_flags & VISIBLE_LV)
+			lv_set_visible(lvl->lv);
+		else
+			lv_set_hidden(lvl->lv);
+
+		if (lv_flags & LV_REBUILD)
+			lvl->lv->status |= LV_REBUILD;
+		else
+			lvl->lv->status &= ~LV_REBUILD;
+
+		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0 /* le */, lvl->lv->status)) {
+			log_error("Failed to add sublv %s", lvl->lv->name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * All areas from LV segments are moved to new
+ * segments allocated with area_count=1 for data_lvs.
+ */
+static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
+						    struct dm_list *data_lvs)
+{
+	uint32_t s = 0, le;
+	struct logical_volume *dlv;
+	struct lv_segment *seg_from, *seg_new;
+	struct lv_list *lvl;
+	struct segment_type *segtype;
+	uint64_t status;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	/* Move segment areas across to the N data LVs of the new raid0 LV */
+	dm_list_iterate_items(lvl, data_lvs)  {
+		dlv = lvl->lv;
+		le = 0;
+		dm_list_iterate_items(seg_from, &lv->segments) {
+			status = RAID | SEG_RAID | (seg_from->status & (LVM_READ | LVM_WRITE));
+
+			/* Allocate a data LV segment with one area for each segment in the striped LV */
+			if (!(seg_new = alloc_lv_segment(segtype, dlv,
+							 le, seg_from->area_len,
+							 status,
+							 0 /* stripe_size */, NULL, 1 /* area_count */,
+							 seg_from->area_len,
+							 0 /* chunk_size */, 0 /* region_size */, 0, NULL)))
+				return_0;
+
+			seg_type(seg_new, 0) = AREA_UNASSIGNED;
+			dm_list_add(&dlv->segments, &seg_new->list);
+			le += seg_from->area_len;
+
+			/* Move the respective area across to our new segment */
+			if (!move_lv_segment_area(seg_new, 0, seg_from, s))
+				return_0;
+		}
+
+		/* Adjust le count and LV size */
+		dlv->le_count = le;
+		dlv->size = (uint64_t) le * lv->vg->extent_size;
+		s++;
+	}
+
+	/* Remove the empty segments from the striped LV */
+	dm_list_init(&lv->segments);
+
+	return 1;
+}
+
+/*
+ * Find the smallest area across all the subLV segments at area_le.
+ */
+static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
+{
+	uint32_t s, area_len = ~0U;
+	struct lv_segment *seg1;
+
+	/* Find smallest segment of each of the data image LVs at offset area_le */
+	for (s = 0; s < seg->area_count; s++) {
+		seg1 = find_seg_by_le(seg_lv(seg, s), area_le);
+		area_len = min(area_len, seg1->len);
+	}
+
+	return area_len;
+}
+
+/*
+ * Split segments in segment LVs in all areas of seg at offset area_le
+ */
+static int _split_area_lvs_segments(struct lv_segment *seg, uint32_t area_le)
+{
+	uint32_t s;
+
+	/* Make sure that there's a segment starting at area_le in all data LVs */
+	for (s = 0; s < seg->area_count; s++)
+		if (area_le < seg_lv(seg, s)->le_count &&
+		    !lv_split_segment(seg_lv(seg, s), area_le))
+			return_0;
+
+	return 1;
+}
+
+static int _alloc_and_add_new_striped_segment(struct logical_volume *lv,
+					      uint32_t le, uint32_t area_len,
+					      struct dm_list *new_segments)
+{
+	struct lv_segment *seg, *new_seg;
+	struct segment_type *striped_segtype;
+
+	seg = first_seg(lv);
+
+	if (!(striped_segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	/* Allocate a segment with seg->area_count areas */
+	if (!(new_seg = alloc_lv_segment(striped_segtype, lv, le, area_len * seg->area_count,
+					 seg->status & ~RAID,
+					 seg->stripe_size, NULL, seg->area_count,
+					 area_len, seg->chunk_size, 0, 0, NULL)))
+		return_0;
+
+	dm_list_add(new_segments, &new_seg->list);
+
+	return 1;
+}
+
+static int _extract_image_component_error_seg(struct lv_segment *seg,
+					      uint64_t type, uint32_t idx,
+					      struct logical_volume **extracted_lv,
+					      int set_error_seg)
+{
+	struct logical_volume *lv;
+
+	switch (type) {
+		case RAID_META:
+			lv = seg_metalv(seg, idx);
+			seg_metalv(seg, idx) = NULL;
+			seg_metatype(seg, idx) = AREA_UNASSIGNED;
+			break;
+		case RAID_IMAGE:
+			lv = seg_lv(seg, idx);
+			seg_lv(seg, idx) = NULL;
+			seg_type(seg, idx) = AREA_UNASSIGNED;
+			break;
+		default:
+			log_error(INTERNAL_ERROR "Bad type provided to %s.", __func__);
+			return 0;
+	}
+
+	log_very_verbose("Extracting image component %s from %s", lv->name, lvseg_name(seg));
+	lv->status &= ~(type | RAID);
+	lv_set_visible(lv);
+
+	/* remove reference from seg to lv */
+	if (!remove_seg_from_segs_using_this_lv(lv, seg))
+		return_0;
+
+	if (!(lv->name = _generate_raid_name(lv, "extracted_", -1)))
+		return_0;
+
+	if (set_error_seg && !replace_lv_with_error_segment(lv))
+		return_0;
+
+	*extracted_lv = lv;
+
+	return 1;
+}
+
+/*
+ * Extract all sub LVs of type from seg starting at idx excluding end and
+ * put them on removal_lvs setting mappings to "error" if error_seg.
+ */
+static int _extract_image_component_sublist(struct lv_segment *seg,
+					    uint64_t type, uint32_t idx, uint32_t end,
+					    struct dm_list *removal_lvs,
+					    int error_seg)
+{
+	uint32_t s;
+	struct lv_list *lvl;
+
+	if (!(lvl = dm_pool_alloc(seg_lv(seg, idx)->vg->vgmem, sizeof(*lvl) * (end - idx))))
+		return_0;
+
+	for (s = idx; s < end; s++) {
+		if (!_extract_image_component_error_seg(seg, type, s, &lvl->lv, error_seg))
+			return 0;
+
+		dm_list_add(removal_lvs, &lvl->list);
+		lvl++;
+	}
+
+	if (!idx && end == seg->area_count) {
+		if (type == RAID_IMAGE)
+			seg->areas = NULL;
+		else
+			seg->meta_areas = NULL;
+	}
+
+	return 1;
+}
+
+/* Extract all sub LVs of type from seg starting with idx and put them on removal_Lvs */
+static int _extract_image_component_list(struct lv_segment *seg,
+					 uint64_t type, uint32_t idx,
+					 struct dm_list *removal_lvs)
+{
+	return _extract_image_component_sublist(seg, type, idx, seg->area_count, removal_lvs, 1);
+}
+
+/*
+ * All areas from lv image component LV's segments are
+ * being split at "striped" compatible boundaries and
+ * moved to allocated new_segments.
+ *
+ * The data component LVs are mapped to an
+ * error target and linked to removal_lvs for disposal
+ * by the caller.
+ */
+static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
+						       struct dm_list *removal_lvs)
+{
+	uint32_t s, area_le, area_len, le;
+	struct lv_segment *data_seg, *seg, *seg_to;
+	struct dm_list new_segments;
+
+	seg = first_seg(lv);
+
+	dm_list_init(&new_segments);
+
+	/*
+	 * Walk all segments of all data LVs splitting them up at proper boundaries
+	 * and create the number of new striped segments we need to move them across
+	 */
+	area_le = le = 0;
+	while (le < lv->le_count) {
+		area_len = _min_sublv_area_at_le(seg, area_le);
+		area_le += area_len;
+
+		if (!_split_area_lvs_segments(seg, area_le) ||
+		    !_alloc_and_add_new_striped_segment(lv, le, area_len, &new_segments))
+			return_0;
+
+		le = area_le * seg->area_count;
+	}
+
+	/* Now move the prepared split areas across to the new segments */
+	area_le = 0;
+	dm_list_iterate_items(seg_to, &new_segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			data_seg = find_seg_by_le(seg_lv(seg, s), area_le);
+
+			/* Move the respective area across to our new segments area */
+			if (!move_lv_segment_area(seg_to, s, data_seg, 0))
+				return_0;
+		}
+
+		/* Presumes all data LVs have equal size */
+		area_le += data_seg->len;
+	}
+
+	/* Extract any metadata LVs and the empty data LVs for disposal by the caller */
+	if (!_extract_image_component_list(seg, RAID_IMAGE, 0, removal_lvs))
+		return_0;
+
+	/*
+	 * Remove the one segment holding the image component areas
+	 * from the top-level LV, then add the new segments to it
+	 */
+	dm_list_del(&seg->list);
+	dm_list_splice(&lv->segments, &new_segments);
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
+	dm_list_iterate_items(lvl, removal_lvs)
+		if (!deactivate_lv(vg->cmd, lvl->lv) ||
+		    !lv_remove(lvl->lv))
+			return_0;
+
+	return 1;
+}
+
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
+ * Eliminate the extracted LVs on @removal_lvs from @vg incl. vg write, commit and backup 
+ */
+static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
+						      struct dm_list *removal_lvs,
+						      int vg_write_requested)
+{
+	if (!removal_lvs || dm_list_empty(removal_lvs))
+		return 1;
+
+	if (!_deactivate_and_remove_lvs(vg, removal_lvs))
+		return_0;
+
+	dm_list_init(removal_lvs);
+
+	/* Wait for events following any deactivation. */
+	sync_local_dev_names(vg->cmd);
+
+	if (vg_write_requested && !_vg_write_commit_backup(vg))
+		return_0;
+
+	return 1;
+}
+
+static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
+{
+	return _eliminate_extracted_lvs_optional_write_vg(vg, removal_lvs, 1);
+}
+/*
+ * Convert a RAID0 set to striped
+ */
+static int _convert_raid0_to_striped(struct logical_volume *lv,
+				     int update_and_reload,
+				     struct dm_list *removal_lvs)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	/* Move the AREA_PV areas across to new top-level segments of type "striped" */
+	if (!_raid0_to_striped_retrieve_segments_and_lvs(lv, removal_lvs)) {
+		log_error("Failed to retrieve raid0 segments from %s.", lv->name);
+		return 0;
+	}
+
+	lv->status &= ~RAID;
+
+	if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	if (update_and_reload) {
+		if (!lv_update_and_reload(lv))
+			return_0;
+
+		/* Eliminate the residual LVs, write VG, commit it and take a backup */
+		return _eliminate_extracted_lvs(lv->vg, removal_lvs);
+	} 
+
+	return 1;
+}
+
+/*
+ * Inserts hidden LVs for all segments and the parallel areas in lv and moves 
+ * given segments and areas across.
+ *
+ * Optionally updates metadata and reloads mappings.
+ */
+static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
+						    int update_and_reload,
+						    struct dm_list *allocate_pvs)
+{
+	uint32_t area_count, area_len = 0, stripe_size;
+	struct lv_segment *seg, *raid0_seg;
+	struct segment_type *segtype;
+	struct dm_list data_lvs;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		area_len += seg->area_len;
+
+	seg = first_seg(lv);
+	stripe_size = seg->stripe_size;
+	area_count = seg->area_count;
+
+	/* Check for not (yet) supported varying area_count on multi-segment striped LVs */
+	if (!lv_has_constant_stripes(lv)) {
+		log_error("Cannot convert striped LV %s with varying stripe count to raid0",
+			  display_lvname(lv));
+		return NULL;
+	}
+
+	if (!is_power_of_2(seg->stripe_size)) {
+		log_error("Cannot convert striped LV %s with non-power of 2 stripe size %u",
+			  display_lvname(lv), seg->stripe_size);
+		// log_error("Please use \"lvconvert --duplicate ...\"");
+		return NULL;
+	}
+
+	if (!(segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0)))
+		return_NULL;
+
+	/* Allocate empty rimage components */
+	dm_list_init(&data_lvs);
+	if (!_alloc_image_components(lv, NULL, area_count, NULL, &data_lvs)) {
+		log_error("Failed to allocate empty image components for raid0 LV %s.",
+			  display_lvname(lv));
+		return NULL;
+	}
+
+	/* Move the AREA_PV areas across to the new rimage components; empties lv->segments */
+	if (!_striped_to_raid0_move_segs_to_raid0_lvs(lv, &data_lvs)) {
+		log_error("Failed to insert linear LVs underneath %s.", display_lvname(lv));
+		return NULL;
+	}
+
+	/*
+	 * Allocate single segment to hold the image component
+	 * areas based on the first data LVs properties derived
+	 * from the first new raid0 LVs first segment
+	 */
+	seg = first_seg(dm_list_item(dm_list_first(&data_lvs), struct lv_list)->lv);
+	if (!(raid0_seg = alloc_lv_segment(segtype, lv,
+					   0 /* le */, lv->le_count /* len */,
+					   seg->status | SEG_RAID,
+					   stripe_size, NULL /* log_lv */,
+					   area_count, area_len,
+					   0 /* chunk_size */,
+					   0 /* seg->region_size */, 0u /* extents_copied */ ,
+					   NULL /* pvmove_source_seg */))) {
+		log_error("Failed to allocate new raid0 segement for LV %s.", display_lvname(lv));
+		return NULL;
+	}
+
+	/* Add new single raid0 segment to emptied LV segments list */
+	dm_list_add(&lv->segments, &raid0_seg->list);
+
+	/* Add data LVs to the top-level LVs segment; resets LV_REBUILD flag on them */
+	if (!_add_image_component_list(raid0_seg, 1, 0, &data_lvs, 0))
+		return NULL;
+
+	lv->status |= RAID;
+
+	if (update_and_reload && !lv_update_and_reload(lv))
+		return NULL;
+
+	return raid0_seg;
+}
+
 /*
  * Individual takeover functions.
  */
@@ -1480,7 +1950,7 @@ typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);
  */
 static int _takeover_noop(TAKEOVER_FN_ARGS)
 {
-	log_error("Logical volume %s is already of requested type %s",
+	log_error("Logical volume %s is already of requested type %s.",
 		  display_lvname(lv), lvseg_name(first_seg(lv)));
 
 	return 0;
@@ -1500,9 +1970,9 @@ static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 static int _takeover_not_possible(takeover_fn_t takeover_fn)
 {
 	if (takeover_fn == _takeover_noop || takeover_fn == _takeover_unsupported)
-		return 0;
+		return 1;
 
-	return 1;
+	return 0;
 }
 
 static int _takeover_unsupported_yet(const struct logical_volume *lv, const struct segment_type *new_segtype)
@@ -1598,7 +2068,16 @@ static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+        /* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* FIXME update_and_reload is only needed if the LV is already active */
+	return _convert_raid0_to_striped(lv, 1, &removal_lvs);
 }
 
 /*
@@ -1743,9 +2222,26 @@ static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 	return _takeover_unsupported_yet(lv, new_segtype);
 }
 
+static int _striped_to_raid0_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     int yes, int force, int alloc_metadata_devs,
+				     struct dm_list *allocate_pvs)
+{
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* FIXME update_and_reload is only needed if the LV is already active */
+	/* FIXME Some of the validation in here needs moving before the archiving */
+	if (!_convert_striped_to_raid0(lv, 1 /* update_and_reload */, allocate_pvs))
+		return_0;
+
+	return 1;
+}
+
 static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _striped_to_raid0_wrapper(lv, new_segtype, yes, force, 0, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid01(TAKEOVER_FN_ARGS)
@@ -1921,6 +2417,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, new_stripe_size, allocate_pvs);
 
 	/* FIXME If not active, prompt and activate */
+	/* FIXME Some operations do not require the LV to be active */
 	/* LV must be active to perform raid conversion operations */
 	if (!lv_is_active(lv)) {
 		log_error("%s must be active to perform this operation.",
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 0e17111..8d8b28c 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -34,3 +34,16 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 
 	return segtype;
 }
+
+struct segment_type *get_segtype_from_flag(struct cmd_context *cmd, uint64_t flag)
+{
+	struct segment_type *segtype;
+
+	dm_list_iterate_items(segtype, &cmd->segtypes)
+		if (flag & segtype->flags)
+			return segtype;
+
+	log_error(INTERNAL_ERROR "Unrecognised segment type flag 0x%" PRIu64, flag);
+
+	return NULL;
+}
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index f3b1510..b43f228 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -222,6 +222,8 @@ struct segtype_handler {
 
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str);
+struct segment_type *get_segtype_from_flag(struct cmd_context *cmd,
+					   uint64_t flag);
 
 struct segtype_library;
 int lvm_register_segtype(struct segtype_library *seglib,
diff --git a/lib/misc/util.h b/lib/misc/util.h
index 1011fdd..730b903 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -27,6 +27,8 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
+#define is_power_of_2(n) ((n) && !((n) & ((n) - 1)))
+
 #if defined(__clang__) || (defined(__GNUC__) && __GNUC__ >= 4 && __GNUC_MINOR__ >= 6)
 #define uninitialized_var(x) x
 #else


