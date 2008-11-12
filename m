From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Nov 2008 15:01:40 -0000
Subject: LVM2 ./WHATS_NEW man/lvchange.8.in man/lvconve ...
Message-ID: <20081112150140.18645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-11-12 15:01:36

Modified files:
	.              : WHATS_NEW 
	man            : lvchange.8.in lvconvert.8.in lvcreate.8.in 
	                 lvdisplay.8.in lvextend.8.in lvmdiskscan.8.in 
	                 lvreduce.8.in lvremove.8.in lvresize.8.in 
	                 lvs.8.in pvchange.8.in pvcreate.8.in 
	                 pvdisplay.8.in pvmove.8.in pvs.8.in vgck.8.in 
	                 vgexport.8.in vgextend.8.in vgimport.8.in 
	                 vgmerge.8.in vgmknodes.8.in vgreduce.8.in 
	                 vgremove.8.in vgrename.8.in vgs.8.in 
	                 vgscan.8.in 

Log message:
	Make man pages consistent with either-or options (use "|" everywhere).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.994&r2=1.995
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdiskscan.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvdisplay.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgck.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgexport.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimport.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmerge.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmknodes.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgreduce.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgscan.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2008/11/10 21:26:06	1.994
+++ LVM2/WHATS_NEW	2008/11/12 15:01:35	1.995
@@ -1,5 +1,6 @@
 Version 2.02.43 - 10th November 2008
 ====================================
+  Make man pages consistent with either-or options (use "|" everywhere).
   Merge device-mapper into the lvm2 tree.
   Correct prototype for --permission on lvchange and lvcreate man pages.
   Exit with non-zero status from vgdisplay if couldn't show any requested VG.
--- LVM2/man/lvchange.8.in	2008/11/07 19:23:52	1.2
+++ LVM2/man/lvchange.8.in	2008/11/12 15:01:36	1.3
@@ -4,27 +4,27 @@
 .SH SYNOPSIS
 .B lvchange
 [\-\-addtag Tag]
-[\-A/\-\-autobackup y/n] [\-a/\-\-available y/n/ey/en/ly/ln]
+[\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
 [\-\-alloc AllocationPolicy]
-[\-C/\-\-contiguous y/n] [\-d/\-\-debug] [\-\-deltag Tag]
+[\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
 [\-\-resync]
-[\-h/\-?/\-\-help]
+[\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
 [\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
-[\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-P/\-\-partial]
-[\-p/\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
+[\-M|\-\-persistent y|n] [\-\-minor minor]
+[\-P|\-\-partial]
+[\-p|\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-\-refresh]
-[\-t/\-\-test]
-[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+[\-t|\-\-test]
+[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
 .SH DESCRIPTION
 lvchange allows you to change the attributes of a logical volume
 including making them known to the kernel ready for use.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.I \-a, \-\-available y/n/ey/en/ly/ln
+.I \-a, \-\-available y|n|ey|en|ly|ln
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (-ay) or deactivate (-an) the 
@@ -36,7 +36,7 @@
 Logical volumes with single-host snapshots are always activated 
 exclusively because they can only be used on one node at once.
 .TP
-.I \-C, \-\-contiguous y/n
+.I \-C, \-\-contiguous y|n
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
@@ -53,7 +53,7 @@
 .I \-\-minor minor
 Set the minor number.
 .TP
-.I \-\-monitor y/n
+.I \-\-monitor y|n
 Controls whether or not a mirrored logical volume is monitored by
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
@@ -66,7 +66,7 @@
 is specified.
 Do not use this if dmeventd is already monitoring a device.
 .TP
-.I \-M, \-\-persistent y/n
+.I \-M, \-\-persistent y|n
 Set to y to make the minor number specified persistent.
 .TP
 .I \-p, \-\-permission r|rw
--- LVM2/man/lvconvert.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvconvert.8.in	2008/11/12 15:01:36	1.2
@@ -3,11 +3,11 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m/\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
-[\-A/\-\-alloc AllocationPolicy]
-[\-b/\-\-background] [\-i/\-\-interval Seconds]
-[\-h/\-?/\-\-help]
-[\-v/\-\-verbose]
+\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
+[\-A|\-\-alloc AllocationPolicy]
+[\-b|\-\-background] [\-i|\-\-interval Seconds]
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
 [\-\-version]
 .br
 LogicalVolume[Path] [PhysicalVolume[Path]...]
@@ -15,10 +15,10 @@
 
 .br
 .B lvconvert
-\-s/\-\-snapshot [\-c/\-\-chunksize ChunkSize]
-[\-h/\-?/\-\-help]
-[\-v/\-\-verbose]
-[\-Z/\-\-zero y/n]
+\-s|\-\-snapshot [\-c|\-\-chunksize ChunkSize]
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
+[\-Z|\-\-zero y|n]
 [\-\-version]
 .br
 OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
@@ -68,7 +68,7 @@
 .I \-c, \-\-chunksize ChunkSize
 Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
 .TP
-.I \-Z, \-\-zero y/n
+.I \-Z, \-\-zero y|n
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 .br
--- LVM2/man/lvcreate.8.in	2008/11/07 19:23:52	1.2
+++ LVM2/man/lvcreate.8.in	2008/11/12 15:01:36	1.3
@@ -5,27 +5,27 @@
 .B lvcreate
 [\-\-addtag Tag]
 [\-\-alloc AllocationPolicy]
-[\-A/\-\-autobackup y/n] [\-C/\-\-contiguous y/n] [\-d/\-\-debug]
-[\-h/\-?/\-\-help]
-[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
- \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
-[\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
-[\-R/\-\-regionsize MirrorLogRegionSize]]
-[\-n/\-\-name LogicalVolumeName]
-[\-p/\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
-[\-t/\-\-test]
-[\-v/\-\-verbose] [\-Z/\-\-zero y/n]
+[\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
+[\-h|\-?|\-\-help]
+[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
+{\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
+ \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+[\-M|\-\-persistent y|n] [\-\-minor minor]
+[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
+[\-R|\-\-regionsize MirrorLogRegionSize]]
+[\-n|\-\-name LogicalVolumeName]
+[\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
+[\-t|\-\-test]
+[\-v|\-\-verbose] [\-Z|\-\-zero y|n]
 VolumeGroupName [PhysicalVolumePath...]
 .br
 
 .br
 .B lvcreate
-{\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
- \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
-[\-c/\-\-chunksize ChunkSize]
-\-s/\-\-snapshot \-n/\-\-name SnapshotLogicalVolumeName OriginalLogicalVolumePath
+{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
+ \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+[\-c|\-\-chunksize ChunkSize]
+\-s|\-\-snapshot \-n|\-\-name SnapshotLogicalVolumeName OriginalLogicalVolumePath
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
@@ -46,7 +46,7 @@
 .I \-c, \-\-chunksize ChunkSize
 Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
 .TP
-.I \-C, \-\-contiguous y/n
+.I \-C, \-\-contiguous y|n
 Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
@@ -83,7 +83,7 @@
 .I \-\-minor minor
 Set the minor number.
 .TP
-.I \-M, \-\-persistent y/n
+.I \-M, \-\-persistent y|n
 Set to y to make the minor number specified persistent.
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -145,7 +145,7 @@
 .B lvdisplay(8)
 on the snapshot in order to check how much data is allocated to it.
 .TP
-.I \-Z, \-\-zero y/n
+.I \-Z, \-\-zero y|n
 Controls zeroing of the first KB of data in the new logical volume.
 .br
 Default is yes.
--- LVM2/man/lvdisplay.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvdisplay.8.in	2008/11/12 15:01:36	1.2
@@ -3,10 +3,10 @@
 lvdisplay \- display attributes of a logical volume
 .SH SYNOPSIS
 .B lvdisplay
-[\-c/\-\-colon] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
-[\-\-maps] [\-P/\-\-partial]
-[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+[\-\-maps] [\-P|\-\-partial]
+[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
--- LVM2/man/lvextend.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvextend.8.in	2008/11/12 15:01:36	1.2
@@ -4,12 +4,12 @@
 .SH SYNOPSIS
 .B lvextend
 [\-\-alloc AllocationPolicy]
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
-[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
-[\-t/\-\-test]
-[\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+[\-t|\-\-test]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
 lvextend allows you to extend the size of a logical volume.
 Extension of snapshot logical volumes (see
--- LVM2/man/lvmdiskscan.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvmdiskscan.8.in	2008/11/12 15:01:36	1.2
@@ -3,9 +3,9 @@
 lvmdiskscan \- scan for all devices visible to LVM2
 .SH SYNOPSIS
 .B lvmdiskscan
-[\-d/\-\-debug] [\-h/\-?/\-\-help] 
-[\-l/\-\-lvmpartition]
-[\-v/\-\-verbose]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-l|\-\-lvmpartition]
+[\-v|\-\-verbose]
 .SH DESCRIPTION
 \fBlvmdiskscan\fP scans all SCSI, (E)IDE disks, multiple devices and a bunch
 of other block devices in the system looking for LVM physical volumes.
--- LVM2/man/lvreduce.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvreduce.8.in	2008/11/12 15:01:36	1.2
@@ -3,12 +3,12 @@
 lvreduce \- reduce the size of a logical volume
 .SH SYNOPSIS
 .B lvreduce
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-f/\-\-force]
-[\-h/\-?/\-\-help]
-{\-l/\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
-\-L/\-\-size [\-]LogicalVolumeSize[kKmMgGtT]}
-[\-t/\-\-test]
-[\-v/\-\-verbose] LogicalVolume[Path]
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
+[\-h|\-?|\-\-help]
+{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
+\-L|\-\-size [\-]LogicalVolumeSize[kKmMgGtT]}
+[\-t|\-\-test]
+[\-v|\-\-verbose] LogicalVolume[Path]
 .SH DESCRIPTION
 lvreduce allows you to reduce the size of a logical volume.
 Be careful when reducing a logical volume's size, because data in the
--- LVM2/man/lvremove.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvremove.8.in	2008/11/12 15:01:36	1.2
@@ -3,10 +3,10 @@
 lvremove \- remove a logical volume
 .SH SYNOPSIS
 .B lvremove
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-f/\-\-force]
-[\-h/\-?/\-\-help] 
-[\-t/\-\-test]
-[\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
+[\-h|\-?|\-\-help] 
+[\-t|\-\-test]
+[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
 .SH DESCRIPTION
 \fBlvremove\fP removes one or more logical volumes.
 Confirmation will be requested before deactivating any active logical
--- LVM2/man/lvresize.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvresize.8.in	2008/11/12 15:01:36	1.2
@@ -4,12 +4,12 @@
 .SH SYNOPSIS
 .B lvresize
 [\-\-alloc AllocationPolicy]
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
-[\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
-[\-t/\-\-test]
-[\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+[\-t|\-\-test]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
 lvresize allows you to resize a logical volume.
 Be careful when reducing a logical volume's size, because data in the reduced
--- LVM2/man/lvs.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvs.8.in	2008/11/12 15:01:36	1.2
@@ -3,14 +3,14 @@
 lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
-[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
-[\-o/\-\-options [+]Field[,Field]]
-[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
-[\-P/\-\-partial] [\-\-segments]
+[\-o|\-\-options [+]Field[,Field]]
+[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-P|\-\-partial] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
-[\-v/\-\-verbose] 
+[\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
 .SH DESCRIPTION
 lvs produces formatted output about logical volumes.
--- LVM2/man/pvchange.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvchange.8.in	2008/11/12 15:01:36	1.2
@@ -4,12 +4,12 @@
 .SH SYNOPSIS
 .B pvchange
 [\-\-addtag Tag]
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] 
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
 [\-\-deltag Tag]
-[\-h/\-?/\-\-help]
-[\-t/\-\-test]
-[\-v/\-\-verbose] [\-a/\-\-all] [\-x/\-\-allocatable y/n]
-[\-u/\-\-uuid] [PhysicalVolumePath...]
+[\-h|\-?|\-\-help]
+[\-t|\-\-test]
+[\-v|\-\-verbose] [\-a|\-\-all] [\-x|\-\-allocatable y|n]
+[\-u|\-\-uuid] [PhysicalVolumePath...]
 .SH DESCRIPTION
 pvchange allows you to change the allocation permissions of one or
 more physical volumes.
@@ -23,7 +23,7 @@
 .I \-u, \-\-uuid
 Generate new random UUID for specified physical volumes.
 .TP
-.I \-x, \-\-allocatable y/n
+.I \-x, \-\-allocatable y|n
 Enable or disable allocation of physical extents on this physical volume.
 .SH Example
 "pvchange -x n /dev/sdk1" disallows the allocation of physical extents
--- LVM2/man/pvcreate.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvcreate.8.in	2008/11/12 15:01:36	1.2
@@ -17,7 +17,7 @@
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
 .RB [ \-\-version ]
-.RB [ \-Z | \-\-zero y/n ]
+.RB [ \-Z | \-\-zero y|n ]
 .IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
 .B pvcreate
@@ -62,7 +62,7 @@
 .BR \-y ", " \-\-yes
 Answer yes to all questions.
 .TP
-.BR \-Z ", " \-\-zero " y/n"
+.BR \-Z ", " \-\-zero " y|n"
 Whether or not the first 4 sectors (2048 bytes) of the device should be 
 wiped.
 If this option is not given, the 
--- LVM2/man/pvdisplay.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvdisplay.8.in	2008/11/12 15:01:36	1.2
@@ -3,8 +3,8 @@
 pvdisplay \- display attributes of a physical volume
 .SH SYNOPSIS
 .B pvdisplay
-[\-c/\-\-colon] [\-d/\-\-debug] [\-h/\-?/\-\-help] [\-s/\-\-short]
-[\-v[v]/\-\-verbose [\-\-verbose]]
+[\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help] [\-s|\-\-short]
+[\-v[v]|\-\-verbose [\-\-verbose]]
 PhysicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
 pvdisplay allows you to see the attributes of one or more physical volumes
--- LVM2/man/pvmove.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvmove.8.in	2008/11/12 15:01:36	1.2
@@ -5,9 +5,9 @@
 .B pvmove
 [\-\-abort]
 [\-\-alloc AllocationPolicy]
-[\-b/\-\-background]
-[\-d/\-\-debug] [\-h/\-\-help] [\-i/\-\-interval Seconds] [\-v/\-\-verbose]
-[\-n/\-\-name LogicalVolume] 
+[\-b|\-\-background]
+[\-d|\-\-debug] [\-h|\-\-help] [\-i|\-\-interval Seconds] [\-v|\-\-verbose]
+[\-n|\-\-name LogicalVolume] 
 [SourcePhysicalVolume[:PE[-PE]...] [DestinationPhysicalVolume[:PE[-PE]...]...]]
 .SH DESCRIPTION
 .B pvmove
--- LVM2/man/pvs.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvs.8.in	2008/11/12 15:01:36	1.2
@@ -3,13 +3,13 @@
 pvs \- report information about physical volumes
 .SH SYNOPSIS
 .B pvs
-[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
-[\-o/\-\-options [+]Field[,Field]]
-[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-o|\-\-options [+]Field[,Field]]
+[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
-[\-v/\-\-verbose] 
+[\-v|\-\-verbose] 
 [\-\-version] [PhysicalVolume [PhysicalVolume...]]
 .SH DESCRIPTION
 pvs produces formatted output about physical volumes.
--- LVM2/man/vgck.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgck.8.in	2008/11/12 15:01:36	1.2
@@ -3,7 +3,7 @@
 vgck \- check volume group metadata
 .SH SYNOPSIS
 .B vgck
-[\-d/\-\-debug] [\-h/\-?/\-\-help] [\-v/\-\-verbose] [VolumeGroupName...]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] [\-v|\-\-verbose] [VolumeGroupName...]
 .SH DESCRIPTION
 vgck checks LVM metadata for each named volume group for consistency.
 .SH OPTIONS
--- LVM2/man/vgexport.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgexport.8.in	2008/11/12 15:01:36	1.2
@@ -3,9 +3,9 @@
 vgexport \- make volume groups unknown to the system
 .SH SYNOPSIS
 .B vgexport
-[\-a/\-\-all]
-[\-d/\-\-debug] [\-h/\-?/\-\-help] 
-[\-v/\-\-verbose]
+[\-a|\-\-all]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-v|\-\-verbose]
 VolumeGroupName [VolumeGroupName...]
 .SH DESCRIPTION
 vgexport allows you to make the inactive 
--- LVM2/man/vgextend.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgextend.8.in	2008/11/12 15:01:36	1.2
@@ -3,9 +3,9 @@
 vgextend \- add physical volumes to a volume group
 .SH SYNOPSIS
 .B vgextend
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help] 
-[\-t/\-\-test]
-[\-v/\-\-verbose]
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-t|\-\-test]
+[\-v|\-\-verbose]
 VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 .SH DESCRIPTION
 vgextend allows you to add one or more initialized physical volumes ( see
--- LVM2/man/vgimport.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgimport.8.in	2008/11/12 15:01:36	1.2
@@ -3,9 +3,9 @@
 vgimport \- make exported volume groups known to the system
 .SH SYNOPSIS
 .B vgimport
-[\-a/\-\-all]
-[\-d/\-\-debug] [\-h/\-?/\-\-help] 
-[\-v/\-\-verbose]
+[\-a|\-\-all]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-v|\-\-verbose]
 VolumeGroupName [VolumeGroupName...]
 .SH DESCRIPTION
 .B vgimport
--- LVM2/man/vgmerge.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgmerge.8.in	2008/11/12 15:01:36	1.2
@@ -3,8 +3,8 @@
 vgmerge \- merge two volume groups
 .SH SYNOPSIS
 .B vgmerge
-[\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help] [\-l/\-\-list]
-[\-t/\-\-test] [\-v/\-\-verbose] DestinationVolumeGroupName
+[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] [\-l|\-\-list]
+[\-t|\-\-test] [\-v|\-\-verbose] DestinationVolumeGroupName
 SourceVolumeGroupName
 .SH DESCRIPTION
 vgmerge merges two existing volume groups. The inactive SourceVolumeGroupName
--- LVM2/man/vgmknodes.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgmknodes.8.in	2008/11/12 15:01:36	1.2
@@ -3,8 +3,8 @@
 vgmknodes \- recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
-[\-d/\-\-debug] [\-h/\-?/\-\-help] 
-[\-v/\-\-verbose]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-v|\-\-verbose]
 [[VolumeGroupName | LogicalVolumePath]...]
 .SH DESCRIPTION
 Checks the LVM2 special files in /dev that are needed for active 
--- LVM2/man/vgreduce.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgreduce.8.in	2008/11/12 15:01:36	1.2
@@ -3,10 +3,10 @@
 vgreduce \- reduce a volume group
 .SH SYNOPSIS
 .B vgreduce
-[\-a/\-\-all] [\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-a|\-\-all] [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-removemissing]
-[\-t/\-\-test]
-[\-v/\-\-verbose] VolumeGroupName
+[\-t|\-\-test]
+[\-v|\-\-verbose] VolumeGroupName
 [PhysicalVolumePath...]
 .SH DESCRIPTION
 vgreduce allows you to remove one or more unused physical volumes
--- LVM2/man/vgremove.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgremove.8.in	2008/11/12 15:01:36	1.2
@@ -3,8 +3,8 @@
 vgremove \- remove a volume group
 .SH SYNOPSIS
 .B vgremove
-[\-d/\-\-debug] [\-f/\-\-force] [\-h/\-?/\-\-help]
-[\-t/\-\-test] [\-v/\-\-verbose]
+[\-d|\-\-debug] [\-f|\-\-force] [\-h|\-?|\-\-help]
+[\-t|\-\-test] [\-v|\-\-verbose]
 VolumeGroupName [VolumeGroupName...]
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.
--- LVM2/man/vgrename.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgrename.8.in	2008/11/12 15:01:36	1.2
@@ -3,11 +3,11 @@
 vgrename \- rename a volume group
 .SH SYNOPSIS
 .B vgrename
-[\-A/\-\-autobackup y/n]
-[\-d/\-\-debug]
-[\-h/\-?/\-\-help]
-[\-t/\-\-test]
-[\-v/\-\-verbose]
+[\-A|\-\-autobackup y|n]
+[\-d|\-\-debug]
+[\-h|\-?|\-\-help]
+[\-t|\-\-test]
+[\-v|\-\-verbose]
 .IR OldVolumeGroup { Path | Name | UUID }
 .IR NewVolumeGroup { Path | Name }
 .SH DESCRIPTION
--- LVM2/man/vgs.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgs.8.in	2008/11/12 15:01:36	1.2
@@ -3,14 +3,14 @@
 vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
-[\-\-aligned] [\-d/\-\-debug] [\-h/\-?/\-\-help]
+[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
-[\-o/\-\-options [+]Field[,Field]]
-[\-O/\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
-[\-P/\-\-partial]
+[\-o|\-\-options [+]Field[,Field]]
+[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-P|\-\-partial]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
-[\-v/\-\-verbose] 
+[\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
 .SH DESCRIPTION
 vgs produces formatted output about volume groups.
--- LVM2/man/vgscan.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgscan.8.in	2008/11/12 15:01:36	1.2
@@ -3,11 +3,11 @@
 vgscan \- scan all disks for volume groups and rebuild caches
 .SH SYNOPSIS
 .B vgscan
-[\-d/\-\-debug] [\-h/\-?/\-\-help] 
+[\-d|\-\-debug] [\-h|\-?|\-\-help] 
 [\-\-ignorelockingfailure]
 [\-\-mknodes]
-[\-P/\-\-partial]
-[\-v/\-\-verbose]
+[\-P|\-\-partial]
+[\-v|\-\-verbose]
 .SH DESCRIPTION
 vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
 of other disk devices in the system looking for LVM physical volumes


