From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 14:24:35 -0000
Subject: LVM2/test Makefile.in lib/aux.sh lib/test.sh
Message-ID: <20120215142435.30674.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 14:24:33

Modified files:
	test           : Makefile.in 
	test/lib       : aux.sh test.sh 

Log message:
	Run tests with lvmetad if we have it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/Makefile.in	2011/11/23 14:56:47	1.66
+++ LVM2/test/Makefile.in	2012/02/15 14:24:31	1.67
@@ -45,11 +45,7 @@
 
 all: check
 
-check: .tests-stamp
-	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) ./lib/harness $(RUN_BASE)
-	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
+check: check_local check_cluster check_lvmetad
 
 check_cluster: .tests-stamp
 	@echo Testing with locking_type 3
@@ -59,6 +55,10 @@
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./lib/harness $(RUN_BASE)
 
+check_lvmetad: .tests-stamp
+	@echo Testing with lvmetad on
+	VERBOSE=$(VERBOSE) LVM_TEST_LVMETAD=1 ./lib/harness $(RUN_BASE)
+
 lib/should: lib/not
 	ln -sf not lib/should
 
--- LVM2/test/lib/aux.sh	2012/01/26 18:25:46	1.36
+++ LVM2/test/lib/aux.sh	2012/02/15 14:24:32	1.37
@@ -61,15 +61,17 @@
 }
 
 prepare_lvmetad() {
+	echo preparing lvmetad...
+
 	# skip if we don't have our own lvmetad...
 	(which lvmetad | grep $abs_builddir) || {
 		touch SKIP_THIS_TEST
 		exit 1
 	}
 
-	lvmconf "global/lvmetad = 1"
+	lvmconf "global/use_lvmetad = 1"
 
-	lvmetad -f "$@" &
+	lvmetad -f "$@" -s $TESTDIR/lvmetad.socket &
 	echo "$!" > LOCAL_LVMETAD
 
 	sleep 1
@@ -322,6 +324,7 @@
 	init_udev_transaction
 	for dev in "$@"; do
         	dmsetup remove -f $dev || true
+		pvscan --lvmetad $dev || true
 	done
 	finish_udev_transaction
 
@@ -335,6 +338,7 @@
 		dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
 		# using device name (since device path does not exists yes with udev)
 		dmsetup resume $name
+		pvscan --lvmetad $dev || true
 	done
 	finish_udev_transaction
 }
--- LVM2/test/lib/test.sh	2011/09/24 20:54:36	1.7
+++ LVM2/test/lib/test.sh	2012/02/15 14:24:32	1.8
@@ -59,6 +59,10 @@
 set -eE -o pipefail
 aux lvmconf
 aux prepare_clvmd
+test -n "$LVM_TEST_LVMETAD" && {
+    aux prepare_lvmetad
+    export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
+}
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
 


