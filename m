From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:27 +0000 (UTC)
Subject: master - test: update lvm1 test
Message-ID: <20160419164927.149286108B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9cf85f606d14bcffdbdfaf19e0fa3a8e8b2a5d3
Commit:        c9cf85f606d14bcffdbdfaf19e0fa3a8e8b2a5d3
Parent:        2a17610899f6dc5d5e5acf5f0a4b427f2cdfeea8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 19 09:18:31 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:19 2016 -0500

test: update lvm1 test

Make it a generic lvm1 test, which should work
with or without lvmetad now that lvmetad is just
disabled when lvm1 is used.
---
 test/shell/lvm1-basic.sh   |   35 +++++++++++++++++++++++++++++++++++
 test/shell/lvmetad-lvm1.sh |   39 ---------------------------------------
 2 files changed, 35 insertions(+), 39 deletions(-)

diff --git a/test/shell/lvm1-basic.sh b/test/shell/lvm1-basic.sh
new file mode 100644
index 0000000..8884bc1
--- /dev/null
+++ b/test/shell/lvm1-basic.sh
@@ -0,0 +1,35 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 2
+pvcreate --metadatatype 1 "$dev1"
+pvs | tee out
+grep "$dev1" out
+vgcreate --metadatatype 1 $vg1 "$dev1"
+vgs | tee out
+grep $vg1 out
+pvs | tee out
+grep "$dev1" out
+
+# check for RHBZ 1080189 -- SEGV in lvremove/vgremove
+pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
+vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
+lvcreate -l1 $vg1
+pvremove -ff -y "$dev2"
+vgchange -an $vg1
+not lvremove $vg1
+not vgremove -ff -y $vg1
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
deleted file mode 100644
index 824c1d5..0000000
--- a/test/shell/lvmetad-lvm1.sh
+++ /dev/null
@@ -1,39 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-# lvmetad does not support lvm1 format
-
-aux prepare_devs 2
-pvcreate --metadatatype 1 "$dev1"
-should not vgscan --cache
-pvs | tee out
-not grep "$dev1" out
-vgcreate --metadatatype 1 $vg1 "$dev1"
-should not vgscan --cache
-vgs | tee out
-not grep $vg1 out
-pvs | tee out
-not grep "$dev1" out
-
-# check for RHBZ 1080189 -- SEGV in lvremove/vgremove
-pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
-vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
-lvcreate -l1 $vg1
-pvremove -ff -y "$dev2"
-vgchange -an $vg1
-not lvremove $vg1
-not vgremove -ff -y $vg1


