From: okozina <okozina@fedoraproject.org>
Date: Mon, 30 Mar 2015 16:43:16 +0000 (UTC)
Subject: master - tests: add pvmove --abort test
Message-ID: <20150330164316.15E1460F36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f7428e4d54254943da721f7ce11ae90aaa3f5a4
Commit:        5f7428e4d54254943da721f7ce11ae90aaa3f5a4
Parent:        c282a66132063d702d1df1e342961f75a5ffcdd2
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Mar 30 16:59:06 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 30 18:39:24 2015 +0200

tests: add pvmove --abort test

test for bug described in c282a66132063d702d1df1e342961f75a5ffcdd2
---
 test/shell/pvmove-abort.sh |   59 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
new file mode 100644
index 0000000..6798b59
--- /dev/null
+++ b/test/shell/pvmove-abort.sh
@@ -0,0 +1,59 @@
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
+# Check pvmove --abort behaviour when specific device is requested
+
+. lib/inittest
+
+aux prepare_pvs 3 60
+
+vgcreate -s 128k $vg "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+vgextend $vg "$dev3"
+
+for mode in "--atomic" "" ;
+do
+for backgroundarg in "-b" "" ;
+do
+
+# Create multisegment LV
+lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
+lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
+
+# Slowdown writes
+aux delay_dev "$dev3" 0 200
+
+pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
+aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
+aux wait_pvmove_lv_ready "$vg-pvmove1" 300
+
+# remove specific device
+pvmove --abort "$dev1"
+
+# check if proper pvmove was canceled
+get lv_field $vg name -a | tee out
+not grep "^\[pvmove0\]" out
+grep "^\[pvmove1\]" out
+
+# Restore delayed device back
+aux enable_dev "$dev3"
+
+# remove any remaining pvmoves in progress
+pvmove --abort
+
+lvremove -ff $vg
+
+wait
+done
+done
+
+vgremove -ff $vg


