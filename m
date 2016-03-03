From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:06 +0000 (UTC)
Subject: master - man: lvconvert updates
Message-ID: <20160303092006.815C1605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd349cb2e50ff60abb5c79d2aab60cc753faa174
Commit:        fd349cb2e50ff60abb5c79d2aab60cc753faa174
Parent:        88ce15004e414a64a3f967908cb2721671a191ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 23:51:16 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

man: lvconvert updates

Improving style (following lvcreate way).
Sorting options alphabetically.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |  612 +++++++++++++++++++++++++++++++---------------------
 2 files changed, 369 insertions(+), 244 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 668e8a4..f623226 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.145 - 
 =====================================
+  Improve lvconvert man page.
   Add kernel_cache_policy lvs field.
   Display [unknown] instead of 'unknown device' in pvs output.
   Fix error path when pvcreate allocation fails (2.02.144).
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 4438893..b889345 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -1,19 +1,22 @@
 .TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
 .SH NAME
 lvconvert \(em convert a logical volume from linear to mirror or snapshot
+.
 .SH SYNOPSIS
+.
+.ad l
 .B lvconvert
 .BR \-m | \-\-mirrors
-.I Mirrors
+.IR Mirrors
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-\-mirrorlog
-.RI { disk | core | mirrored }]
+.RB { disk | core | mirrored }]
 .RB [ \-\-corelog ]
 .RB [ \-R | \-\-regionsize
 .IR MirrorLogRegionSize ]
 .RB [ \-\-stripes
-.I Stripes
+.IR Stripes
 .RB [ \-I | \-\-stripesize
 .IR StripeSize ]]
 .RB [ \-A | \-\-alloc
@@ -29,76 +32,80 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-v | \-\-verbose ]
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-version ]
-.IR LogicalVolume [ Path ]
-.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
+.IR LogicalVolume
+.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
 .sp
 .B lvconvert
-.BR \-\-split
+.BR \-\-merge
+.RB [ \-b | \-\-background ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
-.IR SplitableLogicalVolume { Name | Path }
+.RB [ \-\-version ]
+.IR LogicalVolume...
 .sp
 .B lvconvert
-.BR \-\-splitcache | \-\-uncache
+.BR \-s | \-\-snapshot
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-Z | \-\-zero
+.RB { y | n }]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR CacheLogicalVolume { Name | Path }
-.sp
-.B lvconvert \-\-splitmirrors \fIImages
-.RB [ \-\-name
-.IR SplitLogicalVolumeName ]
-.RB [ \-\-trackchanges ]
-.IR MirrorLogicalVolume [ Path ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RI [ SplittablePhysicalVolume [ Path ][ :PE [ \-PE ]]...]
+.IR OriginalLogicalVolume
+.IR SnapshotLogicalVolume
 .sp
 .B lvconvert
-.BR \-\-splitsnapshot
+.BR \-\-split
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR SnapshotLogicalVolume [ Path ]
+.IR SplitableLogicalVolume
 .sp
 .B lvconvert
-.BR \-s | \-\-snapshot
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkK ]]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
+.BR \-\-splitcache | \-\-uncache
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR OriginalLogicalVolume [ Path ]
-.IR SnapshotLogicalVolume [ Path ]
+.IR CacheLogicalVolume
 .sp
-.B lvconvert \-\-merge
-.RB [ \-b | \-\-background ]
-.RB [ \-i | \-\-interval
-.IR Seconds ]
+.B lvconvert
+.BR \-\-splitmirrors
+.IR Images
+.RB [ \-\-name
+.IR SplitLogicalVolumeName ]
+.RB [ \-\-trackchanges ]
+.IR MirrorLogicalVolume
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RI [ SplittablePhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.sp
+.B lvconvert
+.BR \-\-splitsnapshot
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR LogicalVolume [ Path ]...
+.IR SnapshotLogicalVolume
 .sp
-.B lvconvert \-\-repair
+.B lvconvert
+.BR \-\-repair
 .RB [ \-\-stripes
-.I Stripes
+.IR Stripes
 .RB [ \-I | \-\-stripesize
 .IR StripeSize ]]
 .RB [ \-\-commandprofile
@@ -106,82 +113,87 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR LogicalVolume [ Path ]
+.IR LogicalVolume
 .RI [ PhysicalVolume [ Path ]...]
 .sp
-.B lvconvert \-\-replace \fIPhysicalVolume
+.B lvconvert
+.BR \-\-replace
+.IR PhysicalVolume
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR LogicalVolume [ Path ]
+.IR LogicalVolume
 .RI [ PhysicalVolume [ Path ]...]
 .sp
 .B lvconvert
-.B \-\-type
-.BR \fIthin [ \fI\-pool ]| \-T | \-\-thin
-.RB [ \-\-originname
-.IR NewExternalOriginVolumeName ]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
+.BR \-\-type
+.BR cache [ \-pool ]| \-H | \-\-cache
+.RB [ \-\-cachepool
+.IR CachePoolLogicalVolume ]
+.\" |
+.\" .B \-\-pooldatasize
+.\" .IR CachePoolMetadataSize ]
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkKmMgG ]]
-.RB [ \-\-discards
-.RI { ignore | nopassdown | passdown }]
+.IR ChunkSize ]
+.RB [ \-\-cachemode
+.RB { writeback | writethrough }]
+.RB [ \-\-cachepolicy
+.IR Policy ]
+.RB [ \-\-cachesettings
+.IR Key \fB= Value ]...
 .RB [ \-\-poolmetadata
-.IR ThinPoolMetadataLogicalVolume { Name | Path }
-|
-.B \-\-poolmetadatasize
-.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]
-.RB [ \-r | \-\-readahead
-.RI { ReadAheadSectors | auto | none }]
-.RB [ \-\-stripes \ \fIStripes
-.RB [ \-I | \-\-stripesize \  \fIStripeSize ]]]
+.IR CachePoolMetadataLogicalVolume
+.RB |
+.BR \-\-poolmetadatasize
+.IR CachePoolMetadataSize ]
 .RB [ \-\-poolmetadataspare
-.RI { y | n }]
-.RB [ \-Z | \-\-zero \ { \fIy | \fIn }]]
+.RB { y | n }]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
-.RI [ PhysicalVolume [ Path ][ :PE
-.RI [ \-PE ]]\ \.\|\.\|\.
+.IR LogicalVolume
+.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
 .sp
 .B lvconvert
-.B \-\-type
-.BR \fIcache [ \fI\-pool ]| \-H | \-\-cache
-.RB [ \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }]
-.\" |
-.\" .B \-\-pooldatasize
-.\" .IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]]
+.BR \-\-type
+.BR thin [ \-pool ]| \-T | \-\-thin
+.RB [ \-\-originname
+.IR NewExternalOriginVolumeName ]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolume
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkKmMgG ]]
-.RB [ \-\-cachemode
-.RI { writeback | writethrough }]
-.RB [ \-\-cachepolicy
-.IR policy ]
-.RB [ \-\-cachesettings
-.IR key=value ]
+.IR ChunkSize ]
+.RB [ \-\-discards
+.RB { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadata
-.IR CachePoolMetadataLogicalVolume { Name | Path }
-|
-.B \-\-poolmetadatasize
-.IR CachePoolMetadataSize [ bBsSkKmMgG ]]
+.IR ThinPoolMetadataLogicalVolume
+.RB |
+.BR \-\-poolmetadatasize
+.IR ThinPoolMetadataSize ]
+.RB [ \-r | \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }]
+.RB [ \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]]
 .RB [ \-\-poolmetadataspare
-.RI { y | n }]
+.RB { y | n }]
+.RB [ \-Z | \-\-zero
+.RB { y | n }]]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.IR LogicalVolume { Name | Path }
-.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
+.RI [[ ExternalOrigin | ThinPool ] LogicalVolume ]
+.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.ad b
 .sp
-
+.
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
 characteristics of a logical volume.  For example, it can add or remove the
@@ -196,7 +208,9 @@ these physical extents.  If the conversion frees physical extents
 (for example, when converting from a mirror to a linear, or reducing
 mirror legs) and you specify one or more PhysicalVolumes,
 the freed extents come first from the specified PhysicalVolumes.
+.
 .SH OPTIONS
+.
 See \fBlvm\fP(8) for common options.
 .br
 Exactly one of
@@ -217,140 +231,58 @@ Exactly one of
 or
 .BR \-\-uncache
 arguments is required.
-.TP
-.BR \-b ", " \-\-background
+.
+.HP
+.BR \-b ,
+.BR \-\-background
+.br
 Run the daemon in the background.
-.TP
-.BR \-H ", " \-\-cache ", " \-\-type\ \fIcache
+.
+.HP
+.BR \-H ,
+.BR \-\-cache ,
+.BR \-\-type\ cache
+.br
 Converts logical volume to a cached LV with the use of cache pool
 specified with \fB\-\-cachepool\fP.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
-.TP
-.B \-\-cachepolicy \fIpolicy
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy. \fImq\fP is the basic policy name. \fIsmq\fP is more advanced
+.
+.HP
+.BR \-\-cachepolicy
+.IR Policy
+.br
+Only applicable to cached LVs; see also \fBlvmcache\fP(7). Sets
+the cache policy. \fBmq\fP is the basic policy name. \fBsmq\fP is more advanced
 version available in newer kernels.
-.TP
-.BR \-\-cachepool " " \fICachePoolLV
+.
+.HP
+.BR \-\-cachepool
+.IR CachePoolLV
+.br
 This argument is necessary when converting a logical volume to a cache LV.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
-.TP
-.BR \-\-cachesettings " " \fIkey=value
+.
+.HP
+.BR \-\-cachesettings
+.IR Key \fB= Value
+.br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache tunable settings. In most use-cases, default values should be adequate.
-Special string value \fIdefault\fP switches setting back to its default kernel value
+Special string value \fBdefault\fP switches setting back to its default kernel value
 and removes it from the list of settings stored in lvm2 metadata.
-.TP
-.BR \-m ", " \-\-mirrors " " \fIMirrors
-Specifies the degree of the mirror you wish to create.
-For example, "\fB\-m 1\fP" would convert the original logical
-volume to a mirror volume with 2-sides; that is, a
-linear volume plus one copy.  There are two implementations of mirroring
-which correspond to the "\fIraid1\fP" and "\fImirror\fP" segment types.  The default
-mirroring segment type is "\fIraid1\fP".  If the legacy "\fImirror\fP" segment type
-is desired, the \fB\-\-type\fP argument must be used to explicitly
-select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
-options below are only relevant to the legacy "\fImirror\fP" segment type.
-.TP
-.IR \fB\-\-mirrorlog " {" disk | core | mirrored }
-Specifies the type of log to use.
-The default is \fIdisk\fP, which is persistent and requires
-a small amount of storage space, usually on a separate device
-from the data being mirrored.
-\fICore\fP may be useful for short-lived mirrors: It means the mirror is
-regenerated by copying the data from the first device again every
-time the device is activated - perhaps, for example, after every reboot.
-Using \fImirrored\fP will create a persistent log that is itself mirrored.
-.TP
-.B \-\-corelog
-The optional argument \fB\-\-corelog\fP is the same as specifying
-\fB\-\-mirrorlog\fP \fIcore\fP.
-.TP
-.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize
-A mirror is divided into regions of this size (in MB), and the mirror log
-uses this granularity to track which regions are in sync.
-.TP
-.B \-\-type \fISegmentType
-Used to convert a logical volume to another segment type, like
-.IR cache ,
-.IR cache-pool ,
-.IR raid1 ,
-.IR snapshot ,
-.IR thin ,
-or
-.IR thin-pool .
-When converting a logical volume to a cache LV, the
-.B \-\-cachepool
-argument is required.
-When converting a logical volume to a thin LV, the
-.B \-\-thinpool
-argument is required.
-See \fBlvmcache\fP(7) for more info about caching support
-and \fBlvmthin\fP(7) for thin provisioning support.
-.TP
-.BR \-i ", " \-\-interval " " \fISeconds
-Report progress as a percentage at regular intervals.
-.TP
-.B \-\-noudevsync
-Disables udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.B \-\-splitmirrors \fIImages
-The number of redundant \fIImages\fP of a mirror to be split off and used
-to form a new logical volume.  A name must be supplied for the
-newly-split-off logical volume using the \fB\-\-name\fP argument, unless
-the \fB\-\-trackchanges\fP argument is given.
-.TP
-.BR \-n ", " \-\-name\  \fIName
-The name to apply to a logical volume which has been split off from
-a mirror logical volume.
-.TP
-.B \-\-trackchanges
-Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
-that the read-only detached image can be merged efficiently back into
-the mirror later. Only the regions of the detached device where
-the data changed get resynchronized.
-
-Please note that this feature is only supported with the new md-based mirror
-implementation and not with the original device-mapper mirror implementation.
-.TP
-.B \-\-split
-Separates \fISplitableLogicalVolume\fP.
-Option is agregating various split commands and tries to detect necessary split
-operation from its arguments.
-.TP
-.BR \-\-splitcache
-Separates \fICacheLogicalVolume\fP from cache pool.
-Before the logical volume becomes uncached, cache is flushed.
-The cache pool volume is then left unused and
-could be used e.g. for caching another volume.
-See also the option \fB\-\-uncache\fP for uncaching and removing
-cache pool with one command.
-.TP
-.B \-\-splitsnapshot
-Separates \fISnapshotLogicalVolume\fP from its origin.
-The volume that is split off contains the chunks that differ from the origin
-along with the metadata describing them.  This volume can be wiped and then
-destroyed with lvremove.
-The inverse of \fB\-\-snapshot\fP.
-.TP
-.BR \-s ", " \-\-snapshot ", " \-\-type\ \fIsnapshot
-Recreates a snapshot from constituent logical volumes (or copies of them) after
-having been separated using \fB\-\-splitsnapshot\fP.
-For this to work correctly, no changes may be made to the contents
-of either volume after the split.
-.TP
-.BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
+.
+.HP
+.BR \-c ,
+.BR \-\-chunksize
+.BR \fIChunkSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
 .sp
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
 .sp
-For cache pools the value must be between 32KiB and 1GiB and
+For cache the value must be between 32KiB and 1GiB and
 the default value is 64.
 .sp
 For thin pools the value must be between 64KiB and
@@ -361,20 +293,32 @@ The value must be a multiple of 64KiB.
 (Early kernel support until thin target version 1.4 required the value
 to be a power of 2.  Discards weren't supported for non-power of 2 values
 until thin target version 1.5.)
-.TP
-.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
+.
+.HP
+.BR \-\-corelog
+.br
+The optional argument \fB\-\-corelog\fP is the same as specifying
+\fB\-\-mirrorlog core\fP.
+.
+.HP
+.BR \-\-discards
+.RB { ignore | nopassdown | passdown }
+.br
 Specifies whether or not discards will be processed by the thin layer in the
 kernel and passed down to the Physical Volume.
 Options is currently supported only with thin pools.
-Default is \fIpassdown\fP.
-.TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-Controls zeroing of the first 4KiB of data in the snapshot.
-If the volume is read-only the snapshot will not be zeroed.
-For thin pool volumes it controls zeroing of provisioned blocks.
-Note: Provisioning of large zeroed chunks negatively impacts performance.
-.TP
-.B \-\-merge
+Default is \fBpassdown\fP.
+.
+.HP
+.BR \-i ,
+.BR \-\-interval
+.IR Seconds
+.br
+Report progress as a percentage at regular intervals.
+.
+.HP
+.BR \-\-merge
+.br
 Merges a snapshot into its origin volume or merges a raid1 image that has
 been split from its mirror with \fB\-\-trackchanges\fP back into its mirror.
 
@@ -391,8 +335,56 @@ origin appear as they were directed to the snapshot being merged.  When the
 merge finishes, the merged snapshot is removed.  Multiple snapshots may
 be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
-.TP
-.B \-\-originname \fINewExternalOriginVolumeName\fP
+.
+.HP
+.BR \-m ,
+.BR \-\-mirrors
+.IR Mirrors
+.br
+Specifies the degree of the mirror you wish to create.
+For example, "\fB\-m 1\fP" would convert the original logical
+volume to a mirror volume with 2-sides; that is, a
+linear volume plus one copy.  There are two implementations of mirroring
+which correspond to the "\fIraid1\fP" and "\fImirror\fP" segment types.  The default
+mirroring segment type is "\fIraid1\fP".  If the legacy "\fImirror\fP" segment type
+is desired, the \fB\-\-type\fP argument must be used to explicitly
+select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
+options below are only relevant to the legacy "\fImirror\fP" segment type.
+.
+.HP
+.BR \-\-mirrorlog
+.RB { disk | core | mirrored }
+.br
+Specifies the type of log to use.
+The default is \fBdisk\fP, which is persistent and requires
+a small amount of storage space, usually on a separate device
+from the data being mirrored.
+\fBCore\fP may be useful for short-lived mirrors: It means the mirror is
+regenerated by copying the data from the first device again every
+time the device is activated - perhaps, for example, after every reboot.
+Using \fBmirrored\fP will create a persistent log that is itself mirrored.
+.
+.HP
+.BR \-n ,
+.BR \-\-name
+.IR Name
+.br
+The name to apply to a logical volume which has been split off from
+a mirror logical volume.
+.
+.HP
+.BR \-\-noudevsync
+.br
+Disables udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.
+.HP
+.BR \-\-originname
+.IR NewExternalOriginVolumeName
+.br
 The new name for original logical volume, which becomes external origin volume
 for a thin logical volume that will use given \fB\-\-thinpool\fP.
 .br
@@ -400,12 +392,18 @@ Without this option a default name of "lvol<n>" will be generated where
 <n> is the LVM internal number of the logical volume.
 This volume will be read-only and cannot be further modified as long,
 as it is being used as the external origin.
-.TP
-.\" .IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
+.
+.\" .HP
+.\" .BR \-\-pooldatasize
+.\" .IR PoolDataVolumeSize [ \fBbBsSkKmMgGtTpPeE ]
+.\" .br
 .\" Sets the size of pool's data logical volume.
 .\" The option \fB\-\-size\fP could be still used with thin pools.
-.\" .TP
-.BR \-\-poolmetadata " " \fIPoolMetadataLogicalVolume { \fIName | \fIPath }
+.
+.HP
+.BR \-\-poolmetadata
+.IR PoolMetadataLogicalVolume
+.br
 Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
 Cache pool is specified with the option
@@ -426,8 +424,11 @@ thin provisioning tools
 .BR thin_repair (8)
 and
 .BR thin_restore (8).
-.TP
-.BR \-\-poolmetadatasize " " \fIPoolMetadataSize [ \fIbBsSkKmMgG ]
+.
+.HP
+.BR \-\-poolmetadatasize
+.BR \fIPoolMetadataSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the size of cache or thin pool's metadata logical volume,
 if the pool metadata volume is undefined.
 Pool is specified with the option
@@ -436,21 +437,38 @@ For thin pool supported value is in the range between 2MiB and 16GiB.
 The default value is estimated with this formula
 (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
-.TP
-.IR \fB\-\-poolmetadataspare " {"  y | n }
+.
+.HP
+.BR \-\-poolmetadataspare
+.RB { y | n }
+.br
 Controls creation and maintanence of pool metadata spare logical volume
 that will be used for automated pool recovery.
 Only one such volume is maintained within a volume group
 with the size of the biggest pool metadata volume.
-Default is \fIy\fPes.
-.TP
-.IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
+Default is \fBy\fPes.
+.
+.HP
+.BR \-r ,
+.BR \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }
+.br
 Sets read ahead sector count of thin pool metadata logical volume.
-The default value is "\fIauto\fP" which allows the kernel to choose
+The default value is \fBauto\fP which allows the kernel to choose
 a suitable value automatically.
-"\fINone\fP" is equivalent to specifying zero.
-.TP
-.B \-\-repair
+\fBNone\fP is equivalent to specifying zero.
+.
+.HP
+.BR \-R ,
+.BR \-\-regionsize
+.IR MirrorLogRegionSize
+.br
+A mirror is divided into regions of this size (in MB), and the mirror log
+uses this granularity to track which regions are in sync.
+.
+.HP
+.BR \-\-repair
+.br
 Repair a mirror after suffering a disk failure or try to fix thin pool metadata.
 
 The mirror will be brought back into a consistent state.
@@ -459,8 +477,8 @@ restored if possible.  Specify \fB\-y\fP on the command line to skip
 the prompts. Use \fB\-f\fP if you do not want any replacement.
 Additionally, you may use \fB\-\-use\-policies\fP to use the device
 replacement policy specified in \fBlvm.conf\fP(5),
-viz. activation/mirror_log_fault_policy or
-activation/mirror_device_fault_policy.
+see \fBactivation/mirror_log_fault_policy\fP or
+\fBactivation/mirror_device_fault_policy\fP.
 
 Thin pool repair automates the use of \fBthin_repair\fP(8) tool.
 Only inactive thin pool volumes can be repaired.
@@ -468,8 +486,11 @@ There is no validation of metadata between kernel and lvm2.
 This requires further manual work.
 After successfull repair the old unmodified metadata are still
 available in "<pool>_meta<n>" LV.
-.TP
-.B \-\-replace \fIPhysicalVolume
+.
+.HP
+.BR \-\-replace
+.IR PhysicalVolume
+.br
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
 that is available in the volume group or from the specific list provided.
 This option is only available to RAID segment types
@@ -477,43 +498,146 @@ This option is only available to RAID segment types
 .IR raid1 ,
 .IR raid5 ,
 etc).
-.TP
-.BR \-\-stripes " " \fIStripes
+.
+.HP
+.BR \-\-splitmirrors
+.IR Images
+.br
+The number of redundant \fIImages\fP of a mirror to be split off and used
+to form a new logical volume.  A name must be supplied for the
+newly-split-off logical volume using the \fB\-\-name\fP argument, unless
+the \fB\-\-trackchanges\fP argument is given.
+.
+.HP
+.BR \-s ,
+.BR \-\-snapshot ,
+.BR \-\-type\ snapshot
+.br
+Recreates a snapshot from constituent logical volumes (or copies of them) after
+having been separated using \fB\-\-splitsnapshot\fP.
+For this to work correctly, no changes may be made to the contents
+of either volume after the split.
+.
+.HP
+.BR \-\-split
+.br
+Separates \fISplitableLogicalVolume\fP.
+Option is agregating various split commands and tries to detect necessary split
+operation from its arguments.
+.
+.HP
+.BR \-\-splitcache
+.br
+Separates \fICacheLogicalVolume\fP from cache pool.
+Before the logical volume becomes uncached, cache is flushed.
+The cache pool volume is then left unused and
+could be used e.g. for caching another volume.
+See also the option \fB\-\-uncache\fP for uncaching and removing
+cache pool with one command.
+.
+.HP
+.BR \-\-splitsnapshot
+.br
+Separates \fISnapshotLogicalVolume\fP from its origin.
+The volume that is split off contains the chunks that differ from the origin
+along with the metadata describing them.  This volume can be wiped and then
+destroyed with lvremove.
+The inverse of \fB\-\-snapshot\fP.
+.
+.HP
+.BR \-\-stripes
+.IR Stripes
+.br
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
 the logical volume. This does not apply to existing allocated
 space, only newly allocated space can be striped.
-.TP
-.BR \-I ", " \-\-stripesize " " \fIStripeSize
+.
+.HP
+.BR \-I ,
+.BR \-\-stripesize
+.IR StripeSize
+.br
 Gives the number of kilobytes for the granularity of the stripes.
 .br
 StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
-.TP
-.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-type " " thin
+.
+.HP
+.BR \-T ,
+.BR \-\-thin ,
+.BR \-\-type
+.BR thin
+.br
 Converts the logical volume into a thin logical volume of the thin pool
 specified with \fB\-\-thinpool\fP. The original logical volume
-.I ExternalOriginLogicalVolume
+\fIExternalOriginLogicalVolume\fP
 is renamed into a new read-only logical volume.
 For the non-default name for this volume use \fB\-\-originname\fP.
 The volume cannot be further modified as long as it is used as an
 external origin volume for unprovisioned areas of any thin logical volume.
-.TP
-.IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
+.
+.HP
+.BR \-\-thinpool
+.IR ThinPoolLogicalVolume
+.br
 Specifies or converts logical volume into a thin pool's data volume.
 Content of converted volume is lost.
 Thin pool's metadata logical volume can be specified with the option
 \fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
-.TP
+.
+.HP
+.BR \-\-trackchanges
+.br
+Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
+that the read-only detached image can be merged efficiently back into
+the mirror later. Only the regions of the detached device where
+the data changed get resynchronized.
+
+Please note that this feature is only supported with the new md-based mirror
+implementation and not with the original device-mapper mirror implementation.
+.
+.HP
+.BR \-\-type
+.IR SegmentType
+.br
+Used to convert a logical volume to another segment type, like
+.BR cache ,
+.BR cache-pool ,
+.BR raid1 ,
+.BR snapshot ,
+.BR thin ,
+or
+.BR thin-pool .
+When converting a logical volume to a cache LV, the
+\fB\-\-cachepool\fP argument is required.
+When converting a logical volume to a thin LV, the
+\fB\-\-thinpool\fP argument is required.
+See \fBlvmcache\fP(7) for more info about caching support
+and \fBlvmthin\fP(7) for thin provisioning support.
+.
+.HP
 .BR \-\-uncache
+.br
 Uncaches \fICacheLogicalVolume\fP.
 Before the volume becomes uncached, cache is flushed.
 Unlike with \fB\-\-splitcache\fP the cache pool volume is removed.
 This option could be seen as an inverse of \fB\-\-cache\fP.
-
+.
+.HP
+.BR \-Z ,
+.BR \-\-zero
+.RB { y | n }
+.br
+Controls zeroing of the first 4KiB of data in the snapshot.
+If the volume is read-only the snapshot will not be zeroed.
+For thin pool volumes it controls zeroing of provisioned blocks.
+Note: Provisioning of large zeroed chunks negatively impacts performance.
+.
 .SH Examples
+.
 Converts the linear logical volume "vg00/lvol1" to a two-way mirror
 logical volume:
 .sp


