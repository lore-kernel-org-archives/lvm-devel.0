From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:19 -0400
Subject: master - tests: vdo caching tests
Message-ID: <201903201340.x2KDeJO6012652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f757ab6166074dd3286983c05a30623095845ff
Commit:        7f757ab6166074dd3286983c05a30623095845ff
Parent:        5139e5f1b3b26ae89a6e1415dd994a3ea33c460e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 26 01:36:07 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:39:11 2019 +0100

tests: vdo caching tests

---
 test/shell/lvconvert-cache-vdo.sh |   61 +++++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-vdo-cache.sh  |   55 +++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-vdo.sh b/test/shell/lvconvert-cache-vdo.sh
new file mode 100644
index 0000000..8e28948
--- /dev/null
+++ b/test/shell/lvconvert-cache-vdo.sh
@@ -0,0 +1,61 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise usage of stacked cache volume used in thin pool volumes
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_vdo 6 2 0 || skip
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 1 9000
+
+lvcreate -L10 -n cpool $vg
+lvcreate -L4G -n vpool $vg
+
+# Cache volume
+lvconvert --yes --cache --cachepool cpool $vg/vpool
+
+# Stack cached LV as  VDODataLV for VDOPoolLV
+lvconvert --yes --type vdo-pool -V50M --name $lv1 $vg/vpool
+
+aux mkdev_md5sum $vg $lv1
+
+lvconvert --splitcache $vg/vpool
+
+check dev_md5sum $vg $lv1
+lvchange -an $vg
+lvchange -ay $vg
+check dev_md5sum $vg $lv1
+
+lvconvert --yes --cache --cachepool cpool $vg/vpool
+lvconvert --splitcache $vg/vpool
+
+lvs -a $vg
+
+lvconvert --yes --cache --cachepool cpool $vg/$lv1
+check dev_md5sum $vg $lv1
+lvchange -an $vg
+lvchange -ay $vg
+check dev_md5sum $vg $lv1
+
+lvs -a  $vg
+not lvconvert --splitcache $vg/vpool
+lvconvert --splitcache $vg/$lv1
+lvs -a  $vg
+
+# Also check, removal of cached VDO LV works
+lvconvert --yes --cache --cachepool cpool $vg/$lv1
+vgremove -f $vg
diff --git a/test/shell/lvcreate-vdo-cache.sh b/test/shell/lvcreate-vdo-cache.sh
new file mode 100644
index 0000000..c3d3ed0
--- /dev/null
+++ b/test/shell/lvcreate-vdo-cache.sh
@@ -0,0 +1,55 @@
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
+# Exercise caching vdo and vdo-pool's data LV
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_vdo 6 2 0 || skip
+aux have_cache 1 3 0 || skip
+
+which mkfs.ext4 || skip
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+
+aux prepare_vg 1 9000
+
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool
+
+# Test caching VDOPoolLV
+lvcreate -H -L10 $vg/vpool
+
+mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
+
+lvconvert --uncache $vg/vpool
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+lvcreate -H -L10 $vg/vpool_vdata
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+lvs -a $vg
+lvconvert --uncache $vg/vpool_vdata
+
+
+# Test caching VDOLV
+lvcreate -H -L10 $vg/$lv1
+
+lvconvert --uncache $vg/$lv1
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+lvs -a $vg
+
+vgremove -ff $vg


