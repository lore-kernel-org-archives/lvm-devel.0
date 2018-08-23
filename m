From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 23 Aug 2018 05:30:02 -0400
Subject: 2018-06-01-stable - test: add striped -> raid0 test script
Message-ID: <201808230930.w7N9U2kQ011316@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab1aa0a4fb9b422b177bba35f1bd96fda2330189
Commit:        ab1aa0a4fb9b422b177bba35f1bd96fda2330189
Parent:        d910f75d89e02e46cd16f9ddbc8e8358c3c2efd3
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Aug 22 17:11:03 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 23 11:29:24 2018 +0200

test: add striped -> raid0 test script

(cherry picked from commit 3c966e637fe1bec587ceb9ad13aa009db64b4f8e)
---
 test/shell/lvconvert-striped-raid0.sh |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-striped-raid0.sh b/test/shell/lvconvert-striped-raid0.sh
new file mode 100644
index 0000000..5cfb792
--- /dev/null
+++ b/test/shell/lvconvert-striped-raid0.sh
@@ -0,0 +1,25 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 7 0 || skip
+
+aux prepare_vg 3 16
+
+lvcreate -aey --type striped -i 3 -l3 -n $lv $vg
+lvconvert -y --type raid0_meta $vg/$lv
+check lv_field $vg/$lv segtype "raid0_meta"
+vgremove -ff $vg


