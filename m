From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:54 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: snapshot needs 3 chunks
Message-ID: <20130605120454.6E1B26101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09cc5f65dbe34027c91011907e25ea4c21edfd13
Commit:        09cc5f65dbe34027c91011907e25ea4c21edfd13
Parent:        6f9366696c76863662e6cb12de467b5f748c8495
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 30 17:55:44 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:56:47 2013 +0200

tests: snapshot needs 3 chunks

---
 test/shell/lvcreate-small-snap.sh |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index 9b43868..e0e6d1a 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -11,14 +11,15 @@
 
 . lib/test
 
-aux prepare_pvs 3
+aux prepare_pvs
 
-vgcreate -c n -s 1k $vg $(cat DEVICES)
+vgcreate -s 1k $vg $(cat DEVICES)
 
-lvcreate -n one -l 10 $vg
-lvcreate -s -l 8 -n snapA $vg/one
-lvcreate -s -c 4k -l 8 -n snapX1 $vg/one
-lvcreate -s -c 8k -l 16 -n snapX2 $vg/one
+# 3 Chunks
+lvcreate -aey -n one -l 10 $vg
+lvcreate -s -l 12 -n snapA $vg/one
+lvcreate -s -c 4k -l 12 -n snapX1 $vg/one
+lvcreate -s -c 8k -l 24 -n snapX2 $vg/one
 
 # Check that snapshots that are too small are caught with correct error.
 not lvcreate -s -c 8k -l 8 -n snapX3 $vg/one 2>&1 | tee lvcreate.out


