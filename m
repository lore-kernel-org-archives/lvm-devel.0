From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 00:14:08 +0000 (UTC)
Subject: master - man: lvchange update
Message-ID: <20141119001408.12D736033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=731e99025bf66967de365fb7a79d5689dc14d5fe
Commit:        731e99025bf66967de365fb7a79d5689dc14d5fe
Parent:        53d2db31c6e68c43c59a47333c16f18658ce9ea4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 19 00:30:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 00:31:23 2014 +0100

man: lvchange update

Fix \fI usage.
---
 man/lvchange.8.in |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index d3d63fd..cafb914 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -10,8 +10,9 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]{ y | n }]
 .RB [ \-\-activationmode
-.IR { complete | degraded | partial } ]
-.RB [ \-k | \-\-setactivationskip { y | n } ]
+.RI { complete | degraded | partial }]
+.RB [ \-k | \-\-setactivationskip
+.RI { y | n }]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
@@ -44,7 +45,7 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-\-[raid]writebehind
 .IR IOCount ]
 .RB [ \-\-[raid]writemostly
-.IR PhysicalVolume [ : { t | n | y }]]
+.IR PhysicalVolume [ : { y | n | t }]]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-metadataprofile
@@ -105,15 +106,15 @@ exclusively because they can only be used on one node at once.
 .BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
 The activation mode determines whether logical volumes are allowed to
 activate when there are physical volumes missing (e.g. due to a device
-failure).  \fIcomplete is the most restrictive; allowing only those
+failure).  \fIcomplete\fP is the most restrictive; allowing only those
 logical volumes to be activated that are not affected by the missing
-PVs.  \fIdegraded allows RAID logical volumes to be activated even if
-they have PVs missing.  (Note that the "mirror" segment type is not
-considered a RAID logical volume.  The "raid1" segment type should
-be used instead.)  Finally, \fIpartial allows any logical volume to
+PVs.  \fIdegraded\fP allows RAID logical volumes to be activated even if
+they have PVs missing.  (Note that the "\fImirror\fP" segment type is not
+considered a RAID logical volume.  The "\fIraid1\fP" segment type should
+be used instead.)  Finally, \fIpartial\fP allows any logical volume to
 be activated even if portions are missing due to a missing or failed
 PV.  This last option should only be used when performing recovery or
-repair operations.  \fIdegraded is the default mode.  To change it, modify
+repair operations.  \fIdegraded\fP is the default mode.  To change it, modify
 .B activation_mode
 in
 .BR lvm.conf (5).
@@ -220,14 +221,14 @@ to the constituent devices must complete before the array signals the
 write has completed).  Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
 .TP
-.IR \fB\-\-[raid]writemostly " " PhysicalVolume [ : { t | y | n }]
+.IR \fB\-\-[raid]writemostly " " PhysicalVolume [ : { y | n | t }]
 Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
 to these drives will be avoided unless absolutely necessary.  This keeps
 the number of I/Os to the drive to a minimum.  The default behavior is to
 set the write-mostly attribute for the specified physical volume in the
 logical volume.  It is possible to also remove the write-mostly flag by
-appending a ":n" to the physical volume or to toggle the value by specifying
-":t".  The \fB\-\-writemostly\fP argument can be specified more than one time
+appending a "\fI:n\fP" to the physical volume or to toggle the value by specifying
+"\fI:t\fP".  The \fB\-\-writemostly\fP argument can be specified more than one time
 in a single command; making it possible to toggle the write-mostly attributes
 for all the physical volumes in a logical volume at once.
 .TP


