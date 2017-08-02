From: Marcus Müller <marcus@hostalia.de>
Date: Wed,  2 Aug 2017 19:42:35 +0200
Subject: [PATCH 1/1] added resizing for btrfs
In-Reply-To: <20170802174235.19869-1-marcus@hostalia.de>
References: <20170802174235.19869-1-marcus@hostalia.de>
Message-ID: <20170802174235.19869-2-marcus@hostalia.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Marcus M?ller <mueller@kit.edu>

---
 scripts/fsadm.sh | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 459905fc6..7101109e6 100755
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
@@ -41,6 +42,7 @@ TUNE_REISER=reiserfstune
 RESIZE_REISER=resize_reiserfs
 TUNE_XFS=xfs_info
 RESIZE_XFS=xfs_growfs
+TOOL_BTRFS=btrfs
 
 MOUNT=mount
 UMOUNT=umount
@@ -520,6 +522,70 @@ resize_xfs() {
 	fi
 }
 
+###############################################################################
+# Resize BTRFS filesystem
+# - mounted for upsize
+# - mounted for downsize
+# - since BTRFS supports multi-volume filesystems, only resize the btrfs volume
+#   we've actually resized
+###############################################################################
+resize_btrfs() {
+	  detect_mounted
+	  MOUNTPOINT=$MOUNTED
+	  if [ -z "$MOUNTED" ]; then
+		    MOUNTPOINT=$TEMPDIR
+		    temp_mount || error "Cannot mount Btrfs filesystem."
+	  fi
+    verbose "mounted on $MOUNTPOINT"
+
+    local old_ifs="$IFS"
+    local last_line=""
+    local used=""
+    local devid=""
+    local devid_use=""
+    BLOCKSIZE=1
+
+    unset IFS
+	  verbose "Parsing $TOOL_BTRFS filesystem show --raw \"$VOLUME\""
+	  for i in $(LC_ALL=C "$TOOL_BTRFS" filesystem show --raw "$VOLUME"); do
+        case "$last_line" in
+            "size")
+                BLOCKCOUNT=$i
+                ;;
+            "used")
+                used=$i
+                ;;
+            "devid")
+                devid="$i"
+                ;;
+            "path")
+                if test "$i" = "$VOLUME" ; then
+                    verbose "Found $VOLUME; has devid $devid size $BLOCKCOUNT B"
+                    devid_use="$devid"
+                fi
+                ;;
+            esac
+
+        line_before="$last_line"
+        last_line="$i"
+    done
+    IFS=old_ifs
+
+
+	  validate_parsing "$TOOL_BTRFS"
+	  decode_size "$BLOCKCOUNT" "$BLOCKSIZE"
+	  FSFORCE=$FORCE
+    if test $(("$used")) -lt $(("$NEWSIZE")) ; then
+        verbose "$VOLUME: size $NEWSIZE B >= used $used B"
+    else
+        verbose "$VOLUME: trying to shrink filesystem to size $NEWSIZE B, which is less than used $used B"
+        verbose "$VOLUME: that might still work on multi-volume Btrfs"
+    fi
+    verbose "Resizing filesystem on device \"$VOLUME\", mounted on \"$MOUNTPOINT\" to $NEWSIZE bytes"
+    dry "$TOOL_BTRFS" filesystem resize "${devid_use}:${NEWSIZE}" "$MOUNTPOINT"
+
+}
+
 ####################
 # Resize filesystem
 ####################
@@ -536,6 +602,7 @@ resize() {
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
+	  "btrfs") resize_btrfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac || error "Resize $FSTYPE failed."
 	cleanup 0
@@ -612,7 +679,7 @@ test -n "$FSADM_RUNNING" && exit 0
 
 # test some prerequisities
 for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
-	"$TUNE_XFS" "$RESIZE_XFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
+	"$TUNE_XFS" "$RESIZE_XFS" "$TOOL_BTRFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
 	"$RMDIR" "$BLOCKDEV" "$BLKID" "$GREP" "$READLINK" \
 	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" ; do
 	test -n "$i" || error "Required command definitions in the script are missing!"
-- 
2.13.0


