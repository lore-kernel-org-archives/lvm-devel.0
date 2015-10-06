From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Oct 2015 13:25:19 +0000 (UTC)
Subject: master - man: lvcreate continue
Message-ID: <20151006132519.3DB5760F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ded9452174664b7e204f5ce266bbd5c770714474
Commit:        ded9452174664b7e204f5ce266bbd5c770714474
Parent:        4b1cadbd87a0814a46b36b07cfe94eda7baacb28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 6 14:55:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 6 15:23:55 2015 +0200

man: lvcreate continue

Finish remaing bits of updating pages for better rendering
with -Thtml, -Tps.
---
 man/lvchange.8.in |    3 +
 man/lvcreate.8.in |  277 ++++++++++++++++++++++++++++++----------------------
 man/lvm.8.in      |    1 +
 3 files changed, 164 insertions(+), 117 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 62bdca1..8ae17a0 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -431,7 +431,10 @@ Suppress locking failure messages.
 Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .sp
 .B lvchange \-pr vg00/lvol1
+.
 .SH SEE ALSO
+.
+.nh
 .BR lvm (8),
 .BR lvmetad (8),
 .BR lvs (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 8a364c4..2ce39dd 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -1,7 +1,22 @@
 .TH LVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.
+.\" Use 1st. parameter with \% to fix 'man2html' rendeing on same line!
+.de SIZE_G
+.  IR \\$1 \c
+.  RB [ b | B | s | S | k | K | m | M | g | G ]
+..
+.de SIZE_E
+.  IR \\$1 \c
+.  RB [ b | B | s | S | k | K | m | M | \c
+.  BR g | G | t | T | p | P | e | E ]
+..
+.
 .SH NAME
+.
 lvcreate \- create a logical volume in an existing volume group
+.
 .SH SYNOPSIS
+.
 .ad l
 .B lvcreate
 .RB [ \-a | \-\-activate
@@ -17,7 +32,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
 .IR policy ]
-.RB [ \-\-cachepool
+.RB \%[ \-\-cachepool
 .IR CachePoolLogicalVolume ]
 .RB [ \-\-cachesettings
 .IR key \fB= value ]
@@ -25,7 +40,7 @@ lvcreate \- create a logical volume in an existing volume group
 .IR ChunkSize ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
-.RB [ \-C | \-\-contiguous
+.RB \%[ \-C | \-\-contiguous
 .RB { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-discards
@@ -78,7 +93,7 @@ lvcreate \- create a logical volume in an existing volume group
 .IR Rate ]
 .RB [ \-r | \-\-readahead
 .RB { \fIReadAheadSectors | auto | none }]
-.RB [ \-k | \-\-setactivationskip
+.RB \%[ \-k | \-\-setactivationskip
 .RB { y | n }]
 .RB [ \-s | \-\-snapshot ]
 .RB [ \-V | \-\-virtualsize
@@ -94,9 +109,10 @@ lvcreate \- create a logical volume in an existing volume group
 .RB { y | n }]
 .RB [ \-Z | \-\-zero
 .RB { y | n }]
-.RI [ VolumeGroup [ \fB/ { ExternalOrigin |\: Origin |
-.IR Pool } LogicalVolumeName ]
-.RI [ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.RI [ VolumeGroup \c
+.RB [ / \c
+.RI { ExternalOrigin | Origin | Pool } LogicalVolumeName
+.RI [ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]]
 .LP
 .B lvcreate
 .RB [ \-l | \-\-extents
@@ -107,7 +123,7 @@ lvcreate \- create a logical volume in an existing volume group
 .IR LogicalVolumeSize ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
-.RB [ \-\-commandprofile
+.RB \%[ \-\-commandprofile
 .IR Profile\%Name ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-ignoremonitoring ]
@@ -118,11 +134,13 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-n | \-\-name
 .IR SnapshotLogicalVolume ]
 .BR \-s | \-\-snapshot | \-H | \-\-cache
-.RI \%{[ VolumeGroup \fB/ ] OriginalLogicalVolume
-.BR \-V | \-\-virtualsize
-.IR VirtualSize }
+.RI \%{[ VolumeGroup \fB/\fP] OriginalLogicalVolume
+.RB \%[ \-V | \-\-virtualsize
+.IR VirtualSize ]}
 .ad b
+.
 .SH DESCRIPTION
+.
 lvcreate creates a new logical volume in a volume group (see
 .BR vgcreate "(8), " vgchange (8))
 by allocating logical extents from the free physical extent pool
@@ -151,40 +169,41 @@ for common options.
 .br
 Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
-By default, new Logical Volumes are activated (\fB\-a\fIy\fR).
-If it is possible technically, \fB\-a\fIn\fR will leave the new Logical
+By default, new Logical Volumes are activated (\fB\-ay\fP).
+If it is possible technically, \fB\-an\fP will leave the new Logical
 Volume inactive. But for example, snapshots of active origin can only be
-created in the active state so \fB\-a\fIn\fR cannot be used with
-\fB-\-type\fP \fIsnapshot\fP. This does not apply to thin volume snapshots,
+created in the active state so \fB\-an\fP cannot be used with
+\fB-\-type snapshot\fP. This does not apply to thin volume snapshots,
 which are by default created with flag to skip their activation
-(\fB-k\fP\fIy\fP).
-Normally the \fB\-\-zero\fP \fIn\fP argument has to be supplied too because
+(\fB-ky\fP).
+Normally the \fB\-\-zero n\fP argument has to be supplied too because
 zeroing (the default behaviour) also requires activation.
-If autoactivation option is used (\fB\-a\fIay\fR), the logical volume is
+If autoactivation option is used (\fB\-aay\fP), the logical volume is
 activated only if it matches an item in the
-.IR activation / auto_activation_volume_list
+\fBactivation/auto_activation_volume_list\fP
 set in \fBlvm.conf\fP(5).
-For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP and
-\fB\-\-wipesignatures\fP \fIn\fP is always assumed and it can't
+For autoactivated logical volumes, \fB\-\-zero n\fP and
+\fB\-\-wipesignatures n\fP is always assumed and it can't
 be overridden. If the clustered locking is enabled,
-\fB\-a\fIey\fR will activate exclusively on one node and
-.IR \fB\-a { a | l } y
+\fB\-aey\fP will activate exclusively on one node and
+.BR \-a { a | l } y
 will activate only on the local node.
 .
 .HP
 .BR \-H | \-\-cache
 .br
-Creates cache or cache pool logical volume or both.
-Specifying the optional argument \fB\-\-size\fP will cause the creation of
-the cache logical volume.
+Creates cache or cache pool logical volume.
+.\" or both.
+Specifying the optional argument \fB\-\-extents\fP or \fB\-\-size\fP
+will cause the creation of the cache logical volume.
 .\" Specifying the optional argument \fB\-\-pooldatasize\fP will cause
 .\" the creation of the cache pool logical volume.
-Specifying both arguments will cause the creation of cache with its
-cache pool volume.
+.\" Specifying both arguments will cause the creation of cache with its
+.\" cache pool volume.
 When the Volume group name is specified together with existing logical volume
-name which is NOT a cache pool name, such volume is treaded
-as cache origin volume and cache pool is created. In this case
-the \fB\-\-size\fP is used to specify size of cache pool volume.
+name which is NOT a cache pool name, such volume is treated
+as cache origin volume and cache pool is created. In this case the
+\fB\-\-extents\fP or \fB\-\-size\fP is used to specify size of cache pool volume.
 See \fBlvmcache\fP(7) for more info about caching support.
 Note that the cache segment type requires a dm-cache kernel module version
 1.3.0 or greater.
@@ -228,19 +247,18 @@ and removes it from the list of settings stored in lvm2 metadata.
 .
 .HP
 .BR \-c | \-\-chunksize
-.IR ChunkSize \c
-.RB [ b | B | s | S | k | K | m | M | g | G ]
+.SIZE_G \%ChunkSize
 .br
 Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
 .br
-For \fIsnapshots\fP the value must be power of 2 between 4KiB and 512KiB
+For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4KiB.
 .br
-For \fIcache pools\fP the value must a multiple of 32KiB
+For cache pools the value must a multiple of 32KiB
 between 32KiB and 1GiB. The default is 64KiB.
 .br
-For \fIthin pools\fP the value must be a multiple of 64KiB
+For thin pools the value must be a multiple of 64KiB
 between 64KiB and 1GiB.
 Default value starts with 64KiB and grows up to
 fit the pool metadata size within 128MiB,
@@ -279,7 +297,7 @@ Default is \fBpassdown\fP.
 Configures thin pool behaviour when data space is exhausted.
 Default is \fBn\fPo.
 Device will queue I/O operations until target timeout
-(see dm-thin-pool kernel module option \fIno_space_timeout\fP)
+(see dm-thin-pool kernel module option \fPno_space_timeout\fP)
 expires. Thus configured system has a time to i.e. extend
 the size of thin pool data device.
 When set to \fBy\fPes, the I/O operation is immeditelly errored.
@@ -313,7 +331,7 @@ PhysicalVolume(s) with the suffix \fB%PVS\fP, or (for a snapshot) as a
 percentage of the total space in the Origin Logical Volume with the
 suffix \fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
 When expressed as a percentage, the number is treated
-as an approximate upper limit for the total number of physical extents
+as an approximate upper limit for the number of physical extents
 to be allocated (including extents used by any mirrors, for example).
 .
 .HP
@@ -330,7 +348,7 @@ numbers are dynamically assigned.
 .BR \-\-metadataprofile
 .IR ProfileName
 .br
-Uses and attaches the ProfileName configuration profile to the logical
+Uses and attaches the \fIProfileName\fP configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
 profile attached, the logical volume profile is preferred.
@@ -448,7 +466,7 @@ Otherwise it is \fBn\fPo.
 .
 .HP
 .BR \-\-poolmetadatasize
-.BR \fIMetadataVolumeSize [ b | B | s | S | k | K | m | M | g | G ]
+.SIZE_G \%MetadataVolumeSize
 .br
 Sets the size of pool's metadata logical volume.
 Supported values are in range between 2MiB and 16GiB for thin pool,
@@ -469,7 +487,7 @@ Default is \fBy\fPes.
 .
 .HP
 .BR \-\- [ raid ] maxrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.SIZE_G \%Rate
 .br
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
@@ -478,7 +496,7 @@ recovery rate to 0 means it will be unbounded.
 .
 .HP
 .BR \-\- [ raid ] minrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.SIZE_G \%Rate
 .br
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
@@ -498,7 +516,7 @@ a suitable value automatically.
 .
 .HP
 .BR \-R | \-\-regionsize
-.BR \fIMirrorLogRegionSize [ b | B | s | S | k | K | m | M | g | G ]
+.SIZE_G \%MirrorLogRegionSize
 .br
 A mirror is divided into regions of this size (in MiB), and the mirror log
 uses this granularity to track which regions are in sync.
@@ -522,9 +540,7 @@ where the state of the flag is reported within \fBlv_attr\fP bits.
 .
 .HP
 .BR \-L | \-\-size
-.BR \fILogicalVolumeSize [ b | B | s | S | k | K | m | M | \c
-.BR g | G | t | T | p | P | e | E ]
-.\" man2html cannot handle all those changes in 1 line
+.SIZE_E \%LogicalVolumeSize
 .br
 Gives the size to allocate for the new logical volume.
 A size suffix of \fBB\fP for bytes, \fBS\fP for sectors as 512 bytes,
@@ -533,8 +549,11 @@ A size suffix of \fBB\fP for bytes, \fBS\fP for sectors as 512 bytes,
 or \fBE\fP for exabytes is optional.
 .br
 Default unit is megabytes.
-.TP
-.IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path }
+.
+.HP
+.BR \-s | \fB\-\-snapshot
+.IR OriginalLogicalVolume { Name | Path }
+.br
 Creates a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
@@ -567,29 +586,35 @@ External origin volume can be used/shared for many thin volumes
 even from different thin pools. See
 .BR lvconvert (8)
 for online conversion to thin volumes with external origin.
-.TP
-.BR \-i ", " \-\-stripes " " \fIStripes
+.
+.HP
+.BR \-i | \-\-stripes
+.IR Stripes
+.br
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
 the logical volume.  When creating a RAID 4/5/6 logical volume,
 the extra devices which are necessary for parity are
-internally accounted for.  Specifying
-.BI \-i 3
+internally accounted for.  Specifying \fB\-i 3\fP
 would use 3 devices for striped logical volumes,
 4 devices for RAID 4/5, and 5 devices for RAID 6.  Alternatively,
 RAID 4/5/6 will stripe across all PVs in the volume group or
-all of the PVs specified if the
-.B \-i
+all of the PVs specified if the \fB\-i\fP
 argument is omitted.
-.TP
-.BR \-I ", " \-\-stripesize " " \fIStripeSize
+.
+.HP
+.BR \-I | \-\-stripesize
+.IR StripeSize
+.br
 Gives the number of kilobytes for the granularity of the stripes.
 .br
 StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
-.TP
-.IR \fB\-T ", " \fB\-\-thin
+.
+.HP
+.BR \-T | \-\-thin
+.br
 Creates thin pool or thin logical volume or both.
 Specifying the optional argument \fB\-\-size\fP or \fB\-\-extents\fP
 will cause the creation of the thin pool logical volume.
@@ -600,81 +625,93 @@ thin pool and thin volume using this pool.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
 Thin provisioning requires device mapper kernel driver
 from kernel 3.2 or greater.
-.TP
-.IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
+.
+.HP
+.BR \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }
+.br
 Specifies the name of thin pool volume name. The other way to specify pool name
 is to append name to Volume group name argument.
-.TP
-.B \-\-type \fISegmentType
+.
+.HP
+.BR \-\-type
+.IR SegmentType
+.br
 Creates a logical volume with the specified segment type.
 Supported types are:
-.IR cache ,
-.IR cache-pool ,
-.IR error ,
-.IR linear ,
-.IR mirror,
-.IR raid1 ,
-.IR raid4 ,
-.IR raid5_la ,
-.IR raid5_ls " (= " raid5 ),
-.IR raid5_ra ,
-.IR raid5_rs ,
-.IR raid6_nc ,
-.IR raid6_nr ,
-.IR raid6_zr " (= " raid6 ) ,
-.IR raid10 ,
-.IR snapshot ,
-.IR striped,
-.IR thin ,
-.IR thin-pool
+.BR cache ,
+.BR cache-pool ,
+.BR error ,
+.BR linear ,
+.BR mirror,
+.BR raid1 ,
+.BR raid4 ,
+.BR raid5_la ,
+.BR raid5_ls
+.RB (=
+.BR raid5 ),
+.BR raid5_ra ,
+.BR raid5_rs ,
+.BR raid6_nc ,
+.BR raid6_nr ,
+.BR raid6_zr
+.RB (=
+.BR raid6 ),
+.BR raid10 ,
+.BR snapshot ,
+.BR striped,
+.BR thin ,
+.BR thin-pool
 or
-.IR zero .
+.BR zero .
 Segment type may have a commandline switch alias that will
 enable its use.
 When the type is not explicitly specified an implicit type
 is selected from combination of options:
-.BR \-H | \-\-cache | \-\-cachepool " (" \fIcache
-or
-.IR cachepool ),
-.BR \-T | \-\-thin | \-\-thinpool " (" \fIthin
-or
-.IR thinpool ),
-.BR \-m | \-\-mirrors " (" \fIraid1
-or
-.IR mirror ),
-.BR \-s | \-\-snapshot | \-V | \-\-virtualsize " (" \fIsnapshot
-or
-.IR thin ),
-.BR \-i | \-\-stripes " (" \fIstriped ).
-Default type is \fIlinear\fP.
-.TP
-.BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
+.BR \-H | \-\-cache | \-\-cachepool
+(cache or cachepool),
+.BR \-T | \-\-thin | \-\-thinpool
+(thin or thinpool),
+.BR \-m | \-\-mirrors
+(raid1 or mirror),
+.BR \-s | \-\-snapshot | \-V | \-\-virtualsize
+(snapshot or thin),
+.BR \-i | \-\-stripes
+(striped).
+Default segment type is \fBlinear\fP.
+.
+.HP
+.BR \-V | \-\-virtualsize
+.SIZE_E \%VirtualSize
+.br
 Creates a thinly provisioned device or a sparse device of the given size (in MiB by default).
 See
 .BR lvm.conf (5)
-settings
-.IR global / sparse_segtype_default
+settings \fBglobal/sparse_segtype_default\fP
 to configure default sparse segment type.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
 Anything written to a sparse snapshot will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
-Virtual snapshot is implemented by creating a hidden virtual device of the
-requested size using the zero target.  A suffix of _vorigin is used for
-this device. Note: using sparse snapshots is not efficient for larger
+Virtual snapshot (sparse snapshot) is implemented by creating
+a hidden virtual device of the requested size using the zero target.
+A suffix of _vorigin is used for this device.
+Note: using sparse snapshots is not efficient for larger
 device sizes (GiB), thin provisioning should be used for this case.
-.TP
-.BR \-W ", " \-\-wipesignatures " {" \fIy | \fIn }
+.
+.HP
+.BR \-W | \-\-wipesignatures
+.RB { y | n }
+.br
 Controls wiping of detected signatures on newly created Logical Volume.
 If this option is not specified, then by default signature wiping is done
-each time the zeroing (\fB\-Z\fP/\fB\-\-zero\fP) is done. This default behaviour
-can be controlled by
-.IR allocation / wipe_signatures_when_zeroing_new_lvs
+each time the zeroing (
+.BR \-Z | \-\-zero
+) is done. This default behaviour
+can be controlled by \fB\%allocation/wipe_signatures_when_zeroing_new_lvs\fP
 setting found in
 .BR lvm.conf (5).
 .br
-If blkid wiping is used
-.IR allocation / use_blkid_wiping
-setting in
+If blkid wiping is used \fBallocation/use_blkid_wiping\fP setting in
 .BR lvm.conf (5))
 and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
 to detect the signatures (use \fBblkid \-k\fP command to list the signatures that are recognized).
@@ -682,17 +719,21 @@ Otherwise, native LVM2 code is used to detect signatures (MD RAID, swap and LUKS
 signatures are detected only in this case).
 .br
 Logical volume is not wiped if the read only flag is set.
-.TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
+.
+.HP
+.BR \-Z | \-\-zero
+.RB { y | n }
+.br
 Controls zeroing of the first 4KiB of data in the new logical volume.
-Default is \fIy\fPes.
+Default is \fBy\fPes.
 Snapshot COW volumes are always zeroed.
 Logical volume is not zeroed if the read only flag is set.
-
 .br
 Warning: trying to mount an unzeroed logical volume can cause the system to
 hang.
+.
 .SH Examples
+.
 Creates a striped logical volume with 3 stripes, a stripe size of 8KiB
 and a size of 100MiB in the volume group named vg00.
 The logical volume name will be chosen by lvcreate:
@@ -701,8 +742,8 @@ The logical volume name will be chosen by lvcreate:
 
 Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
 This operation would require 3 devices (or option
-.BI \-\-alloc \ anywhere
-) - two for the mirror devices and one for the disk log:
+\fB\-\-alloc \%anywhere\fP) - two for the mirror
+devices and one for the disk log:
 .sp
 .B lvcreate \-m1 \-L 500M vg00
 
@@ -794,8 +835,10 @@ volume (i.e. the origin LV), creating a cache LV.
 .\" Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
 .\" .sp
 .\" .B lvcreate \-\-cache \-L 1G \-n lv \-\-pooldatasize 10M vg00/pool
-
+.
 .SH SEE ALSO
+.
+.nh
 .BR lvm (8),
 .BR lvm.conf (5),
 .BR lvmcache (7),
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 8ff31ae..31f7187 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -757,6 +757,7 @@ directly.
 .
 .SH SEE ALSO
 .
+.nh
 .BR lvm.conf (5),
 .BR lvmcache (7),
 .BR lvmthin (7),


