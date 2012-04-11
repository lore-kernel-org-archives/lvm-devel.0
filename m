From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Apr 2012 14:20:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20120411142021.21095.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-11 14:20:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Fix inability to split RAID1 image while specifying a particular PV.
	
	The logic for resuming the original and newly split LVs was not properly
	done to handle situations where anything but the last device in the array
	was split.  It did not take into account the possible name collisions that
	might occur when the original LV undergoes the shifting and renaming of its
	sub-LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2382&r2=1.2383
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2012/04/11 12:42:10	1.2382
+++ LVM2/WHATS_NEW	2012/04/11 14:20:19	1.2383
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix inability to split RAID1 image while specifying a particular PV.
   Update man pages to give them same look&feel.
   Fix lvresize of thin pool for stipped devices.
   For lvresize round upward when specifying number of extents.
--- LVM2/lib/metadata/raid_manip.c	2012/04/11 01:23:29	1.26
+++ LVM2/lib/metadata/raid_manip.c	2012/04/11 14:20:20	1.27
@@ -64,6 +64,24 @@
 	return seg->area_count;
 }
 
+/*
+ * Resume sub-LVs first, then top-level LV
+ */
+static int _bottom_up_resume(struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg_is_raid(seg) && (seg->area_count > 1)) {
+		for (s = 0; s < seg->area_count; s++)
+			if (!resume_lv(lv->vg->cmd, seg_lv(seg, s)) ||
+			    !resume_lv(lv->vg->cmd, seg_metalv(seg, s)))
+				return_0;
+	}
+
+	return resume_lv(lv->vg->cmd, lv);
+}
+
 static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 					   struct logical_volume *sub_lv)
 {
@@ -975,8 +993,6 @@
 static int _raid_remove_images(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs)
 {
-	uint32_t s;
-	struct lv_segment *seg;
 	struct dm_list removal_list;
 	struct lv_list *lvl;
 
@@ -1035,13 +1051,7 @@
 	 * tries to rename first, it will collide with the existing
 	 * position 1.
 	 */
-	seg = first_seg(lv);
-	for (s = 0; (new_count > 1) && (s < seg->area_count); s++) {
-		if (!resume_lv(lv->vg->cmd, seg_lv(seg, s)) ||
-		    !resume_lv(lv->vg->cmd, seg_metalv(seg, s)))
-			return_0;
-	}
-	if (!resume_lv(lv->vg->cmd, lv)) {
+	if (!_bottom_up_resume(lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1193,22 +1203,33 @@
 	}
 
 	/*
-	 * Resume original LV
-	 * This also resumes all other sub-lvs (including the extracted)
+	 * First resume the newly split LV and LVs on the removal list.
+	 * This is necessary so that there are no name collisions due to
+	 * the original RAID LV having possibly had sub-LVs that have been
+	 * shifted and renamed.
+	 */
+	if (!resume_lv(cmd, lvl->lv))
+		return_0;
+	dm_list_iterate_items(lvl, &removal_list)
+		if (!resume_lv(cmd, lvl->lv))
+			return_0;
+
+	/*
+	 * Resume the remaining LVs
+	 * We must start by resuming the sub-LVs first (which would
+	 * otherwise be handled automatically) because the shifting
+	 * of positions could otherwise cause name collisions.  For
+	 * example, if position 0 of a 3-way array is split, position
+	 * 1 and 2 must be shifted and renamed 0 and 1.  If position 2
+	 * tries to rename first, it will collide with the existing
+	 * position 1.
 	 */
-	if (!resume_lv(cmd, lv)) {
+	if (!_bottom_up_resume(lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	/* Recycle newly split LV so it is properly renamed */
-	if (!suspend_lv(cmd, lvl->lv) || !resume_lv(cmd, lvl->lv)) {
-		log_error("Failed to rename %s to %s after committing changes",
-			  old_name, split_name);
-		return 0;
-	}
-
 	/*
 	 * Eliminate the residual LVs
 	 */


