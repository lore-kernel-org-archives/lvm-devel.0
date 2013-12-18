From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Dec 2013 08:04:34 +0000 (UTC)
Subject: master - man: syntax and spelling fixes.
Message-ID: <20131218080434.6B9A260E06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3776832499862ce6896b598487e79b02e7432326
Commit:        3776832499862ce6896b598487e79b02e7432326
Parent:        c3d82d717ccd4d4801f5d84787bb12e0189eb1af
Author:        Ville Skytt?? <ville.skytta@iki.fi>
AuthorDate:    Tue Dec 17 20:26:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 18 09:03:42 2013 +0100

man: syntax and spelling fixes.

---
 WHATS_NEW          |    1 +
 man/dmsetup.8.in   |    2 +-
 man/lvconvert.8.in |    2 +-
 man/lvm.8.in       |    4 ++--
 man/lvreduce.8.in  |    2 +-
 man/lvresize.8.in  |    2 +-
 man/pvmove.8.in    |    2 +-
 7 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a7522f9..fe8f1ea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Syntax and spelling fixes in some man pages.
   Dependency scan counts with snapshots and external origins.
   Make sure VG extent size is always greater or equal to PV phys. block size.
   Optimize double call of stat() for cached devices.
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 93621a5..599c843 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -484,7 +484,7 @@ Default subsystem is LVM.
 .B status
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-\noflush ]
+.RB [ \-\-noflush ]
 .RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 44b89af..c8cb2dc 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -203,7 +203,7 @@ a mirror logical volume.
 .B \-\-trackchanges
 Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
 that the read-only detached image can be merged efficiently back into
-the mirror later. Only the regions of the detatched device where
+the mirror later. Only the regions of the detached device where
 the data changed get resynchronized.
 
 Please note that this feature is only supported with the new md-based mirror
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 13e66d0..d78281a 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -21,7 +21,7 @@ that command.
 On invocation, \fBlvm\fP requires that only the standard file descriptors
 stdin, stdout and stderr are available.  If others are found, they
 get closed and messages are issued warning about the leak.
-This warning can be suppressed by setting enviromental variable
+This warning can be suppressed by setting the environment variable
 .B LVM_SUPPRESS_FD_WARNINGS\fP.
 .LP
 Where commands take VG or LV names as arguments, the full path name is
@@ -46,7 +46,7 @@ being created in the filesystem for them.
 \fBdumpconfig\fP \(em Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
-\fBdevtypes\fP \(dm Display the recognised built-in block device types.
+\fBdevtypes\fP \(em Display the recognised built-in block device types.
 .TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index dabdc88..2c38f5b 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -57,7 +57,7 @@ size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of the
 remaining free space in the Volume Group with the suffix \fI%FREE\fP, or (for
 a snapshot) as a percentage of the total space in the Origin Logical
 Volume with the suffix \fI%ORIGIN\fP.
-The resulting value for the substraction is rounded downward, for the absolute
+The resulting value for the subtraction is rounded downward, for the absolute
 size it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index e04869d..3606762 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -56,7 +56,7 @@ the remaining free space of the PhysicalVolumes on the command line with the
 suffix \fI%PVS\fP, as a percentage of the remaining free space in the
 Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
 of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
-The resulting value is rounded downward for the substraction otherwise
+The resulting value is rounded downward for the subtraction otherwise
 it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index c77dcbc..bb69547 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -131,7 +131,7 @@ also refers to 1000 Physical Extents starting from Physical Extent number 1000.
 (Counting starts from 0, so this refers to the 1001st to the 2000th inclusive.)
 .P
 To move a range of Physical Extents to a specific location (which must have
-sufficent free extents) use the form:
+sufficient free extents) use the form:
 .sp
 .B pvmove /dev/sdb1:1000-1999 /dev/sdc1
 .sp


