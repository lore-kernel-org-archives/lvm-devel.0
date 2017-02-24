From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:19 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063219.BCCAB60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34a8d3c2fdc9da2bb1974781070d01f901862b9a
Commit:        34a8d3c2fdc9da2bb1974781070d01f901862b9a
Parent:        932db3db535734f03cec973182dcc73adef9d3a5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 03:37:12 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- enhance _raid45610_to_raid0_or_striped_wrapper() to support
  raid5_n with 2 areas to raid1 conversion to allow for
  striped/raid0(_meta)/raid4/5/6 -> raid1/linear conversions;
  rename it to _takeover_downconvert_wrapper to discontinue the
  illegible function name
- enhance _striped_or_raid0_to_raid45610_wrapper()  to support
  raid1 with 2 areas to raid5* conversions to allow for
  linear/raid1 -> striped/raid0(_meta)/raid4/5/6 conversions;
  rename it to _takeover_upconvert_wrapper for the same reason

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |  258 ++++++++++++++++++++++++++++++++-------------
 1 files changed, 183 insertions(+), 75 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 81360d2..2b5559a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4748,14 +4748,14 @@ static int _shift_parity_dev(struct lv_segment *seg)
 	return 1;
 }
 
-/* raid456 -> raid0* / striped */
+/* raid45610 -> raid0* / stripe, raid5_n -> raid4 */
 static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS);
-static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
+static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 {
 	int rename_sublvs = 0;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_lvs;
-	uint32_t region_size = seg->region_size;
+	char res_str[30];
 
 	dm_list_init(&removal_lvs);
 
@@ -4766,10 +4766,35 @@ static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
-	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
-				  "type losing %s resilience? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv), new_segtype->name,
-				  segtype_is_striped(new_segtype) ? "all" : "some") == 'n') {
+	if (seg_is_any_raid10(seg) && (seg->area_count % seg->data_copies)) {
+		log_error("Can't convert %s LV %s to %s with odd number of stripes.",
+			  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+
+	if (seg_is_any_raid5(seg) &&
+	    segtype_is_raid1(new_segtype)) {
+		if (seg->area_count != 2) {
+			log_error("Can't convert %s LV %s to %s with != 2 legs.",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+			return 0;
+		}
+		if (seg->area_count != new_image_count) {
+			log_error(INTERNAL_ERROR "Bogus new_image_count converting %s LV %s to %s.",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+			return 0;
+		}
+	}
+
+	if (seg->area_count > 2) {
+		if (dm_snprintf(res_str, sizeof(res_str), " losing %s resilience",
+				segtype_is_striped(new_segtype) ? "all" : "some") < 0)
+			return_0;
+	} else
+		*res_str = '\0';
+
+	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" type%s? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name, res_str) == 'n') {
 		log_error("Logical volume %s NOT converted to \"%s\"",
 			  display_lvname(lv), new_segtype->name);
 		return 0;
@@ -4779,6 +4804,9 @@ static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	if (!archive(lv->vg))
 		return_0;
 
+	if (!_lv_free_reshape_space(lv))
+		return_0;
+
 	/*
 	 * raid4 (which actually gets mapped to raid5/dedicated first parity disk)
 	 * needs shifting of SubLVs to move the parity SubLV pair in the first area
@@ -4790,28 +4818,35 @@ static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		if (!_shift_parity_dev(seg))
 			return 0;
 
-		if (segtype_is_any_raid0(new_segtype) &&
-		    !(rename_sublvs = _rename_area_lvs(lv, "_"))) {
-			log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
-			return 0;
-		}
 	} else if (seg_is_raid10_near(seg)) {
-		log_debug_metadata("Reordering areas for raid10 -> raid0 takeover");
+		log_debug_metadata("Reordering areas for raid10 -> raid0 takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_from_raid10_near))
 			return 0;
 	}
 
-	/* Remove meta and data LVs requested */
-	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
+	if (segtype_is_any_raid0(new_segtype) &&
+	    !(rename_sublvs = _rename_area_lvs(lv, "_"))) {
+		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
 		return 0;
+	}
+
+	/* Remove meta and data LVs requested */
+	if (new_image_count != seg->area_count) {
+		log_debug_metadata("Removing %" PRIu32 " component LV pair(s) to %s.",
+				   lv_raid_image_count(lv) - new_image_count,
+				   display_lvname(lv));
+		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
+			return 0;
+
+		seg->area_count = new_image_count;
+	}
 
 	/* FIXME Hard-coded raid4/5/6 to striped/raid0 */
 	if (segtype_is_striped_target(new_segtype) || segtype_is_any_raid0(new_segtype)) {
-		seg->area_len = seg->extents_copied = seg->area_len / seg->area_count;
+		seg->area_len = seg->extents_copied = seg->len / seg->area_count;
+		seg->region_size = 0;
 		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
 			return_0;
-
-		region_size = 0;
 	}
 
 	if (segtype_is_striped_target(new_segtype)) {
@@ -4827,12 +4862,18 @@ static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	} else
 		seg->segtype = new_segtype;
 
-	seg->region_size = new_region_size ?: region_size;
+	if (seg_is_raid1(seg))
+		seg->stripe_size = 0;
 
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 		return_0;
 
 	if (rename_sublvs) {
+		/* Got to clear the meta lvs from raid10 content to be able to convert to e.g. raid6 */
+		if (segtype_is_raid0_meta(new_segtype) &&
+		    !_clear_meta_lvs(lv))
+			return_0;
+
 		if (!_rename_area_lvs(lv, NULL)) {
 			log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
 			return 0;
@@ -4942,8 +4983,8 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 	return 1;
 }
 
-/* Helper: striped/raid0* -> raid4/5/6/10, raid45 -> raid6 wrapper */
-static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
+/* Helper: striped/raid0/raid0_meta/raid1 -> raid4/5/6/10, raid45 -> raid6 wrapper */
+static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 {
 	uint32_t extents_copied, region_size, seg_len, stripe_size;
 	struct lv_segment *seg = first_seg(lv);
@@ -4961,10 +5002,40 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	if (seg_is_any_raid5(seg) && segtype_is_any_raid6(new_segtype) && seg->area_count < 4) {
+		log_error("Minimum of 3 stripes needed for conversion from %s to %s.",
+			  lvseg_name(seg), new_segtype->name);
+		return 0;
+	}
+
+	if (seg_is_raid1(seg)) {
+		if (seg->area_count != 2) {
+			log_error("Can't convert %s LV %s to %s with != 2 legs.",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+			return 0;
+		}
+		if (!segtype_is_any_raid5(new_segtype)) {
+			log_error("Can't convert %s LV %s to %s.",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+			return 0;
+		}
+		if (seg->area_count != new_image_count) {
+			log_error(INTERNAL_ERROR "Bogus new_image_count converting %s LV %s to %s.",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+			return 0;
+		}
+
+		if (!new_stripe_size)
+			new_stripe_size = 128;
+	}
+
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
 
+	if (!_lv_free_reshape_space(lv))
+		return_0;
+
 	/* This helper can be used to convert from striped/raid0* -> raid10 too */
 	if (seg_is_striped_target(seg)) {
 		log_debug_metadata("Converting LV %s from %s to %s.",
@@ -4979,15 +5050,14 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
 			return 0;
 	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role change issues in the kernel */
-	} else if (segtype_is_raid4(new_segtype) &&
-		   !_clear_meta_lvs(lv))
+	}
+
+	if (seg_is_raid0_meta(seg) &&
+	    segtype_is_raid4(new_segtype) &&
+	    !_clear_meta_lvs(lv))
 		return_0;
 
 
-	/* Add the additional component LV pairs */
-	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
-			   new_image_count - lv_raid_image_count(lv),
-			   display_lvname(lv));
 	extents_copied = seg->extents_copied;
 	region_size = seg->region_size;
 	seg_len = seg->len;
@@ -4998,11 +5068,21 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 			return_0;
 		seg->area_len = seg_lv(seg, 0)->le_count;
 		lv->le_count = seg->len = seg->area_len * seg->area_count;
+		seg->area_len = seg->len;
 		seg->extents_copied = seg->region_size = 0;
 	}
 
-	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
-		return 0;
+	/* Add the additional component LV pairs */
+	if (new_image_count != seg->area_count) {
+		log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
+				   new_image_count - lv_raid_image_count(lv),
+				   display_lvname(lv));
+		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
+			return 0;
+
+		seg = first_seg(lv);
+	}
+
 
 	if (segtype_is_raid4(new_segtype) &&
 	    (!_shift_parity_dev(seg) ||
@@ -5010,25 +5090,40 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
 	} else if (segtype_is_raid10_near(new_segtype)) {
-		log_debug_metadata("Reordering areas for raid0 -> raid10 takeover");
+		uint32_t s;
+
+		/* FIXME: raid10 ; needs to change once more than 2 data copies! */
+		seg->data_copies = 2;
+
+		log_debug_metadata("Reordering areas for raid0 -> raid10 takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_to_raid10_near))
 			return 0;
+		/* Set rebuild flags accordingly */
+		for (s = 0; s < seg->area_count; s++) {
+			seg_lv(seg, s)->status &= ~LV_REBUILD;
+			seg_metalv(seg, s)->status &= ~LV_REBUILD;
+			if (s % seg->data_copies)
+				seg_lv(seg, s)->status |= LV_REBUILD;
+		}
+
 	}
 
 	seg->segtype = new_segtype;
 	seg->region_size = new_region_size ?: region_size;
+	seg->stripe_size = new_stripe_size ?: stripe_size;
+	seg->extents_copied = extents_copied;
 
-	/* FIXME Hard-coded raid0 to raid4/5/6 */
-	seg->stripe_size = stripe_size;
+	/* FIXME Hard-coded to raid4/5/6/10 */
 	lv->le_count = seg->len = seg->area_len = seg_len;
-	seg->extents_copied = extents_copied;
 
 	_check_and_adjust_region_size(lv);
 
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, NULL, NULL))
-		return_0;
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
+						       _post_raid_dummy, NULL,
+						       _pre_raid_add_legs, NULL))
+		return 0;
 
 	if (segtype_is_raid4(new_segtype)) {
 		/* We had to rename SubLVs because of collision free shifting, rename back... */
@@ -5118,23 +5213,23 @@ static int _takeover_from_raid0_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count * 2 /* new_image_count */,
-						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count * 2 /* new_image_count */,
+					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count + 1 /* new_image_count */,
-						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count + 1 /* new_image_count */,
+					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count + 2 /* new_image_count */,
-						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count + 2 /* new_image_count */,
+					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
@@ -5170,21 +5265,21 @@ static int _takeover_from_raid0_meta_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count * 2 /* new_image_count */,
 						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count + 1 /* new_image_count */,
 						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count + 2 /* new_image_count */,
 						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
@@ -5249,12 +5344,16 @@ static int _takeover_from_raid45_to_mirrored(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 1,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 1,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
@@ -5278,38 +5377,44 @@ static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 					       1 /* data_copies */, 0, 0, 0, allocate_pvs))
 			return 0;
 	}
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count + 1 /* new_image_count */,
-						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count + 1 /* new_image_count */,
+					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 1,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
-						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 2,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
-						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 2,
+					    1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1,
-						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 1,
+					    2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
-						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count - 2,
+					     2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
@@ -5335,22 +5440,22 @@ static int _takeover_from_striped_to_raid0_meta(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count * 2 /* new_image_count */,
-						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count * 2 /* new_image_count */,
+					   2 /* FIXME: variable data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1,
-						      2 /* data_copies*/, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1,
+					   2 /* data_copies*/, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
-						      first_seg(lv)->area_count + 2 /* new_image_count */,
-						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count + 2 /* new_image_count */,
+					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 /*
@@ -5384,8 +5489,9 @@ static int _takeover_from_raid10_to_mirrored(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid10_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
-						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count / first_seg(lv)->data_copies,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 /*
@@ -5398,8 +5504,9 @@ static int _takeover_from_raid10_to_raid01(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid10_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
-						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count / first_seg(lv)->data_copies,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid10_to_raid1(TAKEOVER_FN_ARGS)
@@ -5418,8 +5525,9 @@ static int _takeover_from_raid10_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid10_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
-						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count / first_seg(lv)->data_copies,
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 /*


