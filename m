From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 16:00:54 -0000
Subject: LVM2/test test-lib.sh
Message-ID: <20080929160054.17782.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 16:00:53

Modified files:
	test           : test-lib.sh 

Log message:
	Export testlib_cleanup_ from test-lib.sh, which is needed for test-utils.sh to
	be able to call proper EXIT traps.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/test-lib.sh	2008/08/05 11:39:54	1.4
+++ LVM2/test/test-lib.sh	2008/09/29 16:00:53	1.5
@@ -247,10 +247,14 @@
 test_dir_rand_=$($abs_srcdir/mkdtemp $test_dir_ lvm-$this_test.XXXXXXXXXX) \
     || error "failed to create temporary directory in $test_dir_"
 
+testlib_cleanup_() {
+    d="$test_dir_rand_";
+    cd "$test_dir_" && chmod -R u+rwx "$d" && rm -rf "$d"
+}
+
 # Run each test from within a temporary sub-directory named after the
 # test itself, and arrange to remove it upon exception or normal exit.
-trap 'st=$?; cleanup_; d='"$test_dir_rand_"';
-    cd '"$test_dir_"' && chmod -R u+rwx "$d" && rm -rf "$d" && exit $st' 0
+trap 'st=$?; cleanup_; testlib_cleanup_; exit $st' 0
 trap '(exit $?); exit $?' 1 2 13 15
 
 cd $test_dir_rand_ || error "failed to cd to $test_dir_rand_"


