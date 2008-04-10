From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 18:55:41 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080410185541.19230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 18:55:41

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Update vgsplit tests that count LVs for adjusted LV counting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/test/t-vgsplit-operation.sh	2008/04/10 01:06:48	1.18
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/10 18:55:40	1.19
@@ -121,9 +121,9 @@
      vgsplit -n $lv1 $vg1 $vg2
    fi &&
    if [ $i == existing ]; then
-     vg_validate_pvlv_counts_ $vg2 4 4 0
+     vg_validate_pvlv_counts_ $vg2 4 1 0
    else
-     vg_validate_pvlv_counts_ $vg2 3 4 0
+     vg_validate_pvlv_counts_ $vg2 3 1 0
    fi &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
@@ -143,9 +143,9 @@
      vgsplit -n $lv1 $vg1 $vg2
    fi &&
    if [ $i == existing ]; then
-     vg_validate_pvlv_counts_ $vg2 4 1 1
+     vg_validate_pvlv_counts_ $vg2 4 2 1
    else
-     vg_validate_pvlv_counts_ $vg2 2 1 1
+     vg_validate_pvlv_counts_ $vg2 2 2 1
    fi &&
    lvremove -f $vg2/$lv2 &&
    lvremove -f $vg2/$lv1 &&
@@ -169,10 +169,10 @@
    fi &&
    if [ $i == existing ]; then
      vg_validate_pvlv_counts_ $vg2 2 1 0
-     vg_validate_pvlv_counts_ $vg1 2 1 1
+     vg_validate_pvlv_counts_ $vg1 2 2 1
    else
      vg_validate_pvlv_counts_ $vg2 1 1 0
-     vg_validate_pvlv_counts_ $vg1 2 1 1
+     vg_validate_pvlv_counts_ $vg1 2 2 1
    fi &&
    lvremove -f $vg1/$lv2 &&
    lvremove -f $vg1/$lv1 &&
@@ -196,10 +196,10 @@
      vgsplit -n $lv2 $vg1 $vg2
    fi &&
    if [ $i == existing ]; then
-     vg_validate_pvlv_counts_ $vg1 3 4 0
+     vg_validate_pvlv_counts_ $vg1 3 2 0
      vg_validate_pvlv_counts_ $vg2 2 1 0
    else
-     vg_validate_pvlv_counts_ $vg1 3 4 0
+     vg_validate_pvlv_counts_ $vg1 3 2 0
      vg_validate_pvlv_counts_ $vg2 1 1 0
    fi &&
    lvremove -f $vg1/$lv1 &&
@@ -231,7 +231,7 @@
    lvcreate -l 16 -n $lv1 $vg1 $d1 $d2 &&
    lvcreate -l 4 -n $lv2 -s $vg1/$lv1 &&
    lvcreate -l 4 -n $lv3 -s $vg1/$lv1 &&
-   vg_validate_pvlv_counts_ $vg1 4 1 2 &&
+   vg_validate_pvlv_counts_ $vg1 4 3 2 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv1 $vg1 $vg2;
    status=$?; echo status=$status; test $status = 5 &&
@@ -246,7 +246,7 @@
    lvcreate -l 16 -n $lv1 $vg1 $d1 $d2 &&
    lvcreate -l 4 -n $lv2 -s $vg1/$lv1 &&
    lvcreate -l 4 -n $lv3 -s $vg1/$lv1 &&
-   vg_validate_pvlv_counts_ $vg1 4 1 2 &&
+   vg_validate_pvlv_counts_ $vg1 4 3 2 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv2 $vg1 $vg2;
    status=$?; echo status=$status; test $status = 5 &&
@@ -270,7 +270,7 @@
   'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
    lvcreate -l 16 -n $lv1 -m1 $vg1 $d1 $d2 $d3 &&
    lvcreate -l 16 -n $lv2 -i 2 $vg1 $d3 $d4 &&
-   vg_validate_pvlv_counts_ $vg1 4 5 0 &&
+   vg_validate_pvlv_counts_ $vg1 4 2 0 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv2 $vg1 $vg2 2>err;
    status=$?; echo status=$status; test $status = 5 &&


