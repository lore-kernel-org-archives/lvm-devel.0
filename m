From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  2 Mar 2014 19:54:28 +0000 (UTC)
Subject: master - test: Test that we cope with stray device nodes.
Message-ID: <20140302195428.5052A6118D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fade191aed03a9ec5027e9a61d8f39439bc01239
Commit:        fade191aed03a9ec5027e9a61d8f39439bc01239
Parent:        3b958984f185fdbc220085b9faef04d11ae6ecf4
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 2 20:45:37 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Sun Mar 2 20:53:43 2014 +0100

test: Test that we cope with stray device nodes.

---
 test/shell/stray-device-node.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
new file mode 100644
index 0000000..70677a7
--- /dev/null
+++ b/test/shell/stray-device-node.sh
@@ -0,0 +1,21 @@
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
+aux prepare_devs 3
+cp -r $dev1 $DM_DEV_DIR/stray
+
+vgcreate $vg $dev1 $dev2 $dev3
+lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
+aux disable_dev "$dev1"
+vgreduce --removemissing --force $vg
+aux enable_dev "$dev1"


