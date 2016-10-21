From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 21 Oct 2016 17:00:46 +0000 (UTC)
Subject: master - lvconvert: position dedicated parity device in raid4 conversions porperly
Message-ID: <20161021170046.1E63A60730@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de78e8eae73cb155fdb906ef2b8ddc9ca1a918c4
Commit:        de78e8eae73cb155fdb906ef2b8ddc9ca1a918c4
Parent:        34da83d729436d245e91e24e30b6996862fe7725
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Oct 21 18:59:59 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Oct 21 19:00:31 2016 +0200

lvconvert: position dedicated parity device in raid4 conversions porperly

On conversions between striped/raid0* and raid4, the kernel expects
the dedicated raid4 parity SubLVs in the first segment area rather than
in the last it's been allocated to, thus the data mapping ain't proper.

Enhance lvconvert (lib/metadata/raid_manip.c) to shift the dedicated
parity SubLVs on conversions from striped/raid0* to raid4 and vice-versa.

In case of raid0_meta -> raid4 where the MD raid0 personality already has
stored RAID array device positions in the superblocks, the MetaLVs have to
be cleared so that the kernel doesn't fail validating the array positions
after lvm has shifted them up by one.

Add more tests to lvconvert-raid-takeover.sh including one to check for
mapping flaws by converting a created raid4 with filesystem -> striped
and fsck it.

Whilst on it:
- add missing direct striped -> raid4 conversion to the takeover array
  to avoid an intermim conversion from striped -> raid0*
- clean up the takeover array
- allow lvconvert to actually call lv_raid_convert() on all takeover requests
  in order to check parameters and display messages provided by takeover
  functions rather than just "...not supported" from within lvconvert
- fix a typo

Resolves: rhbz1386148
---
 WHATS_NEW                             |    2 +
 lib/metadata/raid_manip.c             |  277 ++++++++++++++++++++++++++++++---
 test/shell/lvconvert-raid-takeover.sh |   53 ++++++-
 tools/lvconvert.c                     |   24 +--
 4 files changed, 314 insertions(+), 42 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4138685..3a8e006 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.167 - 
 ======================================
+  Add direct striped -> raid4 conversion
+  Fix raid4 parity image pair position on conversions from striped/raid0*
   Fix a few unconverted return code values for some lvconvert error path.
   Disable lvconvert of thin pool to raid while active.
   Disable systemd service start rate limiting for lvm2-pvscan at .service.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e87a4e5..39d27f1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2459,7 +2459,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 					   0 /* chunk_size */,
 					   0 /* seg->region_size */, 0u /* extents_copied */ ,
 					   NULL /* pvmove_source_seg */))) {
-		log_error("Failed to allocate new raid0 segement for LV %s.", display_lvname(lv));
+		log_error("Failed to allocate new raid0 segment for LV %s.", display_lvname(lv));
 		return NULL;
 	}
 
@@ -2519,42 +2519,51 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
-	  .options = ALLOW_NONE },
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
 	  .possible_types = SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = 1,
 	  .options = ALLOW_STRIPE_SIZE },
-	{ .current_types  = SEG_STRIPED_TARGET, /* striped, i.e. seg->area_count > 1 */
+	{ .current_types  = SEG_STRIPED_TARGET, /* striped -> raid0*, i.e. seg->area_count > 1 */
 	  .possible_types = SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
+	{ .current_types  = SEG_STRIPED_TARGET, /* striped -> raid4 , i.e. seg->area_count > 1 */
+	  .possible_types = SEG_RAID4,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 	/* raid0* -> */
 	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> striped, i.e. seg->area_count > 1 */
+	  .possible_types = SEG_STRIPED_TARGET,
+	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count > 1 */
-	  .possible_types = SEG_RAID4,
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> raid0*, i.e. seg->area_count > 1 */
+	  .possible_types = SEG_RAID0_META|SEG_RAID0,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0 striped, i.e. seg->area_count > 0 */
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0* -> raid4, i.e. seg->area_count > 1 */
+	  .possible_types = SEG_RAID4,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	/* raid4 -> -> */
+	{ .current_types  = SEG_RAID4, /* raid4 ->striped/raid0*, i.e. seg->area_count > 1 */
 	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
-	/* raid1 -> */
+	/* raid1 -> mirror */
 	{ .current_types  = SEG_RAID1,
-	  .possible_types = SEG_RAID1|SEG_MIRROR,
+	  .possible_types = SEG_MIRROR,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 	/* mirror -> raid1 with arbitrary number of legs */
 	{ .current_types  = SEG_MIRROR,
-	  .possible_types = SEG_MIRROR|SEG_RAID1,
-	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
-	{ .current_types  = SEG_RAID4,
-	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
+	  .possible_types = SEG_RAID1,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
 	/* END */
 	{ .current_types  = 0 }
@@ -2861,9 +2870,176 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
 					allocate_pvs, 1, &removal_lvs);
 }
 
+/*
+ * HM Helper: (raid0_meta -> raid4)
+ *
+ * To convert raid0_meta to raid4, which involves shifting the
+ * parity device to lv segment area 0 and thus changing MD
+ * array roles, detach the MetaLVs and reload as raid0 in
+ * order to wipe them then reattach and set back to raid0_meta.
+ */
+static int _clear_meta_lvs(struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment_area *tmp_areas;
+	const struct segment_type *tmp_segtype;
+	struct dm_list meta_lvs;
+	struct lv_list *lvl_array, *lvl;
+
+	/* Reject non-raid0_meta segment types cautiously */
+	if (!seg_is_raid0_meta(seg) ||
+	    !seg->meta_areas)
+		return_0;
+
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
+		return_0;
+
+	dm_list_init(&meta_lvs);
+	tmp_areas = seg->meta_areas;
+
+	/* Extract all MetaLVs listing them on @meta_lvs */
+	log_debug_metadata("Extracting all MetaLVs of %s to activate as raid0",
+			   display_lvname(lv));
+	if (!_extract_image_component_sublist(seg, RAID_META, 0, seg->area_count, &meta_lvs, 0))
+		return_0;
+
+	/* Memorize meta areas and segtype to set again after initializing. */
+	seg->meta_areas = NULL;
+	tmp_segtype = seg->segtype;
+
+	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0)) ||
+	    !lv_update_and_reload(lv))
+		return_0;
+
+	/*
+	 * Now deactivate the MetaLVs before clearing, so
+	 * that _clear_lvs() will activate them visible.
+	 */
+	log_debug_metadata("Deactivating pulled out MetaLVs of %s before initializing.",
+			   display_lvname(lv));
+	dm_list_iterate_items(lvl, &meta_lvs)
+		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
+			return_0;
+
+	log_debug_metadata("Clearing allocated raid0_meta metadata LVs for conversion to raid4");
+	if (!_clear_lvs(&meta_lvs)) {
+		log_error("Failed to initialize metadata LVs");
+		return 0;
+	}
+
+	/* Set memorized meta areas and raid0_meta segtype */
+	seg->meta_areas = tmp_areas;
+	seg->segtype = tmp_segtype;
+
+	log_debug_metadata("Adding metadata LVs back into %s", display_lvname(lv));
+	s = 0;
+	dm_list_iterate_items(lvl, &meta_lvs) {
+		lv_set_hidden(lvl->lv);
+		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0, RAID_META))
+			return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * HM Helper: (raid0* <-> raid4)
+ *
+ * Rename SubLVs (pairs) allowing to shift names w/o collisions with active ones.
+ */
+#define	SLV_COUNT	2
+static int _rename_area_lvs(struct logical_volume *lv, const char *suffix)
+{
+	uint32_t s;
+	size_t sz = strlen("rimage") + (suffix ? strlen(suffix) : 0) + 1;
+	char *sfx[SLV_COUNT] = { NULL, NULL };
+	struct lv_segment *seg = first_seg(lv);
+
+	/* Create _generate_raid_name() suffixes w/ or w/o passed in @suffix */
+	for (s = 0; s < SLV_COUNT; s++)
+		if (!(sfx[s] = dm_pool_alloc(lv->vg->cmd->mem, sz)) ||
+		    dm_snprintf(sfx[s], sz, suffix ? "%s%s" : "%s", s ? "rmeta" : "rimage", suffix) < 0)
+			return_0;
+
+	/* Change names (temporarily) to be able to shift numerical name suffixes */
+	for (s = 0; s < seg->area_count; s++) {
+		if (!(seg_lv(seg, s)->name = _generate_raid_name(lv, sfx[0], s)))
+			return_0;
+		if (seg->meta_areas &&
+		    !(seg_metalv(seg, s)->name = _generate_raid_name(lv, sfx[1], s)))
+			return_0;
+	}
+
+	for (s = 0; s < SLV_COUNT; s++)
+		dm_pool_free(lv->vg->cmd->mem, sfx[s]);
+
+	return 1;
+}
+
+/*
+ * HM Helper: (raid0* <-> raid4)
+ *
+ * Switch area LVs in lv segment @seg indexed by @s1 and @s2
+ */
+static void _switch_area_lvs(struct lv_segment *seg, uint32_t s1, uint32_t s2)
+{
+	struct logical_volume *lvt;
+
+	lvt = seg_lv(seg, s1);
+	seg_lv(seg, s1) = seg_lv(seg, s2);
+	seg_lv(seg, s2) = lvt;
+
+	/* Be cautious */
+	if (seg->meta_areas) {
+		lvt = seg_metalv(seg, s1);
+		seg_metalv(seg, s1) = seg_metalv(seg, s2);
+		seg_metalv(seg, s2) = lvt;
+	}
+}
+
+/*
+ * HM Helper:
+ *
+ * shift range of area LVs in @seg in range [ @s1, @s2 ] up if @s1 < @s2,
+ * else down  bubbling the parity SubLVs up/down whilst shifting.
+ */
+static void _shift_area_lvs(struct lv_segment *seg, uint32_t s1, uint32_t s2)
+{
+	uint32_t s;
+
+	if (s1 < s2)
+		/* Forward shift n+1 -> n */
+		for (s = s1; s < s2; s++)
+			_switch_area_lvs(seg, s, s + 1);
+	else
+		/* Reverse shift n-1 -> n */
+		for (s = s1; s > s2; s--)
+			_switch_area_lvs(seg, s, s - 1);
+}
+
+/*
+ * Switch position of first and last area lv within
+ * @lv to move parity SubLVs from end to end.
+ *
+ * Direction depends on segment type raid4 / raid0_meta.
+ */
+static int _shift_parity_dev(struct lv_segment *seg)
+{
+	if (seg_is_raid0_meta(seg))
+		_shift_area_lvs(seg, seg->area_count - 1, 0);
+	else if (seg_is_raid4(seg))
+		_shift_area_lvs(seg, 0, seg->area_count - 1);
+	else
+		return 0;
+
+	return 1;
+}
+
 /* raid45 -> raid0* / striped */
 static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 {
+	int rename_sublvs = 0;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_lvs;
 
@@ -2879,10 +3055,39 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	if (!_raid_in_sync(lv))
 		return 0;
 
+	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
+				  "type using all resilience? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
+		log_error("Logical volume %s NOT converted to \"%s\"",
+			  display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+	if (sigint_caught())
+		return_0;
+
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
 
+	/*
+	 * raid4 (which actually gets mapped to raid5/dedicated first parity disk)
+	 * needs shifting of SubLVs to move the parity SubLV pair in the first area
+	 * to the last one before conversion to raid0[_meta]/striped to allow for
+	 * SubLV removal from the end of the areas arrays.
+	 */
+	if (seg_is_raid4(seg)) {
+		/* Shift parity SubLV pair "PDD..." -> "DD...P" to be able to remove it off the end */
+		if (!_shift_parity_dev(seg))
+			return 0;
+
+		if (segtype_is_any_raid0(new_segtype) &&
+		    !(rename_sublvs = _rename_area_lvs(lv, "_"))) {
+			log_error("Failed to rename %s LV %s MetaLVs", lvseg_name(seg), display_lvname(lv));
+			return 0;
+		}
+
+	}
+
 	/* Remove meta and data LVs requested */
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
 		return 0;
@@ -2902,7 +3107,19 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 	seg->region_size = 0;
 
-	return _lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs);
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
+		return_0;
+
+	if (rename_sublvs) {
+		if (!_rename_area_lvs(lv, NULL)) {
+			log_error("Failed to rename %s LV %s MetaLVs", lvseg_name(seg), display_lvname(lv));
+			return 0;
+		}
+		if (!lv_update_and_reload(lv))
+			return_0;
+	}
+
+	return 1;
 }
 
 static int _striped_to_raid0_wrapper(struct logical_volume *lv,
@@ -2930,6 +3147,9 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 {
 	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
 
 	if (seg_is_raid10(seg))
 		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
@@ -2944,6 +3164,13 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	/* FIXME: restricted to raid4 for the time being... */
+	if (!segtype_is_raid4(new_segtype)) {
+		/* Can't convert striped/raid0* to e.g. raid10_offset */
+		log_error("Can't convert %s to %s", display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
@@ -2961,7 +3188,10 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		log_debug_metadata("Adding metadata LVs to %s", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
 			return 0;
-	}
+	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role cahnge issues in the kernel */
+	} else if (segtype_is_raid4(new_segtype) &&
+		   !_clear_meta_lvs(lv))
+		return 0;
 
 	/* Add the additional component LV pairs */
 	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s", new_image_count - lv_raid_image_count(lv),
@@ -2969,8 +3199,9 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
 		return 0;
 
-	if (!segtype_is_raid4(new_segtype)) {
-		/* Can't convert striped/raid0* to e.g. raid10_offset */
+	if (segtype_is_raid4(new_segtype) &&
+	    (!_shift_parity_dev(seg) ||
+	     !_rename_area_lvs(lv, "_"))) {
 		log_error("Can't convert %s to %s", display_lvname(lv), new_segtype->name);
 		return 0;
 	}
@@ -2987,6 +3218,14 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, NULL))
 		return_0;
 
+	if (segtype_is_raid4(new_segtype)) {
+		/* We had to rename SubLVs because of collision free sgifting, rename back... */
+		if (!_rename_area_lvs(lv, NULL))
+			return 0;
+		if (!lv_update_and_reload(lv))
+			return_0;
+	}
+
 	return 1;
 }
 
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 19a65d3..0140e22 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -78,22 +78,58 @@ aux wait_for_sync $vg $lv1
 # Clean up
 lvremove --yes $vg/$lv1
 
-# Create 3-way raid0
-lvcreate -y -aey --type raid0 -i 3 -L 64M -n $lv1 $vg
-check lv_field $vg/$lv1 segtype "raid0"
+# Create 3-way striped
+lvcreate -y -aey --type striped -i 3 -L 64M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "striped"
 check lv_field $vg/$lv1 stripes 3
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 
-# Convert raid0 -> raid4
+# Create 3-way raid0
+lvcreate -y -aey --type raid0 -i 3 -L 64M -n $lv2 $vg
+check lv_field $vg/$lv2 segtype "raid0"
+check lv_field $vg/$lv2 stripes 3
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv2
+fsck -fn  /dev/mapper/$vg-$lv2
+
+# Create 3-way raid0_meta
+lvcreate -y -aey --type raid0_meta -i 3 -L 64M -n $lv3 $vg
+check lv_field $vg/$lv3 segtype "raid0_meta"
+check lv_field $vg/$lv3 stripes 3
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv3
+fsck -fn  /dev/mapper/$vg-$lv3
+
+# Create 3-way raid4
+lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg
+check lv_field $vg/$lv4 segtype "raid4"
+check lv_field $vg/$lv4 stripes 4
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv4
+fsck -fn  /dev/mapper/$vg-$lv4
+aux wait_for_sync $vg $lv4
+fsck -fn  /dev/mapper/$vg-$lv4
+
+# Convert raid4 -> striped (correct raid4 mapping test!)
+lvconvert -y --ty striped $vg/$lv4
+check lv_field $vg/$lv4 segtype "striped"
+check lv_field $vg/$lv4 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv4
+
+# Convert striped -> raid4
 lvconvert -y --ty raid4 $vg/$lv1
-lvchange --refresh $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid4"
 check lv_field $vg/$lv1 stripes 4
 fsck -fn  /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 
+# Convert raid0 -> raid4
+lvconvert -y --ty raid4 $vg/$lv2
+check lv_field $vg/$lv2 segtype "raid4"
+check lv_field $vg/$lv2 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv2
+aux wait_for_sync $vg $lv2
+fsck -fn  /dev/mapper/$vg-$lv2
+
 # Convert raid4 -> raid0_meta
 lvconvert -y --ty raid0_meta $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid0_meta"
@@ -116,11 +152,16 @@ fsck -fn  /dev/mapper/$vg-$lv1
 
 # Convert raid0 -> raid4
 lvconvert -y --ty raid4 $vg/$lv1
-lvchange --refresh $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid4"
 check lv_field $vg/$lv1 stripes 4
 fsck -fn  /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 
+# Convert raid4 -> striped
+lvconvert -y --ty striped $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 772c268..1fbe1ea 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1937,7 +1937,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!lp->repair && !lp->replace && (!*lp->type_str || seg->segtype == lp->segtype)) {
+	} else if (!lp->repair && !lp->replace && !*lp->type_str) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
@@ -2005,28 +2005,18 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 1;
 	}
 
-
 try_new_takeover_or_reshape:
-
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
 
-	/* Only let raid4 through for now. */
-	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
-	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
-	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
-		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     lp->region_size, lp->pvh))
-			return_0;
-
-		log_print_unless_silent("Logical volume %s successfully converted.",
-					display_lvname(lv));
-		return 1;
-	}
+	if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+			     lp->region_size, lp->pvh))
+		return_0;
 
-	log_error("Conversion operation not yet supported.");
-	return 0;
+	log_print_unless_silent("Logical volume %s successfully converted.",
+				display_lvname(lv));
+	return 1;
 }
 
 static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow,


