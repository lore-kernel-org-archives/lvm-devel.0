From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:51 +0000 (GMT)
Subject: main - tests: add missing quotes
Message-ID: <20230223154851.35E8F3858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d11e12264fcbca9af84a954fff773b720e471eb6
Commit:        d11e12264fcbca9af84a954fff773b720e471eb6
Parent:        f5acdc2d79d7bf662f85694ec3d89db65d5f3701
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 15:55:04 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

tests: add missing quotes

Add quotes around paths and also add fixme for checking
system is actually usable for a test with all running
services.
---
 test/shell/udev-pvscan-vgchange.sh | 74 ++++++++++++++++++++------------------
 1 file changed, 40 insertions(+), 34 deletions(-)

diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index 0d43e1bf3..14dbe82ba 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+# FIXME: currently test relies on several system properties to be
+# explcitely configure and directly modifies their state
+
 #
 # $ cat /tmp/devs
 # /dev/sdb
@@ -29,11 +32,15 @@ SKIP_WITH_LVMLOCKD=1
 # This test will wipe these devices.
 #
 
-if [ -z ${LVM_TEST_DEVICE_LIST+x} ]; then echo "LVM_TEST_DEVICE_LIST is unset" && skip; else echo "LVM_TEST_DEVICE_LIST is set to '$LVM_TEST_DEVICE_LIST'"; fi
+if [ -z ${LVM_TEST_DEVICE_LIST+x} ]; then
+	skip "LVM_TEST_DEVICE_LIST is unset"
+else
+	echo "LVM_TEST_DEVICE_LIST is set to '$LVM_TEST_DEVICE_LIST'"
+fi
 
 test -e "$LVM_TEST_DEVICE_LIST" || skip
 
-num_devs=$(cat $LVM_TEST_DEVICE_LIST | wc -l)
+num_devs=$(cat "$LVM_TEST_DEVICE_LIST" | wc -l)
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
@@ -60,14 +67,14 @@ aux lvmconf 'devices/dir = "/dev"'
 aux lvmconf 'devices/use_devicesfile = 1'
 DFDIR="$LVM_SYSTEM_DIR/devices"
 DF="$DFDIR/system.devices"
-mkdir $DFDIR || true
-not ls $DF
+mkdir "$DFDIR" || true
+not ls "$DF"
 
 get_real_devs
 
 wipe_all() {
 	for dev in "${REAL_DEVICES[@]}"; do
-		wipefs -a $dev
+		wipefs -a "$dev"
 	done
 }
 
@@ -82,13 +89,13 @@ wait_lvm_activate() {
 }
 
 # Test requires 3 devs
-test $num_devs -gt 2 || skip
+test "$num_devs" -gt 2 || skip
 BDEV1=$(basename "$dev1")
 BDEV2=$(basename "$dev2")
 BDEV3=$(basename "$dev3")
 
 wipe_all
-touch $DF
+touch "$DF"
 for dev in "${REAL_DEVICES[@]}"; do
 	pvcreate $dev
 done
@@ -101,12 +108,12 @@ lvcreate -l1 -an -n $lv1 $vg1 "$dev1"
 PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
 
 _clear_online_files
-udevadm trigger --settle -c add /sys/block/$BDEV1
+udevadm trigger --settle -c add "/sys/block/$BDEV1"
 
 wait_lvm_activate $vg1
 
-ls "$RUNDIR/lvm/pvs_online/$PVID1"
-ls "$RUNDIR/lvm/vgs_online/$vg1"
+ls "$RUNDIR/lvm/pvs_online/$PVID1" || true
+ls "$RUNDIR/lvm/vgs_online/$vg1" || true
 journalctl -u lvm-activate-$vg1 | tee out || true
 grep "now active" out
 check lv_field $vg1/$lv1 lv_active "active"
@@ -126,7 +133,7 @@ PVID2=$(pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}')
 
 _clear_online_files
 
-udevadm trigger --settle -c add /sys/block/$BDEV1
+udevadm trigger --settle -c add "/sys/block/$BDEV1"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 not ls "$RUNDIR/lvm/vgs_online/$vg2"
 journalctl -u lvm-activate-$vg2 | tee out || true
@@ -134,7 +141,7 @@ not grep "now active" out
 check lv_field $vg2/$lv1 lv_active ""
 check lv_field $vg2/$lv2 lv_active ""
 
-udevadm trigger --settle -c add /sys/block/$BDEV2
+udevadm trigger --settle -c add "/sys/block/$BDEV2"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 ls "$RUNDIR/lvm/vgs_online/$vg2"
 
@@ -165,9 +172,9 @@ PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
 
 _clear_online_files
 
-udevadm trigger -c add /sys/block/$BDEV1 &
-udevadm trigger -c add /sys/block/$BDEV2 &
-udevadm trigger -c add /sys/block/$BDEV3
+udevadm trigger -c add "/sys/block/$BDEV1" &
+udevadm trigger -c add "/sys/block/$BDEV2" &
+udevadm trigger -c add "/sys/block/$BDEV3"
 
 aux udev_wait
 wait_lvm_activate $vg3
@@ -208,9 +215,9 @@ PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
 
 _clear_online_files
 
-udevadm trigger -c add /sys/block/$BDEV1 &
-udevadm trigger -c add /sys/block/$BDEV2 &
-udevadm trigger -c add /sys/block/$BDEV3
+udevadm trigger -c add "/sys/block/$BDEV1" &
+udevadm trigger -c add "/sys/block/$BDEV2" &
+udevadm trigger -c add "/sys/block/$BDEV3"
 
 aux udev_wait
 wait_lvm_activate $vg4
@@ -235,8 +242,8 @@ vgremove -y $vg4
 # 3 devs, 3 vgs, 2 lvs in each vg, concurrent pvscans
 
 wipe_all
-rm $DF
-touch $DF
+rm "$DF"
+touch "$DF"
 
 vgcreate $vg5 "$dev1"
 vgcreate $vg6 "$dev2"
@@ -250,9 +257,9 @@ lvcreate -l1 -an -n $lv2 $vg7
 
 _clear_online_files
 
-udevadm trigger -c add /sys/block/$BDEV1 &
-udevadm trigger -c add /sys/block/$BDEV2 &
-udevadm trigger -c add /sys/block/$BDEV3
+udevadm trigger -c add "/sys/block/$BDEV1" &
+udevadm trigger -c add "/sys/block/$BDEV2" &
+udevadm trigger -c add "/sys/block/$BDEV3"
 
 aux udev_wait
 wait_lvm_activate $vg5
@@ -285,8 +292,8 @@ vgremove -y $vg7
 # 3 devs, 1 vg, 1000 LVs
 
 wipe_all
-rm $DF
-touch $DF
+rm "$DF"
+touch "$DF"
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate "$dev2"
 pvcreate "$dev3"
@@ -325,9 +332,9 @@ vgcfgrestore -f data_new $vg8
 
 _clear_online_files
 
-udevadm trigger -c add /sys/block/$BDEV1 &
-udevadm trigger -c add /sys/block/$BDEV2 &
-udevadm trigger -c add /sys/block/$BDEV3
+udevadm trigger -c add "/sys/block/$BDEV1" &
+udevadm trigger -c add "/sys/block/$BDEV2" &
+udevadm trigger -c add "/sys/block/$BDEV3"
 
 aux udev_wait
 wait_lvm_activate $vg8
@@ -338,7 +345,7 @@ grep "now active" out
 
 num_active=$(lvs $vg8 --noheading -o active | grep -c active)
 
-test $num_active -eq $TEST_DEVS
+test "$num_active" -eq "$TEST_DEVS"
 
 vgchange -an $vg8
 vgremove -y $vg8
@@ -364,8 +371,8 @@ test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
        modprobe raid1 || skip
 
 wipe_all
-rm $DF
-touch $DF
+rm "$DF"
+touch "$DF"
 
 aux mdadm_create --metadata=1.0 --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 mddev=$(< MD_DEV)
@@ -420,10 +427,10 @@ PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
 # PVID with dashes
 OPVID1=$(pvs "$dev1" --noheading -o uuid | awk '{print $1}')
 
-udevadm trigger --settle -c add /sys/block/$BDEV1
+udevadm trigger --settle -c add "/sys/block/$BDEV1"
 
 # uevent from the trigger should create this symlink
-ls /dev/disk/by-id/lvm-pv-uuid-$OPVID1
+ls "/dev/disk/by-id/lvm-pv-uuid-$OPVID1"
 
 vgchange -an $vg10
 _clear_online_files
@@ -448,4 +455,3 @@ check lv_field $vg10/$lv1 lv_active "active"
 vgchange -an $vg10
 vgremove -y $vg10
 wipe_all
-

