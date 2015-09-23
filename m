From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Sep 2015 13:39:26 +0000 (UTC)
Subject: master - style: Miscellaneous tidying up of metadata/lv*
Message-ID: <20150923133926.8B0B660283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=192d9ad97769f2c16f3ebe67e51cfb287e67f67c
Commit:        192d9ad97769f2c16f3ebe67e51cfb287e67f67c
Parent:        cb82919b0d77ebeeb7d35d39b9c8584e806433bf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Sep 23 14:37:52 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 23 14:37:52 2015 +0100

style: Miscellaneous tidying up of metadata/lv*

---
 lib/metadata/lv.c       |    1 +
 lib/metadata/lv.h       |    4 +-
 lib/metadata/lv_manip.c |   48 ++++++++++++++++++++++++----------------------
 3 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8f3500c..e0080b1 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -648,6 +648,7 @@ int lv_raid_image_in_sync(const struct logical_volume *lv)
 
 	if ((seg = first_seg(lv)))
 		raid_seg = get_only_segment_using_this_lv(seg->lv);
+
 	if (!raid_seg) {
 		log_error("Failed to find RAID segment for %s", lv->name);
 		return 0;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index efd2a90..a839489 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -35,8 +35,8 @@ struct logical_volume {
 	int32_t major;
 	int32_t minor;
 
-	uint64_t size;		/* Sectors */
-	uint32_t le_count;
+	uint64_t size;		/* Sectors visible */
+	uint32_t le_count;	/* Logical extents visible */
 
 	uint32_t origin_count;
 	uint32_t external_count;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7e8301b..808b630 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -780,7 +780,7 @@ int get_default_region_size(struct cmd_context *cmd)
 
 	if (region_size & (region_size - 1)) {
 		region_size = _round_down_pow2(region_size);
-		log_verbose("Reducing mirror region size to %u kiB (power of 2).",
+		log_verbose("Reducing region size to %u kiB (power of 2).",
 			    region_size / 2);
 	}
 
@@ -930,7 +930,7 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 	dm_list_iterate_items(seg, &lv->segments) {
 		denominator += seg->area_len;
 
-	/* FIXME Generalise name of 'extents_copied' field */
+		/* FIXME Generalise name of 'extents_copied' field */
 		if ((seg_is_raid(seg) || seg_is_mirrored(seg)) &&
 		    (seg->area_count > 1))
 			numerator += seg->extents_copied;
@@ -938,7 +938,7 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 			numerator += seg->area_len;
 	}
 
-	return denominator ? dm_make_percent( numerator, denominator ) : 100.0;
+	return denominator ? dm_make_percent(numerator, denominator) : 100.0;
 }
 
 /*
@@ -1037,6 +1037,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 						uint32_t area_reduction, int with_discard)
 {
 	struct lv_segment *cache_seg;
+	struct logical_volume *lv = seg_lv(seg, s);
 
 	if (seg_type(seg, s) == AREA_UNASSIGNED)
 		return 1;
@@ -1054,10 +1055,10 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if (lv_is_mirror_image(seg_lv(seg, s)) ||
-	    lv_is_thin_pool_data(seg_lv(seg, s)) ||
-	    lv_is_cache_pool_data(seg_lv(seg, s))) {
-		if (!lv_reduce(seg_lv(seg, s), area_reduction))
+	if (lv_is_mirror_image(lv) ||
+	    lv_is_thin_pool_data(lv) ||
+	    lv_is_cache_pool_data(lv)) {
+		if (!lv_reduce(lv, area_reduction))
 			return_0; /* FIXME: any upper level reporting */
 		return 1;
 	}
@@ -1071,20 +1072,20 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 			return_0;
 	}
 
-	if (lv_is_raid_image(seg_lv(seg, s))) {
+	if (lv_is_raid_image(lv)) {
 		/*
 		 * FIXME: Use lv_reduce not lv_remove
 		 *  We use lv_remove for now, because I haven't figured out
 		 *  why lv_reduce won't remove the LV.
-		lv_reduce(seg_lv(seg, s), area_reduction);
+		lv_reduce(lv, area_reduction);
 		*/
 		if (area_reduction != seg->area_len) {
 			log_error("Unable to reduce RAID LV - operation not implemented.");
 			return_0;
 		} else {
-			if (!lv_remove(seg_lv(seg, s))) {
+			if (!lv_remove(lv)) {
 				log_error("Failed to remove RAID image %s",
-					  seg_lv(seg, s)->name);
+					  lv->name);
 				return 0;
 			}
 		}
@@ -1105,9 +1106,9 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
 				 "the top of LV %s:%" PRIu32,
 				 seg->lv->name, seg->le, s,
-				 seg_lv(seg, s)->name, seg_le(seg, s));
+				 lv->name, seg_le(seg, s));
 
-		if (!remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg))
+		if (!remove_seg_from_segs_using_this_lv(lv, seg))
 			return_0;
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
@@ -1460,10 +1461,10 @@ struct alloc_handle {
 	struct dm_pool *mem;
 
 	alloc_policy_t alloc;		/* Overall policy */
-	int approx_alloc;                /* get as much as possible up to new_extents */
+	int approx_alloc;		/* get as much as possible up to new_extents */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
-	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
+	uint32_t parity_count;		/* Adds to area_count, but not area_multiple */
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
 	uint32_t log_area_count;	/* Number of parallel logs */
 	uint32_t metadata_area_count;   /* Number of parallel metadata areas */
@@ -1519,6 +1520,7 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 		 */
 		if (area_count <= segtype->parity_devs)
 			return 1;
+
 		return area_count - segtype->parity_devs;
 	}
 
@@ -1744,7 +1746,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 
 	extents = aa[0].len * area_multiple;
 	lv->le_count += extents;
-	lv->size += (uint64_t) extents *lv->vg->extent_size;
+	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
 	return 1;
 }
@@ -1910,7 +1912,7 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 		*max_seg_len = remaining_seg_len;
 
 	area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
-	area_len = remaining_seg_len / area_multiple ? : 1;
+	area_len = remaining_seg_len / (area_multiple ? : 1);
 
 	/* For striped mirrors, all the areas are counted, through the mirror layer */
 	if (top_level_area_index == -1)
@@ -2956,7 +2958,7 @@ static int _allocate(struct alloc_handle *ah,
 
         if (ah->area_multiple > 1 &&
             (ah->new_extents - alloc_state.allocated) % ah->area_multiple) {
-		log_error("Number of extents requested (%d) needs to be divisible by %d.",
+		log_error("Number of extents requested (" FMTu32 ") needs to be divisible by " FMTu32 ".",
 			  ah->new_extents - alloc_state.allocated,
 			  ah->area_multiple);
 		return 0;
@@ -3765,23 +3767,23 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 {
 	const struct segment_type *segtype;
 	struct logical_volume *sub_lv, *meta_lv;
-	struct lv_segment *seg;
+	struct lv_segment *seg = first_seg(lv);
 	uint32_t fa, s;
 	int clear_metadata = 0;
 
-	segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED);
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
 
 	/*
 	 * The component devices of a "striped" LV all go in the same
 	 * LV.  However, RAID has an LV for each device - making the
 	 * 'stripes' and 'stripe_size' parameters meaningless.
 	 */
-	if (seg_is_raid(first_seg(lv))) {
+	if (seg_is_raid(seg)) {
 		stripes = 1;
 		stripe_size = 0;
 	}
 
-	seg = first_seg(lv);
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
 			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
@@ -5173,7 +5175,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 				log_error("Filesystem check failed.");
 				return NULL;
 			}
-			/* some filesystems supports online resize */
+			/* some filesystems support online resize */
 		}
 
 		/* FIXME forks here */


