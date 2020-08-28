From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:07 +0000 (GMT)
Subject: master - tests: check we detect lvm.conf read failure
Message-ID: <20200828195907.5F209386F039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca54afd70166b1aece6e3893e6649e67731336aa
Commit:        ca54afd70166b1aece6e3893e6649e67731336aa
Parent:        e3e04b99f21428d6392d5a430c7b7a321dbd4ed1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 27 12:55:22 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

tests: check we detect lvm.conf read failure

No coredumps with unreadable lvm.conf.
---
 test/shell/lvm-conf-error.sh | 58 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/test/shell/lvm-conf-error.sh b/test/shell/lvm-conf-error.sh
new file mode 100644
index 000000000..17b7dad97
--- /dev/null
+++ b/test/shell/lvm-conf-error.sh
@@ -0,0 +1,58 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Check what happens when reading of lvm.conf fails
+
+. lib/inittest
+
+MKFS=mkfs.ext3
+which $MKFS || skip
+which filefrag || skip
+
+aux prepare_vg 1
+
+mkdir mnt
+
+lvcreate -L5M -n $lv1 $vg
+
+$MKFS "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
+cp etc/lvm.conf mnt
+
+# Figure where the file is placed in filesystem
+filefrag -e mnt/lvm.conf | tee frags
+umount mnt
+
+# 1st. sector for filesystem
+first_extent_sector=$(get first_extent_sector "$dev1")
+
+# find 1st. 1k block of file and trim '..' from printed number
+file_block=$(awk '/0:/ { gsub(/\.\.$/, "", $4); print $4}'  frags)
+
+# figure sector position on DM device
+file_sector=$(( file_block * 2 + first_extent_sector ))
+
+aux error_dev "$dev1" $file_sector:2
+
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
+
+# force lvm to read lvm.conf from mnt path
+LVM_SYSTEM_DIR=mnt lvs 2>&1 | tee out || true
+
+# shell give nice error message
+grep "Failed to load config file mnt/lvm.conf" out
+
+aux enable_dev "$dev1"
+
+umount mnt
+
+vgremove -ff $vg


