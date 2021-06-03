From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:40:09 +0000 (GMT)
Subject: main - tests: multi-hosts: Test lease timeout with LV shareable mode
Message-ID: <20210603144009.EEC36383B420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe05828e7e4c78a1ed4430ce4057c785d0b898a0
Commit:        fe05828e7e4c78a1ed4430ce4057c785d0b898a0
Parent:        0a4d6d9d1d8ef4e3fe141c757dd5aad4b48b316c
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:25 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: multi-hosts: Test lease timeout with LV shareable mode

This patch is to test timeout handling after activate LV with shareable
mode.  It has the same logic with the testing for LV exclusive mode,
except it verifies the locking with shareable mode.

  On the host A:
    make check_lvmlockd_idm \
      LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
      LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_sh_timeout_hosta.sh

  On the host B:
    make check_lvmlockd_idm \
      LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
      LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_sh_timeout_hostb.sh

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/multi_hosts_lv_sh_timeout_hosta.sh | 87 +++++++++++++++++++++++++++
 test/shell/multi_hosts_lv_sh_timeout_hostb.sh | 56 +++++++++++++++++
 2 files changed, 143 insertions(+)

diff --git a/test/shell/multi_hosts_lv_sh_timeout_hosta.sh b/test/shell/multi_hosts_lv_sh_timeout_hosta.sh
new file mode 100644
index 000000000..6b24f9290
--- /dev/null
+++ b/test/shell/multi_hosts_lv_sh_timeout_hosta.sh
@@ -0,0 +1,87 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Seagate, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# This testing script is for multi-hosts testing.
+#
+# On the host A:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_sh_timeout_hosta.sh
+# On the host B:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_sh_timeout_hostb.sh
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+[ -z "$LVM_TEST_MULTI_HOST" ] && skip;
+
+IFS=',' read -r -a BLKDEVS <<< "$LVM_TEST_BACKING_DEVICE"
+
+for d in "${BLKDEVS[@]}"; do
+	aux extend_filter_LVMTEST "a|$d|"
+done
+
+aux lvmconf "devices/allow_changes_with_duplicate_pvs = 1"
+
+for d in "${BLKDEVS[@]}"; do
+	dd if=/dev/zero of="$d" bs=32k count=1
+	wipefs -a "$d" 2>/dev/null || true
+
+	sg_dev=`sg_map26 ${d}`
+	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
+		echo "Cleanup IDM context for drive ${d} ($sg_dev)"
+		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
+		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
+		rm /tmp/idm_tmp_data.bin
+	fi
+done
+
+for i in $(seq 1 ${#BLKDEVS[@]}); do
+	vgcreate $SHARED TESTVG$i ${BLKDEVS[$(( i - 1 ))]}
+	lvcreate -a n --zero n -l 1 -n foo TESTVG$i
+	lvchange -a sy TESTVG$i/foo
+done
+
+for d in "${BLKDEVS[@]}"; do
+	drive_wwn=`udevadm info $d | awk -F= '/E: ID_WWN=/ {print $2}'`
+	for dev in /dev/*; do
+		if [ -b "$dev" ] && [[ ! "$dev" =~ [0-9] ]]; then
+			wwn=`udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}'`
+			if [ "$wwn" = "$drive_wwn" ]; then
+				base_name="$(basename -- ${dev})"
+				drive_list+=("$base_name")
+				host_list+=(`readlink /sys/block/$base_name | awk -F'/' '{print $6}'`)
+			fi
+		fi
+	done
+done
+
+for d in "${drive_list[@]}"; do
+	[ -f /sys/block/$d/device/delete ] && echo 1 > /sys/block/$d/device/delete
+done
+
+sleep 100
+
+for i in $(seq 1 ${#BLKDEVS[@]}); do
+	check grep_lvmlockd_dump "S lvm_TESTVG$i kill_vg"
+	lvmlockctl --drop TESTVG$i
+done
+
+# Rescan drives so can probe the deleted drives and join back them
+for h in "${host_list[@]}"; do
+	[ -f /sys/class/scsi_host/${h}/scan ] && echo "- - -" > /sys/class/scsi_host/${h}/scan
+done
diff --git a/test/shell/multi_hosts_lv_sh_timeout_hostb.sh b/test/shell/multi_hosts_lv_sh_timeout_hostb.sh
new file mode 100644
index 000000000..7aea2235d
--- /dev/null
+++ b/test/shell/multi_hosts_lv_sh_timeout_hostb.sh
@@ -0,0 +1,56 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Seagate, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# This testing script is for multi-hosts testing.
+#
+# On the host A:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_ex_timeout_hosta.sh
+# On the host B:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_lv_ex_timeout_hostb.sh
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+[ -z "$LVM_TEST_MULTI_HOST" ] && skip;
+
+IFS=',' read -r -a BLKDEVS <<< "$LVM_TEST_BACKING_DEVICE"
+
+for d in "${BLKDEVS[@]}"; do
+	aux extend_filter_LVMTEST "a|$d|"
+done
+
+aux lvmconf "devices/allow_changes_with_duplicate_pvs = 1"
+
+vgchange --lock-start
+
+vgdisplay
+
+for i in $(seq 1 ${#BLKDEVS[@]}); do
+	lvchange -a sy TESTVG$i/foo
+done
+
+# Sleep for 70 seconds so the previous lease is expired
+sleep 70
+
+for i in $(seq 1 ${#BLKDEVS[@]}); do
+	lvchange -a ey TESTVG$i/foo
+	lvchange -a n TESTVG$i/foo
+done
+
+for i in $(seq 1 ${#BLKDEVS[@]}); do
+	vgremove -f TESTVG$i
+done


