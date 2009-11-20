From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:55 -0500
Subject: [PATCH 15/15] lvm-merge-man-lvconvert
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-16-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update lvconvert manpage for snapshot --merge

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 man/lvconvert.8.in |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 879064b..8fd3729 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -24,7 +24,18 @@ LogicalVolume[Path] [PhysicalVolume[Path][:PE[-PE]]...]
 [\-\-version]
 .br
 OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
+.br
 
+.br
+.B lvconvert
+\-\-merge [\-b|\-\-background] [\-i|\-\-interval Seconds]
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
+[\-\-version]
+SnapshotLogicalVolume[Path]
+.br
+
+.br
 .B lvconvert
 \-\-repair
 [\-h|\-?|\-\-help]
@@ -47,7 +58,7 @@ the freed extents come first from the specified PhysicalVolumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
-Exactly one of \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
+Exactly one of \-\-mirrors, \-\-repair, \-\-snapshot or \-\-merge arguments required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -106,6 +117,17 @@ Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
 .I \-Z, \-\-zero y|n
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
+.TP
+.I \-\-merge
+Merges a snapshot into its origin volume. If both the origin and snapshot volume
+are not open the merge will start immediately.  Otherwise, the merge will start
+the first time either the origin or snapshot are activated and both are closed.
+Merging a snapshot into an origin that cannot be closed, for example a root
+filesystem, is deferred until the next time the origin volume is activated.
+When merging starts, the resulting logical volume will have the origin's name,
+minor number and UUID.  While the merge is in progress, reads or writes to the
+origin appear as they were directed to the snapshot being merged.  When the
+merge finishes, the merged snapshot is removed.
 .br
 .SH Examples
 "lvconvert -m1 vg00/lvol1"
@@ -146,6 +168,11 @@ extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
 converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
 extents from /dev/sda.
 
+.br
+"lvconvert --merge vg00/lvol1_snap"
+.br
+merges "vg00/lvol1_snap" into its origin.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
-- 
1.6.5.2


