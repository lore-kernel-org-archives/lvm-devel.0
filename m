From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 14:11:35 +0000 (UTC)
Subject: master - tests: update aux
Message-ID: <20150326141135.D5CFC6113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f08154cc7b2051b68b4eda1a6be0de61fc77d637
Commit:        f08154cc7b2051b68b4eda1a6be0de61fc77d637
Parent:        b7ebab765761098058c436a3543ecbff00ad171a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 15:01:54 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 15:10:31 2015 +0100

tests: update aux

When we use /dev/loopX device - shift first PV1 sector by 1M
so /dev/loop0 and dm device do not appear as same device.

Also notify lvmetad once 'devs' are created - so in case this
command is called in the middle of test - lvmetad properly
drops its metadata for these devices.

Drop used test.img file between reuse so the 'prepare_vg'
always starts with zeroed disks.

When LVM_TEST_AUX_TRACE is set, allow shell tracing of aux commands.
---
 test/lib/aux.sh |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 69c1473..cdd9a2d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -284,7 +284,8 @@ prepare_loop() {
 	echo -n .
 
 	local LOOPFILE="$PWD/test.img"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size)) 2> /dev/null
+	rm -f "$LOOPFILE"
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size + 1)) 2> /dev/null
 	if LOOP=$(losetup -s -f "$LOOPFILE" 2>/dev/null); then
 		:
 	elif LOOP=$(losetup -f) && losetup "$LOOP" "$LOOPFILE"; then
@@ -367,8 +368,11 @@ prepare_devs() {
 	local n=${1:-3}
 	local devsize=${2:-34}
 	local pvname=${3:-pv}
+	local shift=0
 
 	prepare_backing_dev $(($n*$devsize))
+	# shift start of PV devices on /dev/loopXX by 1M
+	not diff LOOP BACKING_DEV >/dev/null 2>&1 || shift=2048
 	echo -n "## preparing $n devices..."
 
 	local size=$(($devsize*2048)) # sectors
@@ -379,7 +383,7 @@ prepare_devs() {
 		local dev="$DM_DEV_DIR/mapper/$name"
 		DEVICES[$count]=$dev
 		count=$(( $count + 1 ))
-		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size)) > "$name.table"
+		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size + $shift)) > "$name.table"
 		if not dmsetup create -u "TEST-$name" "$name" "$name.table" &&
 		   test -n "$LVM_TEST_BACKING_DEVICE";
 		then # maybe the backing device is too small for this test
@@ -408,6 +412,10 @@ prepare_devs() {
 	printf "%s\n" "${DEVICES[@]}" > DEVICES
 #	( IFS=$'\n'; echo "${DEVICES[*]}" ) >DEVICES
 	echo "ok"
+
+	for dev in "${DEVICES[@]}"; do
+		notify_lvmetad "$dev"
+	done
 }
 
 # Replace linear PV device with its 'delayed' version
@@ -894,6 +902,8 @@ dmsetup_wrapped() {
 	dmsetup "$@"
 }
 
+test -z "$LVM_TEST_AUX_TRACE" || set -x
+
 test -f DEVICES && devs=$(< DEVICES)
 
 if test "$1" = dmsetup; then


