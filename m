From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:42 +0000 (GMT)
Subject: main - tests: fix path to dev dir
Message-ID: <20230623160942.7450F3858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2cb43449ee4c92ae443bd72138fa91bb132aabf7
Commit:        2cb43449ee4c92ae443bd72138fa91bb132aabf7
Parent:        fec3087eefc752036a40d854c373132d25ffd30f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 20 21:19:43 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

tests: fix path to dev dir

Correct some explicit references to /dev and use $DM_DEV_DIR.
---
 test/shell/integrity-blocksize.sh                  | 30 +++++++++++-----------
 test/shell/lvconvert-raid-reshape-load.sh          |  4 +--
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |  6 ++---
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |  4 +--
 test/shell/vgchange-pvs-online.sh                  |  8 +++---
 5 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 9fd77086f..e5d2620a1 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -112,7 +112,7 @@ lvremove -y $vg1/$lv1
 # lvconvert on dev512, fsunknown, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 # clear any residual fs so that libblkid cannot find an fs block size
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR/$vg1/$lv1"
 lvconvert --raidintegrity y $vg1/$lv1
 pvck --dump metadata "$LOOP1" | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
@@ -120,7 +120,7 @@ lvremove -y $vg1/$lv1
 # lvconvert on dev4k, fsunknown, result 4k
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 # clear any residual fs so that libblkid cannot find an fs block size
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg2/$lv1"
 lvconvert --raidintegrity y $vg2/$lv1
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
@@ -128,20 +128,20 @@ lvremove -y $vg2/$lv1
 # lvconvert --bs 4k on dev512, fsunknown, result fail
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 # clear any residual fs so that libblkid cannot find an fs block size
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 not lvconvert --raidintegrity y --raidintegrityblocksize 4096 $vg1/$lv1
 lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev4k, fsunknown, result fail
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 # clear any residual fs so that libblkid cannot find an fs block size
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg2/$lv1"
 not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
 lvremove -y $vg2/$lv1
 
 # lvconvert on dev512, ext4 1024, result 1024
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | tee out
 grep BLOCK_SIZE=\"1024\" out
@@ -154,7 +154,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert on dev4k, ext4 4096, result 4096
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR/$vg2/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
@@ -166,7 +166,7 @@ lvremove -y $vg2/$lv1
 
 # lvconvert on dev512, ext4 1024, result 1024 (LV active when adding)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y $vg1/$lv1
@@ -178,7 +178,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert on dev512, ext4 1024, result 1024 (LV inactive when adding)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvchange -an $vg1/$lv1
@@ -192,7 +192,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert on dev4k, ext4 4096, result 4096
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg2/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
@@ -204,7 +204,7 @@ lvremove -y $vg2/$lv1
 
 # lvconvert --bs 512 on dev512, ext4 4096, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
@@ -217,7 +217,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert --bs 1024 on dev512, ext4 4096, result 1024
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg1/$lv1
@@ -233,7 +233,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev512, ext4 1024, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
 blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
@@ -245,7 +245,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev4k, ext4 4096, result fail
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg2/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
 lvremove -y $vg2/$lv1
@@ -257,7 +257,7 @@ lvremove -y $vg2/$lv1
 
 # lvconvert on dev512, ext4 1024, result 1024, (detect fs with LV inactive)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg1/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg1/$lv1"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 echo "test" > $mnt/test
@@ -277,7 +277,7 @@ lvremove -y $vg1/$lv1
 
 # lvconvert on dev4k, ext4 4096, result 4096 (detect fs with LV inactive)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
-aux wipefs_a /dev/$vg2/$lv1
+aux wipefs_a "$DM_DEV_DIR//$vg2/$lv1"
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 echo "test" > $mnt/test
diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 29b8e4ca4..5b381ac09 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -45,8 +45,8 @@ lvcreate --yes --type raid5_ls --stripes 13 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 data_stripes 13
 check lv_first_seg_field $vg/$lv1 stripes 14
-wipefs -a /dev/$vg/$lv1
-mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
 
 mkdir -p $mount_dir
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index da9d34798..b35cd8db6 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -46,9 +46,9 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-wipefs -a /dev/$vg/$lv1
-mkfs -t ext4 /dev/$vg/$lv1
-fsck -fn /dev/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 mkdir -p "$mount_dir"
 mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 68ab8b92b..af1553418 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -46,8 +46,8 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-wipefs -a /dev/$vg/$lv1
-mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR//$vg/$lv1"
 
 mkdir -p $mount_dir
 mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index dab7f5ad7..165e96dde 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -30,10 +30,10 @@ DF="$DFDIR/system.devices"
 
 # Because mapping devno to devname gets dm name from sysfs
 aux lvmconf 'devices/scan = "/dev"'
-bd1="/dev/mapper/$(basename $dev1)"
-bd2="/dev/mapper/$(basename $dev2)"
-bd3="/dev/mapper/$(basename $dev3)"
-bd4="/dev/mapper/$(basename $dev4)"
+bd1="$DM_DEV_DIR/mapper/$(basename $dev1)"
+bd2="$DM_DEV_DIR/mapper/$(basename $dev2)"
+bd3="$DM_DEV_DIR/mapper/$(basename $dev3)"
+bd4="$DM_DEV_DIR/mapper/$(basename $dev4)"
 aux extend_filter "a|$bd1|" "a|$bd2|" "a|$bd3|" "a|$bd4|"
 
 # Changing names will confuse df based on devname

