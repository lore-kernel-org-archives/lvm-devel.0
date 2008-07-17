From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jul 2008 03:17:03 -0000
Subject: LVM2 ./WHATS_NEW test/t-pvcreate-usage.sh test ...
Message-ID: <20080717031703.22076.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-17 03:17:02

Modified files:
	.              : WHATS_NEW 
	test           : t-pvcreate-usage.sh t-vgsplit-usage.sh 
Added files:
	test           : t-pvcreate-operation.sh 

Log message:
	Update pvcreate and vgsplit tests.
	
	Add more pvcreate tests.
	Start handling lvm1 and lvm2 metadata and metadatacopies=0,1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.931&r2=1.932
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2008/07/16 21:32:38	1.931
+++ LVM2/WHATS_NEW	2008/07/17 03:16:59	1.932
@@ -1,6 +1,7 @@
 Version 2.02.40 - 
 ================================
-  Add pvcreate sanity tests, check for label_write() failure in _text_pv_write().
+  Check for label_write() failure in _text_pv_write().
+  Add pvcreate tests and update vgsplit tests to handle lvm1 and lvm2 metadata.
   Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.
   Cease recognising snapshot-in-use percentages returned by early devt kernels.
   Add backward-compatible flags field to on-disk format_text metadata.
/cvs/lvm2/LVM2/test/t-pvcreate-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pvcreate-operation.sh
+++ -	2008-07-17 03:17:02.366739000 +0000
@@ -0,0 +1,72 @@
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
+test_description='Test pvcreate logic operation'
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
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgname' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   vg1=$(this_test_)-test-vg1-$$'
+
+for mdatype in 1 2
+do
+test_expect_success \
+  "pvcreate (lvm$mdatype) fails when PV belongs to VG" \
+  'pvcreate -M$mdatype $d1 &&
+   vgcreate -M$mdatype $vg1 $d1 &&
+   pvcreate -M$mdatype $d1;
+   status=$?; echo status=$status; test $status != 0 &&
+   vgremove -f $vg1 &&
+   pvremove -f $d1'
+
+done
+
+test_expect_success \
+  'pvcreate (lvm2) fails when PV with metadatacopies=0 belongs to VG' \
+  'pvcreate --metadatacopies 0 $d1 &&
+   pvcreate --metadatacopies 1 $d2 &&
+   vgcreate $vg1 $d1 $d2 &&
+   pvcreate $d1;
+   status=$?; echo status=$status; test $status != 0 &&
+   vgremove -f $vg1 &&
+   pvremove -f $d2 &&
+   pvremove -f $d1'
+
+test_expect_success \
+  'pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG' \
+  'pvcreate --metadatacopies 0 $d1 &&
+   pvcreate --metadatacopies 1 $d2 &&
+   vgcreate $vg1 $d1 $d2 &&
+   pvcreate -ff -y $d1 &&
+   vgreduce --removemissing $vg1 &&
+   vgremove -ff $vg1 &&
+   pvremove -f $d2 &&
+   pvremove -f $d1'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/t-pvcreate-usage.sh	2008/07/16 21:32:38	1.1
+++ LVM2/test/t-pvcreate-usage.sh	2008/07/17 03:17:01	1.2
@@ -28,9 +28,9 @@
   'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
    f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4")'
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   vg1=$(this_test_)-test-vg1-$$'
 
-# x. negative setphysicalvolumesize, metadatasize
 test_expect_success \
   'pvcreate rejects negative setphysicalvolumesize' \
   'pvcreate --setphysicalvolumesize -1024 $d1;
@@ -57,13 +57,11 @@
 #  'pvcreate --metadatasize 100000000000000 $d1;
 #   status=$?; echo status=$status; test $status != 0'
 
-# x. metadatacopies < 0, defaults to 1
 test_expect_success \
   'pvcreate rejects metadatacopies < 0' \
   'pvcreate --metadatacopies -1 $d1;
    status=$?; echo status=$status; test $status != 0'
 
-# x. metadatacopies = 0, 1, 2 pass, > 2 fail
 test_expect_success \
   'pvcreate accepts metadatacopies = 0, 1, 2' \
   'pvcreate --metadatacopies 0 $d1 &&
@@ -76,19 +74,16 @@
    pvremove $d2 &&
    pvremove $d3'
 
-# x. metadatacopies > 2 fail
 test_expect_success \
   'pvcreate rejects metadatacopies > 2' \
-  'pvcreate --metadatacopies 3 $d1 &&
+  'pvcreate --metadatacopies 3 $d1;
    status=$?; echo status=$status; test $status != 0'
 
-# x. bogus device given
 test_expect_success \
   'pvcreate rejects invalid device' \
-  'pvcreate $d1bogus &&
+  'pvcreate $d1bogus;
    status=$?; echo status=$status; test $status != 0'
 
-# x. labelsector out of range (< 0 or > deviceSizeInSectors)
 test_expect_success \
   'pvcreate rejects labelsector < 0' \
   'pvcreate --labelsector -1 $d1;
--- LVM2/test/t-vgsplit-usage.sh	2008/04/10 19:59:43	1.5
+++ LVM2/test/t-vgsplit-usage.sh	2008/07/17 03:17:01	1.6
@@ -36,12 +36,17 @@
    vg2=$(this_test_)-test-vg2-$$          &&
    lv1=$(this_test_)-test-lv1-$$          &&
    lv2=$(this_test_)-test-lv2-$$          &&
-   lv3=$(this_test_)-test-lv3-$$          &&
-   pvcreate $d1 $d2 $d3 $d4'
+   lv3=$(this_test_)-test-lv3-$$'
 
+for mdatype in 1 2
+do
 test_expect_success \
-  'vgsplit accepts new vg as destination of split' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) setup PVs" \
+  'pvcreate -M$mdatype $d1 $d2 $d3 $d4'
+
+test_expect_success \
+  "(lvm$mdatype) vgsplit accepts new vg as destination of split" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    vgsplit $vg1 $vg2 $d1 1>err;
    status=$?; echo status=$status; test $status = 0 &&
    grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
@@ -49,9 +54,9 @@
    vgremove $vg2'
 
 test_expect_success \
-  'vgsplit accepts existing vg as destination of split' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit accepts existing vg as destination of split" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype $vg2 $d3 $d4 &&
    vgsplit $vg1 $vg2 $d1 1>err;
    status=$?; echo status=$status; test $status = 0 &&
    grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
@@ -59,25 +64,25 @@
    vgremove $vg2'
 
 test_expect_success \
-  'vgsplit accepts --maxphysicalvolumes 128 on new VG' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) vgsplit accepts --maxphysicalvolumes 128 on new VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $d1 &&
    check_vg_field_ $vg2 max_pv 128 &&
    vgremove $vg1 &&
    vgremove $vg2'
 
 test_expect_success \
-  'vgsplit accepts --maxlogicalvolumes 128 on new VG' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) vgsplit accepts --maxlogicalvolumes 128 on new VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $d1 &&
    check_vg_field_ $vg2 max_lv 128 &&
    vgremove $vg1 &&
    vgremove $vg2'
 
 test_expect_success \
-  'vgsplit rejects split because max_pv of destination would be exceeded' \
-  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because max_pv of destination would be exceeded" \
+  'vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
    grep "^  Maximum number of physical volumes (2) exceeded" err &&
@@ -85,9 +90,9 @@
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because maxphysicalvolumes given with existing vg' \
-  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because maxphysicalvolumes given with existing vg" \
+  'vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
@@ -95,9 +100,9 @@
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because maxlogicalvolumes given with existing vg' \
-  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because maxlogicalvolumes given with existing vg" \
+  'vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
@@ -105,9 +110,9 @@
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because alloc given with existing vg' \
-  'vgcreate --alloc cling $vg1 $d1 $d2 &&
-   vgcreate --alloc cling $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because alloc given with existing vg" \
+  'vgcreate -M$mdatype --alloc cling $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --alloc cling $vg2 $d3 $d4 &&
    vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
@@ -115,9 +120,9 @@
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because clustered given with existing vg' \
-  'vgcreate --clustered n $vg1 $d1 $d2 &&
-   vgcreate --clustered n $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because clustered given with existing vg" \
+  'vgcreate -M$mdatype --clustered n $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --clustered n $vg2 $d3 $d4 &&
    vgsplit --clustered n $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
@@ -125,22 +130,10 @@
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because metadata types differ' \
-  'pvcreate -ff -M1 $d3 $d4 &&
-   pvcreate -ff -M2 $d1 $d2 &&
-   vgcreate -M1 $vg1 $d3 $d4 &&
-   vgcreate -M2 $vg2 $d1 $d2 &&
-   vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Metadata types differ" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgsplit rejects vg with active lv' \
-  'pvcreate -ff -M2 $d3 $d4 &&
-   vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects vg with active lv" \
+  'pvcreate -ff -M$mdatype $d3 $d4 &&
+   vgcreate -M$mdatype $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype $vg2 $d3 $d4 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    vgsplit $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$status; test $status = 5 &&
@@ -149,9 +142,9 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because max_lv is exceeded' \
-  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because max_lv is exceeded" \
+  'vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    lvcreate -l 4 -n $lv2 $vg1 &&
    lvcreate -l 4 -n $lv3 $vg2 &&
@@ -164,8 +157,8 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  'verify default - max_lv attribute from new VG is same as source VG' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) vgsplit verify default - max_lv attribute from new VG is same as source VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 &&
@@ -174,8 +167,8 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  'verify default - max_pv attribute from new VG is same as source VG' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) vgsplit verify default - max_pv attribute from new VG is same as source VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 &&
@@ -184,8 +177,8 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  'verify default - vg_fmt attribute from new VG is same as source VG' \
-  'vgcreate $vg1 $d1 $d2 &&
+  "(lvm$mdatype) vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 &&
@@ -194,9 +187,9 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because PV not in VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+  "(lvm$mdatype) vgsplit rejects split because PV not in VG" \
+  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
+   vgcreate -M$mdatype $vg2 $d3 $d4 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    lvcreate -l 4 -n $lv2 $vg1 &&
    vgchange -an $vg1 &&
@@ -204,6 +197,19 @@
    status=$?; echo status=$status; test $status = 5 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
+done
+
+test_expect_success \
+  '(lvm2) vgsplit rejects split because metadata types differ' \
+  'pvcreate -ff -M1 $d3 $d4 &&
+   pvcreate -ff -M2 $d1 $d2 &&
+   vgcreate -M1 $vg1 $d3 $d4 &&
+   vgcreate -M2 $vg2 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d3 2>err;
+   status=$?; echo status=$status; test $status = 5 &&
+   grep "^  Metadata types differ" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
 
 test_done
 # Local Variables:


