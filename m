From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 4 Jan 2011 21:41:37 -0000
Subject: LVM2/man lvconvert.8.in
Message-ID: <20110104214137.23994.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-04 21:41:36

Modified files:
	man            : lvconvert.8.in 

Log message:
	Fix bug 635949: lvconvert man page clarification

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/man/lvconvert.8.in	2010/10/13 21:26:38	1.18
+++ LVM2/man/lvconvert.8.in	2011/01/04 21:41:35	1.19
@@ -51,9 +51,10 @@
 [\-\-version]
 LogicalVolume[Path] [PhysicalVolume[Path]...]
 .SH DESCRIPTION
-lvconvert will change a linear logical volume to a mirror
-logical volume or to a snapshot of linear volume and vice versa.
-It is also used to add and remove disk logs from mirror devices.
+lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
+characteristics of a logical volume.  For example, it can add or remove the
+redundant images of a logical volume, change the log type of a mirror, or
+designate a logical volume as a snapshot repository.
 .br
 If the conversion requires allocation of physical extents (for
 example, when converting from linear to mirror) and you specify


