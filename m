From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2023 14:22:33 +0000 (GMT)
Subject: main - tests: more updates for 300M xfs
Message-ID: <20230510142233.254F93853824@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf794b66f412765e49c4d79a4bb95b454f2357fc
Commit:        bf794b66f412765e49c4d79a4bb95b454f2357fc
Parent:        bc28082b990bf752a2ce6ffa13aff9452c655ab8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 16:17:38 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 16:19:46 2023 +0200

tests: more updates for 300M xfs

Fix some sizing for larger xfs testing.
Also fix resize of reiserfs which requires resize_fsadm.
---
 test/shell/fsadm-crypt-fsresize.sh | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
index b2847928f..da5688610 100644
--- a/test/shell/fsadm-crypt-fsresize.sh
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -20,7 +20,7 @@ export LVM_TEST_PREFER_BRD=0
 
 . lib/inittest
 
-aux prepare_vg 1 400
+aux prepare_vg 1 1100
 
 # Tests require a libblkid version that shows FSLASTBLOCK
 which mkfs.ext4 || skip
@@ -299,8 +299,10 @@ test_xfs_small_shrink() {
 test_reiserfs_resize() {
 	mkfs.reiserfs -s 513 -f "$3"
 
-	fsadm --lvresize resize $1 30M
-	lvresize -L+10M --fs resize $1
+	fsadm -y --lvresize resize $1 30M
+	# resize fs does not support resiserfs and requires resize_fsadm
+	not lvresize -L+10M --fs resize $1
+	lvresize -L+10M --fs resize_fsadm $1
 	fsadm --lvresize -y resize $1 10M
 
 	fscheck_reiserfs "$3"
@@ -314,8 +316,9 @@ test_reiserfs_resize() {
 test_reiserfs_small_shrink() {
 	mkfs.reiserfs -s 513 -f "$3"
 
-	lvresize -y -L-1 --fs resize $1
-	lvresize -y -L-1 --fs resize  $1
+	not lvresize -y -L-1 --fs resize $1
+	lvresize -y -L-1 --fs resize_fsadm $1
+	lvresize -y -L-1 --fs resize_fsadm $1
 
 	fscheck_reiserfs "$3"
 }
@@ -569,12 +572,10 @@ if check_missing ext3; then
 fi
 
 if check_missing xfs; then
-	lvresize -r -y -L310M $vg_lv
+	lvresize --fs ignore -y -L325M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize --fs ignore -y -L325M $vg_lv
-	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
 

