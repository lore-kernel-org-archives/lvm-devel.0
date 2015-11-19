From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 13:41:48 +0000 (UTC)
Subject: master - tests: more cache conversion checks
Message-ID: <20151119134148.E5BD460B36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da50f8bee654b029e2fc818b66765fa79a70b251
Commit:        da50f8bee654b029e2fc818b66765fa79a70b251
Parent:        795616a87bbb5fd2a3925e1445bb1a94ce718d55
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 19 14:31:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 14:40:49 2015 +0100

tests: more cache conversion checks

---
 test/shell/lvconvert-cache-raid.sh |   24 +++++++++++++++++++++++-
 test/shell/lvconvert-cache.sh      |   12 ++++++++++++
 2 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index b0d8da2..b533bdc 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -74,4 +74,26 @@ aux wait_for_sync $vg cpool_cdata
 lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
 lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 
+lvremove -f $vg
+
+
+# Test up/down raid conversion of cache pool data and metadata
+lvcreate --type cache-pool $vg/cpool -l 10
+lvcreate -n corigin -H $vg/cpool -l 20
+
+lvconvert -m+1 --type raid1 $vg/cpool_cmeta
+check lv_field $vg/cpool_cmeta layout "raid,raid1"
+check lv_field $vg/cpool_cmeta role "private,cache,pool,metadata"
+
+lvconvert -m+1 --type raid1 $vg/cpool_cdata
+check lv_field $vg/cpool_cdata layout "raid,raid1"
+check lv_field $vg/cpool_cdata role "private,cache,pool,data"
+
+lvconvert -m-1  $vg/cpool_cmeta
+check lv_field $vg/cpool_cmeta layout "linear"
+lvconvert -m-1  $vg/cpool_cdata
+check lv_field $vg/cpool_cdata layout "linear"
+
+lvremove -f $vg
+
 vgremove -f $vg
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 5a38d9c..de88032 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -135,6 +135,18 @@ fail lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$
 
 lvremove -f $vg
 
+########################
+# Repair of cache pool #
+########################
+lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
+lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
+
+# unsupported yet
+fail lvconvert --repair $vg/cpool 2>&1 | tee out
+grep "not yet implemented" out
+
+lvremove -f $vg
+
 ##########################
 # Prohibited conversions #
 ##########################


