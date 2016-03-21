From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Mar 2016 15:21:47 +0000 (UTC)
Subject: master - tests: add vg-check-devs-used.sh
Message-ID: <20160321152147.E3F21605F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc57cd39ab0e47a3e0fc6fc81c378c4d4d292093
Commit:        cc57cd39ab0e47a3e0fc6fc81c378c4d4d292093
Parent:        8fad9b9e5d219861fc1f758216fb446cffe3817f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 21 16:21:30 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 21 16:21:30 2016 +0100

tests: add vg-check-devs-used.sh

---
 test/shell/vg-check-devs-used.sh |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
new file mode 100644
index 0000000..b368227
--- /dev/null
+++ b/test/shell/vg-check-devs-used.sh
@@ -0,0 +1,24 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
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
+aux prepare_devs 3 8
+
+vgcreate $vg $dev1 $dev2
+lvcreate -l100%FREE -n $lv $vg
+dd if="$dev1" of="$dev3" bs=1M
+pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
+grep "WARNING: Device mismatch detected for $vg/$lv which is accessing $dev1 instead of $dev3" err
+
+vgremove -ff $vg


