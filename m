From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:42 +0200
Subject: [PATCH v3 09/18] fsadm: Allow to specify lv in vg/lv format
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-10-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Various lvm tools does allow to specify logical volume in vg/lv
format, which meand no real path is provided.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index a1044f7..0a2c8cc 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -294,10 +294,7 @@ decode_size() {
 	NEWBLOCKCOUNT=${NEWBLOCKCOUNT%%.*}
 }
 
-# detect filesystem on the given device
-# dereference device name if it is symbolic link
-detect_fs() {
-	VOLUME_ORIG="$1"
+get_volume() {
 	VOLUME=${DM_DEV_DIR}/${1/#"${DM_DEV_DIR}/"/}
 	if [ -h "$VOLUME" ]; then
 		VOLUME=$("$READLINK" "$READLINK_E" "$VOLUME") || error "Cannot get readlink \"$VOLUME\""
@@ -309,6 +306,12 @@ detect_fs() {
 		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
 		;;
 	esac
+}
+
+# detect filesystem on the given device
+# dereference device name if it is symbolic link
+detect_fs() {
+	get_volume "$1"
 	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
 	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME") || return 1
@@ -529,6 +532,7 @@ resize_fs() {
 	detect_fs "$1" ||  error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 	if [ "$NEWSIZE" ]; then
+		decode_size $NEWSIZE
 		is_natural $NEWSIZE ||  error "$NEWSIZE is not valid number for file system size"
 	fi
 	detect_device_size
@@ -559,6 +563,7 @@ resize_lvolume() {
 
 resize() {
 	local size=
+	devcount=
 
 	# Special case for the situation we have been called from within the lvresize code.
 	if [ "$RESIZE_FS_ONLY" ]; then
@@ -567,7 +572,8 @@ resize() {
 	fi
 
 	for i in "$@"; do
-		if [ -b "$i" ]; then
+		get_volume "$i"
+		if [ -b "$VOLUME" ]; then
 			if [ -z "$devcount" ]; then
 				"$LVM" lvs "$i" &> /dev/null || error "$i is not valid logical volume"
 				lvname=$i
@@ -810,9 +816,10 @@ do_remove() {
 	device=
 	MOUNTED=
 
+	get_volume "$item"
 	# Block device has been given
-	if [ -b "$item" ]; then
-		device=$item
+	if [ -b "$VOLUME" ]; then
+		device=$VOLUME
 	fi
 
 	# Mount point has been given
-- 
1.7.4.4


