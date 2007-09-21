From: meyering@sourceware.org <meyering@sourceware.org>
Date: 21 Sep 2007 17:12:15 -0000
Subject: LVM2/test Makefile.in t-000-basic.sh t-lvcreat ...
Message-ID: <20070921171215.4596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-21 17:12:14

Modified files:
	test           : Makefile.in 
Added files:
	test           : t-000-basic.sh t-lvcreate-pvtags.sh 
	                 t-lvcreate-usage.sh t-pv-range-overflow.sh 
Removed files:
	test           : t0000-basic.sh t1000-lvcreate-usage.sh 
	                 t3000-lvcreate-pvtags.sh 
	                 t4000-pv-range-overflow.sh 

Log message:
	Rename test scripts not to include the 4-digit number.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t0000-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t1000-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t3000-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t4000-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE

/cvs/lvm2/LVM2/test/t-000-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-000-basic.sh
+++ -	2007-09-21 17:12:14.275230000 +0000
@@ -0,0 +1,35 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Basics: see if tools are built, etc.'
+
+. ./test-lib.sh
+
+lvm >/dev/null 2>&1
+if test $? != 3; then
+    echo >&2 'You do not seem to have built lvm yet.'
+    exit 1
+fi
+
+v=$abs_top_srcdir/tools/version.h
+test_expect_success \
+  "get version string from $v" \
+  'sed -n "/#define LVM_VERSION ./s///p" '"$v"'|sed "s/ .*//" > expected'
+
+test_expect_success \
+  'get version of a just-built binary, ensuring PATH is set properly' \
+  'lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual'
+
+test_expect_success \
+  'ensure they are the same' \
+  'diff -u actual expected'
+
+test_done
/cvs/lvm2/LVM2/test/t-lvcreate-pvtags.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-pvtags.sh
+++ -	2007-09-21 17:12:14.363161000 +0000
@@ -0,0 +1,82 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure that lvcreate's select-by-tag code works"
+privileges_required_=1
+
+. ./test-lib.sh
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
+nr_pvs=3
+pvsize=$((200 * 1024 * 2))
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile="$(pwd)/lofile" && lodev=$(loop_setup_ "$lofile")'
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
+  pvs="$pvs /dev/mapper/pv$n"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+vg=lvcreate-pvtags-vg-$$
+test_expect_success \
+  'set up a VG with tagged PVs' \
+  'vgcreate $vg $pvs &&
+   pvchange --addtag fast $pvs'
+
+test_expect_success '3 stripes with 3 PVs (selected by tag, @fast) is fine' \
+  'lvcreate -l3 -i3 $vg @fast'
+test_expect_failure 'too many stripes(4) for 3 PVs' \
+  'lvcreate -l4 -i4 $vg @fast'
+test_expect_failure '2 stripes is too many with just one PV' \
+  'lvcreate -l2 -i2 $vg /dev/mapper/pv1'
+
+test_expect_success 'lvcreate mirror' \
+  'lvcreate -l1 -m1 $vg @fast'
+test_expect_success 'lvcreate mirror w/corelog' \
+  'lvcreate -l1 -m2 --corelog $vg @fast'
+test_expect_failure 'lvcreate mirror w/no free PVs' \
+  'lvcreate -l1 -m2 $vg @fast'
+test_expect_failure 'lvcreate mirror (corelog, w/no free PVs)' \
+  'lvcreate -l1 -m3 --corelog $vg @fast'
+test_expect_failure 'lvcreate mirror with a single PV arg' \
+  'lvcreate -l1 -m1 --corelog $vg /dev/mapper/pv1'
+
+test_done
/cvs/lvm2/LVM2/test/t-lvcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-usage.sh
+++ -	2007-09-21 17:12:14.456337000 +0000
@@ -0,0 +1,79 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some lvcreate diagnostics'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$vg" && {
+    vgchange -an "$vg"
+    lvremove -ff "$vg"
+    vgremove "$vg"
+  } > "$test_dir_/cleanup.log"
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, and a VG' \
+  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
+   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+   pvcreate $d1 $d2      &&
+   vg=$(this_test_)-test-vg-$$  &&
+   vgcreate $vg $d1 $d2'
+
+lv=lvcreate-usage-$$
+
+test_expect_success \
+  'lvcreate rejects a negative stripesize' \
+  'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err; test $? = 3 &&
+   grep "^  Negative stripesize is invalid\$" err'
+
+test_expect_success \
+  'lvcreate rejects a too-large stripesize' \
+  'lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err; test $? = 3 &&
+   grep "^  Stripe size cannot be larger than 512.00 GB\$" err'
+
+test_expect_success \
+  'lvcreate w/single stripe succeeds with diagnostics to stdout' \
+  'lvcreate -L 64M -n $lv -i1 --stripesize 4 $vg >out 2>err &&
+   grep "^  Redundant stripes argument: default is 1\$" out &&
+   grep "^  Ignoring stripesize argument with single stripe\$" out &&
+   lvdisplay $vg &&
+   lvremove -ff $vg'
+
+test_expect_success \
+  'lvcreate w/no stripe size succeeds with diagnostics to stdout' \
+  'lvcreate -L 64M -n $lv -i2 $vg > out &&
+   grep "^  Using default stripesize" out &&
+   lvdisplay $vg &&
+   lvremove -ff $vg'
+
+test_expect_success \
+  'lvcreate rejects an invalid number of stripes' \
+  'lvcreate -L 64M -n $lv -i129 $vg 2>err; test $? = 3 &&
+   grep "^  Number of stripes (129) must be between 1 and 128\$" err'
+
+# The case on lvdisplay output is to verify that the LV was not created.
+test_expect_success \
+  'lvcreate rejects an invalid stripe size' \
+  'lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err; test $? = 3 &&
+   grep "^  Invalid stripe size 3\.00 KB\$" err &&
+   case "$(lvdisplay $vg)" in "") true ;; *) false ;; esac'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
/cvs/lvm2/LVM2/test/t-pv-range-overflow.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pv-range-overflow.sh
+++ -	2007-09-21 17:12:14.548303000 +0000
@@ -0,0 +1,61 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$vg" && {
+    vgchange -an "$vg"
+    lvremove -ff "$vg"
+    vgremove "$vg"
+  } > /dev/null
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, VG, LV' \
+  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
+   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+   pvcreate $d1 $d2              &&
+   vg=pvmove-demo-vg-$$          &&
+   vgcreate "$vg" $d1 $d2        &&
+   lv=lv1                        &&
+   lvcreate -L4 -n"$lv" "$vg"'
+
+# Test for the bogus diagnostic reported in BZ 284771
+# http://bugzilla.redhat.com/284771.  Once the BZ is fixed,
+# update the code below to expect an improved diagnostic.
+test_expect_success \
+  'run pvmove with an unrecognized LV name to show bad diagnostic' \
+  'pvmove -v -nbogus $d1 $d2 2> err
+   test $? = 5 &&
+   tail -n1 err > out &&
+   echo "  No data to move for $vg" > expected &&
+   diff -u out expected'
+
+# With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
+# the PE range parsing code would accept values up to 2^64-1, but would
+# silently truncate them to int32_t.  I.e., $d1:$(echo 2^32|bc) would be
+# treated just like $d1:0.
+test_expect_failure \
+  'run the offending pvmove command' \
+  'pvmove -v -n$lv $d1:4294967296 $d2'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/Makefile.in	2007/09/18 14:29:06	1.5
+++ LVM2/test/Makefile.in	2007/09/21 17:12:13	1.6
@@ -39,12 +39,7 @@
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
-# T = $(wildcard t[0-9][0-9][0-9][0-9]-*.sh)
-T = \
-  t0000-basic.sh \
-  t1000-lvcreate-usage.sh \
-  t3000-lvcreate-pvtags.sh \
-  t4000-pv-range-overflow.sh
+T = $(wildcard t-*.sh)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


