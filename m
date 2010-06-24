From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Jun 2010 08:37:02 -0000
Subject: LVM2/man vgcreate.8.in
Message-ID: <20100624083702.9311.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-24 08:36:58

Modified files:
	man            : vgcreate.8.in 

Log message:
	Fix typo reported in Debian bugzilla #586043

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/man/vgcreate.8.in	2009/10/26 02:36:29	1.6
+++ LVM2/man/vgcreate.8.in	2010/06/24 08:36:57	1.7
@@ -33,7 +33,7 @@
 If \fIPhysicalDevicePath\fP was not previously configured for LVM with
 \fBpvcreate (8)\fP, the device will be initialized with the same
 default values used with \fBpvcreate\fP.  If non-default
-\fPpvcreate\fP values are are desired, they may be given on the
+\fPpvcreate\fP values are desired, they may be given on the
 commandline with the same options as \fPpvcreate\fP.  See
 \fBPHYSICAL DEVICE OPTIONS\fP for available options.  Note
 that the restore-related options such as --restorefile, --uuid,


