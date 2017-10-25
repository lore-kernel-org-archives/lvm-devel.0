From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:04:35 -0400
Subject: master - tests: snapshot conversions
Message-ID: <201710252004.v9PK4ZWt029347@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f32ef63b6c97fbf95568fee88aad8ef92e732c5a
Commit:        f32ef63b6c97fbf95568fee88aad8ef92e732c5a
Parent:        0a0cc696cafd36ee5cd69e15bb4502eb1be22b86
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 21:56:39 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:24 2017 +0200

tests: snapshot conversions

Add missing tests for snapshost conversions.
---
 test/shell/lvconvert-snapshot-cache.sh  |   78 +++++++++++++++++++++++++++++++
 test/shell/lvconvert-snapshot-mirror.sh |   60 +++++++++++++++++++++++
 test/shell/lvconvert-snapshot-raid.sh   |   62 ++++++++++++++++++++++++
 test/shell/lvconvert-snapshot-thin.sh   |   73 +++++++++++++++++++++++++++++
 4 files changed, 273 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-snapshot-cache.sh b/test/shell/lvconvert-snapshot-cache.sh
new file mode 100644
index 0000000..396f431
--- /dev/null
+++ b/test/shell/lvconvert-snapshot-cache.sh
@@ -0,0 +1,78 @@
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
+# Test various supported conversion of snapshot with cache
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 1
+
+vgchange -s 16k $vg
+
+lvcreate -L1 -n cow $vg
+
+# Thin and snapshot conversion
+lvcreate -L1 -n ch $vg
+lvcreate -H -L1 -n cpool $vg/ch
+
+# Cannot create snapshot of cpool
+not lvcreate -s -L1 $vg/cpool 2>&1 | tee err
+grep "not supported" err
+
+# Cannot create snapshot of cpool's meta
+not lvcreate -s -L1 $vg/cpool_cmeta 2>&1 | tee err
+grep "not supported" err
+
+# Cannot create snapshot of cpool's data
+not lvcreate -s -L1 $vg/cpool_cdata 2>&1 | tee err
+grep "not supported" err
+
+# Cannot use cache-type as COW
+not lvconvert --yes --type snapshot $vg/cow $vg/ch 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cdata 2>&1 | tee err
+grep "lv_is_visible" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cmeta 2>&1 | tee err
+grep "lv_is_visible" err
+
+# Cannot use thin-pool, _tdata, _tmeta as origin
+not lvconvert --yes --type snapshot $vg/cpool $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+not lvconvert --yes --type snapshot $vg/cpool_cdata $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+not lvconvert --yes --type snapshot $vg/cpool_cmeta $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+lvconvert --yes -s $vg/ch $vg/cow
+
+check lv_field $vg/ch segtype cache
+check lv_field $vg/cow segtype linear
+check lv_attr_bit type $vg/cow "s"
+check lv_attr_bit type $vg/ch "o"
+
+lvs -a -o+lv_role,lv_layout $vg
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-snapshot-mirror.sh b/test/shell/lvconvert-snapshot-mirror.sh
new file mode 100644
index 0000000..8af9e25
--- /dev/null
+++ b/test/shell/lvconvert-snapshot-mirror.sh
@@ -0,0 +1,60 @@
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
+# Test various supported conversion of snapshot with mirrors
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 3
+
+vgchange -s 16k $vg
+
+lvcreate -L1 -n cow $vg
+
+# Mirror and snapshot conversion
+lvcreate --type mirror -L1 -m1 -n mir $vg
+
+# Cannot create snapshot of mirror leg
+not lvcreate -s -L1 $vg/mir_mimage_0 2>&1 | tee err
+grep "not supported" err
+
+# cannot use 'mirror' as COW
+not lvconvert --yes --type snapshot $vg/cow $vg/mir 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/mir_mimage_0 2>&1 | tee err
+grep "lv_is_visible" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/mir_mlog 2>&1 | tee err
+grep "lv_is_visible" err
+
+# cannot use _mimage
+not lvconvert --yes --type snapshot $vg/mir_mimage_0 $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+# cannot use _mlog
+not lvconvert --yes --type snapshot $vg/mir_mlog $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+lvconvert --yes -s $vg/mir $vg/cow
+
+check lv_field $vg/mir segtype mirror
+check lv_field $vg/cow segtype linear
+check lv_attr_bit type $vg/cow "s"
+check lv_attr_bit type $vg/mir "o"
+
+lvs -a -o+lv_role,lv_layout $vg
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-snapshot-raid.sh b/test/shell/lvconvert-snapshot-raid.sh
new file mode 100644
index 0000000..91bcd94
--- /dev/null
+++ b/test/shell/lvconvert-snapshot-raid.sh
@@ -0,0 +1,62 @@
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
+# Test various supported conversion of snapshot with raid
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 3 0 || skip
+
+aux prepare_vg 3
+
+vgchange -s 16k $vg
+
+lvcreate -L1 -n cow $vg
+
+# Raid and snapshot conversion
+lvcreate --type raid1 -L1 -m1 -n rd $vg
+
+# Cannot create snapshot of raid leg
+not lvcreate -s -L1 $vg/rd_rimage_0 2>&1 | tee err
+grep "not supported" err
+
+# Cannot use raid-type as COW
+not lvconvert --yes --type snapshot $vg/cow $vg/rd 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/rd_rimage_0 2>&1 | tee err
+grep "lv_is_visible" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/rd_rmeta_0 2>&1 | tee err
+grep "lv_is_visible" err
+
+# Cannot use _rimage
+not lvconvert --yes --type snapshot $vg/rd_rimage_0 $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+# Cannot use _rmeta
+not lvconvert --yes --type snapshot $vg/rd_rmeta_0 $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+lvconvert --yes -s $vg/rd $vg/cow
+
+check lv_field $vg/rd segtype raid1
+check lv_field $vg/cow segtype linear
+check lv_attr_bit type $vg/cow "s"
+check lv_attr_bit type $vg/rd "o"
+
+lvs -a -o+lv_role,lv_layout $vg
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-snapshot-thin.sh b/test/shell/lvconvert-snapshot-thin.sh
new file mode 100644
index 0000000..ef1218b
--- /dev/null
+++ b/test/shell/lvconvert-snapshot-thin.sh
@@ -0,0 +1,73 @@
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
+# Test various supported conversion of snapshot with raid
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
+aux prepare_vg 1
+
+vgchange -s 16k $vg
+
+lvcreate -L1 -n cow $vg
+
+# Thin and snapshot conversion
+lvcreate -T -L1 -V10 -n th $vg/pool
+
+# Cannot create snapshot of pool's meta
+not lvcreate -s -L1 $vg/pool_tmeta 2>&1 | tee err
+grep "not supported" err
+
+# Cannot create snapshot of pool's data
+not lvcreate -s -L1 $vg/pool_tdata 2>&1 | tee err
+grep "not supported" err
+
+# Cannot use thin-type as COW
+not lvconvert --yes --type snapshot $vg/cow $vg/th 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/pool 2>&1 | tee err
+grep "not accept" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/pool_tdata 2>&1 | tee err
+grep "lv_is_visible" err
+
+not lvconvert --yes --type snapshot $vg/cow $vg/pool_tmeta 2>&1 | tee err
+grep "lv_is_visible" err
+
+# Cannot use thin-pool, _tdata, _tmeta as origin
+not lvconvert --yes --type snapshot $vg/pool $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+not lvconvert --yes --type snapshot $vg/pool_tdata $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+not lvconvert --yes --type snapshot $vg/pool_tmeta $vg/cow 2>&1 | tee err
+grep "invalid" err
+
+lvconvert --yes -s $vg/th $vg/cow
+
+check lv_field $vg/th segtype thin
+check lv_field $vg/cow segtype linear
+check lv_attr_bit type $vg/cow "s"
+check lv_attr_bit type $vg/th "o"
+
+lvs -a -o+lv_role,lv_layout $vg
+
+vgremove -f $vg


