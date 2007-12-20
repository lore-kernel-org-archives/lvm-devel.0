From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2007 15:42:57 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_alloc.h lib/m ...
Message-ID: <20071220154257.12099.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-20 15:42:55

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_alloc.h lv_manip.c metadata-exported.h 
	                 metadata.h mirror.c 
	scripts        : fsadm.sh 
	tools          : lvconvert.c lvcreate.c pvmove.c toollib.c 
	                 toollib.h 

Log message:
	Major restructuring of pvmove and lvconvert layer manipulation code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.746&r2=1.747
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2007/12/17 12:31:49	1.746
+++ LVM2/WHATS_NEW	2007/12/20 15:42:55	1.747
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Major restructuring of pvmove and lvconvert layer manipulation code.
   Replace tools/fsadm with scripts/fsadm.sh.
   Append fields to report/pvsegs_cols_verbose.
   Permit LV segment fields with PV segment reports.
--- LVM2/lib/metadata/lv_alloc.h	2007/12/05 22:11:19	1.19
+++ LVM2/lib/metadata/lv_alloc.h	2007/12/20 15:42:55	1.20
@@ -50,7 +50,6 @@
 				      uint32_t extents,
                                       struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
-				      unsigned can_split,
 				      struct list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
@@ -58,27 +57,21 @@
 		   struct logical_volume *lv,
                    const struct segment_type *segtype,
                    uint32_t stripe_size,
-                   struct physical_volume *mirrored_pv,
-                   uint32_t mirrored_pe,
                    uint32_t status,   
 		   uint32_t region_size,
                    struct logical_volume *log_lv);
 
+int lv_add_mirror_areas(struct alloc_handle *ah,
+			struct logical_volume *lv, uint32_t le,
+			uint32_t region_size);
+int lv_add_mirror_lvs(struct logical_volume *lv,
+		      struct logical_volume **sub_lvs,
+		      uint32_t num_extra_areas,
+		      uint32_t status, uint32_t region_size);
+
 int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv);
 int lv_add_virtual_segment(struct logical_volume *lv, uint32_t status,
                            uint32_t extents, const struct segment_type *segtype);
-int lv_add_mirror_segment(struct alloc_handle *ah,
-			  struct logical_volume *lv,
-			  struct logical_volume **sub_lvs,
-			  uint32_t mirrors,
-			  const struct segment_type *segtype,
-			  uint32_t status,
-			  uint32_t region_size,
-			  struct logical_volume *log_lv);
-int lv_add_more_mirrored_areas(struct logical_volume *lv,
-                               struct logical_volume **sub_lvs,
-                               uint32_t new_area_count,
-                               uint32_t status);
 
 void alloc_destroy(struct alloc_handle *ah);
 
--- LVM2/lib/metadata/lv_manip.c	2007/12/05 22:11:19	1.136
+++ LVM2/lib/metadata/lv_manip.c	2007/12/20 15:42:55	1.137
@@ -43,6 +43,17 @@
 	uint32_t len;
 };
 
+static struct seg_pvs *_find_seg_pvs_by_le(struct list *list, uint32_t le)
+{
+	struct seg_pvs *spvs;
+
+	list_iterate_items(spvs, list)
+		if (le >= spvs->le && le < spvs->le + spvs->len)
+			return spvs;
+
+	return NULL;
+}
+
 /*
  * Find first unused LV number.
  */
@@ -160,7 +171,9 @@
 		return;
 
 	if (seg_type(seg, s) == AREA_PV) {
-		release_pv_segment(seg_pvseg(seg, s), area_reduction);
+		if (release_pv_segment(seg_pvseg(seg, s), area_reduction) &&
+		    seg->area_len == area_reduction)
+			seg_type(seg, s) = AREA_UNASSIGNED;
 		return;
 	}
 
@@ -543,17 +556,12 @@
 				  uint32_t stripe_size,
 				  const struct segment_type *segtype,
 				  struct alloced_area *aa,
-				  struct physical_volume *mirrored_pv,
-				  uint32_t mirrored_pe,
 				  uint32_t region_size,
 				  struct logical_volume *log_lv __attribute((unused)))
 {
-	uint32_t s, extents, area_multiple, extra_areas = 0;
+	uint32_t s, extents, area_multiple;
 	struct lv_segment *seg;
 
-	if (mirrored_pv)
-		extra_areas = 1;
-
 	area_multiple = calc_area_multiple(segtype, area_count);
 
 	/* log_lv gets set up elsehere */
@@ -561,22 +569,14 @@
 				     lv->le_count,
 				     aa[0].len * area_multiple,
 				     status, stripe_size, NULL,
-				     area_count + extra_areas,
+				     area_count,
 				     aa[0].len, 0u, region_size, 0u))) {
 		log_error("Couldn't allocate new LV segment.");
 		return 0;
 	}
 
-	if (extra_areas) {
-		if (!set_lv_segment_area_pv(seg, 0, mirrored_pv, mirrored_pe)) {
-			stack;
-			return 0;
-		}
-	}
-
 	for (s = 0; s < area_count; s++) {
-		if (!set_lv_segment_area_pv(seg, s + extra_areas, aa[s].pv,
-					    aa[s].pe)) {
+		if (!set_lv_segment_area_pv(seg, s, aa[s].pv, aa[s].pe)) {
 			stack;
 			return 0;
 		}
@@ -600,8 +600,6 @@
 				   uint32_t status,
 				   uint32_t stripe_size,
 				   const struct segment_type *segtype,
-				   struct physical_volume *mirrored_pv,
-				   uint32_t mirrored_pe,
 				   uint32_t region_size,
 				   struct logical_volume *log_lv)
 {
@@ -610,7 +608,6 @@
 	list_iterate_items(aa, &alloced_areas[0]) {
 		if (!_setup_alloced_segment(lv, status, area_count,
 					    stripe_size, segtype, aa,
-					    mirrored_pv, mirrored_pe,
 					    region_size, log_lv)) {
 			stack;
 			return 0;
@@ -1180,7 +1177,6 @@
 				      uint32_t extents,
 				      struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
-				      unsigned can_split,
 				      struct list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -1209,7 +1205,7 @@
 
 	if (!segtype_is_virtual(segtype) &&
 	    !_allocate(ah, vg, lv, (lv ? lv->le_count : 0) + extents,
-		       can_split, allocatable_pvs)) {
+		       1, allocatable_pvs)) {
 		stack;
 		alloc_destroy(ah);
 		return NULL;
@@ -1226,8 +1222,6 @@
 		   struct logical_volume *lv,
 		   const struct segment_type *segtype,
 		   uint32_t stripe_size,
-		   struct physical_volume *mirrored_pv,
-		   uint32_t mirrored_pe,
 		   uint32_t status,
 		   uint32_t region_size,
 		   struct logical_volume *log_lv)
@@ -1245,7 +1239,6 @@
 	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
 				     num_areas, status,
 				     stripe_size, segtype,
-				     mirrored_pv, mirrored_pe,
 				     region_size, log_lv)) {
 		stack;
 		return 0;
@@ -1267,110 +1260,135 @@
 }
 
 /*
- * Turn an empty LV into a mirror log.
- */
-int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
+ * "mirror" segment type doesn't support split.
+ * So, when adding mirrors to linear LV segment, first split it,
+ * then convert it to "mirror" and add areas.
+ */
+static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
+						 uint32_t region_size,
+						 struct logical_volume *log_lv)
 {
-	struct lv_segment *seg;
+	struct lv_segment *newseg;
+	uint32_t s;
 
-	if (list_size(&log_lv->segments)) {
-		log_error("Log segments can only be added to an empty LV");
-		return 0;
+	if (!seg_is_striped(seg)) {
+		log_error("Can't convert non-striped segment to mirrored.");
+		return NULL;
 	}
 
-	if (!(seg = alloc_lv_segment(log_lv->vg->cmd->mem,
-				     get_segtype_from_string(log_lv->vg->cmd,
-							     "striped"),
-				     log_lv, 0, ah->log_area.len, MIRROR_LOG,
-				     0, NULL, 1, ah->log_area.len, 0, 0, 0))) {
-		log_error("Couldn't allocate new mirror log segment.");
-		return 0;
+	if (seg->area_count > 1) {
+		log_error("Can't convert striped segment with multiple areas "
+			  "to mirrored.");
+		return NULL;
 	}
 
-	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe)) {
-		stack;
-		return 0;
+	if (!(newseg = alloc_lv_segment(seg->lv->vg->cmd->mem,
+					get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
+					seg->lv, seg->le, seg->len,
+					seg->status, seg->stripe_size,
+					log_lv,
+					seg->area_count, seg->area_len,
+					seg->chunk_size, region_size,
+					seg->extents_copied))) {
+		log_error("Couldn't allocate converted LV segment");
+		return NULL;
 	}
 
-	list_add(&log_lv->segments, &seg->list);
-	log_lv->le_count += ah->log_area.len;
-	log_lv->size += (uint64_t) log_lv->le_count *log_lv->vg->extent_size;
+	for (s = 0; s < seg->area_count; s++)
+		if (!move_lv_segment_area(newseg, s, seg, s))
+			return_NULL;
 
-	if (log_lv->vg->fid->fmt->ops->lv_setup &&
-	    !log_lv->vg->fid->fmt->ops->lv_setup(log_lv->vg->fid, log_lv)) {
-		stack;
-		return 0;
-	}
+	list_add(&seg->list, &newseg->list);
+	list_del(&seg->list);
 
-	return 1;
+	return newseg;
 }
 
 /*
- * Add a mirror segment
+ * Add new areas to mirrored segments
  */
-int lv_add_mirror_segment(struct alloc_handle *ah,
-			  struct logical_volume *lv,
-			  struct logical_volume **sub_lvs,
-			  uint32_t mirrors,
-			  const struct segment_type *segtype __attribute((unused)),
-			  uint32_t status __attribute((unused)),
-			  uint32_t region_size,
-			  struct logical_volume *log_lv)
+int lv_add_mirror_areas(struct alloc_handle *ah,
+			struct logical_volume *lv, uint32_t le,
+			uint32_t region_size)
 {
+	struct alloced_area *aa;
 	struct lv_segment *seg;
-	uint32_t m;
+	uint32_t current_le = le;
+	uint32_t s, old_area_count, new_area_count;
 
-	if (log_lv && list_empty(&log_lv->segments)) {
-		log_error("Log LV %s is empty.", log_lv->name);
-		return 0;
-	}
+	list_iterate_items(aa, &ah->alloced_areas[0]) {
+		if (!(seg = find_seg_by_le(lv, current_le))) {
+			log_error("Failed to find segment for %s extent %"
+				  PRIu32, lv->name, current_le);
+			return 0;
+		}
 
-	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem,
-				     get_segtype_from_string(lv->vg->cmd,
-							     "mirror"),
-				     lv, lv->le_count, ah->total_area_len, 0,
-				     0, log_lv, mirrors, ah->total_area_len, 0,
-				     region_size, 0))) {
-		log_error("Couldn't allocate new mirror segment.");
-		return 0;
-	}
+		/* Allocator assures aa[0].len <= seg->area_len */
+		if (aa[0].len < seg->area_len) {
+			if (!lv_split_segment(lv, seg->le + aa[0].len)) {
+				log_error("Failed to split segment at %s "
+					  "extent %" PRIu32, lv->name, le);
+				return 0;
+			}
+		}
 
-	for (m = 0; m < mirrors; m++) {
-		set_lv_segment_area_lv(seg, m, sub_lvs[m], 0, MIRROR_IMAGE);
-		first_seg(sub_lvs[m])->mirror_seg = seg;
+		if (!seg_is_mirrored(seg) &&
+		    (!(seg = _convert_seg_to_mirror(seg, region_size, NULL))))
+				return_0;
+
+		old_area_count = seg->area_count;
+		new_area_count = old_area_count + ah->area_count;
+
+		if (!_lv_segment_add_areas(lv, seg, new_area_count))
+			return_0;
+
+		for (s = 0; s < ah->area_count; s++) {
+			if (!set_lv_segment_area_pv(seg, s + old_area_count,
+						    aa[s].pv, aa[s].pe))
+				return_0;
+		}
+
+		current_le += seg->area_len;
 	}
 
-	list_add(&lv->segments, &seg->list);
-	lv->le_count += ah->total_area_len;
-	lv->size += (uint64_t) lv->le_count *lv->vg->extent_size;
+	lv->status |= MIRRORED;
 
 	if (lv->vg->fid->fmt->ops->lv_setup &&
-	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv)) {
-		stack;
-		return 0;
-	}
+	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
+		return_0;
 
 	return 1;
 }
 
 /*
- * Add parallel areas to an existing mirror
+ * Add mirror image LVs to mirrored segments
  */
-int lv_add_more_mirrored_areas(struct logical_volume *lv,
-			       struct logical_volume **sub_lvs,
-			       uint32_t num_extra_areas,
-			       uint32_t status)
+int lv_add_mirror_lvs(struct logical_volume *lv,
+		      struct logical_volume **sub_lvs,
+		      uint32_t num_extra_areas,
+		      uint32_t status, uint32_t region_size)
 {
 	struct lv_segment *seg;
 	uint32_t old_area_count, new_area_count;
 	uint32_t m;
+	struct segment_type *mirror_segtype;
 
-	if (list_size(&lv->segments) != 1) {
-		log_error("Mirrored LV must only have one segment.");
-		return 0;
+	seg = first_seg(lv);
+
+	if (list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
+		log_error("Mirror layer must be inserted before adding mirrors");
+		return_0;
 	}
 
-	seg = first_seg(lv);
+	mirror_segtype = get_segtype_from_string(lv->vg->cmd, "mirror");
+	if (seg->segtype != mirror_segtype)
+		if (!(seg = _convert_seg_to_mirror(seg, region_size, NULL)))
+			return_0;
+
+	if (region_size && region_size != seg->region_size) {
+		log_error("Conflicting region_size");
+		return 0;
+	}
 
 	old_area_count = seg->area_count;
 	new_area_count = old_area_count + num_extra_areas;
@@ -1381,6 +1399,11 @@
 		return 0;
 	}
 
+	for (m = 0; m < old_area_count; m++) {
+		seg_lv(seg, m)->status |= status;
+		first_seg(seg_lv(seg, m))->mirror_seg = seg;
+	}
+
 	for (m = old_area_count; m < new_area_count; m++) {
 		set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count], 0, status);
 		first_seg(sub_lvs[m - old_area_count])->mirror_seg = seg;
@@ -1390,13 +1413,53 @@
 }
 
 /*
+ * Turn an empty LV into a mirror log.
+ */
+int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
+{
+	struct lv_segment *seg;
+
+	if (list_size(&log_lv->segments)) {
+		log_error("Log segments can only be added to an empty LV");
+		return 0;
+	}
+
+	if (!(seg = alloc_lv_segment(log_lv->vg->cmd->mem,
+				     get_segtype_from_string(log_lv->vg->cmd,
+							     "striped"),
+				     log_lv, 0, ah->log_area.len, MIRROR_LOG,
+				     0, NULL, 1, ah->log_area.len, 0, 0, 0))) {
+		log_error("Couldn't allocate new mirror log segment.");
+		return 0;
+	}
+
+	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe)) {
+		stack;
+		return 0;
+	}
+
+	list_add(&log_lv->segments, &seg->list);
+	log_lv->le_count += ah->log_area.len;
+	log_lv->size += (uint64_t) log_lv->le_count *log_lv->vg->extent_size;
+
+	if (log_lv->vg->fid->fmt->ops->lv_setup &&
+	    !log_lv->vg->fid->fmt->ops->lv_setup(log_lv->vg->fid, log_lv)) {
+		stack;
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
  * Entry point for single-step LV allocation + extension.
  */
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
+	      struct physical_volume *mirrored_pv __attribute((unused)),
+	      uint32_t mirrored_pe __attribute((unused)),
 	      uint32_t status, struct list *allocatable_pvs,
 	      alloc_policy_t alloc)
 {
@@ -1404,23 +1467,17 @@
 	uint32_t m;
 	struct alloc_handle *ah;
 	struct lv_segment *seg;
-	unsigned can_split = 1;
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, status, extents, segtype);
 
-	/* FIXME Temporary restriction during code reorganisation */
-	if (mirrored_pv)
-		can_split = 0;
-
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0,
-				    extents, allocatable_pvs, alloc, can_split,
-				    NULL)))
+				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
 	if (mirrors < 2) {
 		if (!lv_add_segment(ah, 0, ah->area_count, lv, segtype, stripe_size,
-			    mirrored_pv, mirrored_pe, status, 0, NULL)) {
+			    status, 0, NULL)) {
 			stack;
 			goto out;
 		}
@@ -1430,7 +1487,7 @@
 			if (!lv_add_segment(ah, m, 1, seg_lv(seg, m),
 					    get_segtype_from_string(lv->vg->cmd,
 								    "striped"),
-					    0, NULL, 0, 0, 0, NULL)) {
+					    0, 0, 0, NULL)) {
 				log_error("Aborting. Failed to extend %s.",
 					  seg_lv(seg, m)->name);
 				return 0;
@@ -1900,3 +1957,504 @@
 	log_print("Logical volume \"%s\" successfully removed", lv->name);
 	return 1;
 }
+
+/*
+ * insert_layer_for_segments_on_pv() inserts a layer segment for a segment area.
+ * However, layer modification could split the underlying layer segment.
+ * This function splits the parent area according to keep the 1:1 relationship
+ * between the parent area and the underlying layer segment.
+ * Since the layer LV might have other layers below, build_parallel_areas()
+ * is used to find the lowest-level segment boundaries.
+ */
+static int _split_parent_area(struct lv_segment *seg, uint32_t s,
+			      struct list *layer_seg_pvs)
+{
+	uint32_t parent_area_len, parent_le, layer_le;
+	uint32_t area_multiple;
+	struct seg_pvs *spvs;
+
+	if (seg_is_striped(seg))
+		area_multiple = seg->area_count;
+	else
+		area_multiple = 1;
+
+	parent_area_len = seg->area_len;
+	parent_le = seg->le;
+	layer_le = seg_le(seg, s);
+
+	while (parent_area_len > 0) {
+		/* Find the layer segment pointed at */
+		if (!(spvs = _find_seg_pvs_by_le(layer_seg_pvs, layer_le))) {
+			log_error("layer segment for %s:%" PRIu32 " not found",
+				  seg->lv->name, parent_le);
+			return 0;
+		}
+
+		if (spvs->le != layer_le) {
+			log_error("Incompatible layer boundary: "
+				  "%s:%" PRIu32 "[%" PRIu32 "] on %s:%" PRIu32,
+				  seg->lv->name, parent_le, s,
+				  seg_lv(seg, s)->name, layer_le);
+			return 0;
+		}
+
+		if (spvs->len < parent_area_len) {
+			parent_le += spvs->len * area_multiple;
+			if (!lv_split_segment(seg->lv, parent_le))
+				return_0;
+		}
+
+		parent_area_len -= spvs->len;
+		layer_le += spvs->len;
+	}
+
+	return 1;
+}
+
+/*
+ * Split the parent LV segments if the layer LV below it is splitted.
+ */
+int split_parent_segments_for_layer(struct cmd_context *cmd,
+				    struct logical_volume *layer_lv)
+{
+	struct lv_list *lvl;
+	struct logical_volume *parent_lv;
+	struct lv_segment *seg;
+	uint32_t s;
+	struct list *parallel_areas;
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, layer_lv)))
+		return_0;
+
+	/* Loop through all LVs except itself */
+	list_iterate_items(lvl, &layer_lv->vg->lvs) {
+		parent_lv = lvl->lv;
+		if (parent_lv == layer_lv)
+			continue;
+
+		/* Find all segments that point at the layer LV */
+		list_iterate_items(seg, &parent_lv->segments) {
+			for (s = 0; s < seg->area_count; s++) {
+				if (seg_type(seg, s) != AREA_LV ||
+				    seg_lv(seg, s) != layer_lv)
+					continue;
+
+				if (!_split_parent_area(seg, s, parallel_areas))
+					return_0;
+			}
+		}
+	}
+
+	return 1;
+}
+
+/* Remove a layer from the LV */
+int remove_layers_for_segments(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       struct logical_volume *layer_lv,
+			       uint32_t status_mask, struct list *lvs_changed)
+{
+	struct lv_segment *seg, *lseg;
+	uint32_t s;
+	int lv_changed = 0;
+	struct lv_list *lvl;
+
+	/* Find all segments that point at the temporary mirror */
+	list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV ||
+			    seg_lv(seg, s) != layer_lv)
+				continue;
+
+			/* Find the layer segment pointed at */
+			if (!(lseg = find_seg_by_le(layer_lv, seg_le(seg, s)))) {
+				log_error("Layer segment found: %s:%" PRIu32,
+					  layer_lv->name, seg_le(seg, s));
+				return 0;
+			}
+
+			/* Check the segment params are compatible */
+			if (!seg_is_striped(lseg) || lseg->area_count != 1) {
+				log_error("Layer is not linear: %s:%" PRIu32,
+					  layer_lv->name, lseg->le);
+				return 0;
+			}
+			if ((lseg->status & status_mask) != status_mask) {
+				log_error("Layer status does not match: "
+					  "%s:%" PRIu32 " status: 0x%x/0x%x",
+					  layer_lv->name, lseg->le,
+					  lseg->status, status_mask);
+				return 0;
+			}
+			if (lseg->le != seg_le(seg, s) ||
+			    lseg->area_len != seg->area_len) {
+				log_error("Layer boundary mismatch: "
+					  "%s:%" PRIu32 "-%" PRIu32 " on "
+					  "%s:%" PRIu32 " / "
+					  "%" PRIu32 "-%" PRIu32 " / ",
+					  lv->name, seg->le, seg->area_len,
+					  layer_lv->name, seg_le(seg, s),
+					  lseg->le, lseg->area_len);
+				return 0;
+			}
+
+			if (!move_lv_segment_area(seg, s, lseg, 0))
+				return_0;
+
+			/* Replace mirror with error segment */
+			if (!(lseg->segtype =
+			      get_segtype_from_string(lv->vg->cmd, "error"))) {
+				log_error("Missing error segtype");
+				return 0;
+			}
+			lseg->area_count = 0;
+
+			/* First time, add LV to list of LVs affected */
+			if (!lv_changed && lvs_changed) {
+				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
+					log_error("lv_list alloc failed");
+					return 0;
+				}
+				lvl->lv = lv;
+				list_add(lvs_changed, &lvl->list);
+				lv_changed = 1;
+			}
+		}
+	}
+	if (lv_changed && !lv_merge_segments(lv))
+		stack;
+
+	return 1;
+}
+
+/* Remove a layer */
+int remove_layers_for_segments_all(struct cmd_context *cmd,
+				   struct logical_volume *layer_lv,
+				   uint32_t status_mask,
+				   struct list *lvs_changed)
+{
+	struct lv_list *lvl;
+	struct logical_volume *lv1;
+
+	/* Loop through all LVs except the temporary mirror */
+	list_iterate_items(lvl, &layer_lv->vg->lvs) {
+		lv1 = lvl->lv;
+		if (lv1 == layer_lv)
+			continue;
+
+		if (!remove_layers_for_segments(cmd, lv1, layer_lv,
+						status_mask, lvs_changed))
+			return 0;
+	}
+
+	if (!lv_empty(layer_lv))
+		return_0;
+
+	return 1;
+}
+
+static void _move_lv_segments(struct logical_volume *lv_to,
+			      struct logical_volume *lv_from,
+			      uint32_t set_status, uint32_t reset_status)
+{
+	struct lv_segment *seg;
+
+	lv_to->segments = lv_from->segments;
+	lv_to->segments.n->p = &lv_to->segments;
+	lv_to->segments.p->n = &lv_to->segments;
+
+	list_iterate_items(seg, &lv_to->segments) {
+		seg->lv = lv_to;
+		seg->status &= ~reset_status;
+		seg->status |= set_status;
+	}
+
+	/* FIXME: how to handle snapshot segments? */
+
+	list_init(&lv_from->segments);
+
+	lv_to->le_count = lv_from->le_count;
+	lv_to->size = lv_from->size;
+
+	lv_from->le_count = 0;
+	lv_from->size = 0;
+}
+
+/* Remove a layer from the LV */
+/* FIXME: how to specify what should be removed if multiple layers stacked? */
+int remove_layer_from_lv(struct logical_volume *lv)
+{
+	struct logical_volume *orig_lv;
+
+	/*
+	 * Before removal, the layer should be cleaned up,
+	 * i.e. additional segments and areas should have been removed.
+	 */
+	if (list_size(&lv->segments) != 1 ||
+	    first_seg(lv)->area_count != 1 ||
+	    seg_type(first_seg(lv), 0) != AREA_LV)
+		return 0;
+
+	orig_lv = seg_lv(first_seg(lv), 0);
+	_move_lv_segments(lv, orig_lv, 0, 0);
+
+	return 1;
+}
+
+/*
+ * Create and insert a linear LV "above" lv_where.
+ * After the insertion, a new LV named lv_where->name + suffix is created
+ * and all segments of lv_where is moved to the new LV.
+ * lv_where will have a single segment which maps linearly to the new LV.
+ */
+struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
+					   struct logical_volume *lv_where,
+					   uint32_t status,
+					   const char *layer_suffix)
+{
+	struct logical_volume *layer_lv;
+	char *name;
+	size_t len;
+	struct segment_type *segtype;
+	struct lv_segment *mapseg;
+
+	if (!(segtype = get_segtype_from_string(lv_where->vg->cmd, "striped")))
+		return_NULL;
+
+	/* create an empty layer LV */
+
+	len = strlen(lv_where->name) + 32;
+	if (!(name = alloca(len))) {
+		log_error("layer name allocation failed. "
+			  "Remove new LV and retry.");
+		return NULL;
+	}
+
+	if (dm_snprintf(name, len, "%s%s", lv_where->name, layer_suffix) < 0) {
+		log_error("layer name allocation failed. "
+			  "Remove new LV and retry.");
+		return NULL;
+	}
+
+	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
+					 ALLOC_INHERIT, 0, lv_where->vg))) {
+		log_error("Creation of layer LV failed");
+		return NULL;
+	}
+
+	log_very_verbose("Inserting layer %s for %s",
+			 layer_lv->name, lv_where->name);
+
+	_move_lv_segments(layer_lv, lv_where, 0, 0);
+
+	/* allocate a new linear segment */
+	if (!(mapseg = alloc_lv_segment(lv_where->vg->cmd->mem, segtype,
+					lv_where, 0, layer_lv->le_count,
+					status, 0, NULL, 1, layer_lv->le_count,
+					0, 0, 0)))
+		return_NULL;
+
+	/* map the new segment to the original underlying are */
+	set_lv_segment_area_lv(mapseg, 0, layer_lv, 0, 0);
+
+	/* add the new segment to the layer LV */
+	list_add(&lv_where->segments, &mapseg->list);
+	lv_where->le_count = layer_lv->le_count;
+	lv_where->size = lv_where->le_count * lv_where->vg->extent_size;
+
+	return layer_lv;
+}
+
+/*
+ * Extend and insert a linear layer LV beneath the source segment area.
+ */
+static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
+					struct lv_segment *seg, uint32_t s,
+					uint32_t status)
+{
+	struct lv_segment *mapseg;
+	struct segment_type *segtype;
+	struct physical_volume *src_pv = seg_pv(seg, s);
+	uint32_t src_pe = seg_pe(seg, s);
+
+	if (seg_type(seg, s) != AREA_PV && seg_type(seg, s) != AREA_LV)
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(layer_lv->vg->cmd, "striped")))
+		return_0;
+
+	/* FIXME Incomplete message? Needs more context */
+	log_very_verbose("Inserting %s:%" PRIu32 "-%" PRIu32 " of %s/%s",
+			 pv_dev_name(src_pv),
+			 src_pe, src_pe + seg->area_len - 1,
+			 seg->lv->vg->name, seg->lv->name);
+
+	/* allocate a new segment */
+	if (!(mapseg = alloc_lv_segment(layer_lv->vg->cmd->mem, segtype,
+					layer_lv, layer_lv->le_count,
+					seg->area_len, status, 0,
+					NULL, 1, seg->area_len, 0, 0, 0)))
+		return_0;
+
+	/* map the new segment to the original underlying are */
+	if (!move_lv_segment_area(mapseg, 0, seg, s))
+		return_0;
+
+	/* add the new segment to the layer LV */
+	list_add(&layer_lv->segments, &mapseg->list);
+	layer_lv->le_count += seg->area_len;
+	layer_lv->size += seg->area_len * layer_lv->vg->extent_size;
+
+	/* map the original area to the new segment */
+	set_lv_segment_area_lv(seg, s, layer_lv, mapseg->le, 0);
+
+	return 1;
+}
+
+/*
+ * Match the segment area to PEs in the pvl
+ * (the segment area boundary should be aligned to PE ranges by
+ *  _adjust_layer_segments() so that there is no partial overlap.)
+ */
+static int _match_seg_area_to_pe_range(struct lv_segment *seg, uint32_t s,
+				       struct pv_list *pvl)
+{
+	struct pe_range *per;
+	uint32_t pe_start, per_end;
+
+	if (!pvl)
+		return 1;
+
+	if (seg_type(seg, s) != AREA_PV || seg_dev(seg, s) != pvl->pv->dev)
+		return 0;
+
+	pe_start = seg_pe(seg, s);
+
+	/* Do these PEs match to any of the PEs in pvl? */
+	list_iterate_items(per, pvl->pe_ranges) {
+		per_end = per->start + per->count - 1;
+
+		if ((pe_start < per->start) || (pe_start > per_end))
+			continue;
+
+		/* FIXME Missing context in this message - add LV/seg details */
+		log_debug("Matched PE range %s:%" PRIu32 "-%" PRIu32 " against "
+			  "%s %" PRIu32 " len %" PRIu32, dev_name(pvl->pv->dev),
+			  per->start, per_end, dev_name(seg_dev(seg, s)),
+			  seg_pe(seg, s), seg->area_len);
+
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * For each segment in lv_where that uses a PV in pvl directly,
+ * split the segment if it spans more than one underlying PV.
+ */
+static int _align_segment_boundary_to_pe_range(struct logical_volume *lv_where,
+					       struct pv_list *pvl)
+{
+	struct lv_segment *seg;
+	struct pe_range *per;
+	uint32_t pe_start, pe_end, per_end, stripe_multiplier, s;
+
+	if (!pvl)
+		return 1;
+
+	/* Split LV segments to match PE ranges */
+	list_iterate_items(seg, &lv_where->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV ||
+			    seg_dev(seg, s) != pvl->pv->dev)
+				continue;
+
+			/* Do these PEs match with the condition? */
+			list_iterate_items(per, pvl->pe_ranges) {
+				pe_start = seg_pe(seg, s);
+				pe_end = pe_start + seg->area_len - 1;
+				per_end = per->start + per->count - 1;
+
+				/* No overlap? */
+				if ((pe_end < per->start) ||
+				    (pe_start > per_end))
+					continue;
+
+				if (seg_is_striped(seg))
+					stripe_multiplier = seg->area_count;
+				else
+					stripe_multiplier = 1;
+
+				if ((per->start != pe_start &&
+				     per->start > pe_start) &&
+				    !lv_split_segment(lv_where, seg->le +
+						      (per->start - pe_start) *
+						      stripe_multiplier))
+					return_0;
+
+				if ((per_end != pe_end &&
+				     per_end < pe_end) &&
+				    !lv_split_segment(lv_where, seg->le +
+						      (per_end - pe_start + 1) *
+						      stripe_multiplier))
+					return_0;
+			}
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Scan lv_where for segments on a PV in pvl, and for each one found
+ * append a linear segment to lv_layer and insert it between the two.
+ *
+ * If pvl is empty, a layer is placed under the whole of lv_where.
+ * If the layer is inserted, lv_where is added to lvs_changed.
+ */
+int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
+				    struct logical_volume *lv_where,
+				    struct logical_volume *layer_lv,
+				    uint32_t status,
+				    struct pv_list *pvl,
+				    struct list *lvs_changed)
+{
+	struct lv_segment *seg;
+	struct lv_list *lvl;
+	int lv_used = 0;
+	uint32_t s;
+
+	if (!_align_segment_boundary_to_pe_range(lv_where, pvl))
+		return_0;
+
+	/* Work through all segments on the supplied PV */
+	list_iterate_items(seg, &lv_where->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (!_match_seg_area_to_pe_range(seg, s, pvl))
+				continue;
+
+			/* First time, add LV to list of LVs affected */
+			if (!lv_used && lvs_changed) {
+				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
+					log_error("lv_list alloc failed");
+					return 0;
+				}
+				lvl->lv = lv_where;
+				list_add(lvs_changed, &lvl->list);
+				lv_used = 1;
+			}
+
+			if (!_extend_layer_lv_for_segment(layer_lv, seg, s,
+							  status)) {
+				log_error("Failed to insert segment in layer "
+					  "LV %s under %s:%" PRIu32 "-%" PRIu32,
+					  layer_lv->name, lv_where->name,
+					  seg->le, seg->le + seg->len);
+				return 0;
+			}
+		}
+	}
+
+	return 1;
+}
--- LVM2/lib/metadata/metadata-exported.h	2007/11/15 22:11:18	1.25
+++ LVM2/lib/metadata/metadata-exported.h	2007/12/20 15:42:55	1.26
@@ -379,6 +379,31 @@
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
+/*
+ * Functions for layer manipulation
+ */
+int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
+				    struct logical_volume *lv_where,
+				    struct logical_volume *layer_lv,
+				    uint32_t status,
+				    struct pv_list *pv,
+				    struct list *lvs_changed);
+int remove_layers_for_segments(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       struct logical_volume *layer_lv,
+			       uint32_t status_mask, struct list *lvs_changed);
+int remove_layers_for_segments_all(struct cmd_context *cmd,
+				   struct logical_volume *layer_lv,
+				   uint32_t status_mask,
+				   struct list *lvs_changed);
+int split_parent_segments_for_layer(struct cmd_context *cmd,
+				    struct logical_volume *layer_lv);
+int remove_layer_from_lv(struct logical_volume *lv);
+struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
+					   struct logical_volume *lv_where,
+					   uint32_t status,
+					   const char *layer_suffix);
+
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
 pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
@@ -422,32 +447,42 @@
 /*
 * Mirroring functions
 */
+int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+		   uint32_t mirrors, uint32_t stripes,
+		   uint32_t region_size, uint32_t log_count,
+		   struct list *pvs, alloc_policy_t alloc, uint32_t flags);
+int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+		      uint32_t mirrors, uint32_t log_count,
+		      struct list *pvs, uint32_t status_mask);
+/* conversion flags */
+#define MIRROR_BY_SEG	0x00000001U	/* segment-by-segment mirror */
+#define MIRROR_BY_LV	0x00000002U	/* mirror by mimage LVs */
+
+uint32_t lv_mirror_count(struct logical_volume *lv);
 struct alloc_handle;
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
-int create_mirror_layers(struct alloc_handle *ah,
-			 uint32_t first_area,
-			 uint32_t num_mirrors,
-			 struct logical_volume *lv,
-			 const struct segment_type *segtype,
-			 uint32_t status,
-			 uint32_t region_size,
-			 struct logical_volume *log_lv);
+int remove_mirrors_from_segments(struct logical_volume *lv,
+				 uint32_t new_mirrors, uint32_t status_mask);
+int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
+			    uint32_t mirrors, uint32_t region_size,
+			    struct list *allocatable_pvs, alloc_policy_t alloc);
 
 int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			 struct list *removable_pvs, unsigned remove_log);
+int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
+		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      struct list *allocatable_pvs, alloc_policy_t alloc,
+		      uint32_t log_count);
+int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct list *removable_pvs);
+int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		   uint32_t log_count, uint32_t region_size,
+		   struct list *allocatable_pvs, alloc_policy_t alloc);
+
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			      struct list *removable_pvs, unsigned remove_log);
 
-int insert_pvmove_mirrors(struct cmd_context *cmd,
-			  struct logical_volume *lv_mirr,
-			  struct list *source_pvl,
-			  struct logical_volume *lv,
-			  struct list *allocatable_pvs,
-			  alloc_policy_t alloc,
-			  struct list *lvs_changed);
-int remove_pvmove_mirrors(struct volume_group *vg,
-			  struct logical_volume *lv_mirr);
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.h	2007/11/05 17:17:55	1.174
+++ LVM2/lib/metadata/metadata.h	2007/12/20 15:42:55	1.175
@@ -295,11 +295,6 @@
 /*
  * Mirroring functions
  */
-int add_mirror_layers(struct alloc_handle *ah,
-		      uint32_t num_mirrors,
-		      uint32_t existing_mirrors,
-		      struct logical_volume *lv,
-		      const struct segment_type *segtype);
 
 /*
  * Given mirror image or mirror log segment, find corresponding mirror segment 
--- LVM2/lib/metadata/mirror.c	2007/11/22 13:57:21	1.45
+++ LVM2/lib/metadata/mirror.c	2007/12/20 15:42:55	1.46
@@ -18,6 +18,7 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
+#include "archiver.h"
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
@@ -31,6 +32,14 @@
 #define MIRROR_ALLOCATE          1
 #define MIRROR_ALLOCATE_ANYWHERE 2
 
+/*
+ * Returns the number of mirrors of the LV
+ */
+uint32_t lv_mirror_count(struct logical_volume *lv)
+{
+	return (lv->status & MIRRORED) ? first_seg(lv)->area_count : 1;
+}
+
 struct lv_segment *find_mirror_seg(struct lv_segment *seg)
 {
 	return seg->mirror_seg;
@@ -56,29 +65,6 @@
 	return region_size;
 }
 
-static void _move_lv_segments(struct logical_volume *lv_to, struct logical_volume *lv_from)
-{
-	struct lv_segment *seg;
-
-	lv_to->segments = lv_from->segments;
-	lv_to->segments.n->p = &lv_to->segments;
-	lv_to->segments.p->n = &lv_to->segments;
-
-	list_iterate_items(seg, &lv_to->segments)
-		seg->lv = lv_to;
-
-/* FIXME set or reset seg->mirror_seg (according to status)? */
-
-	list_init(&lv_from->segments);
-
-	lv_to->le_count = lv_from->le_count;
-	lv_to->size = lv_from->size;
-
-	lv_from->le_count = 0;
-	lv_from->size = 0;
-}
-
-
 /*
  * Delete independent/orphan LV, it must acquire lock.
  */
@@ -196,7 +182,7 @@
 	if (num_mirrors == 1) {
 		lv1 = seg_lv(mirrored_seg, 0);
 		extents = lv1->le_count;
-		_move_lv_segments(mirrored_seg->lv, lv1);
+		remove_layer_from_lv(mirrored_seg->lv);
 		mirrored_seg->lv->status &= ~MIRRORED;
 		mirrored_seg->lv->status &= ~MIRROR_NOTSYNCED;
 		remove_log = 1;
@@ -352,7 +338,7 @@
 			      struct list *removable_pvs, unsigned remove_log)
 {
 	int r;
-	int insync = 0;
+	int in_sync = 0;
 	int log_policy, dev_policy;
 	uint32_t old_num_mirrors = mirrored_seg->area_count;
 	int had_log = (mirrored_seg->log_lv) ? 1 : 0;
@@ -364,14 +350,14 @@
 		log_error("WARNING: Unable to determine mirror sync status of %s/%s.",
 			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 	else if (sync_percent >= 100.0)
-		insync = 1;
+		in_sync = 1;
 
 	/*
 	 * While we are only removing devices, we can have sync set.
 	 * Setting this is only useful if we are moving to core log
 	 * otherwise the disk log will contain the sync information
 	 */
-	init_mirror_in_sync(insync);
+	init_mirror_in_sync(in_sync);
 
 	r = remove_mirror_images(mirrored_seg, num_mirrors,
 				 removable_pvs, remove_log);
@@ -388,7 +374,7 @@
 	r = replace_mirror_images(mirrored_seg,
 				  (dev_policy != MIRROR_REMOVE) ?
 				  old_num_mirrors : num_mirrors,
-				  log_policy, insync);
+				  log_policy, in_sync);
 
 	if (!r)
 		/* Failed to replace device(s) */
@@ -414,12 +400,10 @@
 	return 1;
 }
 
-static int _create_layers_for_mirror(struct alloc_handle *ah,
-				     uint32_t first_area,
-				     uint32_t num_mirrors,
-				     struct logical_volume *lv,
-				     const struct segment_type *segtype __attribute((unused)),
-				     struct logical_volume **img_lvs)
+static int _create_mimage_lvs(struct alloc_handle *ah,
+			      uint32_t num_mirrors,
+			      struct logical_volume *lv,
+			      struct logical_volume **img_lvs)
 {
 	uint32_t m;
 	char *img_name;
@@ -447,13 +431,10 @@
 			return 0;
 		}
 
-		if (m < first_area)
-			continue;
-
-		if (!lv_add_segment(ah, m - first_area, 1, img_lvs[m],
+		if (!lv_add_segment(ah, m, 1, img_lvs[m],
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, NULL, 0, 0, 0, NULL)) {
+				    0, 0, 0, NULL)) {
 			log_error("Aborting. Failed to add mirror image segment "
 				  "to %s. Remove new LV and retry.",
 				  img_lvs[m]->name);
@@ -464,318 +445,47 @@
 	return 1;
 }
 
-int create_mirror_layers(struct alloc_handle *ah,
-			 uint32_t first_area,
-			 uint32_t num_mirrors,
-			 struct logical_volume *lv,
-			 const struct segment_type *segtype,
-			 uint32_t status __attribute((unused)),
-			 uint32_t region_size,
-			 struct logical_volume *log_lv)
-{
-	struct logical_volume **img_lvs;
-	
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * num_mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		return 0;
-	}
-
-	if (!_create_layers_for_mirror(ah, first_area, num_mirrors, lv,
-				       segtype, img_lvs)) {
-		stack;
-		return 0;
-	}
-
-	/* Already got the parent mirror segment? */
-	if (lv->status & MIRRORED)
-		return lv_add_more_mirrored_areas(lv, img_lvs, num_mirrors,
-						  MIRROR_IMAGE);
-
-	/* Already got a non-mirrored area to be converted? */
-	if (first_area)
-		_move_lv_segments(img_lvs[0], lv);
-
-	if (!lv_add_mirror_segment(ah, lv, img_lvs, num_mirrors, segtype,
-				   0, region_size, log_lv)) {
-		log_error("Aborting. Failed to add mirror segment. "
-			  "Remove new LV and retry.");
-		return 0;
-	}
-
-	lv->status |= MIRRORED;
-
-	return 1;
-}
-
-int add_mirror_layers(struct alloc_handle *ah,
-		      uint32_t num_mirrors,
-		      uint32_t existing_mirrors __attribute((unused)),
-		      struct logical_volume *lv,
-		      const struct segment_type *segtype)
-{
-	struct logical_volume **img_lvs;
-
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * num_mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		return 0;
-	}
-
-	if (!_create_layers_for_mirror(ah, 0, num_mirrors,
-				       lv, segtype,
-				       img_lvs)) {
-		stack;
-		return 0;
-	}
-
-	return lv_add_more_mirrored_areas(lv, img_lvs, num_mirrors, 0);
-}
-
-static int _alloc_and_insert_pvmove_seg(struct logical_volume *lv_mirr,
-					struct lv_segment *seg, uint32_t s,
-					struct list *allocatable_pvs,
-					alloc_policy_t alloc,
-					const struct segment_type *segtype)
-{
-	struct physical_volume *pv = seg_pv(seg, s);
-	uint32_t start_le = lv_mirr->le_count;
-	uint32_t pe = seg_pe(seg, s);
-
-	log_very_verbose("Moving %s:%u-%u of %s/%s", pv_dev_name(pv),
-			 pe, pe + seg->area_len - 1,
-			 seg->lv->vg->name, seg->lv->name);
-
-	release_lv_segment_area(seg, s, seg->area_len);
-
-	if (!lv_extend(lv_mirr, segtype, 1,
-	       	seg->area_len, 0u, seg->area_len,
-	       	pv, pe,
-	       	PVMOVE, allocatable_pvs,
-	       	alloc)) {
-		log_error("Unable to allocate "
-			  "temporary LV for pvmove.");
-		return 0;
-	}
-
-	set_lv_segment_area_lv(seg, s, lv_mirr, start_le, 0);
-
-	return 1;
-}
-
-/* 
- * Replace any LV segments on given PV with temporary mirror.
- * Returns list of LVs changed.
+/*
+ * Remove mirrors from each segment.
+ * 'new_mirrors' is the number of mirrors after the removal. '0' for linear.
+ * If 'status_mask' is non-zero, the removal happens only when all segments
+ * has the status bits on.
  */
-int insert_pvmove_mirrors(struct cmd_context *cmd,
-			  struct logical_volume *lv_mirr,
-			  struct list *source_pvl,
-			  struct logical_volume *lv,
-			  struct list *allocatable_pvs,
-			  alloc_policy_t alloc,
-			  struct list *lvs_changed)
+int remove_mirrors_from_segments(struct logical_volume *lv,
+				 uint32_t new_mirrors, uint32_t status_mask)
 {
 	struct lv_segment *seg;
-	struct lv_list *lvl;
-	struct pv_list *pvl;
-	int lv_used = 0;
-	uint32_t s, extent_count = 0u;
-	const struct segment_type *segtype;
-	struct pe_range *per;
-	uint32_t pe_start, pe_end, per_end, stripe_multiplier;
-
-	/* Only 1 PV may feature in source_pvl */
-	pvl = list_item(source_pvl->n, struct pv_list);
-
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "mirror"))) {
-		stack;
-		return 0;
-	}
-
-        if (activation() && segtype->ops->target_present &&
-            !segtype->ops->target_present(NULL)) {
-                log_error("%s: Required device-mapper target(s) not "
-                          "detected in your kernel", segtype->name);
-                return 0;
-        }
+	uint32_t s;
 
-	/* Split LV segments to match PE ranges */
+	/* Check the segment params are compatible */
 	list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV ||
-			    seg_dev(seg, s) != pvl->pv->dev)
-				continue;
-
-			/* Do these PEs need moving? */
-			list_iterate_items(per, pvl->pe_ranges) {
-				pe_start = seg_pe(seg, s);
-				pe_end = pe_start + seg->area_len - 1;
-				per_end = per->start + per->count - 1;
-
-				/* No overlap? */
-				if ((pe_end < per->start) ||
-				    (pe_start > per_end))
-					continue;
-
-				if (seg_is_striped(seg))
-					stripe_multiplier = seg->area_count;
-				else
-					stripe_multiplier = 1;
-
-				if ((per->start != pe_start &&
-				     per->start > pe_start) &&
-				    !lv_split_segment(lv, seg->le +
-						      (per->start - pe_start) *
-						      stripe_multiplier)) {
-					stack;
-					return 0;
-				}
-
-				if ((per_end != pe_end &&
-				     per_end < pe_end) &&
-				    !lv_split_segment(lv, seg->le +
-						      (per_end - pe_start + 1) *
-						      stripe_multiplier)) {
-					stack;
-					return 0;
-				}
-			}
+		if (!seg_is_mirrored(seg)) {
+			log_error("Segment is not mirrored: %s:%" PRIu32,
+				  lv->name, seg->le);
+			return 0;
+		} if ((seg->status & status_mask) != status_mask) {
+			log_error("Segment status does not match: %s:%" PRIu32
+				  " status:0x%x/0x%x", lv->name, seg->le,
+				  seg->status, status_mask);
+			return 0;
 		}
 	}
 
-	/* Work through all segments on the supplied PV */
+	/* Convert the segments */
 	list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV ||
-			    seg_dev(seg, s) != pvl->pv->dev)
-				continue;
-
-			pe_start = seg_pe(seg, s);
-
-			/* Do these PEs need moving? */
-			list_iterate_items(per, pvl->pe_ranges) {
-				per_end = per->start + per->count - 1;
-
-				if ((pe_start < per->start) ||
-				    (pe_start > per_end))
-					continue;
-
-				log_debug("Matched PE range %u-%u against "
-					  "%s %u len %u", per->start, per_end,
-					  dev_name(seg_dev(seg, s)),
-					  seg_pe(seg, s),
-					  seg->area_len);
-
-				/* First time, add LV to list of LVs affected */
-				if (!lv_used) {
-					if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-						log_error("lv_list alloc failed");
-						return 0;
-					}
-					lvl->lv = lv;
-					list_add(lvs_changed, &lvl->list);
-					lv_used = 1;
-				}
-	
-				if (!_alloc_and_insert_pvmove_seg(lv_mirr, seg, s,
-								  allocatable_pvs,
-								  alloc, segtype))
-					return_0;
-
-				extent_count += seg->area_len;
-	
-				lv->status |= LOCKED;
-
-				break;
-			}
+		if (!new_mirrors && seg->extents_copied == seg->area_len) {
+			if (!move_lv_segment_area(seg, 0, seg, 1))
+				return_0;
 		}
-	}
-
-	log_verbose("Moving %u extents of logical volume %s/%s", extent_count,
-		    lv->vg->name, lv->name);
-
-	return 1;
-}
-
-/* Remove a temporary mirror */
-int remove_pvmove_mirrors(struct volume_group *vg,
-			  struct logical_volume *lv_mirr)
-{
-	struct lv_list *lvl;
-	struct logical_volume *lv1;
-	struct lv_segment *seg, *mir_seg;
-	uint32_t s, c;
-
-	/* Loop through all LVs except the temporary mirror */
-	list_iterate_items(lvl, &vg->lvs) {
-		lv1 = lvl->lv;
-		if (lv1 == lv_mirr)
-			continue;
-
-		/* Find all segments that point at the temporary mirror */
-		list_iterate_items(seg, &lv1->segments) {
-			for (s = 0; s < seg->area_count; s++) {
-				if (seg_type(seg, s) != AREA_LV ||
-				    seg_lv(seg, s) != lv_mirr)
-					continue;
 
-				/* Find the mirror segment pointed at */
-				if (!(mir_seg = find_seg_by_le(lv_mirr,
-							       seg_le(seg, s)))) {
-					/* FIXME Error message */
-					log_error("No segment found with LE");
-					return 0;
-				}
-
-				/* Check the segment params are compatible */
-				/* FIXME Improve error mesg & remove restrcn */
-				if (!seg_is_mirrored(mir_seg) ||
-				    !(mir_seg->status & PVMOVE) ||
-				    mir_seg->le != seg_le(seg, s) ||
-				    mir_seg->area_count != 2 ||
-				    mir_seg->area_len != seg->area_len) {
-					log_error("Incompatible segments");
-					return 0;
-				}
-
-				/* Replace original segment with newly-mirrored
-				 * area (or original if reverting)
-				 */
-				if (mir_seg->extents_copied == 
-				        mir_seg->area_len)
-					c = 1;
-				else
-					c = 0;
-
-				if (!move_lv_segment_area(seg, s, mir_seg, c)) {
-					stack;
-					return 0;
-				}
-
-				release_lv_segment_area(mir_seg, c ? 0 : 1U, mir_seg->area_len);
+		for (s = new_mirrors + 1; s < seg->area_count; s++)
+			release_lv_segment_area(seg, s, seg->area_len);
 
-				/* Replace mirror with error segment */
-				if (!
-				    (mir_seg->segtype =
-				     get_segtype_from_string(vg->cmd,
-							     "error"))) {
-					log_error("Missing error segtype");
-					return 0;
-				}
-				mir_seg->area_count = 0;
-
-				/* FIXME Assumes only one pvmove at a time! */
-				lv1->status &= ~LOCKED;
-			}
-		}
-		if (!lv_merge_segments(lv1))
-			stack;
-
-	}
+		seg->area_count = new_mirrors + 1;
 
-	if (!lv_empty(lv_mirr)) {
-		stack;
-		return 0;
+		if (!new_mirrors)
+			seg->segtype = get_segtype_from_string(lv->vg->cmd,
+							       "striped");
 	}
 
 	return 1;
@@ -943,3 +653,568 @@
 	return 1;
 }
 
+/*
+ * Add mirrors to "linear" or "mirror" segments
+ */
+int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
+			    uint32_t mirrors, uint32_t region_size,
+			    struct list *allocatable_pvs, alloc_policy_t alloc)
+{
+	struct alloc_handle *ah;
+	const struct segment_type *segtype;
+	struct list *parallel_areas;
+	uint32_t adjusted_region_size;
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+							   lv->le_count,
+							   region_size);
+
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0,
+				    lv->le_count, allocatable_pvs, alloc,
+				    parallel_areas))) {
+		log_error("Unable to allocate mirror extents for %s.", lv->name);
+		return 0;
+	}
+
+	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
+		log_error("Failed to add mirror areas to %s", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Convert mirror log
+ *
+ * FIXME: Can't handle segment-by-segment mirror (like pvmove)
+ */
+int remove_mirror_log(struct cmd_context *cmd,
+		      struct logical_volume *lv,
+		      struct list *removable_pvs)
+{
+	float sync_percent;
+
+	/* Unimplemented features */
+	if (list_size(&lv->segments) != 1) {
+		log_error("Multiple-segment mirror is not supported");
+		return 0;
+	}
+
+	/* Had disk log, switch to core. */
+	if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+		log_error("Unable to determine mirror sync status.");
+		return 0;
+	}
+
+	if (sync_percent >= 100.0)
+		init_mirror_in_sync(1);
+	else {
+		/* A full resync will take place */
+		lv->status &= ~MIRROR_NOTSYNCED;
+		init_mirror_in_sync(0);
+	}
+
+	if (!remove_mirror_images(first_seg(lv), lv_mirror_count(lv),
+				  removable_pvs, 1U))
+		return_0;
+
+	return 1;
+}
+
+/*
+ * Initialize the LV with 'value'.
+ */
+static int _set_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	   uint64_t sectors, int value)
+{
+	struct device *dev;
+	char *name;
+
+	/*
+	 * FIXME:
+	 * <clausen> also, more than 4k
+	 * <clausen> say, reiserfs puts it's superblock 32k in, IIRC
+	 * <ejt_> k, I'll drop a fixme to that effect
+	 *	   (I know the device is at least 4k, but not 32k)
+	 */
+	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
+		log_error("Name allocation failed - device not cleared");
+		return 0;
+	}
+
+	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+			 lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", lv->name);
+		return 0;
+	}
+
+	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
+
+	if (!(dev = dev_cache_get(name, NULL))) {
+		log_error("%s: not found: device not cleared", name);
+		return 0;
+	}
+
+	if (!dev_open_quiet(dev))
+		return 0;
+
+	dev_set(dev, UINT64_C(0),
+		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
+		value);
+	dev_flush(dev);
+	dev_close_immediate(dev);
+
+	return 1;
+}
+
+/*
+ * This function writes a new header to the mirror log header to the lv
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+#include "xlate.h"
+#define MIRROR_MAGIC 0x4D695272
+#define MIRROR_DISK_VERSION 2
+
+static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct device *dev;
+	char *name;
+	struct { /* The mirror log header */
+		uint32_t magic;
+		uint32_t version;
+		uint64_t nr_regions;
+	} log_header;
+
+	log_header.magic = xlate32(MIRROR_MAGIC);
+	log_header.version = xlate32(MIRROR_DISK_VERSION);
+	log_header.nr_regions = xlate64((uint64_t)-1);
+
+	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
+		log_error("Name allocation failed - log header not written (%s)",
+			lv->name);
+		return 0;
+	}
+
+	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+			 lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - log header not written (%s)", lv->name);
+		return 0;
+	}
+
+	log_verbose("Writing log header to device, %s", lv->name);
+
+	if (!(dev = dev_cache_get(name, NULL))) {
+		log_error("%s: not found: log header not written", name);
+		return 0;
+	}
+
+	if (!dev_open_quiet(dev))
+		return 0;
+
+	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
+		log_error("Failed to write log header to %s", name);
+		dev_close_immediate(dev);
+		return 0;
+	}
+
+	dev_close_immediate(dev);
+
+	return 1;
+}
+
+/*
+ * Initialize mirror log contents
+ */
+static int _init_mirror_log(struct cmd_context *cmd,
+			    struct logical_volume *log_lv, int in_sync,
+			    struct list *tags)
+{
+	struct str_list *sl;
+
+	if (!activation() && in_sync) {
+		log_error("Aborting. Unable to create in-sync mirror log "
+			  "while activation is disabled.");
+		return 0;
+	}
+
+	/* Temporary tag mirror log for activation */
+	list_iterate_items(sl, tags)
+		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
+			log_error("Aborting. Unable to tag mirror log.");
+			return 0;
+		}
+
+	/* store mirror log on disk(s) */
+	if (!vg_write(log_lv->vg))
+		return_0;
+
+	backup(log_lv->vg);
+
+	if (!vg_commit(log_lv->vg))
+		return_0;
+
+	if (!activate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to activate mirror log.");
+		goto revert_new_lv;
+	}
+
+	/* Remove the temporary tags */
+	list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from mirror log.",
+				  sl->str);
+
+	if (activation() && !_set_lv(cmd, log_lv, log_lv->size,
+				    in_sync ? -1 : 0)) {
+		log_error("Aborting. Failed to wipe mirror log.");
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (activation() && !_write_log_header(cmd, log_lv)) {
+		log_error("Aborting. Failed to write mirror log header.");
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to deactivate mirror log. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	log_lv->status &= ~VISIBLE_LV;
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Unable to deactivate mirror log LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+revert_new_lv:
+	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
+	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned log LV before retrying.");
+	return 0;
+}
+
+static struct logical_volume *_create_mirror_log(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct alloc_handle *ah,
+					 alloc_policy_t alloc,
+					 const char *lv_name)
+{
+	struct logical_volume *log_lv;
+	char *log_name;
+	size_t len;
+
+	len = strlen(lv_name) + 32;
+	if (!(log_name = alloca(len))) {
+		log_error("log_name allocation failed.");
+		return NULL;
+	}
+
+	if (dm_snprintf(log_name, len, "%s_mlog", lv->name) < 0) {
+		log_error("log_name allocation failed.");
+		return NULL;
+	}
+
+	if (!(log_lv = lv_create_empty(log_name, NULL,
+				       VISIBLE_LV | LVM_READ | LVM_WRITE,
+				       alloc, 0, lv->vg)))
+		return_NULL;
+
+	if (!lv_add_log_segment(ah, log_lv))
+		return_NULL;
+
+	return log_lv;
+}
+
+static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
+						 struct alloc_handle *ah,
+						 struct logical_volume *lv,
+						 uint32_t log_count,
+						 uint32_t region_size,
+						 alloc_policy_t alloc,
+						 int in_sync)
+{
+	struct logical_volume *log_lv;
+
+	init_mirror_in_sync(in_sync);
+
+	if (!(log_lv = _create_mirror_log(cmd, lv, ah, alloc, lv->name))) {
+		log_error("Failed to create mirror log.");
+		return NULL;
+	}
+
+	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags)) {
+		log_error("Failed to create mirror log.");
+		return NULL;
+	}
+
+	return log_lv;
+}
+
+static void _add_mirror_log(struct logical_volume *lv,
+			    struct logical_volume *log_lv)
+{
+	first_seg(lv)->log_lv = log_lv;
+	log_lv->status |= MIRROR_LOG;
+	first_seg(log_lv)->mirror_seg = first_seg(lv);
+}
+
+int add_mirror_log(struct cmd_context *cmd,
+		   struct logical_volume *lv,
+		   uint32_t log_count,
+		   uint32_t region_size,
+		   struct list *allocatable_pvs,
+		   alloc_policy_t alloc)
+{
+	struct alloc_handle *ah;
+	const struct segment_type *segtype;
+	struct list *parallel_areas;
+	float sync_percent;
+	int in_sync;
+	struct logical_volume *log_lv;
+
+	/* Unimplemented features */
+	if (log_count > 1) {
+		log_error("log_count > 1 is not supported");
+		return 0;
+	}
+	if (list_size(&lv->segments) != 1) {
+		log_error("Multiple-segment mirror is not supported");
+		return 0;
+	}
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
+		return 0;
+	}
+
+	/* allocate destination extents */
+	ah = allocate_extents(lv->vg, NULL, segtype,
+			      0, 0, log_count, 0,
+			      allocatable_pvs, alloc, parallel_areas);
+	if (!ah) {
+		log_error("Unable to allocate temporary LV for pvmove.");
+		return 0;
+	}
+
+	/* check sync status */
+	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
+	    sync_percent >= 100.0)
+		in_sync = 1;
+	else
+		in_sync = 0;
+
+	if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
+					  region_size, alloc, in_sync)))
+		return_0;
+
+	_add_mirror_log(lv, log_lv);
+
+	alloc_destroy(ah);
+	return 1;
+}
+
+/*
+ * Convert "linear" LV to "mirror".
+ */
+int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
+		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      struct list *allocatable_pvs, alloc_policy_t alloc,
+		      uint32_t log_count)
+{
+	struct alloc_handle *ah;
+	const struct segment_type *segtype;
+	struct list *parallel_areas;
+	struct logical_volume **img_lvs, *log_lv;
+
+	if (stripes > 1) {
+		log_error("stripes > 1 is not supported");
+		return 0;
+	}
+
+	/*
+	 * allocate destination extents
+	 */
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	ah = allocate_extents(lv->vg, NULL, segtype,
+			      stripes, mirrors, log_count, lv->le_count,
+			      allocatable_pvs, alloc, parallel_areas);
+	if (!ah) {
+		log_error("Unable to allocate extents for mirror(s).");
+		return 0;
+	}
+
+	/*
+	 * create and initialize mirror log
+	 */
+	if (log_count &&
+	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
+					  region_size, alloc, 0)))
+		return_0;
+
+	/* The log initialization involves vg metadata commit.
+	   So from here on, if failure occurs, the log must be explicitly
+	   removed and the updated vg metadata should be committed. */
+
+	/*
+	 * insert a mirror layer
+	 */
+	if (list_size(&lv->segments) != 1 ||
+	    seg_type(first_seg(lv), 0) != AREA_LV)
+		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
+			goto out_remove_log;
+
+	/*
+	 * create mirror image LVs
+	 */
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
+		log_error("img_lvs allocation failed. "
+			  "Remove new LV and retry.");
+		goto out_remove_log;
+	}
+
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+		goto out_remove_log;
+
+	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
+			       MIRROR_IMAGE | (lv->status & LOCKED),
+			       region_size)) {
+		log_error("Aborting. Failed to add mirror segment. "
+			  "Remove new LV and retry.");
+		goto out_remove_imgs;
+	}
+
+	if (log_count)
+		_add_mirror_log(lv, log_lv);
+
+	lv->status |= MIRRORED;
+
+	alloc_destroy(ah);
+	return 1;
+
+  out_remove_log:
+	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
+	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned log LV before retrying.");
+
+  out_remove_imgs:
+	return 0;
+}
+
+/*
+ * Generic interface for adding mirror and/or mirror log.
+ * 'mirror' is the number of mirrors to be added.
+ * 'pvs' is either allocatable pvs.
+ */
+int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+		   uint32_t mirrors, uint32_t stripes,
+		   uint32_t region_size, uint32_t log_count,
+		   struct list *pvs, alloc_policy_t alloc, uint32_t flags)
+{
+	if (!mirrors && !log_count) {
+		log_error("No conversion is requested");
+		return 0;
+	}
+
+	if (flags & MIRROR_BY_SEG) {
+		if (log_count) {
+			log_error("Persistent log is not supported on "
+				  "segment-by-segment mirroring");
+			return 0;
+		}
+		if (stripes > 1) {
+			log_error("Striped-mirroring is not supported on "
+				  "segment-by-segment mirroring");
+			return 0;
+		}
+
+		return add_mirrors_to_segments(cmd, lv, mirrors,
+					       region_size, pvs, alloc);
+	} else if (flags & MIRROR_BY_LV) {
+		if (!mirrors)
+			return add_mirror_log(cmd, lv, log_count,
+					      region_size, pvs, alloc);
+		return add_mirror_images(cmd, lv, mirrors,
+					 stripes, region_size,
+					 pvs, alloc, log_count);
+	}
+
+	log_error("Unsupported mirror conversion type");
+	return 0;
+}
+
+/*
+ * Generic interface for removing mirror and/or mirror log.
+ * 'mirror' is the number of mirrors to be removed.
+ * 'pvs' is removable pvs.
+ */
+int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+		      uint32_t mirrors, uint32_t log_count, struct list *pvs,
+		      uint32_t status_mask)
+{
+	uint32_t new_mirrors;
+	struct lv_segment *seg;
+
+	if (!mirrors && !log_count) {
+		log_error("No conversion is requested");
+		return 0;
+	}
+
+	seg = first_seg(lv);
+	if (!seg_is_mirrored(seg)) {
+		log_error("Not a mirror segment");
+		return 0;
+	}
+
+	if (seg->area_count <= mirrors) {
+		log_error("Removing more than existing: %d <= %d",
+			  seg->area_count, mirrors);
+		return 0;
+	}
+	new_mirrors = seg->area_count - mirrors - 1;
+
+	/* MIRROR_BY_LV */
+	if (seg_type(seg, 0) == AREA_LV &&
+	    seg_lv(seg, 0)->status & MIRROR_IMAGE) {
+		return remove_mirror_images(first_seg(lv), new_mirrors + 1,
+					    pvs, log_count ? 1U : 0);
+	}
+
+	/* MIRROR_BY_SEG */
+	if (log_count) {
+		log_error("Persistent log is not supported on "
+			  "segment-by-segment mirroring");
+		return 0;
+	}
+	return remove_mirrors_from_segments(lv, new_mirrors, status_mask);
+}
+
--- LVM2/scripts/fsadm.sh	2007/12/17 14:47:22	1.2
+++ LVM2/scripts/fsadm.sh	2007/12/20 15:42:55	1.3
@@ -40,8 +40,8 @@
 UMOUNT=umount
 MKDIR=mkdir
 RM=rm
-BLOCKDEV=blockdev
-BLKID=blkid
+BLOCKDEV=echo 
+BLKID=echo
 GREP=grep
 READLINK=readlink
 FSCK=fsck
@@ -133,7 +133,7 @@
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	VOLUME=$($READLINK -e -n "$1")
+	VOLUME=$($READLINK -n "$1")
 	# use /dev/null as cache file to be sure about the result
 	FSTYPE=$($BLKID -c /dev/null -o value -s TYPE "$VOLUME" || error "Cannot get FSTYPE of \"$VOLUME\"")
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
--- LVM2/tools/lvconvert.c	2007/12/05 22:11:20	1.47
+++ LVM2/tools/lvconvert.c	2007/12/20 15:42:55	1.48
@@ -232,10 +232,6 @@
 {
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
-	struct alloc_handle *ah = NULL;
-	struct logical_volume *log_lv;
-	struct list *parallel_areas;
-	float sync_percent;
 	const char *mirrorlog;
 	unsigned corelog = 0;
 
@@ -312,8 +308,8 @@
 			return 1;
 		}
 
-		if (!remove_mirror_images(seg, 1,
-					  lp->pv_count ? lp->pvh : NULL, 1))
+		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - 1, 1,
+				       lp->pv_count ? lp->pvh : NULL, 0))
 			return_0;
 		goto commit_changes;
 	}
@@ -332,33 +328,13 @@
 			}
 		}
 
-		if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
-			return_0;
-
-		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
-					    1, lp->mirrors - 1,
-					    corelog ? 0U : 1U,
-					    lv->le_count, lp->pvh, lp->alloc,
-					    1, parallel_areas)))
-			return_0;
-
-		lp->region_size = adjusted_mirror_region_size(lv->vg->extent_size,
-							      lv->le_count,
-							      lp->region_size);
-
-		log_lv = NULL;
-		if (!corelog &&
-		    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
-						 lp->alloc,
-						 lv->name, 0, &lv->tags))) {
-			log_error("Failed to create mirror log.");
-			return 0;
-		}
-
-		if (!create_mirror_layers(ah, 1, lp->mirrors, lv,
-					  lp->segtype, 0,
-					  lp->region_size,
-					  log_lv))
+		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, 1,
+				    adjusted_mirror_region_size(
+						lv->vg->extent_size,
+						lv->le_count,
+						lp->region_size),
+				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    MIRROR_BY_LV))
 			return_0;
 		goto commit_changes;
 	}
@@ -375,54 +351,15 @@
 
 	if (lp->mirrors == existing_mirrors) {
 		if (!seg->log_lv && !corelog) {
-			/* No disk log present, add one. */
-			if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+			if (!add_mirror_log(cmd, lv, 1,
+					    adjusted_mirror_region_size(
+							lv->vg->extent_size,
+							lv->le_count,
+							lp->region_size),
+					    lp->pvh, lp->alloc))
 				return_0;
-			if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-				log_error("Unable to determine mirror sync status.");
-				return 0;
-			}
-
-			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype, 0,
-						    0, 1, 0, lp->pvh, lp->alloc,
-						    1, parallel_areas))) {
-				stack;
-				return 0;
-			}
-
-			if (sync_percent >= 100.0)
-				init_mirror_in_sync(1);
-			else
-				init_mirror_in_sync(0);
-
-			if (!(log_lv = create_mirror_log(cmd, lv->vg, ah,
-							 lp->alloc, lv->name,
-							 (sync_percent >= 100.0) ?
-							 1 : 0, &lv->tags))) {
-				log_error("Failed to create mirror log.");
-				return 0;
-			}
-			seg->log_lv = log_lv;
-			log_lv->status |= MIRROR_LOG;
-			first_seg(log_lv)->mirror_seg = seg;
 		} else if (seg->log_lv && corelog) {
-			/* Had disk log, switch to core. */
-			if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-				log_error("Unable to determine mirror sync status.");
-				return 0;
-			}
-
-			if (sync_percent >= 100.0)
-				init_mirror_in_sync(1);
-			else {
-				/* A full resync will take place */
-				lv->status &= ~MIRROR_NOTSYNCED;
-				init_mirror_in_sync(0);
-			}
-
-			if (!remove_mirror_images(seg, lp->mirrors,
-						  lp->pv_count ?
-						  lp->pvh : NULL, 1))
+			if (!remove_mirror_log(cmd, lv, lp->pvh))
 				return_0;
 		} else {
 			/* No change */
@@ -442,9 +379,8 @@
 		return 0;
 	} else {
 		/* Reduce number of mirrors */
-		if (!remove_mirror_images(seg, lp->mirrors,
-					  lp->pv_count ?
-					  lp->pvh : NULL, 0))
+		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
+				       0, lp->pv_count ? lp->pvh : NULL, 0))
 			return_0;
 	}
 
--- LVM2/tools/lvcreate.c	2007/12/05 22:11:20	1.163
+++ LVM2/tools/lvcreate.c	2007/12/20 15:42:55	1.164
@@ -409,7 +409,7 @@
 			return 0;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "mirror"))) {
+		if (!(lp->segtype = get_segtype_from_string(cmd, "striped"))) {
 			stack;
 			return 0;
 		}
@@ -524,11 +524,10 @@
 	uint32_t size_rest;
 	uint32_t status = 0;
 	uint64_t tmp_size;
-	struct logical_volume *lv, *org = NULL, *log_lv = NULL;
+	struct logical_volume *lv, *org = NULL;
 	struct list *pvh, tags;
 	const char *tag = NULL;
 	int origin_active = 0;
-	struct alloc_handle *ah = NULL;
 	char lv_name_buf[128];
 	const char *lv_name;
 	struct lvinfo info;
@@ -745,38 +744,6 @@
 		}
 	}
 
-	if (lp->mirrors > 1) {
-		/* FIXME Calculate how many extents needed for the log */
-
-		if (!(ah = allocate_extents(vg, NULL, lp->segtype, lp->stripes,
-					    lp->mirrors, lp->corelog ? 0U : 1U,
-					    lp->extents, pvh, lp->alloc, 1, NULL)))
-			return_0;
-
-		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
-							      lp->extents,
-							      lp->region_size);
-
-		init_mirror_in_sync(lp->nosync);
-
-		if (lp->nosync) {
-			log_warn("WARNING: New mirror won't be synchronised. "
-				  "Don't read what you didn't write!");
-			status |= MIRROR_NOTSYNCED;
-		}
-
-		list_init(&tags);
-		if (tag)
-			str_list_add(cmd->mem, &tags, tag);
-
-		if (!lp->corelog &&
-		    !(log_lv = create_mirror_log(cmd, vg, ah, lp->alloc,
-						 lv_name, lp->nosync, &tags))) {
-			log_error("Failed to create mirror log.");
-			return 0;
-		}
-	}
-
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
 				   status, lp->alloc, 0, vg))) {
 		stack;
@@ -802,19 +769,34 @@
 		goto error;
 	}
 
+	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
+		       1, lp->extents, NULL, 0u, 0u, pvh, lp->alloc))
+		return_0;
+
 	if (lp->mirrors > 1) {
-		if (!create_mirror_layers(ah, 0, lp->mirrors, lv,
-					  lp->segtype, 0,
-					  lp->region_size, log_lv)) {
-			stack;
-			goto error;
+		init_mirror_in_sync(lp->nosync);
+
+		if (lp->nosync) {
+			log_warn("WARNING: New mirror won't be synchronised. "
+				  "Don't read what you didn't write!");
+			status |= MIRROR_NOTSYNCED;
 		}
 
-		alloc_destroy(ah);
-		ah = NULL;
-	} else if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       lp->mirrors, lp->extents, NULL, 0u, 0u, pvh, lp->alloc))
-		return_0;
+		list_init(&tags);
+		if (tag)
+			str_list_add(cmd->mem, &tags, tag);
+
+		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
+				    adjusted_mirror_region_size(
+						vg->extent_size,
+						lv->le_count,
+						lp->region_size),
+				    lp->corelog ? 0U : 1U, pvh, lp->alloc,
+				    MIRROR_BY_LV)) {
+			stack;
+			goto revert_new_lv;
+		}
+	}
 
 	/* store vg on disk(s) */
 	if (!vg_write(vg))
@@ -901,8 +883,6 @@
 	return 1;
 
 error:
-	if (ah)
-		alloc_destroy(ah);
 	return 0;
 
 deactivate_and_revert_new_lv:
--- LVM2/tools/pvmove.c	2007/12/05 22:11:20	1.44
+++ LVM2/tools/pvmove.c	2007/12/20 15:42:55	1.45
@@ -106,6 +106,40 @@
 	return allocatable_pvs;
 }
 
+/*
+ * Replace any LV segments on given PV with temporary mirror.
+ * Returns list of LVs changed.
+ */
+static int _insert_pvmove_mirrors(struct cmd_context *cmd,
+				  struct logical_volume *lv_mirr,
+				  struct list *source_pvl,
+				  struct logical_volume *lv,
+				  struct list *lvs_changed)
+
+{
+	struct pv_list *pvl;
+	uint32_t prev_le_count;
+
+	/* Only 1 PV may feature in source_pvl */
+	pvl = list_item(source_pvl->n, struct pv_list);
+
+	prev_le_count = lv_mirr->le_count;
+	if (!insert_layer_for_segments_on_pv(cmd, lv, lv_mirr, PVMOVE,
+					     pvl, lvs_changed))
+		return_0;
+
+	/* check if layer was inserted */
+	if (lv_mirr->le_count - prev_le_count) {
+		lv->status |= LOCKED;
+
+		log_verbose("Moving %u extents of logical volume %s/%s",
+			    lv_mirr->le_count - prev_le_count,
+			    lv->vg->name, lv->name);
+	}
+
+	return 1;
+}
+
 /* Create new LV with mirror segments for the required copies */
 static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						struct volume_group *vg,
@@ -117,6 +151,7 @@
 {
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_list *lvl;
+	uint32_t log_count = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -161,14 +196,8 @@
 			log_print("Skipping locked LV %s", lv->name);
 			continue;
 		}
-		/* FIXME Just insert the layer below - no allocation */
-		// This knows nothing about pvmove
-		// insert_layer_for_segments_on_pv(cmd, lv, source_pvl, lv_mirr, *lvs_changed)
-		//   - for each lv segment using that pv
-		//     - call new fn insert_internal_layer()
-		if (!insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
-					   allocatable_pvs, alloc,
-					   *lvs_changed)) {
+		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
+					    *lvs_changed)) {
 			stack;
 			return NULL;
 		}
@@ -180,9 +209,16 @@
 		return NULL;
 	}
 
-	/* FIXME Do allocation and convert to mirror */
-	// again, this knows nothing about pvmove: it's a normal lvconvert lv_mirr to mirror with in-core log
-	// - a flag passed in requires that parent segs get split after the allocation (with failure if not possible)
+	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, log_count,
+			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
+		log_error("Failed to convert pvmove LV to mirrored");
+		return_NULL;
+	}
+
+	if (!split_parent_segments_for_layer(cmd, lv_mirr)) {
+		log_error("Failed to split segments being moved");
+		return_NULL;
+	}
 
 	return lv_mirr;
 }
@@ -381,13 +417,22 @@
 			  struct list *lvs_changed)
 {
 	int r = 1;
+	struct list lvs_completed;
+	struct lv_list *lvl;
 
 	/* Update metadata to remove mirror segments and break dependencies */
-	if (!remove_pvmove_mirrors(vg, lv_mirr)) {
+	list_init(&lvs_completed);
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
+	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
+					    &lvs_completed)) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
 
+	list_iterate_items(lvl, &lvs_completed)
+		/* FIXME Assumes only one pvmove at a time! */
+		lvl->lv->status &= ~LOCKED;
+
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_write(vg)) {
 		log_error("ABORTING: Failed to write new data locations "
@@ -488,6 +533,17 @@
 	char *pv_name = NULL;
 	char *colon;
 	int ret;
+	const struct segment_type *segtype;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+        if (activation() && segtype->ops->target_present &&
+            !segtype->ops->target_present(NULL)) {
+                log_error("%s: Required device-mapper target(s) not "
+                          "detected in your kernel", segtype->name);
+                return 0;
+        }
 
 	if (argc) {
 		pv_name = argv[0];
--- LVM2/tools/toollib.c	2007/11/16 21:16:20	1.118
+++ LVM2/tools/toollib.c	2007/12/20 15:42:55	1.119
@@ -1241,26 +1241,6 @@
 	return 1;
 }
 
-int generate_log_name_format(struct volume_group *vg __attribute((unused)),
-			     const char *lv_name, char *buffer, size_t size)
-{
-	if (dm_snprintf(buffer, size, "%s_mlog", lv_name) < 0) {
-		stack;
-		return 0;
-	}
-
-	/* FIXME I think we can cope without this.  Cf. _add_lv_to_dtree()
-	if (find_lv_in_vg(vg, buffer) &&
-	    dm_snprintf(buffer, size, "%s_mlog_%%d",
-			 lv_name) < 0) {
-		stack;
-		return 0;
-	}
-	*******/
-
-	return 1;
-}
-
 /*
  * Initialize the LV with 'value'.
  */
@@ -1307,149 +1287,3 @@
 	return 1;
 }
 
-/*
- * This function writes a new header to the mirror log header to the lv
- *
- * Returns: 1 on success, 0 on failure
- */
-static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	struct device *dev;
-	char *name;
-	struct { /* The mirror log header */
-		uint32_t magic;
-		uint32_t version;
-		uint64_t nr_regions;
-	} log_header;
-
-	log_header.magic = xlate32(MIRROR_MAGIC);
-	log_header.version = xlate32(MIRROR_DISK_VERSION);
-	log_header.nr_regions = xlate64((uint64_t)-1);
-
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - log header not written (%s)",
-			lv->name);
-		return 0;
-	}
-
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - log header not written (%s)", lv->name);
-		return 0;
-	}
-
-	log_verbose("Writing log header to device, %s", lv->name);
-
-	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: log header not written", name);
-		return 0;
-	}
-
-	if (!dev_open_quiet(dev))
-		return 0;
-
-	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		log_error("Failed to write log header to %s", name);
-		dev_close_immediate(dev);
-		return 0;
-	}
-
-	dev_close_immediate(dev);
-
-	return 1;
-}
-
-struct logical_volume *create_mirror_log(struct cmd_context *cmd,
-					 struct volume_group *vg,
-					 struct alloc_handle *ah,
-					 alloc_policy_t alloc,
-					 const char *lv_name,
-					 int in_sync,
-					 struct list *tags)
-{
-	struct logical_volume *log_lv;
-	char *log_name;
-	size_t len;
-	struct str_list *sl;
-
-	if (!activation() && in_sync) {
-		log_error("Aborting. Unable to create in-sync mirror log "
-			  "while activation is disabled.");
-		return NULL;
-	}
-
-	len = strlen(lv_name) + 32;
-	if (!(log_name = alloca(len)) ||
-	    !(generate_log_name_format(vg, lv_name, log_name, len))) {
-		log_error("log_name allocation failed.");
-		return NULL;
-	}
-
-	if (!(log_lv = lv_create_empty(log_name, NULL,
-				       VISIBLE_LV | LVM_READ | LVM_WRITE,
-				       alloc, 0, vg)))
-		return_NULL;
-
-	if (!lv_add_log_segment(ah, log_lv))
-		return_NULL;
-
-	/* Temporary tag mirror log */
-	list_iterate_items(sl, tags)
-		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
-			log_error("Aborting. Unable to tag mirror log.");
-			return NULL;
-		}
-
-	/* store mirror log on disk(s) */
-	if (!vg_write(vg))
-		return_NULL;
-
-	backup(vg);
-
-	if (!vg_commit(vg))
-		return_NULL;
-
-	if (!activate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to activate mirror log.");
-		goto revert_new_lv;
-	}
-
-	list_iterate_items(sl, tags)
-		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
-				  sl->str);
-
-	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
-				    in_sync ? -1 : 0)) {
-		log_error("Aborting. Failed to wipe mirror log.");
-		goto deactivate_and_revert_new_lv;
-	}
-
-	if (activation() && !_write_log_header(cmd, log_lv)) {
-		log_error("Aborting. Failed to write mirror log header.");
-		goto deactivate_and_revert_new_lv;
-	}
-
-	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to deactivate mirror log. "
-			  "Manual intervention required.");
-		return NULL;
-	}
-
-	log_lv->status &= ~VISIBLE_LV;
-
-	return log_lv;
-
-deactivate_and_revert_new_lv:
-	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Unable to deactivate mirror log LV. "
-			  "Manual intervention required.");
-		return NULL;
-	}
-
-revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned log LV before retrying.");
-	return NULL;
-}
--- LVM2/tools/toollib.h	2007/11/14 18:41:05	1.52
+++ LVM2/tools/toollib.h	2007/12/20 15:42:55	1.53
@@ -98,17 +98,6 @@
 
 int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 
-int generate_log_name_format(struct volume_group *vg, const char *lv_name,
-                             char *buffer, size_t size);
-
-struct logical_volume *create_mirror_log(struct cmd_context *cmd,
-					 struct volume_group *vg,
-					 struct alloc_handle *ah,
-					 alloc_policy_t alloc,
-					 const char *lv_name,
-					 int in_sync,
-					 struct list *tags);
-
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	   uint64_t sectors, int value);
 


