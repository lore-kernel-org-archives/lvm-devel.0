From: David Teigland <teigland@sourceware.org>
Date: Thu, 30 Aug 2018 11:01:46 -0400
Subject: master - tests: add scan-lvs
Message-ID: <201808301501.w7UF1kSF011169@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa0a04236c613fb82e3cd559c6b451f5eb7102ad
Commit:        fa0a04236c613fb82e3cd559c6b451f5eb7102ad
Parent:        bfcecbbce182570d040f3ec446dccb84ca07efcd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 30 09:54:02 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 30 10:00:36 2018 -0500

tests: add scan-lvs

---
 test/shell/scan-lvs.sh |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/test/shell/scan-lvs.sh b/test/shell/scan-lvs.sh
new file mode 100644
index 0000000..8e8a77d
--- /dev/null
+++ b/test/shell/scan-lvs.sh
@@ -0,0 +1,47 @@
+#!/bin/bash
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
+# Test scan_lvs config setting
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux extend_filter_LVMTEST
+
+aux lvmconf 'devices/scan_lvs = 1'
+
+aux prepare_pvs 1
+
+vgcreate $SHARED $vg1 "$dev1"
+
+lvcreate -l1 -n $lv1 $vg1
+
+pvcreate "$DM_DEV_DIR/$vg1/$lv1"
+
+pvs "$DM_DEV_DIR/$vg1/$lv1"
+
+aux lvmconf 'devices/scan_lvs = 0'
+
+not pvs "$DM_DEV_DIR/$vg1/$lv1"
+
+pvs --config devices/scan_lvs=1 "$DM_DEV_DIR/$vg1/$lv1"
+
+not pvremove "$DM_DEV_DIR/$vg1/$lv1"
+
+pvremove --config devices/scan_lvs=1 "$DM_DEV_DIR/$vg1/$lv1"
+
+lvchange -an "$vg1/$lv1"
+
+lvremove "$vg1/$lv1"
+
+vgremove $vg1
+


