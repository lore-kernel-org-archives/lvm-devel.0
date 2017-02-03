From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  3 Feb 2017 19:40:49 +0000 (UTC)
Subject: master - lvconvert: add segtype raid5_n and conversions to/from it
Message-ID: <20170203194049.3F1C360DEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60ddd05f163cbf53670e5c8deabfc384168eae0f
Commit:        60ddd05f163cbf53670e5c8deabfc384168eae0f
Parent:        875ce04c61fb40436bf4d6308356c800d08c1f7e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 3 20:39:40 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 3 20:40:26 2017 +0100

lvconvert: add segtype raid5_n and conversions to/from it

Add:
- support for segment type raid5_n (striped raid with dedicated last parity SubLVs)
- conversion support from striped/raid0/raid0_meta/raid4 to/from raid5_n
- related tests to lvconvert-raid-takeover.sh

Related: rhbz1366296
---
 lib/metadata/merge.c                  |    7 +-
 lib/metadata/raid_manip.c             |  252 +++++++++++++++++++++++----------
 lib/raid/raid.c                       |   15 +-
 libdm/libdm-deptree.c                 |    7 +-
 test/shell/lvconvert-raid-takeover.sh |   63 ++++++++-
 5 files changed, 259 insertions(+), 85 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 59c0885..dbd91db 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -148,7 +148,8 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 {
 	/* Checks applying to any raid4/5/6/10 */
-	if (!seg->meta_areas)
+	/* Allow raid4 + raid5_n to get activated w/o metadata (mandatory during conversion between them) */
+	if (!(seg_is_raid4(seg) || seg_is_raid5_n(seg)) && !seg->meta_areas)
 		raid_seg_error("no meta areas");
 	if (!seg->stripe_size)
 		raid_seg_error("zero stripe size");
@@ -610,7 +611,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				continue;
 			if (lv == seg_lv(seg, s))
 				seg_found++;
-			if (seg_is_raid_with_meta(seg) && (lv == seg_metalv(seg, s)))
+			if (seg->meta_areas && seg_is_raid_with_meta(seg) && (lv == seg_metalv(seg, s)))
 				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8c88280..f845164 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2175,6 +2175,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
+	seg->status |= RAID;
 
 	if (!lv_update_and_reload(lv))
 		return_0;
@@ -2567,44 +2568,22 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	  .possible_types = SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = 1,
 	  .options = ALLOW_STRIPE_SIZE },
-	{ .current_types  = SEG_STRIPED_TARGET, /* striped -> raid0*, i.e. seg->area_count > 1 */
-	  .possible_types = SEG_RAID0|SEG_RAID0_META,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_STRIPED_TARGET, /* striped -> raid4 , i.e. seg->area_count > 1 */
-	  .possible_types = SEG_RAID4,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
 	/* raid0* -> */
 	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
-	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> striped, i.e. seg->area_count > 1 */
-	  .possible_types = SEG_STRIPED_TARGET,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> raid0*, i.e. seg->area_count > 1 */
-	  .possible_types = SEG_RAID0_META|SEG_RAID0,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> raid4, i.e. seg->area_count > 1 */
-	  .possible_types = SEG_RAID4,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
-	/* raid4 -> -> */
-	{ .current_types  = SEG_RAID4, /* raid4 ->striped/raid0*, i.e. seg->area_count > 1 */
-	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
-	/* raid1 -> mirror */
-	{ .current_types  = SEG_RAID1,
-	  .possible_types = SEG_MIRROR,
+
+	/* striped,raid0*,raid4,raid5_n <-> striped,raid0*,raid4,raid5_n */
+	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
-	/* mirror -> raid1 with arbitrary number of legs */
-	{ .current_types  = SEG_MIRROR,
-	  .possible_types = SEG_RAID1,
+
+	/* mirror <-> raid1 with arbitrary number of legs */
+	{ .current_types  = SEG_MIRROR|SEG_RAID1,
+	  .possible_types = SEG_MIRROR|SEG_RAID1,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
@@ -2724,6 +2703,15 @@ static const char *_get_segtype_alias(const struct segment_type *segtype)
 	return "";
 }
 
+/* Return "linear" for striped segtype with 1 area instead of "striped" */
+static const char *_get_segtype_name(const struct segment_type *segtype, unsigned new_image_count)
+{
+	if (!segtype || (segtype_is_striped(segtype) && new_image_count == 1))
+		return "linear";
+
+	return segtype->name;
+}
+
 static int _log_possible_conversion_types(const struct logical_volume *lv, const struct segment_type *new_segtype)
 {
 	unsigned possible_conversions = 0;
@@ -2744,7 +2732,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 
 			log_error("Converting %s from %s%s%s%s is "
 				  "directly possible to the following layout%s:",
-				  display_lvname(lv), lvseg_name(seg),
+				  display_lvname(lv), _get_segtype_name(seg->segtype, seg->area_count),
 				  *alias ? " (same as " : "", alias, *alias ? ")" : "",
 				  possible_conversions > 1 ? "s" : "");
 
@@ -2911,6 +2899,8 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
  * parity device to lv segment area 0 and thus changing MD
  * array roles, detach the MetaLVs and reload as raid0 in
  * order to wipe them then reattach and set back to raid0_meta.
+ *
+ * Same applies to raid4 <-> raid5.
  */
 static int _clear_meta_lvs(struct logical_volume *lv)
 {
@@ -2920,16 +2910,18 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	const struct segment_type *tmp_segtype;
 	struct dm_list meta_lvs;
 	struct lv_list *lvl_array, *lvl;
+	int is_raid4_or_5N = seg_is_raid4(seg) || seg_is_raid5_n(seg);
 
-	/* Reject non-raid0_meta segment types cautiously */
-	if (!seg_is_raid0_meta(seg) ||
-	    !seg->meta_areas)
+	/* Reject non-raid0_meta/raid4/raid5_n segment types cautiously */
+	if (!seg->meta_areas ||
+	    (!seg_is_raid0_meta(seg) && !is_raid4_or_5N))
 		return_0;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
 		return_0;
 
 	dm_list_init(&meta_lvs);
+	tmp_segtype = seg->segtype;
 	tmp_areas = seg->meta_areas;
 
 	/* Extract all MetaLVs listing them on @meta_lvs */
@@ -2940,10 +2932,12 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 
 	/* Memorize meta areas and segtype to set again after initializing. */
 	seg->meta_areas = NULL;
-	tmp_segtype = seg->segtype;
 
-	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0)) ||
-	    !lv_update_and_reload(lv))
+	if (seg_is_raid0_meta(seg) &&
+	    !(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0)))
+		return_0;
+
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	/* Note: detached rmeta are NOT renamed */
@@ -3066,7 +3060,7 @@ static void _shift_area_lvs(struct lv_segment *seg, uint32_t s1, uint32_t s2)
  */
 static int _shift_parity_dev(struct lv_segment *seg)
 {
-	if (seg_is_raid0_meta(seg))
+	if (seg_is_raid0_meta(seg) || seg_is_raid5_n(seg))
 		_shift_area_lvs(seg, seg->area_count - 1, 0);
 	else if (seg_is_raid4(seg))
 		_shift_area_lvs(seg, 0, seg->area_count - 1);
@@ -3082,10 +3076,13 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	int rename_sublvs = 0;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_lvs;
+	uint32_t region_size = seg->region_size;
 
 	dm_list_init(&removal_lvs);
 
-	if (!seg_is_raid4(seg) && !seg_is_raid5_n(seg) && !seg_is_raid6_n_6(seg)) {
+	if (!seg_is_raid4(seg) &&
+	    !seg_is_raid5_n(seg) &&
+	    !seg_is_raid6_n_6(seg)) {
 		log_error("LV %s has to be of type raid4/raid5_n/raid6_n_6 to allow for this conversion.",
 			  display_lvname(lv));
 		return 0;
@@ -3098,7 +3095,7 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
 				  "type losing all resilience? [y/n]: ",
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
-		log_error("Logical volume %s NOT converted to \"%s\".",
+		log_error("Logical volume %s NOT converted to \"%s\"",
 			  display_lvname(lv), new_segtype->name);
 		return 0;
 	}
@@ -3122,22 +3119,23 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 		if (segtype_is_any_raid0(new_segtype) &&
 		    !(rename_sublvs = _rename_area_lvs(lv, "_"))) {
-			log_error("Failed to rename %s LV %s MetaLVs.",
-				  lvseg_name(seg), display_lvname(lv));
+			log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
 			return 0;
 		}
-
 	}
 
 	/* Remove meta and data LVs requested */
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
 		return 0;
 
-	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
-		return_0;
+	/* FIXME Hard-coded raid4/5/6 to striped/raid0 */
+	if (segtype_is_striped_target(new_segtype) || segtype_is_any_raid0(new_segtype)) {
+		seg->area_len = seg->extents_copied = seg->area_len / seg->area_count;
+		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
+			return_0;
 
-	/* FIXME Hard-coded raid4 to raid0 */
-	seg->area_len = seg->extents_copied = seg->area_len / seg->area_count;
+		region_size = 0;
+	}
 
 	if (segtype_is_striped_target(new_segtype)) {
 		if (!_convert_raid0_to_striped(lv, 0, &removal_lvs))
@@ -3146,15 +3144,15 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		   !_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, &removal_lvs))
 		return_0;
 
-	seg->region_size = 0;
+	seg->region_size = region_size;
+	seg->segtype = new_segtype;
 
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
 		return_0;
 
 	if (rename_sublvs) {
 		if (!_rename_area_lvs(lv, NULL)) {
-			log_error("Failed to rename %s LV %s MetaLVs.",
-				  lvseg_name(seg), display_lvname(lv));
+			log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
 			return 0;
 		}
 		if (!lv_update_and_reload(lv))
@@ -3164,6 +3162,79 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	return 1;
 }
 
+/*
+ * raid4 <-> raid5_n helper
+ *
+ * On conversions between raid4 and raid5_n, the parity SubLVs need
+ * to be switched between beginning and end of the segment areas.
+ *
+ * The metadata devices reflect the previous positions within the RaidLV,
+ * thus need to be cleared in order to allow the kernel to start the new
+ * mapping and recreate metadata with the proper new position stored.
+ */
+static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_lvs;
+	uint32_t region_size = seg->region_size;
+
+	dm_list_init(&removal_lvs);
+
+	if (!(seg_is_raid4(seg) && segtype_is_raid5_n(new_segtype)) &&
+	    !(seg_is_raid5_n(seg) && segtype_is_raid4(new_segtype))) {
+		log_error("LV %s has to be of type raid4 or raid5_n to allow for this conversion.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+
+	/* Necessary when convering to raid0/striped w/o redundancy? */
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	log_debug_metadata("Converting LV %s from %s to %s.", display_lvname(lv),
+			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID4 : SEG_TYPE_NAME_RAID5_N),
+			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID5_N : SEG_TYPE_NAME_RAID4));
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	if (!_rename_area_lvs(lv, "_")) {
+		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	if (!_clear_meta_lvs(lv))
+		return_0;
+
+	/* Shift parity SubLV pair "PDD..." <-> "DD...P" on raid4 <-> raid5_n conversion */
+	if( !_shift_parity_dev(seg))
+		return 0;
+
+	/* Don't resync */
+	init_mirror_in_sync(1);
+	seg->region_size = new_region_size ?: region_size;
+	seg->segtype = new_segtype;
+
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
+		return_0;
+
+	init_mirror_in_sync(0);
+
+	if (!_rename_area_lvs(lv, NULL)) {
+		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+	if (!lv_update_and_reload(lv))
+		return_0;
+
+	return 1;
+}
+
 static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     uint32_t new_stripes,
@@ -3188,14 +3259,31 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 /* Helper: striped/raid0* -> raid4/5/6/10 */
 static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 {
+	uint32_t extents_copied, region_size, seg_len, stripe_size;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_lvs;
 
 	dm_list_init(&removal_lvs);
 
+	if (!seg_is_striped_target(seg) &&
+	    !seg_is_any_raid0(seg) &&
+	    !seg_is_raid4(seg) &&
+	    !seg_is_any_raid5(seg)) {
+		log_error("Can't convert %s LV %s.", lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
 	if (seg_is_raid10(seg))
 		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 
+	if (!segtype_is_raid4(new_segtype) &&
+	    !segtype_is_raid5_n(new_segtype) &&
+	    !segtype_is_raid6_n_6(new_segtype)) {
+		/* Can't convert to e.g. raid10_offset */
+		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+
 	if (new_data_copies > new_image_count) {
 		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes.");
 		return 0;
@@ -3206,8 +3294,9 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
-	/* FIXME: restricted to raid4 for the time being... */
-	if (!segtype_is_raid4(new_segtype)) {
+	/* FIXME: restricted to raid4 and raid5_n for the time being... */
+	if (!segtype_is_raid4(new_segtype) &&
+	    !segtype_is_raid5_n(new_segtype)) {
 		/* Can't convert striped/raid0* to e.g. raid10_offset */
 		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
@@ -3219,7 +3308,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	/* This helper can be used to convert from striped/raid0* -> raid10 too */
 	if (seg_is_striped_target(seg)) {
-		log_debug_metadata("Converting LV %s from %s to %s",
+		log_debug_metadata("Converting LV %s from %s to %s.",
 				   display_lvname(lv), SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID0);
 		if (!(seg = _convert_striped_to_raid0(lv, 1 /* alloc_metadata_devs */, 0 /* update_and_reload */, allocate_pvs)))
 			return_0;
@@ -3229,18 +3318,32 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	if (seg_is_raid0(seg)) {
 		log_debug_metadata("Adding metadata LVs to %s.", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
-			return_0;
-	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role cahnge issues in the kernel */
+			return 0;
+	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role change issues in the kernel */
 	} else if (segtype_is_raid4(new_segtype) &&
 		   !_clear_meta_lvs(lv))
 		return_0;
 
+
 	/* Add the additional component LV pairs */
 	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
 			   new_image_count - lv_raid_image_count(lv),
 			   display_lvname(lv));
+	extents_copied = seg->extents_copied;
+	region_size = seg->region_size;
+	seg_len = seg->len;
+	stripe_size = seg->stripe_size;
+
+	if (seg_is_raid4(seg) || seg_is_any_raid5(seg)) {
+		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
+			return_0;
+		seg->area_len = seg_lv(seg, 0)->le_count;
+		lv->le_count = seg->len = seg->area_len * seg->area_count;
+		seg->extents_copied = seg->region_size = 0;
+	}
+
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
-		return_0;
+		return 0;
 
 	if (segtype_is_raid4(new_segtype) &&
 	    (!_shift_parity_dev(seg) ||
@@ -3250,9 +3353,12 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	seg->segtype = new_segtype;
-	seg->region_size = new_region_size;
-	/* FIXME Hard-coded raid0 to raid4 */
-	seg->area_len = seg->len;
+	seg->region_size = new_region_size ?: region_size;
+
+	/* FIXME Hard-coded raid0 to raid4/5/6 */
+	seg->stripe_size = stripe_size;
+	lv->le_count = seg->len = seg->area_len = seg_len;
+	seg->extents_copied = extents_copied;
 
 	_check_and_adjust_region_size(lv);
 
@@ -3262,7 +3368,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return_0;
 
 	if (segtype_is_raid4(new_segtype)) {
-		/* We had to rename SubLVs because of collision free sgifting, rename back... */
+		/* We had to rename SubLVs because of collision free shifting, rename back... */
 		if (!_rename_area_lvs(lv, NULL))
 			return_0;
 		if (!lv_update_and_reload(lv))
@@ -3352,7 +3458,9 @@ static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1, 1 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 1 /* new_image_count */,
+						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
@@ -3398,7 +3506,9 @@ static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1, 1 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 1 /* new_image_count */,
+						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
@@ -3481,7 +3591,7 @@ static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid45_to_raid54_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count, 2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
@@ -3679,14 +3789,10 @@ static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
 			return 0;
 		}
 
-	/* Got to do check for raid5 -> raid6 ... */
-	} else if (seg_is_any_raid5(seg_from) &&
-		   segtype_is_any_raid6(*segtype)) {
-		log_error("Conversion not supported.");
-		return 0;
-
 	/* ... and raid6 -> raid5 */
-	} else if (seg_is_any_raid6(seg_from) &&
+	} else if ((seg_is_raid6_zr(seg_from) ||
+		    seg_is_raid6_nr(seg_from) ||
+		    seg_is_raid6_nc(seg_from)) &&
 		   segtype_is_any_raid5(*segtype)) {
 		log_error("Conversion not supported.");
 		return 0;
@@ -3927,7 +4033,7 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	const char *action_str = rebuild ? "rebuild" : "replace";
 
 	if (seg_is_any_raid0(raid_seg)) {
-		log_error("Can't replace any devices in %s LV %s",
+		log_error("Can't replace any devices in %s LV %s.",
 			  lvseg_name(raid_seg), display_lvname(lv));
 		return 0;
 	}
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 1e562ff..7dfafef 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -87,13 +87,13 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 		}
 
 		/* Metadata device comes first. */
-		if (!seg_is_raid0(seg)) {
-			if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
-				log_error("Couldn't find volume '%s' for segment '%s'.",
-					  cv->v.str ? : "NULL", seg_name);
-				return 0;
-			}
+		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
+			log_error("Couldn't find volume '%s' for segment '%s'.",
+				  cv->v.str ? : "NULL", seg_name);
+			return 0;
+		}
 
+		if (strstr(lv->name, "_rmeta_")) {
 			if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_META))
 				return_0;
 			cv = cv->next;
@@ -537,6 +537,7 @@ static const struct raid_type {
 	{ SEG_TYPE_NAME_RAID10,     0, SEG_RAID10 | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID4,      1, SEG_RAID4 },
 	{ SEG_TYPE_NAME_RAID5,      1, SEG_RAID5 },
+	{ SEG_TYPE_NAME_RAID5_N,    1, SEG_RAID5_N },
 	{ SEG_TYPE_NAME_RAID5_LA,   1, SEG_RAID5_LA },
 	{ SEG_TYPE_NAME_RAID5_LS,   1, SEG_RAID5_LS },
 	{ SEG_TYPE_NAME_RAID5_RA,   1, SEG_RAID5_RA },
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index c5226a7..8a32320 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -47,6 +47,7 @@ enum {
 	SEG_RAID1,
 	SEG_RAID10,
 	SEG_RAID4,
+	SEG_RAID5_N,
 	SEG_RAID5_LA,
 	SEG_RAID5_RA,
 	SEG_RAID5_LS,
@@ -81,6 +82,7 @@ static const struct {
 	{ SEG_RAID1, "raid1"},
 	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
+	{ SEG_RAID5_N,  "raid5_n"},
 	{ SEG_RAID5_LA, "raid5_la"},
 	{ SEG_RAID5_RA, "raid5_ra"},
 	{ SEG_RAID5_LS, "raid5_ls"},
@@ -2140,6 +2142,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 		case SEG_RAID1:
 		case SEG_RAID10:
 		case SEG_RAID4:
+		case SEG_RAID5_N:
 		case SEG_RAID5_LA:
 		case SEG_RAID5_RA:
 		case SEG_RAID5_LS:
@@ -2588,6 +2591,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_RAID1:
 	case SEG_RAID10:
 	case SEG_RAID4:
+	case SEG_RAID5_N:
 	case SEG_RAID5_LA:
 	case SEG_RAID5_RA:
 	case SEG_RAID5_LS:
@@ -3869,6 +3873,7 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 	case SEG_RAID0_META:
 	case SEG_RAID1:
 	case SEG_RAID4:
+	case SEG_RAID5_N:
 	case SEG_RAID5_LA:
 	case SEG_RAID5_RA:
 	case SEG_RAID5_LS:
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index c1cb1aa..0b7d326 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2016,2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -120,6 +120,7 @@ check lv_field $vg/$lv4 segtype "striped"
 check lv_field $vg/$lv4 stripes 3
 fsck -fn  /dev/mapper/$vg-$lv4
 
+
 # Convert striped -> raid4
 lvconvert -y --ty raid4 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid4"
@@ -128,6 +129,37 @@ fsck -fn  /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 
+# Convert raid4 -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid5 -> striped
+lvconvert -y --ty striped $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert striped -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid5_n -> raid4
+lvconvert -y --ty raid4 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid4"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+
 # Convert raid0 -> raid4
 lvconvert -y --ty raid4 $vg/$lv2
 check lv_field $vg/$lv2 segtype "raid4"
@@ -136,6 +168,35 @@ fsck -fn  /dev/mapper/$vg-$lv2
 aux wait_for_sync $vg $lv2
 fsck -fn  /dev/mapper/$vg-$lv2
 
+# Convert raid4 -> raid0
+lvconvert -y --ty raid0 $vg/$lv2
+check lv_field $vg/$lv2 segtype "raid0"
+check lv_field $vg/$lv2 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv2
+
+# Convert raid0 -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv2
+check lv_field $vg/$lv2 segtype "raid5_n"
+check lv_field $vg/$lv2 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv2
+aux wait_for_sync $vg $lv2
+fsck -fn  /dev/mapper/$vg-$lv2
+
+# Convert raid5_n -> raid0_meta
+lvconvert -y --ty raid0_meta $vg/$lv2
+check lv_field $vg/$lv2 segtype "raid0_meta"
+check lv_field $vg/$lv2 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv2
+
+# Convert raid0_meta -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv2
+check lv_field $vg/$lv2 segtype "raid5_n"
+check lv_field $vg/$lv2 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv2
+aux wait_for_sync $vg $lv2
+fsck -fn  /dev/mapper/$vg-$lv2
+
+
 # Convert raid4 -> raid0_meta
 lvconvert -y --ty raid0_meta $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid0_meta"


