From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Sep 2008 16:12:25 -0000
Subject: LVM2/test t-vgreduce-usage.sh
Message-ID: <20080919161225.10883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-19 16:12:25

Modified files:
	test           : t-vgreduce-usage.sh 

Log message:
	Add more vgreduce tests. (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-vgreduce-usage.sh	2008/08/28 11:20:49	1.2
+++ LVM2/test/t-vgreduce-usage.sh	2008/09/19 16:12:25	1.3
@@ -35,8 +35,6 @@
    lv2=$(this_test_)-test-lv2-$$          &&
    lv3=$(this_test_)-test-lv3-$$'
 
-#TODO --removemissing (+ -- mirrorsonly)
-
 for mdatype in 1 2
 do
 test_expect_success \
@@ -72,7 +70,7 @@
 
 test_expect_success \
   "(lvm$mdatype) remove PVs " '
-  pvremove -ff $d1 $d2 
+   pvremove -ff $d1 $d2 
 '
 done
 
@@ -80,8 +78,8 @@
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs (--metadatacopies 0)" '
-  pvcreate -M$mdatype $d1 $d2 &&
-  pvcreate --metadatacopies 0 -M$mdatype $d3 $d4
+   pvcreate -M$mdatype $d1 $d2 &&
+   pvcreate --metadatacopies 0 -M$mdatype $d3 $d4
 '
 
 test_expect_success \
@@ -92,6 +90,64 @@
      vgremove -f $vg1
    }
 '
+
+test_expect_success \
+  "cleanup" '
+   vgremove -ff $vg1; true
+'
+test_expect_success \
+  "(lvm$mdatype) setup: create mirror & damage one pv" '
+   vgcreate -M$mdatype $vg1 $d1 $d2 $d3 &&
+   lvcreate -n $lv1 -m1 -l 16 $vg1 &&
+   lvcreate -n $lv2  -l 16 $vg1 $d2 &&
+   lvcreate -n $lv3 -l 16 $vg1 $d3 &&
+   vgchange -an $vg1 &&
+   pvcreate -ff -y $d1 
+'
+test_expect_success \
+  "(lvm$mdatype) vgreduce --removemissing --force repares to linear" '
+   vgreduce --removemissing --force $vg1 &&
+   check_lv_field_ $vg1/$lv1 segtype linear &&
+   vg_validate_pvlv_counts_ $vg1 2 3 0
+'
+test_expect_success \
+  "cleanup" '
+   vgremove -ff $vg1
+'
+
+test_expect_success \
+  "(lvm$mdatype) setup: create mirror + linear lvs" '
+   vgcreate -M$mdatype $vg1 $d1 &&
+   lvcreate -n $lv2 -l 16 $vg1 &&
+   lvcreate -n $lv1 -l 4 $vg1 &&
+   vgextend $vg1 $d2 $d3 &&
+   lvcreate -n $lv3 -l 16 $vg1 $d3 &&
+   lvconvert -m1 $vg1/$lv1
+'
+test_debug '
+   pvs --segments -o +lv_name
+'
+test_expect_success \
+  "(lvm$mdatype) setup: damage one pv" '
+   vgchange -an $vg1 &&
+   pvcreate -ff -y $d1 
+'
+test_expect_failure \
+  "(lvm$mdatype) vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too" '
+    vgreduce --removemissing --mirrorsonly --force $vg1
+'
+
+test_debug '
+   pvs -P
+   lvs -P
+   vgs -P
+'
+
+test_expect_success \
+  "cleanup" '
+   vgreduce --removemissing --force $vg1
+   vgremove -ff $vg1
+'
 done
 
 


