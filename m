From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 22:47:18 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111104224718.4184.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 22:47:17

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin lvcreate man update
	
	Added poolmetadatasize options
	Add an example.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/man/lvcreate.8.in	2011/10/30 22:08:21	1.29
+++ LVM2/man/lvcreate.8.in	2011/11/04 22:47:17	1.30
@@ -79,26 +79,27 @@
 .br
 
 .B lvcreate
+.BR \-T | \-\-thin
+.IR VolumeGroupName [ Path ][/ ThinPoolLogicalVolumeName
+.RB [{ \-l | \-\-extents
+.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
+|
+.BR \-L | \-\-size
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-i | \-\-stripes
 .IR Stripes
 .RB [ \-I | \-\-stripesize
 .IR StripeSize ]]
-.RB [ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
-|
-.BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
+.RB [ \-\-poolmetadatasize
+.IR MetadataSize [ bBsSkKmMgGt ]]]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolumeName [ Path ]]
 .RB [ \-V | \-\-virtualsize
-.IR VirtualSize ]
+.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-n | \-\-name
-.IR ThinLogicalVolumeName ]
-.RB [ \-T | \-\-thin
-.IR VolumeGroupName [/ ThinPoolLogicalVolumeName
-|
-.B \-\-thinpool
-.IR ThinPoolLogicalVolumeName ]]
+.IR ThinLogicalVolumeName [ Path ]]
 .br
 
 .SH DESCRIPTION
@@ -235,6 +236,12 @@
 .br
 Default is read and write.
 .TP
+.IR \fB\-\-poolmetadatasize " " MetadataSize [ bBsSkKmMgG ]
+Set the size of thin pool's metadata logical volume.
+Supported value is in range between 2MiB and 16GiB.
+Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
+
+.TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
@@ -269,17 +276,24 @@
 .TP
 .B \-\-type \fISegmentType
 Create a logical volume that uses the specified segment type
-(e.g. "raid5", "mirror", "snapshot").  Many segment types have a
+(e.g. "raid5", "mirror", "snapshot", "thin", "thin_pool").
+Many segment types have a
 commandline switch alias that will enable their use (-s is an alias for
 --type snapshot).  However, this argument must be used when no existing
 commandline switch alias is available for the desired type, as is the case
 with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
 .TP
-.BR \-T ", " \-\-thin " " \fIVolumeGroupName [/ \fIThinPoolLogicalVolumeName ]
-Defines the thin pool logical volume.
-.TP
-.BR \-\-thinpool " " \fIThinPoolLogicalVolumeName
-Specifies the thin pool logical volume.
+.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolumeName [ Path ]
+Creates thin pool or thin logical volume or both.
+Specifying the optional argument --size will cause the creation of
+the thin pool logical volume.
+Specifying the optional argument --virtualsize will cause the creation of
+the thin logical volume from given thin pool volume.
+Specifying both arguments will cause the creation of both
+thin pool and thin volume using this pool.
+Requires device mapper kernel driver for thin provisioning
+from kernel 3.2 or newer.
+
 .TP
 .IR \fB\-V ", " \fB\-\-virtualsize " " VirtualSize [ bBsSkKmMgGtTpPeE ]
 Create a sparse device of the given size (in MB by default) using a snapshot
@@ -344,6 +358,12 @@
 .sp
 .B lvcreate --type raid5 -L 5G -i 3 -I 64 -n my_lv vg00
 
+Creates 100MiB pool logical volume for thin provisioning
+build with 2 stripes 64KiB and chunk size 128KiB together with
+1TiB thin provisioned logical volume "vg00/thin_lv".
+.sp
+.B lvcreate -i 2 -I 64 -c 256  -L100M -T vg00/pool -V 1T --name thin_lv
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR vgcreate (8), 


