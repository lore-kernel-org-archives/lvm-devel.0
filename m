From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:56 +0000 (UTC)
Subject: master - test: Allow test devices backed by a permanent block device.
Message-ID: <20150205134056.21AC0606DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7957fc4a4449d301d2c0743e2037eadd4bcc4f9d
Commit:        7957fc4a4449d301d2c0743e2037eadd4bcc4f9d
Parent:        c5a120c4439875c75549da97d2dcd752642fcc50
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:44:53 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Allow test devices backed by a permanent block device.

---
 test/lib/aux.sh |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2fef207..9def304 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -273,7 +273,7 @@ prepare_loop() {
 	echo -n .
 
 	local LOOPFILE="$PWD/test.img"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1)) 2> /dev/null
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size)) 2> /dev/null
 	if LOOP=$(losetup -s -f "$LOOPFILE" 2>/dev/null); then
 		:
 	elif LOOP=$(losetup -f) && losetup "$LOOP" "$LOOPFILE"; then
@@ -295,7 +295,9 @@ prepare_loop() {
 		done
 	fi
 	test -n "$LOOP" # confirm or fail
+	BACKING_DEV="$LOOP"
 	echo "$LOOP" > LOOP
+	echo "$LOOP" > BACKING_DEV
 	echo "ok ($LOOP)"
 }
 
@@ -339,20 +341,24 @@ cleanup_scsi_debug_dev() {
 	rm -f SCSI_DEBUG_DEV LOOP
 }
 
+prepare_backing_dev() {
+	if test -b "$LVM_TEST_BACKING_DEVICE"; then
+		BACKING_DEV="$LVM_TEST_BACKING_DEVICE"
+		echo "$BACKING_DEV" > BACKING_DEV
+	else
+		prepare_loop "$@"
+	fi
+}
+
 prepare_devs() {
 	local n=${1:-3}
 	local devsize=${2:-34}
 	local pvname=${3:-pv}
-	local loopsz
 
-	prepare_loop $(($n*$devsize))
+	prepare_backing_dev $(($n*$devsize))
 	echo -n "## preparing $n devices..."
 
-	if ! loopsz=$(blockdev --getsz "$LOOP" 2>/dev/null); then
-		loopsz=$(blockdev --getsize "$LOOP" 2>/dev/null)
-	fi
-
-	local size=$(($loopsz/$n))
+	local size=$(($devsize*2048)) # sectors
 	local count=0
 	init_udev_transaction
 	for i in $(seq 1 $n); do
@@ -360,11 +366,16 @@ prepare_devs() {
 		local dev="$DM_DEV_DIR/mapper/$name"
 		DEVICES[$count]=$dev
 		count=$(( $count + 1 ))
-		echo 0 $size linear "$LOOP" $((($i-1)*$size)) > "$name.table"
+		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size)) > "$name.table"
 		dmsetup create -u "TEST-$name" "$name" "$name.table"
 	done
 	finish_udev_transaction
 
+	# non-ephemeral devices need to be cleared between tests
+	test -f LOOP || for d in ${DEVICES[@]}; do
+		dd if=/dev/zero of=$d bs=1M count=1
+	done
+
 	#for i in `seq 1 $n`; do
 	#	local name="${PREFIX}$pvname$i"
 	#	dmsetup info -c $name


