From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Apr 2010 01:00:13 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20100409010013.26895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-09 01:00:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h mirror.c 
	tools          : lvconvert.c lvcreate.c lvresize.c pvmove.c 

Log message:
	Permit mimage LVs to be striped in lvcreate and lvresize.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1506&r2=1.1507
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2010/04/08 00:28:57	1.1506
+++ LVM2/WHATS_NEW	2010/04/09 01:00:10	1.1507
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Permit mimage LVs to be striped in lvcreate and lvresize.
   Fix pvmove allocation to take existing parallel stripes into account.
   Add pvmove_source_seg to struct lv_segment.
   Fix incorrect removal of symlinks after LV deactivation fails.
--- LVM2/lib/metadata/lv_manip.c	2010/04/08 00:56:26	1.227
+++ LVM2/lib/metadata/lv_manip.c	2010/04/09 01:00:11	1.228
@@ -526,13 +526,22 @@
 	struct dm_list alloced_areas[0];
 };
 
-static uint32_t calc_area_multiple(const struct segment_type *segtype,
-				   const uint32_t area_count)
+static uint32_t _calc_area_multiple(const struct segment_type *segtype,
+				    const uint32_t area_count, const uint32_t stripes)
 {
-	if (!segtype_is_striped(segtype) || !area_count)
+	if (!area_count)
 		return 1;
 
-	return area_count;
+	/* Striped */
+	if (segtype_is_striped(segtype))
+		return area_count;
+
+	/* Mirrored stripes */
+	if (stripes)
+		return stripes;
+
+	/* Mirrored */
+	return 1;
 }
 
 /*
@@ -559,6 +568,8 @@
 
 /*
  * Preparation for a specific allocation attempt
+ * stripes and mirrors refer to the parallel areas used for data.
+ * If log_area_count > 1 it is always mirrored (not striped).
  */
 static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_pool *mem,
@@ -575,20 +586,14 @@
 	struct alloc_handle *ah;
 	uint32_t s, area_count;
 
-	if (stripes > 1 && mirrors > 1) {
-		log_error("Striped mirrors are not supported yet");
-		return NULL;
-	}
-
-	if (log_area_count && stripes > 1) {
-		log_error("Can't mix striping with a mirror log yet.");
-		return NULL;
-	}
+	/* FIXME Caller should ensure this */
+	if (mirrors && !stripes)
+		stripes = 1;
 
 	if (segtype_is_virtual(segtype))
 		area_count = 0;
 	else if (mirrors > 1)
-		area_count = mirrors;
+		area_count = mirrors * stripes;
 	else
 		area_count = stripes;
 
@@ -617,7 +622,7 @@
 	ah->log_area_count = log_area_count;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
-	ah->area_multiple = calc_area_multiple(segtype, area_count);
+	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
 
 	ah->log_len = log_area_count ? mirror_log_extents(ah->region_size, extent_size, ah->new_extents / ah->area_multiple) : 0;
 
@@ -688,7 +693,7 @@
 	uint32_t s, extents, area_multiple;
 	struct lv_segment *seg;
 
-	area_multiple = calc_area_multiple(segtype, area_count);
+	area_multiple = _calc_area_multiple(segtype, area_count, 0);
 
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count,
@@ -801,6 +806,20 @@
 	return 1;
 }
 
+/* For striped mirrors, all the areas are counted, through the mirror layer */
+static uint32_t _stripes_per_mimage(struct lv_segment *seg)
+{
+	struct lv_segment *last_lvseg;
+
+	if (seg_is_mirrored(seg) && seg->area_count && seg_type(seg, 0) == AREA_LV) {
+		last_lvseg = dm_list_item(dm_list_last(&seg_lv(seg, 0)->segments), struct lv_segment);
+		if (seg_is_striped(last_lvseg))
+			return last_lvseg->area_count;
+	}
+
+	return 1;
+}
+
 /*
  * Call fn for each AREA_PV used by the LV segment at lv:le of length *max_seg_len.
  * If any constituent area contains more than one segment, max_seg_len is
@@ -821,6 +840,7 @@
 {
 	uint32_t s;
 	uint32_t remaining_seg_len, area_len, area_multiple;
+	uint32_t stripes_per_mimage = 1;
 	int r = 1;
 
 	if (!seg && !(seg = find_seg_by_le(lv, le))) {
@@ -838,9 +858,13 @@
 	if (max_seg_len && *max_seg_len > remaining_seg_len)
 		*max_seg_len = remaining_seg_len;
 
-	area_multiple = calc_area_multiple(seg->segtype, seg->area_count);
+	area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
 	area_len = remaining_seg_len / area_multiple ? : 1;
 
+	/* For striped mirrors, all the areas are counted, through the mirror layer */
+	if (top_level_area_index == -1)
+		stripes_per_mimage = _stripes_per_mimage(seg);
+
 	for (s = first_area;
 	     s < seg->area_count && (!max_areas || s <= max_areas);
 	     s++) {
@@ -848,15 +872,14 @@
 			if (!(r = _for_each_pv(cmd, seg_lv(seg, s),
 					       seg_le(seg, s) +
 					       (le - seg->le) / area_multiple,
-					       area_len, NULL, max_seg_len,
-					       only_single_area_segments ? 0 : 0,
-					       only_single_area_segments ? 1U : 0U,
-					       top_level_area_index != -1 ? top_level_area_index : (int) s,
+					       area_len, NULL, max_seg_len, 0,
+					       (stripes_per_mimage == 1) && only_single_area_segments ? 1U : 0U,
+					       top_level_area_index != -1 ? top_level_area_index : (int) s * stripes_per_mimage,
 					       only_single_area_segments, fn,
 					       data)))
 				stack;
 		} else if (seg_type(seg, s) == AREA_PV)
-			if (!(r = fn(cmd, seg_pvseg(seg, s), top_level_area_index != -1 ? (uint32_t) top_level_area_index : s, data)))
+			if (!(r = fn(cmd, seg_pvseg(seg, s), top_level_area_index != -1 ? (uint32_t) top_level_area_index + s : s, data)))
 				stack;
 		if (r != 1)
 			return r;
@@ -947,6 +970,11 @@
 	pvmatch->areas[s].pva = pvmatch->pva;
 	pvmatch->areas[s].used = pvmatch->pva->count;
 
+	log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
+		  " length %" PRIu32 ".",
+		  s, dev_name(pvmatch->pva->map->pv->dev), pvmatch->pva->start, 
+		  pvmatch->pva->count);
+
 	return 2;	/* Finished */
 }
 
@@ -1032,13 +1060,14 @@
 	uint32_t free_pes;
 	struct alloced_area *aa;
 	uint32_t s;
+	uint32_t total_extents_needed = (needed - *allocated) * ah->area_count / ah->area_multiple;
 
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
-	if (needed - *allocated > free_pes) {
+	if (total_extents_needed > free_pes) {
 		log_error("Insufficient free space: %" PRIu32 " extents needed,"
 			  " but only %" PRIu32 " available",
-			  needed - *allocated, free_pes);
+			  total_extents_needed, free_pes);
 		return 0;
 	}
 
@@ -1046,7 +1075,7 @@
 
 	/* Are there any preceding segments we must follow on from? */
 	if (prev_lvseg) {
-		ix_offset = prev_lvseg->area_count;
+		ix_offset = _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
 		if ((alloc == ALLOC_CONTIGUOUS))
 			contiguous = 1;
 		else if ((alloc == ALLOC_CLING))
@@ -1201,20 +1230,25 @@
 						  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
 				}
 			next_pv:
-				if (alloc == ALLOC_ANYWHERE &&
-				    ix + ix_offset >= ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0))
+				/* With ALLOC_ANYWHERE we ignore further PVs once we have at least enough areas */
+				/* With cling and contiguous we stop if we found a match for *all* the areas */
+				/* FIXME Rename these variables! */
+				if ((alloc == ALLOC_ANYWHERE &&
+				    ix + ix_offset >= ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0)) ||
+				    (preferred_count == ix_offset &&
+				     (ix_offset == ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0))))
 					break;
 			}
 		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0));
 
-		if ((contiguous || cling) && (preferred_count < ix_offset))
+		if (preferred_count < ix_offset)
 			break;
 
 		if (ix + ix_offset < ah->area_count +
 		   (*log_needs_allocating ? ah->log_area_count : 0))
 			break;
 
-		/* sort the areas so we allocate from the biggest */
+		/* Sort the areas so we allocate from the biggest */
 		if (ix > 1)
 			qsort((*areas_ptr) + ix_offset, ix, sizeof(**areas_ptr),
 			      _comp_area);
@@ -1310,7 +1344,7 @@
 	/* Upper bound if none of the PVs in prev_lvseg is in pvms */
 	/* FIXME Work size out properly */
 	if (prev_lvseg)
-		areas_size += prev_lvseg->area_count;
+		areas_size += _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
 
 	/* Allocate an array of pv_areas to hold the largest space on each PV */
 	if (!(areas = dm_malloc(sizeof(*areas) * areas_size))) {
@@ -1322,10 +1356,14 @@
 	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
 		old_allocated = allocated;
 		log_debug("Trying allocation using %s policy.  "
-			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log extents.",
+			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
+			  "(Total %" PRIu32 " extents.)",
 			  get_alloc_string(alloc),
 			  (ah->new_extents - allocated) / ah->area_multiple,
-			  ah->area_count, log_needs_allocating ? ah->log_area_count : 0);
+			  ah->area_count, log_needs_allocating ? ah->log_area_count : 0,
+			  log_needs_allocating ? ah->log_len : 0,
+			  (ah->new_extents - allocated) * ah->area_count / ah->area_multiple +
+				(log_needs_allocating ? ah->log_area_count * ah->log_len : 0));
 		if (!_find_parallel_space(ah, alloc, pvms, &areas,
 					  &areas_size, can_split,
 					  prev_lvseg, &allocated, &log_needs_allocating, ah->new_extents))
@@ -1665,7 +1703,8 @@
 
 static int _lv_extend_mirror(struct alloc_handle *ah,
 			     struct logical_volume *lv,
-			     uint32_t extents, uint32_t first_area)
+			     uint32_t extents, uint32_t first_area,
+			     uint32_t stripes, uint32_t stripe_size)
 {
 	struct lv_segment *seg;
 	uint32_t m, s;
@@ -1673,20 +1712,21 @@
 	seg = first_seg(lv);
 	for (m = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
-			if (!_lv_extend_mirror(ah, seg_lv(seg, s), extents, m))
+			if (!_lv_extend_mirror(ah, seg_lv(seg, s), extents, m, stripes, stripe_size))
 				return_0;
 			m += lv_mirror_count(seg_lv(seg, s));
 			continue;
 		}
 
-		if (!lv_add_segment(ah, m++, 1, seg_lv(seg, s),
+		if (!lv_add_segment(ah, m, stripes, seg_lv(seg, s),
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, 0, 0)) {
+				    stripe_size, 0, 0)) {
 			log_error("Aborting. Failed to extend %s.",
 				  seg_lv(seg, s)->name);
 			return 0;
 		}
+		m += stripes;
 	}
 	seg->area_len += extents;
 	seg->len += extents;
@@ -1722,7 +1762,7 @@
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, status, 0);
 	else
-		r = _lv_extend_mirror(ah, lv, extents, 0);
+		r = _lv_extend_mirror(ah, lv, extents, 0, stripes, stripe_size);
 
 	alloc_destroy(ah);
 	return r;
@@ -2095,7 +2135,7 @@
 		/* FIXME Unnecessary nesting! */
 		if (!_for_each_pv(cmd, use_pvmove_parent_lv ? seg->pvmove_source_seg->lv : lv,
 				  use_pvmove_parent_lv ? seg->pvmove_source_seg->le : current_le,
-				  use_pvmove_parent_lv ? spvs->len * calc_area_multiple(seg->pvmove_source_seg->segtype, seg->pvmove_source_seg->area_count) : spvs->len,
+				  use_pvmove_parent_lv ? spvs->len * _calc_area_multiple(seg->pvmove_source_seg->segtype, seg->pvmove_source_seg->area_count, 0) : spvs->len,
 				  use_pvmove_parent_lv ? seg->pvmove_source_seg : NULL,
 				  &spvs->len,
 				  0, 0, -1, 0, _add_pvs, (void *) spvs))
@@ -3148,6 +3188,7 @@
 
 	if (lp->mirrors > 1) {
 		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
+				    lp->stripe_size,
 				    adjusted_mirror_region_size(
 						vg->extent_size,
 						lv->le_count,
--- LVM2/lib/metadata/merge.c	2010/04/08 00:28:58	1.40
+++ LVM2/lib/metadata/merge.c	2010/04/09 01:00:11	1.41
@@ -30,7 +30,8 @@
 static int _merge(struct lv_segment *first, struct lv_segment *second)
 {
 	if (!first || !second || first->segtype != second->segtype ||
-	    !first->segtype->ops->merge_segments) return 0;
+	    !first->segtype->ops->merge_segments)
+		return 0;
 
 	return first->segtype->ops->merge_segments(first, second);
 }
--- LVM2/lib/metadata/metadata-exported.h	2010/04/08 00:28:58	1.138
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/09 01:00:11	1.139
@@ -665,7 +665,7 @@
 */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-		   uint32_t mirrors, uint32_t stripes,
+		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
 		   uint32_t region_size, uint32_t log_count,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
 int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
@@ -688,7 +688,7 @@
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
 			 struct dm_list *removable_pvs, unsigned remove_log);
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      uint32_t mirrors, uint32_t stripes, uint32_t stripe_size, uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count);
 struct logical_volume *detach_mirror_log(struct lv_segment *seg);
--- LVM2/lib/metadata/mirror.c	2010/04/08 00:28:58	1.111
+++ LVM2/lib/metadata/mirror.c	2010/04/09 01:00:11	1.112
@@ -1174,6 +1174,8 @@
 
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
+			      uint32_t stripes,
+			      uint32_t stripe_size,
 			      struct logical_volume *lv,
 			      struct logical_volume **img_lvs,
 			      int log)
@@ -1205,17 +1207,17 @@
 		}
 
 		if (log) {
-			if (!lv_add_log_segment(ah, m + 1, img_lvs[m], 0)) {
+			if (!lv_add_log_segment(ah, m * stripes + 1, img_lvs[m], 0)) {
 				log_error("Aborting. Failed to add mirror image segment "
 					  "to %s. Remove new LV and retry.",
 					  img_lvs[m]->name);
 				return 0;
 			}
 		} else {
-			if (!lv_add_segment(ah, m, 1, img_lvs[m],
+			if (!lv_add_segment(ah, m * stripes, stripes, img_lvs[m],
 					    get_segtype_from_string(lv->vg->cmd,
 								    "striped"),
-					    0, 0, 0)) {
+					    stripe_size, 0, 0)) {
 				log_error("Aborting. Failed to add mirror image segment "
 					  "to %s. Remove new LV and retry.",
 					  img_lvs[m]->name);
@@ -1566,7 +1568,8 @@
  */
 static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 			struct logical_volume *lv,
-			uint32_t mirrors, uint32_t region_size, int log)
+			uint32_t mirrors, uint32_t stripes,
+			uint32_t stripe_size, uint32_t region_size, int log)
 {
 	struct logical_volume **img_lvs;
 
@@ -1587,7 +1590,7 @@
 		return 0;
 	}
 
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs, log))
+	if (!_create_mimage_lvs(ah, mirrors, stripes, stripe_size, lv, img_lvs, log))
 		return 0;
 
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
@@ -1650,7 +1653,7 @@
 	}
 
 	if ((log_count > 1) &&
-	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size, 1)) {
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 1)) {
 		log_error("Failed to form mirrored log.");
 		return NULL;
 	}
@@ -1749,7 +1752,8 @@
  * Convert "linear" LV to "mirror".
  */
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      uint32_t mirrors, uint32_t stripes,
+		      uint32_t stripe_size, uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count)
 {
@@ -1758,11 +1762,6 @@
 	struct dm_list *parallel_areas;
 	struct logical_volume *log_lv = NULL;
 
-	if (stripes > 1) {
-		log_error("stripes > 1 is not supported");
-		return 0;
-	}
-
 	/*
 	 * allocate destination extents
 	 */
@@ -1795,7 +1794,7 @@
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	if (!_form_mirror(cmd, ah, lv, mirrors, region_size, 0))
+	if (!_form_mirror(cmd, ah, lv, mirrors, stripes, stripe_size, region_size, 0))
 		goto out_remove_log;
 
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
@@ -1825,7 +1824,7 @@
  * 'pvs' is either allocatable pvs.
  */
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-		   uint32_t mirrors, uint32_t stripes,
+		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
 		   uint32_t region_size, uint32_t log_count,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags)
 {
@@ -1863,7 +1862,7 @@
 			return add_mirror_log(cmd, lv, log_count,
 					      region_size, pvs, alloc);
 		return add_mirror_images(cmd, lv, mirrors,
-					 stripes, region_size,
+					 stripes, stripe_size, region_size,
 					 pvs, alloc, log_count);
 	}
 
--- LVM2/tools/lvconvert.c	2010/03/31 20:39:51	1.124
+++ LVM2/tools/lvconvert.c	2010/04/09 01:00:11	1.125
@@ -945,21 +945,13 @@
 	if (!(lv->status & MIRRORED)) {
 		/* FIXME Share code with lvcreate */
 
-		/* FIXME Why is this restriction here?  Fix it! */
-		dm_list_iterate_items(seg, &lv->segments) {
-			if (seg_is_striped(seg) && seg->area_count > 1) {
-				log_error("Mirrors of striped volumes are not yet supported.");
-				return 0;
-			}
-		}
-
 		/*
 		 * FIXME should we give not only lp->pvh, but also all PVs
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.
 		 */
 		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, 1,
-				    region_size, new_log_count, operable_pvs,
+				    0, region_size, new_log_count, operable_pvs,
 				    lp->alloc, MIRROR_BY_LV)) {
 			stack;
 			return failure_code;
@@ -1013,7 +1005,7 @@
 
 		/* FIXME: can't have multiple mlogs. force corelog. */
 		if (!lv_add_mirrors(cmd, lv,
-				    new_mimage_count - old_mimage_count, 1,
+				    new_mimage_count - old_mimage_count, 1, 0,
 				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
--- LVM2/tools/lvcreate.c	2010/03/29 16:09:41	1.218
+++ LVM2/tools/lvcreate.c	2010/04/09 01:00:11	1.219
@@ -457,12 +457,6 @@
 			return 0;
 		}
 
-		if (lp->stripes > 1) {
-			log_error("mirrors and stripes are currently "
-				  "incompatible");
-			return 0;
-		}
-
 		if (!(lp->segtype = get_segtype_from_string(cmd, "striped")))
 			return_0;
 	} else {
--- LVM2/tools/lvresize.c	2010/03/20 03:44:04	1.120
+++ LVM2/tools/lvresize.c	2010/04/09 01:00:11	1.121
@@ -73,10 +73,6 @@
 	} else
 		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 
-	if (lp->mirrors) {
-		log_error("Mirrors and striping cannot be combined yet.");
-		return 0;
-	}
 	if (lp->stripe_size & (lp->stripe_size - 1)) {
 		log_error("Stripe size must be power of 2");
 		return 0;
@@ -287,7 +283,7 @@
 	alloc_policy_t alloc;
 	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
-	struct lv_segment *seg;
+	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
 	uint32_t sz, str;
 	struct dm_list *pvh = NULL;
@@ -429,10 +425,32 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	/* If extending, find mirrors of last segment */
+	if ((lp->extents > lv->le_count)) {
+		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
+			if (seg_is_mirrored(mirr_seg))
+				seg_mirrors = lv_mirror_count(mirr_seg->lv);
+			else
+				seg_mirrors = 0;
+			break;
+		}
+		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
+			log_print("Extending %" PRIu32 " mirror images.",
+				  seg_mirrors);
+			lp->mirrors = seg_mirrors;
+		}
+		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
+		    (lp->mirrors != seg_mirrors)) {
+			log_error("Cannot vary number of mirrors in LV yet.");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
 	/* If extending, find stripes, stripesize & size of last segment */
 	if ((lp->extents > lv->le_count) &&
 	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
-		dm_list_iterate_items(seg, &lv->segments) {
+		/* FIXME Don't assume mirror seg will always be AREA_LV */
+		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments : &lv->segments) {
 			if (!seg_is_striped(seg))
 				continue;
 
@@ -440,7 +458,7 @@
 			str = seg->area_count;
 
 			if ((seg_stripesize && seg_stripesize != sz &&
-			     !lp->stripe_size) ||
+			     sz && !lp->stripe_size) ||
 			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
 				log_error("Please specify number of "
 					  "stripes (-i) and stripesize (-I)");
@@ -470,27 +488,6 @@
 		}
 	}
 
-	/* If extending, find mirrors of last segment */
-	if ((lp->extents > lv->le_count)) {
-		dm_list_iterate_back_items(seg, &lv->segments) {
-			if (seg_is_mirrored(seg))
-				seg_mirrors = lv_mirror_count(seg->lv);
-			else
-				seg_mirrors = 0;
-			break;
-		}
-		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
-			log_print("Extending %" PRIu32 " mirror images.",
-				  seg_mirrors);
-			lp->mirrors = seg_mirrors;
-		}
-		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
-		    (lp->mirrors != seg_mirrors)) {
-			log_error("Cannot vary number of mirrors in LV yet.");
-			return EINVALID_CMD_LINE;
-		}
-	}
-
 	/* If reducing, find stripes, stripesize & size of last segment */
 	if (lp->extents < lv->le_count) {
 		extents_used = 0;
--- LVM2/tools/pvmove.c	2010/02/05 22:40:50	1.75
+++ LVM2/tools/pvmove.c	2010/04/09 01:00:11	1.76
@@ -254,7 +254,7 @@
 		return NULL;
 	}
 
-	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, log_count,
+	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
 			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored");
 		return_NULL;


