From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 30 Sep 2011 16:11:33 -0500
Subject: [PATCH 3 of 3] Clean-up splitmirror code
In-Reply-To: <1317416791.4475.3.camel@f14.redhat.com>
References: <1317416791.4475.3.camel@f14.redhat.com>
Message-ID: <1317417093.4475.9.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Clean-up splitmirrors code.

I've attempted to clean-up the splitmirrors code to make it easier to
understand with fewer operations.  I've tried to reduce the number of
metadata operations without compromising the intermediate stages which
are necessary for easy clean-up in the even of failure.

These changes now correctly handle cluster situations - including exclusive
cluster mirrors.

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -394,6 +394,19 @@ activate_lv:
 	return 0;
 }
 
+static int inkind_activate_lv(struct logical_volume *model,
+			      struct logical_volume *lv)
+{
+	if (lv_is_active_exclusive_locally(model)) {
+		if (!activate_lv_excl(lv->vg->cmd, lv))
+			return_0;
+	} else {
+		if (!activate_lv(lv->vg->cmd, lv))
+			return_0;
+	}
+	return 1;
+}
+
 /*
  * Delete independent/orphan LV, it must acquire lock.
  */
@@ -417,13 +430,9 @@ static int _delete_lv(struct logical_vol
 		}
 	}
 
-	if (lv_is_active_exclusive_locally(lv)) {
-		if (!activate_lv_excl(cmd, lv))
-			return_0;
-	} else {
-		if (!activate_lv(cmd, lv))
-			return_0;
-	}
+	// FIXME: shouldn't the activation type be based on mirror_lv, not lv?
+	if (!inkind_activate_lv(lv, lv))
+		return_0;
 
 	sync_local_dev_names(lv->vg->cmd);
 	if (!deactivate_lv(cmd, lv))
@@ -584,7 +593,7 @@ static int _split_mirror_images(struct l
 	struct logical_volume *detached_log_lv = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct dm_list split_images;
-	struct lv_list *lvl, *new_lvl = NULL;
+	struct lv_list *lvl;
 	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!(lv->status & MIRRORED)) {
@@ -626,12 +635,18 @@ static int _split_mirror_images(struct l
 		sub_lv = seg_lv(mirrored_seg, mirrored_seg->area_count);
 
 		sub_lv->status &= ~MIRROR_IMAGE;
-		lv_set_visible(sub_lv);
 		release_lv_segment_area(mirrored_seg, mirrored_seg->area_count,
 					mirrored_seg->area_len);
 
 		log_very_verbose("%s assigned to be split", sub_lv->name);
 
+		if (!new_lv) {
+			lv_set_visible(sub_lv);
+			new_lv = sub_lv;
+			continue;
+		}
+
+		/* If there is more than one image being split, add to list */
 		lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl));
 		if (!lvl) {
 			log_error("lv_list alloc failed");
@@ -640,90 +655,7 @@ static int _split_mirror_images(struct l
 		lvl->lv = sub_lv;
 		dm_list_add(&split_images, &lvl->list);
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
 
-	if (!vg_write(mirrored_seg->lv->vg)) {
-		log_error("Intermediate VG metadata write failed.");
-		return 0;
-	}
-
-	/*
-	 * Suspend the mirror - this includes all the sub-LVs and
-	 *                      soon-to-be-split sub-LVs
-	 */
-	if (!suspend_lv(cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s", mirrored_seg->lv->name);
-		vg_revert(mirrored_seg->lv->vg);
-		return 0;
-	}
-
-	if (!vg_commit(mirrored_seg->lv->vg)) {
-		resume_lv(cmd, mirrored_seg->lv);
-		return 0;
-	}
-
-	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
-
-	/*
-	 * Resume the mirror - this also activates the visible, independent
-	 *                     soon-to-be-split sub-LVs
-	 */
-	if (!resume_lv(cmd, mirrored_seg->lv)) {
-		log_error("Problem resuming %s", mirrored_seg->lv->name);
-		return 0;
-	}
-
-	/* Remove original mirror layer if it has been converted to linear */
-	if (sub_lv && !_delete_lv(lv, sub_lv))
-		return_0;
-
-	/* Remove the log if it has been converted to linear */
-	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
-		return_0;
-
-	/*
-	 * Step 2:
-	 *   The original mirror has been changed and we now have visible,
-	 *   independent, not-yet-renamed, active sub-LVs.  We must:
-	 *   - deactivate the split sub-LVs
-	 *   - rename them
-	 *   - form new mirror if necessary
-	 *   - commit VG changes
-	 *   - activate the new LV
-	 */
-	sync_local_dev_names(lv->vg->cmd);
-	dm_list_iterate_items(lvl, &split_images) {
-		if (!new_lv) {
-			/* Grab 1st sub-LV for later */
-			new_lvl = lvl;
-			new_lv = lvl->lv;
-		}
-
-		sub_lv = lvl->lv;
-		if (!deactivate_lv(cmd, sub_lv)) {
-			log_error("Failed to deactivate former mirror image, %s",
-				  sub_lv->name);
-			return 0;
-		}
-	}
-
-	dm_list_del(&new_lvl->list);
 	new_lv->name = dm_pool_strdup(lv->vg->vgmem, split_name);
 	if (!new_lv->name) {
 		log_error("Unable to rename newly split LV");
@@ -780,19 +712,76 @@ static int _split_mirror_images(struct l
 		init_mirror_in_sync(1);
 	}
 
-	if (!vg_write(mirrored_seg->lv->vg) ||
-	    !vg_commit(mirrored_seg->lv->vg))
-		return_0;
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
 
-	/* Bring newly split-off LV into existence */
-	if (!activate_lv(cmd, new_lv)) {
-		log_error("Failed to activate newly split LV, %s",
-			  new_lv->name);
+	/*
+	 * Recycle newly split LV so it is properly renamed.
+	 *   Cluster requires the extra deactivate/activate calls.
+	 */
+	if (vg_is_clustered(lv->vg) &&
+	    (!deactivate_lv(cmd, new_lv) || !inkind_activate_lv(lv, new_lv))) {
+		log_error("Failed to rename newly split LV in the kernel");
+		return 0;
+	}
+	if (!suspend_lv(cmd, new_lv) || !resume_lv(cmd, new_lv)) {
+		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}
 
-	log_very_verbose("%" PRIu32 " image(s) detached from %s",
-			 split_count, lv->name);
+	/* Remove original mirror layer if it has been converted to linear */
+	if (sub_lv && !_delete_lv(lv, sub_lv))
+		return_0;
+
+	/* Remove the log if it has been converted to linear */
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+		return_0;
 
 	return 1;
 }



