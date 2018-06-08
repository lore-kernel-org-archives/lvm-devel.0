From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:39:04 -0400
Subject: master - tests: initial testing code for lvs while pvmove runs
Message-ID: <201806081239.w58Cd4P2006111@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb7c064b23c90e32ab4e8da610fca2c4e7bac73e
Commit:        bb7c064b23c90e32ab4e8da610fca2c4e7bac73e
Parent:        c93e0932e8d3005d2b0f6e1e66f7fba72f3ac950
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 12:51:27 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

tests: initial testing code for lvs while pvmove runs

---
 test/shell/pvmove-lvs.sh |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-lvs.sh b/test/shell/pvmove-lvs.sh
new file mode 100644
index 0000000..754f86a
--- /dev/null
+++ b/test/shell/pvmove-lvs.sh
@@ -0,0 +1,35 @@
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
+test_description="ensure pvmove works with lvs"
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+aux throttle_dm_mirror || skip
+
+aux prepare_vg 5 180
+
+lvcreate -aey -L30 -n $lv1 $vg "$dev1"
+lvextend -L+30 $vg/$lv1 "$dev2"
+lvextend -L+30 $vg/$lv1 "$dev1"
+lvextend -L+30 $vg/$lv1 "$dev2"
+lvextend -L+30 $vg/$lv1 "$dev1"
+
+pvmove -b "$dev1" "$dev5" 2>&1 | tee out
+
+#lvchange -an $vg/$lv1
+lvs -a $vg
+
+pvmove --abort
+
+lvremove -ff $vg


