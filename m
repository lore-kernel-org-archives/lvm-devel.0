From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 19:24:25 -0000
Subject: LVM2/man lvm.8
Message-ID: <20080111192425.8757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 19:24:25

Modified files:
	man            : lvm.8 

Log message:
	Update lvm man page to enumerate lvm tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/man/lvm.8	2007/03/30 21:00:25	1.10
+++ LVM2/man/lvm.8	2008/01/11 19:24:25	1.11
@@ -50,8 +50,94 @@
 .TP
 \fBversion\fP \(em Display version information.
 .LP
-The following commands are not implemented in LVM2 but might be
-in future: lvmsadc, lvmsar, pvdata, pvresize.
+.SH COMMANDS
+The following commands implement the core LVM functionality.
+.TP
+\fBpvchange\fP \(em Change attributes of a physical volume.
+.TP
+\fBpvck\fP \(em Check physical volume metadata.
+.TP
+\fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
+.TP
+\fBpvdisplay\fP \(em Display attributes of a physical volume.
+.TP
+\fBpvmove\fP \(em Move physical extents.
+.TP
+\fBpvremove\fP \(em Remove a physical volume.
+.TP
+\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
+.TP
+\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
+.TP
+\fBpvs\fP \(em Report information about physical volumes.
+.TP
+\fBpvscan\fP \(em Scan all disks for physical volumes.
+.TP
+\fBvgcfgbackup\fP \(em Backup volume group descriptor area.
+.TP
+\fBvgcfgrestore\fP \(em Restore volume group descriptor area.
+.TP
+\fBvgchange\fP \(em Change attributes of a volume group.
+.TP
+\fBvgck\fP \(em Check volume group metadata.
+.TP
+\fBvgconvert\fP \(em Convert volume group metadata format.
+.TP
+\fBvgcreate\fP \(em Create a volume group.
+.TP
+\fBvgdisplay\fP \(em Display attributes of volume groups.
+.TP
+\fBvgexport\fP \(em Make volume groups unknown to the system.
+.TP
+\fBvgextend\fP \(em Add physical volumes to a volume group.
+.TP
+\fBvgimport\fP \(em Make exported volume groups known to the system.
+.TP
+\fBvgmerge\fP \(em Merge two volume groups.
+.TP
+\fBvgmknodes\fP \(em Recreate volume group directory and logical volume special files
+.TP
+\fBvgreduce\fP \(em Reduce a volume group by removing one or more physical volumes.
+.TP
+\fBvgremove\fP \(em Remove a volume group.
+.TP
+\fBvgrename\fP \(em Rename a volume group.
+.TP
+\fBvgs\fP \(em Report information about volume groups.
+.TP
+\fBvgscan\fP \(em Scan all disks for volume groups and rebuild caches.
+.TP
+\fBvgsplit\fP \(em Split a volume group into two, moving any logical volumes from one volume group to another by moving entire physical volumes.
+.TP
+\fBlvchange\fP \(em Change attributes of a logical volume.
+.TP
+\fBlvconvert\fP \(em Convert a logical volume from linear to mirror or snapshot.
+.TP
+\fBlvcreate\fP \(em Create a logical volume in an existing volume group.
+.TP
+\fBlvdisplay\fP \(em Display attributes of a logical volume.
+.TP
+\fBlvextend\fP \(em Extend the size of a logical volume.
+.TP
+\fBlvmchange\fP \(em Change attributes of the logical volume manager.
+.TP
+\fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
+.TP
+\fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
+.TP
+\fBlvreduce\fP \(em Reduce the size of a logical volume.
+.TP
+\fBlvremove\fP \(em Remove a logical volume.
+.TP
+\fBlvrename\fP \(em Rename a logical volume.
+.TP
+\fBlvresize\fP \(em Resize a logical volume.
+.TP
+\fBlvs\fP \(em Report information about logical volumes.
+.TP
+\fBlvscan\fP \(em Scan (all disks) for logical volumes.
+.TP
+The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata, pvresize.
 .SH OPTIONS
 The following options are available for many of the commands. 
 They are implemented generically and documented here rather 


