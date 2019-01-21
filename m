From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:56:03 -0500
Subject: master - tests: initial test for vdo resize
Message-ID: <201901211156.x0LBu3lU024587@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbadf3d3704f1153b2919392ab8259b9a798a221
Commit:        cbadf3d3704f1153b2919392ab8259b9a798a221
Parent:        246b0c444bfcea68fe6c6d7174e753ee08dd7d8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 12:38:59 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

tests: initial test for vdo resize

---
 test/shell/lvextend-vdo.sh |   34 ++++++++++++++++++++++++++++++++++
 test/shell/lvresize-vdo.sh |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-vdo.sh b/test/shell/lvextend-vdo.sh
new file mode 100644
index 0000000..5a68bb1
--- /dev/null
+++ b/test/shell/lvextend-vdo.sh
@@ -0,0 +1,34 @@
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
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_vdo 6 2 0 || skip
+
+aux lvmconf 'allocation/vdo_slab_size_mb = 128'
+
+aux prepare_vg 1 7000
+lvcreate --vdo -V3G -L4G -n $lv1 $vg/$lv2
+
+# Resize data volume
+lvextend -L+1G $vg/$lv2
+check lv_field $vg/$lv2 size "5.00g"
+check lv_field $vg/${lv2}_vdata size "5.00g"
+
+# Resize virtual volume on top of VDO
+lvextend -L+1G $vg/$lv1
+check lv_field $vg/$lv1 size "4.00g"
+
+vgremove -ff $vg
diff --git a/test/shell/lvresize-vdo.sh b/test/shell/lvresize-vdo.sh
new file mode 100644
index 0000000..6fe0e9c
--- /dev/null
+++ b/test/shell/lvresize-vdo.sh
@@ -0,0 +1,35 @@
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
+# Test resize of VDO volumes
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_vdo 6 2 0 || skip
+
+aux lvmconf 'allocation/vdo_slab_size_mb = 128'
+
+aux prepare_vg 1 7000
+lvcreate --vdo -V3G -L4G -n $lv1 $vg/$lv2
+
+# Resize data volume
+lvresize -L6G $vg/$lv2
+check lv_field $vg/$lv2 size "6.00g"
+check lv_field $vg/${lv2}_vdata size "6.00g"
+
+# Resize virtual volume on top of VDO
+lvresize -L6G $vg/$lv1
+check lv_field $vg/$lv1 size "6.00g"
+
+vgremove -ff $vg


