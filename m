From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Apr 2011 16:22:48 -0000
Subject: LVM2/man pvmove.8.in
Message-ID: <20110428162248.4318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-28 16:22:48

Modified files:
	man            : pvmove.8.in 

Log message:
	Adjust pvmove man page wording.
	
	Add missing --alloc anywhere to example and mention that snapshots and
	mirrors can't be moved.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/pvmove.8.in	2011/02/09 22:24:55	1.5
+++ LVM2/man/pvmove.8.in	2011/04/28 16:22:47	1.6
@@ -21,7 +21,7 @@
 .IR DestinationPhysicalVolume (s).
 If no
 .I DestinationPhysicalVolume
-is specified, the normal allocation rules for the volume group are used.
+is specified, the normal allocation rules for the Volume Group are used.
 
 If \fBpvmove\fP gets interrupted for any reason (e.g. the machine crashes)
 then run \fBpvmove\fP again without any PhysicalVolume arguments to
@@ -31,15 +31,15 @@
 
 You can run more than one pvmove at once provided they are moving data
 off different SourcePhysicalVolumes, but additional pvmoves will ignore
-any logical volumes already in the process of being changed, so some
+any Logical Volumes already in the process of being changed, so some
 data might not get moved.
 
 \fBpvmove\fP works as follows:
 
-1. A temporary 'pvmove' logical volume is created to store
+1. A temporary 'pvmove' Logical Volume is created to store
 details of all the data movements required.
 
-2. Every logical volume in the volume group is searched
+2. Every Logical Volume in the Volume Group is searched
 for contiguous data that need moving
 according to the command line arguments.
 For each piece of data found, a new segment is added to the end of the
@@ -49,25 +49,27 @@
 The original LV is updated to use the new temporary mirror segment
 in the pvmove LV instead of accessing the data directly.
 
-3. The volume group metadata is updated on disk.
+3. The Volume Group metadata is updated on disk.
 
-4. The first segment of the pvmove logical volume is activated and starts
+4. The first segment of the pvmove Logical Volume is activated and starts
 to mirror the first part of the data.  Only one segment is mirrored at once
 as this is usually more efficient.
 
 5. A daemon repeatedly checks progress at the specified time interval.
 When it detects that the first temporary mirror is in-sync,
 it breaks that mirror so that only the new location for that data gets used 
-and writes a checkpoint into the volume group metadata on disk.
+and writes a checkpoint into the Volume Group metadata on disk.
 Then it activates the mirror for the next segment of the pvmove LV.
 
 6. When there are no more segments left to be mirrored, 
-the temporary logical volume is removed and the volume group metadata 
-is updated so that the logical volumes reflect the new data locations.
+the temporary Logical Volume is removed and the Volume Group metadata 
+is updated so that the Logical Volumes reflect the new data locations.
 
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
 
+N.B. The moving of mirrors, snapshots and their origins is not yet supported.
+
 .SH OPTIONS
 .TP
 .I \-\-abort
@@ -94,38 +96,54 @@
 instead of all allocated extents to the destination physical volume(s).
 
 .SH EXAMPLES
-To move all logical extents of any logical volumes on
+To move all Physical Extents that are used by simple Logical Volumes on
 .B /dev/sdb1
-to free physical extents elsewhere in the volume group, use:
+to free Physical Extents elsewhere in the Volume Group use:
 .sp
 \	pvmove /dev/sdb1
 .P
-Additionally, the destination device can be specified.
+Any mirrors, snapshots and their origins are left unchanged.
+.P
+Additionally, a specific destination device
+.B /dev/sdc1
+can be specified like this:
 .sp
 \	pvmove /dev/sdb1 /dev/sdc1
 .P
-It is possible to perform the action on a single logical volume (instead of all
-the logical volumes that might be on the source device), like this:
+To perform the action only on extents belonging to the single Logical Volume 
+.B lvol1
+do this:
 .sp
 \	pvmove -n lvol1 /dev/sdb1 /dev/sdc1
 .P
 Rather than moving the contents of the entire device, it is possible to
-move a range of extents.
+move a range of Physical Extents - for example numbers 1000 to 1999 inclusive on
+.B /dev/sdb1
+- like this:
 .sp
 \	pvmove /dev/sdb1:1000-1999
 .P
-It is possible to move the range of extents to a specific location (as long
-as the location has sufficent free extents) - even on the same device.
+To move a range of Physical Extents to a specific location (which must have
+sufficent free extents) use the form:
 .sp
 \	pvmove /dev/sdb1:1000-1999 /dev/sdc1
 .sp
-\	pvmove /dev/sdb1:1000-1999 /dev/sdb1:0-999
+or
+.sp
+\	pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
 .P
-A specific logical volume in a range of extents can also be picked out and
-moved.
+If the source and destination are on the same disk, the 
+.B anywhere
+allocation policy would be needed, like this:
+.sp
+\	pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
+.P
+
+The part of a specific Logical Volume present within in a range of Physical
+Extents can also be picked out and moved, like this:
 .sp
 \	pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgconvert (8)
-.BR pvs (8)
\ No newline at end of file
+.BR pvs (8)

