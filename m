From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 12:47:22 -0400
Subject: master - tests: change mkfs usage in lvconvert raid tests
Message-ID: <201905231647.x4NGlMXQ026126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1022b88a66dd02e981e738719e17452cd5c1bd59
Commit:        1022b88a66dd02e981e738719e17452cd5c1bd59
Parent:        6169c0a51b8098e4ffa15fb52cafccf7a73ab22c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 23 11:45:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 11:45:26 2019 -0500

tests: change mkfs usage in lvconvert raid tests

The "echo y | mkfs" was failing at times from echo y.
Remove echo y and replace with wipefs -a prior to mkfs.
---
 ...ert-raid-reshape-linear_to_raid6-single-type.sh |    3 ++-
 ...t-raid-reshape-linear_to_striped-single-type.sh |    3 ++-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    3 ++-
 test/shell/lvconvert-raid-reshape-load.sh          |    3 ++-
 ...t-raid-reshape-striped_to_linear-single-type.sh |    3 ++-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    3 ++-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    3 ++-
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    3 ++-
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    3 ++-
 test/shell/lvconvert-raid-restripe-linear.sh       |    3 ++-
 test/shell/lvconvert-raid5_to_raid10.sh            |    3 ++-
 11 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
index cbacf4a..b75e690 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -32,7 +32,8 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+wipefs -a $DM_DEV_DIR/$vg/$lv
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
 fsck -fn $DM_DEV_DIR/$vg/$lv
 
 # Convert linear -> raid1 (takeover)
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
index 6d49f54..62bf482 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -31,7 +31,8 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+wipefs -a $DM_DEV_DIR/$vg/$lv
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
 fsck -fn $DM_DEV_DIR/$vg/$lv
 
 # Convert linear -> raid1
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index c398c5e..b77a1d9 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -30,7 +30,8 @@ lvcreate -aey -L 16M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "linear"
 check lv_field $vg/$lv1 stripes 1
 check lv_field $vg/$lv1 data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+wipefs -a $DM_DEV_DIR/$vg/$lv1
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Convert linear -> raid1
diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 11af24d..7cd149b 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -44,7 +44,8 @@ lvcreate --yes --type raid5_ls --stripes 13 -L190M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 data_stripes 13
 check lv_first_seg_field $vg/$lv1 stripes 14
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 aux wait_for_sync $vg $lv1
 
 mkdir -p $mount_dir
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
index 60fc59f..9840eea 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
@@ -32,7 +32,8 @@ check lv_first_seg_field $vg/$lv segtype "striped"
 check lv_first_seg_field $vg/$lv stripes 4
 check lv_first_seg_field $vg/$lv data_stripes 4
 check lv_first_seg_field $vg/$lv stripesize "64.00k"
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+wipefs -a $DM_DEV_DIR/$vg/$lv
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
 fsck -fn $DM_DEV_DIR/$vg/$lv
 lvextend -y -L64M $DM_DEV_DIR/$vg/$lv
 
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index e217ea3..77e04bc 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -33,7 +33,8 @@ check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 reshape_len_le ""
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+wipefs -a $DM_DEV_DIR/$vg/$lv1
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Convert striped -> raid5(_n)
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 5fa21dc..8dda252 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -45,7 +45,8 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 fsck -fn /dev/$vg/$lv1
 
 mkdir -p $mount_dir
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 61afa88..7318561 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -48,7 +48,8 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 
 mkdir -p "$mount_dir"
 mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index dd04798..32c8174 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -45,7 +45,8 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-echo y|mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a /dev/$vg/$lv1
+mkfs -t ext4 /dev/$vg/$lv1
 
 mkdir -p $mount_dir
 mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
diff --git a/test/shell/lvconvert-raid-restripe-linear.sh b/test/shell/lvconvert-raid-restripe-linear.sh
index 70d31db..b770a47 100644
--- a/test/shell/lvconvert-raid-restripe-linear.sh
+++ b/test/shell/lvconvert-raid-restripe-linear.sh
@@ -29,7 +29,8 @@ lvcreate -aey -L 16M -n $lv $vg
 check lv_field $vg/$lv segtype "linear"
 check lv_field $vg/$lv stripes 1
 check lv_field $vg/$lv data_stripes 1
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+wipefs -a $DM_DEV_DIR/$vg/$lv
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
 fsck -fn $DM_DEV_DIR/$vg/$lv
 
 # Convert linear -> raid1
diff --git a/test/shell/lvconvert-raid5_to_raid10.sh b/test/shell/lvconvert-raid5_to_raid10.sh
index e38e4d3..28f3026 100644
--- a/test/shell/lvconvert-raid5_to_raid10.sh
+++ b/test/shell/lvconvert-raid5_to_raid10.sh
@@ -30,7 +30,8 @@ check lv_field $vg/$lv1 segtype "raid5"
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 data_stripes 3
 check lv_field $vg/$lv1 region_size "256.00k"
-echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+wipefs -a $DM_DEV_DIR/$vg/$lv1
+mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1


