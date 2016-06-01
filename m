From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jun 2016 15:42:22 +0000 (UTC)
Subject: master - tests: check losetup -P is correctly handled
Message-ID: <20160601154222.9A9CE60613@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5d65b4a513b322def4b6da1d498e4491c9da6d0
Commit:        a5d65b4a513b322def4b6da1d498e4491c9da6d0
Parent:        d73a83e8cf508b6d97ee937a01ebd24a678dfabc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 1 17:25:55 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 1 17:37:52 2016 +0200

tests: check losetup -P is correctly handled

Validate pvcreate will not overwrite partitioned loop device.
---
 test/shell/losetup_partscan.sh |   63 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/test/shell/losetup_partscan.sh b/test/shell/losetup_partscan.sh
new file mode 100644
index 0000000..90fafc0
--- /dev/null
+++ b/test/shell/losetup_partscan.sh
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


