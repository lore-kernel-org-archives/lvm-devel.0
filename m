From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:38:07 +0000 (GMT)
Subject: stable-2.02 - fsadm: enhance error handling
Message-ID: <20201023233807.8F0AE386EC0B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a2a59c0ed4320324e908be60693bac7ed507824
Commit:        9a2a59c0ed4320324e908be60693bac7ed507824
Parent:        ab99382d7a614c299e765ea4d1f02fe7282502a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 01:13:42 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:33:39 2020 +0200

fsadm: enhance error handling

Set more secure bash failure mode for pipilines.
Avoid using unset variables.
Enhnace error reporting for failing command.
Avoid using error via 'case..esac || error'.
---
 scripts/fsadm.sh | 47 ++++++++++++++++++++++++++++-------------------
 1 file changed, 28 insertions(+), 19 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 5ca80b4dd..5bba5ff40 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -29,6 +29,8 @@
 #   2 break detected
 #   3 unsupported online filesystem check for given mounted fs
 
+set -euE -o pipefail
+
 TOOL=fsadm
 
 _SAVEPATH=$PATH
@@ -61,7 +63,7 @@ CRYPTSETUP=cryptsetup
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
 
-YES=${_FSADM_YES}
+YES="${_FSADM_YES-}"
 DRY=0
 VERB=
 FORCE=
@@ -206,7 +208,7 @@ decode_major_minor() {
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	test -n "$VOLUME_ORIG" || VOLUME_ORIG=$1
+	test -n "${VOLUME_ORIG-}" || VOLUME_ORIG=$1
 	VOLUME=${1/#"${DM_DEV_DIR}/"/}
 	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME")
 	test -n "$VOLUME" || error "Cannot get readlink \"$1\"."
@@ -257,11 +259,11 @@ check_valid_mounted_device() {
 	local MOUNTEDMAJORMINOR
 	local VOL
 	local CURNAME
-	local SUGGEST="Possibly device \"$1\" has been renamed to \"$CURNAME\"?"
 
 	VOL=$("$READLINK" $READLINK_E "$1")
 	CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings)
 	# more confused, device is not DM....
+	local SUGGEST="Possibly device \"$1\" has been renamed to \"$CURNAME\"?"
 	test -n "$CURNAME" || SUGGEST="Mounted volume is not a device mapper device???"
 
 	test -n "$VOL" ||
@@ -270,7 +272,7 @@ check_valid_mounted_device() {
 		"Filesystem utilities currently do not support renamed devices."
 
 	case "$VOL" in
-	  # hardcoded /dev  since udev does not create these entries elsewhere
+	  # hardcoded /dev  since kernel does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
 		read -r <"/sys/block/${VOL#/dev/}/dev" MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		;;
@@ -674,20 +676,23 @@ resize() {
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
-	test -n "$NEWSIZE_ORIG" || NEWSIZE_ORIG=$NEWSIZE
+	NEWSIZE_ORIG=${NEWSIZE_ORIG:-$NEWSIZE}
 	IFS=$NL
-	test -z "$DO_CRYPTRESIZE" || detect_crypt_device "$VOLUME_ORIG" "$NEWSIZE_ORIG"
-	test -z "$CRYPT_GROW" || resize_crypt "$VOLUME_ORIG"
+	test -z "${DO_CRYPTRESIZE-}" || detect_crypt_device "$VOLUME_ORIG" "$NEWSIZE_ORIG"
+	test -z "${CRYPT_GROW-}" || resize_crypt "$VOLUME_ORIG"
+
 	case "$FSTYPE" in
-	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
-	  "reiserfs") resize_reiser $NEWSIZE ;;
-	  "xfs") resize_xfs $NEWSIZE ;;
+	  ext[234])	CMD=resize_ext ;;
+	  "reiserfs")	CMD=resize_reiser ;;
+	  "xfs")	CMD=resize_xfs ;;
 	  "crypto_LUKS")
 		which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
-		resize_luks $NEWSIZE ;;
+		CMD=resize_luks ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
-	esac || error "Resize $FSTYPE failed."
-	test -z "$CRYPT_SHRINK" || resize_crypt "$VOLUME_ORIG"
+	esac
+
+	$CMD $NEWSIZE || error "$FSTYPE resize failed."
+	test -z "${CRYPT_SHRINK-}" || resize_crypt "$VOLUME_ORIG"
 }
 
 ####################################
@@ -716,7 +721,7 @@ check() {
 	fi
 
 	case "$FSTYPE" in
-	  "ext2"|"ext3"|"ext4")
+	  ext[234])
 		IFS_CHECK=$IFS
 		IFS=$NL
 		for i in $(LC_ALL=C "$TUNE_EXT" -l "$VOLUME"); do
@@ -740,15 +745,15 @@ check() {
 
 	case "$FSTYPE" in
 	  "xfs") if which "$XFS_CHECK" >"$NULL" 2>&1 ; then
-			dry "$XFS_CHECK" "$VOLUME"
+			dry "$XFS_CHECK" "$VOLUME" || error "Xfs check failed."
 		 else
 			# Replacement for outdated xfs_check
 			# FIXME: for small devices we need to force_geometry,
 			# since we run in '-n' mode, it shouldn't be problem.
 			# Think about better way....
-			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME"
+			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME" || error "Xfs repair failed."
 		 fi ;;
-	  "ext2"|"ext3"|"ext4"|"reiserfs")
+	  ext[234]|"reiserfs")
 	        # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) FLAG=$YES ;;
@@ -758,7 +763,8 @@ check() {
 		;;
 	  "crypto_LUKS")
 		which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required."
-		check_luks ;;
+		check_luks || error "Crypto luks check failed."
+		;;
 	  *)
 		error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac
@@ -771,7 +777,7 @@ check() {
 trap "cleanup 2" 2
 
 # test if we are not invoked recursively
-test -n "$FSADM_RUNNING" && exit 0
+test -n "${FSADM_RUNNING-}" && exit 0
 
 # test some prerequisities
 for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
@@ -793,6 +799,9 @@ if [ "$#" -eq 0 ] ; then
 	tool_usage
 fi
 
+CHECK=""
+RESIZE=""
+
 while [ "$#" -ne 0 ]
 do
 	 case "$1" in


