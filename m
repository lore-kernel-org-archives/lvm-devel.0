From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:37 +0000 (GMT)
Subject: master - tests: basic test for vdo on raid LV
Message-ID: <20200923125937.D8C83398E477@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=502b895bb4a132fa0a45d30a2db0f8f06591b272
Commit:        502b895bb4a132fa0a45d30a2db0f8f06591b272
Parent:        39cdc1469d192e48bf5e1b39fc51a42c64e46ab6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 14:48:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 14:58:24 2020 +0200

tests: basic test for vdo on raid LV

Check stacing of VDO on top of raid LV works.
---
 test/shell/lvconvert-vdo-raid.sh | 71 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/test/shell/lvconvert-vdo-raid.sh b/test/shell/lvconvert-vdo-raid.sh
new file mode 100644
index 000000000..998315160
--- /dev/null
+++ b/test/shell/lvconvert-vdo-raid.sh
@@ -0,0 +1,71 @@
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
+# Exercise vdo-pool's on raidLV
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+#
+# Main
+#
+
+#
+aux have_vdo 6 2 1 || skip
+aux have_raid 1 3 0 || skip
+
+
+aux prepare_vg 2 9000
+
+lvcreate --yes --vdo -L4G $vg/vpool
+
+aux zero_dev "$dev1" "$(( $(get first_extent_sector "$dev1") + 8192 )):"
+aux zero_dev "$dev2" "$(( $(get first_extent_sector "$dev2") + 8192 )):"
+
+# convert _vdata to raid
+lvconvert --yes --type raid1 $vg/vpool_vdata
+check lv_field $vg/vpool_vdata segtype raid1 -a
+
+lvconvert --yes -m 0  $vg/vpool_vdata "$dev2"
+check lv_field $vg/vpool_vdata segtype linear -a
+
+# vpool  should redirect to _vdata
+lvconvert --yes --type raid1 $vg/vpool
+check lv_field $vg/vpool_vdata segtype raid1 -a
+
+lvremove -f $vg
+
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+
+lvcreate --type raid1 -L4G --nosync -n vpool1 $vg
+
+lvconvert --yes --vdopool $vg/vpool1 -V2G -n $lv1
+
+mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
+
+not lvrename $vg/vpool1
+
+lvchange -an $vg
+
+lvrename $vg/vpool1 $vg/vpool
+
+lvchange -ay $vg
+
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+lvs -a $vg
+
+vgremove -ff $vg


