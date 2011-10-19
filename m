From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:49:14 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in
Message-ID: <20111019164914.5261.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:49:14

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in 

Log message:
	Improve lvcreate man page
	
	Split syntax for thin-pool since it cannot be fully matched with snapshot.
	So to avoid more confusion - take thin support into separate line.
	
	Though still significant updates are needed for thin provisioning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2163&r2=1.2164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2011/10/19 09:01:03	1.2163
+++ LVM2/WHATS_NEW	2011/10/19 16:49:13	1.2164
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Improve man page style for lvcreate.
   Avoid recursive calls to dmeventd in its LVM plugins.
   Log dev name now returned to kernel for registering during cmirror CTR.
   Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
--- LVM2/man/lvcreate.8.in	2011/09/06 00:26:43	1.22
+++ LVM2/man/lvcreate.8.in	2011/10/19 16:49:14	1.23
@@ -3,52 +3,108 @@
 lvcreate \- create a logical volume in an existing volume group
 .SH SYNOPSIS
 .B lvcreate
-[\-\-addtag Tag]
-[\-\-alloc AllocationPolicy]
-[\-a|\-\-available y|n|ey|en|ly|ln]
-[\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
-[\-h|\-?|\-\-help] [\-\-noudevsync]
-[\-\-ignoremonitoring]
-[\-\-monitor {y|n}]
-[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
- \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
-[\-M|\-\-persistent y|n] [\-\-minor minor]
-[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog]
-[\-R|\-\-regionsize MirrorLogRegionSize]]
-[\-n|\-\-name LogicalVolumeName]
-[\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
-[\-t|\-\-test]
-[\-\-type SegmentType]
-[\-v|\-\-verbose] [\-Z|\-\-zero y|n]
-VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-a | \-\-available
+.RI { y | n | ey | en | ly | ln }]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-C | \-\-contiguous
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-\-ignoremonitoring ]
+.RB [ \-\-monitor
+.RI { y | n }]
+.RB [ \-i | \-\-stripes
+.IR Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB { \-l | \-\-extents
+.IR LogicalExtentsNumber [ % { VG | PVS | FREE }]
+|
+.BR \-L | \-\-size
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-M | \-\-persistent
+.RI { y | n }]
+.RB [ \-\-minor
+.IR minor ]
+.RB [ \-m | \-\-mirrors
+.IR Mirrors
+.RB [ \-\-nosync ]
+.RB [ \-\-mirrorlog
+.RI { disk | core | mirrored }
+|
+.BR \-\-corelog ]
+.RB [ \-R | \-\-regionsize
+.IR MirrorLogRegionSize ]]
+.RB [ \-n | \-\-name
+.IR LogicalVolumeName ]
+.RB [ \-p | \-\-permission
+.RI { r | rw }]
+.RB [ \-r | \-\-readahead
+.RI { ReadAheadSectors | auto | none }]
+.RB [ \-t | \-\-test ]
+.RB [ \-\-type
+.IR SegmentType ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.IR VolumeGroupName
+.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .br
 
 .br
 .B lvcreate
-{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |
- \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
-[\-c|\-\-chunksize ChunkSize]
-[\-\-noudevsync]
-[\-\-ignoremonitoring]
-[\-\-monitor {y|n}]
-[--thinpool ThinPoolLogicalVolumeName]
-[\-n|\-\-name SnapshotLogicalVolumeName]
-{{\-s|\-\-snapshot}
-OriginalLogicalVolumePath | 
-[\-s|\-\-snapshot]
-VolumeGroupName \-V|\-\-virtualsize VirtualSize |
--T VolumeGroupName[/ThinPoolLogicalVolumeName] \-V|\-\-virtualsize VirtualSize}
+.RB { \-l | \-\-extents
+.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
+|
+.BR \-L | \-\-size
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-\-noudevsync ]
+.RB [ \-\-ignoremonitoring ]
+.RB [ \-\-monitor " {" \fIy | \fIn }]
+.RB [ \-n | \-\-name
+.IR SnapshotLogicalVolumeName ]
+.BR \-s | \-\-snapshot
+.RI [ OriginalLogicalVolumePath
+|
+.IR VolumeGroupName
+.BR \-V | \-\-virtualsize
+.IR VirtualSize ]
+.br
+
+.B lvcreate
+.RB [ \-l | \-\-extents
+.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
+|
+.BR \-L | \-\-size
+.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-V | \-\-virtualsize
+.IR VirtualSize ]
+.RB [ \-n | \-\-name
+.IR ThinLogicalVolumeName ]
+.RB [ \-\-thinpool
+.IR ThinPoolLogicalVolumeName ]
+.B \-T
+.IR VolumeGroupName [/ ThinPoolLogicalVolumeName ]
+.br
+
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
-.B vgcreate(8), vgchange(8)
+.BR vgcreate "(8), " vgchange (8)
 ) by allocating logical extents from the free physical extent pool
 of that volume group.  If there are not enough free physical extents then
 the volume group can be extended ( see
-.B vgextend(8)
+.BR vgextend (8)
 ) with other physical volumes or by reducing existing logical volumes
 of this volume group in size ( see
-.B lvreduce(8)
+.BR lvreduce (8)
 ). If you specify one or more PhysicalVolumes, allocation of physical
 extents will be restricted to these volumes.
 .br
@@ -56,66 +112,68 @@
 The second form supports the creation of snapshot logical volumes which 
 keep the contents of the original logical volume for backup purposes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See
+.BR lvm (8)
+for common options.
 .TP
-.I \-a, \-\-available y|n|ey|en|ly|ln
+.IR \fB\-a ", " \fB\-\-available " {" y | n | ey | en | ly | ln }
 Controls the availability of the Logical Volumes for immediate use after 
 the command finishes running.
-By default, new Logical Volumes are activated automatically (-ay).
-If it is possible technically, -an will leave the new Logical Volume inactive.
+By default, new Logical Volumes are activated automatically (\fB-a\fIy\fR).
+If it is possible technically, \fB-a\fIn\fR will leave the new Logical Volume inactive.
 But for example, snapshots can only be created
-in the active state so -an cannot be used with --snapshot.
+in the active state so \fB-a\fIn\fR cannot be used with --snapshot.
 Normally the --zero n argument has to be supplied too because zeroing (the
 default behaviour) also requires activation.
-If clustered locking is enabled, -aey will activate exclusively
-on one node and -aly will activate only on the local node.
+If clustered locking is enabled, \fB-a\fIey\fR will activate exclusively
+on one node and \fB-a\fIly\fR will activate only on the local node.
 .TP
-.I \-c, \-\-chunksize ChunkSize
+.BR \-c ", " \-\-chunksize " " \fIChunkSize
 Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
 .TP
-.I \-C, \-\-contiguous y|n
+.BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
 .TP
-.I \-i, \-\-stripes Stripes
+.BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
 the logical volume.
 .TP
-.I \-I, \-\-stripesize StripeSize
+.BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
 .br
 StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
-.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE|ORIGIN}]
+.IR \fB\-l ", " \fB\-\-extents " " LogicalExtentsNumber [ % { VG | PVS | FREE | ORIGIN }]
 Gives the number of logical extents to allocate for the new
 logical volume.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG, as a percentage of the
-remaining free space in the Volume Group with the suffix %FREE, as a
+in the Volume Group with the suffix \fI%VG\fR, as a percentage of the
+remaining free space in the Volume Group with the suffix \fI%FREE\fR, as a
 percentage of the remaining free space for the specified
-PhysicalVolume(s) with the suffix %PVS, or (for a snapshot) as a
+PhysicalVolume(s) with the suffix \fI%PVS\fR, or (for a snapshot) as a
 percentage of the total space in the Origin Logical Volume with the
-suffix %ORIGIN.
+suffix \fI%ORIGIN\fR.
 .TP
-.I \-L, \-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]
+.IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Gives the size to allocate for the new logical volume.
-A size suffix of K for kilobytes, M for megabytes,
-G for gigabytes, T for terabytes, P for petabytes
-or E for exabytes is optional.
+A size suffix of \fIK\fR for kilobytes, \fIM\fR for megabytes,
+\fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
+or \fIE\fR for exabytes is optional.
 .br
 Default unit is megabytes.
 .TP
-.I \-\-minor minor
+.B \-\-minor \fIminor
 Set the minor number.
 .TP
-.I \-M, \-\-persistent y|n
+.IR \fB\-M ", " \fB\-\-persistent " {" y | n }
 Set to y to make the minor number specified persistent.
 .TP
-.I \-m, \-\-mirrors Mirrors
+.BR \-m ", " \-\-mirrors " " \fIMirrors
 Creates a mirrored logical volume with Mirrors copies.  For example,
 specifying "-m 1" would result in a mirror with two-sides; that is, a
 linear volume plus one copy.
@@ -137,20 +195,20 @@
 The optional argument --corelog is equivalent to --mirrorlog core.
 
 .TP
-.I \-n, \-\-name LogicalVolumeName
+.BR \-n ", " \-\-name " " \fILogicalVolumeName
 The name for the new logical volume.
 .br
 Without this option a default names of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-\-monitor y|n
+.BR \-\-monitor " {" \fIy | \fIn }
 Start or avoid monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed. 
 If a device used by a monitored mirror reports an I/O error,
@@ -158,16 +216,16 @@
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
-.I \-\-ignoremonitoring
+.B \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless \-\-monitor
 is specified.
 .TP
-.I \-p, \-\-permission r|rw
+.BR \-p ", " \-\-permission " {" \fIr | \fIrw }
 Set access permissions to read only or read and write.
 .br
 Default is read and write.
 .TP
-.I \-r, \-\-readahead ReadAheadSectors|auto|none
+.IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
 be a value between 2 and 120.
@@ -175,11 +233,11 @@
 a suitable value automatically.
 "None" is equivalent to specifying zero.
 .TP
-.I \-R, \-\-regionsize MirrorLogRegionSize
+.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log 
 uses this granularity to track which regions are in sync.
 .TP
-.I \-s, \-\-snapshot
+.BR \-s ", " \-\-snapshot
 Create a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
@@ -187,11 +245,11 @@
 backups and online recovery of removed/overwritten data/files. The snapshot
 does not need the same amount of storage the origin has. In a typical scenario,
 15-20% might be enough. In case the snapshot runs out of storage, use
-.B lvextend(8)
+.BR lvextend (8)
 to grow it. Shrinking a snapshot is supported by
-.B lvreduce(8)
+.BR lvreduce (8)
 as well. Run
-.B lvdisplay(8)
+.BR lvdisplay (8)
 on the snapshot in order to check how much data is allocated to it.
 Note that a small amount of the space you allocate to the snapshot is
 used to track the locations of the chunks of data, so you should
@@ -199,7 +257,7 @@
 rate at which the snapshot data is growing so you can avoid running out
 of space.
 .TP
-.I \-\-type SegmentType
+.B \-\-type \fISegmentType
 Create a logical volume that uses the specified segment type
 (e.g. "raid5", "mirror", "snapshot").  Many segment types have a
 commandline switch alias that will enable their use (-s is an alias for
@@ -207,7 +265,7 @@
 commandline switch alias is available for the desired type, as is the case
 with "error", "zero", "raid4", "raid5", or "raid6".
 .TP
-.I -V, \-\-virtualsize VirtualSize
+.BR \-V ", " \-\-virtualsize " " \fIVirtualSize
 Create a sparse device of the given size (in MB by default) using a snapshot.  
 Anything written to the device will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
@@ -215,7 +273,7 @@
 requested size using the zero target.  A suffix of _vorigin is used for
 this device.
 .TP
-.I \-Z, \-\-zero y|n
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first KB of data in the new logical volume.
 .br
 Default is yes.


