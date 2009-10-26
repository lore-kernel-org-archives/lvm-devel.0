From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Oct 2009 13:41:13 -0000
Subject: LVM2/man lvconvert.8.in lvcreate.8.in
Message-ID: <20091026134113.27092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-26 13:41:13

Modified files:
	man            : lvconvert.8.in lvcreate.8.in 

Log message:
	Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
	
	Addresses rhbz 500177.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/man/lvconvert.8.in	2009/08/10 17:23:04	1.8
+++ LVM2/man/lvconvert.8.in	2009/10/26 13:41:13	1.9
@@ -35,6 +35,15 @@
 lvconvert will change a linear logical volume to a mirror
 logical volume or to a snapshot of linear volume and vice versa.
 It is also used to add and remove disk logs from mirror devices.
+.br
+If the conversion requires allocation of physical extents (for
+example, when converting from linear to mirror) and you specify
+one or more PhysicalVolumes (optionally with ranges of physical
+extents), allocation of physical extents will be restricted to
+these physical extents.  If the conversion frees physical extents
+(for example, when converting from a mirror to a linear, or reducing
+mirror legs) and you specify one or more PhysicalVolumes,
+the freed extents come first from the specified PhysicalVolumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
@@ -131,6 +140,12 @@
 converts linear logical volume "vg00/lvol1" to a two-way mirror, using physical
 extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
 
+.br
+"lvconvert -m0 vg00/lvmirror1 /dev/sda
+.br
+converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
+extents from /dev/sda.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/man/lvcreate.8.in	2009/09/29 15:11:06	1.11
+++ LVM2/man/lvcreate.8.in	2009/10/26 13:41:13	1.12
@@ -41,7 +41,9 @@
 ) with other physical volumes or by reducing existing logical volumes
 of this volume group in size ( see
 .B lvreduce(8)
-).
+). If you specify one or more PhysicalVolumes, allocation of physical
+extents will be restricted to these volumes.
+.br
 .br
 The second form supports the creation of snapshot logical volumes which 
 keep the contents of the original logical volume for backup purposes.


