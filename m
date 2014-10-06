From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:27 +0000 (UTC)
Subject: master - man: lvconvert new split options
Message-ID: <20141006133327.F2726610D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbf14b12d8710f10b7a7f1a0a23347ac5ad1a826
Commit:        fbf14b12d8710f10b7a7f1a0a23347ac5ad1a826
Parent:        cb49dd4aa4e6fecb80c163f0279803d4036e48c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 14:43:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:22:24 2014 +0200

man: lvconvert new split options

Update man page with info how to split/uncache cached logical
volumes.

lvconvert: splitsnapshot support --yes

Allow to use --yes to skip prompt.
---
 man/lvconvert.8.in |   84 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 64 insertions(+), 20 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index b8951e2..b08e420 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -32,6 +32,25 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR LogicalVolume [ Path ]
 .RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
+.B lvconvert
+.BR \-\-split
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.IR SplitableLogicalVolume { Name | Path }
+.sp
+.B lvconvert
+.BR \-\-splitcache | \-\-uncache
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR CacheLogicalVolume { Name | Path }
+.sp
 .B lvconvert \-\-splitmirrors \fIImages
 .RB [ \-\-name
 .IR SplitLogicalVolumeName ]
@@ -122,20 +141,20 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-poolmetadataspare
 .RI { y | n }]
 .RB [ \-Z | \-\-zero \ { \fIy | \fIn }]]
-.RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
-.RI [ PhysicalVolume [ Path ][ :PE
-.RI [ \-PE ]]...]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
+.RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
+.RI [ PhysicalVolume [ Path ][ :PE
+.RI [ \-PE ]]...]
 .sp
 .B lvconvert
 .RB [ \-\-type
-.BR \fIcache [ \fI\-pool ]| \-\-cache ]
+.BR \fIcache [ \fI\-pool ]| \-H | \-\-cache ]
 .RB [ \-\-cachepool
-.IR CachePoolLV { Name | Path }]
+.IR CachePoolLogicalVolume { Name | Path }]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -147,13 +166,13 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
 .RB [ \-\-poolmetadataspare
 .RI { y | n }]
-.IR LogicalVolume { Name | Path }
-.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
+.IR LogicalVolume { Name | Path }
+.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
 
 .SH DESCRIPTION
@@ -181,18 +200,21 @@ Exactly one of
 .BR \-\-mirrors ,
 .BR \-\-repair ,
 .BR \-\-replace ,
-.BR \-\-splitsnapshot ,
 .BR \-\-snapshot ,
+.BR \-\-split ,
+.BR \-\-splitcache ,
+.BR \-\-splitsnapshot ,
 .BR \-\-splitmirrors ,
-.BR \-\-thin
-or
+.BR \-\-thin ,
 .BR \-\-type
+or
+.BR \-\-uncache
 arguments is required.
 .TP
 .BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
-.BR \-\-cache ", " \-\-type\ \fIcache
+.BR \-H ", " \-\-cache ", " \-\-type\ \fIcache
 Converts logical volume to a cached LV with the use of cache pool
 specified with \fB\-\-cachepool\fP.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(8).
@@ -277,6 +299,19 @@ the data changed get resynchronized.
 Please note that this feature is only supported with the new md-based mirror
 implementation and not with the original device-mapper mirror implementation.
 .TP
+.B \-\-split
+Separates \fISplitableLogicalVolume\fP.
+Option is agregating various split commands and tries to detect necessary split
+operation from its arguments.
+.TP
+.BR \-\-splitcache ", " \-\-uncache
+Separates \fICacheLogicalVolume\fP from cache pool.
+Before volume becomes uncached, cache is flushed.
+With \-\-split the cache pool volume is then left unused and 
+could be i.e. used for caching other volumes.
+The inverse of \-\-cache is \-\-uncache where the cache pool 
+component volumes are automatically removed.
+.TP
 .B \-\-splitsnapshot
 Separates \fISnapshotLogicalVolume\fP from its origin.
 The volume that is split off contains the chunks that differ from the origin
@@ -347,7 +382,7 @@ Without this option a default name of "lvol<n>" will be generated where
 This volume will be read-only and cannot be further modified as long,
 as it is being used as the external origin.
 .TP
-.BR \-\-poolmetadata " " \fIThinPoolMetadataLogicalVolume { \fIName | \fIPath }
+.BR \-\-poolmetadata " " \fIPoolMetadataLogicalVolume { \fIName | \fIPath }
 Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
 Cache pool is specified with the option
@@ -369,12 +404,12 @@ thin provisioning tools
 and
 .BR thin_restore (8).
 .TP
-.BR \-\-poolmetadatasize " " \fIThinPoolMetadataSize [ \fIbBsSkKmMgG ]
-Sets the size of thin pool's metadata logical volume,
+.BR \-\-poolmetadatasize " " \fIPoolMetadataSize [ \fIbBsSkKmMgG ]
+Sets the size of cache or thin pool's metadata logical volume,
 if the pool metadata volume is undefined.
-Thin pool is specified with the option
-\fB\-\-thinpool\fP.
-Supported value is in the range between 2MiB and 16GiB.
+Pool is specified with the option
+\B\-\-cachepool\P or \fB\-\-thinpool\fP.
+For thin pool supported value is in the range between 2MiB and 16GiB.
 The default value is estimated with this formula
 (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
@@ -554,11 +589,20 @@ given cache metadata LV.
 .B lvconvert \-\-type cache-pool \-\-poolmetadata vg00/lvx_meta vg00/lvx_data
 .br
 .B lvrename vg00/lvx_data vg00/lvx_cachepool
-
+.sp
 Convert an existing logical volume to a cache LV using the given
-cache pool LV.
+cache pool LV and chunk size 128KiB.
+.sp
+.B lvconvert \-\-cache  \-\-cachepool vg00/lvx_cachepool -c 128 vg00/lvx
+.sp
+Detach cache pool from an existing cached logical volume "vg00/lvol1" and
+leave cache pool unused.
+.sp
+.B lvconvert \-\-splitcache vg00/lvol1
+.sp
+Drop cache pool from an existing cached logical volume "vg00/lvol1".
 .sp
-.B lvconvert \-\-cache  \-\-cachepool vg00/lvx_cachepool vg00/lvx
+.B lvconvert \-\-uncache vg00/lvol1
 
 .SH SEE ALSO
 .BR lvm (8),


