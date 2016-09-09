From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:27 +0000 (UTC)
Subject: master - tests: rename test _ -> -
Message-ID: <20160909190027.D30886066E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75a42845c196e0717ac77209fc063718d0d36744
Commit:        75a42845c196e0717ac77209fc063718d0d36744
Parent:        6166cea5bf211501715a314dd891f27096e3bfe7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 16:11:35 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:59:21 2016 +0200

tests: rename test  _ -> -

Change '_' in the test name.
---
 test/shell/losetup-partscan.sh |   63 ++++++++++++++++++++++++++++++++++++++++
 test/shell/losetup_partscan.sh |   63 ----------------------------------------
 2 files changed, 63 insertions(+), 63 deletions(-)

diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
new file mode 100644
index 0000000..90fafc0
--- /dev/null
+++ b/test/shell/losetup-partscan.sh
@@ -0,0 +1,63 @@
+#!/bin/bash
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
+# Check how lvm2 handles partitions over losetup -P devices
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which sfdisk || skip
+
+aux prepare_loop 1000 -P || skip
+
+test -f LOOP
+LOOP=$(< LOOP)
+
+echo "1 2" | sfdisk $LOOP
+
+# wait for links
+aux udev_wait
+
+# losetup -P should provide partition
+ls -la "${LOOP}"*
+test -e "${LOOP}p1"
+
+aux extend_filter "a|$LOOP|"
+
+# creation should fail for 'partitioned' loop device
+not pvcreate -y $LOOP
+not vgcreate vg $LOOP
+
+aux teardown_devs
+
+aux prepare_loop 1000 || skip
+
+test -f LOOP
+LOOP=$(< LOOP)
+
+
+echo "1 2" | sfdisk $LOOP
+
+# wait for links
+aux udev_wait
+
+# no partitione should be actually there
+ls -la "${LOOP}"*
+test ! -e "${LOOP}p1"
+
+aux extend_filter "a|$LOOP|"
+
+# creation should pass for 'non-partitioned' loop device
+pvcreate -y $LOOP
+
+vgcreate vg $LOOP
diff --git a/test/shell/losetup_partscan.sh b/test/shell/losetup_partscan.sh
deleted file mode 100644
index 90fafc0..0000000
--- a/test/shell/losetup_partscan.sh
+++ /dev/null
@@ -1,63 +0,0 @@
-#!/bin/bash
-# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# Check how lvm2 handles partitions over losetup -P devices
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-which sfdisk || skip
-
-aux prepare_loop 1000 -P || skip
-
-test -f LOOP
-LOOP=$(< LOOP)
-
-echo "1 2" | sfdisk $LOOP
-
-# wait for links
-aux udev_wait
-
-# losetup -P should provide partition
-ls -la "${LOOP}"*
-test -e "${LOOP}p1"
-
-aux extend_filter "a|$LOOP|"
-
-# creation should fail for 'partitioned' loop device
-not pvcreate -y $LOOP
-not vgcreate vg $LOOP
-
-aux teardown_devs
-
-aux prepare_loop 1000 || skip
-
-test -f LOOP
-LOOP=$(< LOOP)
-
-
-echo "1 2" | sfdisk $LOOP
-
-# wait for links
-aux udev_wait
-
-# no partitione should be actually there
-ls -la "${LOOP}"*
-test ! -e "${LOOP}p1"
-
-aux extend_filter "a|$LOOP|"
-
-# creation should pass for 'non-partitioned' loop device
-pvcreate -y $LOOP
-
-vgcreate vg $LOOP


