From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Apr 2023 09:26:26 +0000 (GMT)
Subject: main - test: convert to use ext4
Message-ID: <20230422092626.753A13858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2043bb0e387ddec2f2b1ad4cd0a93cfeb272bf85
Commit:        2043bb0e387ddec2f2b1ad4cd0a93cfeb272bf85
Parent:        b0f26a135b34f212f59818ea6cc85ce83ecb28bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 22:28:32 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 22 11:25:39 2023 +0200

test: convert to use ext4

Modify test to check same properties with less demanding ext4.
---
 test/shell/integrity-blocksize.sh | 101 ++++++++++++++++++--------------------
 test/shell/integrity-misc.sh      |   4 +-
 2 files changed, 51 insertions(+), 54 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 55a618f7f..9fd77086f 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -40,7 +40,7 @@ mkdir -p $mnt
 aux prepare_devs 1
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l8 $vg
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
@@ -63,45 +63,39 @@ LOOP2=$(losetup -f loopb --show) || skip "Cannot find free loop device"
 LOOP3=$(losetup -f loopc --sector-size 4096 --show) || skip "Loop cannot handle --sector-size 4096"
 LOOP4=$(losetup -f loopd --sector-size 4096 --show) || skip "Loop cannot handle --sector-size 4096"
 
-echo $LOOP1
-echo $LOOP2
-echo $LOOP3
-echo $LOOP4
+echo "$LOOP1"
+echo "$LOOP2"
+echo "$LOOP3"
+echo "$LOOP4"
 
-aux extend_filter "a|$LOOP1|"
-aux extend_filter "a|$LOOP2|"
-aux extend_filter "a|$LOOP3|"
-aux extend_filter "a|$LOOP4|"
-aux extend_devices "$LOOP1"
-aux extend_devices "$LOOP2"
-aux extend_devices "$LOOP3"
-aux extend_devices "$LOOP4"
+aux extend_filter "a|$LOOP1|" "a|$LOOP2|" "a|$LOOP3|" "a|$LOOP4|"
+aux extend_devices "$LOOP1" "$LOOP2" "$LOOP3" "$LOOP4"
 
 aux lvmconf 'devices/scan = "/dev"'
 
-vgcreate $vg1 $LOOP1 $LOOP2
-vgcreate $vg2 $LOOP3 $LOOP4
+vgcreate $vg1 "$LOOP1" "$LOOP2"
+vgcreate $vg2 "$LOOP3" "$LOOP4"
 
 # LOOP1/LOOP2 have LBS 512 and PBS 512
 # LOOP3/LOOP4 have LBS 4K and PBS 4K
 
-blockdev --getss $LOOP1
-blockdev --getpbsz $LOOP1
-blockdev --getss $LOOP2
-blockdev --getpbsz $LOOP2
-blockdev --getss $LOOP3
-blockdev --getpbsz $LOOP3
-blockdev --getss $LOOP4
-blockdev --getpbsz $LOOP4
+blockdev --getss "$LOOP1"
+blockdev --getpbsz "$LOOP1"
+blockdev --getss "$LOOP2"
+blockdev --getpbsz "$LOOP2"
+blockdev --getss "$LOOP3"
+blockdev --getpbsz "$LOOP3"
+blockdev --getss "$LOOP4"
+blockdev --getpbsz "$LOOP4"
 
 # lvcreate on dev512, result 512
 lvcreate --type raid1 -m1 --raidintegrity y -l 8 -n $lv1 $vg1
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
 # lvcreate on dev4k, result 4k
 lvcreate --type raid1 -m1 --raidintegrity y -l 8 -n $lv1 $vg2
-pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+pvck --dump metadata "$LOOP3" | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
 
 # lvcreate --bs 512 on dev4k, result fail
@@ -110,7 +104,7 @@ not lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 512 -l
 # lvcreate --bs 4096 on dev512, result 4k
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 4096 -l 8 -n $lv1 $vg1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 4096
-pvck --dump metadata $LOOP1 | grep 'block_size = 4096'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 4096'
 lvremove -y $vg1/$lv1
 
 # Test an unknown fs block size by simply not creating a fs on the lv.
@@ -120,7 +114,7 @@ lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 # clear any residual fs so that libblkid cannot find an fs block size
 aux wipefs_a /dev/$vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
 # lvconvert on dev4k, fsunknown, result 4k
@@ -145,22 +139,23 @@ aux wipefs_a /dev/$vg2/$lv1
 not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
 lvremove -y $vg2/$lv1
 
-# lvconvert on dev512, xfs 512, result 512
+# lvconvert on dev512, ext4 1024, result 1024
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
-blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+mkfs.ext4 "$DM_DEV_DIR/$vg1/$lv1"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | tee out
+grep BLOCK_SIZE=\"1024\" out
 lvconvert --raidintegrity y $vg1/$lv1
-blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
-# lvconvert on dev4k, xfs 4096, result 4096
+# lvconvert on dev4k, ext4 4096, result 4096
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
@@ -178,7 +173,7 @@ lvconvert --raidintegrity y $vg1/$lv1
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
 # lvconvert on dev512, ext4 1024, result 1024 (LV inactive when adding)
@@ -192,7 +187,7 @@ lvchange -ay $vg1/$lv1
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 1024'
 lvremove -y $vg1/$lv1
 
 # lvconvert on dev4k, ext4 4096, result 4096
@@ -204,26 +199,26 @@ lvconvert --raidintegrity y $vg2/$lv1
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+pvck --dump metadata "$LOOP3" | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
 
-# lvconvert --bs 512 on dev512, xfs 4096, result 512
+# lvconvert --bs 512 on dev512, ext4 4096, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
-mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 512
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
-# lvconvert --bs 1024 on dev512, xfs 4096, result 1024
+# lvconvert --bs 1024 on dev512, ext4 4096, result 1024
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
-mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg1/$lv1
 # lv needs to be inactive to increase LBS from 512
@@ -233,7 +228,7 @@ lvchange -ay $vg1/$lv1
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 1024'
 lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev512, ext4 1024, result 512
@@ -245,7 +240,7 @@ lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev4k, ext4 4096, result fail
@@ -260,29 +255,30 @@ lvremove -y $vg2/$lv1
 # TODO: lvconvert --bs 512, fsunknown, LBS 512, PBS 4k: result 512
 # TODO: lvconvert --bs 4k, fsunknown, LBS 512, PBS 4k: result 4k
 
-# lvconvert on dev512, xfs 512, result 512, (detect fs with LV inactive)
+# lvconvert on dev512, ext4 1024, result 1024, (detect fs with LV inactive)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg1/$lv1"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
-blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvchange -an $vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
 lvchange -ay $vg1/$lv1
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 cat $mnt/test
 umount $mnt
-blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
-pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+pvck --dump metadata "$LOOP1" | tee out
+grep 'block_size = 1024' out
 lvchange -an $vg1/$lv1
 lvremove -y $vg1/$lv1
 
-# lvconvert on dev4k, xfs 4096, result 4096 (detect fs with LV inactive)
+# lvconvert on dev4k, ext4 4096, result 4096 (detect fs with LV inactive)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
@@ -294,7 +290,8 @@ mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 cat $mnt/test
 umount $mnt
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
-pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+pvck --dump metadata "$LOOP3" | tee out
+grep 'block_size = 4096' out
 lvchange -an $vg2/$lv1
 lvremove -y $vg2/$lv1
 
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index e6c108a0f..37f272cd0 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -14,7 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which mkfs.xfs || skip
+which mkfs.ext4 || skip
 aux have_integrity 1 5 0 || skip
 # Avoid 4K ramdisk devices on older kernels
 aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
@@ -41,7 +41,7 @@ _prepare_vg() {
 }
 
 _add_new_data_to_mnt() {
-        mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+        mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
         mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 

