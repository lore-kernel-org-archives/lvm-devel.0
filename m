From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:45:59 +0000 (UTC)
Subject: master - man: use PD/HP for compressed lines
Message-ID: <20150918154559.C84FB606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=330d584617778b2ac3a852d482c6b8d49818d9eb
Commit:        330d584617778b2ac3a852d482c6b8d49818d9eb
Parent:        11d6f81316bb49adee80e4e128b208c50c42cd1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 16:15:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:46 2015 +0200

man: use PD/HP for compressed lines

Using .PD 0  to user zero spacing together with .HP is the best way
for condensed list of commands.
---
 man/lvm.8.in |  115 ++++++++++++++++++++++++++++++----------------------------
 1 files changed, 59 insertions(+), 56 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index c8e6484..daab791 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -42,122 +42,125 @@ path of \fBlvm\fP.
 .SH BUILT-IN COMMANDS
 The following commands are built into lvm without links normally
 being created in the filesystem for them.
-.TP
+.PD 0
+.HP
 \fBconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
-.TP
+.HP
 \fBdevtypes\fP \(em Display the recognised built-in block device types.
-.TP
+.HP
 \fBdumpconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
-.TP
+.HP
 \fBformats\fP \(em Display recognised metadata formats.
-.TP
+.HP
 \fBhelp\fP \(em Display the help text.
-.TP
+.HP
 \fBlvpoll\fP \(em Internal command used by lvmpolld to complete some Logical Volume operations.
-.TP
+.HP
 \fBpvdata\fP \(em Not implemented in LVM2.
-.TP
+.HP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.
-.TP
+.HP
 \fBsystemid\fP \(em Display the system ID, if any, currently set on this host.
-.TP
+.HP
 \fBtags\fP \(em Display any tags defined on this host.
-.TP
+.HP
 \fBversion\fP \(em Display version information.
-.LP
+.PD
 .SH COMMANDS
 The following commands implement the core LVM functionality.
-.TP
+.PD 0
+.HP
 \fBpvchange\fP \(em Change attributes of a Physical Volume.
-.TP
+.HP
 \fBpvck\fP \(em Check Physical Volume metadata.
-.TP
+.HP
 \fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
-.TP
+.HP
 \fBpvdisplay\fP \(em Display attributes of a Physical Volume.
-.TP
+.HP
 \fBpvmove\fP \(em Move Physical Extents.
-.TP
+.HP
 \fBpvremove\fP \(em Remove a Physical Volume.
-.TP
+.HP
 \fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
-.TP
+.HP
 \fBpvs\fP \(em Report information about Physical Volumes.
-.TP
+.HP
 \fBpvscan\fP \(em Scan all disks for Physical Volumes.
-.TP
+.HP
 \fBvgcfgbackup\fP \(em Backup Volume Group descriptor area.
-.TP
+.HP
 \fBvgcfgrestore\fP \(em Restore Volume Group descriptor area.
-.TP
+.HP
 \fBvgchange\fP \(em Change attributes of a Volume Group.
-.TP
+.HP
 \fBvgck\fP \(em Check Volume Group metadata.
-.TP
+.HP
 \fBvgconvert\fP \(em Convert Volume Group metadata format.
-.TP
+.HP
 \fBvgcreate\fP \(em Create a Volume Group.
-.TP
+.HP
 \fBvgdisplay\fP \(em Display attributes of Volume Groups.
-.TP
+.HP
 \fBvgexport\fP \(em Make volume Groups unknown to the system.
-.TP
+.HP
 \fBvgextend\fP \(em Add Physical Volumes to a Volume Group.
-.TP
+.HP
 \fBvgimport\fP \(em Make exported Volume Groups known to the system.
-.TP
+.HP
 \fBvgimportclone\fP \(em Import and rename duplicated Volume Group (e.g. a hardware snapshot).
-.TP
+.HP
 \fBvgmerge\fP \(em Merge two Volume Groups.
-.TP
+.HP
 \fBvgmknodes\fP \(em Recreate Volume Group directory and Logical Volume special files
-.TP
+.HP
 \fBvgreduce\fP \(em Reduce a Volume Group by removing one or more
 Physical Volumes.
-.TP
+.HP
 \fBvgremove\fP \(em Remove a Volume Group.
-.TP
+.HP
 \fBvgrename\fP \(em Rename a Volume Group.
-.TP
+.HP
 \fBvgs\fP \(em Report information about Volume Groups.
-.TP
+.HP
 \fBvgscan\fP \(em Scan all disks for Volume Groups and rebuild caches.
-.TP
+.HP
 \fBvgsplit\fP \(em Split a Volume Group into two, moving any logical
 volumes from one Volume Group to another by moving entire Physical
 Volumes.
-.TP
+.HP
 \fBlvchange\fP \(em Change attributes of a Logical Volume.
-.TP
+.HP
 \fBlvconvert\fP \(em Convert a Logical Volume from linear to mirror or snapshot.
-.TP
+.HP
 \fBlvcreate\fP \(em Create a Logical Volume in an existing Volume Group.
-.TP
+.HP
 \fBlvdisplay\fP \(em Display attributes of a Logical Volume.
-.TP
+.HP
 \fBlvextend\fP \(em Extend the size of a Logical Volume.
-.TP
+.HP
 \fBlvmchange\fP \(em Change attributes of the Logical Volume Manager.
-.TP
+.HP
 \fBlvmconfig\fP \(em Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
-.TP
+.HP
 \fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
-.TP
+.HP
 \fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
-.TP
+.HP
 \fBlvreduce\fP \(em Reduce the size of a Logical Volume.
-.TP
+.HP
 \fBlvremove\fP \(em Remove a Logical Volume.
-.TP
+.HP
 \fBlvrename\fP \(em Rename a Logical Volume.
-.TP
+.HP
 \fBlvresize\fP \(em Resize a Logical Volume.
-.TP
+.HP
 \fBlvs\fP \(em Report information about Logical Volumes.
-.TP
+.HP
 \fBlvscan\fP \(em Scan (all disks) for Logical Volumes.
-.TP
+.PD
+.HP
 The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
 .SH OPTIONS
 The following options are available for many of the commands.


