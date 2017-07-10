From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:26:35 -0400
Subject: master - tests: aux.sh common pattern for starting daemons
Message-ID: <201707101226.v6ACQZT6021231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f612fdd1ddb7b9c3fa837157b3415c6ab5bcfc3b
Commit:        f612fdd1ddb7b9c3fa837157b3415c6ab5bcfc3b
Parent:        4fc0166ca90efe902805f7abb951edeb0f7a91b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 12:43:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh common pattern for starting daemons

---
 test/lib/aux.sh |   87 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 747255b..a7692cb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -21,6 +21,14 @@ expect_failure() {
         echo "TEST EXPECT FAILURE"
 }
 
+check_daemon_in_builddir() {
+	# skip if we don't have our own deamon...
+	if test -z "${installed_testsuite+varset}"; then
+		(which "$1" 2>/dev/null | grep -q "$abs_builddir") || skip "$1 is not in executed path."
+	fi
+	rm -f debug.log strace.log
+}
+
 create_corosync_conf() {
 	COROSYNC_CONF="/etc/corosync/corosync.conf"
 	COROSYNC_NODE=$(hostname)
@@ -147,89 +155,84 @@ prepare_lvmlockd() {
 }
 
 prepare_clvmd() {
-	rm -f debug.log strace.log
 	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
 
 	if pgrep clvmd ; then
-		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
-		skip
+		skip "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
 	fi
 
-	# skip if we don't have our own clvmd...
-	if test -z "${installed_testsuite+varset}"; then
-		(which clvmd 2>/dev/null | grep -q "$abs_builddir") || skip
-	fi
+	check_daemon_in_builddir clvmd
 
 	test -e "$DM_DEV_DIR/control" || dmsetup table >/dev/null # create control node
 	# skip if singlenode is not compiled in
-	(clvmd --help 2>&1 | grep "Available cluster managers" | grep -q "singlenode") || skip
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep -q "singlenode") || \
+		skip "Compiled clvmd does not support singlenode for testing."
 
 #	lvmconf "activation/monitoring = 1"
-	local run_valgrind=
+	local run_valgrind=""
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	rm -f "$CLVMD_PIDFILE"
 	echo "<======== Starting CLVMD ========>"
+	echo -n "## preparing clvmd..."
 	# lvs is executed from clvmd - use our version
 	LVM_LOG_FILE_EPOCH=CLVMD LVM_LOG_FILE_MAX_LINES=1000000 LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in {1..100} ; do
-		test $i -eq 100 && die "Startup of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" -a -e "${CLVMD_PIDFILE%/*}/lvm/clvmd.sock" && break
-		sleep .2
+		test "$i" -eq 100 && die "Startup of clvmd is too slow."
+		test -e "$CLVMD_PIDFILE" && test -e "${CLVMD_PIDFILE%/*}/lvm/clvmd.sock" && break
+		echo -n .
+		sleep .1
 	done
+	echo ok
 }
 
 prepare_dmeventd() {
-	rm -f debug.log strace.log
 	if pgrep dmeventd ; then
-		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
-		skip
+		skip "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
 	fi
 
-	# skip if we don't have our own dmeventd...
-	if test -z "${installed_testsuite+varset}"; then
-		(which dmeventd 2>/dev/null | grep -q "$abs_builddir") || skip
-	fi
+	check_daemon_in_builddir dmeventd
 	lvmconf "activation/monitoring = 1"
 
-	local run_valgrind=
+	local run_valgrind
 	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
+	echo -n "## preparing dmeventd..."
 #	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" 2>&1 &
 	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" >debug.log_DMEVENTD_out 2>&1 &
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
 	for i in {1..100} ; do
-		test $i -eq 100 && die "Startup of dmeventd is too slow."
+		test "$i" -eq 100 && die "Startup of dmeventd is too slow."
 		test -e "${DMEVENTD_PIDFILE}" && break
-		sleep .2
+		echo -n .
+		sleep .1
 	done
 	echo ok
 }
 
 prepare_lvmetad() {
-	rm -f debug.log strace.log
-	# skip if we don't have our own lvmetad...
-	if test -z "${installed_testsuite+varset}"; then
-		(which lvmetad 2>/dev/null | grep -q "$abs_builddir") || skip
-	fi
+	check_daemon_in_builddir lvmetad
 
-	local run_valgrind=
+	local run_valgrind
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
 	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
 
-	# Avoid reconfiguring, if already set to use_lvmetad
-	(grep use_lvmetad CONFIG_VALUES 2>/dev/null | tail -n 1 | grep -q 1) || \
-		aux lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
+	lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
 	# Default debug is "-l all" and could be override
 	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
-	echo "preparing lvmetad..."
+	echo -n "## preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
 		"${LVM_TEST_LVMETAD_DEBUG_OPTS--l all}" "$@" &
 	echo $! > LOCAL_LVMETAD
-	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
+	for i in {1..100} ; do
+		test "$i" -eq 100 && die "Startup of lvmetad is too slow."
+		test -e "$TESTDIR/lvmetad.socket" && break
+		echo -n .
+		sleep .1;
+	done
 	echo ok
 }
 
@@ -239,7 +242,7 @@ lvmetad_talk() {
 		use=socat
 	elif echo | not nc -U "$TESTDIR/lvmetad.socket" ; then
 		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
-		echo "# failed to contact lvmetad"
+		echo "## failed to contact lvmetad."
 		return 1
 	fi
 
@@ -263,21 +266,23 @@ notify_lvmetad() {
 }
 
 prepare_lvmpolld() {
-	rm -f debug.log
-	# skip if we don't have our own lvmpolld...
-	(which lvmpolld 2>/dev/null | grep "$abs_builddir") || skip
-
+	check_daemon_in_builddir lvmetad
 	lvmconf "global/use_lvmpolld = 1"
 
-	local run_valgrind=
+	local run_valgrind
 	test "${LVM_VALGRIND_LVMPOLLD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
 	kill_sleep_kill_ LOCAL_LVMPOLLD "${LVM_VALGRIND_LVMPOLLD:-0}"
 
-	echo "preparing lvmpolld..."
+	echo -n "## preparing lvmpolld..."
 	$run_valgrind lvmpolld -f "$@" -s "$TESTDIR/lvmpolld.socket" -B "$TESTDIR/lib/lvm" -l all &
 	echo $! > LOCAL_LVMPOLLD
-	while ! test -e "$TESTDIR/lvmpolld.socket"; do echo -n .; sleep .1; done # wait for the socket
+	for i in {1..100} ; do
+		test "$i" -eq 100 && die "Startup of lvmpolld is too slow."
+		test -e "$TESTDIR/lvmpolld.socket" && break
+		echo -n .;
+		sleep .1;
+	done # wait for the socket
 	echo ok
 }
 


