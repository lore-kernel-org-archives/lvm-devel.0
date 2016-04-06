From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:44 +0000 (UTC)
Subject: master - tests: verify repair of failing mirror
Message-ID: <20160406095544.AA5FA60FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07c25429e2b1eb08bb208a6bae015870c7ae635a
Commit:        07c25429e2b1eb08bb208a6bae015870c7ae635a
Parent:        9be7bca4be913f3edc4d4f838d72329475fa8655
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 6 11:50:18 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:54:36 2016 +0200

tests: verify repair of failing mirror

Improved test script to verify lost mirror image does not
cause mirror corruption while mirror is in use.

TODO: add more cases (lost mlog...), lost image from 3leg mirror...
---
 test/shell/lvconvert-repair-mirror.sh |   75 +++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-mirror.sh b/test/shell/lvconvert-repair-mirror.sh
new file mode 100644
index 0000000..242028d
--- /dev/null
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -0,0 +1,75 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+MOUNT_DIR=mnt
+
+. lib/inittest
+
+cleanup_mounted_and_teardown()
+{
+	umount "$MOUNT_DIR" || true
+	aux teardown
+}
+
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+aux prepare_vg 5
+
+################### Check lost mirror leg #################
+#
+# NOTE: using  --regionsize 1M  has  major impact on my box
+# on read performance while mirror is synchronized
+# with the default 512K - my C2D T61 reads just couple MB/s!
+#
+lvcreate -aey --type mirror -L10 --regionsize 1M -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+mkdir "$MOUNT_DIR"
+
+aux delay_dev "$dev2" 0 500 $(get first_extent_sector "$dev2"):
+aux delay_dev "$dev4" 0 500 $(get first_extent_sector "$dev4"):
+#
+# Enforce syncronization
+# ATM requires unmounted/unused LV??
+#
+lvchange --yes --resync --noudevsync $vg/$lv1
+trap 'cleanup_mounted_and_teardown' EXIT
+mount "$DM_DEV_DIR/$vg/$lv1" "$MOUNT_DIR"
+
+# run 'dd' operation during failure of 'mlog/mimage' device
+
+dd if=/dev/zero of=mnt/zero bs=4K count=100 conv=fdatasync 2>err &
+
+PERCENT=$(get lv_field $vg/$lv1 copy_percent)
+PERCENT=${PERCENT%%\.*}  # cut decimal
+test "$PERCENT" -lt 50   # and check less then 50% mirror is in sync
+#lvs -a -o+devices $vg
+
+#aux disable_dev "$dev3"
+aux disable_dev "$dev2"
+
+lvconvert --yes --repair $vg/$lv1
+lvs -a $vg
+
+aux enable_dev "$dev2"
+
+wait
+# dd MAY NOT HAVE produced any error message
+not grep error err
+
+lvs -a -o+devices $vg
+umount "$MOUNT_DIR"
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+aux enable_dev "$dev4"
+lvremove -ff $vg


