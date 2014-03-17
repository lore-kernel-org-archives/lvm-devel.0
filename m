From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 14:19:42 +0000 (UTC)
Subject: master - tests: update error message check
Message-ID: <20140317141942.15126610C0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae2d80dd7e3379e62be610e56114ebba02a0eac2
Commit:        ae2d80dd7e3379e62be610e56114ebba02a0eac2
Parent:        e398901ed1d77684155a52c464f6265f68a96562
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 15:18:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 15:18:02 2014 +0100

tests: update error message check

---
 test/shell/lvcreate-small-snap.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index e0e6d1a..33532db 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -24,8 +24,8 @@ lvcreate -s -c 8k -l 24 -n snapX2 $vg/one
 # Check that snapshots that are too small are caught with correct error.
 not lvcreate -s -c 8k -l 8 -n snapX3 $vg/one 2>&1 | tee lvcreate.out
 not grep "suspend origin one" lvcreate.out
-grep "Unable to create a snapshot" lvcreate.out
+grep "smaller" lvcreate.out
 
 not lvcreate -s -l 4 -n snapB $vg/one 2>&1 | tee lvcreate.out
 not grep "suspend origin one" lvcreate.out
-grep "Unable to create a snapshot" lvcreate.out
+grep "smaller" lvcreate.out


