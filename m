From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:33:51 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111028203351.11196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:33:50

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin option documentation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/man/lvcreate.8.in	2011/10/25 13:24:23	1.26
+++ LVM2/man/lvcreate.8.in	2011/10/28 20:33:50	1.27
@@ -80,19 +80,26 @@
 .br
 
 .B lvcreate
+.RB [ \-i | \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
 .RB [ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
 |
 .BR \-L | \-\-size
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
 .RB [ \-V | \-\-virtualsize
 .IR VirtualSize ]
 .RB [ \-n | \-\-name
 .IR ThinLogicalVolumeName ]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolumeName ]
-.B \-T
-.IR VolumeGroupName [/ ThinPoolLogicalVolumeName ]
+.RB [ \-T | \-\-thin
+.IR VolumeGroupName [/ ThinPoolLogicalVolumeName
+|
+.B \-\-thinpool
+.IR ThinPoolLogicalVolumeName ]]
 .br
 
 .SH DESCRIPTION
@@ -269,11 +276,18 @@
 commandline switch alias is available for the desired type, as is the case
 with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
 .TP
+.BR \-T ", " \-\-thin " " \fIVolumeGroupName [/ \fIThinPoolLogicalVolumeName ]
+Defines the thin pool logical volume.
+.TP
+.BR \-\-thinpool " " \fIThinPoolLogicalVolumeName
+Specifies the thin pool logical volume.
+.TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize
-Create a sparse device of the given size (in MB by default) using a snapshot.  
+Create a sparse device of the given size (in MB by default) using a snapshot
+or thinly provisioned device when thin pool is specified.
 Anything written to the device will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
-It is implemented by creating a hidden virtual device of the
+Virtual snapshot is implemented by creating a hidden virtual device of the
 requested size using the zero target.  A suffix of _vorigin is used for
 this device.
 .TP


