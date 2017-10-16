From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Oct 2017 09:48:47 -0400
Subject: master - tests: check external origin is monitored
Message-ID: <201710161348.v9GDmlmx003250@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f359f7558b5ae7750fa629575426ae110781566
Commit:        1f359f7558b5ae7750fa629575426ae110781566
Parent:        186a3da998b13505990809466f0e5708cfdd6c2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 16 15:45:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 16 15:47:46 2017 +0200

tests: check external origin is monitored

---
 test/shell/lvcreate-external-dmeventd.sh |   47 ++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-external-dmeventd.sh b/test/shell/lvcreate-external-dmeventd.sh
new file mode 100644
index 0000000..20973da
--- /dev/null
+++ b/test/shell/lvcreate-external-dmeventd.sh
@@ -0,0 +1,47 @@
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
+# Test check converted external origin remains monitored
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
+aux have_thin 1 3 0 || skip
+aux have_raid 1 3 0 || skip
+
+aux prepare_dmeventd
+aux prepare_vg 2
+
+# Test validation for external origin being multiple of thin pool chunk size
+lvcreate -L10M -T $vg/pool
+
+# Create raid LV (needs monitoring) for external origin.
+lvcreate -m1 -L1 -n $lv1 $vg
+
+lvconvert -T --thinpool $vg/pool --originname $lv2 $vg/$lv1
+
+# Check  raid LV now as external origing with $lv2 name is still monitored
+check lv_first_seg_field  $vg/$lv2 seg_monitor "monitored"
+
+lvchange -an $vg
+
+lvchange -ay $vg/$lv1
+check lv_first_seg_field  $vg/$lv2 seg_monitor "monitored"
+
+vgremove -ff $vg


