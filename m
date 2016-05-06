From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:11 +0000 (UTC)
Subject: master - test: vgcfgbackup-lvm1
Message-ID: <20160506140111.AE3D760722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa130722cbe3f7ac7f80fce4bcd3c3dc12d6897e
Commit:        fa130722cbe3f7ac7f80fce4bcd3c3dc12d6897e
Parent:        f194d5f169f6977eb0e4ffeb4924cdcb6c8dcf77
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 26 12:21:49 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: vgcfgbackup-lvm1

The lvm1 part of vgcfgbackup-usage.
---
 test/shell/vgcfgbackup-lvm1.sh |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
new file mode 100644
index 0000000..4a7f32a
--- /dev/null
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -0,0 +1,36 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 4
+
+if test -n "$LVM_TEST_LVM1" ; then
+
+pvcreate --metadatacopies 0 "$dev4"
+
+# No automatic backup
+aux lvmconf "backup/backup = 0"
+
+# vgcfgbackup correctly stores metadata LVM1 with missing PVs
+
+pvcreate -M1 $(cat DEVICES)
+vgcreate -M1 -c n $vg $(cat DEVICES)
+lvcreate -l1 -n $lv1 $vg "$dev1"
+pvremove -ff -y "$dev2"
+not lvcreate -l1 -n $lv1 $vg "$dev3"
+vgcfgbackup -f "backup.$$" $vg
+
+fi
+


