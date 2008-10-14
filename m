From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Oct 2008 19:41:13 -0000
Subject: LVM2/test t-mirror-basic.sh t-mirror-vgreduce- ...
Message-ID: <20081014194113.24636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-10-14 19:41:13

Modified files:
	test           : t-mirror-basic.sh 
	                 t-mirror-vgreduce-removemissing.sh 

Log message:
	Conversion of last 2 tests to use test-utils.sh, by jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-mirror-basic.sh	2008/01/26 00:25:45	1.3
+++ LVM2/test/t-mirror-basic.sh	2008/10/14 19:41:12	1.4
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,52 +11,14 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure that basic operations on mirrored LV works"
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
-vg=mirror-basic-vg-$$
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
 lvdev_()
 {
   echo "$G_dev_/$1/$2"
@@ -132,9 +94,8 @@
   local lv="$1"_mlog
   shift 1
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
-  for d in $*; do grep "$d(" out || return 1; done
-  for d in $*; do grep -v "$d(" out > out2; mv out2 out; done
-  grep . out && return 1
+  for d in $*; do grep "$d(" out; done
+  for d in $*; do ! grep -v "$d(" out; done
   return 0
 }
 
@@ -152,31 +113,7 @@
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
@@ -189,13 +126,13 @@
 
 check_and_cleanup_lvs_()
 {
-  lvs -a -o+devices $vg &&
+  lvs -a -o+devices $vg
   lvremove -ff $vg
 }
 
-test_expect_success "check environment setup/cleanup" \
-  'prepare_lvs_ &&
-   check_and_cleanup_lvs_'
+#COMM "check environment setup/cleanup"
+prepare_lvs_ 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # mirrored LV tests
@@ -203,126 +140,125 @@
 # ---
 # create
 
-test_expect_success "create 2-way mirror with disklog from 3 PVs" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "create 2-way mirror with corelog from 2 PVs" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
-   mimages_are_redundant_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "create 3-way mirror with disklog from 4 PVs" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 4) $(pv_ 3):0-1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
+#COMM "create 2-way mirror with disklog from 3 PVs"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+#COMM "create 2-way mirror with corelog from 2 PVs"
+prepare_lvs_ 
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+mimages_are_redundant_ $vg $lv1 
+check_and_cleanup_lvs_
+
+#COMM "create 3-way mirror with disklog from 4 PVs"
+prepare_lvs_ 
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
 
 # ---
 # convert
 
-test_expect_success "convert from linear to 2-way mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 2) $(pv_ 3):0-1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "convert from 2-way mirror to linear" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvconvert -m-1 $vg/$lv1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "convert from disklog to corelog" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvconvert --mirrorlog core $vg/$lv1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "convert from corelog to disklog" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $(pv_ 1) $(pv_ 2) &&
-   lvconvert --mirrorlog disk $vg/$lv1 $(pv_ 3):0-1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
+#COMM "convert from linear to 2-way mirror"
+prepare_lvs_ 
+lvcreate -l2 -n $lv1 $vg $dev1 
+lvconvert -m+1 $vg/$lv1 $dev2 $dev3:0-1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+#COMM "convert from 2-way mirror to linear"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvconvert -m-1 $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+check_and_cleanup_lvs_
+
+#COMM "convert from disklog to corelog"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvconvert --mirrorlog core $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+check_and_cleanup_lvs_
+
+#COMM "convert from corelog to disklog"
+prepare_lvs_ 
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
 
 # ---
 # resize
 
-test_expect_success "extend 2-way mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvextend -l+2 $vg/$lv1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mimages_are_contiguous_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "reduce 2-way mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l4 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvreduce -l-2 $vg/$lv1 &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "extend 2-way mirror (cling if not contiguous)" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvcreate -l1 -n $lv2 $vg $(pv_ 1) &&
-   lvcreate -l1 -n $lv3 $vg $(pv_ 2) &&
-   lvchange -an $vg/$lv1 &&
-   lvextend -l+2 $vg/$lv1 &&
-   mimages_are_redundant_ $vg $lv1 &&
-   mimages_are_clung_ $vg $lv1 &&
-   check_and_cleanup_lvs_'
+#COMM "extend 2-way mirror"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvchange -an $vg/$lv1 
+lvextend -l+2 $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+mimages_are_contiguous_ $vg $lv1 
+check_and_cleanup_lvs_
+
+#COMM "reduce 2-way mirror"
+prepare_lvs_ 
+lvcreate -l4 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvchange -an $vg/$lv1 
+lvreduce -l-2 $vg/$lv1 
+check_and_cleanup_lvs_
+
+#COMM "extend 2-way mirror (cling if not contiguous)"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvcreate -l1 -n $lv2 $vg $dev1 
+lvcreate -l1 -n $lv3 $vg $dev2 
+lvchange -an $vg/$lv1 
+lvextend -l+2 $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+mimages_are_clung_ $vg $lv1 
+check_and_cleanup_lvs_
 
 # ---
 # failure cases
 
-test_expect_failure "create 2-way mirror with disklog from 2 PVs" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2)'
-test_expect_success "(cleanup previous test)" \
-  'check_and_cleanup_lvs_'
-
-test_expect_failure "convert linear to 2-way mirror with 1 PV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -n $lv1 $vg $(pv_ 1) &&
-   lvconvert -m+1 --mirrorlog core $vg/$lv1 $(pv_ 1)'
-test_expect_success "(cleanup previous test)" \
-  'check_and_cleanup_lvs_'
+#COMM "create 2-way mirror with disklog from 2 PVs"
+prepare_lvs_ 
+not lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2
+# "(cleanup previous test)"
+check_and_cleanup_lvs_
+
+#COMM "convert linear to 2-way mirror with 1 PV"
+prepare_lvs_ 
+lvcreate -l2 -n $lv1 $vg $dev1 
+not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
+# "(cleanup previous test)"
+check_and_cleanup_lvs_
 
 # ---
 # resync
 # FIXME: using dm-delay to properly check whether the resync really started
 
-test_expect_success "force resync 2-way active mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   yes | lvchange --resync $vg/$lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
-
-test_expect_success "force resync 2-way inactive mirror" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   lvchange --resync $vg/$lv1 &&
-   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
-   check_and_cleanup_lvs_'
+#COMM "force resync 2-way active mirror"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+yes | lvchange --resync $vg/$lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+
+#COMM "force resync 2-way inactive mirror"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvchange -an $vg/$lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+lvchange --resync $vg/$lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
-test_done
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/09/29 16:02:49	1.3
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/10/14 19:41:12	1.4
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -9,242 +9,239 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
+
 . ./test-utils.sh
 
 dmsetup_has_dm_devdir_support_ || exit 200
 
-pv_() {
-    eval "echo \$dev$1"
-}
-
 lv_is_on_ ()
 {
-  local lv=$vg/$1
-  shift
-  local pvs=$*
-
-  echo "Check if $lv is exactly on PVs $pvs"
-  rm -f out1 out2
-  echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+	local lv=$vg/$1
+	shift
+	local pvs=$*
+
+	echo "Check if $lv is exactly on PVs $pvs"
+	rm -f out1 out2
+	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
 
-  lvs -a -odevices --noheadings $lv | \
-    sed 's/([^)]*)//g; s/[ ,]/\n/g' | sort | uniq > out2
+	lvs -a -odevices --noheadings $lv | \
+	sed 's/([^)]*)//g; s/[ ,]/\n/g' | sort | uniq > out2
 
-  diff --ignore-blank-lines out1 out2
+	diff --ignore-blank-lines out1 out2
 }
 
 mimages_are_on_ ()
 {
-  local lv=$1
-  shift
-  local pvs="$*"
-  local mimages
-  local i
-
-  echo "Check if mirror images of $lv are on PVs $pvs"
-  rm -f out1 out2
-  echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
-
-  mimages=$(lvs --noheadings -a -o lv_name $vg | grep "${lv}_mimage_" | \
-             sed 's/\[//g; s/\]//g')
-  for i in $mimages; do
-    echo "Checking $vg/$i"
-    lvs -a -odevices --noheadings $vg/$i | \
-      sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
-  done
+	local lv=$1
+	shift
+	local pvs="$*"
+	local mimages
+	local i
+
+	echo "Check if mirror images of $lv are on PVs $pvs"
+	rm -f out1 out2
+	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+
+	mimages=$(lvs --noheadings -a -o lv_name $vg | grep "${lv}_mimage_" | \
+		sed 's/\[//g; s/\]//g')
+	for i in $mimages; do
+		echo "Checking $vg/$i"
+		lvs -a -odevices --noheadings $vg/$i | \
+			sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
+	done
 
-  diff --ignore-blank-lines out1 out2
+	diff --ignore-blank-lines out1 out2
 }
 
 mirrorlog_is_on_()
 {
-  local lv="$1"_mlog
-  shift
-  lv_is_on_ $lv $*
+	local lv="$1"_mlog
+	shift
+	lv_is_on_ $lv $*
 }
 
 lv_is_linear_()
 {
-  echo "Check if $1 is linear LV (i.e. not a mirror)"
-  lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
-  lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep -q '^1-'
+	echo "Check if $1 is linear LV (i.e. not a mirror)"
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep -q '^1-'
 }
 
 rest_pvs_()
 {
-  local index=$1
-  local num=$2
-  local rem=""
-  local n
-
-  for n in $(seq 1 $(($index - 1))) $(seq $((index + 1)) $num); do
-    rem="$rem $(pv_ $n)"
-  done
+	local index=$1
+	local num=$2
+	local rem=""
+	local n
+
+	for n in $(seq 1 $(($index - 1))) $(seq $(($index + 1)) $num); do
+		eval local dev=$\dev$n
+		rem="$rem $dev"
+	done
 
-  echo "$rem"
+	echo "$rem"
 }
 
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-aux prepare_vg 5
+prepare_vg 5
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
 prepare_lvs_()
 {
-  lvremove -ff $vg;
-  :
+	lvremove -ff $vg;
+	:
 }
 
 check_and_cleanup_lvs_()
 {
-  lvs -a -o+devices $vg &&
-  lvremove -ff $vg
+	lvs -a -o+devices $vg 
+	lvremove -ff $vg
 }
 
 recover_vg_()
 {
-  enable_dev $* &&
-  pvcreate -ff $* &&
-  vgextend $vg $* &&
-  check_and_cleanup_lvs_
+	enable_dev $* 
+	pvcreate -ff $* 
+	vgextend $vg $* 
+	check_and_cleanup_lvs_
 }
 
-test_expect_success "check environment setup/cleanup" \
-  'prepare_lvs_ &&
-   check_and_cleanup_lvs_'
+#COMM "check environment setup/cleanup" 
+prepare_lvs_ 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # one of mirror images has failed
 
-# basic: fail the 2nd mirror image of 2-way mirrored LV
+#COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvchange -an $vg/$lv1
-aux mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2)
-mirrorlog_is_on_ $lv1 $(pv_ 3)
-disable_dev $(pv_ 2)
+aux mimages_are_on_ $lv1 $dev1 $dev2
+mirrorlog_is_on_ $lv1 $dev3
+disable_dev $dev2
 vgreduce --removemissing --force $vg
 lv_is_linear_ $lv1
-lv_is_on_ $lv1 $(pv_ 1)
+lv_is_on_ $lv1 $dev1
 
-test_expect_success "cleanup" \
-  'recover_vg_ $(pv_ 2)'
+# "cleanup"
+recover_vg_ $dev2
 
 # ---------------------------------------------------------------------
 # LV has 3 images in flat,
 # 1 out of 3 images fails
 
-# test_3way_mirror_fail_1_ <PV# to fail>
+#COMM test_3way_mirror_fail_1_ <PV# to fail>
 test_3way_mirror_fail_1_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1
-   lvchange -an $vg/$lv1
-   aux mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3)
-   mirrorlog_is_on_ $lv1 $(pv_ 4)
-   disable_dev $(pv_ $index)
-   vgreduce --removemissing --force $vg
-   lvs -a -o+devices $vg
-   cat $G_root_/etc/lvm.conf
-   mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
-   mirrorlog_is_on_ $lv1 $(pv_ 4)
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0-1
+	lvchange -an $vg/$lv1
+	aux mimages_are_on_ $lv1 $dev1 $dev2 $dev3
+	mirrorlog_is_on_ $lv1 $dev4
+	eval disable_dev \$dev$index
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
+	mirrorlog_is_on_ $lv1 $dev4
 }
 
 for n in $(seq 1 3); do
-    # fail mirror image $(($n - 1)) of 3-way mirrored LV" \
-    prepare_lvs_
-    test_3way_mirror_fail_1_ $n
-    recover_vg_ $(pv_ $n)
+	#COMM fail mirror image $(($n - 1)) of 3-way mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_fail_1_ $n
+	eval recover_vg_ \$dev$n
 done
 
 # ---------------------------------------------------------------------
 # LV has 3 images in flat,
 # 2 out of 3 images fail
 
-# test_3way_mirror_fail_2_ <PV# NOT to fail>
+#COMM test_3way_mirror_fail_2_ <PV# NOT to fail>
 test_3way_mirror_fail_2_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4):0-1
-   lvchange -an $vg/$lv1
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3)
-   mirrorlog_is_on_ $lv1 $(pv_ 4)
-   rest_pvs_ $index 3
-   disable_dev $(rest_pvs_ $index 3)
-   vgreduce --force --removemissing $vg
-   lvs -a -o+devices $vg
-   aux lv_is_linear_ $lv1
-   lv_is_on_ $lv1 $(pv_ $index)
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0-1
+	lvchange -an $vg/$lv1
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
+	mirrorlog_is_on_ $lv1 $dev4
+	rest_pvs_ $index 3
+	disable_dev $(rest_pvs_ $index 3)
+	vgreduce --force --removemissing $vg
+	lvs -a -o+devices $vg
+	aux lv_is_linear_ $lv1
+	eval lv_is_on_ $lv1 \$dev$n
 }
 
 for n in $(seq 1 3); do
-    # fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
-    prepare_lvs_
-    test_3way_mirror_fail_2_ $n
-    recover_vg_ $(rest_pvs_ $n 3)
+	#COMM fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
+	prepare_lvs_
+	test_3way_mirror_fail_2_ $n
+	recover_vg_ $(rest_pvs_ $n 3)
 done
 
 # ---------------------------------------------------------------------
 # LV has 4 images, 1 of them is in the temporary mirror for syncing.
 # 1 out of 4 images fails
 
-# test_3way_mirror_plus_1_fail_1_ <PV# to fail>
+#COMM test_3way_mirror_plus_1_fail_1_ <PV# to fail>
 test_3way_mirror_plus_1_fail_1_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ $index) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5)
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0-1 
+	lvchange -an $vg/$lv1 
+	lvconvert -m+1 $vg/$lv1 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	eval disable_dev \$dev$n 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
+	mirrorlog_is_on_ $lv1 $dev5
 }
 
 for n in $(seq 1 4); do
-  test_expect_success "fail mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV" \
-    "prepare_lvs_ &&
-     test_3way_mirror_plus_1_fail_1_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(pv_ $n)"
+	#COMM "fail mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_plus_1_fail_1_ $n
+	eval recover_vg_ \$dev$n
 done
 
 # ---------------------------------------------------------------------
 # LV has 4 images, 1 of them is in the temporary mirror for syncing.
 # 3 out of 4 images fail
 
-# test_3way_mirror_plus_1_fail_3_ <PV# NOT to fail>
+#COMM test_3way_mirror_plus_1_fail_3_ <PV# NOT to fail>
 test_3way_mirror_plus_1_fail_3_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m2 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 4) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(rest_pvs_ $index 4) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
-   ! mirrorlog_is_on_ $lv1 $(pv_ 5)
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0-1 
+	lvchange -an $vg/$lv1 
+	lvconvert -m+1 $vg/$lv1 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	disable_dev $(rest_pvs_ $index 4) 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	eval local dev=\$dev$n
+	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
+	not mirrorlog_is_on_ $lv1 $dev5
 }
 
 for n in $(seq 1 4); do
-  test_expect_success "fail mirror images other than mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV" \
-    "prepare_lvs_ &&
-     test_3way_mirror_plus_1_fail_3_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(rest_pvs_ $n 4)"
+	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
+	prepare_lvs_
+	test_3way_mirror_plus_1_fail_3_ $n
+	recover_vg_ $(rest_pvs_ $n 4)
 done
 
 # ---------------------------------------------------------------------
@@ -254,26 +251,25 @@
 # test_2way_mirror_plus_2_fail_1_ <PV# to fail>
 test_2way_mirror_plus_2_fail_1_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+2 $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ $index) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5)
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+	lvchange -an $vg/$lv1 
+	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	eval disable_dev \$dev$n 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
+	mirrorlog_is_on_ $lv1 $dev5
 }
 
 for n in $(seq 1 4); do
-  test_expect_success "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV" \
-    "prepare_lvs_ &&
-     test_2way_mirror_plus_2_fail_1_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(pv_ $n)"
+	#COMM "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV" 
+	prepare_lvs_ 
+	test_2way_mirror_plus_2_fail_1_ $n
+	eval recover_vg_ \$dev$n
 done
 
 # ---------------------------------------------------------------------
@@ -283,143 +279,135 @@
 # test_2way_mirror_plus_2_fail_3_ <PV# NOT to fail>
 test_2way_mirror_plus_2_fail_3_()
 {
-   local index=$1
+	local index=$1
 
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+2 $vg/$lv1 $(pv_ 3) $(pv_ 4) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(rest_pvs_ $index 4) &&
-   vgreduce --removemissing --force $vg &&
-   lvs -a -o+devices $vg &&
-   (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
-   ! mirrorlog_is_on_ $lv1 $(pv_ 5)
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+	lvchange -an $vg/$lv1 
+	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
+	mirrorlog_is_on_ $lv1 $dev5 
+	disable_dev $(rest_pvs_ $index 4) 
+	vgreduce --removemissing --force $vg 
+	lvs -a -o+devices $vg 
+	eval local dev=\$dev$n
+	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
+	not mirrorlog_is_on_ $lv1 $dev5
 }
 
 for n in $(seq 1 4); do
-  test_expect_success "fail mirror images other than mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV" \
-    "prepare_lvs_ &&
-     test_2way_mirror_plus_2_fail_3_ $n"
-  test_expect_success "cleanup" \
-    "recover_vg_ $(rest_pvs_ $n 4)"
+	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
+	prepare_lvs_
+	test_2way_mirror_plus_2_fail_3_ $n
+	recover_vg_ $(rest_pvs_ $n 4)
 done
 
 # ---------------------------------------------------------------------
 # log device is gone (flat mirror and stacked mirror)
 
-test_expect_success "fail mirror log of 2-way mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ 5) &&
-   vgreduce --removemissing --force $vg &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 5)"
-
-test_expect_success "fail mirror log of 3-way (1 converting) mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 3) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ 5) &&
-   vgreduce --removemissing --force $vg &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 5)"
+#COMM "fail mirror log of 2-way mirrored LV" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+disable_dev $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 
+not mirrorlog_is_on_ $lv1 $dev5
+recover_vg_ $dev5
+
+#COMM "fail mirror log of 3-way (1 converting) mirrored LV" 
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+lvconvert -m+1 $vg/$lv1 $dev3 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+mirrorlog_is_on_ $lv1 $dev5 
+disable_dev $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+not mirrorlog_is_on_ $lv1 $dev5
+recover_vg_ $dev5
 
 # ---------------------------------------------------------------------
 # all images are gone (flat mirror and stacked mirror)
 
-test_expect_success "fail all mirror images of 2-way mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ 1) $(pv_ 2) &&
-   vgreduce --removemissing --force $vg &&
-   ! lvs $vg/$lv1'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 1) $(pv_ 2)"
-
-test_expect_success "fail all mirror images of 3-way (1 converting) mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvconvert -m+1 $vg/$lv1 $(pv_ 3) &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   disable_dev $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   vgreduce --removemissing --force $vg &&
-   ! lvs $vg/$lv1'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 1) $(pv_ 2) $(pv_ 3)"
+#COMM "fail all mirror images of 2-way mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+disable_dev $dev1 $dev2 
+vgreduce --removemissing --force $vg 
+not lvs $vg/$lv1
+recover_vg_ $dev1 $dev2
+
+#COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+lvconvert -m+1 $vg/$lv1 $dev3 
+mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
+mirrorlog_is_on_ $lv1 $dev5 
+disable_dev $dev1 $dev2 $dev3 
+vgreduce --removemissing --force $vg 
+not lvs $vg/$lv1
+recover_vg_ $dev1 $dev2 $dev3
 
 # ---------------------------------------------------------------------
 # Multiple LVs
 
-test_expect_success "fail a mirror image of one of mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvcreate -l2 -m1 -n $lv2 $vg $(pv_ 3) $(pv_ 4) $(pv_ 5):1-1 &&
-   lvchange -an $vg/$lv2 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   mirrorlog_is_on_ $lv2 $(pv_ 5) &&
-   disable_dev $(pv_ 2) &&
-   vgreduce --removemissing --force $vg &&
-   mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv2 $(pv_ 5) &&
-   lv_is_linear_ $lv1 &&
-   lv_is_on_ $lv1 $(pv_ 1)'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 2)"
-
-test_expect_success "fail mirror images, one for each mirrored LV" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   lvcreate -l2 -m1 -n $lv2 $vg $(pv_ 3) $(pv_ 4) $(pv_ 5):1-1 &&
-   lvchange -an $vg/$lv2 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   mirrorlog_is_on_ $lv2 $(pv_ 5) &&
-   disable_dev $(pv_ 2) &&
-   disable_dev $(pv_ 4) &&
-   vgreduce --removemissing --force $vg &&
-   lv_is_linear_ $lv1 &&
-   lv_is_on_ $lv1 $(pv_ 1) &&
-   lv_is_linear_ $lv2 &&
-   lv_is_on_ $lv2 $(pv_ 3)'
-test_expect_success "cleanup" \
-  "recover_vg_ $(pv_ 2) $(pv_ 4)"
+#COMM "fail a mirror image of one of mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1-1 
+lvchange -an $vg/$lv2 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv1 $dev5 
+mirrorlog_is_on_ $lv2 $dev5 
+disable_dev $dev2 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv2 $dev5 
+lv_is_linear_ $lv1 
+lv_is_on_ $lv1 $dev1
+recover_vg_ $dev2
+
+#COMM "fail mirror images, one for each mirrored LV"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1-1 
+lvchange -an $vg/$lv2 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mimages_are_on_ $lv2 $dev3 $dev4 
+mirrorlog_is_on_ $lv1 $dev5 
+mirrorlog_is_on_ $lv2 $dev5 
+disable_dev $dev2 
+disable_dev $dev4 
+vgreduce --removemissing --force $vg 
+lv_is_linear_ $lv1 
+lv_is_on_ $lv1 $dev1 
+lv_is_linear_ $lv2 
+lv_is_on_ $lv2 $dev3
+recover_vg_ $dev2 $dev4
 
 # ---------------------------------------------------------------------
 # no failure
 
-test_expect_success "no failures" \
-  'prepare_lvs_ &&
-   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 5):0-1 &&
-   lvchange -an $vg/$lv1 &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   vgreduce --removemissing --force $vg &&
-   mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
-   mirrorlog_is_on_ $lv1 $(pv_ 5)'
-test_expect_success "cleanup" \
-  'check_and_cleanup_lvs_'
+#COMM "no failures"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvchange -an $vg/$lv1 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5 
+vgreduce --removemissing --force $vg 
+mimages_are_on_ $lv1 $dev1 $dev2 
+mirrorlog_is_on_ $lv1 $dev5
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
-test_done


