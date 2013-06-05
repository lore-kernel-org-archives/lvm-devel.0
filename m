From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:07 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: min snap chunk count is 3
Message-ID: <20130605120507.0425E61398@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c83c159631dd9be40d47da168ce1c77423798b9
Commit:        1c83c159631dd9be40d47da168ce1c77423798b9
Parent:        31f3274ed8a81cbf6c25c7bc6307e58894f436a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 11:01:59 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:42:31 2013 +0200

tests: min snap chunk count is 3

---
 test/api/percent.sh |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index 07b8bc6..8f7d5da 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,14 +15,14 @@
 
 kernel_at_least 2 6 33 || skip
 
-aux prepare_devs 2
+aux prepare_pvs 2
 
-vgcreate -c n -s 4k $vg $(cat DEVICES)
-lvcreate -l 5 -n foo $vg
-lvcreate -s -n snap $vg/foo -l 2 -c 4k
+vgcreate -s 4k $vg $(cat DEVICES)
+lvcreate -aey -l 5 -n foo $vg
+lvcreate -s -n snap $vg/foo -l 3 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024
-lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
+lvcreate -aey -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs $vg
 aux apitest percent $vg
 


