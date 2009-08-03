From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  3 Aug 2009 11:02:10 -0400
Subject: [PATCH] Update man pages to clarify usage of PE ranges.
Message-ID: <1249311730-6802-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvconvert.8.in |    9 ++++++++-
 man/lvcreate.8.in  |    8 +++++++-
 man/lvextend.8.in  |    9 ++++++++-
 man/lvresize.8.in  |    9 ++++++++-
 4 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 6682871..62e2be3 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -9,7 +9,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 [\-h|\-?|\-\-help]
 [\-v|\-\-verbose] [\-y|\-\-yes]
 [\-\-version]
-LogicalVolume[Path] [PhysicalVolume[Path]...]
+.br
+LogicalVolume[Path] [PhysicalVolume[Path][:PE[-PE]]...]
 .br
 
 .br
@@ -115,6 +116,12 @@ volume.
 .br
 converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
 
+.br
+"lvconvert -m1 vg1/lv1 /dev/sda:0-15 /dev/sdb:0-15"
+.br
+converts linear logical volume "vg1/lv1" to a two-way mirror, using physical
+extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 001e013..deed127 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -17,7 +17,7 @@ lvcreate \- create a logical volume in an existing volume group
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
 [\-t|\-\-test]
 [\-v|\-\-verbose] [\-Z|\-\-zero y|n]
-VolumeGroupName [PhysicalVolumePath...]
+VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
 .br
 
 .br
@@ -201,6 +201,12 @@ a backup while the original filesystem continues to get updated.
 .br
 creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
 under 100MB of actual data on it.
+.br
+"lvcreate -L 64M -n lv1 vg1 /dev/sda:0-7 /dev/sdb:0-7"
+.br
+creates a linear logical volume "vg1/lv1" using physical extents
+/dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
+
 
 .SH SEE ALSO
 .BR lvm (8), 
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index dcbd736..e451141 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -9,7 +9,7 @@ lvextend \- extend the size of a logical volume
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
 lvextend allows you to extend the size of a logical volume.
 Extension of snapshot logical volumes (see
@@ -60,6 +60,13 @@ there are enough free physical extents in it.
 "lvextend /dev/vg01/lvol01 /dev/sdk3" tries to extend the size of that
 logical volume by the amount of free space on physical volume /dev/sdk3.
 This is equivalent to specifying "-l +100%PVS" on the command line.
+
+.br
+"lvextend -L+16M vg1/lv1 /dev/sda:8-9 /dev/sdb:8-9"
+.br
+tries to extend a logical volume "vg1/lv1" by 16MB using physical extents
+/dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8), 
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 64a4203..95f6f18 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -9,7 +9,7 @@ lvresize \- resize a logical volume
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
+[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
 lvresize allows you to resize a logical volume.
 Be careful when reducing a logical volume's size, because data in the reduced
@@ -58,6 +58,13 @@ Not applicable to LVs using the original metadata LVM format, which
 must use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
+.SH Examples
+.br
+"lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1"
+.br
+tries to extend a logical volume "vg1/lv1" by 16MB using physical extents
+/dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvconvert (8),
-- 
1.6.0.6


