From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:31:37 -0500
Subject: master - test: new reshape test under io load
Message-ID: <201712011731.vB1HVbpk026377@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9681d98cc401681ab60033b6595caf8355f8748d
Commit:        9681d98cc401681ab60033b6595caf8355f8748d
Parent:        d3d18e637cbd4bfb1ef088a404fdc12dd319309e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:31:12 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:31:12 2017 +0100

test: new reshape test under io load

---
 test/shell/lvconvert-raid-reshape-load.sh |   67 +++++++++++++++++++++++++++++
 1 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
new file mode 100644
index 0000000..c01127b
--- /dev/null
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -0,0 +1,67 @@
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
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+LVM_SKIP_LARGE_TESTS=1
+
+. lib/inittest
+
+# Test reshaping under io load
+
+which mkfs.ext4 || skip
+aux have_raid 1 12 0 || skip
+
+mpoint=/tmp/mpoint.$$
+
+trap "[ -d $mpoint ] && rmdir $mpoint" 15
+
+aux prepare_pvs 16 32
+
+get_devs
+
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
+
+# Create 13-way striped raid5 (14 legs total)
+lvcreate --yes --type raid5_ls --stripes 13 -L190M -n$lv1 $vg
+check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
+check lv_first_seg_field $vg/$lv1 data_stripes 13
+check lv_first_seg_field $vg/$lv1 stripes 14
+echo y|mkfs -t ext4 /dev/$vg/$lv1
+aux wait_for_sync $vg $lv1
+
+mkdir -p $mpoint
+mount "$DM_DEV_DIR/$vg/$lv1" $mpoint
+mkdir -p $mpoint/1 $mpoint/2
+
+aux delay_dev "$dev2" 0 100
+
+echo 3 >/proc/sys/vm/drop_caches
+cp -r /usr/bin $mpoint/1 >/dev/null 2>/dev/null &
+cp -r /usr/bin $mpoint/2 >/dev/null 2>/dev/null &
+sync &
+
+# Reshape it to 256K stripe size
+lvconvert --yes --stripesize 256 $vg/$lv1
+aux delay_dev "$dev2" 0 0
+check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
+
+kill -9 %%
+wait
+
+umount $mpoint
+[ -d $mpoint ] && rmdir $mpoint
+
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -ff $vg


