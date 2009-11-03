From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Nov 2009 15:58:02 -0000
Subject: LVM2/man vgextend.8.in
Message-ID: <20091103155802.22578.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-03 15:58:02

Modified files:
	man            : vgextend.8.in 

Log message:
	Remove old, and now incorrect, vgextend man page description of pvcreate options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/vgextend.8.in	2009/10/26 02:36:29	1.5
+++ LVM2/man/vgextend.8.in	2009/11/03 15:58:02	1.6
@@ -22,10 +22,6 @@
 that the restore-related options such as --restorefile, --uuid,
 and --physicalvolumesize are not available.  If a restore operation
 is needed, use \fBpvcreate (8)\fP and \fBvgcfgrestore (8)\fP.
-\fBpvcreate (8)\fP, the device will be initialized with the same
-default values used with \fBpvcreate\fP.  If non-default
-\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
-called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH PHYSICAL DEVICE OPTIONS


