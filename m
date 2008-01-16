From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:40:43 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20080116194043.25273.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:40:43

Modified files:
	tools          : lvconvert.c 

Log message:
	fix to earlier checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/tools/lvconvert.c	2008/01/16 19:16:48	1.55
+++ LVM2/tools/lvconvert.c	2008/01/16 19:40:42	1.56
@@ -540,7 +540,7 @@
 		 * linear-to-mirror conversion.
 		 */
 		original_lv = _original_lv(lv);
-		if (!seg->log_lv && !corelog) {
+		if (!first_seg(original_lv)->log_lv && !corelog) {
 			if (!add_mirror_log(cmd, original_lv, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
@@ -548,7 +548,7 @@
 							lp->region_size),
 					    lp->pvh, lp->alloc))
 				return_0;
-		} else if (seg->log_lv && corelog) {
+		} else if (first_seg(original_lv)->log_lv && corelog) {
 			if (!remove_mirror_log(cmd, original_lv,
 					       lp->pv_count ? lp->pvh : NULL))
 				return_0;


