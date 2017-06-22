From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:42 -0400
Subject: master - tests: flushing of cache is abortable
Message-ID: <201706221818.v5MIIgBE006653@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb2c2484b976e0ea4684cdf4ec26ab6adadce024
Commit:        cb2c2484b976e0ea4684cdf4ec26ab6adadce024
Parent:        7d5afcc0cb968ed73a6c793fd98e8d377cafe473
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 20:09:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:17:20 2017 +0200

tests: flushing of cache is abortable

---
 test/shell/lvconvert-cache-abort.sh |   54 +++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
new file mode 100644
index 0000000..899fa42
--- /dev/null
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise cache flushing is abortable
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
+# Data device on later delayed dev1
+lvcreate -L4 -n cpool $vg "$dev1"
+lvconvert -y --type cache-pool $vg/cpool "$dev2"
+lvcreate -H -L 4 -n $lv1 --chunksize 32k --cachemode writeback --cachepool $vg/cpool $vg "$dev2"
+
+#
+# Ensure cache gets promoted blocks
+#
+for i in $(seq 1 10) ; do
+echo 3 >/proc/sys/vm/drop_caches
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=64K count=20 conv=fdatasync || true
+echo 3 >/proc/sys/vm/drop_caches
+dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=64K count=20 || true
+done
+
+
+# Delay dev to ensure we have some time to 'capture' interrupt in flush
+aux delay_dev "$dev1" 0 500 $(get first_extent_sector "$dev1"):
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
+
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >log 2>&1 &
+PID_CONVERT=$!
+sleep 0.1
+kill -INT $PID_CONVERT
+aux enable_dev "$dev1"
+wait
+egrep "Flushing.*aborted" log
+# check the table got restored
+check grep_dmsetup table $vg-$lv1 "writeback"
+
+vgremove -f $vg


