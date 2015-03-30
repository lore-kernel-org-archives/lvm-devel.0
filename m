From: okozina <okozina@fedoraproject.org>
Date: Mon, 30 Mar 2015 16:43:18 +0000 (UTC)
Subject: master - tests: add pvmove --abort for all moves in progress
Message-ID: <20150330164318.2EAB460F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9e6e66de15ca638ca504a07d6476e571a6197d3
Commit:        b9e6e66de15ca638ca504a07d6476e571a6197d3
Parent:        5f7428e4d54254943da721f7ce11ae90aaa3f5a4
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Mar 30 16:59:51 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 30 18:39:30 2015 +0200

tests: add pvmove --abort for all moves in progress

test for bug described in c282a66132063d702d1df1e342961f75a5ffcdd2
---
 test/shell/pvmove-abort-all.sh |   68 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
new file mode 100644
index 0000000..85ee457
--- /dev/null
+++ b/test/shell/pvmove-abort-all.sh
@@ -0,0 +1,68 @@
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
+# Check pvmove --abort behaviour for all VGs and PVs
+
+. lib/inittest
+
+aux prepare_pvs 6 60
+
+vgcreate -s 128k $vg "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+vgextend $vg "$dev3"
+vgcreate -s 128k $vg1 "$dev4" "$dev5"
+pvcreate --metadatacopies 0 "$dev6"
+vgextend $vg1 "$dev6"
+
+for mode in "--atomic" "" ;
+do
+for backgroundarg in "-b" "" ;
+do
+
+# Create multisegment LV
+lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
+lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
+lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
+lvextend -l+30 -n $vg1/$lv1 "$dev5"
+
+# Slowdown writes
+aux delay_dev "$dev3" 0 300
+aux delay_dev "$dev6" 0 300
+
+pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
+aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
+aux wait_pvmove_lv_ready "$vg-pvmove1" 300
+pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
+aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
+
+# test removal of all pvmove LVs
+pvmove  --abort
+
+# check if proper pvmove was canceled
+get lv_field $vg name -a | tee out
+not grep "^\[pvmove" out
+get lv_field $vg1 name -a | tee out
+not grep "^\[pvmove" out
+
+# Restore delayed device back
+aux enable_dev "$dev3"
+aux enable_dev "$dev6"
+
+lvremove -ff $vg
+lvremove -ff $vg1
+
+wait
+done
+done
+
+vgremove -ff $vg
+vgremove -ff $vg1


