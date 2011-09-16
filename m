From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Sep 2011 09:59:43 -0000
Subject: LVM2 lib/metadata/lv_manip.c test/t-lvcreate-s ...
Message-ID: <20110916095943.957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-09-16 09:59:43

Modified files:
	lib/metadata   : lv_manip.c 
Added files:
	test           : t-lvcreate-striped-mirror.sh 

Log message:
	Fix the divisibility check in the allocator for the mirror+stripe case (require
	divisibility by stripe count alone, not by (mirror*stripe)).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.285&r2=1.286
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-striped-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/lib/metadata/lv_manip.c	2011/09/14 14:20:16	1.285
+++ LVM2/lib/metadata/lv_manip.c	2011/09/16 09:59:42	1.286
@@ -1917,10 +1917,11 @@
 		return 1;
 	}
 
-	if (ah->area_multiple > 1 &&
-	    (ah->new_extents - alloc_state.allocated) % ah->area_count) {
+        if (ah->area_multiple > 1 &&
+            (ah->new_extents - alloc_state.allocated) % ah->area_multiple) {
 		log_error("Number of extents requested (%d) needs to be divisible by %d.",
-			  ah->new_extents - alloc_state.allocated, ah->area_count);
+			  ah->new_extents - alloc_state.allocated,
+			  ah->area_multiple);
 		return 0;
 	}
 
/cvs/lvm2/LVM2/test/t-lvcreate-striped-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-striped-mirror.sh
+++ -	2011-09-16 09:59:43.392905000 +0000
@@ -0,0 +1,65 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+aux prepare_vg 9
+
+lvcreate -i2 -l2 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i2 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l3 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+
+lvcreate -i2 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l3 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i2 -l2 -m3 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+lvcreate -i3 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (2 extents) up to .* (3 extents)" log
+lvremove -ff $vg
+
+lvcreate -i3 -l4 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (4 extents) up to .* (6 extents)" log
+lvremove -ff $vg
+
+lvcreate -i3 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+grep "Rounding size (4 extents) up to .* (6 extents)" log
+lvremove -ff $vg
+
+lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+not grep "Rounding" log
+lvremove -ff $vg


