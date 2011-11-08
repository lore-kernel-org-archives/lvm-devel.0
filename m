From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Nov 2011 12:12:32 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111108121232.21016.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-08 12:12:32

Modified files:
	man            : lvcreate.8.in 

Log message:
	More lvcreate man updates
	
	Use  { Name | Path } consistently like elsewhere.
	Move --thin alphabetically before --type.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/man/lvcreate.8.in	2011/11/07 10:59:55	1.31
+++ LVM2/man/lvcreate.8.in	2011/11/08 12:12:31	1.32
@@ -42,7 +42,7 @@
 .RB [ \-R | \-\-regionsize
 .IR MirrorLogRegionSize ]]
 .RB [ \-n | \-\-name
-.IR LogicalVolumeName [ Path ]]
+.IR LogicalVolume { Name | Path }]
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
 .RB [ \-r | \-\-readahead
@@ -53,7 +53,7 @@
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
-.IR VolumeGroupName [ Path ]
+.IR VolumeGroup { Name | Path }
 .RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .br
 
@@ -69,18 +69,18 @@
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-monitor " {" \fIy | \fIn }]
 .RB [ \-n | \-\-name
-.IR SnapshotLogicalVolumeName [ Path ]]
+.IR SnapshotLogicalVolume { Name | Path }]
 .BR \-s | \-\-snapshot
-.RI [ OriginalLogicalVolume [ Path ]
+.RI { OriginalLogicalVolume { Name | Path }
 |
-.IR VolumeGroupName [ Path ]
+.IR VolumeGroup { Name | Path }
 .BR \-V | \-\-virtualsize
-.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
+.IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
 .br
 
 .B lvcreate
 .BR \-T | \-\-thin
-.IR VolumeGroupName [ Path ][/ ThinPoolLogicalVolumeName
+.IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
 .RB [{ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
 |
@@ -95,11 +95,11 @@
 .RB [ \-\-poolmetadatasize
 .IR MetadataSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
-.IR ThinPoolLogicalVolumeName [ Path ]]
+.IR ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-V | \-\-virtualsize
 .IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-n | \-\-name
-.IR ThinLogicalVolumeName [ Path ]]
+.IR ThinLogicalVolume { Name | Path }]
 .br
 
 .SH DESCRIPTION
@@ -206,7 +206,7 @@
 The optional argument --corelog is equivalent to --mirrorlog core.
 
 .TP
-.BR \-n ", " \-\-name " " \fILogicalVolumeName
+.IR \fB\-n ", " \fB\-\-name " " LogicalVolume { Name | Path }
 The name for the new logical volume.
 .br
 Without this option a default names of "lvol#" will be generated where
@@ -255,7 +255,9 @@
 A mirror is divided into regions of this size (in MB), and the mirror log 
 uses this granularity to track which regions are in sync.
 .TP
-.BR \-s ", " \-\-snapshot
+.IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path } 
+.RI "| " VolumeGroup { Name | Path }
+
 Create a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
@@ -275,16 +277,7 @@
 rate at which the snapshot data is growing so you can avoid running out
 of space.
 .TP
-.B \-\-type \fISegmentType
-Create a logical volume that uses the specified segment type
-(e.g. "raid5", "mirror", "snapshot", "thin", "thin_pool").
-Many segment types have a
-commandline switch alias that will enable their use (-s is an alias for
---type snapshot).  However, this argument must be used when no existing
-commandline switch alias is available for the desired type, as is the case
-with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
-.TP
-.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolumeName [ Path ]
+.IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
 Creates thin pool or thin logical volume or both.
 Specifying the optional argument --size will cause the creation of
 the thin pool logical volume.
@@ -294,7 +287,15 @@
 thin pool and thin volume using this pool.
 Requires device mapper kernel driver for thin provisioning
 from kernel 3.2 or newer.
-
+.TP
+.B \-\-type \fISegmentType
+Create a logical volume that uses the specified segment type
+(e.g. "raid5", "mirror", "snapshot", "thin", "thin_pool").
+Many segment types have a
+commandline switch alias that will enable their use (-s is an alias for
+--type snapshot).  However, this argument must be used when no existing
+commandline switch alias is available for the desired type, as is the case
+with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
 .TP
 .IR \fB\-V ", " \fB\-\-virtualsize " " VirtualSize [ bBsSkKmMgGtTpPeE ]
 Create a sparse device of the given size (in MB by default) using a snapshot


