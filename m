From: meyering@sourceware.org <meyering@sourceware.org>
Date: 9 Oct 2007 13:13:07 -0000
Subject: LVM2 ./WHATS_NEW test/Makefile.in test/lvm-uti ...
Message-ID: <20071009131307.5585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-10-09 13:13:06

Modified files:
	.              : WHATS_NEW 
	test           : Makefile.in lvm-utils.sh t-lvcreate-pvtags.sh 
	                 t-lvcreate-usage.sh test-lib.sh 

Log message:
	Run tests with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
	
	This makes the tests more reproducible and helps isolate
	them from any existing LVM set-up.
	* test/Makefile.in (abs_builddir): Define.
	(init.sh): Emit definition of abs_builddir.
	* test/lvm-utils.sh (unsafe_losetup_): Keep only the portable,
	iterative approach.
	(dmsetup_has_dm_devdir_support_): New function.
	(init_root_dir_): New function.
	Invoke init_root_dir_ for all but the first test.
	* test/test-lib.sh (this_test_): Adapt to test-name change.
	Invoke lvm-utils.sh much later (after tmpdir creation), and
	only if the current test is not being skipped.
	Remove useless abs_top_srcdir definition.
	Rename t0->test_dir_rand_.
	* test/t-lvcreate-pvtags.sh: Skip this test if the available
	version of dmsetup is not new enough.
	Use global, $G_dev_, rather than hard-coded "/dev".
	* test/t-lvcreate-usage.sh: Make --verbose output more useful.
	
	Author: Jim Meyering <jim@meyering.net>
	Committer: Jim Meyering <meyering@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.716&r2=1.717
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/10/02 16:09:46	1.716
+++ LVM2/WHATS_NEW	2007/10/09 13:13:05	1.717
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Tests are run with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
   Fix underquotations in lvm_dump.sh.
   Refactor lvcreate stripe and mirror parameter validation.
--- LVM2/test/Makefile.in	2007/09/21 17:12:13	1.6
+++ LVM2/test/Makefile.in	2007/10/09 13:13:05	1.7
@@ -21,6 +21,7 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 abs_srcdir = @abs_srcdir@
+abs_builddir = @abs_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
@@ -32,6 +33,7 @@
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
+	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
--- LVM2/test/lvm-utils.sh	2007/09/21 21:14:25	1.3
+++ LVM2/test/lvm-utils.sh	2007/10/09 13:13:06	1.4
@@ -19,19 +19,14 @@
 unsafe_losetup_()
 {
   f=$1
-  # Prefer the race-free losetup from recent util-linux-ng.
-  dev=$(losetup --find --show "$f" 2>/dev/null) \
-      && { echo "$dev"; return 0; }
-
-  # If that fails, try to use util-linux-ng's -f "find-device" option.
-  dev=$(losetup -f 2>/dev/null) \
-      && losetup "$dev" "$f" \
-      && { echo "$dev"; return 0; }
 
-  # Last resort: iterate through /dev/loop{,/}{0,1,2,3,4,5,6,7,8,9}
+  test -n "$G_dev_" \
+    || error "Internal error: unsafe_losetup_ called before init_root_dir_"
+
+  # Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7,8,9}
   for slash in '' /; do
     for i in 0 1 2 3 4 5 6 7 8 9; do
-      dev=/dev/loop$slash$i
+      dev=$G_dev_/loop$slash$i
       losetup $dev > /dev/null 2>&1 && continue;
       losetup "$dev" "$f" > /dev/null && { echo "$dev"; return 0; }
       break
@@ -55,7 +50,6 @@
   return 0;
 }
 
-
 check_pv_size_()
 {
   return $(test $(pvs --noheadings -o pv_free $1) == $2)
@@ -65,3 +59,45 @@
 {
   return $(test $(lvs --noheadings -o lv_size $1) == $2)
 }
+
+dmsetup_has_dm_devdir_support_()
+{
+  # Detect support for the envvar.  If it's supported, the
+  # following command will fail with the expected diagnostic.
+  out=$(DM_DEV_DIR=j dmsetup version 2>&1)
+  test "$?:$out" = "1:Invalid DM_DEV_DIR envvar value."
+}
+
+# set up private /dev and /etc
+init_root_dir_()
+{
+  test -n "$test_dir_rand_" \
+    || error "Internal error: called init_root_dir_ before" \
+      " defining $test_dir_rand_"
+
+  # Define these two globals.
+  G_root_=$test_dir_rand_/root
+  G_dev_=$G_root_/dev
+
+  export LVM_SYSTEM_DIR=$G_root_/etc
+  export DM_DEV_DIR=$G_dev_
+
+  # Only the first caller does anything.
+  mkdir -p $G_root_/etc $G_dev_ $G_dev_/mapper
+  for i in 0 1 2 3 4 5 6 7; do
+    mknod $G_root_/dev/loop$i b 7 $i
+  done
+  cat > $G_root_/etc/lvm.conf <<-EOF
+  devices {
+    dir = "$G_dev_"
+    scan = "$G_dev_"
+    filter = [ "a/loop/", "a/mirror/", "a/mapper/", "r/.*/" ]
+    cache_dir = "$G_root_/etc"
+    sysfs_scan = 0
+  }
+EOF
+}
+
+if test $(this_test_) != 000-basic; then
+  init_root_dir_
+fi
--- LVM2/test/t-lvcreate-pvtags.sh	2007/09/24 19:19:18	1.2
+++ LVM2/test/t-lvcreate-pvtags.sh	2007/10/09 13:13:06	1.3
@@ -14,6 +14,13 @@
 
 . ./test-lib.sh
 
+dmsetup_has_dm_devdir_support_ ||
+{
+  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
+  say "Skipping this test"
+  exit 0
+}
+
 cleanup_()
 {
   test -n "$vg" && {
@@ -48,7 +55,7 @@
 done
 
 for n in $(seq 1 $nr_pvs); do
-  pvs="$pvs /dev/mapper/pv$n"
+  pvs="$pvs $G_dev_/mapper/pv$n"
 done
 
 test_expect_success \
@@ -66,7 +73,7 @@
 test_expect_failure 'too many stripes(4) for 3 PVs' \
   'lvcreate -l4 -i4 $vg @fast'
 test_expect_failure '2 stripes is too many with just one PV' \
-  'lvcreate -l2 -i2 $vg /dev/mapper/pv1'
+  'lvcreate -l2 -i2 $vg $G_dev_/mapper/pv1'
 
 test_expect_success 'lvcreate mirror' \
   'lvcreate -l1 -m1 $vg @fast'
@@ -77,6 +84,6 @@
 test_expect_failure 'lvcreate mirror (corelog, w/no free PVs)' \
   'lvcreate -l1 -m3 --corelog $vg @fast'
 test_expect_failure 'lvcreate mirror with a single PV arg' \
-  'lvcreate -l1 -m1 --corelog $vg /dev/mapper/pv1'
+  'lvcreate -l1 -m1 --corelog $vg $G_dev_/mapper/pv1'
 
 test_done
--- LVM2/test/t-lvcreate-usage.sh	2007/09/24 19:19:18	1.2
+++ LVM2/test/t-lvcreate-usage.sh	2007/10/09 13:13:06	1.3
@@ -30,15 +30,16 @@
   'set up temp files, loopback devices, PVs, and a VG' \
   'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
    f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   pvcreate $d1 $d2      &&
-   vg=$(this_test_)-test-vg-$$  &&
+   pvcreate $d1 $d2                       &&
+   vg=$(this_test_)-test-vg-$$            &&
    vgcreate $vg $d1 $d2'
 
 lv=lvcreate-usage-$$
 
 test_expect_success \
   'lvcreate rejects a negative stripesize' \
-  'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err; test $? = 3 &&
+  'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
    grep "^  Negative stripesize is invalid\$" err'
 
 test_expect_success \
--- LVM2/test/test-lib.sh	2007/09/18 14:02:22	1.2
+++ LVM2/test/test-lib.sh	2007/10/09 13:13:06	1.3
@@ -37,7 +37,7 @@
 	echo "* $*"
 }
 
-this_test_() { expr "./$0" : '.*/\(t[0-9]*\)-[^/]*$'; }
+this_test_() { expr "./$0" : '.*/t-\([^/]*\)\.sh$'; }
 
 test "${test_description}" != "" ||
 error "Test script did not set test_description."
@@ -193,8 +193,6 @@
 	esac
 }
 
-. lvm-utils.sh
-
 this_test=$(this_test_)
 
 skip_=0
@@ -208,8 +206,6 @@
     fi
 fi
 
-# Test the binaries we have just built.
-abs_top_srcdir=$(cd .. && pwd)
 pwd_=`pwd`
 
 test_dir_=${LVM_TEST_DIR-.}
@@ -239,16 +235,20 @@
 	esac
 done
 
-t0=$($abs_srcdir/mkdtemp $test_dir_ lvm-$this_test.XXXXXXXXXX) \
+test_dir_rand_=$($abs_srcdir/mkdtemp $test_dir_ lvm-$this_test.XXXXXXXXXX) \
     || error "failed to create temporary directory in $test_dir_"
 
 # Run each test from within a temporary sub-directory named after the
 # test itself, and arrange to remove it upon exception or normal exit.
-trap 'st=$?; cleanup_; d='"$t0"';
+trap 'st=$?; cleanup_; d='"$test_dir_rand_"';
     cd '"$test_dir_"' && chmod -R u+rwx "$d" && rm -rf "$d" && exit $st' 0
 trap '(exit $?); exit $?' 1 2 13 15
 
-cd $t0 || error "failed to cd to $t0"
+cd $test_dir_rand_ || error "failed to cd to $test_dir_rand_"
+
+if test $skip_ = 0; then
+  . $abs_srcdir/lvm-utils.sh || exit 1
+fi
 
 if ( diff --version < /dev/null 2>&1 | grep GNU ) 2>&1 > /dev/null; then
   compare='diff -u'


