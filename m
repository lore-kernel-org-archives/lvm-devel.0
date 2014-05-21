From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:12 +0000 (UTC)
Subject: master - tests: raid and dmeventd
Message-ID: <20140521225612.19CD560DF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2da0f0a5b5b99c10c2ea531b63a3d9466eb1832
Commit:        b2da0f0a5b5b99c10c2ea531b63a3d9466eb1832
Parent:        37b4dc777590ed0e6771833dce4c0727dfc72465
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:13:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:42 2014 +0200

tests: raid and dmeventd

---
 test/shell/lvconvert-repair-raid-dmeventd.sh |   28 ++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
new file mode 100644
index 0000000..a825aa2
--- /dev/null
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
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
+. lib/test
+
+which mkfs.ext3 || skip
+
+aux prepare_dmeventd
+aux prepare_vg 5
+
+lvcreate -aey --type raid1 -m 3 --ignoremonitoring -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+lvs -a -o all,lv_modules $vg
+lvdisplay --maps $vg
+aux disable_dev "$dev2" "$dev4"
+mkfs.ext3 "$DM_DEV_DIR/$vg/4way"
+sleep 10 # FIXME: need a "poll" utility, akin to "check"
+aux enable_dev "$dev2" "$dev4"
+
+vgremove -ff $vg


