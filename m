From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jan 2009 10:16:58 -0000
Subject: LVM2/test test-utils.sh t-inconsistent-metadata.sh
Message-ID: <20090109101658.15593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-01-09 10:16:58

Modified files:
	test           : test-utils.sh 
Added files:
	test           : t-inconsistent-metadata.sh 

Log message:
	Document current state of inconsistent metadata behaviour of a few commands in
	a test. Should make changes to the !consistent bits of code easier. To be
	expanded.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

/cvs/lvm2/LVM2/test/t-inconsistent-metadata.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-inconsistent-metadata.sh
+++ -	2009-01-09 10:16:58.626158000 +0000
@@ -0,0 +1,62 @@
+#!/bin/bash
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
+. ./test-utils.sh
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -l 1 -n resized $vg
+lvchange -a n $vg/mirror
+
+backup_dev $devs
+
+init() {
+	restore_dev $devs
+	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
+	grep resized lvs.out | not grep 8192
+	lvresize -L 8192K $vg/resized
+	restore_dev $dev1
+}
+	
+check() {
+	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
+	grep resized lvs.out | grep 8192
+}
+
+# vgscan fixes up metadata
+init
+vgscan 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgscan 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
+
+# vgdisplay doesn't change anything
+init
+vgdisplay 2>&1 | tee cmd.out
+grep "Volume group \"$vg\" inconsistent" cmd.out
+vgdisplay 2>&1 | tee cmd.out
+grep "Volume group \"$vg\" inconsistent" cmd.out
+
+# lvs fixes up
+init
+lvs 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg - updating" cmd.out
+vgdisplay 2>&1 | tee cmd.out
+not grep "Volume group \"$vg\" inconsistent" cmd.out
+check
+
+# vgs doesn't fix up... (why?)
+init
+vgs 2>&1 | tee cmd.out
+vgdisplay 2>&1 | tee cmd.out
+grep "Volume group \"$vg\" inconsistent" cmd.out
--- LVM2/test/test-utils.sh	2008/12/10 16:16:53	1.8
+++ LVM2/test/test-utils.sh	2009/01/09 10:16:57	1.9
@@ -17,7 +17,15 @@
 	#"$@"
 }
 
-not () { "$@" && exit 1 || return 0; }
+not () {
+	"$@" && exit 1 || {
+		err="$?"
+		if test "$err" = 129; then
+			echo "fatal error $err"
+			exit 1
+		fi
+	}
+}
 
 STACKTRACE() {
 	trap - ERR;
@@ -44,7 +52,10 @@
 
 	test -n "$LOOP" && losetup -d $LOOP
 	test -n "$LOOPFILE" && rm -f $LOOPFILE
+}
 
+teardown_() {
+	teardown
 	cleanup_ # user-overridable cleanup
 	testlib_cleanup_ # call test-lib cleanup routine, too
 }
@@ -60,7 +71,7 @@
 	test -n "$size" || size=32
 
 	test -n "$LOOP" && return 0
-	trap 'aux teardown' EXIT # don't forget to clean up
+	trap 'aux teardown_' EXIT # don't forget to clean up
 	trap 'set +vex; STACKTRACE; set -vex' ERR
 	#trap - ERR
 
@@ -147,6 +158,22 @@
 	done
 }
 
+backup_dev() {
+	for dev in "$@"; do
+		dd if=$dev of=$dev.backup bs=1024
+	done
+}
+
+restore_dev() {
+	for dev in "$@"; do
+		test -e $dev.backup || {
+			echo "Internal error: $dev not backed up, can't restore!"
+			exit 1
+		}
+		dd of=$dev if=$dev.backup bs=1024
+	done
+}
+
 prepare_pvs() {
 	prepare_devs "$@"
 	pvcreate $devs


