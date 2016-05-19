From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 May 2016 16:41:38 +0000 (UTC)
Subject: master - tests: test change of cache mode
Message-ID: <20160519164138.560AA606EF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6247364caf69cce766efcc79d972f70b175c5938
Commit:        6247364caf69cce766efcc79d972f70b175c5938
Parent:        9c083d34af0bc3ce690b3086714dd812c6a15193
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 19 18:21:07 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 19 18:40:14 2016 +0200

tests: test change of cache mode

---
 test/shell/lvchange-cache-mode.sh |   71 +++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
new file mode 100644
index 0000000..8a056d6
--- /dev/null
+++ b/test/shell/lvchange-cache-mode.sh
@@ -0,0 +1,71 @@
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
+# Exercise changing of caching mode on both cache pool and cached LV.
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 2
+
+lvcreate --type cache-pool -L18 -n cpool $vg "$dev1"
+lvcreate -H -L14 -n $lv1 --cachemode writeback --cachesettings migration_threshold=204800 --cachepool $vg/cpool $vg "$dev2"
+
+#cat "$DM_DEV_DIR/$vg/$lv1"  >/dev/null
+#aux delay_dev "$dev2"  300 1000 $(get first_extent_sector "$dev2"):
+
+#dmsetup status $vg-$lv1
+#dmsetup table $vg-$lv1
+
+for i in $(seq 1 10) ; do 
+echo 3 >/proc/sys/vm/drop_caches
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=64K count=20 conv=fdatasync || true
+echo 3 >/proc/sys/vm/drop_caches
+dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=64K count=20 || true
+done
+
+lvs -o+cache_dirty_blocks,cache_read_hits,cache_read_misses,cache_write_hits,cache_write_misses $vg/$lv1
+
+vgcfgbackup -f /tmp/ooo $vg
+
+
+#
+# Drop later, code loading dm tables directly without lvm
+# RHBZ 1337588
+#
+#dmsetup table
+#echo "STATUS before cleaner"
+#dmsetup status
+#dmsetup load --table "0 28672 cache 253:4 253:3 253:5 128 1 writethrough cleaner 0" $vg-$lv1
+#dmsetup resume $vg-$lv1
+#sleep 1
+#dmsetup table
+#echo "STATUS after cleaner 1sec"
+#dmsetup status --noflush
+#dmsetup suspend --noflush $vg-$lv1
+#dmsetup resume $vg-$lv1
+
+#dmsetup load --table "0 28672 cache 253:4 253:3 253:5 128 1 passthrough smq 2 migration_threshold 204800" $vg-$lv1
+#dmsetup resume $vg-$lv1
+
+check lv_field $vg/$lv1 cache_mode "writeback"
+lvchange --cachemode passthrough $vg/$lv1
+check lv_field  $vg/$lv1 cache_mode "passthrough"
+lvchange --cachemode writethrough $vg/$lv1
+check lv_field  $vg/$lv1 cache_mode "writethrough"
+lvchange --cachemode writeback $vg/$lv1
+check lv_field  $vg/$lv1 cache_mode "writeback"
+
+vgremove -f $vg


