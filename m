From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 12 Feb 2014 16:29:34 +0000 (UTC)
Subject: master - cache[pool]: Man page updates for lvs, lvcreate, lvconvert
Message-ID: <20140212162934.D657660FDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bfe4aaf95434d4289c7f030a354564b9375ab3d
Commit:        5bfe4aaf95434d4289c7f030a354564b9375ab3d
Parent:        0912cf67aae21446a10b3a22067aee1e8f792856
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 12 10:29:07 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 12 10:29:07 2014 -0600

cache[pool]: Man page updates for lvs, lvcreate, lvconvert

---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 man/lvcreate.8.in  |   35 ++++++++++++++++++++++++++++++++++-
 man/lvs.8.in       |    4 ++--
 4 files changed, 82 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c8f622a..a089d7c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add basic LVM support for cache[pool] segment types.
   Use local exclusive activation for creation of raid in cluster.
   Use correctly signed 64b constant when selecting raid volumes.
   Add systemd native service for clvmd, cmirrord and clustered LV activation.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index c8cb2dc..32b251c 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -113,6 +113,30 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .sp
+.B lvconvert \-\-type cache_pool
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize [ bBsSkKmMgG ]]
+.RB [ \-\-cachemode
+.RI { writeback | writethrough }]
+.RB [[ \-\-poolmetadata
+.IR CachePoolMetadataLogicalVolume { Name | Path }]
+|
+.RB [ \-\-poolmetadatasize
+.IR CachePoolMetadataSize [ bBsSkKmMgG ]]
+.IR LogicalVolume [ Path ]
+.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.sp
+.B lvconvert \-\-type cache
+.RB \-\-cachepool
+.IR CachePoolLogicalVolume { Name | Path }
+.IR LogicalVolume [ Path ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.sp
 
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
@@ -146,6 +170,13 @@ arguments is required.
 .BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
+.BR \-\-cachepool " " \fCachePoolLogicalVolume
+This argument is used when converting a logical volume to a cached
+logical volume.  The CachePoolLogicalVolume is the small and fast
+logical volume that will provide the cache for the large slow logical
+volume that is being converted.  Not that a cache pool LV can only be
+used by one logical volume.
+.TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
 For example, "\fB-m 1\fP" would convert the original logical
@@ -176,9 +207,9 @@ A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
 .B \-\-type \fISegmentType
-Used to convert a logical volume to another segment type or to explicitly state
-the desired RAID1 segment type (\fImirror\fP or \fIraid1\fP) when converting
-a linear logical volume to a mirror with the \fB-m\fP argument.
+Used to convert a logical volume to another segment type, like cache_pool,
+cache, raid1, mirror.  When converting a logical volume to a cached logical
+volume, the \-\-cachepool argument is required.
 .TP
 .BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
@@ -447,6 +478,17 @@ For the read-only external origin use the new name "vg00/external".
 .sp
 .B lvconvert \-\-thinpool vg00/lvpool \-\-originname external -T vg00/origin
 
+Convert an existing logical volume to a cache pool logical volume using the
+given pool metadata LV.
+.sp
+.B lvconvert --type cache_pool vg00/my_lv_data \-\-poolmetadata vg00/my_lv_meta
+.B lvrename vg00/my_lv_data vg00/my_lv_cachepool
+
+Convert an existing logical volume to a cached logical volume using the given
+cachepool.
+.sp
+.B lvconvert \-\-type cache vg00/my_lv \-\-cachepool vg00/my_lv_cachepool
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4a769cb..800ae8a 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -59,6 +59,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-t | \-\-test ]
 .RB [ \-T | \-\-thin
+.RB [ \-\-cachemode
+.IR { writeback | writethrough }
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
@@ -155,14 +157,28 @@ use \fBlvs\fP command where the state of the flag is reported within
 .TP
 .IR \fB\-K ", " \fB\-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
+
+.TP
+.BR \-\-cachemode " " { writeback | writethrough }
+Specifying a cache mode determines when the writes to a cached logical volume
+are considered complete.  When "writeback" is specified, a write is considered
+complete as soon as it is stored in the cache pool (i.e. the smaller faster
+device).  If "writethough" is specified, a write is considered complete only
+when it has been stored in the cache pool and on the origin (i.e. the larger
+slower device).  While "writethrough" may be slower for writes, it is more
+resilient if something should happen to the cache pool device.
+
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
-Gives the size of chunk for snapshot and thin pool logical volumes.
+Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
 .br
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
 .br
+For cache pools the value must be between 32KiB and 1GiB.  The default
+is 64KiB.  Values must be a multiple of 32KiB.
+.br
 For thin pools the value must be between 64KiB and
 1GiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MiB,
@@ -499,6 +515,23 @@ in vg00 that will use an existing thin pool "vg00/pool":
 .sp
 .B lvcreate -s --thinpool vg00/pool  origin
 
+Create a cache pool logical volume that can later be used to cache one
+logical volume.
+.sp
+.B lvcreate --type cache_pool -L 1G -n my_lv_cachepool vg /dev/fast1
+
+If there is an existing cache pool logical volume, create the large slow
+device (i.e. the origin) and link it to the supplied cache pool LV,
+creating a cache logical volume.
+.sp
+.B lvcreate --type cache -L 100G -n my_lv vg/my_lv_cachepool /dev/slow1
+
+If there is an existing logical volume, create the fast and small
+cache pool logical volume and link it to the supplied existing logical
+volume (i.e. the origin), creating a cache logical volume.
+.sp
+.B lvcreate --type cache -L 1G -n my_lv_cachepool vg/my_lv /dev/fast1
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 8427aca..5c76cf1 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -135,12 +135,12 @@ can also be chosen.
 The lv_attr bits are:
 .RS
 .IP 1 3
-Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
+Volume type: (C)ached, (m)irrored, (M)irrored without initial sync, (o)rigin,
 (O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
 (s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
 mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
 under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
-thin pool m(e)tadata or pool metadata spare.
+pool m(e)tadata or pool metadata spare.
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
 volume


