From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 16:02:53 -0000
Subject: LVM2/test t-lvcreate-pvtags.sh t-lvmcache-exer ...
Message-ID: <20080929160253.18711.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 16:02:50

Modified files:
	test           : t-lvcreate-pvtags.sh t-lvmcache-exercise.sh 
	                 t-lvresize-usage.sh t-mirror-lvconvert.sh 
	                 t-mirror-vgreduce-removemissing.sh 
	                 t-000-basic.sh t-pool-labels.sh t-metadata.sh 
	                 t-covercmd.sh t-pvcreate-operation.sh 
	                 t-vgrename-usage.sh 

Log message:
	Update a bunch of tests to use functionality from test-utils.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pool-labels.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-lvcreate-pvtags.sh	2007/10/09 13:13:06	1.3
+++ LVM2/test/t-lvcreate-pvtags.sh	2008/09/29 16:02:49	1.4
@@ -1,5 +1,4 @@
-#!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,81 +8,33 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure that lvcreate's select-by-tag code works"
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
+aux prepare_pvs 3
 
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
-nr_pvs=3
-pvsize=$((200 * 1024 * 2))
-
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
-  pvs="$pvs $G_dev_/mapper/pv$n"
-done
-
-test_expect_success \
-  "Run this: pvcreate $pvs" \
-  'pvcreate $pvs'
-
-vg=lvcreate-pvtags-vg-$$
-test_expect_success \
-  'set up a VG with tagged PVs' \
-  'vgcreate $vg $pvs &&
-   pvchange --addtag fast $pvs'
-
-test_expect_success '3 stripes with 3 PVs (selected by tag, @fast) is fine' \
-  'lvcreate -l3 -i3 $vg @fast'
-test_expect_failure 'too many stripes(4) for 3 PVs' \
-  'lvcreate -l4 -i4 $vg @fast'
-test_expect_failure '2 stripes is too many with just one PV' \
-  'lvcreate -l2 -i2 $vg $G_dev_/mapper/pv1'
-
-test_expect_success 'lvcreate mirror' \
-  'lvcreate -l1 -m1 $vg @fast'
-test_expect_success 'lvcreate mirror w/corelog' \
-  'lvcreate -l1 -m2 --corelog $vg @fast'
-test_expect_failure 'lvcreate mirror w/no free PVs' \
-  'lvcreate -l1 -m2 $vg @fast'
-test_expect_failure 'lvcreate mirror (corelog, w/no free PVs)' \
-  'lvcreate -l1 -m3 --corelog $vg @fast'
-test_expect_failure 'lvcreate mirror with a single PV arg' \
-  'lvcreate -l1 -m1 --corelog $vg $G_dev_/mapper/pv1'
+vgcreate $vg $devs
+pvchange --addtag fast $devs
 
-test_done
+# 3 stripes with 3 PVs (selected by tag, @fast) is fine
+lvcreate -l3 -i3 $vg @fast
+
+# too many stripes(4) for 3 PVs
+not lvcreate -l4 -i4 $vg @fast
+
+# 2 stripes is too many with just one PV
+not lvcreate -l2 -i2 $vg $G_dev_/mapper/pv1
+
+# lvcreate mirror
+lvcreate -l1 -m1 $vg @fast
+
+# lvcreate mirror w/corelog
+lvcreate -l1 -m2 --corelog $vg @fast
+
+# lvcreate mirror w/no free PVs
+not lvcreate -l1 -m2 $vg @fast
+
+# lvcreate mirror (corelog, w/no free PVs)
+not lvcreate -l1 -m3 --corelog $vg @fast
+
+# lvcreate mirror with a single PV arg
+not lvcreate -l1 -m1 --corelog $vg $dev1
--- LVM2/test/t-lvmcache-exercise.sh	2008/06/09 15:31:58	1.1
+++ LVM2/test/t-lvmcache-exercise.sh	2008/09/29 16:02:49	1.2
@@ -1,5 +1,4 @@
-#!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,53 +8,16 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test lvmcache operation'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
+aux prepare_pvs 5
 
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  test -n "$d5" && losetup -d "$d5"
-  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
-}
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev3
 
-# FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
-# fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
-# metadata
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
-   lv3=$(this_test_)-test-lv3-$$          &&
-   pvcreate $d1 $d2 $d3 $d4 $d5'
-
-#
-# Duplicate vg name should cause warnings (but not segfault!)
-#
-test_expect_success \
-  "Duplicate vg name might cause warnings but should succeed" \
-  'vgcreate $vg1 $d1 &&
-   vgcreate $vg2 $d3 &&
-   losetup -d $d1 &&
-   vgcreate $vg1 $d2 &&
-   losetup $d1 $f1 &&
-   pvs &&
-   pvs'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+disable_dev $dev1
+pvscan
+vgcreate $vg1 $dev2
+enable_dev $dev1
+pvs
+pvs
--- LVM2/test/t-lvresize-usage.sh	2008/04/10 19:59:43	1.2
+++ LVM2/test/t-lvresize-usage.sh	2008/09/29 16:02:49	1.3
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -9,47 +8,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test lvresize command options for validity'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
+aux prepare_vg 2
 
-cleanup_()
-{
-  test -n "$vg" && {
-    vgchange -an "$vg"
-    lvremove -ff "$vg"
-    vgremove "$vg"
-  } > "$test_dir_/cleanup.log"
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  rm -f "$f1" "$f2"
-}
+lvcreate -L 10M -n lv -i2 $vg
+lvresize -l +4 $vg/lv
+lvremove -ff $vg
 
-test_expect_success \
-  'set up temp files, loopback devices, PVs, and a VG' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   pvcreate $d1 $d2                       &&
-   vg=$(this_test_)-test-vg-$$            &&
-   vgcreate $vg $d1 $d2'
-
-lv=lvresize-usage-$$
-
-test_expect_success \
-  'lvresize normal operation succeeds' \
-  'lvcreate -L 64M -n $lv -i2 $vg &&
-   lvresize -l +4 $vg/$lv && 
-   lvremove -ff $vg'
-
-test_expect_success \
-  'lvresize rejects an invalid vgname' \
-  'lvcreate -L 64M -n $lv -i2 $vg &&
-   lvresize -v -l +4 xxx/$lv &&
-   echo status=$?; test $? = 5 &&
-   lvremove -ff $vg'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+lvcreate -L 64M -n $lv -i2 $vg
+not lvresize -v -l +4 xxx/$lv
--- LVM2/test/t-mirror-lvconvert.sh	2008/04/23 18:27:59	1.3
+++ LVM2/test/t-mirror-lvconvert.sh	2008/09/29 16:02:49	1.4
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
@@ -10,57 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure that lvconvert for mirrored LV works"
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
-
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
-vg=mirror-lvconvert-vg-$$
-lv1=lv1
-lv2=lv2
-lv3=lv3
-
-# ---------------------------------------------------------------------
-# Utilities
-
-pv_()
-{
-  echo "$G_dev_/mapper/pv$1"
-}
-
-lvdev_()
-{
-  echo "$G_dev_/$1/$2"
-}
+dmsetup_has_dm_devdir_support_ || exit 200
 
 mimages_are_redundant_ ()
 {
@@ -90,17 +41,6 @@
   return 0
 }
 
-lv_is_clung_ ()
-{
-  local lv=$1
-
-  # if any duplication is found, it's not redundant
-  [ $(lvs -a -odevices --noheadings $lv | sed 's/([^)]*)//g' | \
-        sort | uniq | wc -l) -ne 1 ] && return 1
-
-  return 0
-}
-
 mimages_are_contiguous_ ()
 {
   local vg=$1
@@ -114,26 +54,13 @@
   return 0
 }
 
-mimages_are_clung_ ()
-{
-  local vg=$1
-  local lv=$vg/$2
-  local i
-
-  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
-    lv_is_clung_ $vg/$i || return 1
-  done
-
-  return 0
-}
-
 mirrorlog_is_on_()
 {
   local lv="$1"_mlog
   shift 1
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
   for d in $*; do grep "$d(" out || return 1; done
-  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
+  for d in $*; do grep -v "$d(" out > out2 || true; mv out2 out; done
   grep . out && return 1
   return 0
 }
@@ -176,53 +103,24 @@
   ! grep tmp out
 }
 
-# ---------------------------------------------------------------------
-# Initialize PVs and VGs
-
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
+aux prepare_vg 5
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
 prepare_lvs_()
 {
-  lvremove -ff $vg;
-  :
+  lvremove -ff $vg
 }
 
 check_and_cleanup_lvs_()
 {
-  lvs -a -o+devices $vg &&
+  lvs -a -o+devices $vg
   lvremove -ff $vg
 }
 
-test_expect_success "check environment setup/cleanup" \
-  'prepare_lvs_ &&
-   check_and_cleanup_lvs_'
+prepare_lvs_
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # mirrored LV tests
@@ -230,48 +128,48 @@
 # ---
 # add mirror to mirror
 
-test_expect_success "add 1 mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -i1 $vg/$lv1 $(pv_ 4) &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "add 2 mirrors" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+2 -i1 $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 4 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "add 1 mirror to core log mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   !(check_mirror_log_ $vg/$lv1) &&
-   lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $(pv_ 4) &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   !(check_mirror_log_ $vg/$lv1) &&
-   mimages_are_redundant_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
+# add 1 mirror
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check_mirror_count_ $vg/$lv1 2
+check_mirror_log_ $vg/$lv1
+lvconvert -m+1 -i1 $vg/$lv1 $dev4
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 3
+mimages_are_redundant_ $vg $lv1
+mirrorlog_is_on_ $vg/$lv1 $dev3
+check_and_cleanup_lvs_
+
+# add 2 mirrors
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check_mirror_count_ $vg/$lv1 2
+check_mirror_log_ $vg/$lv1
+lvconvert -m+2 -i1 $vg/$lv1 $dev4 $dev5
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 4
+mimages_are_redundant_ $vg $lv1
+mirrorlog_is_on_ $vg/$lv1 $dev3
+check_and_cleanup_lvs_
+
+# add 1 mirror to core log mirror
+prepare_lvs_
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check_mirror_count_ $vg/$lv1 2
+!(check_mirror_log_ $vg/$lv1)
+lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $dev4 &&
+check_no_tmplvs_ $vg/$lv1 &&
+check_mirror_count_ $vg/$lv1 3 &&
+!(check_mirror_log_ $vg/$lv1) &&
+mimages_are_redundant_ $vg $lv1 &&
+check_and_cleanup_lvs_
 
 test_expect_success "add 2 mirrors to core log mirror" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 &&
    check_mirror_count_ $vg/$lv1 2 &&
    !(check_mirror_log_ $vg/$lv1) &&
-   lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
+   lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $dev4 $dev5 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 4 &&
    !(check_mirror_log_ $vg/$lv1) &&
@@ -281,118 +179,118 @@
 # ---
 # add to converting mirror
 
-test_expect_success "add 1 mirror then add 1 more mirror during conversion" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
-   lvconvert -m+1 -i3 $vg/$lv1 $(pv_ 5) &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 4 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
+# add 1 mirror then add 1 more mirror during conversion
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check_mirror_count_ $vg/$lv1 2
+check_mirror_log_ $vg/$lv1
+lvconvert -m+1 -b -i100 $vg/$lv1 $dev4
+lvconvert -m+1 -i3 $vg/$lv1 $dev5
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 4
+mimages_are_redundant_ $vg $lv1
+mirrorlog_is_on_ $vg/$lv1 $dev3
+check_and_cleanup_lvs_
 
 # ---
 # add mirror and disk log
 
 test_expect_success "add 1 mirror and disk log" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 &&
    check_mirror_count_ $vg/$lv1 2 &&
    !(check_mirror_log_ $vg/$lv1) &&
-   lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $(pv_ 4) $(pv_ 3):0-1 &&
+   lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0-1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 3 &&
    check_mirror_log_ $vg/$lv1 &&
    mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
    check_and_cleanup_lvs_'
 
 # ---
 # check polldaemon restarts
 
-test_expect_success "convert inactive mirror and start polling" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
-   lvchange -ay $vg/$lv1 &&
-   wait_conversion_ $vg/$lv1 &&
-   lvs -a &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_and_cleanup_lvs_'
+# convert inactive mirror and start polling
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+check_mirror_count_ $vg/$lv1 2
+lvchange -an $vg/$lv1
+lvconvert -m+1 $vg/$lv1 $dev4
+lvchange -ay $vg/$lv1
+wait_conversion_ $vg/$lv1
+lvs -a
+check_no_tmplvs_ $vg/$lv1
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # removal during conversion
 
 test_expect_success "remove newly added mirror" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
    check_mirror_count_ $vg/$lv1 2 &&
    check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
-   lvconvert -m-1 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
+   lvconvert -m-1 $vg/$lv1 $dev4 &&
    wait_conversion_ $vg/$lv1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 2 &&
    mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
    check_and_cleanup_lvs_'
 
 test_expect_success "remove one of newly added mirrors" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
    check_mirror_count_ $vg/$lv1 2 &&
    check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+2 -b -i100 $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
-   lvconvert -m-1 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m+2 -b -i100 $vg/$lv1 $dev4 $dev5 &&
+   lvconvert -m-1 $vg/$lv1 $dev4 &&
    lvconvert -i1 $vg/$lv1 &&
    wait_conversion_ $vg/$lv1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 3 &&
    mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
    check_and_cleanup_lvs_'
 
 test_expect_success "remove from original mirror (the original is still mirror)" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5) $(pv_ 3):0-1 &&
+   lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0-1 &&
    check_mirror_count_ $vg/$lv1 3 &&
    check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
-   lvconvert -m-1 $vg/$lv1 $(pv_ 2) &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
+   lvconvert -m-1 $vg/$lv1 $dev2 &&
    lvconvert -i1 $vg/$lv1 &&
    wait_conversion_ $vg/$lv1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 3 &&
    mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
    check_and_cleanup_lvs_'
 
 test_expect_success "remove from original mirror (the original becomes linear)" \
   'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
    check_mirror_count_ $vg/$lv1 2 &&
    check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
-   lvconvert -m-1 $vg/$lv1 $(pv_ 2) &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
+   lvconvert -m-1 $vg/$lv1 $dev2 &&
    lvconvert -i1 $vg/$lv1 &&
    wait_conversion_ $vg/$lv1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 2 &&
    mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
    check_and_cleanup_lvs_'
 
 test_expect_success "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated" \
   'prepare_lvs_ &&
-   lvcreate -l`pvs --noheadings -ope_count $(pv_ 1)` -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0 &&
+   lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0 &&
    check_mirror_count_ $vg/$lv1 2 &&
    check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m0 $vg/$lv1 $(pv_ 1) &&
+   lvconvert -m0 $vg/$lv1 $dev1 &&
    check_no_tmplvs_ $vg/$lv1 &&
    check_mirror_count_ $vg/$lv1 1 &&
    check_and_cleanup_lvs_'
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/09/19 16:10:46	1.2
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/09/29 16:02:49	1.3
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
@@ -10,80 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
+dmsetup_has_dm_devdir_support_ || exit 200
 
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
-vg=mirror-vgreduce-removemissing-vg-$$
-lv1=lv1
-lv2=lv2
-lv3=lv3
-
-# ---------------------------------------------------------------------
-# Utilities
-
-pv_()
-{
-  echo "$G_dev_/mapper/pv$1"
-}
-
-fail_pv_()
-{
-  local map
-  local p
-  for p in $*; do
-    map=$(basename $p)
-    echo "Fail $map"
-    [ -e map_$map ] && return
-    dmsetup table "$map" > "map_$map"
-    echo "0 $pvsize error" | dmsetup load "$map"
-    dmsetup resume "$map"
-  done
-}
-
-recover_pv_()
-{
-  local map
-  local p
-
-  for p in $*; do
-    map=$(basename $p)
-    echo "Recover $map"
-    [ ! -e "map_$map" ] && return
-    cat "map_$map" | dmsetup load "$map"
-    dmsetup resume "$map"
-    rm "map_$map"
-  done
+pv_() {
+    eval "echo \$dev$1"
 }
 
 lv_is_on_ ()
@@ -106,7 +37,7 @@
 {
   local lv=$1
   shift
-  local pvs=$*
+  local pvs="$*"
   local mimages
   local i
 
@@ -135,6 +66,7 @@
 lv_is_linear_()
 {
   echo "Check if $1 is linear LV (i.e. not a mirror)"
+  lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
   lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep -q '^1-'
 }
 
@@ -155,31 +87,7 @@
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-test_expect_success \
-  'set up temp file and loopback device' \
-  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
-
-offset=1
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
+aux prepare_vg 5
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
@@ -198,7 +106,7 @@
 
 recover_vg_()
 {
-  recover_pv_ $* &&
+  enable_dev $* &&
   pvcreate -ff $* &&
   vgextend $vg $* &&
   check_and_cleanup_lvs_
@@ -211,16 +119,17 @@
 # ---------------------------------------------------------------------
 # one of mirror images has failed
 
-test_expect_success "basic: fail the 2nd mirror image of 2-way mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 3) &&
-   fail_pv_ $(pv_ 2) &&
-   vgreduce --removemissing --force $vg &&
-   lv_is_linear_ $lv1 &&
-   lv_is_on_ $lv1 $(pv_ 1)'
+# basic: fail the 2nd mirror image of 2-way mirrored LV
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1
+lvchange -an $vg/$lv1
+aux mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2)
+mirrorlog_is_on_ $lv1 $(pv_ 3)
+disable_dev $(pv_ 2)
+vgreduce --removemissing --force $vg
+lv_is_linear_ $lv1
+lv_is_on_ $lv1 $(pv_ 1)
+
 test_expect_success "cleanup" \
   'recover_vg_ $(pv_ 2)'
 
@@ -233,23 +142,23 @@
 {
    local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 4) &&
-   fail_pv_ $(pv_ $index) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   mimages_are_on_ $lv1 $(rest_pvs_ $index 3) &&
+   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1
+   lvchange -an $vg/$lv1
+   aux mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3)
+   mirrorlog_is_on_ $lv1 $(pv_ 4)
+   disable_dev $(pv_ $index)
+   vgreduce --removemissing --force $vg
+   lvs -a -o+devices $vg
+   cat $G_root_/etc/lvm.conf
+   mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
    mirrorlog_is_on_ $lv1 $(pv_ 4)
 }
 
 for n in $(seq 1 3); do
-  test_expect_success "fail mirror image $(($n - 1)) of 3-way mirrored LV" \
-    "prepare_lvs_ &&
-     test_3way_mirror_fail_1_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(pv_ $n)"
+    # fail mirror image $(($n - 1)) of 3-way mirrored LV" \
+    prepare_lvs_
+    test_3way_mirror_fail_1_ $n
+    recover_vg_ $(pv_ $n)
 done
 
 # ---------------------------------------------------------------------
@@ -261,23 +170,23 @@
 {
    local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 4) &&
-   fail_pv_ $(rest_pvs_ $index 3) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   lv_is_linear_ $lv1 &&
+   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1
+   lvchange -an $vg/$lv1
+   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3)
+   mirrorlog_is_on_ $lv1 $(pv_ 4)
+   rest_pvs_ $index 3
+   disable_dev $(rest_pvs_ $index 3)
+   vgreduce --force --removemissing $vg
+   lvs -a -o+devices $vg
+   aux lv_is_linear_ $lv1
    lv_is_on_ $lv1 $(pv_ $index)
 }
 
 for n in $(seq 1 3); do
-  test_expect_success "fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV" \
-    "prepare_lvs_ &&
-     test_3way_mirror_fail_2_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(rest_pvs_ $n 3)"
+    # fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
+    prepare_lvs_
+    test_3way_mirror_fail_2_ $n
+    recover_vg_ $(rest_pvs_ $n 3)
 done
 
 # ---------------------------------------------------------------------
@@ -294,7 +203,7 @@
    lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ $index) &&
+   disable_dev $(pv_ $index) &&
    vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
@@ -323,7 +232,7 @@
    lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(rest_pvs_ $index 4) &&
+   disable_dev $(rest_pvs_ $index 4) &&
    vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
@@ -352,7 +261,7 @@
    lvconvert -m+2 $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ $index) &&
+   disable_dev $(pv_ $index) &&
    vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
@@ -381,7 +290,7 @@
    lvconvert -m+2 $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(rest_pvs_ $index 4) &&
+   disable_dev $(rest_pvs_ $index 4) &&
    vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
@@ -405,7 +314,7 @@
    lvchange -an $vg/$lv1 &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ 5) &&
+   disable_dev $(pv_ 5) &&
    vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
@@ -419,7 +328,7 @@
    lvconvert -m+1 $vg/$lv1 $(pv_ 3) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ 5) &&
+   disable_dev $(pv_ 5) &&
    vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
@@ -435,7 +344,7 @@
    lvchange -an $vg/$lv1 &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ 1) $(pv_ 2) &&
+   disable_dev $(pv_ 1) $(pv_ 2) &&
    vgreduce --removemissing --force $vg &&
    ! lvs $vg/$lv1'
 test_expect_success "cleanup" \
@@ -448,7 +357,7 @@
    lvconvert -m+1 $vg/$lv1 $(pv_ 3) &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   fail_pv_ $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
+   disable_dev $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    vgreduce --removemissing --force $vg &&
    ! lvs $vg/$lv1'
 test_expect_success "cleanup" \
@@ -467,7 +376,7 @@
    mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
-   fail_pv_ $(pv_ 2) &&
+   disable_dev $(pv_ 2) &&
    vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
@@ -486,8 +395,8 @@
    mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
-   fail_pv_ $(pv_ 2) &&
-   fail_pv_ $(pv_ 4) &&
+   disable_dev $(pv_ 2) &&
+   disable_dev $(pv_ 4) &&
    vgreduce --removemissing --force $vg &&
    lv_is_linear_ $lv1 &&
    lv_is_on_ $lv1 $(pv_ 1) &&
--- LVM2/test/t-000-basic.sh	2008/07/29 21:05:02	1.3
+++ LVM2/test/t-000-basic.sh	2008/09/29 16:02:49	1.4
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -9,32 +8,18 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Basics: see if tools are built, etc.'
+. ./test-utils.sh
 
-. ./test-lib.sh
-
-lvm version >/dev/null 2>&1
-if test $? != 0; then
-    echo >&2 'You do not seem to have built lvm yet.'
-    exit 1
-fi
+lvm version
 
 v=$abs_top_srcdir/tools/version.h
-test_expect_success \
-  "get version string from $v" \
-  'sed -n "/#define LVM_VERSION ./s///p" '"$v"'|sed "s/ .*//" > expected'
-
-test_expect_success \
-  'get version of a just-built binary, ensuring PATH is set properly' \
-  'lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual'
-
-test_expect_success \
-  'ensure they are the same' \
-  'diff -u actual expected'
+sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
 
-# Need mdadm for some pvcreate tests
-test_expect_success \
-  'verify mdadm is installed and in path (needed for pvcreate tests)' \
-  'which mdadm'
+lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
 
-test_done
+# ensure they are the same
+diff -u actual expected
+
+# Need mdadm for some pvcreate tests
+# verify mdadm is installed and in path (needed for pvcreate tests) ... is it?
+which mdadm
--- LVM2/test/t-pool-labels.sh	2008/08/05 12:33:41	1.1
+++ LVM2/test/t-pool-labels.sh	2008/09/29 16:02:49	1.2
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -9,41 +8,30 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test lvm functionality with GFS pool labels'
-privileges_required_=1
-
-. ./test-lib.sh
-
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  rm -f "$f1" "$f2"
-}
+. ./test-utils.sh
 
 # create the old GFS pool labeled linear devices
 create_pool_label_()
 {
-  echo -en "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
-  echo -en "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
+  # FIXME
+  # echo -e is bashism, dash builtin sh doesn't do \xNN in printf either
+  # printf comes from coreutils, and is probably not posix either
+  env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
+  env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
 }
 
-test_expect_success "set up temp files, loopback devices, pool labels" \
-  'f1=$(pwd)/0 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/1 && d2=$(loop_setup_ "$f2") &&
-   create_pool_label_ 0 "$d1"             &&
-   create_pool_label_ 1 "$d2"'
-
-test_expect_failure "check that pvcreate fails without -ff on the pool device" \
-  'pvcreate "$d1"'
-
-test_expect_success "check that vgdisplay and pvcreate -ff works with the pool device" \
-  'vgdisplay                         &&
-   test -n "$d2" && losetup -d "$d2" &&
-   vgdisplay                         &&
-   pvcreate -ff -y "$d1"'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+env printf "" || exit 200 # skip if printf is not available
+
+aux prepare_devs 2
+
+create_pool_label_ 0 "$dev1"
+create_pool_label_ 1 "$dev2"
+
+# check that pvcreate fails without -ff on the pool device
+not pvcreate "$dev1"
+
+# check that vgdisplay and pvcreate -ff works with the pool device
+vgdisplay
+disable_dev "$dev2"
+vgdisplay
+pvcreate -ff -y "$dev1"
--- LVM2/test/t-metadata.sh	2008/08/13 13:49:07	1.1
+++ LVM2/test/t-metadata.sh	2008/09/29 16:02:49	1.2
@@ -1,5 +1,4 @@
-#!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,60 +8,28 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-#
-# tests basic functionality of read-ahead and ra regressions
-#
-
-test_description='Test --metadatatype 1'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
+aux prepare_devs 5
 
-cleanup_()
-{
-   vgremove -f "$vg"
-   test -n "$d1" && losetup -d "$d1"
-   test -n "$d2" && losetup -d "$d2"
-   test -n "$d3" && losetup -d "$d3"
-   test -n "$d4" && losetup -d "$d4"
-   test -n "$d5" && losetup -d "$d5"
-   rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
-}
-
-test_expect_success "set up temp files, loopback devices" \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   lv=$(this_test_)-test-lv-$$
-   pvcreate "$d1"                                    &&
-   pvcreate --metadatacopies 0 "$d2"                 &&
-   pvcreate --metadatacopies 0 "$d3"                 &&
-   pvcreate "$d4"                                    &&
-   pvcreate --metadatacopies 0 "$d5"                 &&
-   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
-   lvcreate -n "$lv" -l 1%FREE -i5 -I256 "$vg"'
-
-test_expect_success "test medatasize 0" \
-  'pvchange -x n "$d1"   &&
-   pvchange -x y "$d1"   &&
-   vgchange -a n "$vg"   &&
-   pvchange --uuid "$d1" &&
-   pvchange --uuid "$d2" &&
-   vgremove -f "$vg"'
-
-
-test_expect_success "test metadatatype 1" \
-  'pvcreate -M1 "$d1"    &&
-   pvcreate -M1 "$d2"    &&
-   pvcreate -M1 "$d3"    &&
-   vgcreate -M1 "$vg" "$d1" "$d2" "$d3" &&
-   pvchange --uuid "$d1"'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --metadatacopies 0 $dev5
+
+vgcreate -c n "$vg" $devs
+lvcreate -n $lv -l 1 -i5 -I256 $vg
+
+pvchange -x n $dev1
+pvchange -x y $dev1
+vgchange -a n $vg
+pvchange --uuid $dev1
+pvchange --uuid $dev2
+vgremove -f $vg
+
+pvcreate -M1 $dev1
+pvcreate -M1 $dev2
+pvcreate -M1 $dev3
+vgcreate -M1 $vg $dev1 $dev2 $dev3
+pvchange --uuid $dev1
--- LVM2/test/t-covercmd.sh	2008/08/20 13:34:33	1.3
+++ LVM2/test/t-covercmd.sh	2008/09/29 16:02:50	1.4
@@ -1,4 +1,3 @@
-#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -13,21 +12,7 @@
 # tests basic functionality of read-ahead and ra regressions
 #
 
-test_description='Test coverage'
-privileges_required_=1
-
-. ./test-lib.sh
-
-cleanup_()
-{
-  vgremove -f "$vg" 2>/dev/null || true
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  test -n "$d5" && losetup -d "$d5"
-  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
-}
+. ./test-utils.sh
 
 get_lvs_()
 {
@@ -37,63 +22,56 @@
   esac
 }
 
-test_expect_success "set up temp files, loopback devices" \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   lv=$(this_test_)-test-lv-$$
-   pvcreate "$d1"                                    &&
-   pvcreate --metadatacopies 0 "$d2"                 &&
-   pvcreate --metadatacopies 0 "$d3"                 &&
-   pvcreate "$d4"                                    &&
-   pvcreate --metadatacopies 0 "$d5"                 &&
-   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
-   lvcreate -n "$lv" -l 1%FREE -i5 -I256 "$vg"'
-
-test_expect_success "test *scan and *display tools" \
-  'pvscan              &&
-   vgscan              &&
-   lvscan              &&
-   lvmdiskscan         &&
-   vgdisplay --units k &&
-   lvdisplay --units g &&
-   for i in b k m g t p e H B K M G T P E ; do \
-     pvdisplay --units "$i" "$d1" || return $? ; done'
-
-test_expect_success "test vgexport vgimport tools" \
-  'vgchange -an "$vg"  &&
-   vgexport "$vg"      &&
-   vgimport "$vg"      &&
-   vgchange -ay "$vg"'
+prepare_devs 5
+
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --metadatacopies 0 $dev5
+vgcreate -c n $vg $devs
+lvcreate -n $lv -l 5 -i5 -I256 $vg
+
+# test *scan and *display tools
+pvscan
+vgscan
+lvscan
+lvmdiskscan
+vgdisplay --units k
+lvdisplay --units g
+for i in b k m g t p e H B K M G T P E ; do
+    pvdisplay --units "$i" "$dev1"
+done
+
+# test vgexport vgimport tools
+vgchange -an $vg
+vgexport $vg
+vgimport $vg
+vgchange -ay $vg
 
 # "-persistent y --major 254 --minor 20"
 # "-persistent n"
-test_expect_success "test various lvm utils" \
-  'for i in dumpconfig formats segtypes 
-     do lvm "$i" || return $? ; done                 &&
-   for i in pr "p rw" an ay "-monitor y" "-monitor n" \
-     -resync -refresh "-addtag MYTAG" "-deltag MYETAG"
-     do lvchange -$i "$vg"/"$lv" || return $? ; done &&
-   pvck "$d1"                                        &&
-   vgck "$vg"                                        &&
-   lvrename "$vg" "$lv" "$lv-rename"                 &&
-   vgcfgbackup -f "$(pwd)/backup.$$" "$vg"           &&
-   vgchange -an "$vg"                                &&
-   vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"         &&
-   vgremove -f "$vg"                                 &&
-   pvresize --setphysicalvolumesize 10M "$d1"'
-
-test_expect_failure "test various errors and obsoleted tools" \
-  'lvmchange          ||
-   lvrename "$vg"     ||
-   lvrename "$vg-xxx" ||
-   lvrename "$vg"  "$vg"/"$lv-rename" "$vg"/"$lv"'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# test various lvm utils
+for i in dumpconfig formats segtypes; do
+    lvm "$i"
+done
+
+for i in pr "p rw" an ay "-monitor y" "-monitor n" \
+        -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
+    lvchange -$i "$vg"/"$lv"
+done
+
+pvck "$d1"
+vgck "$vg"
+lvrename "$vg" "$lv" "$lv-rename"
+vgcfgbackup -f "$(pwd)/backup.$$" "$vg"
+vgchange -an "$vg"
+vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
+vgremove -f "$vg"
+pvresize --setphysicalvolumesize 10M "$dev1"
+
+# test various errors and obsoleted tools
+not lvmchange
+not lvrename "$vg"
+not lvrename "$vg-xxx"
+not lvrename "$vg"  "$vg"/"$lv-rename" "$vg"/"$lv"
--- LVM2/test/t-pvcreate-operation.sh	2008/08/28 10:07:34	1.9
+++ LVM2/test/t-pvcreate-operation.sh	2008/09/29 16:02:50	1.10
@@ -1,5 +1,4 @@
-#!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,134 +8,96 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test pvcreate logic operation'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
-
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
+aux prepare_devs 4
 
 for mdatype in 1 2
 do
 
-test_expect_success \
-  "pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg)" '
-   pvcreate -M$mdatype $d1 &&
-   pvcreate -M$mdatype $d1 &&
-   pvremove -f $d1
-'
-
-test_expect_success \
-  "pvcreate (lvm$mdatype) fails when PV belongs to VG" \
-  'pvcreate -M$mdatype $d1 &&
-   vgcreate -M$mdatype $vg1 $d1 &&
-   pvcreate -M$mdatype $d1;
-   status=$?; echo status=$status; test $status != 0 &&
-   vgremove -f $vg1 &&
-   pvremove -f $d1'
-
-test_expect_success \
-  "pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG" \
-  'pvcreate -M$mdatype $d1 &&
-   pvcreate -M$mdatype $d2 &&
-   vgcreate -M$mdatype $vg1 $d1 &&
-   echo pvcreate a second time on $d2 and $d1 &&
-   pvcreate -M$mdatype $d2 $d1;
-   status=$?; echo status=$status; test $status != 0 &&
-   vgremove -f $vg1 &&
-   pvremove -f $d2 &&
-   pvremove -f $d1'
+# pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg)
+    pvcreate -M$mdatype $dev1
+    pvcreate -M$mdatype $dev1
+    pvremove -f $dev1
+
+# pvcreate (lvm$mdatype) fails when PV belongs to VG" \
+    pvcreate -M$mdatype $dev1
+    vgcreate -M$mdatype $vg1 $dev1
+    not pvcreate -M$mdatype $dev1
+
+    vgremove -f $vg1
+    pvremove -f $dev1
+
+# pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG
+    pvcreate -M$mdatype $dev1
+    pvcreate -M$mdatype $dev2
+    vgcreate -M$mdatype $vg1 $dev1
+
+# pvcreate a second time on $dev2 and $dev1
+    not pvcreate -M$mdatype $dev2 $dev1
+
+    vgremove -f $vg1
+    pvremove -f $dev2
+    pvremove -f $dev1
 
 # NOTE: Force pvcreate after test completion to ensure clean device
 #test_expect_success \
 #  "pvcreate (lvm$mdatype) fails on md component device" \
-#  'mdadm -C -l raid0 -n 2 /dev/md0 $d1 $d2 &&
-#   pvcreate -M$mdatype $d1;
+#  'mdadm -C -l raid0 -n 2 /dev/md0 $dev1 $dev2 &&
+#   pvcreate -M$mdatype $dev1;
 #   status=$?; echo status=$status; test $status != 0 &&
 #   mdadm --stop /dev/md0 &&
-#   pvcreate -ff -y -M$mdatype $d1 $d2 &&
-#   pvremove -f $d1 $d2'
+#   pvcreate -ff -y -M$mdatype $dev1 $dev2 &&
+#   pvremove -f $dev1 $dev2'
 done
 
-test_expect_success \
-  'pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG' \
-  'pvcreate --metadatacopies 0 $d1 &&
-   pvcreate --metadatacopies 1 $d2 &&
-   vgcreate $vg1 $d1 $d2 &&
-   pvcreate $d1;
-   status=$?; echo status=$status; test $status != 0 &&
-   vgremove -f $vg1 &&
-   pvremove -f $d2 &&
-   pvremove -f $d1'
+# pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG
+pvcreate --metadatacopies 0 $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate $vg1 $dev1 $dev2
+not pvcreate $dev1
+vgremove -f $vg1
+pvremove -f $dev2
+pvremove -f $dev1
 
 test_expect_success \
   'pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG' \
-  'pvcreate --metadatacopies 0 $d1 &&
-   pvcreate --metadatacopies 1 $d2 &&
-   vgcreate $vg1 $d1 $d2 &&
-   pvcreate -ff -y $d1 &&
+  'pvcreate --metadatacopies 0 $dev1 &&
+   pvcreate --metadatacopies 1 $dev2 &&
+   vgcreate $vg1 $dev1 $dev2 &&
+   pvcreate -ff -y $dev1 &&
    vgreduce --removemissing $vg1 &&
    vgremove -ff $vg1 &&
-   pvremove -f $d2 &&
-   pvremove -f $d1'
+   pvremove -f $dev2 &&
+   pvremove -f $dev1'
 
 for i in 0 1 2 3 
 do
- test_expect_success \
-  "pvcreate (lvm2) succeeds writing LVM label at sector $i" \
-  'pvcreate --labelsector $i $d1 &&
-  dd if=$d1 bs=512 skip=$i count=1 status=noxfer 2>&1 | strings | grep -q LABELONE;
-  test $? == 0 &&
-  pvremove -f $d1'
+# pvcreate (lvm2) succeeds writing LVM label at sector $i
+    pvcreate --labelsector $i $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 status=noxfer 2>&1 | strings | grep -q LABELONE;
+    pvremove -f $dev1
 done
 
-test_expect_failure \
-  "pvcreate (lvm2) fails writing LVM label at sector 4" \
-  'pvcreate --labelsector 4 $d1'
+# pvcreate (lvm2) fails writing LVM label at sector 4
+not pvcreate --labelsector 4 $dev1
 
 backupfile=mybackupfile-$(this_test_)
 uuid1=freddy-fred-fred-fred-fred-fred-freddy
 uuid2=freddy-fred-fred-fred-fred-fred-fredie
 bogusuuid=fred
 
-test_expect_failure \
-  'pvcreate rejects uuid option with less than 32 characters' \
-  'pvcreate --uuid $bogusuuid $d1'
-
-test_expect_success \
-  'pvcreate rejects uuid already in use' \
-  'pvcreate --uuid $uuid1 $d1 &&
-   pvcreate --uuid $uuid1 $d2;
-   status=$?; echo status=$status; test $status != 0'
+# pvcreate rejects uuid option with less than 32 characters
+not pvcreate --uuid $bogusuuid $dev1
 
-test_expect_success \
-  'pvcreate rejects non-existent file given with restorefile' \
-  'pvcreate --uuid $uuid1 --restorefile $backupfile $d1;
-   status=$?; echo status=$status; test $status != 0'
-
-test_expect_success \
-  'pvcreate rejects restorefile with uuid not found in file' \
-  'pvcreate --uuid $uuid1 $d1 &&
-   vgcfgbackup -f $backupfile &&
-   pvcreate --uuid $uuid2 --restorefile $backupfile $d2;
-   status=$?; echo status=$status; test $status != 0'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# pvcreate rejects uuid already in use
+pvcreate --uuid $uuid1 $dev1
+not pvcreate --uuid $uuid1 $dev2
+
+# pvcreate rejects non-existent file given with restorefile
+not pvcreate --uuid $uuid1 --restorefile $backupfile $dev1
+
+# pvcreate rejects restorefile with uuid not found in file
+pvcreate --uuid $uuid1 $dev1
+vgcfgbackup -f $backupfile
+not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
--- LVM2/test/t-vgrename-usage.sh	2008/08/28 10:59:10	1.2
+++ LVM2/test/t-vgrename-usage.sh	2008/09/29 16:02:50	1.3
@@ -1,5 +1,4 @@
-#!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,49 +8,22 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Exercise some vgrename diagnostics'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
-
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
-   vg1=$(this_test_)-1-$$          &&
-   vg2=$(this_test_)-2-$$          &&
-   pvcreate $d1 $d2                &&
-   pvcreate --metadatacopies 0 $d3 $d4'
-
-test_expect_success \
-  'vgrename normal operation - rename vg1 to vg2' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgrename $vg1 $vg2 &&
-   check_vg_field_ $vg2 vg_name $vg2 &&
-   vgremove $vg2'
-
-test_expect_success \
-  "vgrename by uuid (bz231187)" '
-   vgcreate $vg1 $d1 $d3 &&
-   UUID=$(vgs --noheading -o vg_uuid $vg1) &&
-   check_vg_field_ $vg1 vg_uuid $UUID &&
-   vgrename $UUID $vg2 &&
-   check_vg_field_ $vg2 vg_name $vg2 &&
-   vgremove $vg2
-'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+aux prepare_devs 4
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3 $dev4
+
+# vgrename normal operation - rename vg1 to vg2
+vgcreate $vg1 $dev1 $dev2
+vgrename $vg1 $vg2
+check_vg_field_ $vg2 vg_name $vg2
+vgremove $vg2
+
+# vgrename by uuid (bz231187)
+vgcreate $vg1 $dev1 $dev3
+UUID=$(vgs --noheading -o vg_uuid $vg1)
+check_vg_field_ $vg1 vg_uuid $UUID
+vgrename $UUID $vg2
+check_vg_field_ $vg2 vg_name $vg2
+vgremove $vg2


