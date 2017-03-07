From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 16:08:14 -0500
Subject: master - raid: fix raid LV resizing
Message-ID: <201703072108.v27L8E18027958@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18bbeec8257f2806770601db9483309c35cb5225
Commit:        18bbeec8257f2806770601db9483309c35cb5225
Parent:        9ed11e919187fcc6d2a0ab192937e3cebed08592
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 22:05:23 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 22:05:23 2017 +0100

raid: fix raid LV resizing

The lv_extend/_lv_reduce API doesn't cope with resizing RaidLVs
with allocated reshape space and ongoing conversions.  Prohibit
resizing during conversions and remove the reshape space before
processing resize.  Add missing seg->data_copies initialisation.

Fix typo/comment.
---
 lib/metadata/lv_manip.c          |   30 +++++++++++++++++++++++----
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   41 ++++++++++++++++++++++++++-----------
 3 files changed, 55 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b98391b..f0c3058 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1505,11 +1505,10 @@ int lv_reduce(struct logical_volume *lv, uint32_t extents)
 {
 	struct lv_segment *seg = first_seg(lv);
 
-	/* Ensure stipe boundary extents on RAID LVs */
+	/* Ensure stripe boundary extents on RAID LVs */
 	if (lv_is_raid(lv) && extents != lv->le_count)
 		extents =_round_to_stripe_boundary(lv->vg, extents,
 						   seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg), 0);
-
 	return _lv_reduce(lv, extents, 1);
 }
 
@@ -3943,7 +3942,7 @@ bad:
 static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				 struct logical_volume *lv,
 				 uint32_t extents, uint32_t first_area,
-				 uint32_t stripes, uint32_t stripe_size)
+				 uint32_t mirrors, uint32_t stripes, uint32_t stripe_size)
 {
 	const struct segment_type *segtype;
 	struct logical_volume *sub_lv, *meta_lv;
@@ -3971,7 +3970,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
 			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents / area_multiple,
-						   fa, stripes, stripe_size))
+						   fa, mirrors, stripes, stripe_size))
 				return_0;
 			fa += lv_mirror_count(seg_lv(seg, s));
 			continue;
@@ -3985,6 +3984,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			return 0;
 		}
 
+		last_seg(lv)->data_copies = mirrors;
+
 		/* Extend metadata LVs only on initial creation */
 		if (seg_is_raid_with_meta(seg) && !lv->le_count) {
 			if (!seg->meta_areas) {
@@ -4192,7 +4193,7 @@ int lv_extend(struct logical_volume *lv,
 		}
 
 		if (!(r = _lv_extend_layered_lv(ah, lv, new_extents - lv->le_count, 0,
-						stripes, stripe_size)))
+						mirrors, stripes, stripe_size)))
 			goto_out;
 
 		/*
@@ -5412,6 +5413,17 @@ int lv_resize(struct logical_volume *lv,
 	if (!_lvresize_check(lv, lp))
 		return_0;
 
+	if (seg->reshape_len) {
+		/* Prevent resizing on out-of-sync reshapable raid */
+		if (!lv_raid_in_sync(lv)) {
+			log_error("Can't resize reshaping LV %s.", display_lvname(lv));
+			return 0;
+		}
+		/* Remove any striped raid reshape space for LV resizing */
+		if (!lv_raid_free_reshape_space(lv))
+			return_0;
+	}
+
 	if (lp->use_policies) {
 		lp->extents = 0;
 		lp->sign = SIGN_PLUS;
@@ -5923,6 +5935,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int ask_discard;
 	struct lv_list *lvl;
 	struct seg_list *sl;
+	struct lv_segment *seg = first_seg(lv);
 	int is_last_pool = lv_is_pool(lv);
 
 	vg = lv->vg;
@@ -6029,6 +6042,13 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		is_last_pool = 1;
 	}
 
+	/* Special case removing a striped raid LV with allocated reshape space */
+	if (seg && seg->reshape_len) {
+		if (!(seg->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
+			return_0;
+		lv->le_count = seg->len = seg->area_len = seg_lv(seg, 0)->le_count * seg->area_count;
+	}
+
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if ((!lv_is_cache_pool(lv) || dm_list_empty(&lv->segs_using_this_lv)) &&
 	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 376fee9..4d02d04 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1243,6 +1243,7 @@ int lv_raid_change_region_size(struct logical_volume *lv,
                                int yes, int force, uint32_t new_region_size);
 int lv_raid_in_sync(const struct logical_volume *lv);
 uint32_t lv_raid_data_copies(const struct segment_type *segtype, uint32_t area_count);
+int lv_raid_free_reshape_space(const struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 40044f2..d109c0a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1312,7 +1312,7 @@ static int _lv_set_image_lvs_start_les(struct logical_volume *lv)
 }
 
 /*
- * Relocate @out_of_place_les_per_disk from @lv's data images  begin <-> end depending on @where
+ * Relocate @out_of_place_les_per_disk from @lv's data images begin <-> end depending on @where
  *
  * @where:
  * alloc_begin: end -> begin
@@ -1448,9 +1448,15 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 	out_of_place_les_per_disk = max(2048U, (unsigned) seg->stripe_size);
 	out_of_place_les_per_disk = (uint32_t) max(out_of_place_les_per_disk / (unsigned long long) lv->vg->extent_size, 1ULL);
 
+	if (!lv_is_active(lv)) {
+		log_error("Can't remove reshape space from inactive LV %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	/* Get data_offset and dev_sectors from the kernel */
 	if (!lv_raid_data_offset(lv, &data_offset)) {
-		log_error("Can't get data offset and dev size for %s from kernel.",
+		log_error("Can't get data offset for %s from kernel.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -1473,13 +1479,13 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 	}
 
 	/*
-	 * If we don't reshape space allocated extend the LV.
+	 * If we don't have reshape space allocated extend the LV.
 	 *
-	 * first_seg(lv)->reshape_len (only segment of top level raid LV)
-	 * is accounting for the data rimages so that unchanged
-	 * lv_extend()/lv_reduce() can be used to allocate/free,
-	 * because seg->len etc. still holds the whole size as before
-	 * including the reshape space
+	 * first_seg(lv)->reshape_len (only segment of top level raid LV
+	 * and first segment of the rimage sub LVs) are accounting for
+	 * the reshape space so that lv_extend()/lv_reduce() can be used
+	 * to allocate/free, because seg->len etc. still holds the whole
+	 * size as before including the reshape space
 	 */
 	if (out_of_place_les_per_disk) {
 		uint32_t data_rimages = _data_rimages_count(seg, seg->area_count);
@@ -1488,7 +1494,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		uint64_t lv_size = lv->size;
 
 		if (!lv_extend(lv, seg->segtype, data_rimages,
-			       seg->stripe_size, 1, seg->region_size,
+			       seg->stripe_size, 1, /* seg_is_any_raid10(seg) ? seg->data_copies : 1, */ seg->region_size,
 			       reshape_len /* # of reshape LEs to add */,
 			       allocate_pvs, lv->alloc, 0)) {
 			log_error("Failed to allocate out-of-place reshape space for %s.",
@@ -1600,6 +1606,11 @@ static int _lv_free_reshape_space(struct logical_volume *lv)
 	return _lv_free_reshape_space_with_status(lv, NULL);
 }
 
+int lv_raid_free_reshape_space(const struct logical_volume *lv)
+{
+	return _lv_free_reshape_space_with_status((struct logical_volume *) lv, NULL);
+}
+
 /*
  * HM
  *
@@ -1754,6 +1765,10 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	/* raid10 new image allocation can't cope with allocated reshape space. */
+	if (seg_is_any_raid10(seg) && !_lv_free_reshape_space(lv))
+		return_0;
+
 	/* Allocate new image component pairs for the additional stripes and grow LV size */
 	log_debug_metadata("Adding %u data and metadata image LV pair%s to %s.",
 			   new_image_count - old_image_count, new_image_count - old_image_count > 1 ? "s" : "",
@@ -4902,6 +4917,8 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	if (seg_is_raid1(seg))
 		seg->stripe_size = 0;
 
+	seg->data_copies = new_data_copies;
+
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 		return_0;
 
@@ -5125,6 +5142,8 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 
+	seg->data_copies = new_data_copies;
+
 	if (segtype_is_raid4(new_segtype) &&
 	    (!_shift_parity_dev(seg) ||
 	     !_rename_area_lvs(lv, "_"))) {
@@ -5133,9 +5152,6 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	} else if (segtype_is_raid10_near(new_segtype)) {
 		uint32_t s;
 
-		/* FIXME: raid10 ; needs to change once more than 2 data copies! */
-		seg->data_copies = 2;
-
 		log_debug_metadata("Reordering areas for raid0 -> raid10 takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_to_raid10_near))
 			return 0;
@@ -5889,6 +5905,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
+	/* FIXME: as long as we only support even numbers of raid10 SubLV pairs */
 	if (seg_is_raid10(seg))
 		stripes *= 2;
 


