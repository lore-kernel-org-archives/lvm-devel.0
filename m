From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Mar 2008 18:03:36 -0000
Subject: LVM2 test/t-vgmerge-usage.sh ./WHATS_NEW test/ ...
Message-ID: <20080326180336.7455.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-26 18:03:35

Modified files:
	test           : t-vgmerge-usage.sh 
	.              : WHATS_NEW 
Added files:
	test           : t-vgmerge-operation.sh 

Log message:
	Add vgmerge tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.809&r2=1.810

/cvs/lvm2/LVM2/test/t-vgmerge-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgmerge-operation.sh
+++ -	2008-03-26 18:03:35.831011000 +0000
@@ -0,0 +1,107 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test vgmerge operation'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  rm -f "$f1" "$f2" "$f3" "$f4"
+}
+
+vg_validate_pvlv_counts_()
+{
+	local local_vg=$1
+	local num_pvs=$2
+	local num_lvs=$3
+	local num_snaps=$4
+
+	check_vg_field_ $local_vg pv_count $num_pvs &&
+	check_vg_field_ $local_vg lv_count $num_lvs &&
+	check_vg_field_ $local_vg snap_count $num_snaps
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgnames' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   vg1=$(this_test_)-test-vg1-$$          &&
+   vg2=$(this_test_)-test-vg2-$$          &&
+   lv1=$(this_test_)-test-lv1-$$          &&
+   lv2=$(this_test_)-test-lv2-$$          &&
+   lv3=$(this_test_)-test-lv3-$$          &&
+   pvcreate $d1 $d2 $d3 $d4'
+
+test_expect_success \
+  'vgmerge succeeds with single linear LV in source VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 $d1 &&
+   vgchange -an $vg1 &&
+   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
+   vg_validate_pvlv_counts_ $vg2 2 0 0 &&
+   vgmerge $vg2 $vg1 &&
+   vg_validate_pvlv_counts_ $vg2 4 1 0 &&
+   vgremove -f $vg2'
+
+test_expect_success \
+  'vgmerge succeeds with single linear LV in source and destination VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   lvcreate -l 4 -n $lv2 $vg2 &&
+   vgchange -an $vg1 &&
+   vgchange -an $vg2 &&
+   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
+   vg_validate_pvlv_counts_ $vg2 2 1 0 &&
+   vgmerge $vg2 $vg1 &&
+   vg_validate_pvlv_counts_ $vg2 4 2 0 &&
+   vgremove -f $vg2'
+
+test_expect_success \
+  'vgmerge succeeds with linear LV + snapshots in source VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 $vg1 &&
+   lvcreate -l 4 -s -n $lv2 $vg1/$lv1 &&
+   vgchange -an $vg1 &&
+   vg_validate_pvlv_counts_ $vg1 2 1 1 &&
+   vg_validate_pvlv_counts_ $vg2 2 0 0 &&
+   vgmerge $vg2 $vg1 &&
+   vg_validate_pvlv_counts_ $vg2 4 1 1 &&
+   lvremove -f $vg2/$lv2 &&
+   vgremove -f $vg2'
+
+test_expect_success \
+  'vgmerge succeeds with mirrored LV in source VG' \
+  'vgcreate $vg1 $d1 $d2 $d3 &&
+   vgcreate $vg2 $d4 &&
+   lvcreate -l 4 -n $lv1 -m1 $vg1 &&
+   vgchange -an $vg1 &&
+   vg_validate_pvlv_counts_ $vg1 3 4 0 &&
+   vg_validate_pvlv_counts_ $vg2 1 0 0 &&
+   vgmerge $vg2 $vg1 &&
+   vg_validate_pvlv_counts_ $vg2 4 4 0 &&
+   lvremove -f $vg2/$lv1 &&
+   vgremove -f $vg2'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/t-vgmerge-usage.sh	2008/01/16 21:21:22	1.2
+++ LVM2/test/t-vgmerge-usage.sh	2008/03/26 18:03:35	1.3
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Exercise some vgmerge diagnostics'
+test_description='Test vgmerge command options for validity'
 privileges_required_=1
 
 . ./test-lib.sh
--- LVM2/WHATS_NEW	2008/03/26 16:48:09	1.809
+++ LVM2/WHATS_NEW	2008/03/26 18:03:35	1.810
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add vgmerge tests.
   Add pvseg_is_allocated() for identifying a PV segment allocated to a LV.
   Add list_move() for moving elements from one list to another.
   Add 'is_reserved_lvname()' for identifying hidden LVs.


