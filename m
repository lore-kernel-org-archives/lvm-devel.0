From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Jun 2017 17:31:28 -0400
Subject: master - tests: check conversion of thin-pool
Message-ID: <201706192131.v5JLVSgP019743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31cd01c9b31c2c4e63797edd673fca8dc53da022
Commit:        31cd01c9b31c2c4e63797edd673fca8dc53da022
Parent:        19cc03fa5275fa6d00a1f726bae40141559e2913
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 19 23:15:46 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 19 23:30:11 2017 +0200

tests: check conversion of thin-pool

---
 test/shell/lvconvert-raid-takeover-thin.sh |   52 ++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-thin.sh b/test/shell/lvconvert-raid-takeover-thin.sh
new file mode 100644
index 0000000..93d887d
--- /dev/null
+++ b/test/shell/lvconvert-raid-takeover-thin.sh
@@ -0,0 +1,52 @@
+#!/bin/sh
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
+# check we may convert thin-pool to raid1/raid10 and back
+# RHBZ#1365286
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+aux have_raid 1 9 0 || skip
+
+aux prepare_vg 6
+
+lvcreate -L4  -i3 -T  $vg/pool  -V10
+
+for i in 1 2 ; do
+lvconvert --type raid10 -y  $vg/pool_tdata
+check grep_dmsetup table $vg-pool_tdata "raid10"
+aux wait_for_sync $vg pool_tdata
+
+lvconvert --type striped -y $vg/pool_tdata
+check grep_dmsetup table $vg-pool_tdata "striped"
+done
+
+lvremove -f $vg
+
+lvcreate -L4  -T $vg/pool -V10
+
+for j in data meta ; do
+  LV=pool_t${j}
+  for i in 1 2 ; do
+    lvconvert --type raid1 -m1 -y  $vg/$LV
+    check grep_dmsetup table $vg-${LV} "raid1"
+    aux wait_for_sync $vg $LV
+
+    lvconvert --type raid1 -m0 -y  $vg/$LV
+    check grep_dmsetup table ${vg}-${LV} "linear"
+  done
+done
+
+vgremove -ff $vg


