From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 15:39:18 +0000 (GMT)
Subject: master - tests: use parametrized function
Message-ID: <20200919153918.51793386F47E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b168afcadd6ce1880223bc94829a2acac34c850
Commit:        6b168afcadd6ce1880223bc94829a2acac34c850
Parent:        f63aac5309e10335c3a53477b3838fe1821934e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 16:51:01 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 17:30:51 2020 +0200

tests: use parametrized function

Shorten and make the test easily readable by moving same code into
function and removed one duplicated test for 512,4096 combination.

Always use scsi_debug - since default ramdisk or loop device backend
is unpredictible.
---
 test/shell/writecache-blocksize.sh | 270 ++++++++-----------------------------
 1 file changed, 58 insertions(+), 212 deletions(-)

diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 523d4ab80..964ee205c 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -19,16 +19,6 @@ SKIP_WITH_LVMPOLLD=1
 aux have_writecache 1 0 0 || skip
 which mkfs.xfs || skip
 
-# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
-aux prepare_devs 1
-vgcreate $vg "$dev1"
-lvcreate -n $lv1 -l8 $vg
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
-lvchange -an $vg
-vgremove -ff $vg
-aux cleanup_scsi_debug_dev
-
 mnt="mnt"
 mkdir -p $mnt
 
@@ -104,237 +94,93 @@ _verify_data_on_lv() {
 	lvchange -an $vg/$lv1
 }
 
-# the default is brd ram devs with 512 LBS 4K PBS
-aux prepare_devs 2 64
-
-blockdev --getss "$dev1"
-blockdev --getpbsz "$dev1"
-blockdev --getss "$dev2"
-blockdev --getpbsz "$dev2"
+_check_env() {
 
-# lbs 512, pbs 4k, xfs 4k, wc 4k
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=4096 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 4096 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
+	check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$1"
+	check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "$2"
 
-# lbs 512, pbs 4k, xfs -s 512, wc 512
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -f -s size=512 "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=512 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 512 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
-
-aux cleanup_scsi_debug_dev
-sleep 1
+	blockdev --getss "$dev1"
+	blockdev --getpbsz "$dev1"
+	blockdev --getss "$dev2"
+	blockdev --getpbsz "$dev2"
+}
 
+_run_test() {
+	vgcreate $SHARED $vg "$dev1"
+	vgextend $vg "$dev2"
+	lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+	lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+	lvchange -ay $vg/$lv1
+	mkfs.xfs -f $2 "$DM_DEV_DIR/$vg/$lv1" |tee out
+	grep "sectsz=$1" out
+	_add_new_data_to_mnt
+	lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
+	blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
+	grep "$1" out
+	blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+	_add_more_data_to_mnt
+	_verify_data_on_mnt
+	lvconvert --splitcache $vg/$lv1
+	check lv_field $vg/$lv1 segtype linear
+	check lv_field $vg/$lv2 segtype linear
+	blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+	blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+	_verify_data_on_mnt
+	_verify_more_data_on_mnt
+	umount $mnt
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/$lv2
+	_verify_data_on_lv
+	lvremove $vg/$lv1
+	lvremove $vg/$lv2
+	vgremove $vg
+}
 
 # scsi_debug devices with 512 LBS 512 PBS
 aux prepare_scsi_debug_dev 256
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "512"
 aux prepare_devs 2 64
 
-blockdev --getss "$dev1"
-blockdev --getpbsz "$dev1"
-blockdev --getss "$dev2"
-blockdev --getpbsz "$dev2"
+# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
+vgcreate $vg "$dev1"
+lvcreate -n $lv1 -L50 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+lvchange -an $vg
+vgremove -ff $vg
+
+_check_env "512" "512"
 
 # lbs 512, pbs 512, xfs 512, wc 512
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=512 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 512 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
+_run_test 512 ""
 
 # lbs 512, pbs 512, xfs -s 4096, wc 4096
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -s size=4096 -f "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=4096 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 4096 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
+_run_test 4096 "-s size=4096"
 
 aux cleanup_scsi_debug_dev
-sleep 1
 
 
-# scsi_debug devices with 512 LBS and 4K PBS
-aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "4096"
+# lbs=512, pbs=4096
+aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3 || skip
 aux prepare_devs 2 64
 
-blockdev --getss "$dev1"
-blockdev --getpbsz "$dev1"
-blockdev --getss "$dev2"
-blockdev --getpbsz "$dev2"
+_check_env "512" "4096"
 
 # lbs 512, pbs 4k, xfs 4k, wc 4k
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=4096 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 4096 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
+_run_test 4096 ""
+
+# lbs 512, pbs 4k, xfs -s 512, wc 512
+_run_test 512 "-s size=512"
 
 aux cleanup_scsi_debug_dev
-sleep 1
 
 
 # scsi_debug devices with 4K LBS and 4K PBS
 aux prepare_scsi_debug_dev 256 sector_size=4096
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "4096"
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "4096"
 aux prepare_devs 2 64
 
-blockdev --getss "$dev1"
-blockdev --getpbsz "$dev1"
-blockdev --getss "$dev2"
-blockdev --getpbsz "$dev2"
+_check_env "4096" "4096"
 
 # lbs 4k, pbs 4k, xfs 4k, wc 4k
-vgcreate $SHARED $vg "$dev1"
-vgextend $vg "$dev2"
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep sectsz=4096 out
-_add_new_data_to_mnt
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
-grep 4096 out
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_add_more_data_to_mnt
-_verify_data_on_mnt
-lvconvert --splitcache $vg/$lv1
-check lv_field $vg/$lv1 segtype linear
-check lv_field $vg/$lv2 segtype linear
-blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-_verify_data_on_mnt
-_verify_more_data_on_mnt
-umount $mnt
-lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
-_verify_data_on_lv
-lvremove $vg/$lv1
-lvremove $vg/$lv2
-vgremove $vg
+_run_test 4096 ""
 
 aux cleanup_scsi_debug_dev


