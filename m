From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:32 +0000 (UTC)
Subject: master - tests: test update
Message-ID: <20150403125532.3324560353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=385457de236022b3afb1cc20cd99445a59340831
Commit:        385457de236022b3afb1cc20cd99445a59340831
Parent:        d3a591a7b30baf00d2189638532d825f32a5b913
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 14:24:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 14:54:22 2015 +0200

tests: test update

Really wait till fsck is running (sleep 2 is not ideal)
Use new  'delay_dev'.
---
 test/shell/lock-parallel.sh |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 993175f..98d3d4c 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,6 +15,7 @@
 . lib/inittest
 
 which mkfs.ext3 || skip
+which fsck || skip
 
 aux prepare_vg
 
@@ -23,12 +24,15 @@ lvcreate -l1 -n $lv2 $vg
 mkfs.ext3 "$DM_DEV_DIR/$vg/$lv1"
 
 # Slowdown PV for resized LV
-aux delay_dev "$dev1" 20 20
+aux delay_dev "$dev1" 50 50 $(get first_extent_sector "$dev1"):
 
 lvresize -L-5 -r $vg/$lv1 &
 
 # Let's wait till resize starts
-sleep 2
+for i in $(seq 1 300); do
+        pgrep fsck && break
+        sleep .1
+done
 
 lvremove -f $vg/$lv2
 


