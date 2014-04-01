From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:15 +0000 (UTC)
Subject: master - tests: update lvcreate-cache
Message-ID: <20140401185615.CC6FD60CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c95d43b28c5f89e1d96f2b16805ecd74eb4b02fb
Commit:        c95d43b28c5f89e1d96f2b16805ecd74eb4b02fb
Parent:        dc5a3c9964229a5b7a23c7ceb76523d662ddbc27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 17:52:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:54:10 2014 +0200

tests: update lvcreate-cache

---
 test/shell/lvcreate-cache.sh |   84 +++++++++++++----------------------------
 1 files changed, 27 insertions(+), 57 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 21ef5fe..302a708 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -13,18 +13,18 @@
 
 aux target_at_least dm-cache 1 3 0 || skip
 
-# Skip in cluster for now, but should test EX mode...
-test -e LOCAL_CLVMD && skip
-
 aux prepare_vg 5 80
 
+for mode in "" "--cachemode writethrough"
+do
+
 ####################
 # Cache_Pool creation
 ####################
 
 # Full CLI (the advertised form)
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvremove -ff $vg/${lv}_cache_pool
+lvcreate --type cache-pool -l 1 -n cache_pool $vg $mode
+lvremove -f $vg/cache_pool
 
 # Shorthand CLI (not advertised) -- not yet implemented
 # lvcreate --cache -l 1 vg
@@ -41,43 +41,42 @@ lvremove -ff $vg/${lv}_cache_pool
 # - then, the cache LV (lvcreate distinguishes supplied origin vs cache_pool)
 ################
 
-# Create/remove cache_pool
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvremove -ff $vg
-
 # Create cache_pool, then origin with cache, then remove all
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
+lvcreate --type cache-pool -l 1 -n cache_pool $vg
+lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
-lvremove -ff $vg
+lvremove -f $vg
 
 # Create cache_pool, then origin with cache, then remove cache_pool/cache
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
-lvremove -ff $vg/${lv}_cache_pool
-lvremove -ff $vg/$lv1
+lvcreate --type cache-pool -l 1 -n cache_pool $vg
+lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
+lvremove -f $vg/cache_pool
+lvremove -f $vg/$lv1
 
 # Create cache_pool, then origin with cache, then remove origin
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
-lvremove -ff $vg/$lv1
-lvremove -ff $vg/${lv}_cache_pool
+lvcreate --type cache-pool -l 1 -n cache_pool $vg
+lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
+lvremove -f $vg/$lv1
+lvremove -f $vg/cache_pool
 
 # Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-#lvcreate --cache -l 2 $vg/${lv}_cache_pool -n $lv1
-#lvremove -ff $vg
+#lvcreate --type cache-pool -l 1 -n cache_pool $vg
+#lvcreate --cache -l 2 $vg/cache_pool -n $lv1
+#lvremove -f $vg
 
 # Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-#lvcreate -H -l 2 $vg/${lv}_cache_pool -n $lv1
-#lvremove -ff $vg
+#lvcreate --type cache-pool -l 1 -n cache_pool $vg
+#lvcreate -H -l 2 $vg/cache_pool -n $lv1
+#lvremove -f $vg
 
+if [ 1 -eq 0 ]; then
 # Create origin, then cache_pool and cache
+# FIXME: This case needs to use lvconvert
 lvcreate -l 2 -n $lv1 $vg
-lvcreate --type cache -l 1 $vg/$lv1
+lvconvert --type cache -l 1 $vg/$lv1 $mode
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
+fi
 
 # Shorthand CLI (origin exists, create cache_pool and cache)
 #lvcreate -l 1 -n $lv1 $vg
@@ -89,36 +88,7 @@ lvremove -ff $vg
 #lvcreate -H -l 2 $vg/$lv1
 #lvremove -ff $vg
 
-
-################################################
-# Repeat key tests with 'writethrough' cachemode
-################################################
-# Create/remove cache_pool
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg --cachemode writethrough
-lvremove -ff $vg
-
-# Create cache_pool, then origin with cache, then remove all
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
-lvremove -ff $vg
-
-# Create cache_pool, then origin with cache, then remove cache_pool/cache
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
-lvremove -ff $vg/${lv}_cache_pool
-lvremove -ff $vg/$lv1
-
-# Create cache_pool, then origin with cache, then remove origin
-lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
-lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
-lvremove -ff $vg/$lv1
-lvremove -ff $vg/${lv}_cache_pool
-
-# Create origin, then cache_pool and cache
-lvcreate -l 2 -n $lv1 $vg
-lvcreate --type cache -l 1 $vg/$lv1 --cachemode writethrough
-lvremove -ff $vg
-
+done
 
 ##############################
 # Test things that should fail


