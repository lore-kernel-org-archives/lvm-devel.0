From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:18 -0500
Subject: master - tests: reduce memory footprint
Message-ID: <201811292213.wATMDIkX016698@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e940293c336b22e018aac96217e5e67b2397dde6
Commit:        e940293c336b22e018aac96217e5e67b2397dde6
Parent:        7da75f41edf15242f582d200e4e18379dc529db0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 27 12:15:52 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:09 2018 +0100

tests: reduce memory footprint

---
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |   30 ++++++++++++--------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index f317b7e..61afa88 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -17,9 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
-# FIXME: This test requires 3GB in /dev/shm!
-test $(aux total_mem) -gt $((4096*1024)) || skip
-
+which md5sum || skip
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -31,6 +29,11 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
+checksum_()
+{
+	md5sum "$1" | cut -f1 -d' '
+}
+
 aux prepare_pvs 16 32
 
 get_devs
@@ -40,23 +43,20 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 trap 'cleanup_mounted_and_teardown' EXIT
 
 # Create 10-way striped raid5 (11 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L64M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
 echo y|mkfs -t ext4 /dev/$vg/$lv1
 
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
+dd if=/dev/urandom of="$mount_dir/random" bs=1M count=50 conv=fdatasync
+checksum_ "$mount_dir/random" >MD5
 
 # FIXME: wait_for_sync - is this really testing anything under load?
 aux wait_for_sync $vg $lv1
@@ -80,11 +80,17 @@ done
 
 aux delay_dev "$dev2" 0
 
-kill -9 %%
+kill -9 %% || true
 wait
 
+checksum_ "$mount_dir/random" >MD5_new
+
 umount $mount_dir
 
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
+# Compare checksum is matching
+cat MD5 MD5_new
+diff MD5 MD5_new
+
 vgremove -ff $vg


