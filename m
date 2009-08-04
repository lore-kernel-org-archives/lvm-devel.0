From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Aug 2009 08:09:53 -0000
Subject: LVM2/man lvconvert.8.in lvcreate.8.in lvextend ...
Message-ID: <20090804080953.24615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-04 08:09:52

Modified files:
	man            : lvconvert.8.in lvcreate.8.in lvextend.8.in 
	                 lvreduce.8.in lvremove.8.in lvrename.8.in 
	                 lvresize.8.in pvmove.8.in vgchange.8.in 
	                 vgremove.8.in 

Log message:
	'--noudevsync' -- update relevant man pages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvrename.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/lvconvert.8.in	2009/08/02 21:01:52	1.6
+++ LVM2/man/lvconvert.8.in	2009/08/04 08:09:52	1.7
@@ -7,6 +7,7 @@
 [\-A|\-\-alloc AllocationPolicy]
 [\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
+[\-\-noudevsync]
 [\-v|\-\-verbose] [\-y|\-\-yes]
 [\-\-version]
 LogicalVolume[Path] [PhysicalVolume[Path]...]
@@ -16,6 +17,7 @@
 .B lvconvert
 \-s|\-\-snapshot [\-c|\-\-chunksize ChunkSize]
 [\-h|\-?|\-\-help]
+[\-\-noudevsync]
 [\-v|\-\-verbose]
 [\-Z|\-\-zero y|n]
 [\-\-version]
@@ -67,6 +69,13 @@
 Report progress as a percentage at regular intervals.
 .br
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-\-repair
 Repair a mirror after suffering a disk failure. The mirror will be brought back
 into a consistent state.  By default, the original number of mirrors will be
--- LVM2/man/lvcreate.8.in	2009/07/06 19:13:26	1.8
+++ LVM2/man/lvcreate.8.in	2009/08/04 08:09:52	1.9
@@ -6,7 +6,7 @@
 [\-\-addtag Tag]
 [\-\-alloc AllocationPolicy]
 [\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
-[\-h|\-?|\-\-help]
+[\-h|\-?|\-\-help] [\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
@@ -25,6 +25,7 @@
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
+[\-\-noudevsync]
 \-n|\-\-name SnapshotLogicalVolumeName
 {{\-s|\-\-snapshot}
 OriginalLogicalVolumePath | 
@@ -117,6 +118,13 @@
 Without this option a default names of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-p, \-\-permission r|rw
 Set access permissions to read only or read and write.
 .br
--- LVM2/man/lvextend.8.in	2009/07/06 19:13:26	1.3
+++ LVM2/man/lvextend.8.in	2009/08/04 08:09:52	1.4
@@ -5,6 +5,7 @@
 .B lvextend
 [\-\-alloc AllocationPolicy]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
@@ -21,6 +22,13 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
 Extend or set the logical volume size in units of logical extents.
 With the + sign the value is added to the actual size
--- LVM2/man/lvreduce.8.in	2009/07/07 19:28:57	1.4
+++ LVM2/man/lvreduce.8.in	2009/08/04 08:09:52	1.5
@@ -5,6 +5,7 @@
 .B lvreduce
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help]
+[\-\-noudevsync]
 {\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
 \-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
@@ -36,6 +37,13 @@
 .I \-f, \-\-force
 Force size reduction without any question.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}]
 Reduce or set the logical volume size in units of logical extents.
 With the - sign the value will be subtracted from
--- LVM2/man/lvremove.8.in	2008/11/17 18:20:13	1.3
+++ LVM2/man/lvremove.8.in	2009/08/04 08:09:52	1.4
@@ -5,6 +5,7 @@
 .B lvremove
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help] 
+[\-\-noudevsync]
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
 .SH DESCRIPTION
@@ -22,6 +23,13 @@
 .TP
 .I \-f, \-\-force
 Remove active logical volumes without confirmation.
+.TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
 .SH EXAMPLES
 Remove the active logical volume lvol1 in volume group vg00 
 without asking for confirmation:
--- LVM2/man/lvrename.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvrename.8.in	2009/08/04 08:09:52	1.2
@@ -7,6 +7,7 @@
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-force ]
 .RB [ \-h | \-\-help ]
+.RB [ \-\-noudevsync ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -22,6 +23,13 @@
 .IR NewLogicalVolume { Name | Path }.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+.TP
+.BR \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
 .SH EXAMPLE
 To rename
 .B lvold
--- LVM2/man/lvresize.8.in	2009/07/06 19:13:26	1.4
+++ LVM2/man/lvresize.8.in	2009/08/04 08:09:52	1.5
@@ -5,6 +5,7 @@
 .B lvresize
 [\-\-alloc AllocationPolicy]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
@@ -25,6 +26,13 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
 Change or set the logical volume size in units of logical extents.
 With the + or - sign the value is added to or subtracted from the actual size
--- LVM2/man/pvmove.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/pvmove.8.in	2009/08/04 08:09:52	1.3
@@ -6,8 +6,8 @@
 [\-\-abort]
 [\-\-alloc AllocationPolicy]
 [\-b|\-\-background]
-[\-d|\-\-debug] [\-h|\-\-help] [\-i|\-\-interval Seconds] [\-v|\-\-verbose]
-[\-n|\-\-name LogicalVolume] 
+[\-d|\-\-debug] [\-h|\-\-help] [\-i|\-\-interval Seconds]
+[\-\-noudevsync] [\-v|\-\-verbose] [\-n|\-\-name LogicalVolume]
 [SourcePhysicalVolume[:PE[-PE]...] [DestinationPhysicalVolume[:PE[-PE]...]...]]
 .SH DESCRIPTION
 .B pvmove
@@ -73,6 +73,13 @@
 .I \-\-abort
 Abort any moves in progress.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-b, \-\-background
 Run the daemon in the background.
 .TP
--- LVM2/man/vgchange.8.in	2009/07/06 19:13:26	1.3
+++ LVM2/man/vgchange.8.in	2009/08/04 08:09:52	1.4
@@ -18,6 +18,7 @@
 .RB [ \-h | \-\-help]
 .RB [ \-\-ignorelockingfailure]
 .RB [ \-\-ignoremonitoring]
+.RB [ \-\-noudevsync ]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
@@ -86,6 +87,13 @@
 set in 
 .BR lvm.conf (5).
 .TP
+.BR \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .BR \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless 
 .BR \-\-monitor
--- LVM2/man/vgremove.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgremove.8.in	2009/08/04 08:09:52	1.3
@@ -4,7 +4,7 @@
 .SH SYNOPSIS
 .B vgremove
 [\-d|\-\-debug] [\-f|\-\-force] [\-h|\-?|\-\-help]
-[\-t|\-\-test] [\-v|\-\-verbose]
+[\-\-noudevsync] [\-t|\-\-test] [\-v|\-\-verbose]
 VolumeGroupName [VolumeGroupName...]
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.
@@ -21,6 +21,13 @@
 .BR \-f ", " \-\-force
 Force the removal of any logical volumes on the volume group
 without confirmation.
+.TP
+.BR \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvremove (8),


