From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  9 Mar 2015 14:48:25 +0800
Subject: [PATCH] fsadm: add support for btrfs
Message-ID: <1425883705-8022-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Run `btrfs check` to check filesystem
Run `btrfs filesystem show` to get the filesystem size and
`btrfs filesystem resize` to resize.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 scripts/fsadm.sh | 60 ++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 47 insertions(+), 13 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index f4ea796..b9683bd 100755
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
@@ -72,6 +74,7 @@ TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
 DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 BLOCKSIZE=
 BLOCKCOUNT=
+OLDSIZE=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
@@ -157,18 +160,20 @@ cleanup() {
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
 # (2^(60/50/40/30/20/10/0))
 decode_size() {
-	case "$1" in
-	 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
-	 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
-	 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
-	 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
-	 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
-	 *[kK]) NEWSIZE=$(( ${1%[kK]} * 1024 )) ;;
-	 *[bB]) NEWSIZE=${1%[bB]} ;;
-	     *) NEWSIZE=$(( $1 * $2 )) ;;
-	esac
-	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
-	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
+	if [ -n "$1" -a -n "$2" ]; then
+		case "$1" in
+		 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
+		 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
+		 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
+		 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
+		 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
+		 *[kK]) NEWSIZE=$(( ${1%[kK]} * 1024 )) ;;
+		 *[bB]) NEWSIZE=${1%[bB]} ;;
+		     *) NEWSIZE=$(( $1 * $2 )) ;;
+		esac
+		#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
+		NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
+	fi
 
 	if [ $DO_LVRESIZE -eq 1 ]; then
 		# start lvresize, but first cleanup mounted dirs
@@ -368,6 +373,30 @@ resize_xfs() {
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
+		  *"size"*) OLDSIZE=${i##*size};;
+		esac
+	done
+	OLDSIZE=${OLDSIZE%%used*}
+	decode_size $1
+	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes from $OLDSIZE bytes"
+	dry "$BTRFS" filesystem resize $NEWSIZE "$MOUNTPOINT"
+}
 ####################
 # Resize filesystem
 ####################
@@ -384,6 +413,7 @@ resize() {
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
+	  "btrfs") resize_btrfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
 	esac || error "Resize $FSTYPE failed"
 	cleanup 0
@@ -441,6 +471,10 @@ check() {
 			# Think about better way....
 			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME"
 		 fi ;;
+         "btrfs") if which "$BTRFS" > "$NULL" 2>&1 ; then
+		  	dry "$BTRFS" check "$VOLUME"
+		  fi
+		  ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
@@ -462,7 +496,7 @@ test -n "$FSADM_RUNNING" && exit 0
 for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
 	"$TUNE_XFS" "$RESIZE_XFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
 	"$RMDIR" "$BLOCKDEV" "$BLKID" "$GREP" "$READLINK" \
-	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" ; do
+	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" "$BTRFS"; do
 	test -n "$i" || error "Required command definitions in the script are missing!"
 done
 
-- 
1.8.1.4


