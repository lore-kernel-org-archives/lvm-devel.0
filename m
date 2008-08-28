From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 11:09:59 -0000
Subject: LVM2/test t-vgcreate-usage.sh
Message-ID: <20080828110959.31629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 11:09:58

Modified files:
	test           : t-vgcreate-usage.sh 

Log message:
	add vgcreate rejects repeated invocation test
	add vgcreate fails when the only pv has --metadatacopies 0 test
	(by Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-vgcreate-usage.sh	2008/04/10 01:06:48	1.3
+++ LVM2/test/t-vgcreate-usage.sh	2008/08/28 11:09:58	1.4
@@ -18,15 +18,19 @@
 {
   test -n "$d1" && losetup -d "$d1"
   test -n "$d2" && losetup -d "$d2"
-  rm -f "$f1" "$f2"
+  test -n "$d3" && losetup -d "$d3"
+  rm -f "$f1" "$f2" "$f3"
 }
 
 test_expect_success \
   'set up temp files, loopback devices, PVs, vgname' \
   'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
    f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
    vg=$(this_test_)-test-vg-$$            &&
-   pvcreate $d1 $d2'
+   pvcreate $d1 $d2                       &&
+   pvcreate --metadatacopies 0 $d3
+'
 
 lv=vgcreate-usage-$$
 
@@ -79,13 +83,31 @@
    status=$?; echo status=$status; test $status = 3 &&
    grep "New volume group name \"$vg\" is invalid\$" err'
 
-# FIXME: Not sure why this fails
-#test_expect_success \
-#  'vgcreate rejects MaxLogicalVolumes > 255' \
-#  'vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $d1 $d2 2>err;
-#   cp err save;
-#   status=$?; echo status=$status; test $status = 3 &&
-#   grep "^  Number of volumes may not exceed 255\$" err'
+test_expect_success \
+  'cleanup vg name' '
+   vg=$(this_test_)-test-vg-$$
+'
+
+test_expect_success \
+  "vgcreate rejects repeated invocation (run  2 times)" '
+   vgcreate $vg $d1 $d2 && {
+     vgcreate $vg $d1 $d2;
+     status=$?; echo status=$status; test $status = 5 &&
+     vgremove -ff $vg
+   }
+'
+
+test_expect_success \
+  'vgcreate rejects MaxLogicalVolumes > 255' \
+  'vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $d1 $d2 2>err;
+   status=$?; echo status=$status; test $status = 3 &&
+   grep "^  Number of volumes may not exceed 255\$" err'
+
+test_expect_success \
+  "vgcreate fails when the only pv has --metadatacopies 0" '
+   vgcreate $vg $d3;
+   status=$?; echo status=$status; test $status = 5
+'
 
 test_done
 # Local Variables:


