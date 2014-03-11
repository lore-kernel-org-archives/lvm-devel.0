From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:29 +0000 (UTC)
Subject: master - tests: check we are no reading pool device
Message-ID: <20140311233429.4E59F60EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2c64e21fd1c32205eb2aff554459a5a6db0aac4
Commit:        a2c64e21fd1c32205eb2aff554459a5a6db0aac4
Parent:        dd690d5fd1253d7559d43c60194ec0139d426d79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 12 00:26:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:26:47 2014 +0100

tests: check we are no reading pool device

---
 test/shell/pvremove-thin.sh |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
new file mode 100644
index 0000000..03e6ca3
--- /dev/null
+++ b/test/shell/pvremove-thin.sh
@@ -0,0 +1,28 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Checks we are not reading our own devices
+# https://bugzilla.redhat.com/show_bug.cgi?id=1064374
+
+. lib/test
+
+aux prepare_vg
+
+aux target_at_least dm-thin-pool 1 8 0 || skip
+
+aux extend_filter_LVMTEST
+
+lvcreate -L10 -V10 -n $lv1 -T $vg/pool1
+
+pvcreate "$DM_DEV_DIR/$vg/$lv1"
+pvremove "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -ff $vg


