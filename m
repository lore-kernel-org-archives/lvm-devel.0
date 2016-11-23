From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:47 +0000 (UTC)
Subject: master - cleanup: use display_lvname and msg cleanup
Message-ID: <20161123165547.ED8C060F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5fd5cfe06143cc7323efb9b76a4d520cc9442df8
Commit:        5fd5cfe06143cc7323efb9b76a4d520cc9442df8
Parent:        0ad95b77d0f3eb38bc678bf15ecb899e109287cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 16 15:11:07 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:48:01 2016 +0100

cleanup: use display_lvname and msg cleanup

Use display_lvname in tracing messages.
Add some missing 'dots' to messages.
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    2 +-
 lib/metadata/lv_manip.c                       |   21 ++--
 lib/metadata/mirror.c                         |  212 +++++++++++++------------
 lib/metadata/raid_manip.c                     |    4 +-
 tools/lvconvert.c                             |    8 +-
 5 files changed, 126 insertions(+), 121 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 9df5f1d..a207c99 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -61,7 +61,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 		if (status->insync_regions < status->total_regions) {
 			if (!state->warned)
 				log_warn("WARNING: waiting for resynchronization to finish "
-					 "before initiating repair on RAID device %s", device);
+					 "before initiating repair on RAID device %s.", device);
 
 			state->warned = 1;
 			goto out; /* Not yet done syncing with accessible devices */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0643000..58be1db 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1132,14 +1132,15 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			   struct logical_volume *lv, uint32_t le,
 			   uint64_t status)
 {
-	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
-			 seg->lv->name, seg->le, area_num, lv->name, le);
+	log_very_verbose("Stack %s:" FMTu32 "[" FMTu32 "] on LV %s:" FMTu32 ".",
+			 display_lvname(seg->lv), seg->le, area_num,
+			 display_lvname(lv), le);
 
 	if (status & RAID_META) {
 		seg->meta_areas[area_num].type = AREA_LV;
 		seg_metalv(seg, area_num) = lv;
 		if (le) {
-			log_error(INTERNAL_ERROR "Meta le != 0");
+			log_error(INTERNAL_ERROR "Meta le != 0.");
 			return 0;
 		}
 		seg_metale(seg, area_num) = 0;
@@ -3617,16 +3618,16 @@ int lv_add_mirror_areas(struct alloc_handle *ah,
 
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(lv, current_le))) {
-			log_error("Failed to find segment for %s extent %"
-				  PRIu32, lv->name, current_le);
+			log_error("Failed to find segment for %s extent " FMTu32 ".",
+				  display_lvname(lv), current_le);
 			return 0;
 		}
 
 		/* Allocator assures aa[0].len <= seg->area_len */
 		if (aa[0].len < seg->area_len) {
 			if (!lv_split_segment(lv, seg->le + aa[0].len)) {
-				log_error("Failed to split segment at %s "
-					  "extent %" PRIu32, lv->name, le);
+				log_error("Failed to split segment at %s extent " FMTu32 ".",
+					  display_lvname(lv), le);
 				return 0;
 			}
 		}
@@ -3675,7 +3676,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 	seg = first_seg(lv);
 
 	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
-		log_error("Mirror layer must be inserted before adding mirrors");
+		log_error("Mirror layer must be inserted before adding mirrors.");
 		return 0;
 	}
 
@@ -3685,7 +3686,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 			return_0;
 
 	if (region_size && region_size != seg->region_size) {
-		log_error("Conflicting region_size");
+		log_error("Conflicting region_size.");
 		return 0;
 	}
 
@@ -3694,7 +3695,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 
 	if (!_lv_segment_add_areas(lv, seg, new_area_count)) {
 		log_error("Failed to allocate widened LV segment for %s.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index feb78a5..f5a3676 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -136,16 +136,15 @@ struct lv_segment *find_mirror_seg(struct lv_segment *seg)
 {
 	struct lv_segment *mirror_seg;
 
-	mirror_seg = get_only_segment_using_this_lv(seg->lv);
-
-	if (!mirror_seg) {
-		log_error("Failed to find mirror_seg for %s", seg->lv->name);
+	if (!(mirror_seg = get_only_segment_using_this_lv(seg->lv))) {
+		log_error("Failed to find mirror_seg for %s", display_lvname(seg->lv));
 		return NULL;
 	}
 
 	if (!seg_is_mirrored(mirror_seg)) {
-		log_error("%s on %s is not a mirror segments",
-			  mirror_seg->lv->name, seg->lv->name);
+		log_error("LV %s on %s is not a mirror segments.",
+			  display_lvname(mirror_seg->lv),
+			  display_lvname(seg->lv));
 		return NULL;
 	}
 
@@ -246,7 +245,7 @@ int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage)
 
 	if (mimage >= mirrored_seg->area_count) {
 		log_error("Invalid index (%u) of mirror image supplied "
-			  "to shift_mirror_images()", mimage);
+			  "to shift_mirror_images().", mimage);
 		return 0;
 	}
 
@@ -282,21 +281,22 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	log_header.nr_regions = xlate64((uint64_t)-1);
 
 	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - log header not written (%s)",
-			lv->name);
+		log_error("Name allocation failed - log header not written (%s).",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
 			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - log header not written (%s)", lv->name);
+		log_error("Name too long - log header not written (%s).",
+			  display_lvname(lv));
 		return 0;
 	}
 
-	log_verbose("Writing log header to device, %s", lv->name);
+	log_verbose("Writing log header to device %s.", display_lvname(lv));
 
 	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: log header not written", name);
+		log_error("%s: not found: log header not written.", name);
 		return 0;
 	}
 
@@ -304,7 +304,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 
 	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		log_error("Failed to write log header to %s", name);
+		log_error("Failed to write log header to %s.", name);
 		dev_close_immediate(dev);
 		return 0;
 	}
@@ -663,8 +663,8 @@ static int _split_mirror_images(struct logical_volume *lv,
 	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!lv_is_mirrored(lv)) {
-		log_error("Unable to split non-mirrored LV, %s",
-			  lv->name);
+		log_error("Unable to split non-mirrored LV %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -673,8 +673,8 @@ static int _split_mirror_images(struct logical_volume *lv,
 		return 0;
 	}
 
-	log_verbose("Detaching %d images from mirror, %s",
-		    split_count, lv->name);
+	log_verbose("Detaching %d images from mirror %s.",
+		    split_count, display_lvname(lv));
 
 	if (!_move_removable_mimages_to_end(lv, split_count, removable_pvs)) {
 		/*
@@ -684,8 +684,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		 * removable PVs or all of them.  Should we allow
 		 * them to just specify some - making us pick the rest?
 		 */
-		log_error("Insufficient removable PVs given"
-			  " to satisfy request");
+		log_error("Insufficient removable PVs given to satisfy request.");
 		return 0;
 	}
 
@@ -704,7 +703,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		if (!release_lv_segment_area(mirrored_seg, mirrored_seg->area_count, mirrored_seg->area_len))
 			return_0;
 
-		log_very_verbose("%s assigned to be split", sub_lv->name);
+		log_very_verbose("LV %s assigned to be split.", display_lvname(sub_lv));
 
 		if (!new_lv) {
 			lv_set_visible(sub_lv);
@@ -715,7 +714,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		/* If there is more than one image being split, add to list */
 		lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl));
 		if (!lvl) {
-			log_error("lv_list alloc failed");
+			log_error("lv_list alloc failed.");
 			return 0;
 		}
 		lvl->lv = sub_lv;
@@ -738,8 +737,8 @@ static int _split_mirror_images(struct logical_volume *lv,
 		 */
 
 		if (!insert_layer_for_lv(cmd, new_lv, 0, "_mimage_%d")) {
-			log_error("Failed to build new mirror, %s",
-				  new_lv->name);
+			log_error("Failed to build new mirror, %s.",
+				  display_lvname(new_lv));
 			return 0;
 		}
 
@@ -750,25 +749,25 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 			if (dm_snprintf(format, len, "%s_mimage_%%d",
 					new_lv->name) < 0) {
-				log_error("Failed to build new image name.");
+				log_error("Failed to build new image name for %s.",
+					  display_lvname(new_lv));
 				return 0;
 			}
-			layer_name = dm_pool_alloc(lv->vg->vgmem, len);
-			if (!layer_name) {
-				log_error("Unable to allocate memory");
+			if (!(layer_name = dm_pool_alloc(lv->vg->vgmem, len))) {
+				log_error("Unable to allocate memory.");
 				return 0;
 			}
 			if (!generate_lv_name(lv->vg, format, layer_name, len)||
 			    sscanf(layer_name, format, &i) != 1) {
-				log_error("Failed to generate new image names");
+				log_error("Failed to generate new image names for %s.",
+					  display_lvname(new_lv));
 				return 0;
 			}
 			sub_lv->name = layer_name;
 		}
 
 		if (!_merge_mirror_images(new_lv, &split_images)) {
-			log_error("Failed to group split "
-				  "images into new mirror");
+			log_error("Failed to group split images into new mirror.");
 			return 0;
 		}
 
@@ -904,15 +903,14 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (removed)
 		*removed = 0;
 
-	log_very_verbose("Reducing mirror set %s from %" PRIu32 " to %"
-			 PRIu32 " image(s)%s.", lv->name,
+	log_very_verbose("Reducing mirror set %s from " FMTu32 " to " FMTu32
+			 " image(s)%s.", display_lvname(lv),
 			 old_area_count, old_area_count - num_removed,
 			 remove_log ? " and no log volume" : "");
 
 	if (collapse && (old_area_count - num_removed != 1)) {
-		log_error("Incompatible parameters to _remove_mirror_images");
+		log_error("Incompatible parameters to _remove_mirror_images.");
 		return 0;
-
 	}
 
 	num_removed = 0;
@@ -936,7 +934,8 @@ static int _remove_mirror_images(struct logical_volume *lv,
 			 */
 			if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
 			    !(lv_is_partial(lv))) {
-				log_error("Unable to remove primary mirror image while mirror is not in-sync");
+				log_error("Unable to remove primary mirror image while mirror volume "
+					  "%s is not in-sync.", display_lvname(lv));
 				return 0;
 			}
 			if (!shift_mirror_images(mirrored_seg, s))
@@ -965,7 +964,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		lv_set_visible(seg_lv(mirrored_seg, m));
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
-			log_error("lv_list alloc failed");
+			log_error("lv_list alloc failed.");
 			return 0;
 		}
 		lvl->lv = seg_lv(mirrored_seg, m);
@@ -987,7 +986,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		if (!remove_layer_from_lv(lv, temp_layer_lv))
 			return_0;
 		if (collapse && !_merge_mirror_images(lv, &tmp_orphan_lvs)) {
-			log_error("Failed to add mirror images");
+			log_error("Failed to add mirror images.");
 			return 0;
 		}
                 /*
@@ -1008,7 +1007,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 			dm_list_iterate_items(pvmove_seg, &lv->segments)
 				pvmove_seg->status |= PVMOVE;
 	} else if (new_area_count == 0) {
-		log_very_verbose("All mimages of %s are gone", lv->name);
+		log_very_verbose("All mimages of %s are gone.", display_lvname(lv));
 
 		/* All mirror images are gone.
 		 * It can happen for vgreduce --removemissing. */
@@ -1037,8 +1036,8 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	    lv_is_partial(detached_log_lv)) {
 		struct lv_segment *seg = first_seg(detached_log_lv);
 
-		log_very_verbose("%s being removed due to failures",
-				 detached_log_lv->name);
+		log_very_verbose("%s being removed due to failures.",
+				 display_lvname(detached_log_lv));
 
 		/*
 		 * We are going to replace the mirror with an
@@ -1047,20 +1046,19 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		 * the sub-lv's)
 		 */
 		for (m = 0; m < seg->area_count; m++) {
+			if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
+						  sizeof(*lvl))))
+				return_0;
+
 			seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
 			lv_set_visible(seg_lv(seg, m));
-			if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
-						  sizeof(*lvl)))) {
-				log_error("dm_pool_alloc failed");
-				return 0;
-			}
 			lvl->lv = seg_lv(seg, m);
 			dm_list_add(&tmp_orphan_lvs, &lvl->list);
 		}
 
 		if (!replace_lv_with_error_segment(detached_log_lv)) {
-			log_error("Failed error target substitution for %s",
-				  detached_log_lv->name);
+			log_error("Failed error target substitution for %s.",
+				  display_lvname(detached_log_lv));
 			return 0;
 		}
 
@@ -1095,14 +1093,13 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * remove the LVs from the mirror set, commit that metadata
 	 * then deactivate and remove them fully.
 	 */
-
 	if (!vg_write(mirrored_seg->lv->vg)) {
 		log_error("intermediate VG write failed.");
 		return 0;
 	}
 
 	if (!suspend_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s", mirrored_seg->lv->name);
+		log_error("Failed to lock %s.", display_lvname(mirrored_seg->lv));
 		vg_revert(mirrored_seg->lv->vg);
 		return 0;
 	}
@@ -1115,7 +1112,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * FIXME: check propagation of suspend with visible flag
 	 */
 	if (temp_layer_lv && !suspend_lv(temp_layer_lv->vg->cmd, temp_layer_lv))
-		log_error("Problem suspending temporary LV %s", temp_layer_lv->name);
+		log_error("Problem suspending temporary LV %s.", display_lvname(temp_layer_lv));
 
 	if (!vg_commit(mirrored_seg->lv->vg)) {
 		if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv))
@@ -1123,7 +1120,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		return_0;
 	}
 
-	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
+	log_very_verbose("Updating %s in kernel.", display_lvname(mirrored_seg->lv));
 
 	/*
 	 * Avoid having same mirror target loaded twice simultaneously by first
@@ -1132,12 +1129,12 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * explicitly.
 	 */
 	if (temp_layer_lv && !resume_lv(temp_layer_lv->vg->cmd, temp_layer_lv)) {
-		log_error("Problem resuming temporary LV, %s", temp_layer_lv->name);
+		log_error("Problem resuming temporary LV %s.", display_lvname(temp_layer_lv));
 		return 0;
 	}
 
 	if (!resume_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Problem reactivating %s", mirrored_seg->lv->name);
+		log_error("Problem reactivating %s.", display_lvname(mirrored_seg->lv));
 		return 0;
 	}
 
@@ -1162,7 +1159,8 @@ static int _remove_mirror_images(struct logical_volume *lv,
 				      1, &lv->tags, 0)) {
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
-			log_error("Failed to initialize log device");
+			log_error("Failed to initialize log device %s.",
+				  display_lvname(first_seg(lv)->log_lv));
 			return 0;
 		}
 	}
@@ -1170,8 +1168,9 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (removed)
 		*removed = old_area_count - new_area_count;
 
-	log_very_verbose(FMTu32 " image(s) removed from %s",
-			 old_area_count - new_area_count, lv->name);
+	log_very_verbose(FMTu32 " image(s) removed from %s.",
+			 old_area_count - new_area_count,
+			 display_lvname(lv));
 
 	return 1;
 }
@@ -1353,15 +1352,15 @@ static int _replace_mirror_images(struct lv_segment *mirrored_seg,
 	/* FIXME: Use lvconvert rather than duplicating its code */
 
 	if (mirrored_seg->area_count < num_mirrors) {
-		log_warn("WARNING: Failed to replace mirror device in %s/%s",
-			 mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+		log_warn("WARNING: Failed to replace mirror device in %s.",
+			 display_lvname(mirrored_seg->lv);
 
 		if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv)
-			log_warn("WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices",
-				 num_mirrors - 1, lv->vg->name, lv->name);
+			log_warn("WARNING: Use 'lvconvert -m %d %s --corelog' to replace failed devices.",
+				 num_mirrors - 1, display_lvname(lv));
 		else
-			log_warn("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
-				 num_mirrors - 1, lv->vg->name, lv->name);
+			log_warn("WARNING: Use 'lvconvert -m %d %s' to replace failed devices.",
+				 num_mirrors - 1, display_lvname(lv));
 		r = 0;
 
 		/* REMEMBER/FIXME: set in_sync to 0 if a new mirror device was added */
@@ -1374,11 +1373,11 @@ static int _replace_mirror_images(struct lv_segment *mirrored_seg,
 	 */
 	if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv &&
 	    (log_policy != MIRROR_REMOVE)) {
-		log_warn("WARNING: Failed to replace mirror log device in %s/%s",
-			 lv->vg->name, lv->name);
+		log_warn("WARNING: Failed to replace mirror log device in %s.",
+			 display_lvname(lv));
 
-		log_warn("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
-			 mirrored_seg->area_count - 1 , lv->vg->name, lv->name);
+		log_warn("WARNING: Use 'lvconvert -m %d %s' to replace failed devices.",
+			 mirrored_seg->area_count - 1 , display_lvname(lv));
 		r = 0;
 	}
 
@@ -1411,8 +1410,8 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 		/* Unable to remove bad devices */
 		return 0;
 
-	log_warn("WARNING: Bad device removed from mirror volume, %s/%s",
-		  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+	log_warn("WARNING: Bad device removed from mirror volume %s.",
+		  display_lvname(mirrored_seg->lv));
 
 	log_policy = _get_mirror_log_fault_policy(mirrored_seg->lv->vg->cmd);
 	dev_policy = _get_mirror_device_fault_policy(mirrored_seg->lv->vg->cmd);
@@ -1424,20 +1423,20 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 
 	if (!r)
 		/* Failed to replace device(s) */
-		log_warn("WARNING: Unable to find substitute device for mirror volume, %s/%s",
-			 mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+		log_warn("WARNING: Unable to find substitute device for mirror volume %s.",
+			 display_lvname(mirrored_seg->lv));
 	else if (r > 0)
 		/* Success in replacing device(s) */
-		log_warn("WARNING: Mirror volume, %s/%s restored - substitute for failed device found.",
-			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+		log_warn("WARNING: Mirror volume %s restored - substitute for failed device found.",
+			 display_lvname(mirrored_seg->lv));
 	else
 		/* Bad device removed, but not replaced because of policy */
 		if (mirrored_seg->area_count == 1) {
-			log_warn("WARNING: Mirror volume, %s/%s converted to linear due to device failure.",
-				  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+			log_warn("WARNING: Mirror volume %s converted to linear due to device failure.",
+				  display_lvname(mirrored_seg->lv);
 		} else if (had_log && !mirrored_seg->log_lv) {
-			log_warn("WARNING: Mirror volume, %s/%s disk log removed due to device failure.",
-				  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+			log_warn("WARNING: Mirror volume %s disk log removed due to device failure.",
+				  display_lvname(mirrored_seg->lv));
 		}
 	/*
 	 * If we made it here, we at least removed the bad device.
@@ -1734,23 +1733,26 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc, 0,
 				    parallel_areas))) {
-		log_error("Unable to allocate mirror extents for %s.", lv->name);
+		log_error("Unable to allocate mirror extents for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (flags & MIRROR_BY_SEG) {
 		if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
-			log_error("Failed to add mirror areas to %s", lv->name);
+			log_error("Failed to add mirror areas to %s.",
+				  display_lvname(lv));
 			r = 0;
 		}
 	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
 		if (!lv_add_segmented_mirror_image(ah, lv, 0,
 						   adjusted_region_size)) {
-			log_error("Failed to add mirror areas to %s", lv->name);
+			log_error("Failed to add mirror areas to %s.",
+				  display_lvname(lv));
 			r = 0;
 		}
 	} else {
-		log_error(INTERNAL_ERROR "Unknown mirror flag");
+		log_error(INTERNAL_ERROR "Unknown mirror flag.");
 		r = 0;
 	}
 	alloc_destroy(ah);
@@ -1784,7 +1786,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 
 	/* Unimplemented features */
 	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Multiple-segment mirror is not supported");
+		log_error("Multiple-segment mirror is not supported.");
 		return 0;
 	}
 
@@ -1796,19 +1798,19 @@ int remove_mirror_log(struct cmd_context *cmd,
 			return 0;
 		}
 	} else if (lv_is_active(lv)) {
-		log_error("Unable to determine sync status of"
-			  " remotely active mirror, %s", lv->name);
+		log_error("Unable to determine sync status of "
+			  "remotely active mirror volume %s.", display_lvname(lv));
 		return 0;
 	} else if (vg_is_clustered(vg)) {
 		log_error("Unable to convert the log of an inactive "
-			  "cluster mirror, %s", lv->name);
+			  "cluster mirror volume %s.", display_lvname(lv));
 		return 0;
-	} else if (force || yes_no_prompt("Full resync required to convert "
-				 "inactive mirror %s to core log. "
-				 "Proceed? [y/n]: ", lv->name) == 'y')
+	} else if (force || yes_no_prompt("Full resync required to convert inactive "
+					  "mirror volume %s to core log. "
+					  "Proceed? [y/n]: ", display_lvname(lv)) == 'y')
 		sync_percent = 0;
 	else {
-		log_error("Logical volume %s NOT converted.", lv->name);
+		log_error("Logical volume %s NOT converted.", display_lvname(lv));
 		return 0;
 	}
 
@@ -1976,25 +1978,25 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	int r = 0;
 
 	if (vg_is_clustered(lv->vg) && (log_count > 1)) {
-		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
 		return 0;
 	}
 
 	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Multiple-segment mirror is not supported");
+		log_error("Multiple-segment mirror is not supported.");
 		return 0;
 	}
 
 	if (lv_is_active_but_not_locally(lv)) {
 		log_error("Unable to convert the log of a mirror, %s, that is "
-			  "active remotely but not locally", lv->name);
+			  "active remotely but not locally.", display_lvname(lv));
 		return 0;
 	}
 
 	log_lv = first_seg(lv)->log_lv;
 	old_log_count = (log_lv) ? lv_mirror_count(log_lv) : 0;
 	if (old_log_count == log_count) {
-		log_verbose("Mirror already has a %s log",
+		log_verbose("Mirror %s already has a %s log.", display_lvname(lv),
 			    !log_count ? "core" :
 			    (log_count == 1) ? "disk" : "mirrored");
 		return 1;
@@ -2138,7 +2140,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags)
 {
 	if (!mirrors && !log_count) {
-		log_error("No conversion is requested");
+		log_error("No conversion is requested.");
 		return 0;
 	}
 
@@ -2158,7 +2160,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		 * log daemon is multi-threaded.
 		 */
 		if (log_count > 1) {
-			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
 			return 0;
 		}
 	}
@@ -2176,12 +2178,12 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 	if (flags & MIRROR_BY_SEG) {
 		if (log_count) {
 			log_error("Persistent log is not supported on "
-				  "segment-by-segment mirroring");
+				  "segment-by-segment mirroring.");
 			return 0;
 		}
 		if (stripes > 1) {
 			log_error("Striped-mirroring is not supported on "
-				  "segment-by-segment mirroring");
+				  "segment-by-segment mirroring.");
 			return 0;
 		}
 
@@ -2191,7 +2193,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
 		if (stripes > 1) {
 			log_error("Striped-mirroring is not supported on "
-				  "segment-by-segment mirroring");
+				  "segment-by-segment mirroring.");
 			return 0;
 		}
 
@@ -2207,7 +2209,8 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 					 pvs, alloc, log_count);
 	}
 
-	log_error("Unsupported mirror conversion type");
+	log_error("Unsupported mirror conversion type.");
+
 	return 0;
 }
 
@@ -2219,14 +2222,15 @@ int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
 
 	if (lv_name_is_used_in_vg(lv->vg, split_name, &historical)) {
 		log_error("%sLogical Volume \"%s\" already exists in "
-			  "volume group \"%s\"", historical ? "historical " : "",
+			  "volume group \"%s\".", historical ? "historical " : "",
 			  split_name, lv->vg->name);
 		return 0;
 	}
 
 	/* Can't split a mirror that is not in-sync... unless force? */
 	if (!_mirrored_lv_in_sync(lv)) {
-		log_error("Unable to split mirror that is not in-sync.");
+		log_error("Unable to split mirror %s that is not in-sync.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2263,18 +2267,18 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 	struct lv_segment *seg;
 
 	if (!mirrors && !log_count) {
-		log_error("No conversion is requested");
+		log_error("No conversion is requested.");
 		return 0;
 	}
 
 	seg = first_seg(lv);
 	if (!seg_is_mirrored(seg)) {
-		log_error("Not a mirror segment");
+		log_error("Not a mirror segment.");
 		return 0;
 	}
 
 	if (lv_mirror_count(lv) <= mirrors) {
-		log_error("Removing more than existing: %d <= %d",
+		log_error("Removing more than existing: %d <= %d.",
 			  seg->area_count, mirrors);
 		return 0;
 	}
@@ -2290,7 +2294,7 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 	/* MIRROR_BY_SEG */
 	if (log_count) {
 		log_error("Persistent log is not supported on "
-			  "segment-by-segment mirroring");
+			  "segment-by-segment mirroring.");
 		return 0;
 	}
 	return remove_mirrors_from_segments(lv, new_mirrors, status_mask);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cf4cce1..e91667e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -283,8 +283,8 @@ static int _raid_in_sync(struct logical_volume *lv)
 		 * https://bugzilla.redhat.com/1210637
 		 */
 		if (!lv_raid_percent(lv, &sync_percent)) {
-			log_error("Unable to determine sync status of %s/%s.",
-				  lv->vg->name, lv->name);
+			log_error("Unable to determine sync status of %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 		if (sync_percent > DM_PERCENT_0)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ceeff2d..6165320 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1484,7 +1484,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		 */
 		if (lv_is_origin(lv)) {
 			log_error("Can't add additional mirror images to "
-				  "mirrors that are under snapshots,");
+				  "mirror %s which is under snapshots.",
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -1767,13 +1768,12 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_log_count;
 
 	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
-		log_error("--corelog and --mirrorlog are only compatible with mirror devices");
+		log_error("--corelog and --mirrorlog are only compatible with mirror devices.");
 		return 0;
 	}
 
 	if (lp->merge_mirror) {
-		log_error("Unable to merge mirror images"
-			  "of segment type 'mirror'.");
+		log_error("Unable to merge mirror images of segment type 'mirror'.");
 		return 0;
 	}
 


