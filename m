From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:34 +0000 (UTC)
Subject: master - lvconvert: add missed new test scripts for reshaping
Message-ID: <20170224063234.78F6A60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76f60cc4306deda481c45de7ebcde02a40668d85
Commit:        76f60cc4306deda481c45de7ebcde02a40668d85
Parent:        2574d3257ad41cad8dcbad3332774172e86f05da
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 05:16:21 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:59 2017 +0100

lvconvert: add missed new test scripts for reshaping

Add aforementioned but forgotten new test scripts
lvconvert-raid-reshape-linear_to_striped.sh,
lvconvert-raid-reshape-striped_to_linear.sh and
lvconvert-raid-reshape.sh

Those presume dm-raid target version 1.10.2
provided by a following kernel patch.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 .../lvconvert-raid-reshape-linear_to_striped.sh    |   64 +++++++
 .../lvconvert-raid-reshape-striped_to_linear.sh    |   84 ++++++++
 test/shell/lvconvert-raid-reshape.sh               |  199 ++++++++++++++++++++
 3 files changed, 347 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
new file mode 100644
index 0000000..3b6120c
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -0,0 +1,64 @@
+#!/bin/sh
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
+aux have_raid 1 10 2 || skip
+
+aux prepare_vg 5
+
+#
+# Test single step linear -> striped conversion
+#
+
+# Create linear LV
+lvcreate -aey -L 16M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "linear"
+check lv_field $vg/$lv1 stripes 1
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert linear -> raid1
+lvconvert -y -m 1 $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 2
+check lv_field $vg/$lv1 regionsize "512.00k"
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid1 -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 2
+check lv_field $vg/$lv1 stripesize "64.00k"
+check lv_field $vg/$lv1 regionsize "512.00k"
+
+# Convert raid5_n adding stripes
+lvconvert -y --stripes 4 $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 stripes 5
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 regionsize "512.00k"
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid5_n -> striped
+lvconvert -y --type striped $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
new file mode 100644
index 0000000..fc87caf
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -0,0 +1,84 @@
+#!/bin/sh
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
+aux have_raid 1 10 2 || skip
+
+aux prepare_vg 5
+
+#
+# Test single step linear -> striped conversion
+#
+
+# Create 4-way striped  LV
+lvcreate -aey -i 4 -I 32k -L 16M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "striped"
+check lv_field $vg/$lv1 stripes 4
+check lv_field $vg/$lv1 stripesize "32.00k"
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert striped -> raid5(_n)
+lvconvert -y --ty raid5 -R 128k $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 5
+check lv_field $vg/$lv1 stripesize "32.00k"
+check lv_field $vg/$lv1 regionsize "128.00k"
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Extend raid5_n LV by factor 4 to keep size once linear
+lvresize -y -L 64 $vg/$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid5_n LV to 1 stripe (2 legs total),
+# 64k stripesize and 1024k regionsize
+# FIXME: "--type" superfluous (cli fix needed)
+lvconvert -y -f --ty raid5_n --stripes 1 -I 64k -R 1024k $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 stripes 5
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+aux wait_for_sync $vg $lv1 1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Remove the now freed legs
+lvconvert --stripes 1 $vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 stripes 2
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+
+# Convert raid5_n to raid1
+lvconvert -y --type raid1 $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid1"
+check lv_first_seg_field $vg/$lv1 stripes 2
+check lv_first_seg_field $vg/$lv1 stripesize "0"
+check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+
+# Convert raid5_n -> striped
+lvconvert -y --type linear $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "linear"
+check lv_first_seg_field $vg/$lv1 stripes 1
+check lv_first_seg_field $vg/$lv1 stripesize "0"
+check lv_first_seg_field $vg/$lv1 regionsize "0"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
new file mode 100644
index 0000000..2c302dd
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -0,0 +1,199 @@
+#!/bin/sh
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
+aux have_raid 1 10 2 || skip
+
+aux prepare_vg 64
+
+function _lvcreate
+{
+	local level=$1
+	local req_stripes=$2
+	local stripes=$3
+	local size=$4
+	local vg=$5
+	local lv=$6
+
+	lvcreate -y -aey --type $level -i $req_stripes -L $size -n $lv $vg
+	check lv_first_seg_field $vg/$lv segtype "$level"
+	check lv_first_seg_field $vg/$lv stripes $stripes
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
+}
+
+function _lvconvert
+{
+	local req_level=$1
+	local level=$2
+	local stripes=$3
+	local vg=$4
+	local lv=$5
+	local region_size=$6
+	local wait_and_check=1
+	local R=""
+
+	[ -n "$region_size" ] && R="-R $region_size"
+	[ "${level:0:7}" = "striped" ] && wait_and_check=0
+	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
+
+	lvconvert -y --ty $req_level $R $vg/$lv
+	[ $? -ne 0 ] && return $?
+	check lv_first_seg_field $vg/$lv segtype "$level"
+	check lv_first_seg_field $vg/$lv stripes $stripes
+	[ -n "$region_size" ] && check lv_field $vg/$lv regionsize $region_size
+	if [ "$wait_and_check" -eq 1 ]
+	then
+		fsck -fn "$DM_DEV_DIR/$vg/$lv"
+		aux wait_for_sync $vg $lv
+	fi
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
+}
+
+function _reshape_layout
+{
+	local type=$1
+	shift
+	local stripes=$1
+	shift
+	local vg=$1
+	shift
+	local lv=$1
+	shift
+	local opts="$*"
+	local ignore_a_chars=0
+
+	[[ "$opts" =~ "--stripes" ]] && ignore_a_chars=1
+
+	lvconvert -vvvv -y --ty $type $opts $vg/$lv
+	check lv_first_seg_field $vg/$lv segtype "$type"
+	check lv_first_seg_field $vg/$lv stripes $stripes
+	aux wait_for_sync $vg $lv $ignore_a_chars
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
+}
+
+# Delay leg so that rebuilding status characters
+#  can be read before resync finished too quick.
+# aux delay_dev "$dev1" 1
+
+#
+# Start out with raid5(_ls)
+#
+
+# Create 3-way striped raid5 (4 legs total)
+_lvcreate raid5_ls 3 4 16M $vg $lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+aux wait_for_sync $vg $lv1
+
+# Reshape it to 256K stripe size
+_reshape_layout raid5_ls 4 $vg $lv1 --stripesize 256K
+check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
+
+# Convert raid5(_n) -> striped
+not _lvconvert striped striped 3 $vg $lv1 512k
+_reshape_layout raid5_n 4 $vg $lv1
+_lvconvert striped striped 3 $vg $lv1
+
+# Convert striped -> raid5_n
+_lvconvert raid5_n raid5_n 4 $vg $lv1 "" 1
+
+# Convert raid5_n -> raid5_ls
+_reshape_layout raid5_ls 4 $vg $lv1
+
+# Convert raid5_ls to 5 stripes
+_reshape_layout raid5_ls 6 $vg $lv1 --stripes 5
+
+# Convert raid5_ls back to 3 stripes
+_reshape_layout raid5_ls 6 $vg $lv1 --stripes 3 --force
+_reshape_layout raid5_ls 4 $vg $lv1 --stripes 3
+
+# Convert raid5_ls to 7 stripes
+_reshape_layout raid5_ls 8 $vg $lv1 --stripes 7
+
+# Convert raid5_ls to 9 stripes
+_reshape_layout raid5_ls 10 $vg $lv1 --stripes 9
+
+# Convert raid5_ls to 14 stripes
+_reshape_layout raid5_ls 15 $vg $lv1 --stripes 14
+
+# Convert raid5_ls to 63 stripes
+_reshape_layout raid5_ls 64 $vg $lv1 --stripes 63
+
+# Convert raid5_ls back to 27 stripes
+_reshape_layout raid5_ls 64 $vg $lv1 --stripes 27 --force
+_reshape_layout raid5_ls 28 $vg $lv1 --stripes 27
+
+# Convert raid5_ls back to 4 stripes
+_reshape_layout raid5_ls 28 $vg $lv1 --stripes 4 --force
+_reshape_layout raid5_ls 5 $vg $lv1 --stripes 4
+
+# Convert raid5_ls back to 3 stripes
+_reshape_layout raid5_ls 5 $vg $lv1 --stripes 3 --force
+_reshape_layout raid5_ls 4 $vg $lv1 --stripes 3
+
+# Convert raid5_ls -> raid5_rs
+_reshape_layout raid5_rs 4 $vg $lv1
+
+# Convert raid5_rs -> raid5_la
+_reshape_layout raid5_la 4 $vg $lv1
+
+# Convert raid5_la -> raid5_ra
+_reshape_layout raid5_ra 4 $vg $lv1
+
+# Convert raid5_ra -> raid6_ra_6
+_lvconvert raid6_ra_6 raid6_ra_6 5 $vg $lv1 "4.00m" 1
+
+# Convert raid5_la -> raid6(_zr)
+_reshape_layout raid6 5 $vg $lv1
+
+# Convert raid6(_zr) -> raid6_nc
+_reshape_layout raid6_nc 5 $vg $lv1
+
+# Convert raid6(_nc) -> raid6_nr
+_reshape_layout raid6_nr 5 $vg $lv1
+
+# Convert raid6_nr) -> raid6_rs_6
+_reshape_layout raid6_rs_6 5 $vg $lv1
+
+# Convert raid6_rs_6 to 5 stripes
+_reshape_layout raid6_rs_6 7 $vg $lv1 --stripes 5
+
+# Convert raid6_rs_6 to 4 stripes
+_reshape_layout raid6_rs_6 7 $vg $lv1 --stripes 4 --force
+_reshape_layout raid6_rs_6 6 $vg $lv1 --stripes 4
+check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
+
+# Convert raid6_rs_6 to raid6_n_6
+_reshape_layout raid6_n_6 6 $vg $lv1
+
+# Convert raid6_n_6 -> striped
+_lvconvert striped striped 4 $vg $lv1
+check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
+
+# Convert striped -> raid10(_near)
+_lvconvert raid10 raid10 8 $vg $lv1
+
+# Convert raid10 to 10 stripes and 64K stripesize
+# FIXME: change once we support odd numbers of raid10 stripes
+not _reshape_layout raid10 9 $vg $lv1 --stripes 9 --stripesize 64K
+_reshape_layout raid10 10 $vg $lv1 --stripes 10 --stripesize 64K
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+
+# Convert raid6_n_6 -> striped
+_lvconvert striped striped 5 $vg $lv1
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+
+vgremove -ff $vg


