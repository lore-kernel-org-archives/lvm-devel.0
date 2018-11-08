From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 16:48:58 -0500
Subject: master - man: lvmcache update
Message-ID: <201811082148.wA8Lmw7m012186@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38770db19b3c77e83e4e451f12ba3cd134c09f05
Commit:        38770db19b3c77e83e4e451f12ba3cd134c09f05
Parent:        2f02e8d33ae908b1db523fac1690a4c9246daee2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 6 16:14:59 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 15:48:36 2018 -0600

man: lvmcache update

for cache changes including writecache
---
 man/lvmcache.7_main |  519 +++++++++++++++++++++++----------------------------
 1 files changed, 230 insertions(+), 289 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 6672ad3..1e2acf4 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -4,423 +4,364 @@ lvmcache \(em LVM caching
 
 .SH DESCRIPTION
 
-An \fBlvm\fP(8) \fBcache\fP Logical Volume (LV) uses a small and
-fast LV to improve the performance of a large and slow LV.  It does this
-by storing the frequently used blocks on the faster LV.
-LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
-slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
-(the kernel driver), LVM further splits the cache pool LV into two
-devices - the \fBcache data LV\fP and \fBcache metadata LV\fP.  The cache
-data LV is where copies of data blocks are kept from the
-origin LV to increase speed.  The cache metadata LV holds the
-accounting information that specifies where data blocks are stored (e.g.
-on the origin LV or on the cache data LV).  Users should be familiar with
-these LVs if they wish to create the best and most robust cached
-LVs.  All of these associated LVs must be in the same Volume
-Group (VG).
-
-.SH Cache Terms
-.nf
-origin LV           OriginLV      large slow LV
-cache data LV       CacheDataLV   small fast LV for cache pool data
-cache metadata LV   CacheMetaLV   small fast LV for cache pool metadata
-cache pool LV       CachePoolLV   CacheDataLV + CacheMetaLV
-cache LV            CacheLV       OriginLV + CachePoolLV
-.fi
+\fBlvm\fP(8) includes two kinds of caching that can be used to improve the
+performance of a Logical Volume (LV). Typically, a smaller, faster device
+is used to improve i/o performance of a larger, slower LV. To do this, a
+separate LV is created from the faster device, and then the original LV is
+converted to start using the fast LV.
 
-.SH Cache Usage
+The two kinds of caching are:
 
-The primary method for using a cache type LV:
+.IP \[bu] 2
+A read and write hot-spot cache, using the dm-cache kernel module.  This
+cache is slow moving, and adjusts the cache content over time so that the
+most used parts of the LV are kept on the faster device.  Both reads and
+writes use the cache. LVM refers to this using the LV type \fBcache\fP.
 
+.IP \[bu] 2
+A streaming write cache, using the dm-writecache kernel module.  This
+cache is intended to be used with SSD or PMEM devices to speed up all
+writes to an LV.  Reads do not use this cache.  LVM refers to this using
+the LV type \fBwritecache\fP.
 
-.SS 0. create OriginLV
+.SH USAGE
 
-Create an LV or identify an existing LV to be the origin LV.
+Both kinds of caching use similar lvm commands:
 
-.B lvcreate -n OriginLV -L LargeSize VG SlowPVs
+.B 1. Identify main LV that needs caching
 
-.I Example
-.br
-# lvcreate -n lvol0 -L 100G vg /dev/slow
+A main LV exists on slower devices.
 
+.nf
+  $ lvcreate -n main -L Size vg /dev/slow
+.fi
 
-.SS 1. create CacheDataLV
+.B 2. Identify fast LV to use as the cache
 
-Create the cache data LV.  This LV will hold data blocks from the
-OriginLV.  The size of this LV is the size of the cache and will be
-reported as the size of the cache pool LV.  
+A fast LV exists on faster devices.  This LV will be used to hold the
+cache.
 
-.B lvcreate -n CacheDataLV -L CacheSize VG FastPVs
+.nf
+  $ lvcreate -n fast -L Size vg /dev/fast
 
-.I Example
-.br
-# lvcreate -n cache0 -L 10G vg /dev/fast
+  $ lvs vg -o+devices
+  LV   VG  Attr       LSize   Devices
+  fast vg -wi-------  xx.00m /dev/fast(0)
+  main vg -wi------- yyy.00m /dev/slow(0)
+.fi
 
+.B 3. Start caching the main LV
 
-.SS 2. create CacheMetaLV
+To start caching the main LV using the fast LV, convert the main LV to the
+desired caching type, and specify the fast LV to use:
 
-Create the cache metadata LV.  This LV will hold cache pool metadata.  The
-size of this LV should be 1000 times smaller than the cache data LV, with
-a minimum size of 8MiB.
+.nf
+using dm-cache:
 
-.B lvcreate -n CacheMetaLV -L MetaSize VG FastPVs
+  $ lvconvert --type cache --cachepool fast vg/main
 
-.I Example
-.br
-# lvcreate -n cache0meta -L 12M vg /dev/fast
+or dm-writecache:
 
-.nf
-# lvs -a vg
-  LV         VG   Attr       LSize   Pool Origin
-  cache0     vg   -wi-a-----  10.00g                                                    
-  cache0meta vg   -wi-a-----  12.00m                                                    
-  lvol0      vg   -wi-a----- 100.00g
+  $ lvconvert --type writecache --cachepool fast vg/main
 .fi
 
+.B 4. Display LVs
 
-.SS 3. create CachePoolLV
+Once the fast LV has been attached to the main LV, lvm reports the main LV
+type as either \fBcache\fP or \fBwritecache\fP depending on the type used.
+While attached, the fast LV is hidden, and only displayed when lvs is
+given -a.  The _corig or _wcorig LV represents the original LV without the
+cache.
 
-Combine the data and metadata LVs into a cache pool LV.
-The behavior of the cache pool LV can be set in this step.
-.br
-CachePoolLV takes the name of CacheDataLV.
-.br
-CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
-.br
-CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
+.nf
+using dm-cache:
 
-.B lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV
-.RS
-.B VG/CacheDataLV
-.RE
+  $ lvs -a -o name,vgname,lvattr,origin,segtype,devices vg
+  LV           VG Attr       Origin       Type   Devices       
+  [fast]       vg Cwi-aoC---                     linear /dev/fast(xx)
+  main         vg Cwi-a-C--- [main_corig] cache  main_corig(0) 
+  [main_corig] vg owi-aoC---                     linear /dev/slow(0) 
 
-.I Example
-.br
-# lvconvert --type cache-pool --poolmetadata vg/cache0meta vg/cache0
+or dm-writecache:
 
-.nf
-# lvs -a vg
-  LV              VG   Attr       LSize   Pool Origin
-  cache0          vg   Cwi---C---  10.00g
-  [cache0_cdata]  vg   Cwi-------  10.00g
-  [cache0_cmeta]  vg   ewi-------  12.00m
-  lvol0           vg   -wi-a----- 100.00g
+  $ lvs -a -o name,vgname,lvattr,origin,segtype,devices vg
+  LV            VG Attr       Origin        Type       Devices       
+  [fast]        vg -wi-ao----               linear     /dev/fast(xx)
+  main          vg Cwi-a----- [main_wcorig] writecache main_wcorig(0)
+  [main_wcorig] vg -wi-ao----               linear     /dev/slow(0)   
 .fi
 
+.B 5. Use the main LV
 
-.SS 4. create CacheLV
+Use the LV until the cache is no longer wanted, or needs to be changed.
 
-Create a cache LV by linking the cache pool LV to the origin LV.
-The user accessible cache LV takes the name of the origin LV,
-while the origin LV becomes a hidden LV with the name
-OriginLV_corig.  This can be done while the origin LV is in use.
-.br
-CacheLV takes the name of OriginLV.
-.br
-OriginLV is renamed OriginLV_corig and becomes hidden.
+.B 6. Stop caching
 
-.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
-
-.I Example
-.br
-# lvconvert --type cache --cachepool vg/cache0 vg/lvol0
+To stop caching the main LV, separate the fast LV from the main LV.  This
+changes the type of the main LV back to what it was before the cache was
+attached.
 
 .nf
-# lvs -a vg
-  LV              VG   Attr       LSize   Pool   Origin
-  cache0          vg   Cwi---C---  10.00g                                                             
-  [cache0_cdata]  vg   Cwi-ao----  10.00g                                                             
-  [cache0_cmeta]  vg   ewi-ao----  12.00m                                                             
-  lvol0           vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]                                        
-  [lvol0_corig]   vg   -wi-ao---- 100.00g                                                             
+   $ lvconvert --splitcache vg/main
 .fi
 
 
-.SH Cache Removal
-
-.SS Split a cache pool LV off of a cache LV
+.SH OPTIONS
 
 \&
 
-A cache pool LV can be disconnected from a cache LV, leaving an
-unused cache pool LV, and an uncached origin LV.  This command
-writes back data from the cache pool to the origin LV when necessary.
-
-.B lvconvert --splitcache VG/CacheLV
-
-.SS Removing a cache pool LV without removing its linked origin LV
+.SS dm-writecache block size
 
 \&
 
-This writes back data from the cache pool to the origin LV when necessary,
-then removes the cache pool LV, leaving the uncached origin LV.
-
-.B lvremove VG/CachePoolLV
+The dm-writecache block size can be 4096 bytes (the default), or 512
+bytes.  The default 4096 has better performance and should be used except
+when 512 is necessary for compatibility.  The dm-writecache block size is
+specified with --writecacheblocksize 4096b|512b when caching is started.
 
-An alternative command that also disconnects the cache pool from the cache
-LV, and deletes the cache pool:
+When a file system like xfs already exists on the main LV prior to
+caching, and the file system is using a block size of 512, then the
+writecache block size should be set to 512.  (The file system will likely
+fail to mount if writecache block size of 4096 is used in this case.)
 
-.B lvconvert --uncache VG/CacheLV
+Check the xfs sector size while the fs is mounted:
 
-.I Example
 .nf
-# lvs vg
-  LV     VG   Attr       LSize   Pool   Origin
-  cache0 vg   Cwi---C---  10.00g
-  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
+$ xfs_info /dev/vg/main
+Look for sectsz=512 or sectsz=4096
+.fi
 
-# lvremove vg/cache0
+The writecache block size should be chosen to match the xfs sectsz value.
 
-# lvs vg
-  LV    VG   Attr       LSize   Pool Origin
-  lvol0 vg   -wi-a----- 100.00g
-.fi
+It is also possible to specify a sector size of 4096 to mkfs.xfs when
+creating the file system.  In this case the writecache block size of 4096
+can be used.
 
-.SS Removing a cache LV: both origin LV and the cache pool LV
+.SS dm-writecache settings
 
 \&
 
-Removing a cache LV removes both the origin LV and the linked cache pool
-LV.
+Tunable parameters can be passed to the dm-writecache kernel module using
+the --cachesettings option when caching is started, e.g.
 
-.B lvremove VG/CacheLV
+.nf
+$ lvconvert --type writecache --cachepool fast \\
+	--cachesettings 'high_watermark=N writeback_jobs=N' vg/main
+.fi
 
+Tunable options are:
 
-.SH Cache Topics
+.IP \[bu] 2
+high_watermark = <count>
 
-.SS Tolerate device failures in a cache pool LV
+Start writeback when the number of used blocks reach this watermark
 
-\&
+.IP \[bu] 2
+low_watermark = <count>
 
-Users who are concerned about the possibility of failures in their fast
-devices that could lead to data loss might consider making their cache
-pool sub-LVs redundant.
+Stop writeback when the number of used blocks drops below this watermark
 
-.I Example
-.nf
-0. Create an origin LV we wish to cache
-# lvcreate -L 10G -n lv1 vg /dev/slow
+.IP \[bu] 2
+writeback_jobs = <count>
 
-1. Create a 2-way RAID1 cache data LV
-# lvcreate --type raid1 -m 1 -L 1G -n cache1 vg \\
-	/dev/fast1 /dev/fast2
+Limit the number of blocks that are in flight during writeback.  Setting
+this value reduces writeback throughput, but it may improve latency of
+read requests.
 
-2. Create a 2-way RAID1 cache metadata LV
-# lvcreate --type raid1 -m 1 -L 8M -n cache1meta vg \\
-	/dev/fast1 /dev/fast2
+.IP \[bu] 2
+autocommit_blocks = <count>
 
-3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert --type cache-pool --poolmetadata vg/cache1meta vg/cache1
+When the application writes this amount of blocks without issuing the
+FLUSH request, the blocks are automatically commited.
 
-4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert --type cache --cachepool vg/cache1 vg/lv1
-.fi
+.IP \[bu] 2
+autocommit_time = <milliseconds>
 
-.SS Cache mode
+The data is automatically commited if this time passes and no FLUSH
+request is received.
 
-\&
+.IP \[bu] 2
+fua = 0|1
 
-The default cache mode is "writethrough".  Writethrough ensures that any
-data written will be stored both in the cache pool LV and on the origin
-LV.  The loss of a device associated with the cache pool LV in this case
-would not mean the loss of any data.
+Use the FUA flag when writing data from persistent memory back to the
+underlying device.
+Applicable only to persistent memory.
 
-A second cache mode is "writeback".  Writeback delays writing data blocks
-from the cache pool back to the origin LV.  This mode will increase
-performance, but the loss of a device associated with the cache pool LV
-can result in lost data.
-
-With the --cachemode option, the cache mode can be set when creating a
-cache LV, or changed on an existing cache LV.  The current cache mode of a
-cache LV can be displayed with the cache_mode reporting option:
+.IP \[bu] 2
+nofua = 0|1
 
-.B lvs -o+cache_mode VG/CacheLV
+Don't use the FUA flag when writing back data and send the FLUSH request
+afterwards.  Some underlying devices perform better with fua, some with
+nofua.  Testing is necessary to determine which.
+Applicable only to persistent memory.
 
-.BR lvm.conf (5)
-.B allocation/cache_mode
-.br
-defines the default cache mode.
 
-.I Example
-.nf
-0. Create an origin LV we wish to cache (yours may already exist)
-# lvcreate -L 10G -n lv1 vg /dev/slow
+.SS dm-cache with separate data and metadata LVs
 
-1. Create a cache data LV
-# lvcreate -L 1G -n cache1 vg /dev/fast
+\&
 
-2. Create a cache metadata LV
-# lvcreate -L 8M -n cache1meta vg /dev/fast
+When using dm-cache, the cache metadata and cache data can be stored on
+separate LVs.  To do this, a "cache-pool LV" is created, which is a
+special LV that references two sub LVs, one for data and one for metadata.
 
-3. Create a cache pool LV
-# lvconvert --type cache-pool --poolmetadata vg/cache1meta vg/cache1
+To create a cache-pool LV from two separate LVs:
 
-4. Create a cache LV by combining the cache pool LV and origin LV,
-   and use the writethrough cache mode.
-# lvconvert --type cache --cachepool vg/cache1 \\
-	--cachemode writethrough vg/lv1
+.nf
+$ lvcreate -n fastpool -L DataSize vg /dev/fast1
+$ lvcreate -n fastpoolmeta -L MetadataSize vg /dev/fast2
+$ lvconvert --type cache-pool --poolmetadata fastpoolmeta vg/fastpool
 .fi
 
+Then use the cache-pool LV to start caching the main LV:
 
-.SS Cache policy
+.nf
+$ lvconvert --type cache --cachepool fastpool vg/main
+.fi
 
-\&
+A variation of the same procedure automatically creates a cache-pool when
+caching is started.  To do this, use a standard LV as the --cachepool
+(this will hold cache data), and use another standard LV as the
+--poolmetadata (this will hold cache metadata).  LVM will create a
+cache-pool LV from the two specified LVs, and use the cache-pool to start
+caching the main LV.
 
-The cache subsystem has additional per-LV parameters: the cache policy to
-use, and possibly tunable parameters for the cache policy.  Three policies
-are currently available: "smq" is the default policy, "mq" is an older
-implementation, and "cleaner" is used to force the cache to write back
-(flush) all cached writes to the origin LV.
+.nf
+$ lvcreate -n fastpool -L DataSize vg /dev/fast1
+$ lvcreate -n fastpoolmeta -L MetadataSize vg /dev/fast2
+$ lvconvert --type cache --cachepool fastpool \\
+	--poolmetadata fastpoolmeta vg/main
+.fi
 
-The "mq" policy has a number of tunable parameters. The defaults are
-chosen to be suitable for the majority of systems, but in special
-circumstances, changing the settings can improve performance.
+.SS dm-cache cache modes
 
-With the --cachepolicy and --cachesettings options, the cache policy
-and settings can be set when creating a cache LV, or changed on an
-existing cache LV (both options can be used together).  The current cache
-policy and settings of a cache LV can be displayed with the cache_policy
-and cache_settings reporting options:
+\&
 
-.B lvs -o+cache_policy,cache_settings VG/CacheLV
+The default dm-cache cache mode is "writethrough".  Writethrough ensures
+that any data written will be stored both in the cache and on the origin
+LV.  The loss of a device associated with the cache in this case would not
+mean the loss of any data.
 
-.I Example
-.nf
-Change the cache policy and settings of an existing cache LV.
-# lvchange --cachepolicy mq --cachesettings \\
-	\(aqmigration_threshold=2048 random_threshold=4\(aq vg/lv1
-.fi
+A second cache mode is "writeback".  Writeback delays writing data blocks
+from the cache back to the origin LV.  This mode will increase
+performance, but the loss of a cache device can result in lost data.
 
-.BR lvm.conf (5)
-.B allocation/cache_policy
-.br
-defines the default cache policy.
+With the --cachemode option, the cache mode can be set when caching is
+started, or changed on an LV that is already cached.  The current cache
+mode can be displayed with the cache_mode reporting option:
+
+.B lvs -o+cache_mode VG/LV
 
 .BR lvm.conf (5)
-.B allocation/cache_settings
+.B allocation/cache_mode
 .br
-defines the default cache settings.
+defines the default cache mode.
 
+.nf
+$ lvconvert --type cache --cachepool fast \\
+	--cachemode writethrough vg/main
+.nf
 
-.SS Chunk size
+.SS dm-cache chunk size
 
 \&
 
-The size of data blocks managed by a cache pool can be specified with the
---chunksize option when the cache LV is created.  The default unit
-is KiB. The value must be a multiple of 32KiB between 32KiB and 1GiB.
+The size of data blocks managed by dm-cache can be specified with the
+--chunksize option when caching is started.  The default unit is KiB.  The
+value must be a multiple of 32KiB between 32KiB and 1GiB.
 
 Using a chunk size that is too large can result in wasteful use of the
-cache, where small reads and writes can cause large sections of an LV to
-be mapped into the cache.  However, choosing a chunk size that is too
-small can result in more overhead trying to manage the numerous chunks
-that become mapped into the cache.  Overhead can include both excessive
-CPU time searching for chunks, and excessive memory tracking chunks.
+cache, in which small reads and writes cause large sections of an LV to be
+stored in the cache.  However, choosing a chunk size that is too small
+can result in more overhead trying to manage the numerous chunks that
+become mapped into the cache.  Overhead can include both excessive CPU
+time searching for chunks, and excessive memory tracking chunks.
 
-Command to display the cache pool LV chunk size:
+Command to display the chunk size:
 .br
-.B lvs -o+chunksize VG/CacheLV
+.B lvs -o+chunksize VG/LV
 
 .BR lvm.conf (5)
 .B cache_pool_chunk_size
 .br
-controls the default chunk size used when creating a cache LV.
+controls the default chunk size.
 
 The default value is shown by:
 .br
 .B lvmconfig --type default allocation/cache_pool_chunk_size
 
 
-.SS Spare metadata LV
-
-\&
-
-See
-.BR lvmthin (7)
-for a description of the "pool metadata spare" LV.
-The same concept is used for cache pools.
-
-.SS Automatic pool metadata LV
+.SS dm-cache cache policy
 
 \&
 
-A cache data LV can be converted to cache pool LV without specifying a
-cache pool metadata LV.  LVM will automatically create a metadata LV from
-the same VG.
+The dm-cache subsystem has additional per-LV parameters: the cache policy
+to use, and possibly tunable parameters for the cache policy.  Three
+policies are currently available: "smq" is the default policy, "mq" is an
+older implementation, and "cleaner" is used to force the cache to write
+back (flush) all cached writes to the origin LV.
 
-.B lvcreate -n CacheDataLV -L CacheSize VG
-.br
-.B lvconvert --type cache-pool VG/CacheDataLV
+The older "mq" policy has a number of tunable parameters. The defaults are
+chosen to be suitable for the majority of systems, but in special
+circumstances, changing the settings can improve performance.
 
+With the --cachepolicy and --cachesettings options, the cache policy and
+settings can be set when caching is started, or changed on an existing
+cached LV (both options can be used together).  The current cache policy
+and settings can be displayed with the cache_policy and cache_settings
+reporting options:
 
-.SS Create a new cache LV without an existing origin LV
+.B lvs -o+cache_policy,cache_settings VG/LV
 
-\&
+.nf
+Change the cache policy and settings of an existing LV.
 
-A cache LV can be created using an existing cache pool without an existing
-origin LV.  A new origin LV is created and linked to the cache pool in a
-single step.
+$ lvchange --cachepolicy mq --cachesettings \\
+	\(aqmigration_threshold=2048 random_threshold=4\(aq vg/main
+.fi
 
-.B lvcreate --type cache -L LargeSize -n CacheLV
-.RS
-.B --cachepool VG/CachePoolLV VG SlowPVs
-.RE
+.BR lvm.conf (5)
+.B allocation/cache_policy
+.br
+defines the default cache policy.
 
+.BR lvm.conf (5)
+.B allocation/cache_settings
+.br
+defines the default cache settings.
 
-.SS Single step cache pool LV creation
+.SS dm-cache spare metadata LV
 
 \&
 
-A cache pool LV can be created with a single lvcreate command, rather than
-using lvconvert on existing LVs.  This one command creates a cache data
-LV, a cache metadata LV, and combines the two into a cache pool LV.
-
-.B lvcreate --type cache-pool -L CacheSize -n CachePoolLV VG FastPVs
-
+See
+.BR lvmthin (7)
+for a description of the "pool metadata spare" LV.
+The same concept is used for cache pools.
 
-.SS Convert existing LVs to cache types
+.SS dm-cache metadata formats
 
 \&
 
-When an existing origin LV is converted to a cache LV, the specified cache
-pool may be a normal LV, rather than a cache pool LV.  In this case, lvm
-will first convert the normal LV to a cache pool LV.  A pool metadata LV
-may optionally be specified.
-
-.B lvcreate -n OriginLV -L LargeSize VG
-.br
-.B lvcreate -n CacheDataLV -L CacheSize VG
-.br
-.B lvconvert --type cache --cachepool VG/CataDataLV VG/OriginLV
+There are two disk formats for dm-cache metadata.  The metadata format can
+be specified with --cachemetadataformat when caching is started, and
+cannot be changed.  Format \fB2\fP has better performance; it is more
+compact, and stores dirty bits in a separate btree, which improves the
+speed of shutting down the cache.  With \fBauto\fP, lvm selects the best
+option provided by the current dm-cache kernel module.
 
-This is equivalent to:
-
-.B lvcreate -n OriginLV -L LargeSize VG
-.br
-.B lvcreate -n CacheDataLV -L CacheSize VG
-.br
-.B lvconvert --type cache-pool VG/CacheDataLV
-.br
-.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
-
-
-.SS Cache metadata formats
+.SS mirrored cache device
 
 \&
 
-There are two disk formats for cache metadata.  The metadata format can be
-specified when a cache pool is created, and cannot be changed.
-Format \fB2\fP has better performance; it is more compact, and stores
-dirty bits in a separate btree, which improves the speed of shutting down
-the cache.
-With \fBauto\fP, lvm selects the best option provided by the current
-dm-cache kernel target.
-
-.B lvconvert --type cache-pool --cachemetadataformat auto|1|2
-.RS
-.B VG/CacheDataLV
-.RE
+The fast LV holding the cache can be created as a raid1 mirror so that it
+can tolerate a device failure.  (When using dm-cache with separate data
+and metadata LVs, each of the sub-LVs can use raid1.)
 
+.nf
+$ lvcreate -n main -L Size vg /dev/slow
+$ lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/fast1 /dev/fast2
+$ lvconvert --type cache --cachepool fast vg/main
+.fi
 
 .SH SEE ALSO
 .BR lvm.conf (5),


