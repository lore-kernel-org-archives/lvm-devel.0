From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Feb 2009 13:17:42 -0000
Subject: LVM2 ./WHATS_NEW man/vgchange.8.in man/vgmknod ...
Message-ID: <20090225131742.12076.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-02-25 13:17:41

Modified files:
	.              : WHATS_NEW 
	man            : vgchange.8.in vgmknodes.8.in 

Log message:
	Update vgchange and vgmknodes man pages to include --refresh.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1052&r2=1.1053
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmknodes.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/02/24 15:48:01	1.1052
+++ LVM2/WHATS_NEW	2009/02/25 13:17:40	1.1053
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add --refresh to vgchange and vgmknodes man pages.
   Fixed bug where lvresize option -t was not properly passed to fsadm.
   Using argv[] list in exec_cmd() to allow more params for external commands.
   Fsadm does not allow checking mounted filesystem.
--- LVM2/man/vgchange.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgchange.8.in	2009/02/25 13:17:41	1.2
@@ -25,6 +25,7 @@
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.RB [ \-\-refresh]
 .RB [ -t | \-\-test]
 .RB [ \-v | \-\-verbose]
 .RB [ \-\-version ]
@@ -128,6 +129,12 @@
  
 The 2.4 kernel has a limitation of 2TB per block device.
 .TP
+.BR \-\-refresh
+If any logical volume in the volume group is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering
+manually without a clustered lock manager.
+.TP
 .BR \-x ", " \-\-resizeable " " { y | n }
 Enables or disables the extension/reduction of this volume group
 with/by physical volumes.
--- LVM2/man/vgmknodes.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgmknodes.8.in	2009/02/25 13:17:41	1.3
@@ -3,13 +3,22 @@
 vgmknodes \- recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-v|\-\-verbose]
+.RB [ \-d | \-\-debug]
+.RB [ \-h | \-\-help]
+.RB [ \-\-refresh]
+.RB [ \-v | \-\-verbose]
 [[VolumeGroupName | LogicalVolumePath]...]
 .SH DESCRIPTION
 Checks the LVM2 special files in /dev that are needed for active 
 logical volumes and creates any missing ones and removes unused ones.
 .SH OPTIONS
+.TP
+.BR \-\-refresh
+If any logical volume in the volume group is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering
+manually without a clustered lock manager.
+.TP
 See \fBlvm\fP for common options.
 .SH SEE ALSO
 .BR lvm (8),


