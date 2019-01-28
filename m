From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:41:18 -0500
Subject: master - man: vdo regenerated
Message-ID: <201901282141.x0SLfIQ3002831@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d04520c321cc33b2874c3f09d126602cb714a9ac
Commit:        d04520c321cc33b2874c3f09d126602cb714a9ac
Parent:        cb90606c8338617d7ae3d13b5c5e381def030ff7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 21:37:23 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:39:10 2019 +0100

man: vdo regenerated

Correcting order of appearance of VDO description in lvcreate.
---
 man/lvconvert.8_pregen |    7 +-
 man/lvcreate.8_des     |   11 +
 man/lvcreate.8_pregen  | 3454 ++----------------------------------------------
 man/lvresize.8_pregen  |    9 +-
 4 files changed, 134 insertions(+), 3347 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index cefdb0d..26bcf5f 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -223,7 +223,7 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .ad b
 .br
 .ad l
@@ -1451,7 +1451,7 @@ the image (see --splitmirrors with --name.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -1459,9 +1459,10 @@ For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\
 For thin provisioning (\fBthin\fP, \fBthin-pool\fP) see \fBlvmthin\fP(7).
 For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
+For VDO (\fBvdo\fP) see \fBlvmvdo\fP(7).
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index 589bd63..7bb2bb6 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -25,6 +25,10 @@ Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
+
+VDO LVs are also provisioned volumes from a VDO pool, and are created with a
+virtual size rather than a physical size (see \fBlvmvdo\fP(7)).
+
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP. See descriptions in the options section.
@@ -33,3 +37,10 @@ In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.
+
+In the usage section below, when creating a pool and the name is omitted
+the new LV pool name is generated with the
+"vpool" for vdo-pools  for prefix and a unique numeric suffix.
+
+Pool name can be specified together with \fIVG\fP name i.e.:
+vg00/mythinpool.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index ff68447..f1d9f13 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -231,7 +231,7 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .ad b
 .br
 .ad l
@@ -293,6 +293,10 @@ Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
+
+VDO LVs are also provisioned volumes from a VDO pool, and are created with a
+virtual size rather than a physical size (see \fBlvmvdo\fP(7)).
+
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP. See descriptions in the options section.
@@ -301,133 +305,13 @@ In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.
-.SH USAGE
-Create an LV that returns VDO when used.
-.br
-.P
-\fBlvcreate\fP \fB--type\fP \fBvdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
-.br
-.RS 4
-.ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--vdo\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
-.ad l
-[    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
 
+In the usage section below, when creating a pool and the name is omitted
+the new LV pool name is generated with the
+"vpool" for vdo-pools  for prefix and a unique numeric suffix.
+Also pool name can be specified together with \fIVG\fP name i.e.:
+vg00/mythinpool.
+.SH USAGE
 Create a linear LV.
 .br
 .P
@@ -439,93 +323,9 @@ Create a linear LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBlinear\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -548,90 +348,6 @@ Create a striped LV (infers --type striped).
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -655,54 +371,6 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
@@ -714,42 +382,6 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -785,54 +417,6 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
@@ -840,42 +424,6 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -906,54 +454,6 @@ Create a raid10 LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
@@ -961,42 +461,6 @@ Create a raid10 LV.
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1028,93 +492,9 @@ Create a COW snapshot LV of an origin LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1138,54 +518,6 @@ Create a thin pool.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -1213,42 +545,6 @@ Create a thin pool.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1276,54 +572,6 @@ Create a cache pool.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -1347,42 +595,6 @@ Create a cache pool.
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1402,54 +614,6 @@ Create a thin LV in a thin pool (infers --type thin).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -1461,42 +625,6 @@ Create a thin LV in a thin pool (infers --type thin).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1511,54 +639,6 @@ Create a thin LV that is a snapshot of an existing thin LV
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -1570,42 +650,6 @@ Create a thin LV that is a snapshot of an existing thin LV
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1626,54 +670,6 @@ Create a thin LV that is a snapshot of an external origin LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -1689,45 +685,55 @@ Create a thin LV that is a snapshot of an external origin LV.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
+Create a LV that returns VDO when used.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBvdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
+.RS 4
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[    \fB--ignoremonitoring\fP ]
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--minor\fP \fINumber\fP ]
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB--vdo\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosync\fP ]
+[    \fB--vdopool\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
 .RE
 .br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 -
 
 Create a thin LV, first creating a thin pool for it, 
@@ -1754,54 +760,6 @@ where the new thin pool is named by the --thinpool arg.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -1825,42 +783,6 @@ where the new thin pool is named by the --thinpool arg.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1895,83 +817,94 @@ by the --cachepool arg.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+[    \fB--cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+[    \fB--cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Common options for command:
+.
+.RS 4
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 .ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
@@ -2009,18 +942,6 @@ by the --cachepool arg.
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
-Common options for command:
-.
-.RS 4
 .RE
 
 Common options for lvm:
@@ -2624,7 +1545,7 @@ The name of a thin pool LV.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -2632,9 +1553,10 @@ For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\
 For thin provisioning (\fBthin\fP, \fBthin-pool\fP) see \fBlvmthin\fP(7).
 For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
+For VDO (\fBvdo\fP) see \fBlvmvdo\fP(7).
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
@@ -2777,237 +1699,9 @@ Create an LV that returns errors when used.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
--
-
-Create an VDO LV with VDO pool.
-.br
-.P
-\fBlvcreate\fP \fB--vdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
-.br
-.RS 4
-.ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
-.ad l
-[    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
-Create an VDO LV using existing VDO pool.
-.br
-.P
-\fBlvcreate\fP \fB--vdopool\fP \fILV\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
-.br
-.RS 4
-.ad l
-[    \fB--vdo\fP ]
-.ad b
-.br
-.ad l
-[    \fB--type\fP \fBvdo\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
 -
 
 Create an LV that returns zeros when read.
@@ -3020,90 +1714,6 @@ Create an LV that returns zeros when read.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3119,90 +1729,6 @@ Create a linear LV.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3229,90 +1755,6 @@ Create a striped LV (also see lvcreate --stripes).
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3348,93 +1790,9 @@ Create a mirror LV (also see --type raid1).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3471,90 +1829,6 @@ Create a COW snapshot LV of an origin LV
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3586,90 +1860,6 @@ Create a sparse COW snapshot LV of a virtual origin LV
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3696,93 +1886,9 @@ Create a sparse COW snapshot LV of a virtual origin LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3806,54 +1912,6 @@ Create a thin pool (infers --type thin-pool).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -3881,42 +1939,6 @@ Create a thin pool (infers --type thin-pool).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -3946,54 +1968,6 @@ Create a thin pool named by the --thinpool arg
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -4021,42 +1995,6 @@ Create a thin pool named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4089,54 +2027,6 @@ Create a cache pool named by the --cachepool arg
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -4160,42 +2050,6 @@ Create a cache pool named by the --cachepool arg
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4222,54 +2076,6 @@ Create a thin LV in a thin pool.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -4285,42 +2091,6 @@ Create a thin LV in a thin pool.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4339,54 +2109,6 @@ Create a thin LV in a thin pool named in the first arg
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
@@ -4394,42 +2116,6 @@ Create a thin LV in a thin pool named in the first arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4450,54 +2136,6 @@ naming pool.)
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -4509,42 +2147,6 @@ naming pool.)
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4561,54 +2163,6 @@ Create a thin LV that is a snapshot of an existing thin LV.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
@@ -4616,42 +2170,6 @@ Create a thin LV that is a snapshot of an existing thin LV.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4666,54 +2184,6 @@ Create a thin LV that is a snapshot of an existing thin LV
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -4725,42 +2195,6 @@ Create a thin LV that is a snapshot of an existing thin LV
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -4775,104 +2209,108 @@ Create a thin LV that is a snapshot of an external origin LV
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
+[ COMMON_OPTIONS ]
+.RE
 .br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
+-
+
+Create a VDO LV with VDO pool.
 .br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
+.P
+\fBlvcreate\fP \fB--vdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
+.RS 4
 .ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+[    \fB--vdopool\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
+[ COMMON_OPTIONS ]
+.RE
 .br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Create a VDO LV with VDO pool.
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
+.P
+\fBlvcreate\fP \fB--vdopool\fP \fILV\fP\fI_new\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
+.RS 4
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[    \fB--ignoremonitoring\fP ]
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--minor\fP \fINumber\fP ]
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB--vdo\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosync\fP ]
+[    \fB--type\fP \fBvdo\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
 .RE
 .br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 -
 
 Create a thin LV, first creating a thin pool for it, 
@@ -4901,54 +2339,6 @@ where the new thin pool is named by the --thinpool arg
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -4972,42 +2362,6 @@ where the new thin pool is named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5042,54 +2396,6 @@ where the new thin pool is named by the --thinpool arg
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5113,42 +2419,6 @@ where the new thin pool is named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5185,54 +2455,6 @@ arg is a VG name.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5256,42 +2478,6 @@ arg is a VG name.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5324,54 +2510,6 @@ arg is a VG name (variant, infers --type thin).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5395,42 +2533,6 @@ arg is a VG name (variant, infers --type thin).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5468,54 +2570,6 @@ config setting sparse_segtype_default.
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5543,42 +2597,6 @@ config setting sparse_segtype_default.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5610,54 +2628,6 @@ by the --cachepool arg (variant, infers --type cache).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5685,42 +2655,6 @@ by the --cachepool arg (variant, infers --type cache).
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5752,54 +2686,6 @@ in the first arg (variant, also use --cachepool).
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5831,42 +2717,6 @@ in the first arg (variant, also use --cachepool).
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -5902,54 +2752,6 @@ to type cache after creating a new cache pool LV to use
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
-.br
-.ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
-.br
-.ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
-.br
-.ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -5981,42 +2783,6 @@ to type cache after creating a new cache pool LV to use
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-.ad l
-[    \fB--addtag\fP \fITag\fP ]
-.ad b
-.br
-.ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--minor\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--nosync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
-.br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -6091,6 +2857,10 @@ to the first image).
 .br
 .B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
 
+Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
+.br
+.B lvcreate --T --size 256G --name mythin vg00/tpool0
+
 Create a 1TiB thin LV, first creating a new thin pool for it, where
 the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
 size, and 256KiB chunk size.
@@ -6122,6 +2892,10 @@ then combining the new origin LV with an existing cache pool.
 .RS
 .B -L 100G -n mylv vg00 /dev/slow1
 .RE
+
+Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
+.br
+.B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1
 .SH SEE ALSO
 
 .BR lvm (8)
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index e3a124a..f1a67c4 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -107,7 +107,7 @@ lvresize - Resize a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .ad b
 .br
 .ad l
@@ -224,7 +224,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
+[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP ]
 .ad b
 .RE
 
@@ -522,7 +522,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -530,9 +530,10 @@ For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\
 For thin provisioning (\fBthin\fP, \fBthin-pool\fP) see \fBlvmthin\fP(7).
 For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
+For VDO (\fBvdo\fP) see \fBlvmvdo\fP(7).
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP


