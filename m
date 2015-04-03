From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:28 +0000 (UTC)
Subject: master - tests: enhance delay_dev
Message-ID: <20150403125528.0AE4E60353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc418592202b05eb0643908d4167e7d634eeabd6
Commit:        dc418592202b05eb0643908d4167e7d634eeabd6
Parent:        bd84389c6867d8d1f1a238361e0d12f01be7a32f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 14:22:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 14:53:36 2015 +0200

tests: enhance delay_dev

Use common code for error_dev & delay_dev.
Both functions now take list of sectors.

>From now on we could delay just 'extent' section, while
keeping running  lvm commands fast (having native metadata area).
---
 test/lib/aux.sh |  116 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 59 insertions(+), 57 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a14b7a3..677e486 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -351,7 +351,7 @@ cleanup_scsi_debug_dev() {
 }
 
 prepare_backing_dev() {
-	if test -f BACKING_DEV; then 
+	if test -f BACKING_DEV; then
 		BACKING_DEV=$(< BACKING_DEV)
 	elif test -b "$LVM_TEST_BACKING_DEVICE"; then
 		BACKING_DEV="$LVM_TEST_BACKING_DEVICE"
@@ -415,16 +415,28 @@ prepare_devs() {
 	done
 }
 
-# Replace linear PV device with its 'delayed' version
-# Could be used to more deterministicaly hit some problems.
-# Parameters: {device path} [read delay ms] [write delay ms]
-# Original device is restored when both delay params are 0 (or missing).
-# i.e.  delay_dev "$dev1" 0 200
-delay_dev() {
-	target_at_least dm-delay 1 2 0 || skip
-	local name=$(echo "$1" | sed -e 's,.*/,,')
-	local read_ms=${2:-0}
-	local write_ms=${3:-0}
+
+common_dev_() {
+	local tgtype=$1
+	local name=${2##*/}
+	local offsets
+	local read_ms
+	local write_ms
+
+	case "$tgtype" in
+	delay)
+		read_ms=${3:-0}
+		write_ms=${4:-0}
+		offsets=${@:5}
+		if test "$read_ms" -eq 0 -a "$write_ms" -eq 0 ; then
+			offsets=
+		else
+			test ${#offsets[@]} -eq 0 && offsets="0:"
+		fi ;;
+	error)  offsets=${@:3}
+		test ${#offsets[@]} -eq 0 && offsets="0:" ;;
+	esac
+
 	local pos
 	local size
 	local type
@@ -433,17 +445,46 @@ delay_dev() {
 
 	read pos size type pvdev offset < "$name.table"
 
+	for fromlen in ${offsets[@]}; do
+		from=${fromlen%%:*}
+		len=${fromlen##*:}
+		test -n "$len" || len=$(($size - $from))
+		diff=$(($from - $pos))
+		if test $diff -gt 0 ; then
+			echo "$pos $diff $type $pvdev $(($pos + $offset))"
+			pos=$(($pos + $diff))
+		elif test $diff -lt 0 ; then
+			die "Position error"
+		fi
+
+		case "$tgtype" in
+		delay)
+			echo "$from $len delay $pvdev $(($pos + $offset)) $read_ms $pvdev $(($pos + $offset)) $write_ms" ;;
+		error)
+			echo "$from $len error" ;;
+		esac
+		pos=$(($pos + $len))
+	done > "$name.devtable"
+	diff=$(($size - $pos))
+	test "$diff" -gt 0 && echo "$pos $diff $type $pvdev $(($pos + $offset))" >>"$name.devtable"
+
 	init_udev_transaction
-	if test $read_ms -ne 0 -o $write_ms -ne 0 ; then
-		echo "0 $size delay $pvdev $offset $read_ms $pvdev $offset $write_ms" | \
-			dmsetup load "$name"
-	else
-		dmsetup load "$name" "$name.table"
-	fi
+	dmsetup load "$name" "$name.devtable"
 	dmsetup resume "$name"
 	finish_udev_transaction
 }
 
+# Replace linear PV device with its 'delayed' version
+# Could be used to more deterministicaly hit some problems.
+# Parameters: {device path} [read delay ms] [write delay ms] [offset:size]...
+# Original device is restored when both delay params are 0 (or missing).
+# If the size is missing, the remaing portion of device is taken
+# i.e.  delay_dev "$dev1" 0 200 256:
+delay_dev() {
+	target_at_least dm-delay 1 2 0 || skip
+	common_dev_ delay "$@"
+}
+
 disable_dev() {
 	local dev
 	local silent
@@ -513,46 +554,7 @@ enable_dev() {
 # Original device table is replace with multiple lines
 # i.e.  error_dev "$dev1" 8:32 96:8
 error_dev() {
-	local dev=$1
-	local name=$(echo "$dev" | sed -e 's,.*/,,')
-	local fromlen
-	local pos
-	local size
-	local type
-	local pvdev
-	local offset
-	local silent
-
-	read pos size type pvdev offset < $name.table
-
-	shift
-	rm -f $name.errtable
-	for fromlen in "$@"; do
-		from=${fromlen%%:*}
-		len=${fromlen##*:}
-		diff=$(($from - $pos))
-		if test $diff -gt 0 ; then
-			echo "$pos $diff $type $pvdev $(($pos + $offset))" >>$name.errtable
-			pos=$(($pos + $diff))
-		elif test $diff -lt 0 ; then
-			die "Position error"
-		fi
-		echo "$from $len error" >>$name.errtable
-		pos=$(($pos + $len))
-	done
-	diff=$(($size - $pos))
-	test $diff -gt 0 && echo "$pos $diff $type $pvdev $(($pos + $offset))" >>$name.errtable
-
-	init_udev_transaction
-	if dmsetup table $name ; then
-		dmsetup load "$name" "$name.errtable"
-	else
-		dmsetup create -u "TEST-$name" "$name" "$name.errtable"
-	fi
-	# using device name (since device path does not exists yet with udev)
-	dmsetup resume "$name"
-	finish_udev_transaction
-	test -n "$silent" || notify_lvmetad "$dev"
+	common_dev_ error "$@"
 }
 
 backup_dev() {


