From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Jul 2010 17:05:23 -0000
Subject: LVM2/man lvm.conf.5.in pvchange.8.in pvcreate. ...
Message-ID: <20100702170523.25651.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-02 17:05:22

Modified files:
	man            : lvm.conf.5.in pvchange.8.in pvcreate.8.in 
	                 vgchange.8.in vgcreate.8.in 

Log message:
	Minor changes to man pages for --metadataignore.
	
	Move the definition from pvchange to pvcreate - the location of
	other metadata options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/man/lvm.conf.5.in	2010/06/30 13:03:48	1.11
+++ LVM2/man/lvm.conf.5.in	2010/07/02 17:05:22	1.12
@@ -415,7 +415,7 @@
 or extended after Logical Volumes have been allocated on the device.
 If you do not want to store metadata on this device, it is still wise
 always to allocate a metadata area (use a non-zero value for
-\fB--pvmetadatacopies) in case you need it in the future and to use
+\fB--pvmetadatacopies\fP) in case you need it in the future and to use
 this option to instruct LVM2 to ignore it.
 .IP
 \fBvgmetadatacopies\fP \(em When creating a volume group using the
--- LVM2/man/pvchange.8.in	2010/06/28 20:34:12	1.3
+++ LVM2/man/pvchange.8.in	2010/07/02 17:05:22	1.4
@@ -26,16 +26,6 @@
 .TP
 .I \-x, \-\-allocatable y|n
 Enable or disable allocation of physical extents on this physical volume.
-.TP
-.I \-\-metadataignore y|n
-Ignore or un-ignore metadata areas on this physical volume.  If metadata
-areas on a physical volume are ignored, LVM will not not store metadata
-in the metadata areas present on this Physical Volume.  Metadata areas
-cannot be created or extended after Logical Volumes have been allocated
-on the device. If you do not want to store metadata on this device, it
-is still wise always to allocate a metadata area in case you need it in
-the future and to use this option to instruct LVM2 to ignore it.
-(This option is not applicable to the old LVM1 metadata format.)
 .SH Example
 "pvchange -x n /dev/sdk1" disallows the allocation of physical extents
 on this physical volume (possibly because of disk errors, or because it will
--- LVM2/man/pvcreate.8.in	2010/06/30 12:49:29	1.6
+++ LVM2/man/pvcreate.8.in	2010/07/02 17:05:22	1.7
@@ -118,6 +118,16 @@
 then later use \fBvgsplit\fP you must ensure that each VG is still going 
 to have a suitable number of copies of the metadata after the split!
 .TP
+.I \-\-metadataignore y|n
+Ignore or un-ignore metadata areas on this physical volume.  The default
+is "n".  If metadata areas on a physical volume are ignored, LVM will
+not not store metadata in the metadata areas present on this Physical
+Volume.  Metadata areas cannot be created or extended after Logical
+Volumes have been allocated on the device. If you do not want to store
+metadata on this device, it is still wise always to allocate a metadata
+area in case you need it in the future and to use this option to instruct
+LVM2 to ignore it.
+.TP
 .BR \-\-restorefile " file"
 In conjunction with \fB--uuid\fP, this extracts the location and size
 of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
--- LVM2/man/vgchange.8.in	2010/06/28 20:36:18	1.10
+++ LVM2/man/vgchange.8.in	2010/07/02 17:05:22	1.11
@@ -138,7 +138,7 @@
 .BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate\fP --metadataignore\fP) in order
 to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
 LVM will not automatically manage the 'metadataignore' flags.  If set to
 \fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
--- LVM2/man/vgcreate.8.in	2010/06/28 20:38:23	1.8
+++ LVM2/man/vgcreate.8.in	2010/07/02 17:05:22	1.9
@@ -77,7 +77,7 @@
 .BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+flags on the physical volumes (see \fBpvcreate\fP or \fBpvchange\fP --metadataignore\fP) in order
 to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
 LVM will not automatically manage the 'metadataignore' flags.  If set to
 \fIall\fP, LVM will first clear all of the 'metadataignore' flags on all


