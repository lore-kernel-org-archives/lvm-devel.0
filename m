From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 28 May 2010 03:50:19 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM man/lvcreate.8.in
Message-ID: <20100528035019.20553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-05-28 03:50:19

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	man            : lvcreate.8.in 

Log message:
	Add --type parameter description to the lvcreate man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1599&r2=1.1600
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.374&r2=1.375
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2010/05/27 19:00:14	1.1599
+++ LVM2/WHATS_NEW	2010/05/28 03:50:15	1.1600
@@ -1,6 +1,6 @@
 Version 2.02.67 -
 ===============================
-  Document 'clear' in dmsetup man page.
+  Add --type parameter description to the lvcreate man page.
   Replace strncmp kernel version number checks with proper ones.
   Avoid selecting names under /dev/block if there is an alternative.
   Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
--- LVM2/WHATS_NEW_DM	2010/05/27 15:02:56	1.374
+++ LVM2/WHATS_NEW_DM	2010/05/28 03:50:15	1.375
@@ -1,5 +1,6 @@
 Version 1.02.49 - 
 ================================
+  Document 'clear' in dmsetup man page.
   Use expected union semun for arguments in selected semaphore operations.
 
 Version 1.02.48 - 17th May 2010
--- LVM2/man/lvcreate.8.in	2010/03/26 22:15:43	1.17
+++ LVM2/man/lvcreate.8.in	2010/05/28 03:50:18	1.18
@@ -18,6 +18,7 @@
 [\-n|\-\-name LogicalVolumeName]
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
 [\-t|\-\-test]
+[\-\-type SegmentType]
 [\-v|\-\-verbose] [\-Z|\-\-zero y|n]
 VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
 .br
@@ -183,6 +184,14 @@
 rate at which the snapshot data is growing so you can avoid running out
 of space.
 .TP
+.I \-\-type SegmentType
+Create a logical volume that uses the specified segment type
+(e.g. "mirror", "snapshot", "striped").  Especially useful when no
+existing commandline switch alias enables the use of the desired type
+(e.g. "error" or "zero" types).  Many segment types already have a
+commandline switch alias that will enable their use (-s is an alias for
+--type snapshot).
+.TP
 .I \-\-virtualsize VirtualSize
 Create a sparse device of the given size (in MB by default) using a snapshot.  
 Anything written to the device will be returned when reading from it.


