From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:27 +0000 (GMT)
Subject: main - new udev autoactivation
Message-ID: <20211007174327.744073858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67722b312390cdab29c076c912e14bd739c5c0f6
Commit:        67722b312390cdab29c076c912e14bd739c5c0f6
Parent:        bbf8e7db74d744c1462a63ae2bc64f4d46e8db9f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 26 11:39:05 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:42:31 2021 -0500

new udev autoactivation

new udev rule 69-dm-lvm.rules replaces
69-dm-lvm-meta.rules and lvm2-pvscan.service

udev rule calls pvscan directly on the added device

pvscan output indicates if a complete VG can be activated

udev env var LVM_VG_NAME_COMPLETE is used to pass complete
VG name from pvscan to the udev rule

udev rule uses systemd-run to run vgchange -aay <vgname>
---
 scripts/Makefile.in                |   1 -
 spec/packages.inc                  |   3 +-
 test/shell/udev-pvscan-vgchange.sh | 403 +++++++++++++++++++++++++++++++++++++
 udev/69-dm-lvm.rules.in            |  87 ++++++++
 udev/Makefile.in                   |   2 +-
 5 files changed, 492 insertions(+), 4 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ee0acb6f6..0d7f45680 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -92,7 +92,6 @@ install_systemd_generators:
 install_systemd_units:	install_dbus_service
 	@echo "    [INSTALL] systemd_units"
 	$(Q) $(INSTALL_DIR) $(systemd_unit_dir)
-	$(Q) $(INSTALL_DATA) lvm2-pvscan.service $(systemd_unit_dir)/lvm2-pvscan at .service
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(Q) $(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
 	$(Q) $(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
diff --git a/spec/packages.inc b/spec/packages.inc
index 3f6e26d11..74d795520 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -163,7 +163,7 @@ fi
 %endif
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
- %{_udevdir}/69-dm-lvm-metad.rules
+ %{_udevdir}/69-dm-lvm.rules
 %endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
@@ -189,7 +189,6 @@ fi
  %{_tmpfilesdir}/%{name}.conf
  %{_unitdir}/blk-availability.service
  %{_unitdir}/lvm2-monitor.service
- %{_unitdir}/lvm2-pvscan at .service
  %attr(555, -, -) %{_prefix}/lib/systemd/system-generators/lvm2-activation-generator
  %if %{have_service lvmpolld}
   %{_unitdir}/lvm2-lvmpolld.service
diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
new file mode 100644
index 000000000..c81acf0ce
--- /dev/null
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -0,0 +1,403 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='udev rule and systemd unit run vgchange'
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+#
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
+# udevadm trigger runs udev rule which runs systemd-run --no-wait vgchange -aay
+# Because of --no-wait, we need to wait for the transient systemd
+# service to be gone before checking the effects of the vgchange.
+
+wait_lvm_activate() {
+	local vgw=$1
+	local wait=0
+
+	while systemctl status lvm-activate-$vgw > /dev/null && test "$wait" -le 30; do
+		sleep .2
+		wait=$(( wait + 1 ))
+	done
+}
+
+# Test requires 3 devs
+test $num_devs -gt 2 || skip
+BDEV1=$(basename "$dev1")
+BDEV2=$(basename "$dev2")
+BDEV3=$(basename "$dev3")
+
+wipe_all
+touch $DF
+for dev in "${REAL_DEVICES[@]}"; do
+	pvcreate $dev
+done
+
+# 1 dev, 1 vg, 1 lv
+
+vgcreate $vg1 "$dev1"
+lvcreate -l1 -an -n $lv1 $vg1 "$dev1"
+
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
+
+_clear_online_files
+udevadm trigger --settle -c add /sys/block/$BDEV1
+
+wait_lvm_activate $vg1
+
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/vgs_online/$vg1"
+journalctl -u lvm-activate-$vg1 | tee out || true
+grep "now active" out
+check lv_field $vg1/$lv1 lv_active "active"
+
+vgchange -an $vg1
+vgremove -y $vg1
+
+
+# 2 devs, 1 vg, 2 lvs
+
+vgcreate $vg2 "$dev1" "$dev2"
+lvcreate -l1 -an -n $lv1 $vg2 "$dev1"
+lvcreate -l1 -an -n $lv2 $vg2 "$dev2"
+
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID2=$(pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}')
+
+_clear_online_files
+
+udevadm trigger --settle -c add /sys/block/$BDEV1
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+not ls "$RUNDIR/lvm/vgs_online/$vg2"
+journalctl -u lvm-activate-$vg2 | tee out || true
+not grep "now active" out
+check lv_field $vg2/$lv1 lv_active ""
+check lv_field $vg2/$lv2 lv_active ""
+
+udevadm trigger --settle -c add /sys/block/$BDEV2
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/vgs_online/$vg2"
+
+wait_lvm_activate $vg2
+
+journalctl -u lvm-activate-$vg2 | tee out || true
+grep "now active" out
+check lv_field $vg2/$lv1 lv_active "active"
+check lv_field $vg2/$lv2 lv_active "active"
+
+vgchange -an $vg2
+vgremove -y $vg2
+
+
+# 3 devs, 1 vg, 4 lvs, concurrent pvscans
+# (attempting to have the pvscans run concurrently and race
+# to activate the VG)
+
+vgcreate $vg3 "$dev1" "$dev2" "$dev3"
+lvcreate -l1 -an -n $lv1 $vg3 "$dev1"
+lvcreate -l1 -an -n $lv2 $vg3 "$dev2"
+lvcreate -l1 -an -n $lv3 $vg3 "$dev3"
+lvcreate -l8 -an -n $lv4 -i 2 $vg3 "$dev1" "$dev2"
+
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID2=$(pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
+
+_clear_online_files
+
+udevadm trigger -c add /sys/block/$BDEV1 &
+udevadm trigger -c add /sys/block/$BDEV2 &
+udevadm trigger -c add /sys/block/$BDEV3
+
+aux udev_wait
+wait_lvm_activate $vg3
+
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+ls "$RUNDIR/lvm/vgs_online/$vg3"
+journalctl -u lvm-activate-$vg3 | tee out || true
+grep "now active" out
+check lv_field $vg3/$lv1 lv_active "active"
+check lv_field $vg3/$lv2 lv_active "active"
+check lv_field $vg3/$lv3 lv_active "active"
+check lv_field $vg3/$lv4 lv_active "active"
+
+vgchange -an $vg3
+vgremove -y $vg3
+
+
+# 3 devs, 1 vg, 4 lvs, concurrent pvscans, metadata on only 1 PV
+
+wipe_all
+rm $DF
+touch $DF
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+pvcreate "$dev3"
+
+vgcreate $vg4 "$dev1" "$dev2" "$dev3"
+lvcreate -l1 -an -n $lv1 $vg4 "$dev1"
+lvcreate -l1 -an -n $lv2 $vg4 "$dev2"
+lvcreate -l1 -an -n $lv3 $vg4 "$dev3"
+lvcreate -l8 -an -n $lv4 -i 2 $vg4 "$dev1" "$dev2"
+
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID2=$(pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
+
+_clear_online_files
+
+udevadm trigger -c add /sys/block/$BDEV1 &
+udevadm trigger -c add /sys/block/$BDEV2 &
+udevadm trigger -c add /sys/block/$BDEV3
+
+aux udev_wait
+wait_lvm_activate $vg4
+
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+ls "$RUNDIR/lvm/vgs_online/$vg4"
+journalctl -u lvm-activate-$vg4 | tee out || true
+grep "now active" out
+check lv_field $vg4/$lv1 lv_active "active"
+check lv_field $vg4/$lv2 lv_active "active"
+check lv_field $vg4/$lv3 lv_active "active"
+check lv_field $vg4/$lv4 lv_active "active"
+
+vgchange -an $vg4
+vgremove -y $vg4
+
+
+# 3 devs, 3 vgs, 2 lvs in each vg, concurrent pvscans
+
+wipe_all
+rm $DF
+touch $DF
+
+vgcreate $vg5 "$dev1"
+vgcreate $vg6 "$dev2"
+vgcreate $vg7 "$dev3"
+lvcreate -l1 -an -n $lv1 $vg5
+lvcreate -l1 -an -n $lv2 $vg5
+lvcreate -l1 -an -n $lv1 $vg6
+lvcreate -l1 -an -n $lv2 $vg6
+lvcreate -l1 -an -n $lv1 $vg7
+lvcreate -l1 -an -n $lv2 $vg7
+
+_clear_online_files
+
+udevadm trigger -c add /sys/block/$BDEV1 &
+udevadm trigger -c add /sys/block/$BDEV2 &
+udevadm trigger -c add /sys/block/$BDEV3
+
+aux udev_wait
+wait_lvm_activate $vg5
+wait_lvm_activate $vg6
+wait_lvm_activate $vg7
+
+ls "$RUNDIR/lvm/vgs_online/$vg5"
+ls "$RUNDIR/lvm/vgs_online/$vg6"
+ls "$RUNDIR/lvm/vgs_online/$vg7"
+journalctl -u lvm-activate-$vg5 | tee out || true
+grep "now active" out
+journalctl -u lvm-activate-$vg6 | tee out || true
+grep "now active" out
+journalctl -u lvm-activate-$vg7 | tee out || true
+grep "now active" out
+check lv_field $vg5/$lv1 lv_active "active"
+check lv_field $vg5/$lv2 lv_active "active"
+check lv_field $vg6/$lv1 lv_active "active"
+check lv_field $vg6/$lv2 lv_active "active"
+check lv_field $vg7/$lv1 lv_active "active"
+check lv_field $vg7/$lv2 lv_active "active"
+
+vgchange -an $vg5
+vgremove -y $vg5
+vgchange -an $vg6
+vgremove -y $vg6
+vgchange -an $vg7
+vgremove -y $vg7
+
+# 3 devs, 1 vg, 1000 LVs
+
+wipe_all
+rm $DF
+touch $DF
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate "$dev2"
+pvcreate "$dev3"
+vgcreate -s 128K $vg8 "$dev1" "$dev2" "$dev3"
+
+# Number of LVs to create
+TEST_DEVS=1000
+# On low-memory boxes let's not stress too much
+test "$(aux total_mem)" -gt 524288 || TEST_DEVS=256
+
+vgcfgbackup -f data $vg8
+
+# Generate a lot of devices (size of 1 extent)
+awk -v TEST_DEVS=$TEST_DEVS '/^\t\}/ {
+    printf("\t}\n\tlogical_volumes {\n");
+    cnt=0;
+    for (i = 0; i < TEST_DEVS; i++) {
+        printf("\t\tlvol%06d  {\n", i);
+        printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i);
+        print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]";
+        print "\t\t\tsegment_count = 1";
+        print "\t\t\tsegment1 {";
+        print "\t\t\t\tstart_extent = 0";
+        print "\t\t\t\textent_count = 1";
+        print "\t\t\t\ttype = \"striped\"";
+        print "\t\t\t\tstripe_count = 1";
+        print "\t\t\t\tstripes = [";
+        print "\t\t\t\t\t\"pv0\", " cnt++;
+        printf("\t\t\t\t]\n\t\t\t}\n\t\t}\n");
+      }
+  }
+  {print}
+' data >data_new
+
+vgcfgrestore -f data_new $vg8
+
+_clear_online_files
+
+udevadm trigger -c add /sys/block/$BDEV1 &
+udevadm trigger -c add /sys/block/$BDEV2 &
+udevadm trigger -c add /sys/block/$BDEV3
+
+aux udev_wait
+wait_lvm_activate $vg8
+
+ls "$RUNDIR/lvm/vgs_online/$vg8"
+journalctl -u lvm-activate-$vg8 | tee out || true
+grep "now active" out
+
+num_active=$(lvs $vg8 --noheading -o active | grep active | wc -l)
+
+test $num_active -eq $TEST_DEVS
+
+vgchange -an $vg8
+vgremove -y $vg8
+
+# 1 pv on an md dev, 1 vg
+
+wait_md_create() {
+	local md=$1
+
+	while :; do
+		if ! grep "$(basename $md)" /proc/mdstat; then
+			echo "$md not ready"
+			cat /proc/mdstat
+			sleep 2
+		else
+			break
+		fi
+	done
+	echo "$md" > WAIT_MD_DEV
+}
+
+test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
+       modprobe raid1 || skip
+
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
+
+wipe_all
+rm $DF
+touch $DF
+
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+wait_md_create "$mddev"
+vgcreate $vg9 "$mddev"
+
+PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
+BDEVMD=$(basename "$mddev")
+
+lvcreate -l1 -an -n $lv1 $vg9
+lvcreate -l1 -an -n $lv2 $vg9
+
+_clear_online_files
+
+udevadm trigger --settle -c add /sys/block/$BDEVMD
+
+wait_lvm_activate $vg9
+
+ls "$RUNDIR/lvm/vgs_online/$vg9"
+journalctl -u lvm-activate-$vg9 | tee out || true
+grep "now active" out
+check lv_field $vg9/$lv1 lv_active "active"
+check lv_field $vg9/$lv2 lv_active "active"
+
+vgchange -an $vg9
+vgremove -y $vg9
+
+mdadm --stop "$mddev"
+aux udev_wait
+wipe_all
+
diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
new file mode 100644
index 000000000..39e5b9807
--- /dev/null
+++ b/udev/69-dm-lvm.rules.in
@@ -0,0 +1,87 @@
+# Copyright (C) 2012,2021 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM.
+#
+# This rule requires blkid to be called on block devices before so only devices
+# used as LVM PVs are processed (ID_FS_TYPE="LVM2_member").
+
+SUBSYSTEM!="block", GOTO="lvm_end"
+(LVM_EXEC_RULE)
+
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="lvm_end"
+
+# Only process devices already marked as a PV - this requires blkid to be called before.
+ENV{ID_FS_TYPE}!="LVM2_member", GOTO="lvm_end"
+ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
+ACTION=="remove", GOTO="lvm_end"
+
+# Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV
+ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-id/lvm-pv-uuid-$env{ID_FS_UUID_ENC}"
+
+# If the PV is a special device listed below, scan only if the device is
+# properly activated. These devices are not usable after an ADD event,
+# but they require an extra setup and they are ready after a CHANGE event.
+# Also support coldplugging with ADD event but only if the device is already
+# properly activated.
+# This logic should be eventually moved to rules where those particular
+# devices are processed primarily (MD and loop).
+
+# DM device:
+KERNEL!="dm-[0-9]*", GOTO="next"
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATION}=="1", GOTO="lvm_scan"
+GOTO="lvm_end"
+
+# MD device:
+LABEL="next"
+KERNEL!="md[0-9]*", GOTO="next"
+IMPORT{db}="LVM_MD_PV_ACTIVATED"
+ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
+ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
+ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
+ENV{LVM_MD_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
+GOTO="lvm_end"
+
+# Loop device:
+LABEL="next"
+KERNEL!="loop[0-9]*", GOTO="next"
+ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
+ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
+ENV{LVM_LOOP_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
+GOTO="lvm_end"
+
+LABEL="next"
+ACTION!="add", GOTO="lvm_end"
+
+LABEL="lvm_scan"
+
+ENV{SYSTEMD_READY}="1"
+
+# pvscan will check if this device completes a VG,
+# i.e. all PVs in the VG are now present with the
+# arrival of this PV.  If so, it prints to stdout:
+# LVM_VG_NAME_COMPLETE='foo'
+#
+# When the VG is complete it can be activated, so
+# vgchange -aay <vgname> is run.  It is run via
+# systemd since it can take longer to run than
+# udev wants to block when processing rules.
+# (if there are hundreds of LVs to activate,
+# the vgchange can take many seconds.)
+#
+# pvscan only reads the single device specified,
+# and uses temp files under /run/lvm to check if
+# other PVs in the VG are present.
+#
+# If event_activation=0 in lvm.conf, this pvscan
+# (using checkcomplete) will do nothing, so that
+# no event-based autoactivation will be happen.
+#
+# TODO: adjust the output of vgchange -aay so that
+# it's better suited to appearing in the journal.
+
+IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --udevoutput --journal=output $env{DEVNAME}"
+ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} lvm vgchange -aay --nohints $env{LVM_VG_NAME_COMPLETE}"
+GOTO="lvm_end"
+
+LABEL="lvm_end"
+
diff --git a/udev/Makefile.in b/udev/Makefile.in
index e32cba921..e777dda16 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 include $(top_builddir)/make.tmpl
 
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
-LVM_RULES=11-dm-lvm.rules 69-dm-lvm-metad.rules
+LVM_RULES=11-dm-lvm.rules 69-dm-lvm.rules
 
 DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 


