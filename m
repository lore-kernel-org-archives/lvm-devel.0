From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:16 +0000 (UTC)
Subject: master - man: lvconvert/create updates
Message-ID: <20141024144116.9373A60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29c14a11943d52e47424140ffa3b91dc9b095bc5
Commit:        29c14a11943d52e47424140ffa3b91dc9b095bc5
Parent:        fd00d2c6eceb6536208558561a02d464d1808469
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 14:48:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

man: lvconvert/create updates

More description for cache support.
Introduce --pooldatasize option.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   32 +++-
 man/lvcreate.8.in  |  486 +++++++++++++++++++++++++++++++---------------------
 3 files changed, 314 insertions(+), 205 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1bdb884..5ad246c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Update and correct lvcreate and lvcovert man pages.
   Mark pools and snapshots as unzeroable volumes.
   Check for zeroing of volume after segment type is fully detected.
   Better support for persistent major and minor options with lvcreate.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index b08e420..bf699ee 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -153,8 +153,11 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .B lvconvert
 .RB [ \-\-type
 .BR \fIcache [ \fI\-pool ]| \-H | \-\-cache ]
-.RB [ \-\-cachepool
+.RB [{ \-\-cachepool
 .IR CachePoolLogicalVolume { Name | Path }]
+|
+.B \-\-pooldatasize
+.IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]}]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -304,13 +307,13 @@ Separates \fISplitableLogicalVolume\fP.
 Option is agregating various split commands and tries to detect necessary split
 operation from its arguments.
 .TP
-.BR \-\-splitcache ", " \-\-uncache
+.BR \-\-splitcache
 Separates \fICacheLogicalVolume\fP from cache pool.
-Before volume becomes uncached, cache is flushed.
-With \-\-split the cache pool volume is then left unused and 
-could be i.e. used for caching other volumes.
-The inverse of \-\-cache is \-\-uncache where the cache pool 
-component volumes are automatically removed.
+Before the logical volume becomes uncached, cache is flushed.
+The cache pool volume is then left unused and
+could be used e.g. to caching another volume.
+See also the option \fB\-\-uncache\fP for uncaching and removing
+cache pool with one command.
 .TP
 .B \-\-splitsnapshot
 Separates \fISnapshotLogicalVolume\fP from its origin.
@@ -347,6 +350,7 @@ until thin target version 1.5.)
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Specifies whether or not discards will be processed by the thin layer in the
 kernel and passed down to the Physical Volume.
+Options is currently supported only with thin pools.
 Default is \fIpassdown\fP.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
@@ -382,6 +386,10 @@ Without this option a default name of "lvol<n>" will be generated where
 This volume will be read-only and cannot be further modified as long,
 as it is being used as the external origin.
 .TP
+.IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
+Sets the size of pool's data logical volume.
+The option \fB\-\-size\fP could be still used with thin pools.
+.TP
 .BR \-\-poolmetadata " " \fIPoolMetadataLogicalVolume { \fIName | \fIPath }
 Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
@@ -450,7 +458,7 @@ available in "<pool>_meta<n>" LV.
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
 that is available in the volume group or from the specific list provided.
 This option is only available to RAID segment types
-(e.g. 
+(e.g.
 .IR raid1 ,
 .IR raid5 ,
 etc).
@@ -483,6 +491,12 @@ Content of converted volume is lost.
 Thin pool's metadata logical volume can be specified with the option
 \fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
+.TP
+.BR \-\-uncache
+Uncaches \fICacheLogicalVolume\fP.
+Before the volume becomes uncached, cache is flushed.
+Unlike with \fB\-\-splitcache\fP the cache pool volume is removed.
+This option could seen as an inverse of \fB\-\-cache\fP.
 
 .SH Examples
 Converts the linear logical volume "vg00/lvol1" to a two-way mirror
@@ -593,7 +607,7 @@ given cache metadata LV.
 Convert an existing logical volume to a cache LV using the given
 cache pool LV and chunk size 128KiB.
 .sp
-.B lvconvert \-\-cache  \-\-cachepool vg00/lvx_cachepool -c 128 vg00/lvx
+.B lvconvert \-\-cache \-\-cachepool vg00/lvx_cachepool -c 128 vg00/lvx
 .sp
 Detach cache pool from an existing cached logical volume "vg00/lvol1" and
 leave cache pool unused.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ed0ed65..c843949 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -3,101 +3,107 @@
 lvcreate \- create a logical volume in an existing volume group
 .SH SYNOPSIS
 .B lvcreate
+.RB [ \-a | \-\-activate
+.RI [ a | e | l ]{ y | n }]
 .RB [ \-\-addtag
 .IR Tag ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
-.RB [ \-a | \-\-activate
-.RI [ a | e | l ]{ y | n }]
-.RB [ \-k | \-\-setactivationskip
-.RI { y | n }]
-.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-H | \-\-cache ]
+.RB [ \-\-cachemode
+.RI { writeback | writethrough }]
+.RB [ \-\-cachepool
+.IR CachePoolLogicalVolume { Name | Path }
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-C | \-\-contiguous
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-ignoremonitoring ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-\-monitor
-.RI { y | n }]
-.RB [ \-\-[raid]maxrecoveryrate
-.IR Rate ]
-.RB [ \-\-[raid]minrecoveryrate
-.IR Rate ]
+.RB [ \-\-discards
+.RI { ignore | nopassdown | passdown }]
+.RB [{ \-l | \-\-extents
+.IR LogicalExtentsNumber [ % { FREE | PVS | VG }]
+|
+.BR \-L | \-\-size
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-i | \-\-stripes
 .IR Stripes
 .RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB {[ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { VG | PVS | FREE }]
-|
-.BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
-|
-.BR \-V | \-\-virtualsize
-.IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-M | \-\-persistent
-.RI { y | n }
+.IR StripeSize ]]]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-K | \-\-ignoreactivationskip ]
+.RB [ \-\-ignoremonitoring ]
 .RB [ \-\-minor
-.IR minor ]
-.RB [ \-\-major
+.IR minor
+.RB [ \-j | \-\-major
 .IR major ]]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-m | \-\-mirrors
 .IR Mirrors
-.RB [ \-\-nosync ]
-.RB [ \-\-mirrorlog
-.RI { disk | core | mirrored }
+.RB [{ \-\-corelog
 |
-.BR \-\-corelog ]
+.B \-\-mirrorlog
+.RI { disk | core | mirrored }}]
+.RB [ \-\-nosync ]
 .RB [ \-R | \-\-regionsize
-.IR MirrorLogRegionSize ]]
+.IR MirrorLogRegionSize [ bBsSkKmMgG ]]]
+.RB [ \-\-monitor
+.RI { y | n }]
 .RB [ \-n | \-\-name
 .IR LogicalVolume { Name | Path }]
+.RB [ \-\-noudevsync ]
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
-.RB [ \-r | \-\-readahead
-.RI { ReadAheadSectors | auto | none }]
-.RB [ \-t | \-\-test ]
-.RB [ \-T | \-\-thin
-.RB [ \-\-cachemode
-.RI { writeback | writethrough }
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkKmMgG ]]
-.RB [ \-\-discards
-.RI { ignore | nopassdown | passdown }]
+.RB [ \-M | \-\-persistent
+.RI { y | n }
+.RB [ \-\-pooldatasize
+.IR DataVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-\-poolmetadatasize
 .IR MetadataVolumeSize [ bBsSkKmMgG ]]
 .RB [ \-\-poolmetadataspare
-.RI { y | n }]]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
+.RI { y | n }]
+.RB [ \-\- [ raid ] maxrecoveryrate
+.IR Rate ]
+.RB [ \-\- [ raid ] minrecoveryrate
+.IR Rate ]
+.RB [ \-r | \-\-readahead
+.RI { ReadAheadSectors | auto | none }]
+.RB [ \-k | \-\-setactivationskip
+.RI { y | n }]
 .RB [ \-s | \-\-snapshot
-.RI [ VolumeGroup { Name | Path }/]
-.IR ExternalOriginLogicalVolumeName ]]
+.RB [ \-V | \-\-virtualsize
+.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-t | \-\-test ]
+.RB [ \-T | \-\-thin ]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-W | \-\-wipesignatures ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
-.IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
+.RI [ VolumeGroup { Name | Path }
+.RI [/\{ ExternalOrigin
+|
+.I Origin
+|
+.IR Pool } LogicalVolumeName ]
 .RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
-.br
 
 .B lvcreate
 .RB [ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { ORIGIN | VG | PVS | FREE }]
+.IR LogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
 |
-.BR \-L | \-\-size
+.BR \-L | \-\-size | \-\-pooldatasize
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkK ]]
+.IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-commandprofile
 .IR Profilename ]
 .RB [ \-\-noudevsync ]
@@ -108,7 +114,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RI { y | n }]
 .RB [ \-n | \-\-name
 .IR SnapshotLogicalVolume { Name | Path }]
-.BR \-s | \-\-snapshot
+.BR \-s | \-\-snapshot | \-H | \-\-cache
 .RI {[ VolumeGroup { Name | Path }/] OriginalLogicalVolumeName
 .BR \-V | \-\-virtualsize
 .IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
@@ -140,13 +146,16 @@ Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
 By default, new Logical Volumes are activated (\fB\-a\fIy\fR).
 If it is possible technically, \fB\-a\fIn\fR will leave the new Logical
-Volume inactive. But for example, snapshots can only be created
-in the active state so \fB\-a\fIn\fR cannot be used with \fB\-\-snapshot\fP.
+Volume inactive. But for example, snapshots of active origin can only be
+created in the active state so \fB\-a\fIn\fR cannot be used with
+\fB-\-type\fP \fIsnapshot\fP. This does not apply to thin volume snapshots,
+which are by default created with flag to skip their activation
+(\fB-k\fP\fIy\fP).
 Normally the \fB\-\-zero\fP \fIn\fP argument has to be supplied too because
 zeroing (the default behaviour) also requires activation.
 If autoactivation option is used (\fB\-a\fIay\fR), the logical volume is
 activated only if it matches an item in the
-.B activation/auto_activation_volume_list
+.BR activation / auto_activation_volume_list
 set in \fBlvm.conf\fP(5).
 For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP and
 \fB\-\-wipesignatures\fP \fIn\fP is always assumed and it can't
@@ -155,19 +164,21 @@ be overridden. If the clustered locking is enabled,
 .IR \fB\-a { a | l } y
 will activate only on the local node.
 .TP
-.IR \fB\-k ", " \fB\-\-setactivationskip "  {" y | n }
-Controls whether Logical Volumes are persistently flagged to be skipped during
-activation. By default, thin snapshot volumes are flagged for activation skip.
-To activate such volumes, an extra \fB\-K/\-\-ignoreactivationskip\fP option must
-be used. The flag is not applied during deactivation.
-Use \fBlvchange \-k/\-\-setactivationskip {y|n}\fP command to attach or
-detach the flag for existing volumes. To see whether the flag is attached,
-use \fBlvs\fP command where the state of the flag is reported within
-\fBlv_attr\fP bits.
-.TP
-.BR \-K ", " \-\-ignoreactivationskip
-Ignore the flag to skip Logical Volumes during activation.
-
+.IR \fB\-H ", " \fB\-\-cache
+Creates cache or cache pool logical volume or both.
+Specifying the optional argument \fB\-\-size\fP will cause the creation of
+the cache logical volume.
+Specifying the optional argument \fB\-\-pooldatasize\fP will cause
+the creation of the cache pool logical volume.
+Specifying both arguments will cause the creation of cache with its
+cache pool volume.
+When the Volume group name is specified together with existing logical volume
+name which is NOT a cache pool name, such volume is treaded
+as cache origin volume and cache pool is created. In this case
+the \fB\-\-size\fP is used to specify size of cache pool volume.
+See \fBlvmcache\fP(7) for more info about caching support.
+Note that the cache segment type requires a dm-cache kernel module version
+1.3.0 or greater.
 .TP
 .IR \fB\-\-cachemode " {" writeback | writethrough }
 Specifying a cache mode determines when the writes to a cache LV
@@ -178,24 +189,32 @@ when it has been stored in the cache pool LV and on the origin LV.
 While \fIwritethrough\fP may be slower for writes, it is more
 resilient if something should happen to a device associated with the
 cache pool LV.
-
+.TP
+.IR \fB\-\-cachepool " " CachePoolLogicalVolume { Name | Path }
+Specifies the name of cache pool volume name. The other way to specify pool name
+is to append name to Volume group name argument.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
 .br
-For snapshots the value must be power of 2 between 4KiB and 512KiB
-and the default value is 4.
+For \fIsnapshots\fP the value must be power of 2 between 4KiB and 512KiB
+and the default value is 4KiB.
 .br
-For cache pool LVs the value must be between 32KiB and 1GiB.  The default
-is 64KiB.  Values must be a multiple of 32KiB.
+For \fIcache pools\fP the value must a multiple of 32KiB
+between 32KiB and 1GiB. The default is 64KiB.
 .br
-For thin pools the value must be between 64KiB and
-1GiB and the default value starts with 64 and scales
-up to fit the pool metadata size within 128MiB,
+For \fIthin pools\fP the value must be a multiple of 64KiB
+between 64KiB and 1GiB.
+Default value starts with 64KiB and grows up to
+fit the pool metadata size within 128MiB,
 if the pool metadata size is not specified.
-Thin pool target version <1.4 requires the value to be a power of 2.
-The newer target version relaxes limitation to be a multiple of 64KiB.
+See
+.BR lvm.conf (5)
+setting
+.IR allocation / thin_pool_chunk_size_policy
+to select different calculation policy.
+Thin pool target version <1.4 requires this value to be a power of 2.
 For target version <1.5 discard is not supported for non power of 2 values.
 .TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
@@ -203,30 +222,17 @@ Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
 .TP
+.BR \-\-corelog
+This is shortcut for option \fB\-\-mirrorlog\fP \fIcore\fP.
+.TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Sets discards behavior for thin pool.
 Default is \fIpassdown\fP.
 .TP
-.BR \-i ", " \-\-stripes " " \fIStripes
-Gives the number of stripes.
-This is equal to the number of physical volumes to scatter
-the logical volume.  When creating a RAID 4/5/6 logical volume,
-the extra devices which are necessary for parity are
-internally accounted for.  Specifying
-.BI \-i 3
-would use 3 devices for striped logical volumes,
-4 devices for RAID 4/5, and 5 devices for RAID 6.  Alternatively,
-RAID 4/5/6 will stripe across all PVs in the volume group or
-all of the PVs specified if the
-.B \-i
-argument is omitted.
-.TP
-.BR \-I ", " \-\-stripesize " " \fIStripeSize
-Gives the number of kilobytes for the granularity of the stripes.
-.br
-StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
-For metadata in LVM2 format, the stripe size may be a larger
-power of 2 but must not exceed the physical extent size.
+.BR \-K ", " \-\-ignoreactivationskip
+Ignore the flag to skip Logical Volumes during activation.
+Use \fB\-\-setactivationskip\fP option to set or reset
+activation skipping flag persistently for logical volume.
 .TP
 .B \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
@@ -247,19 +253,28 @@ When expressed as a percentage, the number is treated
 as an approximate upper limit for the total number of physical extents
 to be allocated (including extents used by any mirrors, for example).
 .TP
-.IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
-Gives the size to allocate for the new logical volume.
-A size suffix of \fIB\fR for bytes, \fIS\fR for sectors as 512 bytes,
-\fIK\fR for kilobytes, \fIM\fR for megabytes,
-\fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
-or \fIE\fR for exabytes is optional.
-.br
-Default unit is megabytes.
+.BR \-j ", " \-\-major " " \fImajor
+Sets the major number.
+Major numbers are not supported with pool volumes.
+This option is supported only on older systems
+(kernel version 2.4) and is ignored on modern Linux systems where major
+numbers are dynamically assigned.
+.TP
+.BR \-\-metadataprofile " " \fIProfileName
+Uses and attaches the ProfileName configuration profile to the logical
+volume metadata. Whenever the logical volume is processed next time,
+the profile is automatically applied. If the volume group has another
+profile attached, the logical volume profile is preferred.
+See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+.TP
+.B \-\-minor \fIminor
+Sets the minor number.
+Minor numbers are not supported with pool volumes.
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Creates a mirrored logical volume with \fIMirrors\fP copies.
 For example, specifying
-.BI \-m 1
+.BI \-m\  1
 would result in a mirror with two-sides; that is,
 a linear volume plus one copy.
 
@@ -270,49 +285,40 @@ copied.  This is useful for skipping a potentially long and resource
 intensive initial sync of an empty device.
 
 There are two implementations of mirroring which can be used and correspond
-to the "raid1" and "mirror" segment types.  The default is "raid1".  See the
+to the "\fIraid1\fP" and "\fImirror\fP" segment types.
+The default is "\fIraid1\fP".  See the
 \fB\-\-type\fP option for more information if you would like to use the
-legacy "mirror" segment type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
-options apply to the "mirror" segment type only.
-
-The optional argument \fB\-\-mirrorlog\fP specifies the type of log to be
-used for logical volumes utilizing the legacy "mirror" segment type.
+legacy "\fImirror\fP" segment type.  See
+.BR lvm.conf (5)
+settings
+.BR global / mirror_segtype_default
+to configure default mirror segment type.
+The options
+\fB\-\-mirrorlog\fP and \fB\-\-corelog\fP apply
+to the legacy "\fImirror\fP" segment type only.
+.TP
+.BR \-\-mirrorlog " {" \fIdisk | \fIcore | \fImirrored }
+Specifies the type of log to be used for logical volumes utilizing
+the legacy "\fImirror\fP" segment type.
+.br
 The default is \fIdisk\fP, which is persistent and requires
 a small amount of storage space, usually on a separate device from the
-data being mirrored.  Using \fIcore\fP means the mirror is regenerated
-by copying the data from the first device each time the logical
-volume is activated, like after every reboot.  Using \fImirrored\fP
-will create a persistent log that is itself mirrored.
-
-When the legacy "mirror" segment type is used, the optional argument
-\fB\-\-corelog\fP is equivalent to \fB\-\-mirrorlog\fP \fIcore\fP.
-.TP
-.BR \-\-metadataprofile " " \fIProfileName
-Uses and attaches the ProfileName configuration profile to the logical
-volume metadata. Whenever the logical volume is processed next time,
-the profile is automatically applied. If the volume group has another
-profile attached, the logical volume profile is preferred.
-See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
-.TP
-.IR \fB\-M ", " \fB\-\-persistent " {" y | n }
-Set to \fIy\fP to make the minor number specified persistent.
-.TP
-.B \-\-minor \fIminor
-Sets the minor number.
-.TP
-.B \-\-major \fImajor
-Sets the major number. This option is supported only on older systems
-(kernel version 2.4) and is ignored on modern Linux systems where major
-numbers are dynamically assigned.
+data being mirrored.
+.br
+Using \fIcore\fP means the mirror is regenerated by copying the data
+from the first device each time the logical volume is activated,
+like after every reboot.
+.br
+Using \fImirrored\fP will create a persistent log that is itself mirrored.
 .TP
 .BR \-\-monitor " {" \fIy | \fIn }
 Starts or avoids monitoring a mirrored, snapshot or thin pool logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to
-.B activation/mirror_image_fault_policy
+.BR activation / mirror_image_fault_policy
 and
-.B activation/mirror_log_fault_policy
+.BR activation / mirror_log_fault_policy
 set in \fBlvm.conf\fP(5).
 .TP
 .IR \fB\-n ", " \fB\-\-name " " LogicalVolume { Name | Path }
@@ -321,17 +327,8 @@ Sets the name for the new logical volume.
 Without this option a default name of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
-.IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
-Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
-.TP
-.IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
-Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
+.B \-\-nosync
+Causes the creation of the mirror to skip the initial resynchronization.
 .TP
 .B \-\-noudevsync
 Disables udev synchronisation. The
@@ -345,10 +342,23 @@ Sets access permissions to read only (\fIr\fP) or read and write (\fIrw\fP).
 .br
 Default is read and write.
 .TP
+.BR \-M ", " \-\-persistent " {" \fIy | \fIn }
+Set to \fIy\fP to make the minor number specified persistent.
+Pool volumes cannot have persistent major and minor numbers.
+Defaults to \fIy\fPes only when major or minor number is specified.
+Otherwise it is \fIn\fPo.
+.TP
+.IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
+Sets the size of pool's data logical volume.
+For thin pools you may also specify the size
+with the option \fB\-\-size\fP.
+.TP
 .IR \fB\-\-poolmetadatasize " " MetadataVolumeSize [ bBsSkKmMgG ]
-Sets the size of thin pool's metadata logical volume.
-Supported values are in range between 2MiB and 16GiB.
-Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
+Sets the size of pool's metadata logical volume.
+Supported values are in range between 2MiB and 16GiB for thin pool,
+and upto 16GiB for cache pool. The minimum value is computed from pool's
+data size.
+Default value for thin pool is (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
 .TP
 .IR \fB\-\-poolmetadataspare " {"  y | n }
@@ -358,6 +368,18 @@ Only one such volume is maintained within a volume group
 with the size of the biggest pool metadata volume.
 Default is \fIy\fPes.
 .TP
+.BR \-\- [ raid ] maxrecoveryrate " " \fIRate [ \fIbBsSkKmMgG ]
+Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified as an amount per second for each device in the array.
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
+.TP
+.BR \-\- [ raid ] minrecoveryrate " " \fIRate [ \fIbBsSkKmMgG ]
+Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified as an amount per second for each device in the array.
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
+.TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Sets read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
@@ -366,16 +388,41 @@ The default value is \fIauto\fP which allows the kernel to choose
 a suitable value automatically.
 \fINone\fP is equivalent to specifying zero.
 .TP
-.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize
+.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize [ \fIbBsSkKmMgG ]
 A mirror is divided into regions of this size (in MiB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
+.IR \fB\-k ", " \fB\-\-setactivationskip "  {" y | n }
+Controls whether Logical Volumes are persistently flagged to be skipped during
+activation. By default, thin snapshot volumes are flagged for activation skip.
+See
+.BR lvm.conf (5)
+.IR activation / auto_set_activation_skip
+how to change its default behaviour.
+To activate such volumes, an extra
+.BR \-K | \-\-ignoreactivationskip
+option must be used. The flag is not applied during deactivation. Use
+.B lvchange \-\-setactivationskip {y|n}
+command to change the skip flag for existing volumes.
+To see whether the flag is attached, use \fBlvs\fP command
+where the state of the flag is reported within \fBlv_attr\fP bits.
+.TP
+.IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
+Gives the size to allocate for the new logical volume.
+A size suffix of \fIB\fR for bytes, \fIS\fR for sectors as 512 bytes,
+\fIK\fR for kilobytes, \fIM\fR for megabytes,
+\fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
+or \fIE\fR for exabytes is optional.
+.br
+Default unit is megabytes.
+.TP
 .IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path }
 Creates a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
 while the origin can still be updated. They enable consistent
 backups and online recovery of removed/overwritten data/files.
+.br
 Thin snapshot is created when the origin is a thin volume and
 the size IS NOT specified. Thin snapshot shares same blocks within
 the thin pool volume.
@@ -403,51 +450,91 @@ even from different thin pools. See
 .BR lvconvert (8)
 for online conversion to thin volumes with external origin.
 .TP
-.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
+.BR \-i ", " \-\-stripes " " \fIStripes
+Gives the number of stripes.
+This is equal to the number of physical volumes to scatter
+the logical volume.  When creating a RAID 4/5/6 logical volume,
+the extra devices which are necessary for parity are
+internally accounted for.  Specifying
+.BI \-i 3
+would use 3 devices for striped logical volumes,
+4 devices for RAID 4/5, and 5 devices for RAID 6.  Alternatively,
+RAID 4/5/6 will stripe across all PVs in the volume group or
+all of the PVs specified if the
+.B \-i
+argument is omitted.
+.TP
+.BR \-I ", " \-\-stripesize " " \fIStripeSize
+Gives the number of kilobytes for the granularity of the stripes.
+.br
+StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
+For metadata in LVM2 format, the stripe size may be a larger
+power of 2 but must not exceed the physical extent size.
+.TP
+.IR \fB\-T ", " \fB\-\-thin
 Creates thin pool or thin logical volume or both.
-Specifying the optional argument \fB\-\-size\fP will cause the creation of
-the thin pool logical volume.
+Specifying the optional argument \fB\-\-size\fP or \fB\-\-extents\fP
+will cause the creation of the thin pool logical volume.
 Specifying the optional argument \fB\-\-virtualsize\fP will cause
 the creation of the thin logical volume from given thin pool volume.
 Specifying both arguments will cause the creation of both
 thin pool and thin volume using this pool.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
-Requires device mapper kernel driver for thin provisioning
-from kernel 3.2 or newer.
+Thin provisioning requires device mapper kernel driver
+from kernel 3.2 or greater.
+.TP
+.IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
+Specifies the name of thin pool volume name. The other way to specify pool name
+is to append name to Volume group name argument.
 .TP
 .B \-\-type \fISegmentType
-Create a logical volume that uses the specified segment type
-(e.g.
-.IR mirror ( \fB\-m ),
-.IR raid5 ,
-.IR snapshot ( \fB\-s ),
-.IR thin ( \fB\-T ),
-.IR thin-pool ,\ ...).
-Many segment types have a
-commandline switch alias that will enable their use
-(\fB\-s\fP is an alias for
-.B \-\-type \fIsnapshot\fP).
-However, this argument must be used when no existing
-commandline switch alias is available for the desired type,
-as is the case with
+Creates a logical volume with the specified segment type.
+Supported types are:
 .IR cache ,
+.IR cache-pool ,
 .IR error ,
+.IR linear ,
+.IR mirror,
 .IR raid1 ,
 .IR raid4 ,
-.IR raid5 ,
-.IR raid6 ,
-.IR raid10
+.IR raid5_la ,
+.IR raid5_ls " (= " raid5 ),
+.IR raid5_ra ,
+.IR raid5_rs ,
+.IR raid6_nc ,
+.IR raid6_nr ,
+.IR raid6_zr " (= " raid6 ) ,
+.IR raid10 ,
+.IR snapshot ,
+.IR striped,
+.IR thin ,
+.IR thin-pool
 or
 .IR zero .
-See \fBlvmcache\fP(7) for more info about caching support.
-Note that the cache segment type requires a dm-cache kernel module version
-1.3.0 or greater.
-
+Segment type may have a commandline switch alias that will
+enable its use.
+When the type is not explicitly specified an implicit type
+is selected from combination of options:
+.BR \-H | \-\-cache | \-\-cachepool " (" \fIcache
+or
+.IR cachepool ),
+.BR \-T | \-\-thin | \-\-thinpool " (" \fIthin
+or
+.IR thinpool ),
+.BR \-m | \-\-mirrors " (" \fIraid1
+or
+.IR mirror ),
+.BR \-s | \-\-snapshot | \-V | \-\-virtualsize " (" \fIsnapshot
+or
+.IR thin ),
+.BR \-i | \-\-stripes " (" \fIstriped ).
+Default type is \fIlinear\fP.
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
 Creates a sparse device of the given size (in MiB by default) using a snapshot
 or thinly provisioned device when thin pool is specified.
-Anything written to the device will be returned when reading from it.
+See \fBlvmthin\fP(7) for more info about thin provisioning support.
+Anything written to a sparse snapshot will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
 Virtual snapshot is implemented by creating a hidden virtual device of the
 requested size using the zero target.  A suffix of _vorigin is used for
@@ -458,25 +545,27 @@ device sizes (GiB), thin provisioning should be used for this case.
 Controls wiping of detected signatures on newly created Logical Volume.
 If this option is not specified, then by default signature wiping is done
 each time the zeroing (\fB\-Z\fP/\fB\-\-zero\fP) is done. This default behaviour
-can be controlled by \fBallocation/wipe_signatures_when_zeroing_new_lvs\fP
-setting found in \fBlvm.conf\fP(5).
+can be controlled by
+.BR allocation / wipe_signatures_when_zeroing_new_lvs
+setting found in
+.BR lvm.conf (5).
 .br
-If blkid wiping is used (\fBallocation/use_blkid_wiping setting\fP in \fBlvm.conf\fP(5))
+If blkid wiping is used
+.BR allocation / use_blkid_wiping
+setting in
+.BR lvm.conf (5))
 and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
 to detect the signatures (use \fBblkid -k\fP command to list the signatures that are recognized).
 Otherwise, native LVM2 code is used to detect signatures (MD RAID, swap and LUKS
 signatures are detected only in this case).
 .br
-Logical Volume is not wiped if the read only flag is set.
+Logical volume is not wiped if the read only flag is set.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first 4KiB of data in the new logical volume.
-.br
 Default is \fIy\fPes.
-.br
-Volume will not be zeroed if the read only flag is set.
-.br
-Snapshot volumes are zeroed always.
+Snapshot COW volumes are always zeroed.
+Logical volume is not zeroed if the read only flag is set.
 
 .br
 Warning: trying to mount an unzeroed logical volume can cause the system to
@@ -572,7 +661,7 @@ If there is an existing cache pool LV, create the large slow
 device (i.e. the origin LV) and link it to the supplied cache pool LV,
 creating a cache LV.
 .sp
-.B lvcreate \-\-type cache \-L 100G \-n my_lv vg/my_lv_cachepool /dev/slow1
+.B lvcreate \-\-cache \-L 100G \-n my_lv vg/my_lv_cachepool /dev/slow1
 
 If there is an existing logical volume, create the small and fast
 cache pool LV and link it to the supplied existing logical
@@ -580,6 +669,10 @@ volume (i.e. the origin LV), creating a cache LV.
 .sp
 .B lvcreate \-\-type cache \-L 1G \-n my_lv_cachepool vg/my_lv /dev/fast1
 
+Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
+.sp
+.B lvcreate \-\-cache \-L 1G \-n lv --pooldatasize 10M vg00/pool
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
@@ -593,4 +686,5 @@ volume (i.e. the origin LV), creating a cache LV.
 .BR lvrename (8)
 .BR lvs (8),
 .BR lvscan (8),
-.BR vgcreate (8)
+.BR vgcreate (8),
+.BR blkid (8)


