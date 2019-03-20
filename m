From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:16 -0400
Subject: master - tests: vdo dmevent autoresize
Message-ID: <201903201340.x2KDeGkZ012639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5139e5f1b3b26ae89a6e1415dd994a3ea33c460e
Commit:        5139e5f1b3b26ae89a6e1415dd994a3ea33c460e
Parent:        1117f1d46f9cbc4a0a29a975ab5c5588d63a2feb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:16:18 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:39:11 2019 +0100

tests: vdo dmevent autoresize

---
 test/shell/vdo-autoumount-dmeventd.sh |  121 +++++++++++++++++++++++++++++++++
 1 files changed, 121 insertions(+), 0 deletions(-)

diff --git a/test/shell/vdo-autoumount-dmeventd.sh b/test/shell/vdo-autoumount-dmeventd.sh
new file mode 100644
index 0000000..0d0747a
--- /dev/null
+++ b/test/shell/vdo-autoumount-dmeventd.sh
@@ -0,0 +1,121 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# no automatic extensions, just umount
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mntdir="${PREFIX}mnt with space"
+PERCENT=70
+
+cleanup_mounted_and_teardown()
+{
+	test -z "$PID_SLEEP" || { kill "$PID_SLEEP" || true ; }
+	umount "$mntdir" 2>/dev/null || true
+	vgremove -ff $vg
+	aux teardown
+}
+
+is_lv_opened_()
+{
+	test "$(get lv_field "$1" lv_device_open --binary)" = 1
+}
+
+#
+# Main
+#
+which mkfs.ext4 || skip
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+
+aux have_vdo 6 2 0 || skip
+
+# Simple implementation of umount when lvextend fails
+cat <<- EOF >testcmd.sh
+#!/bin/sh
+
+echo "VDO Pool: \$DMEVENTD_VDO_POOL"
+
+"$TESTDIR/lib/lvextend" --use-policies \$1 || {
+	umount "$mntdir"  || true
+	return 0
+}
+test "\$($TESTDIR/lib/lvs -o selected -S "data_percent>=$PERCENT" --noheadings \$1)" -eq 0 || {
+	umount "$mntdir"  || true
+	return 0
+}
+EOF
+chmod +x testcmd.sh
+# Show prepared script
+cat testcmd.sh
+
+# Use autoextend percent 0 - so extension fails and triggers umount...
+aux lvmconf "activation/vdo_pool_autoextend_percent = 0" \
+	    "activation/vdo_pool_autoextend_threshold = $PERCENT" \
+	    "dmeventd/vdo_command = \"/$PWD/testcmd.sh\"" \
+            "allocation/vdo_slab_size_mb = 128"
+
+aux prepare_dmeventd
+
+aux prepare_vg 1 9000
+
+lvcreate --vdo -L4G -V2G -n $lv1 $vg/vpool
+
+mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
+
+lvchange --monitor y $vg/vpool
+
+mkdir "$mntdir"
+trap 'cleanup_mounted_and_teardown' EXIT
+mount "$DM_DEV_DIR/$vg/$lv1" "$mntdir"
+
+# Check both LV is opened (~mounted)
+is_lv_opened_ "$vg/$lv1"
+
+touch "$mntdir/file$$"
+sync
+
+# Running 'keeper' process sleep holds the block device still in use
+sleep 60 < "$mntdir/file$$" >/dev/null 2>&1 &
+PID_SLEEP=$!
+
+lvs -a $vg
+# Fill pool above 95%  (to cause 'forced lazy umount)
+dd if=/dev/urandom of="$mntdir/file$$" bs=256K count=200 conv=fdatasync
+
+lvs -a $vg
+
+# Could loop here for a few secs so dmeventd can do some work
+# In the worst case check only happens every 10 seconds :(
+for i in $(seq 1 12) ; do
+	is_lv_opened_ "$vg/$lv1" || break
+	sleep 1
+done
+
+test "$i" -eq 12 || die "$mntdir should NOT have been unmounted by dmeventd!"
+
+lvs -a $vg
+
+# Kill device holding process - umount should work now
+kill "$PID_SLEEP"
+PID_SLEEP=
+wait
+
+# Could loop here for a few secs so dmeventd can do some work
+# In the worst case check only happens every 10 seconds :(
+for i in $(seq 1 12) ; do
+	is_lv_opened_ "$vg/$lv1" || break
+	test "$i" -lt 12 || die "$mntdir should have been unmounted by dmeventd!"
+	sleep 1
+done


