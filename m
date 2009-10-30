From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 30 Oct 2009 16:50:45 -0500
Subject: [PATCH 1 of 2] LVM: add split capability to _remove_mirror_images
Message-ID: <200910302150.n9ULojAw005272@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-split-capability-to-_remove_mirror_images.patch

This patch adds the capability to split off a mirror leg
to the _remove_mirror_images function.  Essentially, we
replace the function that pulls a leg from a mirror and
frees it with just the function that pulls it.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -472,6 +472,8 @@ static int _is_mirror_image_removable(st
  *                  mirror layer and merge mirrors to the original LV.
  *                  removable_pvs should be NULL and num_removed should be
  *                  seg->area_count - 1.
+ *   split:	    if non-NULL, split the mimage off rather than removing
+ *		    it, making this argument its name.
  *   removed:       if non NULL, the number of removed mirror images is set
  *                  as a result
  *
@@ -486,7 +488,9 @@ static int _is_mirror_image_removable(st
 static int _remove_mirror_images(struct logical_volume *lv,
 				 uint32_t num_removed,
 				 struct dm_list *removable_pvs,
-				 unsigned remove_log, unsigned collapse,
+				 unsigned remove_log,
+				 unsigned collapse,
+				 const char *split,
 				 uint32_t *removed)
 {
 	uint32_t m;
@@ -537,13 +541,24 @@ static int _remove_mirror_images(struct 
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		lv_set_visible(seg_lv(mirrored_seg, m));
-		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
-			log_error("lv_list alloc failed");
+		if (!split) {
+			lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
+			if (!lvl) {
+				log_error("lv_list alloc failed");
+				return 0;
+			}
+			lvl->lv = seg_lv(mirrored_seg, m);
+			dm_list_add(&tmp_orphan_lvs, &lvl->list);
+			release_lv_segment_area(mirrored_seg, m,
+						mirrored_seg->area_len);
+			continue;
+		}
+		remove_seg_from_segs_using_this_lv(seg_lv(mirrored_seg, m),
+						   mirrored_seg);
+		if (!lv_rename(lv->vg->cmd, seg_lv(mirrored_seg, m), split)) {
+			log_error("Unable to rename newly split LV");
 			return 0;
 		}
-		lvl->lv = seg_lv(mirrored_seg, m);
-		dm_list_add(&tmp_orphan_lvs, &lvl->list);
-		release_lv_segment_area(mirrored_seg, m, mirrored_seg->area_len);
 	}
 	mirrored_seg->area_count = new_area_count;
 
@@ -671,7 +686,7 @@ int remove_mirror_images(struct logical_
 			removed_once = first_seg(next_lv)->area_count - 1;
 
 		if (!_remove_mirror_images(next_lv, removed_once,
-					   removable_pvs, remove_log, 0, &r))
+					   removable_pvs, remove_log, 0, 0, &r))
 			return_0;
 
 		if (r < removed_once) {
@@ -745,7 +760,7 @@ int collapse_mirrored_lv(struct logical_
 
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
-					   NULL, 1, 1, NULL)) {
+					   NULL, 1, 1, 0, NULL)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}
@@ -866,7 +881,7 @@ int reconfigure_mirror_images(struct lv_
 	init_mirror_in_sync(in_sync);
 
 	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors - num_mirrors,
-				  removable_pvs, remove_log, 0, NULL);
+				  removable_pvs, remove_log, 0, 0, NULL);
 	if (!r)
 		/* Unable to remove bad devices */
 		return 0;


