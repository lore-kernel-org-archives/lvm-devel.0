From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Aug 2015 09:29:26 +0000 (UTC)
Subject: master - tests: update cache tests
Message-ID: <20150826092926.698B761188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0ff35c5a6665ef59a5ed86a6b7d920f909300a2
Commit:        d0ff35c5a6665ef59a5ed86a6b7d920f909300a2
Parent:        1307fafe0f72cea9b3f2e7e7fdb70b1b5d0a0670
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 25 15:10:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 26 11:24:41 2015 +0200

tests: update cache tests

---
 test/shell/lvconvert-cache.sh |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 6ac62c4..3c94ee3 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -37,11 +37,25 @@ lvcreate -an -Zn -L 8 -n $lv3 $vg
 lvcreate -an -Zn -L 8 -n $lv4 $vg
 lvcreate -an -Zn -L 16 -n $lv5 $vg
 
-lvconvert --yes --type cache-pool --cachepool $vg/$lv1
+# check validation of cachemode arg works
+fail lvconvert --yes --type cache-pool --cachemode writethroughX --cachepool $vg/$lv1
+
+# by default no cache settings are attached to converted cache-pool
+lvconvert --yes --type cache-pool --chunksize 256 $vg/$lv1
 check inactive $vg ${lv1}_cdata
-lvconvert --yes --type cache-pool --chunksize 256 $vg/$lv2
+check lv_field $vg/$lv1 cache_mode ""
+check lv_field $vg/$lv1 cache_policy ""
+check lv_field $vg/$lv1 cache_settings ""
+check lv_field $vg/$lv1 chunk_size "256.00k"
+
+# but allow to set them when specified explicitely on command line
+lvconvert --yes --type cache-pool --cachemode writeback --cachepolicy mq \
+	--cachesettings sequential_threshold=1234 --cachesettings random_threshold=56 \
+	--cachepool $vg/$lv2
 check inactive $vg ${lv2}_cdata
-check lv_field $vg/$lv2 chunk_size "256.00k"
+check lv_field $vg/$lv2 cache_mode "writeback"
+check lv_field $vg/$lv2 cache_policy "mq"
+check lv_field $vg/$lv2 cache_settings "random_threshold=56,sequential_threshold=1234"
 
 # Check swap of cache pool metadata
 lvconvert --yes --type cache-pool --poolmetadata $lv4 $vg/$lv3
@@ -58,7 +72,8 @@ lvremove -ff $vg
 
 lvcreate -L 2 -n $lv1 $vg
 lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvconvert --cache --cachepool $vg/${lv1}_cachepool --cachemode writeback $vg/$lv1
+check lv_field $vg/$lv1 cache_mode "writeback"
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 
 #lvconvert --cachepool $vg/${lv1}_cachepool $vg/$lv1


