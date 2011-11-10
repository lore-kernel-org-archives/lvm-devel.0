From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:41:39 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111110124139.7123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:41:39

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin lvcreate manpage
	
	Merge thin creation into standard 1st. lvcreate.
	Update snapshot for thin support.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/man/lvcreate.8.in	2011/11/08 12:12:31	1.32
+++ LVM2/man/lvcreate.8.in	2011/11/10 12:41:39	1.33
@@ -23,11 +23,14 @@
 .IR Stripes
 .RB [ \-I | \-\-stripesize
 .IR StripeSize ]]
-.RB { \-l | \-\-extents
+.RB {[ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { VG | PVS | FREE }]
 |
 .BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
+|
+.BR \-V | \-\-virtualsize
+.IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-M | \-\-persistent
 .RI { y | n }]
 .RB [ \-\-minor
@@ -48,21 +51,29 @@
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-t | \-\-test ]
+.RB [ \-T | \-\-thin
+.RI [ ThinPoolLogicalVolume { Name | Path }]
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-\-poolmetadatasize
+.IR MetadataSize [ bBsSkKmMgG ]]]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
-.IR VolumeGroup { Name | Path }
+.IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
 .RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .br
 
 .B lvcreate
-.RB { \-l | \-\-extents
+.RB [ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
 |
 .BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
 .RB [ \-\-noudevsync ]
@@ -78,30 +89,6 @@
 .IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
 .br
 
-.B lvcreate
-.BR \-T | \-\-thin
-.IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
-.RB [{ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
-|
-.BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-i | \-\-stripes
-.IR Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-\-poolmetadatasize
-.IR MetadataSize [ bBsSkKmMgG ]]]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }]
-.RB [ \-V | \-\-virtualsize
-.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
-.RB [ \-n | \-\-name
-.IR ThinLogicalVolume { Name | Path }]
-.br
-
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .BR vgcreate "(8), " vgchange (8)


