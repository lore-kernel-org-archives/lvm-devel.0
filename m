From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Mar 2008 19:48:32 -0000
Subject: LVM2/test t-vgsplit-operation.sh t-vgsplit-usa ...
Message-ID: <20080304194832.7074.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-04 19:48:32

Modified files:
	test           : t-vgsplit-operation.sh 
Added files:
	test           : t-vgsplit-usage.sh 

Log message:
	Update vgsplit tests.
	- Divide into 'usage' and 'operation' tests.
	- Add operation tests for specific LV types.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

/cvs/lvm2/LVM2/test/t-vgsplit-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgsplit-usage.sh
+++ -	2008-03-04 19:48:32.575367000 +0000
@@ -0,0 +1,182 @@
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
+test_description='Test vgsplit command options for validity'
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
+# FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
+# fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
+# metadata
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
+  'vgsplit accepts new vg as destination of split' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d1 1>err;
+   status=$?; echo status=$?; test $status = 0 &&
+   grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts existing vg as destination of split' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   vgsplit $vg1 $vg2 $d1 1>err;
+   status=$?; echo status=$?; test $status = 0 &&
+   grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts --maxphysicalvolumes 128 on new VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $d1 &&
+   check_vg_field_ $vg2 max_pv 128 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts --maxlogicalvolumes 128 on new VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $d1 &&
+   check_vg_field_ $vg2 max_lv 128 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit rejects split because max_pv of destination would be exceeded' \
+  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of physical volumes (2) exceeded" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because maxphysicalvolumes given with existing vg' \
+  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+   vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because maxlogicalvolumes given with existing vg' \
+  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+   vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because alloc given with existing vg' \
+  'vgcreate --alloc cling $vg1 $d1 $d2 &&
+   vgcreate --alloc cling $vg2 $d3 $d4 &&
+   vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because clustered given with existing vg' \
+  'vgcreate --clustered n $vg1 $d1 $d2 &&
+   vgcreate --clustered n $vg2 $d3 $d4 &&
+   vgsplit --clustered n $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because metadata types differ' \
+  'pvcreate -ff -M1 $d3 $d4 &&
+   pvcreate -ff -M2 $d1 $d2 &&
+   vgcreate -M1 $vg1 $d3 $d4 &&
+   vgcreate -M2 $vg2 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d3 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Metadata types differ" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects vg with active lv' \
+  'pvcreate -ff -M2 $d3 $d4 &&
+   vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because max_lv is exceeded' \
+  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   lvcreate -l 4 -n $lv2 $vg1 &&
+   lvcreate -l 4 -n $lv3 $vg2 &&
+   vgchange -an $vg1 &&
+   vgchange -an $vg2 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of logical volumes (2) exceeded" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because PV not in VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   lvcreate -l 4 -n $lv2 $vg1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d3 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Physical volume $d3 not in volume group $vg1" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/t-vgsplit-operation.sh	2008/02/29 00:09:21	1.10
+++ LVM2/test/t-vgsplit-operation.sh	2008/03/04 19:48:32	1.11
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Exercise some vgsplit diagnostics'
+test_description='Test vgsplit operation, including different LV types'
 privileges_required_=1
 
 . ./test-lib.sh
@@ -40,141 +40,47 @@
    pvcreate $d1 $d2 $d3 $d4'
 
 test_expect_success \
-  'vgsplit accepts new vg as destination of split' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$?; test $status = 0 &&
-   grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  'vgsplit accepts existing vg as destination of split' \
+  'vgsplit correctly splits single linear LV into existing VG' \
   'vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$?; test $status = 0 &&
-   grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
-   vgremove $vg1 &&
-   vgremove $vg2'
+   lvcreate -l 4 -n $lv1 $vg1 $d1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   lvremove -f $vg2/$lv1 &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
 
 test_expect_success \
-  'vgsplit accepts --maxphysicalvolumes 128 on new VG' \
+  'vgsplit correctly splits single striped LV into existing VG' \
   'vgcreate $vg1 $d1 $d2 &&
-   vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $d1 &&
-   check_vg_field_ $vg2 max_pv 128 &&
-   vgremove $vg1 &&
-   vgremove $vg2'
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -i 2 -n $lv1 $vg1 $d1 $d2 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d1 $d2 &&
+   lvremove -f $vg2/$lv1 &&
+   vgremove -f $vg2'
 
 test_expect_success \
-  'vgsplit accepts --maxlogicalvolumes 128 on new VG' \
+  'vgsplit correctly splits origin and snapshot LV into existing VG' \
   'vgcreate $vg1 $d1 $d2 &&
-   vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $d1 &&
-   check_vg_field_ $vg2 max_lv 128 &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  'vgsplit rejects split because max_pv of destination would be exceeded' \
-  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Maximum number of physical volumes (2) exceeded" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because maxphysicalvolumes given with existing vg' \
-  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because maxlogicalvolumes given with existing vg' \
-  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because alloc given with existing vg' \
-  'vgcreate --alloc cling $vg1 $d1 $d2 &&
-   vgcreate --alloc cling $vg2 $d3 $d4 &&
-   vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because clustered given with existing vg' \
-  'vgcreate --clustered n $vg1 $d1 $d2 &&
-   vgcreate --clustered n $vg2 $d3 $d4 &&
-   vgsplit --clustered n $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because metadata types differ' \
-  'pvcreate -ff -M1 $d3 $d4 &&
-   pvcreate -ff -M2 $d1 $d2 &&
-   vgcreate -M1 $vg1 $d3 $d4 &&
-   vgcreate -M2 $vg2 $d1 $d2 &&
-   vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Metadata types differ" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects vg with active lv' \
-  'pvcreate -ff -M2 $d3 $d4 &&
-   vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  'vgsplit rejects split because max_lv is exceeded' \
-  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n $lv2 $vg1 &&
-   lvcreate -l 4 -n $lv3 $vg2 &&
+   lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
-   vgchange -an $vg2 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Maximum number of logical volumes (2) exceeded" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
+   vgsplit $vg1 $vg2 $d1 $d2 &&
+   lvremove -f $vg2/$lv2 &&
+   lvremove -f $vg2/$lv1 &&
+   vgremove -f $vg2'
 
 test_expect_success \
-  'vgsplit rejects split because PV not in VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n $lv2 $vg1 &&
+  'vgsplit correctly splits mirror LV into existing VG' \
+  'vgcreate $vg1 $d1 $d2 $d3 &&
+   vgcreate $vg2 $d4 &&
+   lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Physical volume $d3 not in volume group $vg1" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
+   vgsplit $vg1 $vg2 $d1 $d2 $d3 &&
+   lvremove -f $vg2/$lv1 &&
+   vgremove -f $vg2'
 
 test_done
 # Local Variables:


