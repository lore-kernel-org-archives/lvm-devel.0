From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:52 +0000 (UTC)
Subject: master - man vgchange lvchange: mention activation option s
Message-ID: <20150616192452.2E9B260DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d9957e3dd82666a360481b3a18baa9f23c75300
Commit:        3d9957e3dd82666a360481b3a18baa9f23c75300
Parent:        857296c8236f12d93029d6382c8d472598666e6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 13:28:07 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 13:28:07 2015 -0500

man vgchange lvchange: mention activation option s

and improve the existing text about existing
activation options.
---
 man/lvchange.8.in |   39 ++++++++++++++++++++++++++++++++-------
 man/vgchange.8.in |   47 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 68 insertions(+), 18 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 6b41c81..9199b49 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -8,7 +8,7 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-a | \-\-activate
-.RI [ a | e | l ]{ y | n }]
+.RI [ a | e | s | l ]{ y | n }]
 .RB [ \-\-activationmode
 .RI { complete | degraded | partial }]
 .RB [ \-k | \-\-setactivationskip
@@ -81,7 +81,7 @@ including making them known to the kernel ready for use.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIs | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\-ay) or deactivate (\-an) the
@@ -104,11 +104,36 @@ activation. The \-aay option should be also used during system
 boot so it's possible to select which volumes to activate using
 the activation/auto_activation_volume_list setting.
 .IP
-If clustered locking is enabled, -aey will activate exclusively
-on one node and -aly will activate only on the local node.
-To deactivate only on the local node use -aln.
-Logical volumes with single-host snapshots are always activated
-exclusively because they can only be used on one node at once.
+In a clustered VG, clvmd is used for activation, and the
+following options are possible:
+
+With \-aey, clvmd activates the LV in exclusive mode
+(with an exclusive lock), allowing a single node to activate the LV.
+
+With \-asy, clvmd activates the LV in shared mode
+(with a shared lock), allowing multiple nodes to activate the LV concurrently.
+If the LV type prohibits shared access, such as an LV with a snapshot,
+the 's' option is ignored and an exclusive lock is used.
+
+With \-ay (no mode specified), clvmd activates the LV in shared mode
+if the LV type allows concurrent access, such as a linear LV.
+Otherwise, clvmd activates the LV in exclusive mode.
+
+With \-aey, \-asy, and \-ay, clvmd attempts to activate the LV
+on all nodes.  If exclusive mode is used, then only one of the
+nodes will be successful.
+
+With \-an, clvmd attempts to deactivate the LV on all nodes.
+
+With \-aly, clvmd activates the LV only on the local node, and \-aln
+deactivates only on the local node.  If the LV type allows concurrent
+access, then shared mode is used, otherwise exclusive.
+
+LVs with snapshots are always activated exclusively because they can only
+be used on one node at once.
+
+For local VGs, \-ay, \-aey, and \-asy are all equivalent.
+
 .TP
 .BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
 The activation mode determines whether logical volumes are allowed to
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index e6e850a..8225eb5 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -10,7 +10,7 @@ vgchange \(em change attributes of a volume group
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-a | \-\-activate
-.RI [ a | e | l ]
+.RI [ a | e | s | l ]
 .RI { y | n }]
 .RB [ \-\-activationmode
 .IR { complete | degraded | partial } ]
@@ -77,7 +77,7 @@ Controls automatic backup of metadata after the change.  See
 .BR vgcfgbackup (8).
 Default is yes.
 .TP
-.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIs | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes in the volume
 group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
@@ -98,24 +98,49 @@ The location and name of the underlying device node may depend on
 the distribution and configuration (e.g. udev) and might change 
 from release to release.
 .IP
-If clustered locking is enabled, add 'e' to activate/deactivate
-exclusively on one node or 'l' to activate/deactivate only
-on the local node.
-Logical volumes with single-host snapshots are always activated
-exclusively because they can only be used on one node at once.
+In a clustered VG, clvmd is used for activation, and the
+following options are possible:
+
+With \-aey, clvmd activates the LV in exclusive mode
+(with an exclusive lock), allowing a single node to activate the LV.
+
+With \-asy, clvmd activates the LV in shared mode
+(with a shared lock), allowing multiple nodes to activate the LV concurrently.
+If the LV type prohibits shared access, such as an LV with a snapshot,
+the 's' option is ignored and an exclusive lock is used.
+
+With \-ay (no mode specified), clvmd activates the LV in shared mode
+if the LV type allows concurrent access, such as a linear LV.
+Otherwise, clvmd activates the LV in exclusive mode.
+
+With \-aey, \-asy, and \-ay, clvmd attempts to activate the LV
+on all nodes.  If exclusive mode is used, then only one of the
+nodes will be successful.
+
+With \-an, clvmd attempts to deactivate the LV on all nodes.
+
+With \-aly, clvmd activates the LV only on the local node, and \-aln
+deactivates only on the local node.  If the LV type allows concurrent
+access, then shared mode is used, otherwise exclusive.
+
+LVs with snapshots are always activated exclusively because they can only
+be used on one node at once.
+
+For local VGs, \-ay, \-aey, and \-asy are all equivalent.
+
 .TP
 .BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
 The activation mode determines whether logical volumes are allowed to
 activate when there are physical volumes missing (e.g. due to a device
-failure).  \fIcomplete is the most restrictive; allowing only those
+failure).  \fIcomplete\fP is the most restrictive; allowing only those
 logical volumes to be activated that are not affected by the missing
-PVs.  \fIdegraded allows RAID logical volumes to be activated even if
+PVs.  \fIdegraded\fP allows RAID logical volumes to be activated even if
 they have PVs missing.  (Note that the "mirror" segment type is not
 considered a RAID logical volume.  The "raid1" segment type should
-be used instead.)  Finally, \fIpartial allows any logical volume to
+be used instead.)  Finally, \fIpartial\fP allows any logical volume to
 be activated even if portions are missing due to a missing or failed
 PV.  This last option should only be used when performing recovery or
-repair operations.  \fIdegraded is the default mode.  To change it, modify
+repair operations.  \fIdegraded\fP is the default mode.  To change it, modify
 .B activation_mode
 in
 .BR lvm.conf (5).


