From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:52 -0400
Subject: master - tests: aux.sh drop unnecessary $
Message-ID: <201706292027.v5TKRqnN026699@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44e530b919d72005e10970c13699c7fbfd736ce9
Commit:        44e530b919d72005e10970c13699c7fbfd736ce9
Parent:        474e3cd66d7be358f54674f1ea449adf47ab1a61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 00:17:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

tests: aux.sh drop unnecessary $

$/${} is unnecessary on arithmetic variables.
---
 test/lib/aux.sh |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 863f3da..816de9a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -481,7 +481,7 @@ kill_sleep_kill_() {
 		wait=0
 		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .5
-			wait=$(($wait + 1))
+			wait=$(( wait + 1 ))
 		done
 	fi
 }
@@ -513,7 +513,7 @@ kill_tagged_processes() {
 	for pid in $pids ; do
 		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .2
-			wait=$(($wait + 1))
+			wait=$(( wait + 1 ))
 		done
 		test "$wait" -le 10 || kill -KILL "$pid" 2>/dev/null || true
 	done
@@ -619,7 +619,7 @@ prepare_loop() {
 
 	local LOOPFILE="$PWD/test.img"
 	rm -f "$LOOPFILE"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size + 1)) 2> /dev/null
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(( size + 1 )) 2> /dev/null
 	if LOOP=$(losetup ${losetup_params} -s -f "$LOOPFILE" 2>/dev/null); then
 		:
 	elif LOOP=$(losetup -f) && losetup ${losetup_params} "$LOOP" "$LOOPFILE"; then
@@ -792,12 +792,12 @@ prepare_devs() {
 	fi
 
 	touch DEVICES
-	prepare_backing_dev $(($n*$devsize))
+	prepare_backing_dev $(( n * devsize ))
 	# shift start of PV devices on /dev/loopXX by 1M
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || shift=2048
 	echo -n "## preparing $n devices..."
 
-	local size=$(($devsize*2048)) # sectors
+	local size=$(( devsize * 2048 )) # sectors
 	local count=0
 	rm -f CREATE_FAILED
 	init_udev_transaction
@@ -805,8 +805,8 @@ prepare_devs() {
 		local name="${PREFIX}$pvname$i"
 		local dev="$DM_DEV_DIR/mapper/$name"
 		DEVICES[$count]=$dev
-		count=$(( $count + 1 ))
-		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size + $shift)) > "$name.table"
+		count=$((  count + 1 ))
+		echo 0 $size linear "$BACKING_DEV" $(( ( i - 1 ) * size + shift )) > "$name.table"
 		dmsetup create -u "TEST-$name" "$name" "$name.table" || touch CREATE_FAILED &
 		test -f CREATE_FAILED && break;
 	done
@@ -881,25 +881,25 @@ common_dev_() {
 	for fromlen in "${offsets[@]}"; do
 		from=${fromlen%%:*}
 		len=${fromlen##*:}
-		test -n "$len" || len=$(($size - $from))
-		diff=$(($from - $pos))
+		test -n "$len" || len=$(( size - from ))
+		diff=$(( from - pos ))
 		if test $diff -gt 0 ; then
-			echo "$pos $diff $type $pvdev $(($pos + $offset))"
-			pos=$(($pos + $diff))
+			echo "$pos $diff $type $pvdev $(( pos + offset ))"
+			pos=$(( pos + diff ))
 		elif test $diff -lt 0 ; then
 			die "Position error"
 		fi
 
 		case "$tgtype" in
 		delay)
-			echo "$from $len delay $pvdev $(($pos + $offset)) $read_ms $pvdev $(($pos + $offset)) $write_ms" ;;
+			echo "$from $len delay $pvdev $(( pos + offset )) $read_ms $pvdev $(( pos + offset )) $write_ms" ;;
 		error|zero)
 			echo "$from $len $tgtype" ;;
 		esac
-		pos=$(($pos + $len))
+		pos=$(( pos + len ))
 	done > "$name.devtable"
-	diff=$(($size - $pos))
-	test "$diff" -gt 0 && echo "$pos $diff $type $pvdev $(($pos + $offset))" >>"$name.devtable"
+	diff=$(( size - pos ))
+	test "$diff" -gt 0 && echo "$pos $diff $type $pvdev $(( pos + offset ))" >>"$name.devtable"
 
 	init_udev_transaction
 	dmsetup load "$name" "$name.devtable"


