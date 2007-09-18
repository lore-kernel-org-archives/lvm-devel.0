From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:01:46 -0000
Subject: LVM2/test Makefile.in t1000-lvcreate-usage.sh
Message-ID: <20070918140146.5113.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:01:46

Modified files:
	test           : Makefile.in 
Added files:
	test           : t1000-lvcreate-usage.sh 

Log message:
	Test how lvcreate handles its command-line options.
	
	* test/t1000-lvcreate-usage.sh: New tests.
	* test/Makefile.in (T): Add it.
	Derived from test cases by Dave Wysochanski.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t1000-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/test/t1000-lvcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t1000-lvcreate-usage.sh
+++ -	2007-09-18 14:01:46.464180000 +0000
@@ -0,0 +1,70 @@
+#!/bin/sh
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
+  } > /dev/null
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
+  'lvcreate w/negative stripesize must fail' \
+  'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err; test $? = 3 &&
+   grep "^  Negative stripesize is invalid\$" err'
+
+test_expect_success \
+  'lvcreate w/too-large stripesize must fail' \
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
+  'lvcreate w/invalid number of stripes must fail' \
+  'lvcreate -L 64M -n $lv -i129 $vg 2>err; test $? = 3 &&
+   grep "^  Number of stripes (129) must be between 1 and 128\$" err'
+
+# The case on lvdisplay output is to verify that the LV was not created.
+test_expect_success \
+  'lvcreate w/invalid stripe size must fail' \
+  'lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err; test $? = 3 &&
+   grep "^  Invalid stripe size 3\.00 KB\$" err &&
+   case "$(lvdisplay $vg)" in "") true ;; *) false ;; esac'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/Makefile.in	2007/09/18 14:01:24	1.2
+++ LVM2/test/Makefile.in	2007/09/18 14:01:46	1.3
@@ -32,6 +32,7 @@
 # T = $(wildcard t[0-9][0-9][0-9][0-9]-*.sh)
 T = \
   t0000-basic.sh \
+  t1000-lvcreate-usage.sh \
   t3000-lvcreate-pvtags.sh \
   t4000-pv-range-overflow.sh
 


