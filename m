From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 12 Jul 2010 09:30:11 -0500
Subject: [Patch] Split mirror fixes
Message-ID: <1278945011.8025.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

	brassow

Fix for bugs: 612248 & 612291 Split mirror issues

The main problem with these bugs was that the newly split
off LV was not being suspended properly.  This meant that
the memlock count was not being balanced, the DM devices
were not being renamed, and some DM devices which should
have been removed were not.

I've also renamed some of the variables and added comments
to make things clearer as to what is going on.  (I can break
this patch in two if it means easier review.)

Two questions still remaining concerning this patch...
1) After all devices are suspended, is it better to resume
   the newly split LV first, or the original device?  I
   don't think it matters and have chosen to resume the
   split LV first.
2) Even though we are grabbing devices to split off from
   the original mirror from the end of the sub_lv list,
   why are they the numericly first LVs (i.e lv_mimage_0
   instead of lv_mimage_3)?  You would expect to have
   lv_mimage_[01] in your original instead of lv_mimage_[23].
   Will answer this before checking in the patch - can be
   answered by gdb and tracking structures...  I also have
   yet to ensure that this doesn't affect the specification
   of devices to be removed, since they are shifted to the
   end of the list before being pulled.


Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -553,9 +553,9 @@ static int _split_mirror_images(struct l
 				struct dm_list *removable_pvs)
 {
 	uint32_t i;
-	struct logical_volume *sub_lv, *new_lv = NULL;
+	struct logical_volume *sub_lv = NULL;
+	struct logical_volume *new_lv = NULL;
 	struct logical_volume *detached_log_lv = NULL;
-	struct logical_volume *lv1 = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct dm_list split_images;
 	struct lv_list *lvl;
@@ -597,6 +597,8 @@ static int _split_mirror_images(struct l
 		release_lv_segment_area(mirrored_seg, mirrored_seg->area_count,
 					mirrored_seg->area_len);
 
+		log_very_verbose("%s assigned to be split", sub_lv->name);
+
 		if (!new_lv) {
 			new_lv = sub_lv;
 			new_lv->name = dm_pool_strdup(lv->vg->cmd->mem,
@@ -662,13 +664,19 @@ static int _split_mirror_images(struct l
 		init_mirror_in_sync(1);
 	}
 
-	/* If no more mirrors, remove mirror layer */
+	sub_lv = NULL;
+
+	/*
+	 * If no more mirrors, remove mirror layer.
+	 * The sub_lv is removed entirely later - leaving
+	 * only the top-level (now linear) LV.
+	 */
 	if (mirrored_seg->area_count == 1) {
-		lv1 = seg_lv(mirrored_seg, 0);
-		lv1->status &= ~MIRROR_IMAGE;
-		lv_set_visible(lv1);
+		sub_lv = seg_lv(mirrored_seg, 0);
+		sub_lv->status &= ~MIRROR_IMAGE;
+		lv_set_visible(sub_lv);
 		detached_log_lv = detach_mirror_log(mirrored_seg);
-		if (!remove_layer_from_lv(lv, lv1))
+		if (!remove_layer_from_lv(lv, sub_lv))
 			return_0;
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
@@ -679,6 +687,9 @@ static int _split_mirror_images(struct l
 		return 0;
 	}
 
+	/*
+	 * Suspend the original device and all its sub devices
+	 */
 	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Failed to lock %s", mirrored_seg->lv->name);
 		vg_revert(mirrored_seg->lv->vg);
@@ -690,35 +701,32 @@ static int _split_mirror_images(struct l
 		return 0;
 	}
 
-	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
-
 	/*
-	 * If we have split off a mirror instead of linear (i.e. the
-	 * split_images list is not empty), then we must perform a
-	 * resume to get the mirror started.
+	 * Suspend the newly split-off LV (balance memlock count
+	 * and prepare for DM automated renaming via resume).
 	 */
-	if (!dm_list_empty(&split_images) && !resume_lv(lv->vg->cmd, new_lv)) {
-		log_error("Failed to resume newly split LV, %s", new_lv->name);
+	if (!suspend_lv(lv->vg->cmd, new_lv)) {
+		log_error("Failed to lock newly split LV, %s", new_lv->name);
+		vg_revert(lv->vg);
 		return 0;
 	}
 
-	/*
-	 * Avoid having same mirror target loaded twice simultaneously by first
-	 * resuming the removed LV which now contains an error segment.
-	 * As it's now detached from mirrored_seg->lv we must resume it
-	 * explicitly.
-	 */
-	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
-		log_error("Problem resuming temporary LV, %s", lv1->name);
+	/* Bring newly split-off LV into existence */
+	log_very_verbose("Creating %s", new_lv->name);
+	if (!resume_lv(lv->vg->cmd, new_lv)) {
+		log_error("Failed to activate newly split LV, %s",
+			  new_lv->name);
 		return 0;
 	}
 
+	/* Resume altered original LV */
+	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Problem reactivating %s", mirrored_seg->lv->name);
 		return 0;
 	}
 
-	if (lv1 && !_delete_lv(lv, lv1))
+	if (sub_lv && !_delete_lv(lv, sub_lv))
 		return_0;
 
 	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))



