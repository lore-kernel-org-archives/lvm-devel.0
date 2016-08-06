From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Aug 2016 23:57:12 +0000 (UTC)
Subject: master - lvconvert: Support raid0<->raid4 and mirror<->raid1.
Message-ID: <20160806235712.58F8860DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76ef2d15d839106adac4d82005d517be05a657eb
Commit:        76ef2d15d839106adac4d82005d517be05a657eb
Parent:        de7f1deb80499087662e57c4aef9e9373f15ca63
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 7 00:56:08 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 7 00:56:08 2016 +0100

lvconvert: Support raid0<->raid4 and mirror<->raid1.

Only simple takeover cases so far.
---
 WHATS_NEW                 |    2 +
 lib/metadata/raid_manip.c |  476 +++++++++++++++++++++++++++++++++++++++++++--
 tools/lvconvert.c         |  102 +++++++---
 3 files changed, 535 insertions(+), 45 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7282081..3adc194 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.163 - 
 =================================
+  Support straightforward lvconvert between striped and raid4 LVs.
+  Support straightforward lvconvert between raid1 and mirror LVs.
   Report supported conversions when asked for unsupported raid lvconvert.
   Add "--rebuild PV" option to lvchange to allow for PV selective rebuilds.
   Preserve existing mirror region size when using --repair.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2e491eb..c1cff33 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -21,6 +21,7 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
+#include "lvm-signal.h"
 
 static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 {
@@ -1885,12 +1886,117 @@ static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
 }
 
 /*
- * General conversion functions
+ * Clear any rebuild disk flags on lv.
+ * If any flags were cleared, *flags_were_cleared is set to 1.
  */
+/* FIXME Generalise into foreach_underlying_lv_segment_area. */
+static void _clear_rebuild_flags(struct logical_volume *lv, int *flags_were_cleared)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct logical_volume *sub_lv;
+	uint32_t s;
+	uint64_t flags_to_clear = LV_REBUILD;
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) == AREA_PV)
+			continue;
+
+		sub_lv = seg_lv(seg, s);
+
+		/* Recurse into sub LVs */
+		_clear_rebuild_flags(sub_lv, flags_were_cleared);
+
+		if (sub_lv->status & flags_to_clear) {
+			sub_lv->status &= ~flags_to_clear;
+			*flags_were_cleared = 1;
+		}
+	}
+}
 
 /*
- * Convert a RAID0 set to striped
+ * Updates and reloads metadata, clears any flags passed to the kernel,
+ * eliminates any residual LVs and updates and reloads metadata again.
+ *
+ * lv removal_lvs
+ *
+ * This minimally involves 2 metadata commits.
+ */
+static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv, struct dm_list *removal_lvs)
+{
+	int flags_were_cleared = 0, r = 0;
+
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
+
+	/* Eliminate any residual LV and don't commit the metadata */
+	if (!_eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0))
+		return_0;
+
+	/*
+	 * Now that any 'REBUILD' or 'RESHAPE_DELTA_DISKS' etc.
+	 * has/have made its/their way to the kernel, we must
+	 * remove the flag(s) so that the individual devices are
+	 * not rebuilt/reshaped/taken over upon every activation.
+	 *
+	 * Writes and commits metadata if any flags have been reset
+	 * and if successful, performs metadata backup.
+	 */
+	/* FIXME This needs to be done through hooks in the metadata */
+	log_debug_metadata("Clearing any flags for %s passed to the kernel", display_lvname(lv));
+	_clear_rebuild_flags(lv, &flags_were_cleared);
+
+	log_debug_metadata("Updating metadata and reloading mappings for %s", display_lvname(lv));
+	if ((r != 2 || flags_were_cleared) && !lv_update_and_reload(lv)) {
+		log_error("Update and reload of LV %s failed", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Adjust all data sub LVs of lv to mirror
+ * or raid name depending on direction
+ * adjusting their LV status
  */
+enum mirror_raid_conv { MIRROR_TO_RAID1 = 0, RAID1_TO_MIRROR };
+static int _adjust_data_lvs(struct logical_volume *lv, enum mirror_raid_conv direction)
+{
+	uint32_t s;
+	char *sublv_name_suffix;
+	struct lv_segment *seg = first_seg(lv);
+	static struct {
+		char type_char;
+		uint64_t set_flag;
+		uint64_t reset_flag;
+	} conv[] = {
+		{ 'r', RAID_IMAGE, MIRROR_IMAGE },
+		{ 'm', MIRROR_IMAGE, RAID_IMAGE }
+	};
+	struct logical_volume *dlv;
+
+	for (s = 0; s < seg->area_count; ++s) {
+		dlv = seg_lv(seg, s);
+
+		if (!(sublv_name_suffix = first_substring(dlv->name, "_mimage_", "_rimage_", NULL))) {
+			log_error(INTERNAL_ERROR "name lags image part");
+			return 0;
+		}
+
+		*(sublv_name_suffix + 1) = conv[direction].type_char;
+		log_debug_metadata("data LV renamed to %s", dlv->name);
+
+		dlv->status &= ~conv[direction].reset_flag;
+		dlv->status |= conv[direction].set_flag;
+	}
+
+	return 1;
+}
+
+/*
+ * General conversion functions
+ */
+
 static int _convert_mirror_to_raid1(struct logical_volume *lv,
 				    const struct segment_type *new_segtype)
 {
@@ -1987,6 +2093,76 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 }
 
 /*
+ * Convert lv with "raid1" mapping to "mirror"
+ * optionally changing number of data_copies
+ * defined by @new_image_count.
+ */
+static int _convert_raid1_to_mirror(struct logical_volume *lv,
+				    const struct segment_type *new_segtype,
+				    uint32_t new_image_count,
+				    uint32_t new_region_size,
+				    struct dm_list *allocate_pvs,
+				    int update_and_reload,
+				    struct dm_list *removal_lvs)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_raid1(seg)) {
+		log_error(INTERNAL_ERROR "raid1 conversion supported only");
+		return 0;
+	}
+
+	if ((new_image_count = new_image_count ?: seg->area_count) < 2) {
+		log_error("can't convert %s to fewer than 2 data_copies", display_lvname(lv));
+		return 0;
+	}
+
+	if (!_check_max_mirror_devices(new_image_count)) {
+		log_error("Unable to convert %s LV %s with %u images to %s",
+			  SEG_TYPE_NAME_RAID1, display_lvname(lv), new_image_count, SEG_TYPE_NAME_MIRROR);
+		log_error("At least reduce to the maximum of %u images with \"lvconvert -m%u %s\"",
+			  DEFAULT_MIRROR_MAX_IMAGES, DEFAULT_MIRROR_MAX_IMAGES - 1, display_lvname(lv));
+		return 0;
+	}
+
+	init_mirror_in_sync(new_image_count > seg->area_count ? 0 : 1);
+
+	/* Change image pair count to requested # of images */
+	if (new_image_count != seg->area_count) {
+		log_debug_metadata("Changing image count to %u on %s",
+				   new_image_count, display_lvname(lv));
+		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
+			return 0;
+	}
+
+	/* Remove rmeta LVs */
+	log_debug_metadata("Extracting and renaming metadata LVs");
+	if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs))
+		return 0;
+
+	seg->meta_areas = NULL;
+
+	/* Rename all data sub LVs from "*_rimage_*" to "*_mimage_*" and set their status */
+	log_debug_metadata("Adjust data LVs of %s", display_lvname(lv));
+	if (!_adjust_data_lvs(lv, RAID1_TO_MIRROR))
+		return 0;
+
+	seg->segtype = new_segtype;
+	seg->region_size = new_region_size;
+	lv->status &= ~RAID;
+	seg->status &= ~RAID;
+	lv->status |= (MIRROR | MIRRORED);
+
+	/* Add mirror_log LV (should happen in wih image allocation */
+	if (!add_mirror_log(lv->vg->cmd, lv, 1, seg->region_size, allocate_pvs, lv->vg->alloc)) {
+		log_error("Unable to add mirror log to %s", display_lvname(lv));
+		return 0;
+	}
+
+	return update_and_reload ? _lv_update_reload_fns_reset_eliminate_lvs(lv, removal_lvs) : 1;
+}
+
+/*
  * All areas from LV segments are moved to new
  * segments allocated with area_count=1 for data_lvs.
  */
@@ -2263,6 +2439,14 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 /*
  * Takeover.
  *
+ * Change the user's requested segment type to 
+ * the appropriate more-refined one for takeover.
+ *
+ * raid0 can take over:
+ *  raid4
+ *
+ * raid4 can take over:
+ *  raid0 - if there is only one stripe zone
  */
 #define	ALLOW_NONE		0x0
 #define	ALLOW_STRIPES		0x2
@@ -2284,23 +2468,43 @@ struct possible_type {
 
 static struct possible_takeover_reshape_type _possible_takeover_reshape_types[] = {
 	/* striped -> */
+	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
+	  .possible_types = SEG_RAID1,
+	  .current_areas = 1,
+	  .options = ALLOW_NONE },
+	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
+	  .possible_types = SEG_RAID0|SEG_RAID0_META,
+	  .current_areas = 1,
+	  .options = ALLOW_STRIPE_SIZE },
 	{ .current_types  = SEG_STRIPED_TARGET, /* striped, i.e. seg->area_count > 1 */
 	  .possible_types = SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
 	/* raid0* -> */
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count = 1 */
+	  .possible_types = SEG_RAID1,
+	  .current_areas = 1,
+	  .options = ALLOW_NONE },
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count > 1 */
+	  .possible_types = SEG_RAID4,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
 	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0 striped, i.e. seg->area_count > 0 */
 	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
 	/* raid1 -> */
 	{ .current_types  = SEG_RAID1,
-	  .possible_types = SEG_RAID1,
+	  .possible_types = SEG_RAID1|SEG_MIRROR,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
 	/* mirror -> raid1 with arbitrary number of legs */
 	{ .current_types  = SEG_MIRROR,
-	  .possible_types = SEG_MIRROR,
+	  .possible_types = SEG_MIRROR|SEG_RAID1,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
+	{ .current_types  = SEG_RAID4,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE },
 
@@ -2336,6 +2540,23 @@ static struct possible_type *_get_possible_type(const struct lv_segment *seg_fro
 }
 
 /*
+ * Return allowed options (--stripes, ...) for conversion from @seg_from -> @seg_to
+ */
+static int _get_allowed_conversion_options(const struct lv_segment *seg_from,
+					   const struct segment_type *segtype_to,
+					   uint32_t new_image_count, uint32_t *options)
+{
+	struct possible_type *pt;
+
+	if ((pt = _get_possible_type(seg_from, segtype_to, new_image_count, NULL))) {
+		*options = pt->options;
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
  * Log any possible conversions for @lv
  */
 typedef int (*type_flag_fn_t)(uint64_t *processed_segtypes, void *data);
@@ -2455,6 +2676,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 	int yes,				\
 	int force,				\
 	unsigned new_image_count,		\
+	unsigned new_data_copies,		\
 	const unsigned new_stripes,		\
 	uint32_t new_stripe_size,		\
 	const uint32_t new_region_size,		\
@@ -2517,7 +2739,6 @@ static int _takeover_not_possible(takeover_fn_t takeover_fn)
 /*
  * Wrapper functions that share conversion code.
  */
-
 static int _raid0_meta_change_wrapper(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     uint32_t new_stripes,
@@ -2565,6 +2786,77 @@ static int _raid0_to_striped_wrapper(struct logical_volume *lv,
 	return 1;
 }
 
+/* raid1 -> mirror */
+static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
+{
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	if (!_raid_in_sync(lv))
+		return_0;
+
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s back to the older \"%s\" type? [y/n]: ",
+				  display_lvname(lv), SEG_TYPE_NAME_MIRROR) == 'n') {
+		log_error("Logical volume %s NOT converted to \"%s\"",
+			  display_lvname(lv), SEG_TYPE_NAME_MIRROR);
+		return 0;
+	}
+	if (sigint_caught())
+		return_0;
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _convert_raid1_to_mirror(lv, new_segtype, new_image_count, new_region_size,
+					allocate_pvs, 1, &removal_lvs);
+}
+
+/* raid45 -> raid0* / striped */
+static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	if (!seg_is_raid4(seg) && !seg_is_raid5_n(seg) && !seg_is_raid6_n_6(seg)) {
+		log_error("LV %s has to be of type raid4/raid5_n/raid6_n_6 to allow for this conversion",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	/* Necessary when convering to raid0/striped w/o redundancy? */
+	if (!_raid_in_sync(lv))
+		return 0;
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* Remove meta and data LVs requested */
+	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
+		return 0;
+
+	if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
+		return_0;
+
+	/* FIXME Hard-coded raid4 to raid0 */
+	seg->area_len = seg->extents_copied = seg->area_len / seg->area_count;
+
+	if (segtype_is_striped_target(new_segtype)) {
+		if (!_convert_raid0_to_striped(lv, 0, &removal_lvs))
+			return_0;
+	} else if (segtype_is_raid0(new_segtype) &&
+		   !_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, &removal_lvs))
+		return_0;
+
+	seg->region_size = 0;
+
+	return _lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs);
+}
+
 static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     uint32_t new_stripes,
@@ -2586,8 +2878,69 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 	return 1;
 }
 
+/* Helper: striped/raid0* -> raid4/5/6/10 */
+static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg_is_raid10(seg))
+		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+
+	if (new_data_copies > new_image_count) {
+		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes");
+		return 0;
+	}
+
+	if (new_stripes && new_stripes != seg->area_count) {
+		log_error("Can't restripe LV %s during conversion", display_lvname(lv));
+		return 0;
+	}
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	/* This helper can be used to convert from striped/raid0* -> raid10 too */
+	if (seg_is_striped_target(seg)) {
+		log_debug_metadata("Converting LV %s from %s to %s",
+				   display_lvname(lv), SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID0);
+		if (!(seg = _convert_striped_to_raid0(lv, 1 /* alloc_metadata_devs */, 0 /* update_and_reload */, allocate_pvs)))
+			return 0;
+	}
+
+	/* Add metadata LVs */
+	if (seg_is_raid0(seg)) {
+		log_debug_metadata("Adding metadata LVs to %s", display_lvname(lv));
+		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
+			return 0;
+	}
+
+	/* Add the additional component LV pairs */
+	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s", new_image_count - lv_raid_image_count(lv),
+			   display_lvname(lv));
+	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
+		return 0;
 
+	if (!segtype_is_raid4(new_segtype)) {
+		/* Can't convert striped/raid0* to e.g. raid10_offset */
+		log_error("Can't convert %s to %s", display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+
+	seg->segtype = new_segtype;
+	seg->region_size = new_region_size;
+	/* FIXME Hard-coded raid0 to raid4 */
+	seg->area_len = seg->len;
 
+	_check_and_adjust_region_size(lv);
+
+	log_debug_metadata("Updating VG metadata and reloading %s LV %s",
+			   lvseg_name(seg), display_lvname(lv));
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, NULL))
+		return_0;
+
+	return 1;
+}
 
 /************************************************/
 
@@ -2669,7 +3022,7 @@ static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1, 1 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
@@ -2715,7 +3068,7 @@ static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1, 1 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
@@ -2738,7 +3091,7 @@ static int _takeover_from_raid1_to_linear(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid1_to_mirrored(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid1_to_mirrored_wrapper(lv, new_segtype, yes, force, new_image_count, new_data_copies, new_stripes, new_stripe_size, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid1_to_raid0(TAKEOVER_FN_ARGS)
@@ -2783,12 +3136,12 @@ static int _takeover_from_raid45_to_mirrored(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
@@ -2808,7 +3161,7 @@ static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
@@ -2859,7 +3212,8 @@ static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1,
+						      2 /* data_copies*/, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
@@ -2960,6 +3314,92 @@ static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t
 }
 
 /*
+ * Determine whether data_copies, stripes, stripe_size are
+ * possible for conversion from seg_from to new_segtype.
+ */
+static int _log_prohibited_option(const struct lv_segment *seg_from,
+				  const struct segment_type *new_segtype,
+				  const char *opt_str)
+{
+	if (seg_from->segtype == new_segtype)
+		log_error("%s not allowed when converting %s LV %s.",
+			  opt_str, lvseg_name(seg_from), display_lvname(seg_from->lv));
+	else
+		log_error("%s not allowed for LV %s when converting from %s to %s.",
+			  opt_str, display_lvname(seg_from->lv), lvseg_name(seg_from), new_segtype->name);
+
+	return 1;
+}
+
+/* Change segtype for raid4 <-> raid5 <-> raid6 takeover where necessary. */
+static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
+					      const struct segment_type **segtype)
+{
+	if (seg_is_striped(seg_from) || seg_is_raid4(seg_from)) {
+		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
+		if (segtype_is_any_raid5(*segtype) &&
+		    !segtype_is_raid5_n(*segtype)) {
+			log_error("Conversion to raid5_n not yet supported.");
+			return 0;
+
+		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
+		} else if (segtype_is_any_raid6(*segtype) &&
+			   !segtype_is_raid6_n_6(*segtype)) {
+			log_error("Conversion to raid6_n_6 not yet supported.");
+			return 0;
+		}
+
+	/* Got to do check for raid5 -> raid6 ... */
+	} else if (seg_is_any_raid5(seg_from) &&
+		   segtype_is_any_raid6(*segtype)) {
+			log_error("Conversion not supported.");
+		return_0;
+
+	/* ... and raid6 -> raid5 */
+	} else if (seg_is_any_raid6(seg_from) &&
+		   segtype_is_any_raid5(*segtype)) {
+			log_error("Conversion not supported.");
+		return_0;
+	}
+
+	return 1;
+}
+
+/* Check allowed conversion from seg_from to *segtype_to */
+static int _conversion_options_allowed(const struct lv_segment *seg_from,
+				       const struct segment_type **segtype_to,
+				       uint32_t new_image_count,
+				       int new_data_copies, int region_size,
+				       int stripes, unsigned new_stripe_size_supplied)
+{
+	int r = 1;
+	uint32_t opts;
+
+	if (!new_image_count && !_set_convenient_raid456_segtype_to(seg_from, segtype_to))
+		return_0;
+
+	if (!_get_allowed_conversion_options(seg_from, *segtype_to, new_image_count, &opts)) {
+		log_error("Unable to convert LV %s from %s to %s.",
+			  display_lvname(seg_from->lv), lvseg_name(seg_from), (*segtype_to)->name);
+		return 0;
+	}
+
+	if (stripes > 1 && !(opts & ALLOW_STRIPES)) {
+		if (!_log_prohibited_option(seg_from, *segtype_to, "--stripes"))
+			stack;
+		r = 0;
+	}
+
+	if (new_stripe_size_supplied && !(opts & ALLOW_STRIPE_SIZE)) {
+		if (!_log_prohibited_option(seg_from, *segtype_to, "-I/--stripesize"))
+			stack;
+		r = 0;
+	}
+
+	return r;
+}
+
+/*
  * lv_raid_convert
  *
  * Convert lv from one RAID type (or striped/mirror segtype) to new_segtype,
@@ -3001,11 +3441,19 @@ int lv_raid_convert(struct logical_volume *lv,
 	if (segtype_is_raid(new_segtype) && !_check_max_raid_devices(new_image_count))
 		return_0;
 
+	/*
+	 * Check acceptible options mirrors, region_size,
+	 * stripes and/or stripe_size have been provided.
+	 */
+	if (!_conversion_options_allowed(seg, &new_segtype, 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
+					 new_stripes, new_stripe_size_supplied))
+		return _log_possible_conversion_types(lv, new_segtype);
+	
 	takeover_fn = _get_takeover_fn(first_seg(lv), new_segtype, new_image_count);
 
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
-		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size,
+		return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
 				   new_region_size, allocate_pvs);
 
 	log_verbose("Converting %s from %s to %s.",
@@ -3036,7 +3484,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size,
+	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
 			   new_region_size, allocate_pvs);
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8c3bf05..5677e9c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -311,17 +311,9 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	if (!type_str || !*type_str)
 		return 1;
 
-	if (!strcmp(type_str, SEG_TYPE_NAME_MIRROR)) {
-		if (!arg_is_set(cmd, mirrors_ARG)) {
-			log_error("Conversions to --type mirror require -m/--mirrors");
-			return 0;
-		}
-		return 1;
-	}
-
 	/* FIXME: Check thin-pool and thin more thoroughly! */
 	if (!strcmp(type_str, SEG_TYPE_NAME_SNAPSHOT) || _striped_type_requested(type_str) ||
-	    !strncmp(type_str, SEG_TYPE_NAME_RAID, 4) ||
+	    !strncmp(type_str, SEG_TYPE_NAME_RAID, 4) || !strcmp(type_str, SEG_TYPE_NAME_MIRROR) ||
 	    !strcmp(type_str, SEG_TYPE_NAME_CACHE_POOL) || !strcmp(type_str, SEG_TYPE_NAME_CACHE) ||
 	    !strcmp(type_str, SEG_TYPE_NAME_THIN_POOL) || !strcmp(type_str, SEG_TYPE_NAME_THIN))
 		return 1;
@@ -1770,6 +1762,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	if (!lp->need_polling)
 		log_print_unless_silent("Logical volume %s converted.",
 					display_lvname(lv));
+	else
+		log_print_unless_silent("Logical volume %s being converted.",
+					display_lvname(lv));
 
 	backup(lv->vg);
 
@@ -1837,29 +1832,35 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 	/* Can only change image count for raid1 and linear */
-	if (lp->mirrors_supplied && !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
-		log_error("'--mirrors/-m' is not compatible with %s.",
-			  lvseg_name(seg));
-		goto try_new_takeover_or_reshape;
+	if (lp->mirrors_supplied) {
+		if (_raid0_type_requested(lp->type_str)) {
+			log_error("--mirrors/-m is not compatible with conversion to %s.",
+				  lp->type_str);
+			return 0;
+		}
+		if (!seg_is_mirrored(seg) && !seg_is_linear(seg)) {
+			log_error("--mirrors/-m is not compatible with %s.",
+				  lvseg_name(seg));
+			return 0;
+		}
 	}
 
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
-	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype)) {
-		log_error("Unable to convert %s from %s to %s.",
-			  display_lvname(lv), lvseg_name(seg),
-			  lp->segtype->name);
+	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype))
 		goto try_new_takeover_or_reshape;
-	}
 
 	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
-		if (_raid0_type_requested(lp->type_str))
+		if (_raid0_type_requested(lp->type_str)) {
 			log_error("Linear LV %s cannot be converted to %s.",
 				  display_lvname(lv), lp->type_str);
-		else
+			return 0;
+		} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_RAID1)) {
 			log_error("Raid conversions of LV %s require -m/--mirrors.",
 				  display_lvname(lv));
+			return 0;
+		}
 		goto try_new_takeover_or_reshape;
 	}
 
@@ -1896,19 +1897,38 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (lp->keep_mimages)
 		return lv_raid_split(lv, lp->lv_split_name, image_count, lp->pvh);
 
-	if (lp->mirrors_supplied)
-		return lv_raid_change_image_count(lv, image_count, lp->pvh);
+	if (lp->mirrors_supplied) {
+		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR)) {
+			if (!lv_raid_change_image_count(lv, image_count, lp->pvh))
+				return_0;
+
+			log_print_unless_silent("Logical volume %s successfully converted.",
+						display_lvname(lv));
+
+			return 1;
+		}
+		goto try_new_takeover_or_reshape;
+	} else if (!*lp->type_str || seg->segtype == lp->segtype) {
+		log_error("Conversion operation not yet supported.");
+		return 0;
+	}
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
 	    (lp->type_str && lp->type_str[0])) {
+		/* Activation is required later which precludes existing unsupported raid0 segment */
 		if (segtype_is_any_raid0(lp->segtype) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
 			log_error("RAID module does not support RAID0.");
 			return 0;
 		}
+
+		if (!arg_is_set(cmd, stripes_long_ARG))
+			lp->stripes = 0;
+
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
 				     lp->region_size, lp->pvh))
 			return_0;
+
 		log_print_unless_silent("Logical volume %s successfully converted.",
 					display_lvname(lv));
 		return 1;
@@ -1968,13 +1988,27 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 1;
 	}
 
-	log_error("Conversion operation not yet supported.");
 
 try_new_takeover_or_reshape:
-	;
 
-	/* FIXME New takeover and reshape code is called from here */
+	/* FIXME This needs changing globally. */
+	if (!arg_is_set(cmd, stripes_long_ARG))
+		lp->stripes = 0;
 
+	/* Only let raid4 through for now. */
+	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
+	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
+	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
+		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+				     lp->region_size, lp->pvh))
+			return_0;
+
+		log_print_unless_silent("Logical volume %s successfully converted.",
+					display_lvname(lv));
+		return 1;
+	}
+
+	log_error("Conversion operation not yet supported.");
 	return 0;
 }
 
@@ -2409,9 +2443,6 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
-	// FIXME: allow origin to be specified
-	// FIXME: verify snapshot is descendant of specified origin
-
 	/*
 	 * Prevent merge with open device(s) as it would likely lead
 	 * to application/filesystem failure.  Merge on origin's next
@@ -4240,7 +4271,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
-	if (segtype_is_raid(lp->segtype))
+	if (segtype_is_raid(lp->segtype) || segtype_is_mirror(lp->segtype))
 		return _convert_raid_raid(cmd, lv, lp);
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
@@ -4264,6 +4295,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --type thin-pool\n"
 		  "  --type cache-pool\n"
 		  "  --type raid*\n"
+		  "  --type mirror\n"
 		  "  --type striped\n"
 		  "  --type linear\n");
 	return 0;
@@ -4328,6 +4360,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 /*
+ * Main entry point.
  * lvconvert performs a specific <operation> on a specific <lv_type>.
  *
  * The <operation> is specified by command line args.
@@ -4345,7 +4378,6 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
  * So, when the use of arg_type_str(type_ARG) here was replaced with
  * lp->type_str, some commands are no longer identified/routed correctly.
  */
-
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvconvert_params *lp)
 {
@@ -4393,6 +4425,13 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	else if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 		return_0;
 
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
+		if (!lp->mirrors_supplied && !seg_is_raid1(seg)) {
+			log_error("Conversions to --type mirror require -m/--mirrors");
+			return 0;
+		}
+	}
+
 	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -4404,6 +4443,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME This is incomplete */
 	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
 	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
+		/* FIXME Handle +/- adjustments too? */
 		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
 			return_0;
 		/* FIXME Move this into the get function */
@@ -4412,7 +4452,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
 			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
 			/* The default keeps existing number of stripes, handled inside the library code */
-			if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
+			if (!arg_is_set(cmd, stripes_long_ARG))
 				lp->stripes = 0;
 	}
 


