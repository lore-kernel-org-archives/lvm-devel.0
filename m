From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2011 20:02:08 -0000
Subject: LVM2 ./WHATS_NEW man/lvscan.8.in
Message-ID: <20110124200208.31506.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-24 20:02:08

Modified files:
	.              : WHATS_NEW 
	man            : lvscan.8.in 

Log message:
	Bring lvscan man page up-to-date.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1888&r2=1.1889
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvscan.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2011/01/24 14:19:05	1.1888
+++ LVM2/WHATS_NEW	2011/01/24 20:02:07	1.1889
@@ -1,5 +1,6 @@
 Version 2.02.82 -
 ===================================
+  Bring lvscan man page up-to-date.
   Fix lvchange --test to exit cleanly.
   Add change_tag to toollib.
   Allow multiple pvchange command line options to be specified together.
--- LVM2/man/lvscan.8.in	2009/10/26 14:37:09	1.2
+++ LVM2/man/lvscan.8.in	2011/01/24 20:02:08	1.3
@@ -1,6 +1,6 @@
 .TH LVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvscan \- scan (all disks) for logical volumes
+lvscan \- scan (all disks) for Logical Volumes
 .SH SYNOPSIS
 .B lvscan
 .RB [ \-a | \-\-all]
@@ -13,7 +13,11 @@
 .SH DESCRIPTION
 .B lvscan
 scans all known volume groups or all supported LVM block devices
-in the system for defined logical volumes.
+in the system for defined Logical Volumes.  The output consists
+of one line for each Logical Volume indicating whether or not it is active, 
+a snapshot or origin, the size of the device and its allocation policy.
+Use \fBlvs(8)\fP or \fBlvdisplay(8)\fP to obtain more-comprehensive information 
+about the Logical Volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
@@ -26,9 +30,10 @@
 mimage_0, mimage_1, and mlog.
 .TP
 .BR \-b ", " \-\-blockdevice
-Adds the device major and minor numbers to the display
-of each logical volume.
+This option is now ignored.  Instead, use \fBlvs(8)\fP or \fBlvdisplay(8)\fP to obtain
+the device number.
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8),
 .BR lvdisplay (8)
+.BR lvs (8)


