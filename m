From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 24 Oct 2017 07:43:12 -0400
Subject: master - fsadm: refactor resize_crypt function
Message-ID: <201710241143.v9OBhC2F031263@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dcc8f90c587be5e60f45847d7c8ffc945e78d41c
Commit:        dcc8f90c587be5e60f45847d7c8ffc945e78d41c
Parent:        9916d8fa9ad82eeb63c85b1b74879c8da56f74a0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 24 11:53:22 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 24 13:41:16 2017 +0200

fsadm: refactor resize_crypt function

split resize_crypt function in two.

a) Detect proper dm-crypt device type and count new --size
   value for cryptsetup resize command.

b) Perform the resize
---
 scripts/fsadm.sh |   60 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 25bddba..4f402ce 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -607,16 +607,12 @@ resize_luks() {
 	fi
 }
 
-#################################
-# Resize active crypt device
-#  (on direct user request only)
-#################################
-resize_crypt() {
-	local CRYPT_TYPE=
-	local TMP=
-	local SHRINK=0
+detect_crypt_device() {
+	local CRYPT_TYPE
+	local L_NEWSIZE
+	local TMP
 
-	which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
+	which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize crypt device"
 
 	CRYPT_TYPE=$($CRYPTSETUP status $1 2> /dev/null | $GREP "type:")
 
@@ -624,31 +620,38 @@ resize_crypt() {
 
 	CRYPT_TYPE=${CRYPT_TYPE##*[[:space:]]}
 
-	TMP=$NEWSIZE
+	case "$CRYPT_TYPE" in
+	 LUKS[12]|PLAIN)
+		verbose "\"$1\" crypt device is type $CRYPT_TYPE"
+		;;
+	 *)
+		error "Unsupported crypt type \"$CRYPT_TYPE\""
+	esac
 
+	TMP=$NEWSIZE
 	decode_size "$2" 512
-	detect_device_size
+	L_NEWSIZE=$NEWSIZE
+	NEWSIZE=$TMP
 
-	if [ "$DEVSIZE" -gt "$NEWSIZE" ]; then
-		SHRINK=1
+	if [ $((L_NEWSIZE % 512)) -ne 0 ]; then
+		error "New size is not sector alligned"
 	fi
 
-	NEWSIZE=$TMP
+	CRYPT_RESIZE_BLOCKS=$NEWBLOCKCOUNT
 
-	if [ $SHRINK -eq 1 -a -z "$3" ]; then
-		return
+	if [ "$DEVSIZE" -ge "$L_NEWSIZE" ]; then
+		CRYPT_SHRINK=1
+	else
+		CRYPT_GROW=1
 	fi
+}
 
-	# going to resize, drop the request flag
-	unset DO_CRYPTRESIZE
-
-	case "$CRYPT_TYPE" in
-	 LUKS[12]|PLAIN)
-		dry $CRYPTSETUP resize "$1" --size $NEWBLOCKCOUNT || error "Failed to resize device $1"
-		;;
-	 *)
-		error "Unsupported crypt type \"$CRYPT_TYPE\""
-	esac
+#################################
+# Resize active crypt device
+#  (on direct user request only)
+#################################
+resize_crypt() {
+	dry $CRYPTSETUP resize "$1" --size $CRYPT_RESIZE_BLOCKS || error "$CRYPTSETUP failed to resize device $1"
 }
 
 ####################
@@ -664,7 +667,8 @@ resize() {
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
 	test -n "$NEWSIZE_ORIG" || NEWSIZE_ORIG=$NEWSIZE
 	IFS=$NL
-	test -z "$DO_CRYPTRESIZE" || resize_crypt "$VOLUME_ORIG" "$NEWSIZE_ORIG"
+	test -z "$DO_CRYPTRESIZE" || detect_crypt_device "$VOLUME_ORIG" "$NEWSIZE_ORIG"
+	test -z "$CRYPT_GROW" || resize_crypt "$VOLUME_ORIG"
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
@@ -674,7 +678,7 @@ resize() {
 		resize_luks $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac || error "Resize $FSTYPE failed."
-	test -z "$DO_CRYPTRESIZE" || resize_crypt "$VOLUME_ORIG" "$NEWSIZE_ORIG" do_shrink
+	test -z "$CRYPT_SHRINK" || resize_crypt "$VOLUME_ORIG"
 }
 
 ####################################


