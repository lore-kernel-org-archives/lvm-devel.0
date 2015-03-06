From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:48 +0000 (UTC)
Subject: master - tests: speed of many PVS in a VG
Message-ID: <20150306133148.8ACB6600E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=588b3bd7a16b19423f9c4d06b27a3cbe7ac9d623
Commit:        588b3bd7a16b19423f9c4d06b27a3cbe7ac9d623
Parent:        85ef614b37bafd3c91c9fb6e6cfb6c40d6f80f99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 14:29:26 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 14:29:26 2015 +0100

tests: speed of many PVS in a VG

---
 test/shell/vgcreate-many-pvs.sh |   62 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
new file mode 100644
index 0000000..c6d3852
--- /dev/null
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -0,0 +1,62 @@
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
+#
+# Test to exercise larger number of PVs in a VG
+# Related to https://bugzilla.redhat.com/show_bug.cgi?id=736027
+# 
+# Original measured times of the whole test case before 
+# and with the acceleration patch from my bare metal hw
+# (Lenovo T61, 2.2GHz, 4G RAM, rawhide 2015-03-06 with ndebug kernel):
+#
+# export LVM_TEST_PVS=300
+#
+# make check_local   ~52sec  (U:29s, S:13s)
+# make check_lvmetad ~20sec  (U: 4s, S: 5s)
+#
+# With patch from 2015-03-06:
+#
+# make check_local   ~30sec  (U:10s, S:12s)
+# make check_lvmetad ~20sec  (U: 4s, S: 5s)
+#
+
+# TODO: extend test suite to monitor performance and report regressions...
+
+# Use just 100 to get 'decent' speed on slow boxes
+LVM_TEST_PVS=${LVM_TEST_PVS:-100}
+
+#aux prepare_devs $LVM_TEST_PVS 8
+#vgcreate $vg $(< DEVICES)
+
+# prepare_vg is now directly using steps above
+aux prepare_vg $LVM_TEST_PVS
+
+# Check we have decent speed with typical commands
+vgs
+
+lvs
+
+pvs
+
+lvcreate -l1 -n $lv1 $vg
+
+lvremove -f $vg/$lv1
+
+vgremove -ff $vg
+
+# 
+# TODO Turn this into another test case:
+#
+#for i in $(seq 1 $LVM_TEST_PVS); do
+#	vgcreate ${vg}$i "$DM_DEV_DIR/mapper/${PREFIX}pv$i"
+#done


