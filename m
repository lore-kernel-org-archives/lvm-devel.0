From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:04:21 -0000
Subject: LVM2/man vgcreate.8.in vgextend.8.in
Message-ID: <20091005200421.29373.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:04:21

Modified files:
	man            : vgcreate.8.in vgextend.8.in 

Log message:
	Update vgcreate and vgextend man pages to clarify implicit pvcreate.
	
	vgcreate and vgextend now implicitly call pvcreate on devices not
	currently initialized for LVM use.  Previously these commands would
	fail with an error, so clarify the new behavior in the man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/vgcreate.8.in	2009/07/13 11:25:36	1.3
+++ LVM2/man/vgcreate.8.in	2009/10/05 20:04:21	1.4
@@ -21,16 +21,24 @@
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.I VolumeGroupName PhysicalVolumePath
-.RI [ PhysicalVolumePath ...]
+.RB [ PHYSICAL DEVICE OPTIONS ]
+.I VolumeGroupName PhysicalDevicePath
+.RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
 .B vgcreate
 creates a new volume group called
 .I VolumeGroupName
-using the block special device
-.IR PhysicalVolumePath
-previously configured for LVM with
-.BR pvcreate (8).
+using the block special device \fIPhysicalDevicePath\fP.
+.sp
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default
+\fPpvcreate\fP values are are desired, they may be given on the
+commandline with the same options as \fPpvcreate\fP.  See
+\fBPHYSICAL DEVICE OPTIONS\fP for available options.  Note
+that the restore-related options such as --restorefile, --uuid,
+and --physicalvolumesize are not available.  If a restore operation
+is needed, use \fBpvcreate (8)\fP and \fBvgcfgrestore (8)\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
@@ -86,6 +94,25 @@
 impact on I/O performance to the logical volume.  The smallest PE is 1KB.
 
 The 2.4 kernel has a limitation of 2TB per block device.
+.SH PHYSICAL DEVICE OPTIONS
+The following options are available for initializing physical devices in the
+volume group.  These options are further described in the pvcreate man page.
+.TP
+.BR \-f ", " \-\-force
+.TP
+.BR \-y ", " \-\-yes
+.TP
+.BR \-Z ", " \-\-zero " y|n"
+.TP
+.BR \-\-labelsector " sector"
+.TP
+.BR \-\-metadatasize " size"
+.TP
+.BR \-\-metadatacopies " copies"
+.TP
+.BR \-\-dataalignment " alignment"
+.TP
+.BR \-\-dataalignmentoffset " alignment_offset"
 .SH EXAMPLES
 To create a volume group named
 .B test_vg 
--- LVM2/man/vgextend.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgextend.8.in	2009/10/05 20:04:21	1.3
@@ -6,13 +6,47 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
 [\-t|\-\-test]
 [\-v|\-\-verbose]
+.RB [ PHYSICAL DEVICE OPTIONS ]
 VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 .SH DESCRIPTION
 vgextend allows you to add one or more initialized physical volumes ( see
 .B pvcreate(8)
 ) to an existing volume group to extend it in size.
+.sp
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default
+\fPpvcreate\fP values are are desired, they may be given on the
+commandline with the same options as \fPpvcreate\fP.  See
+\fBPHYSICAL DEVICE OPTIONS\fP for available options.  Note
+that the restore-related options such as --restorefile, --uuid,
+and --physicalvolumesize are not available.  If a restore operation
+is needed, use \fBpvcreate (8)\fP and \fBvgcfgrestore (8)\fP.
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+.SH PHYSICAL DEVICE OPTIONS
+The following options are available for initializing physical devices in the
+volume group.  These options are further described in the pvcreate man page.
+.TP
+.BR \-f ", " \-\-force
+.TP
+.BR \-y ", " \-\-yes
+.TP
+.BR \-Z ", " \-\-zero " y|n"
+.TP
+.BR \-\-labelsector " sector"
+.TP
+.BR \-\-metadatasize " size"
+.TP
+.BR \-\-metadatacopies " copies"
+.TP
+.BR \-\-dataalignment " alignment"
+.TP
+.BR \-\-dataalignmentoffset " alignment_offset"
 .SH Examples
 "vgextend vg00 /dev/sda4 /dev/sdn1" tries to extend the existing volume
 group "vg00" by the new physical volumes (see


