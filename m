From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Dec 2016 13:42:19 +0000 (UTC)
Subject: master - tests: usage of cached volume for snapshot
Message-ID: <20161219134219.8FA6A60FF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f47da0ad234118f4a7a5e64b7a8480f6afd8e1de
Commit:        f47da0ad234118f4a7a5e64b7a8480f6afd8e1de
Parent:        0c56eb8f438a17a8c98470f9f6b2222235a7bf59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 19 14:05:16 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 19 14:41:43 2016 +0100

tests: usage of cached volume for snapshot

---
 test/shell/lvconvert-cache-snapshot.sh |   63 ++++++++++++++++++++++++++++++++
 test/shell/lvconvert-cache.sh          |    1 -
 test/shell/lvcreate-cache-snapshot.sh  |   63 ++++++++++++++++++++++++++++++++
 3 files changed, 126 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache-snapshot.sh b/test/shell/lvconvert-cache-snapshot.sh
new file mode 100644
index 0000000..8f0ab53
--- /dev/null
+++ b/test/shell/lvconvert-cache-snapshot.sh
@@ -0,0 +1,63 @@
+#!/bin/sh
+
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
+# Test various supported conversion of snapshot of cached volume
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 1
+
+
+# Prepare cached LV
+lvcreate -aey -L1 -n $lv1 $vg
+lvcreate -H -L2 -n cpool $vg/$lv1
+
+# Prepare snapshot 'cow' LV
+lvcreate -L3 -n cow $vg
+
+# Can't use  'cached'  cow volume
+not lvconvert -s cow $vg/$lv1
+
+# Use cached LV with 'striped' cow volume
+lvconvert -y -s $vg/$lv1 cow
+check lv_field $vg/cow segtype linear
+check lv_field $vg/$lv1 segtype cache
+
+# Drop cache while being in-use origin
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+
+# Cache existing origin
+lvconvert -y --cache $vg/$lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 segtype cache
+
+# Cannot split from 'origin' (being cached LV)
+not lvconvert -y --splitsnapshot $vg/$lv1
+
+lvchange --cachemode writeback $vg/$lv1
+check lv_field  $vg/$lv1 cache_mode "writeback"
+check grep_dmsetup status  ${vg}-${lv1}-real "writeback"
+
+lvchange --cachemode writethrough $vg/$lv1
+check lv_field  $vg/$lv1 cache_mode "writethrough"
+check grep_dmsetup status  ${vg}-${lv1}-real "writethrough"
+
+# Split 'cow'  from cached origin
+lvconvert -y --splitsnapshot $vg/cow
+get lv_field $vg/cow attr | grep "^-wi"
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 76116ea..31fe4e8 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -23,7 +23,6 @@ aux prepare_vg 5 80
 lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 
-fail lvcreate -s -L2 $vg/corigin
 fail lvcreate -s -L2 $vg/cpool
 fail lvcreate -s -L2 $vg/cpool_cdata
 fail lvcreate -s -L2 $vg/cpool_cmeta
diff --git a/test/shell/lvcreate-cache-snapshot.sh b/test/shell/lvcreate-cache-snapshot.sh
new file mode 100644
index 0000000..6b6ef2c
--- /dev/null
+++ b/test/shell/lvcreate-cache-snapshot.sh
@@ -0,0 +1,63 @@
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
+# Exercise creation of snapshot of cached LV
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext2 || skip
+which fsck || skip
+
+aux have_cache 1 5 0 || skip
+
+aux prepare_vg 2
+
+lvcreate --type cache-pool -L1 $vg/cpool
+lvcreate -H -L4 -n $lv1 $vg/cpool
+
+lvcreate -s -L2 -n $lv2 $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+
+
+# Make some 'fs' data in snapshot
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv2"
+mkdir mnt
+mount "$DM_DEV_DIR/$vg/$lv2" mnt
+touch mnt/test
+umount mnt
+
+sync
+aux udev_wait
+
+# Merge snap to origin
+lvconvert --merge $vg/$lv2
+
+# Check cached origin has no valid fs.
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+# Check deactivation
+lvchange -an $vg
+
+# Check activation
+lvchange -ay $vg
+
+
+lvconvert --uncache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+
+# Uncached origin is fine as well
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+
+vgremove -ff $vg


