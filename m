From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 24 Jul 2017 20:27:26 -0400
Subject: master - make generate
Message-ID: <201707250027.v6P0RQtG010673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1dbefe9c8cd7f9bcbf19d0516082a3f354703b4
Commit:        a1dbefe9c8cd7f9bcbf19d0516082a3f354703b4
Parent:        5fd7c0aa3340a58318d0bcfb0ae5aeb9924881f6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 25 01:26:58 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 25 01:26:58 2017 +0100

make generate

---
 man/lvconvert.8_pregen |   14 ++--
 man/lvcreate.8_pregen  |   60 +++++++-------
 man/vgchange.8_pregen  |  203 ++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 208 insertions(+), 69 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 6855550..93a8b27 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1424,7 +1424,7 @@ Alternate command forms, advanced command usage, and listing of all valid syntax
 .P
 Convert LV to type mirror (also see type raid1), 
 .br
-(also see lvconvert \-\-mirrors).
+(also see lvconvert --mirrors).
 .br
 .P
 \fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
@@ -1481,7 +1481,7 @@ Change the type of mirror log used by a mirror LV.
 
 Convert LV to a thin LV, using the original LV as an external origin 
 .br
-(infers \-\-type thin).
+(infers --type thin).
 .br
 .P
 \fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
@@ -1528,7 +1528,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 .br
 -
 
-Convert LV to type cache (infers \-\-type cache).
+Convert LV to type cache (infers --type cache).
 .br
 .P
 \fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
@@ -1613,11 +1613,11 @@ Swap metadata LV in a thin pool or cache pool (for repair only).
 .br
 -
 
-Merge LV that was split from a mirror (variant, use \-\-mergemirrors). 
+Merge LV that was split from a mirror (variant, use --mergemirrors). 
 .br
-Merge thin LV into its origin LV (variant, use \-\-mergethin). 
+Merge thin LV into its origin LV (variant, use --mergethin). 
 .br
-Merge COW snapshot LV into its origin (variant, use \-\-mergesnapshot).
+Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
 .br
 .P
 \fBlvconvert\fP \fB--merge\fP \fIVG\fP|\fILV\fP\fI_linear_striped_snapshot_thin_raid\fP|\fITag\fP ...
@@ -1693,7 +1693,7 @@ origin LV (first arg) to reverse a splitsnapshot command.
 .br
 -
 
-Poll LV to continue conversion (also see \-\-startpoll).
+Poll LV to continue conversion (also see --startpoll).
 .br
 .P
 \fBlvconvert\fP \fILV\fP\fI_mirror_raid\fP
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 6b05147..71bd82b 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -300,7 +300,7 @@ Create a linear LV.
 .RE
 -
 
-Create a striped LV (infers \-\-type striped).
+Create a striped LV (infers --type striped).
 .br
 .P
 \fBlvcreate\fP \fB-i\fP|\fB--stripes\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
@@ -322,7 +322,7 @@ Create a striped LV (infers \-\-type striped).
 .RE
 -
 
-Create a raid1 or mirror LV (infers \-\-type raid1|mirror).
+Create a raid1 or mirror LV (infers --type raid1|mirror).
 .br
 .P
 \fBlvcreate\fP \fB-m\fP|\fB--mirrors\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
@@ -569,7 +569,7 @@ Create a cache pool.
 .RE
 -
 
-Create a thin LV in a thin pool (infers \-\-type thin).
+Create a thin LV in a thin pool (infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
@@ -598,7 +598,7 @@ Create a thin LV in a thin pool (infers \-\-type thin).
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
-(infers \-\-type thin).
+(infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP\fI_thin\fP
@@ -658,7 +658,7 @@ Create a thin LV that is a snapshot of an external origin LV.
 
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the \-\-thinpool arg.
+where the new thin pool is named by the --thinpool arg.
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
@@ -715,7 +715,7 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-by the \-\-cachepool arg.
+by the --cachepool arg.
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -1606,7 +1606,7 @@ Create a linear LV.
 .RE
 -
 
-Create a striped LV (also see lvcreate \-\-stripes).
+Create a striped LV (also see lvcreate --stripes).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBstriped\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
@@ -1632,7 +1632,7 @@ Create a striped LV (also see lvcreate \-\-stripes).
 .RE
 -
 
-Create a mirror LV (also see \-\-type raid1).
+Create a mirror LV (also see --type raid1).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBmirror\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
@@ -1672,7 +1672,7 @@ Create a mirror LV (also see \-\-type raid1).
 
 Create a COW snapshot LV of an origin LV 
 .br
-(also see \-\-snapshot).
+(also see --snapshot).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBsnapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP
@@ -1708,7 +1708,7 @@ Create a COW snapshot LV of an origin LV
 
 Create a sparse COW snapshot LV of a virtual origin LV 
 .br
-(also see \-\-snapshot).
+(also see --snapshot).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBsnapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -1766,7 +1766,7 @@ Create a sparse COW snapshot LV of a virtual origin LV.
 .RE
 -
 
-Create a thin pool (infers \-\-type thin-pool).
+Create a thin pool (infers --type thin-pool).
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
@@ -1816,9 +1816,9 @@ Create a thin pool (infers \-\-type thin-pool).
 .RE
 -
 
-Create a thin pool named by the \-\-thinpool arg 
+Create a thin pool named by the --thinpool arg 
 .br
-(infers \-\-type thin-pool).
+(infers --type thin-pool).
 .br
 .P
 \fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP \fIVG\fP
@@ -1872,9 +1872,9 @@ Create a thin pool named by the \-\-thinpool arg
 .RE
 -
 
-Create a cache pool named by the \-\-cachepool arg 
+Create a cache pool named by the --cachepool arg 
 .br
-(variant, uses \-\-cachepool in place of \-\-name).
+(variant, uses --cachepool in place of --name).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache-pool\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -1967,7 +1967,7 @@ Create a thin LV in a thin pool.
 
 Create a thin LV in a thin pool named in the first arg 
 .br
-(variant, also see \-\-thinpool for naming pool).
+(variant, also see --thinpool for naming pool).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
@@ -1992,7 +1992,7 @@ Create a thin LV in a thin pool named in the first arg
 
 Create a thin LV in the thin pool named in the first arg 
 .br
-(variant, infers \-\-type thin, also see \-\-thinpool for 
+(variant, infers --type thin, also see --thinpool for 
 .br
 naming pool.)
 .br
@@ -2046,7 +2046,7 @@ Create a thin LV that is a snapshot of an existing thin LV.
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
-(infers \-\-type thin).
+(infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fILV\fP\fI_thin\fP
@@ -2071,7 +2071,7 @@ Create a thin LV that is a snapshot of an existing thin LV
 
 Create a thin LV that is a snapshot of an external origin LV 
 .br
-(infers \-\-type thin).
+(infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
@@ -2096,9 +2096,9 @@ Create a thin LV that is a snapshot of an external origin LV
 
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the \-\-thinpool arg 
+where the new thin pool is named by the --thinpool arg 
 .br
-(variant, infers \-\-type thin).
+(variant, infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -2153,9 +2153,9 @@ where the new thin pool is named by the \-\-thinpool arg
 
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the \-\-thinpool arg 
+where the new thin pool is named by the --thinpool arg 
 .br
-(variant, infers \-\-type thin).
+(variant, infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -2273,7 +2273,7 @@ where the new thin pool is named in the first arg,
 .br
 or the new thin pool name is generated when the first 
 .br
-arg is a VG name (variant, infers \-\-type thin).
+arg is a VG name (variant, infers --type thin).
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
@@ -2324,13 +2324,13 @@ arg is a VG name (variant, infers \-\-type thin).
 
 Create a thin LV, first creating a thin pool for it 
 .br
-(infers \-\-type thin). 
+(infers --type thin). 
 .br
 Create a sparse snapshot of a virtual origin LV 
 .br
-(infers \-\-type snapshot). 
+(infers --type snapshot). 
 .br
-Chooses \-\-type thin or \-\-type snapshot according to 
+Chooses --type thin or --type snapshot according to 
 .br
 config setting sparse_segtype_default.
 .br
@@ -2390,7 +2390,7 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-by the \-\-cachepool arg (variant, infers \-\-type cache).
+by the --cachepool arg (variant, infers --type cache).
 .br
 .P
 \fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
@@ -2448,7 +2448,7 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-in the first arg (variant, also use \-\-cachepool).
+in the first arg (variant, also use --cachepool).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP\fI_cachepool\fP
@@ -2512,7 +2512,7 @@ first creating a new origin LV, then combining it with
 .br
 the existing cache pool named in the first arg 
 .br
-(variant, infers \-\-type cache, also use \-\-cachepool). 
+(variant, infers --type cache, also use --cachepool). 
 .br
 When LV is not a cache pool, convert the specified LV 
 .br
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index b08c2f9..c1628a7 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -3,7 +3,7 @@
 vgchange - Change volume group attributes
 .
 .SH SYNOPSIS
-\fBvgchange\fP \fIoption_args\fP
+\fBvgchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
@@ -250,30 +250,50 @@ required, after which the others are optional.
 .ad b
 .br
 .ad l
-     \fB--systemid\fP \fIString\fP,
+     \fB--profile\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP,
+     \fB--detachprofile\fP,
 .ad b
 .br
 .ad l
-     \fB--profile\fP \fIString\fP,
+     \fB--metadataprofile\fP \fIString\fP )
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-     \fB--detachprofile\fP,
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-     \fB--metadataprofile\fP \fIString\fP )
-.RE
+[ \fB-f\fP|\fB--force\fP ]
+.ad b
 .br
-.RS 4
 .ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoreskippedcluster\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -289,6 +309,18 @@ Start or stop monitoring LVs from dmeventd.
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-f\fP|\fB--force\fP ]
+.ad b
+.br
+.ad l
 [    \fB--sysinit\fP ]
 .ad b
 .br
@@ -300,6 +332,22 @@ Start or stop monitoring LVs from dmeventd.
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoreskippedcluster\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -315,9 +363,37 @@ Start or stop processing LV conversions.
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-f\fP|\fB--force\fP ]
+.ad b
+.br
+.ad l
 [    \fB--ignorelockingfailure\fP ]
 .ad b
 .br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoreskippedcluster\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -341,6 +417,18 @@ Activate or deactivate LVs.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-f\fP|\fB--force\fP ]
+.ad b
+.br
+.ad l
 [    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
 .ad b
 .br
@@ -360,6 +448,22 @@ Activate or deactivate LVs.
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoreskippedcluster\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -375,6 +479,18 @@ Reactivate LVs using the latest metadata.
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-f\fP|\fB--force\fP ]
+.ad b
+.br
+.ad l
 [    \fB--sysinit\fP ]
 .ad b
 .br
@@ -386,6 +502,22 @@ Reactivate LVs using the latest metadata.
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoreskippedcluster\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -394,6 +526,17 @@ Reactivate LVs using the latest metadata.
 .RE
 -
 
+Change the system ID of a VG.
+.br
+.P
+\fBvgchange\fP \fB--systemid\fP \fIString\fP \fIVG\fP
+.br
+.RS 4
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Start the lockspace of a shared VG in lvmlockd.
 .br
 .P
@@ -401,6 +544,10 @@ Start the lockspace of a shared VG in lvmlockd.
 .br
 .RS 4
 .ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--lockopt\fP \fIString\fP ]
 .ad b
 .br
@@ -419,6 +566,10 @@ Stop the lockspace of a shared VG in lvmlockd.
 .br
 .RS 4
 .ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--lockopt\fP \fIString\fP ]
 .ad b
 .br
@@ -430,36 +581,24 @@ Stop the lockspace of a shared VG in lvmlockd.
 .RE
 -
 
-Common options for command:
-.
-.RS 4
-.ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[ \fB-f\fP|\fB--force\fP ]
-.ad b
+Change the lock type for a shared VG.
 .br
-.ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoremonitoring\fP ]
-.ad b
+.P
+\fBvgchange\fP \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP \fIVG\fP
 .br
+.RS 4
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB--lockopt\fP \fIString\fP ]
 .ad b
 .br
-.ad l
-[    \fB--noudevsync\fP ]
-.ad b
+[ COMMON_OPTIONS ]
+.RE
 .br
-.ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
+-
+
+Common options for command:
+.
+.RS 4
 .RE
 
 Common options for lvm:


