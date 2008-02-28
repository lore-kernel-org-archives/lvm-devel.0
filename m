From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Feb 2008 16:48:11 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080228164811.6385.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-28 16:48:11

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Fix t-vgsplit-operation.sh lv1 definition to include test signature.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-vgsplit-operation.sh	2008/01/22 03:30:14	1.7
+++ LVM2/test/t-vgsplit-operation.sh	2008/02/28 16:48:09	1.8
@@ -34,6 +34,7 @@
    f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
    vg1=$(this_test_)-test-vg1-$$          &&
    vg2=$(this_test_)-test-vg2-$$          &&
+   lv1=$(this_test_)-test-lv1-$$          &&
    pvcreate $d1 $d2 $d3 $d4'
 
 test_expect_success \
@@ -138,7 +139,7 @@
   'pvcreate -ff -M2 $d3 $d4 &&
    vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n lv1 $vg1 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
    vgsplit $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$?; test $status = 5 &&
    grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
@@ -149,7 +150,7 @@
   'vgsplit rejects split because max_lv is exceeded' \
   'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n lv1 $vg1 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
    lvcreate -l 4 -n lv2 $vg1 &&
    lvcreate -l 4 -n lv3 $vg2 &&
    vgchange -an $vg1 &&


