From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 25 Feb 2014 19:29:36 +0000 (UTC)
Subject: master - man: Enhancements to various man pages for cache[-pool] segtypes
Message-ID: <20140225192936.2069B60F9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bb9eda97c6ef2fb6848322e36b2b44a688ed37c
Commit:        3bb9eda97c6ef2fb6848322e36b2b44a688ed37c
Parent:        f8bf4d7dfbd0ab44ec035bc61a286388a263fc48
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 25 12:17:03 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 25 12:17:03 2014 -0600

man: Enhancements to various man pages for cache[-pool] segtypes

Better formatting.  More consistent naming.  Better clarity.
---
 man/lvconvert.8.in |   30 +++----
 man/lvcreate.8.in  |   33 ++++----
 man/lvm.8.in       |  256 ++++++++++++++++++++++++++++++----------------------
 man/lvs.8.in       |    2 +-
 4 files changed, 179 insertions(+), 142 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index c496d74..190e221 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -131,7 +131,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert \-\-type cache
 .RB \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
+.IR CachePoolLV { Name | Path }
 .IR LogicalVolume [ Path ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
@@ -170,12 +170,9 @@ arguments is required.
 .BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
-.BR \-\-cachepool " " \fCachePoolLogicalVolume
-This argument is used when converting a logical volume to a cached
-logical volume.  The CachePoolLogicalVolume is the small and fast
-logical volume that will provide the cache for the large slow logical
-volume that is being converted.  Not that a cache pool LV can only be
-used by one logical volume.
+.BR \-\-cachepool " " \fCachePoolLV
+This argument is necessary when converting a logical volume to a cache LV.
+For more information on cache pool LVs and cache LVs, see \fBlvm\fP(8).
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
@@ -208,8 +205,8 @@ uses this granularity to track which regions are in sync.
 .TP
 .B \-\-type \fISegmentType
 Used to convert a logical volume to another segment type, like cache-pool,
-cache, raid1, mirror.  When converting a logical volume to a cached logical
-volume, the \-\-cachepool argument is required.
+cache, raid1, or thin-pool.  When converting a logical volume to a cache LV,
+the \-\-cachepool argument is required.
 .TP
 .BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
@@ -478,16 +475,17 @@ For the read-only external origin use the new name "vg00/external".
 .sp
 .B lvconvert \-\-thinpool vg00/lvpool \-\-originname external -T vg00/origin
 
-Convert an existing logical volume to a cache pool logical volume using the
-given pool metadata LV.
+Convert an existing logical volume to a cache pool LV using the
+given cache metadata LV.
 .sp
-.B lvconvert --type cache-pool vg00/my_lv_data \-\-poolmetadata vg00/my_lv_meta
-.B lvrename vg00/my_lv_data vg00/my_lv_cachepool
+.B lvconvert --type cache-pool --poolmetadata vg00/lvx_meta vg00/lvx_data
+.br
+.B lvrename vg00/lvx_data vg00/lvx_cachepool
 
-Convert an existing logical volume to a cached logical volume using the given
-cachepool.
+Convert an existing logical volume to a cache LV using the given
+cache pool LV.
 .sp
-.B lvconvert \-\-type cache vg00/my_lv \-\-cachepool vg00/my_lv_cachepool
+.B lvconvert \-\-type cache  \-\-cachepool vg00/lvx_cachepool vg00/lvx
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index c449eb1..325baad 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -160,13 +160,14 @@ Ignore the flag to skip Logical Volumes during activation.
 
 .TP
 .BR \-\-cachemode " " { writeback | writethrough }
-Specifying a cache mode determines when the writes to a cached logical volume
-are considered complete.  When "writeback" is specified, a write is considered
-complete as soon as it is stored in the cache pool (i.e. the smaller faster
-device).  If "writethough" is specified, a write is considered complete only
-when it has been stored in the cache pool and on the origin (i.e. the larger
-slower device).  While "writethrough" may be slower for writes, it is more
-resilient if something should happen to the cache pool device.
+Specifying a cache mode determines when the writes to a cache LV
+are considered complete.  When \fIwriteback\fP is specified, a write is
+considered complete as soon as it is stored in the cache pool LV.
+If \fIwritethough\fP is specified, a write is considered complete only
+when it has been stored in the cache pool LV and on the origin LV.
+While \fIwritethrough\fP may be slower for writes, it is more
+resilient if something should happen to a device associated with the
+cache pool LV.
 
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
@@ -176,7 +177,7 @@ Default unit is in kilobytes.
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
 .br
-For cache pools the value must be between 32KiB and 1GiB.  The default
+For cache pool LVs the value must be between 32KiB and 1GiB.  The default
 is 64KiB.  Values must be a multiple of 32KiB.
 .br
 For thin pools the value must be between 64KiB and
@@ -415,7 +416,7 @@ as is the case with
 or
 .IR zero .
 Note that the cache segment type requires a dm-cache kernel module version
-1.3.0 or greater or a kernel version 3.14 or newer.
+1.3.0 or greater.
 
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
@@ -532,20 +533,20 @@ in vg00 that will use an existing thin pool "vg00/pool":
 .sp
 .B lvcreate -s --thinpool vg00/pool  origin
 
-Create a cache pool logical volume that can later be used to cache one
+Create a cache pool LV that can later be used to cache one
 logical volume.
 .sp
 .B lvcreate --type cache-pool -L 1G -n my_lv_cachepool vg /dev/fast1
 
-If there is an existing cache pool logical volume, create the large slow
-device (i.e. the origin) and link it to the supplied cache pool LV,
-creating a cache logical volume.
+If there is an existing cache pool LV, create the large slow
+device (i.e. the origin LV) and link it to the supplied cache pool LV,
+creating a cache LV.
 .sp
 .B lvcreate --type cache -L 100G -n my_lv vg/my_lv_cachepool /dev/slow1
 
-If there is an existing logical volume, create the fast and small
-cache pool logical volume and link it to the supplied existing logical
-volume (i.e. the origin), creating a cache logical volume.
+If there is an existing logical volume, create the small and fast
+cache pool LV and link it to the supplied existing logical
+volume (i.e. the origin LV), creating a cache LV.
 .sp
 .B lvcreate --type cache -L 1G -n my_lv_cachepool vg/my_lv /dev/fast1
 
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 363f6af..39e47d3 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -390,156 +390,194 @@ To view the way the allocation process currently works in any specific
 case, read the debug logging output, for example by adding \fB\-vvvv\fP to
 a command.
 
-.SH ADVANCED LOGICAL VOLUME TYPES
+.SH LOGICAL VOLUME TYPES
 Some logical volume types are simple to create and can be done with a
 single \fBlvcreate\fP(8) command.  The linear and striped logical
 volume types are an example of this.  Other logical volume types may
-require more than one command to create.  The cache and thinly provisioned
-types are examples of this.  This section is devoted to explaining the
-creation and monitoring of the more advanced types of logical volumes in
-LVM.  While the specifics of each command can be found in their respective
-man page, here you will find examples and best practices that may invoke
-multiple commands.
+require more than one command to create.  The cache and thin provisioning
+types are examples of this.
+
 .br
-.SS Cache Logical Volumes
-A cache logical volume is one that allows a small and fast block device to
-be used to improve the performance of larger and slower block devices.  It
-does this by storing the more frequently used blocks on the faster device.
-LVM refers to the small fast device as a "cache pool".  The large slow device
-is called the "origin".  Due to requirements from dm-cache (the kernel
-driver), LVM further splits the "cache pool" into two devices - the "cache pool
-metadata" and "cache pool data" devices.  The "cache pool data" device is where
-copies of data blocks are kept from the origin to increase speed.  The "cache
-pool metadata" device holds the accounting information that specifies where
-data blocks are stored (e.g. on the "origin" or in the "cache pool data" device).
-Users should be familiar with these three devices should they wish to create
-the best and most robust cached logical volumes.
-
-.SS Creating Cache Logical Volumes
-The steps to create a logical volume of cache type are as follows:
-.TP
-1)
-Create the cache pool's data device.  The size of this device directly
-correlates to the size of the cache and will ultimately be reported as
-the size of the cache pool.
-.TP
-2)
-Create the cache pool's metadata device.  The size of this device is
-loosely related to the size of the data device.  Generally, a user can
-size this 1000 times smaller than the cache pool data device with a
-minimum size of 8MiB.
-.TP
-3)
-Create the cache pool by combining the cache pool data and metadata
-logical volumes created in steps 1 & 2.  When performing this step,
-the user can specify behavioral characteristics of the cache pool if
-they wish.  If no new name is specified when combining, the name of the
-cache pool data device will become the name of the cachepool.  The sub-LVs
-are then renamed to <name>_cdata and <name>_cmeta.
-.TP
-4)
-Create a cached logical volume by linking the cache pool to an existing
-logical volume.  The user accessible cached LV keeps the name of the origin,
-while the actual origin device becomes a hidden LV with the name
-<origial name>_corig.  Users can perform this step while the device which
-is to be cached is in use.
+.SS Cache
+The \fIcache\fP logical volume type uses a small and fast LV to improve
+the performance of a large and slow LV.  It does this by storing the
+frequently used blocks on the faster LV.
+LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
+slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
+(the kernel driver), LVM further splits the cache pool LV into two
+devices - the \fBcache data LV\fP and \fBcache metadata LV\fP.  The cache
+data LV is where copies of data blocks are kept from the
+origin LV to increase speed.  The cache metadata LV holds the
+accounting information that specifies where data blocks are stored (e.g.
+on the origin LV or on the cache data LV).  Users should be familiar with
+these LVs if they wish to create the best and most robust cached
+logical volumes.
+
+.SS Cache Terms
+.nf
+origin LV           OriginLV      large slow LV
+cache data LV       CacheDataLV   small fast LV for cache pool data
+cache metadata LV   CacheMetaLV   small fast LV for cache pool metadata
+cache pool LV       CachePoolLV   CacheDataLV + CacheMetaLV
+cache LV            CacheLV       OriginLV + CachePoolLV
+.fi
+
+.SS Cache Steps
+The steps to create a logical volume of \fIcache\fP type are as follows:
+.TP
+0.
+Create an LV or identify an existing LV to be the origin LV.
+.TP
+1.
+Create the cache data LV.  The size of this LV is the size of the cache
+and will be reported as the size of the cache pool LV.
+.TP
+2.
+Create the cache metadata LV.
+The size of this LV should be 1000 times smaller than the cache data LV
+with a minimum size of 8MiB.
+.TP
+3.
+Create the cache pool LV by combining the cache data LV (from step 1)
+and cache metadata LV (from step 2).  When performing this step,
+behavioral characteristics of the cache pool LV can be set.
+The name of the cache pool LV takes the name of the cache data LV and
+the cache data LV and cache metadata LV are renamed
+to CachePoolLV_cdata and CachePoolLV_cmeta.
+.TP
+4.
+Create a cache LV by linking the cache pool LV to the origin LV.
+The user accessible cache LV takes the name of the origin LV,
+while the origin LV becomes a hidden LV with the name
+OriginLV_corig.  Users can perform this step while the origin LV
+is in use.
 
 .P
-The above steps represent the best way to create a cached logical volume.
-They provide access to the most options and have the ability to create the
-most robust logical volumes.  The examples below will illustrate how these
+The steps above represent the best way to create a cache LV.
+They provide the most options and have the ability to create the
+most robust logical volumes.  The examples below illustrate how these
 steps might be used in practice.
 
+.SS Cache Commands
+.nf
+0. create OriginLV
+lvcreate -L LargeSize -n OriginLV VG SlowPVs
+
+1. create CacheDataLV
+lvcreate -L CacheSize -n CacheDataLV VG FastPVs
+
+2. create CacheMetaLV
+lvcreate -L MetaSize -n CacheMetaLV VG FastPVs
+
+3. create CachePoolLV
+lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV VG/CacheDataLV
+CachePoolLV takes the name of CacheDataLV.
+CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
+CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
+
+4. create CacheLV
+lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
+CacheLV takes the name of OriginLV.
+OriginLV is renamed OriginLV_corig and becomes hidden.
+.fi
+
+.SS Cache Examples
+
 .B Example 1:
-Creating a simple cache device named, "my_lv".
+Creating a simple cache LV.
 .br
 
 .nf
-# Create a device we wish to cache (yours may already exist)
-Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+0. Create the origin LV
+# lvcreate -L 10G -n lvx vg /dev/slow_dev
 
-# Create a cache pool data LV
-Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
+1. Create a cache data LV
+# lvcreate -L 1G -n lvx_cache vg /dev/fast_dev
 
-# Create a cache pool metadata LV (~1/1000th size of pool data)
-Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
+2. Create a cache metadata LV (~1/1000th size of CacheDataLV or 8MiB)
+# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast_dev
 
-# Combine cache pool sub-LVs into a cache pool.
-Step-3> lvconvert --type cache-pool vg/cachepool --poolmetadata vg/meta
+3. Create a cache pool LV, combining cache data LV and cache metadata LV
+# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
+	vg/lvx_cache
 
-# Combine the cache pool and origin to create a cached LV
-Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+4. Create a cached LV by combining the cache pool LV and origin LV
+# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
 .fi
 
+.B Example 2:
+Creating a cache LV with a fault tolerant cache pool LV.
+
 Users who are concerned about the possibility of failures in their fast devices
 that could lead to data loss might consider making their cache pool sub-LVs
-redundant.  Example 2 illustrates how to do just that.  Note that only steps
-1 & 2 change slightly.
-
-.B Example 2:
-Creating a cache LV with a fault tolerant cache pool.
+redundant.  Example 2 illustrates how to do that.  Note that only steps
+1 & 2 change.
 
 .nf
-# Create a device we wish to cache (yours may already exist)
-Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+0. Create an origin LV we wish to cache
+# lvcreate -L 10G -n lvx vg /dev/slow_devs
 
-# Create a 2-way RAID1 cache pool data LV
-Step-01> lvcreate --type raid1 -L 1G -n cachepool my_vg /dev/fast[12]
+1. Create a 2-way RAID1 cache data LV
+# lvcreate --type raid1 -m 1 -L 1G -n lvx_cache vg \\
+	/dev/fast1 /dev/fast2
 
-# Create a 2-way RAID1 cache pool metadata LV
-Step-2> lvcreate --type raid1 -L 8M -n meta my_vg /dev/fast1 /dev/fast2
+2. Create a 2-way RAID1 cache metadata LV
+# lvcreate --type raid1 -m 1 -L 8M -n lvx_cache_meta vg \\
+	/dev/fast1 /dev/fast2
 
-# Combine cache pool sub-LVs into a cache pool.
-Step-3> lvconvert --type cache-pool vg/cachepool --poolmetadata vg/meta
+3. Create a cache pool LV combining cache data LV and cache metadata LV
+# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
+	vg/lvx_cache
 
-# Combine the cache pool and origin to create a cached LV
-Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+4. Create a cached LV by combining the cache pool LV and origin LV
+# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
 .fi
 
-Some users wish to ensure that any data written will be stored both in the
-cache pool and on the origin.  The loss of the cache device in this case
-would not mean the loss of any data.  When combining the cache pool's sub-LVs
-to form the cachepool, behavioral characteristics of the cache can be
-specified - in this case, writethrough vs. writeback.  Note that only step
-3 is affected in this case.
-
 .B Example 3:
-Creating a simple cache device with "writethough" caching.
+Creating a simple cache LV with \fIwritethough\fP caching.
+
+Some users wish to ensure that any data written will be stored both in the
+cache pool LV and on the origin LV.  The loss of a device associated with
+the cache pool LV in this case would not mean the loss of any data.  When
+combining the cache data LV and the cache metadata LV to form the cache pool
+LV, properties of the cache can be specified - in this case,
+\fIwritethrough\fP vs. \fIwriteback\fP.  Note that only step 3 is affected
+in this case.
 
 .nf
-# Create a device we wish to cache (yours may already exist)
-Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+0. Create an origin LV we wish to cache (yours may already exist)
+# lvcreate -L 10G -n lvx vg /dev/slow
 
-# Create a cache pool data LV
-Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
+1. Create a cache data LV
+# lvcreate -L 1G -n lvx_cache vg /dev/fast
 
-# Create a cache pool metadata LV
-Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
+2. Create a cache metadata LV
+# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast
 
-# Combine cache pool sub-LVs into a cache pool and specify "writethough".
-Step-3> lvconvert --type cache-pool vg/cachepool \\
-	--poolmetadata vg/meta --cachemode writethrough -n cachepool
+3. Create a cache pool LV specifying cache mode "writethrough"
+# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
+	--cachemode writethrough vg/lvx_cache
 
-# Combine the cache pool and origin to create a cached LV
-Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+4. Create a cache LV by combining the cache pool LV and origin LV
+# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
 .fi
 
 .SS Removing Cache Logical Volumes
-If users wish to remove all logical volumes associated with a cached
-logical volume, they must remove both top-level, user visible devices.
-The cache pool metadata and data logical volumes cannot be removed
-directly.  If only the cache pool is specfied for removal, any cached
-blocks not yet on the origin will be flush, the cache pool will be
-removed, and the now un-cached origin will remain.  If the user
-specifies a cached LV for removal, then the origin device is
-removed and only the cache pool will remain.  The cache pool can then be
-used to create another cache LV with a different origin if desired.
+If you wish to remove all logical volumes associated with a cache
+LV, you must remove both top-level, user-visible devices.
+The cache metadata LV and cache data LV cannot be removed
+directly.  If only the cache pool LV is specfied for removal, any cached
+blocks not yet on the origin LV will be flush, the cache pool LV will be
+removed, and the now un-cached origin LV will remain.  If the user
+specifies a cache LV for removal, then the origin LV is
+removed and only the cache pool LV will remain.  The cache pool LV can then
+be used to create another cache LV with a different origin LV if desired.
 
 When users intend to remove all logical volumes associated with a
-cached LV, it is generally better to start with the origin and then
-remove the cache pool.  If the operations are performed in the
+cache LV, it is generally better to start with the origin LV and then
+remove the cache pool LV.  If the operations are performed in the
 reverse order, the user will have to wait for the contents of the
-cache pool to be flushed before they remove the origin.  This
+cache pool LV to be flushed before the origin LV is removed.  This
 could take some time.
 
 .SH DIAGNOSTICS
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 5c76cf1..95eb25a 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -135,7 +135,7 @@ can also be chosen.
 The lv_attr bits are:
 .RS
 .IP 1 3
-Volume type: (C)ached, (m)irrored, (M)irrored without initial sync, (o)rigin,
+Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
 (O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
 (s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
 mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,


