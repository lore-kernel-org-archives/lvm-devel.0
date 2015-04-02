From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:16 +0000 (UTC)
Subject: master - tests: move exa test to separate file
Message-ID: <20150402114116.7D2926023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95dbedb301976e176315a95c34be2f3e71a281f2
Commit:        95dbedb301976e176315a95c34be2f3e71a281f2
Parent:        6d1c9a0eb814a7eca55c67cfd89bbf056c65f13e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 27 14:31:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: move exa test to separate file

Make it visible the 'exa' test passed on an arch.
---
 test/shell/snapshot-usage-exa.sh |   39 ++++++++++++++++++++++++++++++++++++++
 test/shell/snapshot-usage.sh     |   24 -----------------------
 2 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
new file mode 100644
index 0000000..ae5ca6d
--- /dev/null
+++ b/test/shell/snapshot-usage-exa.sh
@@ -0,0 +1,39 @@
+#!/bin/bash
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
+# Check very large device size (upto 15Exa bytes)
+# this needs 64bit arch
+
+. lib/inittest
+
+aux can_use_16T || skip
+
+aux prepare_pvs 1
+
+# Prepare large enough backend device
+vgcreate -s 4M $vg $(cat DEVICES)
+lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize 15P
+aux extend_filter_LVMTEST
+
+# Check usability with largest extent size
+pvcreate "$DM_DEV_DIR/$vg/$lv"
+vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"
+
+lvcreate -an -Zn -l50%FREE -n $lv1 $vg1
+lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
+check lv_field $vg1/$lv2 size "7.50p"
+lvremove -ff $vg1
+
+lvcreate --type snapshot -V15E -l1 -n $lv1 -s $vg1
+check lv_field $vg1/$lv1 origin_size "15.00e"
+
+vgremove -ff $vg1
+vgremove -ff $vg
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 74f54de..e3db1fb 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -208,27 +208,3 @@ fsck -n "$DM_DEV_DIR/$vg1/snap"
 check lv_field $vg1/snap data_percent "$EXPECT4"
 
 vgremove -ff $vg1
-
-
-# Can't test >= 16T devices on 32bit
-test "$TSIZE" = 15P || exit 0
-
-# synchronize with udev activity
-# FIXME - otherwise sequence of vgremove followed by vgcreate may fail...
-# as there could be still remaing links in /dev
-# Unusure if 'vgcreate' should do this type of detection in udev mode.
-aux udev_wait
-
-# Check usability with largest extent size
-pvcreate "$DM_DEV_DIR/$vg/$lv"
-vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"
-
-lvcreate -an -Zn -l50%FREE -n $lv1 $vg1
-lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
-check lv_field $vg1/$lv2 size "7.50p"
-lvremove -ff $vg1
-
-lvcreate --type snapshot -V15E -l1 -n $lv1 -s $vg1
-check lv_field $vg1/$lv1 origin_size "15.00e"
-
-vgremove -ff $vg1


