From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Jul 2016 11:23:24 +0000 (UTC)
Subject: master - man: restore lost synopsis for lvconvert
Message-ID: <20160712112324.E486B60D9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80394ae7cd9ae3a9b7523216840a3b4bfca5cd70
Commit:        80394ae7cd9ae3a9b7523216840a3b4bfca5cd70
Parent:        525497141810752c98e6ab0ed013ae36f5dd702f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 13:17:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 12 13:20:56 2016 +0200

man: restore lost synopsis for lvconvert

Synopsis are very useful for quick orientation and also
we provide then for all remaining command.

Also list ALL supported options in a single ordered list,
user should not seek for them.
---
 man/lvconvert.8.in |  259 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 231 insertions(+), 28 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index f51ad61..f335336 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -7,6 +7,197 @@ lvconvert \(em change LV type and other utilities
 .B lvconvert
 .RI [ OPTION ]...
 .IR VolumeGroup / LogicalVolume
+.sp
+
+.ad l
+.B lvconvert
+.BR \-m | \-\-mirrors
+.IR Mirrors
+.RB [ \-\-type
+.IR SegmentType ]
+.RB [ \-\-mirrorlog
+.RB { disk | core | mirrored }]
+.RB [ \-\-corelog ]
+.RB [ \-R | \-\-regionsize
+.IR MirrorLogRegionSize ]
+.RB [ \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB [ \-A | \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-b | \-\-background ]
+.RB [ \-f | \-\-force ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-y | \-\-yes ]
+.RB [ \-\-version ]
+.IR LogicalVolume
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.sp
+.B lvconvert
+.BR \-\-merge
+.RB [ \-b | \-\-background ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume...
+.sp
+.B lvconvert
+.BR \-s | \-\-snapshot
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-Z | \-\-zero
+.RB { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR OriginalLogicalVolume
+.IR SnapshotLogicalVolume
+.sp
+.B lvconvert
+.BR \-\-split
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.IR SplitableLogicalVolume
+.sp
+.B lvconvert
+.BR \-\-splitcache | \-\-uncache
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR CacheLogicalVolume
+.sp
+.B lvconvert
+.BR \-\-splitmirrors
+.IR Images
+.RB [ \-\-name
+.IR SplitLogicalVolumeName ]
+.RB [ \-\-trackchanges ]
+.IR MirrorLogicalVolume
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RI \%[ SplittablePhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.sp
+.B lvconvert
+.BR \-\-splitsnapshot
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR SnapshotLogicalVolume
+.sp
+.B lvconvert
+.BR \-\-repair
+.RB [ \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume
+.RI [ PhysicalVolume [ Path ]...]
+.sp
+.B lvconvert
+.BR \-\-replace
+.IR PhysicalVolume
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume
+.RI [ PhysicalVolume [ Path ]...]
+.sp
+.B lvconvert
+.BR \-\-type
+.BR cache [ \-pool ]| \-H | \-\-cache
+.RB [ \-\-cachepool
+.IR CachePoolLogicalVolume ]
+.\" |
+.\" .B \-\-pooldatasize
+.\" .IR CachePoolMetadataSize ]
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-\-cachemode
+.RB { writeback | writethrough }]
+.RB [ \-\-cachepolicy
+.IR Policy ]
+.RB [ \-\-cachesettings
+.IR Key \fB= Value ]...
+.RB [ \-\-poolmetadata
+.IR CachePoolMetadataLogicalVolume
+.RB |
+.BR \-\-poolmetadatasize
+.IR CachePoolMetadataSize ]
+.RB [ \-\-poolmetadataspare
+.RB { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.sp
+.B lvconvert
+.BR \-\-type
+.BR thin [ \-pool ]| \-T | \-\-thin
+.RB [ \-\-originname
+.IR NewExternalOriginVolumeName ]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolume
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-\-discards
+.RB { ignore | nopassdown | passdown }]
+.RB [ \-\-poolmetadata
+.IR ThinPoolMetadataLogicalVolume
+.RB |
+.BR \-\-poolmetadatasize
+.IR ThinPoolMetadataSize ]
+.RB [ \-r | \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }]
+.RB [ \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB [ \-\-poolmetadataspare
+.RB { y | n }]
+.RB [ \-Z | \-\-zero
+.RB { y | n }]]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [[ ExternalOrigin | ThinPool ] LogicalVolume
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]]
+.ad b
+.sp
 
 .SH DESCRIPTION
 
@@ -500,6 +691,17 @@ return before the operation is complete, and polling is done in the
 background.
 .
 .HP
+.BR \-H ,
+.BR \-\-cache
+.br
+Converts logical volume to a cached LV with the use of cache pool
+specified with \fB\-\-cachepool\fP. When the volume specified as
+cache pool is not yet of cache-pool type, such volume will be converted
+first into a cache pool volume type.
+For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
+It is an alias for \fB\-\-type\ cache\fP.
+.
+.HP
 .BR \-\-cachepolicy
 .IR Policy
 .br
@@ -619,7 +821,7 @@ Using \fBmirrored\fP will create a persistent log that is itself mirrored.
 .IR Number
 .br
 Specifies the number mirror images in addition to the original LV image,
-e.g. \fB\-\-mirrors 1\fP means two copies of the data, the original and
+e.g. \fB\-\-mirrors\ 1\fP means two copies of the data, the original and
 one mirror image.
 
 This option is required when converting an LV to a \fBraid1\fP or
@@ -761,6 +963,15 @@ times depending on the RaidLV type.  See
 .BR lvmraid (7)
 for specific limits on device replacement for each raid level.
 (This option only applies to \fBraid*\fP LV types.)
+.HP
+.BR \-s ,
+.BR \-\-snapshot
+.br
+Recreates a snapshot from constituent logical volumes (or copies of them) after
+having been separated using \fB\-\-splitsnapshot\fP.
+For this to work correctly, no changes may be made to the contents
+of either volume after the split.
+It is an alias for \fB\-\-type\ snapshot\fP.
 .
 .HP
 .BR \-\-split
@@ -824,6 +1035,21 @@ before writing to the next stripe/device.  StripeSize must be a power of 2
 and cannot exceed the VG physical extent (PE) size.
 .
 .HP
+.BR \-T ,
+.BR \-\-thin
+.br
+Converts the logical volume into a thin logical volume of the thin pool
+specified with \fB\-\-thinpool\fP.
+When the volume specified as thin pool is not yet of thin-pool type,
+such volume will be converted first into a thin pool volume type.
+The original logical volume \fIExternalOriginLogicalVolume\fP
+is renamed into a new read-only logical volume.
+For the non-default name for this volume use \fB\-\-originname\fP.
+The volume cannot be further modified as long as it is used as an
+external origin volume for unprovisioned areas of any thin logical volume.
+It is an alias for \fB\-\-type\ thin\fP.
+.
+.HP
 .BR \-\-type
 .IR SegmentType
 .br
@@ -853,8 +1079,9 @@ to the \fBraid1\fP LV type.)
 .BR \-\-uncache
 .br
 Separates a cache pool from a cache LV, and removes the unused cache pool
-LV.  Before the separation, the cache is flushed.  See similar option
-.B \-\-splitcache.
+LV (See similar option \fB\-\-splitcache\fP).
+Before the separation, the cache is flushed.
+This option could be seen as an inverse of \fB\-\-cache\fP.
 Also see
 .BR lvmcache (7).
 .
@@ -871,27 +1098,6 @@ Provisioning of large zeroed chunks negatively impacts performance.
 Also see
 .BR lvmthin (7).
 .
-
-.SS Option aliases
-
-.B \-\-type cache
-can be replaced with
-.B \-H
-or
-.B \-\-cache.
-
-.B \-\-type thin
-can be replaced with
-.B \-T
-or
-.B \-\-thin.
-
-.B \-\-type snapshot
-can be replaced with
-.B \-s
-or
-.B \-\-snapshot.
-
 .SH Examples
 .
 Convert a linear LV to a two-way mirror LV:
@@ -968,10 +1174,7 @@ Convert an LV into a thin LV in the specified thin pool.  The existing LV
 is used as an external read\-only origin for the new thin LV, and is
 renamed "external":
 .br
-.B lvconvert \-\-type thin \-\-thinpool vg/tpool1
-.RS
-.B \-\-originname external vg/lvol1
-.RE
+.B lvconvert -T \-\-thinpool vg/tpool1 \-\-originname external vg/lvol1
 
 Convert an LV to a cache pool LV using another specified LV for cache pool
 metadata:


