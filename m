From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:04 +0000 (GMT)
Subject: main - tests: writecache adapt to 300M XFS
Message-ID: <20220907130504.37FF6385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=570dbad52718f558fb679a5f5ed87b101bfb39c1
Commit:        570dbad52718f558fb679a5f5ed87b101bfb39c1
Parent:        6990cbc16659aa8b81cb0cd40728cebe8d1d4839
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 19:00:55 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: writecache adapt to 300M XFS

---
 test/shell/writecache-cache-blocksize-2.sh | 13 +++++++------
 test/shell/writecache-cache-blocksize.sh   | 25 ++++++++++++-------------
 test/shell/writecache-large.sh             |  9 ++++-----
 test/shell/writecache-misc.sh              |  6 +++---
 test/shell/writecache-split.sh             | 12 ++++++------
 test/shell/writecache.sh                   | 17 ++++++++---------
 6 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/test/shell/writecache-cache-blocksize-2.sh b/test/shell/writecache-cache-blocksize-2.sh
index 9b5d15365..0ab715d50 100644
--- a/test/shell/writecache-cache-blocksize-2.sh
+++ b/test/shell/writecache-cache-blocksize-2.sh
@@ -119,7 +119,7 @@ _check_env() {
 _run_test() {
 	vgcreate $SHARED $vg "$1"
 	vgextend $vg "$2"
-	lvcreate -n $lv1 -l 8 -an $vg "$1"
+	lvcreate -n $lv1 -L 300 -an $vg "$1"
 	lvcreate -n $lv2 -l 4 -an $vg "$2"
 	lvchange -ay $vg/$lv1
 	mkfs.xfs -f $5 "$DM_DEV_DIR/$vg/$lv1" |tee out
@@ -156,12 +156,13 @@ _run_test() {
 #        dev4 LBS 512, PBS 512   (using loop)
 #
 
-aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
-aux prepare_devs 2 64
+# On scsi debug   2 PVs has to fit!
+aux prepare_scsi_debug_dev 602 sector_size=512 physblk_exp=3 || skip
+aux prepare_devs 2 301
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 vgcreate $vg "$dev1"
-lvcreate -n $lv1 -L50 $vg
+lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
@@ -169,8 +170,8 @@ vgremove -ff $vg
 
 # loopa/loopb have LBS 512 PBS 512
 which fallocate || skip
-fallocate -l 64M loopa
-fallocate -l 64M loopb
+fallocate -l 301M loopa
+fallocate -l 301M loopb
 
 for i in {1..5}; do
 	LOOP1=$(losetup -f loopa --show || true)
diff --git a/test/shell/writecache-cache-blocksize.sh b/test/shell/writecache-cache-blocksize.sh
index 4e17effe5..c38700755 100644
--- a/test/shell/writecache-cache-blocksize.sh
+++ b/test/shell/writecache-cache-blocksize.sh
@@ -119,7 +119,7 @@ _check_env() {
 _run_test() {
 	vgcreate $SHARED $vg "$dev1"
 	vgextend $vg "$dev2"
-	lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+	lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 	lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 	lvchange -ay $vg/$lv1
 	mkfs.xfs -f $5 "$DM_DEV_DIR/$vg/$lv1" |tee out
@@ -147,12 +147,12 @@ _run_test() {
 }
 
 # Setup: LBS 512, PBS 512
-aux prepare_scsi_debug_dev 256 || skip
-aux prepare_devs 2 64
+aux prepare_scsi_debug_dev 602 || skip
+aux prepare_devs 2 301
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 vgcreate $vg "$dev1"
-lvcreate -n $lv1 -L50 $vg
+lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
@@ -176,8 +176,8 @@ aux cleanup_scsi_debug_dev
 
 
 # Setup: LBS 512, PBS 4096
-aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
-aux prepare_devs 2 64
+aux prepare_scsi_debug_dev 602 sector_size=512 physblk_exp=3
+aux prepare_devs 2 301
 
 _check_env "512" "4096"
 
@@ -195,10 +195,10 @@ _run_test 512 512 "cache" "--cachepool" "-s size=512"
 
 aux cleanup_scsi_debug_dev
 
-
 # Setup: LBS 4096, PBS 4096
-aux prepare_scsi_debug_dev 256 sector_size=4096
-aux prepare_devs 2 64
+# NOTE: Here we actually need PV of size 304M to get 300M ??
+aux prepare_scsi_debug_dev 608 sector_size=4096 || skip
+aux prepare_devs 2 304
 
 _check_env "4096" "4096"
 
@@ -212,14 +212,14 @@ aux cleanup_scsi_debug_dev
 
 
 # Setup: LBS 512, PBS 512
-aux prepare_scsi_debug_dev 256 || skip
-aux prepare_devs 2 64
+aux prepare_scsi_debug_dev 602 || skip
+aux prepare_devs 2 301
 
 _check_env "512" "512"
 
 vgcreate $SHARED $vg "$dev1"
 vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvconvert --yes --type writecache --cachevol $lv2 --cachesettings "block_size=4096" $vg/$lv1
 lvs -o writecacheblocksize $vg/$lv1 |tee out
@@ -249,4 +249,3 @@ lvremove $vg/$lv2
 vgremove $vg
 
 aux cleanup_scsi_debug_dev
-
diff --git a/test/shell/writecache-large.sh b/test/shell/writecache-large.sh
index 6391cef49..000a2cc41 100644
--- a/test/shell/writecache-large.sh
+++ b/test/shell/writecache-large.sh
@@ -118,13 +118,13 @@ lvcreate -n $lv1 -L 560M -an $vg "$dev1"
 lvcreate -n $lv2 -L 500M -an $vg "$dev2"
 
 lvchange -ay $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" 
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1" 
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
 
 lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 dmsetup table $vg-$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" 
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1" 
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
 
 _add_new_data_to_mnt
 _add_more_data_to_mnt
@@ -179,4 +179,3 @@ umount $mnt
 lvchange -an $vg/$lv1
 
 vgremove -ff $vg
-
diff --git a/test/shell/writecache-misc.sh b/test/shell/writecache-misc.sh
index f62974c54..ba8196c7f 100644
--- a/test/shell/writecache-misc.sh
+++ b/test/shell/writecache-misc.sh
@@ -47,13 +47,13 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 4
+aux prepare_devs 4 301
 
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 
 # Create writecache without a specified name so it gets automatic name
-lvcreate -n $lv1 -l 4 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -y --type writecache -l 4 --cachevol $lv1 $vg "$dev2"
 check lv_exists $vg lvol0
 lvremove -y $vg
@@ -62,7 +62,7 @@ lvremove -y $vg
 # Test pvmove with writecache
 #
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index f6d2d9aec..c68f29baa 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -46,11 +46,11 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 4
+aux prepare_devs 4 301
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 #
@@ -123,7 +123,7 @@ vgextend --restoremissing $vg "$dev2"
 #
 
 lvremove $vg/$lv2
-lvcreate -n $lv2 -l 14 -an $vg "$dev2" "$dev3"
+lvcreate -n $lv2 -l 14 -an $vg "$dev2:0-10" "$dev3"
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 
@@ -159,7 +159,7 @@ vgremove -ff $vg
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvchange -ay $vg/$lv1
@@ -224,7 +224,7 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 # while inactive
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
@@ -244,7 +244,7 @@ lvremove -y $vg/$lv1
 
 # while active
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 421c5bb4f..9cb6d3f94 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -20,14 +20,14 @@ aux have_writecache 1 0 0 || skip
 which mkfs.xfs || skip
 
 # scsi_debug devices with 512 LBS 512 PBS
-aux prepare_scsi_debug_dev 256
+aux prepare_scsi_debug_dev 602
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "512"
-aux prepare_devs 2 64
+aux prepare_devs 2 301
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 vgcreate $vg "$dev1"
-lvcreate -n $lv1 -L50 $vg
+lvcreate -n $lv1 -L 300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
@@ -159,7 +159,7 @@ blockdev --getpbsz "$dev2"
 # Test attach while inactive, detach while inactive
 # create fs on LV before writecache is attached
 
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvchange -ay $vg/$lv1
 _add_new_data_to_mnt
@@ -193,7 +193,7 @@ lvremove $vg/$lv2
 # Test attach while inactive, detach while inactive
 # create fs on LV after writecache is attached
 
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 check lv_field $vg/$lv1 segtype writecache
@@ -221,7 +221,7 @@ lvremove $vg/$lv2
 
 # Test attach while active, detach while active
 
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvchange -ay $vg/$lv1
 _add_new_data_to_mnt
@@ -246,7 +246,7 @@ lvremove $vg/$lv2
 
 # Test attach while active, detach while active,
 # skip cleaner so flush message is used instead
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvchange -ay $vg/$lv1
 _add_new_data_to_mnt
@@ -268,6 +268,5 @@ lvchange -an $vg/$lv2
 _verify_data_on_lv
 lvremove $vg/$lv1
 lvremove $vg/$lv2
- 
+
 vgremove -ff $vg
- 

