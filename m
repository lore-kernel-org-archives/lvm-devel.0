From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 01:07:54 +0000 (UTC)
Subject: master - man: document allocation process in lvm.8
Message-ID: <20120807010754.8FBCF3604@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=016997acaf8bc59e5b48e9b33ef2db0596e25063
Commit:        016997acaf8bc59e5b48e9b33ef2db0596e25063
Parent:        6e55201144be3bcf82b6aafe7e9f7430318719d0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 02:06:42 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 02:06:42 2012 +0100

man: document allocation process in lvm.8

---
 WHATS_NEW    |    1 +
 man/lvm.8.in |  190 +++++++++++++++++++++++++++++++++++++++-------------------
 2 files changed, 130 insertions(+), 61 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eab7e99..2c4d139 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Improve documention of allocation policies in lvm.8.
   Increase limit for major:minor to 4095:1048575 when using -My option.
   Add make install_systemd_generators.
   Add generator for lvm2 activation systemd units.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index cf5d4bc..a2108ed 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -50,96 +50,99 @@ loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBpvdata\fP \(em Not implemented in LVM2.
 .TP
-\fBsegtypes\fP \(em Display recognised logical volume segment types.
+\fBsegtypes\fP \(em Display recognised Logical Volume segment types.
 .TP
 \fBversion\fP \(em Display version information.
 .LP
 .SH COMMANDS
 The following commands implement the core LVM functionality.
 .TP
-\fBpvchange\fP \(em Change attributes of a physical volume.
+\fBpvchange\fP \(em Change attributes of a Physical Volume.
 .TP
-\fBpvck\fP \(em Check physical volume metadata.
+\fBpvck\fP \(em Check Physical Volume metadata.
 .TP
 \fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
 .TP
-\fBpvdisplay\fP \(em Display attributes of a physical volume.
+\fBpvdisplay\fP \(em Display attributes of a Physical Volume.
 .TP
-\fBpvmove\fP \(em Move physical extents.
+\fBpvmove\fP \(em Move Physical Extents.
 .TP
-\fBpvremove\fP \(em Remove a physical volume.
+\fBpvremove\fP \(em Remove a Physical Volume.
 .TP
 \fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
 .TP
-\fBpvs\fP \(em Report information about physical volumes.
+\fBpvs\fP \(em Report information about Physical Volumes.
 .TP
-\fBpvscan\fP \(em Scan all disks for physical volumes.
+\fBpvscan\fP \(em Scan all disks for Physical Volumes.
 .TP
-\fBvgcfgbackup\fP \(em Backup volume group descriptor area.
+\fBvgcfgbackup\fP \(em Backup Volume Group descriptor area.
 .TP
-\fBvgcfgrestore\fP \(em Restore volume group descriptor area.
+\fBvgcfgrestore\fP \(em Restore Volume Group descriptor area.
 .TP
-\fBvgchange\fP \(em Change attributes of a volume group.
+\fBvgchange\fP \(em Change attributes of a Volume Group.
 .TP
-\fBvgck\fP \(em Check volume group metadata.
+\fBvgck\fP \(em Check Volume Group metadata.
 .TP
-\fBvgconvert\fP \(em Convert volume group metadata format.
+\fBvgconvert\fP \(em Convert Volume Group metadata format.
 .TP
-\fBvgcreate\fP \(em Create a volume group.
+\fBvgcreate\fP \(em Create a Volume Group.
 .TP
-\fBvgdisplay\fP \(em Display attributes of volume groups.
+\fBvgdisplay\fP \(em Display attributes of Volume Groups.
 .TP
-\fBvgexport\fP \(em Make volume groups unknown to the system.
+\fBvgexport\fP \(em Make volume Groups unknown to the system.
 .TP
-\fBvgextend\fP \(em Add physical volumes to a volume group.
+\fBvgextend\fP \(em Add Physical Volumes to a Volume Group.
 .TP
-\fBvgimport\fP \(em Make exported volume groups known to the system.
+\fBvgimport\fP \(em Make exported Volume Groups known to the system.
 .TP
-\fBvgimportclone\fP \(em Import and rename duplicated volume group (e.g. a hardware snapshot).
+\fBvgimportclone\fP \(em Import and rename duplicated Volume Group (e.g. a hardware snapshot).
 .TP
-\fBvgmerge\fP \(em Merge two volume groups.
+\fBvgmerge\fP \(em Merge two Volume Groups.
 .TP
-\fBvgmknodes\fP \(em Recreate volume group directory and logical volume special files
+\fBvgmknodes\fP \(em Recreate Volume Group directory and Logical Volume special files
 .TP
-\fBvgreduce\fP \(em Reduce a volume group by removing one or more physical volumes.
+\fBvgreduce\fP \(em Reduce a Volume Group by removing one or more
+Physical Volumes.
 .TP
-\fBvgremove\fP \(em Remove a volume group.
+\fBvgremove\fP \(em Remove a Volume Group.
 .TP
-\fBvgrename\fP \(em Rename a volume group.
+\fBvgrename\fP \(em Rename a Volume Group.
 .TP
-\fBvgs\fP \(em Report information about volume groups.
+\fBvgs\fP \(em Report information about Volume Groups.
 .TP
-\fBvgscan\fP \(em Scan all disks for volume groups and rebuild caches.
+\fBvgscan\fP \(em Scan all disks for Volume Groups and rebuild caches.
 .TP
-\fBvgsplit\fP \(em Split a volume group into two, moving any logical volumes from one volume group to another by moving entire physical volumes.
+\fBvgsplit\fP \(em Split a Volume Group into two, moving any logical
+volumes from one Volume Group to another by moving entire Physical
+Volumes.
 .TP
-\fBlvchange\fP \(em Change attributes of a logical volume.
+\fBlvchange\fP \(em Change attributes of a Logical Volume.
 .TP
-\fBlvconvert\fP \(em Convert a logical volume from linear to mirror or snapshot.
+\fBlvconvert\fP \(em Convert a Logical Volume from linear to mirror or snapshot.
 .TP
-\fBlvcreate\fP \(em Create a logical volume in an existing volume group.
+\fBlvcreate\fP \(em Create a Logical Volume in an existing Volume Group.
 .TP
-\fBlvdisplay\fP \(em Display attributes of a logical volume.
+\fBlvdisplay\fP \(em Display attributes of a Logical Volume.
 .TP
-\fBlvextend\fP \(em Extend the size of a logical volume.
+\fBlvextend\fP \(em Extend the size of a Logical Volume.
 .TP
-\fBlvmchange\fP \(em Change attributes of the logical volume manager.
+\fBlvmchange\fP \(em Change attributes of the Logical Volume Manager.
 .TP
 \fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
 .TP
 \fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
 .TP
-\fBlvreduce\fP \(em Reduce the size of a logical volume.
+\fBlvreduce\fP \(em Reduce the size of a Logical Volume.
 .TP
-\fBlvremove\fP \(em Remove a logical volume.
+\fBlvremove\fP \(em Remove a Logical Volume.
 .TP
-\fBlvrename\fP \(em Rename a logical volume.
+\fBlvrename\fP \(em Rename a Logical Volume.
 .TP
-\fBlvresize\fP \(em Resize a logical volume.
+\fBlvresize\fP \(em Resize a Logical Volume.
 .TP
-\fBlvs\fP \(em Report information about logical volumes.
+\fBlvs\fP \(em Report information about Logical Volumes.
 .TP
-\fBlvscan\fP \(em Scan (all disks) for logical volumes.
+\fBlvscan\fP \(em Scan (all disks) for Logical Volumes.
 .TP
 The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
 .SH OPTIONS
@@ -183,13 +186,13 @@ You are strongly advised not to disable this!
 See \fBvgcfgbackup\fP(8).
 .TP
 .BR \-P ", " \-\-partial
-When set, the tools will do their best to provide access to volume groups
-that are only partially available (one or more physical volumes belonging
-to the volume group are missing from the system).  Where part of a logical
+When set, the tools will do their best to provide access to Volume Groups
+that are only partially available (one or more Physical Volumes belonging
+to the Volume Group are missing from the system).  Where part of a logical
 volume is missing, \fB/dev/ioerror\fP will be substituted, and you could use
 \fBdmsetup\fP(8) to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
-changed with this option. To insert a replacement physical volume
+changed with this option. To insert a replacement Physical Volume
 of the same or large size use \fBpvcreate \-u\fP to set the uuid to
 match the original followed by \fBvgcfgrestore\fP(8).
 .TP
@@ -239,27 +242,23 @@ The allocation policy to use:
 .IR normal ,
 .IR anywhere " or"
 .IR inherit .
-When a command needs to allocate physical extents from the volume group,
+When a command needs to allocate Physical Extents from the Volume Group,
 the allocation policy controls how they are chosen.
-Each volume group and logical volume has an allocation policy.
-The default for a volume group is \fInormal\fP which applies
+Each Volume Group and Logical Volume has an allocation policy defined.
+The default for a Volume Group is \fInormal\fP which applies
 common-sense rules such as not placing parallel stripes on the same
-physical volume.  The default for a logical volume is \fIinherit\fP
-which applies the same policy as for the volume group.  These policies can
-be changed using \fBlvchange\fP(8) and \fBvgchange\fP(8) or over-ridden
+Physical Volume.  The default for a Logical Volume is \fIinherit\fP
+which applies the same policy as for the Volume Group.  These policies can
+be changed using \fBlvchange\fP(8) and \fBvgchange\fP(8) or overridden
 on the command line of any command that performs allocation.
-The \fIcontiguous\fP policy requires that new extents be placed adjacent
-to existing extents.
-The \fIcling\fP policy places new extents on the same physical
-volume as existing extents in the same stripe of the Logical Volume.
-If there are sufficient free extents to satisfy
+The \fIcontiguous\fP policy requires that new Physical Extents be placed adjacent
+to existing Physical Extents.
+The \fIcling\fP policy places new Physical Extents on the same Physical
+Volume as existing Physical Extents in the same stripe of the Logical Volume.
+If there are sufficient free Physical Extents to satisfy
 an allocation request but \fInormal\fP doesn't use them,
 \fIanywhere\fP will - even if that reduces performance by
-placing two stripes on the same physical volume.
-.IP
-N.B. The policies described above are not implemented fully yet.
-In particular, contiguous free space cannot be broken up to
-satisfy allocation attempts.
+placing two stripes on the same Physical Volume.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B HOME
@@ -271,8 +270,8 @@ Directory containing \fBlvm.conf\fP(5) and other LVM system files.
 Defaults to "#DEFAULT_SYS_DIR#".
 .TP
 .B LVM_VG_NAME
-The volume group name that is assumed for
-any reference to a logical volume that doesn't specify a path.
+The Volume Group name that is assumed for
+any reference to a Logical Volume that doesn't specify a path.
 Not set by default.
 .SH VALID NAMES
 The following characters are valid for VG and LV names:
@@ -283,8 +282,77 @@ There are also various reserved names that are used internally by lvm that can n
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
 the strings '_mlog', '_mimage', '_rimage', '_tdata', '_tmeta'.
+.SH ALLOCATION
+When an operation needs to allocate Physical Extents for one or more
+Logical Volumes, the tools proceed as follows:
 
+First of all, they generate the complete set of unallocated Physical Extents
+in the Volume Group.  If any ranges of Physical Extents are supplied at
+the end of the command line, only unallocated Physical Extents within
+those ranges on the specified Physical Volumes are considered.
 
+Then they try each allocation policy in turn, starting with the strictest
+policy (\fIcontiguous\fP) and ending with the allocation policy specified
+using \fB\-\-alloc\fP or set as the default for the particular Logical
+Volume or Volume Group concerned.  For each policy, working from the
+lowest-numbered Logical Extent of the empty Logical Volume space that
+needs to be filled, they allocate as much space as possible according to
+the restrictions imposed by the policy.  If more space is needed,
+they move on to the next policy.
+
+The restrictions are as follows:
+
+\fIContiguous\fP requires that the physical location of any Logical
+Extent that is not the first Logical Extent of a Logical Volume is
+adjacent to the physical location of the Logical Extent immediately
+preceding it.
+
+\fICling\fP requires that the Physical Volume used for any Logical
+Extent to be added to an existing Logical Volume is already in use by at
+least one Logical Extent earlier in that Logical Volume.  If the
+configuration parameter allocation/cling_tag_list is defined, then two
+Physical Volumes are considered to match if any of the listed tags is
+present on both Physical Volumes.  This allows groups of Physical
+Volumes with similar properties (such as their physical location) to be
+tagged and treated as equivalent for allocation purposes.
+
+When a Logical Volume is striped or mirrored, the above restrictions are
+applied independently to each stripe or mirror image (leg) that needs
+space.
+
+\fINormal\fP will not choose a Physical Extent that shares the same Physical
+Volume as a Logical Extent already allocated to a parallel Logical
+Volume (i.e. a different stripe or mirror image/leg) at the same offset 
+within that parallel Logical Volume.
+
+When allocating a mirror log at the same time as Logical Volumes to hold
+the mirror data, Normal will first try to select different Physical
+Volumes for the log and the data.  If that's not possible and the
+allocation/mirror_logs_require_separate_pvs configuration parameter is
+set to 0, it will then allow the log to share Physical Volume(s) with
+part of the data.  
+
+When allocating thin pool metadata, similar considerations to those of a
+mirror log in the last paragraph apply based on the value of the
+allocation/thin_pool_metadata_require_separate_pvs configuration
+parameter.
+
+If you rely upon any layout behaviour beyond that documented here, be
+aware that it might change in future versions of the code.  
+
+For example, if you supply on the command line two empty Physical
+Volumes that have an identical number of free Physical Extents available for
+allocation, the current code considers using each of them in the order
+they are listed, but there is no guarantee that future releases will
+maintain that property.  If it is important to obtain a specific layout
+for a particular Logical Volume, then you should build it up through a
+sequence of \fBlvcreate\fP(8) and \fBlvconvert\fP(8) steps such that the
+restrictions described above applied to each step leave the tools no
+discretion over the layout.
+
+To view the way the allocation process currently works in any specific
+case, read the debug logging output, for example by adding \-vvvv to
+a command.
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
 .SH FILES


