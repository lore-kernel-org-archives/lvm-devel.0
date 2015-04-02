From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:20 +0000 (UTC)
Subject: master - tests: deal with kernel and broken lcm
Message-ID: <20150402114120.BCE816023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=536f5fa0a310fe863340768ea1a8b062b63e02ef
Commit:        536f5fa0a310fe863340768ea1a8b062b63e02ef
Parent:        7a6e3838e961fe072bbaafe9f8b073b1c1b0c242
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 12:22:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: deal with kernel and broken  lcm

If the kernel has 'new lcm()' (3.19) it provides wrong
optimal_io_size value for dm device so lvm2 command cannot
create properly aligned devices.

Use 'should' for this case - so test ends with 'TEST WARNING'.
---
 test/shell/profiles-thin.sh    |   12 ++++++++++--
 test/shell/topology-support.sh |   35 ++++++++++++++---------------------
 2 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 3519985..e8110d9 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -24,7 +24,15 @@ aux prepare_profiles "thin-performance"
 
 # Create scsi debug dev with sector size of 4096B and 1MiB optimal_io_size
 aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256 || skip
+EXPECT=1048576
+check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" optimal_io_size "$EXPECT"
 aux prepare_pvs 1 $DEV_SIZE
+
+# Check we are not running on buggy kernel (broken lcm())
+# If so, turn chunk_size test into  'should'
+MINOR=$(stat -c %T "$dev1")
+check sysfs_queue "dm-$MINOR" optimal_io_size "$EXPECT" || SHOULD=should
+
 vgcreate $vg "$dev1"
 
 # By default, "generic" policy is used to
@@ -43,7 +51,7 @@ check lv_field $vg/pool_generic zero "zero"
 # under "thin-perforance" profile.
 lvcreate --profile thin-performance -L8m -T $vg/pool_performance
 check lv_field $vg/pool_performance profile "thin-performance"
-check lv_field $vg/pool_performance chunk_size 1.00m
+$SHOULD check lv_field $vg/pool_performance chunk_size 1.00m
 check lv_field $vg/pool_performance zero ""
 
 vgremove -ff $vg
@@ -55,5 +63,5 @@ lvcreate -L8m -T $vg/pool_performance_inherited
 # ...the LV does not have the profile attached, but VG does!
 check vg_field $vg profile "thin-performance"
 check lv_field $vg/pool_performance_inherited profile ""
-check lv_field $vg/pool_performance_inherited chunk_size 1.00m
+$SHOULD check lv_field $vg/pool_performance_inherited chunk_size 1.00m
 check lv_field $vg/pool_performance_inherited zero ""
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index caebb3d..2e63da8 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,20 +13,6 @@
 
 which mkfs.ext3 || skip
 
-check_logical_block_size() {
-    # Verify logical_block_size - requires Linux >= 2.6.31
-    SYSFS_LOGICAL_BLOCK_SIZE="/sys/block/$(basename $(< SCSI_DEBUG_DEV))/queue/logical_block_size"
-    test -f "$SYSFS_LOGICAL_BLOCK_SIZE" || return 0
-    test "$(< $SYSFS_LOGICAL_BLOCK_SIZE)" -eq "$1" # ACTUAL_LOGICAL_BLOCK_SIZE
-}
-
-check_optimal_io_size() {
-    # Verify optimal_io_size
-    SYSFS_OPTIMAL_IO_SIZE="/sys/block/$(basename $(< SCSI_DEBUG_DEV))/queue/optimal_io_size"
-    test -f "$SYSFS_OPTIMAL_IO_SIZE" || return 0
-    test "$(< $SYSFS_OPTIMAL_IO_SIZE)" -eq "$1" # ACTUAL_OPTIMAL_IO_SIZE
-}
-
 lvdev_() {
     echo "$DM_DEV_DIR/$1/$2"
 }
@@ -70,7 +56,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
-check_logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs
@@ -87,7 +73,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
-check_logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -102,7 +88,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=4096
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE
-check_logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -118,10 +104,17 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE opt_blks=1536
-check_logical_block_size $LOGICAL_BLOCK_SIZE
-check_optimal_io_size 786432
+
+TDEV="$(basename $(< SCSI_DEBUG_DEV))"
+check sysfs_queue "$TDEV" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$TDEV" optimal_io_size 786432
 
 aux prepare_pvs 1 $PER_DEV_SIZE
-check pv_field "${DEVICES[@]}" pe_start 768.00k
+
+# Kernel (3.19) could provide wrong results - in this case skip
+# test with incorrect result - lvm2 can't figure out good values.
+MINOR=$(stat -c %T "$dev1")
+check sysfs_queue "dm-$MINOR" optimal_io_size 786432 || SHOULD=should
+$SHOULD check pv_field "${DEVICES[@]}" pe_start 768.00k
 
 aux cleanup_scsi_debug_dev


