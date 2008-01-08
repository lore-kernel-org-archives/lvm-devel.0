From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jan 2008 16:45:43 -0000
Subject: LVM2/scripts fsadm.sh
Message-ID: <20080108164543.4398.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-01-08 16:45:43

Modified files:
	scripts        : fsadm.sh 

Log message:
	added more safety checks
	fixed error reporting commands
	extended with Exa and Peta support

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/fsadm.sh	2007/12/20 15:42:55	1.3
+++ LVM2/scripts/fsadm.sh	2008/01/08 16:45:43	1.4
@@ -12,7 +12,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 #
-# Author: Zdenek Kabelac <zkabelac@redhat.com>
+# Author: Zdenek Kabelac <zkabelac@redhat.com>
 #
 # Script for resizing devices (usable for LVM resize)
 #
@@ -39,9 +39,9 @@
 MOUNT=mount
 UMOUNT=umount
 MKDIR=mkdir
-RM=rm
-BLOCKDEV=echo 
-BLKID=echo
+RMDIR=rmdir
+BLOCKDEV=blockdev
+BLKID=blkid
 GREP=grep
 READLINK=readlink
 FSCK=fsck
@@ -69,7 +69,7 @@
 	echo "  ${TOOL} [options] check device"
 	echo "    - Check the filesystem on device using fsck"
 	echo
-	echo "  ${TOOL} [options] resize device [new_size[BKMGT]]"
+	echo "  ${TOOL} [options] resize device [new_size[BKMGTPE]]"
 	echo "    - Change the size of the filesystem on device to new_size"
 	echo
 	echo "  Options:"
@@ -97,8 +97,11 @@
 }
 
 dry() {
+	if [ "$DRY" -ne 0 ]; then
+		verbose "Dry execution $@"
+		return 0
+	fi
 	verbose "Executing $@"
-	test "$DRY" -ne 0 && return 0
 	$@
 }
 
@@ -115,10 +118,12 @@
 	exit $1
 }
 
-# convert parameters from Mega/Kilo/Bytes/Blocks
-# and print number of bytes
+# convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
+# (2^(60/50/40/30/20/10/0))
 decode_size() {
 	case "$1" in
+	 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
+	 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
 	 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
 	 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
 	 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
@@ -133,14 +138,15 @@
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	VOLUME=$($READLINK -n "$1")
+	VOLUME=$($READLINK -e -n "$1") || error "Cannot get readlink $1"
 	# use /dev/null as cache file to be sure about the result
-	FSTYPE=$($BLKID -c /dev/null -o value -s TYPE "$VOLUME" || error "Cannot get FSTYPE of \"$VOLUME\"")
+	FSTYPE=$($BLKID -c /dev/null -o value -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
 # check if the given device is already mounted and where
 detect_mounted()  {
+	$MOUNT >/dev/null || error "Cannot detect mounted device $VOLUME"
 	MOUNTED=$($MOUNT | $GREP "$VOLUME")
 	MOUNTED=${MOUNTED##* on }
 	MOUNTED=${MOUNTED% type *} # allow type in the mount name
@@ -165,7 +171,9 @@
 }
 
 temp_umount() {
-	dry $UMOUNT "$TEMPDIR" && dry $RM -r "${TEMPDIR%%m}" || error "Failed to umount $TEMPDIR"
+	dry $UMOUNT "$TEMPDIR" || error "Failed to umount $TEMPDIR"
+	dry $RMDIR "${TEMPDIR}" || error "Failed to remove $TEMPDIR"
+	dry $RMDIR "${TEMPDIR%%m}" || error "Failed to remove ${TEMPDIR%%m}"
 }
 
 yes_no() {
@@ -207,7 +215,7 @@
 	decode_size $1 $BLOCKSIZE
 	FSFORCE=$FORCE
 
-	if [ $NEWBLOCKCOUNT -lt $BLOCKCOUNT -o $EXTOFF -eq 1 ]; then
+	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
 		detect_mounted && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
 		# CHECKME: after umount resize2fs requires fsck or -f flag.
@@ -288,7 +296,7 @@
 	verbose "Device \"$VOLUME\" has $DEVSIZE bytes"
 	# if the size parameter is missing use device size
 	NEWSIZE=$2
-	test -z $NEWSIZE && NEWSIZE=${DEVSIZE}b
+	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
 	trap cleanup 2
 	#IFS=$'\n'  # don't use bash-ism ??
 	IFS="$(printf \"\\n\")"  # needed for parsing output
@@ -316,6 +324,18 @@
 # start point of this script
 # - parsing parameters
 #############################
+
+# test some prerequisities
+test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
+  -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
+  -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
+  -a -n "$FSCK" -a -n "$XFS_CHECK" || error "Required command definitions in the script are missing!"
+$($READLINK -e -n / >/dev/null 2>&1) || error "$READLINK does not support options -e -n"
+TEST64BIT=$(( 1000 * 1000000000000 ))
+test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
+$(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"
+
+
 if [ "$1" = "" ] ; then
 	tool_usage
 fi


