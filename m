From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:42:06 +0000 (UTC)
Subject: master - tests: using mkfs config file
Message-ID: <20160704154206.293B060E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5d1f3d6c5433e8b118e572a507f121c45729715
Commit:        e5d1f3d6c5433e8b118e572a507f121c45729715
Parent:        2063d6bb0640c54d0356dff3618a1239357a55ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 17:39:17 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:41:10 2016 +0200

tests: using  mkfs config file

Use more predictable local config when creating ext4.
---
 test/shell/thin-autoumount-dmeventd.sh |   34 +++++++++++++++++++++----------
 test/shell/thin-foreign-dmeventd.sh    |   10 ++++++--
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index dd0884e..3729e18 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -16,6 +16,17 @@ SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
+mntdir="${PREFIX}mnt with space"
+mntusedir="${PREFIX}mntuse"
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mntdir" 2>/dev/null || true
+	umount "$mntusedir" 2>/dev/null || true
+	vgremove -ff $vg
+	aux teardown
+}
+
 is_lv_opened_()
 {
 	test $(get lv_field "$1" lv_device_open --binary) = "1"
@@ -26,7 +37,8 @@ is_lv_opened_()
 #
 # Main
 #
-which mkfs.ext2 || skip
+which mkfs.ext4 || skip
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux have_thin 1 0 0 || skip
 
@@ -38,18 +50,17 @@ aux lvmconf "activation/thin_pool_autoextend_percent = 0" \
 
 aux prepare_vg 2
 
-mntdir="${PREFIX}mnt with space"
-mntusedir="${PREFIX}mntuse"
 
 lvcreate -L8M -V8M -n $lv1 -T $vg/pool
 lvcreate -V8M -n $lv2 -T $vg/pool
 
-mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
-mkfs.ext2 "$DM_DEV_DIR/$vg/$lv2"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv2"
 
 lvchange --monitor y $vg/pool
 
 mkdir "$mntdir" "$mntusedir"
+trap 'cleanup_mounted_and_teardown' EXIT
 mount "$DM_DEV_DIR/mapper/$vg-$lv1" "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-$lv2" "$mntusedir"
 
@@ -64,8 +75,10 @@ sync
 sleep 60 < "$mntusedir/file$$" &
 PID_SLEEP=$!
 
-# Fill pool above 70%
-dd if=/dev/zero of="$mntdir/file$$" bs=1M count=6 conv=fdatasync
+lvs -a $vg
+# Fill pool above 95%  (to cause 'forced lazy umount)
+dd if=/dev/zero of="$mntdir/file$$" bs=256K count=20 conv=fdatasync
+sync
 lvs -a $vg
 
 # Could loop here for a few secs so dmeventd can do some work
@@ -77,6 +90,8 @@ for i in $(seq 1 12) ; do
 	sleep 1
 done
 
+lvs -a $vg
+
 is_lv_opened_ "$vg/$lv2" || \
 	die "$mntusedir is not mounted here (sleep already expired??)"
 
@@ -84,10 +99,7 @@ is_lv_opened_ "$vg/$lv2" || \
 kill $PID_SLEEP
 wait
 
-is_lv_opened_ "$vg/$lv2" && {
+not is_lv_opened_ "$vg/$lv2" || {
 	mount
 	die "$mntusedir should have been unmounted by dmeventd!"
 }
-
-vgremove -f $vg
-
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index a96b206..5d7488e 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -37,13 +37,17 @@ percent_() {
 aux have_thin 1 0 0 || skip
 which mkfs.ext4 || skip
 
+# Use our mkfs config file to get approximately same results
+# TODO: maybe use it for all test via some 'prepare' function
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+
 aux prepare_dmeventd
 aux prepare_pvs 2 64
 
 vgcreate $vg -s 64K $(cat DEVICES)
 
 # Create named pool only
-lvcreate --errorwhenfull y -L2100K -T $vg/pool
+lvcreate --errorwhenfull y -L2 -T $vg/pool
 
 POOL="$vg-pool"
 THIN="${PREFIX}_thin"
@@ -65,7 +69,7 @@ dmsetup table
 dmsetup info -c
 
 mkdir "$MOUNT_DIR"
-# This mkfs fills 2.2MB pool over 95%
+# This mkfs should fill 2MB pool over 95%
 # no autoresize is configured
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
 test $(percent_) -gt 95
@@ -78,7 +82,7 @@ test $(percent_) -gt 95
 aux lvmconf 'activation/thin_pool_autoextend_percent = 10' \
 	    'activation/thin_pool_autoextend_threshold = 75'
 
-# Give it some time to left dmeventd do some work
+# Give it some time to left dmeventd do some (failing to resize) work
 sleep 20
 
 # And check foreign thin device is still mounted


