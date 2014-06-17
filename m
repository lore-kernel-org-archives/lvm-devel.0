From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:37 +0000 (UTC)
Subject: master - snapshot: %ORIGIN is relative to data size
Message-ID: <20140617132437.C459661207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=494db110040cdc88ebf60abee87b04c6c8718cea
Commit:        494db110040cdc88ebf60abee87b04c6c8718cea
Parent:        cd6d6fc24e8093d437543613ddbcbdb0e9c5f8c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 17 13:33:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:41:01 2014 +0200

snapshot: %ORIGIN is relative to data size

Let's use the size of origin as the real base for percenta calculation,
and 'silenly' add needed metadata space for snapshot.

So now command   'lvcreate -s -l100%ORIGIN vg/lv' should always create a
snapshot to handle full device overwrite.
---
 WHATS_NEW         |    1 +
 man/lvcreate.8.in |   12 +++++++++---
 tools/lvcreate.c  |    4 +++-
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d83a66..77dfdcf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Automatically add snapshot metadata size for -l %ORIGIN calculation.
   When converting RAID origin to cache LV, properly rename sub-LVs.
   Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
   Add thin-generic configuration profile for generic thin settings.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 9301063..4ae2b9a 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -240,7 +240,8 @@ remaining free space in the Volume Group with the suffix \fI%FREE\fR, as a
 percentage of the remaining free space for the specified
 PhysicalVolume(s) with the suffix \fI%PVS\fR, or (for a snapshot) as a
 percentage of the total space in the Origin Logical Volume with the
-suffix \fI%ORIGIN\fR.  When expressed as a percentage, the number is treated
+suffix \fI%ORIGIN\fR (i.e. \fI100%ORIGIN\fR provides space for the whole origin).
+When expressed as a percentage, the number is treated
 as an approximate upper limit for the total number of physical extents
 to be allocated (including extents used by any mirrors, for example).
 .TP
@@ -492,8 +493,8 @@ This operation would require 2 devices - the log is "in-memory":
 .sp
 .B lvcreate \-m1 \-\-mirrorlog core \-L 500M vg00
 
-Creates a snapshot logical volume named /dev/vg00/snap which has access to the
-contents of the original logical volume named /dev/vg00/lvol1
+Creates a snapshot logical volume named "vg00/snap" which has access to the
+contents of the original logical volume named "vg00/lvol1"
 at snapshot logical volume creation time. If the original logical volume
 contains a file system, you can mount the snapshot logical volume on an
 arbitrary directory in order to access the contents of the filesystem to run
@@ -501,6 +502,11 @@ a backup while the original filesystem continues to get updated:
 .sp
 .B lvcreate \-\-size 100m \-\-snapshot \-\-name snap /dev/vg00/lvol1
 
+Creates a snapshot logical volume named "vg00/snap" with size
+for overwriting 20% of the original logical volume named "vg00/lvol1".:
+.sp
+.B lvcreate \-s \-l 20%ORIGIN \-\-name snap vg00/lvol1
+
 Creates a sparse device named /dev/vg1/sparse of size 1TiB with space for just
 under 100MiB of actual data on it:
 .sp
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1fa5aef..86264f3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -394,7 +394,9 @@ static int _update_extents_params(struct volume_group *vg,
 				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
 				return 0;
 			}
-			extents = percent_of_extents(lp->extents, origin->le_count, 0);
+			/* Add whole metadata size estimation */
+			extents = cow_max_extents(origin, lp->chunk_size) - origin->le_count +
+				percent_of_extents(lp->extents, origin->le_count, 1);
 			break;
 		case PERCENT_NONE:
 			extents = lp->extents;


