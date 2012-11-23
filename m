From: Ondrej Kozina <okozina@redhat.com>
Date: Fri, 23 Nov 2012 15:48:38 +0100
Subject: [PATCH 3/3] - add simple test for fsadm btrfs suport
In-Reply-To: <1353682118-17855-1-git-send-email-okozina@redhat.com>
References: <1353682118-17855-1-git-send-email-okozina@redhat.com>
Message-ID: <1353682118-17855-4-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/fsadm-btrfs.sh | 156 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 156 insertions(+)
 create mode 100644 test/shell/fsadm-btrfs.sh

diff --git a/test/shell/fsadm-btrfs.sh b/test/shell/fsadm-btrfs.sh
new file mode 100644
index 0000000..f3333ee
--- /dev/null
+++ b/test/shell/fsadm-btrfs.sh
@@ -0,0 +1,156 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise fsadm btrfs resize'
+
+. lib/test
+
+aux prepare_vg 1 1024
+
+which mkfs.btrfs || check_btrfs=${check_btrfs:-mkfs.btrfs}
+which btrfsck	 || check_btrfs=${check_btrfs:-btrfsck}
+which btrfs	 || check_btrfs=${check_btrfs:-btrfs}
+
+vg_lv=$vg/$lv1
+vg_lv2=$vg/${lv1}bar
+vg_lv3=$vg/${lv1}bar2
+dev_vg_lv="$DM_DEV_DIR/$vg_lv"
+dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
+dev_vg_lv3="$DM_DEV_DIR/$vg_lv3"
+mount_dir="mnt"
+mount_space_dir="mnt space dir"
+# for recursive call
+export LVM_BINARY=$(which lvm)
+
+test ! -d "$mount_dir" && mkdir "$mount_dir"
+test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	umount "$mount_space_dir" || true
+	aux teardown
+}
+
+check_missing_btrfs()
+{
+	eval local t=$check_btrfs
+	test -z "$t" && return 0
+	test "$t" = skip && return 1
+	# trick for warning test
+	echo "WARNING: fsadm test skipped btrfs tests, $t tool is missing"
+	return 1
+}
+
+fscheck_btrfs() {
+	btrfsck "$1"
+}
+
+lvcreate -n $lv1 -L300M $vg
+lvcreate -n ${lv1}bar -L300M $vg
+lvcreate -n ${lv1}bar2 -L300M $vg
+trap 'cleanup_mounted_and_teardown' EXIT
+
+single_device_test() {
+	mkfs.btrfs -m single "$dev_vg_lv"
+	mkfs.btrfs -m single "$dev_vg_lv2"
+	# 256 MB is minimal fs size btrfs is resizable to
+	# you can grow fs from 30MB->256MB
+	# but you can't grow from 30MB->180MB
+	fsadm --lvresize resize $vg_lv 256M
+	fsadm --lvresize resize $vg_lv2 256M
+
+	not fsadm -y --lvresize resize $vg_lv 200M
+	lvresize -L+10M -r $vg_lv
+	lvreduce -L256M -r $vg_lv
+	fscheck_btrfs $dev_vg_lv
+
+	mount "$dev_vg_lv" "$mount_dir"
+	mount "$dev_vg_lv2" "$mount_space_dir"
+
+	not fsadm -y --lvresize resize $vg_lv 200M
+	lvresize -L+10M -r $vg_lv
+	lvreduce -L256M -r $vg_lv
+	umount "$mount_dir"
+	fscheck_btrfs $dev_vg_lv
+
+	not fsadm -y --lvresize resize $vg_lv2 200M
+	lvresize -L+10M -r $vg_lv2
+	lvreduce -L256M -r $vg_lv2
+	umount "$mount_space_dir"
+	fscheck_btrfs $dev_vg_lv2
+}
+
+multiple_devices_test() {
+	mkfs.btrfs -m single -d single "$dev_vg_lv" "$dev_vg_lv2" "$dev_vg_lv3"
+
+	fsadm -y --lvresize resize $vg_lv 256M
+	fsadm -y --lvresize resize $vg_lv2 256M
+	fsadm -y --lvresize resize $vg_lv3 256M
+
+	# check if fsadm is able to get/resize btrfs on
+	# the right device
+	lvresize -L+150M $vg_lv
+	fsadm -y resize $vg_lv 300M
+	not fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv3 300M
+	lvreduce -y -L256M -r $vg_lv
+
+	lvresize -L+150M $vg_lv2
+	fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv3 300M
+	not fsadm -y resize $vg_lv 300M
+	lvreduce -y -L256M -r $vg_lv2
+
+	lvresize -L+150M $vg_lv3
+	fsadm -y resize $vg_lv3 300M
+	not fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv 300M
+	lvreduce -y -L256M -r $vg_lv3
+	fscheck_btrfs $dev_vg_lv
+
+	# repeat with mounted fs
+	mount "$dev_vg_lv" "$mount_dir"
+	mount "$dev_vg_lv2" "$mount_space_dir"
+
+	lvresize -L300M $vg_lv
+	fsadm -y resize $vg_lv 300M
+	not fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv3 300M
+	lvreduce -y -L256M -r $vg_lv
+
+	lvresize -L300M $vg_lv2
+	fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv3 300M
+	not fsadm -y resize $vg_lv 300M
+	lvreduce -y -L256M -r $vg_lv2
+
+	lvresize -L300M $vg_lv3
+	fsadm -y resize $vg_lv3 300M
+	not fsadm -y resize $vg_lv2 300M
+	not fsadm -y resize $vg_lv 300M
+	lvreduce -y -L256M -r $vg_lv3
+
+	umount "$mount_dir"
+	umount "$mount_space_dir"
+	fscheck_btrfs $dev_vg_lv
+
+	lvresize -nf -L300M $vg_lv
+	lvresize -nf -L300M $vg_lv2
+}
+
+if check_missing_btrfs; then
+
+	single_device_test
+	multiple_devices_test
+fi
+
+vgremove -ff $vg
-- 
1.8.0


