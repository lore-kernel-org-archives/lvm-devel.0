From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:54 +0000 (GMT)
Subject: dev-next - man: describe profile support lvmcache.7
Message-ID: <20210331214954.95DAA3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff5776024f056aeff0f1dac9f028e55761e7c24b
Commit:        ff5776024f056aeff0f1dac9f028e55761e7c24b
Parent:        2aaea13aaa2935905a6d1cb32db4e2cd477c22f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 29 18:55:47 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:08:14 2021 +0200

man: describe profile support lvmcache.7

Add missing description for profile usage with cache pool.
List cache-pools as first option for dm-cache as it provides
better performance and more functionality over cachevols.
---
 man/lvmcache.7_main | 160 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 112 insertions(+), 48 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 85d4d9e34..182dc0a79 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -63,17 +63,21 @@ To start caching the main LV, convert the main LV to the desired caching
 type, and specify the fast LV to use as the cache:
 
 .nf
-using dm-cache:
+using dm-cache (with cachepool):
+
+  $ lvconvert --type cache --cachepool fast vg/main
+
+using dm-cache (with cachevol):
 
   $ lvconvert --type cache --cachevol fast vg/main
 
-using dm-writecache:
+using dm-writecache (with cachevol):
 
   $ lvconvert --type writecache --cachevol fast vg/main
 
-using dm-cache (with cachepool):
-
-  $ lvconvert --type cache --cachepool fast vg/main
+For more alteratives see:
+dm-cache command shortcut
+dm-cache with separate data and metadata LVs
 .fi
 
 .B 4. Display LVs
@@ -85,31 +89,31 @@ suffix.  It is displayed by lvs -a.  The _corig or _wcorig LV represents
 the original LV without the cache.
 
 .nf
-using dm-cache:
+using dm-cache (with cachepool):
 
-  $ lvs -a
-  LV           Pool        Type   Devices       
-  main         [fast_cvol] cache  main_corig(0) 
+  $ lvs -ao+devices
+  LV                 Pool         Type       Devices
+  main               [fast_cpool] cache      main_corig(0)
+  [fast_cpool]                    cache-pool fast_pool_cdata(0)
+  [fast_cpool_cdata]              linear     /dev/fast_ssd
+  [fast_cpool_cmeta]              linear     /dev/fast_ssd
+  [main_corig]                    linear     /dev/slow_hhd
+
+using dm-cache (with cachevol):
+
+  $ lvs -ao+devices
+  LV           Pool        Type   Devices
+  main         [fast_cvol] cache  main_corig(0)
   [fast_cvol]              linear /dev/fast_ssd
   [main_corig]             linear /dev/slow_hhd
 
-using dm-writecache:
+using dm-writecache (with cachevol):
 
-  $ lvs -a
-  LV            Pool        Type       Devices       
+  $ lvs -ao+devices
+  LV            Pool        Type       Devices
   main          [fast_cvol] writecache main_wcorig(0)
   [fast_cvol]               linear     /dev/fast_ssd
   [main_wcorig]             linear     /dev/slow_hhd
-
-using dm-cache (with cachepool):
-
-  $ lvs -a
-  LV                 Pool         Type       Devices        
-  main               [fast_cpool] cache      main_corig(0)  
-  [fast_cpool]                    cache-pool fast_pool_cdata(0)  
-  [fast_cpool_cdata]              linear     /dev/fast_ssd
-  [fast_cpool_cmeta]              linear     /dev/fast_ssd
-  [main_corig]                    linear     /dev/slow_hhd
 .fi
 
 .B 5. Use the main LV
@@ -118,26 +122,26 @@ Use the LV until the cache is no longer wanted, or needs to be changed.
 
 .B 6. Stop caching
 
-To stop caching the main LV, separate the fast LV from the main LV.  This
-changes the type of the main LV back to what it was before the cache was
-attached.
+To stop caching the main LV and also remove unneeded cache pool,
+use the --uncache:
 
 .nf
-  $ lvconvert --splitcache vg/main
+  $ lvconvert --uncache vg/main
 
   $ lvs -a
-  LV   VG Attr       Type   Devices    
-  fast vg -wi------- linear /dev/fast_ssd
+  LV   VG Attr       Type   Devices
   main vg -wi------- linear /dev/slow_hhd
 
-To stop caching the main LV and also remove unneeded cache pool,
-use the --uncache:
+To stop caching the main LV, separate the fast LV from the main LV.  This
+changes the type of the main LV back to what it was before the cache was
+attached.
 
 .nf
-  $ lvconvert --uncache vg/main
+  $ lvconvert --splitcache vg/main
 
   $ lvs -a
   LV   VG Attr       Type   Devices
+  fast vg -wi------- linear /dev/fast_ssd
   main vg -wi------- linear /dev/slow_hhd
 
 .fi
@@ -167,14 +171,6 @@ for the fast LV.
 
 \&
 
-.B --cachevol
-.I LV
-.br
-
-Pass this option a fast LV that should be used to hold the cache.  With a
-cachevol, cache data and metadata are stored in different parts of the
-same fast LV.  This option can be used with dm-writecache or dm-cache.
-
 .B --cachepool
 .IR CachePoolLV | LV
 .br
@@ -189,6 +185,14 @@ that cannot be used directly.  If a standard LV is passed with this
 option, lvm will first convert it to a cache pool by combining it with
 another LV to use for metadata.  This option can be used with dm-cache.
 
+.B --cachevol
+.I LV
+.br
+
+Pass this option a fast LV that should be used to hold the cache.  With a
+cachevol, cache data and metadata are stored in different parts of the
+same fast LV.  This option can be used with dm-writecache or dm-cache.
+
 .B --cachedevice
 .I PV
 .br
@@ -318,10 +322,25 @@ cleaner mode, and any required flushing is performed in device suspend.
 
 \&
 
-When using dm-cache, the cache metadata and cache data can be stored on
-separate LVs.  To do this, a "cache pool" is created, which is a special
+Preferred way of using dm-cache is to place the cache metadata and cache data
+on separate LVs.  To do this, a "cache pool" is created, which is a special
 LV that references two sub LVs, one for data and one for metadata.
 
+To create a cache pool of given data size and let lvm2 calculate appropriate
+metadata size:
+
+.nf
+$ lvcreate --type cache-pool -L DataSize -n fast vg /dev/fast_ssd1
+.fi
+
+To create a cache pool from separate LV and let lvm2 calculate
+appropriate cache metadata size:
+
+.nf
+$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+$ lvconvert --type cache-pool vg/fast /dev/fast_ssd1
+.fi
+
 To create a cache pool from two separate LVs:
 
 .nf
@@ -374,8 +393,12 @@ mode can be displayed with the cache_mode reporting option:
 defines the default cache mode.
 
 .nf
-$ lvconvert --type cache --cachevol fast \\
-	--cachemode writethrough vg/main
+$ lvconvert --type cache --cachemode writethrough \\
+        --cachepool fast vg/main
+
+
+$ lvconvert --type cache --cachemode writethrough \\
+        --cachevol fast  vg/main
 .nf
 
 .SS dm-cache chunk size
@@ -480,6 +503,39 @@ defines the default cache policy.
 .br
 defines the default cache settings.
 
+.SS dm-cache using metadata profiles
+
+\&
+
+Cache pools allows to set a variety of options. Lots of these settings
+can be specified in lvm.conf or profile settings. You can prepare
+a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
+and just specify the metadata profile file name when caching LV or creating cache-pool.
+Check the output of \fBlvmconfig --type default --withcomments\fP
+for a detailed description of all individual cache settings.
+
+.I Example
+.nf
+# cat <<EOF > #DEFAULT_SYS_DIR#/profile/cache_big_chunk.profile
+allocation {
+	cache_pool_metadata_require_separate_pvs=0
+	cache_pool_chunk_size=512
+	cache_metadata_format=2
+	cache_mode="writethrough"
+	cache_policy="smq"
+	cache_settings {
+		smq {
+			migration_threshold=8192
+			random_threshold=4096
+		}
+	}
+}
+EOF
+
+# lvcreate --cache -L10G --metadataprofile cache_big_chunk vg/main  /dev/fast_ssd
+# lvcreate --cache -L10G --config 'allocation/cache_pool_chunk_size=512' vg/main /dev/fast_ssd
+.fi
+
 .SS dm-cache spare metadata LV
 
 \&
@@ -518,16 +574,24 @@ $ lvconvert --type cache --cachevol fast vg/main
 
 \&
 
-A single command can be used to create a cache pool and attach that new
-cache pool to a main LV:
+A single command can be used to cache main LV with automatic
+creation of a cache-pool:
+
+.nf
+$ lvcreate --cache --size CacheDataSize VG/LV [FastPVs]
+.fi
+
+or the longer variant
 
 .nf
-$ lvcreate --type cache --name Name --size Size VG/LV [PV]
+$ lvcreate --type cache --size CacheDataSize \\
+	--name NameCachePool VG/LV [FastPVs]
 .fi
 
 In this command, the specified LV already exists, and is the main LV to be
-cached.  The command creates a new cache pool with the given name and
-size, using the optionally specified PV (typically an ssd).  Then it
+cached.  The command creates a new cache pool with size and given name
+or the name is automatically selected from a sequence lvolX_cpool,
+using the optionally specified fast PV(s) (typically an ssd).  Then it
 attaches the new cache pool to the existing main LV to begin caching.
 
 (Note: ensure that the specified main LV is a standard LV.  If a cache


