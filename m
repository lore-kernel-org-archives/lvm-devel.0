From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:21 -0400
Subject: master - tests: inittest may run without root
Message-ID: <201805121626.w4CGQLDH008297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbe81a0b058b6c994ff2cdf9b3f7bd7903074320
Commit:        cbe81a0b058b6c994ff2cdf9b3f7bd7903074320
Parent:        0221ebfd64541ee8598fc7f936f8267505b1bfae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 00:08:06 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

tests: inittest may run without root

If the test does not need root, it can use 'SKIP_ROOT_DM_CHECK'.

For such test no actions needed root to initilize DM devices and
nodes will be take and test can check i.e. functional unit tests.
---
 test/lib/inittest.sh |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index b6a1a3a..5e900c0 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -47,6 +47,7 @@ SKIP_WITH_LVMETAD=${SKIP_WITH_LVMETAD-}
 
 SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
 SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
+SKIP_ROOT_DM_CHECK=${SKIP_ROOT_DM_CHECK-}
 
 if test -n "$LVM_TEST_FLAVOUR"; then
 	. "lib/flavour-$LVM_TEST_FLAVOUR"
@@ -75,7 +76,9 @@ COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
 # Check we are not conflickting with some exiting setup
-dmsetup table | not grep "${PREFIX}[^0-9]" || die "DM table already has devices with prefix $PREFIX!"
+if test -z "$SKIP_ROOT_DM_CHECK" ; then
+	dmsetup table | not grep "${PREFIX}[^0-9]" || die "DM table already has devices with prefix $PREFIX!"
+fi
 
 if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
 TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
@@ -88,8 +91,13 @@ LVM_LOG_FILE_MAX_LINES=${LVM_LOG_FILE_MAX_LINES-1000000}
 LVM_EXPECTED_EXIT_STATUS=1
 export LVM_LOG_FILE_EPOCH LVM_LOG_FILE_MAX_LINES LVM_EXPECTED_EXIT_STATUS
 
-test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
-trap 'aux teardown' EXIT # don't forget to clean up
+if test -z "$SKIP_ROOT_DM_CHECK" ; then
+	# Teardown only with root
+	test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
+	trap 'aux teardown' EXIT # don't forget to clean up
+else
+	trap 'cd $TESTOLDPWD; rm -rf "${TESTDIR:?}"' EXIT
+fi
 
 cd "$TESTDIR"
 mkdir lib
@@ -114,7 +122,7 @@ mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
 	test -d "$LVM_TEST_DEVDIR" || die "Test device directory LVM_TEST_DEVDIR=\"$LVM_TEST_DEVDIR\" is not valid."
 	DM_DEV_DIR=$LVM_TEST_DEVDIR
-else
+elif test -z "$SKIP_ROOT_DM_CHECK" ; then
 	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed"
 	echo >"$DM_DEV_DIR/testnull" || \
 		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
@@ -151,7 +159,7 @@ if test -n "$LVM_TEST_LVMETAD" ; then
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
 	aux prepare_lvmetad
-else
+elif test -z "$SKIP_ROOT_DM_CHECK" ; then
 	# lvmetad prepares its own lvmconf
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/non-existing-file"
 	aux lvmconf


