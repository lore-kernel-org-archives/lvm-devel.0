From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:36:18 -0000
Subject: LVM2/man vgchange.8.in
Message-ID: <20100628203618.17341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:36:18

Modified files:
	man            : vgchange.8.in 

Log message:
	Define vgmetadatacopies in vgchange man page.
	
	This patch adds a vgmetadatacopies parameter for metadata balancing.
	This parameter provides a simple way for users to create a policy for
	placing metadata on PVs automatically by LVM.  The behavior is implemented
	inside LVM by managing the 'ignore' mda bits.  We chose the name
	'vgmetadatacopies' as this is a natural extension to the existing parameter
	'pvmetadatacopies' / 'metadatacopies' in pvcreate.
	
	This is a first step at VG parameter based metadata balancing.  Most users
	will probably want to state that they want a certain number of PVs to contain
	metadata, and they may be less concerned about a specific number of metadata
	copies in the volume group.  However, for default values (pvmetadatacopies
	is 1 by default), the number of metadatacopies in the volume group, and the
	number of PVs with metadata are the same.  In the future we could add
	vgmetadatacopiespvs to define more specifically the number of pvs in the
	VG that contain metadata, but for now we start with this parameter.
	
	Another possible future extension would be to define a specific pv tag
	to mark the set of PVs that should be used for metadata balancing.  This
	tag based approach could be used in conjunction with 'vgmetadatacopies'.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/man/vgchange.8.in	2010/05/06 11:15:55	1.9
+++ LVM2/man/vgchange.8.in	2010/06/28 20:36:18	1.10
@@ -25,6 +25,8 @@
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-[vg]metadatacopies ]
+.IR NumberOfCopies|unmanaged|all ]
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
@@ -127,13 +129,23 @@
 Changes the maximum number of physical volumes that can belong
 to this volume group.
 For volume groups with metadata in lvm1 format, the limit is 255.
-If the metadata uses lvm2 format, the value 0
-removes this restriction: there is then no limit.
-If you have a large number of physical volumes in
-a volume group with metadata in lvm2 format,
-for tool performance reasons, you should consider
-some use of \fB--pvmetadatacopies 0\fP
-as described in \fBpvcreate(8)\fP.
+If the metadata uses lvm2 format, the value 0 removes this restriction:
+there is then no limit.  If you have a large number of physical volumes in
+a volume group with metadata in lvm2 format, for tool performance reasons,
+you should consider some use of \fB--pvmetadatacopies 0\fP as described in
+\fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
+.TP
+.BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
+Sets the desired number of metadata copies in the volume group.  If set to
+a non-zero value, LVM will automatically manage the 'metadataignore'
+flags on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
+LVM will not automatically manage the 'metadataignore' flags.  If set to
+\fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
+metadata areas in the volume group, then set the value to \fIunmanaged\fP.
+The \fBvgmetadatacopies\fP option is useful for volume groups containing
+large numbers of physical volumes with metadata as it may be used to
+minimize metadata read and write overhead.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
 Changes the physical extent size on physical volumes of this volume group.


