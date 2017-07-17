From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 14:57:13 -0400
Subject: master - tests: better support for unbound vars for older shell
Message-ID: <201707171857.v6HIvD7h030323@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fde23f7ce1a7e567fce3f1d33387f110f81d1fef
Commit:        fde23f7ce1a7e567fce3f1d33387f110f81d1fef
Parent:        5a5553bcec2141382407d27781cbade2f6966fe1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 20:32:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 20:32:48 2017 +0200

tests: better support for unbound vars for older shell

---
 test/lib/aux.sh |   43 ++++++++++++++++++-------------------------
 1 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b385129..20a8a1e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -272,7 +272,7 @@ prepare_lvmpolld() {
 	check_daemon_in_builddir lvmetad
 	lvmconf "global/use_lvmpolld = 1"
 
-	local run_valgrind
+	local run_valgrind=""
 	test "${LVM_VALGRIND_LVMPOLLD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
 	kill_sleep_kill_ LOCAL_LVMPOLLD "${LVM_VALGRIND_LVMPOLLD:-0}"
@@ -881,23 +881,22 @@ prepare_devs() {
 
 common_dev_() {
 	local tgtype=$1
-	local name=${2##*/}
-	local offsets
-	local read_ms
-	local write_ms
+	local dev=$2
+	local name=${dev##*/}
+	shift 2
+	local read_ms=${1-0}
+	local write_ms=${2-0}
 
 	case "$tgtype" in
 	delay)
-		read_ms=${3:-0}
-		write_ms=${4:-0}
-		offsets=( ${@:5} )
-		if test "$read_ms" -eq 0 && test "$write_ms" -eq 0 ; then
-			offsets=( )
-		else
-			test -z "${offsets[@]}" && offsets=( "0:" )
-		fi ;;
-	error|zero)  offsets=( ${@:3} )
-		test -z "${offsets[@]}" && offsets=( "0:" ) ;;
+		test "$read_ms" -eq 0 && test "$write_ms" -eq 0 && {
+			# zero delay is just equivalent to 'enable_dev'
+			enable_dev "$dev"
+			return
+		}
+		shift 2
+		;;
+	# error|zero target does not take read_ms & write_ms only offset list
 	esac
 
 	local pos
@@ -908,7 +907,7 @@ common_dev_() {
 
 	read -r pos size type pvdev offset < "$name.table"
 
-	for fromlen in "${offsets[@]}"; do
+	for fromlen in "${@-0:}"; do
 		from=${fromlen%%:*}
 		len=${fromlen##*:}
 		test -n "$len" || len=$(( size - from ))
@@ -931,11 +930,7 @@ common_dev_() {
 	diff=$(( size - pos ))
 	test "$diff" -gt 0 && echo "$pos $diff $type $pvdev $(( pos + offset ))" >>"$name.devtable"
 
-	init_udev_transaction
-	dmsetup load "$name" "$name.devtable"
-	# TODO: add support for resume without udev rescan
-	dmsetup resume "$name"
-	finish_udev_transaction
+	restore_from_devtable "$dev"
 }
 
 # Replace linear PV device with its 'delayed' version
@@ -1001,8 +996,7 @@ enable_dev() {
 	rm -f debug.log strace.log
 	init_udev_transaction
 	for dev in "$@"; do
-		local name
-		name=$(echo "$dev" | sed -e 's,.*/,,')
+		local name=${dev##*/}
 		dmsetup create -u "TEST-$name" "$name" "$name.table" 2>/dev/null || \
 			dmsetup load "$name" "$name.table"
 		# using device name (since device path does not exists yes with udev)
@@ -1029,8 +1023,7 @@ restore_from_devtable() {
 	rm -f debug.log strace.log
 	init_udev_transaction
 	for dev in "$@"; do
-		local name
-		name=$(echo "$dev" | sed -e 's,.*/,,')
+		local name=${dev##*/}
 		dmsetup load "$name" "$name.devtable"
 		dmsetup resume "$name"
 	done


