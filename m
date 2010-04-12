From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2010 19:16:25 -0000
Subject: LVM2/test t-lvconvert-mirror.sh t-lvcreate-mir ...
Message-ID: <20100412191625.30453.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-12 19:16:25

Added files:
	test           : t-lvconvert-mirror.sh t-lvcreate-mirror.sh 
	                 t-lvresize-mirror.sh t-lvchange-mirror.sh 
Removed files:
	test           : t-mirror-basic.sh 

Log message:
	Explode t-mirror-basic into a number of smaller tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvchange-mirror.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.9&r2=NONE

/cvs/lvm2/LVM2/test/t-lvconvert-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror.sh
+++ -	2010-04-12 19:16:25.320603000 +0000
@@ -0,0 +1,57 @@
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
+. ./test-utils.sh
+aux prepare_vg 5 80
+
+# convert from linear to 2-way mirror
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# convert from 2-way mirror to linear
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -m-1 $vg/$lv1
+check linear $vg $lv1
+lvremove -ff $vg
+
+# convert from disklog to corelog, active
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -f --mirrorlog core $vg/$lv1
+check mirror $vg $lv1 ""
+lvremove -ff $vg
+
+# convert from corelog to disklog, active
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# bz192865: lvconvert log of an inactive mirror lv
+# convert from disklog to corelog, inactive
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+echo y | lvconvert -f --mirrorlog core $vg/$lv1
+check mirror $vg $lv1 ""
+lvremove -ff $vg
+
+# convert from corelog to disklog, inactive
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvchange -an $vg/$lv1
+lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# convert linear to 2-way mirror with 1 PV
+lvcreate -l2 -n $lv1 $vg $dev1
+not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/t-lvcreate-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-mirror.sh
+++ -	2010-04-12 19:16:25.407102000 +0000
@@ -0,0 +1,39 @@
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
+. ./test-utils.sh
+aux prepare_vg 5 80
+
+# 2-way mirror with corelog, 2 PVs
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check mirror_images_redundant $vg $lv1
+lvremove -ff $vg
+
+# 2-way mirror with disklog, 3 PVs
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check mirror_images_redundant $vg $lv1
+check mirror_log_on $vg/$lv1 $dev3
+lvremove -ff $vg
+
+# 3-way mirror with disklog, 4 PVs
+lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+check mirror_images_redundant $vg $lv1
+check mirror_log_on $vg/$lv1 $dev3
+lvremove -ff $vg
+
+# lvcreate --nosync is in 100% sync after creation (bz429342)
+lvcreate -l2 -m1 --nosync -n $lv1 $vg $dev1 $dev2 $dev3:0-1 2>out
+grep "New mirror won't be synchronised." out
+lvs -o copy_percent --noheadings $vg/$lv1 | grep 100.00
+lvremove -ff $vg
+
+# creating 2-way mirror with disklog from 2 PVs fails
+not lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2
/cvs/lvm2/LVM2/test/t-lvresize-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvresize-mirror.sh
+++ -	2010-04-12 19:16:25.487661000 +0000
@@ -0,0 +1,38 @@
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
+. ./test-utils.sh
+aux prepare_vg 5 80
+
+# extend 2-way mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+lvextend -l+2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+check mirror_images_contiguous $vg $lv1
+lvremove -ff $vg
+
+# reduce 2-way mirror
+lvcreate -l4 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+lvreduce -l-2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# extend 2-way mirror (cling if not contiguous)
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l1 -n $lv2 $vg $dev1
+lvcreate -l1 -n $lv3 $vg $dev2
+lvchange -an $vg/$lv1
+lvextend -l+2 $vg/$lv1
+check mirror $vg $lv1 $dev3
+check mirror_images_clung $vg $lv1
+lvremove -ff $vg
/cvs/lvm2/LVM2/test/t-lvchange-mirror.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvchange-mirror.sh
+++ -	2010-04-12 19:16:25.569964000 +0000
@@ -0,0 +1,28 @@
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
+. ./test-utils.sh
+aux prepare_vg 3
+
+# force resync 2-way active mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check mirror $vg $lv1 $dev3
+echo y | lvchange --resync $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg
+
+# force resync 2-way inactive mirror
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvchange -an $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvchange --resync $vg/$lv1
+check mirror $vg $lv1 $dev3
+lvremove -ff $vg


