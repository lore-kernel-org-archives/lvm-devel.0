From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:37 +0100
Subject: [PATCH 13/15] Man page consistency fixes
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <fc0aa87deeeec237f87137f86e69cc3a4fa2d9e2.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make a better looking colorized manpages for few commands.
It's rather a my proposal how do I'd like to see man pages to be
looking. For view I'm using 'midnight commander' and its colorized
man page reader output looked quite unreabable with original man pages.

Also it removes some common options - they are better described
in lvm(8) page.

This patch makes them IMHO better - but I see it rather for discussion
how the options and options' parameters should be visible.

Also it extends a bit pvremove man page with -ff and -y option
description.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/pvcreate.8.in |   63 ++++++++++++++++++++++++----------------------------
 man/pvremove.8.in |   15 +++++++-----
 man/pvresize.8.in |   13 +++++------
 man/pvscan.8.in   |   14 ++++-------
 4 files changed, 49 insertions(+), 56 deletions(-)

diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index cb10049..14f0a38 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
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
@@ -54,9 +49,9 @@ See \fBlvm\fP(8) for common options.
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
@@ -68,12 +63,12 @@ used.
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
@@ -91,25 +86,25 @@ Additional tools for manipulating the locations and sizes of metadata areas
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
@@ -121,7 +116,7 @@ with VGs containing large numbers of PVs.  But if you do this and
 then later use \fBvgsplit\fP you must ensure that each VG is still going 
 to have a suitable number of copies of the metadata after the split!
 .TP
-.BR \-\-metadataignore " y|n"
+.BI \-\-metadataignore " y" \fR| n
 Ignore or un-ignore metadata areas on this physical volume.
 The default is "n".  This setting can be changed with \fBpvchange\fP.
 If metadata areas on a physical volume are ignored, LVM will
@@ -132,7 +127,7 @@ metadata on this device, it is still wise always to allocate a metadata
 area in case you need it in the future and to use this option to instruct
 LVM2 to ignore it.
 .TP
-.BR \-\-restorefile " file"
+.BI \-\-restorefile " file"
 In conjunction with \fB--uuid\fP, this extracts the location and size
 of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
 and ensures that the metadata that the program produces is consistent 
@@ -141,17 +136,17 @@ the same place and not get overwritten by new metadata.  This provides
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
diff --git a/man/pvremove.8.in b/man/pvremove.8.in
index b435fc7..3522e80 100644
--- a/man/pvremove.8.in
+++ b/man/pvremove.8.in
@@ -3,11 +3,7 @@
 pvremove \- remove a physical volume
 .SH SYNOPSIS
 .B pvremove
-.RB [ \-d | \-\-debug]
-.RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
-.RB [\-h | \-\-help]
-.RB [ \-t | \-\-test ]
-.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.RB [ \-ff ]| \-\-force " " \-\-force ]
 .RB [ \-y | \-\-yes ]
 .IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
@@ -15,7 +11,14 @@ pvremove \- remove a physical volume
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
diff --git a/man/pvresize.8.in b/man/pvresize.8.in
index 845f6d3..10a0b50 100644
--- a/man/pvresize.8.in
+++ b/man/pvresize.8.in
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
@@ -18,7 +14,7 @@ allocated on it.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-\-setphysicalvolumesize " size"
+.BI \-\-setphysicalvolumesize " size"
 Overrides the automatically-detected size of the PV.  Use with care, or
 prior to reducing the physical size of the device.
 .SH EXAMPLES
@@ -46,4 +42,7 @@ does.
 won't currently work correctly on LVM1 volumes or PVs with extra
 metadata areas.
 .SH SEE ALSO
-.BR lvm "(8), " pvmove "(8), " lvresize "(8), " fdisk "(8)"
+.BR lvm (8),
+.BR pvmove (8),
+.BR lvresize (8),
+.BR fdisk (8)
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 4a6bcd7..a3147d7 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
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
-- 
1.7.3.5


