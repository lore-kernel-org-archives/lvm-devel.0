From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 17:47:11 -0500
Subject: stable-2.02 - tests: add scan_lvs.sh
Message-ID: <201902202247.x1KMlBjC005093@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=850e95f24a86c4487363c6cf43b10c15a86b0c26
Commit:        850e95f24a86c4487363c6cf43b10c15a86b0c26
Parent:        083f162e8e01eca1a6c66b4d9bfeede05ed6feab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 14:38:01 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:38:01 2019 -0600

tests: add scan_lvs.sh

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


