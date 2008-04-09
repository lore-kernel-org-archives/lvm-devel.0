From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Apr 2008 14:39:56 -0000
Subject: LVM2 ./WHATS_NEW man/vgsplit.8
Message-ID: <20080409143956.27996.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-09 14:39:55

Modified files:
	.              : WHATS_NEW 
	man            : vgsplit.8 

Log message:
	Update vgsplit man page to reflect lvnames on cmdline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.838&r2=1.839
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2008/04/09 13:47:13	1.838
+++ LVM2/WHATS_NEW	2008/04/09 14:39:55	1.839
@@ -1,6 +1,7 @@
 Version 2.02.34 -
 ===================================
-  Update vgsplit to take "-n LogicalVolumeName" on the commandline.
+  Update vgsplit man page to reflect lvnames on the cmdline.
+  Update vgsplit to take "-n LogicalVolumeName" on the cmdline.
   Use clustered mirror log with pvmove in clustered VGs, if available.
   Fix some pvmove error status codes.
   Fix vgsplit error paths to release vg_to lock.
--- LVM2/man/vgsplit.8	2008/01/22 02:48:52	1.7
+++ LVM2/man/vgsplit.8	2008/04/09 14:39:55	1.8
@@ -15,18 +15,21 @@
 .IR type ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-n | \-\-name 
+.IR LogicalVolumeName ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 SourceVolumeGroupName DestinationVolumeGroupName
-PhysicalVolumePath [PhysicalVolumePath...]
+[ PhysicalVolumePath ...]
 .SH DESCRIPTION
 .B vgsplit 
-moves
-.IR PhysicalVolumePath (s)
-from
+moves one or more physical volumes from
 .I SourceVolumeGroupName
 into
-.I DestinationVolumeGroupName\fP.
+.I DestinationVolumeGroupName\fP.  The physical volumes moved can be
+specified either explicitly via \fIPhysicalVolumePath\fP, or implicitly by
+\fB-n\fP \fILogicalVolumeName\fP, in which case only physical volumes
+underlying the specified logical volume will be moved.
 
 If
 .I DestinationVolumeGroupName
@@ -46,9 +49,13 @@
 volume group attributes with an existing destination volume group is an error,
 and no split will occur.
 
-Logical Volumes cannot be split between Volume Groups.
-Each existing Logical Volume must be entirely on the Physical Volumes forming
-either the source or the destination Volume Group.
+Logical volumes cannot be split between volume groups. \fBVgsplit(8)\fP only
+moves complete physical volumes: To move part of a physical volume, use
+\fBpvmove(8)\fP.  Each existing logical volume must be entirely on the physical
+volumes forming either the source or the destination volume group.  For this
+reason, \fBvgsplit(8)\fP may fail with an error if a split would result in a
+logical volume being split across volume groups.
+
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH SEE ALSO


