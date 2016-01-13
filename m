From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:57 +0000 (UTC)
Subject: master - test: add report-invisible.sh test
Message-ID: <20160113134657.E402360679@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efab21b4115d1cc79c3b02c64cd15f360176c3cb
Commit:        efab21b4115d1cc79c3b02c64cd15f360176c3cb
Parent:        c66a83fdc380f7a4f694481cb3d78d52ce888fa4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 14:17:50 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 14:37:09 2016 +0100

test: add report-invisible.sh test

---
 test/shell/report-invisible.sh |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/test/shell/report-invisible.sh b/test/shell/report-invisible.sh
new file mode 100644
index 0000000..d906c97
--- /dev/null
+++ b/test/shell/report-invisible.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 1
+lvcreate --type mirror -m1 -l1 --alloc anywhere -n $lv1 $vg
+
+aux lvmconf 'log/prefix=""'
+
+aux lvmconf "report/mark_invisible_devices = 0"
+lvs --noheadings -a -o name $vg > out
+grep "^${lv1}_mimage_0" out
+not grep "^\[${lv1}_mimage_0\]" out
+lvs --noheadings -a -o devices $vg/$lv1 > out
+grep "^${lv1}_mimage_0" out
+not grep "^\[${lv1}_mimage_0\]" out
+
+aux lvmconf "report/mark_invisible_devices = 1"
+lvs --noheadings -a -o name $vg > out
+grep "^\[${lv1}_mimage_0\]" out
+not grep "^${lv1}_mimage_0" out
+lvs --noheadings -a -o devices $vg/$lv1 > out
+grep "^\[${lv1}_mimage_0\]" out
+not grep "^${lv1}_mimage_0" out
+
+vgremove -ff $vg


