From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 13:03:50 -0000
Subject: LVM2 man/lvm.conf.5.in man/vgextend.8.in tools ...
Message-ID: <20100630130350.9442.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 13:03:49

Modified files:
	man            : lvm.conf.5.in vgextend.8.in 
	tools          : commands.h 

Log message:
	Add --metadataignore to vgextend and man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/man/lvm.conf.5.in	2010/06/30 12:49:29	1.10
+++ LVM2/man/lvm.conf.5.in	2010/06/30 13:03:48	1.11
@@ -411,7 +411,7 @@
 The default is "n".  If metadata areas on a physical volume are ignored,
 LVM will not not store metadata in the metadata areas present on newly
 created Physical Volumes.  The option can be overridden on the command
-line with \fB--pvmetadataignore\fP.  Metadata areas cannot be created
+line with \fB--metadataignore\fP.  Metadata areas cannot be created
 or extended after Logical Volumes have been allocated on the device.
 If you do not want to store metadata on this device, it is still wise
 always to allocate a metadata area (use a non-zero value for
--- LVM2/man/vgextend.8.in	2009/11/03 15:58:02	1.6
+++ LVM2/man/vgextend.8.in	2010/06/30 13:03:48	1.7
@@ -38,6 +38,8 @@
 .TP
 .BR \-\-metadatasize " size"
 .TP
+.RB [ \-\-metadataignore y|n ]
+.TP
 .BR \-\-pvmetadatacopies " copies"
 .TP
 .BR \-\-dataalignment " alignment"
--- LVM2/tools/commands.h	2010/06/30 12:17:25	1.151
+++ LVM2/tools/commands.h	2010/06/30 13:03:48	1.152
@@ -856,7 +856,7 @@
    autobackup_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   dataalignment_ARG, dataalignmentoffset_ARG)
+   metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",


