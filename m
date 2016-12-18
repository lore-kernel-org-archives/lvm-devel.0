From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:29 +0000 (UTC)
Subject: master - tests: using cached LV for external origin
Message-ID: <20161218185229.AA1D960E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d6ac1c3ba2ee72e9832383609b6ff030d9883ce
Commit:        8d6ac1c3ba2ee72e9832383609b6ff030d9883ce
Parent:        8c17233af585b4e46a86acca8ddb126beb5faf95
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 17:43:05 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:38:51 2016 +0100

tests: using cached LV for external origin

---
 test/shell/lvconvert-thin-external-cache.sh |  107 +++++++++++++++++++++++++++
 1 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external-cache.sh b/test/shell/lvconvert-thin-external-cache.sh
new file mode 100644
index 0000000..5fc1ff8
--- /dev/null
+++ b/test/shell/lvconvert-thin-external-cache.sh
@@ -0,0 +1,107 @@
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
+# Test conversion cached LV to thin with cached external origin
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+which mkfs.ext2 || skip
+which fsck || skip
+
+#
+# Main
+#
+aux have_thin 1 5 0 || skip
+aux have_cache 1 7 0 || skip
+
+aux prepare_vg 2 64
+
+# Test will use thin-pool
+lvcreate -L10 -T $vg/tpool
+
+lvcreate -aey -L20 -n $lv1 $vg
+
+
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
+mkdir mnt
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
+touch mnt/test
+
+# Prepared cached LV - first in 'writeback' mode
+lvcreate -H --cachemode writeback -L10 -n cpool $vg/$lv1
+
+# Can't convert  'writeback' cache
+not lvconvert --thin --thinpool $vg/tpool $vg/$lv1
+
+# Switch to 'writethrough' - this should be supported
+lvchange --cachemode writethrough $vg/$lv1
+
+lvconvert --thin $vg/$lv1 --originname extorg --thinpool $vg/tpool
+
+# check cache exist as extorg-real
+check grep_dmsetup table  ${vg}-extorg-real "cache"
+
+
+# Split cache from external origin (while in-use)
+lvconvert --splitcache $vg/extorg
+
+# check linear exist as extorg-real
+check grep_dmsetup table  ${vg}-extorg-real "linear"
+check lv_field $vg/extorg segtype linear
+
+# Cache external origin in-use again
+lvconvert -y -H $vg/extorg --cachepool $vg/cpool
+
+get lv_field $vg/extorg attr | grep "^ori"
+
+umount mnt
+
+# Is filesystem still ok ?
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+lvchange -an $vg
+lvchange -ay $vg
+
+# Remove thin,   external origin remains
+lvremove -f $vg/$lv1
+
+#lvchange -prw  $vg/extorg
+lvconvert --uncache $vg/extorg
+
+lvremove -f $vg
+
+#
+# Check some more API variants
+#
+
+lvcreate -L10 -n pool $vg
+
+lvcreate -aey -L2 -n $lv1 $vg
+lvcreate -H -L2 $vg/$lv1
+
+# Converts $vg/pool to thin-pool  AND  $vg/$lv1 to thin
+lvconvert -y --type thin $vg/$lv1 --originname extorg --thinpool $vg/pool
+
+check lv_field $vg/$lv1 segtype thin
+check lv_field $vg/pool segtype thin-pool
+check lv_field $vg/extorg segtype cache
+
+lvconvert --uncache $vg/extorg
+
+check lv_field $vg/extorg segtype linear
+
+vgremove -ff $vg


