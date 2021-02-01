From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:45 +0000 (GMT)
Subject: main - tests: check for cache support presence
Message-ID: <20210201114745.5F9E13836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b26e565ee5d27314a58cba31e0a017d927698440
Commit:        b26e565ee5d27314a58cba31e0a017d927698440
Parent:        19ddad12cae6b8c6a8011876302dd968ae3ddbeb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 18:45:00 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

tests: check for cache support presence

---
 test/shell/dev-aliases.sh | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/shell/dev-aliases.sh b/test/shell/dev-aliases.sh
index c97cd5da2..c3e4c7c53 100644
--- a/test/shell/dev-aliases.sh
+++ b/test/shell/dev-aliases.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,9 +14,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_devs 3
+aux have_cache 1 10 0 || skip
 
-vgcreate $vg $dev1 $dev2 $dev3
+aux prepare_vg 3
 
 #
 # This lvconvert command will deactivate LV1, then internally create a new
@@ -37,13 +37,13 @@ vgcreate $vg $dev1 $dev2 $dev3
 # wiping code would fail to open that stale name.
 #
 
-lvcreate -n $lv1 -L32M $vg $dev1
-lvcreate -n $lv2 -L16M $vg $dev2
+lvcreate -n $lv1 -L32M $vg "$dev1"
+lvcreate -n $lv2 -L16M $vg "$dev2"
 lvconvert -y --type cache-pool --poolmetadata $lv2 --cachemode writeback $vg/$lv1 --config='devices { preferred_names=["/dev/mapper/"] }' 
 lvremove -y $vg/$lv1
 
-lvcreate -n $lv1 -L32M $vg $dev1
-lvcreate -n $lv2 -L16M $vg $dev2
+lvcreate -n $lv1 -L32M $vg "$dev1"
+lvcreate -n $lv2 -L16M $vg "$dev2"
 lvconvert -y --type cache-pool --poolmetadata $lv2 $vg/$lv1
 lvremove -y $vg/$lv1
 


