From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:56 +0000 (UTC)
Subject: master - tests: lvcreate cache interface updates
Message-ID: <20141006133356.4A1F760DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4baf4b8cf982a3ead10b9644b5c04ec3575e3009
Commit:        4baf4b8cf982a3ead10b9644b5c04ec3575e3009
Parent:        b7a78d81bc52b8a9078bd9d57ab900032f8e5729
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 19:02:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:08 2014 +0200

tests: lvcreate cache interface updates

---
 test/shell/lvcreate-cache.sh |  160 +++++++++++++++++++++++++++---------------
 1 files changed, 103 insertions(+), 57 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 84c9c88..63591c4 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -9,30 +9,72 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+# Exercise creation of cache and cache pool volumes
+
+# Full CLI uses  --type
+# Shorthand CLI uses --cache | -H
+
 . lib/inittest
 
 aux have_cache 1 3 0 || skip
 
-aux prepare_vg 5 80
+# FIXME: parallel cache metadata allocator is crashing when used value 8000!
+aux prepare_vg 5 80000
 
-for mode in "" "--cachemode writethrough"
-do
+#######################
+# Cache_Pool creation #
+#######################
 
-####################
-# Cache_Pool creation
-####################
+# FIXME: Unsupported yet creation of cache pool and cached volume at once
+# needs some policy to determine cache pool size
+invalid lvcreate -H -l 1 $vg
+invalid lvcreate --cache -l 1 $vg
+invalid lvcreate --type cache -l 1 $vg
 
-# Full CLI (the advertised form)
-lvcreate --type cache-pool -l 1 -n cache_pool $vg $mode
-lvremove -f $vg/cache_pool
+# Unlike in thin pool case - cache pool and cached volume both need size arg.
+# So we require cache pool to exist and need to fail when it's missing.
+#
+# FIXME: introduce  --poolsize to make this command possible to pass
+fail lvcreate -l 1 -H --cachepool $vg/pool3
+fail lvcreate -l 1 -H --cachepool pool4 $vg
+fail lvcreate -l 1 --type cache --cachepool $vg/pool5
+fail lvcreate -l 1 --type cache --cachepool pool6 $vg
+# --cachpool bring implicit --cache
+fail lvcreate -l 1 --cachepool pool7 $vg
+
+# Check nothing has been created yet
+check vg_field $vg lv_count 0
+
+# If the cache pool volume doesn't yet exist -> cache pool creation
+lvcreate -l 1 -H $vg/pool1
+lvcreate -l 1 --type cache $vg/pool2
+
+# With cache-pool we are clear what has to be created
+lvcreate -l 1 --type cache-pool $vg/pool3
+lvcreate -l 1 --type cache-pool --cachepool $vg/pool4
+lvcreate -l 1 --type cache-pool --cachepool pool5 $vg
+lvcreate -l 1 --type cache-pool --name pool6 $vg
+lvcreate -l 1 --type cache-pool --name $vg/pool7
+
+check lv_field $vg/pool1 segtype "cache-pool"
+check lv_field $vg/pool2 segtype "cache-pool"
+check lv_field $vg/pool3 segtype "cache-pool"
+check lv_field $vg/pool4 segtype "cache-pool"
+check lv_field $vg/pool5 segtype "cache-pool"
+check lv_field $vg/pool6 segtype "cache-pool"
+check lv_field $vg/pool7 segtype "cache-pool"
+
+lvremove -f $vg
 
-# Shorthand CLI (not advertised) -- not yet implemented
-# lvcreate --cache -l 1 vg
-# lvremove -ff $vg
+# Validate ambiguos pool name is detected
+invalid lvcreate -l 1 --type cache-pool --cachepool pool1 $vg/pool2
+invalid lvcreate -l 1 --type cache-pool --name pool3 --cachepool pool4 $vg
+invalid lvcreate -l 1 --type cache-pool --name pool6 --cachepool pool6 $vg/pool7
+invalid lvcreate -l 1 --type cache-pool --name pool8 $vg/pool9
+check vg_field $vg lv_count 0
 
-# Shorthand CLI (not advertised) -- not yet implemented
-# lvcreate -H -l 1 vg
-# lvremove -ff $vg
+for mode in "" "--cachemode writethrough"
+do
 
 ################
 # Cache creation
@@ -41,68 +83,72 @@ lvremove -f $vg/cache_pool
 # - then, the cache LV (lvcreate distinguishes supplied origin vs cache_pool)
 ################
 
-# Create cache_pool, then origin with cache, then remove all
-lvcreate --type cache-pool -l 1 -n cache_pool $vg
-lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
+lvcreate --type cache-pool -l 1 -n pool $vg $mode
+# Select automatic name for cached LV
+lvcreate --type cache -l1 $vg/pool
+
+lvcreate --type cache-pool -l 1 -n pool1 $vg $mode
+lvcreate --cache -l1 -n $lv1 --cachepool $vg/pool1
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
-lvremove -f $vg
 
-# Create cache_pool, then origin with cache, then remove cache_pool/cache
-lvcreate --type cache-pool -l 1 -n cache_pool $vg
-lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
-lvremove -f $vg/cache_pool
-lvremove -f $vg/$lv1
+lvcreate --type cache-pool -l 1 -n pool2 $vg $mode
+lvcreate -H -l1 -n $lv2 --cachepool pool2 $vg
 
-# Create cache_pool, then origin with cache, then remove origin
-lvcreate --type cache-pool -l 1 -n cache_pool $vg
-lvcreate --type cache -l 2 $vg/cache_pool -n $lv1 $mode
+#
+# Now check removals
+#
+
+# Removal of cached LV removes every related LV
+check lv_field $vg/$lv1 segtype "cache"
 lvremove -f $vg/$lv1
-lvremove -f $vg/cache_pool
+check lv_not_exists $vg $lv1 pool1 pool1_cdata pool1_cmeta
+# to preserve cachepool use  lvconvert --splitcache $vg/$lv1
+
+# Removal of cache pool leaves origin uncached
+check lv_field $vg/$lv2 segtype "cache"
+lvremove -f $vg/pool2
+check lv_not_exists $vg pool2 pool2_cdata pool2_cmeta
+check lv_field $vg/$lv2 segtype "linear"
 
-# Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache-pool -l 1 -n cache_pool $vg
-#lvcreate --cache -l 2 $vg/cache_pool -n $lv1
-#lvremove -f $vg
+lvremove -f $vg
 
-# Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache-pool -l 1 -n cache_pool $vg
-#lvcreate -H -l 2 $vg/cache_pool -n $lv1
-#lvremove -f $vg
+done
 
+# Conversion through lvcreate case
 # Bug 1110026
-# Create origin, then cache_pool and cache
+# Create origin, then cache pool and cache the origin
 lvcreate -aey -l 2 -n $lv1 $vg
 lvcreate --type cache -l 1 $vg/$lv1
-#should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
-lvremove -ff $vg
+dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 
 # Bug 1110026 & Bug 1095843
-# Create RAID1 origin, then cache_pool and cache
-lvcreate -aey -l 2 -n $lv1 $vg
-lvcreate --type cache -l 1 $vg/$lv1
-#should lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
-#should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
-lvremove -ff $vg
+# Create RAID1 origin, then cache pool and cache
+lvcreate -aey -l 2 --type raid1 -m1 -n $lv2 $vg
+lvcreate --cache -l 1 $vg/$lv2
+check lv_exists $vg/${lv2}_corig_rimage_0	# ensure images are properly renamed
+dmsetup table ${vg}-$lv2 | grep cache		# ensure it is loaded in kernel
 
-# Shorthand CLI (origin exists, create cache_pool and cache)
-#lvcreate -l 1 -n $lv1 $vg
-#lvcreate --cache -l 2 $vg/$lv1
-#lvremove -ff $vg
+lvremove -f $vg
 
-# Shorthand CLI (origin exists, create cache_pool and cache)
-#lvcreate -l 1 -n $lv1 $vg
-#lvcreate -H -l 2 $vg/$lv1
-#lvremove -ff $vg
 
-done
+# Check minimum cache pool metadata size
+lvcreate -l 1 --type cache-pool --poolmetadatasize 1 $vg 2>out
+grep "WARNING: Minimum" out
+
+# FIXME: This test is failing in allocator with smaller VG sizes
+lvcreate -l 1 --type cache-pool --poolmetadatasize 17G $vg 2>out
+grep "WARNING: Maximum" out
+
+lvremove -f $vg
+
 
 ##############################
 # Test things that should fail
 ##############################
 
-# Attempt to create smaller cache than origin should fail
-lvcreate -aey -l 1 -n $lv1 $vg
-not lvcreate --type cache -l 2 $vg/$lv1
+# Atempt to use bigger chunk size then cache pool data size
+fail lvcreate -l 1 --type cache-pool --chunksize 16M $vg 2>out
+grep "is bigger" out
 
 # Option testing
 # --chunksize


