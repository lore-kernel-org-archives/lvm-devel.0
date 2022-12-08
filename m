From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  8 Dec 2022 11:37:12 +0000 (GMT)
Subject: rhel-8.8.0 - thin: fix message processing on thin-pool extension
Message-ID: <20221208113712.0E7A53872216@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7db3a53d8a3aa7401337fb9aaf00f19cf4407e70
Commit:        7db3a53d8a3aa7401337fb9aaf00f19cf4407e70
Parent:        0b9d9963b8f15a6f12a0149a62809fa9b846c5c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 30 14:16:11 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 29 14:09:25 2022 +0100

thin: fix message processing on thin-pool extension

When thin-pool had queued some delete message on extension operation
such message has been 'lost' and thin-pool kernel metadata has been
left with a thin volume that no longer existed for lvm2 metadata.

(cherry picked from commit 09371131469f7398c597a5fb30dc565859253cc2)
---
 WHATS_NEW                          |  4 ++
 lib/metadata/lv_manip.c            |  2 +-
 test/shell/lvextend-thin-adddel.sh | 78 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e626802ec..bffd24648 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,6 +2,10 @@ Version 2.03.17 -
 ===============================
   Fix lvconvert --test --type vdo-pool execution.
 
+Version 2.03.16 - 
+====================================
+  Fix lossing of delete message on thin-pool extension.
+
 Version 2.03.14 - 20th October 2021
 ===================================
   Device scanning is skipping directories on different filesystems.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 003748d6f..9523e3e66 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6179,7 +6179,7 @@ int lv_resize(struct logical_volume *lv,
 
 	if (lv_is_thin_pool(lock_lv)) {
 		/* Update lvm pool metadata (drop messages). */
-		if (!update_pool_lv(lock_lv, 0))
+		if (!update_pool_lv(lock_lv, 1))
 			goto_bad;
 	}
 
diff --git a/test/shell/lvextend-thin-adddel.sh b/test/shell/lvextend-thin-adddel.sh
new file mode 100644
index 000000000..59b1bfa41
--- /dev/null
+++ b/test/shell/lvextend-thin-adddel.sh
@@ -0,0 +1,78 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2022 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+#
+# Play with thin-pool and thin removal and creation in corner cases
+#
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+
+test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
+"$LVM_TEST_THIN_RESTORE_CMD" -V || skip
+
+aux have_thin 1 10 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -V10 -n $lv1 -L10 -T $vg/pool
+lvcreate -V10 -n $lv2 $vg/pool
+
+# Forcibly 'error' _tmeta thin-pool metadata device
+not dmsetup remove -f $vg-pool_tmeta
+
+# Now try to schedule removal of thin volume id 1
+# that will fail with errored meta device
+not lvremove -y $vg/$lv1
+
+# Check we have queued 'message'
+vgcfgbackup -f out0 $vg
+grep "message1" out0
+
+vgchange -an $vg || true
+
+not dmsetup table ${vg}-pool-tpool
+
+# Reactivate thin-pool
+vgchange -ay $vg
+
+# Check message is still queued there
+vgcfgbackup -f out1 $vg
+grep "message1" out1
+
+lvchange -an $vg
+
+lvextend -L+10 $vg/pool
+
+# Messages should be now processed and gone
+vgcfgbackup -f out2 $vg
+not grep "message1" out2
+
+lvchange -an $vg
+
+lvchange -y -ay $vg/pool_tmeta
+
+# Kernel metadata must not see dev_id 1 either
+thin_dump $DM_DEV_DIR/$vg/pool_tmeta | tee meta
+not grep 'dev_id="1"' meta
+
+lvremove -ff $vg
+
+lvs -a $vg
+
+vgremove -ff $vg

