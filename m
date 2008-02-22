From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2008 13:28:30 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20080222132830.15811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-22 13:28:29

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.797&r2=1.798
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2008/02/22 13:22:44	1.797
+++ LVM2/WHATS_NEW	2008/02/22 13:28:29	1.798
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV. (2.02.30)
   Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)
   Add missing no-longer-used segs_using_this_lv test to check_lv_segments.
   Remove redundant non-NULL tests before calling free in clvmd.c.
--- LVM2/lib/metadata/mirror.c	2008/01/31 12:19:35	1.69
+++ LVM2/lib/metadata/mirror.c	2008/02/22 13:28:29	1.70
@@ -504,6 +504,8 @@
 	 * to remove the layer. */
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
+		lv1->status &= ~MIRROR_IMAGE;
+		lv1->status |= VISIBLE_LV;
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;


