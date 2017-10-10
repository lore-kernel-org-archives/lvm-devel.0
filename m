From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 10 Oct 2017 08:19:29 -0400
Subject: master - fsadm: add support for crypt devices
Message-ID: <201710101219.v9ACJTuV031199@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30293baaa0f87efeab81f01f9c5d73b26869babf
Commit:        30293baaa0f87efeab81f01f9c5d73b26869babf
Parent:        22789563dec6d470a48e728305e6e0a92ff92a9f
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Oct 6 16:28:35 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 10 14:18:57 2017 +0200

fsadm: add support for crypt devices

---
 WHATS_NEW        |    1 +
 man/fsadm.8_main |    8 +++-
 scripts/fsadm.sh |  142 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 146 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4314c69..9140858 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Support for encrypted devices in fsadm.
   Improve thin pool overprovisioning and repair warning messages.
 
 Version 2.02.175 - 6th October 2017
diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index c46033c..799cb25 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -65,6 +65,11 @@ Be more verbose.
 Answer "yes" at any prompts.
 .
 .HP
+.BR -c | --cryptresize
+.br
+Resize dm-crypt mapping together with filesystem detected on the device. The dm-crypt device must be recognizable by cryptsetup(8).
+.
+.HP
 .BR \fInew_size [ B | K | M | G | T | P | E ]
 .br
 Absolute number of filesystem blocks to be in the filesystem,
@@ -111,4 +116,5 @@ Defaults to "\fI/dev\fP" and must be an absolute path.
 .BR resize_reiserfs (8),
 .BR xfs_info (8),
 .BR xfs_growfs (8),
-.BR xfs_check (8)
+.BR xfs_check (8),
+.BR cryptsetup (8)
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 753da2b..da687fd 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -17,7 +17,7 @@
 # Script for resizing devices (usable for LVM resize)
 #
 # Needed utilities:
-#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check
+#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check, cryptsetup
 #
 # ext2/ext3/ext4: resize2fs, tune2fs
 # reiserfs: resize_reiserfs, reiserfstune
@@ -56,6 +56,7 @@ FSCK=fsck
 XFS_CHECK=xfs_check
 # XFS_REPAIR -n is used when XFS_CHECK is not found
 XFS_REPAIR=xfs_repair
+CRYPTSETUP=cryptsetup
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -101,6 +102,7 @@ tool_usage() {
 	echo "    -f | --force        Bypass sanity checks"
 	echo "    -n | --dry-run      Print commands without running them"
 	echo "    -l | --lvresize     Resize given device (if it is LVM device)"
+	echo "    -c | --cryptresize  Resize given crypt device"
 	echo "    -y | --yes          Answer \"yes\" at any prompts"
 	echo
 	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"
@@ -152,7 +154,7 @@ cleanup() {
 		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
 		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
-		dry exec "$LVM" lvresize $VERB $FORCE -r -L"${NEWSIZE}b" "$VOLUME_ORIG"
+		dry exec "$LVM" lvresize $VERB $FORCE -r -L"${NEWSIZE_ORIG}b" "$VOLUME_ORIG"
 	fi
 
 	# error exit status for break
@@ -196,7 +198,7 @@ decode_major_minor() {
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	VOLUME_ORIG=$1
+	test -n "$VOLUME_ORIG" || VOLUME_ORIG=$1
 	VOLUME=${1/#"${DM_DEV_DIR}/"/}
 	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME")
 	test -n "$VOLUME" || error "Cannot get readlink \"$1\"."
@@ -520,6 +522,131 @@ resize_xfs() {
 	fi
 }
 
+# Find active LUKS device on original volume
+# 1) look for LUKS device with well-known UUID format (CRYPT-LUKS[12]-<uuid>-<dmname>)
+# 2) the dm-crypt device has to be on top of original device (dont't support detached LUKS headers)
+detect_luks_device() {
+	local _LUKS_VERSION=
+	local _LUKS_UUID=
+
+	CRYPT_NAME=""
+	CRYPT_DATA_OFFSET=""
+
+	_LUKS_VERSION=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "Version:")
+
+	if [ -z $_LUKS_VERSION ]; then
+		verbose "Failed to parse LUKS version on volume \"$VOLUME\""
+		return
+	fi
+
+	_LUKS_VERSION=${_LUKS_VERSION//[Version:[:space:]]/}
+
+	_LUKS_UUID=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "UUID:")
+
+	if [ -z $_LUKS_UUID ]; then
+		verbose "Failed to parse LUKS UUID on volume \"$VOLUME\""
+		return
+	fi
+
+	_LUKS_UUID="CRYPT-LUKS$_LUKS_VERSION-${_LUKS_UUID//[UID:[:space:]-]/}-*"
+
+	CRYPT_NAME=$(dmsetup info -c --noheadings -S "UUID=~$_LUKS_UUID&&segments=1&&devnos_used='$MAJOR:$MINOR'" -o name)
+	test -z "$CRYPT_NAME" || CRYPT_DATA_OFFSET=$(dmsetup table $CRYPT_NAME | cut -d ' ' -f 8)
+}
+
+######################################
+# Resize active LUKS device
+# - LUKS must be active for fs resize
+######################################
+resize_luks() {
+	local NEWFSIZE=
+	local NEWCBLOCKCOUNT=
+	local NAME=""
+	local SHRINK=0
+
+	detect_luks_device
+
+	# LUKS device must be active and mapped over volume where detected
+	if [ -z "$CRYPT_NAME" -o -z "$CRYPT_DATA_OFFSET" ]; then
+		error "Can not find active LUKS device. Unlock \"$VOLUME\" volume first."
+	fi
+
+	NAME=$CRYPT_NAME
+
+	verbose "Found active LUKS device \"$NAME\" for volume \"$VOLUME\""
+
+	decode_size "$1" 512
+
+	if [ $((NEWSIZE % 512)) -gt 0 ]; then
+		error "New size is not sector alligned"
+	fi
+
+	NEWCBLOCKCOUNT=$((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET))
+	NEWFSIZE=$(( NEWCBLOCKCOUNT * 512))
+
+	VOLUME="/dev/mapper/$NAME"
+	detect_device_size
+
+	test "$DEVSIZE" -le "$NEWSIZE" || SHRINK=1
+
+	if [ $SHRINK -eq 1 ]; then
+		# shrink fs on LUKS device first
+		resize "/dev/mapper/$NAME" "$NEWFSIZE"b
+	fi
+
+	# resize LUKS device
+	dry $CRYPTSETUP resize $NAME --size $NEWCBLOCKCOUNT || error "Failed to resize active LUKS device"
+
+	if [ $SHRINK -eq 0 ]; then
+		# grow fs on top of LUKS device
+		resize "/dev/mapper/$NAME" "$NEWFSIZE"b
+	fi
+}
+
+#################################
+# Resize active crypt device
+#  (on direct user request only)
+#################################
+resize_crypt() {
+	local CRYPT_TYPE=
+	local TMP=
+	local SHRINK=0
+
+	which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
+
+	CRYPT_TYPE=$($CRYPTSETUP status $1 2> /dev/null | $GREP "type:")
+
+	test -n "$CRYPT_TYPE" || error "$CRYPTSETUP failed to detect device type on $1."
+
+	CRYPT_TYPE=${CRYPT_TYPE##*[[:space:]]}
+
+	TMP=$NEWSIZE
+
+	decode_size "$2" 512
+	detect_device_size
+
+	if [ "$DEVSIZE" -gt "$NEWSIZE" ]; then
+		SHRINK=1
+	fi
+
+	NEWSIZE=$TMP
+
+	if [ $SHRINK -eq 1 -a -z "$3" ]; then
+		return
+	fi
+
+	# going to resize, drop the request flag
+	unset DO_CRYPTRESIZE
+
+	case "$CRYPT_TYPE" in
+	 LUKS[12]|PLAIN)
+		dry $CRYPTSETUP resize "$1" --size $NEWBLOCKCOUNT || error "Failed to resize device $1"
+		;;
+	 *)
+		error "Unsupported crypt type \"$CRYPT_TYPE\""
+	esac
+}
+
 ####################
 # Resize filesystem
 ####################
@@ -531,14 +658,19 @@ resize() {
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
+	test -n "$NEWSIZE_ORIG" || NEWSIZE_ORIG=$NEWSIZE
 	IFS=$NL
+	test -z "$DO_CRYPTRESIZE" || resize_crypt "$VOLUME_ORIG" "$NEWSIZE_ORIG"
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
+	  "crypto_LUKS")
+		which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
+		resize_luks $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac || error "Resize $FSTYPE failed."
-	cleanup 0
+	test -z "$DO_CRYPTRESIZE" || resize_crypt "$VOLUME_ORIG" "$NEWSIZE_ORIG" do_shrink
 }
 
 ####################################
@@ -641,6 +773,7 @@ do
 	  "-e"|"--ext-offline") EXTOFF=1 ;;
 	  "-y"|"--yes") YES="-y" ;;
 	  "-l"|"--lvresize") DO_LVRESIZE=1 ;;
+	  "-c"|"--cryptresize") DO_CRYPTRESIZE=1 ;;
 	  "check") CHECK=$2 ; shift ;;
 	  "resize") RESIZE=$2 ; NEWSIZE=$3 ; shift 2 ;;
 	  *) error "Wrong argument \"$1\". (see: $TOOL --help)"
@@ -656,6 +789,7 @@ if [ -n "$CHECK" ]; then
 elif [ -n "$RESIZE" ]; then
 	export FSADM_RUNNING="fsadm"
 	resize "$RESIZE" "$NEWSIZE"
+	cleanup 0
 else
 	error "Missing command. (see: $TOOL --help)"
 fi


