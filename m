From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 01:58:43 +0200
Subject: patch3/4
Message-ID: <1282262323.3337.96.camel@fermat.scientia.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

3) lvm.8.reordering+pvcreate.patch
It seems that right now, neither built-in commands nor commands are
ordered
alphabetically.
The patch orders them in a (IMHO) better way, especially:
First VG-, then PV-, then LV-, then "general"-commands.
In each section I also made some grouping, e.g. commands that do display
stuff,
create/remove/rename, resize/extend, etc.
Please check, that (when copy&pasting around) I did not accidentally
drop one ;)

Another thing done by the patch: For pvcreate it's hinted (by "etc")
that not
only disks and partitions can serve as PV. (e.g. md devices, or
dm-crypt, etc.)




--- lvm.8	2010-06-23 16:25:44.099108000 +0200
+++ lvm.8	2010-06-23 16:57:07.394112635 +0200
@@ -41,105 +41,104 @@
 The following commands are built into lvm without links normally
 being created in the filesystem for them.
 .TP
-\fBdumpconfig\fP \(em Display the configuration information after 
-loading \fBlvm.conf\fP (5) and any other configuration files.
+\fBdumpconfig\fP \(em Display the configuration information after
loading \fBlvm.conf\fP (5) and any other configuration files.
 .TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
-\fBhelp\fP \(em Display the help text.
-.TP
 \fBpvdata\fP \(em Not implemented in LVM2.
 .TP
 \fBsegtypes\fP \(em Display recognised logical volume segment types.
 .TP
+\fBhelp\fP \(em Display the help text.
+.TP
 \fBversion\fP \(em Display version information.
 .LP
 .SH COMMANDS
 The following commands implement the core LVM functionality.
 .TP
-\fBpvchange\fP \(em Change attributes of a physical volume.
-.TP
-\fBpvck\fP \(em Check physical volume metadata.
-.TP
-\fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
-.TP
-\fBpvdisplay\fP \(em Display attributes of a physical volume.
+\fBvgs\fP \(em Report information about volume groups.
 .TP
-\fBpvmove\fP \(em Move physical extents.
+\fBvgdisplay\fP \(em Display attributes of volume groups.
 .TP
-\fBpvremove\fP \(em Remove a physical volume.
+\fBvgscan\fP \(em Scan all disks for volume groups and rebuild caches.
 .TP
-\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
+\fBvgcreate\fP \(em Create a volume group.
 .TP
-\fBpvs\fP \(em Report information about physical volumes.
+\fBvgremove\fP \(em Remove a volume group.
 .TP
-\fBpvscan\fP \(em Scan all disks for physical volumes.
+\fBvgrename\fP \(em Rename a volume group.
 .TP
-\fBvgcfgbackup\fP \(em Backup volume group descriptor area.
+\fBvgchange\fP \(em Change attributes of a volume group.
 .TP
-\fBvgcfgrestore\fP \(em Restore volume group descriptor area.
+\fBvgextend\fP \(em Add physical volumes to a volume group.
 .TP
-\fBvgchange\fP \(em Change attributes of a volume group.
+\fBvgreduce\fP \(em Reduce a volume group by removing one or more
physical volumes.
 .TP
 \fBvgck\fP \(em Check volume group metadata.
 .TP
-\fBvgconvert\fP \(em Convert volume group metadata format.
-.TP
-\fBvgcreate\fP \(em Create a volume group.
+\fBvgmerge\fP \(em Merge two volume groups.
 .TP
-\fBvgdisplay\fP \(em Display attributes of volume groups.
+\fBvgsplit\fP \(em Split a volume group into two, moving any logical
volumes from one volume group to another by moving entire physical
volumes.
 .TP
 \fBvgexport\fP \(em Make volume groups unknown to the system.
 .TP
-\fBvgextend\fP \(em Add physical volumes to a volume group.
-.TP
 \fBvgimport\fP \(em Make exported volume groups known to the system.
 .TP
-\fBvgimportclone\fP \(em Import and rename duplicated volume group
(e.g. a hardware snapshot).
+\fBvgcfgbackup\fP \(em Backup volume group descriptor area.
 .TP
-\fBvgmerge\fP \(em Merge two volume groups.
+\fBvgcfgrestore\fP \(em Restore volume group descriptor area.
 .TP
-\fBvgmknodes\fP \(em Recreate volume group directory and logical volume
special files
+\fBvgimportclone\fP \(em Import and rename duplicated volume group
(e.g. a hardware snapshot).
 .TP
-\fBvgreduce\fP \(em Reduce a volume group by removing one or more
physical volumes.
+\fBvgmknodes\fP \(em Recreate volume group directory and logical volume
special files
 .TP
-\fBvgremove\fP \(em Remove a volume group.
+\fBvgconvert\fP \(em Convert volume group metadata format.
 .TP
-\fBvgrename\fP \(em Rename a volume group.
+\fBpvs\fP \(em Report information about physical volumes.
 .TP
-\fBvgs\fP \(em Report information about volume groups.
+\fBpvdisplay\fP \(em Display attributes of a physical volume.
 .TP
-\fBvgscan\fP \(em Scan all disks for volume groups and rebuild caches.
+\fBpvscan\fP \(em Scan all disks for physical volumes.
 .TP
-\fBvgsplit\fP \(em Split a volume group into two, moving any logical
volumes from one volume group to another by moving entire physical
volumes.
+\fBpvcreate\fP \(em Initialize a disk, partition, etc. as physical
volume for use by LVM.
 .TP
-\fBlvchange\fP \(em Change attributes of a logical volume.
+\fBpvremove\fP \(em Remove a physical volume.
 .TP
-\fBlvconvert\fP \(em Convert a logical volume from linear to mirror or
snapshot.
+\fBpvchange\fP \(em Change attributes of a physical volume.
 .TP
-\fBlvcreate\fP \(em Create a logical volume in an existing volume
group.
+\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
 .TP
-\fBlvdisplay\fP \(em Display attributes of a logical volume.
+\fBpvck\fP \(em Check physical volume metadata.
 .TP
-\fBlvextend\fP \(em Extend the size of a logical volume.
+\fBpvmove\fP \(em Move physical extents.
 .TP
-\fBlvmchange\fP \(em Change attributes of the logical volume manager.
+\fBlvs\fP \(em Report information about logical volumes.
 .TP
-\fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
+\fBlvdisplay\fP \(em Display attributes of a logical volume.
 .TP
-\fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic
purposes.
+\fBlvscan\fP \(em Scan (all disks) for logical volumes.
 .TP
-\fBlvreduce\fP \(em Reduce the size of a logical volume.
+\fBlvcreate\fP \(em Create a logical volume in an existing volume
group.
 .TP
 \fBlvremove\fP \(em Remove a logical volume.
 .TP
 \fBlvrename\fP \(em Rename a logical volume.
 .TP
+\fBlvchange\fP \(em Change attributes of a logical volume.
+.TP
 \fBlvresize\fP \(em Resize a logical volume.
 .TP
-\fBlvs\fP \(em Report information about logical volumes.
+\fBlvextend\fP \(em Extend the size of a logical volume.
 .TP
-\fBlvscan\fP \(em Scan (all disks) for logical volumes.
+\fBlvreduce\fP \(em Reduce the size of a logical volume.
+.TP
+\fBlvconvert\fP \(em Convert a logical volume from linear to mirror or
snapshot.
+.TP
+\fBlvmchange\fP \(em Change attributes of the logical volume manager.
+.TP
+\fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
+.TP
+\fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic
purposes.
 .TP
 The following commands are not implemented in LVM2 but might be in the
future: lvmsadc, lvmsar, pvdata.
 .SH OPTIONS


