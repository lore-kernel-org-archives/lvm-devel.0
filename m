From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 22:02:08 -0500
Subject: master - test: raid1 down convert to linear / split and track tests
Message-ID: <201703090302.v29328jF002059@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d1df10af381bd1ae87be2209b1a7ff0d1167793
Commit:        3d1df10af381bd1ae87be2209b1a7ff0d1167793
Parent:        d250aa7208a6211d54cb2264b767fc3d2063eff8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 04:01:47 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 04:01:47 2017 +0100

test: raid1 down convert to linear / split and track tests

Add/adjust tests for commits d250aa7208a6 and 7fbe6ef16bfb.
---
 test/shell/lvconvert-raid.sh      |   27 +++++++++++++++++++++++++--
 test/shell/lvconvert-thin-raid.sh |   10 +++++++---
 2 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 8538c41..b5bfede 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -72,7 +72,19 @@ for i in 1 2 3; do
 			lvcreate -aey -s $vg/$lv1 -n snap -l 2
 		fi
 
-		lvconvert -m $((j - 1)) $vg/$lv1
+		mirrors=$((j - 1))
+		if [ $i -eq 1 ]
+		then
+			[ $mirrors -eq 0 ] && lvconvert -m $mirrors $vg/$lv1
+		else
+			if [ $mirrors -eq 0 ]
+			then
+				not lvconvert -m $mirrors $vg/$lv1
+				lvconvert -y -m $mirrors $vg/$lv1
+			else
+				lvconvert -m $mirrors $vg/$lv1
+			fi
+		fi
 
 		# FIXME: ensure no residual devices
 
@@ -160,6 +172,17 @@ not fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
+# Check split track changes gets rejected w/o -y on 2-legged raid1
+lvcreate --type raid1 -m 1 -l 1 -n $lv1 $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
+aux wait_for_sync $vg $lv1
+fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
+not lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
+lvconvert -y --splitmirrors 1 --trackchanges $vg/$lv1
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
 ###########################################
 # Linear to RAID1 conversion ("raid1" default segtype)
 ###########################################
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 33e5b6d..7890350 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -39,11 +39,15 @@ lvchange -ay $vg
 
 lvconvert --splitmirrors 1 --name data2 $vg/${lv1}_tdata "$dev2"
 lvconvert --splitmirrors 1 --name data3 $vg/${lv1}_tdata "$dev3"
-lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tdata "$dev4"
+# Check split and track gets rejected on 2-legged raid1
+not lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tdata "$dev4"
+lvconvert -y --splitmirrors 1 --trackchanges $vg/${lv1}_tdata "$dev4"
 
 lvconvert --splitmirrors 1 --name meta1 $vg/${lv1}_tmeta "$dev1"
 lvconvert --splitmirrors 1 --name meta2 $vg/${lv1}_tmeta "$dev2"
-lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tmeta "$dev4"
+# Check split and track gets rejected on 2-legged raid1
+not lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tmeta "$dev4"
+lvconvert -y --splitmirrors 1 --trackchanges $vg/${lv1}_tmeta "$dev4"
 
 lvremove -ff $vg/data2 $vg/data3 $vg/meta1 $vg/meta2
 


