From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Apr 2008 21:10:13 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080409211013.6627.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-09 21:10:13

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Add vgsplit tests to verify mirror is not moved unnecessarily.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/t-vgsplit-operation.sh	2008/04/09 20:56:06	1.16
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/09 21:10:13	1.17
@@ -20,7 +20,8 @@
   test -n "$d2" && losetup -d "$d2"
   test -n "$d3" && losetup -d "$d3"
   test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
+  test -n "$d5" && losetup -d "$d5"
+  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
 }
 
 vg_validate_pvlv_counts_()
@@ -44,12 +45,13 @@
    f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
    f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
    vg1=$(this_test_)-test-vg1-$$          &&
    vg2=$(this_test_)-test-vg2-$$          &&
    lv1=$(this_test_)-test-lv1-$$          &&
    lv2=$(this_test_)-test-lv2-$$          &&
    lv3=$(this_test_)-test-lv3-$$          &&
-   pvcreate $d1 $d2 $d3 $d4'
+   pvcreate $d1 $d2 $d3 $d4 $d5'
 
 #
 # vgsplit can be done into a new or existing VG
@@ -178,6 +180,33 @@
    vgremove -f $vg1 &&
    vgremove -f $vg2'
 
+test_expect_success \
+  "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" \
+  'vgcreate $vg1 $d1 $d2 $d3 &&
+   if [ $i == existing ]; then
+     vgcreate $vg2 $d5
+   fi &&
+   lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
+   vgextend $vg1 $d4 &&
+   lvcreate -l 64 -n $lv2 $vg1 $d4 &&
+   vgchange -an $vg1 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d4
+   else
+     vgsplit -n $lv2 $vg1 $vg2
+   fi &&
+   if [ $i == existing ]; then
+     vg_validate_pvlv_counts_ $vg1 3 4 0
+     vg_validate_pvlv_counts_ $vg2 2 1 0
+   else
+     vg_validate_pvlv_counts_ $vg1 3 4 0
+     vg_validate_pvlv_counts_ $vg2 1 1 0
+   fi &&
+   lvremove -f $vg1/$lv1 &&
+   lvremove -f $vg2/$lv2 &&
+   vgremove -f $vg1 &&
+   vgremove -f $vg2'
+
 done
 done
 


