From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 13:13:55 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20080117131355.21166.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 13:13:55

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	tools          : vgreduce.c 

Log message:
	lvconvert/vgreduce fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/lib/metadata/lv_manip.c	2008/01/16 20:00:01	1.142
+++ LVM2/lib/metadata/lv_manip.c	2008/01/17 13:13:54	1.143
@@ -459,6 +459,24 @@
 }
 
 /*
+ * Empty an LV and add error segment.
+ */
+int lv_remap_error(struct logical_volume *lv)
+{
+	uint32_t len = lv->le_count;
+
+	if (!lv_empty(lv))
+		return_0;
+
+	if (!lv_add_virtual_segment(lv, 0, len,
+				    get_segtype_from_string(lv->vg->cmd,
+							    "error")))
+		return_0;
+
+	return 1;
+}
+
+/*
  * Remove given number of extents from LV.
  */
 int lv_reduce(struct logical_volume *lv, uint32_t extents)
--- LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:54:39	1.37
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/17 13:13:54	1.38
@@ -378,6 +378,9 @@
 /* Empty an LV prior to deleting it */
 int lv_empty(struct logical_volume *lv);
 
+/* Empty an LV and add error segment */
+int lv_remap_error(struct logical_volume *lv);
+
 /* Entry point for all LV extent allocations */
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
--- LVM2/lib/metadata/mirror.c	2008/01/16 19:50:23	1.59
+++ LVM2/lib/metadata/mirror.c	2008/01/17 13:13:54	1.60
@@ -373,11 +373,34 @@
 
 /*
  * Remove num_removed images from mirrored_seg
+ *
+ * Arguments:
+ *   num_removed:   the requested (maximum) number of mirrors to be removed
+ *   removable_pvs: if not NULL, only mirrors using PVs in this list
+ *                  will be removed
+ *   remove_log:    if non-zero, log_lv will be removed
+ *                  (even if it's 0, log_lv will be removed if there is no
+ *                   mirror remaining after the removal)
+ *   collapse:      if non-zero, instead of removing, remove the temporary
+ *                  mirror layer and merge mirrors to the original LV.
+ *                  removable_pvs should be NULL and num_removed should be
+ *                  seg->area_count - 1.
+ *   removed:       if non NULL, the number of removed mirror images is set
+ *                  as a result
+ *
+ * If collapse is non-zero, <removed> is guaranteed to be equal to num_removed.
+ *
+ * Return values:
+ *   Failure (0) means something unexpected has happend and
+ *   the caller should abort.
+ *   Even if no mirror was removed (e.g. no LV matches to 'removable_pvs'),
+ *   returns success (1).
  */
 static int _remove_mirror_images(struct logical_volume *lv,
 				 uint32_t num_removed,
 				 struct list *removable_pvs,
-				 unsigned remove_log, unsigned collapse)
+				 unsigned remove_log, unsigned collapse,
+				 uint32_t *removed)
 {
 	uint32_t m;
 	uint32_t s;
@@ -391,6 +414,9 @@
 	struct lv_list *lvl;
 	struct list tmp_orphan_lvs;
 
+	if (removed)
+		*removed = 0;
+
 	log_very_verbose("Reducing mirror set from %" PRIu32 " to %"
 			 PRIu32 " image(s)%s.",
 			 old_area_count, old_area_count - num_removed,
@@ -407,7 +433,8 @@
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);
-			if (_is_mirror_image_removable(sub_lv, removable_pvs)) {
+			if (!is_temporary_mirror_layer(sub_lv) &&
+			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
 				/* Swap segment to end */
 				new_area_count--;
 				area = mirrored_seg->areas[new_area_count];
@@ -415,10 +442,8 @@
 				mirrored_seg->areas[s] = area;
 			}
 		}
-		if (num_removed && old_area_count == new_area_count) {
-			log_error("No mirror images found using specified PVs.");
-			return 0;
-		}
+		if (num_removed && old_area_count == new_area_count)
+			return 1;
 	} else
 		new_area_count = old_area_count - num_removed;
 
@@ -442,7 +467,10 @@
 	log_lv = mirrored_seg->log_lv;
 
 	/* If no more mirrors, remove mirror layer */
-	if (new_area_count == 1) {
+	/* As an exceptional case, if the lv is temporary layer,
+	 * leave the LV as mirrored and let the lvconvert completion
+	 * to remove the layer. */
+	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
 		_remove_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
@@ -454,6 +482,15 @@
 			log_error("Failed to add mirror images");
 			return 0;
 		}
+	} else if (new_area_count == 0) {
+		/* All mirror images are gone.
+		 * It can happen for vgreduce --removemissing. */
+		_remove_mirror_log(mirrored_seg);
+		lv->status &= ~MIRRORED;
+		lv->status &= ~MIRROR_NOTSYNCED;
+		if (!lv_remap_error(lv))
+			return_0;
+		remove_log = 1;
 	} else if (remove_log)
 		_remove_mirror_log(mirrored_seg);
 
@@ -502,6 +539,20 @@
 	if (remove_log && log_lv && !_delete_lv(lv, log_lv))
 		return 0;
 
+	/* Mirror with only 1 area is 'in sync'. */
+	if (!remove_log && log_lv &&
+	    new_area_count == 1 && is_temporary_mirror_layer(lv)) {
+		if (!_init_mirror_log(lv->vg->cmd, log_lv, 1, &lv->tags, 0)) {
+			/* As a result, unnecessary sync may run after
+			 * collapsing. But safe.*/
+			log_error("Failed to initialize log device");
+			return_0;
+		}
+	}
+
+	if (removed)
+		*removed = old_area_count - new_area_count;
+
 	return 1;
 }
 
@@ -511,24 +562,43 @@
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
 			 struct list *removable_pvs, unsigned remove_log)
 {
-	uint32_t num_removed, removed_once;
+	uint32_t num_removed, removed_once, r;
 	uint32_t existing_mirrors = lv_mirror_count(lv);
+	struct logical_volume *next_lv = lv;
 
 	num_removed = existing_mirrors - num_mirrors;
 
 	/* num_removed can be 0 if the function is called just to remove log */
 	do {
-		if (num_removed < first_seg(lv)->area_count)
+		if (num_removed < first_seg(next_lv)->area_count)
 			removed_once = num_removed;
 		else
-			removed_once = first_seg(lv)->area_count - 1;
+			removed_once = first_seg(next_lv)->area_count - 1;
 
-		if (!_remove_mirror_images(lv, removed_once,
-				           removable_pvs, remove_log, 0))
+		if (!_remove_mirror_images(next_lv, removed_once,
+					   removable_pvs, remove_log, 0, &r))
 			return_0;
 
-		num_removed -= removed_once;
-	} while (num_removed);
+		if (r < removed_once) {
+			/* Some mirrors are removed from the temporary mirror,
+			 * but the temporary layer still exists.
+			 * Down the stack and retry for remainder. */
+			next_lv = find_tmp_mirror(next_lv);
+		}
+
+		num_removed -= r;
+	} while (next_lv && num_removed);
+
+	if (num_removed) {
+		if (num_removed == existing_mirrors - num_mirrors)
+			log_error("No mirror images found using specified PVs.");
+		else {
+			log_error("%u images are removed out of requested %u.",
+				  existing_mirrors - lv_mirror_count(lv),
+				  existing_mirrors - num_mirrors);
+		}
+		return 0;
+	}
 
 	return 1;
 }
@@ -581,7 +651,7 @@
 
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
-					   NULL, 1, 1)) {
+					   NULL, 1, 1, NULL)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}
@@ -701,8 +771,8 @@
 	 */
 	init_mirror_in_sync(in_sync);
 
-	r = remove_mirror_images(mirrored_seg->lv, num_mirrors,
-				 removable_pvs, remove_log);
+	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors - num_mirrors,
+				  removable_pvs, remove_log, 0, NULL);
 	if (!r)
 		/* Unable to remove bad devices */
 		return 0;
--- LVM2/tools/vgreduce.c	2008/01/16 19:00:59	1.73
+++ LVM2/tools/vgreduce.c	2008/01/17 13:13:54	1.74
@@ -255,8 +255,10 @@
 			}
 		}
 
+  lvs_changed_altered:
 		/* Remove lost mirror images from mirrors */
 		list_iterate_items(lvl, &vg->lvs) {
+  mirrored_seg_altered:
 			mirrored_seg = first_seg(lvl->lv);
 			if (!seg_is_mirrored(mirrored_seg))
 				continue;
@@ -315,6 +317,23 @@
 					vg_revert(vg);
 					return 0;
 				}
+
+				/* mirrored LV no longer has valid mimages.
+				 * So add it to lvs_changed for removal.
+				 * For this LV may be an area of other mirror,
+				 * restart the loop. */
+				if (!mimages) {
+					if (!_remove_lv(cmd, lvl->lv,
+						 &list_unsafe, &lvs_changed))
+						return_0;
+					goto lvs_changed_altered;
+				}
+
+				/* As a result of reconfigure_mirror_images(),
+				 * first_seg(lv) may now be different seg.
+				 * e.g. a temporary layer might be removed.
+				 * So check the mirrored_seg again. */
+				goto mirrored_seg_altered;
 			}
 		}
 


