From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Apr 2008 14:47:34 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgsplit-operation.sh
Message-ID: <20080409144734.749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-09 14:47:34

Modified files:
	.              : WHATS_NEW 
	test           : t-vgsplit-operation.sh 

Log message:
	Update vgsplit tests for lvnames on the cmdline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.839&r2=1.840
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2008/04/09 14:39:55	1.839
+++ LVM2/WHATS_NEW	2008/04/09 14:47:34	1.840
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Update vgsplit tests for lvnames on the cmdline.
   Update vgsplit man page to reflect lvnames on the cmdline.
   Update vgsplit to take "-n LogicalVolumeName" on the cmdline.
   Use clustered mirror log with pvmove in clustered VGs, if available.
--- LVM2/test/t-vgsplit-operation.sh	2008/03/21 22:00:29	1.14
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/09 14:47:34	1.15
@@ -56,15 +56,24 @@
 #
 for i in new existing
 do
+#
+# We can have PVs or LVs on the cmdline
+#
+for j in PV LV
+do
 test_expect_success \
-  "vgsplit correctly splits single linear LV into $i VG" \
+  "vgsplit correctly splits single linear LV into $i VG ($j args)" \
   'vgcreate $vg1 $d1 $d2 &&
    if [ $i == existing ]; then
       vgcreate $vg2 $d3 $d4
    fi &&
    lvcreate -l 4 -n $lv1 $vg1 $d1 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d1
+   else
+     vgsplit -n $lv1 $vg1 $vg2
+   fi &&
    vg_validate_pvlv_counts_ $vg1 1 0 0 &&
    if [ $i == existing ]; then
       vg_validate_pvlv_counts_ $vg2 3 1 0
@@ -76,14 +85,18 @@
    vgremove -f $vg1'
 
 test_expect_success \
-  "vgsplit correctly splits single striped LV into $i VG" \
+  "vgsplit correctly splits single striped LV into $i VG ($j args)" \
   'vgcreate $vg1 $d1 $d2 &&
    if [ $i == existing ]; then
       vgcreate $vg2 $d3 $d4
    fi &&
    lvcreate -l 4 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d1 $d2
+   else
+     vgsplit -n $lv1 $vg1 $vg2
+   fi &&
    if [ $i == existing ]; then
      vg_validate_pvlv_counts_ $vg2 4 1 0
    else
@@ -93,43 +106,121 @@
    vgremove -f $vg2'
 
 test_expect_success \
-  "vgsplit correctly splits origin and snapshot LV into $i VG" \
-  'vgcreate $vg1 $d1 $d2 &&
+  "vgsplit correctly splits mirror LV into $i VG ($j args)" \
+  'vgcreate $vg1 $d1 $d2 $d3 &&
    if [ $i == existing ]; then
-     vgcreate $vg2 $d3 $d4
+     vgcreate $vg2 $d4
    fi &&
-   lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
-   lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
+   lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d1 $d2 $d3
+   else
+     vgsplit -n $lv1 $vg1 $vg2
+   fi &&
    if [ $i == existing ]; then
-     vg_validate_pvlv_counts_ $vg2 4 1 1
+     vg_validate_pvlv_counts_ $vg2 4 4 0
    else
-     vg_validate_pvlv_counts_ $vg2 2 1 1
+     vg_validate_pvlv_counts_ $vg2 3 4 0
    fi &&
-   lvremove -f $vg2/$lv2 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
 test_expect_success \
-  "vgsplit correctly splits mirror LV into $i VG" \
-  'vgcreate $vg1 $d1 $d2 $d3 &&
+  "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" \
+  'vgcreate $vg1 $d1 $d2 &&
    if [ $i == existing ]; then
-     vgcreate $vg2 $d4
+     vgcreate $vg2 $d3 $d4
    fi &&
-   lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
+   lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 $d2 $d3 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d1 $d2
+   else
+     vgsplit -n $lv1 $vg1 $vg2
+   fi &&
    if [ $i == existing ]; then
-     vg_validate_pvlv_counts_ $vg2 4 4 0
+     vg_validate_pvlv_counts_ $vg2 4 1 1
    else
-     vg_validate_pvlv_counts_ $vg2 3 4 0
+     vg_validate_pvlv_counts_ $vg2 2 1 1
    fi &&
+   lvremove -f $vg2/$lv2 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
+
+done
 done
 
+#
+# Test more complex setups where the code has to find associated PVs and
+# LVs to split the VG correctly
+# 
+test_expect_success \
+  "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 -i 2 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv2 -i 2 $vg1 $d2 $d3 &&
+   lvcreate -l 4 -n $lv3 -i 2 $vg1 $d3 $d4 &&
+   vgchange -an $vg1 &&
+   vgsplit -n $lv1 $vg1 $vg2;
+   status=$?; echo status=$?; test $status = 5 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv2 -s $vg1/$lv1 &&
+   lvcreate -l 4 -n $lv3 -s $vg1/$lv1 &&
+   vg_validate_pvlv_counts_ $vg1 4 1 2 &&
+   vgchange -an $vg1 &&
+   vgsplit -n $lv1 $vg1 $vg2;
+   status=$?; echo status=$?; test $status = 5 &&
+   lvremove -f $vg1/$lv2 &&
+   lvremove -f $vg1/$lv3 &&
+   lvremove -f $vg1/$lv1 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv2 -s $vg1/$lv1 &&
+   lvcreate -l 4 -n $lv3 -s $vg1/$lv1 &&
+   vg_validate_pvlv_counts_ $vg1 4 1 2 &&
+   vgchange -an $vg1 &&
+   vgsplit -n $lv2 $vg1 $vg2;
+   status=$?; echo status=$?; test $status = 5 &&
+   lvremove -f $vg1/$lv2 &&
+   lvremove -f $vg1/$lv3 &&
+   lvremove -f $vg1/$lv1 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit fails splitting one mirror LV, only one PV specified" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 -m1 $vg1 $d1 $d2 $d3 &&
+   vg_validate_pvlv_counts_ $vg1 4 4 0 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d2 &&
+   status=$?; echo status=$?; test $status = 5 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 -m1 $vg1 $d1 $d2 $d3 &&
+   lvcreate -l 16 -n $lv2 -i 2 $vg1 $d3 $d4 &&
+   vg_validate_pvlv_counts_ $vg1 4 5 0 &&
+   vgchange -an $vg1 &&
+   vgsplit -n $lv2 $vg1 $vg2 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   vgremove -ff $vg1'
+
+
 test_done
+
 # Local Variables:
 # indent-tabs-mode: nil
 # End:


