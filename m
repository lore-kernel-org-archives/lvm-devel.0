From: Lidong Zhong <lzhong@suse.com>
Date: Wed, 11 Mar 2015 14:34:03 +0800
Subject: [Patch v2] fsadm: add support for btrfs
Message-ID: <1426055643-8417-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check: mount the device first and then run`btrfs filesystem scrub start
-B` command
Reisze: find the mount point first and resize the filesystem after get
the device id since there are maybe several devices underneath btrfs
filesystem

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
Hi List,
According Ondrej's reply and what he did in his patch
(http://www.redhat.com/archives/lvm-devel/2012-November/msg00052.html), I 
made the following modifications:
1\ replace btrfs check with btrfs scrub, which will check the data integrity
2\ adding logic to deal with there are several devices underneath the filesystem.

Regards,
Lidong

 scripts/fsadm.sh | 104 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 88 insertions(+), 16 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index f4ea796..765f9dc 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -22,6 +22,7 @@
 # ext2/ext3/ext4: resize2fs, tune2fs
 # reiserfs: resize_reiserfs, reiserfstune
 # xfs: xfs_growfs, xfs_info
+# btrfs: btrfs
 #
 # Return values:
 #   0 success
@@ -56,6 +57,7 @@ FSCK=fsck
 XFS_CHECK=xfs_check
 # XFS_REPAIR -n is used when XFS_CHECK is not found
 XFS_REPAIR=xfs_repair
+BTRFS=btrfs
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -75,6 +77,9 @@ BLOCKCOUNT=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
+FINDMNT=
+UUID=
+BTRFS_DEVID=
 PROCMOUNTS="/proc/mounts"
 NULL="$DM_DEV_DIR/null"
 
@@ -147,7 +152,7 @@ cleanup() {
 		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
 		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
-		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
+		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME"
 	fi
 
 	# error exit status for break
@@ -198,27 +203,62 @@ detect_fs() {
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
+check_findmnt() {
+	FINDMNT=$(which findmnt 2>$NULL)
+	test -n "$FINDMNT"
+}
+
+detect_fs_uuid() {
+	UUID=$($BLKID -o value -c $NULL -s UUID "$VOLUME" 2>$NULL)
+	test -n "$UUID"
+}
+
+#find the mountpoint of this device
+detect_mounted_findmnt() {
+	local TMP
+	local STR_IFS=$IFS
+	IFS=" $(echo -n -e '\t')"
+
+	read -r TMP<<EOF
+$($FINDMNT -nuP -o TARGET,UUID 2>$NULL | $GREP "$UUID")
+EOF
+
+	TMP=${TMP##*TARGET=\"}
+	TMP=${TMP%%\"*}
+	MOUNTED=$TMP
+	test -n "$MOUNTED"
+
+	IFS=$STR_IFS
+}
+
 # check if the given device is already mounted and where
 # FIXME: resolve swap usage and device stacking
 detect_mounted()  {
-	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
+	if test "$FSTYPE" = "btrfs" ; then
+		check_findmnt || error "Need 'findmnt' utility to work with btrfs filesystem"
+		detect_fs_uuid || verbose "Can't get fs UUID from \"$VOLUME\" volume"
+		detect_mounted_findmnt
+		
+	else
+		test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
 
-	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
+		MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
 
-	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
+		# for empty string try again with real volume name
+		test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
 
-	# cut device name prefix and trim everything past mountpoint
-	# echo translates \040 to spaces
-	MOUNTED=${MOUNTED#* }
-	MOUNTED=$(echo -n -e ${MOUNTED%% *})
+		# cut device name prefix and trim everything past mountpoint
+		# echo translates \040 to spaces
+		MOUNTED=${MOUNTED#* }
+		MOUNTED=$(echo -n -e ${MOUNTED%% *})
 
-	# for systems with different device names - check also mount output
-	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
-		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
-		MOUNTED=${MOUNTED##* on }
-		MOUNTED=${MOUNTED% type *} # allow type in the mount name
+		# for systems with different device names - check also mount output
+		if test -z "$MOUNTED" ; then
+			MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
+			test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
+			MOUNTED=${MOUNTED##* on }
+			MOUNTED=${MOUNTED% type *} # allow type in the mount name
+		fi
 	fi
 
 	test -n "$MOUNTED"
@@ -368,6 +408,31 @@ resize_xfs() {
 	fi
 }
 
+########################
+# Resize btrfs filesystem
+# - mounted for upsize/downsize
+# - cannot resize when unmounted 
+########################
+resize_btrfs() {
+	detect_mounted
+	MOUNTPOINT=$MOUNTED
+	if [ -z "$MOUNTED" ]; then
+		MOUNTPOINT=$TEMPDIR
+		temp_mount || error "Cannot mount Btrfs filesystem"
+	fi
+
+	verbose "Parsing $BTRFS filesystem show \"$MOUNTPOINT\""
+	for i in $(LC_ALL=C "$BTRFS" filesystem show "$MOUNTPOINT"); do
+		case "$i" in
+		  *"$VOLUME"*) BTRFS_DEVID=${i##*devid};;
+		esac
+	done
+	BTRFS_DEVID=${BTRFS_DEVID%%size*}
+	BTRFS_DEVID=$(echo $BTRFS_DEVID|sed 's/^[ \t]*//g'|sed 's/[ \t]*$'//g)
+	decode_size $1 1
+	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes(btrfs devid: $BTRFS_DEVID) "
+	dry "$BTRFS" filesystem resize "$BTRFS_DEVID":"$NEWSIZE" "$MOUNTPOINT"
+}
 ####################
 # Resize filesystem
 ####################
@@ -384,6 +449,7 @@ resize() {
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
+	  "btrfs") resize_btrfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
 	esac || error "Resize $FSTYPE failed"
 	cleanup 0
@@ -441,6 +507,12 @@ check() {
 			# Think about better way....
 			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME"
 		 fi ;;
+         "btrfs") #mount the device first and then run scrub
+		 MOUNTPOINT=$TEMPDIR
+		 temp_mount || error "Cannot mount btrfs filesystem"
+		 dry "$BTRFS" scrub start -B "$VOLUME"
+		 test "$MOUNTPOINT" = "$TEMPDIR" && MOUNTPOINT="" temp_umount
+		 ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
@@ -462,7 +534,7 @@ test -n "$FSADM_RUNNING" && exit 0
 for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
 	"$TUNE_XFS" "$RESIZE_XFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
 	"$RMDIR" "$BLOCKDEV" "$BLKID" "$GREP" "$READLINK" \
-	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" ; do
+	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" "$BTRFS" ; do 
 	test -n "$i" || error "Required command definitions in the script are missing!"
 done
 
-- 
1.8.1.4


