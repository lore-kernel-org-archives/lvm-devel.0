From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:45 +0000 (UTC)
Subject: master - man: lvconvert update
Message-ID: <20140711113445.9AF5D60701@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bbfac359c5e7e82a0600fa3d41bf7ea308e485f
Commit:        4bbfac359c5e7e82a0600fa3d41bf7ea308e485f
Parent:        b2988a917af8ca16814b067c1d73f899e871e1d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:28:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:23 2014 +0200

man: lvconvert update

Update lvconvert doc for conversion of pools
(thin and cache pools and volumes)

Various more cleanups.
---
 man/lvconvert.8.in |  178 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 99 insertions(+), 79 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index f96cee2..e038371 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -5,26 +5,26 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .B lvconvert
 .BR \-m | \-\-mirrors
 .I Mirrors
+.RB [ \-\-type
+.IR SegmentType ]
 .RB [ \-\-mirrorlog
 .RI { disk | core | mirrored }]
 .RB [ \-\-corelog ]
 .RB [ \-R | \-\-regionsize
 .IR MirrorLogRegionSize ]
-.RB [ \-\-type
-.IR SegmentType ]
+.RB [ \-\-stripes
+.I Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
 .RB [ \-A | \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-b | \-\-background ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
 .RB [ \-f | \-\-force ]
 .RB [ \-i | \-\-interval
 .IR Seconds ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-stripes
-.I Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-y | \-\-yes ]
@@ -33,12 +33,12 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
 .B lvconvert \-\-splitmirrors \fIImages
-.RB [ \-\-commandprofile
-.IR ProfileName ]
 .RB [ \-\-name
 .IR SplitLogicalVolumeName ]
 .RB [ \-\-trackchanges ]
 .IR MirrorLogicalVolume [ Path ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RI [ SplittablePhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
 .B lvconvert
@@ -53,38 +53,38 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert
 .BR \-s | \-\-snapshot
-.RB [ \-\-commandprofile
-.IR ProfileName ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkK ]]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
 .RB [ \-\-version ]
 .IR OriginalLogicalVolume [ Path ]
 .IR SnapshotLogicalVolume [ Path ]
 .sp
 .B lvconvert \-\-merge
-.RB [ \-\-commandprofile
-.IR ProfileName ]
 .RB [ \-b | \-\-background ]
 .RB [ \-i | \-\-interval
 .IR Seconds ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]...
 .sp
 .B lvconvert \-\-repair
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-stripes
 .I Stripes
 .RB [ \-I | \-\-stripesize
 .IR StripeSize ]]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]
@@ -99,10 +99,12 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR LogicalVolume [ Path ]
 .RI [ PhysicalVolume [ Path ]...]
 .sp
-.B lvconvert \-\-thinpool
+.B lvconvert
+.RB [{ \-\-type \  \fIthin [ \fI\-pool ]| \-T | \-\-thin }
+.RB [ \-\-originname
+.IR NewExternalOriginVolumeName ]]
+.RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
-.RB [ \-\-commandprofile
-.IR ProfileName ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
@@ -114,24 +116,22 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR ThinPoolMetadataSize [ bBsSkKmMgG ]}]
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
-.RB [ \-\-stripes
-.I Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
-.RB [ \-T | \-\-thin
-.IR ExternalOriginLogicalVolume { Name | Path }
-.RB [ \-\-originname
-.IR NewExternalOriginVolumeName ]]
-.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
+.RB [ \-\-stripes \ \fIStripes
+.RB [ \-I | \-\-stripesize \  \fIStripeSize ]]]
+.RB [ \-Z | \-\-zero \ { \fIy | \fIn }]]
+.RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
+.RI [ PhysicalVolume [ Path ][ :PE
+.RI [ \-PE ]]...]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .sp
-.B lvconvert \-\-type \fIcache-pool
-.RB [ \-\-commandprofile
-.IR ProfileName ]
+.B lvconvert
+.RB [ \-\-type \  \fIcache [ \fI\-pool ]| \-\-cache ]
+.RB [ \-\-cachepool
+.IR CachePoolLV { Name | Path }]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -141,16 +141,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 |
 .B \-\-poolmetadatasize
 .IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
-.IR LogicalVolume [ Path ]
+.IR LogicalVolume { Name | Path }
 .RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.sp
-.B lvconvert \-\-type \fIcache
-.B \-\-cachepool
-.IR CachePoolLV { Name | Path }
-.IR LogicalVolume [ Path ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
@@ -176,6 +168,7 @@ the freed extents come first from the specified PhysicalVolumes.
 See \fBlvm\fP(8) for common options.
 .br
 Exactly one of
+.BR \-\-cache ,
 .BR \-\-merge ,
 .BR \-\-mirrors ,
 .BR \-\-repair ,
@@ -183,8 +176,7 @@ Exactly one of
 .BR \-\-splitsnapshot ,
 .BR \-\-snapshot ,
 .BR \-\-splitmirrors ,
-.BR \-\-thin ,
-.BR \-\-thinpool
+.BR \-\-thin
 or
 .BR \-\-type
 arguments is required.
@@ -192,20 +184,25 @@ arguments is required.
 .BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
+.BR \-\-cache ", " \-\-type\ \fIcache
+Converts logical volume to a cached LV with the use of cache pool
+specified with \fB\-\-cachepool\fP.
+For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(8).
+.TP
 .BR \-\-cachepool " " \fICachePoolLV
 This argument is necessary when converting a logical volume to a cache LV.
-For more information on cache pool LVs and cache LVs, see \fBlvm\fP(8).
+For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(8).
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
 For example, "\fB\-m 1\fP" would convert the original logical
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.  There are two implementations of mirroring
-which correspond to the "raid1" and "mirror" segment types.  The default
-mirroring segment type is "raid1".  If the legacy "mirror" segment type
+which correspond to the "\fIraid1\fP" and "\fImirror\fP" segment types.  The default
+mirroring segment type is "\fIraid1\fP".  If the legacy "\fImirror\fP" segment type
 is desired, the \fB\-\-type\fP argument must be used to explicitly
 select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
-options below are only relevant to the legacy "mirror" segment type.
+options below are only relevant to the legacy "\fImirror\fP" segment type.
 .TP
 .IR \fB\-\-mirrorlog " {" disk | core | mirrored }
 Specifies the type of log to use.
@@ -227,14 +224,19 @@ uses this granularity to track which regions are in sync.
 .TP
 .B \-\-type \fISegmentType
 Used to convert a logical volume to another segment type, like
-.IR cache-pool ,
 .IR cache ,
+.IR cache-pool ,
 .IR raid1 ,
+.IR snapshot ,
+.IR thin ,
 or
 .IR thin-pool .
 When converting a logical volume to a cache LV, the
 .B \-\-cachepool
 argument is required.
+When converting a logical volume to a thin LV, the
+.B \-\-thinpool
+argument is required.
 See \fBlvmcache\fP(7) for more info about caching support
 and \fBlvmthin\fP(7) for thin provisioning support.
 .TP
@@ -274,28 +276,30 @@ along with the metadata describing them.  This volume can be wiped and then
 destroyed with lvremove.
 The inverse of \fB\-\-snapshot\fP.
 .TP
-.B \-s, \-\-snapshot
+.BR \-s ", " \-\-snapshot ", " \-\-type\ \fIsnapshot
 Recreates a snapshot from constituent logical volumes (or copies of them) after
 having been separated using \fB\-\-splitsnapshot\fP.
 For this to work correctly, no changes may be made to the contents
 of either volume after the split.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
-Gives the size of chunk for snapshot and thin pool logical volumes.
+Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
-.br
+.sp
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
-.br
+.sp
+For cache pools the value must be between 32KiB and 1GiB and
+the default value is 64.
+.sp
 For thin pools the value must be between 64KiB and
 1GiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MiB,
 if the pool metadata size is not specified.
-The value must be a multiple of 64KiB. 
+The value must be a multiple of 64KiB.
 (Early kernel support until thin target version 1.4 required the value
 to be a power of 2.  Discards weren't supported for non-power of 2 values
 until thin target version 1.5.)
-Default unit is in kilobytes.
 .TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Specifies whether or not discards will be processed by the thin layer in the
@@ -306,7 +310,7 @@ Default is \fIpassdown\fP.
 Controls zeroing of the first 4KiB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 For thin pool volumes it controls zeroing of provisioned blocks.
-Note: Provisioning of large zeroed chunks impacts performance.
+Note: Provisioning of large zeroed chunks negatively impacts performance.
 .TP
 .B \-\-merge
 Merges a snapshot into its origin volume or merges a raid1 image that has
@@ -327,25 +331,35 @@ be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
 .TP
 .B \-\-originname \fINewExternalOriginVolumeName\fP
-The new name for original logical volume, which becomes external origin volume.
+The new name for original logical volume, which becomes external origin volume
+for a thin logical volume that will use given \fB\-\-thinpool\fP.
 .br
-Without this option a default names of "lvol#" will be generated where
-# is the LVM internal number of the logical volume.
+Without this option a default name of "lvol<n>" will be generated where
+<n> is the LVM internal number of the logical volume.
 This volume will be read-only and cannot be further modified as long,
-as it is being used as external origin.
+as it is being used as the external origin.
 .TP
 .BR \-\-poolmetadata " " \fIThinPoolMetadataLogicalVolume { \fIName | \fIPath }
-Specifies thin pool metadata logical volume.
+Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
+Cache pool is specified with the option
+\fB\-\-cachepool\fP.
 Thin pool is specified with the option
 \fB\-\-thinpool\fP.
-When the specified thin pool already exists,
-the thin pool's metadata volume will be swapped with the given LV.
-Properties of the thin pool like chunk size, discards or zero
+When the specified pool already exists,
+the pool's metadata volume will be swapped with the given LV.
+Pool properties (like chunk size, discards or zero)
 are preserved by default in this case.
-It can be useful for thin pool metadata repair or its offline resize,
-since the content of metadata becomes accessible for
-thin provisioning tools \fBthin_dump\fP(8) and \fBthin_restore\fP(8).
+It can be useful for pool metadata repair or its offline resize,
+since the metadata volume is available as regular volume for a user with
+thin provisioning tools
+.BR cache_dump (8),
+.BR cache_repair (8),
+.BR cache_restore (8),
+.BR thin_dump (8),
+.BR thin_repair (8)
+and
+.BR thin_restore (8).
 .TP
 .BR \-\-poolmetadatasize " " \fIThinPoolMetadataSize [ \fIbBsSkKmMgG ]
 Sets the size of thin pool's metadata logical volume,
@@ -380,13 +394,16 @@ Only inactive thin pool volumes can be repaired.
 There is no validation of metadata between kernel and lvm2.
 This requires further manual work.
 After successfull repair the old unmodified metadata are still
-available in \fB<pool>_meta<n>\fP LV.
+available in "<pool>_meta<n>" LV.
 .TP
 .B \-\-replace \fIPhysicalVolume
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
 that is available in the volume group or from the specific list provided.
 This option is only available to RAID segment types
-(e.g. "raid1", "raid5", etc).
+(e.g. 
+.IR raid1 ,
+.IR raid5 ,
+etc).
 .TP
 .BR \-\-stripes " " \fIStripes
 Gives the number of stripes.
@@ -401,17 +418,17 @@ StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
-.IR \fB\-T ", " \fB\-\-thin " " ExternalOriginLogicalVolume { Name | Path }
+.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-type " " thin
 Converts the logical volume into a thin logical volume of the thin pool
 specified with \fB\-\-thinpool\fP. The original logical volume
 .I ExternalOriginLogicalVolume
 is renamed into a new read-only logical volume.
-The non-default name for this volume use \fB\-\-originname\fP.
+For the non-default name for this volume use \fB\-\-originname\fP.
 The volume cannot be further modified as long as it is used as an
 external origin volume for unprovisioned areas of any thin logical volume.
 .TP
 .IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
-Switches logical volume into a thin pool's data volume.
+Specifies or converts logical volume into a thin pool's data volume.
 Content of converted volume is lost.
 Thin pool's metadata logical volume can be specified with the option
 \fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
@@ -507,14 +524,14 @@ and convert "vg00/lv1" into a thin volume using this pool. Original "vg00/lv1"
 is used as an external read-only origin, where all writes to such volume
 are stored in the "vg00/lvpool".
 .sp
-.B lvconvert \-\-thinpool vg00/lvpool \-c 128 \-T lv1
+.B lvconvert \-\-type thin \-\-thinpool vg00/lvpool \-c 128 lv1
 
 Convert the logical volume "vg00/origin" into a thin volume from the thin pool
 "vg00/lvpool". This thin volume will use "vg00/origin" as an external origin
 volume for unprovisioned areas in this volume.
 For the read-only external origin use the new name "vg00/external".
 .sp
-.B lvconvert \-\-thinpool vg00/lvpool \-\-originname external \-T vg00/origin
+.B lvconvert \-T \-\-thinpool vg00/lvpool \-\-originname external vg00/origin
 
 Convert an existing logical volume to a cache pool LV using the
 given cache metadata LV.
@@ -526,7 +543,7 @@ given cache metadata LV.
 Convert an existing logical volume to a cache LV using the given
 cache pool LV.
 .sp
-.B lvconvert \-\-type cache  \-\-cachepool vg00/lvx_cachepool vg00/lvx
+.B lvconvert \-\-cache  \-\-cachepool vg00/lvx_cachepool vg00/lvx
 
 .SH SEE ALSO
 .BR lvm (8),
@@ -540,6 +557,9 @@ cache pool LV.
 .BR lvrename (8),
 .BR lvscan (8),
 .BR vgcreate (8),
+.BR cache_dump (8),
+.BR cache_repair (8),
+.BR cache_restore (8),
 .BR thin_dump (8),
-.BR thin_repair (8)
+.BR thin_repair (8),
 .BR thin_restore (8)


