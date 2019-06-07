From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:09:22 -0400
Subject: master - tests: add outdated-pv.sh
Message-ID: <201906072109.x57L9M8c005408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fa1638301672c94c22b7ceacc586316af897f29
Commit:        4fa1638301672c94c22b7ceacc586316af897f29
Parent:        9156640b6083690a7341d6073c491272f1187282
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 24 15:26:47 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

tests: add outdated-pv.sh

---
 test/shell/outdated-pv.sh |   66 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/test/shell/outdated-pv.sh b/test/shell/outdated-pv.sh
new file mode 100644
index 0000000..5c9b1b2
--- /dev/null
+++ b/test/shell/outdated-pv.sh
@@ -0,0 +1,66 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+. lib/inittest
+
+aux prepare_devs 3
+get_devs
+
+#
+# Test handling of "outdated PV" which occurs when a PV goes missing
+# from a VG, and while it's missing the PV is removed from the VG.
+# Then the PV reappears with the old VG metadata that shows it is a
+# member.  That outdated metadata needs to be cleared.
+#
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+lvcreate -n $lv1 -l1 -an $vg "$dev1"
+lvcreate -n $lv2 -l1 -an $vg "$dev1"
+
+aux disable_dev "$dev2"
+
+vgreduce --removemissing $vg
+
+pvs
+
+aux enable_dev "$dev2"
+
+pvs 2>&1 | tee out
+grep "outdated" out
+
+not pvs "$dev2"
+
+# The VG can still be used with the outdated PV around
+lvcreate -n $lv3 -l1 $vg
+lvchange -ay $vg
+lvs $vg
+lvchange -an $vg
+
+# Clears the outdated PV
+vgck --updatemetadata $vg
+
+pvs 2>&1 | tee out
+not grep "outdated" out
+
+# The PV is no longer in the VG
+pvs "$dev2" | tee out
+not grep "$vg" out
+
+# The cleared PV can be added back to the VG
+vgextend $vg "$dev2"
+
+pvs "$dev2" | tee out
+grep "$vg" out
+
+vgremove -ff $vg
+


