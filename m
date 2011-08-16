From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:19:24 -0500
Subject: [PATCH 4 of 5] LVM RAID: Add up-convert support for RAID1
In-Reply-To: <1313503895.11617.10.camel@f14.redhat.com>
References: <1313503895.11617.10.camel@f14.redhat.com>
Message-ID: <1313504364.11617.19.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the ability to upconvert a RAID1 array (m-way -> n-way)

This patch adds the ability to upconvert a raid1 array - say from 2-way to
3-way.  It does not yet support upconverting linear to n-way.

The 'raid' device-mapper target allows for individual components (images) of
an array to be specified for rebuild.  This mechanism is used when adding
new images to the array so that the new images can be resync'ed while the
rest of the images in the array can remain 'in-sync'.  (There is no
mirror-on-mirror layering required.)

Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -196,6 +196,81 @@ static int raid_remove_top_layer(struct 
 }
 
 /*
+ * clear_lv
+ * @lv
+ *
+ * If LV is active:
+ *        clear first block of device
+ * otherwise:
+ *        activate, clear, deactivate
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int clear_lv(struct logical_volume *lv)
+{
+	int was_active = lv_is_active(lv);
+
+	if (!was_active && !activate_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to activate %s for clearing",
+			  lv->name);
+		return 0;
+	}
+
+	log_verbose("Clearing metadata area of %s/%s",
+		    lv->vg->name, lv->name);
+	/*
+	 * Rather than wiping lv->size, we can simply
+	 * wipe '1' to remove the superblock of any previous
+	 * RAID devices.  It is much quicker.
+	 */
+	if (!set_lv(lv->vg->cmd, lv, 1, 0)) {
+		log_error("Failed to zero %s", lv->name);
+		return 0;
+	}
+
+	if (!was_active && !deactivate_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to deactivate %s", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/* Makes on-disk metadata changes */
+static int clear_lvs(struct dm_list *lv_list)
+{
+	struct lv_list *lvl;
+	struct volume_group *vg = NULL;
+
+	if (dm_list_empty(lv_list)) {
+		log_debug(INTERNAL_ERROR "Empty list of LVs given for clearing");
+		return 1;
+	}
+
+	dm_list_iterate_items(lvl, lv_list) {
+		if (!lv_is_visible(lvl->lv)) {
+			log_error(INTERNAL_ERROR
+				  "LVs must be set visible before clearing");
+			return 0;
+		}
+		vg = lvl->lv->vg;
+	}
+
+	/*
+	 * FIXME: only vg_[write|commit] if LVs are not already written
+	 * as visible in the LVM metadata (which is never the case yet).
+	 */
+	if (!vg || !vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	dm_list_iterate_items(lvl, lv_list)
+		if (!clear_lv(lvl->lv))
+			return 0;
+
+	return 1;
+}
+
+/*
  * _shift_and_rename_image_components
  * @seg: Top-level RAID segment
  *
@@ -278,14 +353,234 @@ static int _shift_and_rename_image_compo
 	return 1;
 }
 
+/*
+ * Create an LV of specified type.  Set visible after creation.
+ * This function does not make metadata changes.
+ */
+static int _alloc_image_component(struct logical_volume *lv,
+				  struct alloc_handle *ah, uint32_t first_area,
+				  uint32_t type, struct logical_volume **new_lv)
+{
+	uint64_t status;
+	size_t len = strlen(lv->name) + 32;
+	char img_name[len];
+	struct logical_volume *tmp_lv;
+	const struct segment_type *segtype;
+
+	if (type == RAID_META) {
+		if (dm_snprintf(img_name, len, "%s_rmeta_%%d", lv->name) < 0)
+			return_0;
+	} else if (type == RAID_IMAGE) {
+		if (dm_snprintf(img_name, len, "%s_rimage_%%d", lv->name) < 0)
+			return_0;
+	} else {
+		log_error(INTERNAL_ERROR
+			  "Bad type provided to _alloc_raid_component");
+		return 0;
+	}
+
+	if (!ah) {
+		first_area = 0;
+		log_error(INTERNAL_ERROR
+			  "Stand-alone %s area allocation not implemented",
+			  (type == RAID_META) ? "metadata" : "data");
+		return 0;
+	}
+
+	status = LVM_READ | LVM_WRITE | LV_NOTSYNCED | type;
+	tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg);
+	if (!tmp_lv) {
+		log_error("Failed to allocate new raid component, %s", img_name);
+		return 0;
+	}
+
+	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+	if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
+		log_error("Failed to add segment to LV, %s", img_name);
+		return 0;
+	}
+
+	lv_set_visible(tmp_lv);
+	*new_lv = tmp_lv;
+	return 1;
+}
+
+static int _alloc_image_components(struct logical_volume *lv,
+				   struct dm_list *pvs, uint32_t count,
+				   struct dm_list *new_meta_lvs,
+				   struct dm_list *new_data_lvs)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+	struct alloc_handle *ah;
+	struct dm_list *parallel_areas;
+	struct logical_volume *tmp_lv;
+	struct lv_list *lvl_array;
+
+	lvl_array = dm_pool_alloc(lv->vg->vgmem,
+				  sizeof(*lvl_array) * count * 2);
+	if (!lvl_array)
+		return_0;
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
+		return_0;
+
+	if (!(ah = allocate_extents(lv->vg, NULL, seg->segtype, 0, count, count,
+				    seg->region_size, lv->le_count, pvs,
+				    lv->alloc, parallel_areas)))
+		return_0;
+
+	for (s = 0; s < count; s++) {
+		/*
+		 * The allocation areas are grouped together.  First
+		 * come the rimage allocated areas, then come the metadata
+		 * allocated areas.  Thus, the metadata areas are pulled
+		 * from 's + count'.
+		 */
+		if (!_alloc_image_component(lv, ah, s + count,
+					    RAID_META, &tmp_lv))
+			return_0;
+		lvl_array[s + count].lv = tmp_lv;
+		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
+
+		if (!_alloc_image_component(lv, ah, s, RAID_IMAGE, &tmp_lv))
+			return_0;
+		lvl_array[s].lv = tmp_lv;
+		dm_list_add(new_data_lvs, &(lvl_array[s].list));
+	}
+	alloc_destroy(ah);
+	return 1;
+}
+
 static int raid_add_images(struct logical_volume *lv,
 			   uint32_t new_count, struct dm_list *pvs)
 {
-	/* Not implemented */
-	log_error("Unable to add images to LV, %s/%s",
-		  lv->vg->name, lv->name);
+	uint32_t s;
+	uint32_t old_count = lv_raid_image_count(lv);
+	uint32_t count = new_count - old_count;
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list meta_lvs, data_lvs;
+	struct lv_list *lvl;
+	struct lv_segment_area *new_areas;
+
+	dm_list_init(&meta_lvs); /* For image addition */
+	dm_list_init(&data_lvs); /* For image addition */
+
+	if (!seg_is_raid(seg)) {
+		log_error("Unable to add RAID images to %s of segment type %s",
+			  lv->name, seg->segtype->name);
+		return 0;
+	}
+
+	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs)) {
+		log_error("Failed to allocate new image components");
+		return 0;
+	}
+
+	/* Metadata LVs must be cleared before being added to the array */
+	if (!clear_lvs(&meta_lvs))
+		goto fail;
+
+/*
+FIXME: It would be proper to activate the new LVs here, instead of having
+them activated by the suspend.  However, this causes residual device nodes
+to be left for these sub-lvs.
+	dm_list_iterate_items(lvl, &meta_lvs)
+		if (!do_correct_activate(lv, lvl->lv))
+			return_0;
+	dm_list_iterate_items(lvl, &data_lvs)
+		if (!do_correct_activate(lv, lvl->lv))
+			return_0;
+*/
+	/* Expand areas array */
+	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
+					 new_count * sizeof(*new_areas))))
+		goto fail;
+	memcpy(new_areas, seg->areas, seg->area_count * sizeof(*seg->areas));
+	seg->areas = new_areas;
+	seg->area_count = new_count;
+
+	/* Expand meta_areas array */
+	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
+					 new_count * sizeof(*new_areas))))
+		goto fail;
+	memcpy(new_areas, seg->meta_areas,
+	       seg->area_count * sizeof(*seg->meta_areas));
+	seg->meta_areas = new_areas;
+
+	/* Set segment areas for metadata sub_lvs */
+	s = old_count;
+	dm_list_iterate_items(lvl, &meta_lvs) {
+		log_debug("Adding %s to %s",
+			  lvl->lv->name, lv->name);
+		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
+					    lvl->lv->status)) {
+			log_error("Failed to add %s to %s",
+				  lvl->lv->name, lv->name);
+			goto fail;
+		}
+		s++;
+	}
 
-	return 0;
+	/* Set segment areas for data sub_lvs */
+	s = old_count;
+	dm_list_iterate_items(lvl, &data_lvs) {
+		log_debug("Adding %s to %s",
+			  lvl->lv->name, lv->name);
+		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
+					    lvl->lv->status)) {
+			log_error("Failed to add %s to %s",
+				  lvl->lv->name, lv->name);
+			goto fail;
+		}
+		s++;
+	}
+
+	/*
+	 * FIXME: Failure handling during these points is harder.
+	 */
+	dm_list_iterate_items(lvl, &meta_lvs)
+		lv_set_hidden(lvl->lv);
+	dm_list_iterate_items(lvl, &data_lvs)
+		lv_set_hidden(lvl->lv);
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+
+fail:
+	/* Cleanly remove newly allocated LVs that failed insertion attempt */
+
+	dm_list_iterate_items(lvl, &meta_lvs)
+		if (!lv_remove(lvl->lv))
+			return_0;
+	dm_list_iterate_items(lvl, &data_lvs)
+		if (!lv_remove(lvl->lv))
+			return_0;
+	return_0;
 }
 
 /*
@@ -386,7 +681,7 @@ static int raid_extract_images(struct lo
 		    (extract > 1) ? "images" : "image",
 		    lv->vg->name, lv->name);
 
-	lvl_array = dm_pool_alloc(lv->vg->cmd->mem,
+	lvl_array = dm_pool_alloc(lv->vg->vgmem,
 				  sizeof(*lvl_array) * extract * 2);
 	if (!lvl_array)
 		return_0;
@@ -429,56 +724,21 @@ static int raid_extract_images(struct lo
 	return 1;
 }
 
-/*
- * lv_raid_change_image_count
- * @lv
- * @new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
- * @pvs: The list of PVs that are candidates for removal (or empty list)
- *
- * RAID arrays have 'images' which are composed of two parts, they are:
- *    - 'rimage': The data/parity holding portion
- *    - 'rmeta' : The metadata holding portion (i.e. superblock/bitmap area)
- * This function adds or removes _both_ portions of the image and commits
- * the results.
- *
- * Returns: 1 on success, 0 on failure
- */
-int lv_raid_change_image_count(struct logical_volume *lv,
-			       uint32_t new_count, struct dm_list *pvs)
+static int raid_remove_images(struct logical_volume *lv,
+			      uint32_t new_count, struct dm_list *pvs)
 {
-	uint32_t old_count = lv_raid_image_count(lv);
-	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_list;
 	struct lv_list *lvl;
 
 	dm_list_init(&removal_list);
 
-	if (!seg_is_mirrored(seg)) {
-		log_error("Unable to change image count of non-mirrored RAID.");
+	if (!raid_extract_images(lv, new_count, pvs, 1,
+				 &removal_list, &removal_list)) {
+		log_error("Failed to extract images from %s/%s",
+			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	if (old_count == new_count) {
-		log_verbose("%s/%s already has image count of %d",
-			    lv->vg->name, lv->name, new_count);
-		return 1;
-	}
-
-	if (old_count > new_count) {
-		if (!raid_extract_images(lv, new_count, pvs, 1,
-					 &removal_list, &removal_list)) {
-			log_error("Failed to extract images from %s/%s",
-				  lv->vg->name, lv->name);
-			return 0;
-		}
-	} else {
-		if (!raid_add_images(lv, new_count, pvs)) {
-			log_error("Failed to add images to %s/%s",
-				  lv->vg->name, lv->name);
-			return 0;
-		}
-	}
-
 	/* Convert to linear? */
 	if ((new_count == 1) && !raid_remove_top_layer(lv, &removal_list)) {
 		log_error("Failed to remove RAID layer after linear conversion");
@@ -532,6 +792,43 @@ int lv_raid_change_image_count(struct lo
 	return 1;
 }
 
+/*
+ * lv_raid_change_image_count
+ * @lv
+ * @new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
+ * @pvs: The list of PVs that are candidates for removal (or empty list)
+ *
+ * RAID arrays have 'images' which are composed of two parts, they are:
+ *    - 'rimage': The data/parity holding portion
+ *    - 'rmeta' : The metadata holding portion (i.e. superblock/bitmap area)
+ * This function adds or removes _both_ portions of the image and commits
+ * the results.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+int lv_raid_change_image_count(struct logical_volume *lv,
+			       uint32_t new_count, struct dm_list *pvs)
+{
+	uint32_t old_count = lv_raid_image_count(lv);
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_mirrored(seg)) {
+		log_error("Unable to change image count of non-mirrored RAID.");
+		return 0;
+	}
+
+	if (old_count == new_count) {
+		log_error("%s/%s already has image count of %d",
+			  lv->vg->name, lv->name, new_count);
+		return 1;
+	}
+
+	if (old_count > new_count)
+		return raid_remove_images(lv, new_count, pvs);
+
+	return raid_add_images(lv, new_count, pvs);
+}
+
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs)
 {
Index: LVM2/lib/raid/raid.c
===================================================================
--- LVM2.orig/lib/raid/raid.c
+++ LVM2/lib/raid/raid.c
@@ -161,20 +161,37 @@ _raid_add_target_line(struct dev_manager
 		      struct dm_tree_node *node, uint64_t len,
 		      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
+	uint32_t s;
+	uint64_t rebuilds = 0;
+
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
 			  "with no areas for %s.", seg->lv->name);
 		return 0;
 	}
 
+	/*
+	 * 64 device restriction imposed by kernel as well.  It is
+	 * not strictly a userspace limitation.
+	 */
+	if (seg->area_count > 64) {
+		log_error("Unable to handle more than 64 devices in a "
+			  "single RAID array");
+		return 0;
+	}
+
 	if (!seg->region_size) {
 		log_error("Missing region size for mirror segment.");
 		return 0;
 	}
 
+	for (s = 0; s < seg->area_count; s++)
+		if (seg_lv(seg, s)->status & LV_NOTSYNCED)
+			rebuilds |= 1 << s;
+
 	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
 					  seg->region_size, seg->stripe_size,
-					  0, 0))
+					  rebuilds, 0))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c
+++ LVM2/libdm/libdm-deptree.c
@@ -149,6 +149,8 @@ struct load_segment {
 	unsigned rdevice_count;		/* Replicator */
 	struct dm_tree_node *replicator;/* Replicator-dev */
 	uint64_t rdevice_index;		/* Replicator-dev */
+
+	uint64_t rebuilds;              /* raid */
 };
 
 /* Per-device properties */
@@ -1724,6 +1726,7 @@ static int _raid_emit_segment_line(struc
 				   uint64_t *seg_start, char *params,
 				   size_t paramsize)
 {
+	uint32_t i, *tmp;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
 
@@ -1733,6 +1736,10 @@ static int _raid_emit_segment_line(struc
 	if (seg->region_size)
 		param_count += 2;
 
+	tmp = (uint32_t *)(&seg->rebuilds); /* rebuilds is 64-bit */
+	param_count += 2 * hweight32(tmp[0]);
+	param_count += 2 * hweight32(tmp[1]);
+
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
@@ -1747,6 +1754,10 @@ static int _raid_emit_segment_line(struc
 	if (seg->region_size)
 		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
 
+	for (i = 0; i < (seg->area_count / 2); i++)
+		if (seg->rebuilds & (1 << i))
+			EMIT_PARAMS(pos, " rebuild %u", i);
+
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", seg->area_count/2);
 
@@ -1862,7 +1873,8 @@ static int _emit_segment_line(struct dm_
 
 	log_debug("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
 		  " %" PRIu64 " %s %s", major, minor,
-		  *seg_start, seg->size, dm_segtypes[seg->type].target, params);
+		  *seg_start, seg->size, target_type_is_raid ? "raid" :
+		  dm_segtypes[seg->type].target, params);
 
 	if (!dm_task_add_target(dmt, *seg_start, seg->size,
 				target_type_is_raid ? "raid" :
@@ -2354,7 +2366,7 @@ int dm_tree_node_add_raid_target(struct 
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t reserved1,
+				 uint64_t rebuilds,
 				 uint64_t reserved2)
 {
 	int i;
@@ -2372,6 +2384,7 @@ int dm_tree_node_add_raid_target(struct 
 	seg->region_size = region_size;
 	seg->stripe_size = stripe_size;
 	seg->area_count = 0;
+	seg->rebuilds = rebuilds;
 
 	return 1;
 }
Index: LVM2/libdm/libdevmapper.h
===================================================================
--- LVM2.orig/libdm/libdevmapper.h
+++ LVM2/libdm/libdevmapper.h
@@ -472,7 +472,7 @@ int dm_tree_node_add_raid_target(struct 
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t reserved1,
+				 uint64_t rebuilds,
 				 uint64_t reserved2);
 
 /*
Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -1027,7 +1027,8 @@ static int _alloc_parallel_area(struct a
 			log_debug("Allocating parallel metadata area %" PRIu32
 				  " on %s start PE %" PRIu32
 				  " length %" PRIu32 ".",
-				  s, pv_dev_name(aa[s].pv), aa[s].pe,
+				  (s - (ah->area_count + ah->parity_count)),
+				  pv_dev_name(aa[s].pv), aa[s].pe,
 				  ah->log_len);
 
 			consume_pv_area(pva, ah->log_len);
@@ -1536,6 +1537,35 @@ static void _clear_areas(struct alloc_st
 		alloc_state->areas[s].pva = NULL;
 }
 
+static void _report_needed_allocation_space(struct alloc_handle *ah,
+					    struct alloc_state *alloc_state)
+{
+	const char *metadata_type;
+	uint32_t p_areas_count, p_area_size;
+	uint32_t metadata_count, metadata_size;
+
+	p_area_size = (ah->new_extents - alloc_state->allocated);
+	p_area_size /= ah->area_multiple;
+	p_area_size -= (ah->alloc_and_split_meta) ? ah->log_len : 0;
+	p_areas_count = ah->area_count + ah->parity_count;
+
+	metadata_size = ah->log_len;
+	if (ah->alloc_and_split_meta) {
+		metadata_type = "RAID metadata area";
+		metadata_count = p_areas_count;
+	} else {
+		metadata_type = "mirror log";
+		metadata_count = alloc_state->log_area_count_still_needed;
+	}
+
+	log_debug("Still need %" PRIu32 " total extents:",
+		p_area_size * p_areas_count + metadata_size * metadata_count);
+	log_debug("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
+		  " parity) parallel areas of %" PRIu32 " extents each",
+		  p_areas_count, ah->area_count, ah->parity_count, p_area_size);
+	log_debug("  %" PRIu32 " %ss of %" PRIu32 " extents each",
+		  metadata_count, metadata_type, metadata_size);
+}
 /*
  * Returns 1 regardless of whether any space was found, except on error.
  */
@@ -1571,13 +1601,7 @@ static int _find_some_parallel_space(str
 
 	_clear_areas(alloc_state);
 
-	log_debug("Still need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
-		  "(Total %" PRIu32 " extents.)",
-		  (ah->new_extents - alloc_state->allocated) / ah->area_multiple,
-		  devices_needed, alloc_state->log_area_count_still_needed,
-		  alloc_state->log_area_count_still_needed ? ah->log_len : 0,
-		  (ah->new_extents - alloc_state->allocated) * devices_needed / ah->area_multiple +
-			alloc_state->log_area_count_still_needed * ah->log_len);
+	_report_needed_allocation_space(ah, alloc_state);
 
 	/* ix holds the number of areas found on other PVs */
 	do {
@@ -1769,6 +1793,7 @@ static int _find_some_parallel_space(str
 static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, struct alloc_parms *alloc_parms,
 						   struct dm_list *pvms, struct alloc_state *alloc_state)
 {
+	uint32_t max_tmp;
 	uint32_t max_to_allocate;	/* Maximum extents to allocate this time */
 	uint32_t old_allocated;
 	uint32_t next_le;
@@ -1791,8 +1816,20 @@ static int _find_max_parallel_space_for_
 				if (next_le >= spvs->le + spvs->len)
 					continue;
 
-				if (max_to_allocate + alloc_state->allocated > (spvs->le + spvs->len) * ah->area_multiple)
+				max_tmp = max_to_allocate +
+					alloc_state->allocated;
+
+				/*
+				 * Because a request that groups metadata and
+				 * data together will be split, we must adjust
+				 * the comparison accordingly.
+				 */
+				if (ah->alloc_and_split_meta)
+					max_tmp -= ah->log_len;
+				if (max_tmp > (spvs->le + spvs->len) * ah->area_multiple) {
 					max_to_allocate = (spvs->le + spvs->len) * ah->area_multiple - alloc_state->allocated;
+					max_to_allocate += ah->alloc_and_split_meta ? ah->log_len : 0;
+				}
 				parallel_pvs = &spvs->pvs;
 				break;
 			}



