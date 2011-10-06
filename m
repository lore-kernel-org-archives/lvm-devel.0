From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Oct 2011 14:55:41 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20111006145541.20297.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-06 14:55:40

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/metadata   : mirror.c 

Log message:
	Fix splitmirror in cluster having different DM/LVM views of storage.
	This patch also does some clean-up of the splitmirrors code.
	
	I've attempted to clean-up the splitmirrors code to make it easier to
	understand with fewer operations.  I've tried to reduce the number of
	metadata operations without compromising the intermediate stages which
	are necessary for easy clean-up in the even of failure.
	
	These changes now correctly handle cluster situations - including exclusive
	cluster mirrors.  Whereas before, a splitmirror operation would result in
	remote nodes having LVM commands report the newly split LV with a proper
	name while DM commands would report the old (pre-split) names of the device.
	IOW, there was a kernel/userspace mismatch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2148&r2=1.2149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173

--- LVM2/WHATS_NEW	2011/10/06 14:49:16	1.2148
+++ LVM2/WHATS_NEW	2011/10/06 14:55:39	1.2149
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix splitmirror in cluster having different DM/LVM views of storage.
   Fix improper udev settings during suspend/resume for mirror sub-LVs.
   Fix vgsplit when there are mirrors that have mirrored logs.
   Clarify multi-name device filter pattern matching explanation in lvm.conf.5.
--- LVM2/lib/activate/activate.c	2011/10/03 18:37:47	1.216
+++ LVM2/lib/activate/activate.c	2011/10/06 14:55:40	1.217
@@ -230,10 +230,19 @@
 void activation_exit(void)
 {
 }
+
 int lv_is_active(struct logical_volume *lv)
 {
 	return 0;
 }
+int lv_is_active_but_not_locally(struct logical_volume *lv)
+{
+	return 0;
+}
+int lv_is_active_exclusive(struct logical_volume *lv)
+{
+	return 0;
+}
 int lv_is_active_exclusive_locally(struct logical_volume *lv)
 {
 	return 0;
@@ -242,6 +251,7 @@
 {
 	return 0;
 }
+
 int lv_check_transient(struct logical_volume *lv)
 {
 	return 1;
@@ -873,6 +883,13 @@
 	return _lv_is_active(lv, &l, NULL) && !l;
 }
 
+int lv_is_active_exclusive(struct logical_volume *lv)
+{
+	int e;
+
+	return _lv_is_active(lv, NULL, &e) && e;
+}
+
 int lv_is_active_exclusive_locally(struct logical_volume *lv)
 {
 	int l, e;
--- LVM2/lib/activate/activate.h	2011/10/03 18:37:47	1.82
+++ LVM2/lib/activate/activate.h	2011/10/06 14:55:40	1.83
@@ -109,6 +109,7 @@
 
 int lv_is_active(struct logical_volume *lv);
 int lv_is_active_but_not_locally(struct logical_volume *lv);
+int lv_is_active_exclusive(struct logical_volume *lv);
 int lv_is_active_exclusive_locally(struct logical_volume *lv);
 int lv_is_active_exclusive_remotely(struct logical_volume *lv);
 
--- LVM2/lib/metadata/mirror.c	2011/10/06 14:49:16	1.172
+++ LVM2/lib/metadata/mirror.c	2011/10/06 14:55:40	1.173
@@ -395,6 +395,22 @@
 }
 
 /*
+ * Activate an LV similarly (i.e. SH or EX) to a given "model" LV
+ */
+static int _activate_lv_like_model(struct logical_volume *model,
+				   struct logical_volume *lv)
+{
+	if (lv_is_active_exclusive(model)) {
+		if (!activate_lv_excl(lv->vg->cmd, lv))
+			return_0;
+	} else {
+		if (!activate_lv(lv->vg->cmd, lv))
+			return_0;
+	}
+	return 1;
+}
+
+/*
  * Delete independent/orphan LV, it must acquire lock.
  */
 static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv)
@@ -417,13 +433,9 @@
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
+	if (!_activate_lv_like_model(lv, lv))
+		return_0;
 
 	sync_local_dev_names(lv->vg->cmd);
 	if (!deactivate_lv(cmd, lv))
@@ -560,8 +572,14 @@
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
 			       NULL)) {
-		log_error("Unable to determine mirror sync status of %s/%s.",
-			  lv->vg->name, lv->name);
+		if (lv_is_active_but_not_locally(lv))
+			log_error("Unable to determine mirror sync status of"
+				  " remotely active LV, %s/%s",
+				  lv->vg->name, lv->name);
+		else
+			log_error("Unable to determine mirror "
+				  "sync status of %s/%s.",
+				  lv->vg->name, lv->name);
 		return 0;
 	}
 
@@ -584,7 +602,7 @@
 	struct logical_volume *detached_log_lv = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct dm_list split_images;
-	struct lv_list *lvl, *new_lvl = NULL;
+	struct lv_list *lvl;
 	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!(lv->status & MIRRORED)) {
@@ -626,12 +644,18 @@
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
@@ -640,90 +664,7 @@
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
-
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
 
-	dm_list_del(&new_lvl->list);
 	new_lv->name = dm_pool_strdup(lv->vg->vgmem, split_name);
 	if (!new_lv->name) {
 		log_error("Unable to rename newly split LV");
@@ -780,19 +721,77 @@
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
 
-	/* Bring newly split-off LV into existence */
-	if (!activate_lv(cmd, new_lv)) {
-		log_error("Failed to activate newly split LV, %s",
-			  new_lv->name);
+	/*
+	 * Suspend the mirror - this includes all the sub-LVs and
+	 *                      soon-to-be-split sub-LVs
+	 */
+	if (!suspend_lv(cmd, mirrored_seg->lv)) {
+		log_error("Failed to lock %s", mirrored_seg->lv->name);
+		vg_revert(mirrored_seg->lv->vg);
 		return 0;
 	}
 
-	log_very_verbose("%" PRIu32 " image(s) detached from %s",
-			 split_count, lv->name);
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
+	/*
+	 * Recycle newly split LV so it is properly renamed.
+	 *   Cluster requires the extra deactivate/activate calls.
+	 */
+	if (vg_is_clustered(lv->vg) &&
+	    (!deactivate_lv(cmd, new_lv) ||
+	     !_activate_lv_like_model(lv, new_lv))) {
+		log_error("Failed to rename newly split LV in the kernel");
+		return 0;
+	}
+	if (!suspend_lv(cmd, new_lv) || !resume_lv(cmd, new_lv)) {
+		log_error("Failed to rename newly split LV in the kernel");
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
 
 	return 1;
 }


