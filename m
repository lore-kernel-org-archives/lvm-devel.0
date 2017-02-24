From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:11 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063211.4831860AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4de0e692dba592206c8bb1f5000b4a6e445914a5
Commit:        4de0e692dba592206c8bb1f5000b4a6e445914a5
Parent:        7d39b4d5e7c38438b294469f74d437bdbb9a2632
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 02:12:30 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add function to support disk adding reshapes
- add function to support disk removing reshapes
- add function to support layout (e.g. raid5ls -> raid5_rs)
  or stripesize reshaping

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |  314 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 311 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b82ec90..1cee8c3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -557,7 +557,7 @@ static void _swap_areas(struct lv_segment_area *a1, struct lv_segment_area *a2)
  *
  * raid10_{near,far} can only be reordered to raid0 if !mod(#total_devs, #mirrors)
  *
- * Examples with 6 disks indexed 0..5 with 3 stripes:
+ * Examples with 6 disks indexed 0..5 with 3 stripes and 2 data copies:
  * raid0             (012345) -> raid10_{near,far} (031425) order
  * idx                024135
  * raid10_{near,far} (012345) -> raid0  (024135/135024) order depending on mirror leg selection (TBD)
@@ -576,7 +576,7 @@ enum raid0_raid10_conversion { reorder_to_raid10_near, reorder_from_raid10_near
 static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_raid10_conversion conv)
 {
 	unsigned dc, idx1, idx1_sav, idx2, s, ss, str, xchg;
-	uint32_t data_copies = 2; /* seg->data_copies */
+	uint32_t data_copies = seg->data_copies;
 	uint32_t *idx, stripes = seg->area_count;
 	unsigned i = 0;
 
@@ -589,7 +589,7 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 
 	/* FIXME: once more data copies supported with raid10 */
 	if (seg_is_raid10_near(seg) && (stripes % data_copies)) {
-		log_error("Can't convert %s LV %s with number of stripes not divisable by number of data copies",
+		log_error("Can't convert %s LV %s with number of stripes not divisable by number of data copies.",
 			  lvseg_name(seg), display_lvname(seg->lv));
 		return 0;
 	}
@@ -1545,6 +1545,314 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 }
 
 /*
+ * HM Helper:
+ *
+ * Reshape: add immages to existing raid lv
+ *
+ */
+static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
+				       int commit, int use_existing_area_len);
+__attribute__ ((__unused__))
+static int _raid_reshape_add_images(struct logical_volume *lv,
+				    const struct segment_type *new_segtype, int yes,
+				    uint32_t old_image_count, uint32_t new_image_count,
+				    const unsigned new_stripes, const unsigned new_stripe_size,
+				    struct dm_list *allocate_pvs)
+{
+	uint32_t grown_le_count, current_le_count, s;
+	struct volume_group *vg;
+	struct logical_volume *slv;
+	struct lv_segment *seg = first_seg(lv);
+	struct lvinfo info = { 0 };
+
+	if (new_image_count == old_image_count) {
+		log_error(INTERNAL_ERROR "No change of image count on LV %s.", display_lvname(lv));
+		return_0;
+	}
+
+	vg = lv->vg;
+
+	if (!lv_info(vg->cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
+		log_error("lv_info failed: aborting.");
+		return 0;
+	}
+
+	if (seg->segtype != new_segtype)
+		log_print_unless_silent("Ignoring layout change on device adding reshape.");
+
+	if (seg_is_any_raid10(seg) && (new_image_count % seg->data_copies)) {
+		log_error("Can't reshape %s LV %s to odd number of stripes.", 
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &grown_le_count))
+		return 0;
+
+	current_le_count = lv->le_count - _reshape_len_per_lv(lv);
+	grown_le_count -= _reshape_len_per_dev(seg) * _data_rimages_count(seg, new_image_count);
+	log_warn("WARNING: Adding stripes to active%s logical volume %s "
+		 "will grow it from %u to %u extents!",
+		 info.open_count ? " and open" : "",
+		 display_lvname(lv), current_le_count, grown_le_count);
+	log_print_unless_silent("Run \"lvresize -l%u %s\" to shrink it or use the additional capacity.",
+				current_le_count, display_lvname(lv));
+	if (!yes && yes_no_prompt("Are you sure you want to add %u images to %s LV %s? [y/n]: ",
+				  new_image_count - old_image_count, lvseg_name(seg), display_lvname(lv)) == 'n') {
+		log_error("Logical volume %s NOT converted.", display_lvname(lv));
+		return 0;
+	}
+
+	/* Allocate new image component pairs for the additional stripes and grow LV size */
+	log_debug_metadata("Adding %u data and metadata image LV pair%s to %s.",
+			   new_image_count - old_image_count, new_image_count - old_image_count > 1 ? "s" : "",
+			   display_lvname(lv));
+	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 0))
+		return 0;
+
+	/* Reshape adding image component pairs -> change sizes/counters accordingly */
+	if (!_reshape_adjust_to_size(lv, old_image_count, new_image_count)) {
+		log_error("Failed to adjust LV %s to new size!", display_lvname(lv));
+		return 0;
+	}
+
+	/* Allocate forward out of place reshape space at the beginning of all data image LVs */
+	log_debug_metadata("(Re)allocating reshape space for %s.", display_lvname(lv));
+	if (!_lv_alloc_reshape_space(lv, alloc_begin, NULL, allocate_pvs))
+		return 0;
+
+	/*
+	 * Reshape adding image component pairs:
+	 *
+	 * - reset rebuild flag on new image LVs
+	 * - set delta disks plus flag on new image LVs
+	 */
+	if (old_image_count < seg->area_count) {
+		log_debug_metadata("Setting delta disk flag on new data LVs of %s.",
+				   display_lvname(lv));
+		for (s = old_image_count; s < seg->area_count; s++) {
+			slv = seg_lv(seg, s);
+			slv->status &= ~LV_REBUILD;
+			slv->status |= LV_RESHAPE_DELTA_DISKS_PLUS;
+		}
+	}
+
+	seg->stripe_size = new_stripe_size;
+
+	return 1;
+}
+
+/*
+ * HM Helper:
+ *
+ * Reshape: remove images from existing raid lv
+ *
+ */
+__attribute__ ((__unused__))
+static int _raid_reshape_remove_images(struct logical_volume *lv,
+				       const struct segment_type *new_segtype,
+				       int yes, int force,
+				       uint32_t old_image_count, uint32_t new_image_count,
+				       const unsigned new_stripes, const unsigned new_stripe_size,
+				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs)
+{
+	uint32_t active_lvs, current_le_count, reduced_le_count, removed_lvs, s;
+	uint64_t extend_le_count;
+	unsigned devs_health, devs_in_sync;
+	struct lv_segment *seg = first_seg(lv);
+	struct lvinfo info = { 0 };
+
+	if (seg_is_any_raid6(seg) && new_stripes < 3) {
+		log_error("Minimum 3 stripes required for %s LV %s.",
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	if (new_image_count == old_image_count) {
+		log_error(INTERNAL_ERROR "No change of image count on LV %s.", display_lvname(lv));
+		return_0;
+	}
+
+	switch (_reshaped_state(lv, new_image_count, &devs_health, &devs_in_sync)) {
+	case 3:
+		/*
+		 * Disk removal reshape step 1:
+		 *
+		 * we got more disks active than requested via @new_stripes
+		 *
+		 * -> flag the ones to remove
+		 *
+		 */
+		if (seg->segtype != new_segtype)
+			log_print_unless_silent("Ignoring layout change on device removing reshape.");
+
+		if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
+			log_error("lv_info failed: aborting.");
+			return 0;
+		}
+
+		if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &reduced_le_count))
+			return 0;
+
+		reduced_le_count -= seg->reshape_len * _data_rimages_count(seg, new_image_count);
+		current_le_count = lv->le_count - seg->reshape_len * _data_rimages_count(seg, old_image_count);
+		extend_le_count = current_le_count * current_le_count / reduced_le_count;
+		log_warn("WARNING: Removing stripes from active%s logical "
+			 "volume %s will shrink it from %s to %s!",
+			 info.open_count ? " and open" : "", display_lvname(lv),
+			 display_size(lv->vg->cmd, (uint64_t) current_le_count * lv->vg->extent_size),
+			 display_size(lv->vg->cmd, (uint64_t) reduced_le_count * lv->vg->extent_size));
+		log_warn("THIS MAY DESTROY (PARTS OF) YOUR DATA!");
+		if (!yes)
+			log_warn("Interrupt the conversion and run \"lvresize -y -l%u %s\" to "
+				 "keep the current size if not done already!",
+				 (uint32_t) extend_le_count, display_lvname(lv));
+		log_print_unless_silent("If that leaves the logical volume larger than %llu extents due to stripe rounding,",
+					(unsigned long long) extend_le_count);
+		log_print_unless_silent("you may want to grow the content afterwards (filesystem etc.)");
+		log_warn("WARNING: too remove freed stripes after the conversion has finished, you have to run \"lvconvert --stripes %u %s\"",
+			 new_stripes, display_lvname(lv));
+
+		if (!force) {
+			log_warn("WARNING: Can't remove stripes without --force option.");
+			return 0;
+		}
+
+		if (!yes && yes_no_prompt("Are you sure you want to remove %u images from %s LV %s? [y/n]: ",
+					  old_image_count - new_image_count, lvseg_name(seg), display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s NOT converted.", display_lvname(lv));
+			return 0;
+		}
+
+		/*
+		 * Allocate backward out of place reshape space at the
+		 * _end_ of all data image LVs, because MD reshapes backwards
+		 * to remove disks from a raid set
+		 */
+		if (!_lv_alloc_reshape_space(lv, alloc_end, NULL, allocate_pvs))
+			return 0;
+
+		/* Flag all disks past new images as delta disks minus to kernel */
+		for (s = new_image_count; s < old_image_count; s++)
+			seg_lv(seg, s)->status |= LV_RESHAPE_DELTA_DISKS_MINUS;
+
+		if (seg_is_any_raid5(seg) && new_image_count == 2)
+			seg->data_copies = 2;
+
+		break;
+
+	case 1:
+		/*
+		 * Disk removal reshape step 2:
+		 *
+		 * we got the proper (smaller) amount of devices active
+		 * for a previously finished disk removal reshape
+		 *
+		 * -> remove the freed up images and reduce LV size
+		 *
+		 */
+		for (active_lvs = removed_lvs = s = 0; s < seg->area_count; s++) {
+			struct logical_volume *slv;
+
+			if (!seg_lv(seg, s) || !(slv = seg_lv(seg, s))) {
+				log_error("Missing image sub lv off LV %s.", display_lvname(lv));
+				return 0;
+			}
+
+			if (slv->status & LV_REMOVE_AFTER_RESHAPE)
+				removed_lvs++;
+			else
+				active_lvs++;
+		}
+
+		if (devs_in_sync != new_image_count) {
+			log_error("No correct kernel/lvm active LV count on %s.", display_lvname(lv));
+			return 0;
+		}
+
+		if (active_lvs + removed_lvs != old_image_count) {
+			log_error ("No correct kernel/lvm total LV count on %s.", display_lvname(lv));
+			return 0;
+		}
+
+		/* Reshape removing image component pairs -> change sizes accordingly */
+		if (!_reshape_adjust_to_size(lv, old_image_count, new_image_count)) {
+			log_error("Failed to adjust LV %s to new size!", display_lvname(lv));
+			return 0;
+		}
+
+		log_debug_metadata("Removing %u data and metadata image LV pair%s from %s.",
+				   old_image_count - new_image_count, old_image_count - new_image_count > 1 ? "s" : "",
+				   display_lvname(lv));
+		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
+			return 0;
+
+		seg->area_count = new_image_count;
+
+		break;
+
+	default:
+		log_error(INTERNAL_ERROR "Bad return provided to %s.", __func__);
+		return 0;
+	}
+
+	seg->stripe_size = new_stripe_size;
+
+	return 1;
+}
+/*
+ * HM Helper:
+ *
+ * Reshape: keep images in RAID @lv but change stripe size or data copies
+ *
+ */
+__attribute__ ((__unused__))
+static int _raid_reshape_keep_images(struct logical_volume *lv,
+				     const struct segment_type *new_segtype,
+				     int yes, int force, int *force_repair,
+				     const int new_data_copies, const unsigned new_stripe_size,
+				     struct dm_list *allocate_pvs)
+{
+	int alloc_reshape_space = 1;
+	enum alloc_where where = alloc_anywhere;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg->segtype != new_segtype)
+		log_print_unless_silent("Converting %s LV %s to %s.",
+					lvseg_name(seg), display_lvname(lv), new_segtype->name);
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s NOT converted.", display_lvname(lv));
+			return 0;
+	}
+
+	seg->stripe_size = new_stripe_size;
+
+	/*
+	 * Reshape layout alogorithm or chunksize:
+	 *
+	 * Allocate free out-of-place reshape space unless raid10_far.
+	 *
+	 * If other raid10, allocate it appropriatly.
+	 *
+	 * Allocate it anywhere for raid4/5 to avoid remapping
+	 * it in case it is already allocated.
+	 *
+	 * The dm-raid target is able to use the space whereever it
+	 * is found by appropriately selecting forward or backward reshape.
+	 */
+	if (seg->area_count != 2 &&
+	    alloc_reshape_space &&
+	    !_lv_alloc_reshape_space(lv, where, NULL, allocate_pvs))
+		return 0;
+
+	seg->segtype = new_segtype;
+
+	return 1;
+}
+
+/*
  * _alloc_rmeta_for_lv
  * @lv
  *


