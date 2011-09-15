From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Sep 2011 15:26:41 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c tools/lvresi ...
Message-ID: <20110915152641.20268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-15 15:26:40

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c lvresize.c toollib.c tools.h 
Added files:
	test           : t-lvcreate-large.sh 

Log message:
	Fix possible overflow of size if %FREE or %VG is used.
	
	https://bugzilla.redhat.com/show_bug.cgi?id=737087

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2110&r2=1.2111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-large.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/WHATS_NEW	2011/09/14 18:20:03	1.2110
+++ LVM2/WHATS_NEW	2011/09/15 15:26:40	1.2111
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix possible overflow of size if %FREE or %VG is used.
   Fix vgchange activation of snapshot with virtual origin.
   Activate virtual snapshot origin exclusively (only on local node in cluster).
   Fix lv_mirror_count to handle mirrored stripes properly.
/cvs/lvm2/LVM2/test/t-lvcreate-large.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-large.sh
+++ -	2011-09-15 15:26:41.117437000 +0000
@@ -0,0 +1,40 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+aux prepare_vg 4
+
+lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
+
+#FIXME this should be 1024T
+#check lv_field $vg/$lv size "128.00m"
+
+aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+
+pvcreate $DM_DEV_DIR/$vg/$lv
+vgcreate $vg1 $DM_DEV_DIR/$vg/$lv
+
+lvcreate -l 100%FREE -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "1024.00t"
+lvresize -f -l 72%VG $vg1/$lv1
+check lv_field $vg1/$lv1 size "737.28t"
+lvremove -ff $vg1/$lv1
+
+lvcreate -l 100%VG -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "1024.00t"
+lvresize -f -l 72%VG $vg1/$lv1
+check lv_field $vg1/$lv1 size "737.28t"
+lvremove -ff $vg1/$lv1
+
+lvremove -ff $vg/$lv
\ No newline at end of file
--- LVM2/tools/lvcreate.c	2011/09/08 16:41:19	1.240
+++ LVM2/tools/lvcreate.c	2011/09/15 15:26:40	1.241
@@ -250,17 +250,17 @@
 
 	switch(lcp->percent) {
 		case PERCENT_VG:
-			lp->extents = lp->extents * vg->extent_count / 100;
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count);
 			break;
 		case PERCENT_FREE:
-			lp->extents = lp->extents * vg->free_count / 100;
+			lp->extents = percent_of_extents(lp->extents, vg->free_count);
 			break;
 		case PERCENT_PVS:
 			if (!lcp->pv_count)
-				lp->extents = lp->extents * vg->extent_count / 100;
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count);
 			else {
 				pv_extent_count = pv_list_extents_free(lp->pvh);
-				lp->extents = lp->extents * pv_extent_count / 100;
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count);
 			}
 			break;
 		case PERCENT_LV:
@@ -278,7 +278,7 @@
 				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
 				return 0;
 			}
-			lp->extents = lp->extents * origin->le_count / 100;
+			lp->extents = percent_of_extents(lp->extents, origin->le_count);
 			break;
 		case PERCENT_NONE:
 			break;
--- LVM2/tools/lvresize.c	2011/09/06 00:26:43	1.135
+++ LVM2/tools/lvresize.c	2011/09/15 15:26:40	1.136
@@ -433,27 +433,27 @@
 
 	switch(lp->percent) {
 		case PERCENT_VG:
-			lp->extents = lp->extents * vg->extent_count / 100;
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count);
 			break;
 		case PERCENT_FREE:
-			lp->extents = lp->extents * vg->free_count / 100;
+			lp->extents = percent_of_extents(lp->extents, vg->free_count);
 			break;
 		case PERCENT_LV:
-			lp->extents = lp->extents * lv->le_count / 100;
+			lp->extents = percent_of_extents(lp->extents, lv->le_count);
 			break;
 		case PERCENT_PVS:
 			if (lp->argc) {
 				pv_extent_count = pv_list_extents_free(pvh);
-				lp->extents = lp->extents * pv_extent_count / 100;
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count);
 			} else
-				lp->extents = lp->extents * vg->extent_count / 100;
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count);
 			break;
 		case PERCENT_ORIGIN:
 			if (!lv_is_cow(lv)) {
 				log_error("Specified LV does not have an origin LV.");
 				return EINVALID_CMD_LINE;
 			}
-			lp->extents = lp->extents * origin_from_cow(lv)->le_count / 100;
+			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count);
 			break;
 		case PERCENT_NONE:
 			break;
--- LVM2/tools/toollib.c	2011/09/07 08:41:48	1.230
+++ LVM2/tools/toollib.c	2011/09/15 15:26:40	1.231
@@ -1623,3 +1623,9 @@
 
 	return 1;
 }
+
+/* Return percents of extents and avoid overflow */
+uint32_t percent_of_extents(uint32_t percents, uint32_t count)
+{
+	return (uint32_t)((uint64_t)percents * (uint64_t)count / 100);
+}
--- LVM2/tools/tools.h	2011/07/08 19:42:11	1.76
+++ LVM2/tools/tools.h	2011/09/15 15:26:40	1.77
@@ -181,4 +181,5 @@
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
+uint32_t percent_of_extents(uint32_t percents, uint32_t count);
 #endif


