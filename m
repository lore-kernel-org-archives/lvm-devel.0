From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 13:42:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091119134239.26005.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 13:42:39

Modified files:
	lib/metadata   : mirror.c 

Log message:
	The double resume in remove_mirror_images does not happen *always*. Only call
	memlock_inc() when it actually does happen.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/lib/metadata/mirror.c	2009/11/19 12:09:53	1.94
+++ LVM2/lib/metadata/mirror.c	2009/11/19 13:42:38	1.95
@@ -608,21 +608,24 @@
 	 * As it's now detached from mirrored_seg->lv we must resume it
 	 * explicitly.
 	 */
-	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
-		log_error("Problem resuming temporary LV, %s", lv1->name);
-		return 0;
-	}
+	if (lv1) {
+		if (!resume_lv(lv1->vg->cmd, lv1)) {
+			log_error("Problem resuming temporary LV, %s", lv1->name);
+			return 0;
+		}
 
-	/*
-	 * The code above calls a suspend_lv once, however we now need to
-	 * resume 2 LVs, due to image removal: the mirror image itself above,
-	 * and now the remaining mirror LV. Since suspend_lv/resume_lv call
-	 * memlock_inc/memlock_dec and these need to be balanced, we need to
-	 * call an extra memlock_inc() here to balance for the second resume,
-	 * which could otherwise either deadlock due to suspended devices, or
-	 * alternatively drop memlock_count below 0.
-	 */
-	memlock_inc();
+		/*
+		 * The code above calls a suspend_lv once, however we now need
+		 * to resume 2 LVs, due to image removal: the mirror image
+		 * itself here, and now the remaining mirror LV. Since
+		 * suspend_lv/resume_lv call memlock_inc/memlock_dec and these
+		 * need to be balanced, we need to call an extra memlock_inc()
+		 * here to balance for the this extra resume -- the following
+		 * one could otherwise either deadlock due to suspended
+		 * devices, or alternatively drop memlock_count below 0.
+		 */
+		memlock_inc();
+	}
 
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Problem reactivating %s", mirrored_seg->lv->name);


