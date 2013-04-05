From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Apr 2013 12:16:22 +0000 (UTC)
Subject: master - man: lvceate document external origin snapshot
Message-ID: <20130405121622.D8FCA517@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c22e925ce4fa765b208670e851eae5103fb141f4
Commit:        c22e925ce4fa765b208670e851eae5103fb141f4
Parent:        ddafa0115e6881f30ada55f40cb07dd41a6afd2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 5 12:56:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 5 14:15:03 2013 +0200

man: lvceate document external origin snapshot

Document added support for external origin.
---
 WHATS_NEW         |    1 +
 man/lvcreate.8.in |   20 +++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 539d8fb..525c173 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add external origin support for lvcreate.
   Improve lvcreate, lvconvert and lvm man pages.
   Clean up format1 PV write to remove a need for an orphan VG for it to pass.
   Fix vgextend to not allow a PV with 0 MDAs to be used while already in a VG.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index d208cad..47c0a72 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -59,7 +59,10 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-poolmetadatasize
 .IR ThinPoolMetadataSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }]
+.IR ThinPoolLogicalVolume { Name | Path }
+.RB [ \-s | \-\-snapshot
+.RI [ VolumeGroup { Name | Path }/]
+.IR ExternalOriginLogicalVolumeName ]]
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
@@ -291,6 +294,15 @@ used to track the locations of the chunks of data, so you should
 allocate slightly more space than you actually need and monitor
 (\fB\-\-monitor\fP) the rate at which the snapshot data is growing
 so you can \fBavoid\fP running out of space.
+If \fB\-\-thinpool\fP is specified, thin volume is created that will
+use given original logical volume as an external origin that
+serves unprovisioned blocks.
+Only read-only volumes can be used as external origins.
+To make the volume external origin, lvm expects the volume to be inactive.
+External origin volume can be used/shared for many thin volumes
+even from different thin pools. See
+.BR lvconvert (8)
+for online conversion to thin volumes with external origin.
 .TP
 .IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
 Creates thin pool or thin logical volume or both.
@@ -407,9 +419,15 @@ build with 2 stripes 64KiB and chunk size 256KiB together with
 .sp
 .B lvcreate \-i 2 \-I 64 \-c 256 \-L100M \-T vg00/pool \-V 1T \-\-name thin_lv
 
+Creates thin volume snapshot of read only inactive volume "vg00/origin"
+that will use an existing thin pool "vg00/pool":
+.sp
+.B lvcreate -s --thinpool "vg00/pool"  origin
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
+.BR lvconvert (8),
 .BR lvchange (8),
 .BR lvextend (8),
 .BR lvreduce (8),


