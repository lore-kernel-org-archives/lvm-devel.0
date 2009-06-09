From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jun 2009 15:31:37 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20090609153137.19485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-06-09 15:31:36

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Use 'lvm lvresize' instead of 'lvresize' in fsadm.
	Do not use '-n' realine option in fsadm for busybox compatiblity.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1144&r2=1.1145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2009/06/09 14:43:59	1.1144
+++ LVM2/WHATS_NEW	2009/06/09 15:31:36	1.1145
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Use 'lvm lvresize' instead of 'lvresize' in fsadm.
+  Do not use '-n' realine option in fsadm for busybox compatiblity.
   Update vgrename, vgsplit, and vgcreate to use vg_lock_newname.
   Add vg_lock_newname() library function.
   Round up requested readahead to at least one page and print warning.
--- LVM2/scripts/fsadm.sh	2009/02/24 15:48:01	1.10
+++ LVM2/scripts/fsadm.sh	2009/06/09 15:31:36	1.11
@@ -48,7 +48,8 @@
 FSCK=fsck
 XFS_CHECK=xfs_check
 
-LVRESIZE=lvresize
+# user may override lvm location by setting LVM_BINARY
+LVM=${LVM_BINARY-lvm}
 
 YES=
 DRY=0
@@ -66,6 +67,9 @@
 REMOUNT=
 
 IFS_OLD=$IFS
+# without bash $'\n'
+NL='
+'
 
 tool_usage() {
 	echo "${TOOL}: Utility to resize or check the filesystem on a device"
@@ -124,7 +128,7 @@
 	# start LVRESIZE with the filesystem modification flag
 	# and allow recursive call of fsadm
 	unset FSADM_RUNNING
-	test "$DO_LVRESIZE" -eq 2 && exec $LVRESIZE $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
+	test "$DO_LVRESIZE" -eq 2 && exec $LVM lvresize $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
 	exit ${1:-0}
 }
 
@@ -155,7 +159,9 @@
 # dereference device name if it is symbolic link
 detect_fs() {
         VOLUME=${1#/dev/}
-	VOLUME=$($READLINK $READLINK_E -n "/dev/$VOLUME") || error "Cannot get readlink $1"
+	VOLUME=$($READLINK $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
+	# strip newline from volume name
+	VOLUME=${VOLUME%%$NL}
 	# use /dev/null as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
 	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
@@ -324,8 +330,7 @@
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
 	trap cleanup 2
-	#IFS=$'\n'  # don't use bash-ism ??
-	IFS="$(printf \"\\n\")"  # needed for parsing output
+	IFS=$NL
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
@@ -359,10 +364,11 @@
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" \
+  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVM" \
   || error "Required command definitions in the script are missing!"
 
-$($READLINK -e -n / >/dev/null 2>&1) || READLINK_E="-f"
+$LVM version >/dev/null 2>&1 || error "Could not run lvm binary '$LVM'"
+$($READLINK -e / >/dev/null 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
 $(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"


