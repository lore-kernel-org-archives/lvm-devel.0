From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:17 +0000 (UTC)
Subject: master - tests: resize of filesystem
Message-ID: <20160713195617.263BB60370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07587c2699b04058b6dd044adb69c854a6458e24
Commit:        07587c2699b04058b6dd044adb69c854a6458e24
Parent:        deb6f6a06c2fa25b1c9aa4c6eeb9529ce7c5c4c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 13 21:15:34 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

tests: resize of filesystem

Test for https://bugzilla.redhat.com/1354396
---
 test/shell/lvresize-full.sh |   69 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
new file mode 100644
index 0000000..17ee6aa
--- /dev/null
+++ b/test/shell/lvresize-full.sh
@@ -0,0 +1,69 @@
+#!/bin/sh
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
+# Excersize resize of filesystem when size of LV already matches
+# https://bugzilla.redhat.com/1354396
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+FSCK=${FSCK-fsck}
+MKFS=${MKFS-mkfs.ext3}
+RESIZEFS=${RESIZEFS-resize2fs}
+
+which $FSCK || skip
+which $MKFS || skip
+which $RESIZEFS || skip
+
+aux prepare_vg 2 20
+
+lvcreate -l100%FREE -n $lv1 $vg
+
+lvdev="$DM_DEV_DIR/$vg/$lv1"
+
+lvs -a $vg
+
+"$MKFS" "$lvdev"
+
+# this should resolve to resize to same actual size
+lvreduce -r -f -l-100%FREE $vg/$lv1
+"$FSCK" -n "$lvdev"
+
+# size should remain the same
+lvextend -r -f -l+100%FREE $vg/$lv1
+"$FSCK" -n "$lvdev"
+
+#lvchange -an $vg/$lv1
+lvresize -r -f -l+100%FREE $vg/$lv1
+"$FSCK" -n "$lvdev"
+
+# Check there is really file system resize happening
+# even when LV itself has still the same size
+"$RESIZEFS" -f "$lvdev" 20000
+"$FSCK" -n "$lvdev" | tee out
+grep "20000 blocks" out
+
+SIZE=$(get lv_field $vg/$lv1 size)
+lvresize -r -f -l-100%FREE $vg/$lv1
+test "$SIZE" = "$(get lv_field $vg/$lv1 size)"
+
+"$FSCK" -n "$lvdev" | tee out
+grep -v "20000 blocks" out
+
+
+# Also check it fails when the user 'resize' volume without
+# resizing fs and then retries with '-r'.
+lvreduce -f -l50%VG $vg/$lv1
+fail lvresize -r -f -l50%VG $vg/$lv1
+
+lvremove -ff $vg


