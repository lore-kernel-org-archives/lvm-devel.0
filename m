From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  6 Jul 2016 16:36:52 +0000 (UTC)
Subject: master - man: clarify lvcreate size in extents
Message-ID: <20160706163652.6FA5760FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=351bcf5f82a76b897cd431e3709759507566ee7b
Commit:        351bcf5f82a76b897cd431e3709759507566ee7b
Parent:        f6b98ec7cac4ce2c4022057eddf6c1e49a2f7748
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 6 11:35:50 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 6 11:35:50 2016 -0500

man: clarify lvcreate size in extents

---
 man/lvcreate.8.in |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 3e2bf32..da308fa 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -329,19 +329,18 @@ is specified.
 .IR LogicalExtentsNumber \c
 .RB [ % { VG | PVS | FREE | ORIGIN }]
 .br
-Gives the number of logical extents to allocate for the new
-logical volume.  The total number of physical extents allocated will be
-greater than this, for example, if the volume is mirrored.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fB%VG\fP, as a percentage of the
-remaining free space in the Volume Group with the suffix \fB%FREE\fP, as a
-percentage of the remaining free space for the specified
+The size of the new LV in logical extents.  The number of physical extents
+allocated may be different, and depends on the LV type, e.g.  mirroring.
+The number of logical extents can also be expressed as a percentage of the
+total space in the Volume Group with the suffix \fB%VG\fP, as a percentage
+of the remaining free space in the Volume Group with the suffix
+\fB%FREE\fP, as a percentage of the remaining free space for the specified
 PhysicalVolume(s) with the suffix \fB%PVS\fP, or (for a snapshot) as a
-percentage of the total space in the Origin Logical Volume with the
-suffix \fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
-When expressed as a percentage, the number is treated
-as an approximate upper limit for the number of physical extents
-to be allocated (including extents used by any mirrors, for example).
+percentage of the total space in the Origin Logical Volume with the suffix
+\fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
+When expressed as a percentage, the number is treated as an approximate
+upper limit, and the actual size of the LV (in logical extents) may be
+less.
 .
 .HP
 .BR \-j | \-\-major


