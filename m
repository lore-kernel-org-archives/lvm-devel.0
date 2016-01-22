From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Jan 2016 13:20:51 +0000 (UTC)
Subject: master - tests: add pv-check-dev-size.sh
Message-ID: <20160122132051.2E6CA60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc8f8ac0facc610c3252eb9af592b9c63a935ce2
Commit:        bc8f8ac0facc610c3252eb9af592b9c63a935ce2
Parent:        136fd8f2f642c82b132ded4b9a95b05e822e9117
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 22 13:58:35 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 22 14:16:00 2016 +0100

tests: add pv-check-dev-size.sh

---
 test/shell/pv-check-dev-size.sh |   44 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
new file mode 100644
index 0000000..8e707fe
--- /dev/null
+++ b/test/shell/pv-check-dev-size.sh
@@ -0,0 +1,44 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 1 8
+
+aux lvmconf 'metadata/check_pv_device_sizes = 1'
+
+CHECK_MSG="smaller than corresponding PV size"
+
+vgcreate $vg $dev1 2>err
+not grep "$CHECK_MSG" err
+pvs 2>err
+not grep "$CHECK_MSG" err
+vgremove -ff $vg
+
+# set PV size to 2x dev size
+pvcreate --setphysicalvolumesize 16m $dev1
+vgcreate $vg $dev1 2>err
+grep "$CHECK_MSG" err
+pvs 2>err
+grep "$CHECK_MSG" err
+vgremove -ff $vg
+
+# should be quiet if requested
+aux lvmconf 'metadata/check_pv_device_sizes = 0'
+pvcreate --setphysicalvolumesize 16m $dev1
+vgcreate $vg $dev1 2>err
+not grep "$CHECK_MSG" err
+pvs 2>err
+not grep "$CHECK_MSG" err
+
+vgremove -ff $vg


