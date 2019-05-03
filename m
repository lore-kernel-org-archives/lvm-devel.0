From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 May 2019 15:39:58 -0400
Subject: master - tests: expand lvm-on-md
Message-ID: <201905031939.x43JdwDm006028@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ff1583c1ba58d045fb5c8a198698e0d13f1acee
Commit:        6ff1583c1ba58d045fb5c8a198698e0d13f1acee
Parent:        1e9e21a171db49b75e1c7276b05ef2959a340c4e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 3 14:05:40 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 3 14:39:42 2019 -0500

tests: expand lvm-on-md

test both md raid0 and raid1
---
 test/shell/lvm-on-md.sh |  151 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 136 insertions(+), 15 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 4f4a0c4..4c66431 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -12,12 +12,30 @@
 
 SKIP_WITH_LVMPOLLD=1
 
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+}
+
 . lib/inittest
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
+
+# This stops lvm from asking udev if a dev is an md component.
+# LVM will ask udev if a dev is an md component, but we don't
+# want to rely on that ability in this test.
+aux lvmconf 'devices/obtain_device_list_from_udev = 0'
+
 aux extend_filter_LVMTEST "a|/dev/md|"
 
 aux prepare_devs 2
@@ -26,31 +44,31 @@ aux prepare_devs 2
 # by default using metadata format 1.0 with data at the end of device
 aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
 
+cat /proc/mdstat
+
 mddev=$(< MD_DEV)
 pvdev=$(< MD_DEV_PV)
 
 vgcreate $vg "$mddev"
 
-lvs $vg
-
 lvcreate -n $lv1 -l 2 $vg
 lvcreate -n $lv2 -l 2 -an $vg
 
 lvchange -ay $vg/$lv2
+check lv_field $vg/$lv1 lv_active "active"
 
-lvs $vg
-
-pvs -vvvv 2>&1|tee pvs.out
-
-vgchange -an $vg
-
-vgchange -ay -vvvv $vg 2>&1| tee vgchange.out
-
-lvs $vg
-pvs
+# lvm does not show md components as PVs
+pvs "$mddev"
+not pvs "$dev1"
+not pvs "$dev2"
+sleep 1
 
 vgchange -an $vg
+sleep 1
 
+# When the md device is started, lvm will see that and know to
+# scan for md components, so stop the md device to remove this
+# advantage so we will test the fallback detection.
 mdadm --stop "$mddev"
 aux udev_wait
 
@@ -61,14 +79,114 @@ pvs 2>&1 |tee out
 cat out
 grep "prefers device" out
 
-pvs -vvvv 2>&1| tee pvs2.out
+# should not activate from the md legs
+not vgchange -ay $vg
+
+# should not show an active lv
+rm out
+lvs -o active $vg |tee out || true
+not grep "active" out
+
+# should not allow updating vg
+not lvcreate -l1 $vg
 
 # should not activate from the md legs
-not vgchange -ay -vvvv $vg 2>&1|tee vgchange-fail.out
+_clear_online_files
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
 
 # should not show an active lv
+rm out
+lvs -o active $vg |tee out || true
+not grep "active" out
+
+# start the md dev
+mdadm --assemble "$mddev" "$dev1" "$dev2"
+aux udev_wait
+
+# Now that the md dev is online, pvs can see it and
+# ignore the two legs, so there's no duplicate warning
+
+pvs 2>&1 |tee out
+cat out
+not grep "prefers device" out
+
+vgchange -ay $vg 2>&1 |tee out
+cat out
+not grep "prefers device" out
+
+check lv_field $vg/$lv1 lv_active "active"
+
+vgchange -an $vg
+aux udev_wait
+
+vgremove -f $vg
+
+aux cleanup_md_dev
+
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+
+
+# create 2 disk MD raid0 array
+# by default using metadata format 1.0 with data at the end of device
+# When a raid0 md array is stopped, the components will not look like
+# duplicate PVs as they do with raid1.
+aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
+
+cat /proc/mdstat
+
+mddev=$(< MD_DEV)
+pvdev=$(< MD_DEV_PV)
+
+vgcreate $vg "$mddev"
+
 lvs $vg
 
+lvcreate -n $lv1 -l 2 $vg
+lvcreate -n $lv2 -l 2 -an $vg
+
+lvchange -ay $vg/$lv2
+check lv_field $vg/$lv1 lv_active "active"
+
+# lvm does not show md components as PVs
+pvs "$mddev"
+not pvs "$dev1"
+not pvs "$dev2"
+sleep 1
+
+vgchange -an $vg
+sleep 1
+
+# When the md device is started, lvm will see that and know to
+# scan for md components, so stop the md device to remove this
+# advantage so we will test the fallback detection.
+mdadm --stop "$mddev"
+aux udev_wait
+
+pvs 2>&1 |tee pvs.out
+
+# should not activate from the md legs
+not vgchange -ay $vg
+
+# should not show an active lv
+rm out
+lvs -o active $vg |tee out || true
+not grep "active" out
+
+# should not allow updating vg
+not lvcreate -l1 $vg
+
+# should not activate from the md legs
+_clear_online_files
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
+
+# should not show an active lv
+rm out
+lvs -o active $vg |tee out || true
+not grep "active" out
+
 # start the md dev
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
@@ -84,9 +202,12 @@ vgchange -ay $vg 2>&1 |tee out
 cat out
 not grep "prefers device" out
 
+check lv_field $vg/$lv1 lv_active "active"
+
 vgchange -an $vg
 aux udev_wait
 
+vgremove -f $vg
+
 aux cleanup_md_dev
 
-# vgremove -f $vg


