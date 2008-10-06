From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 Oct 2008 16:47:08 -0000
Subject: LVM2/test t-covercmd.sh t-mirror-names.sh t-pv ...
Message-ID: <20081006164708.15825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-10-06 16:47:07

Modified files:
	test           : t-covercmd.sh t-mirror-names.sh 
	                 t-pv-range-overflow.sh t-pvchange-usage.sh 
	                 t-pvcreate-metadata0.sh t-pvcreate-usage.sh 
	                 t-pvmove-basic.sh t-read-ahead.sh 
	                 t-vgcreate-usage.sh t-vgmerge-operation.sh 
	                 t-vgmerge-usage.sh 

Log message:
	More test conversions by jstava. Make check still passes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-covercmd.sh	2008/09/29 16:02:50	1.4
+++ LVM2/test/t-covercmd.sh	2008/10/06 16:47:07	1.5
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -22,7 +22,7 @@
   esac
 }
 
-prepare_devs 5
+aux prepare_devs 5
 
 pvcreate $dev1
 pvcreate --metadatacopies 0 $dev2
--- LVM2/test/t-mirror-names.sh	2008/01/31 12:19:36	1.1
+++ LVM2/test/t-mirror-names.sh	2008/10/06 16:47:07	1.2
@@ -11,53 +11,15 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="check namings of mirrored LV"
-privileges_required_=1
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ ||
-{
-  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
-  say "Skipping this test"
-  exit 0
-}
-
-cleanup_()
-{
-  test -n "$vg" && {
-    lvremove -ff $vg
-    vgremove $vg
-  } > /dev/null
-  test -n "$pvs" && {
-    pvremove $pvs > /dev/null
-    for d in $pvs; do
-      dmsetup remove $(basename $d)
-    done
-  }
-  losetup -d $lodev
-  rm -f $lofile
-}
-
-# ---------------------------------------------------------------------
-# config
-
-nr_pvs=5
-pvsize=$((80 * 1024 * 2))
-
-vg=mirror-names-vg-$$
-lv1=lv1
-lv2=lv2
+dmsetup_has_dm_devdir_support_ || exit 200
 
 # ---------------------------------------------------------------------
 # Utilities
 
-pv_()
-{
-  echo "$G_dev_/mapper/pv$1"
-}
-
-lv_devices_()
-{
+lv_devices_() {
   local d
   local lv=$1
   shift
@@ -74,15 +36,13 @@
   [ "$(echo $devices | sed 's/ //g')" = "" ]
 }
 
-lv_mirror_log_()
-{
+lv_mirror_log_() {
   local lv=$1
 
   echo $(lvs -a -omirror_log --noheadings $lv | sed 's/ //g')
 }
 
-lv_convert_lv_()
-{
+lv_convert_lv_() {
   local lv=$1
 
   echo $(lvs -a -oconvert_lv --noheadings $lv | sed 's/ //g')
@@ -91,111 +51,90 @@
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-test_expect_success \
-  'set up temp file and loopback device' \
-  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
-
-offset=0
-pvs=
-for n in $(seq 1 $nr_pvs); do
-  test_expect_success \
-      "create pv$n" \
-      'echo "0 $pvsize linear $lodev $offset" > in &&
-       dmsetup create pv$n < in'
-  offset=$(($offset + $pvsize))
-done
-
-for n in $(seq 1 $nr_pvs); do
-  pvs="$pvs $(pv_ $n)"
-done
-
-test_expect_success \
-  "Run this: pvcreate $pvs" \
-  'pvcreate $pvs'
-
-test_expect_success \
-  'set up a VG' \
-  'vgcreate $vg $pvs'
+aux prepare_vg 5 80
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
-prepare_lvs_()
-{
+prepare_lvs_() {
   lvremove -ff $vg;
   :
 }
 
-check_and_cleanup_lvs_()
-{
-  lvs -a -o+devices $vg &&
+check_and_cleanup_lvs_() {
+  lvs -a -o+devices $vg 
   lvremove -ff $vg
 }
 
-test_expect_success "check environment setup/cleanup" \
-  'prepare_lvs_ &&
-   check_and_cleanup_lvs_'
+prepare_lvs_ 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # basic
 
-test_expect_success "init: lvcreate" "prepare_lvs_"
+#COMM "init: lvcreate" 
+prepare_lvs_
 
-test_expect_success "mirror images are ${lv1}_mimage_x" \
-  'lvcreate -l2 -m1 -n $lv1 $vg &&
-   lv_devices_ $vg/$lv1 "$lv1"_mimage_0 "$lv1"_mimage_1'
+#COMM "mirror images are ${lv1}_mimage_x"
+lvcreate -l2 -m1 -n $lv1 $vg 
+lv_devices_ $vg/$lv1 "$lv1"_mimage_0 "$lv1"_mimage_1
 
-test_expect_success "mirror log is ${lv1}_mlog" \
-  'lv_mirror_log_ $vg/$lv1 "$lv1"_mlog'
+#COMM "mirror log is ${lv1}_mlog"
+lv_mirror_log_ $vg/$lv1 "$lv1"_mlog
 
-test_expect_success "cleanup" "check_and_cleanup_lvs_"
+#COMM "cleanup" 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # lvrename
 
-test_expect_success "init: lvrename" "prepare_lvs_"
+#COMM "init: lvrename" 
+prepare_lvs_
 
-test_expect_success "renamed mirror names: $lv1 to $lv2" \
-  'lvcreate -l2 -m1 -n $lv1 $vg &&
-   lvrename $vg/$lv1 $vg/$lv2 &&
-   lv_devices_ $vg/$lv2 "$lv2"_mimage_0 "$lv2"_mimage_1 &&
-   lv_mirror_log_ $vg/$lv2 "$lv2"_mlog'
+#COMM "renamed mirror names: $lv1 to $lv2" 
+lvcreate -l2 -m1 -n $lv1 $vg 
+lvrename $vg/$lv1 $vg/$lv2 
+lv_devices_ $vg/$lv2 "$lv2"_mimage_0 "$lv2"_mimage_1 
+lv_mirror_log_ $vg/$lv2 "$lv2"_mlog
 
-test_expect_success "cleanup" "check_and_cleanup_lvs_"
+#COMM "cleanup" 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # lvconvert
 
-test_expect_success "init: lvconvert" "prepare_lvs_"
+#COMM "init: lvconvert" 
+prepare_lvs_
 
-test_expect_success "converting mirror names is ${lv1}_mimagetmp_2" \
-  'lvcreate -l2 -m1 -n $lv1 $vg &&
-   lvconvert -m+1 -i1000 -b $vg/$lv1 &&
-   convlv=$(lv_convert_lv_ "$vg/$lv1") &&
-   test "$convlv" = "$lv1"_mimagetmp_2 &&
-   lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 &&
-   lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 &&
-   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
-   test "$loglv" = "$lv1"_mlog'
-
-test_expect_success "mirror log name after re-adding is ${lv1}_mlog" \
-  'lvconvert --mirrorlog core $vg/$lv1 &&
-   lvconvert --mirrorlog disk $vg/$lv1 &&
-   convlv=$(lv_convert_lv_ "$vg/$lv1") &&
-   lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 &&
-   lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 &&
-   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
-   test "$loglv" = "$lv1"_mlog'
-
-test_expect_success "renamed converting mirror names: $lv1 to $lv2" \
-  'lvrename $vg/$lv1 $vg/$lv2 &&
-   convlv=$(lv_convert_lv_ "$vg/$lv2") &&
-   lv_devices_ $vg/$lv2 "$convlv" "$lv2"_mimage_2 &&
-   lv_devices_ "$vg/$convlv" "$lv2"_mimage_0 "$lv2"_mimage_1 &&
-   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
-   test "$loglv" = "$lv2"_mlog'
+#COMM "converting mirror names is ${lv1}_mimagetmp_2"
+lvcreate -l2 -m1 -n $lv1 $vg 
+lvconvert -m+1 -i1000 -b $vg/$lv1 
+convlv=$(lv_convert_lv_ "$vg/$lv1") 
+test "$convlv" = "$lv1"_mimagetmp_2 
+lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv1"_mlog
+
+#COMM "mirror log name after re-adding is ${lv1}_mlog" \
+lvconvert --mirrorlog core $vg/$lv1 
+lvconvert --mirrorlog disk $vg/$lv1 
+convlv=$(lv_convert_lv_ "$vg/$lv1") 
+lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv1"_mlog
+
+#COMM "renamed converting mirror names: $lv1 to $lv2" \
+lvrename $vg/$lv1 $vg/$lv2 
+convlv=$(lv_convert_lv_ "$vg/$lv2") 
+lv_devices_ $vg/$lv2 "$convlv" "$lv2"_mimage_2 
+lv_devices_ "$vg/$convlv" "$lv2"_mimage_0 "$lv2"_mimage_1 
+loglv=$(lv_mirror_log_ "$vg/$convlv") 
+test "$loglv" = "$lv2"_mlog
 
-test_expect_success "cleanup" "check_and_cleanup_lvs_"
+#COMM "cleanup" 
+check_and_cleanup_lvs_
 
 # Temporary mirror log should have "_mlogtmp_<n>" suffix
 # but currently lvconvert doesn't have an option to add the log.
@@ -203,4 +142,3 @@
 # be added.
 
 # ---------------------------------------------------------------------
-test_done
--- LVM2/test/t-pv-range-overflow.sh	2008/04/04 11:59:30	1.3
+++ LVM2/test/t-pv-range-overflow.sh	2008/10/06 16:47:07	1.4
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,52 +9,24 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
-privileges_required_=1
+# 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$vg" && {
-    vgchange -an "$vg"
-    lvremove -ff "$vg"
-    vgremove "$vg"
-  } > /dev/null
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  rm -f "$f1" "$f2"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, VG, LV' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   pvcreate $d1 $d2              &&
-   vg=pvmove-demo-vg-$$          &&
-   vgcreate "$vg" $d1 $d2        &&
-   lv=lv1                        &&
-   lvcreate -L4 -n"$lv" "$vg"'
+aux prepare_vg 2
+
+lvcreate -L4 -n"$lv" $vg
 
 # Test for the bogus diagnostic reported in BZ 284771
 # http://bugzilla.redhat.com/284771.
-test_expect_success \
-  'run pvmove with an unrecognized LV name to show bad diagnostic' \
-  'pvmove -v -nbogus $d1 $d2 2> err
-   test $? = 5 &&
-   tail -n1 err > out &&
-   echo "  Logical volume bogus not found." > expected &&
-   diff -u out expected'
+# 'run pvmove with an unrecognized LV name to show bad diagnostic'
+not pvmove -v -nbogus $dev1 $dev2 2> err
+grep "  Logical volume bogus not found." err
 
 # With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
 # the PE range parsing code would accept values up to 2^64-1, but would
-# silently truncate them to int32_t.  I.e., $d1:$(echo 2^32|bc) would be
-# treated just like $d1:0.
-test_expect_failure \
-  'run the offending pvmove command' \
-  'pvmove -v -n$lv $d1:4294967296 $d2'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# silently truncate them to int32_t.  I.e., $dev1:$(echo 2^32|bc) would be
+# treated just like $dev1:0.
+# 'run the offending pvmove command'
+not pvmove -v -n$lv $dev1:4294967296 $dev2
+
--- LVM2/test/t-pvchange-usage.sh	2008/08/28 10:07:34	1.2
+++ LVM2/test/t-pvchange-usage.sh	2008/10/06 16:47:07	1.3
@@ -9,96 +9,56 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test pvchange option values'
-privileges_required_=1
+# 'Test pvchange option values'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgname' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   vg1=$(this_test_)-test-vg1-$$ &&
-   lv=$(this_test_)-test-lv-$$'
+aux prepare_devs 4
 
 for mda in 0 1 2 
 do
-test_expect_success \
-  "setup pv with metadatacopies = $mda" '
-   pvcreate $d4 &&
-   pvcreate --metadatacopies $mda $d1 &&
-   vgcreate $vg1 $d1 $d4 
-'
-
-test_expect_success \
-  "pvchange adds/dels tag to pvs with metadatacopies = $mda " '
-   pvchange $d1 --addtag test$mda &&
-   check_pv_field_ $d1 pv_tags test$mda &&
-   pvchange $d1 --deltag test$mda &&
-   check_pv_field_ $d1 pv_tags " "
-'
-
-test_expect_success \
-  "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)" '
-   pvchange $d1 -x n &&
-   check_pv_field_ $d1 pv_attr  --  &&
-   pvchange $d1 -x y &&
-   check_pv_field_ $d1 pv_attr  a- 
-'
-
-test_expect_success \
-  'remove pv' '
-   vgremove $vg1 &&
-   pvremove $d1 $d4
-'
+# "setup pv with metadatacopies = $mda" 
+	pvcreate $dev4 
+	pvcreate --metadatacopies $mda $dev1 
+	vgcreate $vg1 $dev1 $dev4 
+
+# "pvchange adds/dels tag to pvs with metadatacopies = $mda " 
+	pvchange $dev1 --addtag test$mda 
+	check_pv_field_ $dev1 pv_tags test$mda 
+	pvchange $dev1 --deltag test$mda 
+	check_pv_field_ $dev1 pv_tags " "
+
+# "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
+	pvchange $dev1 -x n 
+	check_pv_field_ $dev1 pv_attr  --  
+	pvchange $dev1 -x y 
+	check_pv_field_ $dev1 pv_attr  a- 
+
+# 'remove pv'
+	vgremove $vg1 
+	pvremove $dev1 $dev4
 done
 
-test_expect_success \
-  "pvchange uuid" "
-   pvcreate --metadatacopies 0 $d1 &&
-   pvcreate --metadatacopies 2 $d2 &&
-   vgcreate $vg1 $d1 $d2 &&
-   pvchange -u $d1 &&
-   pvchange -u $d2 &&
-   vg_validate_pvlv_counts_ $vg1 2 0 0
-"
-test_expect_success \
-  "pvchange rejects uuid change under an active lv" '
-   lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   { pvchange -u $d1;
-     status=$?; echo status=$status; test $status = 5 &&
-     lvchange -an "$vg1"/"$lv" &&
-     pvchange -u $d1
-   }
-'
-
-test_expect_success \
-  "cleanup" '
-   lvremove -f "$vg1"/"$lv" &&
-   vgremove $vg1
-'
-
-test_expect_success \
-  "pvchange reject --addtag to lvm1 pv" '
-   pvcreate -M1 $d1 &&
-   { pvchange $d1 --addtag test;
-     status=$?; echo status=$status; test $status != 0
-   }
-'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# "pvchange uuid"
+pvcreate --metadatacopies 0 $dev1 
+pvcreate --metadatacopies 2 $dev2 
+vgcreate $vg1 $dev1 $dev2 
+pvchange -u $dev1 
+pvchange -u $dev2 
+vg_validate_pvlv_counts_ $vg1 2 0 0
+
+# "pvchange rejects uuid change under an active lv" 
+lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 
+vg_validate_pvlv_counts_ $vg1 2 1 0 
+not pvchange -u $dev1
+lvchange -an "$vg1"/"$lv" 
+pvchange -u $dev1
+
+# "cleanup" 
+lvremove -f "$vg1"/"$lv"
+vgremove $vg1
+
+# "pvchange reject --addtag to lvm1 pv"
+pvcreate -M1 $dev1 
+not pvchange $dev1 --addtag test
+
--- LVM2/test/t-pvcreate-metadata0.sh	2008/08/05 12:33:41	1.1
+++ LVM2/test/t-pvcreate-metadata0.sh	2008/10/06 16:47:07	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,37 +13,20 @@
 # Testcase for bugzilla #450651
 # also checks that vgremove properly removes all lv devices in the right order
 #
-test_description='Test pvcreate without metadata on all pvs'
-privileges_required_=1
+# 'Test pvcreate without metadata on all pvs'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  rm -f "$f1" "$f2"
-}
+aux prepare_devs 2 128
 
-test_expect_success "set up temp files, loopback devices" \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   lv=$(this_test_)-test-lv-$$            &&
-   lv_snap=$(this_test_)-test-lv-snap-$$  &&
-   pvcreate "$d1"                         &&
-   pvcreate --metadatacopies 0 "$d2"'
-
-test_expect_success "check lv snapshot" \
-  'vgcreate -c n "$vg" "$d1" "$d2"                  &&
-   lvcreate -n "$lv" -l 60%FREE "$vg"               &&
-   lvcreate -s -n "$lv_snap" -l 10%FREE "$vg"/"$lv" &&
-   pvdisplay                                        &&
-   lvdisplay                                        &&
-   vgremove -f "$vg"'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+#lv_snap=$lv2
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+
+# "check lv snapshot" 
+vgcreate -c n "$vg" "$dev1" "$dev2" 
+lvcreate -n "$lv" -l 60%FREE "$vg" 
+lvcreate -s -n $lv2 -l 10%FREE "$vg"/"$lv" 
+pvdisplay 
+lvdisplay
+vgremove -f "$vg"
--- LVM2/test/t-pvcreate-usage.sh	2008/07/17 03:17:01	1.2
+++ LVM2/test/t-pvcreate-usage.sh	2008/10/06 16:47:07	1.3
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,89 +10,56 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test pvcreate option values'
-privileges_required_=1
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgname' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   vg1=$(this_test_)-test-vg1-$$'
-
-test_expect_success \
-  'pvcreate rejects negative setphysicalvolumesize' \
-  'pvcreate --setphysicalvolumesize -1024 $d1;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects negative metadatasize' \
-  'pvcreate --metadatasize -1024 $d1;
-   status=$?; echo status=$status; test $status != 0'
+aux prepare_devs 4
+
+#COMM 'pvcreate rejects negative setphysicalvolumesize'
+not pvcreate --setphysicalvolumesize -1024 $dev1
+
+#COMM 'pvcreate rejects negative metadatasize'
+not pvcreate --metadatasize -1024 $dev1
 
 # x. metadatasize 0, defaults to 255
 # FIXME: unable to check default value, not in reporting cmds
 # should default to 255 according to code
-#   check_pv_field_ pv_mda_size 255 &&
-test_expect_success \
-  'pvcreate accepts metadatasize 0' \
-  'pvcreate --metadatasize 0 $d1 &&
-   pvremove $d1'
+#   check_pv_field_ pv_mda_size 255 
+#COMM 'pvcreate accepts metadatasize 0'
+pvcreate --metadatasize 0 $dev1
+pvremove $dev1
 
 # x. metadatasize too large
 # For some reason we allow this, even though there's no room for data?
 #test_expect_success \
-#  'pvcreate rejects metadatasize too large' \
-#  'pvcreate --metadatasize 100000000000000 $d1;
-#   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects metadatacopies < 0' \
-  'pvcreate --metadatacopies -1 $d1;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate accepts metadatacopies = 0, 1, 2' \
-  'pvcreate --metadatacopies 0 $d1 &&
-   pvcreate --metadatacopies 1 $d2 &&
-   pvcreate --metadatacopies 2 $d3 &&
-   check_pv_field_ $d1 pv_mda_count 0 &&
-   check_pv_field_ $d2 pv_mda_count 1 &&
-   check_pv_field_ $d3 pv_mda_count 2 &&
-   pvremove $d1 &&
-   pvremove $d2 &&
-   pvremove $d3'
-
-test_expect_success \
-  'pvcreate rejects metadatacopies > 2' \
-  'pvcreate --metadatacopies 3 $d1;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects invalid device' \
-  'pvcreate $d1bogus;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects labelsector < 0' \
-  'pvcreate --labelsector -1 $d1;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects labelsector > 1000000000000' \
-  'pvcreate --labelsector 1000000000000 $d1;
-   status=$?; echo status=$status; test $status != 0'
+##COMM  'pvcreate rejects metadatasize too large' 
+#not pvcreate --metadatasize 100000000000000 $dev1
+
+#COMM 'pvcreate rejects metadatacopies < 0'
+not pvcreate --metadatacopies -1 $dev1
+
+#COMM 'pvcreate accepts metadatacopies = 0, 1, 2'
+pvcreate --metadatacopies 0 $dev1 
+pvcreate --metadatacopies 1 $dev2 
+pvcreate --metadatacopies 2 $dev3 
+check_pv_field_ $dev1 pv_mda_count 0 
+check_pv_field_ $dev2 pv_mda_count 1 
+check_pv_field_ $dev3 pv_mda_count 2 
+pvremove $dev1 
+pvremove $dev2 
+pvremove $dev3
+
+#COMM 'pvcreate rejects metadatacopies > 2'
+not pvcreate --metadatacopies 3 $dev1
+
+#COMM 'pvcreate rejects invalid device'
+not pvcreate $dev1bogus
+
+#COMM 'pvcreate rejects labelsector < 0'
+not pvcreate --labelsector -1 $dev1
+
+#COMM 'pvcreate rejects labelsector > 1000000000000'
+not pvcreate --labelsector 1000000000000 $dev1
 
 # other possibilites based on code inspection (not sure how hard)
 # x. device too small (min of 512 * 1024 KB)
@@ -104,7 +71,3 @@
 # x. BLKGETSIZE64 fails
 # x. set size to value inconsistent with device / PE size
 
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
--- LVM2/test/t-pvmove-basic.sh	2008/01/16 21:21:22	1.1
+++ LVM2/test/t-pvmove-basic.sh	2008/10/06 16:47:07	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,152 +11,84 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure that pvmove works with basic options"
-privileges_required_=1
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ ||
-{
-  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
-  say "Skipping this test"
-  exit 0
-}
-
-cleanup_()
-{
-  test -n "$vg" && {
-    lvremove -ff $vg
-    vgremove $vg
-  } > /dev/null
-  test -n "$pvs" && {
-    pvremove $pvs > /dev/null
-    for d in $pvs; do
-      dmsetup remove $(basename $d)
-    done
-  }
-  losetup -d $lodev
-  rm -f $lofile
-}
-
-# ---------------------------------------------------------------------
-# config
-
-nr_pvs=5
-pvsize=$((80 * 1024 * 2))
-
-vg=pvmove-basic-vg-$$
-lv1=lv1
-lv2=lv2
-lv3=lv3
+dmsetup_has_dm_devdir_support_ || exit 200
 
 # ---------------------------------------------------------------------
 # Utilities
 
-pv_()
-{
-  echo "$G_dev_/mapper/pv$1"
-}
-
-lvdev_()
-{
+lvdev_() {
   echo "$G_dev_/$1/$2"
 }
 
-lv_is_on_()
-{
-  local lv=$1
+lv_is_on_() {
+  local lv=$1 #allready vg/lv
   shift 1
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
-  for d in $*; do grep "$d(" out || return 1; done
-  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
-  grep . out && return 1
+#is on all specified devs
+  for d in $*; do grep "$d(" out; done
+#isn't on any other dev (we are set -e remember)
+  for d in $*; do ! grep -v "$d(" out; done
   return 0
 }
 
-save_dev_sum_()
-{
+save_dev_sum_() {
   mkfs.ext3 $1 > /dev/null &&
   md5sum $1 > md5.$(basename $1)
 }
 
-check_dev_sum_()
-{
+check_dev_sum_() {
   md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
 }
 
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-test_expect_success \
-  'set up temp file and loopback device' \
-  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
-
-offset=0
-pvs=
-for n in $(seq 1 $nr_pvs); do
-  test_expect_success \
-      "create pv$n" \
-      'echo "0 $pvsize linear $lodev $offset" > in &&
-       dmsetup create pv$n < in'
-  offset=$(($offset + $pvsize))
-done
-
-for n in $(seq 1 $nr_pvs); do
-  pvs="$pvs $(pv_ $n)"
-done
-
-test_expect_success \
-  "Run this: pvcreate $pvs" \
-  'pvcreate $pvs'
-
-test_expect_success \
-  'set up a VG' \
-  'vgcreate $vg $pvs'
+aux prepare_vg 5 80
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
-prepare_lvs_()
-{
-  lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
-    lv_is_on_ $vg/$lv1 $(pv_ 1) &&
-  lvcreate -l9 -i3 -n $lv2 $vg $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-    lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-  lvextend -l+2 $vg/$lv1 $(pv_ 2) &&
-    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) &&
-  lvextend -l+2 $vg/$lv1 $(pv_ 3) &&
-    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-  lvextend -l+2 $vg/$lv1 $(pv_ 1) &&
-    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 1) &&
-  lvcreate -l1 -n $lv3 $vg $(pv_ 2) &&
-    lv_is_on_ $vg/$lv3 $(pv_ 2) &&
-  save_dev_sum_ $(lvdev_ $vg $lv1) &&
-  save_dev_sum_ $(lvdev_ $vg $lv2) &&
-  save_dev_sum_ $(lvdev_ $vg $lv3) &&
-  lvs -a -o devices --noheadings $vg/$lv1 > lv1_devs &&
-  lvs -a -o devices --noheadings $vg/$lv2 > lv2_devs &&
-  lvs -a -o devices --noheadings $vg/$lv3 > lv3_devs
+prepare_lvs_() {
+  lvcreate -l2 -n $lv1 $vg $dev1 
+    lv_is_on_ $vg/$lv1 $dev1 
+  lvcreate -l9 -i3 -n $lv2 $vg $dev2 $dev3 $dev4 
+    lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
+  lvextend -l+2 $vg/$lv1 $dev2 
+    lv_is_on_ $vg/$lv1 $dev1 $dev2 
+  lvextend -l+2 $vg/$lv1 $dev3 
+    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 
+  lvextend -l+2 $vg/$lv1 $dev1 
+    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1 
+  lvcreate -l1 -n $lv3 $vg $dev2 
+    lv_is_on_ $vg/$lv3 $dev2 
+  save_dev_sum_ $(lvdev_ $vg $lv1) 
+  save_dev_sum_ $(lvdev_ $vg $lv2) 
+  save_dev_sum_ $(lvdev_ $vg $lv3) 
+  lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs 
+  lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs 
+  lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
 }
 
-lv_not_changed_()
-{
-  lvs -a -o devices --noheadings $1 > out &&
+lv_not_changed_() {
+  lvs -a -o devices --noheadings $1 > out
   diff $(basename $1)_devs out
 }
 
-check_and_cleanup_lvs_()
-{
-  lvs -a -o+devices $vg &&
-  check_dev_sum_ $(lvdev_ $vg $lv1) &&
-  check_dev_sum_ $(lvdev_ $vg $lv2) &&
-  check_dev_sum_ $(lvdev_ $vg $lv3) &&
-  lvs -a -o name $vg > out && ! grep ^pvmove out &&
+check_and_cleanup_lvs_() {
+  lvs -a -o+devices $vg
+  check_dev_sum_ $(lvdev_ $vg $lv1)
+  check_dev_sum_ $(lvdev_ $vg $lv2)
+  check_dev_sum_ $(lvdev_ $vg $lv3)
+  lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
 }
 
-test_expect_success "check environment setup/cleanup" \
-  'prepare_lvs_ &&
-   check_and_cleanup_lvs_'
+#COMM "check environment setup/cleanup"
+prepare_lvs_
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # pvmove tests
@@ -164,265 +96,264 @@
 # ---
 # filter by LV
 
-test_expect_success "only specified LV is moved: from pv2 to pv5 only for lv1" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv1 $(pv_ 2) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # segments in a LV
 
-test_expect_success "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv1 $(pv_ 1) $(pv_ 4) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 4) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv1 $(pv_ 2) $(pv_ 4) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 4) $(pv_ 3) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 4) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev1 $dev4 
+lv_is_on_ $vg/$lv1 $dev4 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev2 $dev4 
+lv_is_on_ $vg/$lv1 $dev1 $dev4 $dev3 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv1 $dev3 $dev4 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev4 $dev1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # multiple LVs matching
 
-test_expect_success "1 out of 3 LVs is moved: from pv4 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 4) $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "2 out of 3 LVs are moved: from pv3 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 3) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 5) $(pv_ 1) &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "3 out of 3 LVs are moved: from pv2 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) $(pv_ 1) &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_is_on_ $vg/$lv3 $(pv_ 5) &&
-   check_and_cleanup_lvs_'
+#COMM "1 out of 3 LVs is moved: from pv4 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev4 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev5 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "2 out of 3 LVs are moved: from pv3 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 $dev1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "3 out of 3 LVs are moved: from pv2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_is_on_ $vg/$lv3 $dev5 
+check_and_cleanup_lvs_
 
 # ---
 # areas of striping
 
-test_expect_success "move the 1st stripe: from pv2 of lv2 to pv1" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv2 $(pv_ 2) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 1) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "move the 2nd stripe: from pv3 of lv2 to pv1" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv2 $(pv_ 3) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 1) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "move the 3rd stripe: from pv4 of lv2 to pv1" \
-  'prepare_lvs_ &&
-   pvmove -i1 -n $vg/$lv2 $(pv_ 4) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 1) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "move the 1st stripe: from pv2 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev2 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev1 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev3 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
+prepare_lvs_ 
+pvmove -i1 -n $vg/$lv2 $dev4 $dev1 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev1 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # partial segment match (source segment splitted)
 
-test_expect_success "match to the start of segment:from pv2:0-0 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):0-0 $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "match to the middle of segment: from pv2:1-1 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):1-1 $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "match to the end of segment: from pv2:2-2 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):2-2 $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "match to the start of segment:from pv2:0-0 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-0 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "match to the middle of segment: from pv2:1-1 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:1-1 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "match to the end of segment: from pv2:2-2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:2-2 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # destination segment splitted
 
-test_expect_success "no destination split: from pv2:0-2 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):0-2 $(pv_ 5) &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):0-2 $(pv_ 5):5-5 $(pv_ 4):5-6 &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 4) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):0-2 $(pv_ 3):5-5 $(pv_ 4):5-5 $(pv_ 5):5-5 &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 3) $(pv_ 4) $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "no destination split: from pv2:0-2 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-2 $dev5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-2 $dev5:5-5 $dev4:5-6 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev4 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
+prepare_lvs_ 
+pvmove -i1 $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev3 $dev4 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # alloc policy (anywhere, contiguous) with both success and failure cases
 
-test_expect_failure "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 3):0-2 $(pv_ 3):5-7'
-test_expect_success "(cleanup previous test)" \
-  'lv_not_changed_ $vg/$lv1 &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7" \
-  'prepare_lvs_ &&
-   pvmove -i1 --alloc anywhere $(pv_ 3):0-2 $(pv_ 3):5-7 &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5" \
-  'prepare_lvs_ &&
-   pvmove -i1 --alloc anywhere $(pv_ 3):0-2 $(pv_ 3):5-7 $(pv_ 5):5-6 $(pv_ 4):5-5 &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_failure "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6" \
-  'prepare_lvs_ &&
-   pvmove -i1 --alloc contiguous $(pv_ 2):0-2 $(pv_ 5):5-5 $(pv_ 4):5-6'
-test_expect_success "(cleanup previous test)" \
-  'lv_not_changed_ $vg/$lv1 &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6" \
-  'prepare_lvs_ &&
-   pvmove -i1 --alloc contiguous $(pv_ 2):0-2 $(pv_ 5):0-0 $(pv_ 5):3-5 $(pv_ 4):5-6 &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" 
+prepare_lvs_ 
+not pvmove -i1 $dev3:0-2 $dev3:5-7
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5"
+prepare_lvs_ 
+pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
+prepare_lvs_ 
+not pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:5-5 $dev4:5-6
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
+prepare_lvs_ 
+pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:0-0 $dev5:3-5 $dev4:5-6 
+lv_not_changed_ $vg/$lv1 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # multiple segments in a LV
 
-test_expect_success "multiple source LVs: from pv3 to pv5" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 3) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "multiple source LVs: from pv3 to pv5"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 
+lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---
 # move inactive LV
 
-test_expect_success "move inactive LV: from pv2 to pv5" \
-  'prepare_lvs_ &&
-   lvchange -an $vg/$lv1 &&
-   lvchange -an $vg/$lv3 &&
-   pvmove -i1 $(pv_ 2) $(pv_ 5) &&
-   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) &&
-   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
-   lv_is_on_ $vg/$lv3 $(pv_ 5) &&
-   check_and_cleanup_lvs_'
+#COMM "move inactive LV: from pv2 to pv5"
+prepare_lvs_ 
+lvchange -an $vg/$lv1 
+lvchange -an $vg/$lv3 
+pvmove -i1 $dev2 $dev5 
+lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 
+lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
+lv_is_on_ $vg/$lv3 $dev5 
+check_and_cleanup_lvs_
 
 # ---
 # other failure cases
 
-test_expect_failure "no PEs to move: from pv3 to pv1" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 3) $(pv_ 1) &&
-   pvmove -i1 $(pv_ 3) $(pv_ 1)'
-test_expect_success "(cleanup previous test)" \
-  'lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 1) &&
-   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 1) $(pv_ 4) &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_failure "no space available: from pv2:0-0 to pv1:0-0" \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 2):0-0 $(pv_ 1):0-0'
-test_expect_success "(cleanup previous test)" \
-  'lv_not_changed_ $vg/$lv1 &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_failure 'same source and destination: from pv1 to pv1' \
-  'prepare_lvs_ &&
-   pvmove -i1 $(pv_ 1) $(pv_ 1)'
-test_expect_success "(cleanup previous test)" \
-  'lv_not_changed_ $vg/$lv1 &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_failure "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough" \
-  'prepare_lvs_ &&
-   pvmove --alloc anywhere $(pv_ 1):0-2 $(pv_ 1):0-2 $(pv_ 5):0-0 2> err'
-test_expect_success "(cleanup previous test)" \
-  'grep "Insufficient free space" err &&
-   lv_not_changed_ $vg/$lv1 &&
-   lv_not_changed_ $vg/$lv2 &&
-   lv_not_changed_ $vg/$lv3 &&
-   check_and_cleanup_lvs_'
+#COMM "no PEs to move: from pv3 to pv1"
+prepare_lvs_ 
+pvmove -i1 $dev3 $dev1 
+not pvmove -i1 $dev3 $dev1
+# "(cleanup previous test)"
+lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev1 
+lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "no space available: from pv2:0-0 to pv1:0-0" 
+prepare_lvs_ 
+not pvmove -i1 $dev2:0-0 $dev1:0-0
+# "(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM 'same source and destination: from pv1 to pv1'
+prepare_lvs_ 
+not pvmove -i1 $dev1 $dev1
+#"(cleanup previous test)"
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
+
+#COMM "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough"
+prepare_lvs_ 
+not pvmove --alloc anywhere $dev1:0-2 $dev1:0-2 $dev5:0-0 2> err
+#"(cleanup previous test)"
+grep "Insufficient free space" err 
+lv_not_changed_ $vg/$lv1 
+lv_not_changed_ $vg/$lv2 
+lv_not_changed_ $vg/$lv3 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
-test_expect_success "pvmove abort" \
-  'prepare_lvs_ &&
-   pvmove -i100 -b $(pv_ 1) $(pv_ 3) &&
-   pvmove --abort &&
-   check_and_cleanup_lvs_'
+#COMM "pvmove abort"
+prepare_lvs_ 
+pvmove -i100 -b $dev1 $dev3 
+pvmove --abort 
+check_and_cleanup_lvs_
 
-test_done
--- LVM2/test/t-read-ahead.sh	2008/08/04 09:15:15	1.2
+++ LVM2/test/t-read-ahead.sh	2008/10/06 16:47:07	1.3
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,55 +14,26 @@
 #
 
 test_description='Test read-ahead functionality'
-privileges_required_=1
 
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
 
-get_lvs_()
-{
+get_lvs_() {
    case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
     *$2) true ;;
     *) false ;;
    esac
 }
 
-test_expect_success "set up temp files, loopback devices" \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   lv=$(this_test_)-test-lv-$$'
-
-test_expect_success "test various read ahead settings" \
-  'pvcreate "$d1"                                    &&
-   pvcreate "$d2"                                    &&
-   pvcreate "$d3"                                    &&
-   pvcreate "$d4"                                    &&
-   pvcreate "$d5"                                    &&
-   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
-   lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     &&
-   lvdisplay "$vg"/"$lv"                             &&
-   lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto     &&
-   get_lvs_ lv auto                                  &&
-   get_lvs_ lv_kernel 5120                           &&
-   lvchange -r 400 "$vg/$lv"                         &&
-   get_lvs_ lv 400                                   &&
-   vgremove -f "$vg"'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+aux prepare_vg 5
+
+#COMM "test various read ahead settings"
+lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     
+lvdisplay "$vg"/"$lv"                             
+lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto     
+get_lvs_ lv auto                                  
+get_lvs_ lv_kernel 5120                           
+lvchange -r 400 "$vg/$lv"                         
+get_lvs_ lv 400                                   
+vgremove -f "$vg"
+
--- LVM2/test/t-vgcreate-usage.sh	2008/08/28 11:09:58	1.4
+++ LVM2/test/t-vgcreate-usage.sh	2008/10/06 16:47:07	1.5
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,106 +10,59 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise some vgcreate diagnostics'
-privileges_required_=1
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  rm -f "$f1" "$f2" "$f3"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgname' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   pvcreate $d1 $d2                       &&
-   pvcreate --metadatacopies 0 $d3
-'
-
-lv=vgcreate-usage-$$
-
-test_expect_success \
-  'vgcreate accepts 8.00M physicalextentsize for VG' \
-  'vgcreate $vg --physicalextentsize 8.00M $d1 $d2 &&
-   check_vg_field_ $vg vg_extent_size 8.00M &&
-   vgremove $vg'
-
-test_expect_success \
-  'vgcreate accepts smaller (128) maxlogicalvolumes for VG' \
-  'vgcreate $vg --maxlogicalvolumes 128 $d1 $d2 &&
-   check_vg_field_ $vg max_lv 128 &&
-   vgremove $vg'
-
-test_expect_success \
-  'vgcreate accepts smaller (128) maxphysicalvolumes for VG' \
-  'vgcreate $vg --maxphysicalvolumes 128 $d1 $d2 &&
-   check_vg_field_ $vg max_pv 128 &&
-   vgremove $vg'
-
-test_expect_success \
-  'vgcreate rejects a zero physical extent size' \
-  'vgcreate --physicalextentsize 0 $vg $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "^  Physical extent size may not be zero\$" err'
-
-test_expect_success \
-  'vgcreate rejects "inherit" allocation policy' \
-  'vgcreate --alloc inherit $vg $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "^  Volume Group allocation policy cannot inherit from anything\$" err'
-
-test_expect_success \
-  'vgcreate rejects vgname "."' \
-  'vg=.; vgcreate $vg $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "New volume group name \"$vg\" is invalid\$" err'
-
-test_expect_success \
-  'vgcreate rejects vgname greater than 128 characters' \
-  'vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome;
-   vgcreate $vginvalid $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "New volume group name \"$vginvalid\" is invalid\$" err'
-
-test_expect_success \
-  'vgcreate rejects already existing vgname "/tmp/$vg"' \
-  'touch /tmp/$vg; vgcreate $vg $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "New volume group name \"$vg\" is invalid\$" err'
-
-test_expect_success \
-  'cleanup vg name' '
-   vg=$(this_test_)-test-vg-$$
-'
-
-test_expect_success \
-  "vgcreate rejects repeated invocation (run  2 times)" '
-   vgcreate $vg $d1 $d2 && {
-     vgcreate $vg $d1 $d2;
-     status=$?; echo status=$status; test $status = 5 &&
-     vgremove -ff $vg
-   }
-'
-
-test_expect_success \
-  'vgcreate rejects MaxLogicalVolumes > 255' \
-  'vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "^  Number of volumes may not exceed 255\$" err'
-
-test_expect_success \
-  "vgcreate fails when the only pv has --metadatacopies 0" '
-   vgcreate $vg $d3;
-   status=$?; echo status=$status; test $status = 5
-'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+aux prepare_devs 3
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3
+
+#COMM 'vgcreate accepts 8.00M physicalextentsize for VG'
+vgcreate $vg --physicalextentsize 8.00M $dev1 $dev2 
+check_vg_field_ $vg vg_extent_size 8.00M 
+vgremove $vg
+
+#COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
+vgcreate $vg --maxlogicalvolumes 128 $dev1 $dev2 
+check_vg_field_ $vg max_lv 128 
+vgremove $vg
+
+#COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
+vgcreate $vg --maxphysicalvolumes 128 $dev1 $dev2
+check_vg_field_ $vg max_pv 128
+vgremove $vg
+
+#COMM 'vgcreate rejects a zero physical extent size'
+not vgcreate --physicalextentsize 0 $vg $dev1 $dev2 2>err
+grep "^  Physical extent size may not be zero\$" err
+
+#COMM 'vgcreate rejects "inherit" allocation policy'
+not vgcreate --alloc inherit $vg $dev1 $dev2 2>err
+grep "^  Volume Group allocation policy cannot inherit from anything\$" err
+
+#COMM 'vgcreate rejects vgname "."'
+vginvalid=.; 
+not vgcreate $vginvalid $dev1 $dev2 2>err
+grep "New volume group name \"$vginvalid\" is invalid\$" err
+
+#COMM 'vgcreate rejects vgname greater than 128 characters'
+vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
+not vgcreate $vginvalid $dev1 $dev2 2>err
+grep "New volume group name \"$vginvalid\" is invalid\$" err
+
+#COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
+#touch /tmp/$vg
+#not vgcreate $vg $dev1 $dev2 2>err
+#grep "New volume group name \"$vg\" is invalid\$" err
+
+#COMM "vgcreate rejects repeated invocation (run 2 times)"
+vgcreate $vg $dev1 $dev2
+not vgcreate $vg $dev1 $dev2
+vgremove -ff $vg
+
+#COMM 'vgcreate rejects MaxLogicalVolumes > 255'
+not vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $dev1 $dev2 2>err
+grep "^  Number of volumes may not exceed 255\$" err
+
+#COMM "vgcreate fails when the only pv has --metadatacopies 0"
+not vgcreate $vg $dev3
--- LVM2/test/t-vgmerge-operation.sh	2008/04/11 14:06:16	1.3
+++ LVM2/test/t-vgmerge-operation.sh	2008/10/06 16:47:07	1.4
@@ -10,86 +10,57 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test vgmerge operation'
-privileges_required_=1
 
-. ./test-lib.sh
+. ./test-utils.sh
+
+aux prepare_pvs 4 64
+
+# 'vgmerge succeeds with single linear LV in source VG'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 $dev1 
+vgchange -an $vg1 
+vg_validate_pvlv_counts_ $vg1 2 1 0 
+vg_validate_pvlv_counts_ $vg2 2 0 0 
+vgmerge $vg2 $vg1 
+vg_validate_pvlv_counts_ $vg2 4 1 0 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with single linear LV in source and destination VG'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+lvcreate -l 4 -n $lv1 $vg1 
+lvcreate -l 4 -n $lv2 $vg2 
+vgchange -an $vg1 
+vgchange -an $vg2 
+vg_validate_pvlv_counts_ $vg1 2 1 0 
+vg_validate_pvlv_counts_ $vg2 2 1 0 
+vgmerge $vg2 $vg1 
+vg_validate_pvlv_counts_ $vg2 4 2 0 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with linear LV + snapshots in source VG'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+lvcreate -l 16 -n $lv1 $vg1 
+lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
+vgchange -an $vg1 
+vg_validate_pvlv_counts_ $vg1 2 2 1 
+vg_validate_pvlv_counts_ $vg2 2 0 0 
+vgmerge $vg2 $vg1 
+vg_validate_pvlv_counts_ $vg2 4 2 1 
+lvremove -f $vg2/$lv2 
+vgremove -f $vg2
+
+# 'vgmerge succeeds with mirrored LV in source VG'
+vgcreate $vg1 $dev1 $dev2 $dev3 
+vgcreate $vg2 $dev4 
+lvcreate -l 4 -n $lv1 -m1 $vg1 
+vgchange -an $vg1 
+vg_validate_pvlv_counts_ $vg1 3 1 0 
+vg_validate_pvlv_counts_ $vg2 1 0 0 
+vgmerge $vg2 $vg1 
+vg_validate_pvlv_counts_ $vg2 4 1 0 
+lvremove -f $vg2/$lv1 
+vgremove -f $vg2
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgnames' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   vg1=$(this_test_)-test-vg1-$$          &&
-   vg2=$(this_test_)-test-vg2-$$          &&
-   lv1=$(this_test_)-test-lv1-$$          &&
-   lv2=$(this_test_)-test-lv2-$$          &&
-   lv3=$(this_test_)-test-lv3-$$          &&
-   pvcreate $d1 $d2 $d3 $d4'
-
-test_expect_success \
-  'vgmerge succeeds with single linear LV in source VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 $d1 &&
-   vgchange -an $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   vg_validate_pvlv_counts_ $vg2 2 0 0 &&
-   vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 1 0 &&
-   vgremove -f $vg2'
-
-test_expect_success \
-  'vgmerge succeeds with single linear LV in source and destination VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n $lv1 $vg1 &&
-   lvcreate -l 4 -n $lv2 $vg2 &&
-   vgchange -an $vg1 &&
-   vgchange -an $vg2 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   vg_validate_pvlv_counts_ $vg2 2 1 0 &&
-   vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 2 0 &&
-   vgremove -f $vg2'
-
-test_expect_success \
-  'vgmerge succeeds with linear LV + snapshots in source VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 16 -n $lv1 $vg1 &&
-   lvcreate -l 4 -s -n $lv2 $vg1/$lv1 &&
-   vgchange -an $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 2 2 1 &&
-   vg_validate_pvlv_counts_ $vg2 2 0 0 &&
-   vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 2 1 &&
-   lvremove -f $vg2/$lv2 &&
-   vgremove -f $vg2'
-
-test_expect_success \
-  'vgmerge succeeds with mirrored LV in source VG' \
-  'vgcreate $vg1 $d1 $d2 $d3 &&
-   vgcreate $vg2 $d4 &&
-   lvcreate -l 4 -n $lv1 -m1 $vg1 &&
-   vgchange -an $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 3 1 0 &&
-   vg_validate_pvlv_counts_ $vg2 1 0 0 &&
-   vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 1 0 &&
-   lvremove -f $vg2/$lv1 &&
-   vgremove -f $vg2'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
--- LVM2/test/t-vgmerge-usage.sh	2008/04/10 01:06:48	1.4
+++ LVM2/test/t-vgmerge-usage.sh	2008/10/06 16:47:07	1.5
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,94 +9,61 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test vgmerge command options for validity'
-privileges_required_=1
+# 'Test vgmerge command options for validity'
 
-. ./test-lib.sh
+. ./test-utils.sh
+
+aux prepare_pvs 4
+
+# 'vgmerge normal operation'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+vgmerge $vg1 $vg2 
+vgremove $vg1
+
+# 'vgmerge rejects duplicate vg name'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg1 2>err
+grep "^  Duplicate volume group name \"$vg1\"\$" err 
+vgremove $vg2 
+vgremove $vg1
+
+# 'vgmerge rejects vgs with incompatible extent_size'
+vgcreate --physicalextentsize 4M $vg1 $dev1 $dev2 
+vgcreate --physicalextentsize 8M $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Extent sizes differ" err 
+vgremove $vg2 
+vgremove $vg1
+
+# 'vgmerge rejects vgmerge because max_pv is exceeded'
+vgcreate --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Maximum number of physical volumes (2) exceeded" err 
+vgremove $vg2 
+vgremove $vg1
+
+# 'vgmerge rejects vg with active lv'
+vgcreate $vg1 $dev1 $dev2 
+vgcreate $vg2 $dev3 $dev4 
+lvcreate -l 4 -n lv1 $vg2 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Logical volumes in \"$vg2\" must be inactive\$" err 
+vgremove -f $vg2 
+vgremove -f $vg1
+
+# 'vgmerge rejects vgmerge because max_lv is exceeded' 
+vgcreate --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
+lvcreate -l 4 -n lv1 $vg1 
+lvcreate -l 4 -n lv2 $vg1 
+lvcreate -l 4 -n lv3 $vg2 
+vgchange -an $vg1 
+vgchange -an $vg2 
+not vgmerge $vg1 $vg2 2>err
+grep "^  Maximum number of logical volumes (2) exceeded" err 
+vgremove -f $vg2 
+vgremove -f $vg1
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgnames' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   vg1=$(this_test_)-test-vg1-$$          &&
-   vg2=$(this_test_)-test-vg2-$$          &&
-   pvcreate $d1 $d2 $d3 $d4'
-
-test_expect_success \
-  'vgmerge normal operation' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   vgmerge $vg1 $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgmerge rejects duplicate vg name' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   vgmerge $vg1 $vg1 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Duplicate volume group name \"$vg1\"\$" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgmerge rejects vgs with incompatible extent_size' \
-  'vgcreate --physicalextentsize 4M $vg1 $d1 $d2 &&
-   vgcreate --physicalextentsize 8M $vg2 $d3 $d4 &&
-   vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Extent sizes differ" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgmerge rejects vgmerge because max_pv is exceeded' \
-  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Maximum number of physical volumes (2) exceeded" err &&
-   vgremove $vg2 &&
-   vgremove $vg1'
-
-test_expect_success \
-  'vgmerge rejects vg with active lv' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgcreate $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n lv1 $vg2 &&
-   vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Logical volumes in \"$vg2\" must be inactive\$" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_expect_success \
-  'vgmerge rejects vgmerge because max_lv is exceeded' \
-  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-   lvcreate -l 4 -n lv1 $vg1 &&
-   lvcreate -l 4 -n lv2 $vg1 &&
-   lvcreate -l 4 -n lv3 $vg2 &&
-   vgchange -an $vg1 &&
-   vgchange -an $vg2 &&
-   vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   grep "^  Maximum number of logical volumes (2) exceeded" err &&
-   vgremove -f $vg2 &&
-   vgremove -f $vg1'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:


