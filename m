From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 15:20:10 -0000
Subject: LVM2/test t-vgsplit-usage.sh test-utils.sh
Message-ID: <20080930152010.28715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 15:20:09

Modified files:
	test           : t-vgsplit-usage.sh test-utils.sh 

Log message:
	Convert t-vgsplit-usage.sh to use the new test-utils.sh. Original conversion by
	jstava. Lvm1 testing restored by mornfall.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-vgsplit-usage.sh	2008/08/28 10:59:10	1.9
+++ LVM2/test/t-vgsplit-usage.sh	2008/09/30 15:20:09	1.10
@@ -9,228 +9,171 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test vgsplit command options for validity'
-privileges_required_=1
+# Test vgsplit command options for validity
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  test -n "$d5" && losetup -d "$d5"
-  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
-}
+aux prepare_devs 5
 
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgnames' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
-   vg1=$(this_test_)-test-vg1-$$          &&
-   vg2=$(this_test_)-test-vg2-$$          &&
-   lv1=$(this_test_)-test-lv1-$$          &&
-   lv2=$(this_test_)-test-lv2-$$          &&
-   lv3=$(this_test_)-test-lv3-$$'
 
 for mdatype in 1 2
 do
-test_expect_success \
-  "(lvm$mdatype) setup PVs" \
-  'pvcreate -M$mdatype $d1 $d2 $d3 $d4'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit accepts new vg as destination of split" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$status; test $status = 0 &&
-   grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit accepts existing vg as destination of split" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$status; test $status = 0 &&
-   grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit accepts --maxphysicalvolumes 128 on new VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $d1 &&
-   check_vg_field_ $vg2 max_pv 128 &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit accepts --maxlogicalvolumes 128 on new VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $d1 &&
-   check_vg_field_ $vg2 max_lv 128 &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because max_pv of destination would be exceeded" \
-  'vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Maximum number of physical volumes (2) exceeded" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because maxphysicalvolumes given with existing vg" \
-  'vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because maxlogicalvolumes given with existing vg" \
-  'vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because alloc given with existing vg" \
-  'vgcreate -M$mdatype --alloc cling $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --alloc cling $vg2 $d3 $d4 &&
-   vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because clustered given with existing vg" \
-  'vgcreate -M$mdatype --clustered n $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --clustered n $vg2 $d3 $d4 &&
-   vgsplit --clustered n $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects vg with active lv" \
-  'pvcreate -ff -M$mdatype $d3 $d4 &&
-   vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because max_lv is exceeded" \
-  'vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n $lv2 $vg1 &&
-   lvcreate -l 4 -n $lv3 $vg2 &&
-   vgchange -an $vg1 &&
-   vgchange -an $vg2 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Maximum number of logical volumes (2) exceeded" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit verify default - max_lv attribute from new VG is same as source VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 &&
-   compare_vg_field_ $vg1 $vg2 max_lv &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit verify default - max_pv attribute from new VG is same as source VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 &&
-   compare_vg_field_ $vg1 $vg2 max_pv &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d1 &&
-   compare_vg_field_ $vg1 $vg2 vg_fmt &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  "(lvm$mdatype) vgsplit rejects split because PV not in VG" \
-  'vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgcreate -M$mdatype $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n $lv2 $vg1 &&
-   vgchange -an $vg1 &&
-   vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
+
+pvcreate -M$mdatype $devs
+
+# vgsplit accepts new vg as destination of split
+vgcreate -M$mdatype $vg1 $devs
+vgsplit $vg1 $vg2 $dev1 1>err
+grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgremove $vg1 
+vgremove $vg2
+
+# vgsplit accepts existing vg as destination of split
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+vgsplit $vg1 $vg2 $dev1 1>err
+grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgremove $vg1 
+vgremove $vg2
+
+# vgsplit accepts --maxphysicalvolumes 128 on new VG
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $dev1 
+check_vg_field_ $vg2 max_pv 128 
+vgremove $vg1 
+vgremove $vg2
+
+# vgsplit accepts --maxlogicalvolumes 128 on new VG
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $dev1 
+check_vg_field_ $vg2 max_lv 128 
+vgremove $vg1 
+vgremove $vg2
+
+# vgsplit rejects split because max_pv of destination would be exceeded
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Maximum number of physical volumes (2) exceeded" err
+vgremove $vg2
+vgremove $vg1
+
+# vgsplit rejects split because maxphysicalvolumes given with existing vg
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+not vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $dev1 2>err;
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg2 
+vgremove $vg1
+
+# vgsplit rejects split because maxlogicalvolumes given with existing vg
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+not vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $dev1 2>err
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg2 
+vgremove $vg1
+
+# vgsplit rejects split because alloc given with existing vg" \
+vgcreate -M$mdatype --alloc cling $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --alloc cling $vg2 $dev3 $dev4 
+not vgsplit --alloc cling $vg1 $vg2 $dev1 2>err;
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg2 
+vgremove $vg1
+
+# vgsplit rejects split because clustered given with existing vg" \
+vgcreate -M$mdatype --clustered n $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --clustered n $vg2 $dev3 $dev4 
+not vgsplit --clustered n $vg1 $vg2 $dev1 2>err
+grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgremove $vg2 
+vgremove $vg1
+
+# vgsplit rejects vg with active lv" \
+pvcreate -M$mdatype -ff $dev3 $dev4 
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Logical volumes in \"$vg1\" must be inactive\$" err 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# vgsplit rejects split because max_lv is exceeded" \
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg1 
+lvcreate -l 4 -n $lv3 $vg2 
+vgchange -an $vg1 
+vgchange -an $vg2 
+not vgsplit $vg1 $vg2 $dev1 2>err;
+grep "^  Maximum number of logical volumes (2) exceeded" err 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# vgsplit verify default - max_lv attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+compare_vg_field_ $vg1 $vg2 max_lv 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# vgsplit verify default - max_pv attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+compare_vg_field_ $vg1 $vg2 max_pv 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+lvcreate -l 4 -n $lv1 $vg1 
+vgchange -an $vg1 
+vgsplit $vg1 $vg2 $dev1 
+compare_vg_field_ $vg1 $vg2 vg_fmt 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# vgsplit rejects split because PV not in VG" \
+vgcreate -M$mdatype $vg1 $dev1 $dev2 
+vgcreate -M$mdatype $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg1 
+vgchange -an $vg1 
+not vgsplit $vg1 $vg2 $dev3 2>err;
+vgremove -f $vg2 
+vgremove -f $vg1
 done
 
-test_expect_success \
-  "(lvm2) setup PVs" '
-   pvcreate -M$mdatype --metadatacopies 0 $d5'
-
-test_expect_success \
-  "(lvm2) vgsplit rejects to give away pv with the last mda copy" '
-   vgcreate -M2 $vg1 $d5 $d2  &&
-   lvcreate -l 10 -n $lv1  $vg1 &&
-   lvchange -an $vg1/$lv1 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   { vgsplit  $vg1 $vg2 $d5;
-     status=$?; echo status=$status; test $status != 0 &&
-     vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-     vgremove -ff $vg1
-   }
-'
-
-test_expect_success \
-  '(lvm2) vgsplit rejects split because metadata types differ' \
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
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# ONLY LVM2 metadata
+# setup PVs" '
+pvcreate --metadatacopies 0 $dev5
+
+# vgsplit rejects to give away pv with the last mda copy
+vgcreate $vg1 $dev5 $dev2  
+lvcreate -l 10 -n $lv1  $vg1 
+lvchange -an $vg1/$lv1 
+vg_validate_pvlv_counts_ $vg1 2 1 0 
+not vgsplit  $vg1 $vg2 $dev5;
+vg_validate_pvlv_counts_ $vg1 2 1 0 
+vgremove -ff $vg1
+
+# vgsplit rejects split because metadata types differ
+pvcreate -ff -M1 $dev3 $dev4 
+pvcreate -ff $dev1 $dev2 
+vgcreate -M1 $vg1 $dev3 $dev4 
+vgcreate $vg2 $dev1 $dev2 
+not vgsplit $vg1 $vg2 $dev3 2>err;
+grep "^  Metadata types differ" err 
+vgremove $vg2 
+vgremove $vg1
+
--- LVM2/test/test-utils.sh	2008/09/29 15:59:19	1.1
+++ LVM2/test/test-utils.sh	2008/09/30 15:20:09	1.2
@@ -87,6 +87,7 @@
     lv=LV
     lv1=LV1
     lv2=LV2
+    lv3=LV3
 }
 
 disable_dev() {


