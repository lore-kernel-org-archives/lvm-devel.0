From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2017 09:41:31 -0400
Subject: master - fsadm: some cleanup
Message-ID: <201705101341.v4ADfViY005118@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ea33b633a1d856a4347f6ecf98a50c1d2b60d76
Commit:        8ea33b633a1d856a4347f6ecf98a50c1d2b60d76
Parent:        1107d483a26a5735de7d740fd3182d2e58960f63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 15:13:35 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:40:31 2017 +0200

fsadm: some cleanup

Put some extra "" around vars.
Indent.
Error messages with dots.
---
 scripts/fsadm.sh |   52 +++++++++++++++++++++++++---------------------------
 1 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 0d6c503..5574143 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -187,18 +187,16 @@ detect_fs() {
 	test -n "$VOLUME" || error "Cannot get readlink \"$1\"."
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
-          # hardcoded /dev  since udev does not create these entries elsewhere
+	  # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
 		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
-		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\""
+		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		;;
 	  *)
-		STAT=$(stat --format "MAJOR=%t MINOR=%T" ${RVOLUME})
+		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" ${RVOLUME})
 		test -n "$STAT" || error "Cannot get major:minor for \"$VOLUME\"."
-		eval $STAT
-		MAJOR=$((0x${MAJOR}))
-		MINOR=$((0x${MINOR}))
-		MAJORMINOR=${MAJOR}:${MINOR}
+		eval "$STAT"
+		MAJORMINOR="${MAJOR}:${MINOR}"
 		;;
 	esac
 	# use null device as cache file to be sure about the result
@@ -207,10 +205,10 @@ detect_fs() {
 	test -n "$FSTYPE" || error "Cannot get FSTYPE of \"$VOLUME\"."
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}
-	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
+	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\"."
 }
 
-detect_mounted_with_proc_self_mountinfo()  {
+detect_mounted_with_proc_self_mountinfo() {
 	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO")
 
 	# extract 5th field which is mount point
@@ -221,7 +219,7 @@ detect_mounted_with_proc_self_mountinfo()  {
 	test -n "$MOUNTED"
 }
 
-detect_mounted_with_proc_mounts()  {
+detect_mounted_with_proc_mounts() {
 	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
@@ -245,13 +243,13 @@ detect_mounted_with_proc_mounts()  {
 
 # check if the given device is already mounted and where
 # FIXME: resolve swap usage and device stacking
-detect_mounted()  {
+detect_mounted() {
 	if test -e "$PROCSELFMOUNTINFO"; then
 		detect_mounted_with_proc_self_mountinfo
 	elif test -e "$PROCMOUNTS"; then
 		detect_mounted_with_proc_mounts
 	else
-		error "Cannot detect mounted device \"$VOLUME\""
+		error "Cannot detect mounted device \"$VOLUME\"."
 	fi
 }
 
@@ -279,14 +277,14 @@ round_up_block_size() {
 }
 
 temp_mount() {
-	dry "$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR"
-	dry "$MOUNT" "$VOLUME" "$TEMPDIR" || error "Failed to mount $TEMPDIR"
+	dry "$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
+	dry "$MOUNT" "$VOLUME" "$TEMPDIR" || error "Failed to mount $TEMPDIR."
 }
 
 temp_umount() {
-	dry "$UMOUNT" "$TEMPDIR" || error "Failed to umount \"$TEMPDIR\""
-	dry "$RMDIR" "${TEMPDIR}" || error "Failed to remove \"$TEMPDIR\""
-	dry "$RMDIR" "${TEMPDIR%%m}" || error "Failed to remove \"${TEMPDIR%%m}\""
+	dry "$UMOUNT" "$TEMPDIR" || error "Failed to umount \"$TEMPDIR\"."
+	dry "$RMDIR" "${TEMPDIR}" || error "Failed to remove \"$TEMPDIR\","
+	dry "$RMDIR" "${TEMPDIR%%m}" || error "Failed to remove \"${TEMPDIR%%m}\"."
 }
 
 yes_no() {
@@ -306,11 +304,11 @@ yes_no() {
 
 try_umount() {
 	yes_no "Do you want to unmount \"$MOUNTED\"" && dry "$UMOUNT" "$MOUNTED" && return 0
-	error "Cannot proceed with mounted filesystem \"$MOUNTED\""
+	error "Cannot proceed with mounted filesystem \"$MOUNTED\"."
 }
 
 validate_parsing() {
-	test -n "$BLOCKSIZE" && test -n "$BLOCKCOUNT" || error "Cannot parse $1 output"
+	test -n "$BLOCKSIZE" && test -n "$BLOCKCOUNT" || error "Cannot parse $1 output."
 }
 ####################################
 # Resize ext2/ext3/ext4 filesystem
@@ -380,7 +378,7 @@ resize_xfs() {
 	MOUNTPOINT=$MOUNTED
 	if [ -z "$MOUNTED" ]; then
 		MOUNTPOINT=$TEMPDIR
-		temp_mount || error "Cannot mount Xfs filesystem"
+		temp_mount || error "Cannot mount Xfs filesystem."
 	fi
 	verbose "Parsing $TUNE_XFS \"$MOUNTPOINT\""
 	for i in $(LC_ALL=C "$TUNE_XFS" "$MOUNTPOINT"); do
@@ -398,7 +396,7 @@ resize_xfs() {
 	elif [ $NEWBLOCKCOUNT -eq $BLOCKCOUNT ]; then
 		verbose "Xfs filesystem already has the right size"
 	else
-		error "Xfs filesystem shrinking is unsupported"
+		error "Xfs filesystem shrinking is unsupported."
 	fi
 }
 
@@ -418,8 +416,8 @@ resize() {
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
-	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
-	esac || error "Resize $FSTYPE failed"
+	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
+	esac || error "Resize $FSTYPE failed."
 	cleanup 0
 }
 
@@ -500,12 +498,12 @@ for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
 	test -n "$i" || error "Required command definitions in the script are missing!"
 done
 
-"$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\""
+"$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\"."
 $("$READLINK" -e / >"$NULL" 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
-test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
-$(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly"
-test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
+test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic."
+$(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly."
+test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work."
 
 
 if [ "$#" -eq 0 ] ; then


