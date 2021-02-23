From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 Feb 2021 22:48:51 +0000 (GMT)
Subject: main - tests: for devices file
Message-ID: <20210223224851.CA23F3899435@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b36b4b82d88181204f6cda5f0d613be77e8c1a43
Commit:        b36b4b82d88181204f6cda5f0d613be77e8c1a43
Parent:        135c226e26e966faf73f5257c17d45276e5a6b6c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 23 17:15:25 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 16:43:38 2021 -0600

tests: for devices file

---
 test/lib/aux.sh                    |  10 +
 test/shell/devicesfile-basic.sh    | 639 +++++++++++++++++++++++++++++++++++++
 test/shell/devicesfile-devname.sh  | 548 +++++++++++++++++++++++++++++++
 test/shell/devicesfile-realdevs.sh | 610 +++++++++++++++++++++++++++++++++++
 4 files changed, 1807 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 72837de22..c53d07b9e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -822,12 +822,16 @@ wipefs_a() {
 	local dev=$1
 	shift
 
+#	lvmdevices --deldev $dev || true
+
 	if wipefs -V >/dev/null; then
 		wipefs -a "$dev"
 	else
 		dd if=/dev/zero of="$dev" bs=4096 count=8 || true
 		mdadm --zero-superblock "$dev" || true
 	fi
+
+#	lvmdevices --adddev $dev || true
 }
 
 prepare_backing_dev() {
@@ -913,6 +917,12 @@ prepare_devs() {
 		wipefs -a "$d" 2>/dev/null || true
 	done
 
+#	mkdir -p $TESTDIR/etc/lvm/devices || true
+#	rm $TESTDIR/etc/lvm/devices/system.devices || true
+#	for d in "${DEVICES[@]}"; do
+#		lvmdevices --adddev $dev || true
+#	done
+
 	#for i in `seq 1 $n`; do
 	#	local name="${PREFIX}$pvname$i"
 	#	dmsetup info -c $name
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
new file mode 100644
index 000000000..352f75575
--- /dev/null
+++ b/test/shell/devicesfile-basic.sh
@@ -0,0 +1,639 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='devices file'
+
+. lib/inittest
+
+aux prepare_devs 7
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_LOOKUP_DIR"/*
+}
+
+wipe_all() {
+	aux wipefs_a "$dev1"
+	aux wipefs_a "$dev2"
+	aux wipefs_a "$dev3"
+	aux wipefs_a "$dev4"
+	aux wipefs_a "$dev5"
+	aux wipefs_a "$dev6"
+	aux wipefs_a "$dev7"
+}
+
+# The tests run with system dir of "/etc" but lvm when running
+# normally has cmd->system_dir set to "/etc/lvm".
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir -p $DFDIR || true
+DF=$DFDIR/system.devices
+
+#
+# Test with use_devicesfile=0 (no devices file is being applied by default)
+#
+
+aux lvmconf 'devices/use_devicesfile = 0'
+
+wipe_all
+rm -f $DF
+pvcreate $dev1
+not ls $DF
+
+wipe_all
+rm -f $DF
+vgcreate $vg1 $dev1
+not ls $DF
+
+wipe_all
+rm -f $DF
+
+# create one VG in a non-system devices file
+vgcreate --devicesfile test.devices $vg1 $dev1
+vgextend --devicesfile test.devices $vg1 $dev2
+cat $DFDIR/test.devices
+grep $dev1 $DFDIR/test.devices
+grep $dev2 $DFDIR/test.devices
+not ls $DFDIR/system.devices
+
+# create two VGs outside the special devices file
+vgcreate $vg2 $dev3 $dev4
+vgcreate $vg3 $dev5 $dev6
+not grep $dev3 $DFDIR/test.devices
+not grep $dev5 $DFDIR/test.devices
+not ls $DFDIR/system.devices
+
+PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs $dev4 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID5=`pvs $dev5 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID6=`pvs $dev6 --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+lvcreate -l4 -an -i2 -n $lv1 $vg1
+lvcreate -l4 -an -i2 -n $lv2 $vg2
+lvcreate -l4 -an -i2 -n $lv3 $vg3
+
+cat $DFDIR/test.devices
+grep $PVID1 $DFDIR/test.devices
+grep $PVID2 $DFDIR/test.devices
+not grep $PVID3 $DFDIR/test.devices
+not grep $PVID4 $DFDIR/test.devices
+not grep $PVID5 $DFDIR/test.devices
+not grep $PVID6 $DFDIR/test.devices
+not ls $DFDIR/system.devices
+
+# verify devices file is working
+vgs --devicesfile test.devices $vg1
+not vgs --devicesfile test.devices $vg2
+
+# devicesfile and devices cannot be used together
+not vgs --devicesfile test.devices --devices $dev1,$dev1 $vg1
+
+# verify correct vgs are seen / not seen when devices are specified
+vgs --devices $dev1,$dev2 $vg1
+vgs --devices $dev3,$dev4 $vg2
+vgs --devices $dev5,$dev6 $vg3
+not vgs --devices $dev1,$dev2 $vg2
+not vgs --devices $dev1,$dev2 $vg3
+not vgs --devices $dev1,$dev2 $vg2
+not vgs --devices $dev5,$dev6 $vg2
+not vgs --devices $dev1,$dev2 $vg3
+not vgs --devices $dev3,$dev4 $vg3
+
+vgs --devices $dev1,$dev2 |tee out
+grep $vg1 out
+not grep $vg2 out
+not grep $vg3 out
+vgs --devices $dev3,$dev4 |tee out
+not grep $vg1 out
+grep $vg2 out
+not grep $vg3 out
+
+# verify correct pvs are seen / not seen when devices are specified
+pvs --devices $dev1,$dev2 $dev1 $dev2
+pvs --devices $dev3,$dev4 $dev3 $dev4
+pvs --devices $dev5,$dev6 $dev5 $dev6
+not pvs --devices $dev1,$dev2 $dev3 $dev4
+not pvs --devices $dev1,$dev2 $dev5 $dev6
+not pvs --devices $dev3,$dev4 $dev1 $dev2 $dev5 $dev6
+
+pvs --devices $dev1,$dev2 |tee out
+grep $dev1 out
+grep $dev2 out
+not grep $dev3 out
+not grep $dev4 out
+not grep $dev5 out
+not grep $dev6 out
+pvs --devices $dev3,$dev4 |tee out
+not grep $dev1 out
+not grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+not grep $dev5 out
+not grep $dev6 out
+
+# verify correct lvs are activated / not activated when devices are specified
+vgchange --devices $dev1,$dev2 -ay
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg2/$lv2 lv_active ""
+check lv_field $vg3/$lv3 lv_active ""
+vgchange --devices $dev1,$dev2 -an
+check lv_field $vg1/$lv1 lv_active ""
+
+vgchange --devices $dev3,$dev4 -ay
+check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg2/$lv2 lv_active "active"
+check lv_field $vg3/$lv3 lv_active ""
+vgchange --devices $dev3,$dev4 -an
+check lv_field $vg2/$lv2 lv_active ""
+
+# verify devices covering multiple vgs
+vgs --devices $dev1,$dev2,$dev3,$dev4 $vg1 $vg2 |tee out
+grep $vg1 out
+grep $vg2 out
+not grep $vg3 out
+vgs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 $vg1 $vg2 $vg3 |tee out
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+
+# verify vgs seen when incomplete devices are specified
+vgs --devices $dev1 $vg1
+vgs --devices $dev3 $vg2
+vgs --devices $dev5 $vg3
+
+# incomplete vg because of --devices is the same as vg incomplete because
+# of missing device
+not lvcreate --devices $dev1 -l1 $vg1
+not lvchange --devices $dev1 -ay $vg1/$lv1
+not lvextend --devices $dev1 -l+1 $vg1/$lv1
+not vgremove --devices $dev1 $vg1
+not lvcreate --devices $dev3 -l1 $vg2
+not lvchange --devices $dev3 -ay $vg2/$lv2
+not lvextend --devices $dev3 -l+1 $vg2/$lv2
+not vgremove --devices $dev3 $vg2
+
+# verify various commands with --devices for vg in a devicesfile
+not lvcreate --devices $dev1,$dev2 -l1 -n $lv2 -an $vg1 $dev7
+lvcreate --devices $dev1,$dev2 -l1 -n $lv2 -an $vg1
+lvs --devices $dev1,$dev2 $vg1/$lv2
+lvextend --devices $dev1,$dev2 -l2 $vg1/$lv2
+lvchange --devices $dev1,$dev2 -ay $vg1/$lv2
+lvchange --devices $dev1,$dev2 -an $vg1/$lv2
+lvremove --devices $dev1,$dev2 $vg1/$lv2
+vgchange --devices $dev1,$dev2 -ay $vg1
+vgchange --devices $dev1,$dev2 -an $vg1
+not vgextend --devices $dev1,$dev2 $vg1 $dev7
+vgextend --devices $dev1,$dev2,$dev7 $vg1 $dev7
+vgreduce --devices $dev1,$dev2,$dev7 $vg1 $dev7
+vgexport --devices $dev1,$dev2 $vg1
+vgimport --devices $dev1,$dev2 $vg1
+not pvremove --devices $dev1,$dev2 $dev7
+not pvcreate --devices $dev1,$dev2 $dev7
+not vgcreate --devices $dev1,$dev2 $vg7 $dev7
+pvremove --devices $dev7 $dev7
+pvcreate --devices $dev7 $dev7
+vgcreate --devices $dev7 $vg7 $dev7
+vgremove --devices $dev7 $vg7
+pvremove --devices $dev7 $dev7
+
+# verify various commands with --devices for vg not in a devicesfile
+not lvcreate --devices $dev3,$dev4 -l1 -n $lv4 -an $vg2 $dev7
+lvcreate --devices $dev3,$dev4 -l1 -n $lv4 -an $vg2
+lvs --devices $dev3,$dev4 $vg2/$lv4
+lvextend --devices $dev3,$dev4 -l2 $vg2/$lv4
+lvchange --devices $dev3,$dev4 -ay $vg2/$lv4
+lvchange --devices $dev3,$dev4 -an $vg2/$lv4
+lvremove --devices $dev3,$dev4 $vg2/$lv4
+vgchange --devices $dev3,$dev4 -ay $vg2
+vgchange --devices $dev3,$dev4 -an $vg2
+not vgextend --devices $dev3,$dev4 $vg2 $dev7
+vgextend --devices $dev3,$dev4,$dev7 $vg2 $dev7
+vgreduce --devices $dev3,$dev4,$dev7 $vg2 $dev7
+vgexport --devices $dev3,$dev4 $vg2
+vgimport --devices $dev3,$dev4 $vg2
+not pvremove --devices $dev3,$dev4 $dev7
+not pvcreate --devices $dev3,$dev4 $dev7
+not vgcreate --devices $dev3,$dev4 $vg7 $dev7
+pvremove --devices $dev7 $dev7
+pvcreate --devices $dev7 $dev7
+vgcreate --devices $dev7 $vg7 $dev7
+vgremove --devices $dev7 $vg7
+pvremove --devices $dev7 $dev7
+
+# verify pvscan with devices file and devices list
+
+# arg not in devices file
+_clear_online_files
+pvscan --devicesfile test.devices --cache -aay $dev3
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+pvscan --devicesfile test.devices --cache -aay $dev4
+not ls "$RUNDIR/lvm/pvs_online/$PVID4"
+check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg2/$lv2 lv_active ""
+
+# arg in devices file
+_clear_online_files
+pvscan --devicesfile test.devices --cache $dev1
+pvscan --devicesfile test.devices --cache $dev2
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+
+# autoactivate with devices file
+_clear_online_files
+pvscan --devicesfile test.devices --cache -aay $dev1
+pvscan --devicesfile test.devices --cache -aay $dev2
+check lv_field $vg1/$lv1 lv_active "active"
+vgchange -an $vg1
+
+# autoactivate with no devices file
+_clear_online_files
+pvscan --cache -aay $dev3
+pvscan --cache -aay $dev4
+check lv_field $vg2/$lv2 lv_active "active"
+vgchange -an $vg2
+
+# arg not in devices list
+_clear_online_files
+pvscan --devices $dev1,$dev2 --cache $dev3
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+pvscan --devices $dev4 --cache $dev3
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+pvscan --devices $dev5 --cache $dev3
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+
+# arg in devices list
+_clear_online_files
+pvscan --devices $dev3 --cache -aay $dev3
+pvscan --devices $dev4 --cache -aay $dev4
+check lv_field $vg2/$lv2 lv_active "active"
+vgchange -an $vg2
+
+
+# verify --devicesfile and --devices are not affected by a filter
+# hide_dev excludes using existing filter
+aux hide_dev $dev2
+aux hide_dev $dev4
+pvs --devicesfile test.devices $dev1
+pvs --devicesfile test.devices $dev2
+not pvs --devicesfile test.devices $dev3
+not pvs --devicesfile test.devices $dev4
+pvs --devices $dev1 $dev1
+pvs --devices $dev2 $dev2
+pvs --devices $dev3 $dev3
+pvs --devices $dev4 $dev4
+pvs --devices $dev5 $dev5
+pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev1 $dev2 $dev3 $dev4 $dev5 | tee out
+grep $dev1 out
+grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+grep $dev5 out
+vgchange --devices $dev1,$dev2 -ay $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange --devices $dev1,$dev2 -an $vg1/$lv1
+vgchange --devices $dev3,$dev4 -ay $vg2
+check lv_field $vg2/$lv2 lv_active "active"
+lvchange --devices $dev3,$dev4 -an $vg2/$lv2
+aux unhide_dev $dev2
+aux unhide_dev $dev4
+
+vgchange --devicesfile "" -an
+vgremove --devicesfile "" -y $vg1
+vgremove --devicesfile "" -y $vg2
+vgremove --devicesfile "" -y $vg3
+
+#
+# Test with use_devicesfile=1 (system devices file is in use by default)
+#
+
+aux lvmconf 'devices/use_devicesfile = 1'
+
+DF="$DFDIR/system.devices"
+touch $DF
+
+# create one VG in a non-system devices file
+vgcreate --devicesfile test.devices $vg1 $dev1 $dev2
+
+# create one VG in the default system devices file
+vgcreate $vg2 $dev3 $dev4
+
+# create one VG in neither devices file
+vgcreate --devicesfile "" $vg3 $dev5 $dev6
+
+lvcreate --devicesfile test.devices -l4 -an -i2 -n $lv1 $vg1
+lvcreate -l4 -an -i2 -n $lv2 $vg2
+lvcreate --devicesfile "" -l4 -an -i2 -n $lv3 $vg3
+
+# system.devices only sees vg2
+vgs |tee out
+not grep $vg1 out
+grep $vg2 out
+not grep $vg3 out
+not vgs $vg1
+vgs $vg2
+not vgs $vg3
+pvs |tee out
+not grep $dev1 out
+not grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+not grep $dev5 out
+not grep $dev6 out
+
+# test.devices only sees vg1
+vgs --devicesfile test.devices |tee out
+grep $vg1 out
+not grep $vg2 out
+not grep $vg3 out
+pvs --devicesfile test.devices |tee out
+grep $dev1 out
+grep $dev2 out
+not grep $dev3 out
+not grep $dev4 out
+not grep $dev5 out
+not grep $dev6 out
+
+# no devices file sees all
+vgs --devicesfile "" |tee out
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+vgs --devicesfile "" $vg1
+vgs --devicesfile "" $vg2
+vgs --devicesfile "" $vg3
+pvs --devicesfile "" |tee out
+grep $dev1 out
+grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+grep $dev5 out
+grep $dev6 out
+
+vgchange -ay
+lvs --devicesfile test.devices -o active $vg1/$lv1 |tee out
+not grep active out
+lvs -o active $vg2/$lv2 |tee out
+grep active out
+lvs --devicesfile "" -o active $vg3/$lv3 |tee out
+not grep active out
+vgchange -an
+lvs -o active $vg2/$lv2 |tee out
+not grep active out
+
+vgchange --devicesfile test.devices -ay
+lvs --devicesfile test.devices -o active $vg1/$lv1 |tee out
+grep active out
+lvs -o active $vg2/$lv2 |tee out
+not grep active out
+lvs --devicesfile "" -o active $vg3/$lv3 |tee out
+not grep active out
+vgchange --devicesfile test.devices -an
+lvs --devicesfile test.devices -o active $vg1/$lv1 |tee out
+not grep active out
+
+# --devices overrides all three cases:
+# always gives access to the specified devices
+# always denies access to unspecified devices
+
+vgs --devices $dev1,$dev2 $vg1
+vgs --devices $dev3,$dev4 $vg2
+vgs --devices $dev5,$dev6 $vg3
+
+pvs --devices $dev1 $dev1
+pvs --devices $dev3 $dev3
+pvs --devices $dev5 $dev5
+
+not pvs --devices $dev1 $dev1 $dev2 |tee out
+grep $dev1 out
+not grep $dev2 out
+
+not pvs --devices $dev3 $dev3 $dev4 |tee out
+grep $dev3 out
+not grep $dev4 out
+
+not pvs --devices $dev5 $dev1 $dev2 $dev3 $dev4 $dev5 |tee out
+grep $dev5 out
+not grep $dev1 out
+not grep $dev2 out
+not grep $dev3 out
+not grep $dev4 out
+not grep $dev6 out
+
+pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev5 |tee out
+grep $dev5 out
+not grep $dev1 out
+not grep $dev2 out
+not grep $dev3 out
+not grep $dev4 out
+not grep $dev6 out
+
+pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev1 $dev2 $dev3 $dev4 $dev5 |tee out
+grep $dev1 out
+grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+grep $dev5 out
+
+vgchange --devices $dev1,$dev2 -ay
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+not grep $lv2 out
+not grep $lv3 out
+vgchange --devices $dev1,$dev2 -an
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | tee out
+not grep active out
+
+vgchange --devices $dev3,$dev4 -ay
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+not grep $lv1 out
+grep $lv2 out
+not grep $lv3 out
+vgchange --devices $dev3,$dev4 -an
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+not grep active out
+
+vgchange --devices $dev5,$dev6 -ay
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+not grep $lv1 out
+not grep $lv2 out
+grep $lv3 out
+vgchange --devices $dev5,$dev6 -an
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+not grep active out
+
+lvcreate --devices $dev1,$dev2 -l1 -an -n $lv4 $vg1
+lvremove --devices $dev1,$dev2 $vg1/$lv4
+lvcreate --devices $dev3,$dev4 -l1 -an -n $lv4 $vg2
+lvremove --devices $dev3,$dev4 $vg2/$lv4
+lvcreate --devices $dev5,$dev6 -l1 -an -n $lv4 $vg3
+lvremove --devices $dev5,$dev6 $vg3/$lv4
+
+not vgchange --devices $dev1,$dev2 -ay $vg2
+not vgchange --devices $dev1,$dev2 -ay $vg3
+not vgchange --devices $dev3,$dev4 -ay $vg1
+not vgchange --devices $dev3,$dev4 -ay $vg3
+not vgchange --devices $dev5,$dev6 -ay $vg1
+not vgchange --devices $dev5,$dev6 -ay $vg2
+
+not lvcreate --devices $dev1,$dev2 -an -l1 $vg2
+not lvcreate --devices $dev1,$dev2 -an -l1 $vg3
+not lvcreate --devices $dev3,$dev4 -an -l1 $vg1
+not lvcreate --devices $dev3,$dev4 -an -l1 $vg3
+not lvcreate --devices $dev5,$dev6 -an -l1 $vg1
+not lvcreate --devices $dev5,$dev6 -an -l1 $vg2
+
+# autoactivate devs in default devices file
+_clear_online_files
+pvscan --cache -aay $dev3
+pvscan --cache -aay $dev4
+check lv_field $vg2/$lv2 lv_active "active"
+vgchange -an $vg2
+pvscan --cache -aay $dev1
+not ls "$RUNDIR/lvm/pvs_online/$PVID1"
+pvscan --cache -aay $dev2
+not ls "$RUNDIR/lvm/pvs_online/$PVID2"
+pvscan --cache -aay $dev5
+not ls "$RUNDIR/lvm/pvs_online/$PVID5"
+_clear_online_files
+pvscan --devices $dev3 --cache -aay $dev3
+pvscan --devices $dev3,$dev4 --cache -aay $dev4
+lvs --devices $dev3,$dev4 -o active $vg2/$lv2 | grep active
+vgchange --devices $dev3,$dev4 -an $vg2
+
+not vgchange -ay $vg1
+vgchange --devicesfile test.devices -ay $vg1
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+not grep $lv2 out
+not grep $lv3 out
+
+vgchange -ay $vg2
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+grep $lv2 out
+not grep $lv3 out
+
+not vgchange -ay $vg3
+vgchange --devicesfile "" -ay $vg3
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+grep $lv2 out
+grep $lv3 out
+
+vgchange -an
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+not grep $lv2 out
+grep $lv3 out
+
+vgchange -ay
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+grep $lv1 out
+grep $lv2 out
+grep $lv3 out
+
+vgchange --devicesfile "" -an
+lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+not grep active out
+
+not vgremove $vg1
+not vgremove $vg3
+vgremove -y $vg2
+vgremove --devicesfile test.devices -y $vg1
+vgremove --devicesfile "" -y $vg3
+
+#
+# Test when system.devices is created by lvm
+#
+
+# no pvs exist, pvcreate creates DF, e.g. system installation
+
+wipe_all
+rm -f $DF
+pvcreate $dev1
+ls $DF
+grep $dev1 $DF
+
+# no pvs exist, vgcreate creates DF, e.g. system installation
+
+wipe_all
+rm -f $DF
+vgcreate $vg1 $dev1
+ls $DF
+grep $dev1 $DF
+
+# no pvs exist, touch DF, pvcreate uses it
+
+wipe_all
+rm -f $DF
+touch $DF
+pvcreate $dev1
+grep $dev1 $DF
+
+# no vgs exist, touch DF, vgcreate uses it
+
+wipe_all
+rm -f $DF
+touch $DF
+vgcreate $vg1 $dev1
+grep $dev1 $DF
+
+# vgs exist, pvcreate/vgcreate do not create DF
+
+wipe_all
+rm -f $DF
+vgcreate $vg1 $dev1
+ls $DF
+rm $DF
+pvcreate $dev2
+not ls $DF
+vgcreate $vg3 $dev3
+not ls $DF
+
+# vgs exist, pvcreate/vgcreate --devicesfile system.devices creates DF
+
+wipe_all
+rm -f $DF
+vgcreate $vg1 $dev1
+ls $DF
+rm $DF
+pvcreate --devicesfile system.devices $dev2
+ls $DF
+grep $dev2 $DF
+rm $DF
+vgcreate --devicesfile system.devices $vg3 $dev3
+ls $DF
+grep $dev3 $DF
+
+# pvcreate/vgcreate always create non-system DF if it doesn't exist
+
+wipe_all
+rm -f $DF
+vgcreate $vg1 $dev1
+rm $DF
+rm $DFDIR/test.devices
+pvcreate --devicesfile test.devices $dev2
+grep $dev2 $DFDIR/test.devices
+rm $DFDIR/test.devices
+vgcreate --devicesfile test.devices $vg3 $dev3
+grep $dev3 $DFDIR/test.devices
+
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
new file mode 100644
index 000000000..2ef0be13a
--- /dev/null
+++ b/test/shell/devicesfile-devname.sh
@@ -0,0 +1,548 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='devices file with devnames'
+
+. lib/inittest
+
+aux prepare_devs 7
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_LOOKUP_DIR"/*
+}
+
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir $DFDIR || true
+DF="$DFDIR/system.devices"
+ORIG="$DFDIR/orig.devices"
+
+aux lvmconf 'devices/use_devicesfile = 1'
+
+pvcreate $dev1
+ls $DF
+grep $dev1 $DF
+
+pvcreate $dev2
+grep $dev2 $DF
+
+pvcreate $dev3
+grep $dev3 $DF
+
+vgcreate $vg1 $dev1 $dev2
+
+# PVID with dashes for matching pvs -o+uuid output
+OPVID1=`pvs $dev1 --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs $dev2 --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs $dev3 --noheading -o uuid | awk '{print $1}'`
+
+# PVID without dashes for matching devices file fields
+PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+lvmdevices --deldev $dev3
+
+not grep $dev3 $DF
+not grep $PVID3 $DF
+not pvs $dev3
+
+cp $DF $ORIG
+
+lvcreate -l4 -an -i2 -n $lv1 $vg1
+
+#
+# when wrong idname devname is outside DF it's corrected if search_for=1
+# by a general cmd, or by lvmdevices --addpvid
+#
+# when wrong idname devname is outside DF it's not found or corrected if
+# search_for=0 by a general cmd, but will be by lvmdevices --addpvid
+#
+# when wrong idname devname is inside DF it's corrected if search_for=0|1
+# by a general cmd, or by lvmdevices --addpvid
+# 
+# pvscan --cache -aay does not update DF when devname= is wrong
+#
+# pvscan --cache -aay when idname devname is wrong:
+# every dev is read and then skipped if pvid is not in DF
+#
+# commands still work with incorrect devname=
+# . and they automatically correct the devname=
+#
+
+
+#
+# idname changes to become incorrect, devname remains unchanged and correct
+# . change idname to something outside DF
+# . change idname to match another DF entry
+# . swap idname of two DF entries
+#
+
+# edit DF idname, s/dev1/dev3/, where new dev is not in DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
+cat $DF
+# pvs reports correct info 
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+not grep $OPVID3 out
+not grep $dev3 out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+# pvs fixed the DF
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
+cat $DF
+# lvcreate uses correct dev
+lvcreate -l1 -n $lv2 -an $vg1 $dev1
+# lvcreate fixed the DF
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+# pvs reports correct dev
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+not grep $OPVID3 out
+not grep $dev3 out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+lvremove $vg1/$lv2
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+cat $DF
+
+# edit DF idname, s/dev1/dev2/, creating two entries with same idname
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
+cat $DF
+# lvcreate uses correct dev
+lvcreate -l1 -n $lv2 -an $vg1 $dev1
+# lvcreate fixed the DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+lvremove $vg1/$lv2
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+# edit DF idname, swap dev1 and dev2
+
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
+cat $DF
+# lvcreate uses correct dev
+lvcreate -l1 -n $lv2 -an $vg1 $dev1
+# lvcreate fixed the DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+lvremove $vg1/$lv2
+cat $DF
+
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+
+#
+# idname remains correct, devname changes to become incorrect
+# . change devname to something outside DF
+# . change devname to match another DF entry
+# . swap devname of two DF entries
+#
+
+# edit DF devname, s/dev1/dev3/, where new dev is not in DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+not grep $OPVID3 out
+not grep $dev3 out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+# pvs fixed the DF
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+cat $DF
+
+# edit DF devname, s/dev1/dev2/, creating two entries with same devname
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" $ORIG > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" $ORIG > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+# edit DF devname, swap dev1 and dev2
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep IDNAME=$dev2 out
+cat $DF
+
+
+#
+# idname and devname change, both become incorrect
+# . change idname&devname to something outside DF
+# . change idname&devname to match another DF entry
+# . swap idname&devname of two DF entries
+#
+
+# edit DF idname&devname, s/dev1/dev3/, where new dev is not in DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+not grep $OPVID3 out
+not grep $dev3 out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+# pvs fixed the DF
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+not grep $PVID3 $DF
+not grep $dev3 $DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+cat $DF
+
+# edit DF idname&devname, s/dev1/dev2/, creating two entries with same devname
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+grep IDNAME=$dev2 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+grep IDNAME=$dev2 out
+cat $DF
+
+# edit DF devname, swap dev1 and dev2
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
+cat $DF
+# pvs reports correct info
+pvs -o+uuid | tee pvs.out
+grep $vg1 pvs.out > out
+grep $OPVID1 out |tee out2
+grep $dev1 out2
+grep $OPVID2 out |tee out2
+grep $dev2 out2
+# pvs fixed the DF
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+grep IDNAME=$dev2 out
+cat $DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
+cat $DF
+# lvmdevices fixes the DF
+lvmdevices --update
+grep $PVID1 $DF |tee out
+grep DEVNAME=$dev1 out
+grep IDNAME=$dev1 out
+grep $PVID2 $DF |tee out
+grep DEVNAME=$dev2 out
+grep IDNAME=$dev2 out
+cat $DF
+
+#
+# check that pvscan --cache -aay does the right thing:
+#
+# idname and devname change, both become incorrect
+# . change idname&devname to something outside DF
+# . swap idname&devname of two DF entries
+#
+
+# edit DF idname&devname, s/dev1/dev3/, where new dev is not in DF
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
+cat $DF
+_clear_online_files
+pvscan --cache -aay $dev1
+pvscan --cache -aay $dev2
+pvscan --cache -aay $dev3
+cat $DF
+# pvscan does not fix DF
+grep $dev3 $DF
+not grep $dev1 $DF
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+check lv_field $vg1/$lv1 lv_active "active"
+# pvs updates the DF
+pvs |tee out
+grep $dev1 out
+grep $dev2 out
+not grep $dev3 out
+grep $dev1 $DF
+grep $dev2 $DF
+not grep $dev3 $DF
+vgchange -an $vg1
+
+# edit DF idname&devname, swap dev1 and dev2
+
+vgremove -y $vg1
+vgcreate $vg1 $dev1
+lvcreate -n $lv1 -l1 -an $vg1
+vgcreate $vg2 $dev2
+lvcreate -n $lv2 -l1 -an $vg2
+
+cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
+sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
+cat $DF
+
+_clear_online_files
+
+# pvscan creates the correct online files and activates correct vg
+pvscan --cache -aay $dev1
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/vgs_online/$vg1"
+not ls "$RUNDIR/lvm/pvs_online/$PVID2"
+not ls "$RUNDIR/lvm/vgs_online/$vg2"
+# don't use lvs because it would fix DF before we check it
+dmsetup status $vg1-$lv1
+not dmsetup status $vg2-$lv2
+
+pvscan --cache -aay $dev2
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/vgs_online/$vg2"
+dmsetup status $vg2-$lv2
+
+pvscan --cache -aay $dev3
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+
+# pvscan did not correct DF
+cat $DF
+grep $PVID1 $DF |tee out
+grep $dev2 out
+not grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $dev1 out
+not grep $dev2 out
+
+# pvs corrects DF
+pvs
+grep $PVID1 $DF |tee out
+grep $dev1 out
+not grep $dev2 out
+grep $PVID2 $DF |tee out
+grep $dev2 out
+not grep $dev1 out
+
+vgremove -ff $vg1
diff --git a/test/shell/devicesfile-realdevs.sh b/test/shell/devicesfile-realdevs.sh
new file mode 100644
index 000000000..edcaed0c4
--- /dev/null
+++ b/test/shell/devicesfile-realdevs.sh
@@ -0,0 +1,610 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='devices file with real devs'
+
+. lib/inittest
+
+#
+# To use this test, add two or more devices with real device ids,
+# e.g. wwids, to a file, e.g.
+# $ cat /tmp/devs
+# /dev/sdb
+# /dev/sdc
+# /dev/sdd
+#
+# Specify this file as LVM_TEST_DEVICE_LIST=/tmp/devs
+# when running the test.
+#
+# This test will wipe these devices.
+#
+
+if [ -z ${LVM_TEST_DEVICE_LIST+x} ]; then echo "LVM_TEST_DEVICE_LIST is unset" && skip; else echo "LVM_TEST_DEVICE_LIST is set to '$LVM_TEST_DEVICE_LIST'"; fi
+
+test -e "$LVM_TEST_DEVICE_LIST" || skip
+
+num_devs=$(cat $LVM_TEST_DEVICE_LIST | wc -l)
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
+
+_clear_online_files() {
+	# wait till udev is finished
+	aux udev_wait
+	rm -f "$PVS_ONLINE_DIR"/*
+	rm -f "$VGS_ONLINE_DIR"/*
+	rm -f "$PVS_LOOKUP_DIR"/*
+}
+
+test -d "$PVS_ONLINE_DIR" || mkdir -p "$PVS_ONLINE_DIR"
+test -d "$VGS_ONLINE_DIR" || mkdir -p "$VGS_ONLINE_DIR"
+test -d "$PVS_LOOKUP_DIR" || mkdir -p "$PVS_LOOKUP_DIR"
+_clear_online_files
+
+aux prepare_real_devs
+
+aux lvmconf 'devices/dir = "/dev"'
+aux lvmconf 'devices/use_devicesfile = 1'
+DFDIR="$LVM_SYSTEM_DIR/devices"
+DF="$DFDIR/system.devices"
+mkdir $DFDIR || true
+not ls $DF
+
+get_real_devs
+
+wipe_all() {
+	for dev in "${REAL_DEVICES[@]}"; do
+		wipefs -a $dev
+	done
+}
+
+wipe_all
+
+# check each dev is added correctly to df
+
+touch $DF
+for dev in "${REAL_DEVICES[@]}"; do
+	pvcreate $dev
+
+	pvs -o+uuid $dev
+	maj=$(get pv_field "$dev" major)
+	min=$(get pv_field "$dev" minor)
+	pvid=`pvs $dev --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+	sys_wwid_file="/sys/dev/block/$maj:$min/device/wwid"
+	sys_serial_file="/sys/dev/block/$maj:$min/device/serial"
+	sys_dm_uuid_file="/sys/dev/block/$maj:$min/dm/uuid"
+	sys_md_uuid_file="/sys/dev/block/$maj:$min/md/uuid"
+	sys_loop_file="/sys/dev/block/$maj:$min/loop/backing_file"
+
+	if test -e $sys_wwid_file; then
+		sys_file=$sys_wwid_file
+		idtype="sys_wwid"
+	elif test -e $sys_serial_file; then
+		sys_file=$sys_serial_file
+		idtype="sys_serial"
+	elif test -e $sys_dm_uuid_file; then
+		sys_file=$sys_dm_uuid_file
+		idtype="mpath_uuid"
+	elif test -e $sys_md_uuid_file; then
+		sys_file=$sys_md_uuid_file
+		idtype="md_uuid"
+	elif test -e $sys_loop_file; then
+		sys_file=$sys_loop_file
+		idtype="loop_file"
+	else
+		echo "no id type for device"
+		skip
+	fi
+
+	idname=$(< $sys_file)
+
+	rm -f idline
+	grep IDNAME=$idname $DF | tee idline
+	grep IDTYPE=$idtype idline
+	grep DEVNAME=$dev idline
+	grep PVID=$pvid idline
+done
+
+cp $DF df2
+
+# vgcreate from existing pvs, already in df
+
+vgcreate $vg ${REAL_DEVICES[@]}
+
+vgremove $vg
+rm $DF
+
+# vgcreate from existing pvs, adding to df
+
+touch $DF
+vgcreate $vg ${REAL_DEVICES[@]}
+
+grep IDNAME $DF > df.ids
+grep IDNAME df2 > df2.ids
+diff df.ids df2.ids
+
+# check device id metadata fields
+
+for dev in "${REAL_DEVICES[@]}"; do
+	grep $dev $DF
+	deviceid=`pvs $dev --noheading -o deviceid | awk '{print $1}'`
+	deviceidtype=`pvs $dev --noheading -o deviceidtype | awk '{print $1}'`
+	grep $dev $DF | grep $deviceid
+	grep $dev $DF | grep $deviceidtype
+	lvcreate -l1 $vg $dev
+done
+
+vgchange -an $vg
+vgremove -y $vg
+
+# check pvremove leaves devs in df but without pvid
+
+for dev in "${REAL_DEVICES[@]}"; do
+	maj=$(get pv_field "$dev" major)
+	min=$(get pv_field "$dev" minor)
+	pvid=`pvs $dev --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+	pvremove $dev
+	grep $dev $DF
+	not grep $pvid $DF
+done
+
+# Many of remaining tests require two or three devices
+test $num_devs -gt 2 || skip
+
+# check vgextend adds new dev to df, vgreduce leaves dev in df
+
+rm $DF
+
+touch $DF
+vgcreate $vg $dev1
+vgextend $vg $dev2
+grep $dev1 $DF
+grep $dev2 $DF
+id1=`pvs $dev1 --noheading -o deviceid | awk '{print $1}'`
+id2=`pvs $dev2 --noheading -o deviceid | awk '{print $1}'`
+grep $id1 $DF
+grep $id2 $DF
+vgreduce $vg $dev2
+grep $dev2 $DF
+vgremove $vg
+
+# check devs are not visible to lvm until added to df
+
+rm $DF
+
+# df needs to exist otherwise devicesfile feature turned off
+touch $DF
+
+not pvs $dev1
+not pvs $dev2
+pvs -a |tee all
+not grep $dev1 all
+not grep $dev2 all
+not grep $dev1 $DF
+not grep $dev2 $DF
+
+pvcreate $dev1
+
+pvs $dev1
+not pvs $dev2
+pvs -a |tee all
+grep $dev1 all
+not grep $dev2 all
+grep $dev1 $DF
+not grep $dev2 $DF
+
+pvcreate $dev2
+
+pvs $dev1
+pvs $dev2
+pvs -a |tee all
+grep $dev1 all
+grep $dev2 all
+grep $dev1 $DF
+grep $dev2 $DF
+
+vgcreate $vg $dev1
+
+pvs $dev1
+pvs $dev2
+pvs -a |tee all
+grep $dev1 all
+grep $dev2 all
+grep $dev1 $DF
+grep $dev2 $DF
+
+vgextend $vg $dev2
+
+pvs $dev1
+pvs $dev2
+pvs -a |tee all
+grep $dev1 all
+grep $dev2 all
+grep $dev1 $DF
+grep $dev2 $DF
+
+# check vgimportdevices VG
+
+rm $DF
+wipe_all
+
+vgcreate $vg ${REAL_DEVICES[@]}
+rm $DF
+touch $DF
+
+for dev in "${REAL_DEVICES[@]}"; do
+	not pvs $dev
+done
+
+vgimportdevices $vg
+
+for dev in "${REAL_DEVICES[@]}"; do
+	pvs $dev
+done
+
+# check vgimportdevices -a
+
+rm $DF
+wipe_all
+
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+
+rm $DF
+
+vgimportdevices -a
+
+ls $DF
+
+vgs $vg1
+vgs $vg2
+
+pvs $dev1
+pvs $dev2
+
+# check vgimportclone --importdevices
+
+rm $DF
+wipe_all
+
+vgcreate $vg1 $dev1
+vgimportdevices $vg1
+
+dd if=$dev1 of=$dev2 bs=1M count=1
+
+pvs $dev1
+not pvs $dev2
+
+grep $dev1 $DF
+not grep $dev2 $DF
+
+not vgimportclone $dev2
+
+not grep $dev2 $DF
+
+vgimportclone --basevgname $vg2 --importdevices $dev2
+
+pvid1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+pvid2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+test "$pvid1" != "$pvid2" || die "same uuid"
+
+id1=`pvs $dev1 --noheading -o deviceid | tr -d - | awk '{print $1}'`
+id2=`pvs $dev2 --noheading -o deviceid | tr -d - | awk '{print $1}'`
+test "$id1" != "$id2" || die "same device id"
+
+grep $dev1 $DF
+grep $dev2 $DF
+grep $pvid1 $DF
+grep $pvid2 $DF
+grep $id1 $DF
+grep $id2 $DF
+
+vgs $vg1
+vgs $vg2
+
+#
+# check lvmdevices
+#
+
+wipe_all
+rm $DF
+
+# set up pvs and save pvids/deviceids
+touch $DF
+count=0
+for dev in "${REAL_DEVICES[@]}"; do
+	pvcreate $dev
+	vgcreate ${vg}_${count} $dev
+	pvid=`pvs $dev --noheading -o uuid | tr -d - | awk '{print $1}'`
+	did=`pvs $dev --noheading -o deviceid | awk '{print $1}'`
+	echo dev $dev pvid $pvid did $did
+	PVIDS[$count]=$pvid
+	DEVICEIDS[$count]=$did
+	count=$(( count + 1 ))
+done
+
+rm $DF || true
+not lvmdevices
+touch $DF
+lvmdevices
+
+# check lvmdevices --adddev
+count=0
+for dev in "${REAL_DEVICES[@]}"; do
+	pvid=${PVIDS[$count]}
+	did=${DEVICEIDS[$count]}
+	echo $dev pvid: $pvid did: $did
+	not pvs $dev
+	lvmdevices --adddev $dev
+	lvmdevices |tee out
+	grep $dev out |tee idline
+	grep $pvid idline
+	grep $did idline
+	grep $dev $DF
+	pvs $dev
+	count=$(( count + 1 ))
+done
+
+# check lvmdevices --deldev
+count=0
+for dev in "${REAL_DEVICES[@]}"; do
+	pvid=${PVIDS[$count]}
+	did=${DEVICEIDS[$count]}
+	pvs $dev
+	lvmdevices --deldev $dev
+	lvmdevices |tee out
+	not grep $dev out
+	not grep $pvid out
+	not grep $did out
+	not grep $dev $DF
+	not pvs $dev
+	count=$(( count + 1 ))
+done
+
+# check lvmdevices --addpvid
+count=0
+for dev in "${REAL_DEVICES[@]}"; do
+	pvid=${PVIDS[$count]}
+	did=${DEVICEIDS[$count]}
+	not pvs $dev
+	lvmdevices --addpvid $pvid
+	lvmdevices |tee out
+	grep $dev out |tee idline
+	grep $pvid idline
+	grep $did idline
+	grep $dev $DF
+	pvs $dev
+	count=$((  count + 1 ))
+done
+
+# check lvmdevices --delpvid
+count=0
+for dev in "${REAL_DEVICES[@]}"; do
+	pvid=${PVIDS[$count]}
+	did=${DEVICEIDS[$count]}
+	pvs $dev
+	lvmdevices --delpvid $pvid
+	lvmdevices |tee out
+	not grep $dev out
+	not grep $pvid out
+	not grep $did out
+	not grep $dev $DF
+	not pvs $dev
+	count=$((  count + 1 ))
+done
+
+# wrong pvid in df
+rm $DF
+pvid1=${PVIDS[0]}
+pvid2=${PVIDS[1]}
+did1=${DEVICEIDS[0]}
+did2=${DEVICEIDS[1]}
+lvmdevices --adddev $dev1
+lvmdevices --adddev $dev2
+
+# test bad pvid
+cp $DF $DF.orig
+rm $DF
+sed "s/$pvid1/badpvid/" "$DF.orig" |tee $DF
+not grep $pvid1 $DF
+grep $did1 $DF
+
+lvmdevices --check 2>&1|tee out
+grep $dev1 out
+grep badpvid out
+grep $pvid1 out
+not grep $dev2 out
+
+lvmdevices |tee out
+grep $dev1 out |tee out1
+grep badpvid out1
+not grep $pvid1 out1
+grep $dev2 out
+
+lvmdevices --update
+
+lvmdevices 2>&1|tee out
+grep $dev1 out
+grep $dev2 out
+not grep badpvid
+grep $pvid1 out
+grep $did1 out
+grep $pvid1 $DF
+grep $did1 $DF
+
+# wrong deviceid in df
+# the devicesfile logic and behavior is based on the idname being
+# the primary identifier that we trust over everything else, i.e.
+# we'll never assume that the deviceid is wrong and some other
+# field is correct, and "fix" the deviceid.  We always assume the
+# deviceid correct and other values are wrong (since pvid and devname
+# have known, common ways of becoming wrong, but the deviceid doesn't
+# really have any known way of becoming wrong apart from random
+# file corruption.)
+# So, if the deviceid *is* corrupted, as we do here, then standard
+# commands won't correct it.  We need to use delpvid/addpvid explicitly
+# to say that we are targetting the given pvid.
+
+rm $DF
+sed "s/$did1/baddid/" "$DF.orig" |tee $DF
+
+lvmdevices --check 2>&1|tee out
+grep $dev1 out
+grep baddid out
+not grep $dev2 out
+
+lvmdevices 2>&1|tee out
+grep $pvid1 out
+grep $pvid2 out
+grep baddid out
+grep $did2 out
+grep $dev2 out
+
+lvmdevices --delpvid $pvid1
+lvmdevices --addpvid $pvid1
+
+lvmdevices |tee out
+grep $dev1 out
+grep $dev2 out
+not grep baddid
+grep $pvid1 out
+grep $did1 out
+grep $pvid1 $DF
+grep $did1 $DF
+
+# wrong devname in df, this is expected to become incorrect regularly
+# given inconsistent dev names after reboot
+
+rm $DF
+d1=$(basename $dev1)
+d3=$(basename $dev3)
+sed "s/$d1/$d3/" "$DF.orig" |tee $DF
+lvmdevices --check 2>&1 |tee out
+grep $dev1 out
+
+lvmdevices --update
+
+lvmdevices |tee out
+grep $dev1 out |tee out1
+grep $pvid1 out1
+grep $did1 out1
+grep $dev2 out |tee out2
+grep $pvid2 out2
+grep $did2 out2
+
+# swap devnames for two existing entries
+
+rm $DF
+d1=$(basename $dev1)
+d2=$(basename $dev2)
+sed "s/$d1/tmp/" "$DF.orig" |tee ${DF}_1
+sed "s/$d2/$d1/" "${DF}_1" |tee ${DF}_2
+sed "s/tmp/$d2/" "${DF}_2" |tee $DF
+rm ${DF}_1 ${DF}_2
+lvmdevices --check 2>&1 |tee out
+grep $dev1 out
+grep $dev2 out
+
+lvmdevices --update
+
+lvmdevices |tee out
+grep $dev1 out |tee out1
+grep $pvid1 out1
+grep $did1 out1
+grep $dev2 out |tee out2
+grep $pvid2 out2
+grep $did2 out2
+
+# ordinary command is not confused by wrong devname and fixes
+# the wrong devname in df
+
+rm $DF
+d1=$(basename $dev1)
+d3=$(basename $dev3)
+sed "s/$d1/$d3/" "$DF.orig" |tee $DF
+lvmdevices --check 2>&1 |tee out
+grep $dev1 out
+
+pvs -o+uuid,deviceid | grep $vg |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $did1 out1
+grep $did2 out2
+not grep $dev3 out
+
+# same dev info reported after df is fixed
+pvs -o+uuid,deviceid | grep $vg |tee out3
+diff out out3
+
+pvid=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+test "$pvid" == "$pvid1" || die "wrong uuid"
+pvid=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+test "$pvid" == "$pvid2" || die "wrong uuid"
+
+lvmdevices |tee out
+grep $dev1 out |tee out1
+grep $pvid1 out1
+grep $did1 out1
+grep $dev2 out |tee out2
+grep $pvid2 out2
+grep $did2 out2
+
+# pvscan --cache doesn't fix wrong devname but still works correctly with
+# the correct device
+
+wipe_all
+rm $DF
+touch $DF
+vgcreate $vg $dev1 $dev2
+vgcreate $vg3 $dev3
+lvcreate -an -n $lv1 -l1 $vg $dev1
+lvcreate -an -n $lv2 -l1 $vg $dev2
+lvcreate -an -n $lv3 -l1 $vg3 $dev3
+PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+rm $DF
+lvmdevices --adddev $dev1
+lvmdevices --adddev $dev2
+cp $DF $DF.orig
+d1=$(basename $dev1)
+d3=$(basename $dev3)
+sed "s/$d1/$d3/" "$DF.orig" |tee $DF
+_clear_online_files
+pvscan --cache -aay $dev1
+pvscan --cache -aay $dev2
+# pvscan should ignore dev3 since it's not in DF
+pvscan --cache -aay $dev3
+# pvscan does not fix the devname field in DF
+grep $dev3 $DF
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+check lv_field $vg/$lv1 lv_active "active"
+check lv_field $vg/$lv2 lv_active "active"
+# pvs updates the DF
+pvs |tee out
+grep $dev1 out
+grep $dev2 out
+not grep $dev3 out
+grep $dev1 $DF
+grep $dev2 $DF
+not grep $dev3 $DF
+not pvs $dev3
+vgchange -an $vg
+wipe_all
+


