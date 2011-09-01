From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 31 Aug 2011 21:47:05 -0500
Subject: [PATCH] Fix for bug 732142 - Unsafe table load during mirror image split
Message-ID: <1314845226.7510.2.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix for bug 732142: Unsafe table load during mirror image split
(Likely fixes bug 733114 also.)

There was a bad sequence:
*) Make changes to LV layout to split images (e.g. 4-way -> 2-way/2-way)
1) vg_write, suspend_lv(original_mirror), vg_commit
2) activate_lv(newly_split_lv)
3) resume_lv(original_mirror)

Step #2 is not allowed.  However, without it, the resume or the original
mirror will also resume its former sub-LVs - making it impossible to
activate the newly split LV due to the changes in layering, pointers, and
names that had already been made.  Additionally, the resume or the original
brings the sub-lv's online with names that differ from the metadata on disk -
also a no-no.  Thus, the split must be done in stages such that the active LVs
always reflect what is in the committed LVM metadata.

First, alter the original mirror by releasing the images.  The images are made
visible and independent as an intermediate stage.  (This way, we can have
consistency between LVM metadata and active LVs.)  The second stage collects
the recently split LVs, deactivates them, forms them into a mirror if necessary,
and then activates them.  It is a bit of a circuitous method, but it is the only
way to split a mirror from a mirror and obey these general rules:
1) Never [de]activate sub-lvs when the top-level LV is suspended
2) Avoid having active LVs that differ from the description in the LVM metadata

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -585,7 +585,8 @@ static int _split_mirror_images(struct l
 	struct logical_volume *detached_log_lv = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct dm_list split_images;
-	struct lv_list *lvl;
+	struct lv_list *lvl, *new_lvl;
+	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!(lv->status & MIRRORED)) {
 		log_error("Unable to split non-mirrored LV, %s",
@@ -594,7 +595,7 @@ static int _split_mirror_images(struct l
 	}
 
 	if (!split_count) {
-		log_error("split_count is zero!");
+		log_error(INTERNAL_ERROR "split_count is zero!");
 		return 0;
 	}
 
@@ -614,6 +615,12 @@ static int _split_mirror_images(struct l
 		return 0;
 	}
 
+	/*
+	 * Step 1:
+	 *   Remove the images from the mirror.
+	 *   Make them visible, independent LVs (don't change names yet).
+	 *   Track them in a list for later instantiation.
+	 */
 	dm_list_init(&split_images);
 	for (i = 0; i < split_count; i++) {
 		mirrored_seg->area_count--;
@@ -626,31 +633,114 @@ static int _split_mirror_images(struct l
 
 		log_very_verbose("%s assigned to be split", sub_lv->name);
 
+		lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl));
+		if (!lvl) {
+			log_error("lv_list alloc failed");
+			return 0;
+		}
+		lvl->lv = sub_lv;
+		dm_list_add(&split_images, &lvl->list);
+	}
+	sub_lv = NULL;
+
+	/*
+	 * If no more mirrors, remove mirror layer.
+	 * The sub_lv is removed entirely later - leaving
+	 * only the top-level (now linear) LV.
+	 */
+	if (mirrored_seg->area_count == 1) {
+		sub_lv = seg_lv(mirrored_seg, 0);
+		sub_lv->status &= ~MIRROR_IMAGE;
+		lv_set_visible(sub_lv);
+		detached_log_lv = detach_mirror_log(mirrored_seg);
+		if (!remove_layer_from_lv(lv, sub_lv))
+			return_0;
+		lv->status &= ~MIRRORED;
+		lv->status &= ~LV_NOTSYNCED;
+	}
+
+	if (!vg_write(mirrored_seg->lv->vg)) {
+		log_error("Intermediate VG metadata write failed.");
+		return 0;
+	}
+
+	/*
+	 * Suspend the mirror - this includes all the sub-LVs and
+	 *                      soon-to-be-split sub-LVs
+	 */
+	if (!suspend_lv(cmd, mirrored_seg->lv)) {
+		log_error("Failed to lock %s", mirrored_seg->lv->name);
+		vg_revert(mirrored_seg->lv->vg);
+		return 0;
+	}
+
+	if (!vg_commit(mirrored_seg->lv->vg)) {
+		resume_lv(cmd, mirrored_seg->lv);
+		return 0;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
+
+	/*
+	 * Resume the mirror - this also activates the visible, independent
+	 *                     soon-to-be-split sub-LVs
+	 */
+	if (!resume_lv(cmd, mirrored_seg->lv)) {
+		log_error("Problem resuming %s", mirrored_seg->lv->name);
+		return 0;
+	}
+
+	/* Remove original mirror layer if it has been converted to linear */
+	if (sub_lv && !_delete_lv(lv, sub_lv))
+		return_0;
+
+	/* Remove the log if it has been converted to linear */
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+		return_0;
+
+	/*
+	 * Step 2:
+	 *   The original mirror has been changed and we now have visible,
+	 *   independent, not-yet-renamed, active sub-LVs.  We must:
+	 *   - deactivate the split sub-LVs
+	 *   - rename them
+	 *   - form new mirror if necessary
+	 *   - commit VG changes
+	 *   - activate the new LV
+	 */
+	new_lv = NULL;
+	dm_list_iterate_items(lvl, &split_images) {
 		if (!new_lv) {
-			new_lv = sub_lv;
-			new_lv->name = dm_pool_strdup(lv->vg->cmd->mem,
-						      split_name);
-			if (!new_lv->name) {
-				log_error("Unable to rename newly split LV");
-				return 0;
-			}
-		} else {
-			lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
-			if (!lvl) {
-				log_error("lv_list alloc failed");
-				return 0;
-			}
-			lvl->lv = sub_lv;
-			dm_list_add(&split_images, &lvl->list);
+			/* Grab 1st sub-LV for later */
+			new_lvl = lvl;
+			new_lv = lvl->lv;
+		}
+
+		sub_lv = lvl->lv;
+		if (!deactivate_lv(cmd, sub_lv)) {
+			log_error("Failed to deactivate former mirror image, %s",
+				  sub_lv->name);
+			return 0;
 		}
 	}
 
+	dm_list_del(&new_lvl->list);
+	new_lv->name = dm_pool_strdup(lv->vg->vgmem, split_name);
+	if (!new_lv->name) {
+		log_error("Unable to rename newly split LV");
+		return 0;
+	}
+
 	if (!dm_list_empty(&split_images)) {
 		size_t len = strlen(new_lv->name) + 32;
 		char *layer_name, format[len];
 
-		if (!insert_layer_for_lv(lv->vg->cmd, new_lv,
-					 0, "_mimage_%d")) {
+		/*
+		 * A number of images have been split and
+		 * a new mirror layer must be formed
+		 */
+
+		if (!insert_layer_for_lv(cmd, new_lv, 0, "_mimage_%d")) {
 			log_error("Failed to build new mirror, %s",
 				  new_lv->name);
 			return 0;
@@ -664,7 +754,7 @@ static int _split_mirror_images(struct l
 			dm_snprintf(format, len, "%s_mimage_%%d",
 				    new_lv->name);
 
-			layer_name = dm_pool_alloc(lv->vg->cmd->mem, len);
+			layer_name = dm_pool_alloc(lv->vg->vgmem, len);
 			if (!layer_name) {
 				log_error("Unable to allocate memory");
 				return 0;
@@ -691,63 +781,17 @@ static int _split_mirror_images(struct l
 		init_mirror_in_sync(1);
 	}
 
-	sub_lv = NULL;
-
-	/*
-	 * If no more mirrors, remove mirror layer.
-	 * The sub_lv is removed entirely later - leaving
-	 * only the top-level (now linear) LV.
-	 */
-	if (mirrored_seg->area_count == 1) {
-		sub_lv = seg_lv(mirrored_seg, 0);
-		sub_lv->status &= ~MIRROR_IMAGE;
-		lv_set_visible(sub_lv);
-		detached_log_lv = detach_mirror_log(mirrored_seg);
-		if (!remove_layer_from_lv(lv, sub_lv))
-			return_0;
-		lv->status &= ~MIRRORED;
-		lv->status &= ~LV_NOTSYNCED;
-	}
-
-	if (!vg_write(mirrored_seg->lv->vg)) {
-		log_error("Intermediate VG metadata write failed.");
-		return 0;
-	}
-
-	/*
-	 * Suspend the original device and all its sub devices
-	 */
-	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s", mirrored_seg->lv->name);
-		vg_revert(mirrored_seg->lv->vg);
-		return 0;
-	}
-
-	if (!vg_commit(mirrored_seg->lv->vg)) {
-		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
-		return 0;
-	}
+	if (!vg_write(mirrored_seg->lv->vg) ||
+	    !vg_commit(mirrored_seg->lv->vg))
+		return_0;
 
 	/* Bring newly split-off LV into existence */
-	if (!activate_lv(lv->vg->cmd, new_lv)) {
+	if (!activate_lv(cmd, new_lv)) {
 		log_error("Failed to activate newly split LV, %s",
 			  new_lv->name);
 		return 0;
 	}
 
-	/* Resume altered original LV */
-	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
-	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Problem reactivating %s", mirrored_seg->lv->name);
-		return 0;
-	}
-
-	if (sub_lv && !_delete_lv(lv, sub_lv))
-		return_0;
-
-	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
-		return_0;
-
 	log_very_verbose("%" PRIu32 " image(s) detached from %s",
 			 split_count, lv->name);
 



