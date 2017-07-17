From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:41:21 -0400
Subject: master - tests: aux.sh also uses increseed hardening protection
Message-ID: <201707171141.v6HBfLBo022670@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84b56872fbf82f6c0509cab6cc8a5054489cb2d8
Commit:        84b56872fbf82f6c0509cab6cc8a5054489cb2d8
Parent:        bd2a0fe2eca6cd60c0574bc3c2e590c886f5995b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 18:27:03 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:33:42 2017 +0200

tests: aux.sh also uses increseed hardening protection

Also use similar incresed hardeing of script correctness
for standalone aux scripts - so there is one common
logic for pipe failures.
---
 test/lib/aux.sh      |   36 +++++++++++++++++++-----------------
 test/lib/inittest.sh |    4 ++++
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b7a9ad6..30623b3 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -11,6 +11,8 @@
 
 . lib/utils
 
+test -n "$BASH" && set -euE -o pipefail
+
 run_valgrind() {
 	# Execute script which may use $TESTNAME for creating individual
 	# log files for each execute command
@@ -195,7 +197,7 @@ prepare_dmeventd() {
 	check_daemon_in_builddir dmeventd
 	lvmconf "activation/monitoring = 1"
 
-	local run_valgrind
+	local run_valgrind=""
 	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	echo -n "## preparing dmeventd..."
 #	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" 2>&1 &
@@ -215,7 +217,7 @@ prepare_dmeventd() {
 prepare_lvmetad() {
 	check_daemon_in_builddir lvmetad
 
-	local run_valgrind
+	local run_valgrind=""
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
 	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
@@ -536,7 +538,7 @@ kill_tagged_processes() {
 }
 
 teardown() {
-	local TEST_LEAKED_DEVICES
+	local TEST_LEAKED_DEVICES=""
 	echo -n "## teardown..."
 	unset LVM_LOG_FILE_EPOCH
 
@@ -728,7 +730,7 @@ prepare_md_dev() {
 
 	case "$level" in
 	"1")  coption="--bitmap-chunk" ;;
-	"0")  unset with_bitmap ;;
+	"0")  with_bitmap="" ;;
 	esac
 	# Have MD use a non-standard name to avoid colliding with an existing MD device
 	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
@@ -950,9 +952,9 @@ delay_dev() {
 
 disable_dev() {
 	local dev
-	local silent
-	local error
-	local notify
+	local silent=""
+	local error=""
+	local notify=""
 
 	while test -n "$1"; do
 	    if test "$1" = "--silent"; then
@@ -987,7 +989,7 @@ disable_dev() {
 
 enable_dev() {
 	local dev
-	local silent
+	local silent=""
 
 	if test "$1" = "--silent"; then
 	    silent=1
@@ -1015,7 +1017,7 @@ enable_dev() {
 # this is a quick way to restore to this table entry
 restore_from_devtable() {
 	local dev
-	local silent
+	local silent=""
 
 	if test "$1" = "--silent"; then
 	    silent=1
@@ -1222,7 +1224,7 @@ EOF
 	}
 
 	local sec
-	local last_sec
+	local last_sec=""
 
 	# read sequential list and put into associative array
 	while IFS= read -r v; do
@@ -1245,7 +1247,7 @@ EOF
 }
 
 lvmconf() {
-	unset profile_name
+	local profile_name=""
 	test $# -eq 0 || {
 		# Compare if passed args aren't already all in generated lvm.conf
 		local needed=0
@@ -1355,7 +1357,7 @@ thin_pool_error_works_32() {
 udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm &>/dev/null || return 0
-	if test -n "$1" ; then
+	if test -n "${1-}" ; then
 		udevadm settle --exit-if-exists="$1" || true
 	else
 		udevadm settle --timeout=15 || true
@@ -1366,7 +1368,7 @@ udev_wait() {
 wait_for_sync() {
 	local i
 	for i in {1..100} ; do
-		check in_sync "$1" "$2" "$3" && return
+		check in_sync "$@" && return
 		sleep .2
 	done
 
@@ -1452,7 +1454,7 @@ have_thin() {
 	}
 	target_at_least dm-thin-pool "$@"
 
-	declare -a CONF
+	declare -a CONF=()
 	# disable thin_check if not present in system
 	if test -n "$LVM_TEST_THIN_CHECK_CMD" && test ! -x "$LVM_TEST_THIN_CHECK_CMD"; then
 		CONF[0]="global/thin_check_executable = \"\""
@@ -1500,7 +1502,7 @@ have_cache() {
 	}
 	target_at_least dm-cache "$@"
 
-	declare -a CONF
+	declare -a CONF=()
 	# disable cache_check if not present in system
 	if test -n "$LVM_TEST_CACHE_CHECK_CMD" -a ! -x "$LVM_TEST_CACHE_CHECK_CMD" ; then
 		CONF[0]="global/cache_check_executable = \"\""
@@ -1569,7 +1571,7 @@ wait_pvmove_lv_ready() {
 	local retries=${2:-300}
 
 	if [ -e LOCAL_LVMPOLLD ]; then
-		local lvid
+		local lvid=""
 		while : ; do
 			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
 			test -n "$lvid" || {
@@ -1627,7 +1629,7 @@ kernel_at_least() {
 	version_at_least "$(uname -r)" "$@"
 }
 
-test -z "$LVM_TEST_AUX_TRACE" || set -x
+test -z "${LVM_TEST_AUX_TRACE-}" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
 
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index f13b386..d5ca6fd 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,6 +25,7 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
+LVM_TEST_BACKING_DEVICE=${LVM_TEST_BACKING_DEVICE-}
 LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}
 LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
 LVM_TEST_LVM1=${LVM_TEST_LVM1-}
@@ -63,6 +64,9 @@ test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 
 unset CDPATH
 
+export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG
+export LVM_TEST_LVMETAD LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
+export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK
 # grab some common utilities
 . lib/utils
 


