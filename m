From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Oct 2018 03:55:29 -0400
Subject: master - tests: check activation of many thin-pool
Message-ID: <201810100755.w9A7tTRE000513@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c36ad06a12e25302f6daf7f3504db82845195a8
Commit:        5c36ad06a12e25302f6daf7f3504db82845195a8
Parent:        194eccf9254653f5085cc116954e7ffb0a759226
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 5 14:36:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 09:54:08 2018 +0200

tests: check activation of many thin-pool

Artifitical testing of monitoring of many thin-pools with low number
of resources in use (need only few pools to actually hit the race).
---
 test/shell/thin-many-dmeventd.sh |   64 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-many-dmeventd.sh b/test/shell/thin-many-dmeventd.sh
new file mode 100644
index 0000000..f73b516
--- /dev/null
+++ b/test/shell/thin-many-dmeventd.sh
@@ -0,0 +1,64 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test activation of monitoring with more thin-pool
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_dmeventd
+aux prepare_vg 2 64
+
+# Create couple pools to later cause race in dmeventd during activation.
+# each pool may add 1sec. extra delay
+
+for i in $(seq 1 5)
+do
+	lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+        # Fill thin-pool to some capacity >50%
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
+done
+
+lvs -a $vg
+vgchange -an $vg
+
+
+# Try to now activate all existing pool - this will generate in about 10sec later
+# storm of intial call of 'lvextend --use-policies'
+vgchange -ay $vg
+
+# Every 10sec. ATM there is DM status monitoring made by dmeventd
+sleep 9
+
+# Here try to hit the race by creating several new thin-pools in sequence.
+# Creation meets with dmeventd running 'lvextend' command and taking
+# it's internal lvm2 library lock - this used to make impossible to proceed with
+# new thin-pool registration.
+for i in $(seq 11 15)
+do
+	/usr/bin/time -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+        read -r t < TM
+        test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
+        # Fill thin-pool to some capacity >50%
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
+done
+
+vgremove -f $vg


