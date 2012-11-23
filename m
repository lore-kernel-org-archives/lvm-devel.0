From: Ondrej Kozina <okozina@redhat.com>
Date: Fri, 23 Nov 2012 15:48:36 +0100
Subject: [PATCH 1/3] - add btrfs support into fsadm
In-Reply-To: <1353682118-17855-1-git-send-email-okozina@redhat.com>
References: <1353682118-17855-1-git-send-email-okozina@redhat.com>
Message-ID: <1353682118-17855-2-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 scripts/fsadm.sh | 141 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 133 insertions(+), 8 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4624a1c..6adbe09 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -17,11 +17,12 @@
 # Script for resizing devices (usable for LVM resize)
 #
 # Needed utilities:
-#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check
+#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check, btrfs-progs, lsblk, findmnt
 #
 # ext2/ext3/ext4: resize2fs, tune2fs
 # reiserfs: resize_reiserfs, reiserfstune
 # xfs: xfs_growfs, xfs_info
+# btrfs: btrfs, btrfsck
 #
 # Return values:
 #   0 success
@@ -41,6 +42,7 @@ TUNE_REISER=reiserfstune
 RESIZE_REISER=resize_reiserfs
 TUNE_XFS=xfs_info
 RESIZE_XFS=xfs_growfs
+BTRFS=btrfs
 
 MOUNT=mount
 UMOUNT=umount
@@ -48,12 +50,15 @@ MKDIR=mkdir
 RMDIR=rmdir
 BLOCKDEV=blockdev
 BLKID=blkid
+# set by check_findmnt()
+FINDMNT=
 DATE=date
 GREP=grep
 READLINK=readlink
 READLINK_E="-e"
 FSCK=fsck
 XFS_CHECK=xfs_check
+BTRFS_CHECK=btrfsck
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -74,12 +79,16 @@ MOUNTPOINT=
 MOUNTED=
 REMOUNT=
 PROCMOUNTS="/proc/mounts"
+PROCPARTITIONS="/proc/partitions"
 NULL="$DM_DEV_DIR/null"
+BTRFS_DEVID=
+UUID=
 
 IFS_OLD=$IFS
 # without bash $'\n'
 NL='
 '
+READ_IFS=" $(echo -n -e '\t')"
 
 tool_usage() {
 	echo "${TOOL}: Utility to resize or check the filesystem on a device"
@@ -152,6 +161,10 @@ cleanup() {
 	exit ${1:-1}
 }
 
+check_findmnt() {
+	FINDMNT=$(which findmnt 2> $NULL);
+}
+
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
 # (2^(60/50/40/30/20/10/0))
 decode_size() {
@@ -196,15 +209,87 @@ detect_fs() {
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
+detect_fs_uuid() {
+	UUID=$($BLKID -o value -c $NULL -s UUID "$VOLUME" 2>$NULL)
+
+	test -n "$UUID"
+}
+
+# example:
+# 'btrfs fi show' output :
+# 	devid    3 size 1.00GB used 894.50MB path /dev/sdb
+# need:		 ^
+btrfs_parse_devid() {
+	local a devid b
+	while read -r a devid b;
+	do
+		echo -n "$devid";
+	done;
+}
+
+btrfs_get_devid() {
+	local STR_IFS=$IFS
+
+	TMP=$(lsblk -Pdno MAJ:MIN $VOLUME)
+	TMP=${TMP##*=\"}
+	MAJOR=${TMP%%:*}
+	MINOR=${TMP##*:}
+	MINOR=${MINOR%%\"*}
+
+	test -n "$MAJOR" -a -n "$MINOR" || error "Can't get \"$VOLUME\" major:minor numbers"
+
+	IFS=$READ_IFS
+	test -e "$PROCPARTITIONS" || error "Can't read $PROCPARTITIONS"
+	while read -r RMAJOR RMINOR RSIZE RDEV;
+	do
+		if [ "$RMAJOR" = "$MAJOR" -a "$RMINOR" = "$MINOR" ] ; then
+			BTRFS_DEVICE=$RDEV
+			break;
+		fi
+	done <$PROCPARTITIONS
+
+	test -z $BTRFS_DEVICE || $BTRFS filesystem show "$UUID" 2> $NULL | $GREP "/dev/$BTRFS_DEVICE" | btrfs_parse_devid
+	IFS=$STR_IFS
+}
+
+
+# The whole btrfs volume (subvolid=0) is identified by UUID.
+# Also there can be multiple subvolumes mounted as well
+# identified by same UUID
+get_first_mounted_subvolume() {
+	local TMP
+	local STR_IFS=$IFS
+	IFS=$READ_IFS
+
+	read -r TMP<<EOF
+$($FINDMNT -nuP -o TARGET,UUID 2>$NULL | $GREP "$UUID")
+EOF
+
+	TMP=${TMP##*TARGET=\"}
+	TMP=${TMP%%\"*}
+	echo -n $TMP
+
+	IFS=$STR_IFS
+}
+
+detect_mounted_findmnt() {
+	MOUNTED=$(get_first_mounted_subvolume)
+
+	verbose "found $MOUNTED"
+	test -n "$MOUNTED"
+}
+
 # check if the given device is already mounted and where
 # FIXME: resolve swap usage and device stacking
-detect_mounted()  {
-	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
+# $1 - VOLUME
+# $2 - RVOLUME
+detect_mounted_classic() {
+	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$1\""
 
-	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
+	MOUNTED=$("$GREP" "^$1[ \t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$2[ \t]" "$PROCMOUNTS")
 
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
@@ -213,8 +298,8 @@ detect_mounted()  {
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
-		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
+		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$1[ \t]")
+		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$2[ \t]")
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
@@ -222,6 +307,17 @@ detect_mounted()  {
 	test -n "$MOUNTED"
 }
 
+
+detect_mounted() {
+	if test "$FSTYPE" = "btrfs" ; then
+		detect_fs_uuid || verbose "Can't get fs UUID from \"$VOLUME\" volume"
+		test -n "$FINDMNT" || error "Need 'findmnt' utility to work with btrfs filesystem"
+		detect_mounted_findmnt
+	else
+		detect_mounted_classic "$VOLUME" "$RVOLUME"
+	fi
+}
+
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
@@ -366,6 +462,31 @@ resize_xfs() {
 	fi
 }
 
+
+################################
+# Resize Btrfs filesystem
+# - mounted for upsize/downsize
+# - need to find btrfs devid
+################################
+resize_btrfs() {
+	detect_mounted
+	MOUNTPOINT=$MOUNTED
+	if [ -z "$MOUNTED" ]; then
+		MOUNTPOINT=$TEMPDIR
+		temp_mount || error "Cannot mount Btrfs filesystem"
+	fi
+
+	# need to find btrfs devid to resize right btrfs volume
+	BTRFS_DEVID=$(btrfs_get_devid)
+	test -n "$BTRFS_DEVID" || error "Cannot find btrfs devid for \"$VOLUME ($RVOLUME)\""
+
+	# btrfs tool doesn't decode units above GiB
+	decode_size "$1" 1
+
+	verbose "Resizing \"$VOLUME\" btrfs filesystem to $NEWSIZE bytes (btrfs devid: $BTRFS_DEVID)"
+	dry "$BTRFS" filesystem resize $BTRFS_DEVID:$NEWSIZE $MOUNTPOINT
+}
+
 ####################
 # Resize filesystem
 ####################
@@ -382,6 +503,7 @@ resize() {
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
+	  "btrfs") resize_btrfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
 	esac || error "Resize $FSTYPE failed"
 	cleanup 0
@@ -431,6 +553,7 @@ check() {
 
 	case "$FSTYPE" in
 	  "xfs") dry "$XFS_CHECK" "$VOLUME" ;;
+	  "btrfs") dry "$BTRFS_CHECK" "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
@@ -453,6 +576,7 @@ test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REIS
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
   -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$LVM" \
+  -a -n "$BTRFS" -a -n "$BTRFS_CHECK" -a -z "$FINDMNT" \
   || error "Required command definitions in the script are missing!"
 
 "$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\""
@@ -462,11 +586,12 @@ test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit ari
 $(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly"
 test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
 
-
 if [ "$#" -eq 0 ] ; then
 	tool_usage
 fi
 
+check_findmnt
+
 while [ "$#" -ne 0 ]
 do
 	 case "$1" in
-- 
1.8.0


