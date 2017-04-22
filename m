From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Sat, 22 Apr 2017 01:00:23 -0400
Subject: master - raid: handle insufficent PVs on takeover to/from raid4
Message-ID: <201704220500.v3M50Nd5009715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f305f025ed862689a8b4e34557e6a469201cba0
Commit:        8f305f025ed862689a8b4e34557e6a469201cba0
Parent:        97a5fa4b876ea861a5927ff714b617bb4c72efbc
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 22 01:19:44 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 22 01:19:44 2017 +0200

raid: handle insufficent PVs on takeover to/from raid4

Commit 7bc85177b08c7a6f4f0c3384c8d05b9089267c14
felt short relative to striped/raid0* -> raid4
and raid4 -> raid6.

Related: rhbz1438013
---
 lib/metadata/raid_manip.c |  150 +++++++++++++++++++++++++++++++++------------
 1 files changed, 110 insertions(+), 40 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1563110..b708442 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -138,6 +138,18 @@ static void _check_and_adjust_region_size(const struct logical_volume *lv)
 	seg->region_size = raid_ensure_min_region_size(lv, lv->size, seg->region_size);
 }
 
+/* Drop @suffix from *str by writing '\0' to the beginning of @suffix */
+static int _drop_suffix(const char *str, const char *suffix)
+{
+	char *p;
+
+	if (!(p = strstr(str, suffix)))
+		return_0;
+
+	*p = '\0';
+	return 1;
+}
+
 /* Strip any raid suffix off LV name */
 char *top_level_lv_name(struct volume_group *vg, const char *lv_name)
 {
@@ -3386,6 +3398,27 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 	return 1;
 }
 
+/* Add new @lv to @seg at area index @idx */
+static int _add_component_lv(struct lv_segment *seg, struct logical_volume *lv, uint64_t lv_flags, uint32_t idx)
+{
+	if (lv_flags & VISIBLE_LV)
+		lv_set_visible(lv);
+	else
+		lv_set_hidden(lv);
+
+	if (lv_flags & LV_REBUILD)
+		lv->status |= LV_REBUILD;
+	else
+		lv->status &= ~LV_REBUILD;
+
+	if (!set_lv_segment_area_lv(seg, idx, lv, 0 /* le */, lv->status)) {
+		log_error("Failed to add sublv %s.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Add new @lvs to @lv at @area_offset */
 static int _add_image_component_list(struct lv_segment *seg, int delete_from_list,
 				     uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)
@@ -3396,22 +3429,8 @@ static int _add_image_component_list(struct lv_segment *seg, int delete_from_lis
 	dm_list_iterate_items_safe(lvl, tmp, lvs) {
 		if (delete_from_list)
 			dm_list_del(&lvl->list);
-
-		if (lv_flags & VISIBLE_LV)
-			lv_set_visible(lvl->lv);
-		else
-			lv_set_hidden(lvl->lv);
-
-		if (lv_flags & LV_REBUILD)
-			lvl->lv->status |= LV_REBUILD;
-		else
-			lvl->lv->status &= ~LV_REBUILD;
-
-		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0 /* le */, lvl->lv->status)) {
-			log_error("Failed to add sublv %s.",
-				  display_lvname(lvl->lv));
+		if (!_add_component_lv(seg, lvl->lv, lv_flags, s++))
 			return 0;
-		}
 	}
 
 	return 1;
@@ -5026,12 +5045,30 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 	return 1;
 }
 
+/* Set sizes of @lv on takeover upconvert */
+static void _set_takeover_upconvert_sizes(struct logical_volume *lv,
+					  const struct segment_type *new_segtype,
+					  uint32_t region_size, uint32_t stripe_size,
+					  uint32_t extents_copied, uint32_t seg_len) {
+	struct lv_segment *seg = first_seg(lv);
+
+	seg->segtype = new_segtype;
+	seg->region_size = region_size;
+	seg->stripe_size = stripe_size;
+	seg->extents_copied = extents_copied;
+
+	/* FIXME Hard-coded to raid4/5/6/10 */
+	lv->le_count = seg->len = seg->area_len = seg_len;
+
+	_check_and_adjust_region_size(lv);
+}
+
 /* Helper: striped/raid0/raid0_meta/raid1 -> raid4/5/6/10, raid45 -> raid6 wrapper */
 static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 {
 	uint32_t extents_copied, region_size, seg_len, stripe_size;
 	struct lv_segment *seg = first_seg(lv);
-	const struct segment_type *initial_segtype = seg->segtype;
+	const struct segment_type *raid5_n_segtype, *initial_segtype = seg->segtype;
 	struct dm_list removal_lvs;
 
 	dm_list_init(&removal_lvs);
@@ -5077,11 +5114,9 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		}
 
 		if (!new_stripe_size)
-			new_stripe_size = 128;
+			new_stripe_size = 2 * DEFAULT_STRIPESIZE;
 	}
 
-	region_size = seg->region_size;
-
 	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
 		return 0;
 
@@ -5100,23 +5135,25 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 			return_0;
 	}
 
-	/* Add metadata LVs */
+	/* Add metadata LVs in case of raid0 */
 	if (seg_is_raid0(seg)) {
 		log_debug_metadata("Adding metadata LVs to %s.", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, NULL))
 			return 0;
-	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role change issues in the kernel */
 	}
 
+	/* Have to be cleared in conversion from raid0_meta -> raid4 or kernel will reject due to reordering disks */
 	if (segtype_is_raid0_meta(initial_segtype) &&
 	    segtype_is_raid4(new_segtype) &&
 	    !_clear_meta_lvs(lv))
 		return_0;
 
+	region_size = new_region_size ?: seg->region_size;
+	stripe_size = new_stripe_size ?: seg->stripe_size;
 	extents_copied = seg->extents_copied;
 	seg_len = seg->len;
-	stripe_size = seg->stripe_size;
 
+	/* In case of raid4/5, adjust to allow for allocation of additonal image pairs */
 	if (seg_is_raid4(seg) || seg_is_any_raid5(seg)) {
 		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
 			return_0;
@@ -5140,7 +5177,8 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 			 *
 			 * - initial type is raid0 -> just remove remove metadata devices
 			 *
-			 * - initial type is striped -> convert back to it (removes metadata devices)
+			 * - initial type is striped -> convert back to it
+			 *   (removes metadata and image devices)
 			 */
 			if (segtype_is_raid0(initial_segtype) &&
 			    !_raid0_add_or_remove_metadata_lvs(lv, 0, NULL, &removal_lvs))
@@ -5157,6 +5195,52 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		seg = first_seg(lv);
 	}
 
+	/* Process raid4 (up)converts */
+	if (segtype_is_raid4(initial_segtype)) {
+		if (!(raid5_n_segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID5_N)))
+			return_0;
+
+		/* raid6 upconvert: vonvert to raid5_n preserving already allocated new image component pair */
+		if (segtype_is_any_raid6(new_segtype)) {
+			struct logical_volume *meta_lv, *data_lv;
+
+			if (new_image_count != seg->area_count)
+				return_0;
+
+			log_debug_metadata ("Extracting last image component pair of %s temporarily.",
+					    display_lvname(lv));
+			if (!_extract_image_components(seg, seg->area_count - 1, &meta_lv, &data_lv))
+				return_0;
+
+			_set_takeover_upconvert_sizes(lv, initial_segtype,
+						      region_size, stripe_size,
+						      extents_copied, seg_len);
+			seg->area_count--;
+
+			if (!_raid45_to_raid54_wrapper(lv, raid5_n_segtype, yes, force, seg->area_count,
+						       1 /* data_copies */, 0, 0, 0, allocate_pvs))
+				return 0;
+
+			if (!_drop_suffix(meta_lv->name, "_extracted") ||
+			    !_drop_suffix(data_lv->name, "_extracted"))
+				return 0;
+
+			data_lv->status |= RAID_IMAGE;
+			meta_lv->status |= RAID_META;
+			seg->area_count++;
+
+			log_debug_metadata ("Adding extracted last image component pair back to %s to convert to %s.",
+					    display_lvname(lv), new_segtype->name);
+			if (!_add_component_lv(seg, meta_lv, LV_REBUILD, seg->area_count - 1) ||
+			    !_add_component_lv(seg, data_lv, LV_REBUILD, seg->area_count - 1))
+				return_0;
+
+		} else if (segtype_is_raid5_n(new_segtype) &&
+			   !_raid45_to_raid54_wrapper(lv, raid5_n_segtype, yes, force, seg->area_count,
+						      1 /* data_copies */, 0, 0, 0, allocate_pvs))
+			return 0;
+	}
+
 	seg->data_copies = new_data_copies;
 
 	if (segtype_is_raid4(new_segtype) &&
@@ -5181,15 +5265,9 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 
 	}
 
-	seg->segtype = new_segtype;
-	seg->region_size = new_region_size ?: region_size;
-	seg->stripe_size = new_stripe_size ?: stripe_size;
-	seg->extents_copied = extents_copied;
-
-	/* FIXME Hard-coded to raid4/5/6/10 */
-	lv->le_count = seg->len = seg->area_len = seg_len;
-
-	_check_and_adjust_region_size(lv);
+	_set_takeover_upconvert_sizes(lv, new_segtype,
+				      region_size, stripe_size,
+				      extents_copied, seg_len);
 
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
@@ -5455,14 +5533,6 @@ static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 {
-	if (seg_is_raid4(first_seg(lv))) {
-		struct segment_type *segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID5_N);
-
-		if (!segtype ||
-		    !_raid45_to_raid54_wrapper(lv, segtype, yes, force, first_seg(lv)->area_count,
-					       1 /* data_copies */, 0, 0, 0, allocate_pvs))
-			return 0;
-	}
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count + 1 /* new_image_count */,
 					   3 /* data_copies */, 0, new_stripe_size,


