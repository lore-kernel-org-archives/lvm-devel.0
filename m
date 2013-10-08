From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 14:20:31 +0000 (UTC)
Subject: master - tests: reappering device
Message-ID: <20131008142032.0305060E64@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ee969e8514d7d7310990308a242b210e55a9113
Commit:        2ee969e8514d7d7310990308a242b210e55a9113
Parent:        2f5ddfbadea5dae6b2fc236d4f243bd88d955aa8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 16:19:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 16:19:14 2013 +0200

tests: reappering device

Simulation of problem for:
https://bugzilla.redhat.com/show_bug.cgi?id=995440
---
 test/shell/lvmcache-exercise.sh |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index b1e2b92..5ea6381 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,10 +14,23 @@
 aux prepare_pvs 5
 
 vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev3"
+vgcreate $vg2 "$dev3" "$dev4" "$dev5"
 
 aux disable_dev "$dev1"
 pvscan
 vgcreate $vg1 "$dev2"
 aux enable_dev "$dev1"
 pvs
+
+# reappearing device (rhbz 995440)
+lvcreate -aey -m2 --type mirror -l4 --alloc anywhere --corelog -n $lv1 $vg2
+
+aux disable_dev "$dev3"
+lvconvert --yes --repair $vg2/$lv1
+aux enable_dev "$dev3"
+
+# here it should fix any reappeared devices
+lvconvert --yes --repair $vg2/$lv1
+
+lvs -a $vg2 -o+devices 2>&1 | tee out
+not grep reappeared out


