From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 24 Oct 2017 07:42:58 -0400
Subject: master - test: add regression test for fsadm bug
Message-ID: <201710241142.v9OBgwGl031240@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=213cea3aaa19dffef6e922e914225d21f05589f2
Commit:        213cea3aaa19dffef6e922e914225d21f05589f2
Parent:        af781897fa7d124c073c1763f47adac3d7186907
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 24 11:55:14 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 24 13:41:00 2017 +0200

test: add regression test for fsadm bug

the bug in LUKS grow/shrink decision in fsadm was
masked due to fact that default LVM2 extent size
was larger than LUKS1 default data offset for dm-crypt
mapping. The new test address this bug.
---
 test/shell/fsadm-crypt.sh |   62 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index bd2c686..5104feb 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_vg 1 200
+aux prepare_vg 1 300
 
 # set to "skip" to avoid testing given fs and test warning result
 # i.e. check_reiserfs=skip
@@ -188,7 +188,7 @@ create_crypt_device()
 which lsblk > /dev/null || skip
 check_missing cryptsetup || skip
 
-# Test for block sizes != 1024 (rhbz #480022)
+vgchange -s 128k
 lvcreate -n $lv1 -L25M $vg
 lvcreate -n ${lv1}bar -L35M $vg
 lvcreate -n ${lv1}plain -L35M $vg
@@ -217,6 +217,15 @@ test_ext2_resize() {
 	fscheck_ext3 "$3"
 }
 
+test_ext2_small_shrink() {
+	mkfs.ext2 "$3"
+
+	lvresize -L-1 -r $1
+	lvresize -L-1 -r $1
+
+	fscheck_ext3 "$3"
+}
+
 test_ext3_resize() {
 	mkfs.ext3 -b4096 -j "$3"
 
@@ -237,6 +246,15 @@ test_ext3_resize() {
 	umount "$mount_dir"
 }
 
+test_ext3_small_shrink() {
+	mkfs.ext3 "$3"
+
+	lvresize -L-1 -r $1
+	lvresize -L-1 -r $1
+
+	fscheck_ext3 "$3"
+}
+
 test_xfs_resize() {
 	mkfs.xfs -l internal,size=1000b -f "$3"
 
@@ -252,6 +270,13 @@ test_xfs_resize() {
 	fscheck_xfs "$3"
 }
 
+test_xfs_small_shrink() {
+	mkfs.xfs -l internal,size=1000b -f "$3"
+
+	not lvresize -L-1 -r $1
+	fscheck_xfs "$3"
+}
+
 test_reiserfs_resize() {
 	mkfs.reiserfs -s 513 -f "$3"
 
@@ -267,6 +292,15 @@ test_reiserfs_resize() {
 	fscheck_reiserfs "$3"
 }
 
+test_reiserfs_small_shrink() {
+	mkfs.reiserfs -s 513 -f "$3"
+
+	lvresize -L-1 -r $1
+	lvresize -L-1 -r $1
+
+	fscheck_reiserfs "$3"
+}
+
 # $1 LVM backend (vg/lv name)
 # $2 LVM backend device (/dev/vg/lv)
 # $3 active dm-crypt device (/dev/mapper/some_name )
@@ -478,6 +512,12 @@ if check_missing ext2; then
 	test_ext2_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
+	lvresize -f -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_ext2_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize -f -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
 	if [ -z "$SKIP_DETACHED" ]; then
 		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
 		test_ext2_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -496,6 +536,12 @@ if check_missing ext3; then
 	test_ext3_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
+	lvresize -f -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_ext3_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize -f -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
 	if [ -z "$SKIP_DETACHED" ]; then
 		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
 		test_ext3_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -514,6 +560,12 @@ if check_missing xfs; then
 	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
+	lvresize -f -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_xfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize -f -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
 	if [ -z "$SKIP_DETACHED" ]; then
 		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
 		test_xfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -532,6 +584,12 @@ if check_missing reiserfs; then
 	test_reiserfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
+	lvresize -f -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_reiserfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize -f -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
 	if [ -z "$SKIP_DETACHED" ]; then
 		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
 		test_reiserfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"


