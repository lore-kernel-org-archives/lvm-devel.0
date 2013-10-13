From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:31:04 +0000 (UTC)
Subject: master - tests: lvcreate and snapshot update
Message-ID: <20131013223104.5A0EC60CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f55d7ccccb2c274f31760d1c97286ee03e24e4c
Commit:        0f55d7ccccb2c274f31760d1c97286ee03e24e4c
Parent:        9f8f6bfefe0636880a1d70c8f7c99ff9938eb5eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 23:59:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 00:29:03 2013 +0200

tests: lvcreate and snapshot update

Test creation really in cluster.
Update test to check removal when snapshot device is being held open.
---
 test/shell/lvcreate-usage.sh |   16 ++++++++--------
 test/shell/snapshot-usage.sh |   34 +++++++++++++++++++++++++++++++++-
 2 files changed, 41 insertions(+), 9 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 7f32bbc..105fbce 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,7 +15,7 @@
 
 aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 "$dev1"
-vgcreate -cn $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 
 # "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
 lvcreate -n $lv -l 4 $vg 
@@ -58,7 +58,7 @@ test -z "$(lvdisplay $vg)"
 # Setting max_lv works. (bz490298)
 lvremove -ff $vg
 vgchange -l 3 $vg
-lvcreate -l1 -n $lv1 $vg
+lvcreate -aey -l1 -n $lv1 $vg
 lvcreate -l1 -s -n $lv2 $vg/$lv1
 lvcreate -l1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
@@ -71,7 +71,7 @@ not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
 lvremove -ff $vg/$lv3
-lvcreate -l1 --type mirror -m1 -n $lv3 $vg
+lvcreate -aey -l1 --type mirror -m1 -n $lv3 $vg
 vgs -o +max_lv $vg
 not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
@@ -90,8 +90,8 @@ vgchange -l 0 $vg
 # lvcreate rejects invalid chunksize, accepts between 4K and 512K
 # validate origin_size
 vgremove -ff $vg
-vgcreate -cn $vg $(cat DEVICES)
-lvcreate -L 32m -n $lv1 $vg
+vgcreate $vg $(cat DEVICES)
+lvcreate -aey -L 32m -n $lv1 $vg
 not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
 not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
 lvcreate -L 8m -n $lv2 -s --chunksize 4k $vg/$lv1
@@ -111,10 +111,10 @@ not lvcreate -L 32m -n $lv -R0 $vg 2>err
 grep "Non-zero region size must be supplied." err
 not lvcreate -L 32m -n $lv -R 11k $vg
 not lvcreate -L 32m -n $lv -R 1k $vg
-lvcreate -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
+lvcreate -aey -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "32.00m"
 lvremove -ff $vg
-lvcreate -L 32m -n $lv --regionsize 4m --type mirror -m 1 $vg
+lvcreate -aey -L 32m -n $lv --regionsize 4m --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "4.00m"
 lvremove -ff $vg
 
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 9c1c2f6..d7a602b 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -17,6 +17,12 @@ fill() {
 	dd if=/dev/zero of=$DM_DEV_DIR/$vg1/lvol0 bs=$1 count=1
 }
 
+cleanup_tail()
+{
+	test -z "$SLEEP_PID" || kill $SLEEP_PID
+	aux teardown
+}
+
 aux prepare_pvs 1
 vgcreate -s 4M $vg $(cat DEVICES)
 
@@ -30,6 +36,32 @@ aux lvmconf "activation/snapshot_autoextend_percent = 20" \
 pvcreate --setphysicalvolumesize 4T $DM_DEV_DIR/$vg/$lv
 vgcreate -s 1K $vg1 $DM_DEV_DIR/$vg/$lv
 
+# Test removal of opened snapshot
+lvcreate -V50 -L10 -n $lv1 -s $vg1
+
+lvs -a -o+lv_active $vg1
+lvchange -an $vg1
+
+# Snapshot get exclusive activation
+lvchange -ay $vg1
+lvs -a -o+lv_active $vg1
+
+trap 'cleanup_tail' EXIT
+# Keep device busy (but not mounted) for a while
+sleep 30 < $DM_DEV_DIR/$vg1/$lv1 &
+SLEEP_PID=$!
+
+# Opened virtual snapshot device is not removable
+# it should retry device removal for a few seconds
+not lvremove -f $vg1/$lv1
+
+kill $SLEEP_PID
+SLEEP_PID=
+
+lvremove -f $vg1/$lv1
+not dmsetup info $vg1-$lv1 >/dev/null || \
+	die "$vg1/$lv1 expected to be removed, but there are mappings!"
+
 # Check border size
 lvcreate -aey -L4095G $vg1
 lvcreate -s -L100K $vg1/lvol0
@@ -79,7 +111,7 @@ lvcreate -an -Zn -l50%FREE -n $lv1 $vg1
 lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
 check lv_field $vg1/$lv2 size "7.50p"
 lvremove -ff $vg1
- 
+
 lvcreate -aey -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 


