From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Feb 2016 09:22:52 +0000 (UTC)
Subject: master - tests: update test
Message-ID: <20160212092252.AB97160E35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a077a649837b6d60d892516e32be8854bfb57ee7
Commit:        a077a649837b6d60d892516e32be8854bfb57ee7
Parent:        befe0078ad15563967d8b8321638c75a4f25f438
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 12 10:21:07 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 12 10:21:07 2016 +0100

tests: update test

Upgrade test to count with much faster dmeventd work thanks
to low_watter_mark support.

Fix some wrong tests.
---
 test/shell/thin-autoumount-dmeventd.sh |   47 +++++++++++++++++++++-----------
 1 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 781a27e..6b7c7c1 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,9 +15,9 @@ SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
-is_dir_mounted_()
+is_lv_opened_()
 {
-	cat /proc/mounts | sed 's:\\040: :g' | grep "$1"
+	test $(get lv_field "$1" lv_device_open --binary) = "1"
 }
 
 . lib/inittest
@@ -31,6 +31,7 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_dmeventd
 
+# Use autoextend percent 0 - so extension fails and triggers umount...
 aux lvmconf "activation/thin_pool_autoextend_percent = 0" \
             "activation/thin_pool_autoextend_threshold = 70"
 
@@ -51,24 +52,38 @@ mkdir "$mntdir" "$mntusedir"
 mount "$DM_DEV_DIR/mapper/$vg-$lv1" "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-$lv2" "$mntusedir"
 
-is_dir_mounted_ "$mntdir"
+# Check both LVs are opened (~mounted)
+is_lv_opened_ "$vg/$lv1"
+is_lv_opened_ "$vg/$lv2"
 
-# fill above 70%
-dd if=/dev/zero of="$mntdir/file$$" bs=1M count=6
 touch "$mntusedir/file$$"
-tail -f "$mntusedir/file$$" &
-PID_TAIL=$!
 sync
-lvs -a $vg
-sleep 12 # dmeventd only checks every 10 seconds :(
 
-lvs -a $vg
-# both dirs should be unmounted
-not is_dir_mounted "$mntdir"
-not is_dir_mounted "$mntusedir"
+# Running 'keeper' process sleep holds the block device still in use
+sleep 60 < "$mntusedir/file$$" &
+PID_SLEEP=$!
 
-# running tail keeps the block device still in use
-kill $PID_TAIL
+# Fill pool above 70%
+dd if=/dev/zero of="$mntdir/file$$" bs=1M count=6 conv=fdatasync
 lvs -a $vg
 
+# Could loop here for a few secs so dmeventd can do some work
+# In the worst case check only happens every 10 seconds :(
+# With low water mark it should react way faster
+for i in $(seq 1 12) ; do
+	is_lv_opened_ "$vg/$lv1" || break
+	test $i -lt 12 || die "$mntdir should have been unmounted by dmeventd!"
+        sleep 1
+done
+
+is_lv_opened_ "$vg/$lv2" || \
+	die "$mntusedir is not mounted here (sleep already expired??) "
+
+# Kill device holding process
+kill $PID_SLEEP
+wait
+
+is_lv_opened_ "$vg/$lv2" && \
+	{ mount; die "$mntusedir should have been unmounted by dmeventd!" }
+
 vgremove -f $vg


