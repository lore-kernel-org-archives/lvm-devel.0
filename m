From: mulhern <amulhern@redhat.com>
Date: Wed, 20 Apr 2016 14:18:15 -0400
Subject: [PATCH] man: rewrite --extents option description for lvcreate
Message-ID: <1461176295-22154-1-git-send-email-amulhern@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The changes are:
1. Change LogicalExtentsNumber meta-variable to ExtentsNumber meta-variable,
since the value may indicate a number of physical extents.
2. Mention that the value may by interpreted as a specification of physical
extents at the beginning rather than at the end of the description.
3. Make the description about the use of the %ORIGIN modifier more precise.

There are --extents options for lvreduce, lvextend, lvresize. These retain
their old meanings, and so these changes are inappropriate for them.

Signed-off-by: mulhern <amulhern@redhat.com>
---
 man/lvcreate.8.in | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index f6bb14f..8a33b56 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -116,7 +116,7 @@ lvcreate \- create a logical volume in an existing volume group
 .LP
 .B lvcreate
 .RB [ \-l | \-\-extents
-.BR \fILogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
+.BR \fIExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
 |
 .BR \-L | \-\-size
 .\" | \-\-pooldatasize
@@ -317,22 +317,26 @@ is specified.
 .
 .HP
 .BR -l | \-\-extents
-.IR LogicalExtentsNumber \c
+.IR ExtentsNumber \c
 .RB [ % { VG | PVS | FREE | ORIGIN }]
 .br
-Gives the number of logical extents to allocate for the new
-logical volume.  The total number of physical extents allocated will be
-greater than this, for example, if the volume is mirrored.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fB%VG\fP, as a percentage of the
-remaining free space in the Volume Group with the suffix \fB%FREE\fP, as a
-percentage of the remaining free space for the specified
-PhysicalVolume(s) with the suffix \fB%PVS\fP, or (for a snapshot) as a
-percentage of the total space in the Origin Logical Volume with the
-suffix \fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
-When expressed as a percentage, the number is treated
-as an approximate upper limit for the number of physical extents
-to be allocated (including extents used by any mirrors, for example).
+Specify the size of the new logical volume as a number of logical extents.
+Alternatively, using one of the optional modifiers, specify an upper bound on
+the number of physical extents to allocate to create the new logical volume.
+Often the number of physical extents allocated to create a logical volume
+is greater than the number of logical extents in the resulting volume. For
+example, if the type of the volume is raid1, the number of physical extents
+allocated for the volume will be roughly twice the number of logical extents
+in the volume.
+
+The bound on the number of physical extents may be expressed as a
+percentage of the total space in the Volume Group with the suffix \fB%VG\fP,
+as a percentage of the remaining free space in the Volume Group with the
+suffix \fB%FREE\fP, as a percentage of the remaining free space for the
+specified PhysicalVolume(s) with the suffix \fB%PVS\fP, or, for a snapshot
+only, as a percentage of the total space in the Origin Logical Volume with the
+suffix \fB%ORIGIN\fP, e.g. \fB100%ORIGIN\fP allocates as many physical extents
+for the new volume as there are logical extents in the Origin Logical Volume.
 .
 .HP
 .BR \-j | \-\-major
-- 
2.4.11


