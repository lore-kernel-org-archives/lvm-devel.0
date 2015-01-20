From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:03:06 +0000 (UTC)
Subject: master - man: errorwhenfull doc
Message-ID: <20150120140306.140E5617B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cef00c4ca25237ed045ae5def506128f8678e21
Commit:        3cef00c4ca25237ed045ae5def506128f8678e21
Parent:        d80d832ae963e1d7bae94e96fd2d5362042fbfea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 15 15:20:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 15:02:19 2015 +0100

man: errorwhenfull doc

---
 man/lvchange.8.in |   15 +++++++++++----
 man/lvcreate.8.in |   11 +++++++++++
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 4577cce..bb5bea5 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -31,6 +31,8 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-\-detachprofile ]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
+.RB [ \-\-errorwhenfull
+.RI { y | n }]
 .RB [ \-\-resync ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -82,15 +84,15 @@ See \fBlvm\fP(8) for common options.
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\-ay) or deactivate (\-an) the
-logical volumes. 
+logical volumes.
 .IP
 Activation of a logical volume creates a symbolic link
 /dev/VolumeGroupName/LogicalVolumeName pointing to the device node.
 This link is removed on deactivation.
 All software and scripts should access the device through
 this symbolic link and present this as the name of the device.
-The location and name of the underlying device node may depend on 
-the distribution and configuration (e.g. udev) and might change 
+The location and name of the underlying device node may depend on
+the distribution and configuration (e.g. udev) and might change
 from release to release.
 .IP
 If autoactivation option is used (\-aay),
@@ -156,9 +158,14 @@ Set this to \fIignore\fP to ignore any discards received by a
 thin pool Logical Volume.  Set to \fInopassdown\fP to process such
 discards within the thin pool itself and allow the no-longer-needed
 extents to be overwritten by new data.  Set to \fIpassdown\fP (the
-default) to process them both within the thin pool itself and to 
+default) to process them both within the thin pool itself and to
 pass them down the underlying device.
 .TP
+.BR \-\-errorwhenfull " {" \fIy | \fIn }
+Sets thin pool behavior when data space is exhaused. See
+.BR lvcreate (8)
+for information.
+.TP
 .B \-\-resync
 Forces the complete resynchronization of a mirror.  In normal
 circumstances you should not need this option because synchronization
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index cc51546..8c1ee4b 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -25,6 +25,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
+.RB [ \-\-errorwhenfull
+.RI { y | n }]
 .RB [{ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { FREE | PVS | VG }]
 |
@@ -230,6 +232,15 @@ This is shortcut for option \fB\-\-mirrorlog\fP \fIcore\fP.
 Sets discards behavior for thin pool.
 Default is \fIpassdown\fP.
 .TP
+.BR \-\-errorwhenfull " {" \fIy |\fIn }
+Configures thin pool behaviour when data space is exhausted.
+Default is \fIn\fPo.
+Device will queue I/O operations until target timeout
+(see dm-thin-pool kernel module option \fIno_space_timeout\fP)
+expires. Thus configured system has a time to i.e. extend
+the size of thin pool data device.
+When set to \fIy\fPes, the I/O operation is immeditelly errored.
+.TP
 .BR \-K ", " \-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
 Use \fB\-\-setactivationskip\fP option to set or reset


