From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Sep 2011 18:51:12 -0000
Subject: LVM2 tools/lvresize.c test/t-lvresize-rounding.sh
Message-ID: <20110915185112.31044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-09-15 18:51:11

Modified files:
	tools          : lvresize.c 
Added files:
	test           : t-lvresize-rounding.sh 

Log message:
	When resizing LVs, always round in the safe direction, regardless of whether we
	were called as lvresize or lvreduce.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-rounding.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

/cvs/lvm2/LVM2/test/t-lvresize-rounding.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvresize-rounding.sh
+++ -	2011-09-15 18:51:11.985248000 +0000
@@ -0,0 +1,25 @@
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
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
+
+aux prepare_vg 2
+
+lvcreate -l 10 -n lv -i2 $vg
+
+lvextend -l +1 $vg/lv 2>&1 | tee log
+grep 'down to stripe' log
+lvresize -l +1 $vg/lv 2>&1 | tee log
+grep 'down to stripe' log
+
+lvreduce -f -l -1 $vg/lv 2>&1 | tee log
+grep 'up to stripe' log
+lvresize -f -l -1 $vg/lv 2>&1 | tee log
+grep 'up to stripe' log
--- LVM2/tools/lvresize.c	2011/09/15 15:26:40	1.136
+++ LVM2/tools/lvresize.c	2011/09/15 18:51:11	1.137
@@ -606,7 +606,8 @@
 			stripesize_extents = 1;
 
 		size_rest = seg_size % (lp->stripes * stripesize_extents);
-		if (size_rest && lp->resize == LV_REDUCE) {
+		/* Round toward the original size. */
+		if (size_rest && lp->extents < lv->le_count) {
 			log_print("Rounding size (%d extents) up to stripe "
 				  "boundary size for segment (%d extents)",
 				  lp->extents, lp->extents - size_rest +


