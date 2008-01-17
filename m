From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jan 2008 03:18:18 -0000
Subject: LVM2/man vgsplit.8
Message-ID: <20080117031818.30750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-17 03:18:18

Modified files:
	man            : vgsplit.8 

Log message:
	Fixup vgsplit man page

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/vgsplit.8	2008/01/16 17:14:56	1.5
+++ LVM2/man/vgsplit.8	2008/01/17 03:18:18	1.6
@@ -29,9 +29,24 @@
 .I SourceVolumeGroupName
 into
 .I DestinationVolumeGroupName\fP.
+
 If
 .I DestinationVolumeGroupName
-does not exist, it will be created.
+does not exist, a new volume group will be created.  The default attributes
+for the new volume group can be specified with \fB\-\-alloc\fR,
+\fB\-\-clustered\fR, \fB\-\-maxlogicalvolumes\fR, \fB\-\-metadatatype\fR,
+\fB\-\-maxphysicalvolumes\fR, and \fB\-\-physicalextentsize\fR
+(see \fBvgcreate(8)\fR for a description of these options).
+If any of these options are not given, the default attribute(s) are taken
+from
+.I SourceVolumeGroupName\fP.
+
+If
+.I DestinationVolumeGroupName
+does exist, it will be checked for compatibility with
+.I SourceVolumeGroupName
+before the physical volumes are moved.
+
 Logical Volumes cannot be split between Volume Groups.
 Each existing Logical Volume must be entirely on the Physical Volumes forming
 either the source or the destination Volume Group.


