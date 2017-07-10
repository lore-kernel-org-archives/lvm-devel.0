From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:11 -0400
Subject: master - tests: cleanup msg
Message-ID: <201707101234.v6ACYBAT022902@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=408e3b84f6b5d04fca1533cc7aab80d19e561d1c
Commit:        408e3b84f6b5d04fca1533cc7aab80d19e561d1c
Parent:        73bbd5528c2ccc9c5bdc4851e1c0b0ade19705ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 11:04:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: cleanup msg

---
 test/lib/aux.sh |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d3e1af9..2e0cc10 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -52,12 +52,12 @@ create_dlm_conf() {
 
 prepare_dlm() {
 	if pgrep dlm_controld ; then
-		echo "Cannot run while existing dlm_controld process exists"
+		echo "Cannot run while existing dlm_controld process exists."
 		exit 1
 	fi
 
 	if pgrep corosync; then
-		echo "Cannot run while existing corosync process exists"
+		echo "Cannot run while existing corosync process exists."
 		exit 1
 	fi
 
@@ -67,14 +67,14 @@ prepare_dlm() {
 	systemctl start corosync
 	sleep 1
 	if ! pgrep corosync; then
-		echo "Failed to start corosync"
+		echo "Failed to start corosync."
 		exit 1
 	fi
 
 	systemctl start dlm
 	sleep 1
 	if ! pgrep dlm_controld; then
-		echo "Failed to start dlm"
+		echo "Failed to start dlm."
 		exit 1
 	fi
 }
@@ -286,7 +286,7 @@ lvmpolld_talk() {
 		use=socat
 	elif echo | not nc -U "$TESTDIR/lvmpolld.socket" ; then
 		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
-		echo "# failed to contact lvmpolld"
+		echo "## failed to contact lvmpolld."
 		return 1
 	fi
 
@@ -302,15 +302,15 @@ lvmpolld_dump() {
 }
 
 prepare_lvmdbusd() {
-	local daemon=
+	local daemon
 	rm -f debug.log_LVMDBUSD_out
 
 	kill_sleep_kill_ LOCAL_LVMDBUSD 0
 
         # FIXME: This is not correct! Daemon is auto started.
-	echo "checking lvmdbusd is NOT running..."
+	echo -n "## checking lvmdbusd is NOT running..."
 	if pgrep -f -l lvmdbusd | grep python3 ; then
-		skip "Cannot run while existing lvmdbusd process exists"
+		skip "Cannot run lvmdbusd while existing lvmdbusd process exists"
 	fi
 	echo ok
 
@@ -323,7 +323,7 @@ prepare_lvmdbusd() {
 	else
 		daemon=$(which lvmdbusd || :)
 	fi
-	[[ -n "$daemon" && -x "$daemon" ]] || skip "The daemon is missing"
+	test -x "$daemon" || skip "The lvmdbusd daemon is missing"
 	which python3 >/dev/null || skip "Missing python3"
 
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
@@ -334,14 +334,14 @@ prepare_lvmdbusd() {
 		install -m 644 "$abs_top_builddir/scripts/com.redhat.lvmdbus1.conf" /etc/dbus-1/system.d/
 	fi
 
-	echo "preparing lvmdbusd..."
+	echo "## preparing lvmdbusd..."
 	lvmconf "global/notify_dbus = 1"
 
 	"$daemon" --debug  > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 
 	sleep 1
-	echo "checking lvmdbusd IS running..."
+	echo -n "## checking lvmdbusd IS running..."
 	if ! pgrep -f -l lvmdbusd | grep python3; then
 		echo "Failed to start lvmdbusd daemon"
 		return 1
@@ -397,7 +397,7 @@ teardown_devs_prefixed() {
 
 	local mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) )
 	if test ${#mounts[@]} -gt 0; then
-		test "$stray" -eq 0 || echo "Removing stray mounted devices containing $prefix:" "${mounts[@]}"
+		test "$stray" -eq 0 || echo "## removing stray mounted devices containing $prefix:" "${mounts[@]}"
 		if umount -fl "${mounts[@]}"; then
 			udev_wait
 		fi
@@ -424,7 +424,7 @@ teardown_devs_prefixed() {
 		local num_remaining_devs=999
 		while num_devs=$(dm_table | grep -c "$prefix") && \
 		    test "$num_devs" -lt "$num_remaining_devs" -a "$num_devs" -ne 0; do
-			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
+			test "$stray" -eq 0 || echo "## removing $num_devs stray mapped devices with names beginning with $prefix: "
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			for dm in $(dm_info name --sort open,-minor | grep "$prefix") ; do
 				dmsetup remove -f "$dm" || true
@@ -460,7 +460,7 @@ teardown_devs() {
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
-			echo "Removing stray loop devices containing $COMMON_PREFIX:" "${stray_loops[@]}"
+			echo "## removing stray loop devices containing $COMMON_PREFIX:" "${stray_loops[@]}"
 			for i in "${stray_loops[@]}" ; do test ! -b "$i" || losetup -d "$i" || true ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
@@ -501,7 +501,7 @@ kill_tagged_processes() {
 	rm -f PIDS
 	print_procs_by_tag_ "$@" | while read -r pid wait; do
 		if test -n "$pid" ; then
-			echo "Killing tagged process: $pid ${wait:0:120}..."
+			echo "## killing tagged process: $pid ${wait:0:120}..."
 			kill -TERM "$pid" 2>/dev/null || true
 		fi
 		echo "$pid" >> PIDS
@@ -535,7 +535,7 @@ teardown() {
 
 	if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
 		echo ""
-		echo "stopping lvmlockd in teardown"
+		echo "## stopping lvmlockd in teardown"
 		killall lvmlockd
 		sleep 1
 		killall lvmlockd || true
@@ -549,7 +549,7 @@ teardown() {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
 		if dm_info suspended,name | grep -q "^Suspended:.*$prefix" ; then
-			echo "Skipping vgremove, suspended devices detected."
+			echo "## skipping vgremove, suspended devices detected."
 		else
 			vgremove -ff "$cfg"  \
 			"$vg" "$vg1" "$vg2" "$vg3" "$vg4" &>/dev/null || rm -f debug.log strace.log
@@ -579,7 +579,7 @@ teardown() {
 	fi
 
 	test -z "$TEST_LEAKED_DEVICES" || {
-		echo "Unexpected devices left dm table:"
+		echo "## unexpected devices left dm table:"
 		echo "$TEST_LEAKED_DEVICES"
 		return 1
 	}
@@ -1234,7 +1234,7 @@ lvmconf() {
 			test "$val" = "$i" || { needed=1; break; }
 		done
 		test "$needed" -eq 0 && {
-			echo "## LVMCONF: values are already there, skipping."
+			echo "## Skipping reconfiguring for: (" "$@" ")"
 			return 0 # not needed
 		}
 	}


