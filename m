From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 13 Dec 2017 08:42:17 -0500
Subject: master - test: fix trap adding proper teardown to previous, new raid tests
Message-ID: <201712131342.vBDDgHkZ000487@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=584ff361dff9dc27a05839ac179899a80007b56e
Commit:        584ff361dff9dc27a05839ac179899a80007b56e
Parent:        86fa0333fffe89547263f8b46b291d19726e7cca
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Dec 13 14:39:06 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Dec 13 14:41:23 2017 +0100

test: fix trap adding proper teardown to previous, new raid tests

Also remove superfluous variable.
---
 test/shell/lvconvert-raid-reshape-load.sh          |   25 ++++++++++--------
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |   27 +++++++++++---------
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |   25 ++++++++++--------
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |   25 ++++++++++--------
 4 files changed, 57 insertions(+), 45 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 55e2ad4..d17b186 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -13,8 +13,6 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-LVM_SKIP_LARGE_TESTS=1
-
 . lib/inittest
 
 # Test reshaping under io load
@@ -22,9 +20,13 @@ LVM_SKIP_LARGE_TESTS=1
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 
-mpoint=/tmp/mpoint.$$
+mount_dir="mnt"
 
-trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	aux teardown
+}
 
 aux prepare_pvs 16 32
 
@@ -32,6 +34,8 @@ get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
+trap 'cleanup_mounted_and_teardown' EXIT
+
 # Create 13-way striped raid5 (14 legs total)
 lvcreate --yes --type raid5_ls --stripes 13 -L190M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
@@ -40,15 +44,15 @@ check lv_first_seg_field $vg/$lv1 stripes 14
 echo y|mkfs -t ext4 /dev/$vg/$lv1
 aux wait_for_sync $vg $lv1
 
-mkdir -p $mpoint
-mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
-mkdir -p $mpoint/1 $mpoint/2
+mkdir -p $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mkdir -p $mount_dir/1 $mount_dir/2
 
 aux delay_dev "$dev2" 0 100
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
 sync &
 
 # Reshape it to 256K stripe size
@@ -59,8 +63,7 @@ check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
 kill -9 %%
 wait
 
-umount $mpoint
-[ -d $mpoint ] && rmdir $mpoint
+umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 96bea52..38af778 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -13,8 +13,6 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-LVM_SKIP_LARGE_TESTS=1
-
 . lib/inittest
 
 # Test reshaping under io load
@@ -22,9 +20,13 @@ LVM_SKIP_LARGE_TESTS=1
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 
-mpoint=/tmp/mpoint.$$
+mount_dir="mnt"
 
-trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	aux teardown
+}
 
 aux prepare_pvs 16 32
 
@@ -32,6 +34,8 @@ get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
+trap 'cleanup_mounted_and_teardown' EXIT
+
 # Create 13-way striped raid5 (14 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
@@ -40,14 +44,14 @@ check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
 echo y|mkfs -t ext4 /dev/$vg/$lv1
 
-mkdir -p $mpoint
-mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
-mkdir -p $mpoint/1 $mpoint/2
+mkdir -p $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mkdir -p $mount_dir/1 $mount_dir/2
 
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
 sync &
 
 aux wait_for_sync $vg $lv1
@@ -62,13 +66,12 @@ check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 15
 check lv_first_seg_field $vg/$lv1 stripes 16
 
-rm -fr $mpoint/2
+rm -fr $mount_dir/2
 sync
 kill -9 %%
 wait
 
-umount $mpoint
-[ -d $mpoint ] && rmdir $mpoint
+umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 9ca3ded..f0a71c3 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -13,8 +13,6 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-LVM_SKIP_LARGE_TESTS=1
-
 . lib/inittest
 
 # Test reshaping under io load
@@ -22,9 +20,13 @@ LVM_SKIP_LARGE_TESTS=1
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
-mpoint=/tmp/mpoint.$$
+mount_dir="mnt"
 
-trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	aux teardown
+}
 
 aux prepare_pvs 16 32
 
@@ -32,6 +34,8 @@ get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
+trap 'cleanup_mounted_and_teardown' EXIT
+
 # Create 13-way striped raid5 (14 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
@@ -40,13 +44,13 @@ check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
 echo y|mkfs -t ext4 /dev/$vg/$lv1
 
-mkdir -p $mpoint
-mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
-mkdir -p $mpoint/1 $mpoint/2
+mkdir -p $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mkdir -p $mount_dir/1 $mount_dir/2
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
 sync &
 
 aux wait_for_sync $vg $lv1
@@ -73,8 +77,7 @@ aux delay_dev "$dev2" 0
 kill -9 %%
 wait
 
-umount $mpoint
-[ -d $mpoint ] && rmdir $mpoint
+umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 53bba2e..785ee76 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -13,8 +13,6 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-LVM_SKIP_LARGE_TESTS=1
-
 . lib/inittest
 
 # Test reshaping under io load
@@ -22,9 +20,13 @@ LVM_SKIP_LARGE_TESTS=1
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 
-mpoint=/tmp/mpoint.$$
+mount_dir="mnt"
 
-trap "[ -d $mpoint ] && rmdir $mpoint" 1 2 3 15
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	aux teardown
+}
 
 aux prepare_pvs 16 32
 
@@ -32,6 +34,8 @@ get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
+trap 'cleanup_mounted_and_teardown' EXIT
+
 # Create 13-way striped raid5 (14 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
@@ -40,14 +44,14 @@ check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
 echo y|mkfs -t ext4 /dev/$vg/$lv1
 
-mkdir -p $mpoint
-mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
-mkdir -p $mpoint/1 $mpoint/2
+mkdir -p $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mkdir -p $mount_dir/1 $mount_dir/2
 
 
 echo 3 >/proc/sys/vm/drop_caches
-cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
-cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
 sync &
 
 aux wait_for_sync $vg $lv1
@@ -64,8 +68,7 @@ check lv_first_seg_field $vg/$lv1 stripes 16
 kill -9 %%
 wait
 
-umount $mpoint
-[ -d $mpoint ] && rmdir $mpoint
+umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 


