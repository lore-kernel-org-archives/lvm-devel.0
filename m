From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:44 +0000 (UTC)
Subject: master - fsadm: avoid using -a in test
Message-ID: <20140702084844.2A8B861054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f6900d457afdf8533968f6cd639d4b14779ad51
Commit:        6f6900d457afdf8533968f6cd639d4b14779ad51
Parent:        7bdf4719e8327a74262e47adfe78ad81a26ff4c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 20:03:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:41 2014 +0200

fsadm: avoid using -a in test

---
 scripts/fsadm.sh |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index e6fe7ce..f4ea796 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -276,7 +276,7 @@ try_umount() {
 }
 
 validate_parsing() {
-	test -n "$BLOCKSIZE" -a -n "$BLOCKCOUNT" || error "Cannot parse $1 output"
+	test -n "$BLOCKSIZE" && test -n "$BLOCKCOUNT" || error "Cannot parse $1 output"
 }
 ####################################
 # Resize ext2/ext3/ext4 filesystem
@@ -459,12 +459,12 @@ trap "cleanup 2" 2
 test -n "$FSADM_RUNNING" && exit 0
 
 # test some prerequisities
-test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
-  -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
-  -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$XFS_REPAIR" \
-  -a -n "$LVM" \
-  || error "Required command definitions in the script are missing!"
+for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
+	"$TUNE_XFS" "$RESIZE_XFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
+	"$RMDIR" "$BLOCKDEV" "$BLKID" "$GREP" "$READLINK" \
+	"$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" ; do
+	test -n "$i" || error "Required command definitions in the script are missing!"
+done
 
 "$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\""
 $("$READLINK" -e / >"$NULL" 2>&1) || READLINK_E="-f"


