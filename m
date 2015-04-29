From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Apr 2015 13:10:30 +0000 (UTC)
Subject: master - tests: minimize teardown when uneeded
Message-ID: <20150429131030.7C53560ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=244ca7ee775b554eb12d1897a8f90bf2d9640138
Commit:        244ca7ee775b554eb12d1897a8f90bf2d9640138
Parent:        c5b4327f3d34f823ae01511ea8b7635c3637fe87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 29 13:37:13 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 29 15:09:58 2015 +0200

tests: minimize teardown when uneeded

If test has not yet initilized any device,
make teardown a bit faster.
---
 test/lib/aux.sh      |   25 +++++++++++++------------
 test/lib/inittest.sh |   10 +++-------
 2 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 961dfcf..373909a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -140,6 +140,8 @@ teardown_devs_prefixed() {
 	local IFS=$IFS_NL
 	local dm
 
+	rm -rf "$TESTDIR/dev/$prefix"*
+
 	# Resume suspended devices first
 	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
 		echo "dmsetup resume \"${dm#Suspended:}\""
@@ -180,16 +182,16 @@ teardown_devs_prefixed() {
 			num_remaining_devs=$num_devs
 		done
 	fi
+
+	udev_wait
 }
 
 teardown_devs() {
 	# Delete any remaining dm/udev semaphores
 	teardown_udev_cookies
 
-	test -z "$PREFIX" || {
-		rm -rf "$TESTDIR/dev/$PREFIX"*
-		teardown_devs_prefixed "$PREFIX"
-	}
+	test ! -f MD_DEV || cleanup_md_dev
+	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
@@ -199,22 +201,21 @@ teardown_devs() {
 		test ! -f LOOP || losetup -d $(< LOOP) || true
 		test ! -f LOOPFILE || rm -f $(< LOOPFILE)
 	fi
-	rm -f DEVICES # devs is set in prepare_devs()
+
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || rm -f BACKING_DEV
-	rm -f LOOP
+	rm -f DEVICES LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
 	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -z "$COMMON_PREFIX" || {
-		teardown_devs_prefixed "$COMMON_PREFIX" 1
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
+			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
 			for i in "${stray_loops[@]}" ; do losetup -d $i ; done
+			# Leave test when udev processed all removed devices
+			udev_wait
 		}
 	}
-
-	# Leave test when udev processed all removed devices
-	udev_wait
 }
 
 kill_sleep_kill_() {
@@ -248,9 +249,8 @@ kill_listed_processes() {
 }
 
 teardown() {
-	test -f MD_DEV && cleanup_md_dev
-
 	echo -n "## teardown..."
+	unset LVM_LOG_FILE_EPOCH
 
 	if test -f TESTNAME ; then
 
@@ -461,6 +461,7 @@ prepare_devs() {
 	local pvname=${3:-pv}
 	local shift=0
 
+	touch DEVICES
 	prepare_backing_dev $(($n*$devsize))
 	# shift start of PV devices on /dev/loopXX by 1M
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || shift=2048
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 0efbf0d..96dfff2 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -32,7 +32,7 @@ PREFIX="${COMMON_PREFIX}$$"
 if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
 TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
-RUNNING_DMEVENTD=$(pgrep dmeventd) || true
+RUNNING_DMEVENTD=$(pgrep dmeventd || true)
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 export LVM_LOG_FILE_EPOCH=DEBUG
@@ -62,7 +62,7 @@ mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
 	DM_DEV_DIR=$LVM_TEST_DEVDIR
 else
-	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed";
+	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed"
 	echo >"$DM_DEV_DIR/testnull" || \
 		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
 	mkdir "$DM_DEV_DIR/mapper"
@@ -77,11 +77,7 @@ echo "$TESTNAME" >TESTNAME
 
 echo "Kernel is $(uname -a)"
 # Report SELinux mode
-if which getenforce &>/dev/null ; then
-	echo "Selinux mode is \"$(getenforce 2>/dev/null)\"."
-else
-	echo "Selinux mode is not installed."
-fi
+echo "Selinux mode is $(getenforce 2>/dev/null || echo not installed)."
 
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars


