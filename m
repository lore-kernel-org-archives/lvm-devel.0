From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  1 Jul 2016 21:23:39 +0000 (UTC)
Subject: master - raid0: Add raid0_meta segment type.
Message-ID: <20160701212339.3E41660237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8c2677ab92c3c3bd35ccab0d486ebce8db4fbb4
Commit:        d8c2677ab92c3c3bd35ccab0d486ebce8db4fbb4
Parent:        1df98222242d89c5c88d1122427ba5ae233e435a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 1 22:20:54 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 1 22:20:54 2016 +0100

raid0: Add raid0_meta segment type.

---
 WHATS_NEW                      |    1 +
 lib/metadata/lv_manip.c        |   28 ++-
 lib/metadata/raid_manip.c      |  461 +++++++++++++++++++++++++++++++---------
 lib/metadata/segtype.c         |    4 +
 lib/metadata/segtype.h         |    6 +-
 lib/metadata/takeover_matrix.h |    4 +-
 lib/raid/raid.c                |   31 ++--
 libdm/libdm-deptree.c          |   16 ++-
 tools/lvconvert.c              |   24 ++-
 tools/lvcreate.c               |   14 +-
 10 files changed, 444 insertions(+), 145 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d71ea8..e35ca82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.159 - 
 =================================
+  Add raid0_meta segment type that provides metadata space for raid conversions.
   Fix created link for a used pool for vgmknode.
   Introduce and use is_power_of_2 macro.
   Support conversions between striped and raid0 segment types.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a706578..6f02b16 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -115,6 +115,7 @@ enum {
 	LV_TYPE_SPARE,
 	LV_TYPE_VIRTUAL,
 	LV_TYPE_RAID0,
+	LV_TYPE_RAID0_META,
 	LV_TYPE_RAID1,
 	LV_TYPE_RAID10,
 	LV_TYPE_RAID4,
@@ -164,6 +165,7 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_SPARE] =				"spare",
 	[LV_TYPE_VIRTUAL] =				"virtual",
 	[LV_TYPE_RAID0] =				SEG_TYPE_NAME_RAID0,
+	[LV_TYPE_RAID0_META] =				SEG_TYPE_NAME_RAID0_META,
 	[LV_TYPE_RAID1] =				SEG_TYPE_NAME_RAID1,
 	[LV_TYPE_RAID10] =				SEG_TYPE_NAME_RAID10,
 	[LV_TYPE_RAID4] =				SEG_TYPE_NAME_RAID4,
@@ -929,6 +931,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	}
 
 	if (segtype_is_raid(segtype) &&
+	    !segtype_is_raid0(segtype) &&
 	    !(seg->meta_areas = dm_pool_zalloc(mem, areas_sz))) {
 		dm_pool_free(mem, seg); /* frees everything alloced since seg */
 		return_NULL;
@@ -3809,7 +3812,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	if (seg_is_raid(seg)) {
 		stripes = 1;
 		stripe_size = 0;
-		if (seg_is_raid0(seg))
+		if (seg_is_any_raid0(seg))
 			area_multiple = seg->area_count;
 	}
 
@@ -3960,14 +3963,19 @@ int lv_extend(struct logical_volume *lv,
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
-	if (!lv->le_count && segtype_is_pool(segtype)) {
-		/*
-		 * Pool allocations treat the metadata device like a mirror log.
-		 */
-		/* FIXME Support striped metadata pool */
-		log_count = 1;
-	} else if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype) && !lv->le_count)
-		log_count = mirrors * stripes;
+	if (!lv->le_count) {
+		if (segtype_is_pool(segtype))
+			/*
+			 * Pool allocations treat the metadata device like a mirror log.
+			 */
+			/* FIXME Support striped metadata pool */
+			log_count = 1;
+		else if (segtype_is_raid0_meta(segtype))
+			/* Extend raid0 metadata LVs too */
+			log_count = stripes;
+		else if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
+			log_count = mirrors * stripes;
+	}
 	/* FIXME log_count should be 1 for mirrors */
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
@@ -4961,7 +4969,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 						seg_size /= seg_mirrors;
 					lp->extents = logical_extents_used + seg_size;
 					break;
-				}
+			}
 			} else if (new_extents <= logical_extents_used + seg_logical_extents) {
 				seg_size = new_extents - logical_extents_used;
 				lp->extents = new_extents;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 71334b5..26b2645 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -22,6 +22,17 @@
 #include "lv_alloc.h"
 #include "lvm-string.h"
 
+static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
+{
+	if (new_stripes && new_stripes != first_seg(lv)->area_count) {
+		log_error("Cannot restripe LV %s from %" PRIu32 " to %u stripes during conversion.",
+			  display_lvname(lv), first_seg(lv)->area_count, new_stripes);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -88,6 +99,9 @@ static int _raid_in_sync(struct logical_volume *lv)
 {
 	dm_percent_t sync_percent;
 
+	if (seg_is_striped(first_seg(lv)))
+		return 1;
+
 	if (!lv_raid_percent(lv, &sync_percent)) {
 		log_error("Unable to determine sync status of %s/%s.",
 			  lv->vg->name, lv->name);
@@ -517,7 +531,8 @@ static int _alloc_image_components(struct logical_volume *lv,
  * be allocated from the same PV(s) as the data device.
  */
 static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
-			       struct logical_volume **meta_lv)
+			       struct logical_volume **meta_lv,
+			       struct dm_list *allocate_pvs)
 {
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
@@ -526,6 +541,9 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 
 	dm_list_init(&allocatable_pvs);
 
+	if (!allocate_pvs)
+		allocate_pvs = &allocatable_pvs;
+
 	if (!seg_is_linear(seg)) {
 		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
 			  "area for non-linear LV, %s", data_lv->name);
@@ -603,7 +621,7 @@ static int _raid_add_images(struct logical_volume *lv,
 			return 0;
 		}
 
-		if (!_alloc_rmeta_for_lv(lv, &lvl->lv))
+		if (!_alloc_rmeta_for_lv(lv, &lvl->lv, NULL))
 			return_0;
 
 		dm_list_add(&meta_lvs, &lvl->list);
@@ -845,7 +863,7 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
  *	  Otherwise, leave the [meta_]areas as AREA_UNASSIGNED and
  *	  seg->area_count unchanged.
  * @extracted_[meta|data]_lvs:  The LVs removed from the array.  If 'shift'
- *		              is set, then there will likely be name conflicts.
+ *			      is set, then there will likely be name conflicts.
  *
  * This function extracts _both_ portions of the indexed image.  It
  * does /not/ commit the results.  (IOW, erroring-out requires no unwinding
@@ -1401,7 +1419,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	for (s = 0; s < seg->area_count; s++) {
 		log_debug_metadata("Allocating new metadata LV for %s",
 				   seg_lv(seg, s)->name);
-		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv))) {
+		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv), NULL)) {
 			log_error("Failed to allocate metadata LV for %s in %s",
 				  seg_lv(seg, s)->name, lv->name);
 			return 0;
@@ -1813,6 +1831,205 @@ static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *rem
 {
 	return _eliminate_extracted_lvs_optional_write_vg(vg, removal_lvs, 1);
 }
+
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
+
+	if (!raid_devs)
+		return_0;
+
+	if (!(lvl_array = dm_pool_zalloc(lv->vg->vgmem, raid_devs * sizeof(*lvl_array))))
+		return_0;
+
+	dm_list_iterate_items(lvl, new_data_lvs) {
+		log_debug_metadata("Allocating new metadata LV for %s", lvl->lv->name);
+
+		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
+			log_error("Failed to allocate metadata LV for %s in %s",
+				  lvl->lv->name, lv->vg->name);
+			return 0;
+		}
+
+		dm_list_add(new_meta_lvs, &lvl_array[a++].list);
+		
+		dm_list_iterate_items(lvl1, new_meta_lvs)
+			if (!_avoid_pvs_with_other_images_of_lv(lvl1->lv, allocate_pvs))
+				return_0;
+	}
+
+	_clear_allocation_prohibited(allocate_pvs);
+
+	return 1;
+}
+
+/*
+ * Allocate metadata devs for all data devs of an LV
+ */
+static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
+				    struct dm_list *meta_lvs,
+				    struct dm_list *allocate_pvs)
+{
+	uint32_t s;
+	struct lv_list *lvl_array;
+	struct dm_list data_lvs;
+	struct lv_segment *seg = first_seg(lv);
+
+	dm_list_init(&data_lvs);
+
+	if (!(seg->meta_areas = dm_pool_zalloc(lv->vg->vgmem, seg->area_count * sizeof(*seg->meta_areas))))
+		return 0;
+
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
+		return_0;
+
+	for (s = 0; s < seg->area_count; s++) {
+		lvl_array[s].lv = seg_lv(seg, s);
+		dm_list_add(&data_lvs, &lvl_array[s].list);
+	}
+
+	if (!_alloc_rmeta_devs_for_rimage_devs(lv, &data_lvs, meta_lvs, allocate_pvs)) {
+		log_error("Failed to allocate metadata LVs for %s", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Add metadata areas to raid0
+ */
+static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list meta_lvs;
+
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
+
+	return 1;
+}
+
+/*
+ * Add/remove metadata areas to/from raid0
+ */
+static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
+					     int update_and_reload,
+					     struct dm_list *allocate_pvs,
+					     struct dm_list *removal_lvs)
+{
+	uint64_t new_raid_type_flag;
+	struct lv_segment *seg = first_seg(lv);
+
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
+
+	return 1;
+}
+
+static int _raid0_meta_change_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
+				     int yes, int force, int alloc_metadata_devs,
+				     struct dm_list *allocate_pvs)
+{
+	struct dm_list removal_lvs;
+
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
+
+
 /*
  * Convert a RAID0 set to striped
  */
@@ -1822,6 +2039,11 @@ static int _convert_raid0_to_striped(struct logical_volume *lv,
 {
 	struct lv_segment *seg = first_seg(lv);
 
+	/* Remove metadata devices */
+	if (seg_is_raid0_meta(seg) &&
+	    !_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, NULL, removal_lvs))
+		return_0;
+
 	/* Move the AREA_PV areas across to new top-level segments of type "striped" */
 	if (!_raid0_to_striped_retrieve_segments_and_lvs(lv, removal_lvs)) {
 		log_error("Failed to retrieve raid0 segments from %s.", lv->name);
@@ -1851,6 +2073,7 @@ static int _convert_raid0_to_striped(struct logical_volume *lv,
  * Optionally updates metadata and reloads mappings.
  */
 static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
+						    int alloc_metadata_devs,
 						    int update_and_reload,
 						    struct dm_list *allocate_pvs)
 {
@@ -1924,12 +2147,18 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 
 	lv->status |= RAID;
 
+	/* Allocate metadata LVs if requested */
+	if (alloc_metadata_devs && !_raid0_add_or_remove_metadata_lvs(lv, 0, allocate_pvs, NULL))
+		return NULL;
+
 	if (update_and_reload && !lv_update_and_reload(lv))
 		return NULL;
 
 	return raid0_seg;
 }
 
+/************************************************/
+
 /*
  * Individual takeover functions.
  */
@@ -1959,7 +2188,9 @@ static int _takeover_noop(TAKEOVER_FN_ARGS)
 static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 {
 	log_error("Converting the segment type for %s from %s to %s is not supported.",
-		  display_lvname(lv), lvseg_name(first_seg(lv)), new_segtype->name);
+		  display_lvname(lv), lvseg_name(first_seg(lv)),
+		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	return 0;
 }
@@ -1975,10 +2206,12 @@ static int _takeover_not_possible(takeover_fn_t takeover_fn)
 	return 0;
 }
 
-static int _takeover_unsupported_yet(const struct logical_volume *lv, const struct segment_type *new_segtype)
+static int _takeover_unsupported_yet(const struct logical_volume *lv, const unsigned new_stripes, const struct segment_type *new_segtype)
 {
 	log_error("Converting the segment type for %s from %s to %s is not supported yet.",
-		  display_lvname(lv), lvseg_name(first_seg(lv)), new_segtype->name);
+		  display_lvname(lv), lvseg_name(first_seg(lv)),
+		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	return 0;
 }
@@ -1988,32 +2221,32 @@ static int _takeover_unsupported_yet(const struct logical_volume *lv, const stru
  */
 static int _takeover_from_linear_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_linear_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_linear_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_linear_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_mirrored_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_mirrored_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_mirrored_to_raid1(TAKEOVER_FN_ARGS)
@@ -2023,217 +2256,246 @@ static int _takeover_from_mirrored_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_mirrored_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_mirrored_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_to_linear(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
-
 static int _takeover_from_raid0_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	if (!_raid0_meta_change_wrapper(lv, new_segtype, new_stripes, yes, force, 1, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
 static int _takeover_from_raid0_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
-static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
+static int _raid0_to_striped_wrapper(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
+				     int yes, int force,
+				     struct dm_list *allocate_pvs)
 {
 	struct dm_list removal_lvs;
 
 	dm_list_init(&removal_lvs);
 
-        /* Archive metadata */
+	if (!_check_restriping(new_stripes, lv))
+		return_0;
+
+	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
 
 	/* FIXME update_and_reload is only needed if the LV is already active */
-	return _convert_raid0_to_striped(lv, 1, &removal_lvs);
+	/* FIXME Some of the validation in here needs moving before the archiving */
+	if (!_convert_raid0_to_striped(lv, 1 /* update_and_reload */, &removal_lvs))
+		return_0;
+
+	return 1;
+}
+
+static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
+{
+	if (!_raid0_to_striped_wrapper(lv, new_segtype, new_stripes, yes, force, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
-/*
 static int _takeover_from_raid0_meta_to_linear(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	if (!_raid0_meta_change_wrapper(lv, new_segtype, new_stripes, yes, force, 0, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
 static int _takeover_from_raid0_meta_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid0_meta_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	if (!_raid0_to_striped_wrapper(lv, new_segtype, new_stripes, yes, force, allocate_pvs))
+		return_0;
+
+	return 1;
 }
-*/
 
 static int _takeover_from_raid1_to_linear(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid1_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_linear(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
+				     uint32_t new_stripes,
 				     int yes, int force, int alloc_metadata_devs,
 				     struct dm_list *allocate_pvs)
 {
+	if (!_check_restriping(new_stripes, lv))
+		return_0;
+
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
 
 	/* FIXME update_and_reload is only needed if the LV is already active */
 	/* FIXME Some of the validation in here needs moving before the archiving */
-	if (!_convert_striped_to_raid0(lv, 1 /* update_and_reload */, allocate_pvs))
+	if (!_convert_striped_to_raid0(lv, alloc_metadata_devs, 1 /* update_and_reload */, allocate_pvs))
 		return_0;
 
 	return 1;
@@ -2241,88 +2503,94 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 
 static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _striped_to_raid0_wrapper(lv, new_segtype, yes, force, 0, allocate_pvs);
+	if (!_striped_to_raid0_wrapper(lv, new_segtype, new_stripes, yes, force, 0, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
 static int _takeover_from_striped_to_raid01(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_striped_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	if (!_striped_to_raid0_wrapper(lv, new_segtype, new_stripes, yes, force, 1, allocate_pvs))
+		return_0;
+
+	return 1;
 }
 
 static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 /*
 static int _takeover_from_raid01_to_raid01(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid01_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid01_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_linear(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_raid01(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
 static int _takeover_from_raid10_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_segtype);
+	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 */
 
@@ -2336,11 +2604,10 @@ static unsigned _segtype_ix(const struct segment_type *segtype, uint32_t area_co
 	int i = 2, j;
 
 	/* Linear special case */
-	if (segtype_is_striped(segtype)) {
+	if (segtype_is_striped(segtype) && !segtype_is_any_raid0(segtype)) {
 		if (area_count == 1)
 			return 0;	/* linear */
-		if (!segtype_is_raid0(segtype))
-			return 1;	/* striped */
+		return 1;	/* striped */
 	}
 
 	while ((j = _segtype_index[i++]))
@@ -2401,11 +2668,14 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!_check_max_raid_devices(new_image_count))
-		return_0;
-
 	stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
 
+	if (segtype_is_striped(new_segtype))
+		new_image_count = stripes;
+
+	if (segtype_is_raid(new_segtype) && !_check_max_raid_devices(new_image_count))
+		return_0;
+
 	/* FIXME Ensure caller does *not* set wrong default value! */
 	/* Define new stripe size if not passed in */
 	stripe_size = new_stripe_size ?: seg->stripe_size;
@@ -2414,7 +2684,12 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
-		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, new_stripe_size, allocate_pvs);
+		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size, allocate_pvs);
+
+	log_verbose("Converting %s from %s to %s.",
+		    display_lvname(lv), lvseg_name(first_seg(lv)),
+		    (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	/* FIXME If not active, prompt and activate */
 	/* FIXME Some operations do not require the LV to be active */
@@ -2439,7 +2714,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, new_stripe_size, allocate_pvs);
+	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size, allocate_pvs);
 }
 
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
@@ -2520,28 +2795,6 @@ has_enough_space:
 	return 1;
 }
 
-static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
-{
-	struct dm_list *allocate_pvs = (struct dm_list *) data;
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, allocate_pvs)
-		if (!lv_is_partial(lv) && lv_is_on_pv(lv, pvl->pv))
-			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
-
-	return 1;
- }
-
-/*
- * Prevent any PVs holding other image components of @lv from being used for allocation
- * by setting the internal PV_ALLOCATION_PROHIBITED flag to use it to avoid generating
- * pv maps for those PVs.
- */
-static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
-{
-	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
-}
-
 /*
  * lv_raid_replace
  * @lv
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 8d8b28c..2b060da 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -22,6 +22,10 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 {
 	struct segment_type *segtype;
 
+	/* FIXME Register this properly within striped.c */
+	if (!strcmp(str, SEG_TYPE_NAME_LINEAR))
+		str = SEG_TYPE_NAME_STRIPED;
+
 	dm_list_iterate_items(segtype, &cmd->segtypes)
 		if (!strcmp(segtype->name, str))
 			return segtype;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index b43f228..2afb02a 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -48,6 +48,7 @@ struct dev_manager;
 #define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000ULL
 
 #define SEG_RAID0		0x0000000000040000ULL
+#define SEG_RAID0_META		0x0000000000080000ULL
 #define SEG_RAID1		0x0000000000100000ULL
 #define SEG_RAID10		0x0000000000200000ULL
 #define SEG_RAID4		0x0000000000400000ULL
@@ -82,6 +83,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_ZERO		"zero"
 #define SEG_TYPE_NAME_RAID		"raid"
 #define SEG_TYPE_NAME_RAID0		"raid0"
+#define SEG_TYPE_NAME_RAID0_META	"raid0_meta"
 #define SEG_TYPE_NAME_RAID1		"raid1"
 #define SEG_TYPE_NAME_RAID10		"raid10"
 #define SEG_TYPE_NAME_RAID4		"raid4"
@@ -102,7 +104,8 @@ struct dev_manager;
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
 #define segtype_is_raid0(segtype)	((segtype)->flags & SEG_RAID0 ? 1 : 0)
-#define segtype_is_any_raid0(segtype)	((segtype)->flags & SEG_RAID0 ? 1 : 0)
+#define segtype_is_raid0_meta(segtype)	((segtype)->flags & SEG_RAID0_META ? 1 : 0)
+#define segtype_is_any_raid0(segtype)	((segtype)->flags & (SEG_RAID0 | SEG_RAID0_META) ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_raid1(segtype)	((segtype)->flags & SEG_RAID1 ? 1 : 0)
 #define segtype_is_raid4(segtype)	((segtype)->flags & SEG_RAID4 ? 1 : 0)
@@ -135,6 +138,7 @@ struct dev_manager;
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
 #define seg_is_pool(seg)	segtype_is_pool((seg)->segtype)
 #define seg_is_raid0(seg)	segtype_is_raid0((seg)->segtype)
+#define seg_is_raid0_meta(seg)	segtype_is_raid0_meta((seg)->segtype)
 #define seg_is_any_raid0(seg)	segtype_is_any_raid0((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
 #define seg_is_raid1(seg)	segtype_is_raid1((seg)->segtype)
diff --git a/lib/metadata/takeover_matrix.h b/lib/metadata/takeover_matrix.h
index 25a8197..0736643 100644
--- a/lib/metadata/takeover_matrix.h
+++ b/lib/metadata/takeover_matrix.h
@@ -84,7 +84,7 @@ static uint64_t _segtype_index[] = {
 	1, /* striped */
 	SEG_MIRROR,
 	SEG_RAID0,
-	// SEG_RAID0_META,
+	SEG_RAID0_META,
 	SEG_RAID1,
 	SEG_RAID4 | SEG_RAID5_LS | SEG_RAID5_LA | SEG_RAID5_LS | SEG_RAID5_RS | SEG_RAID5_RA | SEG_RAID5_N,
 	SEG_RAID6_LS_6 | SEG_RAID6_LA_6 | SEG_RAID6_RS_6 | SEG_RAID6_RA_6 | SEG_RAID6_NC | SEG_RAID6_NR | SEG_RAID6_ZR | SEG_RAID6_N_6,
@@ -108,7 +108,7 @@ static takeover_fn_t _takeover_fns[][11] = {
         /* striped    */ { X      ,  N      ,  X      ,  str_r0,  str_r0m,  lin_r1,  str_r45,  str_r6,  str_r10,  str_r01, X },
         /* mirror     */ { X      ,  X      ,  N      ,  mir_r0,  mir_r0m,  mir_r1,  mir_r45,  X     ,  mir_r10,  X      , X },
         /* raid0      */ { r0__lin,  r0__str,  r0__mir,  N     ,  r0__r0m,  r0__r1,  r0__r45,  r0__r6,  r0__r10,  X      , X },
-        /* raid0_meta */ // { r0m_lin,  r0m_str,  r0m_mir,  r0m_r0,  N      ,  r0m_r1,  r0m_r45,  r0m_r6,  r0m_r10,  X      , X },
+        /* raid0_meta */ { r0m_lin,  r0m_str,  r0m_mir,  r0m_r0,  N      ,  r0m_r1,  r0m_r45,  r0m_r6,  r0m_r10,  X      , X },
         /* raid1      */ { r1__lin,  r1__str,  r1__mir,  r1__r0,  r1__r0m,  r1__r1,  r1__r45,  X     ,  r1__r10,  X      , X },
         /* raid4/5    */ { r45_lin,  r45_str,  r45_mir,  r45_r0,  r45_r0m,  r45_r1,  r45_r54,  r45_r6,  X      ,  X      , X },
         /* raid6      */ { X      ,  r6__str,  X      ,  r6__r0,  r6__r0m,  X     ,  r6__r45,  X     ,  X      ,  X      , X },
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e299e17..ef5794f 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -153,7 +153,7 @@ static int _raid_text_import(struct lv_segment *seg,
 		}
 	}
 
-	if (!dm_config_get_list(sn, seg_is_any_raid0(seg) ? "raid0_lvs" : "raids", &cv)) {
+	if (!dm_config_get_list(sn, seg_is_raid0(seg) ? "raid0_lvs" : "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
 			  dm_config_parent_name(sn), seg->lv->name);
@@ -179,7 +179,7 @@ static int _raid_text_export_raid0(const struct lv_segment *seg, struct formatte
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
 
-	return out_areas(f, seg, "raid0_lv");
+	return out_areas(f, seg, seg_is_raid0(seg) ? "raid0_lv" : "raid");
 }
 
 static int _raid_text_export_raid(const struct lv_segment *seg, struct formatter *f)
@@ -469,19 +469,20 @@ static const struct raid_type {
 	unsigned parity;
 	uint64_t extra_flags;
 } _raid_types[] = {
-	{ SEG_TYPE_NAME_RAID0,    0, SEG_RAID0 | SEG_AREAS_STRIPED },
-	{ SEG_TYPE_NAME_RAID1,    0, SEG_RAID1 | SEG_AREAS_MIRRORED },
-	{ SEG_TYPE_NAME_RAID10,   0, SEG_RAID10 | SEG_AREAS_MIRRORED },
-	{ SEG_TYPE_NAME_RAID4,    1, SEG_RAID4 },
-	{ SEG_TYPE_NAME_RAID5,    1, SEG_RAID5 },
-	{ SEG_TYPE_NAME_RAID5_LA, 1, SEG_RAID5_LA },
-	{ SEG_TYPE_NAME_RAID5_LS, 1, SEG_RAID5_LS },
-	{ SEG_TYPE_NAME_RAID5_RA, 1, SEG_RAID5_RA },
-	{ SEG_TYPE_NAME_RAID5_RS, 1, SEG_RAID5_RS },
-	{ SEG_TYPE_NAME_RAID6,    2, SEG_RAID6 },
-	{ SEG_TYPE_NAME_RAID6_NC, 2, SEG_RAID6_NC },
-	{ SEG_TYPE_NAME_RAID6_NR, 2, SEG_RAID6_NR },
-	{ SEG_TYPE_NAME_RAID6_ZR, 2, SEG_RAID6_ZR }
+	{ SEG_TYPE_NAME_RAID0,      0, SEG_RAID0 | SEG_AREAS_STRIPED },
+	{ SEG_TYPE_NAME_RAID0_META, 0, SEG_RAID0_META | SEG_AREAS_STRIPED },
+	{ SEG_TYPE_NAME_RAID1,      0, SEG_RAID1 | SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID10,     0, SEG_RAID10 | SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID4,      1, SEG_RAID4 },
+	{ SEG_TYPE_NAME_RAID5,      1, SEG_RAID5 },
+	{ SEG_TYPE_NAME_RAID5_LA,   1, SEG_RAID5_LA },
+	{ SEG_TYPE_NAME_RAID5_LS,   1, SEG_RAID5_LS },
+	{ SEG_TYPE_NAME_RAID5_RA,   1, SEG_RAID5_RA },
+	{ SEG_TYPE_NAME_RAID5_RS,   1, SEG_RAID5_RS },
+	{ SEG_TYPE_NAME_RAID6,      2, SEG_RAID6 },
+	{ SEG_TYPE_NAME_RAID6_NC,   2, SEG_RAID6_NC },
+	{ SEG_TYPE_NAME_RAID6_NR,   2, SEG_RAID6_NR },
+	{ SEG_TYPE_NAME_RAID6_ZR,   2, SEG_RAID6_ZR }
 };
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index dd5ee9e..d74bb9c 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -43,6 +43,7 @@ enum {
 	SEG_THIN_POOL,
 	SEG_THIN,
 	SEG_RAID0,
+	SEG_RAID0_META,
 	SEG_RAID1,
 	SEG_RAID10,
 	SEG_RAID4,
@@ -76,6 +77,7 @@ static const struct {
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
 	{ SEG_RAID0, "raid0"},
+	{ SEG_RAID0_META, "raid0_meta"},
 	{ SEG_RAID1, "raid1"},
 	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
@@ -2134,6 +2136,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 			}
 			break;
 		case SEG_RAID0:
+		case SEG_RAID0_META:
 		case SEG_RAID1:
 		case SEG_RAID10:
 		case SEG_RAID4:
@@ -2353,6 +2356,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	uint32_t i;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
+	unsigned type = seg->type;
 
 	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
 		param_count++;
@@ -2366,10 +2370,14 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	param_count += _get_params_count(seg->rebuilds);
 	param_count += _get_params_count(seg->writemostly);
 
-	if ((seg->type == SEG_RAID1) && seg->stripe_size)
+	if ((type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
-	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[seg->type].target,
+	/* Kernel only expects "raid0", not "raid0_meta" */
+	if (type == SEG_RAID0_META)
+		type = SEG_RAID0;
+
+	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[type].target,
 		    param_count, seg->stripe_size);
 
 	if (seg->flags & DM_NOSYNC)
@@ -2576,6 +2584,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			    seg->iv_offset : *seg_start);
 		break;
 	case SEG_RAID0:
+	case SEG_RAID0_META:
 	case SEG_RAID1:
 	case SEG_RAID10:
 	case SEG_RAID4:
@@ -3853,6 +3862,7 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 
 	switch (seg->type) {
 	case SEG_RAID0:
+	case SEG_RAID0_META:
 	case SEG_RAID1:
 	case SEG_RAID4:
 	case SEG_RAID5_LA:
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a6f2704..9ce6ef5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -285,7 +285,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	}
 
 	/* FIXME: Check thin-pool and thin more thoroughly! */
-	if (!strcmp(type_str, "snapshot") ||
+	if (!strcmp(type_str, "snapshot") || !strcmp(type_str, "linear") ||
 	    !strcmp(type_str, "striped") ||
 	    !strncmp(type_str, "raid", 4) ||
 	    !strcmp(type_str, "cache-pool") || !strcmp(type_str, "cache") ||
@@ -304,7 +304,7 @@ static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_st
 
 static int _raid0_type_requested(struct cmd_context *cmd, const char *type_str)
 {
-	return (!strcmp(type_str, "raid0"));
+	return (!strcmp(type_str, "raid0") || !strcmp(type_str, "raid0_meta"));
 }
 
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
@@ -316,7 +316,12 @@ static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *t
 
 static int _striped_type_requested(struct cmd_context *cmd, const char *type_str)
 {
-	return (!strcmp(type_str, "striped"));
+	return (!strcmp(type_str, SEG_TYPE_NAME_STRIPED) || !strcmp(type_str, SEG_TYPE_NAME_LINEAR));
+}
+
+static int _linear_type_requested(const char *type_str)
+{
+	return (!strcmp(type_str, SEG_TYPE_NAME_LINEAR));
 }
 
 static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
@@ -584,7 +589,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	     lp->repair || arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(cmd, lp->type_str) ||
 	     _striped_type_requested(cmd, lp->type_str))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
-			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped, "
+			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped/--type linear, "
 			  "--mirrorlog, --repair or --thinpool.");
 		return 0;
 	}
@@ -593,7 +598,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str) ||
 	      _raid0_type_requested(cmd, lp->type_str) || lp->repair || arg_is_set(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
-			  "with --mirrors/--type mirror/--type raid*/--type striped, --repair and --thinpool");
+			  "with --mirrors/--type mirror/--type raid*/--type striped/--type linear, --repair and --thinpool");
 		return 0;
 	}
 
@@ -769,8 +774,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
 		} 
-	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or raid0 */
-		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped",
+	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or linear or raid0 */
+		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
 					 -1))
 			return_0;
@@ -778,6 +783,11 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
+		/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
+		/* The default keeps existing number of stripes, handled inside the library code */
+		if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
+			lp->stripes = 0;
+
 		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 			return_0;
 	} /* else segtype will default to current type */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8db68c1..0dd9b1e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -547,6 +547,13 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
+	if (lp->stripes < 2 && segtype_is_any_raid0(lp->segtype))
+		if (arg_count(cmd, stripes_ARG)) {
+			/* User supplied the bad argument */
+			log_error("Segment type %s requires 2 or more stripes.", lp->segtype->name);
+			return 0;
+		}
+
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
@@ -1238,12 +1245,13 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  lp->segtype->name);
 			return 0;
 		}
-	} else if (segtype_is_raid10(lp->segtype)) {
+	} else if (segtype_is_any_raid0(lp->segtype) ||
+		   segtype_is_raid10(lp->segtype)) {
 		if (!arg_is_set(cmd, stripes_ARG))
 			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {
-			log_error("Unable to create RAID10 LV,"
-				  " insufficient number of devices.");
+			log_error("Unable to create RAID(1)0 LV: "
+				  "insufficient number of devices.");
 			return 0;
 		}
 	}


