From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  7 Jul 2016 22:13:44 +0000 (UTC)
Subject: master - man: rewrite lvconvert
Message-ID: <20160707221344.32421606B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=589b752eeb6b442f2987b1cd1736f8f461c9aa95
Commit:        589b752eeb6b442f2987b1cd1736f8f461c9aa95
Parent:        0de56eeaad0791821ac286c26f064c2744742848
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 6 15:26:56 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 7 17:12:37 2016 -0500

man: rewrite lvconvert

Based on the new enumeration of all possible commands.
---
 man/lvconvert.8.in | 1245 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 706 insertions(+), 539 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 12aaea2..855da9a 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -1,313 +1,527 @@
 .TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
 .SH NAME
-lvconvert \(em convert a logical volume from linear to mirror or snapshot
+lvconvert \(em change LV type and other utilities
 .
 .SH SYNOPSIS
-.
-.ad l
-.B lvconvert
-.BR \-m | \-\-mirrors
-.IR Mirrors
-.RB [ \-\-type
-.IR SegmentType ]
-.RB [ \-\-mirrorlog
-.RB { disk | core | mirrored }]
-.RB [ \-\-corelog ]
-.RB [ \-R | \-\-regionsize
-.IR MirrorLogRegionSize ]
-.RB [ \-\-stripes
-.IR Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB [ \-A | \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-b | \-\-background ]
-.RB [ \-f | \-\-force ]
-.RB [ \-i | \-\-interval
-.IR Seconds ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-y | \-\-yes ]
-.RB [ \-\-version ]
-.IR LogicalVolume
-.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
-.sp
-.B lvconvert
-.BR \-\-merge
-.RB [ \-b | \-\-background ]
-.RB [ \-i | \-\-interval
-.IR Seconds ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR LogicalVolume...
-.sp
-.B lvconvert
-.BR \-s | \-\-snapshot
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-Z | \-\-zero
-.RB { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR OriginalLogicalVolume
-.IR SnapshotLogicalVolume
-.sp
-.B lvconvert
-.BR \-\-split
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-v | \-\-verbose ]
-.IR SplitableLogicalVolume
-.sp
-.B lvconvert
-.BR \-\-splitcache | \-\-uncache
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR CacheLogicalVolume
-.sp
-.B lvconvert
-.BR \-\-splitmirrors
-.IR Images
-.RB [ \-\-name
-.IR SplitLogicalVolumeName ]
-.RB [ \-\-trackchanges ]
-.IR MirrorLogicalVolume
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RI \%[ SplittablePhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
-.sp
-.B lvconvert
-.BR \-\-splitsnapshot
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR SnapshotLogicalVolume
-.sp
-.B lvconvert
-.BR \-\-repair
-.RB [ \-\-stripes
-.IR Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR LogicalVolume
-.RI [ PhysicalVolume [ Path ]...]
-.sp
-.B lvconvert
-.BR \-\-replace
-.IR PhysicalVolume
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR LogicalVolume
-.RI [ PhysicalVolume [ Path ]...]
-.sp
-.B lvconvert
-.BR \-\-type
-.BR cache [ \-pool ]| \-H | \-\-cache
-.RB [ \-\-cachepool
-.IR CachePoolLogicalVolume ]
-.\" |
-.\" .B \-\-pooldatasize
-.\" .IR CachePoolMetadataSize ]
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-\-cachemode
-.RB { writeback | writethrough }]
-.RB [ \-\-cachepolicy
-.IR Policy ]
-.RB [ \-\-cachesettings
-.IR Key \fB= Value ]...
-.RB [ \-\-poolmetadata
-.IR CachePoolMetadataLogicalVolume
-.RB |
-.BR \-\-poolmetadatasize
-.IR CachePoolMetadataSize ]
-.RB [ \-\-poolmetadataspare
-.RB { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR LogicalVolume
-.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
-.sp
+
 .B lvconvert
-.BR \-\-type
-.BR thin [ \-pool ]| \-T | \-\-thin
-.RB [ \-\-originname
-.IR NewExternalOriginVolumeName ]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-\-discards
-.RB { ignore | nopassdown | passdown }]
-.RB [ \-\-poolmetadata
-.IR ThinPoolMetadataLogicalVolume
-.RB |
-.BR \-\-poolmetadatasize
-.IR ThinPoolMetadataSize ]
-.RB [ \-r | \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }]
-.RB [ \-\-stripes
-.IR Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB [ \-\-poolmetadataspare
-.RB { y | n }]
-.RB [ \-Z | \-\-zero
-.RB { y | n }]]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [[ ExternalOrigin | ThinPool ] LogicalVolume
-.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]]
-.ad b
-.sp
-.
+.RI [ OPTION ]...
+.IR VolumeGroup / LogicalVolume
+
 .SH DESCRIPTION
-lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
-characteristics of a logical volume.  For example, it can add or remove the
-redundant images of a logical volume, change the log type of a mirror, or
-designate a logical volume as a snapshot repository.
-.br
-If the conversion requires allocation of physical extents (for
-example, when converting from linear to mirror) and you specify
-one or more PhysicalVolumes (optionally with ranges of physical
-extents), allocation of physical extents will be restricted to
-these physical extents.  If the conversion frees physical extents
-(for example, when converting from a mirror to a linear, or reducing
-mirror legs) and you specify one or more PhysicalVolumes,
-the freed extents come first from the specified PhysicalVolumes.
-.
+
+lvconvert changes the LV type and includes various LV utilities.
+
+To display the current LV type, run the command:
+
+.B lvs \-o name,segtype VG/LV
+
+To change the LV type, run the command:
+
+.B lvconvert \-\-type
+.I NewType
+.B VG/LV
+
+.SS LV types
+
+The LV type is also called the "segment type" or "segtype".
+
+LVs with the following types can be modified by lvconvert:
+.B striped,
+.B snapshot,
+.B mirror,
+.B raid*,
+.B thin,
+.B cache,
+.B thin\-pool,
+.B cache\-pool.
+
+The specific operations available on each LV type are listed below.
+
+The
+.B linear
+type is equivalent to the
+.B striped
+type when one stripe exists.
+In that case, the types can sometimes be used interchangably.
+
+In most cases, the
+.B mirror
+type is deprecated and the
+.B raid1
+type should be used.  They are both implementations of mirroring.
+
+The
+.B raid*
+type refers to one of many raid levels, e.g.
+.B raid1,
+.B raid5.
+See
+.BR lvmraid (7)
+for a full list.
+
+.SS LV layers
+
+In some cases, an LV is a single device mapper (dm) layer above physical
+devices.  In other cases, hidden LVs (dm devices) are layered between the
+visible LV and physical devices.  LVs in the middle layers are sometimes
+called sub LVs.
+
+Changing the LV type will often change the composition of sub LVs.
+
+Sub LVs can be displayed with the command
+.B lvs -a.
+
+A command run on a visible LV sometimes operates on a sub LV rather than
+the specified LV.  These cases are noted below.
+
+Sometimes a sub LV must be specified directly on the command line, but
+this is a non-standard form.  These cases may change in the future to
+avoid the direct use of hidden LVs.
+
+.SH COMMANDS
+
+.SS Operations on a StripedLV with type striped or linear:
+
+\&
+
+.B lvconvert \-\-merge
+VG/StripedLV
+.br
+\[bu]
+Merge StripedLV into an LV when it is a previously split mirror.
+.br
+\[bu]
+See --splitmirror.
+./" FIXME: use --merge-mirror
+
+.B lvconvert \-\-type snapshot
+VG/StripedLV VG/SnapshotLV
+.br
+\[bu]
+Recombine StripedLV with SnapshotLV which was previously split.
+.br
+\[bu]
+See --splitsnapshot.
+
+.B lvconvert \-\-type thin
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type thin with an external origin.
+.br
+\[bu]
+Also specify a thin pool to use, see \-\-thinpool.
+.br
+\[bu]
+StripedLV becomes a read\-only external origin LV with a new name.
+.br
+\[bu]
+See \-\-originname.
+
+.B lvconvert \-\-type cache
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type cache.
+.br
+\[bu]
+Also specify a cache pool to use, see \-\-cachepool.
+
+.B lvconvert \-\-type thin\-pool
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type thin\-pool.
+
+.B lvconvert \-\-type cache\-pool
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type cache\-pool.
+
+.B lvconvert \-\-type mirror
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type mirror.
+.br
+\[bu]
+Also specify the number of mirrors, see \-\-mirrors.
+
+.B lvconvert \-\-type raid*
+VG/StripedLV
+.br
+\[bu]
+Convert StripedLV to type raid*.
+.br
+\[bu]
+Also specify the number of mirrors, see \-\-mirrors.
+
+.SS Operations on RaidLV with type raid*:
+
+\&
+
+.B lvconvert \-\-mirrors
+Number
+VG/RaidLV
+.br
+\[bu]
+Change the number of images in RaidLV.
+
+.B lvconvert \-\-splitmirrors
+Number
+VG/RaidLV
+.br
+\[bu]
+Split images from RaidLV and use them to create a new LV.
+.br
+\[bu]
+Also specify \-\-name for new LV, or use \-\-trackchanges.
+
+.B lvconvert \-\-merge
+VG/RaidLV
+.br
+\[bu]
+Merge RaidLV into an LV when it is a previously split mirror.
+.br
+\[bu]
+See --splitmirror.
+./" FIXME: use --merge-mirror
+
+.B lvconvert \-\-repair
+VG/RaidLV
+.br
+\[bu]
+Replace failed PVs in RaidLV.
+
+.B lvconvert \-\-replace
+PV
+VG/RaidLV
+.br
+\[bu]
+Replace a specific PV in a raid* LV with another PV.
+.br
+\[bu]
+The replacement PV can be optionally specified, see below.
+
+.B lvconvert \-\-type snapshot
+VG/RaidLV
+VG/SnapshotLV
+.br
+\[bu]
+Combine RaidLV with SnapshotLV that was previously split.
+.br
+\[bu]
+See \-\-splitsnapshot.
+
+.B lvconvert \-\-type thin
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type thin with an external origin.
+.br
+\[bu]
+Also specify a thin pool to use, see \-\-thinpool.
+.br
+\[bu]
+RaidLV becomes a read\-only external origin LV with a new name.
+.br
+\[bu]
+See \-\-originname.
+
+.B lvconvert \-\-type cache
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type cache.
+.br
+\[bu]
+Also specify a cache pool to use, see \-\-cachepool.
+
+.B lvconvert \-\-type thin\-pool
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type thin\-pool.
+
+.B lvconvert \-\-type cache\-pool
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type cache\-pool.
+
+.B lvconvert \-\-type raid*
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to use a different raid level.
+
+.B lvconvert \-\-type striped
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type striped.
+
+.B lvconvert \-\-type linear
+VG/RaidLV
+.br
+\[bu]
+Convert RaidLV to type linear.
+
+.SS Operations on MirrorLV with type mirror:
+
+\&
+
+.B lvconvert \-\-mirrors
+Number
+VG/MirrorLV
+.br
+\[bu]
+Change the number of images in MirrorLV.
+
+.B lvconvert \-\-splitmirrors
+Number
+VG/MirrorLV
+.br
+\[bu]
+Split images from MirrorLV and use them to create a new LV.
+.br
+\[bu]
+Also specify \-\-name for new LV.
+
+.B lvconvert \-\-mirrorlog
+LogType
+VG/MirrorLV
+.br
+\[bu]
+Change the type of log used by MirrorLV.
+.br
+\[bu]
+See --mirrorlog and --corelog for log types.
+
+.B lvconvert \-\-repair
+VG/MirrorLV
+.br
+\[bu]
+Replace failed PVs in MirrorLV.
+
+.B lvconvert \-\-type linear
+VG/MirrorLV
+.br
+\[bu]
+Convert MirrorLV to type linear.
+
+.B lvconvert \-\-type raid*
+VG/MirrorLV
+.br
+\[bu]
+Convert MirrorLV to type raid*.
+.br
+\[bu]
+See lvmraid(7) for permitted raid levels.
+
+.SS Operations on CachePoolLV with type cache\-pool:
+
+\&
+
+.B lvconvert \-\-splitcache
+VG/CachePoolLV
+.br
+\[bu]
+Split the cache LV from CachePoolLV.
+
+.SS Operations on CacheLV with type cache:
+
+\&
+
+.B lvconvert \-\-splitcache
+VG/CacheLV
+.br
+\[bu]
+Split and keep the cache pool from CacheLV.
+
+.B lvconvert \-\-uncache
+VG/CacheLV
+.br
+\[bu]
+Split and remove the cache pool from CacheLV.
+
+.B lvconvert \-\-splitmirrors
+Number
+VG/CacheLV
+.br
+\[bu]
+Split images from the mirrored origin of CacheLV to create a new LV.
+.br
+\[bu]
+Operates on mirror or raid1 sub LV.
+.br
+\[bu]
+Also specify \-\-name for new LV, or use \-\-trackchanges.
+
+.B lvconvert \-\-type thin\-pool
+VG/CacheLV
+.br
+\[bu]
+Convert CacheLV to type thin-pool.
+.br
+\[bu]
+The CacheLV is used for thin pool data.
+
+
+.SS Operations on ThinPoolLV with type thin\-pool:
+
+\&
+
+.B lvconvert \-\-splitcache
+VG/ThinPoolLV
+.br
+\[bu]
+Split and keep the cache pool from the data portion of ThinPoolLV.
+.br
+\[bu]
+Operates on the data sub LV of the thin pool LV.
+.br
+\[bu]
+The data sub LV of the thin pool must be a cache LV.
+
+.B lvconvert \-\-uncache
+VG/ThinPoolLV
+.br
+\[bu]
+Split and remove the cache pool from the data portion of ThinPoolLV.
+.br
+\[bu]
+Operates on the data sub LV of the thin pool LV.
+.br
+\[bu]
+The data sub LV of the thin pool must be a cache LV.
+
+.B lvconvert \-\-type cache
+VG/ThinPoolLV
+.br
+\[bu]
+Convert the data portion of ThinPoolLV to type cache.
+.br
+\[bu]
+Operates on the data sub LV of the thin pool LV.
+
+.B lvconvert \-\-repair
+VG/ThinPoolLV
+.br
+\[bu]
+Repair ThinPoolLV.
+
+.SS Operations on ThinLV with type thin:
+
+\&
+
+.B lvconvert \-\-merge
+VG/ThinLV
+.br
+\[bu]
+Merge ThinLV into its origin LV.
+.br
+\[bu]
+ThinLV must have been created as a snapshot of another thin LV.
+./" FIXME: use --merge-snapshot
+
+.SS Operations on SnapshotLV with type snapshot:
+
+\&
+
+.B lvconvert \-\-splitsnapshot
+VG/SnapshotLV
+.br
+\[bu]
+Separate COW snapshot SnapshotLV from its origin LV.
+
+.B lvconvert \-\-merge
+VG/SnapshotLV
+.br
+\[bu]
+Merge COW snapshot SnapshotLV into its origin.
+./" FIXME: use --merge-snapshot
+
 .SH OPTIONS
 .
 See \fBlvm\fP(8) for common options.
 .br
-Exactly one of
-.BR \-\-cache ,
-.BR \-\-corelog ,
-.BR \-\-merge ,
-.BR \-\-mirrorlog ,
-.BR \-\-mirrors ,
-.BR \-\-repair ,
-.BR \-\-replace ,
-.BR \-\-snapshot ,
-.BR \-\-split ,
-.BR \-\-splitcache ,
-.BR \-\-splitsnapshot ,
-.BR \-\-splitmirrors ,
-.BR \-\-thin ,
-.BR \-\-type
-or
-.BR \-\-uncache
-arguments is required.
 .
 .HP
 .BR \-b ,
 .BR \-\-background
 .br
-Run the daemon in the background.
-.
-.HP
-.BR \-H ,
-.BR \-\-cache ,
-.BR \-\-type\ cache
-.br
-Converts logical volume to a cached LV with the use of cache pool
-specified with \fB\-\-cachepool\fP.
-For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
+If the operation requires polling, this option causes the command to
+return before the operation is complete, and polling is done in the
+background.
 .
 .HP
 .BR \-\-cachepolicy
 .IR Policy
 .br
-Only applicable to cached LVs; see also \fBlvmcache\fP(7). Sets
-the cache policy. \fBmq\fP is the basic policy name. \fBsmq\fP is more advanced
-version available in newer kernels.
+Specifies the cache policy for a cache LV.  Also see
+.BR lvmcache (7).
 .
 .HP
 .BR \-\-cachepool
 .IR CachePoolLogicalVolume { Name | Path }
 .br
-This argument is necessary when converting a logical volume to a cache LV.
-For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
+Specifies the cache pool to use when converting an LV to a cache LV.  If
+CachePoolLogicalVolume is not yet a cache pool, the command will attempt
+to convert it into a cache pool prior to the cache LV conversion.
+Also see
+.BR lvmcache (7).
 .
 .HP
 .BR \-\-cachesettings
 .IB Key = Value
 .br
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache tunable settings. In most use-cases, default values should be adequate.
-Special string value \fBdefault\fP switches setting back to its default kernel value
-and removes it from the list of settings stored in lvm2 metadata.
+Specifies tunable values for a cache LV.  (The default values should
+usually be adequate.)  The special string value \fBdefault\fP switches
+settings back to their default kernel values and removes them from the
+list of settings stored in LVM metadata.
+Also see
+.BR lvmcache (7).
 .
 .HP
 .BR \-c ,
 .BR \-\-chunksize
 .BR \fIChunkSize [ b | B | s | S | k | K | m | M | g | G ]
 .br
-Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
-Default unit is in kilobytes.
+Sets the chunk size for a snapshot, cache pool or thin pool.
+The default unit is in kilobytes.
 .sp
-For snapshots the value must be power of 2 between 4KiB and 512KiB
+For snapshots, the value must be a power of 2 between 4KiB and 512KiB
 and the default value is 4.
 .sp
-For cache the value must be between 32KiB and 1GiB and
+For a cache pool the value must be between 32KiB and 1GiB and
 the default value is 64.
 .sp
-For thin pools the value must be between 64KiB and
+For a thin pool the value must be between 64KiB and
 1GiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MiB,
 if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 (Early kernel support until thin target version 1.4 required the value
-to be a power of 2.  Discards weren't supported for non-power of 2 values
+to be a power of 2.  Discards were not supported for non-power of 2 values
 until thin target version 1.5.)
 .
 .HP
 .BR \-\-corelog
 .br
-The optional argument \fB\-\-corelog\fP is the same as specifying
-\fB\-\-mirrorlog core\fP.
+Specifies or changes the log type for a mirror LV.
+It is an alias for \fB\-\-mirrorlog core\fP.
+(This option does not apply to the \fBraid1\fP LV type.)
 .
 .HP
 .BR \-\-discards
 .RB { ignore | nopassdown | passdown }
 .br
-Specifies whether or not discards will be processed by the thin layer in the
-kernel and passed down to the Physical Volume.
-Options is currently supported only with thin pools.
-Default is \fBpassdown\fP.
+Specifies if discards will be processed by the thin layer in the
+kernel and passed down to the Physical Volume.  This applies only
+to thin pools.  The default is \fBpassdown\fP.
 .
 .HP
 .BR \-i ,
@@ -319,79 +533,87 @@ Report progress as a percentage at regular intervals.
 .HP
 .BR \-\-merge
 .br
-Merges a snapshot into its origin volume or merges a raid1 image that has
-been split from its mirror with \fB\-\-trackchanges\fP back into its mirror.
+Merges a snapshot that was split from an origin LV using
+\fB\-\-splitsnapshot\fP, back into the origin LV.
 
-To check if your kernel supports the snapshot merge feature, look
-for 'snapshot-merge' in the output
-of \fBdmsetup targets\fP.  If both the origin and snapshot volume are not
-open the merge will start immediately.  Otherwise, the merge will start
-the first time either the origin or snapshot are activated and both are closed.
-Merging a snapshot into an origin that cannot be closed, for example a root
-filesystem, is deferred until the next time the origin volume is activated.
-When merging starts, the resulting logical volume will have the origin's name,
-minor number and UUID.  While the merge is in progress, reads or writes to the
-origin appear as they were directed to the snapshot being merged.  When the
-merge finishes, the merged snapshot is removed.  Multiple snapshots may
-be specified on the commandline or a @tag may be used to specify
-multiple snapshots be merged to their respective origin.
+Merges a raid1 image that was split from a raid1 LV using
+\fB\-\-splitsnapshot\fP and \fB\-\-trackchanges\fP, back into
+the original raid1 LV.
+
+To check if the kernel supports the snapshot merge feature, look for
+"snapshot\-merge" in the output of \fBdmsetup targets\fP.
+
+When merging a snapshot, if both the origin and snapshot LVs are not open,
+the merge will start immediately.  Otherwise, the merge will start the
+first time either the origin or snapshot LV are activated and both are
+closed.  Merging a snapshot into an origin that cannot be closed, for
+example a root filesystem, is deferred until the next time the origin
+volume is activated.  When merging starts, the resulting LV will have the
+origin's name, minor number and UUID.  While the merge is in progress,
+reads or writes to the origin appear as being directed to the snapshot
+being merged.  When the merge finishes, the merged snapshot is removed.
+Multiple snapshots may be specified on the command line or a @tag may be
+used to specify multiple snapshots be merged to their respective origin.
 .
 .HP
 .BR \-\-mirrorlog
 .RB { disk | core | mirrored }
 .br
-Specifies the type of log to use.
+Specifies or changes the log type for a mirror LV.
 The default is \fBdisk\fP, which is persistent and requires
 a small amount of storage space, usually on a separate device
 from the data being mirrored.
-\fBCore\fP may be useful for short-lived mirrors: It means the mirror is
+\fBCore\fP may be useful for short-lived mirrors.  It means the mirror is
 regenerated by copying the data from the first device again every
-time the device is activated - perhaps, for example, after every reboot.
+time the device is activated - e.g. possibly after every reboot.
 Using \fBmirrored\fP will create a persistent log that is itself mirrored.
+(This option does not apply to the \fBraid1\fP LV type.)
 .
 .HP
 .BR \-m ,
 .BR \-\-mirrors
-.IR Mirrors
+.IR Number
 .br
-Specifies the degree of the mirror you wish to create.
-For example, "\fB\-m 1\fP" would convert the original logical
-volume to a mirror volume with 2-sides; that is, a
-linear volume plus one copy.  There are two implementations of mirroring
-which correspond to the \fBraid1\fP and \fBmirror\fP segment types.  The default
-mirroring segment type is \fBraid1\fP.  If the legacy \fBmirror\fP" segment type
-is desired, the \fB\-\-type\fP argument must be used to explicitly
-select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
-options below are only relevant to the legacy \fBmirror\fP segment type.
+Specifies the number mirror images in addition to the original LV image,
+e.g. \fB\-\-mirrors 1\fP means two copies of the data, the original and
+one mirror image.
+
+This option is required when converting an LV to a \fBraid1\fP or
+\fBmirror\fP LV.
+
+This option can be used alone to change the number of mirror images in an
+existing \fBraid1\fP or \fBmirror\fP LV.
+
+The special case \fB\-\-mirrors 0\fP indicates a linear LV with no mirror
+images.
 .
 .HP
 .BR \-n ,
 .BR \-\-name
 .IR Name
 .br
-The name to apply to a logical volume which has been split off from
-a mirror logical volume.
+Specifies the name to use when the command is creating a new LV, e.g.
+.B \-\-splitmirrors.
 .
 .HP
 .BR \-\-noudevsync
 .br
-Disables udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
+Disables udev synchronisation. The process will not wait for notification
+from udev.  It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running or has
+rules that ignore the devices LVM creates.
 .
 .HP
 .BR \-\-originname
 .IR NewExternalOriginVolumeName
 .br
-The new name for original logical volume, which becomes external origin volume
-for a thin logical volume that will use given \fB\-\-thinpool\fP.
+Specifies the name to use for the external origin LV when converting an LV
+to a thin LV.  The LV being converted becomes a read\-only external origin
+with this name.
+.br
+Without this option, the default name of "lvol<n>" will be generated where
+<n> is the LVM internal number of the LV.
 .br
-Without this option a default name of "lvol<n>" will be generated where
-<n> is the LVM internal number of the logical volume.
-This volume will be read-only and cannot be further modified as long,
-as it is being used as the external origin.
 .
 .\" .HP
 .\" .BR \-\-pooldatasize
@@ -404,56 +626,51 @@ as it is being used as the external origin.
 .BR \-\-poolmetadata
 .IR PoolMetadataLogicalVolume { Name | Path }
 .br
-Specifies cache or thin pool metadata logical volume.
-The size should be in between 2MiB and 16GiB.
-Cache pool is specified with the option
-\fB\-\-cachepool\fP.
-Thin pool is specified with the option
-\fB\-\-thinpool\fP.
-When the specified pool already exists,
-the pool's metadata volume will be swapped with the given LV.
-Pool properties (like chunk size, discards or zero)
-are preserved by default in this case.
-It can be useful for pool metadata repair or its offline resize,
-since the metadata volume is available as regular volume for a user with
-thin provisioning tools
-.BR cache_dump (8),
-.BR cache_repair (8),
-.BR cache_restore (8),
-.BR thin_dump (8),
-.BR thin_repair (8)
+Specifies the LV to use for thin pool metadata when converting an LV to a
+thin pool LV.
+.br
+Specifies the LV to use for cache pool metadata when converting an LV to a
+cache pool LV.
+.br
+The size should be between 2MiB and 16GiB.
+.br
+(This option can also be used when a thin pool or cache pool are created
+as an auxiliary operation within a different command.)
+Also see
+.BR lvmthin (7),
 and
-.BR thin_restore (8).
+.BR lvmcache (7).
 .
 .HP
 .BR \-\-poolmetadatasize
 .BR \fIPoolMetadataSize [ b | B | s | S | k | K | m | M | g | G ]
 .br
-Sets the size of cache or thin pool's metadata logical volume,
-if the pool metadata volume is undefined.
-Pool is specified with the option
-\fB\-\-cachepool\fP or \fB\-\-thinpool\fP.
-For thin pool supported value is in the range between 2MiB and 16GiB.
-The default value is estimated with this formula
-(Pool_LV_size / Pool_LV_chunk_size * 64b).
-Default unit is megabytes.
+Specifies the size of a cache pool metadata LV or a thin pool metadata LV.
+This is used if a command creates a pool metadata LV automatically as part
+of the operation.  This option is not used when an existing LV is
+specified as the pool metadata LV, i.e. \fB\-\-poolmetadata\fP.
+The default unit is megabytes.
+Also see
+.BR lvmthin (7),
+and
+.BR lvmcache (7).
 .
 .HP
 .BR \-\-poolmetadataspare
 .RB { y | n }
 .br
-Controls creation and maintanence of pool metadata spare logical volume
-that will be used for automated pool recovery.
-Only one such volume is maintained within a volume group
-with the size of the biggest pool metadata volume.
-Default is \fBy\fPes.
+Specifies if a spare pool metadata LV should be created.
+A spare pool metadata LV will be used for pool repair.
+Only one spare pool metadata LV is maintained within a VG, with the size
+of the largest existing pool metadata LV.
+The default is \fBy\fPes.
 .
 .HP
 .BR \-r ,
 .BR \-\-readahead
 .RB { \fIReadAheadSectors | auto | none }
 .br
-Sets read ahead sector count of thin pool metadata logical volume.
+Specifies the read ahead sector count of a thin pool metadata LV.
 The default value is \fBauto\fP which allows the kernel to choose
 a suitable value automatically.
 \fBNone\fP is equivalent to specifying zero.
@@ -463,298 +680,248 @@ a suitable value automatically.
 .BR \-\-regionsize
 .IR MirrorLogRegionSize
 .br
-A mirror is divided into regions of this size (in MB), and the mirror log
-uses this granularity to track which regions are in sync.
+A mirror LV is divided into regions of this size (in MB), and the mirror
+log uses this granularity to track which regions are in sync.
+(This option does not apply to the \fBraid1\fP LV type.)
 .
 .HP
 .BR \-\-repair
 .br
-Repair a mirror after suffering a disk failure or try to fix thin pool metadata.
-
-The mirror will be brought back into a consistent state.
-By default, the original number of mirrors will be
-restored if possible.  Specify \fB\-y\fP on the command line to skip
-the prompts. Use \fB\-f\fP if you do not want any replacement.
-Additionally, you may use \fB\-\-use\-policies\fP to use the device
-replacement policy specified in \fBlvm.conf\fP(5),
-see \fBactivation/mirror_log_fault_policy\fP or
+Replaces failed PVs in a raid1 or mirror LV with other PVs available in
+the VG.  By default, the original number of mirror images will be restored
+if possible.  Specify \fB\-y\fP on the command line to skip the prompts.
+Use \fB\-f\fP if you do not want any replacement.  You may use
+\fB\-\-use\-policies\fP to use the device replacement policy specified in
+\fBlvm.conf\fP(5), see \fBactivation/mirror_log_fault_policy\fP or
 \fBactivation/mirror_device_fault_policy\fP.
 
-Thin pool repair automates the use of \fBthin_repair\fP(8) tool.
-Only inactive thin pool volumes can be repaired.
-There is no validation of metadata between kernel and lvm2.
-This requires further manual work.
-After successfull repair the old unmodified metadata are still
-available in "<pool>_meta<n>" LV.
+When used with a thin pool LV, this option automates the use of the
+\fBthin_repair\fP(8) tool on the thin pool.  This repairs a very limitted
+number of problems.  Only inactive thin pools can be repaired.  There is
+no validation of metadata between kernel and LVM.  This requires further
+manual work.  After successfull repair the old unmodified metadata are
+still available in "<pool>_meta<n>" LV.
 .
 .HP
 .BR \-\-replace
 .IR PhysicalVolume
 .br
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
-that is available in the volume group or from the specific list provided.
-This option is only available to RAID segment types
-(e.g.
-.IR raid1 ,
-.IR raid5 ,
-etc).
-.
-.HP
-.BR \-s ,
-.BR \-\-snapshot ,
-.BR \-\-type\ snapshot
-.br
-Recreates a snapshot from constituent logical volumes (or copies of them) after
-having been separated using \fB\-\-splitsnapshot\fP.
-For this to work correctly, no changes may be made to the contents
-of either volume after the split.
+that is available in the VG, or from a specific list of PVs specified on
+the command line following the LV name.
+(This option only applies to \fBraid*\fP LV types.)
 .
 .HP
 .BR \-\-split
 .br
 Separates \fISplitableLogicalVolume\fP.
-Option is agregating various split commands and tries to detect necessary split
-operation from its arguments.
+This option tries to detect the necessary split operation from its arguments.
+Avoid using this option and use one of the following instead:
+.B \-\-splitcache, \-\-splitmirror, \-\-splitsnapshot.
 .
 .HP
 .BR \-\-splitcache
 .br
-Separates \fICacheLogicalVolume\fP from cache pool.
-Before the logical volume becomes uncached, cache is flushed.
-The cache pool volume is then left unused and
-could be used e.g. for caching another volume.
-See also the option \fB\-\-uncache\fP for uncaching and removing
-cache pool with one command.
+Separates a cache pool from a cache LV, and keeps the unused cache pool
+LV.  Before the separation, the cache is flushed.  Also see
+.B \-\-uncache.
 .
 .HP
 .BR \-\-splitmirrors
-.IR Images
+.IR Number
 .br
-The number of redundant \fIImages\fP of a mirror to be split off and used
-to form a new logical volume.  A name must be supplied for the
-newly-split-off logical volume using the \fB\-\-name\fP argument, unless
-the \fB\-\-trackchanges\fP argument is given.
+Splits the specified number of images from a \fBraid1\fP or \fBmirror\fP
+LV and uses them to create a new LV.
+
+If \fB\-\-trackchanges\fP is also specified, changes to the raid1 LV are
+tracked while the split LV remains detached.
+.B lvconvert \-\-merge
+can be used to recombine the split images with the original raid1 LV.
+
+A name can be specified for the new LV with \fB\-\-name\fP (a name is
+required without \fB\-\-trackchanges\fP).
 .
 .HP
 .BR \-\-splitsnapshot
 .br
-Separates \fISnapshotLogicalVolume\fP from its origin.
-The volume that is split off contains the chunks that differ from the origin
-along with the metadata describing them.  This volume can be wiped and then
-destroyed with lvremove.
-The inverse of \fB\-\-snapshot\fP.
+Separates a COW snapshot from its origin LV.  The LV that is split off
+contains the chunks that differ from the origin LV along with metadata
+describing them.  This LV can be wiped and then destroyed with lvremove.
+Also see
+.B lvconvert \-\-type snapshot.
 .
 .HP
 .BR \-\-stripes
-.IR Stripes
+.IR Number
 .br
-Gives the number of stripes.
-This is equal to the number of physical volumes to scatter
-the logical volume. This does not apply to existing allocated
-space, only newly allocated space can be striped.
+Specifies the number of stripes in a striped LV.  This is the number of
+physical volumes (devices) across which to spread a striped LV.  Data that
+appears sequential in the LV is spread (striped) across multiple devices
+in units of the stripe size (see below).  This does not apply to existing
+allocated space, only newly allocated space can be striped.
 .
 .HP
 .BR \-I ,
 .BR \-\-stripesize
 .IR StripeSize
 .br
-Gives the number of kilobytes for the granularity of the stripes.
-.br
-StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
-For metadata in LVM2 format, the stripe size may be a larger
-power of 2 but must not exceed the physical extent size.
+Specifies the stripe size in kilobytes for a striped LV.  The stripe size
+is the number of kilobytes written to each stripe, i.e. to one device,
+before writing to the next stripe/device.  StripeSize must be a power of 2
+and cannot exceed the VG physical extent (PE) size.
 .
 .HP
-.BR \-T ,
-.BR \-\-thin ,
-.BR \-\-type\ thin
+.BR \-\-type
+.IR SegmentType
 .br
-Converts the logical volume into a thin logical volume of the thin pool
-specified with \fB\-\-thinpool\fP. The original logical volume
-\fIExternalOriginLogicalVolume\fP
-is renamed into a new read-only logical volume.
-For the non-default name for this volume use \fB\-\-originname\fP.
-The volume cannot be further modified as long as it is used as an
-external origin volume for unprovisioned areas of any thin logical volume.
+Converts an LV from one segment type to another.  See commmands above.
 .
 .HP
 .BR \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
 .br
-Specifies or converts logical volume into a thin pool's data volume.
-Content of converted volume is lost.
-Thin pool's metadata logical volume can be specified with the option
-\fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
-See \fBlvmthin\fP(7) for more info about thin provisioning support.
+Specifies the thin pool to use when converting an LV to a thin LV.  If
+ThinPoolLogicalVolume is not yet a thin pool, the command will attempt to
+convert it to a thin pool prior to the thin LV conversion.
+Also see
+.BR lvmthin (7).
 .
 .HP
 .BR \-\-trackchanges
 .br
-Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
-that the read-only detached image can be merged efficiently back into
-the mirror later. Only the regions of the detached device where
-the data changed get resynchronized.
-
-Please note that this feature is only supported with the new md-based mirror
-implementation and not with the original device-mapper mirror implementation.
-.
-.HP
-.BR \-\-type
-.IR SegmentType
-.br
-Used to convert a logical volume to another segment type, like
-.BR cache ,
-.BR cache-pool ,
-.BR raid1 ,
-.BR snapshot ,
-.BR thin ,
-or
-.BR thin-pool .
-When converting a logical volume to a cache LV, the
-\fB\-\-cachepool\fP argument is required.
-When converting a logical volume to a thin LV, the
-\fB\-\-thinpool\fP argument is required.
-See \fBlvmcache\fP(7) for more info about caching support
-and \fBlvmthin\fP(7) for thin provisioning support.
+Can be used with \fB\-\-splitmirrors\fP on a raid1 LV.  This causes
+changes to the original raid1 LV to be tracked while the split images
+remain detached.  This allows the read\-only detached image(s) to be
+merged efficiently back into the raid1 LV later.  Only the regions with
+changed data are resynchronized during merge.  (This option only applies
+to the \fBraid1\fP LV type.)
 .
 .HP
 .BR \-\-uncache
 .br
-Uncaches \fICacheLogicalVolume\fP.
-Before the volume becomes uncached, cache is flushed.
-Unlike with \fB\-\-splitcache\fP the cache pool volume is removed.
-This option could be seen as an inverse of \fB\-\-cache\fP.
+Separates a cache pool from a cache LV, and removes the unused cache pool
+LV.  Before the separation, the cache is flushed.  Also see
+.B \-\-splitcache.
 .
 .HP
 .BR \-Z ,
 .BR \-\-zero
 .RB { y | n }
 .br
-Controls zeroing of the first 4KiB of data in the snapshot.
-If the volume is read-only the snapshot will not be zeroed.
-For thin pool volumes it controls zeroing of provisioned blocks.
-Note: Provisioning of large zeroed chunks negatively impacts performance.
+For snapshots, this controls zeroing of the first 4KiB of data in the
+snapshot.  If the LV is read\-only, the snapshot will not be zeroed.
+
+For thin pools, this controls zeroing of provisioned blocks.
+Provisioning of large zeroed chunks negatively impacts performance.
 .
+
+.SS Option aliases
+
+.B \-\-type cache
+can be replaced with
+.B \-H
+or
+.B \-\-cache.
+
+.B \-\-type thin
+can be replaced with
+.B \-T
+or
+.B \-\-thin.
+
+.B \-\-type snapshot
+can be replaced with
+.B \-s
+or
+.B \-\-snapshot.
+
 .SH Examples
 .
-Converts the linear logical volume "vg00/lvol1" to a two-way mirror
-logical volume:
-.sp
-.B lvconvert \-m1 vg00/lvol1
+Convert a linear LV to a two-way mirror LV:
+.br
+.B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
 
-Converts the linear logical volume "vg00/lvol1" to a two-way RAID1
-logical volume:
-.sp
-.B lvconvert \-\-type raid1 \-m1 vg00/lvol1
+Convert a linear LV to a two-way RAID1 LV:
+.br
+.B lvconvert \-\-type raid1 \-\-mirrors 1 vg/lvol1
 
-Converts a mirror with a disk log to a mirror with an in-memory log:
-.sp
-.B lvconvert \-\-mirrorlog core vg00/lvol1
+Convert a mirror LV to use an in\-memory log:
+.br
+.B lvconvert \-\-mirrorlog core vg/lvol1
 
-Converts a mirror with an in-memory log to a mirror with a disk log:
-.sp
-.B lvconvert \-\-mirrorlog disk vg00/lvol1
+Convert a mirror LV to use a disk log:
+.br
+.B lvconvert \-\-mirrorlog disk vg/lvol1
 
-Converts a mirror logical volume to a linear logical volume:
-.sp
-.B lvconvert \-m0 vg00/lvol1
+Convert a mirror or raid1 LV to a linear LV:
+.br
+.B lvconvert --type linear vg/lvol1
 
-Converts a mirror logical volume to a RAID1 logical volume with the same
-number of images:
-.sp
-.B lvconvert \-\-type raid1 vg00/mirror_lv
+Convert a mirror LV to a raid1 LV with the same number of images:
+.br
+.B lvconvert \-\-type raid1 vg/lvol1
 
-Converts logical volume "vg00/lvol2" to snapshot of original volume
-"vg00/lvol1":
-.sp
-.B lvconvert \-s vg00/lvol1 vg00/lvol2
+./" Split and merge a COW snapshot:
+./" TODO
 
-Converts linear logical volume "vg00/lvol1" to a two-way mirror,
-using physical extents /dev/sda:0\-15 and /dev/sdb:0\-15 for allocation
-of new extents:
-.sp
-.B lvconvert \-m1 vg00/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
+Convert a linear LV to a two-way mirror LV, allocating new extents from specific
+PV ranges:
+.br
+.B lvconvert \-\-mirrors 1 vg/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
 
-Converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
-extents from /dev/sda:
-.sp
-.B lvconvert \-m0 vg00/lvmirror1 /dev/sda
+Convert a mirror LV to a linear LV, freeing physical extents from a specific PV:
+.br
+.B lvconvert \-\-type linear vg/lvol1 /dev/sda
 
-Merges "vg00/lvol1_snap" into its origin:
-.sp
-.B lvconvert \-\-merge vg00/lvol1_snap
+Split one image from a mirror or raid1 LV, making it a new LV:
+.br
+.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg/lvol1
 
-If "vg00/lvol1", "vg00/lvol2" and "vg00/lvol3" are all tagged with "some_tag"
-each snapshot logical volume will be merged serially,
-e.g.: "vg00/lvol1", then "vg00/lvol2", then "vg00/lvol3".
-If \-\-background were used it would start
-all snapshot logical volume merges in parallel.
-.sp
-.B lvconvert \-\-merge @some_tag
+Split one image from a raid1 LV, and track changes made to the raid1 LV
+while the split image remains detached:
+.br
+.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg/lvol1
 
-Extracts one image from the mirror, making it a new logical volume named
-"lv_split".  The mirror the image is extracted from is reduced accordingly.
-If it was a 2-way mirror (created with '-m 1'), then the resulting original
-volume will be linear.
-.sp
-.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg00/lvmirror1
-
-A mirrored logical volume created with \-\-type raid1 can use the
-\-\-trackchanges argument when splitting off an image.
-Detach one image from the mirrored logical volume lv_raid1 as a separate
-read-only device and track the changes made to the mirror while it is detached.
-The split-off device has a name of the form lv_raid1_rimage_N, where N is
-a number, and it cannot be renamed.
-.sp
-.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg00/lv_raid1
+Merge an image (that was previously created with \-\-splitmirrors and
+\-\-trackchanges) back into the original raid1 LV:
+.br
+.B lvconvert \-\-merge vg/lvol1_rimage_1
+./" FIXME: use merge-mirror
 
-Merge an image that was detached temporarily from its mirror with
-the \-\-trackchanges argument back into its original mirror and
-bring its contents back up-to-date.
-.sp
-.B lvconvert \-\-merge vg00/lv_raid1_rimage_1
+Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1 LV:
+.br
+.B lvconvert \-\-replace /dev/sdb1 vg/lvol1 /dev/sdf1
 
-Replaces the physical volume "/dev/sdb1" in the RAID1 logical volume "my_raid1"
-with the specified physical volume "/dev/sdf1".  Had the argument "/dev/sdf1"
-been left out, lvconvert would attempt to find a suitable device from those
-available in the volume group.
-.sp
-.B lvconvert \-\-replace /dev/sdb1 vg00/my_raid1 /dev/sdf1
+Convert an LV into a thin LV in the specified thin pool.  The existing LV
+is used as an external read\-only origin for the new thin LV.
+.br
+.B lvconvert \-\-type thin \-\-thinpool vg/tpool1 vg/lvol1
 
-Convert the logical volume "vg00/lvpool" into a thin pool with chunk size 128KiB
-and convert "vg00/lv1" into a thin volume using this pool. Original "vg00/lv1"
-is used as an external read-only origin, where all writes to such volume
-are stored in the "vg00/lvpool".
-.sp
-.B lvconvert \-\-type thin \-\-thinpool vg00/lvpool \-c 128 lv1
+Convert an LV into a thin LV in the specified thin pool.  The existing LV
+is used as an external read\-only origin for the new thin LV, and is
+renamed "external":
+.br
+.B lvconvert \-\-type thin \-\-thinpool vg/tpool1
+.RS
+.B \-\-originname external vg/lvol1
+.RE
 
-Convert the logical volume "vg00/origin" into a thin volume from the thin pool
-"vg00/lvpool". This thin volume will use "vg00/origin" as an external origin
-volume for unprovisioned areas in this volume.
-For the read-only external origin use the new name "vg00/external".
-.sp
-.B lvconvert \-T \-\-thinpool vg00/lvpool \-\-originname external vg00/origin
+Convert an LV to a cache pool LV using another specified LV for cache pool
+metadata:
+.br
+.B lvconvert \-\-type cache-pool \-\-poolmetadata vg/poolmeta1 vg/lvol1
 
-Convert an existing logical volume to a cache pool LV using the
-given cache metadata LV.
-.sp
-.B lvconvert \-\-type cache-pool \-\-poolmetadata vg00/lvx_meta vg00/lvx_data
+Convert an LV to a cache LV using the specified cache pool and chunk size:
 .br
-.B lvrename vg00/lvx_data vg00/lvx_cachepool
-.sp
-Convert an existing logical volume to a cache LV using the given
-cache pool LV and chunk size 128KiB.
-.sp
-.B lvconvert \-\-cache \-\-cachepool vg00/lvx_cachepool -c 128 vg00/lvx
-.sp
-Detach cache pool from an existing cached logical volume "vg00/lvol1" and
-leave cache pool unused.
-.sp
-.B lvconvert \-\-splitcache vg00/lvol1
-.sp
-Drop cache pool from an existing cached logical volume "vg00/lvol1".
-.sp
-.B lvconvert \-\-uncache vg00/lvol1
+.B lvconvert \-\-cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
+
+Detach and keep the cache pool from a cache LV:
+.br
+.B lvconvert \-\-splitcache vg/lvol1
+
+Detach and remove the cache pool from a cache LV:
+.br
+.B lvconvert \-\-uncache vg/lvol1
 
 .SH SEE ALSO
 .BR lvm (8),


