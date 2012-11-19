From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:49:07 +0000 (UTC)
Subject: master - thin: man page updates
Message-ID: <20121119134907.EE7221698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf1cf1459f414eb1b397c21a0cdbd5acda7540f6
Commit:        bf1cf1459f414eb1b397c21a0cdbd5acda7540f6
Parent:        1794f777f48be29184ef8030b6e11b3a8e61757b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 30 17:11:59 2012 +0000
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

thin: man page updates

Cover latest extensions of lvconvert functionality.
Update also lvcreate page.
---
 man/lvconvert.8.in |  103 ++++++++++++++++++++++++++++++++++++++++++++--------
 man/lvcreate.8.in  |   18 +++++-----
 2 files changed, 96 insertions(+), 25 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 2659719..48345a9 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -40,7 +40,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .B lvconvert
 .BR \-s | \-\-snapshot
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
+.IR ChunkSize [ bBsSkK ]]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
@@ -59,17 +59,6 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]...
 .sp
-.B lvconvert \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
-.IR ThinMetadataLogicalVolume { Name | Path }
-.sp
 .B lvconvert \-\-repair
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
@@ -83,6 +72,31 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]
 .RI [ PhysicalVolume [ Path ]...]
+.sp
+.B lvconvert \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize [ bBsSkKmMgG ]]
+.RB [ \-\-discards
+.RI { ignore | nopassdown | passdown }]
+.RB [[ \-\-poolmetadata
+.IR ThinPoolMetadataLogicalVolume { Name | Path }]
+|
+.RB [ \-\-poolmetadatasize
+.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]
+.RB [ \-r | \-\-readahead
+.RI { ReadAheadSectors | auto | none }]
+.RB [ \-\-stripes
+.I Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.sp
 
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
@@ -102,8 +116,9 @@ the freed extents come first from the specified PhysicalVolumes.
 See \fBlvm\fP(8) for common options.
 .br
 Exactly one of 
-.BR \-\-splitmirrors ", " \-\-mirrors ", " \-\-repair ", " \-\-snapshot
-or \fB\-\-merge\fP arguments is required.
+.BR \-\-merge ", " \-\-mirrors ", " \-\-repair ", " \-\-replace
+.RB ", " \-\-snapshot ", " \-\-splitmirrors " or " \-\-thinpool
+arguments is required.
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
@@ -170,12 +185,28 @@ implementation and not with the original device-mapper mirror implementation.
 Create a snapshot from existing logical volume using another
 existing logical volume as its origin.
 .TP
-.BR \-c ", " \-\-chunksize " " \fIChunkSize
-Power of 2 chunk size for the snapshot logical volume between 4KiB and 512KiB.
+.BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
+Gives the size of chunk for snapshot and thin pool logical volumes.
+For snapshots the value must be power of 2 between 4KiB and 512KiB
+and the default value is 4.
+For thin pools the value must be between 64KiB and
+1GiB and the default value starts with 64 and scales
+up to fit the pool metadata size within 128MB,
+if the pool metadata size is not specified.
+Older dm thin pool target version (<1.4) requires the value to be power of 2.
+The newer version requires to be the multiple of 64KiB, however discard is
+not supported for non power of 2 values.
+Default unit is in kilobytes.
+.TP
+.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
+Sets discards behavior for thin pool.
+Default is \fIpassdown\fP.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
+For thin pool volumes it controls zeroing of provisioned blocks.
+Note: Provisioning of large zeroed chunks impacts performance.
 .TP
 .B \-\-merge
 Merges a snapshot into its origin volume or merges a raid1 image that has
@@ -195,6 +226,28 @@ merge finishes, the merged snapshot is removed.  Multiple snapshots may
 be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
 .TP
+.BR \-\-poolmetadata " " \fIThinPoolMetadataLogicalVolume { \fIName | \fIPath }
+Specifies thin pool metadata logical volume.
+The size should be in between 2MiB and 16GiB.
+Thin pool is specified with the option
+\fB\-\-thinpool\fP.
+.TP
+.BR \-\-poolmetadatasize " " \fIThinPoolMetadataSize [ \fIbBsSkKmMgG ]
+Sets the size of thin pool's metadata logical volume,
+if the pool metadata volume is undefined.
+Thin pool is specified with the option
+\fB\-\-thinpool\fP.
+Supported value is in the range between 2MiB and 16GiB.
+The default value is estimated with this formula
+(Pool_LV_size / Pool_LV_chunk_size * 64b).
+Default unit is megabytes.
+.TP
+.IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
+Sets read ahead sector count of thin pool metadata logical volume.
+The default value is "auto" which allows the kernel to choose
+a suitable value automatically.
+"None" is equivalent to specifying zero.
+.TP
 .B \-\-repair
 Repair a mirror after suffering a disk failure. The mirror will be brought back
 into a consistent state.  By default, the original number of mirrors will be
@@ -210,6 +263,24 @@ Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
 that is available in the volume group or from the specific list provided.
 This option is only available to RAID segment types
 (e.g. "raid1", "raid5", etc).
+.TP
+.BR \-\-stripes " " \fIStripes
+Gives the number of stripes.
+This is equal to the number of physical volumes to scatter
+the logical volume.
+.TP
+.BR \-I ", " \-\-stripesize " " \fIStripeSize
+Gives the number of kilobytes for the granularity of the stripes.
+.br
+StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
+For metadata in LVM2 format, the stripe size may be a larger
+power of 2 but must not exceed the physical extent size.
+.TP
+.IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
+Changes logical volume into a thin pool volume. The volume
+will store the pool's data.
+Thin pool metadata logical volume can be specified with the option
+\fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
 
 .SH Examples
 Converts the linear logical volume "vg00/lvol1" to a two-way mirror
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index f374950..705ebae 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -53,11 +53,11 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-t | \-\-test ]
 .RB [ \-T | \-\-thin
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
+.IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
-.IR MetadataSize [ bBsSkKmMgG ]]]
+.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-\-type
@@ -76,7 +76,7 @@ lvcreate \- create a logical volume in an existing volume group
 .BR \-L | \-\-size
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
+.IR ChunkSize [ bBsSkK ]]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-monitor " {" \fIy | \fIn }]
@@ -125,14 +125,14 @@ always assumed and it can't be overridden. If clustered locking is enabled,
 \fB\-a\fIey\fR will activate exclusively on one node and \fB\-a\fIly\fR will
 activate only on the local node.
 .TP
-.BR \-c ", " \-\-chunksize " " \fIChunkSize
+.BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot and thin pool logical volumes.
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
 For thin pools the value must be between 64KiB and
-1048576KiB and the default value starts with 64 and scales
+1GiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MB,
-if the poolmetadata size is not specified.
+if the pool metadata size is not specified.
 Older dm thin pool target version (<1.4) requires the value to be power of 2.
 The newer version requires to be the multiple of 64KiB, however discard is
 not supported for non power of 2 values.
@@ -144,7 +144,7 @@ logical volumes. Default is no contiguous allocation based
 on a next free principle.
 .TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
-Set discards behavior.
+Set discards behavior for thin pool.
 Default is \fIpassdown\fP.
 .TP
 .BR \-i ", " \-\-stripes " " \fIStripes
@@ -236,7 +236,7 @@ Set access permissions to read only or read and write.
 .br
 Default is read and write.
 .TP
-.IR \fB\-\-poolmetadatasize " " MetadataSize [ bBsSkKmMgG ]
+.IR \fB\-\-poolmetadatasize " " ThinPoolMetadataSize [ bBsSkKmMgG ]
 Set the size of thin pool's metadata logical volume.
 Supported value is in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
@@ -372,7 +372,7 @@ copies.
 .B lvcreate \-\-type raid10 \-L 5G \-i 2 \-m 1 \-n my_lv vg00
 
 Creates 100MiB pool logical volume for thin provisioning
-build with 2 stripes 64KiB and chunk size 128KiB together with
+build with 2 stripes 64KiB and chunk size 256KiB together with
 1TiB thin provisioned logical volume "vg00/thin_lv":
 .sp
 .B lvcreate \-i 2 \-I 64 \-c 256 \-L100M \-T vg00/pool \-V 1T \-\-name thin_lv


