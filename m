From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 13 Dec 2017 07:31:23 -0500
Subject: master - test: new raid tests
Message-ID: <201712131231.vBDCVNd3021070@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86fa0333fffe89547263f8b46b291d19726e7cca
Commit:        86fa0333fffe89547263f8b46b291d19726e7cca
Parent:        3edc25dbdfc5d8d5ba109921dae87c5415a0b460
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Dec 13 02:55:06 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Dec 13 13:30:53 2017 +0100

test: new raid tests

Add three new raid tests with io load and table
reloads during reshape for target 1.13.2.

Add a raid0 to raid10 conversion test.

Also add more signals to trap in lvconvert-raid-reshape-load.sh.
---
 test/shell/lvconvert-raid-reshape-load.sh          |    2 +-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |   75 ++++++++++++++++++
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |   81 ++++++++++++++++++++
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |   72 +++++++++++++++++
 test/shell/lvconvert-raid0_to_raid10.sh            |   32 ++++++++
 5 files changed, 261 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 4ccf01f..55e2ad4 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -24,7 +24,7 @@ aux have_raid 1 13 1 || skip
 
 mpoint=/tmp/mpoint.$$
 
-trap "[ -d $mpoint ] && rmdir $mpoint" 15
+trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
 
 aux prepare_pvs 16 32
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
new file mode 100644
index 0000000..96bea52
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -0,0 +1,75 @@
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
+LVM_SKIP_LARGE_TESTS=1
+
+. lib/inittest
+
+# Test reshaping under io load
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 1 || skip
+
+mpoint=/tmp/mpoint.$$
+
+trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+
+aux prepare_pvs 16 32
+
+get_devs
+
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
+
+# Create 13-way striped raid5 (14 legs total)
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 10
+check lv_first_seg_field $vg/$lv1 stripes 11
+echo y|mkfs -t ext4 /dev/$vg/$lv1
+
+mkdir -p $mpoint
+mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
+mkdir -p $mpoint/1 $mpoint/2
+
+
+echo 3 >/proc/sys/vm/drop_caches
+cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+sync &
+
+aux wait_for_sync $vg $lv1
+aux delay_dev "$dev2" 0 100
+
+# Reshape it to 15 data stripes
+lvconvert --yes --stripes 15 $vg/$lv1
+aux disable_dev $dev1
+aux delay_dev "$dev2" 0 0
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 15
+check lv_first_seg_field $vg/$lv1 stripes 16
+
+rm -fr $mpoint/2
+sync
+kill -9 %%
+wait
+
+umount $mpoint
+[ -d $mpoint ] && rmdir $mpoint
+
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
new file mode 100644
index 0000000..9ca3ded
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -0,0 +1,81 @@
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
+LVM_SKIP_LARGE_TESTS=1
+
+. lib/inittest
+
+# Test reshaping under io load
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 2 || skip
+
+mpoint=/tmp/mpoint.$$
+
+trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+
+aux prepare_pvs 16 32
+
+get_devs
+
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
+
+# Create 13-way striped raid5 (14 legs total)
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 10
+check lv_first_seg_field $vg/$lv1 stripes 11
+echo y|mkfs -t ext4 /dev/$vg/$lv1
+
+mkdir -p $mpoint
+mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
+mkdir -p $mpoint/1 $mpoint/2
+
+echo 3 >/proc/sys/vm/drop_caches
+cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+sync &
+
+aux wait_for_sync $vg $lv1
+aux delay_dev "$dev2" 0 200
+
+# Reshape it to 15 data stripes
+lvconvert --yes --stripes 15 $vg/$lv1
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 15
+check lv_first_seg_field $vg/$lv1 stripes 16
+
+# Reload table during reshape to test for data corruption
+for i in {0..5}
+do
+	dmsetup table $vg-$lv1|dmsetup load $vg-$lv1
+	dmsetup suspend --noflush $vg-$lv1
+	dmsetup resume $vg-$lv1
+	sleep 0.3
+done
+
+aux delay_dev "$dev2" 0
+
+kill -9 %%
+wait
+
+umount $mpoint
+[ -d $mpoint ] && rmdir $mpoint
+
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
new file mode 100644
index 0000000..53bba2e
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -0,0 +1,72 @@
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
+LVM_SKIP_LARGE_TESTS=1
+
+. lib/inittest
+
+# Test reshaping under io load
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 1 || skip
+
+mpoint=/tmp/mpoint.$$
+
+trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+
+aux prepare_pvs 16 32
+
+get_devs
+
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
+
+# Create 13-way striped raid5 (14 legs total)
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 10
+check lv_first_seg_field $vg/$lv1 stripes 11
+echo y|mkfs -t ext4 /dev/$vg/$lv1
+
+mkdir -p $mpoint
+mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
+mkdir -p $mpoint/1 $mpoint/2
+
+
+echo 3 >/proc/sys/vm/drop_caches
+cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+sync &
+
+aux wait_for_sync $vg $lv1
+aux delay_dev "$dev2" 0 100
+
+# Reshape it to 15 data stripes
+lvconvert --yes --stripes 15 $vg/$lv1
+aux delay_dev "$dev2" 0 0
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 data_stripes 15
+check lv_first_seg_field $vg/$lv1 stripes 16
+
+kill -9 %%
+wait
+
+umount $mpoint
+[ -d $mpoint ] && rmdir $mpoint
+
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid0_to_raid10.sh b/test/shell/lvconvert-raid0_to_raid10.sh
new file mode 100644
index 0000000..d1e1fa0
--- /dev/null
+++ b/test/shell/lvconvert-raid0_to_raid10.sh
@@ -0,0 +1,32 @@
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
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# rhbz1514500
+
+aux have_raid 1 12 0 || skip
+
+# 8 PVs needed for RAID10 testing (4-stripes/2-mirror)
+aux prepare_pvs 8 64
+get_devs
+vgcreate -s 256k "$vg" "${DEVICES[@]}"
+
+lvcreate -y --ty raid0 -R32.00k -i 4 -n $lv1 -L 64M $vg
+lvcreate -y -i4 -l4 -n $lv2 $vg
+lvextend -y -l +4 $vg/$lv1
+lvconvert -y -R512K --ty raid10 $vg/$lv1
+
+vgremove -ff $vg


