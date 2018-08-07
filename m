From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:01:23 -0400
Subject: master - tests: splitmirror for mirror type
Message-ID: <201808071601.w77G1NIV026863@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1310242550e28dfe7c386a78435235955963c95
Commit:        d1310242550e28dfe7c386a78435235955963c95
Parent:        acab59137869e2f8119d8faa09fdab5074b8c4b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 10:34:59 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 17:59:50 2018 +0200

tests: splitmirror for mirror type

---
 test/shell/lvconvert-mirror-split.sh |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror-split.sh b/test/shell/lvconvert-mirror-split.sh
new file mode 100644
index 0000000..40720a4
--- /dev/null
+++ b/test/shell/lvconvert-mirror-split.sh
@@ -0,0 +1,32 @@
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
+# Check --splitmirrors for mirror segtype
+
+. lib/inittest
+
+aux prepare_vg 3
+
+###########################################
+# Mirror split tests
+###########################################
+# 3-way to 2-way/linear
+lvcreate --type mirror -m 2 -l 2 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvconvert --splitmirrors 1 -n $lv2 -vvvv $vg/$lv1
+
+check lv_exists $vg $lv1
+check linear $vg $lv2
+check active $vg $lv2
+# FIXME: ensure no residual devices
+
+vgremove -ff $vg


