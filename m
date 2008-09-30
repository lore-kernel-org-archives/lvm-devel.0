From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 17:47:35 -0000
Subject: LVM2/test t-lvcreate-usage.sh t-lvextend-perce ...
Message-ID: <20080930174735.17976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 17:47:34

Modified files:
	test           : t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 
	                 t-mdata-strings.sh t-mirror-lvconvert.sh 
	                 t-pvcreate-operation.sh 

Log message:
	More test conversions, all of these are by jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/t-lvcreate-usage.sh	2008/08/28 10:07:34	1.6
+++ LVM2/test/t-lvcreate-usage.sh	2008/09/30 17:47:34	1.7
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,82 +9,46 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Exercise some lvcreate diagnostics'
-privileges_required_=1
+# 'Exercise some lvcreate diagnostics'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
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
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, and a VG' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   pvcreate $d1 $d2                       &&
-   vg=$(this_test_)-test-vg-$$            &&
-   vgcreate $vg $d1 $d2'
-
-lv=lvcreate-usage-$$
-
-test_expect_success \
-  "lvcreate rejects repeated invocation (run 2 times)" '
-   lvcreate -n $lv -l 4 $vg && 
-   { lvcreate -n $lv -l 4 $vg;
-     status=$?; echo status=$status; test $status = 5 &&
-     lvremove -ff $vg/$lv
-   }
-'
-
-test_expect_success \
-  'lvcreate rejects a negative stripe_size' \
-  'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
-   status=$?; echo status=$status; test $status = 3 &&
-   grep "^  Negative stripesize is invalid\$" err'
-
-test_expect_success \
-  'lvcreate rejects a too-large stripesize' \
-  'lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err; test $? = 3 &&
-   grep "^  Stripe size cannot be larger than 512.00 GB\$" err'
-
-test_expect_success \
-  'lvcreate w/single stripe succeeds with diagnostics to stdout' \
-  'lvcreate -L 64M -n $lv -i1 --stripesize 4 $vg >out 2>err &&
-   grep "^  Redundant stripes argument: default is 1\$" out &&
-   grep "^  Ignoring stripesize argument with single stripe\$" out &&
-   lvdisplay $vg &&
-   lvremove -ff $vg'
-
-test_expect_success \
-  'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout' \
-  'lvcreate -L 64M -n $lv -i2 $vg > out &&
-   grep "^  Using default stripesize" out &&
-   lvdisplay $vg &&
-   check_lv_field_ $vg/$lv stripesize "64.00K" &&
-   lvremove -ff $vg'
-
-test_expect_success \
-  'lvcreate rejects an invalid number of stripes' \
-  'lvcreate -L 64M -n $lv -i129 $vg 2>err; test $? = 3 &&
-   grep "^  Number of stripes (129) must be between 1 and 128\$" err'
+aux prepare_vg 2
+
+# "lvcreate rejects repeated invocation (run 2 times)" 
+lvcreate -n $lv -l 4 $vg 
+not lvcreate -n $lv -l 4 $vg
+lvremove -ff $vg/$lv
+
+# "lvcreate rejects a negative stripe_size"
+not lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
+grep "^  Negative stripesize is invalid\$" err
+
+# 'lvcreate rejects a too-large stripesize'
+not lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err
+grep "^  Stripe size cannot be larger than 512.00 GB\$" err
+
+# 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
+lvcreate -L 64M -n $lv -i1 --stripesize 4 $vg >out 2>err 
+grep "^  Redundant stripes argument: default is 1\$" out 
+grep "^  Ignoring stripesize argument with single stripe\$" out 
+lvdisplay $vg 
+lvremove -ff $vg
+
+# 'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout'
+lvcreate -L 64M -n $lv -i2 $vg > out
+grep "^  Using default stripesize" out 
+lvdisplay $vg 
+check_lv_field_ $vg/$lv stripesize "64.00K" 
+lvremove -ff $vg
+
+# 'lvcreate rejects an invalid number of stripes' 
+not lvcreate -L 64M -n $lv -i129 $vg 2>err
+grep "^  Number of stripes (129) must be between 1 and 128\$" err
 
 # The case on lvdisplay output is to verify that the LV was not created.
-test_expect_success \
-  'lvcreate rejects an invalid stripe size' \
-  'lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err; test $? = 3 &&
-   grep "^  Invalid stripe size 3\.00 KB\$" err &&
-   case $(lvdisplay $vg) in "") true ;; *) false ;; esac'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# 'lvcreate rejects an invalid stripe size'
+not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
+grep "^  Invalid stripe size 3\.00 KB\$" err
+case $(lvdisplay $vg) in "") true ;; *) false ;; esac'
+
--- LVM2/test/t-lvextend-percent-extents.sh	2008/01/17 18:05:57	1.4
+++ LVM2/test/t-lvextend-percent-extents.sh	2008/09/30 17:47:34	1.5
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,60 +9,36 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Check extents percentage arguments'
-privileges_required_=1
+# 'Check extents percentage arguments'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$vg" && {
-    vgchange -an "$vg"
-    lvremove -ff "$vg"
-    vgremove -f "$vg"
-  } > "$test_dir_/cleanup.log"
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  rm -f "$f1" "$f2"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, and a VG' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   pvcreate $d1 $d2      &&
-   vg=$(this_test_)-test-vg-$$  &&
-   vgcreate $vg $d1 $d2 &&
-   lv=$(this_test_)-test-lv-$$ &&
-   lvcreate -L 64M -n $lv $vg'
-
-test_expect_success \
-  'lvextend rejects both size and extents without PVs' \
-  'lvextend -l 10 -L 64M $vg/$lv 2>err; test $? = 3 &&
-   grep "^  Please specify either size or extents but not both.\$" err'
-
-test_expect_success \
-  'lvextend rejects both size and extents with PVs' \
-  'lvextend -l 10 -L 64M $vg/$lv $d1 2>err; test $? = 3 &&
-   grep "^  Please specify either size or extents but not both.\$" err'
-
-test_expect_success \
-  'lvextend accepts no size or extents but one PV - bz154691' \
-  'lvextend $vg/$lv $d1 >out; test $? = 0 &&
-  grep "^  Logical volume $lv successfully resized\$" out &&
-  check_pv_field_ $d1 pv_free "0"'
-
-test_expect_success \
-  'Reset LV to original size' \
-  'lvremove -f $vg/$lv; test $? = 0 &&
-   lvcreate -L 64M -n $lv $vg; test $? = 0'
-
-test_expect_success \
-  'lvextend accepts no size but extents 100%PVS and two PVs - bz154691' \
-  'lvextend -l +100%PVS $vg/$lv $d1 $d2 >out; test $? = 0 &&
-  grep "^  Logical volume $lv successfully resized\$" out &&
-  check_pv_field_ $d1 pv_free "0" &&
-  check_pv_field_ $d2 pv_free "0"'
+aux prepare_vg 2 128
+
+lvcreate -L 64M -n $lv $vg
+
+# 'lvextend rejects both size and extents without PVs'
+not lvextend -l 10 -L 64M $vg/$lv 2>err
+grep "^  Please specify either size or extents but not both.\$" err
+
+# 'lvextend rejects both size and extents with PVs'
+not lvextend -l 10 -L 64M $vg/$lv $dev1 2>err
+grep "^  Please specify either size or extents but not both.\$" err
+
+# 'lvextend accepts no size or extents but one PV - bz154691'
+lvextend $vg/$lv $dev1 >out
+grep "^  Logical volume $lv successfully resized\$" out
+check_pv_field_ $dev1 pv_free "0"
+
+# 'Reset LV to original size' 
+lvremove -f $vg/$lv 
+lvcreate -L 64M -n $lv $vg
+
+# 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
+lvextend -l +100%PVS $vg/$lv $dev1 $dev2 >out
+grep "^  Logical volume $lv successfully resized\$" out 
+check_pv_field_ $dev1 pv_free "0" 
+check_pv_field_ $dev2 pv_free "0"
 
 # Exercise the range overlap code.  Allocate every 2 extents.
 #
@@ -84,22 +60,15 @@
 # Total number of extents should be 12 + overlap = 12 + 6 = 18.
 # Thus, total size for the LV should be 18 * 4M = 72M
 #
-test_expect_success \
-  'Reset LV to 12 extents, allocate every other 2 extents' \
-  'create_pvs=`for i in $(seq 0 4 20); do echo -n "\$d1:$i-$(($i + 1)) "; done` &&
-   lvremove -f $vg/$lv; test $? = 0 &&
-   lvcreate -l 12 -n $lv $vg $create_pvs; test $? = 0 &&
-   check_lv_field_ $vg/$lv lv_size "48.00M"'
-
-test_expect_success \
-  'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' \
-  'extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$d1:$i-$(($i + 2)) "; done` &&
-  lvextend -l +100%PVS $vg/$lv $extend_pvs >out; test $? = 0 &&
-  grep "^  Logical volume $lv successfully resized\$" out &&
-  check_lv_field_ $vg/$lv lv_size "72.00M"'
-
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# 'Reset LV to 12 extents, allocate every other 2 extents' 
+create_pvs=`for i in $(seq 0 4 20); do echo -n "\$dev1:$i-$(($i + 1)) "; done` 
+lvremove -f $vg/$lv
+lvcreate -l 12 -n $lv $vg $create_pvs
+check_lv_field_ $vg/$lv lv_size "48.00M"
+
+# 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' 
+extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$dev1:$i-$(($i + 2)) "; done` 
+lvextend -l +100%PVS $vg/$lv $extend_pvs >out
+grep "^  Logical volume $lv successfully resized\$" out 
+check_lv_field_ $vg/$lv lv_size "72.00M"
+
--- LVM2/test/t-mdata-strings.sh	2008/04/10 01:06:48	1.2
+++ LVM2/test/t-mdata-strings.sh	2008/09/30 17:47:34	1.3
@@ -9,43 +9,25 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test for proper escaping of strings in metadata (bz431474)'
-privileges_required_=1
+# 'Test for proper escaping of strings in metadata (bz431474)'
 
-. ./test-lib.sh
+. ./test-utils.sh
 
-cleanup_()
-{
-  test -n "$vg" && {
-    vgchange -an "$vg"
-    vgremove "$vg"
-  } > "$test_dir_/cleanup.log"
-  test -n "$d1" && losetup -d "$d1"
-  rm -f "$f1"
-}
+aux prepare_devs 1
 
 pv_suffix="__\"!@#\$%^&*()'\\\"__"
 
-test_expect_success \
-  'set up temp files, loopback devices' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-  mv "$d1" "$d1$pv_suffix"                &&
-  d1=$d1$pv_suffix'
-
-test_expect_success \
-  'pvcreate, vgcreate on filename with backslashed chars' \
-  'pvcreate "$d1"                          &&
-  vg=$(this_test_)-test-vg-$$              &&
-  vgcreate $vg $d1'
-  
-test_expect_success \
-  'no parse errors and VG really exists' \
-  'vgs 2>err                                    &&
-  grep "Parse error" err;
-  status=$?; echo status=$status; test $status -ne 0 &&
-  vgs $vg'
-
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# 'set up temp files, loopback devices' 
+name=$(basename "$dev1")
+dmsetup rename "$name" "$name$pv_suffix" 
+dev1=$(dirname "$dev1")/$name$pv_suffix
+
+# 'pvcreate, vgcreate on filename with backslashed chars' 
+pvcreate "$dev1" 
+vgcreate $vg "$dev1"
+
+# 'no parse errors and VG really exists' 
+vgs 2>err
+not grep "Parse error" err;
+vgs $vg
+
--- LVM2/test/t-mirror-lvconvert.sh	2008/09/29 16:02:49	1.4
+++ LVM2/test/t-mirror-lvconvert.sh	2008/09/30 17:47:34	1.5
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -156,25 +156,25 @@
 prepare_lvs_
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 check_mirror_count_ $vg/$lv1 2
-!(check_mirror_log_ $vg/$lv1)
-lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $dev4 &&
-check_no_tmplvs_ $vg/$lv1 &&
-check_mirror_count_ $vg/$lv1 3 &&
-!(check_mirror_log_ $vg/$lv1) &&
-mimages_are_redundant_ $vg $lv1 &&
-check_and_cleanup_lvs_
-
-test_expect_success "add 2 mirrors to core log mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   !(check_mirror_log_ $vg/$lv1) &&
-   lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $dev4 $dev5 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 4 &&
-   !(check_mirror_log_ $vg/$lv1) &&
-   mimages_are_redundant_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
+not check_mirror_log_ $vg/$lv1
+lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $dev4 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 3 
+not check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1 
+check_and_cleanup_lvs_
+
+# add 2 mirrors to core log mirror" 
+prepare_lvs_ 
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+check_mirror_count_ $vg/$lv1 2 
+not check_mirror_log_ $vg/$lv1 
+lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $dev4 $dev5 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 4 
+not check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1 
+check_and_cleanup_lvs_
 
 # ---
 # add to converting mirror
@@ -195,18 +195,18 @@
 # ---
 # add mirror and disk log
 
-test_expect_success "add 1 mirror and disk log" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   !(check_mirror_log_ $vg/$lv1) &&
-   lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0-1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   check_mirror_log_ $vg/$lv1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
-   check_and_cleanup_lvs_'
+# "add 1 mirror and disk log" 
+prepare_lvs_ 
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+check_mirror_count_ $vg/$lv1 2 
+not check_mirror_log_ $vg/$lv1 
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0-1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 3 
+check_mirror_log_ $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
 
 # ---
 # check polldaemon restarts
@@ -226,75 +226,74 @@
 # ---------------------------------------------------------------------
 # removal during conversion
 
-test_expect_success "remove newly added mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
-   lvconvert -m-1 $vg/$lv1 $dev4 &&
-   wait_conversion_ $vg/$lv1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "remove one of newly added mirrors" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+2 -b -i100 $vg/$lv1 $dev4 $dev5 &&
-   lvconvert -m-1 $vg/$lv1 $dev4 &&
-   lvconvert -i1 $vg/$lv1 &&
-   wait_conversion_ $vg/$lv1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "remove from original mirror (the original is still mirror)" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0-1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
-   lvconvert -m-1 $vg/$lv1 $dev2 &&
-   lvconvert -i1 $vg/$lv1 &&
-   wait_conversion_ $vg/$lv1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 3 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "remove from original mirror (the original becomes linear)" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 &&
-   lvconvert -m-1 $vg/$lv1 $dev2 &&
-   lvconvert -i1 $vg/$lv1 &&
-   wait_conversion_ $vg/$lv1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $dev3 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated" \
-  'prepare_lvs_ &&
-   lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0 &&
-   check_mirror_count_ $vg/$lv1 2 &&
-   check_mirror_log_ $vg/$lv1 &&
-   lvconvert -m0 $vg/$lv1 $dev1 &&
-   check_no_tmplvs_ $vg/$lv1 &&
-   check_mirror_count_ $vg/$lv1 1 &&
-   check_and_cleanup_lvs_'
+# "remove newly added mirror" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+check_mirror_count_ $vg/$lv1 2 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev4 
+wait_conversion_ $vg/$lv1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 2 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+# "remove one of newly added mirrors" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+check_mirror_count_ $vg/$lv1 2 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m+2 -b -i100 $vg/$lv1 $dev4 $dev5 
+lvconvert -m-1 $vg/$lv1 $dev4 
+lvconvert -i1 $vg/$lv1 
+wait_conversion_ $vg/$lv1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 3 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+# "remove from original mirror (the original is still mirror)"
+prepare_lvs_ 
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0-1 
+check_mirror_count_ $vg/$lv1 3 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert -i1 $vg/$lv1 
+wait_conversion_ $vg/$lv1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 3 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+# "remove from original mirror (the original becomes linear)"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+check_mirror_count_ $vg/$lv1 2 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert -i1 $vg/$lv1 
+wait_conversion_ $vg/$lv1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 2 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+# "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
+prepare_lvs_ 
+lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0 
+check_mirror_count_ $vg/$lv1 2 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m0 $vg/$lv1 $dev1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 1 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
-test_done
--- LVM2/test/t-pvcreate-operation.sh	2008/09/29 16:02:50	1.10
+++ LVM2/test/t-pvcreate-operation.sh	2008/09/30 17:47:34	1.11
@@ -60,18 +60,17 @@
 pvremove -f $dev2
 pvremove -f $dev1
 
-test_expect_success \
-  'pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG' \
-  'pvcreate --metadatacopies 0 $dev1 &&
-   pvcreate --metadatacopies 1 $dev2 &&
-   vgcreate $vg1 $dev1 $dev2 &&
-   pvcreate -ff -y $dev1 &&
-   vgreduce --removemissing $vg1 &&
-   vgremove -ff $vg1 &&
-   pvremove -f $dev2 &&
-   pvremove -f $dev1'
+# pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG
+pvcreate --metadatacopies 0 $dev1 
+pvcreate --metadatacopies 1 $dev2
+vgcreate $vg1 $dev1 $dev2 
+pvcreate -ff -y $dev1 
+vgreduce --removemissing $vg1 
+vgremove -ff $vg1 
+pvremove -f $dev2 
+pvremove -f $dev1
 
-for i in 0 1 2 3 
+for i in 0 1 2 3
 do
 # pvcreate (lvm2) succeeds writing LVM label at sector $i
     pvcreate --labelsector $i $dev1


