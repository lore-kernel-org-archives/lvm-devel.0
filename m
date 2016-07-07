From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  7 Jul 2016 18:12:01 +0000 (UTC)
Subject: master - man: more rewording for lvcreate size
Message-ID: <20160707181201.E9FD7600F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0de56eeaad0791821ac286c26f064c2744742848
Commit:        0de56eeaad0791821ac286c26f064c2744742848
Parent:        13cd3ff5a0dd1652cf20697dbb0d768c6b5115f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 7 13:11:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 7 13:11:43 2016 -0500

man: more rewording for lvcreate size

---
 man/lvcreate.8.in |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index da308fa..b7ad7bb 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -329,18 +329,19 @@ is specified.
 .IR LogicalExtentsNumber \c
 .RB [ % { VG | PVS | FREE | ORIGIN }]
 .br
-The size of the new LV in logical extents.  The number of physical extents
-allocated may be different, and depends on the LV type, e.g.  mirroring.
-The number of logical extents can also be expressed as a percentage of the
-total space in the Volume Group with the suffix \fB%VG\fP, as a percentage
-of the remaining free space in the Volume Group with the suffix
-\fB%FREE\fP, as a percentage of the remaining free space for the specified
-PhysicalVolume(s) with the suffix \fB%PVS\fP, or (for a snapshot) as a
-percentage of the total space in the Origin Logical Volume with the suffix
-\fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
-When expressed as a percentage, the number is treated as an approximate
-upper limit, and the actual size of the LV (in logical extents) may be
-less.
+Specifies the size of the new LV in logical extents.  The number of
+physical extents allocated may be different, and depends on the LV type.
+Certain LV types require more physical extents for data redundancy or
+metadata.  An alternate syntax allows the size to be determined indirectly
+as a percentage of the size of a related VG, LV, or set of PVs.  The
+suffix \fB%VG\fP denotes the total size of the VG, the suffix \fB%FREE\fP
+the remaining free space in the VG, and the suffix \fB%PVS\fP the free
+space in the specified Physical Volumes.  For a snapshot, the upper bound
+can be expressed as a percentage of the total size of the Origin Logical
+Volume with the suffix \fB%ORIGIN\fP (\fB100%ORIGIN\fP provides space for
+the whole origin).  When expressed as a percentage, the number is treated
+as an approximate upper limit, and the final size of the LV is not known
+until the command is complete.
 .
 .HP
 .BR \-j | \-\-major


