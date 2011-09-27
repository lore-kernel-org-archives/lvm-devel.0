From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:22 +0200
Subject: [PATCH 08/16] fsadm: Remove unnecessary modification of PATH variable
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-9-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

User (or the system) should be set properly so there is no need to
modify PATH variable. It also prevent us from setting appropriate PATH
before calling the fsadm.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index d9120b2..abd9c3f 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -37,9 +37,6 @@
 
 TOOL=$(basename "$0")
 
-_SAVEPATH=$PATH
-PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
-
 # utilities
 TUNE_EXT=tune2fs
 RESIZE_EXT=resize2fs
@@ -297,10 +294,7 @@ decode_size() {
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
@@ -312,6 +306,12 @@ detect_fs() {
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
@@ -532,6 +532,7 @@ resize_fs() {
 	detect_fs "$1" ||  error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 	if [ "$NEWSIZE" ]; then
+		decode_size $NEWSIZE
 		is_natural $NEWSIZE ||  error "$NEWSIZE is not valid number for file system size"
 	fi
 	detect_device_size
@@ -562,6 +563,7 @@ resize_lvolume() {
 
 resize() {
 	local size=
+	devcount=
 
 	# Special case for the situation we have been called from within the lvresize code.
 	# How crazy is that ?:) But anyway to preserve the old behaviour it is there.
@@ -571,7 +573,8 @@ resize() {
 	fi
 
 	for i in "$@"; do
-		if [ -b "$i" ]; then
+		get_volume "$i"
+		if [ -b "$VOLUME" ]; then
 			if [ -z "$devcount" ]; then
 				"$LVM" lvs "$i" &> /dev/null || error "$i is not valid logical volume"
 				lvname=$i
@@ -811,9 +814,10 @@ do_remove() {
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


