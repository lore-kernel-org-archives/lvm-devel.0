From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:36:06 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111028203606.19405.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:36:06

Modified files:
	man            : lvcreate.8.in 

Log message:
	Continue with lvcreate man page update
	
	Already in WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/man/lvcreate.8.in	2011/10/28 20:33:50	1.27
+++ LVM2/man/lvcreate.8.in	2011/10/28 20:36:05	1.28
@@ -304,44 +304,46 @@
 Warning: trying to mount an unzeroed logical volume can cause the system to
 hang.
 .SH Examples
-"lvcreate -i 3 -I 8 -L 100M vg00" tries to create a striped logical
-volume with 3 stripes, a stripesize of 8KB and a size of 100MB in the volume
-group named vg00. The logical volume name will be chosen by lvcreate.
-
-"lvcreate -m1 -L 500M vg00" tries to create a mirror logical volume
-with 2 sides with a useable size of 500 MiB.  This operation would
-require 3 devices - two for the mirror devices and one for the disk
-log.
-
-"lvcreate -m1 --mirrorlog core -L 500M vg00" tries to create a mirror logical volume
-with 2 sides with a useable size of 500 MiB.  This operation would
-require 2 devices - the log is "in-memory".
-
-"lvcreate --size 100m --snapshot --name snap /dev/vg00/lvol1"
-.br
-creates a snapshot logical volume named /dev/vg00/snap which has access to the
+Creates a striped logical volume with 3 stripes, a stripesize of 8KB 
+and a size of 100MB in the volume group named vg00.
+The logical volume name will be chosen by lvcreate:
+.sp
+.B lvcreate -i 3 -I 8 -L 100M vg00
+
+Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
+This operation would require 3 devices (or option --alloc anywhere) - two 
+for the mirror devices and one for the disk log.
+.sp
+.B lvcreate -m1 -L 500M vg00
+
+Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
+This operation would require 2 devices - the log is "in-memory".
+.sp
+.B lvcreate -m1 --mirrorlog core -L 500M vg00
+
+Creates a snapshot logical volume named /dev/vg00/snap which has access to the
 contents of the original logical volume named /dev/vg00/lvol1
 at snapshot logical volume creation time. If the original logical volume
 contains a file system, you can mount the snapshot logical volume on an
 arbitrary directory in order to access the contents of the filesystem to run
 a backup while the original filesystem continues to get updated.
+.sp
+.B lvcreate --size 100m --snapshot --name snap /dev/vg00/lvol1
 
-"lvcreate --virtualsize 1T --size 100M --snapshot --name sparse vg1"
-.br
-creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
+Creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
 under 100MB of actual data on it.
-.br
+.sp
+.B lvcreate --virtualsize 1T --size 100M --snapshot --name sparse vg1
 
-"lvcreate -L 64M -n lvol1 vg00 /dev/sda:0-7 /dev/sdb:0-7"
-.br
-creates a linear logical volume "vg00/lvol1" using physical extents
+Creates a linear logical volume "vg00/lvol1" using physical extents
 /dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
-.br
+.sp
+.B lvcreate -L 64M -n lvol1 vg00 /dev/sda:0-7 /dev/sdb:0-7
 
-"lvcreate --type raid5 -L 5G -i 3 -I 64 -n my_lv vg00"
-.br
-creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
+Creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
 a parity drive for a total of 4 devices) and a stripesize of 64kiB.
+.sp
+.B lvcreate --type raid5 -L 5G -i 3 -I 64 -n my_lv vg00
 
 .SH SEE ALSO
 .BR lvm (8), 


