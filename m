From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 06 Oct 2011 10:38:00 -0500
Subject: [PATCH] LVM RAID: Add ability to convert linear to RAID1
Message-ID: <1317915480.21095.1.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the ability to convert linear LVs to RAID1

Example:
~> lvconvert --type raid1 -m 1 vg/lv

The following steps are performed to convert linear to RAID1:
1) Allocate a metadata device from the same PV as the linear device
   to provide the metadata/data LV pair required for all RAID components.
2) Allocate the required number of metadata/data LV pairs for the
   remaining additional images.
3) Clear the metadata LVs.  This performs a LVM metadata update.
4) Create the top-level RAID LV and add the component devices.

We want to make any failure easy to unwind.  This is why we don't create the
top-level LV and add the components until the last step.  Should anything
happen before that, the user could simply remove the unnecessary images.  Also,
we want to ensure that the metadata LVs are cleared before forming the array to
prevent stale information from polluting the new array.

A new macro 'seg_is_linear' was added to allow us to distinguish linear LVs
from striped LVs.

The ability to reserve LV names was added to prevent generate_lv_name from
choosing a name which we want to use in the future.  The need for this comes
from the required order of steps when converting linear LVs to RAID1, and
the following constraints:
1) We want the linear LV to occupy the first position in the array (*_rimage_0)
2) We must allocate the new metadata/data LVs in pairs to allow the allocator
   to group them together on the same device cleanly.
3) The linear LV does not aquire its sub-lv name until insert_layer_for_lv is
   called.
'generate_lv_name' is used in all the above cases to create names for the
rimage and rmeta LVs.  If we can't reserve the *_rimage_0 name, then the
rmeta and rimage LV pair names would not match, nor would the converting LV's
rimage name be correct.

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2866,10 +2866,40 @@ out:
 	return r;
 }
 
+int reserve_lv_name(struct volume_group *vg, const char *name)
+{
+	struct str_list *strl;
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (!strcmp(lvl->lv->name, name)) {
+			log_error("Unable to reserve existing LV name, %s",
+				  name);
+			return 0;
+		}
+
+	if (!(strl = dm_pool_zalloc(vg->vgmem, sizeof(*strl))))
+		goto fail;
+
+	if (!(strl->str = dm_pool_strdup(vg->vgmem, name)))
+		goto fail;
+
+	dm_list_add(&vg->reserved_lv_names, &strl->list);
+	log_debug("Reserving logical volume name, %s in volume group %s",
+		  name, vg->name);
+
+	return 1;
+
+fail:
+	log_error("Unable to reserve LV name, %s:  Out of memory", name);
+	return 0;
+}
+
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len)
 {
 	struct lv_list *lvl;
+	struct str_list *strl;
 	int high = -1, i;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -2880,6 +2910,14 @@ char *generate_lv_name(struct volume_gro
 			high = i;
 	}
 
+	dm_list_iterate_items(strl, &vg->reserved_lv_names) {
+		if (sscanf(strl->str, format, &i) != 1)
+			continue;
+
+		if (i > high)
+			high = i;
+	}
+
 	if (dm_snprintf(buffer, len, format, high + 1) < 0)
 		return NULL;
 
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -801,6 +801,7 @@ struct dm_list *lvs_using_lv(struct cmd_
 			  struct logical_volume *lv);
 
 uint32_t find_free_lvnum(struct logical_volume *lv);
+int reserve_lv_name(struct volume_group *vg, const char *name);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -24,6 +24,8 @@
 #include "str_list.h"
 #include "memlock.h"
 
+#define RAID_REGION_SIZE 1024
+
 uint32_t lv_raid_image_count(const struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -125,6 +127,45 @@ static int _lv_is_on_pvs(struct logical_
 	return 0;
 }
 
+static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
+{
+	uint32_t s;
+	struct pv_list *pvl;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_linear(seg)) {
+		log_error(INTERNAL_ERROR
+			  "_get_pv_list_for_lv only handles linear volumes");
+		return 0;
+	}
+
+	log_debug("Getting list of PVs that %s/%s is on:",
+		  lv->vg->name, lv->name);
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV) {
+				log_error(INTERNAL_ERROR
+					  "Linear seg_type should be AREA_PV");
+				return 0;
+			}
+
+			if (!(pvl = dm_pool_zalloc(lv->vg->cmd->mem,
+						   sizeof(*pvl)))) {
+				log_error("Failed to allocate memory");
+				return 0;
+			}
+
+			pvl->pv = seg_pv(seg, s);
+			log_debug("  %s/%s is on %s", lv->vg->name, lv->name,
+				  pv_dev_name(pvl->pv));
+			dm_list_add(pvs, &pvl->list);
+		}
+	}
+
+	return 1;
+}
+
 static int _raid_in_sync(struct logical_volume *lv)
 {
 	percent_t sync_percent;
@@ -411,7 +452,9 @@ static int _alloc_image_components(struc
 				   struct dm_list *new_data_lvs)
 {
 	uint32_t s;
+	uint32_t region_size;
 	struct lv_segment *seg = first_seg(lv);
+	const struct segment_type *segtype;
 	struct alloc_handle *ah;
 	struct dm_list *parallel_areas;
 	struct logical_volume *tmp_lv;
@@ -425,8 +468,18 @@ static int _alloc_image_components(struc
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
 		return_0;
 
-	if (!(ah = allocate_extents(lv->vg, NULL, seg->segtype, 0, count, count,
-				    seg->region_size, lv->le_count, pvs,
+	if (seg_is_linear(seg))
+		region_size = RAID_REGION_SIZE;
+	else
+		region_size = seg->region_size;
+
+	if (seg_is_raid(seg))
+		segtype = seg->segtype;
+	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
+		return_0;
+
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
+				    region_size, lv->le_count, pvs,
 				    lv->alloc, parallel_areas)))
 		return_0;
 
@@ -452,12 +505,60 @@ static int _alloc_image_components(struc
 	return 1;
 }
 
+/*
+ * _alloc_rmeta_for_lv
+ * @lv
+ *
+ * Allocate a RAID metadata device for the given LV (which is or will
+ * be the associated RAID data device).  The new metadata device must
+ * be allocated from the same PV(s) as the data device.
+ */
+static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
+			       struct logical_volume **meta_lv)
+{
+	struct dm_list allocatable_pvs;
+	struct alloc_handle *ah;
+	struct lv_segment *seg = first_seg(data_lv);
+
+	dm_list_init(&allocatable_pvs);
+
+	if (!seg_is_linear(seg)) {
+		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
+			  "area for non-linear LV, %s", data_lv->name);
+		return 0;
+	}
+
+	if (strstr("_mimage_", data_lv->name)) {
+		log_error("Unable to alloc metadata device for mirror device");
+		return 0;
+	}
+
+	if (!_get_pv_list_for_lv(data_lv, &allocatable_pvs)) {
+		log_error("Failed to build list of PVs for %s/%s",
+			  data_lv->vg->name, data_lv->name);
+		return 0;
+	}
+
+	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
+				    seg->region_size,
+				    1 /*RAID_METADATA_AREA_LEN*/,
+				    &allocatable_pvs, data_lv->alloc, NULL)))
+		return_0;
+
+	if (!_alloc_image_component(data_lv, ah, 0, RAID_META, meta_lv))
+		return_0;
+
+	alloc_destroy(ah);
+	return 1;
+}
+
 static int _raid_add_images(struct logical_volume *lv,
 			    uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
 	uint32_t count = new_count - old_count;
+	uint64_t status_mask = -1;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list meta_lvs, data_lvs;
@@ -467,7 +568,29 @@ static int _raid_add_images(struct logic
 	dm_list_init(&meta_lvs); /* For image addition */
 	dm_list_init(&data_lvs); /* For image addition */
 
-	if (!seg_is_raid(seg)) {
+	/*
+	 * If the segtype is linear, then we must allocate a metadata
+	 * LV to accompany it.
+	 */
+	if (seg_is_linear(seg)) {
+		char reserve_name[strlen(lv->name) + 12];
+		sprintf(reserve_name, "%s_rimage_0", lv->name);
+		if (!reserve_lv_name(lv->vg, reserve_name))
+			return_0;
+
+		/* A complete resync will be done, no need to mark each sub-lv */
+		status_mask = ~(LV_NOTSYNCED);
+
+		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
+			log_error("Memory allocation failed");
+			return 0;
+		}
+
+		if (!_alloc_rmeta_for_lv(lv, &lvl->lv))
+			return_0;
+
+		dm_list_add(&meta_lvs, &lvl->list);
+	} else if (!seg_is_raid(seg)) {
 		log_error("Unable to add RAID images to %s of segment type %s",
 			  lv->name, seg->segtype->name);
 		return 0;
@@ -482,6 +605,21 @@ static int _raid_add_images(struct logic
 	if (!_clear_lvs(&meta_lvs))
 		goto fail;
 
+	if (seg_is_linear(seg)) {
+		first_seg(lv)->status |= RAID_IMAGE;
+		if (!insert_layer_for_lv(lv->vg->cmd, lv,
+					 RAID | LVM_READ | LVM_WRITE,
+					 "_rimage_0"))
+			return_0;
+
+		lv->status |= RAID;
+		seg = first_seg(lv);
+		seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
+		seg->region_size = RAID_REGION_SIZE;
+		seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1");
+		if (!seg->segtype)
+			return_0;
+	}
 /*
 FIXME: It would be proper to activate the new LVs here, instead of having
 them activated by the suspend.  However, this causes residual device nodes
@@ -504,16 +642,21 @@ to be left for these sub-lvs.
 	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
 					 new_count * sizeof(*new_areas))))
 		goto fail;
-	memcpy(new_areas, seg->meta_areas,
-	       seg->area_count * sizeof(*seg->meta_areas));
+	if (seg->meta_areas)
+		memcpy(new_areas, seg->meta_areas,
+		       seg->area_count * sizeof(*seg->meta_areas));
 	seg->meta_areas = new_areas;
 	seg->area_count = new_count;
 
+	/* Add extra meta area when converting from linear */
+	s = (old_count == 1) ? 0 : old_count;
+
 	/* Set segment areas for metadata sub_lvs */
-	s = old_count;
 	dm_list_iterate_items(lvl, &meta_lvs) {
 		log_debug("Adding %s to %s",
 			  lvl->lv->name, lv->name);
+		lvl->lv->status &= status_mask;
+		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
 			log_error("Failed to add %s to %s",
@@ -523,11 +666,14 @@ to be left for these sub-lvs.
 		s++;
 	}
 
-	/* Set segment areas for data sub_lvs */
 	s = old_count;
+
+	/* Set segment areas for data sub_lvs */
 	dm_list_iterate_items(lvl, &data_lvs) {
 		log_debug("Adding %s to %s",
 			  lvl->lv->name, lv->name);
+		lvl->lv->status &= status_mask;
+		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
 			log_error("Failed to add %s to %s",
@@ -810,12 +956,6 @@ int lv_raid_change_image_count(struct lo
 			       uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
-	struct lv_segment *seg = first_seg(lv);
-
-	if (!seg_is_mirrored(seg)) {
-		log_error("Unable to change image count of non-mirrored RAID.");
-		return 0;
-	}
 
 	if (old_count == new_count) {
 		log_error("%s/%s already has image count of %d",
Index: LVM2/lib/metadata/segtype.h
===================================================================
--- LVM2.orig/lib/metadata/segtype.h
+++ LVM2/lib/metadata/segtype.h
@@ -47,6 +47,7 @@ struct dev_manager;
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
+#define     seg_is_linear(seg)  (seg_is_striped(seg) && !(seg)->stripe_size)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
Index: LVM2/lib/metadata/vg.c
===================================================================
--- LVM2.orig/lib/metadata/vg.c
+++ LVM2/lib/metadata/vg.c
@@ -48,6 +48,7 @@ struct volume_group *alloc_vg(const char
 	dm_list_init(&vg->pvs_to_create);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->reserved_lv_names);
 	dm_list_init(&vg->removed_pvs);
 
 	log_debug("Allocated VG %s at %p.", vg->name, vg);
Index: LVM2/lib/metadata/vg.h
===================================================================
--- LVM2.orig/lib/metadata/vg.h
+++ LVM2/lib/metadata/vg.h
@@ -91,6 +91,14 @@ struct volume_group {
 	struct dm_list tags;
 
 	/*
+	 * The 'reserved_lv_names' list is used by the
+	 * [generate|reserve]_lv_name functions.  'generate_lv_name' will not
+	 * generate an LV name that exists or has been reserved by
+	 * 'reserve_lv_name'.
+	 */
+	struct dm_list reserved_lv_names;
+
+	/*
 	 * FIXME: Move the next fields into a different struct?
 	 */
 
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -98,6 +98,7 @@ xx(lvconvert,
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
+   "\t[--type SegmentType]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -141,7 +142,7 @@ xx(lvconvert,
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, trackchanges_ARG,
-   stripes_long_ARG, stripesize_ARG, test_ARG,
+   type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -304,7 +304,8 @@ static int _read_params(struct lvconvert
 			return 0;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "mirror")))
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "mirror"));
+		if (!lp->segtype)
 			return_0;
 	}
 
@@ -1393,7 +1394,7 @@ static int is_valid_raid_conversion(cons
 	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
 		return_0;  /* Not converting to or from RAID? */
 
-	return 0;
+	return 1;
 }
 
 static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
@@ -1405,7 +1406,9 @@ static int lvconvert_raid(struct logical
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;
 
-	if (arg_count(cmd, mirrors_ARG) && !seg_is_mirrored(seg)) {
+	/* Can only change image count for raid1 and linear */
+	if (arg_count(cmd, mirrors_ARG) &&
+	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
 			  seg->segtype->name);
 		return 0;



