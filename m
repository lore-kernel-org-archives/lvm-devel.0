From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:01:01 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20080116190101.32648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:01:00

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 
	                 metadata-exported.h metadata.h mirror.c 
	lib/report     : report.c 
	tools          : vgreduce.c 

Log message:
	Maintain lists of stacked LV segments using each LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.763&r2=1.764
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2008/01/16 18:15:26	1.763
+++ LVM2/WHATS_NEW	2008/01/16 19:00:58	1.764
@@ -1,5 +1,7 @@
 Version 2.02.30 -
 ===================================
+  Maintain lists of stacked LV segments using each LV.
+  Change vgsplit -l (for unimplemented --list) into --maxlogicalvolumes.
   Fix process_all_pvs to detect non-orphans with no MDAs correctly.
   Don't use block_on_error with mirror targets version 1.12 and above.
   Update vgsplit to include vgcreate-style options when new VG is destination.
--- LVM2/lib/format1/import-export.c	2007/11/09 16:51:53	1.91
+++ LVM2/lib/format1/import-export.c	2008/01/16 19:00:59	1.92
@@ -361,6 +361,7 @@
 	list_init(&lv->snapshot_segs);
 	list_init(&lv->segments);
 	list_init(&lv->tags);
+	list_init(&lv->segs_using_this_lv);
 
 	return 1;
 }
--- LVM2/lib/format_pool/import_export.c	2007/11/09 16:51:53	1.18
+++ LVM2/lib/format_pool/import_export.c	2008/01/16 19:00:59	1.19
@@ -83,6 +83,7 @@
 	list_init(&lv->snapshot_segs);
 	list_init(&lv->segments);
 	list_init(&lv->tags);
+	list_init(&lv->segs_using_this_lv);
 
 	list_iterate_items(pl, pls) {
 		lv->size += pl->pd.pl_blocks;
--- LVM2/lib/format_text/import_vsn1.c	2008/01/10 18:35:50	1.46
+++ LVM2/lib/format_text/import_vsn1.c	2008/01/16 19:00:59	1.47
@@ -408,8 +408,10 @@
 				return 0;
 			}
 		} else if ((lv1 = find_lv(seg->lv->vg, cv->v.str))) {
-			set_lv_segment_area_lv(seg, s, lv1, (uint32_t) cv->next->v.i,
-					       flags);
+			if (!set_lv_segment_area_lv(seg, s, lv1,
+						    (uint32_t) cv->next->v.i,
+						    flags))
+				return_0;
 		} else {
 			log_error("Couldn't find volume '%s' "
 				  "for segment '%s'.",
@@ -562,6 +564,7 @@
 	list_init(&lv->snapshot_segs);
 	list_init(&lv->segments);
 	list_init(&lv->tags);
+	list_init(&lv->segs_using_this_lv);
 
 	/* Optional tags */
 	if ((cn = find_config_node(lvn, "tags")) &&
--- LVM2/lib/metadata/lv_alloc.h	2007/12/20 15:42:55	1.20
+++ LVM2/lib/metadata/lv_alloc.h	2008/01/16 19:00:59	1.21
@@ -33,9 +33,9 @@
 
 int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
 			   struct physical_volume *pv, uint32_t pe);
-void set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
-			    struct logical_volume *lv, uint32_t le,
-			    uint32_t flags);
+int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
+			   struct logical_volume *lv, uint32_t le,
+			   uint32_t flags);
 int move_lv_segment_area(struct lv_segment *seg_to, uint32_t area_to,
 			 struct lv_segment *seg_from, uint32_t area_from);
 void release_lv_segment_area(struct lv_segment *seg, uint32_t s,
--- LVM2/lib/metadata/lv_manip.c	2007/12/20 23:12:27	1.140
+++ LVM2/lib/metadata/lv_manip.c	2008/01/16 19:00:59	1.141
@@ -31,6 +31,69 @@
 	const char *new;
 };
 
+int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg)
+{
+	struct seg_list *sl;
+
+	list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (sl->seg == seg) {
+			sl->count++;
+			return 1;
+		}
+	}
+
+	if (!(sl = dm_pool_zalloc(lv->vg->cmd->mem, sizeof(*sl)))) {
+		log_error("Failed to allocate segment list");
+		return 0;
+	}
+
+	sl->count = 1;
+	sl->seg = seg;
+	list_add(&lv->segs_using_this_lv, &sl->list);
+
+	return 1;
+}
+
+int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg)
+{
+	struct seg_list *sl;
+
+	list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (sl->seg != seg)
+			continue;
+		if (sl->count > 1)
+			sl->count--;
+		else
+			list_del(&sl->list);
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * This is a function specialized for the common case where there is
+ * only one segment which uses the LV.
+ * e.g. the LV is a layer inserted by insert_layer_for_lv().
+ *
+ * In general, walk through lv->segs_using_this_lv.
+ */
+struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	if (list_size(&lv->segs_using_this_lv) != 1) {
+		log_error("%s is expected to have only one segment using it, "
+			  "while it has %d", lv->name,
+			  list_size(&lv->segs_using_this_lv));
+		return NULL;
+	}
+
+	sl = list_item(list_first(&lv->segs_using_this_lv), struct seg_list);
+
+	return sl->seg;
+}
+
 /*
  * PVs used by a segment of an LV
  */
@@ -127,12 +190,12 @@
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
 	seg->log_lv = log_lv;
-	seg->mirror_seg = NULL;
 	list_init(&seg->tags);
 
 	if (log_lv) {
 		log_lv->status |= MIRROR_LOG;
-		first_seg(log_lv)->mirror_seg = seg;
+		if (!add_seg_to_segs_using_this_lv(log_lv, seg))
+			return_NULL;
 	}
 
 	return seg;
@@ -183,6 +246,7 @@
 	}
 
 	if (area_reduction == seg->area_len) {
+		remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg);
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
 		seg_type(seg, s) = AREA_UNASSIGNED;
@@ -223,7 +287,8 @@
 					seg_from->area_len);
 		release_lv_segment_area(seg_to, area_to, seg_to->area_len);
 
-		set_lv_segment_area_lv(seg_to, area_to, lv, le, 0);
+		if (!set_lv_segment_area_lv(seg_to, area_to, lv, le, 0))
+			return_0;
 
 		break;
 
@@ -254,14 +319,19 @@
 /*
  * Link one LV segment to another.  Assumes sizes already match.
  */
-void set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
-			    struct logical_volume *lv, uint32_t le,
-			    uint32_t flags)
+int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
+			   struct logical_volume *lv, uint32_t le,
+			   uint32_t flags)
 {
 	seg->areas[area_num].type = AREA_LV;
 	seg_lv(seg, area_num) = lv;
 	seg_le(seg, area_num) = le;
 	lv->status |= flags;
+
+	if (!add_seg_to_segs_using_this_lv(lv, seg))
+		return_0;
+
+	return 1;
 }
 
 /*
@@ -1399,14 +1469,13 @@
 		return 0;
 	}
 
-	for (m = 0; m < old_area_count; m++) {
+	for (m = 0; m < old_area_count; m++)
 		seg_lv(seg, m)->status |= status;
-		first_seg(seg_lv(seg, m))->mirror_seg = seg;
-	}
 
 	for (m = old_area_count; m < new_area_count; m++) {
-		set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count], 0, status);
-		first_seg(sub_lvs[m - old_area_count])->mirror_seg = seg;
+		if (!set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count],
+					    0, status))
+			return_0;
 		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
 	}
 
@@ -1780,6 +1849,7 @@
 	list_init(&lv->snapshot_segs);
 	list_init(&lv->segments);
 	list_init(&lv->tags);
+	list_init(&lv->segs_using_this_lv);
 
 	if (lvid)
 		lv->lvid = *lvid;
@@ -2212,53 +2282,29 @@
 	return 1;
 }
 
-/*
- * Find a parent LV for the layer_lv in the lv
- */
-struct logical_volume *find_parent_for_layer(struct logical_volume *lv,
-                                            struct logical_volume *layer_lv)
-{
-	struct logical_volume *parent;
-	struct lv_segment *seg;
-	uint32_t s;
-
-	list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_LV)
-				continue;
-			if (seg_lv(seg, s) == layer_lv)
-				return lv;
-			parent = find_parent_for_layer(seg_lv(seg, s),
-						       layer_lv);
-			if (parent)
-				return parent;
-		}
-	}
-	return NULL;
-}
-
 /* Remove a layer from the LV */
 int remove_layer_from_lv(struct logical_volume *lv,
 			 struct logical_volume *layer_lv)
 {
 	struct logical_volume *parent;
+	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
 
-	parent = find_parent_for_layer(lv, layer_lv);
-	if (!parent) {
+	if (!(parent_seg = get_only_segment_using_this_lv(layer_lv))) {
 		log_error("Failed to find layer %s in %s",
 		layer_lv->name, lv->name);
 		return 0;
 	}
+	parent = parent_seg->lv;
 
 	/*
 	 * Before removal, the layer should be cleaned up,
 	 * i.e. additional segments and areas should have been removed.
 	 */
 	if (list_size(&parent->segments) != 1 ||
-	    first_seg(parent)->area_count != 1 ||
-	    seg_type(first_seg(parent), 0) != AREA_LV ||
-	    layer_lv != seg_lv(first_seg(parent), 0) ||
+	    parent_seg->area_count != 1 ||
+	    seg_type(parent_seg, 0) != AREA_LV ||
+	    layer_lv != seg_lv(parent_seg, 0) ||
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
@@ -2328,7 +2374,8 @@
 		return_NULL;
 
 	/* map the new segment to the original underlying are */
-	set_lv_segment_area_lv(mapseg, 0, layer_lv, 0, 0);
+	if (!set_lv_segment_area_lv(mapseg, 0, layer_lv, 0, 0))
+		return_NULL;
 
 	/* add the new segment to the layer LV */
 	list_add(&lv_where->segments, &mapseg->list);
@@ -2379,7 +2426,8 @@
 	layer_lv->size += seg->area_len * layer_lv->vg->extent_size;
 
 	/* map the original area to the new segment */
-	set_lv_segment_area_lv(seg, s, layer_lv, mapseg->le, 0);
+	if (!set_lv_segment_area_lv(seg, s, layer_lv, mapseg->le, 0))
+		return_0;
 
 	return 1;
 }
--- LVM2/lib/metadata/merge.c	2007/11/07 16:33:11	1.30
+++ LVM2/lib/metadata/merge.c	2008/01/16 19:00:59	1.31
@@ -62,9 +62,10 @@
 {
 	struct lv_segment *seg, *seg2;
 	uint32_t le = 0;
-	unsigned seg_count = 0;
+	unsigned seg_count = 0, seg_found;
 	int r = 1;
 	uint32_t area_multiplier, s;
+	struct seg_list *sl;
 
 	list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -101,7 +102,7 @@
 			}
 
 			if (!(seg2 = first_seg(seg->log_lv)) ||
-			    seg2->mirror_seg != seg) {
+			    find_mirror_seg(seg2) != seg) {
 				log_error("LV %s: segment %u log LV does not "
 					  "point back to mirror segment",
 					   lv->name, seg_count);
@@ -110,8 +111,8 @@
 		}
 
 		if (complete_vg && seg->status & MIRROR_IMAGE) {
-			if (!seg->mirror_seg ||
-			    !seg_is_mirrored(seg->mirror_seg)) {
+			if (!find_mirror_seg(seg) ||
+			    !seg_is_mirrored(find_mirror_seg(seg))) {
 				log_error("LV %s: segment %u mirror image "
 					  "is not mirrored",
 					  lv->name, seg_count);
@@ -157,7 +158,7 @@
 				    (seg_lv(seg, s)->status & MIRROR_IMAGE) &&
 				    (!(seg2 = find_seg_by_le(seg_lv(seg, s),
 							    seg_le(seg, s))) ||
-				     seg2->mirror_seg != seg)) {
+				     find_mirror_seg(seg2) != seg)) {
 					log_error("LV %s: segment %u mirror "
 						  "image %u missing mirror ptr",
 						  lv->name, seg_count, s);
@@ -173,12 +174,57 @@
 					r = 0;
 				}
  */
+				seg_found = 0;
+				list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv)
+					if (sl->seg == seg)
+						seg_found++;
+				if (!seg_found) {
+					log_error("LV %s segment %d uses LV %s,"
+						  " but missing ptr from %s to %s",
+						  lv->name, seg_count,
+						  seg_lv(seg, s)->name,
+						  seg_lv(seg, s)->name, lv->name);
+					r = 0;
+				} else if (seg_found > 1) {
+					log_error("LV %s has duplicated links "
+						  "to LV %s segment %d",
+						  seg_lv(seg, s)->name,
+						  lv->name, seg_count);
+					r = 0;
+				}
 			}
 		}
 
 		le += seg->len;
 	}
 
+	list_iterate_items(sl, &lv->segs_using_this_lv) {
+		seg = sl->seg;
+		seg_found = 0;
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			if (lv == seg_lv(seg, s))
+				seg_found++;
+		}
+		if (seg->log_lv == lv)
+			seg_found++;
+		if (!seg_found) {
+			log_error("LV %s is used by LV %s:%" PRIu32 ", "
+				  "but missing ptr from %s to %s",
+				  lv->name, seg->lv->name, seg->le,
+				  seg->lv->name, lv->name);
+			r = 0;
+		} else if (seg_found != sl->count) {
+			log_error("Reference count mismatch: LV %s has %d "
+				  "links to LV %s:%" PRIu32
+				  ", which has %d links",
+				  lv->name, sl->count,
+				  seg->lv->name, seg->le, seg_found);
+			r = 0;
+		}
+	}
+
 	if (le != lv->le_count) {
 		log_error("LV %s: inconsistent LE count %u != %u",
 			  lv->name, le, lv->le_count);
@@ -243,9 +289,9 @@
 		/* Split area at the offset */
 		switch (seg_type(seg, s)) {
 		case AREA_LV:
-			seg_lv(split_seg, s) = seg_lv(seg, s);
-			seg_le(split_seg, s) =
-			    seg_le(seg, s) + seg->area_len;
+			if (!set_lv_segment_area_lv(split_seg, s, seg_lv(seg, s),
+						    seg_le(seg, s) + seg->area_len, 0))
+				return_0;
 			log_debug("Split %s:%u[%u] at %u: %s LE %u", lv->name,
 				  seg->le, s, le, seg_lv(seg, s)->name,
 				  seg_le(split_seg, s));
--- LVM2/lib/metadata/metadata-exported.h	2008/01/16 18:15:26	1.34
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:00:59	1.35
@@ -242,7 +242,6 @@
 	uint32_t region_size;	/* For mirrors - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
-	struct lv_segment *mirror_seg;
 
 	struct list tags;
 
@@ -274,6 +273,7 @@
 
 	struct list segments;
 	struct list tags;
+	struct list segs_using_this_lv;
 };
 
 struct pe_range {
@@ -412,8 +412,6 @@
 				   struct list *lvs_changed);
 int split_parent_segments_for_layer(struct cmd_context *cmd,
 				    struct logical_volume *layer_lv);
-struct logical_volume *find_parent_for_layer(struct logical_volume *lv,
-					     struct logical_volume *layer_lv);
 int remove_layer_from_lv(struct logical_volume *lv,
 			 struct logical_volume *layer_lv);
 struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
@@ -464,6 +462,7 @@
 /*
 * Mirroring functions
 */
+struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
--- LVM2/lib/metadata/metadata.h	2007/12/20 18:55:46	1.176
+++ LVM2/lib/metadata/metadata.h	2008/01/16 19:00:59	1.177
@@ -158,6 +158,12 @@
 	struct pv_segment *peg;
 };
 
+struct seg_list {
+	struct list list;
+	unsigned count;
+	struct lv_segment *seg;
+};
+
 /*
  * Ownership of objects passes to caller.
  */
@@ -293,13 +299,20 @@
 int lv_split_segment(struct logical_volume *lv, uint32_t le);
 
 /*
+ * Add/remove upward link from underlying LV to the segment using it
+ * FIXME: ridiculously long name
+ */
+int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
+int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
+struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
+
+/*
  * Mirroring functions
  */
 
 /*
  * Given mirror image or mirror log segment, find corresponding mirror segment 
  */
-struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int fixup_imported_mirrors(struct volume_group *vg);
 
 /*
--- LVM2/lib/metadata/mirror.c	2008/01/10 18:35:50	1.52
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:00:59	1.53
@@ -76,7 +76,22 @@
 
 struct lv_segment *find_mirror_seg(struct lv_segment *seg)
 {
-	return seg->mirror_seg;
+	struct lv_segment *mirror_seg;
+
+	mirror_seg = get_only_segment_using_this_lv(seg->lv);
+
+	if (!mirror_seg) {
+		log_error("Failed to find mirror_seg for %s", seg->lv->name);
+		return NULL;
+	}
+
+	if (!seg_is_mirrored(mirror_seg)) {
+		log_error("%s on %s is not a mirror segments",
+			  mirror_seg->lv->name, seg->lv->name);
+		return NULL;
+	}
+
+	return mirror_seg;
 }
 
 /*
@@ -155,6 +170,20 @@
 				 MIRROR_IMAGE, first_seg(lv)->region_size);
 }
 
+/* Unlink the relationship between the segment and its log_lv */
+static void _remove_mirror_log(struct lv_segment *mirrored_seg)
+{
+	struct logical_volume *log_lv;
+
+	if (!mirrored_seg->log_lv)
+		return;
+
+	log_lv = mirrored_seg->log_lv;
+	mirrored_seg->log_lv = NULL;
+	log_lv->status &= ~MIRROR_LOG;
+	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
+}
+
 /*
  * Remove num_removed images from mirrored_seg
  */
@@ -244,6 +273,7 @@
 		}
 		lvl->lv = seg_lv(mirrored_seg, m);
 		list_add(&tmp_orphan_lvs, &lvl->list);
+		release_lv_segment_area(mirrored_seg, m, mirrored_seg->area_len);
 	}
 	mirrored_seg->area_count = new_area_count;
 
@@ -254,7 +284,7 @@
 	/* If no more mirrors, remove mirror layer */
 	if (new_area_count == 1) {
 		lv1 = seg_lv(mirrored_seg, 0);
-		mirrored_seg->log_lv = NULL;
+		_remove_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
 		lv->status &= ~MIRRORED;
@@ -265,12 +295,10 @@
 			return 0;
 		}
 	} else if (remove_log)
-		mirrored_seg->log_lv = NULL;
+		_remove_mirror_log(mirrored_seg);
 
-	if (remove_log && log_lv) {
-		log_lv->status &= ~MIRROR_LOG;
+	if (remove_log && log_lv)
 		log_lv->status |= VISIBLE_LV;
-	}
 
 	/*
 	 * To successfully remove these unwanted LVs we need to
@@ -395,18 +423,25 @@
  */
 int collapse_mirrored_lv(struct logical_volume *lv)
 {
-	struct logical_volume *tmp_lv, *parent_lv;
+	struct logical_volume *tmp_lv;
+	struct lv_segment *mirror_seg;
 
 	while ((tmp_lv = _find_tmp_mirror(lv))) {
-		parent_lv = find_parent_for_layer(lv, tmp_lv);
-		if (!_mirrored_lv_in_sync(parent_lv)) {
+		mirror_seg = find_mirror_seg(first_seg(tmp_lv));
+		if (!mirror_seg) {
+			log_error("Failed to find mirrored LV for %s",
+				  tmp_lv->name);
+			return 0;
+		}
+
+		if (!_mirrored_lv_in_sync(mirror_seg->lv)) {
 			log_verbose("Not collapsing %s: out-of-sync",
-				    parent_lv->name);
+				    mirror_seg->lv->name);
 			return 1;
 		}
 
-		if (!_remove_mirror_images(parent_lv,
-					   first_seg(parent_lv)->area_count - 1,
+		if (!_remove_mirror_images(mirror_seg->lv,
+					   mirror_seg->area_count - 1,
 					   NULL, 1, 1)) {
 			log_error("Failed to release mirror images");
 			return 0;
@@ -801,7 +836,6 @@
 {
 	struct lv_list *lvl;
 	struct lv_segment *seg;
-	uint32_t s;
 
 	list_iterate_items(lvl, &vg->lvs) {
 		list_iterate_items(seg, &lvl->lv->segments) {
@@ -809,12 +843,8 @@
 			    get_segtype_from_string(vg->cmd, "mirror"))
 				continue;
 
-			if (seg->log_lv)
-				first_seg(seg->log_lv)->mirror_seg = seg;
-			for (s = 0; s < seg->area_count; s++)
-				if (seg_type(seg, s) == AREA_LV)
-					first_seg(seg_lv(seg, s))->mirror_seg
-					    = seg;
+			if (seg->log_lv && !add_seg_to_segs_using_this_lv(seg->log_lv, seg))
+				return_0;
 		}
 	}
 
@@ -1103,7 +1133,7 @@
 {
 	first_seg(lv)->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	first_seg(log_lv)->mirror_seg = first_seg(lv);
+	add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
 }
 
 int add_mirror_log(struct cmd_context *cmd,
--- LVM2/lib/report/report.c	2008/01/10 18:35:51	1.71
+++ LVM2/lib/report/report.c	2008/01/16 19:00:59	1.72
@@ -275,13 +275,12 @@
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	float percent;
-	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
 
-	if (!(lv->status & MIRROR_IMAGE) || !seg->mirror_seg)
+	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
 		return_0;
 
-	if (!lv_mirror_percent(lv->vg->cmd, seg->mirror_seg->lv, 0,
-			       &percent, NULL))
+	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent, NULL))
 		return_0;
 
 	if (percent >= 100.0)
--- LVM2/tools/vgreduce.c	2007/11/19 18:24:08	1.72
+++ LVM2/tools/vgreduce.c	2008/01/16 19:00:59	1.73
@@ -50,7 +50,7 @@
 static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
 		      int *list_unsafe, struct list *lvs_changed)
 {
-	struct lv_segment *snap_seg, *mirror_seg;
+	struct lv_segment *snap_seg;
 	struct list *snh, *snht;
 	struct logical_volume *cow;
 	struct lv_list *lvl;
@@ -117,9 +117,8 @@
 	 * Clean-up is currently done by caller (_make_vg_consistent()).
 	 */
 	if ((lv_info(cmd, lv, &info, 0, 0) && info.exists)
-	    || first_seg(lv)->mirror_seg) {
+	    || find_mirror_seg(first_seg(lv))) {
 		extents = lv->le_count;
-		mirror_seg = first_seg(lv)->mirror_seg;
 		if (!lv_empty(lv)) {
 			stack;
 			return 0;
@@ -130,10 +129,6 @@
 			stack;
 			return 0;
 		}
-		if (mirror_seg) {
-			first_seg(lv)->status |= MIRROR_IMAGE;
-			first_seg(lv)->mirror_seg = mirror_seg;
-		}
 
 		if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");


