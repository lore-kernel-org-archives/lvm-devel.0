From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:44 +0000 (UTC)
Subject: master - tests: add lv-ancestry.sh test
Message-ID: <20160303132044.116076033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a78c258ba8da349059138618858856f66cb7fed
Commit:        9a78c258ba8da349059138618858856f66cb7fed
Parent:        45c82260db1c25f3885ea0e2185d7c3e7c33ed26
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:32:32 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

tests: add lv-ancestry.sh test

---
 test/shell/lv-ancestry.sh |  226 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 226 insertions(+), 0 deletions(-)

diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
new file mode 100644
index 0000000..febaf40
--- /dev/null
+++ b/test/shell/lv-ancestry.sh
@@ -0,0 +1,226 @@
+#!/bin/sh
+
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
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+aux prepare_pvs 1 16
+
+aux lvmconf "metadata/record_lvs_history=1"
+
+vgcreate $vg -s 64K $(cat DEVICES)
+
+lvcreate -l100%FREE -T ${vg}/pool
+
+# Thin snap chain with 2 branches starting at lv3.
+#
+# lv1 --> lv2 --> lv3 --> lv4 --> lv5
+#                    \
+#                     --> lv6 --> lv7
+
+lvcreate -V1 -T ${vg}/pool -n lv1
+lvcreate -s ${vg}/lv1 -n lv2
+lvcreate -s ${vg}/lv2 -n lv3
+lvcreate -s ${vg}/lv3 -n lv4
+lvcreate -s ${vg}/lv4 -n lv5
+lvcreate -s ${vg}/lv3 -n lv6
+lvcreate -s ${vg}/lv6 -n lv7
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "lv2,lv3,lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/lv2 full_ancestors "lv1"
+check lvh_field ${vg}/lv2 full_descendants "lv3,lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/lv3 full_ancestors "lv2,lv1"
+check lvh_field ${vg}/lv3 full_descendants "lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/lv4 full_ancestors "lv3,lv2,lv1"
+check lvh_field ${vg}/lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "lv4,lv3,lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/lv6 full_ancestors "lv3,lv2,lv1"
+check lvh_field ${vg}/lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "lv6,lv3,lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+
+# lv1 --> lv2 --> lv3 --> -lv4 --> lv5
+#                    \
+#                     -->  lv6 --> lv7
+lvremove -ff ${vg}/lv4
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "lv2,lv3,lv6,lv7,-lv4,lv5"
+
+check lvh_field ${vg}/lv2 full_ancestors "lv1"
+check lvh_field ${vg}/lv2 full_descendants "lv3,lv6,lv7,-lv4,lv5"
+
+check lvh_field ${vg}/lv3 full_ancestors "lv2,lv1"
+check lvh_field ${vg}/lv3 full_descendants "lv6,lv7,-lv4,lv5"
+
+check lvh_field ${vg}/-lv4 full_ancestors "lv3,lv2,lv1"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,lv3,lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/lv6 full_ancestors "lv3,lv2,lv1"
+check lvh_field ${vg}/lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "lv6,lv3,lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+
+# lv1 --> lv2 --> -lv3 --> -lv4 --> lv5
+#                     \
+#                      -->  lv6 --> lv7
+lvremove -ff ${vg}/lv3
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "lv2,-lv3,-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/lv2 full_ancestors "lv1"
+check lvh_field ${vg}/lv2 full_descendants "-lv3,-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/-lv3 full_ancestors "lv2,lv1"
+check lvh_field ${vg}/-lv3 full_descendants "-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv3,lv2,lv1"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv3,lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/lv6 full_ancestors "-lv3,lv2,lv1"
+check lvh_field ${vg}/lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "lv6,-lv3,lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+# lv1 --> -lv2 --> -lv3 --> -lv4 --> lv5
+#                      \
+#                       -->  lv6 --> lv7
+lvremove -ff $vg/lv2
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "-lv2,-lv3,-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/-lv2 full_ancestors "lv1"
+check lvh_field ${vg}/-lv2 full_descendants "-lv3,-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/-lv3 full_ancestors "-lv2,lv1"
+check lvh_field ${vg}/-lv3 full_descendants "-lv4,lv5,lv6,lv7"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv3,-lv2,lv1"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv3,-lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/lv6 full_ancestors "-lv3,-lv2,lv1"
+check lvh_field ${vg}/lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "lv6,-lv3,-lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+# lv1 --> -lv2 --> -lv3 --> -lv4 --> lv5
+#                      \
+#                       --> -lv6 --> lv7
+lvremove -ff ${vg}/lv6
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "-lv2,-lv3,-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv2 full_ancestors "lv1"
+check lvh_field ${vg}/-lv2 full_descendants "-lv3,-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv3 full_ancestors "-lv2,lv1"
+check lvh_field ${vg}/-lv3 full_descendants "-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv3,-lv2,lv1"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv3,-lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/-lv6 full_ancestors "-lv3,-lv2,lv1"
+check lvh_field ${vg}/-lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "-lv6,-lv3,-lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+# lv1 --> -lv2 -----------> -lv4 --> lv5
+#                      \
+#                       --> -lv6 --> lv7
+lvremove -ff ${vg}/-lv3
+
+check lvh_field ${vg}/lv1 full_ancestors ""
+check lvh_field ${vg}/lv1 full_descendants "-lv2,-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv2 full_ancestors "lv1"
+check lvh_field ${vg}/-lv2 full_descendants "-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv2,lv1"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv2,lv1"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/-lv6 full_ancestors "-lv2,lv1"
+check lvh_field ${vg}/-lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "-lv6,-lv2,lv1"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+#  -lv2 -----------> -lv4 --> lv5
+#               \
+#                --> -lv6 --> lv7
+
+lvremove --nohistory -ff ${vg}/lv1
+
+check lvh_field ${vg}/-lv2 full_ancestors ""
+check lvh_field ${vg}/-lv2 full_descendants "-lv4,lv5,-lv6,lv7"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv2"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv2"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/-lv6 full_ancestors "-lv2"
+check lvh_field ${vg}/-lv6 full_descendants "lv7"
+
+check lvh_field ${vg}/lv7 full_ancestors "-lv6,-lv2"
+check lvh_field ${vg}/lv7 full_descendants ""
+
+#  -lv2 -----------> -lv4 --> lv5
+#
+#                             lv7
+lvremove --nohistory -ff ${vg}/-lv6
+
+check lvh_field ${vg}/-lv2 full_ancestors ""
+check lvh_field ${vg}/-lv2 full_descendants "-lv4,lv5"
+
+check lvh_field ${vg}/-lv4 full_ancestors "-lv2"
+check lvh_field ${vg}/-lv4 full_descendants "lv5"
+
+check lvh_field ${vg}/lv5 full_ancestors "-lv4,-lv2"
+check lvh_field ${vg}/lv5 full_descendants ""
+
+check lvh_field ${vg}/lv7 full_ancestors ""
+check lvh_field ${vg}/lv7 full_descendants ""
+
+vgremove -ff $vg


