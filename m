From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:14 +0000 (GMT)
Subject: stable-2.02 - tests: changes from master
Message-ID: <20201020212514.7FE14394741A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f33ccaee45eb75c3aeac8a6647997de87ff3f207
Commit:        f33ccaee45eb75c3aeac8a6647997de87ff3f207
Parent:        e8cd4e2057eecfc5c0b68658a7c8ac601a70949b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 23:23:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 23:23:44 2020 +0200

tests: changes from master

---
 ...ert-raid-reshape-linear_to_raid6-single-type.sh | 26 ++++++++--------
 ...t-raid-reshape-linear_to_striped-single-type.sh | 22 ++++++-------
 .../lvconvert-raid-reshape-linear_to_striped.sh    | 22 ++++++-------
 test/shell/lvconvert-raid-reshape-load.sh          |  5 +--
 ...t-raid-reshape-striped_to_linear-single-type.sh | 21 ++++++-------
 .../lvconvert-raid-reshape-striped_to_linear.sh    | 31 +++++++++----------
 .../lvconvert-raid-reshape-stripes-load-fail.sh    | 23 ++++++++------
 .../lvconvert-raid-reshape-stripes-load-reload.sh  | 36 +++++++++++++++-------
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |  9 ++++--
 9 files changed, 104 insertions(+), 91 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
index 05cb61635..731f00649 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -19,11 +19,8 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #
@@ -35,22 +32,23 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+wipefs -a "$DM_DEV_DIR/$vg/$lv"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert linear -> raid1 (takeover)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_field $vg/$lv segtype "raid1"
 check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 2
 check lv_field $vg/$lv regionsize "128.00k"
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid1 -> raid5_ls (takeover)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_field $vg/$lv segtype "raid5_ls"
 check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 1
@@ -59,7 +57,7 @@ check lv_field $vg/$lv regionsize "128.00k"
 
 # Convert raid5_ls adding stripes (reshape)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 3
@@ -67,11 +65,11 @@ check lv_first_seg_field $vg/$lv stripesize "64.00k"
 check lv_first_seg_field $vg/$lv regionsize "128.00k"
 check lv_first_seg_field $vg/$lv reshape_len_le 8
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid5_ls -> raid6_ls_6 (takeover)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid6_ls_6"
 check lv_first_seg_field $vg/$lv stripes 5
 check lv_first_seg_field $vg/$lv data_stripes 3
@@ -82,7 +80,7 @@ aux wait_for_sync $vg $lv
 
 # Convert raid6_ls_6 -> raid6(_zr) (reshape)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid6"
 check lv_first_seg_field $vg/$lv stripes 5
 check lv_first_seg_field $vg/$lv data_stripes 3
@@ -93,7 +91,7 @@ aux wait_for_sync $vg $lv
 
 # Remove reshape space
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid6"
 check lv_first_seg_field $vg/$lv stripes 5
 check lv_first_seg_field $vg/$lv data_stripes 3
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
index 7e31cb9f6..09f90dc7c 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -18,11 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #
@@ -34,22 +31,23 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+wipefs -a "$DM_DEV_DIR/$vg/$lv"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert linear -> raid1
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_field $vg/$lv segtype "raid1"
 check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 2
 check lv_field $vg/$lv regionsize "128.00k"
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid1 -> raid5_n
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_field $vg/$lv segtype "raid5_n"
 check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 1
@@ -58,7 +56,7 @@ check lv_field $vg/$lv regionsize "128.00k"
 
 # Convert raid5_n adding stripes
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid5_n"
 check lv_first_seg_field $vg/$lv data_stripes 4
 check lv_first_seg_field $vg/$lv stripes 5
@@ -67,11 +65,11 @@ check lv_first_seg_field $vg/$lv stripesize "64.00k"
 check lv_first_seg_field $vg/$lv regionsize "128.00k"
 check lv_first_seg_field $vg/$lv reshape_len_le 10
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid5_n -> striped
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "striped"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 4
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 04e2d62c1..7df25f12a 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -17,11 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #
@@ -33,22 +30,23 @@ lvcreate -aey -L 16M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "linear"
 check lv_field $vg/$lv1 stripes 1
 check lv_field $vg/$lv1 data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert linear -> raid1
 lvconvert -y -m 1 $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 2
 check lv_field $vg/$lv1 data_stripes 2
 check lv_field $vg/$lv1 regionsize "512.00k"
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid1 -> raid5_n
 lvconvert -y --ty raid5_n --stripesize 64K --regionsize 512K $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 stripes 2
 check lv_field $vg/$lv1 data_stripes 1
@@ -57,7 +55,7 @@ check lv_field $vg/$lv1 regionsize "512.00k"
 
 # Convert raid5_n adding stripes
 lvconvert -y --stripes 4 $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 4
 check lv_first_seg_field $vg/$lv1 stripes 5
@@ -65,10 +63,10 @@ check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "512.00k"
 check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5_n -> striped
 lvconvert -y --type striped $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index c42154a4b..14b5dfdde 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 # Test reshaping under io load
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 2 || skip
+aux have_raid 1 14 0 || skip
 
 mount_dir="mnt"
 
@@ -41,7 +41,8 @@ lvcreate --yes --type raid5_ls --stripes 13 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 data_stripes 13
 check lv_first_seg_field $vg/$lv1 stripes 14
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 aux wait_for_sync $vg $lv1
 
 mkdir -p $mount_dir
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
index 476fb1095..d7d4715ae 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
@@ -18,11 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 5
 
@@ -36,9 +32,10 @@ check lv_first_seg_field $vg/$lv segtype "striped"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 4
 check lv_first_seg_field $vg/$lv stripesize "64.00k"
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
-lvextend -y -L64M $DM_DEV_DIR/$vg/$lv
+wipefs -a "$DM_DEV_DIR/$vg/$lv"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
+lvextend -y -L64M $vg/$lv
 
 # Convert striped -> raid5_n
 lvconvert -y --type linear $vg/$lv
@@ -50,14 +47,14 @@ check lv_field $vg/$lv stripesize "64.00k"
 check lv_field $vg/$lv regionsize "512.00k"
 check lv_field $vg/$lv reshape_len_le 0
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Restripe raid5_n LV to single data stripe
 #
 # Need --force in order to remove stripes thus shrinking LV size!
 lvconvert -y --force --type linear $vg/$lv
 aux wait_for_sync $vg $lv 1
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 # Remove the now freed stripes
 lvconvert -y --type linear $vg/$lv
 check lv_field $vg/$lv segtype "raid5_n"
@@ -75,7 +72,7 @@ check lv_field $vg/$lv data_stripes 2
 check lv_field $vg/$lv stripesize 0
 check lv_field $vg/$lv regionsize "512.00k"
 check lv_field $vg/$lv reshape_len_le ""
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid1 -> linear
 lvconvert -y --type linear $vg/$lv
@@ -84,6 +81,6 @@ check lv_first_seg_field $vg/$lv stripes 1
 check lv_first_seg_field $vg/$lv data_stripes 1
 check lv_first_seg_field $vg/$lv stripesize 0
 check lv_first_seg_field $vg/$lv regionsize 0
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index ccbe6ad38..ab075e1e8 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -18,11 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 5 20
 
@@ -37,12 +33,13 @@ check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 reshape_len_le ""
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert striped -> raid5(_n)
 lvconvert -y --ty raid5 -R 128k $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 5
@@ -50,7 +47,7 @@ check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
 check lv_field $vg/$lv1 reshape_len_le 0
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Extend raid5_n LV by factor 4 to keep size once linear
 lvresize -y -L 64M $vg/$lv1
@@ -63,13 +60,13 @@ check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
 check lv_field $vg/$lv1 reshape_len_le "0"
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5_n LV to 1 stripe (2 legs total),
 # 64k stripesize and 1024k regionsize
 # FIXME: "--type" superfluous (cli fix needed)
 lvconvert -y -f --ty raid5_n --stripes 1 -I 64k -R 1024k $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 5
@@ -81,7 +78,7 @@ check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 #	check lv_first_seg_field $vg/${lv1}_rimage_${slv} reshape_len_le 2
 # done
 aux wait_for_sync $vg $lv1 1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Remove the now freed legs
 lvconvert -y --stripes 1 $vg/$lv1
@@ -91,28 +88,28 @@ check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "32.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le 4
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5_n to raid1
 lvconvert -y --type raid1 $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_first_seg_field $vg/$lv1 segtype "raid1"
 check lv_first_seg_field $vg/$lv1 data_stripes 2
 check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le ""
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid1 -> linear
 lvconvert -y --type linear $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_first_seg_field $vg/$lv1 segtype "linear"
 check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 1
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "0"
 check lv_first_seg_field $vg/$lv1 reshape_len_le ""
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index cadacb581..220cd365c 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+case "$(uname -r)" in
+  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+esac
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -36,23 +40,24 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 fsck -fn /dev/$vg/$lv1
 
-mkdir -p $mount_dir
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-mkdir -p $mount_dir/1 $mount_dir/2
+mkdir -p "$mount_dir"
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+mkdir -p "$mount_dir/1" "$mount_dir/2"
 
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mount_dir/1 &>/dev/null &
-cp -r /usr/bin $mount_dir/2 &>/dev/null &
+cp -r /usr/bin "$mount_dir/1" &>/dev/null &
+cp -r /usr/bin "$mount_dir/2" &>/dev/null &
 sync &
 
 aux wait_for_sync $vg $lv1
@@ -69,10 +74,10 @@ check lv_first_seg_field $vg/$lv1 stripes 16
 
 kill -9 %%
 wait
-rm -fr $mount_dir/[12]
+rm -fr "$mount_dir/[12]"
 
 sync
-umount $mount_dir
+umount "$mount_dir"
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index d439a7cd5..b79561fbb 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -17,9 +17,14 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+which md5sum || skip
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
+case "$(uname -r)" in
+  5.[89]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+esac
+
 mount_dir="mnt"
 
 cleanup_mounted_and_teardown()
@@ -28,6 +33,11 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
+checksum_()
+{
+	md5sum "$1" | cut -f1 -d' '
+}
+
 aux prepare_pvs 16 32
 
 get_devs
@@ -36,24 +46,22 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 
-mkdir -p $mount_dir
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-mkdir -p $mount_dir/1 $mount_dir/2
+mkdir -p "$mount_dir"
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
 echo 3 >/proc/sys/vm/drop_caches
 # FIXME: This is filling up ram disk. Use sane amount of data please! Rate limit the data written!
-cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
-# FIXME: should this wait for above two processes and sync then?
-sync &
+dd if=/dev/urandom of="$mount_dir/random" bs=1M count=4 conv=fdatasync
+checksum_ "$mount_dir/random" >MD5
 
 # FIXME: wait_for_sync - is this really testing anything under load?
 aux wait_for_sync $vg $lv1
@@ -77,11 +85,17 @@ done
 
 aux delay_dev "$dev2" 0
 
-kill -9 %%
+kill -9 %% || true
 wait
 
-umount $mount_dir
+checksum_ "$mount_dir/random" >MD5_new
+
+umount "$mount_dir"
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
+# Compare checksum is matching
+cat MD5 MD5_new
+diff MD5 MD5_new
+
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index aa6913f95..6184e9d64 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -15,6 +15,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+case "$(uname -r)" in
+  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+esac
+
 # Test reshaping under io load
 
 which mkfs.ext4 || skip
@@ -36,13 +40,14 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 
 mkdir -p $mount_dir
 mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir


