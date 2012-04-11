From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:40:06 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20120411124006.755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:40:04

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Fix lvresize for thin pool
	
	When resizing thin pool - we need to use strip info from  _tdata volume.
	In future more generic solution will be necessary once we start to support
	lvconvert (resize of stacked devices and stay properly aligned).
	For now we just allow striped or linear LV so this code will work.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2380&r2=1.2381
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2012/04/11 12:36:37	1.2380
+++ LVM2/WHATS_NEW	2012/04/11 12:40:03	1.2381
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix lvresize of thin pool for stipped devices.
   For lvresize round upward when specifying number of extents.
   For lvcreate with %FREE support rounding downward strip alignment.
   Change message severity to log_very_verbose for missing dev info in udev db.
--- LVM2/tools/lvresize.c	2012/04/11 12:36:38	1.153
+++ LVM2/tools/lvresize.c	2012/04/11 12:40:04	1.154
@@ -590,7 +590,10 @@
 	if ((lp->extents > lv->le_count) &&
 	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
 		/* FIXME Don't assume mirror seg will always be AREA_LV */
-		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments : &lv->segments) {
+		/* FIXME We will need to support resize for metadata LV as well,
+		 *       and data LV could be any type (i.e. mirror)) */
+		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
+				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
 			if (!seg_is_striped(seg))
 				continue;
 
@@ -739,13 +742,6 @@
 			log_warn("Thin pool volumes do not have filesystem.");
 			lp->resizefs = 0;
 		}
-
-		if (!lp->stripes) {
-			/* Try to use the same strip settings for underlying pool data LV */
-			lp->stripes = last_seg(seg_lv(first_seg(lv), 0))->area_count;
-			if (!lp->stripe_size)
-				lp->stripe_size = last_seg(seg_lv(first_seg(lv), 0))->stripe_size;
-		}
 	}
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)


