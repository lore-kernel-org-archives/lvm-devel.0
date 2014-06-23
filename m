From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Jun 2014 13:01:56 +0000 (UTC)
Subject: master - man: More /dev/vg and /dev/mapper documentation.
Message-ID: <20140623130156.D906C60564@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=867b92b031b4913213c335bd0bf7363e934f379d
Commit:        867b92b031b4913213c335bd0bf7363e934f379d
Parent:        9c3c35787423b3b3d29fdb6a86cf796a1847cce4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jun 23 14:01:31 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jun 23 14:01:31 2014 +0100

man: More /dev/vg and /dev/mapper documentation.

---
 man/dmsetup.8.in  |    8 +++++++-
 man/lvchange.8.in |   13 ++++++++++++-
 man/lvm.8.in      |    9 +++++++++
 man/vgchange.8.in |    9 +++++++++
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index b545dcf..b18b0b0 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -502,7 +502,13 @@ Sets the device geometry to C/H/S.
 .RI [ subsystem ]
 .br
 Splits given device name into subsystem constituents.
-Default subsystem is LVM.
+The default subsystem is LVM.  
+LVM currently generates device names by concatenating the names of the Volume
+Group, Logical Volume and any internal Layer with a hyphen as separator.
+Any hyphens within the names are doubled to escape them.
+The precise encoding might change without notice in any future
+release, so we recommend you always decode using the current version of
+this command.
 .br
 .TP
 .B status
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 5c896e0..f7aee8f 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -72,7 +72,18 @@ See \fBlvm\fP(8) for common options.
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\-ay) or deactivate (\-an) the
-logical volumes. If autoactivation option is used (\-aay),
+logical volumes. 
+.IP
+Activation of a logical volume creates a symbolic link
+/dev/VolumeGroupName/LogicalVolumeName pointing to the device node.
+This link is removed on deactivation.
+All software and scripts should access the device through
+this symbolic link and present this as the name of the device.
+The location and name of the underlying device node may depend on 
+the distribution and configuration (e.g. udev) and might change 
+from release to release.
+.IP
+If autoactivation option is used (\-aay),
 the logical volume is activated only if it matches an item in
 the activation/auto_activation_volume_list set in lvm.conf.
 If this list is not set, then all volumes are considered for
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 0a5c69c..76d1237 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -347,6 +347,14 @@ There are also various reserved names that are used internally by lvm that can n
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
 the strings '_mlog', '_mimage', '_rimage', '_tdata', '_tmeta'.
+A directory bearing the name of each Volume Group is created under /dev when any of its Logical Volumes are activated.
+Each active Logical Volume is accessible from this directory as a symbolic link leading to a device node.
+Links or nodes in /dev/mapper are intended only for internal use and the precise format and escaping might change between releases and distributions.
+Other software and scripts should use the
+/dev/VolumeGroupName/LogicalVolumeName format to reduce the chance of needing
+amendment when the software is updated.  Should you need to process the node
+names in /dev/mapper, you may use \fBdmsetup splitname\fP to separate out the
+original VG, LV and internal layer names.
 .SH ALLOCATION
 When an operation needs to allocate Physical Extents for one or more
 Logical Volumes, the tools proceed as follows:
@@ -500,6 +508,7 @@ All tools return a status code of zero on success or non-zero on failure.
 .BR lvmthin (7),
 .BR lvm\ dumpconfig (8),
 .BR clvmd (8),
+.BR dmsetup (8),
 .BR lvchange (8),
 .BR lvcreate (8),
 .BR lvdisplay (8),
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 284a655..9ea2f65 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -83,6 +83,15 @@ The \-aay option should be also used during system boot so it's
 possible to select which volumes to activate using the
 activation/auto_activation_volume_list settting.
 .IP
+Activation of a logical volume creates a symbolic link 
+/dev/VolumeGroupName/LogicalVolumeName pointing to the device node.
+This link is removed on deactivation.
+All software and scripts should access the device through
+this symbolic link and present this as the name of the device.
+The location and name of the underlying device node may depend on   
+the distribution and configuration (e.g. udev) and might change 
+from release to release.
+.IP
 If clustered locking is enabled, add 'e' to activate/deactivate
 exclusively on one node or 'l' to activate/deactivate only
 on the local node.


