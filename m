From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Oct 2017 06:07:25 -0400
Subject: master - tests: check stacked cache dataLV of thin-pool
Message-ID: <201710231007.v9NA7PA3003945@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=888dd33148563e95b2b3faac98f6c6dd5f00a60a
Commit:        888dd33148563e95b2b3faac98f6c6dd5f00a60a
Parent:        df3ff32fc012b1e881dd492c1e34a7d1020747b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 23 11:51:51 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 23 12:01:16 2017 +0200

tests: check stacked cache dataLV of thin-pool

---
 test/shell/lvcreate-thin-cache.sh |   48 +++++++++++++++++++++++++++++++++++++
 test/shell/lvextend-thin-cache.sh |   36 +++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-thin-cache.sh b/test/shell/lvcreate-thin-cache.sh
new file mode 100644
index 0000000..0b9f3c8
--- /dev/null
+++ b/test/shell/lvcreate-thin-cache.sh
@@ -0,0 +1,48 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise caching thin-pool's data LV
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+aux have_cache 1 3 0 || skip
+
+which mkfs.ext4 || skip
+
+aux prepare_pvs 2 64
+get_devs
+
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
+
+lvcreate -L10M -V10M -T $vg/pool --name $lv1
+
+lvcreate -H -L10 $vg/pool
+
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+lvconvert --uncache $vg/pool
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+lvcreate -H -L10 $vg/pool_tdata
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+lvconvert --uncache $vg/pool_tdata
+
+vgremove -ff $vg
diff --git a/test/shell/lvextend-thin-cache.sh b/test/shell/lvextend-thin-cache.sh
new file mode 100644
index 0000000..8983b7d
--- /dev/null
+++ b/test/shell/lvextend-thin-cache.sh
@@ -0,0 +1,36 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise resize of cached thin pool data volumes
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -l2 -T $vg/pool
+# Caching of thin-pool's dataLV
+lvcreate -H -L10 $vg/pool
+
+# Resize is unsupported
+not lvextend -l+2 $vg/pool 2>&1 | tee out
+
+grep "Unable to resize" out
+
+vgremove -ff $vg


