From: agk@sourceware.org <agk@sourceware.org>
Date: 16 May 2012 12:50:17 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120516125017.8063.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-16 12:50:16

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
	- The test should be checking the LV as a whole, not just individual segments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2405&r2=1.2406
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.278&r2=1.279

--- LVM2/WHATS_NEW	2012/05/14 16:18:58	1.2405
+++ LVM2/WHATS_NEW	2012/05/16 12:50:14	1.2406
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
   Fix alloc cling to cling to PVs already found with contiguous policy.
   Fix cling policy not to behave like normal policy if no previous LV seg.
   Fix allocation loop not to use later policies when --alloc cling without tags.
--- LVM2/lib/activate/dev_manager.c	2012/04/24 00:51:26	1.278
+++ LVM2/lib/activate/dev_manager.c	2012/05/16 12:50:15	1.279
@@ -1581,22 +1581,6 @@
 				  seg->lv->vg->name, seg->lv->name);
 			return 0;
 		}
-
-		/*
-		 * Mirrors activate LVs replaced with error targets and
-		 * RAID can handle non-accessible sub-LVs.
-		 *
-		 * TODO: Can we eventually skip to activate such LVs ?
-		 */
-		if (!num_existing_areas &&
-		    !strstr(seg->lv->name, "_rmeta_") &&
-		    !strstr(seg->lv->name, "_rimage_") &&
-		    !strstr(seg->lv->name, "_mimage_") &&
-		    !((name = strstr(seg->lv->name, "_mlog")) && !name[5])) {
-			log_error("Cannot activate %s/%s: all segments missing.",
-				  seg->lv->vg->name, seg->lv->name);
-			return 0;
-		}
 	}
 
 	return 1;


