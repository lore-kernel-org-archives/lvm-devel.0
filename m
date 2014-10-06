From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:58 +0000 (UTC)
Subject: master - tests: lvcreate thin-pool support --name
Message-ID: <20141006133358.88E6260DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de0e6029f18a78a816f3c183d42ab641001dbebe
Commit:        de0e6029f18a78a816f3c183d42ab641001dbebe
Parent:        4baf4b8cf982a3ead10b9644b5c04ec3575e3009
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 5 20:00:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:08 2014 +0200

tests: lvcreate thin-pool support --name

---
 test/shell/lvcreate-thin.sh |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 215bfac..42ea635 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -50,6 +50,30 @@ lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/poo
 check vg_field $vg lv_count 0
 
 
+# Let's pretend pool is like normal LV when using --type thin-pool support --name
+# Reject ambigous thin pool names
+invalid lvcreate --type thin-pool -l1 --name pool1 $vg/pool2
+invalid lvcreate --type thin-pool -l1 --name pool3 --thinpool pool4 $vg
+invalid lvcreate --type thin-pool -l1 --name pool5 --thinpool pool6 $vg/pool7
+invalid lvcreate --type thin-pool -l1 --name pool8 --thinpool pool8 $vg/pool9
+check vg_field $vg lv_count 0
+
+lvcreate --type thin-pool -l1 --name pool1 $vg
+lvcreate --type thin-pool -l1 --name $vg/pool2
+# If the thin pool name is unambigous let it proceed
+lvcreate --type thin-pool -l1 --name pool3 $vg/pool3
+lvcreate --type thin-pool -l1 --name pool4 --thinpool $vg/pool4
+lvcreate --type thin-pool -l1 --name pool5 --thinpool $vg/pool5 $vg/pool5
+
+check lv_field $vg/pool1 segtype "thin-pool"
+check lv_field $vg/pool2 segtype "thin-pool"
+check lv_field $vg/pool3 segtype "thin-pool"
+check lv_field $vg/pool4 segtype "thin-pool"
+check lv_field $vg/pool5 segtype "thin-pool"
+
+lvremove -ff $vg
+
+
 # Create default pool name
 lvcreate -l1 -T $vg
 lvcreate -l1 --type thin $vg


