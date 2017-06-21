From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 06:37:09 -0400
Subject: master - debug: missing traces
Message-ID: <201706211037.v5LAb9o1021152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f4cfa7c4a6da707354f8c1c059531dac5287192
Commit:        5f4cfa7c4a6da707354f8c1c059531dac5287192
Parent:        07fe64b47317daba1744c8c1ccbef38754fe8a4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 11:29:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 12:36:01 2017 +0200

debug: missing traces

---
 lib/metadata/raid_manip.c |   87 +++++++++++++++++++++++----------------------
 1 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b91bfba..34545b4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -912,7 +912,7 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 		break;
 
 	default:
-		return 0;
+		return_0;
 	}
 
 	/* Sort areas */
@@ -1591,7 +1591,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		lv->size = lv_size_cur;
 		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
 		if (!_lv_set_reshape_len(lv, _lv_total_rimage_len(lv) - prev_rimage_len))
-			return 0;
+			return_0;
 	}
 
 	/* Preset data offset in case we fail relocating reshape space below */
@@ -1668,7 +1668,7 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 		seg->extents_copied = first_seg(lv)->area_len;
 
 		if (!_lv_set_reshape_len(lv, 0))
-			return 0;
+			return_0;
 
 		/*
 		 * Only in case reshape space was freed at the beginning,
@@ -1722,7 +1722,7 @@ static int _reshaped_state(struct logical_volume *lv, const unsigned dev_count,
 		return_0;
 
 	if (!_get_dev_health(lv, &kernel_devs, devs_health, devs_in_sync, NULL))
-		return 0;
+		return_0;
 
 	if (kernel_devs == dev_count)
 		return 1;
@@ -1773,7 +1773,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 	uint32_t new_le_count;
 
 	if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &new_le_count))
-		return 0;
+		return_0;
 
 	/* Externally visible LV size w/o reshape space */
 	lv->le_count = seg->len = new_le_count;
@@ -1836,7 +1836,7 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 	}
 
 	if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &grown_le_count))
-		return 0;
+		return_0;
 
 	current_le_count = lv->le_count - _reshape_len_per_lv(lv);
 	grown_le_count -= _reshape_len_per_dev(seg) * _data_rimages_count(seg, new_image_count);
@@ -1861,7 +1861,7 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 			   new_image_count - old_image_count, new_image_count - old_image_count > 1 ? "s" : "",
 			   display_lvname(lv));
 	if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, NULL, 0, 0))
-		return 0;
+		return_0;
 
 	/* Reshape adding image component pairs -> change sizes/counters accordingly */
 	if (!_reshape_adjust_to_size(lv, old_image_count, new_image_count)) {
@@ -1872,7 +1872,7 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 	/* Allocate forward out of place reshape space at the beginning of all data image LVs */
 	log_debug_metadata("(Re)allocating reshape space for %s.", display_lvname(lv));
 	if (!_lv_alloc_reshape_space(lv, alloc_begin, NULL, allocate_pvs))
-		return 0;
+		return_0;
 
 	/*
 	 * Reshape adding image component pairs:
@@ -1947,7 +1947,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		}
 
 		if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &reduced_le_count))
-			return 0;
+			return_0;
 
 		reduced_le_count -= seg->reshape_len * _data_rimages_count(seg, new_image_count);
 		current_le_count = lv->le_count - seg->reshape_len * _data_rimages_count(seg, old_image_count);
@@ -1985,7 +1985,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		 * to remove disks from a raid set
 		 */
 		if (!_lv_alloc_reshape_space(lv, alloc_end, NULL, allocate_pvs))
-			return 0;
+			return_0;
 
 		/* Flag all disks past new images as delta disks minus to kernel */
 		for (s = new_image_count; s < old_image_count; s++)
@@ -2031,7 +2031,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 				   old_image_count - new_image_count, old_image_count - new_image_count > 1 ? "s" : "",
 				   display_lvname(lv));
 		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, removal_lvs, 0, 0))
-			return 0;
+			return_0;
 
 		seg->area_count = new_image_count;
 		break;
@@ -2102,7 +2102,7 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 
 	if (alloc_reshape_space &&
 	    !_lv_alloc_reshape_space(lv, where, NULL, allocate_pvs))
-		return 0;
+		return_0;
 
 	seg->segtype = new_segtype;
 
@@ -2198,7 +2198,7 @@ static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
 	struct dm_list *lv_list = data;
 
 	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
-		return 0;
+		return_0;
 
 	/* 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
 	return _activate_sub_lvs_excl_local_list(lv, lv_list) ? 2 : 0;
@@ -2245,7 +2245,7 @@ static int _raid_reshape(struct logical_volume *lv,
 		return_0;
 
 	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
-		return 0;
+		return_0;
 
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to convert %s while it is not in-sync.",
@@ -2343,7 +2343,7 @@ static int _raid_reshape(struct logical_volume *lv,
 		if (!_raid_reshape_add_images(lv, new_segtype, yes,
 					      old_image_count, new_image_count,
 					      new_stripes, new_stripe_size, allocate_pvs))
-			return 0;
+			return_0;
 
 	/* Handle disk removal reshaping */
 	} else if (old_image_count > new_image_count) {
@@ -2351,7 +2351,7 @@ static int _raid_reshape(struct logical_volume *lv,
 						 old_image_count, new_image_count,
 						 new_stripes, new_stripe_size,
 						 allocate_pvs, &removal_lvs))
-			return 0;
+			return_0;
 
 	/*
 	 * Handle raid set layout reshaping w/o changing # of legs (allocation algorithm or stripe size change)
@@ -2359,7 +2359,7 @@ static int _raid_reshape(struct logical_volume *lv,
 	 */
 	} else if (!_raid_reshape_keep_images(lv, new_segtype, yes, force, &force_repair,
 					      new_data_copies, new_stripe_size, allocate_pvs))
-		return 0;
+		return_0;
 
 	/* HM FIXME: workaround for not resetting "nosync" flag */
 	init_mirror_in_sync(0);
@@ -2368,13 +2368,13 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	/* https://bugzilla.redhat.com/1447812 also check open count */
 	if (!_check_lv_open_count(lv, 1))
-		return 0;
+		return_0;
 
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
-			return 0;
+			return_0;
 	} if (!_vg_write_commit_backup(lv->vg))
-		return 0;
+		return_0;
 
 	return 1; 
 	/* FIXME force_repair ? _lv_cond_repair(lv) : 1; */
@@ -3549,7 +3549,7 @@ static int _add_image_component_list(struct lv_segment *seg, int delete_from_lis
 		if (delete_from_list)
 			dm_list_del(&lvl->list);
 		if (!_add_component_lv(seg, lvl->lv, lv_flags, s++))
-			return 0;
+			return_0;
 	}
 
 	return 1;
@@ -3655,7 +3655,7 @@ static int _extract_image_component_sublist(struct lv_segment *seg,
 
 	for (s = idx; s < end; s++) {
 		if (!_extract_image_component_error_seg(seg, type, s, &lvl->lv, error_seg))
-			return 0;
+			return_0;
 
 		dm_list_add(removal_lvs, &lvl->list);
 		lvl++;
@@ -3812,7 +3812,7 @@ static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
 		new_raid_type_flag = SEG_RAID0;
 	} else {
 		if (!_alloc_and_add_rmeta_devs_for_lv(lv, allocate_pvs))
-			return 0;
+			return_0;
 
 		new_raid_type_flag = SEG_RAID0_META;
 	}
@@ -4526,7 +4526,7 @@ static int _process_type_flags(const struct logical_volume *lv, struct possible_
 		    !(t & seg->segtype->flags) &&
 		     ((segtype = get_segtype_from_flag(lv->vg->cmd, t))))
 			if (!tfn(processed_segtypes, data ? : (void *) segtype))
-				return 0;
+				return_0;
 	}
 
 	return 1;
@@ -4857,7 +4857,7 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	dm_list_iterate_items(lvl, &meta_lvs) {
 		lv_set_hidden(lvl->lv);
 		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0, RAID_META))
-			return 0;
+			return_0;
 	}
 
 	return 1;
@@ -5011,7 +5011,7 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 
 	/* Shift parity SubLV pair "PDD..." <-> "DD...P" on raid4 <-> raid5_n conversion */
 	if( !_shift_parity_dev(seg))
-		return 0;
+		return_0;
 
 	/* Don't resync */
 	init_mirror_in_sync(1);
@@ -5051,7 +5051,7 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
-		return 0;
+		return_0;
 
 	if (seg_is_any_raid10(seg) && (seg->area_count % seg->data_copies)) {
 		log_error("Can't convert %s LV %s to %s with odd number of stripes.",
@@ -5096,12 +5096,12 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	if (seg_is_raid4(seg)) {
 		/* Shift parity SubLV pair "PDD..." -> "DD...P" to be able to remove it off the end */
 		if (!_shift_parity_dev(seg))
-			return 0;
+			return_0;
 
 	} else if (seg_is_raid10_near(seg)) {
 		log_debug_metadata("Reordering areas for raid10 -> raid0 takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_from_raid10_near))
-			return 0;
+			return_0;
 	}
 
 	if (segtype_is_any_raid0(new_segtype) &&
@@ -5116,7 +5116,7 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 				   lv_raid_image_count(lv) - new_image_count,
 				   display_lvname(lv));
 		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
-			return 0;
+			return_0;
 
 		seg->area_count = new_image_count;
 	}
@@ -5266,7 +5266,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
-		return 0;
+		return_0;
 
 	/* Archive metadata */
 	if (!archive(lv->vg))
@@ -5287,7 +5287,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	if (seg_is_raid0(seg)) {
 		log_debug_metadata("Adding metadata LVs to %s.", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, NULL))
-			return 0;
+			return_0;
 	}
 
 	/* Have to be cleared in conversion from raid0_meta -> raid4 or kernel will reject due to reordering disks */
@@ -5337,7 +5337,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 			if (!_eliminate_extracted_lvs(lv->vg, &removal_lvs)) /* Updates vg */
 				return_0;
 
-			return 0;
+			return_0;
 		}
 
 		seg = first_seg(lv);
@@ -5367,11 +5367,11 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 
 			if (!_raid45_to_raid54_wrapper(lv, raid5_n_segtype, 1 /* yes */, force, seg->area_count,
 						       1 /* data_copies */, 0, 0, 0, allocate_pvs))
-				return 0;
+				return_0;
 
 			if (!_drop_suffix(meta_lv->name, "_extracted") ||
 			    !_drop_suffix(data_lv->name, "_extracted"))
-				return 0;
+				return_0;
 
 			data_lv->status |= RAID_IMAGE;
 			meta_lv->status |= RAID_META;
@@ -5386,7 +5386,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		} else if (segtype_is_raid5_n(new_segtype) &&
 			   !_raid45_to_raid54_wrapper(lv, raid5_n_segtype, yes, force, seg->area_count,
 						      1 /* data_copies */, 0, 0, 0, allocate_pvs))
-			return 0;
+			return_0;
 	}
 
 	seg->data_copies = new_data_copies;
@@ -5402,7 +5402,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 
 		log_debug_metadata("Reordering areas for raid0 -> raid10_near takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_to_raid10_near))
-			return 0;
+			return_0;
 		/* Set rebuild flags accordingly */
 		for (s = 0; s < seg->area_count; s++) {
 			seg_lv(seg, s)->status &= ~LV_REBUILD;
@@ -5420,7 +5420,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
-		return 0;
+		return_0;
 
 	if (segtype_is_raid4(new_segtype) &&
 	    seg->area_count != 2) {
@@ -6094,7 +6094,7 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 	}
 
 	if (!_check_region_size_constraints(lv, seg->segtype, region_size, seg->stripe_size))
-		return 0;
+		return_0;
 
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to change region size on %s LV %s while it is not in-sync.",
@@ -6348,12 +6348,12 @@ int lv_raid_convert(struct logical_volume *lv,
 
 		/* https://bugzilla.redhat.com/1447812 reject reshape on open LV */
 		if (!_check_lv_open_count(lv, 0))
-			return 0;
+			return_0;
 		if (!_lv_open_excl(lv, &dev))
-			return 0;
+			return_0;
 		if (!_check_lv_open_count(lv, 1)) {
 			dev_close(dev);
-			return 0;
+			return_0;
 		}
 
 		if (!_raid_reshape(lv, new_segtype, yes, force,
@@ -6377,7 +6377,8 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* Prohibit any takeover in case sub LVs to be removed still exist after a previous reshape */
 	if (!_get_available_removed_sublvs(lv, &available_slvs, &removed_slvs))
-		return 0;
+		return_0;
+
 	if (removed_slvs) {
 		log_error("Can't convert %s LV %s to %s containing sub LVs to remove after a reshape.",
 			  lvseg_name(seg), display_lvname(lv), new_segtype->name);


