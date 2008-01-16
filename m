From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 22:54:50 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20080116225450.12998.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 22:54:50

Modified files:
	tools          : lvconvert.c 

Log message:
	another lvconvert fix

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/tools/lvconvert.c	2008/01/16 19:40:42	1.56
+++ LVM2/tools/lvconvert.c	2008/01/16 22:54:49	1.57
@@ -509,7 +509,7 @@
 
 	if (lp->mirrors == existing_mirrors) {
 		original_lv = _original_lv(lv);
-		if (!seg->log_lv && !corelog) {
+		if (!first_seg(original_lv)->log_lv && !corelog) {
 			if (!add_mirror_log(cmd, original_lv, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
@@ -517,7 +517,7 @@
 							lp->region_size),
 					    lp->pvh, lp->alloc))
 				return_0;
-		} else if (seg->log_lv && corelog) {
+		} else if (first_seg(original_lv)->log_lv && corelog) {
 			if (!remove_mirror_log(cmd, original_lv,
 					       lp->pv_count ? lp->pvh : NULL))
 				return_0;


