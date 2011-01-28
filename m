From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:03:39 -0000
Subject: LVM2 ./WHATS_NEW man/pvcreate.8.in man/pvremov ...
Message-ID: <20110128160339.24249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:03:38

Modified files:
	.              : WHATS_NEW 
	man            : pvcreate.8.in pvremove.8.in pvresize.8.in 
	                 pvscan.8.in 

Log message:
	Updating man pages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1894&r2=1.1895
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvresize.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2011/01/28 10:14:08	1.1894
+++ LVM2/WHATS_NEW	2011/01/28 16:03:38	1.1895
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Updating man pages for pvcreate, pvremove, pvresize, pvscan.
   Avoid rebuilding of uuid validation table.
   Always use O_DIRECT when opening block devices to check for partitioning.
   Improve lvcreate "insufficient extents" errors to "insufficient free space".
--- LVM2/man/pvcreate.8.in	2010/08/12 04:09:00	1.9
+++ LVM2/man/pvcreate.8.in	2011/01/28 16:03:38	1.10
@@ -3,25 +3,20 @@
 pvcreate \- initialize a disk or partition for use by LVM
 .SH SYNOPSIS
 .B pvcreate
-.RB [ \-d | \-\-debug ]
 .RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
 .RB [ \-y | \-\-yes ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
-.RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-[pv]metadatacopies #copies ]
-.RB [ \-\-metadatasize size ]
-.RB [ \-\-metadataignore y|n ]
-.RB [ \-\-dataalignment alignment ]
-.RB [ \-\-dataalignmentoffset alignment_offset ]
-.RB [ \-\-restorefile file ]
+.RB [ \-M | \-\-metadatatype " " \fItype ]
+.RB [ \-\-[pv]metadatacopies " " \fI#copies ]
+.RB [ \-\-metadatasize " " \fIsize ]
+.RB [ \-\-metadataignore " {" \fIy | \fIn }]
+.RB [ \-\-dataalignment " " \fIalignment ]
+.RB [ \-\-dataalignmentoffset " " \fIalignment_offset ]
+.RB [ \-\-restorefile " " \fIfile ]
 .RB [ \-\-norestorefile ]
-.RB [ \-\-setphysicalvolumesize size ]
-.RB [ \-u | \-\-uuid uuid ]
-.RB [ \-\-version ]
-.RB [ \-Z | \-\-zero y|n ]
+.RB [ \-\-setphysicalvolumesize " " \fIsize ]
+.RB [ \-u | \-\-uuid " " \fIuuid ]
+.RB [ \-Z | \-\-zero " {" \fIy | \fIn }]
 .IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
 .B pvcreate
@@ -54,9 +49,9 @@
 .BR \-f ", " \-\-force
 Force the creation without any confirmation.  You can not recreate
 (reinitialize) a physical volume belonging to an existing volume group.
-In an emergency you can override this behaviour with -ff.
+In an emergency you can override this behaviour with \fB-ff\fP.
 .TP
-.BR \-u ", " \-\-uuid " uuid"
+.BR \-u ", " \-\-uuid " " \fIuuid
 Specify the uuid for the device.  
 Without this option, \fBpvcreate\fP generates a random uuid.
 All of your physical volumes must have unique uuids.
@@ -68,12 +63,12 @@
 .BR \-y ", " \-\-yes
 Answer yes to all questions.
 .TP
-.BR \-Z ", " \-\-zero " y|n"
+.BR \-Z ", " \-\-zero " " \fIy | \fIn
 Whether or not the first 4 sectors (2048 bytes) of the device should be 
 wiped.
 If this option is not given, the 
-default is to wipe these sectors unless either or both of the --restorefile 
-or --uuid options were specified.
+default is to wipe these sectors unless either or both of the \fB--restorefile\fP
+or \fB--uuid\fP options were specified.
 .SH NEW METADATA OPTIONS
 LVM2 introduces a new format for storing metadata on disk.
 This new format is more efficient and resilient than the format the 
@@ -91,25 +86,25 @@
 will be written in due course.  Use the verbose/debug options on the tools
 to see where the metadata areas are placed.
 .TP
-.BR \-\-metadatasize " size"
+.BI \-\-metadatasize " size"
 The approximate amount of space to be set aside for each metadata area.
 (The size you specify may get rounded.)
 .TP
-.BR \-\-dataalignment " alignment"
+.BI \-\-dataalignment " alignment"
 Align the start of the data to a multiple of this number.
-You should also specify an appropriate \fBPhysicalExtentSize\fP when creating
+You should also specify an appropriate \fIPhysicalExtentSize\fP when creating
 the Volume Group with \fBvgcreate\fP.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
-\fBalignment\fP.  In addition it may be shifted by \fBalignment_offset\fP from
-\fBdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
+alignment.  In addition it may be shifted by \fIalignment_offset\fP from
+\fIdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
 \fB--dataalignmentoffset\fP.
 .TP
-.BR \-\-dataalignmentoffset " alignment_offset"
-Shift the start of the data area by this additional \fBalignment_offset\fP.
+.BI \-\-dataalignmentoffset " alignment_offset"
+Shift the start of the data area by this additional \fIalignment_offset\fP.
 .TP
-.BR \-\-[pv]metadatacopies " copies"
+.BI \-\-[pv]metadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
 this can be 0, 1 or 2.  
 If set to 2, two copies of the volume group metadata 
@@ -121,7 +116,7 @@
 then later use \fBvgsplit\fP you must ensure that each VG is still going 
 to have a suitable number of copies of the metadata after the split!
 .TP
-.BR \-\-metadataignore " y|n"
+.BI \-\-metadataignore " y" \fR| n
 Ignore or un-ignore metadata areas on this physical volume.
 The default is "n".  This setting can be changed with \fBpvchange\fP.
 If metadata areas on a physical volume are ignored, LVM will
@@ -132,7 +127,7 @@
 area in case you need it in the future and to use this option to instruct
 LVM2 to ignore it.
 .TP
-.BR \-\-restorefile " file"
+.BI \-\-restorefile " file"
 In conjunction with \fB--uuid\fP, this extracts the location and size
 of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
 and ensures that the metadata that the program produces is consistent 
@@ -141,17 +136,17 @@
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care. See also \fBvgconvert\fP(8).
 .TP
-.BR \-\-norestorefile
-In conjunction with \fB--uuid\fP, this allows a uuid to be specified
+.B \-\-norestorefile
+In conjunction with \fB--uuid\fP, this allows a \fIuuid\fP to be specified
 without also requiring that a backup of the metadata be provided.
 .TP
-.BR \-\-labelsector " sector"
+.BI \-\-labelsector " sector"
 By default the PV is labelled with an LVM2 identifier in its second 
 sector (sector 1).  This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source).  Use with care.
 .TP
-.BR \-\-setphysicalvolumesize " size"
+.BI \-\-setphysicalvolumesize " size"
 Overrides the automatically-detected size of the PV.  Use with care.
 .SH EXAMPLES
 Initialize partition #4 on the third SCSI disk and the entire fifth
--- LVM2/man/pvremove.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvremove.8.in	2011/01/28 16:03:38	1.2
@@ -3,11 +3,7 @@
 pvremove \- remove a physical volume
 .SH SYNOPSIS
 .B pvremove
-.RB [ \-d | \-\-debug]
 .RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
-.RB [\-h | \-\-help]
-.RB [ \-t | \-\-test ]
-.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
 .RB [ \-y | \-\-yes ]
 .IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
@@ -15,7 +11,14 @@
 wipes the label on a device so that LVM will no longer recognise it
 as a physical volume.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-ff ", " \-\-force " " \-\-force
+Force the removal of a physical volume belonging to an existing volume group.
+You cannot remove a physical volume which in use by some active logical volume.
+.TP
+.BR \-y ", " \-\-yes
+Answer yes to all questions.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
--- LVM2/man/pvresize.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvresize.8.in	2011/01/28 16:03:38	1.2
@@ -3,11 +3,7 @@
 pvresize \- resize a disk or partition in use by LVM2
 .SH SYNOPSIS
 .B pvresize
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-setphysicalvolumesize size ]
+.RB [ \-\-setphysicalvolumesize " " \fIsize ]
 .IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
 .B pvresize
@@ -18,7 +14,7 @@
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-\-setphysicalvolumesize " size"
+.BI \-\-setphysicalvolumesize " size"
 Overrides the automatically-detected size of the PV.  Use with care, or
 prior to reducing the physical size of the device.
 .SH EXAMPLES
@@ -46,4 +42,7 @@
 won't currently work correctly on LVM1 volumes or PVs with extra
 metadata areas.
 .SH SEE ALSO
-.BR lvm "(8), " pvmove "(8), " lvresize "(8), " fdisk "(8)"
+.BR lvm (8),
+.BR pvmove (8),
+.BR lvresize (8),
+.BR fdisk (8)
--- LVM2/man/pvscan.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvscan.8.in	2011/01/28 16:03:38	1.2
@@ -3,19 +3,15 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
-.RB [ \-d | \-\-debug]
-.RB [\-e | \-\-exported]
-.RB [\-h | \-\-help]
-.RB [\-\-ignorelockingfailure]
-.RB [ \-n | \-\-novolumegroup]
-.RB [\-s | \-\-short]
-.RB [\-u | \-\-uuid]
-.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.RB [ \-e | \-\-exported ]
+.RB [ \-n | \-\-novolumegroup ]
+.RB [ \-s | \-\-short ]
+.RB [ \-u | \-\-uuid ]
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-e ", " \-\-exported
 Only show physical volumes belonging to exported volume groups.


