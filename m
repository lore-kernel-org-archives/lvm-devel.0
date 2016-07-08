From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  8 Jul 2016 13:18:26 +0000 (UTC)
Subject: master - man: enhance lvconvert
Message-ID: <20160708131826.DD60C61CDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12ecd95965321af194c3d446c0b5205d90994522
Commit:        12ecd95965321af194c3d446c0b5205d90994522
Parent:        ebc7fc67c88790a475eaaa3f6d650ca81012ed16
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jul 8 15:18:18 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 8 15:18:18 2016 +0200

man: enhance lvconvert

---
 man/lvconvert.8.in |   35 ++++++++++++++++++++++++++++-------
 1 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 855da9a..747bb7d 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -89,7 +89,7 @@ avoid the direct use of hidden LVs.
 VG/StripedLV
 .br
 \[bu]
-Merge StripedLV into an LV when it is a previously split mirror.
+Merge StripedLV into an LV when it is a previously split mirror
 .br
 \[bu]
 See --splitmirror.
@@ -167,14 +167,14 @@ Number
 VG/RaidLV
 .br
 \[bu]
-Change the number of images in RaidLV.
+Change the number of images in a raid1 RaidLV.
 
 .B lvconvert \-\-splitmirrors
 Number
 VG/RaidLV
 .br
 \[bu]
-Split images from RaidLV and use them to create a new LV.
+Split images from raid1 RaidLV and use them to create a new LV.
 .br
 \[bu]
 Also specify \-\-name for new LV, or use \-\-trackchanges.
@@ -197,10 +197,13 @@ Replace failed PVs in RaidLV.
 
 .B lvconvert \-\-replace
 PV
+.B [\-\-replace
+PV
+.B ...]
 VG/RaidLV
 .br
 \[bu]
-Replace a specific PV in a raid* LV with another PV.
+Replace specific PV(s) in a raid* LV with another PV.
 .br
 \[bu]
 The replacement PV can be optionally specified, see below.
@@ -708,7 +711,15 @@ still available in "<pool>_meta<n>" LV.
 .br
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
 that is available in the VG, or from a specific list of PVs specified on
-the command line following the LV name.
+the command line following the LV name. This option may be repeated multiple
+times depending on the RaidLV type. Maxima for raid1 are N-1 mirrors,
+for raid4/5 1 stripe, for raid6 2 stripes and for raid10 it is the number
+of stripes, i.e. one mirror in each mirror group. It is recommended to keep
+resilience whilst replacing PVs whenever possible, i.e. only replace a maximum
+of N-2 mirrors in a raid1 LV and 1 stripe in a raid6 LV at a time;
+this is not possible with raid4/5/10 LVs, because any single replaced PV
+will render the RaidLV non-resilient against another PV failure during replacement.
+.br
 (This option only applies to \fBraid*\fP LV types.)
 .
 .HP
@@ -863,7 +874,6 @@ Convert a mirror LV to a raid1 LV with the same number of images:
 
 ./" Split and merge a COW snapshot:
 ./" TODO
-
 Convert a linear LV to a two-way mirror LV, allocating new extents from specific
 PV ranges:
 .br
@@ -888,10 +898,21 @@ Merge an image (that was previously created with \-\-splitmirrors and
 .B lvconvert \-\-merge vg/lvol1_rimage_1
 ./" FIXME: use merge-mirror
 
-Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1 LV:
+Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV:
 .br
 .B lvconvert \-\-replace /dev/sdb1 vg/lvol1 /dev/sdf1
 
+Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV:
+.br
+.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 \-\-replace /dev/sdd1
+.RS
+.B vg/lvol1 /dev/sd[fgh]1
+.RE
+
+Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV:
+.br
+.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
+
 Convert an LV into a thin LV in the specified thin pool.  The existing LV
 is used as an external read\-only origin for the new thin LV.
 .br


