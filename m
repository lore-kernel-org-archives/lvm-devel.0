From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:44:39 +0000 (UTC)
Subject: master - raid: Infrastructure for raid takeover.
Message-ID: <20160628014439.D0280616D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79446ffad7358dd8c130ff498514150d1e0ea08b
Commit:        79446ffad7358dd8c130ff498514150d1e0ea08b
Parent:        ff3c4ed1c0e2e554e9fb5f9b7ff20fdf5a835852
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 28 02:42:30 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:42:30 2016 +0100

raid: Infrastructure for raid takeover.

---
 WHATS_NEW                        |    1 +
 lib/config/defaults.h            |    3 +-
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/raid_manip.c        |  490 ++++++++++++++++++++++++++++++++++++--
 lib/metadata/takeover_matrix.h   |  120 ++++++++++
 tools/lvconvert.c                |    7 +-
 6 files changed, 596 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cfa707f..3184412 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.159 - 
 =================================
+  Add infrastructure for raid takeover lvconvert options.
 
 Version 2.02.158 - 25th June 2016
 =================================
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3d449ff..addb14f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -66,7 +66,8 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
-#define DEFAULT_RAID_MAX_IMAGES 8
+// FIXME Increase this to 64
+#define DEFAULT_RAID_MAX_IMAGES 8 /* limited by kernel failed devices bitfield in superblock (raid4/5/6 max 253) */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f47fa1d..7765d23 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1196,7 +1196,6 @@ int lv_raid_merge(struct logical_volume *lv);
 int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,
 		    int yes, int force,
-		    const unsigned image_count,
 		    const unsigned stripes,
 		    const unsigned new_stripe_size,
 		    struct dm_list *allocate_pvs);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 132eef3..2cef777 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -96,7 +96,7 @@ static int _raid_in_sync(struct logical_volume *lv)
 	if (sync_percent == DM_PERCENT_0) {
 		/*
 		 * FIXME We repeat the status read here to workaround an
-		 * unresolved kernel bug when we see 0 even though the 
+		 * unresolved kernel bug when we see 0 even though the
 		 * the array is 100% in sync.
 		 * https://bugzilla.redhat.com/1210637
 		 */
@@ -174,9 +174,9 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
  * @lv
  *
  * If LV is active:
- *        clear first block of device
+ *	clear first block of device
  * otherwise:
- *        activate, clear, deactivate
+ *	activate, clear, deactivate
  *
  * Returns: 1 on success, 0 on failure
  */
@@ -839,10 +839,10 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
  * @new_count:  The absolute count of images (e.g. '2' for a 2-way mirror)
  * @target_pvs:  The list of PVs that are candidates for removal
  * @shift:  If set, use _shift_and_rename_image_components().
- *          Otherwise, leave the [meta_]areas as AREA_UNASSIGNED and
- *          seg->area_count unchanged.
+ *	  Otherwise, leave the [meta_]areas as AREA_UNASSIGNED and
+ *	  seg->area_count unchanged.
  * @extracted_[meta|data]_lvs:  The LVs removed from the array.  If 'shift'
- *                              is set, then there will likely be name conflicts.
+ *		              is set, then there will likely be name conflicts.
  *
  * This function extracts _both_ portions of the indexed image.  It
  * does /not/ commit the results.  (IOW, erroring-out requires no unwinding
@@ -851,9 +851,9 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
  * Returns: 1 on success, 0 on failure
  */
 static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
-			        struct dm_list *target_pvs, int shift,
-			        struct dm_list *extracted_meta_lvs,
-			        struct dm_list *extracted_data_lvs)
+				struct dm_list *target_pvs, int shift,
+				struct dm_list *extracted_meta_lvs,
+				struct dm_list *extracted_data_lvs)
 {
 	int ss, s, extract, lvl_idx = 0;
 	struct lv_list *lvl_array;
@@ -1461,9 +1461,428 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 }
 
 /*
- * lv_raid_reshape
- * @lv
- * @new_segtype
+ * Individual takeover functions.
+ */
+#define TAKEOVER_FN_ARGS			\
+	struct logical_volume *lv,		\
+	const struct segment_type *new_segtype,	\
+	int yes,				\
+	int force,				\
+	unsigned new_image_count,		\
+	const unsigned new_stripes,		\
+	unsigned new_stripe_size,		\
+	struct dm_list *allocate_pvs
+
+typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);
+
+/*
+ * Common takeover functions.
+ */
+static int _takeover_noop(TAKEOVER_FN_ARGS)
+{
+	log_error("Logical volume %s is already of requested type %s",
+		  display_lvname(lv), lvseg_name(first_seg(lv)));
+
+	return 0;
+}
+
+static int _takeover_unsupported(TAKEOVER_FN_ARGS)
+{
+	log_error("Converting the segment type for %s from %s to %s is not supported.",
+		  display_lvname(lv), lvseg_name(first_seg(lv)), new_segtype->name);
+
+	return 0;
+}
+
+/*
+ * Will this particular takeover combination be possible?
+ */
+static int _takeover_not_possible(takeover_fn_t takeover_fn)
+{
+	if (takeover_fn == _takeover_noop || takeover_fn == _takeover_unsupported)
+		return 0;
+
+	return 1;
+}
+
+static int _takeover_unsupported_yet(const struct logical_volume *lv, const struct segment_type *new_segtype)
+{
+	log_error("Converting the segment type for %s from %s to %s is not supported yet.",
+		  display_lvname(lv), lvseg_name(first_seg(lv)), new_segtype->name);
+
+	return 0;
+}
+
+/*
+ * Customised takeover functions
+ */
+static int _takeover_from_linear_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_linear_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_linear_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_linear_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_mirrored_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_mirrored_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_mirrored_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _convert_mirror_to_raid1(lv, new_segtype);
+}
+
+static int _takeover_from_mirrored_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_mirrored_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_linear(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_mirrored(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+/*
+static int _takeover_from_raid0_meta_to_linear(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_mirrored(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid0_meta_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+*/
+
+static int _takeover_from_raid1_to_linear(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_mirrored(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid1_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_linear(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_mirrored(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid01(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+/*
+static int _takeover_from_raid01_to_raid01(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid01_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid01_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_linear(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_mirrored(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_raid0(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_raid01(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_raid0_meta(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_raid1(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_raid10(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+
+static int _takeover_from_raid10_to_striped(TAKEOVER_FN_ARGS)
+{
+	return _takeover_unsupported_yet(lv, new_segtype);
+}
+*/
+
+/*
+ * Import takeover matrix.
+ */
+#include "takeover_matrix.h"
+
+static unsigned _segtype_ix(const struct segment_type *segtype, uint32_t area_count)
+{
+	int i = 2, j;
+
+	/* Linear special case */
+	if (segtype_is_striped(segtype)) {
+		if (area_count == 1)
+			return 0;	/* linear */
+		if (!segtype_is_raid0(segtype))
+			return 1;	/* striped */
+	}
+
+	while ((j = _segtype_index[i++]))
+		if (segtype->flags & j)
+			break;
+
+	return (i - 1);
+}
+
+/* Call appropriate takeover function */
+static takeover_fn_t _get_takeover_fn(const struct lv_segment *seg, const struct segment_type *new_segtype, unsigned new_image_count)
+{
+	return _takeover_fns[_segtype_ix(seg->segtype, seg->area_count)][_segtype_ix(new_segtype, new_image_count)];
+}
+
+/*
+ * Check for maximum number of raid devices.
+ * Constrained by kernel MD maximum device limits _and_ dm-raid superblock
+ * bitfield constraints.
+ */
+static int _check_max_raid_devices(uint32_t image_count)
+{
+	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
+		log_error("Unable to handle arrays with more than %u devices",
+			  DEFAULT_RAID_MAX_IMAGES);
+		return 0;
+	}
+	return 1;
+}
+
+/* Number of data (not parity) rimages */
+static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t total_rimages)
+{
+	return total_rimages - seg->segtype->parity_devs;
+}
+
+/*
+ * lv_raid_convert
  *
  * Convert an LV from one RAID type (or 'mirror' segtype) to another.
  *
@@ -1472,33 +1891,60 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,
 		    int yes, int force,
-		    unsigned new_image_count,
 		    const unsigned new_stripes,
 		    const unsigned new_stripe_size,
 		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
+	uint32_t stripes, stripe_size;
+	uint32_t new_image_count = seg->area_count;
+	takeover_fn_t takeover_fn;
 
 	if (!new_segtype) {
 		log_error(INTERNAL_ERROR "New segtype not specified");
 		return 0;
 	}
 
+	if (!_check_max_raid_devices(new_image_count))
+		return_0;
+
+	stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
+
+	/* FIXME Ensure caller does *not* set wrong default value! */
+	/* Define new stripe size if not passed in */
+	stripe_size = new_stripe_size ?: seg->stripe_size;
+
+	takeover_fn = _get_takeover_fn(first_seg(lv), new_segtype, new_image_count);
+
+	/* Exit without doing activation checks if the combination isn't possible */
+	if (_takeover_not_possible(takeover_fn))
+		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, new_stripe_size, allocate_pvs);
+
+	/* FIXME If not active, prompt and activate */
+	/* LV must be active to perform raid conversion operations */
+	if (!lv_is_active(lv)) {
+		log_error("%s must be active to perform this operation.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	/* In clustered VGs, the LV must be active on this node exclusively. */
 	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
-		log_error("%s/%s must be active exclusive locally to"
-			  " perform this operation.", lv->vg->name, lv->name);
+		log_error("%s must be active exclusive locally to "
+			  "perform this operation.", display_lvname(lv));
 		return 0;
 	}
 
-	if (seg_is_mirror(seg) && segtype_is_raid1(new_segtype))
-		return _convert_mirror_to_raid1(lv, new_segtype);
+	/* LV must be in sync. */
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync",
+			  display_lvname(lv));
+		return 0;
+	}
 
-	log_error("Converting the segment type for %s/%s from %s to %s is not yet supported.",
-		  lv->vg->name, lv->name, lvseg_name(seg), new_segtype->name);
-	return 0;
+	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, new_stripe_size, allocate_pvs);
 }
 
-
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 					       struct dm_list *remove_pvs)
 {
@@ -1876,7 +2322,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	 */
 
 	for (s = 0; s < seg->area_count; s++) {
-		if (!lv_is_partial(seg_lv(seg, s)) && 
+		if (!lv_is_partial(seg_lv(seg, s)) &&
 		    (!seg->meta_areas || !seg_metalv(seg, s) || !lv_is_partial(seg_metalv(seg, s))))
 			continue;
 
diff --git a/lib/metadata/takeover_matrix.h b/lib/metadata/takeover_matrix.h
new file mode 100644
index 0000000..25a8197
--- /dev/null
+++ b/lib/metadata/takeover_matrix.h
@@ -0,0 +1,120 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#define N _takeover_noop
+#define X _takeover_unsupported
+
+#define lin_r0   _takeover_from_linear_to_raid0
+#define lin_r0   _takeover_from_linear_to_raid0
+#define lin_r1   _takeover_from_linear_to_raid1
+#define lin_r10  _takeover_from_linear_to_raid10
+#define lin_r45  _takeover_from_linear_to_raid45
+#define mir_r0   _takeover_from_mirrored_to_raid0
+#define mir_r0m  _takeover_from_mirrored_to_raid0_meta
+#define mir_r1   _takeover_from_mirrored_to_raid1
+#define mir_r10  _takeover_from_mirrored_to_raid10
+#define mir_r45  _takeover_from_mirrored_to_raid45
+#define r01_r01  _takeover_from_raid01_to_raid01
+#define r01_r10  _takeover_from_raid01_to_raid10
+#define r01_str  _takeover_from_raid01_to_striped
+#define r0__lin  _takeover_from_raid0_to_linear
+#define r0__mir  _takeover_from_raid0_to_mirrored
+#define r0m_lin  _takeover_from_raid0_meta_to_linear
+#define r0m_mir  _takeover_from_raid0_meta_to_mirrored
+#define r0m_r0   _takeover_from_raid0_meta_to_raid0
+#define r0m_r1   _takeover_from_raid0_meta_to_raid1
+#define r0m_r10  _takeover_from_raid0_meta_to_raid10
+#define r0m_r45  _takeover_from_raid0_meta_to_raid45
+#define r0m_r6   _takeover_from_raid0_meta_to_raid6
+#define r0m_str  _takeover_from_raid0_meta_to_striped
+#define r0__r0m  _takeover_from_raid0_to_raid0_meta
+#define r0__r1   _takeover_from_raid0_to_raid1
+#define r0__r10  _takeover_from_raid0_to_raid10
+#define r0__r45  _takeover_from_raid0_to_raid45
+#define r0__r6   _takeover_from_raid0_to_raid6
+#define r0__str  _takeover_from_raid0_to_striped
+#define r10_lin  _takeover_from_raid10_to_linear
+#define r10_mir  _takeover_from_raid10_to_mirrored
+#define r10_r0   _takeover_from_raid10_to_raid0
+#define r10_r01  _takeover_from_raid10_to_raid01
+#define r10_r0m  _takeover_from_raid10_to_raid0_meta
+#define r10_r1   _takeover_from_raid10_to_raid1
+#define r10_r10  _takeover_from_raid10_to_raid10
+#define r10_str  _takeover_from_raid10_to_striped
+#define r1__lin  _takeover_from_raid1_to_linear
+#define r1__mir  _takeover_from_raid1_to_mirrored
+#define r1__r0   _takeover_from_raid1_to_raid0
+#define r1__r0m  _takeover_from_raid1_to_raid0_meta
+#define r1__r1   _takeover_from_raid1_to_raid1
+#define r1__r10  _takeover_from_raid1_to_raid10
+#define r1__r45  _takeover_from_raid1_to_raid45
+#define r1__str  _takeover_from_raid1_to_striped
+#define r45_lin  _takeover_from_raid45_to_linear
+#define r45_mir  _takeover_from_raid45_to_mirrored
+#define r45_r0   _takeover_from_raid45_to_raid0
+#define r45_r0m  _takeover_from_raid45_to_raid0_meta
+#define r45_r1   _takeover_from_raid45_to_raid1
+#define r45_r54  _takeover_from_raid45_to_raid54
+#define r45_r6   _takeover_from_raid45_to_raid6
+#define r45_str  _takeover_from_raid45_to_striped
+#define r6__r0   _takeover_from_raid6_to_raid0
+#define r6__r0m  _takeover_from_raid6_to_raid0_meta
+#define r6__r45  _takeover_from_raid6_to_raid45
+#define r6__str  _takeover_from_raid6_to_striped
+#define str_r0   _takeover_from_striped_to_raid0
+#define str_r01  _takeover_from_striped_to_raid01
+#define str_r0m  _takeover_from_striped_to_raid0_meta
+#define str_r10  _takeover_from_striped_to_raid10
+#define str_r45  _takeover_from_striped_to_raid45
+#define str_r6   _takeover_from_striped_to_raid6
+
+static uint64_t _segtype_index[] = {
+	1, /* linear */
+	1, /* striped */
+	SEG_MIRROR,
+	SEG_RAID0,
+	// SEG_RAID0_META,
+	SEG_RAID1,
+	SEG_RAID4 | SEG_RAID5_LS | SEG_RAID5_LA | SEG_RAID5_LS | SEG_RAID5_RS | SEG_RAID5_RA | SEG_RAID5_N,
+	SEG_RAID6_LS_6 | SEG_RAID6_LA_6 | SEG_RAID6_RS_6 | SEG_RAID6_RA_6 | SEG_RAID6_NC | SEG_RAID6_NR | SEG_RAID6_ZR | SEG_RAID6_N_6,
+	0, // SEG_RAID10_NEAR | SEG_RAID10_FAR | SEG_RAID10_OFFSET,
+	0, // SEG_RAID01,
+	0
+};
+
+/*
+ * Matrix of takeover functions.
+ * Row corresponds to original segment type.
+ * Column corresponds to new segment type.
+ * N represents a combination that has no effect (no-op).
+ * X represents a combination that is unsupported.
+ */
+static takeover_fn_t _takeover_fns[][11] = {
+        /* from, to ->    linear     striped   mirror    raid0    raid0_meta raid1   raid4/5   raid6    raid10    raid01   other*/
+        /*   | */
+        /*   v */
+        /* linear     */ { N      ,  X      ,  X      ,  lin_r0,  lin_r0 ,  lin_r1,  lin_r45,  X     ,  lin_r10,  X      , X },
+        /* striped    */ { X      ,  N      ,  X      ,  str_r0,  str_r0m,  lin_r1,  str_r45,  str_r6,  str_r10,  str_r01, X },
+        /* mirror     */ { X      ,  X      ,  N      ,  mir_r0,  mir_r0m,  mir_r1,  mir_r45,  X     ,  mir_r10,  X      , X },
+        /* raid0      */ { r0__lin,  r0__str,  r0__mir,  N     ,  r0__r0m,  r0__r1,  r0__r45,  r0__r6,  r0__r10,  X      , X },
+        /* raid0_meta */ // { r0m_lin,  r0m_str,  r0m_mir,  r0m_r0,  N      ,  r0m_r1,  r0m_r45,  r0m_r6,  r0m_r10,  X      , X },
+        /* raid1      */ { r1__lin,  r1__str,  r1__mir,  r1__r0,  r1__r0m,  r1__r1,  r1__r45,  X     ,  r1__r10,  X      , X },
+        /* raid4/5    */ { r45_lin,  r45_str,  r45_mir,  r45_r0,  r45_r0m,  r45_r1,  r45_r54,  r45_r6,  X      ,  X      , X },
+        /* raid6      */ { X      ,  r6__str,  X      ,  r6__r0,  r6__r0m,  X     ,  r6__r45,  X     ,  X      ,  X      , X },
+        /* raid10     */ // { r10_lin,  r10_str,  r10_mir,  r10_r0,  r10_r0m,  r10_r1,  X      ,  X     ,  r10_r10,  r10_r01, X },
+        /* raid01     */ // { X      ,  r01_str,  X      ,  X     ,  X      ,  X     ,  X      ,  X     ,  r01_r10,  r01_r01, X },
+        /* other      */ { X      ,  X      ,  X      ,  X     ,  X      ,  X     ,  X      ,  X     ,  X      ,  X      , X },
+};
+#undef X
+#undef N
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f99291a..65143a1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1845,13 +1845,16 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
-	    ((lp->type_str && lp->type_str[0]) || image_count)) {
+	    (lp->type_str && lp->type_str[0])) {
 		if (segtype_is_any_raid0(lp->segtype) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
 			log_error("RAID module does not support RAID0.");
 			return 0;
 		}
-		return lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, image_count, lp->stripes, lp->stripe_size, lp->pvh);
+		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size, lp->pvh))
+			return_0;
+		log_print_unless_silent("Logical volume %s successfully converted", display_lvname(lv));
+		return 1;
 	}
 
 	if (lp->replace)


