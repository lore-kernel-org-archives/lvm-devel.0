From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 24 Jul 2016 00:31:41 +0000 (UTC)
Subject: master - raid_manip: Reorder some functions.
Message-ID: <20160724003141.8E7C060CB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a544ae272c172d0ba63096c488688a69f997e98
Commit:        4a544ae272c172d0ba63096c488688a69f997e98
Parent:        f6acf922e625912e88e064fb03a5188bdcc8bb43
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Jul 24 01:31:30 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Jul 24 01:31:30 2016 +0100

raid_manip: Reorder some functions.

---
 lib/metadata/raid_manip.c |  858 +++++++++++++++++++++++----------------------
 1 files changed, 433 insertions(+), 425 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2dbbbe4..2470532 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -33,6 +33,21 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 	return 1;
 }
 
+/*
+ * Check for maximum number of raid devices.
+ * Constrained by kernel MD maximum device limits _and_ dm-raid superblock
+ * bitfield constraints.
+ */
+static int _check_max_raid_devices(uint32_t image_count)
+{
+	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
+		log_error("Unable to handle arrays with more than %u devices",
+			  DEFAULT_RAID_MAX_IMAGES);
+		return 0;
+	}
+	return 1;
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -85,6 +100,37 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 	return 1;
 }
 
+static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
+{
+	struct dm_list *allocate_pvs = (struct dm_list *) data;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, allocate_pvs)
+		if (!lv_is_partial(lv) && lv_is_on_pv(lv, pvl->pv))
+			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
+
+	return 1;
+}
+
+/*
+ * Prevent any PVs holding other image components of @lv from being used for allocation
+ * by setting the internal PV_ALLOCATION_PROHIBITED flag to use it to avoid generating
+ * pv maps for those PVs.
+ */
+static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+{
+	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+}
+
+static void _clear_allocation_prohibited(struct dm_list *pvs)
+{
+	struct pv_list *pvl;
+
+	if (pvs)
+		dm_list_iterate_items(pvl, pvs)
+			pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
+}
+
 /*
  * _raid_in_sync
  * @lv
@@ -1387,103 +1433,57 @@ int lv_raid_merge(struct logical_volume *image_lv)
 }
 
 /*
- * General conversion functions
+ * Deactivate and remove the LVs on removal_lvs list from vg.
  */
-static int _convert_mirror_to_raid1(struct logical_volume *lv,
-				    const struct segment_type *new_segtype)
+static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
 {
-	uint32_t s;
-	struct lv_segment *seg = first_seg(lv);
-	struct lv_list lvl_array[seg->area_count], *lvl;
-	struct dm_list meta_lvs;
-	struct lv_segment_area *meta_areas;
-	char *new_name;
+	struct lv_list *lvl;
 
-	dm_list_init(&meta_lvs);
+	dm_list_iterate_items(lvl, removal_lvs)
+		if (!deactivate_lv(vg->cmd, lvl->lv) ||
+		    !lv_remove(lvl->lv))
+			return_0;
 
-	if (!_raid_in_sync(lv)) {
-		log_error("Unable to convert %s/%s while it is not in-sync",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+	return 1;
+}
 
-	if (!(meta_areas = dm_pool_zalloc(lv->vg->vgmem,
-					  lv_mirror_count(lv) * sizeof(*meta_areas)))) {
-		log_error("Failed to allocate meta areas memory.");
-		return 0;
-	}
+/*
+ * Allocate metadata devs for all @new_data_devs and link them to list @new_meta_lvs
+ */
+static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
+					     struct dm_list *new_data_lvs,
+					     struct dm_list *new_meta_lvs,
+					     struct dm_list *allocate_pvs)
+{
+	uint32_t a = 0, raid_devs = dm_list_size(new_data_lvs);
+	struct lv_list *lvl, *lvl1, *lvl_array;
 
-	if (!archive(lv->vg))
+	if (!raid_devs)
 		return_0;
 
-	for (s = 0; s < seg->area_count; s++) {
-		log_debug_metadata("Allocating new metadata LV for %s",
-				   seg_lv(seg, s)->name);
-		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv), NULL)) {
-			log_error("Failed to allocate metadata LV for %s in %s",
-				  seg_lv(seg, s)->name, lv->name);
-			return 0;
-		}
-		dm_list_add(&meta_lvs, &(lvl_array[s].list));
-	}
-
-	log_debug_metadata("Clearing newly allocated metadata LVs");
-	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs");
-		return 0;
-	}
-
-	if (seg->log_lv) {
-		log_debug_metadata("Removing mirror log, %s", seg->log_lv->name);
-		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
-			log_error("Failed to remove mirror log");
-			return 0;
-		}
-	}
-
-	seg->meta_areas = meta_areas;
-	s = 0;
-
-	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug_metadata("Adding %s to %s", lvl->lv->name, lv->name);
+	if (!(lvl_array = dm_pool_zalloc(lv->vg->vgmem, raid_devs * sizeof(*lvl_array))))
+		return_0;
 
-		/* Images are known to be in-sync */
-		lvl->lv->status &= ~LV_REBUILD;
-		first_seg(lvl->lv)->status &= ~LV_REBUILD;
-		lv_set_hidden(lvl->lv);
+	dm_list_iterate_items(lvl, new_data_lvs) {
+		log_debug_metadata("Allocating new metadata LV for %s", lvl->lv->name);
 
-		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
-					    lvl->lv->status)) {
-			log_error("Failed to add %s to %s",
-				  lvl->lv->name, lv->name);
+		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
+			log_error("Failed to allocate metadata LV for %s in %s",
+				  lvl->lv->name, lv->vg->name);
 			return 0;
 		}
-		s++;
-	}
 
-	for (s = 0; s < seg->area_count; ++s) {
-		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
-			return_0;
-		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
-		seg_lv(seg, s)->name = new_name;
-		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
-		seg_lv(seg, s)->status |= RAID_IMAGE;
+		dm_list_add(new_meta_lvs, &lvl_array[a++].list);
+		
+		dm_list_iterate_items(lvl1, new_meta_lvs)
+			if (!_avoid_pvs_with_other_images_of_lv(lvl1->lv, allocate_pvs))
+				return_0;
 	}
-	init_mirror_in_sync(1);
-
-	log_debug_metadata("Setting new segtype for %s", lv->name);
-	seg->segtype = new_segtype;
-	lv->status &= ~MIRROR;
-	lv->status &= ~MIRRORED;
-	lv->status |= RAID;
-	seg->status |= RAID;
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	_clear_allocation_prohibited(allocate_pvs);
 
 	return 1;
 }
-
 /* Add new @lvs to @lv at @area_offset */
 static int _add_image_component_list(struct lv_segment *seg, int delete_from_list,
 				     uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)
@@ -1515,82 +1515,6 @@ static int _add_image_component_list(struct lv_segment *seg, int delete_from_lis
 }
 
 /*
- * All areas from LV segments are moved to new
- * segments allocated with area_count=1 for data_lvs.
- */
-static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
-						    struct dm_list *data_lvs)
-{
-	uint32_t s = 0, le;
-	struct logical_volume *dlv;
-	struct lv_segment *seg_from, *seg_new;
-	struct lv_list *lvl;
-	struct segment_type *segtype;
-	uint64_t status;
-
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
-
-	/* Move segment areas across to the N data LVs of the new raid0 LV */
-	dm_list_iterate_items(lvl, data_lvs)  {
-		dlv = lvl->lv;
-		le = 0;
-		dm_list_iterate_items(seg_from, &lv->segments) {
-			status = RAID | SEG_RAID | (seg_from->status & (LVM_READ | LVM_WRITE));
-
-			/* Allocate a data LV segment with one area for each segment in the striped LV */
-			if (!(seg_new = alloc_lv_segment(segtype, dlv,
-							 le, seg_from->area_len,
-							 status,
-							 0 /* stripe_size */, NULL, 1 /* area_count */,
-							 seg_from->area_len,
-							 0 /* chunk_size */, 0 /* region_size */, 0, NULL)))
-				return_0;
-
-			seg_type(seg_new, 0) = AREA_UNASSIGNED;
-			dm_list_add(&dlv->segments, &seg_new->list);
-			le += seg_from->area_len;
-
-			/* Move the respective area across to our new segment */
-			if (!move_lv_segment_area(seg_new, 0, seg_from, s))
-				return_0;
-		}
-
-		/* Adjust le count and LV size */
-		dlv->le_count = le;
-		dlv->size = (uint64_t) le * lv->vg->extent_size;
-		s++;
-	}
-
-	/* Remove the empty segments from the striped LV */
-	dm_list_init(&lv->segments);
-
-	return 1;
-}
-
-/*
- * Find the smallest area across all the subLV segments at area_le.
- */
-static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
-{
-	uint32_t s, area_len = ~0U;
-	struct lv_segment *seg1;
-
-	/* Find smallest segment of each of the data image LVs at offset area_le */
-	for (s = 0; s < seg->area_count; s++) {
-		if (!(seg1 = find_seg_by_le(seg_lv(seg, s), area_le))) {
-			log_error("Failed to find segment for %s extent %" PRIu32,
-				  seg_lv(seg, s)->name, area_le);
-			return 0;
-		}
-
-		area_len = min(area_len, seg1->len);
-	}
-
-	return area_len;
-}
-
-/*
  * Split segments in segment LVs in all areas of seg at offset area_le
  */
 static int _split_area_lvs_segments(struct lv_segment *seg, uint32_t area_le)
@@ -1714,90 +1638,72 @@ static int _extract_image_component_list(struct lv_segment *seg,
 }
 
 /*
- * All areas from lv image component LV's segments are
- * being split at "striped" compatible boundaries and
- * moved to allocated new_segments.
- *
- * The data component LVs are mapped to an
- * error target and linked to removal_lvs for disposal
- * by the caller.
+ * Allocate metadata devs for all data devs of an LV
  */
-static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
-						       struct dm_list *removal_lvs)
+static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
+				    struct dm_list *meta_lvs,
+				    struct dm_list *allocate_pvs)
 {
-	uint32_t s, area_le, area_len, le;
-	struct lv_segment *data_seg = NULL, *seg, *seg_to;
-	struct dm_list new_segments;
+	uint32_t s;
+	struct lv_list *lvl_array;
+	struct dm_list data_lvs;
+	struct lv_segment *seg = first_seg(lv);
 
-	seg = first_seg(lv);
+	dm_list_init(&data_lvs);
 
-	dm_list_init(&new_segments);
-
-	/*
-	 * Walk all segments of all data LVs splitting them up at proper boundaries
-	 * and create the number of new striped segments we need to move them across
-	 */
-	area_le = le = 0;
-	while (le < lv->le_count) {
-		if (!(area_len = _min_sublv_area_at_le(seg, area_le)))
-			return_0;
-		area_le += area_len;
+	if (!(seg->meta_areas = dm_pool_zalloc(lv->vg->vgmem, seg->area_count * sizeof(*seg->meta_areas))))
+		return 0;
 
-		if (!_split_area_lvs_segments(seg, area_le) ||
-		    !_alloc_and_add_new_striped_segment(lv, le, area_len, &new_segments))
-			return_0;
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
+		return_0;
 
-		le = area_le * seg->area_count;
+	for (s = 0; s < seg->area_count; s++) {
+		lvl_array[s].lv = seg_lv(seg, s);
+		dm_list_add(&data_lvs, &lvl_array[s].list);
 	}
 
-	/* Now move the prepared split areas across to the new segments */
-	area_le = 0;
-	dm_list_iterate_items(seg_to, &new_segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (!(data_seg = find_seg_by_le(seg_lv(seg, s), area_le))) {
-				log_error("Failed to find segment for %s extent %" PRIu32,
-					  seg_lv(seg, s)->name, area_le);
-				return 0;
-			}
-
-			/* Move the respective area across to our new segments area */
-			if (!move_lv_segment_area(seg_to, s, data_seg, 0))
-				return_0;
-		}
-
-		/* Presumes all data LVs have equal size */
-		area_le += data_seg->len;
+	if (!_alloc_rmeta_devs_for_rimage_devs(lv, &data_lvs, meta_lvs, allocate_pvs)) {
+		log_error("Failed to allocate metadata LVs for %s", lv->name);
+		return 0;
 	}
 
-	/* Extract any metadata LVs and the empty data LVs for disposal by the caller */
-	if (!_extract_image_component_list(seg, RAID_IMAGE, 0, removal_lvs))
-		return_0;
-
-	/*
-	 * Remove the one segment holding the image component areas
-	 * from the top-level LV, then add the new segments to it
-	 */
-	dm_list_del(&seg->list);
-	dm_list_splice(&lv->segments, &new_segments);
-
 	return 1;
 }
 
 /*
- * Deactivate and remove the LVs on removal_lvs list from vg.
+ * Add metadata areas to raid0
  */
-static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
+static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
-	struct lv_list *lvl;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list meta_lvs;
 
-	dm_list_iterate_items(lvl, removal_lvs)
-		if (!deactivate_lv(vg->cmd, lvl->lv) ||
-		    !lv_remove(lvl->lv))
-			return_0;
+	dm_list_init(&meta_lvs);
+
+	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
+	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs)) {
+		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
+		return_0;
+	}
+
+	/* Metadata LVs must be cleared before being added to the array */
+	log_debug_metadata("Clearing newly allocated metadata LVs for %s", display_lvname(lv));
+	if (!_clear_lvs(&meta_lvs)) {
+		log_error("Failed to initialize metadata LVs for %s", display_lvname(lv));
+		return_0;
+	}
+
+	/* Set segment areas for metadata sub_lvs */
+	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
+	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
+		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));
+		return_0;
+	}
 
 	return 1;
 }
 
+
 /* FIXME Move this out */
 /* Write, commit and optionally backup metadata of vg */
 static int _vg_write_commit_backup(struct volume_group *vg)
@@ -1846,207 +1752,292 @@ static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *rem
 	return _eliminate_extracted_lvs_optional_write_vg(vg, removal_lvs, 1);
 }
 
-static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
+/*
+ * Add/remove metadata areas to/from raid0
+ */
+static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
+					     int update_and_reload,
+					     struct dm_list *allocate_pvs,
+					     struct dm_list *removal_lvs)
 {
-	struct dm_list *allocate_pvs = (struct dm_list *) data;
-	struct pv_list *pvl;
+	uint64_t new_raid_type_flag;
+	struct lv_segment *seg = first_seg(lv);
 
-	dm_list_iterate_items(pvl, allocate_pvs)
-		if (!lv_is_partial(lv) && lv_is_on_pv(lv, pvl->pv))
-			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
+	if (removal_lvs) {
+		if (seg->meta_areas) {
+			if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs))
+				return_0;
+			seg->meta_areas = NULL;
+		}
+		new_raid_type_flag = SEG_RAID0;
+	} else {
+		if (!_alloc_and_add_rmeta_devs_for_lv(lv, allocate_pvs))
+			return 0;
+
+		new_raid_type_flag = SEG_RAID0_META;
+	}
+
+	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, new_raid_type_flag)))
+		return_0;
+
+	if (update_and_reload) {
+		if (!lv_update_and_reload_origin(lv))
+			return_0;
+
+		/* If any residual LVs, eliminate them, write VG, commit it and take a backup */
+		return _eliminate_extracted_lvs(lv->vg, removal_lvs);
+	}
 
 	return 1;
 }
 
 /*
- * Prevent any PVs holding other image components of @lv from being used for allocation
- * by setting the internal PV_ALLOCATION_PROHIBITED flag to use it to avoid generating
- * pv maps for those PVs.
+ * General conversion functions
  */
-static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
-{
-	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
-}
-
-static void _clear_allocation_prohibited(struct dm_list *pvs)
-{
-	struct pv_list *pvl;
-
-	if (pvs)
-		dm_list_iterate_items(pvl, pvs)
-			pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
-}
 
 /*
- * Allocate metadata devs for all @new_data_devs and link them to list @new_meta_lvs
+ * Convert a RAID0 set to striped
  */
-static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
-					     struct dm_list *new_data_lvs,
-					     struct dm_list *new_meta_lvs,
-					     struct dm_list *allocate_pvs)
+static int _convert_mirror_to_raid1(struct logical_volume *lv,
+				    const struct segment_type *new_segtype)
 {
-	uint32_t a = 0, raid_devs = dm_list_size(new_data_lvs);
-	struct lv_list *lvl, *lvl1, *lvl_array;
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+	struct lv_list lvl_array[seg->area_count], *lvl;
+	struct dm_list meta_lvs;
+	struct lv_segment_area *meta_areas;
+	char *new_name;
 
-	if (!raid_devs)
-		return_0;
+	dm_list_init(&meta_lvs);
 
-	if (!(lvl_array = dm_pool_zalloc(lv->vg->vgmem, raid_devs * sizeof(*lvl_array))))
-		return_0;
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s/%s while it is not in-sync",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
 
-	dm_list_iterate_items(lvl, new_data_lvs) {
-		log_debug_metadata("Allocating new metadata LV for %s", lvl->lv->name);
+	if (!(meta_areas = dm_pool_zalloc(lv->vg->vgmem,
+					  lv_mirror_count(lv) * sizeof(*meta_areas)))) {
+		log_error("Failed to allocate meta areas memory.");
+		return 0;
+	}
 
-		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
+	if (!archive(lv->vg))
+		return_0;
+
+	for (s = 0; s < seg->area_count; s++) {
+		log_debug_metadata("Allocating new metadata LV for %s",
+				   seg_lv(seg, s)->name);
+		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv), NULL)) {
 			log_error("Failed to allocate metadata LV for %s in %s",
-				  lvl->lv->name, lv->vg->name);
+				  seg_lv(seg, s)->name, lv->name);
 			return 0;
 		}
+		dm_list_add(&meta_lvs, &(lvl_array[s].list));
+	}
 
-		dm_list_add(new_meta_lvs, &lvl_array[a++].list);
-		
-		dm_list_iterate_items(lvl1, new_meta_lvs)
-			if (!_avoid_pvs_with_other_images_of_lv(lvl1->lv, allocate_pvs))
-				return_0;
+	log_debug_metadata("Clearing newly allocated metadata LVs");
+	if (!_clear_lvs(&meta_lvs)) {
+		log_error("Failed to initialize metadata LVs");
+		return 0;
 	}
 
-	_clear_allocation_prohibited(allocate_pvs);
+	if (seg->log_lv) {
+		log_debug_metadata("Removing mirror log, %s", seg->log_lv->name);
+		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
+			log_error("Failed to remove mirror log");
+			return 0;
+		}
+	}
+
+	seg->meta_areas = meta_areas;
+	s = 0;
+
+	dm_list_iterate_items(lvl, &meta_lvs) {
+		log_debug_metadata("Adding %s to %s", lvl->lv->name, lv->name);
+
+		/* Images are known to be in-sync */
+		lvl->lv->status &= ~LV_REBUILD;
+		first_seg(lvl->lv)->status &= ~LV_REBUILD;
+		lv_set_hidden(lvl->lv);
+
+		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
+					    lvl->lv->status)) {
+			log_error("Failed to add %s to %s",
+				  lvl->lv->name, lv->name);
+			return 0;
+		}
+		s++;
+	}
+
+	for (s = 0; s < seg->area_count; ++s) {
+		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
+			return_0;
+		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
+		seg_lv(seg, s)->name = new_name;
+		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
+		seg_lv(seg, s)->status |= RAID_IMAGE;
+	}
+	init_mirror_in_sync(1);
+
+	log_debug_metadata("Setting new segtype for %s", lv->name);
+	seg->segtype = new_segtype;
+	lv->status &= ~MIRROR;
+	lv->status &= ~MIRRORED;
+	lv->status |= RAID;
+	seg->status |= RAID;
+
+	if (!lv_update_and_reload(lv))
+		return_0;
 
 	return 1;
 }
 
 /*
- * Allocate metadata devs for all data devs of an LV
+ * All areas from LV segments are moved to new
+ * segments allocated with area_count=1 for data_lvs.
  */
-static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
-				    struct dm_list *meta_lvs,
-				    struct dm_list *allocate_pvs)
+static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
+						    struct dm_list *data_lvs)
 {
-	uint32_t s;
-	struct lv_list *lvl_array;
-	struct dm_list data_lvs;
-	struct lv_segment *seg = first_seg(lv);
+	uint32_t s = 0, le;
+	struct logical_volume *dlv;
+	struct lv_segment *seg_from, *seg_new;
+	struct lv_list *lvl;
+	struct segment_type *segtype;
+	uint64_t status;
 
-	dm_list_init(&data_lvs);
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
 
-	if (!(seg->meta_areas = dm_pool_zalloc(lv->vg->vgmem, seg->area_count * sizeof(*seg->meta_areas))))
-		return 0;
+	/* Move segment areas across to the N data LVs of the new raid0 LV */
+	dm_list_iterate_items(lvl, data_lvs)  {
+		dlv = lvl->lv;
+		le = 0;
+		dm_list_iterate_items(seg_from, &lv->segments) {
+			status = RAID | SEG_RAID | (seg_from->status & (LVM_READ | LVM_WRITE));
 
-	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
-		return_0;
+			/* Allocate a data LV segment with one area for each segment in the striped LV */
+			if (!(seg_new = alloc_lv_segment(segtype, dlv,
+							 le, seg_from->area_len,
+							 status,
+							 0 /* stripe_size */, NULL, 1 /* area_count */,
+							 seg_from->area_len,
+							 0 /* chunk_size */, 0 /* region_size */, 0, NULL)))
+				return_0;
 
-	for (s = 0; s < seg->area_count; s++) {
-		lvl_array[s].lv = seg_lv(seg, s);
-		dm_list_add(&data_lvs, &lvl_array[s].list);
-	}
+			seg_type(seg_new, 0) = AREA_UNASSIGNED;
+			dm_list_add(&dlv->segments, &seg_new->list);
+			le += seg_from->area_len;
 
-	if (!_alloc_rmeta_devs_for_rimage_devs(lv, &data_lvs, meta_lvs, allocate_pvs)) {
-		log_error("Failed to allocate metadata LVs for %s", lv->name);
-		return 0;
+			/* Move the respective area across to our new segment */
+			if (!move_lv_segment_area(seg_new, 0, seg_from, s))
+				return_0;
+		}
+
+		/* Adjust le count and LV size */
+		dlv->le_count = le;
+		dlv->size = (uint64_t) le * lv->vg->extent_size;
+		s++;
 	}
 
+	/* Remove the empty segments from the striped LV */
+	dm_list_init(&lv->segments);
+
 	return 1;
 }
 
 /*
- * Add metadata areas to raid0
+ * Find the smallest area across all the subLV segments at area_le.
  */
-static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
 {
-	struct lv_segment *seg = first_seg(lv);
-	struct dm_list meta_lvs;
-
-	dm_list_init(&meta_lvs);
-
-	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
-	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs)) {
-		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
-		return_0;
-	}
+	uint32_t s, area_len = ~0U;
+	struct lv_segment *seg1;
 
-	/* Metadata LVs must be cleared before being added to the array */
-	log_debug_metadata("Clearing newly allocated metadata LVs for %s", display_lvname(lv));
-	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs for %s", display_lvname(lv));
-		return_0;
-	}
+	/* Find smallest segment of each of the data image LVs at offset area_le */
+	for (s = 0; s < seg->area_count; s++) {
+		if (!(seg1 = find_seg_by_le(seg_lv(seg, s), area_le))) {
+			log_error("Failed to find segment for %s extent %" PRIu32,
+				  seg_lv(seg, s)->name, area_le);
+			return 0;
+		}
 
-	/* Set segment areas for metadata sub_lvs */
-	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
-	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
-		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));
-		return_0;
+		area_len = min(area_len, seg1->len);
 	}
 
-	return 1;
+	return area_len;
 }
-
 /*
- * Add/remove metadata areas to/from raid0
+ * All areas from lv image component LV's segments are
+ * being split at "striped" compatible boundaries and
+ * moved to allocated new_segments.
+ *
+ * The data component LVs are mapped to an
+ * error target and linked to removal_lvs for disposal
+ * by the caller.
  */
-static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
-					     int update_and_reload,
-					     struct dm_list *allocate_pvs,
-					     struct dm_list *removal_lvs)
+static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
+						       struct dm_list *removal_lvs)
 {
-	uint64_t new_raid_type_flag;
-	struct lv_segment *seg = first_seg(lv);
+	uint32_t s, area_le, area_len, le;
+	struct lv_segment *data_seg = NULL, *seg, *seg_to;
+	struct dm_list new_segments;
 
-	if (removal_lvs) {
-		if (seg->meta_areas) {
-			if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs))
-				return_0;
-			seg->meta_areas = NULL;
-		}
-		new_raid_type_flag = SEG_RAID0;
-	} else {
-		if (!_alloc_and_add_rmeta_devs_for_lv(lv, allocate_pvs))
-			return 0;
+	seg = first_seg(lv);
 
-		new_raid_type_flag = SEG_RAID0_META;
-	}
+	dm_list_init(&new_segments);
 
-	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, new_raid_type_flag)))
-		return_0;
+	/*
+	 * Walk all segments of all data LVs splitting them up at proper boundaries
+	 * and create the number of new striped segments we need to move them across
+	 */
+	area_le = le = 0;
+	while (le < lv->le_count) {
+		if (!(area_len = _min_sublv_area_at_le(seg, area_le)))
+			return_0;
+		area_le += area_len;
 
-	if (update_and_reload) {
-		if (!lv_update_and_reload_origin(lv))
+		if (!_split_area_lvs_segments(seg, area_le) ||
+		    !_alloc_and_add_new_striped_segment(lv, le, area_len, &new_segments))
 			return_0;
 
-		/* If any residual LVs, eliminate them, write VG, commit it and take a backup */
-		return _eliminate_extracted_lvs(lv->vg, removal_lvs);
+		le = area_le * seg->area_count;
 	}
 
-	return 1;
-}
+	/* Now move the prepared split areas across to the new segments */
+	area_le = 0;
+	dm_list_iterate_items(seg_to, &new_segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (!(data_seg = find_seg_by_le(seg_lv(seg, s), area_le))) {
+				log_error("Failed to find segment for %s extent %" PRIu32,
+					  seg_lv(seg, s)->name, area_le);
+				return 0;
+			}
 
-static int _raid0_meta_change_wrapper(struct logical_volume *lv,
-				     const struct segment_type *new_segtype,
-				     uint32_t new_stripes,
-				     int yes, int force, int alloc_metadata_devs,
-				     struct dm_list *allocate_pvs)
-{
-	struct dm_list removal_lvs;
+			/* Move the respective area across to our new segments area */
+			if (!move_lv_segment_area(seg_to, s, data_seg, 0))
+				return_0;
+		}
 
-	dm_list_init(&removal_lvs);
+		/* Presumes all data LVs have equal size */
+		area_le += data_seg->len;
+	}
 
-	if (!_check_restriping(new_stripes, lv))
+	/* Extract any metadata LVs and the empty data LVs for disposal by the caller */
+	if (!_extract_image_component_list(seg, RAID_IMAGE, 0, removal_lvs))
 		return_0;
 
-	if (!archive(lv->vg))
-		return_0;
+	/*
+	 * Remove the one segment holding the image component areas
+	 * from the top-level LV, then add the new segments to it
+	 */
+	dm_list_del(&seg->list);
+	dm_list_splice(&lv->segments, &new_segments);
 
-	if (alloc_metadata_devs)
-		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, NULL);
-	else
-		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, &removal_lvs);
+	return 1;
 }
 
-
-
-/*
- * Convert a RAID0 set to striped
- */
 static int _convert_raid0_to_striped(struct logical_volume *lv,
 				     int update_and_reload,
 				     struct dm_list *removal_lvs)
@@ -2171,11 +2162,8 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	return raid0_seg;
 }
 
-/************************************************/
+/***********************************************/
 
-/*
- * Individual takeover functions.
- */
 #define TAKEOVER_FN_ARGS			\
 	struct logical_volume *lv,		\
 	const struct segment_type *new_segtype,	\
@@ -2188,8 +2176,10 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 
 typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);
 
+/***********************************************/
+
 /*
- * Common takeover functions.
+ * Unsupported takeover functions.
  */
 static int _takeover_noop(TAKEOVER_FN_ARGS)
 {
@@ -2209,6 +2199,16 @@ static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 	return 0;
 }
 
+static int _takeover_unsupported_yet(const struct logical_volume *lv, const unsigned new_stripes, const struct segment_type *new_segtype)
+{
+	log_error("Converting the segment type for %s from %s to %s is not supported yet.",
+		  display_lvname(lv), lvseg_name(first_seg(lv)),
+		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
+
+	return 0;
+}
+
 /*
  * Will this particular takeover combination be possible?
  */
@@ -2220,16 +2220,85 @@ static int _takeover_not_possible(takeover_fn_t takeover_fn)
 	return 0;
 }
 
-static int _takeover_unsupported_yet(const struct logical_volume *lv, const unsigned new_stripes, const struct segment_type *new_segtype)
+/***********************************************/
+
+/*
+ * Wrapper functions that share conversion code.
+ */
+
+static int _raid0_meta_change_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
+				     int yes, int force, int alloc_metadata_devs,
+				     struct dm_list *allocate_pvs)
 {
-	log_error("Converting the segment type for %s from %s to %s is not supported yet.",
-		  display_lvname(lv), lvseg_name(first_seg(lv)),
-		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
-		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
+	struct dm_list removal_lvs;
 
-	return 0;
+	dm_list_init(&removal_lvs);
+
+	if (!_check_restriping(new_stripes, lv))
+		return_0;
+
+	if (!archive(lv->vg))
+		return_0;
+
+	if (alloc_metadata_devs)
+		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, NULL);
+	else
+		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, &removal_lvs);
+}
+
+static int _raid0_to_striped_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
+				     int yes, int force,
+				     struct dm_list *allocate_pvs)
+{
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	if (!_check_restriping(new_stripes, lv))
+		return_0;
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* FIXME update_and_reload is only needed if the LV is already active */
+	/* FIXME Some of the validation in here needs moving before the archiving */
+	if (!_convert_raid0_to_striped(lv, 1 /* update_and_reload */, &removal_lvs))
+		return_0;
+
+	return 1;
+}
+
+static int _striped_to_raid0_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
+				     int yes, int force, int alloc_metadata_devs,
+				     struct dm_list *allocate_pvs)
+{
+	if (!_check_restriping(new_stripes, lv))
+		return_0;
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* FIXME update_and_reload is only needed if the LV is already active */
+	/* FIXME Some of the validation in here needs moving before the archiving */
+	if (!_convert_striped_to_raid0(lv, alloc_metadata_devs, 1 /* update_and_reload */, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
+
+
+
+/************************************************/
+
 /*
  * Customised takeover functions
  */
@@ -2315,31 +2384,6 @@ static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
-static int _raid0_to_striped_wrapper(struct logical_volume *lv,
-				     const struct segment_type *new_segtype,
-				     uint32_t new_stripes,
-				     int yes, int force,
-				     struct dm_list *allocate_pvs)
-{
-	struct dm_list removal_lvs;
-
-	dm_list_init(&removal_lvs);
-
-	if (!_check_restriping(new_stripes, lv))
-		return_0;
-
-	/* Archive metadata */
-	if (!archive(lv->vg))
-		return_0;
-
-	/* FIXME update_and_reload is only needed if the LV is already active */
-	/* FIXME Some of the validation in here needs moving before the archiving */
-	if (!_convert_raid0_to_striped(lv, 1 /* update_and_reload */, &removal_lvs))
-		return_0;
-
-	return 1;
-}
-
 static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
 {
 	if (!_raid0_to_striped_wrapper(lv, new_segtype, new_stripes, yes, force, allocate_pvs))
@@ -2494,27 +2538,6 @@ static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
-static int _striped_to_raid0_wrapper(struct logical_volume *lv,
-				     const struct segment_type *new_segtype,
-				     uint32_t new_stripes,
-				     int yes, int force, int alloc_metadata_devs,
-				     struct dm_list *allocate_pvs)
-{
-	if (!_check_restriping(new_stripes, lv))
-		return_0;
-
-	/* Archive metadata */
-	if (!archive(lv->vg))
-		return_0;
-
-	/* FIXME update_and_reload is only needed if the LV is already active */
-	/* FIXME Some of the validation in here needs moving before the archiving */
-	if (!_convert_striped_to_raid0(lv, alloc_metadata_devs, 1 /* update_and_reload */, allocate_pvs))
-		return_0;
-
-	return 1;
-}
-
 static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
 {
 	if (!_striped_to_raid0_wrapper(lv, new_segtype, new_stripes, yes, force, 0, allocate_pvs))
@@ -2637,21 +2660,6 @@ static takeover_fn_t _get_takeover_fn(const struct lv_segment *seg, const struct
 	return _takeover_fns[_segtype_ix(seg->segtype, seg->area_count)][_segtype_ix(new_segtype, new_image_count)];
 }
 
-/*
- * Check for maximum number of raid devices.
- * Constrained by kernel MD maximum device limits _and_ dm-raid superblock
- * bitfield constraints.
- */
-static int _check_max_raid_devices(uint32_t image_count)
-{
-	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
-		log_error("Unable to handle arrays with more than %u devices",
-			  DEFAULT_RAID_MAX_IMAGES);
-		return 0;
-	}
-	return 1;
-}
-
 /* Number of data (not parity) rimages */
 static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t total_rimages)
 {


