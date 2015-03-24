From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Mar 2015 09:13:03 +0000 (UTC)
Subject: master - tests: move thin-related test from select-tools.sh to select-tools-thin.sh
Message-ID: <20150324091303.74AF460F13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0bffd99daa6510f80c918a23187b638260e9e634
Commit:        0bffd99daa6510f80c918a23187b638260e9e634
Parent:        9dbe2d760f3810463ffa416e82f89766b12b0071
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 24 10:12:04 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 24 10:12:27 2015 +0100

tests: move thin-related test from select-tools.sh to select-tools-thin.sh

And skip this test if thin target is not available.
---
 test/shell/select-tools-thin.sh |   35 +++++++++++++++++++++++++++++++++++
 test/shell/select-tools.sh      |   15 ---------------
 2 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
new file mode 100644
index 0000000..d70289f
--- /dev/null
+++ b/test/shell/select-tools-thin.sh
@@ -0,0 +1,35 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+
+aux prepare_pvs 1 16
+
+#########################
+# special cases to test #
+#########################
+
+# if calling lvremove and an LV is removed that is related to other LV
+# and we're doing selection based on this relation, check if we're
+# selecting on initial state (here, thin origin LV thin_orig is removed
+# first, but thin snap should be still selectable based on origin=thin_orig
+# condition even though thin_orig has just been removed)
+vgcreate -s 4m $vg1 $dev1
+lvcreate -l100%FREE -T $vg1/pool
+lvcreate -V4m -T $vg1/pool -n thin_orig
+lvcreate -s $vg1/thin_orig -n thin_snap
+lvremove -ff -S 'lv_name=thin_orig || origin=thin_orig' > out
+grep "Logical volume \"thin_orig\" successfully removed" out
+grep "Logical volume \"thin_snap\" successfully removed" out
+not lvs $vg1/thin_orig
+not lvs $vg1/thin_snap
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 975ebdb..d04ed0a 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -273,18 +273,3 @@ pvchange -a --deltag 309 --deltag tag
 # iterates over LVs with process_each_lv_in_vg - so internally it actually
 # operates per-LV, but we still need the selection to be done per-VG)
 vgremove --yes -S 'lv_name=lv2' # should remove whole vg1, not just the lv2
-
-# if calling lvremove and an LV is removed that is related to other LV
-# and we're doing selection based on this relation, check if we're
-# selecting on initial state (here, thin origin LV thin_orig is removed
-# first, but thin snap should be still selectable based on origin=thin_orig
-# condition even though thin_orig has just been removed)
-vgcreate -s 4m $vg1 $dev1 $dev2
-lvcreate -l100%FREE -T $vg1/pool
-lvcreate -V4m -T $vg1/pool -n thin_orig
-lvcreate -s $vg1/thin_orig -n thin_snap
-lvremove -ff -S 'lv_name=thin_orig || origin=thin_orig' > out
-grep "Logical volume \"thin_orig\" successfully removed" out
-grep "Logical volume \"thin_snap\" successfully removed" out
-not lvs $vg1/thin_orig
-not lvs $vg1/thin_snap


