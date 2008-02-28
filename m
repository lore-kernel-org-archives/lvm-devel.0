From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Feb 2008 17:39:47 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080228173947.17567.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-28 17:39:47

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Fix t-vgsplit-operation.sh lv2-3 definitions to include test signature.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-vgsplit-operation.sh	2008/02/28 16:48:09	1.8
+++ LVM2/test/t-vgsplit-operation.sh	2008/02/28 17:39:47	1.9
@@ -35,6 +35,8 @@
    vg1=$(this_test_)-test-vg1-$$          &&
    vg2=$(this_test_)-test-vg2-$$          &&
    lv1=$(this_test_)-test-lv1-$$          &&
+   lv2=$(this_test_)-test-lv2-$$          &&
+   lv3=$(this_test_)-test-lv3-$$          &&
    pvcreate $d1 $d2 $d3 $d4'
 
 test_expect_success \
@@ -151,8 +153,8 @@
   'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n lv2 $vg1 &&
-   lvcreate -l 4 -n lv3 $vg2 &&
+   lvcreate -l 4 -n $lv2 $vg1 &&
+   lvcreate -l 4 -n $lv3 $vg2 &&
    vgchange -an $vg1 &&
    vgchange -an $vg2 &&
    vgsplit $vg1 $vg2 $d1 2>err;


