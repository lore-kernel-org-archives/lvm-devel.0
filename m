From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:16 +0000 (UTC)
Subject: master - tests: thin lvol0 updates
Message-ID: <20130715140316.1E78860E48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=255db4c4e4d8e505bb5cf10892640cffd40ebed2
Commit:        255db4c4e4d8e505bb5cf10892640cffd40ebed2
Parent:        3498575b20c3dad46ba4e76fe8a9c3d95f75d1de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 13:37:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 16:01:29 2013 +0200

tests: thin lvol0 updates

---
 test/shell/lvcreate-thin-snap.sh |    4 +-
 test/shell/lvcreate-thin.sh      |   64 +++++++++++++++++++-------------------
 2 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 6dd16d7..701bb08 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -35,9 +35,9 @@ vgcreate $vg -s 64K $(cat DEVICES)
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
 # create thin snapshot of thin LV
-lvcreate -K -s $vg/$lv1
+lvcreate -K -s $vg/$lv1 --name snap
 # check snapshot filesystem was properly frozen before snapping
-fsck -p $DM_DEV_DIR/$vg/lvol0
+fsck -p $DM_DEV_DIR/$vg/snap
 lvcreate -K -s $vg/$lv1 --name $lv2
 lvcreate -K -s $vg/$lv1 --name $vg/$lv3
 lvcreate --type snapshot $vg/$lv1
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 8daa923..ed2631e 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -55,7 +55,7 @@ lvcreate -l1 -T $vg
 lvcreate -l1 --type thin $vg
 lvcreate -l1 --type thin-pool $vg
 
-lvremove -ff $vg/lvol0 $vg/lvol1 $vg/lvol2
+lvremove -ff $vg
 check vg_field $vg lv_count 0
 
 
@@ -67,14 +67,14 @@ lvremove -ff $vg
 
 
 # Create named pool and default thin LV
-lvcreate -L4M -V2G -T $vg/pool1
-lvcreate -L4M -V2G -T --thinpool $vg/pool2
-lvcreate -L4M -V2G -T --thinpool pool3 $vg
-lvcreate -L4M -V2G --type thin $vg/pool4
-lvcreate -L4M -V2G --type thin --thinpool $vg/pool5
-lvcreate -L4M -V2G --type thin --thinpool pool6 $vg
-
-check lv_exists $vg lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+lvcreate -L4M -V2G --name lvo1 -T $vg/pool1
+lvcreate -L4M -V2G --name lvo2 -T --thinpool $vg/pool2
+lvcreate -L4M -V2G --name lvo3 -T --thinpool pool3 $vg
+lvcreate -L4M -V2G --name lvo4 --type thin $vg/pool4
+lvcreate -L4M -V2G --name lvo5 --type thin --thinpool $vg/pool5
+lvcreate -L4M -V2G --name lvo6 --type thin --thinpool pool6 $vg
+
+check lv_exists $vg lvo1 lvo2 lvo3 lvo4 lvo5 lvo6
 lvremove -ff $vg
 
 
@@ -103,14 +103,14 @@ lvremove -ff $vg
 
 # Create default thin LV in existing pool
 lvcreate -L4M -T $vg/pool
-lvcreate -V2G -T $vg/pool
-lvcreate -V2G -T --thinpool $vg/pool
-lvcreate -V2G -T --thinpool pool $vg
-lvcreate -V2G --type thin $vg/pool
-lvcreate -V2G --type thin --thinpool $vg/pool
-lvcreate -V2G --type thin --thinpool pool $vg
+lvcreate -V2G --name lvo0 -T $vg/pool
+lvcreate -V2G --name lvo1 -T --thinpool $vg/pool
+lvcreate -V2G --name lvo2 -T --thinpool pool $vg
+lvcreate -V2G --name lvo3 --type thin $vg/pool
+lvcreate -V2G --name lvo4 --type thin --thinpool $vg/pool
+lvcreate -V2G --name lvo5 --type thin --thinpool pool $vg
 
-check lv_exists $vg lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+check lv_exists $vg lvo0 lvo1 lvo2 lvo3 lvo4 lvo5
 
 
 # Create named thin LV in existing pool
@@ -136,27 +136,27 @@ check vg_field $vg lv_count 0
 # Create thin snapshot of thinLV
 lvcreate -L10M -V10M -T $vg/pool --name lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/lv1
-lvcreate -s -K $vg/lv1
-fsck -p $DM_DEV_DIR/$vg/lvol0
-lvcreate -s -K $vg/lv1 --name lv2
-lvcreate -s -K $vg/lv1 --name $vg/lv3
-lvcreate --type snapshot -K $vg/lv1
-lvcreate --type snapshot -K $vg/lv1 --name lv4
-lvcreate --type snapshot -K $vg/lv1 --name $vg/lv5
-
-check_lv_field_modules_ thin-pool lv1 lvol0 lv2 lv3 lvol1 lv4 lv5
+lvcreate -K -s $vg/lv1 --name snap_lv1
+fsck -p $DM_DEV_DIR/$vg/snap_lv1
+lvcreate -s $vg/lv1 --name lv2
+lvcreate -s $vg/lv1 --name $vg/lv3
+lvcreate --type snapshot $vg/lv1
+lvcreate --type snapshot $vg/lv1 --name lv4
+lvcreate --type snapshot $vg/lv1 --name $vg/lv5
+
+check_lv_field_modules_ thin-pool lv1 snap_lv1 lv2 lv3 lvol1 lv4 lv5
 check vg_field $vg lv_count 8
 lvremove -ff $vg
 
 
 # Normal Snapshots of thinLV
 lvcreate -L4M -V2G -T $vg/pool --name lv1
-lvcreate -s -K $vg/lv1 -l1
-lvcreate -s -K $vg/lv1 -l1 --name lv2
-lvcreate -s -K $vg/lv1 -l1 --name $vg/lv3
-lvcreate -s -K lv1 -L4M --name $vg/lv4
+lvcreate -s $vg/lv1 -l1 --name snap_lv1
+lvcreate -s $vg/lv1 -l1 --name lv2
+lvcreate -s $vg/lv1 -l1 --name $vg/lv3
+lvcreate -s lv1 -L4M --name $vg/lv4
 
-check_lv_field_modules_ snapshot lvol0 lv2 lv3 lv4
+check_lv_field_modules_ snapshot snap_lv1 lv2 lv3 lv4
 check vg_field $vg lv_count 6
 
 lvremove -ff $vg
@@ -174,7 +174,7 @@ not lvcreate -L4M --chunksize 2G -T $vg/pool1
 
 lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
-not lvcreate -s -K $vg/lv1 -L4M -V2G --name $vg/lv4
+not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
 
 # Check we cannot create mirror and thin or thinpool together
 not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg


