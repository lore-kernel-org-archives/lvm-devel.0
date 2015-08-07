From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  7 Aug 2015 21:26:29 +0000 (UTC)
Subject: master - man: add lockd bits to relevant commands
Message-ID: <20150807212629.CDB7060C90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=993fe07a3c9cd756d854d36d576cba5620bf3e36
Commit:        993fe07a3c9cd756d854d36d576cba5620bf3e36
Parent:        2bbf2fa8ebc3d723bc686689378db2a1fe8eaf6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 7 16:25:00 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 7 16:25:00 2015 -0500

man: add lockd bits to relevant commands

---
 man/lvm.8.in      |    5 +++++
 man/vgchange.8.in |   42 ++++++++++++++++++++++++++++++++++++++++++
 man/vgcreate.8.in |    8 ++++++++
 man/vgs.8.in      |    2 +-
 4 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 685a4fc..c8e6484 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -261,6 +261,11 @@ It can be used to report or display a VG that is owned by another host.
 This option can cause a command to perform poorly because lvmetad caching
 is not used and metadata is read from disks.
 .TP
+.B \-\-shared
+Cause the command to access shared VGs, that would otherwise be skipped
+when lvmlockd is not being used.  It can be used to report or display a
+lockd VG without locking.
+.TP
 .B \-\-addtag \fITag
 Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 8225eb5..77ab70e 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -34,6 +34,10 @@ vgchange \(em change attributes of a volume group
 .RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-lock\-start ]
+.RB [ \-\-lock\-stop ]
+.RB [ \-\-lock\-type
+.IR LockType ]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
 .RB [ \-p | \-\-maxphysicalvolumes
@@ -127,6 +131,30 @@ LVs with snapshots are always activated exclusively because they can only
 be used on one node at once.
 
 For local VGs, \-ay, \-aey, and \-asy are all equivalent.
+.IP
+In a shared VG, lvmlockd is used for locking, and the following options
+are possible:
+
+With \-aey, the command activates the LV in exclusive mode, allowing a
+single host to activate the LV (the host running the command).  Before
+activating the LV, the command uses lvmlockd to acquire an exclusive lock
+on the LV.  If the lock cannot be acquired, the LV is not activated and an
+error is reported.  This would happen if the LV is active on another host.
+
+With \-asy, the command activates the LV in shared mode, allowing multiple
+hosts to activate the LV concurrently.  Before activating the LV, the
+command uses lvmlockd to acquire a shared lock on the LV.  If the lock
+cannot be acquired, the LV is not activated and an error is reported.
+This would happen if the LV is active exclusively on another host.  If the
+LV type prohibits shared access, such as a snapshot, the command will
+report an error and fail.
+
+With \-an, the command deactivates the LV on the host running the command.
+After deactivating the LV, the command uses lvmlockd to release the
+current lock on the LV.
+
+With lvmlockd, an unspecified mode is always exclusive, \-ay defaults to
+\-aey.
 
 .TP
 .BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
@@ -213,6 +241,20 @@ Make no attempt to interact with dmeventd unless
 is specified.
 Do not use this if dmeventd is already monitoring a device.
 .TP
+.BR \-\-lock\-start
+Start the lockspace of a shared VG in lvmlockd.  lvmlockd locks becomes
+available for the VG, allowing LVM to use the VG.  See
+.BR lvmlockd (8).
+.TP
+.BR \-\-lock\-stop
+Stop the lockspace of a shared VG in lvmlockd.  lvmlockd locks become
+unavailable for the VG, preventing LVM from using the VG.  See
+.BR lvmlockd (8).
+.TP
+.BR \-\-lock\-type " " \fILockType
+Change the VG lock type to or from a shared lock type used with lvmlockd.  See
+.BR lvmlockd (8).
+.TP
 .BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes
 Changes the maximum logical volume number of an existing inactive
 volume group.
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index c55dbfe..92ef06c 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -27,6 +27,7 @@ vgcreate \(em create a volume group
 .IR NumberOfCopies | unmanaged | all ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-shared ]
 .RB [ \-\-systemid
 .IR SystemID ]
 .RB [ \-t | \-\-test ]
@@ -128,6 +129,13 @@ impact on I/O performance to the logical volume.  The smallest PE is 1KiB
 The 2.4 kernel has a limitation of 2TiB per block device.
 
 .TP
+.B \-\-shared
+Create a shared VG using lvmlockd.  lvmlockd will select lock type sanlock
+or dlm depending on which lock manager is running.  This allows multiple
+hosts to share a VG on shared devices.  See
+.BR lvmlockd (8).
+
+.TP
 .BR \-\-systemid " " \fISystemID
 Specifies the system ID that will be given to the new VG, overriding the
 system ID of the host running the command.  A VG is normally created
diff --git a/man/vgs.8.in b/man/vgs.8.in
index 6dd52f1..654e8bb 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -93,7 +93,7 @@ are missing from the system
 .IP 5 3
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .IP 6 3
-(c)lustered
+(c)lustered, (s)hared
 .RE
 .TP
 .BR \-O ", " \-\-sort


