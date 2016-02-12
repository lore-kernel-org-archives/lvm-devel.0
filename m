From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Feb 2016 15:30:47 +0000 (UTC)
Subject: master - man: pvresize: remove old comment about inability to resize PV with more mdas
Message-ID: <20160212153047.7D9B5605B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=672deaebc55464015065c2101a3de03e02190e01
Commit:        672deaebc55464015065c2101a3de03e02190e01
Parent:        337aa4ca8ef4e88c09567b47838e28688258ae44
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 16:29:39 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 12 16:29:47 2016 +0100

man: pvresize: remove old comment about inability to resize PV with more mdas

---
 man/pvresize.8.in           |    3 +--
 test/shell/pvresize-mdas.sh |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/man/pvresize.8.in b/man/pvresize.8.in
index 2cc1183..8b78651 100644
--- a/man/pvresize.8.in
+++ b/man/pvresize.8.in
@@ -46,8 +46,7 @@ free space, like
 does.
 .sp
 .B pvresize
-won't currently work correctly on LVM1 volumes or PVs with extra
-metadata areas.
+won't currently work correctly on LVM1 volumes.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvmove (8),
diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
new file mode 100644
index 0000000..96d0381
--- /dev/null
+++ b/test/shell/pvresize-mdas.sh
@@ -0,0 +1,26 @@
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
+aux prepare_devs 1 8
+
+pvcreate --setphysicalvolumesize 8m --metadatacopies 2 "$dev1"
+check pv_field "$dev1" pv_size 8.00m
+check pv_field "$dev1" pv_mda_count 2
+pvs "$dev1"
+
+pvresize --setphysicalvolumesize 4m "$dev1"
+check pv_field "$dev1" pv_size 4.00m
+check pv_field "$dev1" pv_mda_count 2
+pvs "$dev1"


