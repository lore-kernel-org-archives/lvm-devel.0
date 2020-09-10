From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:22 +0000 (GMT)
Subject: master - tests: adding "" around DM_DEV_DIR
Message-ID: <20200910215622.85A83398544E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49d2b27a687da0bffcfc2517576bcf364aac90c0
Commit:        49d2b27a687da0bffcfc2517576bcf364aac90c0
Parent:        3dcd61d3d797e3ed12e934f1fa7064153e2fdb71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 16:47:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:55:03 2020 +0200

tests: adding "" around DM_DEV_DIR

---
 ...ert-raid-reshape-linear_to_raid6-single-type.sh | 22 +++++++++---------
 ...t-raid-reshape-linear_to_striped-single-type.sh | 18 +++++++--------
 .../lvconvert-raid-reshape-linear_to_striped.sh    | 18 +++++++--------
 ...t-raid-reshape-striped_to_linear-single-type.sh | 16 ++++++-------
 .../lvconvert-raid-reshape-striped_to_linear.sh    | 26 +++++++++++-----------
 .../lvconvert-raid-reshape-stripes-load-fail.sh    | 14 ++++++------
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |  2 +-
 test/shell/lvconvert-raid-reshape.sh               |  8 +++----
 test/shell/lvconvert-raid-restripe-linear.sh       | 18 +++++++--------
 test/shell/lvconvert-raid5_to_raid10.sh            | 16 ++++++-------
 test/shell/lvcreate-raid1-read-error.sh            |  2 +-
 11 files changed, 80 insertions(+), 80 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
index b75e69027..731f00649 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -32,23 +32,23 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-wipefs -a $DM_DEV_DIR/$vg/$lv
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
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
@@ -57,7 +57,7 @@ check lv_field $vg/$lv regionsize "128.00k"
 
 # Convert raid5_ls adding stripes (reshape)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 3
@@ -65,11 +65,11 @@ check lv_first_seg_field $vg/$lv stripesize "64.00k"
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
@@ -80,7 +80,7 @@ aux wait_for_sync $vg $lv
 
 # Convert raid6_ls_6 -> raid6(_zr) (reshape)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid6"
 check lv_first_seg_field $vg/$lv stripes 5
 check lv_first_seg_field $vg/$lv data_stripes 3
@@ -91,7 +91,7 @@ aux wait_for_sync $vg $lv
 
 # Remove reshape space
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid6"
 check lv_first_seg_field $vg/$lv stripes 5
 check lv_first_seg_field $vg/$lv data_stripes 3
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
index 62bf48252..09f90dc7c 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -31,23 +31,23 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-wipefs -a $DM_DEV_DIR/$vg/$lv
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
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
@@ -56,7 +56,7 @@ check lv_field $vg/$lv regionsize "128.00k"
 
 # Convert raid5_n adding stripes
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_first_seg_field $vg/$lv segtype "raid5_n"
 check lv_first_seg_field $vg/$lv data_stripes 4
 check lv_first_seg_field $vg/$lv stripes 5
@@ -65,11 +65,11 @@ check lv_first_seg_field $vg/$lv stripesize "64.00k"
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
index b77a1d94e..7df25f12a 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -30,23 +30,23 @@ lvcreate -aey -L 16M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "linear"
 check lv_field $vg/$lv1 stripes 1
 check lv_field $vg/$lv1 data_stripes 1
-wipefs -a $DM_DEV_DIR/$vg/$lv1
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
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
@@ -55,7 +55,7 @@ check lv_field $vg/$lv1 regionsize "512.00k"
 
 # Convert raid5_n adding stripes
 lvconvert -y --stripes 4 $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 4
 check lv_first_seg_field $vg/$lv1 stripes 5
@@ -63,10 +63,10 @@ check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
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
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
index 9840eeae1..d7d4715ae 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
@@ -32,10 +32,10 @@ check lv_first_seg_field $vg/$lv segtype "striped"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 4
 check lv_first_seg_field $vg/$lv stripesize "64.00k"
-wipefs -a $DM_DEV_DIR/$vg/$lv
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
-lvextend -y -L64M $DM_DEV_DIR/$vg/$lv
+wipefs -a "$DM_DEV_DIR/$vg/$lv"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
+lvextend -y -L64M $vg/$lv
 
 # Convert striped -> raid5_n
 lvconvert -y --type linear $vg/$lv
@@ -47,14 +47,14 @@ check lv_field $vg/$lv stripesize "64.00k"
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
@@ -72,7 +72,7 @@ check lv_field $vg/$lv data_stripes 2
 check lv_field $vg/$lv stripesize 0
 check lv_field $vg/$lv regionsize "512.00k"
 check lv_field $vg/$lv reshape_len_le ""
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid1 -> linear
 lvconvert -y --type linear $vg/$lv
@@ -81,6 +81,6 @@ check lv_first_seg_field $vg/$lv stripes 1
 check lv_first_seg_field $vg/$lv data_stripes 1
 check lv_first_seg_field $vg/$lv stripesize 0
 check lv_first_seg_field $vg/$lv regionsize 0
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 77e04bc7c..ab075e1e8 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -33,13 +33,13 @@ check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 reshape_len_le ""
-wipefs -a $DM_DEV_DIR/$vg/$lv1
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
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
@@ -47,7 +47,7 @@ check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
 check lv_field $vg/$lv1 reshape_len_le 0
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Extend raid5_n LV by factor 4 to keep size once linear
 lvresize -y -L 64M $vg/$lv1
@@ -60,13 +60,13 @@ check lv_field $vg/$lv1 stripesize "32.00k"
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
@@ -78,7 +78,7 @@ check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 #	check lv_first_seg_field $vg/${lv1}_rimage_${slv} reshape_len_le 2
 # done
 aux wait_for_sync $vg $lv1 1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Remove the now freed legs
 lvconvert -y --stripes 1 $vg/$lv1
@@ -88,28 +88,28 @@ check lv_first_seg_field $vg/$lv1 stripes 2
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
index cb94a66ba..656e49818 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -46,14 +46,14 @@ wipefs -a /dev/$vg/$lv1
 mkfs -t ext4 /dev/$vg/$lv1
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
@@ -70,10 +70,10 @@ check lv_first_seg_field $vg/$lv1 stripes 16
 
 kill -9 %%
 wait
-rm -fr $mount_dir/[12]
+rm -fr "$mount_dir/[12]"
 
 sync
-umount $mount_dir
+umount "$mount_dir"
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 414445244..1afeff46b 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -90,7 +90,7 @@ wait
 
 checksum_ "$mount_dir/random" >MD5_new
 
-umount $mount_dir
+umount "$mount_dir"
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 28c7e2d12..bc6eaa733 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -64,7 +64,7 @@ function _lvconvert
 	[ "${level:0:7}" = "striped" ] && wait_and_check=0
 	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
 
-	lvconvert -y --ty $req_level $R "$DM_DEV_DIR/$vg/$lv" || return $?
+	lvconvert -y --ty $req_level $R $vg/$lv || return $?
 
 	check lv_first_seg_field $vg/$lv segtype "$level"
 	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
@@ -95,7 +95,7 @@ function _reshape_layout
 
 	[[ "$opts" =~ "--stripes" ]] && ignore_a_chars=1
 
-	lvconvert -y --ty $type $opts "$DM_DEV_DIR/$vg/$lv"
+	lvconvert -y --ty $type $opts $vg/$lv
 	check lv_first_seg_field $vg/$lv segtype "$type"
 	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes
@@ -170,8 +170,8 @@ fi
 
 # No we got the data reshaped and the freed SubLVs still present
 # -> check takeover request gets rejected
-not lvconvert --yes --type striped "$DM_DEV_DIR/$vg/$lv1"
-not lvconvert --yes --type raid0 "$DM_DEV_DIR/$vg/$lv1"
+not lvconvert --yes --type striped $vg/$lv1
+not lvconvert --yes --type raid0 $vg/$lv1
 not lvconvert --yes --type "$DM_DEV_DIR/raid0_meta $vg/$lv1"
 not lvconvert --yes --type "$DM_DEV_DIR/raid6 $vg/$lv1"
 # Remove the freed SubLVs
diff --git a/test/shell/lvconvert-raid-restripe-linear.sh b/test/shell/lvconvert-raid-restripe-linear.sh
index b770a4743..59b4d5d6e 100644
--- a/test/shell/lvconvert-raid-restripe-linear.sh
+++ b/test/shell/lvconvert-raid-restripe-linear.sh
@@ -29,22 +29,22 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-wipefs -a $DM_DEV_DIR/$vg/$lv
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+wipefs -a "$DM_DEV_DIR/$vg/$lv"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert linear -> raid1
 not lvconvert -y --stripes 4 $vg/$lv
 not lvconvert -y --stripes 4 --stripesize 64K $vg/$lv
 not lvconvert -y --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 check lv_field $vg/$lv segtype "raid1"
 check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 2
 check lv_field $vg/$lv regionsize "512.00k"
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid1 -> raid5_n
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
@@ -53,7 +53,7 @@ check lv_field $vg/$lv stripes 2
 check lv_field $vg/$lv data_stripes 1
 check lv_field $vg/$lv stripesize "64.00k"
 check lv_field $vg/$lv regionsize "512.00k"
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid5_n adding stripes
 lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
@@ -64,11 +64,11 @@ check lv_first_seg_field $vg/$lv stripesize "64.00k"
 check lv_first_seg_field $vg/$lv regionsize "512.00k"
 check lv_first_seg_field $vg/$lv reshape_len_le 10
 aux wait_for_sync $vg $lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
-resize2fs $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
+resize2fs "$DM_DEV_DIR/$vg/$lv"
 
 # Convert raid5_n -> striped
 lvconvert -y --type striped $vg/$lv
-fsck -fn $DM_DEV_DIR/$vg/$lv
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid5_to_raid10.sh b/test/shell/lvconvert-raid5_to_raid10.sh
index 28f302654..e7ecbc4e0 100644
--- a/test/shell/lvconvert-raid5_to_raid10.sh
+++ b/test/shell/lvconvert-raid5_to_raid10.sh
@@ -30,32 +30,32 @@ check lv_field $vg/$lv1 segtype "raid5"
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 data_stripes 3
 check lv_field $vg/$lv1 region_size "256.00k"
-wipefs -a $DM_DEV_DIR/$vg/$lv1
-mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5 -> raid10 (first step raid5 -> raid5_n)
 lvconvert -y --ty raid10 $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 data_stripes 3
 check lv_field $vg/$lv1 region_size "256.00k"
 aux wait_for_sync $vg $lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5 -> raid10 (second step raid5_n -> raid0_meta)
 lvconvert -y --ty raid10 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid0_meta"
 check lv_field $vg/$lv1 stripes 3
 check lv_field $vg/$lv1 data_stripes 3
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert raid5 -> raid10 (third + last step raid0_meta -> raid10)
 lvconvert -y --ty raid10 -R 256K $vg/$lv1
-fsck -fn $DM_DEV_DIR/$vg/$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid10"
 check lv_field $vg/$lv1 stripes 6
 check lv_field $vg/$lv1 data_stripes 3
diff --git a/test/shell/lvcreate-raid1-read-error.sh b/test/shell/lvcreate-raid1-read-error.sh
index 322c60e39..f9c6bb9e7 100644
--- a/test/shell/lvcreate-raid1-read-error.sh
+++ b/test/shell/lvcreate-raid1-read-error.sh
@@ -28,6 +28,6 @@ aux wait_for_sync $vg $lv
 
 aux error_dev "$dev1" 20:500
 
-dd if=$DM_DEV_DIR/$vg/$lv iflag=direct,fullblock of=/dev/zero bs=128K count=1
+dd if="$DM_DEV_DIR/$vg/$lv" iflag=direct,fullblock of=/dev/zero bs=128K count=1
 
 vgremove --force $vg


