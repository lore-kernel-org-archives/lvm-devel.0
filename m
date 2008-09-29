From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 15:59:23 -0000
Subject: LVM2/test harness.sh test-utils.sh
Message-ID: <20080929155923.16156.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 15:59:21

Added files:
	test           : harness.sh test-utils.sh 

Log message:
	Import new test utilities and a test harness.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/harness.sh,v  -->  standard output
revision 1.1
--- LVM2/test/harness.sh
+++ -	2008-09-29 15:59:23.452628000 +0000
@@ -0,0 +1,33 @@
+#!/bin/sh
+
+tests="$@"
+test -z "$tests" && tests=`echo t-*.sh`
+
+for t in $tests; do
+    printf "Running %-40s" "$t ..."
+    out=`sh ./$t 2>&1`
+    ret=$?
+    if test $ret = 0; then
+	echo " passed."
+    elif test $ret = 200; then
+	echo " skipped."
+    else
+	echo " FAILED!"
+	len=`echo $t | wc -c`
+	# fancy formatting...
+	printf -- "--- Output: $t -"
+	for i in `seq $(($len + 14)) 78`; do echo -n "-"; done; echo
+	printf "%s\n" "$out"
+	for i in `seq 1 78`; do echo -n "-"; done; echo
+	failed="$failed $t"
+    fi
+done
+
+if test -n "$failed"; then
+    echo "TESTS FAILED:"
+    for t in $failed; do
+	printf "\t%s\n" $t
+    done
+else
+    echo "All tests passed."
+fi
/cvs/lvm2/LVM2/test/test-utils.sh,v  -->  standard output
revision 1.1
--- LVM2/test/test-utils.sh
+++ -	2008-09-29 15:59:23.544074000 +0000
@@ -0,0 +1,146 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="foo" # silence test-lib for now
+. ./test-lib.sh
+
+aux() {
+    # use just "$@" for verbose operation
+    "$@" > /dev/null 2> /dev/null
+}
+
+not () { "$@" && exit 1 || return 0; }
+
+teardown() {
+    echo $LOOP
+    echo $PREFIX
+
+    test -n "$PREFIX" && {
+	rm -rf /dev/$PREFIX*
+	while dmsetup table | grep -q ^$PREFIX; do
+            for s in `dmsetup table | grep ^$PREFIX| cut -f1 -d:`; do
+		dmsetup resume $s 2>/dev/null > /dev/null || true
+		dmsetup remove $s 2>/dev/null > /dev/null || true
+            done
+	done
+    }
+
+    test -n "$LOOP" && losetup -d $LOOP
+    test -n "$LOOPFILE" && rm -f $LOOPFILE
+
+    cleanup_ # user-overridable cleanup
+    testlib_cleanup_ # call test-lib cleanup routine, too
+}
+
+make_ioerror() {
+    echo 0 10000000 error | dmsetup create ioerror
+    dmsetup resume ioerror
+    ln -s /dev/mapper/ioerror /dev/ioerror
+}
+
+prepare_loop() {
+    size=$1
+    test -n "$size" || size=32
+
+    test -n "$LOOP" && return 0
+    trap "aux teardown" EXIT # don't forget to clean up
+
+    LOOPFILE=test.img
+    dd if=/dev/zero of=test.img bs=$((1024*1024)) count=1 seek=$(($size-1))
+    LOOP=`losetup -s -f test.img`
+}
+
+prepare_devs() {
+    local n="$1"
+    test -z "$n" && n=3
+    local devsize="$2"
+    test -z "$devsize" && devsize=33
+
+    prepare_loop $(($n*$devsize))
+
+    PREFIX="LVMTEST$$"
+
+    local loopsz=`blockdev --getsz $LOOP`
+    local size=$(($loopsz/$n))
+
+    for i in `seq 1 $n`; do
+	local name="${PREFIX}pv$i"
+	local dev="$G_dev_/mapper/$name"
+	eval "dev$i=$dev"
+	devs="$devs $dev"
+	echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
+	dmsetup create $name $name.table
+	dmsetup resume $name
+    done
+
+    # set up some default names
+    vg=${PREFIX}vg
+    vg1=${PREFIX}vg1
+    vg2=${PREFIX}vg2
+    lv=LV
+    lv1=LV1
+    lv2=LV2
+}
+
+disable_dev() {
+    for dev in "$@"; do
+        # first we make the device inaccessible
+	echo 0 10000000 error | dmsetup load $dev
+	dmsetup resume $dev
+        # now let's try to get rid of it if it's unused
+        #dmsetup remove $dev
+    done
+}
+
+enable_dev() {
+    for dev in "$@"; do
+	local name=`echo "$dev" | sed -e 's,.*/,,'`
+	dmsetup create $name $name.table || dmsetup load $name $name.table
+	dmsetup resume $dev
+    done
+}
+
+prepare_pvs() {
+    prepare_devs "$@"
+    pvcreate $devs
+}
+
+prepare_vg() {
+    prepare_pvs "$@"
+    vgcreate $vg $devs
+}
+
+prepare_lvmconf() {
+  cat > $G_root_/etc/lvm.conf <<-EOF
+  devices {
+    dir = "$G_dev_"
+    scan = "$G_dev_"
+    filter = [ "a/dev\/mirror/", "a/dev\/mapper/", "r/.*/" ]
+    cache_dir = "$G_root_/etc"
+    sysfs_scan = 0
+  }
+  log {
+    verbose = $verboselevel
+    syslog = 0
+    indent = 1
+  }
+  backup {
+    backup = 0
+    archive = 0
+  }
+  global {
+    library_dir = "$G_root_/lib"
+  }
+EOF
+}
+
+set -vex
+aux prepare_lvmconf
+


