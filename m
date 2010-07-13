From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Jul 2010 21:48:18 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100713214818.17286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-13 21:48:17

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bugs: 612248 & 612291 Split mirror issues
	
	The main problem with these bugs was that the newly split
	off LV was not being suspended properly.  This meant that
	the memlock count was not being balanced, the DM devices
	were not being renamed, and some DM devices which should
	have been removed were not.
	
	I've also renamed some of the variables and added comments
	to make things clearer as to what is going on.  (I can break
	this patch in two if it means easier review.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1666&r2=1.1667
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/WHATS_NEW	2010/07/13 13:51:01	1.1666
+++ LVM2/WHATS_NEW	2010/07/13 21:48:16	1.1667
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Fix suspend/resume logic for LVs resulting from splitting a mirror.
   Switch cmirrord and clvmd to use dm_create_lockfile.
   Allow clvmd pidfile to be configurable.
   Update comments about memory handling in lvm2app.h.
--- LVM2/lib/metadata/mirror.c	2010/07/09 17:57:51	1.125
+++ LVM2/lib/metadata/mirror.c	2010/07/13 21:48:17	1.126
@@ -553,9 +553,9 @@
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
@@ -597,6 +597,8 @@
 		release_lv_segment_area(mirrored_seg, mirrored_seg->area_count,
 					mirrored_seg->area_len);
 
+		log_very_verbose("%s assigned to be split", sub_lv->name);
+
 		if (!new_lv) {
 			new_lv = sub_lv;
 			new_lv->name = dm_pool_strdup(lv->vg->cmd->mem,
@@ -662,13 +664,19 @@
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
@@ -679,6 +687,9 @@
 		return 0;
 	}
 
+	/*
+	 * Suspend the original device and all its sub devices
+	 */
 	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Failed to lock %s", mirrored_seg->lv->name);
 		vg_revert(mirrored_seg->lv->vg);
@@ -690,35 +701,32 @@
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


