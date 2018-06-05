From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 5 Jun 2018 10:25:46 -0400
Subject: master - test: add convcenience conversion tests linear <-> striped
Message-ID: <201806051425.w55EPkN9028182@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3810fd8d0d9cfcc519355f995d9cc70dca2811fd
Commit:        3810fd8d0d9cfcc519355f995d9cc70dca2811fd
Parent:        bd7cdd0b09ba123b064937fddde08daacbed7dab
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 30 12:50:34 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 5 16:23:18 2018 +0200

test: add convcenience conversion tests linear <-> striped

Add tests for linear <-> striped|raid* conversions.

Add region_size config to reshape tests to avoid test
failures in case of it being defined unexpectedly in lvm.conf.

Related: rhbz1439925
Related: rhbz1447809
---
 test/shell/lvchange-rebuild-raid.sh                |    2 +-
 ...ert-raid-reshape-linear_to_raid6-single-type.sh |  102 ++++++++++++++++++++
 ...t-raid-reshape-linear_to_striped-single-type.sh |   80 +++++++++++++++
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    2 +
 ...t-raid-reshape-striped_to_linear-single-type.sh |   89 +++++++++++++++++
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    9 ++-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    9 +-
 test/shell/lvconvert-raid-restripe-linear.sh       |   76 +++++++++++++++
 8 files changed, 363 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 913a88d..22acb92 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 3 2 || skip
 v1_9_0=0
-aux have_raid 1 9 && v1_9_0=1
+aux have_raid 1 9 0 && v1_9_0=1
 
 aux prepare_vg 8
 get_devs
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
new file mode 100644
index 0000000..f01e7ef
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -0,0 +1,102 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# Ensure expected default region size
+aux lvmconf 'activation/raid_region_size = 512'
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 1 || skip
+
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_multi_core || skip
+aux prepare_vg 5
+
+#
+# Test multi step linear -> striped conversion
+#
+
+# Create linear LV
+lvcreate -aey -L 16M -n $lv $vg
+check lv_field $vg/$lv segtype "linear"
+check lv_field $vg/$lv stripes 1
+check lv_field $vg/$lv data_stripes 1
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert linear -> raid1 (takeover)
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv regionsize "128.00k"
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid1 -> raid5_ls (takeover)
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_field $vg/$lv segtype "raid5_ls"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv regionsize "128.00k"
+
+# Convert raid5_ls adding stripes (reshape)
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv stripes 4
+check lv_first_seg_field $vg/$lv data_stripes 3
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "128.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 8
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid5_ls -> raid6_ls_6 (takeover)
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid6_ls_6"
+check lv_first_seg_field $vg/$lv stripes 5
+check lv_first_seg_field $vg/$lv data_stripes 3
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "128.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 0
+
+# Convert raid6_ls_6 -> raid6(_zr) (reshape)
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid6"
+check lv_first_seg_field $vg/$lv stripes 5
+check lv_first_seg_field $vg/$lv data_stripes 3
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "128.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 10
+
+# Remove reshape space
+lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid6"
+check lv_first_seg_field $vg/$lv stripes 5
+check lv_first_seg_field $vg/$lv data_stripes 3
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "128.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 0
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
new file mode 100644
index 0000000..7e31cb9
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -0,0 +1,80 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux lvmconf 'activation/raid_region_size = 512'
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 1 || skip
+
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_multi_core || skip
+aux prepare_vg 5
+
+#
+# Test multi step linear -> striped conversion
+#
+
+# Create linear LV
+lvcreate -aey -L 16M -n $lv $vg
+check lv_field $vg/$lv segtype "linear"
+check lv_field $vg/$lv stripes 1
+check lv_field $vg/$lv data_stripes 1
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert linear -> raid1
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv regionsize "128.00k"
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid1 -> raid5_n
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_field $vg/$lv segtype "raid5_n"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv regionsize "128.00k"
+
+# Convert raid5_n adding stripes
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid5_n"
+check lv_first_seg_field $vg/$lv data_stripes 4
+check lv_first_seg_field $vg/$lv stripes 5
+check lv_first_seg_field $vg/$lv data_stripes 4
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "128.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 10
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid5_n -> striped
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 128K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_first_seg_field $vg/$lv segtype "striped"
+check lv_first_seg_field $vg/$lv stripes 4
+check lv_first_seg_field $vg/$lv data_stripes 4
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 55d4c18..04e2d62 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -14,6 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'activation/raid_region_size = 512'
+
 which mkfs.ext4 || skip
 aux have_raid 1 12 0 || skip
 
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
new file mode 100644
index 0000000..476fb10
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
@@ -0,0 +1,89 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux lvmconf 'activation/raid_region_size = 512'
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 1 || skip
+
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_multi_core || skip
+
+aux prepare_vg 5
+
+#
+# Test multi step striped -> linear conversion
+#
+
+# Create 4-way striped LV
+lvcreate -aey --type striped -L 16M --stripes 4 --stripesize 64K -n $lv $vg
+check lv_first_seg_field $vg/$lv segtype "striped"
+check lv_first_seg_field $vg/$lv stripes 4
+check lv_first_seg_field $vg/$lv data_stripes 4
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+lvextend -y -L64M $DM_DEV_DIR/$vg/$lv
+
+# Convert striped -> raid5_n
+lvconvert -y --type linear $vg/$lv
+check lv_field $vg/$lv segtype "raid5_n"
+check lv_field $vg/$lv data_stripes 4
+check lv_field $vg/$lv stripes 5
+check lv_field $vg/$lv data_stripes 4
+check lv_field $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv regionsize "512.00k"
+check lv_field $vg/$lv reshape_len_le 0
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Restripe raid5_n LV to single data stripe
+#
+# Need --force in order to remove stripes thus shrinking LV size!
+lvconvert -y --force --type linear $vg/$lv
+aux wait_for_sync $vg $lv 1
+fsck -fn $DM_DEV_DIR/$vg/$lv
+# Remove the now freed stripes
+lvconvert -y --type linear $vg/$lv
+check lv_field $vg/$lv segtype "raid5_n"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv regionsize "512.00k"
+check lv_field $vg/$lv reshape_len_le 4
+
+# Convert raid5_n -> raid1
+lvconvert -y --type linear $vg/$lv
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv stripesize 0
+check lv_field $vg/$lv regionsize "512.00k"
+check lv_field $vg/$lv reshape_len_le ""
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid1 -> linear
+lvconvert -y --type linear $vg/$lv
+check lv_first_seg_field $vg/$lv segtype "linear"
+check lv_first_seg_field $vg/$lv stripes 1
+check lv_first_seg_field $vg/$lv data_stripes 1
+check lv_first_seg_field $vg/$lv stripesize 0
+check lv_first_seg_field $vg/$lv regionsize 0
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index ed3769d..ccbe6ad 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'activation/raid_region_size = 512'
+
 which mkfs.ext4 || skip
 aux have_raid 1 12 0 || skip
 
@@ -51,7 +53,9 @@ aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Extend raid5_n LV by factor 4 to keep size once linear
-lvresize -y -L 64 $vg/$lv1
+lvresize -y -L 64M $vg/$lv1
+aux wait_for_sync $vg $lv1
+
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 5
@@ -87,6 +91,7 @@ check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "32.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le 4
+fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Convert raid5_n to raid1
 lvconvert -y --type raid1 $vg/$lv1
@@ -97,6 +102,7 @@ check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le ""
+fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Convert raid1 -> linear
 lvconvert -y --type linear $vg/$lv1
@@ -107,5 +113,6 @@ check lv_first_seg_field $vg/$lv1 stripes 1
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "0"
 check lv_first_seg_field $vg/$lv1 reshape_len_le ""
+fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index feaf1e2..c7ccad8 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -46,6 +46,7 @@ check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
 echo y|mkfs -t ext4 /dev/$vg/$lv1
+fsck -fn /dev/$vg/$lv1
 
 mkdir -p $mount_dir
 mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
@@ -53,8 +54,8 @@ mkdir -p $mount_dir/1 $mount_dir/2
 
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/1 &>/dev/null &
+cp -r /usr/bin $mount_dir/2 &>/dev/null &
 sync &
 
 aux wait_for_sync $vg $lv1
@@ -69,11 +70,11 @@ check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 15
 check lv_first_seg_field $vg/$lv1 stripes 16
 
-rm -fr $mount_dir/2
-sync
 kill -9 %%
 wait
+rm -fr $mount_dir/[12]
 
+sync
 umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvconvert-raid-restripe-linear.sh b/test/shell/lvconvert-raid-restripe-linear.sh
new file mode 100644
index 0000000..0ac8a04
--- /dev/null
+++ b/test/shell/lvconvert-raid-restripe-linear.sh
@@ -0,0 +1,76 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+aux have_raid 1 12 0 || skip
+
+# Temporarily skip reshape tests on single-core CPUs until there's a fix for
+# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
+aux have_multi_core || skip
+aux prepare_vg 5
+
+#
+# Test single step linear -> striped conversion
+#
+
+# Create linear LV
+lvcreate -aey -L 16M -n $lv $vg
+check lv_field $vg/$lv segtype "linear"
+check lv_field $vg/$lv stripes 1
+check lv_field $vg/$lv data_stripes 1
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert linear -> raid1
+not lvconvert -y --stripes 4 $vg/$lv
+not lvconvert -y --stripes 4 --stripesize 64K $vg/$lv
+not lvconvert -y --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv regionsize "512.00k"
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid1 -> raid5_n
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
+check lv_field $vg/$lv segtype "raid5_n"
+check lv_field $vg/$lv stripes 2
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv regionsize "512.00k"
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+# Convert raid5_n adding stripes
+lvconvert -y --type striped --stripes 4 --stripesize 64K --regionsize 512K $vg/$lv
+check lv_first_seg_field $vg/$lv segtype "raid5_n"
+check lv_first_seg_field $vg/$lv data_stripes 4
+check lv_first_seg_field $vg/$lv stripes 5
+check lv_first_seg_field $vg/$lv stripesize "64.00k"
+check lv_first_seg_field $vg/$lv regionsize "512.00k"
+check lv_first_seg_field $vg/$lv reshape_len_le 10
+aux wait_for_sync $vg $lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+resize2fs $DM_DEV_DIR/$vg/$lv
+
+# Convert raid5_n -> striped
+lvconvert -y --type striped $vg/$lv
+fsck -fn $DM_DEV_DIR/$vg/$lv
+
+vgremove -ff $vg


