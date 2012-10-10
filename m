From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 10 Oct 2012 16:49:36 +0000 (UTC)
Subject: master - TEST: Add lvchange-partial.sh and vgchange-partial.sh to the test suite
Message-ID: <20121010164936.72B04A1043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b296e30f98dc0bab12e8a184f0a93b69cbe291f8
Commit:        b296e30f98dc0bab12e8a184f0a93b69cbe291f8
Parent:        3501f17fd0fcec2a1fbb8aeecf228e86ee022d99
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Oct 10 11:47:04 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Oct 10 11:47:04 2012 -0500

TEST:  Add lvchange-partial.sh and vgchange-partial.sh to the test suite

Commit 3501f17fd0fcec2a1fbb8aeecf228e86ee022d99 enables a limited set
of metadata updates for partial LV/VGs when issuing lvchange or vgchange.
These tests verify those changes operate as intended.
---
 test/shell/lvchange-partial.sh |   66 ++++++++++++++++++++++++++++++++++++++++
 test/shell/vgchange-partial.sh |   52 +++++++++++++++++++++++++++++++
 2 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
new file mode 100644
index 0000000..fe642d4
--- /dev/null
+++ b/test/shell/lvchange-partial.sh
@@ -0,0 +1,66 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+aux target_at_least dm-raid 1 1 0 || skip
+
+aux prepare_vg 2
+
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvchange -an $vg/$lv1
+aux disable_dev "$dev1"
+
+#
+# Test for allowable metadata changes
+#
+# contiguous_ARG
+lvchange -C y $vg/$lv1
+lvchange -C n $vg/$lv1
+
+# permission_ARG
+lvchange -p r $vg/$lv1
+lvchange -p rw $vg/$lv1
+
+# readahead_ARG
+lvchange -r none $vg/$lv1
+lvchange -r auto $vg/$lv1
+
+# persistent_ARG
+lvchange -M y --minor 56 --major 253 $vg/$lv1
+lvchange -M n $vg/$lv1
+
+# addtag_ARG
+# deltag_ARG
+lvchange --addtag foo $vg/$lv1
+lvchange --deltag foo $vg/$lv1
+
+#
+# Test for disallowed metadata changes
+#
+# resync_ARG
+not lvchange --resync $vg/$lv1
+
+# alloc_ARG
+not lvchange --alloc anywhere $vg/$lv1
+
+# discards_ARG
+not lvchange --discards ignore $vg/$lv1
+
+# zero_ARG
+not lvchange --zero y $vg/$lv1
+
+#
+# Ensure that allowed args don't cause disallowed args to get through
+#
+not lvchange --resync -ay $vg/$lv1
+not lvchange --resync --addtag foo $vg/$lv1
+
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
new file mode 100644
index 0000000..5b21a40
--- /dev/null
+++ b/test/shell/vgchange-partial.sh
@@ -0,0 +1,52 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+aux prepare_vg 2
+
+aux disable_dev "$dev1"
+
+#
+# Test for allowable metadata changes
+# addtag_ARG
+# deltag_ARG
+vgchange --addtag foo $vg
+vgchange --deltag foo $vg
+
+#
+# Test for disallowed metadata changes
+#
+# maxphysicalvolumes_ARG
+not vgchange -p 10 $vg
+
+# resizeable_ARG
+not vgchange -x n $vg
+
+# uuid_ARG
+not vgchange -u $vg
+
+# physicalextentsize_ARG
+not vgchange -s 2M $vg
+
+# clustered_ARG
+not vgchange -c y $vg
+
+# alloc_ARG
+not vgchange --alloc anywhere $vg
+
+# vgmetadatacopies_ARG
+not vgchange --vgmetadatacopies 2 $vg
+
+#
+# Ensure that allowed args don't cause disallowed args to get through
+#
+not vgchange -p 10 --addtag foo $vg


