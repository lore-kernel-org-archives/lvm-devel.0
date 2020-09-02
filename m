From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Sep 2020 19:47:55 +0000 (GMT)
Subject: master - writecache: allow pvmove on origin
Message-ID: <20200902194755.8E8163857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8bb85d9638e1b0cad96c654a1e4a61b6d33aa97
Commit:        d8bb85d9638e1b0cad96c654a1e4a61b6d33aa97
Parent:        f5a669f3145c92220346871bad4ab1c0149a1cc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 2 14:45:52 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 2 14:45:52 2020 -0500

writecache: allow pvmove on origin

The removed check didn't actually prevent pvmoving the origin,
which was possible by naming the wcorig lv, or naming no lv.
---
 test/shell/writecache-misc.sh | 80 +++++++++++++++++++++++++++++++++++++++++++
 tools/pvmove.c                |  5 ---
 2 files changed, 80 insertions(+), 5 deletions(-)

diff --git a/test/shell/writecache-misc.sh b/test/shell/writecache-misc.sh
new file mode 100644
index 000000000..4f4c125fb
--- /dev/null
+++ b/test/shell/writecache-misc.sh
@@ -0,0 +1,80 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test single lv cache options
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mkfs_mount_umount()
+{
+        lvt=$1
+
+        mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lvt"
+        mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
+        cp pattern1 "$mount_dir/pattern1"
+        dd if=/dev/zero of="$mount_dir/zeros2M" bs=1M count=32 conv=fdatasync
+        umount "$mount_dir"
+}
+
+mount_umount()
+{
+        lvt=$1
+
+        mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
+        diff pattern1 "$mount_dir/pattern1"
+        dd if="$mount_dir/zeros2M" of=/dev/null bs=1M count=32
+        umount "$mount_dir"
+}
+
+aux have_writecache 1 0 0 || skip
+which mkfs.xfs || skip
+
+mount_dir="mnt"
+mkdir -p "$mount_dir"
+
+# generate random data
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+aux prepare_devs 4
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+
+#
+# Test pvmove with writecache
+#
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+
+lvchange -ay $vg/$lv1
+mkfs_mount_umount $lv1
+
+# cannot pvmove the cachevol
+not pvmove "$dev2" "$dev3"
+
+# can pvmove the origin
+pvmove "$dev1" "$dev3"
+
+mount_umount $lv1
+
+# can pvmove the origin, naming the lv with the writecache
+pvmove -n $vg/$lv1 "$dev3" "$dev1"
+
+mount_umount $lv1
+lvchange -an $vg/$lv1
+
+vgremove -ff $vg
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a346b5338..cc512b9de 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -626,11 +626,6 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			return ECMD_FAILED;
 		}
 
-		if (lv_is_writecache(lv)) {
-			log_error("pvmove not allowed on LV using writecache.");
-			return ECMD_FAILED;
-		}
-
 		if (lv_is_raid(lv) && lv_raid_has_integrity(lv)) {
 			log_error("pvmove not allowed on raid LV with integrity.");
 			return ECMD_FAILED;


