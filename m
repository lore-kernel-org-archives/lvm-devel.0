From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:34:00 +0000 (UTC)
Subject: master - tests: lvcreate external origin
Message-ID: <20141006133400.A34A76113F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52821572d507a48b7bf9b9b79e2fd765ece9c423
Commit:        52821572d507a48b7bf9b9b79e2fd765ece9c423
Parent:        de0e6029f18a78a816f3c183d42ab641001dbebe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 11:52:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:31:33 2014 +0200

tests: lvcreate external origin

Fix unsupportable case.
We cannot create thinpool and snapshot at the same time.
(-L could not have 2 meanings).
---
 test/shell/lvcreate-thin-external.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 74e5521..65401fb 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -60,8 +60,11 @@ lvcreate -s $vg/$lv2 --thinpool $vg/pool
 # Fail with --thin and --snapshot
 not lvcreate -s $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
 
-# Fail to create already existing pool
-not lvcreate -s $vg/$lv2 -L10 --thinpool $vg/pool
+# Cannot specify size and thin pool.
+# TODO: maybe with --poolsize
+invalid lvcreate -s $vg/$lv2 -L10 --thinpool $vg/pool
+invalid lvcreate -s -K $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool
+
 not lvcreate -s $vg/$lv2 --chunksize 64 --thinpool $vg/pool
 not lvcreate -s $vg/$lv2 --zero y --thinpool $vg/pool
 not lvcreate -s $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
@@ -70,7 +73,7 @@ not lvcreate -s $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
 not lvcreate -s $vg/$lv2 --thinpool $vg/newpool
 
 # Create pool and snap
-lvcreate -s -K $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool
+lvcreate -T --name $vg/$lv3 -V10 -L20 --chunksize 128 --thinpool $vg/newpool
 lvcreate -s -K $vg/$lv3 --name $vg/$lv4
 lvcreate -s -K $vg/$lv2 --name $vg/$lv5 --thinpool $vg/newpool
 # Make normal thin snapshot


