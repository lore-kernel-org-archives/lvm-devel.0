From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jul 2010 15:04:25 -0000
Subject: LVM2/man lvm.conf.5.in pvchange.8.in pvcreate. ...
Message-ID: <20100713150425.18492.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-13 15:04:24

Modified files:
	man            : lvm.conf.5.in pvchange.8.in pvcreate.8.in 
	                 vgchange.8.in 

Log message:
	Minor man page updates related to metadataignore and vgmetadatacopies.
	
	pvchange: Add --metadataignore description
	vgchange: Fix minor formatting
	pvcreate: Update metadataignore description to refer to pvchange
	lvm.conf: Refer to pvcreate and pvchange for metadata options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/man/lvm.conf.5.in	2010/07/02 17:05:22	1.12
+++ LVM2/man/lvm.conf.5.in	2010/07/13 15:04:23	1.13
@@ -386,7 +386,8 @@
 Currently it can be set to 0, 1 or 2.  The default is 1.  
 If set to 2, one copy is placed at the beginning of the disk
 and the other is placed at the end.
-It can be overridden on the command line with \fB--pvmetadatacopies\fP.
+It can be overridden on the command line with \fB--pvmetadatacopies\fP
+(see \fBpvcreate\fP).
 If creating a volume group with just one physical volume, it's a
 good idea to have 2 copies.  If creating a large volume group with
 many physical volumes, you may decide that 3 copies of the metadata
@@ -411,8 +412,9 @@
 The default is "n".  If metadata areas on a physical volume are ignored,
 LVM will not not store metadata in the metadata areas present on newly
 created Physical Volumes.  The option can be overridden on the command
-line with \fB--metadataignore\fP.  Metadata areas cannot be created
-or extended after Logical Volumes have been allocated on the device.
+line with \fB--metadataignore\fP (See \fBpvcreate\fP and \fBpvchange\fP).
+Metadata areas cannot be created or extended after Logical Volumes have
+been allocated on the device.
 If you do not want to store metadata on this device, it is still wise
 always to allocate a metadata area (use a non-zero value for
 \fB--pvmetadatacopies\fP) in case you need it in the future and to use
@@ -422,13 +424,14 @@
 LVM2 metadata format, this is the default number of copies of metadata
 desired across all the physical volumes in the volume group.  If set to
 a non-zero value, LVM will automatically set or clear the metadataignore
-flag on the physical volumes (see \fBpvchange --metadataignore\fP) in order
-to achieve the desired number of metadata copies.  An LVM command that
-adds or removes physical volumes (for example, \fBvgextend\fP, \fBvgreduce\fP,
-\fBvgsplit\fP, or \fBvgmerge\fP), may cause LVM to automatically set or
-clear the metadataignore flags.  Also, if physical volumes go missing or
-reappear, or a new number of copies is explicitly set (see
-\fBvgchange --vgmetadatacopies\fP), LVM may adjust the metadataignore flags.
+flag on the physical volumes (see \fBpvcreate\fP and \fBpvchange\fP
+\fB--metadataignore\fP) in order to achieve the desired number of metadata
+copies.  An LVM command that adds or removes physical volumes (for example,
+\fBvgextend\fP, \fBvgreduce\fP, \fBvgsplit\fP, or \fBvgmerge\fP), may cause
+LVM to automatically set or clear the metadataignore flags.  Also, if
+physical volumes go missing or reappear, or a new number of copies is
+explicitly set (see \fBvgchange --vgmetadatacopies\fP), LVM may adjust
+the metadataignore flags.
 Set \fBvgmetadatacopies\fP to 0 instructs LVM not to set or clear the
 metadataignore flags automatically.  You may set a value larger than the
 sum of all metadata areas on all physical volumes.  The value can
--- LVM2/man/pvchange.8.in	2010/07/07 19:14:57	1.5
+++ LVM2/man/pvchange.8.in	2010/07/13 15:04:23	1.6
@@ -22,6 +22,12 @@
 If PhysicalVolumePath is not specified on the command line all
 physical volumes are searched for and used.
 .TP
+.I \-\-metadataignore " y|n"
+Ignore or un-ignore metadata areas on this physical volume.
+If metadata areas on a physical volume are ignored, LVM will
+not not store metadata in the metadata areas present on this Physical
+Volume.
+.TP
 .I \-u, \-\-uuid
 Generate new random UUID for specified physical volumes.
 .TP
--- LVM2/man/pvcreate.8.in	2010/07/02 17:05:22	1.7
+++ LVM2/man/pvcreate.8.in	2010/07/13 15:04:23	1.8
@@ -118,9 +118,10 @@
 then later use \fBvgsplit\fP you must ensure that each VG is still going 
 to have a suitable number of copies of the metadata after the split!
 .TP
-.I \-\-metadataignore y|n
-Ignore or un-ignore metadata areas on this physical volume.  The default
-is "n".  If metadata areas on a physical volume are ignored, LVM will
+.BR \-\-metadataignore " y|n"
+Ignore or un-ignore metadata areas on this physical volume.
+The default is "n".  This setting can be changed with \fBpvchange\fP.
+If metadata areas on a physical volume are ignored, LVM will
 not not store metadata in the metadata areas present on this Physical
 Volume.  Metadata areas cannot be created or extended after Logical
 Volumes have been allocated on the device. If you do not want to store
--- LVM2/man/vgchange.8.in	2010/07/02 17:05:22	1.11
+++ LVM2/man/vgchange.8.in	2010/07/13 15:04:23	1.12
@@ -135,10 +135,10 @@
 you should consider some use of \fB--pvmetadatacopies 0\fP as described in
 \fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
 .TP
-.BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
+.BR \-\-[vg]metadatacopies " " \fINumberOfCopies|unmanaged|all\fP
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate\fP --metadataignore\fP) in order
+flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate --metadataignore\fP) in order
 to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
 LVM will not automatically manage the 'metadataignore' flags.  If set to
 \fIall\fP, LVM will first clear all of the 'metadataignore' flags on all


