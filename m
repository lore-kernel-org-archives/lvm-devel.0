From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:19 +0000 (GMT)
Subject: main - tests: adapt for xfs 300M min size
Message-ID: <20230506204619.EDC533858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7267322fc19a6e09d6949058ee0efdb107e7ef81
Commit:        7267322fc19a6e09d6949058ee0efdb107e7ef81
Parent:        4af8063c963f0610761d9cecbd6ed23b52f77256
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 20:11:32 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:43:22 2023 +0200

tests: adapt for xfs 300M min size

Some test still were missed to be converted for XFS 300M min size.
---
 test/shell/fsadm-crypt-fsresize.sh | 31 +++++++++++++++-------------
 test/shell/lvresize-fs-crypt.sh    | 42 +++++++++++++++-----------------------
 2 files changed, 34 insertions(+), 39 deletions(-)

diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
index 4ad2ab980..b2847928f 100644
--- a/test/shell/fsadm-crypt-fsresize.sh
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -20,7 +20,7 @@ export LVM_TEST_PREFER_BRD=0
 
 . lib/inittest
 
-aux prepare_vg 1 300
+aux prepare_vg 1 400
 
 # Tests require a libblkid version that shows FSLASTBLOCK
 which mkfs.ext4 || skip
@@ -209,8 +209,8 @@ check_missing cryptsetup || skip
 
 vgchange -s 128k
 lvcreate -n $lv1 -L25M $vg
-lvcreate -n ${lv1}bar -L35M $vg
-lvcreate -n ${lv1}plain -L35M $vg
+lvcreate -n ${lv1}bar -L335M $vg
+lvcreate -n ${lv1}plain -L335M $vg
 create_crypt_device
 trap 'cleanup_mounted_and_teardown' EXIT
 
@@ -275,9 +275,9 @@ test_ext3_small_shrink() {
 }
 
 test_xfs_resize() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
-	fsadm --lvresize resize $1 30M
+	fsadm --lvresize resize $1 330M
 	# Fails - not enough space for 4M fs
 	lvresize -L+10M -y --fs resize $1
 	not lvreduce -L10M --fs resize $1
@@ -290,7 +290,7 @@ test_xfs_resize() {
 }
 
 test_xfs_small_shrink() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not lvresize -L-1 --fs resize $1
 	fscheck_xfs "$3"
@@ -354,7 +354,7 @@ test_ext3_inactive() {
 
 test_xfs_inactive() {
 	crypt_open "$2" $PWD2 "$4"
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
@@ -435,7 +435,7 @@ test_ext3_plain() {
 }
 
 test_xfs_plain() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M --fs resize $1
@@ -443,7 +443,7 @@ test_xfs_plain() {
 	fscheck_xfs "$3"
 
 	lvresize -f -L+10M $1
-	fsadm --cryptresize resize $3 40M
+	fsadm --cryptresize resize $3 345M
 	# no shrink support in xfs
 	not fsadm --cryptresize resize $3 35M
 	fscheck_xfs "$3"
@@ -455,7 +455,7 @@ test_xfs_plain() {
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_xfs "$3"
 
-	lvresize -f -L35M $1
+	lvresize -f -L320M $1
 }
 
 test_reiserfs_plain() {
@@ -501,7 +501,7 @@ test_ext3_detached() {
 }
 
 test_xfs_detached() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M --fs resize $1
@@ -569,8 +569,11 @@ if check_missing ext3; then
 fi
 
 if check_missing xfs; then
+	lvresize -r -y -L310M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
 	test_xfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize --fs ignore -y -L25M $vg_lv
+	lvresize --fs ignore -y -L325M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -579,10 +582,10 @@ if check_missing xfs; then
 	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize --fs ignore -y -L100M $vg_lv
+	lvresize --fs ignore -y -L310M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_xfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize --fs ignore -y -L25M $vg_lv
+	lvresize --fs ignore -y -L325M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	if [ -z "$SKIP_DETACHED" ]; then
diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
index 4bef771dc..7a73e108b 100644
--- a/test/shell/lvresize-fs-crypt.sh
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -23,8 +23,7 @@ which mkfs.xfs || skip
 lvcreate -n $lv1 -L 300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
 blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip
-lvchange -an $vg
-lvremove $vg/$lv1
+lvremove -f $vg/$lv1
 
 mount_dir="mnt_lvresize_cr"
 mkdir -p "$mount_dir"
@@ -38,7 +37,7 @@ echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
 echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
 mkfs.ext4 /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 lvextend -L+200M --fs resize $vg/$lv
 check lv_field $vg/$lv lv_size "456.00m"
@@ -46,8 +45,7 @@ df --output=size "$mount_dir" |tee df2
 not diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvreduce ext4 on LUKS1
 lvcreate -n $lv -L 456M $vg
@@ -55,7 +53,7 @@ echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
 echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
 mkfs.ext4 /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 lvresize -L-100M --yes --fs resize $vg/$lv
 check lv_field $vg/$lv lv_size "356.00m"
@@ -63,25 +61,23 @@ df --output=size "$mount_dir" |tee df2
 not diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvextend xfs on LUKS1
-lvcreate -n $lv -L 256M $vg
+lvcreate -n $lv -L 320M $vg
 echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
 echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
 mkfs.xfs /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
-lvextend -L+200M --fs resize $vg/$lv
+lvextend -L+136M --fs resize $vg/$lv
 check lv_field $vg/$lv lv_size "456.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvreduce xfs on LUKS1
 lvcreate -n $lv -L 456M $vg
@@ -89,7 +85,7 @@ echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
 echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
 mkfs.xfs /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # xfs cannot be reduced
 not lvresize -L-100M --yes --fs resize $vg/$lv
@@ -98,15 +94,14 @@ df --output=size "$mount_dir" |tee df2
 diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvextend ext4 on plain crypt (no header)
 lvcreate -n $lv -L 256M $vg
 echo 93R4P4pIqAH8 | cryptsetup create $cr "$DM_DEV_DIR/$vg/$lv"
 mkfs.ext4 /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # fails when no fs is found for --fs resize
 not lvextend -L+200M --yes --fs resize $vg/$lv
@@ -115,15 +110,14 @@ df --output=size "$mount_dir" |tee df2
 diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvreduce ext4 on plain crypt (no header)
 lvcreate -n $lv -L 456M $vg
 echo 93R4P4pIqAH8 | cryptsetup create $cr "$DM_DEV_DIR/$vg/$lv"
 mkfs.ext4 /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # fails when no fs is found for --fs resize
 not lvresize -L-100M --yes --fs resize $vg/$lv
@@ -132,8 +126,7 @@ df --output=size "$mount_dir" |tee df2
 diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # lvresize uses helper only for crypt dev resize
 # because the fs was resized separately beforehand
@@ -142,7 +135,7 @@ echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
 echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
 mkfs.ext4 /dev/mapper/$cr
 mount /dev/mapper/$cr "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # resize only the fs (to 256M), not the crypt dev or LV
 umount "$mount_dir"
@@ -162,8 +155,7 @@ df --output=size "$mount_dir" |tee df2
 not diff df1 df2
 umount "$mount_dir"
 cryptsetup close $cr
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 # test with LUKS2?
 

