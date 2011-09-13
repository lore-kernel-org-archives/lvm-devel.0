From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 13:59:20 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20110913135920.4871.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 13:59:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bug 733114.
	
	When an image is split from a 2-way mirror, the original mirror is converted to
	a linear device.  To do this, the top "layer" must be removed.  The segments
	are transferred from the sub-lv to the top-level LV and the link is severed.
	The former sub-lv - having its segments transferred - now contains a temporary
	error target.
	
	When the original LV is resumed, the old sub-lv that now contains an error
	segment is activated and scanned.  This is what causes the I/O error messages.
	There are three ways to fix this problem:
	
	1) Do not set the sub-lv which contains the error target as "visible" before
	suspending the original LV.  This way, when the original is resumed, the sub-lv
	device node is not created and it is not scanned - avoiding the error messages.
	The problem with this approach is that if the machine crashes after the
	resume, it leaves the *hidden* LV in place and the user has a more difficult
	time noticing that it needs to be cleaned up.  Thus, this type of processing is
	frowned upon.
	
	2) Do like _remove_mirror_images does and suspend the original, then suspend
	the sub-lv (the error target), then resume the sub-lv, and finally resume the
	original LV.  This seems like extra pointless operations to me, but it does not
	produce the error message (although, I'm not sure why) and it allows us to
	leave the visible flag in place.
	
	3) Flag the sub-lv (error target) with a "do not scan" flag.  This seems like
	the cleanest approach, but I have been unable to find the method for doing
	this.  LVs get tagged in such a way by _get_udev_flags, but in this case the
	resume of the original LV also resumes the error target LV without running it
	through _get_udev_flags (likely because they are no longer linked).  Could
	there be something wrong in resume_lv?
	
	Option #2 was chosen to fix this bug, but it seems like more of a workaround
	for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2101&r2=1.2102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/WHATS_NEW	2011/09/08 20:55:39	1.2101
+++ LVM2/WHATS_NEW	2011/09/13 13:59:19	1.2102
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Work around resume_lv causing error LV scanning during splitmirror operation.
   Add 7th lv_attr char to show the related kernel target.
   Terminate pv_attr field correctly. (2.02.86)
   Fix 'not not' typo in pvcreate man page.
--- LVM2/lib/metadata/mirror.c	2011/09/06 19:25:43	1.162
+++ LVM2/lib/metadata/mirror.c	2011/09/13 13:59:19	1.163
@@ -666,6 +666,10 @@
 		return 0;
 	}
 
+	/* Suspend temporary error target (see FIXME for resume below) */
+	if (sub_lv && !suspend_lv(sub_lv->vg->cmd, sub_lv))
+		return_0;
+
 	if (!vg_commit(mirrored_seg->lv->vg)) {
 		resume_lv(cmd, mirrored_seg->lv);
 		return 0;
@@ -674,6 +678,42 @@
 	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
 
 	/*
+	 * FIXME:
+When an image is split from a 2-way mirror, the original mirror is converted to
+a linear device.  To do this, the top "layer" must be removed.  The segments
+are transferred from the sub-lv to the top-level LV and the link is severed. 
+The former sub-lv - having its segments transferred - now contains a temporary
+error target.
+
+When the original LV is resumed, the old sub-lv that now contains an error
+segment is activated and scanned.  This causes I/O error messages.  There are
+three ways to fix this problem:
+
+1) Do not set the sub-lv which contains the error target as "visible" before
+suspending the original LV.  This way, when the original is resumed, the sub-lv
+device node is not created and it is not scanned - avoiding the error messages.
+ The problem with this approach is that if the machine crashes after the
+resume, it leaves the *hidden* LV in place and the user has a more difficult
+time noticing that it needs to be cleaned up.  Thus, this type of processing is
+frowned upon.
+
+2) Do like _remove_mirror_images does and suspend the original, then suspend
+the sub-lv (the error target), then resume the sub-lv, and finally resume the
+original LV.  This seems like extra pointless operations to me, but it does not
+produce the error message (although, I'm not sure why) and it allows us to
+leave the visible flag in place.  ** THIS IS THE CHOSEN SOLUTION HERE **
+
+3) Flag the sub-lv (error target) with a "do not scan" flag.  This seems like
+the cleanest approach, but I have been unable to find the method for doing
+this.  LVs get tagged in such a way by _get_udev_flags, but in this case the
+resume of the original LV also resumes the error target LV without running it
+through _get_udev_flags (likely because they are no longer linked).  Could
+there be something wrong in resume_lv?
+	*/
+	if (sub_lv && !resume_lv(sub_lv->vg->cmd, sub_lv))
+		return_0;
+
+	/*
 	 * Resume the mirror - this also activates the visible, independent
 	 *                     soon-to-be-split sub-LVs
 	 */


