From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:39 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - avoid __ function prefixes
Message-ID: <20150131141039.4AFB860DBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8f933989c2fbd9fcedf511867f1d7a1c9e58145
Commit:        d8f933989c2fbd9fcedf511867f1d7a1c9e58145
Parent:        86c0cd36df46cba666cc5b191f3d8c0f71f1ef2c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jan 30 17:33:59 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jan 30 17:33:59 2015 +0100

avoid __ function prefixes

---
 lib/metadata/lv_manip.c   |    2 +
 lib/metadata/raid_manip.c |  220 +++++++++++++++++++++++++--------------------
 2 files changed, 126 insertions(+), 96 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 70a2e8b..c4b9a16 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1016,12 +1016,14 @@ static uint32_t __round_to_stripe_boundary(struct logical_volume *lv, uint32_t e
 	if (!stripes)
 		return extents;
 
+printf("%s %d extents=%u stripes=%u\n", __func__, __LINE__, extents, stripes);
 	/* Round up extents to stripe divisable amount */
 	if ((rest = extents % stripes)) {
 		extents += up ? stripes - rest : -rest;
 		log_print_unless_silent("Rounding up size to full stripe size %s",
 			  		display_size(lv->vg->cmd, extents * lv->vg->extent_size));
 	}
+printf("%s %d extents=%u stripes=%u rest=%u\n", __func__, __LINE__, extents, stripes, rest);
 
 	return extents;
 }
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3327935..aac0e99 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -41,7 +41,7 @@ static void _ensure_min_region_size(struct logical_volume *lv)
 }
 
 /* Default region_size on @lv unless already set */
-static void __check_and_init_region_size(struct logical_volume *lv)
+static void _check_and_init_region_size(struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
 
@@ -50,7 +50,7 @@ static void __check_and_init_region_size(struct logical_volume *lv)
 }
 
 /* Return data images count for @total_rimages depending on @seg's type */
-static uint32_t __data_rimages_count(struct lv_segment *seg, uint32_t total_rimages)
+static uint32_t _data_rimages_count(struct lv_segment *seg, uint32_t total_rimages)
 {
 	return total_rimages - seg->segtype->parity_devs;
 }
@@ -106,11 +106,12 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 }
 
 /* Deactivate and remove the LVs on @removal_lvs list */
-static int __deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
+static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
 {
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, removal_lvs) {
+printf("%s %d lvl->lv->name=%s\n", __func__, __LINE__,  lvl->lv->name);
 		if (!deactivate_lv(vg->cmd, lvl->lv))
 			return_0;
 
@@ -292,7 +293,7 @@ static int _clear_lvs(struct dm_list *lv_list)
 }
 
 /* Check for maximum supported devices caused by the kernel superblock bitfield constraint */
-static int __check_maximum_devices(uint32_t num_devices)
+static int _check_maximum_devices(uint32_t num_devices)
 {
 	if (num_devices > DEFAULT_RAID_MAX_IMAGES) {
 		log_error("Unable to handle arrays with more than %u devices",
@@ -304,7 +305,7 @@ static int __check_maximum_devices(uint32_t num_devices)
 }
 
 /* Replace @lv with error segment */
-static int __replace_lv_with_error_segment(struct logical_volume *lv)
+static int _replace_lv_with_error_segment(struct logical_volume *lv)
 {
 	if (lv && (lv->status & PARTIAL_LV)) {
 		log_debug("Replacing %s segments with error target", lv->name);
@@ -318,7 +319,7 @@ static int __replace_lv_with_error_segment(struct logical_volume *lv)
 }
 
 /* Retrieve index from @*lv_name and add it to @prefix; set the result in @*lv_name */
-static int __lv_name_add_string_index(struct cmd_context *cmd, const char **lv_name, const char *prefix)
+static int _lv_name_add_string_index(struct cmd_context *cmd, const char **lv_name, const char *prefix)
 {
 	size_t len;
 	char *b, *e, *newname, *tmpname;
@@ -362,7 +363,7 @@ static int _shift_image_components(struct lv_segment *seg)
 		return_0;
 
 	/* Should not be possible here, but... */
-	if (!__check_maximum_devices(seg->area_count))
+	if (!_check_maximum_devices(seg->area_count))
 		return 0;
 
 	log_very_verbose("Shifting images in %s", seg->lv->name);
@@ -432,8 +433,9 @@ static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *rem
 {
 	sync_local_dev_names(vg->cmd);
 
+printf("%s %d\n", __func__, __LINE__);
 	if (!dm_list_empty(removal_list)) {
-		if (!__deactivate_and_remove_lvs(vg, removal_list))
+		if (!_deactivate_and_remove_lvs(vg, removal_list))
 			return 0;
 
 		if (!vg_write(vg) || !vg_commit(vg))
@@ -442,6 +444,7 @@ static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *rem
 		if (!backup(vg))
 			log_error("Backup of VG %s failed after removal of image component LVs", vg->name);
 	}
+printf("%s %d\n", __func__, __LINE__);
 
 	return 1;
 }
@@ -450,7 +453,7 @@ static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *rem
  * Reallocate segment areas given by @seg_areas (i.e eith data or metadata areas)
  * in segment @seg to amount in @areas copying the minimum of common areas across
  */
-static int __realloc_seg_areas(struct logical_volume *lv, struct lv_segment *seg,
+static int _realloc_seg_areas(struct logical_volume *lv, struct lv_segment *seg,
 			       uint32_t areas, struct lv_segment_area **seg_areas)
 {
 	struct lv_segment_area *new_areas;
@@ -470,15 +473,15 @@ static int __realloc_seg_areas(struct logical_volume *lv, struct lv_segment *seg
 /*
  * Reallocate both data and metadata areas of segmen @seg to new amount in @ares
  */
-static int __realloc_meta_and_data_seg_areas(struct logical_volume *lv, struct lv_segment *seg,
+static int _realloc_meta_and_data_seg_areas(struct logical_volume *lv, struct lv_segment *seg,
 					     uint32_t areas)
 {
-	return (__realloc_seg_areas(lv, seg, areas, &seg->meta_areas) &&
-	        __realloc_seg_areas(lv, seg, areas, &seg->areas)) ? 1 : 0;
+	return (_realloc_seg_areas(lv, seg, areas, &seg->meta_areas) &&
+	        _realloc_seg_areas(lv, seg, areas, &seg->areas)) ? 1 : 0;
 }
 
 /* Add new @lvs to @lv at @area_offset */
-static int __add_sublvs_to_lv(struct logical_volume *lv, int delete_from_list,
+static int _add_sublvs_to_lv(struct logical_volume *lv, int delete_from_list,
 			      uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)
 {
 	uint32_t a = area_offset;
@@ -608,7 +611,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-	__check_and_init_region_size(data_lv);
+	_check_and_init_region_size(data_lv);
 
 	(void) dm_strncpy(base_name, data_lv->name, sizeof(base_name));
 	if ((p = strstr(base_name, "_mimage_")) ||
@@ -642,7 +645,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 /*
  * Allocate metadata devs for all @new_data_devs and link them to list @new_meta_lvs
  */
-static int __alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
+static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 					     uint32_t raid_devs,
 					     struct dm_list *new_data_lvs, struct dm_list *new_meta_lvs)
 {
@@ -697,7 +700,7 @@ static int _alloc_image_components(struct logical_volume *lv, int allocate,
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
 		return_0;
 
-	__check_and_init_region_size(lv);
+	_check_and_init_region_size(lv);
 
 	if (seg_is_raid(seg))
 		segtype = seg->segtype;
@@ -717,7 +720,7 @@ static int _alloc_image_components(struct logical_volume *lv, int allocate,
 		if (new_meta_lvs || new_data_lvs) {
 			/* Amount of extents for the rimage device(s) */
 			extents = (segtype_is_raid0(segtype) || segtype->parity_devs) ?
-				  lv->le_count / __data_rimages_count(seg, seg->area_count) : lv->le_count;
+				  lv->le_count / _data_rimages_count(seg, seg->area_count) : lv->le_count;
 
 			if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, count, count,
 						    seg->region_size, extents,
@@ -763,7 +766,7 @@ err:
 }
 
 /* Cleanly remove newly-allocated LVs that failed insertion attempt */
-static int __remove_lvs(struct dm_list *lvs)
+static int _remove_lvs(struct dm_list *lvs)
 {
 	struct lv_list *lvl;
 
@@ -775,7 +778,7 @@ static int __remove_lvs(struct dm_list *lvs)
 }
 
 /* Factored out function to allocate an rmeta dev for a linear one */
-static int __alloc_rmeta_for_linear(struct logical_volume *lv, struct dm_list *meta_lvs)
+static int _alloc_rmeta_for_linear(struct logical_volume *lv, struct dm_list *meta_lvs)
 {
 	struct lv_list *lvl;
 
@@ -793,7 +796,7 @@ static int __alloc_rmeta_for_linear(struct logical_volume *lv, struct dm_list *m
 }
 
 /* Correct LV names for @data_lvs in case of a linear @lv */
-static int __correct_data_lv_names(struct logical_volume *lv, uint32_t count, struct dm_list *data_lvs)
+static int _correct_data_lv_names(struct logical_volume *lv, uint32_t count, struct dm_list *data_lvs)
 {
 	struct dm_list *l;
 	struct lv_list *lvl, *lvl_n;
@@ -815,7 +818,7 @@ static int __correct_data_lv_names(struct logical_volume *lv, uint32_t count, st
 }
 
 /* Return length of unsigned @idx as a string */
-static unsigned __unsigned_str_len(unsigned idx)
+static unsigned _unsigned_str_len(unsigned idx)
 {
 	unsigned r = 0;
 
@@ -827,11 +830,11 @@ static unsigned __unsigned_str_len(unsigned idx)
 }
 
 /* Create an rimage string suffix with @idx appended */
-static const char *__generate_rimage_suffix(struct logical_volume *lv, unsigned idx)
+static const char *_generate_rimage_suffix(struct logical_volume *lv, unsigned idx)
 {
 	const char *type = "_rimage";
 	char *suffix;
-	size_t len = strlen(type) + __unsigned_str_len(idx) + 1;
+	size_t len = strlen(type) + _unsigned_str_len(idx) + 1;
 
 	if (!(suffix = dm_pool_alloc(lv->vg->vgmem, len))) {
 		log_error("Failed to allocate name suffix.");
@@ -845,10 +848,10 @@ static const char *__generate_rimage_suffix(struct logical_volume *lv, unsigned
 }
 
 /* Insert RAID layer on top of @lv with suffix counter @idx */
-static int __insert_raid_layer_for_lv(struct logical_volume *lv, const char *sfx, unsigned idx)
+static int _insert_raid_layer_for_lv(struct logical_volume *lv, const char *sfx, unsigned idx)
 {
 	uint64_t flags = RAID | LVM_READ | LVM_WRITE;
-	const char *suffix = sfx ?: __generate_rimage_suffix(lv, idx);
+	const char *suffix = sfx ?: _generate_rimage_suffix(lv, idx);
 
 	if (!insert_layer_for_lv(lv->vg->cmd, lv, flags, suffix))
 		return 0;
@@ -859,19 +862,19 @@ static int __insert_raid_layer_for_lv(struct logical_volume *lv, const char *sfx
 }
 
 /* Convert linear @lv to raid1 */
-static int __convert_linear_to_raid1(struct logical_volume *lv)
+static int _convert_linear_to_raid1(struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t region_size = seg->region_size;
 
-	if (!__insert_raid_layer_for_lv(lv, "_rimage0", 0))
+	if (!_insert_raid_layer_for_lv(lv, "_rimage0", 0))
 		return 0;
 
 	/* Segment has changed */
 	seg = first_seg(lv);
 	seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
 	seg->region_size = region_size;
-	__check_and_init_region_size(lv);
+	_check_and_init_region_size(lv);
 
 	if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
 		return_0;
@@ -880,7 +883,7 @@ static int __convert_linear_to_raid1(struct logical_volume *lv)
 }
 
 /* Reset any rebuild or reshape flags on @seg already passed to the kernel */
-static int __reset_flags_passed_to_kernel(struct lv_segment *seg)
+static int _reset_flags_passed_to_kernel(struct lv_segment *seg)
 {
 	uint32_t s;
 	int flag_cleared = 0;
@@ -958,12 +961,16 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 		 * A complete resync will be done because of
 		 * the new raid1 set, no need to mark each sub-lv
 		 */
-		lv_flags = 0; /* Resets LV_REBUILD in __add_sublvs_to_lv() */
+		lv_flags = 0; /* Resets LV_REBUILD in _add_sublvs_to_lv() */
 
 		/* Allocate an rmeta device to pair with the linear image */
-		if (!__alloc_rmeta_for_linear(lv, &meta_lvs))
+		if (!_alloc_rmeta_for_linear(lv, &meta_lvs))
 			return 0;
 	}
+#if 0
+	 else if (interim)
+		lv_flags = 0; /* Resets LV_REBUILD in _add_sublvs_to_lv() because of interim RAID level */
+#endif
 
 	/* Allocate the additional meta and data lvs requested */
 	if (!_alloc_image_components(lv, 1, pvs, count, &meta_lvs, &data_lvs))
@@ -976,7 +983,7 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 	 * commits the LVM metadata before clearing the LVs.
 	 */
 	if (linear &&
-	    !__correct_data_lv_names(lv, count, &data_lvs))
+	    !_correct_data_lv_names(lv, count, &data_lvs))
 		return 0;
 
 	/* Metadata LVs must be cleared before being added to the array */
@@ -985,7 +992,7 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 
 	/* We are converting from linear to raid1 */
 	if (linear) {
-	    	if (!__convert_linear_to_raid1(lv))
+	    	if (!_convert_linear_to_raid1(lv))
 			return 0;
 
 		seg = first_seg(lv);
@@ -998,7 +1005,7 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 	 */
 
 	/* Expand areas arrays for metadata and data devs  */
-	if (!__realloc_meta_and_data_seg_areas(lv, seg, new_count)) {
+	if (!_realloc_meta_and_data_seg_areas(lv, seg, new_count)) {
 		log_error("Relocation of areas arrays failed.");
 		return 0;
 	}
@@ -1009,17 +1016,17 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 	 * Set segment areas for metadata sub_lvs adding
 	 * an extra meta area when converting from linear
 	 */
-	if (!__add_sublvs_to_lv(lv, 0, 0, &meta_lvs, linear ? 0 : old_count))
+	if (!_add_sublvs_to_lv(lv, 0, 0, &meta_lvs, linear ? 0 : old_count))
 		goto fail;
 
 	/* Set segment areas for data sub_lvs */
-	if (!__add_sublvs_to_lv(lv, 0, lv_flags, &data_lvs, old_count))
+	if (!_add_sublvs_to_lv(lv, 0, lv_flags, &data_lvs, old_count))
 		goto fail;
 
 	/* Reshape adding image component pairs to raid set changing size accordingly */
 	if (!seg_is_raid1(seg)) {
 		if (seg->segtype == segtype) {
-			uint32_t extents = lv->le_count / __data_rimages_count(seg, old_count);
+			uint32_t extents = lv->le_count / _data_rimages_count(seg, old_count);
 
 			for (s = old_count; s < new_count; s++) {
 				seg_lv(seg, s)->status &= ~LV_REBUILD;
@@ -1057,7 +1064,7 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 	 * the kernel, we must remove the flag so that the individual devices
 	 * are not rebuilt upon every activation.
 	 */
-	if (__reset_flags_passed_to_kernel(first_seg(lv))) {
+	if (_reset_flags_passed_to_kernel(first_seg(lv))) {
 		if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 			log_error("Failed to clear REBUILD flag for %s/%s components",
 				  lv->vg->name, lv->name);
@@ -1071,8 +1078,8 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 
 fail:
 	/* Cleanly remove newly-allocated LVs that failed insertion attempt */
-	if (!__remove_lvs(&meta_lvs) ||
-	    !__remove_lvs(&data_lvs))
+	if (!_remove_lvs(&meta_lvs) ||
+	    !_remove_lvs(&data_lvs))
 		return_0;
 
 	return 0;
@@ -1150,7 +1157,7 @@ static int _extract_image_component(struct lv_segment *seg,
  *
  * Returns: 1 on success, 0 on failure
  */
-static int __extract_image_components(struct lv_segment *seg, uint32_t idx,
+static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 				     struct lv_list *lvl_array)
 {
 	/* Don't change extraction sequence; callers are relying on it */
@@ -1162,7 +1169,7 @@ static int __extract_image_components(struct lv_segment *seg, uint32_t idx,
 }
 
 /* Write vg of @lv, suspend @lv and commit the vg */
-static int __vg_write_lv_suspend_vg_commit(struct logical_volume *lv)
+static int _vg_write_lv_suspend_vg_commit(struct logical_volume *lv)
 {
 	if (!vg_write(lv->vg)) {
 		log_error("Failed to write changes to %s in %s",
@@ -1280,7 +1287,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 			}
 		}
 
-		if (!__extract_image_components(seg, s, lvl_array + lvl_idx)) {
+		if (!_extract_image_components(seg, s, lvl_array + lvl_idx)) {
 			log_error("Failed to extract %s from %s", seg_lv(seg, s)->name, lv->name);
 			return 0;
 		}
@@ -1317,9 +1324,11 @@ static int _raid_remove_images(struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 #endif
 
+printf("%s %d\n", __func__, __LINE__);
 	if (!archive(lv->vg))
 		return_0;
 
+printf("%s %d\n", __func__, __LINE__);
 	dm_list_init(&removal_list);
 
 #if 0
@@ -1330,6 +1339,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	}
 #endif
 
+printf("%s %d\n", __func__, __LINE__);
 	if (!_raid_extract_images(lv, new_count, pvs, 1,
 				  &removal_list, &removal_list)) {
 		log_error("Failed to extract images from %s/%s",
@@ -1337,6 +1347,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 		return 0;
 	}
 
+printf("%s %d\n", __func__, __LINE__);
 	/* Convert to linear? */
 	if (new_count == 1) {
 		if (!_raid_remove_top_layer(lv, &removal_list)) {
@@ -1349,11 +1360,13 @@ static int _raid_remove_images(struct logical_volume *lv,
 		first_seg(lv)->writebehind = 0;
 	}
 
+printf("%s %d\n", __func__, __LINE__);
 #if 0
 dump_lv("", lv);
 #endif
 
-	if (!__vg_write_lv_suspend_vg_commit(lv))
+printf("%s %d\n", __func__, __LINE__);
+	if (!_vg_write_lv_suspend_vg_commit(lv))
 		return 0;
 
 
@@ -1361,6 +1374,7 @@ dump_lv("", lv);
 	 * We activate the extracted sub-LVs first so they are
 	 * renamed and won't conflict with the remaining sub-LVs.
 	 */
+printf("%s %d\n", __func__, __LINE__);
 	dm_list_iterate_items(lvl, &removal_list) {
 		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
 			log_error("Failed to resume extracted LVs");
@@ -1368,12 +1382,14 @@ dump_lv("", lv);
 		}
 	}
 
+printf("%s %d\n", __func__, __LINE__);
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
+printf("%s %d\n", __func__, __LINE__);
 	/* Eliminate the residual LVs, write VG, commit it and take a backup */
 	return _eliminate_extracted_lvs(lv->vg, &removal_list);
 }
@@ -1392,7 +1408,7 @@ dump_lv("", lv);
  *
  * Returns: 1 on success, 0 on failure
  */
-static int __lv_raid_change_image_count(struct logical_volume *lv, struct segment_type *segtype,
+static int _lv_raid_change_image_count(struct logical_volume *lv, struct segment_type *segtype,
 					uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
@@ -1402,10 +1418,12 @@ static int __lv_raid_change_image_count(struct logical_volume *lv, struct segmen
 			 lv->vg->name, lv->name, new_count);
 		return 1;
 	}
+printf("%s %d\n", __func__, __LINE__);
 
 	/* Check for maximum supported raid devices */
-	if (!__check_maximum_devices(new_count))
+	if (!_check_maximum_devices(new_count))
 		return 0;
+printf("%s %d\n", __func__, __LINE__);
 
 	/*
 	 * LV must be either in-active or exclusively active
@@ -1417,6 +1435,7 @@ static int __lv_raid_change_image_count(struct logical_volume *lv, struct segmen
 			  " perform this operation.", lv->vg->name, lv->name);
 		return 0;
 	}
+printf("%s %d\n", __func__, __LINE__);
 
 	return (old_count > new_count) ? _raid_remove_images(lv, new_count, pvs) :
 					 _raid_add_images(lv, segtype, new_count, pvs);
@@ -1425,7 +1444,7 @@ static int __lv_raid_change_image_count(struct logical_volume *lv, struct segmen
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs)
 {
-	return __lv_raid_change_image_count(lv, NULL, new_count, pvs);
+	return _lv_raid_change_image_count(lv, NULL, new_count, pvs);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -1507,10 +1526,10 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 
 	/* Rename all extracted rimages */
 	dm_list_iterate_items(lvl, &data_list)
-		if (!__lv_name_add_string_index(cmd, &lvl->lv->name, split_name))
+		if (!_lv_name_add_string_index(cmd, &lvl->lv->name, split_name))
 			return 0;
 
-	if (!__vg_write_lv_suspend_vg_commit(lv))
+	if (!_vg_write_lv_suspend_vg_commit(lv))
 		return 0;
 
 	dm_list_iterate_items(lvl, &data_list)
@@ -1797,7 +1816,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
  *
  * Returns: 1 on success, 0 on failure
  */
-static int __striped_to_raid0_move_segs_to_raid0_components(struct logical_volume *lv,
+static int _striped_to_raid0_move_segs_to_raid0_components(struct logical_volume *lv,
 							   struct dm_list *new_data_lvs)
 {
 	unsigned area_idx = 0, le;
@@ -1851,7 +1870,7 @@ static int __striped_to_raid0_move_segs_to_raid0_components(struct logical_volum
  *
  * Returns: 1 on success, 0 on failure
  */
-static int __striped_to_raid0_alloc_raid0_segment(struct logical_volume *lv,
+static int _striped_to_raid0_alloc_raid0_segment(struct logical_volume *lv,
 						  uint32_t area_count,
 						  struct lv_segment *seg)
 {
@@ -1875,7 +1894,7 @@ static int __striped_to_raid0_alloc_raid0_segment(struct logical_volume *lv,
 }
 
 /* Check that @lv has equal stripe count in all of its segements */
-static int __equal_stripes(struct logical_volume *lv)
+static int _equal_stripes(struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 	unsigned area_count = first_seg(lv)->area_count;
@@ -1921,7 +1940,7 @@ static int _convert_striped_to_raid0(struct logical_volume *lv,
 	dm_list_init(&new_data_lvs);
 
 	/* Check for non-supported varying area_count on multi-segment striped LVs */
-	if (!__equal_stripes(lv))
+	if (!_equal_stripes(lv))
 		return 0;
 
 	if (!archive(lv->vg))
@@ -1942,14 +1961,14 @@ static int _convert_striped_to_raid0(struct logical_volume *lv,
 		seg_lv(seg, s)->status &= LV_REBUILD;
 
 	/* Move the AREA_PV areas across to the new rimage components */
-	if (!__striped_to_raid0_move_segs_to_raid0_components(lv, &new_data_lvs)) {
+	if (!_striped_to_raid0_move_segs_to_raid0_components(lv, &new_data_lvs)) {
 		log_error("Failed to insert linear LVs underneath, %s.", lv->name);
 		return_0;
 	}
 
 	/* Allocate new top-level LV segment */
 	seg = first_seg(dm_list_item(dm_list_first(&new_data_lvs), struct lv_list)->lv);
-	if (!__striped_to_raid0_alloc_raid0_segment(lv, area_count, seg)) {
+	if (!_striped_to_raid0_alloc_raid0_segment(lv, area_count, seg)) {
 		log_error("Failed to allocate new raid0 segement for LV %s.", lv->name);
 		return_0;
 	}
@@ -1959,11 +1978,11 @@ static int _convert_striped_to_raid0(struct logical_volume *lv,
 
 	/* Optionally allocate a new metadata device for each of the raid0 stripe LVs */
 	if (alloc_metadata_devs &&
-	    !__alloc_rmeta_devs_for_rimage_devs(lv, area_count, &new_data_lvs, &new_meta_lvs))
+	    !_alloc_rmeta_devs_for_rimage_devs(lv, area_count, &new_data_lvs, &new_meta_lvs))
 		return 0;
 
 	/* Add data lvs to the top-level lv before working on optional rmeta devs */
-	if (!__add_sublvs_to_lv(lv, 1, 0, &new_data_lvs, 0))
+	if (!_add_sublvs_to_lv(lv, 1, 0, &new_data_lvs, 0))
 		return 0;
 
 	if (alloc_metadata_devs) {
@@ -1975,13 +1994,13 @@ static int _convert_striped_to_raid0(struct logical_volume *lv,
 		}
 
 		/* Allocate meta_areas for new raid0 lv */
-		if (!__realloc_seg_areas(lv, seg, area_count, &seg->meta_areas))
+		if (!_realloc_seg_areas(lv, seg, area_count, &seg->meta_areas))
 			return 0;
 
 		seg->area_count = area_count;
 
 		/* Add metadata lvs to the top-level lv */
-		if (!__add_sublvs_to_lv(lv, 1, 0, &new_meta_lvs, 0))
+		if (!_add_sublvs_to_lv(lv, 1, 0, &new_meta_lvs, 0))
 			return_0;
 	}
 
@@ -1997,7 +2016,7 @@ static int _convert_striped_to_raid0(struct logical_volume *lv,
 /* END: striped -> raid0 conversion */
 
 /* Remove segv from segments using @lv and set one segment mapped to error target to @lv */
-static int __remove_and_set_error_target(struct logical_volume *lv, struct lv_segment *seg)
+static int _remove_and_set_error_target(struct logical_volume *lv, struct lv_segment *seg)
 {
 	lv->status &= ~RAID;
 	lv_set_visible(lv);
@@ -2017,7 +2036,7 @@ static int __remove_and_set_error_target(struct logical_volume *lv, struct lv_se
  *
  * Returns: 1 on success, 0 on failure
  */
-static int __raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
+static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
 							struct dm_list *removal_lvs)
 {
 	uint32_t s, le = 0;
@@ -2052,7 +2071,7 @@ static int __raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *l
 		if (seg->meta_areas &&
 		    (mlv = lvl_array[seg->area_count + s].lv = seg_metalv(seg, s))) {
 			dm_list_add(removal_lvs, &lvl_array[seg->area_count + s].list);
-			if (!__remove_and_set_error_target(mlv, seg))
+			if (!_remove_and_set_error_target(mlv, seg))
 				return 0;
 		}
 
@@ -2067,7 +2086,7 @@ static int __raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *l
 		}
 
 		dm_list_add(removal_lvs, &lvl_array[s].list);
-		if (!__remove_and_set_error_target(dlv, seg))
+		if (!_remove_and_set_error_target(dlv, seg))
 			return 0;
 	}
 
@@ -2111,7 +2130,7 @@ static int _convert_raid0_to_striped(struct logical_volume *lv,
 		return_0;
 
 	/* Move the AREA_PV areas across to new top-level segments */
-	if (!__raid0_to_striped_retrieve_segments_and_lvs(lv, &removal_lvs)) {
+	if (!_raid0_to_striped_retrieve_segments_and_lvs(lv, &removal_lvs)) {
 		log_error("Failed to retrieve raid0 segments from %s.", lv->name);
 		return_0;
 	}
@@ -2125,19 +2144,19 @@ static int _convert_raid0_to_striped(struct logical_volume *lv,
 /* END: raid0 -> striped conversion */
 
 /* BEGIN: raid <-> raid conversion */
-static int __cmp_level(const struct segment_type *t1, const struct segment_type *t2)
+static int _cmp_level(const struct segment_type *t1, const struct segment_type *t2)
 {
 	return strncmp(t1->name, t2->name, 5);
 }
 
 static int is_same_level(const struct segment_type *t1, const struct segment_type *t2)
 {
-	return !__cmp_level(t1, t2);
+	return !_cmp_level(t1, t2);
 }
 
 static int is_level_up(const struct segment_type *t1, const struct segment_type *t2)
 {
-	return __cmp_level(t1, t2) < 0;
+	return _cmp_level(t1, t2) < 0;
 }
 
 /*
@@ -2176,7 +2195,7 @@ static int is_level_up(const struct segment_type *t1, const struct segment_type
  */
 
 /* Adjust @*segtype to the correct one for takeover */
-static int __adjust_segtype_for_takeover(struct logical_volume *lv, struct segment_type **new_segtype)
+static int _adjust_segtype_for_takeover(struct logical_volume *lv, struct segment_type **new_segtype)
 {
 	struct lv_segment *seg = first_seg(lv);
 	struct segment_type *requested_segtype = *new_segtype;
@@ -2326,14 +2345,14 @@ static int __adjust_segtype_for_takeover(struct logical_volume *lv, struct segme
  * allocation of new stripes.
  */
 /* HM FIXME: CODEME TESTME */
-static int __convert_reshape(struct logical_volume *lv,
+static int _convert_reshape(struct logical_volume *lv,
 			     struct segment_type *new_segtype,
 			     const unsigned new_stripes,
 			     const unsigned new_stripe_size,
 		 	     struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
-	unsigned old_stripes = __data_rimages_count(seg, seg->area_count);
+	unsigned old_stripes = _data_rimages_count(seg, seg->area_count);
 
 	if (seg->segtype == new_segtype &&
 	    seg->area_count - seg->segtype->parity_devs == new_stripes &&
@@ -2346,7 +2365,7 @@ static int __convert_reshape(struct logical_volume *lv,
 		return_0;
 
 	if (old_stripes < new_stripes &&
-	    !__lv_raid_change_image_count(lv, new_segtype, new_stripes + seg->segtype->parity_devs, allocate_pvs))
+	    !_lv_raid_change_image_count(lv, new_segtype, new_stripes + seg->segtype->parity_devs, allocate_pvs))
 		return 0;
 
 	seg->segtype = new_segtype;
@@ -2355,7 +2374,7 @@ static int __convert_reshape(struct logical_volume *lv,
 }
 
 /* Process one level up takeover on @lv to @segtype allocating fron @allocate_pvs */
-static int __raid_level_up(struct logical_volume *lv,
+static int _raid_level_up(struct logical_volume *lv,
 			   struct segment_type *segtype,
 			   struct dm_list *allocate_pvs)
 {
@@ -2363,7 +2382,7 @@ static int __raid_level_up(struct logical_volume *lv,
 	uint32_t new_count = seg->area_count + 1;
 
 	/* Make sure to set default region size on takeover from raid0 */
-	__check_and_init_region_size(lv);
+	_check_and_init_region_size(lv);
 
 	/*
 	 * In case of raid1 -> raid5, takeover will run a degraded 2 disk raid5 set
@@ -2388,21 +2407,22 @@ static int __raid_level_up(struct logical_volume *lv,
 	 * The top-level LV is being reloaded and the VG
 	 * written and committed in the course of this call
 	 */
-	return __lv_raid_change_image_count(lv, segtype, new_count, allocate_pvs);
+	return _lv_raid_change_image_count(lv, segtype, new_count, allocate_pvs);
 }
 
 /* Process one level down takeover on @lv to @segtype */
-static int __raid_level_down(struct logical_volume *lv,
+static int _raid_level_down(struct logical_volume *lv,
 			    struct segment_type *segtype,
 			    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t new_count = seg->area_count - 1;
 
+printf("%s %d\n", __func__, __LINE__);
 	if (segtype_is_raid1(segtype)) {
 		/* FIXME: delta_disks = -1 mandatory! */
 		/* Reduce image count to 2 first */
-		if (!__lv_raid_change_image_count(lv, NULL, new_count, NULL))
+		if (!_lv_raid_change_image_count(lv, NULL, new_count, allocate_pvs))
 			return 0;
 
 		seg->segtype = segtype;
@@ -2414,16 +2434,19 @@ static int __raid_level_down(struct logical_volume *lv,
 		return 1;
 	}
 
+printf("%s %d\n", __func__, __LINE__);
 	seg->segtype = segtype;
 
+printf("%s %d\n", __func__, __LINE__);
 	/* This causes any !raid1 -> raid takeover */
 	if (!lv_update_and_reload(lv))
 		return_0;
+printf("%s %d\n", __func__, __LINE__);
 
-	return __lv_raid_change_image_count(lv, segtype, new_count, NULL);
+	return _lv_raid_change_image_count(lv, segtype, new_count, allocate_pvs);
 }
 
-static struct segment_type *__get_next_up_segtype(struct logical_volume *lv,
+static struct segment_type *_get_next_up_segtype(struct logical_volume *lv,
 						 const struct segment_type *segtype,
 						 const struct segment_type *new_segtype)
 {
@@ -2443,7 +2466,7 @@ static struct segment_type *__get_next_up_segtype(struct logical_volume *lv,
 	return segtype_name ? get_segtype_from_string(lv->vg->cmd, segtype_name) : NULL;
 }
 
-static struct segment_type *__get_next_down_segtype(struct logical_volume *lv,
+static struct segment_type *_get_next_down_segtype(struct logical_volume *lv,
 						   const struct segment_type *segtype,
 						   const struct segment_type *new_segtype)
 {
@@ -2461,12 +2484,12 @@ static struct segment_type *__get_next_down_segtype(struct logical_volume *lv,
 	return segtype_name ? get_segtype_from_string(lv->vg->cmd, segtype_name) : NULL;
 }
 
-static struct segment_type *__get_next_segtype(struct logical_volume *lv,
+static struct segment_type *_get_next_segtype(struct logical_volume *lv,
 					      const struct segment_type *segtype,
 					      const struct segment_type *new_segtype,
 					      int up)
 {
-	return (up ? __get_next_up_segtype : __get_next_down_segtype)(lv, segtype, new_segtype);
+	return (up ? _get_next_up_segtype : _get_next_down_segtype)(lv, segtype, new_segtype);
 }
 
 /* Adjust @segtype to takeover compatible one */
@@ -2476,7 +2499,7 @@ struct possible_takeover {
 };
 
 #define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*a))
-static const struct segment_type *__adjust_final_segtype(struct logical_volume *lv,
+static const struct segment_type *_adjust_final_segtype(struct logical_volume *lv,
 							const struct segment_type *segtype,
 							const struct segment_type *new_segtype)
 {
@@ -2521,7 +2544,7 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 	struct segment_type *new_segtype = (struct segment_type *) requested_segtype;
 	struct segment_type *next_segtype;
 	const struct segment_type *final_segtype;
-	unsigned stripes = new_stripes ?: __data_rimages_count(seg, seg->area_count);
+	unsigned stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
 	unsigned stripe_size = new_stripe_size ?: seg->stripe_size;
 
 	/* Check + apply stripe size change */
@@ -2542,7 +2565,7 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 	}
 
 	if (new_segtype == seg->segtype &&
-	    stripes == __data_rimages_count(seg, seg->area_count) &&
+	    stripes == _data_rimages_count(seg, seg->area_count) &&
 	    stripe_size == seg->stripe_size) {
 		log_error("Nothing to do");
 		return 0;
@@ -2551,14 +2574,14 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 #if 1
 	/* HM FIXME: REMOVEME once supported */
 	/* No stripes reduction so far */
-	if (stripes < __data_rimages_count(seg, seg->area_count)) {
+	if (stripes < _data_rimages_count(seg, seg->area_count)) {
 		log_error("No stripes reduction on %s supported so far", lv->name);
 		return_0;
 	}
 #endif
 	/* Staying on the same level -> reshape required to change stripes, stripe size or algorithm */
 	if (is_same_level(seg->segtype, new_segtype)) {
-		if (!__convert_reshape(lv, new_segtype, stripes, stripe_size, allocate_pvs))
+		if (!_convert_reshape(lv, new_segtype, stripes, stripe_size, allocate_pvs))
 			return 0;
 
 		if (!lv_update_and_reload(lv))
@@ -2581,14 +2604,19 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 	 * In order to postprocess the takeover of a raid set from level M to M (M > N)
 	 * in @lv, the last rimage/rmeta devs pair need to be droped in the metadata.
 	 */
-	if (!(final_segtype = __adjust_final_segtype(lv, seg->segtype, new_segtype)))
+	if (!(final_segtype = _adjust_final_segtype(lv, seg->segtype, new_segtype)))
 		return 0;
+
 	up = is_level_up(seg->segtype, final_segtype);
 	do {
-		if (!(next_segtype = __get_next_segtype(lv, seg->segtype, final_segtype, up)) ||
-		    !__adjust_segtype_for_takeover(lv, &next_segtype) ||
-		    !__raid_level_up(lv, next_segtype, allocate_pvs))
+		if (!(next_segtype = _get_next_segtype(lv, seg->segtype, final_segtype, up)))
+			return 0;
+		if (!_adjust_segtype_for_takeover(lv, &next_segtype))
 			return 0;
+		if (!(up ? _raid_level_up : _raid_level_down)(lv, next_segtype, allocate_pvs))
+			return 0;
+
+		seg = first_seg(lv);
 	} while (next_segtype != final_segtype);
 
 	return 1;
@@ -2745,7 +2773,7 @@ has_enough_space:
 	 * the remaining free space) in order to allocate the image
 	 * anew.
 	 */
-	if (!__replace_lv_with_error_segment(rm_image))
+	if (!_replace_lv_with_error_segment(rm_image))
 		return 0;
 
 	return 1;
@@ -2769,7 +2797,7 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  * Prevent any PVs holding other image components of @lv from being used for allocation,
  * I.e. remove respective PVs from @allocatable_pvs
  */
-static int __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
 	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
 }
@@ -2880,7 +2908,7 @@ int lv_raid_replace(struct logical_volume *lv,
 	}
 
 	/* Prevent any PVs holding image components from being used for allocation */
-	if (!__avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
+	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
 		log_error("Failed to prevent PVs holding image components "
 			  "from being used for allocation.");
 		return 0;
@@ -3017,7 +3045,7 @@ try_again:
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
-	if (!__deactivate_and_remove_lvs(lv->vg, &old_lvs))
+	if (!_deactivate_and_remove_lvs(lv->vg, &old_lvs))
 		return 0;
 
 	/* Update new sub-LVs to correct name and clear REBUILD flag */
@@ -3060,8 +3088,8 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	 * FIXME: Make sure # of compromised components will not affect RAID
 	 */
 	for (s = 0; s < seg->area_count; s++)
-		if (!__replace_lv_with_error_segment(seg_lv(seg, s)) ||
-		    !__replace_lv_with_error_segment(seg_metalv(seg, s)))
+		if (!_replace_lv_with_error_segment(seg_lv(seg, s)) ||
+		    !_replace_lv_with_error_segment(seg_metalv(seg, s)))
 			return 0;
 
 	if (!lv_update_and_reload(lv))


