From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:54:51 -0400
Subject: master - tests: explicit testing of thin snapshot
Message-ID: <201910252254.x9PMspw6011811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e88fd2edfd0d723bb26f7f29460ac668d794313f
Commit:        e88fd2edfd0d723bb26f7f29460ac668d794313f
Parent:        0e5f39a5accf777db0cb5934f5adfd983c5e4491
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 26 00:15:31 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:49:16 2019 +0200

tests: explicit testing of thin snapshot

Check merging of old snapshot of thin LV.
---
 test/shell/snapshot-merge-thin.sh |   49 +++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-merge-thin.sh b/test/shell/snapshot-merge-thin.sh
new file mode 100644
index 0000000..80969d1
--- /dev/null
+++ b/test/shell/snapshot-merge-thin.sh
@@ -0,0 +1,49 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise merge of old snapshots over thin
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux target_at_least dm-snapshot-merge 1 0 0 || skip
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -T -L1 -V1 -n $lv1 $vg/pool "$dev1"
+lvcreate -s -n $lv2 -L2 $vg/$lv1 "$dev2"
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 conv=fdatasync
+
+# Initiate background merge
+lvconvert -b --merge $vg/$lv2
+
+# Query status of snapshot immediatelly after start
+# - may hit race of checking already in-progress merge
+lvs -a -o+lv_merging,lv_merge_failed $vg
+
+sleep 1
+
+# Here should be everything already merged
+lvs -a -o+lv_merging,lv_merge_failed $vg
+
+# -real must not exist for  $vg/$lv1
+not dmsetup info ${vg}-${lv1}-real 2>&1 | tee out
+grep "not exist" out
+
+not dmsetup info ${vg}-${lv2}-cow 2>&1 | tee out
+grep "not exist" out
+
+check lv_not_exists $vg $lv2
+
+vgremove -f $vg


