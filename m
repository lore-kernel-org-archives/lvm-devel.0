From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:34 -0400
Subject: master - blkdeactivate: replace obsoleted syntax
Message-ID: <201706292025.v5TKPYpJ025676@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd359aec86756e2eaa62880855f0c0ff412b6df1
Commit:        bd359aec86756e2eaa62880855f0c0ff412b6df1
Parent:        95ca7cfdffc5052e360d76c787a601e9aa626bd1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:15:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: replace obsoleted syntax

---
 scripts/blkdeactivate.sh.in |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 436c72e..5c1ab82 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -147,7 +147,7 @@ add_vg_to_skip_list() {
 is_top_level_device() {
 	# top level devices do not have any holders, that is
 	# the SYS_BLK_DIR/<device_name>/holders dir is empty
-	files="`echo $SYS_BLK_DIR/$kname/holders/*`"
+	files=$(echo "$SYS_BLK_DIR/$kname/holders/"*)
 	test -z "$files"
 }
 
@@ -182,7 +182,7 @@ device_umount() {
 	else
 		while $FINDMNT_READ; do
 			device_umount_one || return 1
-		done <<< "`$FINDMNT $DEV_DIR/$kname`"
+		done <<< "$($FINDMNT $DEV_DIR/$kname)"
 	fi
 
 }
@@ -201,7 +201,7 @@ deactivate_holders () {
 		# try to deactivate the holder
 		test $skip -eq 1 && skip=0 && continue
 		deactivate || return 1
-	done <<< "`$LSBLK $1`"
+	done <<< "$($LSBLK $1)"
 }
 
 deactivate_dm () {
@@ -337,7 +337,7 @@ deactivate_all() {
 		# Unmount all relevant mountpoints first
 		while $LSBLK_READ; do
 			device_umount
-		done <<< "`$LSBLK | $SORT_MNT`"
+		done <<< "$($LSBLK | $SORT_MNT)"
 
 		# Do deactivate
 		while $LSBLK_READ; do
@@ -360,7 +360,7 @@ deactivate_all() {
 			# device's subtree to be skipped when processing
 			# devices further in this loop
 			deactivate || skip=1
-		done <<< "`$LSBLK -s`"
+		done <<< "$($LSBLK -s)"
 	else
 		##################################
 		# Process only specified devices #
@@ -370,12 +370,12 @@ deactivate_all() {
 			# Unmount all relevant mountpoints first
 			while $LSBLK_READ; do
 				device_umount
-			done <<< "`$LSBLK $1 | $SORT_MNT`"
+			done <<< "$($LSBLK $1 | $SORT_MNT)"
 
 			# Do deactivate
 			# Single dm device tree deactivation.
 			if test -b "$1"; then
-				$LSBLK_READ <<< "`$LSBLK --nodeps $1`"
+				$LSBLK_READ <<< "$($LSBLK --nodeps $1)"
 
 				# check if the device is not on the skip list already
 				test -z ${SKIP_DEVICE_LIST["$kname"]} || {


