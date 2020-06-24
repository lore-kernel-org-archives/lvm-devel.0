From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:47 +0000 (GMT)
Subject: master - man: update cache page
Message-ID: <20200624130247.387A83938C10@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7885dbb734de97e39dca28a38850cbb623cf57f
Commit:        b7885dbb734de97e39dca28a38850cbb623cf57f
Parent:        cca2a652d1ac2fa67677e3dca50141efa8e2c1a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 12:19:54 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

man: update cache page

Few more sentences around migration threshold.
---
 man/lvmcache.7_main | 55 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 51 insertions(+), 4 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 244ea1e48..37d0e3359 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -129,6 +129,17 @@ attached.
   LV   VG Attr       Type   Devices    
   fast vg -wi------- linear /dev/fast_ssd
   main vg -wi------- linear /dev/slow_hhd
+
+To stop caching the main LV and also remove unneeded cache pool,
+use the --uncache:
+
+.nf
+  $ lvconvert --uncache vg/main
+
+  $ lvs -a
+  LV   VG Attr       Type   Devices
+  main vg -wi------- linear /dev/slow_hhd
+
 .fi
 
 .SS Create a new LV with caching.
@@ -170,8 +181,10 @@ same fast LV.  This option can be used with dm-writecache or dm-cache.
 
 Pass this option a cachepool LV or a standard LV.  When using a cache
 pool, lvm places cache data and cache metadata on different LVs.  The two
-LVs together are called a cache pool.  This permits specific placement of
-data and metadata.  A cache pool is represented as a special type of LV
+LVs together are called a cache pool.  This has a bit better performance
+for dm-cache and permits specific placement and segment type selection
+for data and metadata volumes.
+A cache pool is represented as a special type of LV
 that cannot be used directly.  If a standard LV is passed with this
 option, lvm will first convert it to a cache pool by combining it with
 another LV to use for metadata.  This option can be used with dm-cache.
@@ -361,11 +374,16 @@ $ lvconvert --type cache --cachevol fast \\
 
 The size of data blocks managed by dm-cache can be specified with the
 --chunksize option when caching is started.  The default unit is KiB.  The
-value must be a multiple of 32KiB between 32KiB and 1GiB.
+value must be a multiple of 32KiB between 32KiB and 1GiB. Cache chunks
+bigger then 512KiB shall be only used when necessary.
 
 Using a chunk size that is too large can result in wasteful use of the
 cache, in which small reads and writes cause large sections of an LV to be
-stored in the cache.  However, choosing a chunk size that is too small
+stored in the cache. It can also require increasing migration threshold
+which defaults to 2048 sectors (1 MiB). Lvm2 ensures migration threshold is
+at least 8 chunks in size. This may in some cases result in very
+high bandwidth load of transfering data between the cache LV and its
+cache origin LV. However, choosing a chunk size that is too small
 can result in more overhead trying to manage the numerous chunks that
 become mapped into the cache.  Overhead can include both excessive CPU
 time searching for chunks, and excessive memory tracking chunks.
@@ -383,6 +401,35 @@ The default value is shown by:
 .br
 .B lvmconfig --type default allocation/cache_pool_chunk_size
 
+Checking migration threshold (in sectors) of running cached LV:
+.br
+.B lvs -o+kernel_cache_settings VG/LV
+
+
+.SS dm-cache migration threshold
+
+\&
+
+Migrating data between the origin and cache LV uses bandwidth.
+The user can set a throttle to prevent more than a certain amount of
+migration occurring at any one time.  Currently dm-cache is not taking any
+account of normal io traffic going to the devices.
+
+User can set migration threshold via cache policy settings as
+"migration_threshold=<#sectors>" to set the maximum number
+of sectors being migrated, the default being 2048 sectors (1MiB).
+
+Command to set migration threshold to 2MiB (4096 sectors):
+.br
+.B lvcreate --cachepolicy 'migration_threshold=4096' VG/LV
+
+
+Command to display the migration threshold:
+.br
+.B lvs -o+kernel_cache_settings,cache_settings VG/LV
+.br
+.B lvs -o+chunksize VG/LV
+
 
 .SS dm-cache cache policy
 


