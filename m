From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  1 Sep 2013 20:41:24 +0000 (UTC)
Subject: master - tests: test pvmove behavior after restart
Message-ID: <20130901204124.D829060EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=039585bb0d0cccb4c30c1f3fafe007e24ad101b6
Commit:        039585bb0d0cccb4c30c1f3fafe007e24ad101b6
Parent:        7cc36a93f6b4a9648f430e32973ea882e3c0e7c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 30 14:53:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Aug 31 21:40:51 2013 +0200

tests: test pvmove behavior after restart

Simulate crash of the system and restarted pvmove after next VG
activation.

Test is catching regression introduced in 2.02.99 for partial tree
creation changes.
---
 test/shell/pvmove-restart.sh |   52 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
new file mode 100644
index 0000000..c8da45e
--- /dev/null
+++ b/test/shell/pvmove-restart.sh
@@ -0,0 +1,52 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check pvmove behavior when it's progress and machine is rebooted
+
+. lib/test
+
+aux prepare_pvs 3 60
+
+vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
+
+# Create multisegment LV
+lvcreate -an -Zn -l5 -n $lv1 $vg "$dev1"
+lvextend -l+10 $vg/$lv1 "$dev2"
+lvextend -l+5 $vg/$lv1 "$dev1"
+lvextend -l+10 $vg/$lv1 "$dev2"
+
+# Slowdown writes
+aux delay_dev "$dev3" 0 100
+
+lvs -o+devices $vg
+
+pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" &
+PVMOVE=$!
+# Let's wait a bit till pvmove starts and kill it
+sleep 1
+kill -9 $PVMOVE
+
+# Simulate reboot - forcibly remove related devices
+dmsetup remove $vg-$lv1
+dmsetup remove $vg-pvmove0
+
+# Only PVs should be left in table...
+dmsetup table
+
+# Restart pvmove
+vgchange -ay $vg
+
+pvmove --abort
+
+# Restore delayed device back
+aux delay_dev "$dev3"
+
+lvs -a -o+devices $vg


