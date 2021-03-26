From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 19:50:29 +0000 (GMT)
Subject: main - tests: use blkid without caching
Message-ID: <20210326195029.EF0583857C44@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51ac56a05e9da2c28ef5047345468fed4946078a
Commit:        51ac56a05e9da2c28ef5047345468fed4946078a
Parent:        02e02a5ccc7275c23e59e65df25287c8f82276fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:12:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:41 2021 +0100

tests: use blkid without caching

Always use blkid without caching to avoid poluting
cache stored in /run/blkid or /etc on older distros
---
 test/shell/integrity-blocksize.sh  | 42 +++++++++++++++++++-------------------
 test/shell/pvcreate-md-fake-hdr.sh |  2 +-
 test/shell/writecache-blocksize.sh |  2 +-
 3 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 329a2f73f..a85070cc5 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -41,7 +41,7 @@ aux prepare_devs 1
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l8 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
@@ -145,9 +145,9 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 lvconvert --raidintegrity y $vg1/$lv1
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -157,9 +157,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
@@ -169,9 +169,9 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y $vg1/$lv1
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -181,11 +181,11 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvchange -an $vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
 lvchange -ay $vg1/$lv1
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
@@ -195,9 +195,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
@@ -207,10 +207,10 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 512
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -220,13 +220,13 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg1/$lv1
 # lv needs to be inactive to increase LBS from 512
 lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 1024
 lvchange -ay $vg1/$lv1
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
@@ -236,9 +236,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -263,14 +263,14 @@ mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 lvchange -an $vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
 lvchange -ay $vg1/$lv1
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 cat $mnt/test
 umount $mnt
-blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvchange -an $vg1/$lv1
 lvremove -y $vg1/$lv1
@@ -282,14 +282,14 @@ mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg2/$lv1
 lvconvert --raidintegrity y $vg2/$lv1
 lvchange -ay $vg2/$lv1
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 cat $mnt/test
 umount $mnt
-blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvchange -an $vg2/$lv1
 lvremove -y $vg2/$lv1
diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 7a16ef5e4..73846ed71 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -59,7 +59,7 @@ sleep 3
 # print what  blkid thinks about each PV
 for i in "$dev1" "$dev2" "$dev3" "$dev4"
 do
-	blkid -c /dev/null -w /dev/null "$i" || echo "Unknown signature"
+	blkid -c /dev/null "$i" || echo "Unknown signature"
 done
 
 # expect open count for each PV to be 0
diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 74f8c2ae5..a8bb1e49d 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -144,7 +144,7 @@ aux prepare_devs 2 64
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -L50 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 


