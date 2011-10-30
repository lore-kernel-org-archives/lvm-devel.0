From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:08:22 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111030220822.7999.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:08:21

Modified files:
	man            : lvcreate.8.in 

Log message:
	More updates for lvcreate manpage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/man/lvcreate.8.in	2011/10/28 20:36:05	1.28
+++ LVM2/man/lvcreate.8.in	2011/10/30 22:08:21	1.29
@@ -42,7 +42,7 @@
 .RB [ \-R | \-\-regionsize
 .IR MirrorLogRegionSize ]]
 .RB [ \-n | \-\-name
-.IR LogicalVolumeName ]
+.IR LogicalVolumeName [ Path ]]
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
 .RB [ \-r | \-\-readahead
@@ -53,11 +53,10 @@
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
-.IR VolumeGroupName
+.IR VolumeGroupName [ Path ]
 .RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .br
 
-.br
 .B lvcreate
 .RB { \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
@@ -70,13 +69,13 @@
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-monitor " {" \fIy | \fIn }]
 .RB [ \-n | \-\-name
-.IR SnapshotLogicalVolumeName ]
+.IR SnapshotLogicalVolumeName [ Path ]]
 .BR \-s | \-\-snapshot
-.RI [ OriginalLogicalVolumePath
+.RI [ OriginalLogicalVolume [ Path ]
 |
-.IR VolumeGroupName
+.IR VolumeGroupName [ Path ]
 .BR \-V | \-\-virtualsize
-.IR VirtualSize ]
+.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
 .br
 
 .B lvcreate
@@ -282,7 +281,7 @@
 .BR \-\-thinpool " " \fIThinPoolLogicalVolumeName
 Specifies the thin pool logical volume.
 .TP
-.BR \-V ", " \-\-virtualsize " " \fIVirtualSize
+.IR \fB\-V ", " \fB\-\-virtualsize " " VirtualSize [ bBsSkKmMgGtTpPeE ]
 Create a sparse device of the given size (in MB by default) using a snapshot
 or thinly provisioned device when thin pool is specified.
 Anything written to the device will be returned when reading from it.


