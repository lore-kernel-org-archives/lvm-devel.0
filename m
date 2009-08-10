From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Aug 2009 17:23:05 -0000
Subject: LVM2/man lvconvert.8.in lvcreate.8.in lvextend ...
Message-ID: <20090810172305.5775.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-10 17:23:05

Modified files:
	man            : lvconvert.8.in lvcreate.8.in lvextend.8.in 
	                 lvresize.8.in 

Log message:
	Update man pages to clarify usage of PE ranges.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/lvconvert.8.in	2009/08/04 08:09:52	1.7
+++ LVM2/man/lvconvert.8.in	2009/08/10 17:23:04	1.8
@@ -10,7 +10,8 @@
 [\-\-noudevsync]
 [\-v|\-\-verbose] [\-y|\-\-yes]
 [\-\-version]
-LogicalVolume[Path] [PhysicalVolume[Path]...]
+.br
+LogicalVolume[Path] [PhysicalVolume[Path][:PE[-PE]]...]
 .br
 
 .br
@@ -124,6 +125,12 @@
 .br
 converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
 
+.br
+"lvconvert -m1 vg00/lvol1 /dev/sda:0-15 /dev/sdb:0-15"
+.br
+converts linear logical volume "vg00/lvol1" to a two-way mirror, using physical
+extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/man/lvcreate.8.in	2009/08/04 08:09:52	1.9
+++ LVM2/man/lvcreate.8.in	2009/08/10 17:23:04	1.10
@@ -17,7 +17,7 @@
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
 [\-t|\-\-test]
 [\-v|\-\-verbose] [\-Z|\-\-zero y|n]
-VolumeGroupName [PhysicalVolumePath...]
+VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
 .br
 
 .br
@@ -209,6 +209,13 @@
 .br
 creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
 under 100MB of actual data on it.
+.br
+
+"lvcreate -L 64M -n lvol1 vg00 /dev/sda:0-7 /dev/sdb:0-7"
+.br
+creates a linear logical volume "vg00/lvol1" using physical extents
+/dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
+
 
 .SH SEE ALSO
 .BR lvm (8), 
--- LVM2/man/lvextend.8.in	2009/08/04 08:09:52	1.4
+++ LVM2/man/lvextend.8.in	2009/08/10 17:23:04	1.5
@@ -10,7 +10,7 @@
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
 lvextend allows you to extend the size of a logical volume.
 Extension of snapshot logical volumes (see
@@ -68,6 +68,13 @@
 "lvextend /dev/vg01/lvol01 /dev/sdk3" tries to extend the size of that
 logical volume by the amount of free space on physical volume /dev/sdk3.
 This is equivalent to specifying "-l +100%PVS" on the command line.
+
+.br
+"lvextend -L+16M vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9"
+.br
+tries to extend a logical volume "vg01/lvol01" by 16MB using physical extents
+/dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8), 
--- LVM2/man/lvresize.8.in	2009/08/04 08:09:52	1.5
+++ LVM2/man/lvresize.8.in	2009/08/10 17:23:04	1.6
@@ -10,7 +10,7 @@
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
 lvresize allows you to resize a logical volume.
 Be careful when reducing a logical volume's size, because data in the reduced
@@ -66,6 +66,13 @@
 must use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
+.SH Examples
+.br
+"lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1"
+.br
+tries to extend a logical volume "vg1/lv1" by 16MB using physical extents
+/dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvconvert (8),


