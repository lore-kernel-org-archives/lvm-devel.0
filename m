From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Dec 2016 14:15:17 +0000 (UTC)
Subject: master - cleanup: messages in raid
Message-ID: <20161209141517.9DE49602B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15e4ab3e9375b561880fa83f0a5a3c438e192bcc
Commit:        15e4ab3e9375b561880fa83f0a5a3c438e192bcc
Parent:        6dd0bd0255d585feca61000432d2de9552ede4e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 14:27:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 9 15:15:02 2016 +0100

cleanup: messages in raid

Use display_lvname and add 'dots'.
Add some missing WARNING and log_debug_metadata.
---
 lib/metadata/raid_manip.c |  398 ++++++++++++++++++++++++---------------------
 1 files changed, 215 insertions(+), 183 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 7e591e9..7c4ce61 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -64,7 +64,8 @@ static void _ensure_min_region_size(const struct logical_volume *lv)
 		region_size *= 2;
 
 	if (seg->region_size != region_size) {
-		log_very_verbose("Setting region_size to %u for %s", seg->region_size, display_lvname(lv));
+		log_very_verbose("Setting region_size to %u for %s.",
+				 seg->region_size, display_lvname(lv));
 		seg->region_size = region_size;
 	}
 }
@@ -77,7 +78,7 @@ static void _ensure_min_region_size(const struct logical_volume *lv)
 static int _check_max_raid_devices(uint32_t image_count)
 {
 	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
-		log_error("Unable to handle raid arrays with more than %u devices",
+		log_error("Unable to handle raid arrays with more than %u devices.",
 			  DEFAULT_RAID_MAX_IMAGES);
 		return 0;
 	}
@@ -88,7 +89,7 @@ static int _check_max_raid_devices(uint32_t image_count)
 static int _check_max_mirror_devices(uint32_t image_count)
 {
 	if (image_count > DEFAULT_MIRROR_MAX_IMAGES) {
-		log_error("Unable to handle mirrors with more than %u devices",
+		log_error("Unable to handle mirrors with more than %u devices.",
 			  DEFAULT_MIRROR_MAX_IMAGES);
 		return 0;
 	}
@@ -335,15 +336,15 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 
 	if (!seg_is_mirrored(seg)) {
 		log_error(INTERNAL_ERROR
-			  "Unable to remove RAID layer from segment type %s",
+			  "Unable to remove RAID layer from segment type %s.",
 			  lvseg_name(seg));
 		return 0;
 	}
 
 	if (seg->area_count != 1) {
 		log_error(INTERNAL_ERROR
-			  "Unable to remove RAID layer when there"
-			  " is more than one sub-lv");
+			  "Unable to remove RAID layer when there is "
+			  "more than one sub-lv.");
 		return 0;
 	}
 
@@ -392,26 +393,28 @@ static int _clear_lv(struct logical_volume *lv)
 
 	lv->status |= LV_TEMPORARY;
 	if (!was_active && !activate_lv_local(lv->vg->cmd, lv)) {
-		log_error("Failed to activate localy %s for clearing",
-			  lv->name);
+		log_error("Failed to activate localy %s for clearing.",
+			  display_lvname(lv));
 		return 0;
 	}
 	lv->status &= ~LV_TEMPORARY;
 
-	log_verbose("Clearing metadata area of %s/%s",
-		    lv->vg->name, lv->name);
+	log_verbose("Clearing metadata area of %s",
+		    display_lvname(lv));
 	/*
 	 * Rather than wiping lv->size, we can simply
 	 * wipe the first sector to remove the superblock of any previous
 	 * RAID devices.  It is much quicker.
 	 */
 	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
-		log_error("Failed to zero %s", lv->name);
+		log_error("Failed to zero %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!was_active && !deactivate_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to deactivate %s", lv->name);
+		log_error("Failed to deactivate %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -425,14 +428,14 @@ static int _clear_lvs(struct dm_list *lv_list)
 	struct volume_group *vg = NULL;
 
 	if (dm_list_empty(lv_list)) {
-		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing");
+		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing.");
 		return 1;
 	}
 
 	dm_list_iterate_items(lvl, lv_list) {
 		if (!lv_is_visible(lvl->lv)) {
 			log_error(INTERNAL_ERROR
-				  "LVs must be set visible before clearing");
+				  "LVs must be set visible before clearing.");
 			return 0;
 		}
 		vg = lvl->lv->vg;
@@ -484,17 +487,17 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 		 * FIXME: Handling more would mean I'd have
 		 * to handle double digits
 		 */
-		log_error("Unable handle arrays with more than 10 devices");
+		log_error("Unable handle arrays with more than 10 devices.");
 		return 0;
 	}
 
-	log_very_verbose("Shifting images in %s", seg->lv->name);
+	log_very_verbose("Shifting images in %s.", display_lvname(seg->lv));
 
 	for (s = 0, missing = 0; s < seg->area_count; s++) {
 		if (seg_type(seg, s) == AREA_UNASSIGNED) {
 			if (seg_metatype(seg, s) != AREA_UNASSIGNED) {
 				log_error(INTERNAL_ERROR "Metadata segment area"
-					  " #%d should be AREA_UNASSIGNED", s);
+					  " #%d should be AREA_UNASSIGNED.", s);
 				return 0;
 			}
 			missing++;
@@ -503,9 +506,9 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 		if (!missing)
 			continue;
 
-		log_very_verbose("Shifting %s and %s by %u",
-				 seg_metalv(seg, s)->name,
-				 seg_lv(seg, s)->name, missing);
+		log_very_verbose("Shifting %s and %s by %u.",
+				 display_lvname(seg_metalv(seg, s)),
+				 display_lvname(seg_lv(seg, s)), missing);
 
 		/* Alter rmeta name */
 		shift_name = dm_pool_strdup(cmd->mem, seg_metalv(seg, s)->name);
@@ -595,7 +598,7 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 
 	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
 			(alt_base_name) ? : lv->name, type_suffix) < 0) {
-		log_error("Component name for raid %s is too long.", lv->name);
+		log_error("Component name for raid %s is too long.", display_lvname(lv));
 		return 0;
 	}
 
@@ -610,7 +613,7 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 			return_0;
 
 		if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
-			log_error("Failed to add segment to LV, %s", img_name);
+			log_error("Failed to add segment to LV, %s.", img_name);
 			return 0;
 		}
 	}
@@ -738,15 +741,15 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		allocate_pvs = &allocatable_pvs;
 		if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
 					data_lv, &allocatable_pvs)) {
-			log_error("Failed to build list of PVs for %s/%s",
-				  data_lv->vg->name, data_lv->name);
+			log_error("Failed to build list of PVs for %s.",
+				  display_lvname(data_lv));
 			return 0;
 		}
 	}
 
 	if (!seg_is_linear(seg)) {
 		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
-			  "area for non-linear LV, %s", data_lv->name);
+			  "area for non-linear LV %s.", display_lvname(data_lv));
 		return 0;
 	}
 
@@ -789,13 +792,15 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 	}
 
 	if (!_raid_in_sync(lv)) {
-		log_error("Can't add image to RAID LV that"
-			  " is still initializing.");
+		log_error("Can't add image to RAID LV that is still initializing.");
 		return 0;
 	}
 
-	if (lv_is_active(lv_lock_holder(lv)) && (old_count == 1) && (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))) {
-		log_error("Can't add image to active thin pool LV %s yet. Deactivate first.", display_lvname(lv));
+	if (lv_is_active(lv_lock_holder(lv)) &&
+	    (old_count == 1) &&
+	    (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))) {
+		log_error("Can't add image to active thin pool LV %s yet. Deactivate first.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -814,7 +819,7 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		status_mask = ~(LV_REBUILD);
 
 		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
-			log_error("Memory allocation failed");
+			log_error("Memory allocation failed.");
 			return 0;
 		}
 
@@ -823,8 +828,8 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 
 		dm_list_add(&meta_lvs, &lvl->list);
 	} else if (!seg_is_raid(seg)) {
-		log_error("Unable to add RAID images to %s of segment type %s",
-			  lv->name, lvseg_name(seg));
+		log_error("Unable to add RAID images to %s of segment type %s.",
+			  display_lvname(lv), lvseg_name(seg));
 		return 0;
 	}
 
@@ -873,7 +878,7 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		/* MD's bitmap is limited to tracking 2^21 regions */
 		while (seg->region_size < (lv->size / (1 << 21))) {
 			seg->region_size *= 2;
-			log_very_verbose("Setting RAID1 region_size to %uS",
+			log_very_verbose("Setting RAID1 region_size to %uS.",
 					 seg->region_size);
 		}
 		if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
@@ -916,14 +921,16 @@ to be left for these sub-lvs.
 
 	/* Set segment areas for metadata sub_lvs */
 	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug_metadata("Adding %s to %s",
-				   lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s.",
+				   display_lvname(lvl->lv),
+				   display_lvname(lv));
 		lvl->lv->status &= status_mask;
 		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
-			log_error("Failed to add %s to %s",
-				  lvl->lv->name, lv->name);
+			log_error("Failed to add %s to %s.",
+				  display_lvname(lvl->lv),
+				  display_lvname(lv));
 			goto fail;
 		}
 		s++;
@@ -933,14 +940,16 @@ to be left for these sub-lvs.
 
 	/* Set segment areas for data sub_lvs */
 	dm_list_iterate_items(lvl, &data_lvs) {
-		log_debug_metadata("Adding %s to %s",
-				   lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s.",
+				   display_lvname(lvl->lv),
+				   display_lvname(lv));
 		lvl->lv->status &= status_mask;
 		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
-			log_error("Failed to add %s to %s",
-				  lvl->lv->name, lv->name);
+			log_error("Failed to add %s to %s.",
+				  display_lvname(lvl->lv),
+				  display_lvname(lv));
 			goto fail;
 		}
 		s++;
@@ -1002,8 +1011,8 @@ static int _raid_add_images(struct logical_volume *lv,
 	}
 	if (rebuild_flag_cleared) {
 		if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-			log_error("Failed to clear REBUILD flag for %s/%s components",
-				  lv->vg->name, lv->name);
+			log_error("Failed to clear REBUILD flag for %s components.",
+				  display_lvname(lv));
 			return 0;
 		}
 		backup(lv->vg);
@@ -1099,9 +1108,9 @@ static int _raid_extract_images(struct logical_volume *lv,
 	struct segment_type *error_segtype;
 
 	extract = seg->area_count - new_count;
-	log_verbose("Extracting %u %s from %s/%s", extract,
+	log_verbose("Extracting %u %s from %s.", extract,
 		    (extract > 1) ? "images" : "image",
-		    lv->vg->name, lv->name);
+		    display_lvname(lv));
 	if ((int) dm_list_size(target_pvs) < extract) {
 		log_error("Unable to remove %d images:  Only %d device%s given.",
 			  extract, dm_list_size(target_pvs),
@@ -1146,7 +1155,7 @@ static int _raid_extract_images(struct logical_volume *lv,
 					  " the command.");
 				return 0;
 			}
-			log_debug("LVs with error segments to be removed: %s %s",
+			log_debug("LVs with error segments to be removed: %s %s.",
 				  display_lvname(seg_metalv(seg, s)),
 				  display_lvname(seg_lv(seg, s)));
 		} else {
@@ -1162,7 +1171,7 @@ static int _raid_extract_images(struct logical_volume *lv,
 			if (!_raid_devs_sync_healthy(lv) &&
 			    (!seg_is_mirrored(seg) || (s == 0 && !force))) {
 				log_error("Unable to extract %sRAID image"
-					  " while RAID array is not in-sync%s",
+					  " while RAID array is not in-sync%s.",
 					  seg_is_mirrored(seg) ? "primary " : "",
 					  seg_is_mirrored(seg) ? " (use --force option to replace)" : "");
 				return 0;
@@ -1175,7 +1184,7 @@ static int _raid_extract_images(struct logical_volume *lv,
 		}
 
 		if (shift && !_shift_and_rename_image_components(seg)) {
-			log_error("Failed to shift and rename image components");
+			log_error("Failed to shift and rename image components.");
 			return 0;
 		}
 
@@ -1187,7 +1196,7 @@ static int _raid_extract_images(struct logical_volume *lv,
 		extract--;
 	}
 	if (extract) {
-		log_error("Unable to extract enough images to satisfy request");
+		log_error("Unable to extract enough images to satisfy request.");
 		return 0;
 	}
 
@@ -1211,16 +1220,16 @@ static int _raid_remove_images(struct logical_volume *lv,
 
 	if (!_raid_extract_images(lv, 0, new_count, allocate_pvs, 1,
 				 removal_lvs, removal_lvs)) {
-		log_error("Failed to extract images from %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Failed to extract images from %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Convert to linear? */
 	if (new_count == 1) {
 		if (!_raid_remove_top_layer(lv, removal_lvs)) {
-			log_error("Failed to remove RAID layer"
-				  " after linear conversion");
+			log_error("Failed to remove RAID layer "
+				  "after linear conversion.");
 			return 0;
 		}
 		lv->status &= ~(LV_NOTSYNCED | LV_WRITEMOSTLY);
@@ -1231,21 +1240,21 @@ static int _raid_remove_images(struct logical_volume *lv,
 		return 1;
 
 	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
+		log_error("Failed to write changes for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!suspend_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
+		log_error("Failed to suspend %s before committing changes.",
+			  display_lvname(lv));
 		vg_revert(lv->vg);
 		return 0;
 	}
 
 	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
+		log_error("Failed to commit changes for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1256,14 +1265,14 @@ static int _raid_remove_images(struct logical_volume *lv,
 	 */
 	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
-			log_error("Failed to resume extracted LVs");
+			log_error("Failed to resume extracted LVs.");
 			return 0;
 		}
 	}
 
 	if (!resume_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
+		log_error("Failed to resume %s after committing changes.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1307,8 +1316,8 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 	uint32_t old_count = lv_raid_image_count(lv);
 
 	if (old_count == new_count) {
-		log_warn("%s/%s already has image count of %d.",
-			 lv->vg->name, lv->name, new_count);
+		log_warn("WARGNING: %s already has image count of %d.",
+			 display_lvname(lv), new_count);
 		return 1;
 	}
 
@@ -1317,8 +1326,8 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 	 */
 	if (lv_is_active(lv_lock_holder(lv)) && vg_is_clustered(lv->vg) &&
 	    !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		log_error("%s/%s must be active exclusive locally to"
-			  " perform this operation.", lv->vg->name, lv->name);
+		log_error("%s must be active exclusive locally to "
+			  "perform this operation.", display_lvname(lv));
 		return 0;
 	}
 
@@ -1349,33 +1358,33 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	dm_list_init(&data_list);
 
 	if (is_lockd_type(lv->vg->lock_type)) {
-		log_error("Splitting raid image is not allowed with lock_type %s",
+		log_error("Splitting raid image is not allowed with lock_type %s.",
 			  lv->vg->lock_type);
 		return 0;
 	}
 
 	if ((old_count - new_count) != 1) {
-		log_error("Unable to split more than one image from %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Unable to split more than one image from %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!seg_is_mirrored(first_seg(lv)) ||
 	    seg_is_raid10(first_seg(lv))) {
-		log_error("Unable to split logical volume of segment type, %s",
+		log_error("Unable to split logical volume of segment type, %s.",
 			  lvseg_name(first_seg(lv)));
 		return 0;
 	}
 
 	if (lv_name_is_used_in_vg(lv->vg, split_name, &historical)) {
-		log_error("%sLogical Volume \"%s\" already exists in %s",
+		log_error("%sLogical Volume \"%s\" already exists in %s.",
 			  historical ? "historical " : "", split_name, lv->vg->name);
 		return 0;
 	}
 
 	if (!_raid_in_sync(lv)) {
-		log_error("Unable to split %s/%s while it is not in-sync.",
-			  lv->vg->name, lv->name);
+		log_error("Unable to split %s while it is not in-sync.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1386,8 +1395,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (_lv_is_raid_with_tracking(lv, &tracking)) {
 		if (!lv_is_on_pvs(tracking, splittable_pvs)) {
 			log_error("Unable to split additional image from %s "
-				  "while tracking changes for %s",
-				  lv->name, tracking->name);
+				  "while tracking changes for %s.",
+				  display_lvname(lv), tracking->name);
 			return 0;
 		}
 
@@ -1401,14 +1410,14 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 
 	if (!_raid_extract_images(lv, 0, new_count, splittable_pvs, 1,
 				 &removal_lvs, &data_list)) {
-		log_error("Failed to extract images from %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Failed to extract images from %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Convert to linear? */
 	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_lvs)) {
-		log_error("Failed to remove RAID layer after linear conversion");
+		log_error("Failed to remove RAID layer after linear conversion.");
 		return 0;
 	}
 
@@ -1419,21 +1428,21 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	lvl->lv->name = split_name;
 
 	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
+		log_error("Failed to write changes for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!suspend_lv(cmd, lv_lock_holder(lv))) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
+		log_error("Failed to suspend %s before committing changes.",
+			  display_lvname(lv_lock_holder(lv)));
 		vg_revert(lv->vg);
 		return 0;
 	}
 
 	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
+		log_error("Failed to commit changes for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1451,8 +1460,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 			return_0;
 
 	if (!resume_lv(cmd, lv_lock_holder(lv))) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
+		log_error("Failed to resume %s after committing changes.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1502,19 +1511,19 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 
 	if (!seg_is_mirrored(seg)) {
-		log_error("Unable to split images from non-mirrored RAID");
+		log_error("Unable to split images from non-mirrored RAID.");
 		return 0;
 	}
 
 	if (!_raid_in_sync(lv)) {
-		log_error("Unable to split image from %s/%s while not in-sync",
-			  lv->vg->name, lv->name);
+		log_error("Unable to split image from %s while not in-sync.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Cannot track two split images at once */
 	if (lv_is_raid_with_tracking(lv)) {
-		log_error("Cannot track more than one split image at a time");
+		log_error("Cannot track more than one split image at a time.");
 		return 0;
 	}
 
@@ -1535,14 +1544,16 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return_0;
 
 	log_print_unless_silent("%s split from %s for read-only purposes.",
-				seg_lv(seg, s)->name, lv->name);
+				display_lvname(seg_lv(seg, s)),
+				display_lvname(lv));
 
 	/* Activate the split (and tracking) LV */
 	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
 		return_0;
 
-	log_print_unless_silent("Use 'lvconvert --merge %s/%s' to merge back into %s",
-				lv->vg->name, seg_lv(seg, s)->name, lv->name);
+	log_print_unless_silent("Use 'lvconvert --merge %s' to merge back into %s.",
+				display_lvname(seg_lv(seg, s)),
+				display_lvname(lv));
 	return 1;
 }
 
@@ -1609,8 +1620,9 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	if (!lv_update_and_reload(lv))
 		return_0;
 
-	log_print_unless_silent("%s/%s successfully merged back into %s/%s",
-				vg->name, image_lv->name, vg->name, lv->name);
+	log_print_unless_silent("%s successfully merged back into %s.",
+				display_lvname(image_lv),
+				display_lvname(lv));
 	return 1;
 }
 
@@ -1632,7 +1644,8 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 		return_0;
 
 	dm_list_iterate_items(lvl, new_data_lvs) {
-		log_debug_metadata("Allocating new metadata LV for %s", lvl->lv->name);
+		log_debug_metadata("Allocating new metadata LV for %s.",
+				   display_lvname(lvl->lv));
 
 		/*
 		 * Try to collocate with DataLV first and
@@ -1645,8 +1658,8 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 					return_0;
 
 			if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
-				log_error("Failed to allocate metadata LV for %s in %s",
-					  lvl->lv->name, lv->vg->name);
+				log_error("Failed to allocate metadata LV for %s.",
+					  display_lvname(lvl->lv));
 				return 0;
 			}
 		}
@@ -1685,7 +1698,8 @@ static int _add_image_component_list(struct lv_segment *seg, int delete_from_lis
 			lvl->lv->status &= ~LV_REBUILD;
 
 		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0 /* le */, lvl->lv->status)) {
-			log_error("Failed to add sublv %s", lvl->lv->name);
+			log_error("Failed to add sublv %s.",
+				  display_lvname(lvl->lv));
 			return 0;
 		}
 	}
@@ -1756,7 +1770,8 @@ static int _extract_image_component_error_seg(struct lv_segment *seg,
 			return 0;
 	}
 
-	log_very_verbose("Extracting image component %s from %s", lv->name, lvseg_name(seg));
+	log_very_verbose("Extracting image component %s from %s.",
+			 display_lvname(lv), lvseg_name(seg));
 	lv->status &= ~(type | RAID);
 	lv_set_visible(lv);
 
@@ -1843,7 +1858,8 @@ static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
 	}
 
 	if (!_alloc_rmeta_devs_for_rimage_devs(lv, &data_lvs, meta_lvs, allocate_pvs)) {
-		log_error("Failed to allocate metadata LVs for %s", lv->name);
+		log_error("Failed to allocate metadata LVs for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1861,24 +1877,30 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 
 	dm_list_init(&meta_lvs);
 
-	log_debug_metadata("Allocating metadata LVs for %s.", display_lvname(lv));
+	log_debug_metadata("Allocating metadata LVs for %s.",
+			   display_lvname(lv));
 	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs, &seg_meta_areas)) {
-		log_error("Failed to allocate metadata LVs for %s.", display_lvname(lv));
+		log_error("Failed to allocate metadata LVs for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Metadata LVs must be cleared before being added to the array */
-	log_debug_metadata("Clearing newly allocated metadata LVs for %s.", display_lvname(lv));
+	log_debug_metadata("Clearing newly allocated metadata LVs for %s.",
+			   display_lvname(lv));
 	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs for %s.", display_lvname(lv));
+		log_error("Failed to initialize metadata LVs for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Set segment areas for metadata sub_lvs */
 	seg->meta_areas = seg_meta_areas;
-	log_debug_metadata("Adding newly allocated metadata LVs to %s.", display_lvname(lv));
+	log_debug_metadata("Adding newly allocated metadata LVs to %s.",
+			   display_lvname(lv));
 	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
-		log_error("Failed to add newly allocated metadata LVs to %s.", display_lvname(lv));
+		log_error("Failed to add newly allocated metadata LVs to %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2014,12 +2036,15 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	 * and if successful, performs metadata backup.
 	 */
 	/* FIXME This needs to be done through hooks in the metadata */
-	log_debug_metadata("Clearing any flags for %s passed to the kernel", display_lvname(lv));
+	log_debug_metadata("Clearing any flags for %s passed to the kernel.",
+			   display_lvname(lv));
 	_clear_rebuild_flags(lv, &flags_were_cleared);
 
-	log_debug_metadata("Updating metadata and reloading mappings for %s", display_lvname(lv));
+	log_debug_metadata("Updating metadata and reloading mappings for %s.",
+			   display_lvname(lv));
 	if ((r != 2 || flags_were_cleared) && !lv_update_and_reload(lv)) {
-		log_error("Update and reload of LV %s failed", display_lvname(lv));
+		log_error("Update and reload of LV %s failed.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2056,7 +2081,7 @@ static int _adjust_data_lvs(struct logical_volume *lv, enum mirror_raid_conv dir
 		}
 
 		*(sublv_name_suffix + 1) = conv[direction].type_char;
-		log_debug_metadata("data LV renamed to %s", dlv->name);
+		log_debug_metadata("data LV renamed to %s.", display_lvname(dlv));
 
 		dlv->status &= ~conv[direction].reset_flag;
 		dlv->status |= conv[direction].set_flag;
@@ -2082,8 +2107,8 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	dm_list_init(&meta_lvs);
 
 	if (!_raid_in_sync(lv)) {
-		log_error("Unable to convert %s/%s while it is not in-sync",
-			  lv->vg->name, lv->name);
+		log_error("Unable to convert %s while it is not in-sync.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2097,26 +2122,28 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		return_0;
 
 	for (s = 0; s < seg->area_count; s++) {
-		log_debug_metadata("Allocating new metadata LV for %s",
-				   seg_lv(seg, s)->name);
+		log_debug_metadata("Allocating new metadata LV for %s.",
+				   display_lvname(seg_lv(seg, s)));
 		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv), NULL)) {
-			log_error("Failed to allocate metadata LV for %s in %s",
-				  seg_lv(seg, s)->name, lv->name);
+			log_error("Failed to allocate metadata LV for %s in %s.",
+				  display_lvname(seg_lv(seg, s)),
+				  display_lvname(lv));
 			return 0;
 		}
 		dm_list_add(&meta_lvs, &(lvl_array[s].list));
 	}
 
-	log_debug_metadata("Clearing newly allocated metadata LVs");
+	log_debug_metadata("Clearing newly allocated metadata LVs.");
 	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs");
+		log_error("Failed to initialize metadata LVs.");
 		return 0;
 	}
 
 	if (seg->log_lv) {
-		log_debug_metadata("Removing mirror log, %s", seg->log_lv->name);
+		log_debug_metadata("Removing mirror log %s.",
+				   display_lvname(seg->log_lv));
 		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
-			log_error("Failed to remove mirror log");
+			log_error("Failed to remove mirror log.");
 			return 0;
 		}
 	}
@@ -2125,7 +2152,9 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	s = 0;
 
 	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug_metadata("Adding %s to %s", lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s.",
+				   display_lvname(lvl->lv),
+				   display_lvname(lv));
 
 		/* Images are known to be in-sync */
 		lvl->lv->status &= ~LV_REBUILD;
@@ -2134,8 +2163,9 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
-			log_error("Failed to add %s to %s",
-				  lvl->lv->name, lv->name);
+			log_error("Failed to add %s to %s.",
+				  display_lvname(lvl->lv),
+				  display_lvname(lv));
 			return 0;
 		}
 		s++;
@@ -2144,14 +2174,14 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	for (s = 0; s < seg->area_count; ++s) {
 		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
 			return_0;
-		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
+		log_debug_metadata("Renaming %s to %s.", seg_lv(seg, s)->name, new_name);
 		seg_lv(seg, s)->name = new_name;
 		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
 		seg_lv(seg, s)->status |= RAID_IMAGE;
 	}
 	init_mirror_in_sync(1);
 
-	log_debug_metadata("Setting new segtype for %s", lv->name);
+	log_debug_metadata("Setting new segtype for %s.", display_lvname(lv));
 	seg->segtype = new_segtype;
 	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
@@ -2180,19 +2210,19 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 
 	if (!seg_is_raid1(seg)) {
-		log_error(INTERNAL_ERROR "raid1 conversion supported only");
+		log_error(INTERNAL_ERROR "raid1 conversion supported only.");
 		return 0;
 	}
 
 	if ((new_image_count = new_image_count ?: seg->area_count) < 2) {
-		log_error("can't convert %s to fewer than 2 data_copies", display_lvname(lv));
+		log_error("can't convert %s to fewer than 2 data_copies.", display_lvname(lv));
 		return 0;
 	}
 
 	if (!_check_max_mirror_devices(new_image_count)) {
-		log_error("Unable to convert %s LV %s with %u images to %s",
+		log_error("Unable to convert %s LV %s with %u images to %s.",
 			  SEG_TYPE_NAME_RAID1, display_lvname(lv), new_image_count, SEG_TYPE_NAME_MIRROR);
-		log_error("At least reduce to the maximum of %u images with \"lvconvert -m%u %s\"",
+		log_error("At least reduce to the maximum of %u images with \"lvconvert -m%u %s\".",
 			  DEFAULT_MIRROR_MAX_IMAGES, DEFAULT_MIRROR_MAX_IMAGES - 1, display_lvname(lv));
 		return 0;
 	}
@@ -2201,21 +2231,21 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 
 	/* Change image pair count to requested # of images */
 	if (new_image_count != seg->area_count) {
-		log_debug_metadata("Changing image count to %u on %s",
+		log_debug_metadata("Changing image count to %u on %s.",
 				   new_image_count, display_lvname(lv));
 		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
 			return 0;
 	}
 
 	/* Remove rmeta LVs */
-	log_debug_metadata("Extracting and renaming metadata LVs");
+	log_debug_metadata("Extracting and renaming metadata LVs.");
 	if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs))
 		return 0;
 
 	seg->meta_areas = NULL;
 
 	/* Rename all data sub LVs from "*_rimage_*" to "*_mimage_*" and set their status */
-	log_debug_metadata("Adjust data LVs of %s", display_lvname(lv));
+	log_debug_metadata("Adjust data LVs of %s.", display_lvname(lv));
 	if (!_adjust_data_lvs(lv, RAID1_TO_MIRROR))
 		return 0;
 
@@ -2227,7 +2257,7 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 
 	/* Add mirror_log LV (should happen in wih image allocation */
 	if (!add_mirror_log(lv->vg->cmd, lv, 1, seg->region_size, allocate_pvs, lv->vg->alloc)) {
-		log_error("Unable to add mirror log to %s", display_lvname(lv));
+		log_error("Unable to add mirror log to %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -2299,8 +2329,8 @@ static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
 	/* Find smallest segment of each of the data image LVs at offset area_le */
 	for (s = 0; s < seg->area_count; s++) {
 		if (!(seg1 = find_seg_by_le(seg_lv(seg, s), area_le))) {
-			log_error("Failed to find segment for %s extent %" PRIu32,
-				  seg_lv(seg, s)->name, area_le);
+			log_error("Failed to find segment for %s extent " FMTu32 ".",
+				  display_lvname(seg_lv(seg, s)), area_le);
 			return 0;
 		}
 
@@ -2352,8 +2382,8 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 	dm_list_iterate_items(seg_to, &new_segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (!(data_seg = find_seg_by_le(seg_lv(seg, s), area_le))) {
-				log_error("Failed to find segment for %s extent %" PRIu32,
-					  seg_lv(seg, s)->name, area_le);
+				log_error("Failed to find segment for %s extent " FMTu32 ".",
+					  display_lvname(seg_lv(seg, s)), area_le);
 				return 0;
 			}
 
@@ -2396,7 +2426,8 @@ static int _convert_raid0_to_striped(struct logical_volume *lv,
 
 	/* Move the AREA_PV areas across to new top-level segments of type "striped" */
 	if (!_raid0_to_striped_retrieve_segments_and_lvs(lv, removal_lvs)) {
-		log_error("Failed to retrieve raid0 segments from %s.", lv->name);
+		log_error("Failed to retrieve raid0 segments from %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2441,13 +2472,13 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 
 	/* Check for not (yet) supported varying area_count on multi-segment striped LVs */
 	if (!lv_has_constant_stripes(lv)) {
-		log_error("Cannot convert striped LV %s with varying stripe count to raid0",
+		log_error("Cannot convert striped LV %s with varying stripe count to raid0.",
 			  display_lvname(lv));
 		return NULL;
 	}
 
 	if (!is_power_of_2(seg->stripe_size)) {
-		log_error("Cannot convert striped LV %s with non-power of 2 stripe size %u",
+		log_error("Cannot convert striped LV %s with non-power of 2 stripe size %u.",
 			  display_lvname(lv), seg->stripe_size);
 		return NULL;
 	}
@@ -2879,7 +2910,7 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
 
 	if (!yes && yes_no_prompt("Are you sure you want to convert %s back to the older \"%s\" type? [y/n]: ",
 				  display_lvname(lv), SEG_TYPE_NAME_MIRROR) == 'n') {
-		log_error("Logical volume %s NOT converted to \"%s\"",
+		log_error("Logical volume %s NOT converted to \"%s\".",
 			  display_lvname(lv), SEG_TYPE_NAME_MIRROR);
 		return 0;
 	}
@@ -2923,7 +2954,7 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	tmp_areas = seg->meta_areas;
 
 	/* Extract all MetaLVs listing them on @meta_lvs */
-	log_debug_metadata("Extracting all MetaLVs of %s to activate as raid0",
+	log_debug_metadata("Extracting all MetaLVs of %s to activate as raid0.",
 			   display_lvname(lv));
 	if (!_extract_image_component_sublist(seg, RAID_META, 0, seg->area_count, &meta_lvs, 0))
 		return_0;
@@ -2946,9 +2977,9 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
 			return_0;
 
-	log_debug_metadata("Clearing allocated raid0_meta metadata LVs for conversion to raid4");
+	log_debug_metadata("Clearing allocated raid0_meta metadata LVs for conversion to raid4.");
 	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs");
+		log_error("Failed to initialize metadata LVs.");
 		return 0;
 	}
 
@@ -2956,7 +2987,7 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	seg->meta_areas = tmp_areas;
 	seg->segtype = tmp_segtype;
 
-	log_debug_metadata("Adding metadata LVs back into %s", display_lvname(lv));
+	log_debug_metadata("Adding metadata LVs back into %s.", display_lvname(lv));
 	s = 0;
 	dm_list_iterate_items(lvl, &meta_lvs) {
 		lv_set_hidden(lvl->lv);
@@ -3070,7 +3101,7 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	dm_list_init(&removal_lvs);
 
 	if (!seg_is_raid4(seg) && !seg_is_raid5_n(seg) && !seg_is_raid6_n_6(seg)) {
-		log_error("LV %s has to be of type raid4/raid5_n/raid6_n_6 to allow for this conversion",
+		log_error("LV %s has to be of type raid4/raid5_n/raid6_n_6 to allow for this conversion.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -3736,7 +3767,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	takeover_fn_t takeover_fn;
 
 	if (!new_segtype) {
-		log_error(INTERNAL_ERROR "New segtype not specified");
+		log_error(INTERNAL_ERROR "New segtype not specified.");
 		return 0;
 	}
 
@@ -3790,7 +3821,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* LV must be in sync. */
 	if (!_raid_in_sync(lv)) {
-		log_error("Unable to convert %s while it is not in-sync",
+		log_error("Unable to convert %s while it is not in-sync.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -3832,8 +3863,8 @@ static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 				if (pv->status & MISSING_PV)
 					extents_needed += rm_seg->len;
 			}
-			log_debug("%u extents needed to repair %s",
-				  extents_needed, rm_image->name);
+			log_debug_metadata("%u extents needed to repair %s.",
+				  extents_needed, display_lvname(rm_image));
 
 			/* Second, do the other PVs have the space */
 			dm_list_iterate_items(rm_seg, &rm_image->segments) {
@@ -3845,13 +3876,13 @@ static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 
 				if ((pv->pe_count - pv->pe_alloc_count) >
 				    extents_needed) {
-					log_debug("%s has enough space for %s",
-						  pv_dev_name(pv),
-						  rm_image->name);
+					log_debug_metadata("%s has enough space for %s.",
+							   pv_dev_name(pv),
+							   display_lvname(rm_image));
 					goto has_enough_space;
 				}
-				log_debug("Not enough space on %s for %s",
-					  pv_dev_name(pv), rm_image->name);
+				log_debug_metadata("Not enough space on %s for %s.",
+						   pv_dev_name(pv), display_lvname(rm_image));
 			}
 		}
 	}
@@ -3921,15 +3952,15 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		lv->vg->cmd->partial_activation = 1;
 
 	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		log_error("%s/%s must be active %sto perform this operation.",
-			  lv->vg->name, lv->name,
+		log_error("%s must be active %sto perform this operation.",
+			  display_lvname(lv),
 			  vg_is_clustered(lv->vg) ? "exclusive locally " : "");
 		return 0;
 	}
 
 	if (!_raid_in_sync(lv)) {
-		log_error("Unable to replace devices in %s/%s while it is"
-			  " not in-sync.", lv->vg->name, lv->name);
+		log_error("Unable to replace devices in %s while it is "
+			  "not in-sync.", display_lvname(lv));
 		return 0;
 	}
 
@@ -3943,7 +3974,7 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		if ((seg_type(raid_seg, s) == AREA_UNASSIGNED) ||
 		    (seg_metatype(raid_seg, s) == AREA_UNASSIGNED)) {
 			log_error("Unable to replace RAID images while the "
-				  "array has unassigned areas");
+				  "array has unassigned areas.");
 			return 0;
 		}
 
@@ -3960,19 +3991,18 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	}
 
 	if (!match_count) {
-		log_print_unless_silent("%s does not contain devices specified"
-					" to %s", display_lvname(lv), action_str);
+		log_print_unless_silent("%s does not contain devices specified to %s.",
+					display_lvname(lv), action_str);
 		return 1;
 	} else if (match_count == raid_seg->area_count) {
-		log_error("Unable to %s all PVs from %s/%s at once.",
-			  action_str, lv->vg->name, lv->name);
+		log_error("Unable to %s all PVs from %s at once.",
+			  action_str, display_lvname(lv));
 		return 0;
 	} else if (raid_seg->segtype->parity_devs &&
 		   (match_count > raid_seg->segtype->parity_devs)) {
-		log_error("Unable to %s more than %u PVs from (%s) %s/%s",
+		log_error("Unable to %s more than %u PVs from (%s) %s.",
 			  action_str, raid_seg->segtype->parity_devs,
-			  lvseg_name(raid_seg),
-			  lv->vg->name, lv->name);
+			  lvseg_name(raid_seg), display_lvname(lv));
 		return 0;
 	} else if (seg_is_raid10(raid_seg)) {
 		uint32_t i, rebuilds_per_group = 0;
@@ -4049,8 +4079,8 @@ try_again:
 			lv->vg->cmd->partial_activation = 1;
 			goto try_again;
 		}
-		log_error("Failed to allocate replacement images for %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Failed to allocate replacement images for %s.",
+			  display_lvname(lv));
 
 		return 0;
 	}
@@ -4073,8 +4103,8 @@ try_again:
 				  partial_segment_removed ?
 				  &lv->vg->pvs : remove_pvs, 0,
 				  &old_lvs, &old_lvs)) {
-		log_error("Failed to remove the specified images from %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Failed to remove the specified images from %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -4106,8 +4136,9 @@ try_again:
 				return_0;
 			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
 						    lvl->lv->status)) {
-				log_error("Failed to add %s to %s",
-					  lvl->lv->name, lv->name);
+				log_error("Failed to add %s to %s.",
+					  display_lvname(lvl->lv),
+					  display_lvname(lv));
 				return 0;
 			}
 			lv_set_hidden(lvl->lv);
@@ -4121,8 +4152,9 @@ try_again:
 				return_0;
 			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
 						    lvl->lv->status)) {
-				log_error("Failed to add %s to %s",
-					  lvl->lv->name, lv->name);
+				log_error("Failed to add %s to %s.",
+					  display_lvname(lvl->lv),
+					  display_lvname(lv));
 				return 0;
 			}
 			lv_set_hidden(lvl->lv);
@@ -4200,16 +4232,16 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	struct lv_segment *seg = first_seg(lv);
 
 	if (!lv_is_partial(lv)) {
-		log_error(INTERNAL_ERROR "%s/%s is not a partial LV",
-			  lv->vg->name, lv->name);
+		log_error(INTERNAL_ERROR "%s is not a partial LV.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!archive(lv->vg))
 		return_0;
 
-	log_debug("Attempting to remove missing devices from %s LV, %s",
-		  lvseg_name(seg), lv->name);
+	log_debug("Attempting to remove missing devices from %s LV, %s.",
+		  lvseg_name(seg), display_lvname(lv));
 
 	/*
 	 * FIXME: Make sure # of compromised components will not affect RAID
@@ -4220,10 +4252,10 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		    (!seg->meta_areas || !seg_metalv(seg, s) || !lv_is_partial(seg_metalv(seg, s))))
 			continue;
 
-		log_debug("Replacing %s segments with error target",
+		log_debug("Replacing %s segments with error target.",
 			  display_lvname(seg_lv(seg, s)));
 		if (seg->meta_areas && seg_metalv(seg, s))
-			log_debug("Replacing %s segments with error target",
+			log_debug("Replacing %s segments with error target.",
 				  display_lvname(seg_metalv(seg, s)));
 		if (!replace_lv_with_error_segment(seg_lv(seg, s))) {
 			log_error("Failed to replace %s's extents with error target.",
@@ -4325,7 +4357,7 @@ static int _lv_may_be_activated_in_degraded_mode(struct logical_volume *lv, void
 	dm_list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) != AREA_LV) {
-				log_verbose("%s contains a segment incapable of degraded activation",
+				log_verbose("%s contains a segment incapable of degraded activation.",
 					    display_lvname(lv));
 				*not_capable = 1;
 			}


