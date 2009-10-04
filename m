From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:46 -0400
Subject: [PATCH 09/10] Update vgcreate and vgextend man pages to clarify implicit pvcreate.
In-Reply-To: <1254697907-16448-9-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-6-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-7-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-8-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vgcreate and vgextend now implicitly call pvcreate on devices not
currently initialized for LVM use.  Previously these commands would
fail with an error, so clarify the new behavior in the man page.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgcreate.8.in |   39 +++++++++++++++++++++++++++++++++------
 man/vgextend.8.in |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 71bc136..f00afcf 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -21,16 +21,24 @@ vgcreate \- create a volume group
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
@@ -86,6 +94,25 @@ but having a large number of extents will slow down the tools but have no
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
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 682cc5a..9cfc631 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -6,13 +6,47 @@ vgextend \- add physical volumes to a volume group
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
-- 
1.6.0.6


