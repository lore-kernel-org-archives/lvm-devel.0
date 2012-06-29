From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 29 Jun 2012 10:43:10 +0000 (UTC)
Subject: master - man: --activate ay and auto_activation_volume_list
Message-ID: <20120629104310.3E2851707@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a54285a715b5e34808632b4973942db354fd089a
Commit:        a54285a715b5e34808632b4973942db354fd089a
Parent:        ec8f377748f4922d6a18ff0136e9a93f1d0b3f86
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 29 12:40:26 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 29 12:40:26 2012 +0200

man: --activate ay and auto_activation_volume_list

---
 WHATS_NEW         |    1 +
 man/lvchange.8.in |   10 +++++++---
 man/lvcreate.8.in |   14 +++++++++-----
 man/lvm.conf.5.in |   11 +++++++++++
 man/pvscan.8.in   |    8 ++++++++
 man/vgchange.8.in |    9 +++++++--
 6 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4be4c90..d19df2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Update man pages with --activate ay option and auto_activation_volume_list.
   Fix _alloc_parallel_area to avoid picking already-full areas for raid devices.
   Use vgchange -aay instead of vgchange -ay in clmvd init script.
   Add activation/auto_activation_volume_list to lvm.conf.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 9494ba7..c7507d4 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -8,7 +8,7 @@ lvchange \- change attributes of a logical volume
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-a | \-\-activate
-.RI [ e | l ]{ y | n }]
+.RI [ a | e | l ]{ y | n }]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-C | \-\-contiguous
@@ -46,11 +46,15 @@ including making them known to the kernel ready for use.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-a ", " \-\-activate " [" \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\-ay) or deactivate (\-an) the
-logical volumes.
+logical volumes. If autoactivation option is used (\-aay),
+the logical volume is activated only if it matches an item in
+the activation/auto_activation_volume_list set in lvm.conf.
+Autoactivation is not yet supported for logical volumes that
+are part of partial or clustered volume groups.
 .IP
 If clustered locking is enabled, -aey will activate exclusively
 on one node and -aly will activate only on the local node.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4b393e1..2917775 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -8,7 +8,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-a | \-\-activate
-.RI [ e | l ]{ y | n }]
+.RI [ a | e | l ]{ y | n }]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-C | \-\-contiguous
@@ -107,17 +107,21 @@ See
 .BR lvm (8)
 for common options.
 .TP
-.IR \fB\-a ", " \fB\-\-activate " {" y | n | ey | en | ly | ln }
+.IR \fB\-a ", " \fB\-\-activate " {" y | ay | n | ey | en | ly | ln }
 Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
-By default, new Logical Volumes are activated automatically (\fB-a\fIy\fR).
+By default, new Logical Volumes are activated (\fB-a\fIy\fR).
 If it is possible technically, \fB-a\fIn\fR will leave the new Logical
 Volume inactive. But for example, snapshots can only be created
 in the active state so \fB\-a\fIn\fR cannot be used with \fB\-\-snapshot\fP.
 Normally the \fB\-\-zero n\fP argument has to be supplied too because
 zeroing (the default behaviour) also requires activation.
-If clustered locking is enabled, \fB\-a\fIey\fR will activate exclusively
-on one node and \fB\-a\fIly\fR will activate only on the local node.
+If autoactivation option is used (\fB\-a\fIay\fR), the logical volume is
+activated only if it matches an item in the activation/auto_activation_volume_list
+set in lvm.conf. For autoactivated logical volumes, \fB\-\-zero n\fP is
+always assumed and it can't be overridden. If clustered locking is enabled,
+\fB\-a\fIey\fR will activate exclusively on one node and \fB\-a\fIly\fR will
+activate only on the local node.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize
 Gives the size of chunk for snapshot and thin pool logical volumes.
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 6de7419..47ee9f1 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -424,6 +424,17 @@ metadata for a match.
 Logical volume and volume groups can also be included in the list
 by name e.g. vg00, vg00/lvol1.
 .IP
+\fBauto_activation_volume_list\fP \(em This acts as a filter through
+which all requests to autoactivate a logical volume on this machine
+are passed. A logical volume is autoactivated if it matches
+an item in the list. Volumes must also pass the \fBvolume_list\fP
+filter, if present. Tags must be preceded by @ and are checked against
+all tags defined in the logical volume and volume group metadata for
+a match. @* is short-hand to check every tag set on the host machine
+(see \fBtags\fP above).
+Logical volume and volume groups can also be included in the list
+by name e.g. vg00, vg00/lvol1.
+.IP
 \fBread_only_volume_list\fP \(em This acts as a filter through
 which all requests to activate a logical volume on this machine
 are passed.  A logical volume is activated in read-only mode (instead
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index b75773b..1be3109 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -18,6 +18,7 @@ pvscan \- scan all disks for physical volumes
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .B \-\-cache
+.RB [ \-a | \-\-activate " " \fIay ]
 .RB [ \-\-major
 .I major
 .B \-\-minor
@@ -42,6 +43,13 @@ Short listing format.
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
+.BR \-a ", " \-\-activate " " \fIay
+Together with the information already cached in lvmetad, automatically activate
+any logical volumes that become activatable after the scan done on one or more devices.
+The logical volume to autoactivate is matched against the
+activation/auto_activation_volume_list set in lvm.conf. Autoactivation is not yet
+supported on logical volumes that are part of partial or clustered volume groups.
+.TP
 .BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " ]..."
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 056acb4..28e2623 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -10,7 +10,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-a | \-\-activate
-.RI [ e | l ]
+.RI [ a | e | l ]
 .RI { y | n }]
 .RB [ \-\-monitor
 .RI { y | n }]
@@ -64,10 +64,15 @@ Controls automatic backup of metadata after the change.  See
 .BR vgcfgbackup (8).
 Default is yes.
 .TP
-.BR \-a ", " \-\-activate " [" \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes in the volume
 group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
+If autoactivation option is used (\-aay), each logical volume in
+the volume group is activated only if it matches an item in the
+activation/auto_activation_volume_list set in lvm.conf.
+Autoactivation is not yet supported for partial or clustered
+volume groups.
 .IP
 If clustered locking is enabled, add 'e' to activate/deactivate
 exclusively on one node or 'l' to activate/deactivate only


