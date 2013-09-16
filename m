From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 11:48:51 +0000 (UTC)
Subject: master - tests: update vgcfgrestore test
Message-ID: <20130916114851.D2034610DB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2abaf87a9b36cff2f32398a8dfb26609c0f56e14
Commit:        2abaf87a9b36cff2f32398a8dfb26609c0f56e14
Parent:        9742c5192e8871ebde12856170dae70ee861ef40
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 13:46:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 13:48:44 2013 +0200

tests: update vgcfgrestore test

Test vgcfgrestore when seqno of restored mda is smaller then current
metadata on device.
---
 test/shell/vgcfgbackup-usage.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 7a1e530..b04ac86 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -18,9 +18,12 @@ vg1=${PREFIX}vg00
 vg2=${PREFIX}vg01
 vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev2"
-vgcfgbackup -f $TESTDIR/bak-%s >out
+vgcfgbackup -f bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
+# increase seqno
+lvcreate -l1 $vg1
+vgcfgrestore -f bak-$vg1 $vg1
 vgremove -ff $vg1 $vg2
 
 # vgcfgbackup correctly stores metadata with missing PVs


