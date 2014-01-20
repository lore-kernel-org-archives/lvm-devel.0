From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Jan 2014 11:03:21 +0000 (UTC)
Subject: master - fsadm: use xfs_repair when available
Message-ID: <20140120110321.F37B561159@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59336a2a0626eba91dc3bc76ff6297e0c70e7e9e
Commit:        59336a2a0626eba91dc3bc76ff6297e0c70e7e9e
Parent:        5f9035363684953d66c076f0f874d12d0576b4b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 11:57:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 20 11:57:39 2014 +0100

fsadm: use xfs_repair when available

Since support for xfs_check is going to be obsoleted,
replace its usage with xfs_repair -n tool.

However this tool needs further intrumentation, since for really small
xfs devices (having just 1 allocation group) it needs to pass in
flag: "-o force_geometry". As we run the tool with '-n', it should
be safe to pass this flag always.

FIXME: figure way without always passing this flag.
---
 scripts/fsadm.sh |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 1e8a22a..e6fe7ce 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -54,6 +54,8 @@ READLINK=readlink
 READLINK_E="-e"
 FSCK=fsck
 XFS_CHECK=xfs_check
+# XFS_REPAIR -n is used when XFS_CHECK is not found
+XFS_REPAIR=xfs_repair
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -430,7 +432,15 @@ check() {
 	esac
 
 	case "$FSTYPE" in
-	  "xfs") dry "$XFS_CHECK" "$VOLUME" ;;
+	  "xfs") if which "$XFS_CHECK" >"$NULL" 2>&1 ; then
+			dry "$XFS_CHECK" "$VOLUME"
+		 else
+			# Replacement for outdated xfs_check
+			# FIXME: for small devices we need to force_geometry,
+			# since we run in '-n' mode, it shouldn't be problem.
+			# Think about better way....
+			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME"
+		 fi ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
@@ -452,7 +462,8 @@ test -n "$FSADM_RUNNING" && exit 0
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$LVM" \
+  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$XFS_REPAIR" \
+  -a -n "$LVM" \
   || error "Required command definitions in the script are missing!"
 
 "$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\""


