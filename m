From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 Jul 2016 19:34:46 +0000 (UTC)
Subject: master - man: lvconvert changes
Message-ID: <20160708193446.E7E4260FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7771793a560b839e6bc4083819bc5b192d94835a
Commit:        7771793a560b839e6bc4083819bc5b192d94835a
Parent:        3951ca93204742d23b56f8d253230d33f322aad5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 8 11:55:42 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 8 14:34:36 2016 -0500

man: lvconvert changes

---
 man/lvconvert.8.in |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 747bb7d..e85fe96 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -89,7 +89,7 @@ avoid the direct use of hidden LVs.
 VG/StripedLV
 .br
 \[bu]
-Merge StripedLV into an LV when it is a previously split mirror
+Merge StripedLV into an LV when it is a previously split mirror.
 .br
 \[bu]
 See --splitmirror.
@@ -167,7 +167,7 @@ Number
 VG/RaidLV
 .br
 \[bu]
-Change the number of images in a raid1 RaidLV.
+Change the number of images in raid1 RaidLV.
 
 .B lvconvert \-\-splitmirrors
 Number
@@ -197,9 +197,6 @@ Replace failed PVs in RaidLV.
 
 .B lvconvert \-\-replace
 PV
-.B [\-\-replace
-PV
-.B ...]
 VG/RaidLV
 .br
 \[bu]
@@ -207,6 +204,9 @@ Replace specific PV(s) in a raid* LV with another PV.
 .br
 \[bu]
 The replacement PV can be optionally specified, see below.
+.br
+\[bu]
+Repeat to replace multiple: \-\-replace PV1 \-\-replace PV2 ...
 
 .B lvconvert \-\-type snapshot
 VG/RaidLV
@@ -333,6 +333,9 @@ VG/CachePoolLV
 .br
 \[bu]
 Split the cache LV from CachePoolLV.
+.br
+\[bu]
+Equivalent to --splitcache on CacheLV.
 
 .SS Operations on CacheLV with type cache:
 
@@ -587,8 +590,8 @@ This option is required when converting an LV to a \fBraid1\fP or
 This option can be used alone to change the number of mirror images in an
 existing \fBraid1\fP or \fBmirror\fP LV.
 
-The special case \fB\-\-mirrors 0\fP indicates a linear LV with no mirror
-images.
+The special case \fB\-\-mirrors 0\fP has been used historically to
+indicate a linear LV with no mirror images.
 .
 .HP
 .BR \-n ,
@@ -709,17 +712,12 @@ still available in "<pool>_meta<n>" LV.
 .BR \-\-replace
 .IR PhysicalVolume
 .br
-Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
+Remove the specified device \fIPhysicalVolume\fP and replace it with one
 that is available in the VG, or from a specific list of PVs specified on
 the command line following the LV name. This option may be repeated multiple
-times depending on the RaidLV type. Maxima for raid1 are N-1 mirrors,
-for raid4/5 1 stripe, for raid6 2 stripes and for raid10 it is the number
-of stripes, i.e. one mirror in each mirror group. It is recommended to keep
-resilience whilst replacing PVs whenever possible, i.e. only replace a maximum
-of N-2 mirrors in a raid1 LV and 1 stripe in a raid6 LV at a time;
-this is not possible with raid4/5/10 LVs, because any single replaced PV
-will render the RaidLV non-resilient against another PV failure during replacement.
-.br
+times depending on the RaidLV type.  See
+.BR lvmraid (7)
+for specific limits on device replacement for each raid level.
 (This option only applies to \fBraid*\fP LV types.)
 .
 .HP
@@ -766,7 +764,7 @@ Also see
 .IR Number
 .br
 Specifies the number of stripes in a striped LV.  This is the number of
-physical volumes (devices) across which to spread a striped LV.  Data that
+physical volumes (devices) a striped LV is spread across.  Data that
 appears sequential in the LV is spread (striped) across multiple devices
 in units of the stripe size (see below).  This does not apply to existing
 allocated space, only newly allocated space can be striped.


