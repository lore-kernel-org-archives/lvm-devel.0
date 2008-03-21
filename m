From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Mar 2008 21:14:39 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080321211439.6299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-21 21:14:39

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Update vgsplit tests to execute twice (existing and new VG as destination).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/t-vgsplit-operation.sh	2008/03/04 22:49:00	1.12
+++ LVM2/test/t-vgsplit-operation.sh	2008/03/21 21:14:38	1.13
@@ -23,7 +23,7 @@
   rm -f "$f1" "$f2" "$f3" "$f4"
 }
 
-validate_vg_pvlv_counts_()
+vg_validate_pvlv_counts_()
 {
 	local local_vg=$1
 	local num_pvs=$2
@@ -51,53 +51,83 @@
    lv3=$(this_test_)-test-lv3-$$          &&
    pvcreate $d1 $d2 $d3 $d4'
 
+#
+# vgsplit can be done into a new or existing VG
+#
+for i in new existing
+do
 test_expect_success \
-  'vgsplit correctly splits single linear LV into existing VG' \
+  "vgsplit correctly splits single linear LV into $i VG" \
   'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+   if [ $i == existing ]; then
+      vgcreate $vg2 $d3 $d4
+   fi &&
    lvcreate -l 4 -n $lv1 $vg1 $d1 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 &&
-   validate_vg_pvlv_counts_ $vg1 1 0 0 &&
-   validate_vg_pvlv_counts_ $vg2 3 1 0 &&
+   vgsplit --force $vg1 $vg2 $d1 &&
+   vg_validate_pvlv_counts_ $vg1 1 0 0 &&
+   if [ $i == existing ]; then
+      vg_validate_pvlv_counts_ $vg2 3 1 0
+   else
+      vg_validate_pvlv_counts_ $vg2 1 1 0
+   fi &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
 
 test_expect_success \
-  'vgsplit correctly splits single striped LV into existing VG' \
+  "vgsplit correctly splits single striped LV into $i VG" \
   'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+   if [ $i == existing ]; then
+      vgcreate $vg2 $d3 $d4
+   fi &&
    lvcreate -l 4 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 &&
-   validate_vg_pvlv_counts_ $vg2 4 1 0 &&
+   vgsplit --force $vg1 $vg2 $d1 $d2 &&
+   if [ $i == existing ]; then
+     vg_validate_pvlv_counts_ $vg2 4 1 0
+   else
+     vg_validate_pvlv_counts_ $vg2 2 1 0
+   fi &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
 test_expect_success \
-  'vgsplit correctly splits origin and snapshot LV into existing VG' \
+  "vgsplit correctly splits origin and snapshot LV into $i VG" \
   'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
+   if [ $i == existing ]; then
+     vgcreate $vg2 $d3 $d4
+   fi &&
    lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 &&
-   validate_vg_pvlv_counts_ $vg2 4 1 1 &&
+   vgsplit --force $vg1 $vg2 $d1 $d2 &&
+   if [ $i == existing ]; then
+     vg_validate_pvlv_counts_ $vg2 4 1 1
+   else
+     vg_validate_pvlv_counts_ $vg2 2 1 1
+   fi &&
    lvremove -f $vg2/$lv2 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
 test_expect_success \
-  'vgsplit correctly splits mirror LV into existing VG' \
+  "vgsplit correctly splits mirror LV into $i VG" \
   'vgcreate $vg1 $d1 $d2 $d3 &&
-   vgcreate $vg2 $d4 &&
+   if [ $i == existing ]; then
+     vgcreate $vg2 $d4
+   fi &&
    lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 $d3 &&
-   validate_vg_pvlv_counts_ $vg2 4 4 0 &&
+   vgsplit --force $vg1 $vg2 $d1 $d2 $d3 &&
+   if [ $i == existing ]; then
+     vg_validate_pvlv_counts_ $vg2 4 4 0
+   else
+     vg_validate_pvlv_counts_ $vg2 3 4 0
+   fi &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
+done
 
 test_done
 # Local Variables:


