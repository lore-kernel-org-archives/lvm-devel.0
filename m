From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:46:04 +0000 (UTC)
Subject: master - tests: check dmsetup remove --force
Message-ID: <20150918154604.131FF606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83a52c07b7c7f36a084a21cce148061c1e77cd21
Commit:        83a52c07b7c7f36a084a21cce148061c1e77cd21
Parent:        7d1dd5f52d26ebe15dd6de211001ece975be2c7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 17:34:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:46 2015 +0200

tests: check dmsetup remove --force

---
 test/shell/snapshot-remove-dmsetup.sh |   65 +++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
new file mode 100644
index 0000000..b5aad1f
--- /dev/null
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -0,0 +1,65 @@
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
+# check if 'dmsetup --noflush' will work properly for mounted snapshot
+
+. lib/inittest
+
+which mkfs.ext2 || skip
+
+test -e LOCAL_LVMETAD && skip
+test -e LOCAL_LVMPOLLD && skip
+test -e LOCAL_CLVMD && skip
+
+aux prepare_vg 5
+
+# Create stacked device
+lvcreate --type snapshot -s -L10 -n $lv1 $vg --virtualsize 100M
+aux extend_filter_LVMTEST
+vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv1
+
+
+lvcreate -L20 -n $lv1 $vg1
+lvcreate -L10 -n snap -s $vg1/$lv1
+
+mkfs.ext2 "$DM_DEV_DIR/$vg1/snap"
+mkdir mnt
+mount -o errors=remount-ro "$DM_DEV_DIR/$vg1/snap" mnt
+
+# intetionally suspend layer bellow
+dmsetup suspend $vg-$lv1
+
+# now this should pass without blocking
+dmsetup suspend --noflush --nolockfs $vg1-snap
+
+# unlock device below
+dmsetup resume $vg-$lv1
+# so this will pass without blocking on udev
+# otherwise --noudevsync would be needed
+dmsetup resume $vg1-snap
+
+
+# Try how force removal works
+dmsetup suspend $vg-$lv1
+# needs to fail as device is still open
+not dmsetup remove --force $vg1-snap
+dmsetup resume $vg-$lv1
+
+# check it really is now 'error' target
+dmsetup table $vg1-snap | tee out
+grep error out
+
+umount mnt || true
+
+lvremove -f $vg1
+
+vgremove -ff $vg1
+vgremove -ff $vg


