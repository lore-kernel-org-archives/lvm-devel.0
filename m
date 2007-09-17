From: Jim Meyering <jim@meyering.net>
Date: Mon, 17 Sep 2007 16:42:59 +0200
Subject: test/t1000-lvcreate-usage.sh: exercise lvcreate
Message-ID: <873axdcpzg.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave and I were talking last week about the lack of
integration tests, and since he was working on lvcreate
and I'd just created this test framework, he sent me a bunch
of commands he'd been using to test lvcreate;  Today I
made them work with the new framework.

When I run the new test by itself, it does this:

    # cd test && ./t1000-lvcreate-usage.sh
    *   ok 1: set up temp files, loopback devices, PVs, and a VG
    *   ok 2: lvcreate w/negative stripesize must fail
    *   ok 3: lvcreate w/too-large stripesize must fail
    *   ok 4: lvcreate w/single stripe succeeds with diagnostics to stdout
    *   ok 5: lvcreate w/no stripe size succeeds with diagnostics to stdout
    *   ok 6: lvcreate w/invalid number of stripes must fail
    *   ok 7: lvcreate w/invalid stripe size must fail
    * passed all 7 test(s)

[Remember, I'm new to LVM, so if there are better/cleaner ways to test
 these things, please let me know, soon.  Otherwise, anything that's ugly
 or plain wrong in this test may end up being copy/pasted into new tests.
 Of course, if there's too much commonality, things will be factored out
 into shell functions that are shared, but still... ]

Here's the patch:

	Test how lvcreate handles its command-line options.

	* test/t1000-lvcreate-usage.sh: New tests.
	* test/Makefile.in (T): Add it.
	Derived from test cases by Dave Wysochanski.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 test/Makefile.in             |    1 +
 test/t1000-lvcreate-usage.sh |   70 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+), 0 deletions(-)
 create mode 100755 test/t1000-lvcreate-usage.sh

diff --git a/test/Makefile.in b/test/Makefile.in
index a7f2876..b54560f 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -32,6 +32,7 @@ SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 # T = $(wildcard t[0-9][0-9][0-9][0-9]-*.sh)
 T = \
   t0000-basic.sh \
+  t1000-lvcreate-usage.sh \
   t3000-lvcreate-pvtags.sh \
   t4000-pv-range-overflow.sh

diff --git a/test/t1000-lvcreate-usage.sh b/test/t1000-lvcreate-usage.sh
new file mode 100755
index 0000000..5f04b3e
--- /dev/null
+++ b/test/t1000-lvcreate-usage.sh
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
--
1.5.3.1.19.gb5ef6-dirty


