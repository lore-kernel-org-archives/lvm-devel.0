From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 13:03:05 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110107130305.23157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 13:03:04

Modified files:
	test/lib       : aux.sh 

Log message:
	In aux, exit 200 no longer works as skip -- replace with real skip call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/lib/aux.sh	2011/01/05 00:25:07	1.2
+++ LVM2/test/lib/aux.sh	2011/01/07 13:03:04	1.3
@@ -10,6 +10,11 @@
 
 . lib/utils
 
+skip() {
+    touch SKIP_THIS_TEST
+    exit 1
+}
+
 prepare_clvmd() {
 	if test -z "$LVM_TEST_LOCKING" || test "$LVM_TEST_LOCKING" -ne 3 ; then
 		return 0 # not needed
@@ -17,22 +22,21 @@
 
 	if pgrep clvmd ; then
 		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
-                touch SKIP_THIS_TEST
-		exit 1
+                skip
 	fi
 
 	# skip if we don't have our own clvmd...
-	(which clvmd | grep $abs_builddir) || exit 200
+	(which clvmd | grep $abs_builddir) || skip
 
 	# skip if we singlenode is not compiled in
-	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || exit 200
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || skip
 
 	clvmd -Isinglenode -d 1 &
 	LOCAL_CLVMD="$!"
 
 	# check that it is really running now
 	sleep .1
-	ps $LOCAL_CLVMD || exit 200
+	ps $LOCAL_CLVMD || skip
 }
 
 prepare_dmeventd() {
@@ -175,16 +179,16 @@
     test -n "$DM_DEV_DIR"
 
     # Skip test if awk isn't available (required for get_sd_devs_)
-    which awk || exit 200
+    which awk || skip
 
     # Skip test if scsi_debug module is unavailable or is already in use
-    modprobe --dry-run scsi_debug || exit 200
-    lsmod | grep -q scsi_debug && exit 200
+    modprobe --dry-run scsi_debug || skip
+    lsmod | grep -q scsi_debug && skip
 
     # Create the scsi_debug device and determine the new scsi device's name
     # NOTE: it will _never_ make sense to pass num_tgts param;
     # last param wins.. so num_tgts=1 is imposed
-    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || exit 200
+    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
     sleep 2 # allow for async Linux SCSI device registration
 
     local DEBUG_DEV=/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)
@@ -353,15 +357,12 @@
 apitest() {
 	t=$1
         shift
-	test -x $abs_top_builddir/test/api/$t.t || {
-            touch SKIP_THIS_TEST
-            exit 200
-        }
+	test -x $abs_top_builddir/test/api/$t.t || skip
 	$abs_top_builddir/test/api/$t.t "$@"
 }
 
 api() {
-	test -x $abs_top_builddir/test/api/wrapper || exit 200
+	test -x $abs_top_builddir/test/api/wrapper || skip
 	$abs_top_builddir/test/api/wrapper "$@"
 }
 


