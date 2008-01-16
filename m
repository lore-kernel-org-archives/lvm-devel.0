From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jan 2008 21:21:24 -0000
Subject: LVM2/test lvm-utils.sh Makefile.in t-vgmerge-u ...
Message-ID: <20080116212124.19241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-16 21:21:23

Modified files:
	test           : lvm-utils.sh Makefile.in t-vgmerge-usage.sh 
	                 t-vgsplit-operation.sh 
Added files:
	test           : t-mirror-basic.sh t-mirror-lvconvert.sh 
	                 t-pvmove-basic.sh 

Log message:
	Fix 'make check' runnable with recent versions of dmsetup.
	Fix 'make check' to use DMDIR to check DM_DEV_DIR support in dmsetup.
	Add basic test cases for mirrored LV.
	Add basic test cases for lvconvert mirror.
	Add basic test cases for pvmove.
	Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
	
	Add new vgsplit and vgmerge tests.
	Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

/cvs/lvm2/LVM2/test/t-mirror-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-mirror-basic.sh
+++ -	2008-01-16 21:21:23.374333000 +0000
@@ -0,0 +1,307 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that pvmove works with basic options"
+privileges_required_=1
+
+. ./test-lib.sh
+
+dmsetup_has_dm_devdir_support_ ||
+{
+  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
+  say "Skipping this test"
+  exit 0
+}
+
+cleanup_()
+{
+  test -n "$vg" && {
+    lvremove -ff $vg
+    vgremove $vg
+  } > /dev/null
+  test -n "$pvs" && {
+    pvremove $pvs > /dev/null
+    for d in $pvs; do
+      dmsetup remove $(basename $d)
+    done
+  }
+  losetup -d $lodev
+  rm -f $lofile
+}
+
+# ---------------------------------------------------------------------
+# config
+
+nr_pvs=5
+pvsize=$((80 * 1024 * 2))
+
+vg=mirror-basic-vg-$$
+lv1=lv1
+lv2=lv2
+lv3=lv3
+
+# ---------------------------------------------------------------------
+# Utilities
+
+pv_()
+{
+  echo "$G_dev_/mapper/pv$1"
+}
+
+lvdev_()
+{
+  echo "$G_dev_/$1/$2"
+}
+
+mimages_are_redundant_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  rm -f out
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lvs -a -odevices --noheadings $vg/$i | sed 's/([^)]*)//g; s/,/ /g' | \
+      sort | uniq >> out
+  done
+
+  # if any duplication is found, it's not redundant
+  sort out | uniq -d | grep . && return 1
+
+  return 0
+}
+
+lv_is_contiguous_ ()
+{
+  local lv=$1
+
+  # if the lv has multiple segments, it's not contiguous
+  [ $(lvs -a --segments --noheadings $lv | wc -l) -ne 1 ] && return 1
+
+  return 0
+}
+
+lv_is_clung_ ()
+{
+  local lv=$1
+
+  # if any duplication is found, it's not redundant
+  [ $(lvs -a -odevices --noheadings $lv | sed 's/([^)]*)//g' | \
+        sort | uniq | wc -l) -ne 1 ] && return 1
+
+  return 0
+}
+
+mimages_are_contiguous_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lv_is_contiguous_ $vg/$i || return 1
+  done
+
+  return 0
+}
+
+mimages_are_clung_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lv_is_clung_ $vg/$i || return 1
+  done
+
+  return 0
+}
+
+mirrorlog_is_on_()
+{
+  local lv="$1"_mlog
+  shift 1
+  lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
+  for d in $*; do grep "$d(" out || return 1; done
+  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
+  grep . out && return 1
+  return 0
+}
+
+save_dev_sum_()
+{
+  mkfs.ext3 $1 > /dev/null &&
+  md5sum $1 > md5.$(basename $1)
+}
+
+check_dev_sum_()
+{
+  md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
+
+offset=0
+pvs=
+for n in $(seq 1 $nr_pvs); do
+  test_expect_success \
+      "create pv$n" \
+      'echo "0 $pvsize linear $lodev $offset" > in &&
+       dmsetup create pv$n < in'
+  offset=$(($offset + $pvsize))
+done
+
+for n in $(seq 1 $nr_pvs); do
+  pvs="$pvs $(pv_ $n)"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+test_expect_success \
+  'set up a VG' \
+  'vgcreate $vg $pvs'
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+  lvremove -ff $vg;
+  :
+}
+
+check_and_cleanup_lvs_()
+{
+  lvs -a -o+devices $vg &&
+  lvremove -ff $vg
+}
+
+test_expect_success "check environment setup/cleanup" \
+  'prepare_lvs_ &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+# mirrored LV tests
+
+# ---
+# create
+
+test_expect_success "create 2-way mirror with disklog from 3 PVs" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "create 2-way mirror with corelog from 2 PVs" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   mimages_are_redundant_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "create 3-way mirror with disklog from 4 PVs" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 4) $(pv_ 3):0-1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# convert
+
+test_expect_success "convert from linear to 2-way mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
+   lvconvert -m+1 $vg/$lv1 $(pv_ 2) $(pv_ 3):0-1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "convert from 2-way mirror to linear" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvconvert -m-1 $vg/$lv1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "convert from disklog to corelog" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvconvert --mirrorlog core $vg/$lv1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "convert from corelog to disklog" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   lvconvert --mirrorlog disk $vg/$lv1 $(pv_ 3):0-1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# resize
+
+test_expect_success "extend 2-way mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvchange -an $vg/$lv1 &&
+   lvextend -l+2 $vg/$lv1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mimages_are_contiguous_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "reduce 2-way mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l4 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvchange -an $vg/$lv1 &&
+   lvreduce -l-2 $vg/$lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "extend 2-way mirror (cling if not contiguous)" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvcreate -l1 -n $lv2 $vg $(pv_ 1) &&
+   lvcreate -l1 -n $lv3 $vg $(pv_ 2) &&
+   lvchange -an $vg/$lv1 &&
+   lvextend -l+2 $vg/$lv1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mimages_are_clung_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# failure cases
+
+test_expect_failure "create 2-way mirror with disklog from 2 PVs" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2)'
+test_expect_success "(cleanup previous test)" \
+  'check_and_cleanup_lvs_'
+
+test_expect_failure "convert linear to 2-way mirror with 1 PV" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
+   lvconvert -m+1 --mirrorlog core $vg/$lv1 $(pv_ 1)'
+test_expect_success "(cleanup previous test)" \
+  'check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+
+test_done
/cvs/lvm2/LVM2/test/t-mirror-lvconvert.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-mirror-lvconvert.sh
+++ -	2008-01-16 21:21:23.534202000 +0000
@@ -0,0 +1,392 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that pvmove works with basic options"
+privileges_required_=1
+
+. ./test-lib.sh
+
+dmsetup_has_dm_devdir_support_ ||
+{
+  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
+  say "Skipping this test"
+  exit 0
+}
+
+cleanup_()
+{
+  test -n "$vg" && {
+    lvremove -ff $vg
+    vgremove $vg
+  } > /dev/null
+  test -n "$pvs" && {
+    pvremove $pvs > /dev/null
+    for d in $pvs; do
+      dmsetup remove $(basename $d)
+    done
+  }
+  losetup -d $lodev
+  rm -f $lofile
+}
+
+# ---------------------------------------------------------------------
+# config
+
+nr_pvs=5
+pvsize=$((80 * 1024 * 2))
+
+vg=mirror-basic-vg-$$
+lv1=lv1
+lv2=lv2
+lv3=lv3
+
+# ---------------------------------------------------------------------
+# Utilities
+
+pv_()
+{
+  echo "$G_dev_/mapper/pv$1"
+}
+
+lvdev_()
+{
+  echo "$G_dev_/$1/$2"
+}
+
+mimages_are_redundant_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  rm -f out
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lvs -a -odevices --noheadings $vg/$i | sed 's/([^)]*)//g; s/,/ /g' | \
+      sort | uniq >> out
+  done
+
+  # if any duplication is found, it's not redundant
+  sort out | uniq -d | grep . && return 1
+
+  return 0
+}
+
+lv_is_contiguous_ ()
+{
+  local lv=$1
+
+  # if the lv has multiple segments, it's not contiguous
+  [ $(lvs -a --segments --noheadings $lv | wc -l) -ne 1 ] && return 1
+
+  return 0
+}
+
+lv_is_clung_ ()
+{
+  local lv=$1
+
+  # if any duplication is found, it's not redundant
+  [ $(lvs -a -odevices --noheadings $lv | sed 's/([^)]*)//g' | \
+        sort | uniq | wc -l) -ne 1 ] && return 1
+
+  return 0
+}
+
+mimages_are_contiguous_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lv_is_contiguous_ $vg/$i || return 1
+  done
+
+  return 0
+}
+
+mimages_are_clung_ ()
+{
+  local vg=$1
+  local lv=$vg/$2
+  local i
+
+  for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lv_is_clung_ $vg/$i || return 1
+  done
+
+  return 0
+}
+
+mirrorlog_is_on_()
+{
+  local lv="$1"_mlog
+  shift 1
+  lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
+  for d in $*; do grep "$d(" out || return 1; done
+  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
+  grep . out && return 1
+  return 0
+}
+
+save_dev_sum_()
+{
+  mkfs.ext3 $1 > /dev/null &&
+  md5sum $1 > md5.$(basename $1)
+}
+
+check_dev_sum_()
+{
+  md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
+}
+
+check_mirror_count_()
+{
+  local lv=$1
+  local mirrors=$2
+  [ "$mirrors" -eq "$(lvs --noheadings -ostripes $lv)" ]
+}
+
+check_mirror_log_()
+{
+  local lv=$1
+  local mlog=$(lvs --noheadings -omirror_log $lv | sed -e 's/ //g')
+  [ "$(basename $lv)_mlog" = "$mlog" ]
+}
+
+wait_conversion_()
+{
+  local lv=$1
+  while (lvs --noheadings -oattr "$lv" | grep -q '^ *c'); do sleep 1; done
+}
+
+check_no_tmplvs_()
+{
+  local lv=$1
+  lvs -a --noheadings -oname $(dirname $lv) > out
+  ! grep tmp out
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
+
+offset=0
+pvs=
+for n in $(seq 1 $nr_pvs); do
+  test_expect_success \
+      "create pv$n" \
+      'echo "0 $pvsize linear $lodev $offset" > in &&
+       dmsetup create pv$n < in'
+  offset=$(($offset + $pvsize))
+done
+
+for n in $(seq 1 $nr_pvs); do
+  pvs="$pvs $(pv_ $n)"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+test_expect_success \
+  'set up a VG' \
+  'vgcreate $vg $pvs'
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+  lvremove -ff $vg;
+  :
+}
+
+check_and_cleanup_lvs_()
+{
+  lvs -a -o+devices $vg &&
+  lvremove -ff $vg
+}
+
+test_expect_success "check environment setup/cleanup" \
+  'prepare_lvs_ &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+# mirrored LV tests
+
+# ---
+# add mirror to mirror
+
+test_expect_success "add 1 mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+1 -i1 $vg/$lv1 $(pv_ 4) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "add 2 mirrors" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+2 -i1 $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 4 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "add 1 mirror to core log mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   !(check_mirror_log_ $vg/$lv1) &&
+   lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $(pv_ 4) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   !(check_mirror_log_ $vg/$lv1) &&
+   mimages_are_redundant_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "add 2 mirrors to core log mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   !(check_mirror_log_ $vg/$lv1) &&
+   lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 4 &&
+   !(check_mirror_log_ $vg/$lv1) &&
+   mimages_are_redundant_ $vg $lv1 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# add to converting mirror
+
+test_expect_success "add 1 mirror then add 1 more mirror during conversion" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m+1 -i3 $vg/$lv1 $(pv_ 5) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 4 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# add mirror and disk log
+
+test_expect_success "add 1 mirror and disk log" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   !(check_mirror_log_ $vg/$lv1) &&
+   lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $(pv_ 4) $(pv_ 3):0-1 &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   check_mirror_log_ $vg/$lv1 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# check polldaemon restarts
+
+test_expect_success "convert inactive mirror and start polling" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   lvchange -an $vg/$lv1 &&
+   lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
+   lvchange -ay $vg/$lv1 &&
+   wait_conversion_ $vg/$lv1 &&
+   lvs -a &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+# removal during conversion
+
+test_expect_success "remove newly added mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m-1 $vg/$lv1 $(pv_ 4) &&
+   wait_conversion_ $vg/$lv1 &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "remove one of newly added mirrors" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+2 -b -i100 $vg/$lv1 $(pv_ 4) $(pv_ 5) &&
+   lvconvert -m-1 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -i1 $vg/$lv1 &&
+   wait_conversion_ $vg/$lv1 &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "remove from original mirror (the original is still mirror)" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m-1 $vg/$lv1 $(pv_ 2) &&
+   lvconvert -i1 $vg/$lv1 &&
+   wait_conversion_ $vg/$lv1 &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 3 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "remove from original mirror (the original becomes linear)" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m+1 -b -i100 $vg/$lv1 $(pv_ 4) &&
+   lvconvert -m-1 $vg/$lv1 $(pv_ 2) &&
+   lvconvert -i1 $vg/$lv1 &&
+   wait_conversion_ $vg/$lv1 &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   mimages_are_redundant_ $vg $lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+
+test_done
/cvs/lvm2/LVM2/test/t-pvmove-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pvmove-basic.sh
+++ -	2008-01-16 21:21:23.741130000 +0000
@@ -0,0 +1,428 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that pvmove works with basic options"
+privileges_required_=1
+
+. ./test-lib.sh
+
+dmsetup_has_dm_devdir_support_ ||
+{
+  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
+  say "Skipping this test"
+  exit 0
+}
+
+cleanup_()
+{
+  test -n "$vg" && {
+    lvremove -ff $vg
+    vgremove $vg
+  } > /dev/null
+  test -n "$pvs" && {
+    pvremove $pvs > /dev/null
+    for d in $pvs; do
+      dmsetup remove $(basename $d)
+    done
+  }
+  losetup -d $lodev
+  rm -f $lofile
+}
+
+# ---------------------------------------------------------------------
+# config
+
+nr_pvs=5
+pvsize=$((80 * 1024 * 2))
+
+vg=pvmove-basic-vg-$$
+lv1=lv1
+lv2=lv2
+lv3=lv3
+
+# ---------------------------------------------------------------------
+# Utilities
+
+pv_()
+{
+  echo "$G_dev_/mapper/pv$1"
+}
+
+lvdev_()
+{
+  echo "$G_dev_/$1/$2"
+}
+
+lv_is_on_()
+{
+  local lv=$1
+  shift 1
+  lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
+  for d in $*; do grep "$d(" out || return 1; done
+  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
+  grep . out && return 1
+  return 0
+}
+
+save_dev_sum_()
+{
+  mkfs.ext3 $1 > /dev/null &&
+  md5sum $1 > md5.$(basename $1)
+}
+
+check_dev_sum_()
+{
+  md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
+
+offset=0
+pvs=
+for n in $(seq 1 $nr_pvs); do
+  test_expect_success \
+      "create pv$n" \
+      'echo "0 $pvsize linear $lodev $offset" > in &&
+       dmsetup create pv$n < in'
+  offset=$(($offset + $pvsize))
+done
+
+for n in $(seq 1 $nr_pvs); do
+  pvs="$pvs $(pv_ $n)"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+test_expect_success \
+  'set up a VG' \
+  'vgcreate $vg $pvs'
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+  lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
+    lv_is_on_ $vg/$lv1 $(pv_ 1) &&
+  lvcreate -l9 -i3 -n $lv2 $vg $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+    lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+  lvextend -l+2 $vg/$lv1 $(pv_ 2) &&
+    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) &&
+  lvextend -l+2 $vg/$lv1 $(pv_ 3) &&
+    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
+  lvextend -l+2 $vg/$lv1 $(pv_ 1) &&
+    lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 1) &&
+  lvcreate -l1 -n $lv3 $vg $(pv_ 2) &&
+    lv_is_on_ $vg/$lv3 $(pv_ 2) &&
+  save_dev_sum_ $(lvdev_ $vg $lv1) &&
+  save_dev_sum_ $(lvdev_ $vg $lv2) &&
+  save_dev_sum_ $(lvdev_ $vg $lv3) &&
+  lvs -a -o devices --noheadings $vg/$lv1 > lv1_devs &&
+  lvs -a -o devices --noheadings $vg/$lv2 > lv2_devs &&
+  lvs -a -o devices --noheadings $vg/$lv3 > lv3_devs
+}
+
+lv_not_changed_()
+{
+  lvs -a -o devices --noheadings $1 > out &&
+  diff $(basename $1)_devs out
+}
+
+check_and_cleanup_lvs_()
+{
+  lvs -a -o+devices $vg &&
+  check_dev_sum_ $(lvdev_ $vg $lv1) &&
+  check_dev_sum_ $(lvdev_ $vg $lv2) &&
+  check_dev_sum_ $(lvdev_ $vg $lv3) &&
+  lvs -a -o name $vg > out && ! grep ^pvmove out &&
+  lvremove -ff $vg
+}
+
+test_expect_success "check environment setup/cleanup" \
+  'prepare_lvs_ &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+# pvmove tests
+
+# ---
+# filter by LV
+
+test_expect_success "only specified LV is moved: from pv2 to pv5 only for lv1" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv1 $(pv_ 2) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# segments in a LV
+
+test_expect_success "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv1 $(pv_ 1) $(pv_ 4) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 4) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv1 $(pv_ 2) $(pv_ 4) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 4) $(pv_ 3) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 4) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# multiple LVs matching
+
+test_expect_success "1 out of 3 LVs is moved: from pv4 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 4) $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "2 out of 3 LVs are moved: from pv3 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 3) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 5) $(pv_ 1) &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "3 out of 3 LVs are moved: from pv2 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) $(pv_ 1) &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_is_on_ $vg/$lv3 $(pv_ 5) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# areas of striping
+
+test_expect_success "move the 1st stripe: from pv2 of lv2 to pv1" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv2 $(pv_ 2) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 1) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "move the 2nd stripe: from pv3 of lv2 to pv1" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv2 $(pv_ 3) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 1) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "move the 3rd stripe: from pv4 of lv2 to pv1" \
+  'prepare_lvs_ &&
+   pvmove -i1 -n $vg/$lv2 $(pv_ 4) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 1) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# partial segment match (source segment splitted)
+
+test_expect_success "match to the start of segment:from pv2:0-0 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):0-0 $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "match to the middle of segment: from pv2:1-1 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):1-1 $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "match to the end of segment: from pv2:2-2 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):2-2 $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# destination segment splitted
+
+test_expect_success "no destination split: from pv2:0-2 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):0-2 $(pv_ 5) &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):0-2 $(pv_ 5):5-5 $(pv_ 4):5-6 &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 4) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):0-2 $(pv_ 3):5-5 $(pv_ 4):5-5 $(pv_ 5):5-5 &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 3) $(pv_ 4) $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# alloc policy (anywhere, contiguous) with both success and failure cases
+
+test_expect_failure "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 3):0-2 $(pv_ 3):5-7'
+test_expect_success "(cleanup previous test)" \
+  'lv_not_changed_ $vg/$lv1 &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7" \
+  'prepare_lvs_ &&
+   pvmove -i1 --alloc anywhere $(pv_ 3):0-2 $(pv_ 3):5-7 &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5" \
+  'prepare_lvs_ &&
+   pvmove -i1 --alloc anywhere $(pv_ 3):0-2 $(pv_ 3):5-7 $(pv_ 5):5-6 $(pv_ 4):5-5 &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_failure "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6" \
+  'prepare_lvs_ &&
+   pvmove -i1 --alloc contiguous $(pv_ 2):0-2 $(pv_ 5):5-5 $(pv_ 4):5-6'
+test_expect_success "(cleanup previous test)" \
+  'lv_not_changed_ $vg/$lv1 &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6" \
+  'prepare_lvs_ &&
+   pvmove -i1 --alloc contiguous $(pv_ 2):0-2 $(pv_ 5):0-0 $(pv_ 5):3-5 $(pv_ 4):5-6 &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# multiple segments in a LV
+
+test_expect_success "multiple source LVs: from pv3 to pv5" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 3) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 5) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---
+# move inactive LV
+
+test_expect_success "move inactive LV: from pv2 to pv5" \
+  'prepare_lvs_ &&
+   lvchange -an $vg/$lv1 &&
+   lvchange -an $vg/$lv3 &&
+   pvmove -i1 $(pv_ 2) $(pv_ 5) &&
+   lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 5) $(pv_ 3) &&
+   lv_is_on_ $vg/$lv2 $(pv_ 5) $(pv_ 3) $(pv_ 4) &&
+   lv_is_on_ $vg/$lv3 $(pv_ 5) &&
+   check_and_cleanup_lvs_'
+
+# ---
+# other failure cases
+
+test_expect_failure "no PEs to move: from pv3 to pv1" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 3) $(pv_ 1) &&
+   pvmove -i1 $(pv_ 3) $(pv_ 1)'
+test_expect_success "(cleanup previous test)" \
+  'lv_is_on_ $vg/$lv1 $(pv_ 1) $(pv_ 2) $(pv_ 1) &&
+   lv_is_on_ $vg/$lv2 $(pv_ 2) $(pv_ 1) $(pv_ 4) &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_failure "no space available: from pv2:0-0 to pv1:0-0" \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 2):0-0 $(pv_ 1):0-0'
+test_expect_success "(cleanup previous test)" \
+  'lv_not_changed_ $vg/$lv1 &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_failure 'same source and destination: from pv1 to pv1' \
+  'prepare_lvs_ &&
+   pvmove -i1 $(pv_ 1) $(pv_ 1)'
+test_expect_success "(cleanup previous test)" \
+  'lv_not_changed_ $vg/$lv1 &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+test_expect_failure "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough" \
+  'prepare_lvs_ &&
+   pvmove --alloc anywhere $(pv_ 1):0-2 $(pv_ 1):0-2 $(pv_ 5):0-0 2> err'
+test_expect_success "(cleanup previous test)" \
+  'grep "Insufficient free space" err &&
+   lv_not_changed_ $vg/$lv1 &&
+   lv_not_changed_ $vg/$lv2 &&
+   lv_not_changed_ $vg/$lv3 &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+
+test_expect_success "pvmove abort" \
+  'prepare_lvs_ &&
+   pvmove -i100 -b $(pv_ 1) $(pv_ 3) &&
+   pvmove --abort &&
+   check_and_cleanup_lvs_'
+
+test_done
--- LVM2/test/lvm-utils.sh	2008/01/14 21:07:58	1.5
+++ LVM2/test/lvm-utils.sh	2008/01/16 21:21:22	1.6
@@ -70,7 +70,8 @@
   # Detect support for the envvar.  If it's supported, the
   # following command will fail with the expected diagnostic.
   out=$(DM_DEV_DIR=j dmsetup version 2>&1)
-  test "$?:$out" = "1:Invalid DM_DEV_DIR envvar value."
+  test "$?:$out" = "1:Invalid DM_DEV_DIR envvar value." -o \
+       "$?:$out" = "1:Invalid DM_DEV_DIR environment variable value."
 }
 
 # set up private /dev and /etc
--- LVM2/test/Makefile.in	2007/10/09 13:13:05	1.7
+++ LVM2/test/Makefile.in	2008/01/16 21:21:22	1.8
@@ -56,6 +56,7 @@
 	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
+	test -n "@DMDIR@" && ln -s "@DMDIR@/dmsetup/dmsetup" bin/dmsetup
 	touch $@
 
 lvm-wrapper: Makefile
--- LVM2/test/t-vgmerge-usage.sh	2008/01/16 19:54:39	1.1
+++ LVM2/test/t-vgmerge-usage.sh	2008/01/16 21:21:22	1.2
@@ -70,30 +70,31 @@
    vgremove $vg2 &&
    vgremove $vg1'
 
-# FIXME: error with device mapper
-#test_expect_success \
-#  'vgmerge rejects vgmerge because max_lv is exceeded' \
-#  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
-#   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
-#   lvcreate -l 4 -n lv1 $vg1 &&
-#   lvcreate -l 4 -n lv2 $vg1 &&
-#   lvcreate -l 4 -n lv3 $vg2 &&
-#   vgmerge $vg1 $vg2 2>err;
-#   status=$?; echo status=$?; test $status = 5 &&
-#   grep "^  Maximum number of logical volumes (2) exceeded" err &&
-#   vgremove $vg2 &&
-#   vgremove $vg1'
+test_expect_success \
+  'vgmerge rejects vg with active lv' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n lv1 $vg2 &&
+   vgmerge $vg1 $vg2 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Logical volumes in \"$vg2\" must be inactive\$" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
 
-#test_expect_success \
-#  'vgmerge rejects vg with active lv' \
-#  'vgcreate $vg1 $d1 $d2 &&
-#   vgcreate $vg2 $d3 $d4 &&
-#   lvcreate -l 64 -n lv1 $vg1 &&
-#   vgmerge $vg1 $vg1 2>err;
-#   status=$?; echo status=$?; test $status = 5 &&
-#   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
-#   vgremove -f $vg2 &&
-#   vgremove -f $vg1'
+test_expect_success \
+  'vgmerge rejects vgmerge because max_lv is exceeded' \
+  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n lv1 $vg1 &&
+   lvcreate -l 4 -n lv2 $vg1 &&
+   lvcreate -l 4 -n lv3 $vg2 &&
+   vgchange -an $vg1 &&
+   vgchange -an $vg2 &&
+   vgmerge $vg1 $vg2 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of logical volumes (2) exceeded" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
 
 test_done
 # Local Variables:
--- LVM2/test/t-vgsplit-operation.sh	2008/01/16 19:54:39	1.3
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/16 21:21:22	1.4
@@ -98,6 +98,32 @@
    vgremove $vg2 &&
    vgremove $vg1'
 
+test_expect_success \
+  'vgsplit rejects vg with active lv' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n lv1 $vg1 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because max_lv is exceeded' \
+  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n lv1 $vg1 &&
+   lvcreate -l 4 -n lv2 $vg1 &&
+   lvcreate -l 4 -n lv3 $vg2 &&
+   vgchange -an $vg1 &&
+   vgchange -an $vg2 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of logical volumes (2) exceeded" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil


