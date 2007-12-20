From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2007 18:55:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20071220185547.9279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-20 18:55:46

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 metadata.h mirror.c 
	tools          : lvconvert.c lvresize.c toollib.c 

Log message:
	stacked mirror support (incomplete)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.747&r2=1.748
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/WHATS_NEW	2007/12/20 15:42:55	1.747
+++ LVM2/WHATS_NEW	2007/12/20 18:55:46	1.748
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Add support for stacked mirrors.
   Major restructuring of pvmove and lvconvert layer manipulation code.
   Replace tools/fsadm with scripts/fsadm.sh.
   Append fields to report/pvsegs_cols_verbose.
--- LVM2/lib/metadata/lv_manip.c	2007/12/20 15:42:55	1.137
+++ LVM2/lib/metadata/lv_manip.c	2007/12/20 18:55:46	1.138
@@ -1407,6 +1407,7 @@
 	for (m = old_area_count; m < new_area_count; m++) {
 		set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count], 0, status);
 		first_seg(sub_lvs[m - old_area_count])->mirror_seg = seg;
+		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
 	}
 
 	return 1;
@@ -1451,6 +1452,39 @@
 	return 1;
 }
 
+static int _lv_extend_mirror(struct alloc_handle *ah,
+			     struct logical_volume *lv,
+			     uint32_t extents, uint32_t first_area)
+{
+	struct lv_segment *seg;
+	uint32_t m, s;
+
+	seg = first_seg(lv);
+	for (m = first_area, s = 0; s < seg->area_count; s++) {
+		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
+			if (!_lv_extend_mirror(ah, seg_lv(seg, s), extents, m))
+				return_0;
+			m += lv_mirror_count(seg_lv(seg, s));
+			continue;
+		}
+
+		if (!lv_add_segment(ah, m++, 1, seg_lv(seg, s),
+				    get_segtype_from_string(lv->vg->cmd,
+							    "striped"),
+				    0, 0, 0, NULL)) {
+			log_error("Aborting. Failed to extend %s.",
+				  seg_lv(seg, s)->name);
+			return 0;
+		}
+	}
+	seg->area_len += extents;
+	seg->len += extents;
+	lv->le_count += extents;
+	lv->size += (uint64_t) extents *lv->vg->extent_size;
+
+	return 1;
+}
+
 /*
  * Entry point for single-step LV allocation + extension.
  */
@@ -1464,9 +1498,7 @@
 	      alloc_policy_t alloc)
 {
 	int r = 1;
-	uint32_t m;
 	struct alloc_handle *ah;
-	struct lv_segment *seg;
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, status, extents, segtype);
@@ -1482,21 +1514,8 @@
 			goto out;
 		}
 	} else {
-		seg = first_seg(lv);
-		for (m = 0; m < mirrors; m++) {
-			if (!lv_add_segment(ah, m, 1, seg_lv(seg, m),
-					    get_segtype_from_string(lv->vg->cmd,
-								    "striped"),
-					    0, 0, 0, NULL)) {
-				log_error("Aborting. Failed to extend %s.",
-					  seg_lv(seg, m)->name);
-				return 0;
-			}
-		}
-		seg->area_len += extents;
-		seg->len += extents;
-		lv->le_count += extents;
-		lv->size += (uint64_t) extents *lv->vg->extent_size;
+		if (!_lv_extend_mirror(ah, lv, extents, 0))
+			return_0;
 	}
 
       out:
@@ -1599,10 +1618,14 @@
 	list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !func(cmd, seg->log_lv, data))
 			return 0;
-		for (s = 0; s < seg->area_count; s++)
-			if (seg_type(seg, s) == AREA_LV &&
-			    !func(cmd, seg_lv(seg, s), data))
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			if (!func(cmd, seg_lv(seg, s), data))
 				return 0;
+			if (!_for_each_sub_lv(cmd, seg_lv(seg, s), func, data))
+				return 0;
+		}
 	}
 
 	return 1;
@@ -2180,23 +2203,62 @@
 	lv_from->size = 0;
 }
 
+/*
+ * Find a parent LV for the layer_lv in the lv
+ */
+struct logical_volume *find_parent_for_layer(struct logical_volume *lv,
+                                            struct logical_volume *layer_lv)
+{
+	struct logical_volume *parent;
+	struct lv_segment *seg;
+	uint32_t s;
+
+	list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			if (seg_lv(seg, s) == layer_lv)
+				return lv;
+			parent = find_parent_for_layer(seg_lv(seg, s),
+						       layer_lv);
+			if (parent)
+				return parent;
+		}
+	}
+	return NULL;
+}
+
 /* Remove a layer from the LV */
-/* FIXME: how to specify what should be removed if multiple layers stacked? */
-int remove_layer_from_lv(struct logical_volume *lv)
+int remove_layer_from_lv(struct logical_volume *lv,
+			 struct logical_volume *layer_lv)
 {
-	struct logical_volume *orig_lv;
+	struct logical_volume *parent;
+	struct segment_type *segtype;
+
+	parent = find_parent_for_layer(lv, layer_lv);
+	if (!parent) {
+		log_error("Failed to find layer %s in %s",
+		layer_lv->name, lv->name);
+		return 0;
+	}
 
 	/*
 	 * Before removal, the layer should be cleaned up,
 	 * i.e. additional segments and areas should have been removed.
 	 */
-	if (list_size(&lv->segments) != 1 ||
-	    first_seg(lv)->area_count != 1 ||
-	    seg_type(first_seg(lv), 0) != AREA_LV)
-		return 0;
+	if (list_size(&parent->segments) != 1 ||
+	    first_seg(parent)->area_count != 1 ||
+	    seg_type(first_seg(parent), 0) != AREA_LV ||
+	    layer_lv != seg_lv(first_seg(parent), 0) ||
+	    parent->le_count != layer_lv->le_count)
+		return_0;
 
-	orig_lv = seg_lv(first_seg(lv), 0);
-	_move_lv_segments(lv, orig_lv, 0, 0);
+	_move_lv_segments(parent, layer_lv, 0, 0);
+
+	/* Replace the empty layer with error segment */
+	segtype = get_segtype_from_string(lv->vg->cmd, "error");
+	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype))
+		return_0;
 
 	return 1;
 }
--- LVM2/lib/metadata/metadata-exported.h	2007/12/20 15:42:55	1.26
+++ LVM2/lib/metadata/metadata-exported.h	2007/12/20 18:55:46	1.27
@@ -398,7 +398,10 @@
 				   struct list *lvs_changed);
 int split_parent_segments_for_layer(struct cmd_context *cmd,
 				    struct logical_volume *layer_lv);
-int remove_layer_from_lv(struct logical_volume *lv);
+struct logical_volume *find_parent_for_layer(struct logical_volume *lv,
+					     struct logical_volume *layer_lv);
+int remove_layer_from_lv(struct logical_volume *lv,
+			 struct logical_volume *layer_lv);
 struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   struct logical_volume *lv_where,
 					   uint32_t status,
@@ -417,7 +420,7 @@
 					const char *pv_name);
 
 /* Find LV segment containing given LE */
-struct lv_segment *first_seg(struct logical_volume *lv);
+struct lv_segment *first_seg(const struct logical_volume *lv);
 
 
 /*
@@ -458,8 +461,8 @@
 #define MIRROR_BY_SEG	0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV	0x00000002U	/* mirror by mimage LVs */
 
-uint32_t lv_mirror_count(struct logical_volume *lv);
-struct alloc_handle;
+int is_temporary_mirror_layer(const struct logical_volume *lv);
+uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
 int remove_mirrors_from_segments(struct logical_volume *lv,
@@ -468,7 +471,7 @@
 			    uint32_t mirrors, uint32_t region_size,
 			    struct list *allocatable_pvs, alloc_policy_t alloc);
 
-int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
+int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
 			 struct list *removable_pvs, unsigned remove_log);
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
@@ -482,6 +485,7 @@
 
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			      struct list *removable_pvs, unsigned remove_log);
+int collapse_mirrored_lv(struct logical_volume *lv);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
--- LVM2/lib/metadata/metadata.c	2007/11/15 02:20:03	1.144
+++ LVM2/lib/metadata/metadata.c	2007/12/20 18:55:46	1.145
@@ -937,7 +937,7 @@
 }
 
 /* Find segment at a given logical extent in an LV */
-struct lv_segment *find_seg_by_le(struct logical_volume *lv, uint32_t le)
+struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le)
 {
 	struct lv_segment *seg;
 
@@ -948,7 +948,7 @@
 	return NULL;
 }
 
-struct lv_segment *first_seg(struct logical_volume *lv)
+struct lv_segment *first_seg(const struct logical_volume *lv)
 {
 	struct lv_segment *seg = NULL;
 
@@ -959,7 +959,7 @@
 }
 
 /* Find segment at a given physical extent in a PV */
-struct pv_segment *find_peg_by_pe(struct physical_volume *pv, uint32_t pe)
+struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe)
 {
 	struct pv_segment *peg;
 
--- LVM2/lib/metadata/metadata.h	2007/12/20 15:42:55	1.175
+++ LVM2/lib/metadata/metadata.h	2007/12/20 18:55:46	1.176
@@ -264,10 +264,10 @@
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);
 
 /* Find LV segment containing given LE */
-struct lv_segment *find_seg_by_le(struct logical_volume *lv, uint32_t le);
+struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 
 /* Find PV segment containing given LE */
-struct pv_segment *find_peg_by_pe(struct physical_volume *pv, uint32_t pe);
+struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe);
 
 /*
  * Remove a dev_dir if present.
--- LVM2/lib/metadata/mirror.c	2007/12/20 15:42:55	1.46
+++ LVM2/lib/metadata/mirror.c	2007/12/20 18:55:46	1.47
@@ -33,11 +33,40 @@
 #define MIRROR_ALLOCATE_ANYWHERE 2
 
 /*
+ * Returns true if the lv is temporary mirror layer for resync
+ */
+int is_temporary_mirror_layer(const struct logical_volume *lv)
+{
+	if (lv->status & MIRROR_IMAGE
+	    && lv->status & MIRRORED
+	    && !(lv->status & LOCKED))
+		return 1;
+
+	return 0;
+}
+
+/*
  * Returns the number of mirrors of the LV
  */
-uint32_t lv_mirror_count(struct logical_volume *lv)
+uint32_t lv_mirror_count(const struct logical_volume *lv)
 {
-	return (lv->status & MIRRORED) ? first_seg(lv)->area_count : 1;
+	struct lv_segment *seg;
+	uint32_t s, mirrors;
+
+	if (!(lv->status & MIRRORED))
+		return 1;
+
+	seg = first_seg(lv);
+	mirrors = seg->area_count;
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) != AREA_LV)
+			continue;
+		if (is_temporary_mirror_layer(seg_lv(seg, s)))
+			mirrors += lv_mirror_count(seg_lv(seg, s)) - 1;
+	}
+
+	return mirrors;
 }
 
 struct lv_segment *find_mirror_seg(struct lv_segment *seg)
@@ -68,21 +97,21 @@
 /*
  * Delete independent/orphan LV, it must acquire lock.
  */
-static int _delete_lv(struct lv_segment *mirrored_seg, struct logical_volume *lv)
+static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv)
 {
-	struct cmd_context *cmd = mirrored_seg->lv->vg->cmd;
+	struct cmd_context *cmd = mirror_lv->vg->cmd;
 	struct str_list *sl;
 
 	/* Inherit tags - maybe needed for activation */
-	if (!str_list_match_list(&mirrored_seg->lv->tags, &lv->tags)) {
-		list_iterate_items(sl, &mirrored_seg->lv->tags)
+	if (!str_list_match_list(&mirror_lv->tags, &lv->tags)) {
+		list_iterate_items(sl, &mirror_lv->tags)
 			if (!str_list_add(cmd->mem, &lv->tags, sl->str)) {
 				log_error("Aborting. Unable to tag.");
 				return 0;
 			}
 
-		if (!vg_write(mirrored_seg->lv->vg) ||
-		    !vg_commit(mirrored_seg->lv->vg)) {
+		if (!vg_write(mirror_lv->vg) ||
+		    !vg_commit(mirror_lv->vg)) {
 			log_error("Intermediate VG commit for orphan volume failed.");
 			return 0;
 		}
@@ -101,29 +130,31 @@
 }
 
 /*
- * Reduce mirrored_seg to num_mirrors images.
+ * Remove num_removed images from mirrored_seg
  */
-int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			 struct list *removable_pvs, unsigned remove_log)
+static int _remove_mirror_images(struct logical_volume *lv,
+				 uint32_t num_removed,
+				 struct list *removable_pvs,
+				 unsigned remove_log, struct list *orphan_lvs)
 {
 	uint32_t m;
-	uint32_t extents;
 	uint32_t s, s1;
 	struct logical_volume *sub_lv;
 	struct logical_volume *log_lv = NULL;
 	struct logical_volume *lv1 = NULL;
 	struct physical_volume *pv;
-	struct lv_segment *seg;
+	struct lv_segment *seg, *mirrored_seg = first_seg(lv);
 	struct lv_segment_area area;
 	int all_pvs_removable, pv_found;
 	struct pv_list *pvl;
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
-	struct segment_type *segtype;
+	struct lv_list *lvl;
+	struct list tmp_orphan_lvs;
 
 	log_very_verbose("Reducing mirror set from %" PRIu32 " to %"
 			 PRIu32 " image(s)%s.",
-			 old_area_count, num_mirrors,
+			 old_area_count, old_area_count - num_removed,
 			 remove_log ? " and no log volume" : "");
 
 	/* Move removable_pvs to end of array */
@@ -162,39 +193,46 @@
 				mirrored_seg->areas[s] = area;
 			}
 			/* Found enough matches? */
-			if (new_area_count == num_mirrors)
+			if (old_area_count - new_area_count == num_removed)
 				break;
 		}
-		if (new_area_count == mirrored_seg->area_count) {
+		if (old_area_count == new_area_count) {
 			log_error("No mirror images found using specified PVs.");
 			return 0;
 		}
-	}
+	} else
+		new_area_count = old_area_count - num_removed;
 
-	for (m = num_mirrors; m < mirrored_seg->area_count; m++) {
+	/* Remove mimage LVs from the segment */
+	list_init(&tmp_orphan_lvs);
+	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		seg_lv(mirrored_seg, m)->status |= VISIBLE_LV;
+		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
+			log_error("lv_list alloc failed");
+			return 0;
+		}
+		lvl->lv = seg_lv(mirrored_seg, m);
+		list_add(&tmp_orphan_lvs, &lvl->list);
 	}
+	mirrored_seg->area_count = new_area_count;
 
-	mirrored_seg->area_count = num_mirrors;
+	/* Save log_lv as mirrored_seg may not be available after
+	 * remove_layer_from_lv(), */
+	log_lv = mirrored_seg->log_lv;
 
 	/* If no more mirrors, remove mirror layer */
-	if (num_mirrors == 1) {
+	if (new_area_count == 1) {
 		lv1 = seg_lv(mirrored_seg, 0);
-		extents = lv1->le_count;
-		remove_layer_from_lv(mirrored_seg->lv);
-		mirrored_seg->lv->status &= ~MIRRORED;
-		mirrored_seg->lv->status &= ~MIRROR_NOTSYNCED;
-		remove_log = 1;
-		/* Replace mirror with error segment */
-		segtype = get_segtype_from_string(mirrored_seg->lv->vg->cmd, "error");
-		if (!lv_add_virtual_segment(lv1, 0, extents, segtype))
+		mirrored_seg->log_lv = NULL;
+		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
+		lv->status &= ~MIRRORED;
+		lv->status &= ~MIRROR_NOTSYNCED;
+		remove_log = 1;
 	}
 
-	if (remove_log && mirrored_seg->log_lv) {
-		log_lv = mirrored_seg->log_lv;
-		mirrored_seg->log_lv = NULL;
+	if (remove_log && log_lv) {
 		log_lv->status &= ~MIRROR_LOG;
 		log_lv->status |= VISIBLE_LV;
 	}
@@ -228,16 +266,148 @@
 		return 0;
 	}
 
-	/* Delete the 'orphan' LVs */
-	for (m = num_mirrors; m < old_area_count; m++)
-		if (!_delete_lv(mirrored_seg, seg_lv(mirrored_seg, m)))
-			return 0;
+	/* Save or delete the 'orphan' LVs */
+	if (orphan_lvs) {
+		*orphan_lvs = tmp_orphan_lvs;
+		orphan_lvs->n->p = orphan_lvs;
+		orphan_lvs->p->n = orphan_lvs;
+	} else {
+		list_iterate_items(lvl, &tmp_orphan_lvs)
+			if (!_delete_lv(lv, lvl->lv))
+				return 0;
+	}
 
-	if (lv1 && !_delete_lv(mirrored_seg, lv1))
+	if (lv1 && !_delete_lv(lv, lv1))
 		return 0;
 
-	if (log_lv && !_delete_lv(mirrored_seg, log_lv))
+	if (remove_log && log_lv && !_delete_lv(lv, log_lv))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Remove the number of mirror images from the LV
+ */
+int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
+			 struct list *removable_pvs, unsigned remove_log)
+{
+	uint32_t num_removed, removed_once;
+	uint32_t existing_mirrors = lv_mirror_count(lv);
+
+	num_removed = existing_mirrors - num_mirrors;
+
+	while (num_removed) {
+		if (num_removed < first_seg(lv)->area_count)
+			removed_once = num_removed;
+		else
+			removed_once = first_seg(lv)->area_count - 1;
+
+		if (!_remove_mirror_images(lv, removed_once,
+				           removable_pvs, remove_log, NULL))
+			return_0;
+
+		num_removed -= removed_once;
+	}
+
+	return 1;
+}
+
+static int _mirrored_lv_in_sync(struct logical_volume *lv)
+{
+	float sync_percent;
+
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL)) {
+		log_error("Unable to determine mirror sync status of %s/%s.",
+			  lv->vg->name, lv->name);
 		return 0;
+	}
+
+	if (sync_percent >= 100.0)
+		return 1;
+
+	return 0;
+}
+
+static int _merge_mirror_images(struct logical_volume *lv,
+				const struct list *mimages)
+{
+	int addition = list_size(mimages);
+	struct logical_volume **img_lvs;
+	struct lv_list *lvl;
+	int i = 0;
+
+	if (!addition)
+		return 1;
+
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * addition)))
+		return_0;
+
+	list_iterate_items(lvl, mimages)
+		img_lvs[i++] = lvl->lv;
+
+	return lv_add_mirror_lvs(lv, img_lvs, addition,
+				 MIRROR_IMAGE, first_seg(lv)->region_size);
+}
+
+/*
+ * Return a temporary LV for resyncing added mirror image.
+ * Add other mirror legs to lvs list.
+ */
+static struct logical_volume *_find_tmp_mirror(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (!(lv->status & MIRRORED))
+		return NULL;
+
+	seg = first_seg(lv);
+
+	/* Temporary mirror is always area_num == 0 */
+	if (seg_type(seg, 0) == AREA_LV &&
+	    is_temporary_mirror_layer(seg_lv(seg, 0)))
+		return seg_lv(seg, 0);
+
+	return NULL;
+}
+
+/*
+ * Collapsing temporary mirror layers.
+ *
+ * When mirrors are added to already-mirrored LV, a temporary mirror layer
+ * is inserted at the top of the stack to reduce resync work.
+ * The function will remove the intermediate layer and collapse the stack
+ * as far as mirrors are in-sync.
+ *
+ * The function is destructive: to remove intermediate mirror layers,
+ * VG metadata commits and suspend/resume are necessary.
+ */
+int collapse_mirrored_lv(struct logical_volume *lv)
+{
+	struct logical_volume *tmp_lv, *parent_lv;
+	struct list lvlist;
+
+	while ((tmp_lv = _find_tmp_mirror(lv))) {
+		parent_lv = find_parent_for_layer(lv, tmp_lv);
+		if (!_mirrored_lv_in_sync(parent_lv)) {
+			log_verbose("Not collapsing %s: out-of-sync",
+				    parent_lv->name);
+			return 1;
+		}
+
+		list_init(&lvlist);
+		if (!_remove_mirror_images(parent_lv,
+					   first_seg(parent_lv)->area_count - 1,
+					   NULL, 1, &lvlist)) {
+			log_error("Failed to release mirror images");
+			return 0;
+		}
+
+		if (!_merge_mirror_images(parent_lv, &lvlist)) {
+			log_error("Failed to add mirror images");
+			return 0;
+		}
+	}
 
 	return 1;
 }
@@ -338,19 +508,13 @@
 			      struct list *removable_pvs, unsigned remove_log)
 {
 	int r;
-	int in_sync = 0;
+	int in_sync;
 	int log_policy, dev_policy;
 	uint32_t old_num_mirrors = mirrored_seg->area_count;
 	int had_log = (mirrored_seg->log_lv) ? 1 : 0;
-	float sync_percent = 0;
 
 	/* was the mirror in-sync before problems? */
-	if (!lv_mirror_percent(mirrored_seg->lv->vg->cmd,
-			       mirrored_seg->lv, 0, &sync_percent, NULL))
-		log_error("WARNING: Unable to determine mirror sync status of %s/%s.",
-			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
-	else if (sync_percent >= 100.0)
-		in_sync = 1;
+	in_sync = _mirrored_lv_in_sync(mirrored_seg->lv);
 
 	/*
 	 * While we are only removing devices, we can have sync set.
@@ -359,7 +523,7 @@
 	 */
 	init_mirror_in_sync(in_sync);
 
-	r = remove_mirror_images(mirrored_seg, num_mirrors,
+	r = remove_mirror_images(mirrored_seg->lv, num_mirrors,
 				 removable_pvs, remove_log);
 	if (!r)
 		/* Unable to remove bad devices */
@@ -721,7 +885,7 @@
 		init_mirror_in_sync(0);
 	}
 
-	if (!remove_mirror_images(first_seg(lv), lv_mirror_count(lv),
+	if (!remove_mirror_images(lv, lv_mirror_count(lv),
 				  removable_pvs, 1U))
 		return_0;
 
@@ -1195,17 +1359,17 @@
 		return 0;
 	}
 
-	if (seg->area_count <= mirrors) {
+	if (lv_mirror_count(lv) <= mirrors) {
 		log_error("Removing more than existing: %d <= %d",
 			  seg->area_count, mirrors);
 		return 0;
 	}
-	new_mirrors = seg->area_count - mirrors - 1;
+	new_mirrors = lv_mirror_count(lv) - mirrors - 1;
 
 	/* MIRROR_BY_LV */
 	if (seg_type(seg, 0) == AREA_LV &&
 	    seg_lv(seg, 0)->status & MIRROR_IMAGE) {
-		return remove_mirror_images(first_seg(lv), new_mirrors + 1,
+		return remove_mirror_images(lv, new_mirrors + 1,
 					    pvs, log_count ? 1U : 0);
 	}
 
--- LVM2/tools/lvconvert.c	2007/12/20 15:42:55	1.48
+++ LVM2/tools/lvconvert.c	2007/12/20 18:55:46	1.49
@@ -369,14 +369,20 @@
 			return 1;
 		}
 	} else if (lp->mirrors > existing_mirrors) {
-		/* FIXME Unless anywhere, remove PV of log_lv
-		 * from allocatable_pvs & allocate
-		 * (mirrors - existing_mirrors) new areas
-		 */
-		/* FIXME Create mirror hierarchy to sync */
-		log_error("Adding mirror images is not "
-			  "supported yet.");
-		return 0;
+		/* FIXME: can't have multiple mlogs. force corelog. */
+		corelog = 1;
+		if (!insert_layer_for_lv(cmd, lv, 0, "_resync%d")) {
+			log_error("Failed to insert resync layer");
+			return 0;
+		}
+		if (!lv_add_mirrors(cmd, lv, lp->mirrors - existing_mirrors, 1,
+				    adjusted_mirror_region_size(
+						lv->vg->extent_size,
+						lv->le_count,
+						lp->region_size),
+				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    MIRROR_BY_LV))
+			return_0;
 	} else {
 		/* Reduce number of mirrors */
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
--- LVM2/tools/lvresize.c	2007/11/15 02:20:03	1.89
+++ LVM2/tools/lvresize.c	2007/12/20 18:55:46	1.90
@@ -435,7 +435,7 @@
 	if ((lp->extents > lv->le_count)) {
 		list_iterate_back_items(seg, &lv->segments) {
 			if (seg_is_mirrored(seg))
-				seg_mirrors = seg->area_count;
+				seg_mirrors = lv_mirror_count(seg->lv);
 			else
 				seg_mirrors = 0;
 			break;
@@ -469,7 +469,7 @@
 			}
 
 			if (seg_is_mirrored(seg))
-				seg_mirrors = seg->area_count;
+				seg_mirrors = lv_mirror_count(seg->lv);
 			else
 				seg_mirrors = 0;
 
--- LVM2/tools/toollib.c	2007/12/20 15:42:55	1.119
+++ LVM2/tools/toollib.c	2007/12/20 18:55:46	1.120
@@ -1222,6 +1222,12 @@
 		return 0;
 	}
 
+	if (strstr(name, "_resync")) {
+		log_error("Names including \"_resync\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	return 1;
 }
 


