From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 10:50:40 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20120120105040.1201.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 10:50:40

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin extend lvcreate man page about snapshot support

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/man/lvcreate.8.in	2011/12/21 13:58:38	1.34
+++ LVM2/man/lvcreate.8.in	2012/01/20 10:50:39	1.35
@@ -81,9 +81,7 @@
 .RB [ \-n | \-\-name
 .IR SnapshotLogicalVolume { Name | Path }]
 .BR \-s | \-\-snapshot
-.RI { OriginalLogicalVolume { Name | Path }
-|
-.IR VolumeGroup { Name | Path }
+.RI {[ VolumeGroup { Name | Path }/] OriginalLogicalVolumeName
 .BR \-V | \-\-virtualsize
 .IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
 .br
@@ -241,16 +239,19 @@
 A mirror is divided into regions of this size (in MB), and the mirror log 
 uses this granularity to track which regions are in sync.
 .TP
-.IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path } 
-.RI "| " VolumeGroup { Name | Path }
+.IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path }
 
 Create a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
 while the origin can still be updated. They enable consistent
-backups and online recovery of removed/overwritten data/files. The snapshot
-does not need the same amount of storage the origin has. In a typical scenario,
-15-20% might be enough. In case the snapshot runs out of storage, use
+backups and online recovery of removed/overwritten data/files.
+Thin snapshot is created when the origin is a thin volume and
+the size is not specified. Thin snapshot shares same blocks within
+the thin pool volume.
+The snapshot with the specified size does not need the same amount of
+storage the origin has. In a typical scenario, 15-20% might be enough.
+In case the snapshot runs out of storage, use
 .BR lvextend (8)
 to grow it. Shrinking a snapshot is supported by
 .BR lvreduce (8)


