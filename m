From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Oct 2009 02:36:29 -0000
Subject: LVM2/man vgcreate.8.in vgextend.8.in
Message-ID: <20091026023629.457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-26 02:36:29

Modified files:
	man            : vgcreate.8.in vgextend.8.in 

Log message:
	Minor fix to vgcreate/vgextend man pages for PHYSICAL DEVICE OPTIONS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/man/vgcreate.8.in	2009/10/05 20:55:57	1.5
+++ LVM2/man/vgcreate.8.in	2009/10/26 02:36:29	1.6
@@ -21,7 +21,7 @@
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RB [ PHYSICAL DEVICE OPTIONS ]
+[ \fIPHYSICAL DEVICE OPTIONS\fP ]
 .I VolumeGroupName PhysicalDevicePath
 .RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
--- LVM2/man/vgextend.8.in	2009/10/05 20:55:57	1.4
+++ LVM2/man/vgextend.8.in	2009/10/26 02:36:29	1.5
@@ -6,7 +6,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
 [\-t|\-\-test]
 [\-v|\-\-verbose]
-.RB [ PHYSICAL DEVICE OPTIONS ]
+[ \fIPHYSICAL DEVICE OPTIONS\fP ]
 VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 .SH DESCRIPTION
 vgextend allows you to add one or more initialized physical volumes ( see


