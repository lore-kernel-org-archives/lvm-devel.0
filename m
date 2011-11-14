From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:13:00 -0500
Subject: [PATCH 4/5] Add resize_dev() function to LVM nightly test library.
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1321305181-28158-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a resize device function to LVM nightly test library.  This will
help us test scenarios when devices get resized after being added to
LVM control.  This has been seen in customer environments, and today
LVM does not detect this condition.

To implement resize_dev, we needed two things:
1. The count of devices originally created via prepare_pvs
2. The size of the devices originally created via prepare_pvs

When I looked into #1, a reasonable solution seemed to be to save
a "NUM_DEVICES" to a file, similar to what is done with "LOOP".

For #2, the size of the loop device, divided by "NUM_DEVICES" would
suffice.  However, I discovered the actual size of the loop device
had a bug because of the 'dd' statement.  So I fixed that in this
patch as well.  You can easily see the bug if you dump 'loopsz'
in prepare_devs during create with say "prepare_pvs 3 10".

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/lib/aux.sh |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cde5581..25781fa 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -103,6 +103,7 @@ teardown_devs() {
 		test -f LOOPFILE && rm -f $(cat LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
+	rm -f NUM_DEVICES
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
@@ -203,7 +204,7 @@ prepare_loop() {
         echo -n .
 
 	LOOPFILE="$PWD/test.img"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1)) 2> /dev/null
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size)) 2> /dev/null
 	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
 		:
 	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then
@@ -314,6 +315,7 @@ prepare_devs() {
 	#done
 
         echo $devs > DEVICES
+        echo $n > NUM_DEVICES
         echo "ok"
 }
 
@@ -339,6 +341,34 @@ enable_dev() {
 	finish_udev_transaction
 }
 
+resize_dev() {
+	local dev="$1"
+	local new_size="$2"
+	if [ $# -ne 2 ]; then
+		echo "Usage: resize_dev devname size_in_mb"
+		return 1
+	fi
+
+	local name=`echo "$dev" | sed -e 's,.*/,,'`
+	local dev_num=`echo "$name" | sed -e 's/.*pv//g'`
+	if ! loopsz=`blockdev --getsz $LOOP 2>/dev/null`; then
+		loopsz=`blockdev --getsize $LOOP 2>/dev/null`
+	fi
+	local new_size_sectors=$((new_size * 1024 * 2))
+	local max_size_sectors=$(($loopsz / $NUM_DEVICES))
+
+	if [ "$new_size_sectors" -gt "$max_size_sectors" ]; then
+		echo "resize_dev: new size $new_size_sectors sectors exceeds maximum size $max_size_sectors sectors"
+		return 1
+	fi
+	disable_dev $dev
+	init_udev_transaction
+	echo "0 $new_size_sectors linear $LOOP $((($dev_num-1)*$max_size_sectors))" > $name.table
+	dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
+	dmsetup resume $name
+	finish_udev_transaction
+}
+
 backup_dev() {
 	for dev in "$@"; do
 		dd if=$dev of=$dev.backup bs=1024
@@ -482,6 +512,7 @@ target_at_least()
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
+test -f NUM_DEVICES && NUM_DEVICES=$(cat NUM_DEVICES)
 test -f LOOP && LOOP=$(cat LOOP)
 
 "$@"
-- 
1.7.4.4


