From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2010 00:28:59 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-extents.c ...
Message-ID: <20100408002859.11139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-08 00:28:58

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-extents.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 
	                 metadata-exported.h mirror.c 

Log message:
	Fix pvmove allocation to take existing parallel stripes into account.
	
	When moving parts of striped LVs, pvmove wouldn't care about leaving you with
	two stripes on the same disk.  Now --alloc anywhere is needed for that.
	(Tried and gave up on two alternative approaches before the one committed here.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1505&r2=1.1506
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/WHATS_NEW	2010/04/07 20:04:41	1.1505
+++ LVM2/WHATS_NEW	2010/04/08 00:28:57	1.1506
@@ -1,5 +1,7 @@
 Version 2.02.63 -  
 ================================
+  Fix pvmove allocation to take existing parallel stripes into account.
+  Add pvmove_source_seg to struct lv_segment.
   Fix incorrect removal of symlinks after LV deactivation fails.
   Fix is_partitioned_dev not to attempt to reopen device.
   Fix another thread race in clvmd.
--- LVM2/lib/format1/import-extents.c	2009/07/15 20:02:46	1.38
+++ LVM2/lib/format1/import-extents.c	2010/04/08 00:28:57	1.39
@@ -219,7 +219,7 @@
 		len = _area_length(lvm, le);
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
-					     len, 0, 0, NULL, 1, len, 0, 0, 0))) {
+					     len, 0, 0, NULL, 1, len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -293,7 +293,7 @@
 					     lvm->stripes * area_len,
 					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
-					     area_len, 0, 0, 0))) {
+					     area_len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate striped segment.");
 			return 0;
 		}
--- LVM2/lib/format_pool/import_export.c	2009/09/28 17:46:16	1.28
+++ LVM2/lib/format_pool/import_export.c	2010/04/08 00:28:58	1.29
@@ -197,7 +197,7 @@
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
 				     usp->striping, NULL, usp->num_devs,
-				     area_len, 0, 0, 0))) {
+				     area_len, 0, 0, 0, NULL))) {
 		log_error("Unable to allocate striped lv_segment structure");
 		return 0;
 	}
@@ -234,7 +234,7 @@
 		if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 					     area_len, 0, usp->striping,
 					     NULL, 1, area_len,
-					     POOL_PE_SIZE, 0, 0))) {
+					     POOL_PE_SIZE, 0, 0, NULL))) {
 			log_error("Unable to allocate linear lv_segment "
 				  "structure");
 			return 0;
--- LVM2/lib/format_text/import_vsn1.c	2010/04/06 14:04:54	1.73
+++ LVM2/lib/format_text/import_vsn1.c	2010/04/08 00:28:58	1.74
@@ -340,7 +340,7 @@
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
 				     extent_count, 0, 0, NULL, area_count,
-				     extent_count, 0, 0, 0))) {
+				     extent_count, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
 		return 0;
 	}
--- LVM2/lib/metadata/lv_alloc.h	2010/03/26 22:15:43	1.27
+++ LVM2/lib/metadata/lv_alloc.h	2010/04/08 00:28:58	1.28
@@ -26,7 +26,8 @@
 				    uint32_t area_len,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
-				    uint32_t extents_copied);
+				    uint32_t extents_copied,
+				    struct lv_segment *pvmove_source_seg);
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				      uint64_t status, uint32_t old_le_count);
@@ -76,6 +77,7 @@
 void alloc_destroy(struct alloc_handle *ah);
 
 struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
-					  struct logical_volume *lv);
+					     struct logical_volume *lv,
+					     unsigned use_pvmove_parent_lv);
 
 #endif
--- LVM2/lib/metadata/lv_manip.c	2010/04/02 01:35:34	1.224
+++ LVM2/lib/metadata/lv_manip.c	2010/04/08 00:28:58	1.225
@@ -174,7 +174,8 @@
 				    uint32_t area_len,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
-				    uint32_t extents_copied)
+				    uint32_t extents_copied,
+				    struct lv_segment *pvmove_source_seg)
 {
 	struct lv_segment *seg;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
@@ -204,6 +205,7 @@
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
 	seg->log_lv = log_lv;
+	seg->pvmove_source_seg = pvmove_source_seg;
 	dm_list_init(&seg->tags);
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
@@ -227,7 +229,7 @@
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv, old_le_count,
 				     lv->le_count - old_le_count, status, 0,
 				     NULL, 0, lv->le_count - old_le_count,
-				     0, 0, 0))) {
+				     0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new snapshot segment.");
 		return NULL;
 	}
@@ -693,7 +695,7 @@
 				     aa[0].len * area_multiple,
 				     status, stripe_size, NULL,
 				     area_count,
-				     aa[0].len, 0u, region_size, 0u))) {
+				     aa[0].len, 0u, region_size, 0u, NULL))) {
 		log_error("Couldn't allocate new LV segment.");
 		return 0;
 	}
@@ -807,7 +809,8 @@
  * In the last case, this function passes on the return code.
  */
 static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
-			uint32_t le, uint32_t len, uint32_t *max_seg_len,
+			uint32_t le, uint32_t len, struct lv_segment *seg,
+			uint32_t *max_seg_len,
 			uint32_t first_area, uint32_t max_areas,
 			int top_level_area_index,
 			int only_single_area_segments,
@@ -816,12 +819,11 @@
 				  void *data),
 			void *data)
 {
-	struct lv_segment *seg;
 	uint32_t s;
 	uint32_t remaining_seg_len, area_len, area_multiple;
 	int r = 1;
 
-	if (!(seg = find_seg_by_le(lv, le))) {
+	if (!seg && !(seg = find_seg_by_le(lv, le))) {
 		log_error("Failed to find segment for %s extent %" PRIu32,
 			  lv->name, le);
 		return 0;
@@ -846,7 +848,7 @@
 			if (!(r = _for_each_pv(cmd, seg_lv(seg, s),
 					       seg_le(seg, s) +
 					       (le - seg->le) / area_multiple,
-					       area_len, max_seg_len,
+					       area_len, NULL, max_seg_len,
 					       only_single_area_segments ? 0 : 0,
 					       only_single_area_segments ? 1U : 0U,
 					       top_level_area_index != -1 ? top_level_area_index : (int) s,
@@ -862,7 +864,7 @@
 
 	/* FIXME only_single_area_segments used as workaround to skip log LV - needs new param? */
 	if (!only_single_area_segments && seg_is_mirrored(seg) && seg->log_lv) {
-		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count,
+		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count, NULL,
 				       NULL, 0, 0, 0, only_single_area_segments,
 				       fn, data)))
 			stack;
@@ -965,7 +967,7 @@
 
 	/* FIXME Cope with stacks by flattening */
 	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
-			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL,
+			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL, NULL,
 			       0, 0, -1, 1,
 			       _is_condition, &pvmatch)))
 		stack;
@@ -993,7 +995,7 @@
 
 	/* FIXME Cope with stacks by flattening */
 	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
-			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL,
+			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL, NULL,
 			       0, 0, -1, 1,
 			       _is_condition, &pvmatch)))
 		stack;
@@ -1364,7 +1366,7 @@
 
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count, extents, status, 0,
-				     NULL, 0, extents, 0, 0, 0))) {
+				     NULL, 0, extents, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new zero segment.");
 		return 0;
 	}
@@ -1504,7 +1506,7 @@
 					log_lv,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
-					seg->extents_copied))) {
+					seg->extents_copied, NULL))) {
 		log_error("Couldn't allocate converted LV segment");
 		return NULL;
 	}
@@ -1513,6 +1515,8 @@
 		if (!move_lv_segment_area(newseg, s, seg, s))
 			return_NULL;
 
+	seg->pvmove_source_seg = NULL; /* Not maintained after allocation */
+
 	dm_list_add(&seg->list, &newseg->list);
 	dm_list_del(&seg->list);
 
@@ -2050,13 +2054,16 @@
 
 /*
  * Construct dm_list of segments of LVs showing which PVs they use.
+ * For pvmove we use the *parent* LV so we can pick up stripes & existing mirrors etc.
  */
 struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
-					  struct logical_volume *lv)
+					     struct logical_volume *lv,
+					     unsigned use_pvmove_parent_lv)
 {
 	struct dm_list *parallel_areas;
 	struct seg_pvs *spvs;
 	uint32_t current_le = 0;
+	struct lv_segment *seg;
 
 	if (!(parallel_areas = dm_pool_alloc(cmd->mem, sizeof(*parallel_areas)))) {
 		log_error("parallel_areas allocation failed");
@@ -2078,9 +2085,19 @@
 
 		dm_list_add(parallel_areas, &spvs->list);
 
+		if (use_pvmove_parent_lv && !(seg = find_seg_by_le(lv, current_le))) {
+			log_error("Failed to find segment for %s extent %" PRIu32,
+				  lv->name, current_le);
+			return 0;
+		}
+
 		/* Find next segment end */
 		/* FIXME Unnecessary nesting! */
-		if (!_for_each_pv(cmd, lv, current_le, spvs->len, &spvs->len,
+		if (!_for_each_pv(cmd, use_pvmove_parent_lv ? seg->pvmove_source_seg->lv : lv,
+				  use_pvmove_parent_lv ? seg->pvmove_source_seg->le : current_le,
+				  use_pvmove_parent_lv ? spvs->len * calc_area_multiple(seg->pvmove_source_seg->segtype, seg->pvmove_source_seg->area_count) : spvs->len,
+				  seg->pvmove_source_seg,
+				  &spvs->len,
 				  0, 0, -1, 0, _add_pvs, (void *) spvs))
 			return_NULL;
 
@@ -2331,7 +2348,7 @@
 	uint32_t s;
 	struct dm_list *parallel_areas;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, layer_lv)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, layer_lv, 0)))
 		return_0;
 
 	/* Loop through all LVs except itself */
@@ -2617,7 +2634,7 @@
 	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
 					lv_where, 0, layer_lv->le_count,
 					status, 0, NULL, 1, layer_lv->le_count,
-					0, 0, 0)))
+					0, 0, 0, NULL)))
 		return_NULL;
 
 	/* map the new segment to the original underlying are */
@@ -2660,7 +2677,7 @@
 	if (!(mapseg = alloc_lv_segment(layer_lv->vg->cmd->mem, segtype,
 					layer_lv, layer_lv->le_count,
 					seg->area_len, status, 0,
-					NULL, 1, seg->area_len, 0, 0, 0)))
+					NULL, 1, seg->area_len, 0, 0, 0, seg)))
 		return_0;
 
 	/* map the new segment to the original underlying are */
--- LVM2/lib/metadata/merge.c	2010/04/01 12:14:20	1.39
+++ LVM2/lib/metadata/merge.c	2010/04/08 00:28:58	1.40
@@ -280,7 +280,7 @@
 					   seg->log_lv,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
-					   seg->extents_copied))) {
+					   seg->extents_copied, seg->pvmove_source_seg))) {
 		log_error("Couldn't allocate cloned LV segment.");
 		return 0;
 	}
--- LVM2/lib/metadata/metadata-exported.h	2010/03/23 22:30:19	1.137
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/08 00:28:58	1.138
@@ -301,6 +301,7 @@
 	uint32_t region_size;	/* For mirrors - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
+	struct lv_segment *pvmove_source_seg;
 	void *segtype_private;
 
 	struct dm_list tags;
--- LVM2/lib/metadata/mirror.c	2010/04/01 14:54:37	1.110
+++ LVM2/lib/metadata/mirror.c	2010/04/08 00:28:58	1.111
@@ -1450,7 +1450,7 @@
 	uint32_t adjusted_region_size;
 	int r = 1;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 1)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -1702,7 +1702,7 @@
 		return 0;
 	}
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -1767,7 +1767,7 @@
 	 * allocate destination extents
 	 */
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))


