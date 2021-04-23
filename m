From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:14 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210423210614.8941E39450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cdd4dcca7e6d166e44270a81425a50e598836f4
Commit:        9cdd4dcca7e6d166e44270a81425a50e598836f4
Parent:        64a8505b96548631ed8fb251dce794077402ad77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 11:28:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:02:58 2021 +0200

make: generate

---
 conf/example.conf.in   |  15 +++---
 man/lvconvert.8_pregen |  26 ++++++-----
 man/lvcreate.8_pregen  | 121 ++++++++++++++++++++++---------------------------
 man/lvextend.8_pregen  |   2 +-
 man/lvreduce.8_pregen  |   2 +-
 man/lvresize.8_pregen  |   2 +-
 6 files changed, 79 insertions(+), 89 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 19efe6b6d..b4a55ae6a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1084,13 +1084,14 @@ global {
 
 	# Configuration option global/event_activation.
 	# Activate LVs based on system-generated device events.
-	# When a device appears on the system, a system-generated event runs
-	# the pvscan command to activate LVs if the new PV completes the VG.
-	# When event_activation is disabled, the system will generally run
-	# a direct activation command to activate LVs in complete VGs.
-	# Activation commands that are run by the system, either from events
-	# or at fixed points during startup, use autoactivation (-aay).  See
-	# the --setautoactivation option or the auto_activation_volume_list
+	# When a PV appears on the system, a system-generated uevent triggers
+	# the lvm2-pvscan service which runs the pvscan --cache -aay command.
+	# If the new PV completes a VG, pvscan autoactivates LVs in the VG.
+	# When event_activation is disabled, the lvm2-activation services are
+	# generated and run at fixed points during system startup.  These
+	# services run vgchange -aay to autoactivate LVs in VGs that happen
+	# to be present at that point in time.
+	# See the --setautoactivation option or the auto_activation_volume_list
 	# setting to configure autoactivation for specific VGs or LVs.
 	# This configuration option has an automatic default value.
 	# event_activation = 1
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index a921438b6..84b4ac75e 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1650,23 +1650,22 @@ LV1 types: mirror
 .P
 \(em
 .P
-Convert LV to a thin LV, using the original LV as an external origin 
-.br
-(infers --type thin).
+Convert LV to a thin LV, using the original LV as an external origin.
 .br
 .P
 \fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
+[ \fB--type thin\fP ] (implied)
+.br
+.br
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
 .br
-[    \fB--type\fP \fBthin\fP ]
-.br
 [    \fB--originname\fP \fILV\fP\fI_new\fP ]
 .br
 [    \fB--poolmetadata\fP \fILV\fP ]
@@ -1687,21 +1686,22 @@ LV1 types: linear striped thin cache raid error zero
 .P
 \(em
 .P
-Attach a cache pool to an LV (infers --type cache).
+Attach a cache pool to an LV.
 .br
 .P
 \fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
+[ \fB--type cache\fP ] (implied)
+.br
+.br
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
 .br
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBcache\fP ]
-.br
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
@@ -1766,6 +1766,9 @@ Convert LV to type vdopool.
 .br
 .RS 4
 .ad l
+[ \fB--type vdo-pool\fP ] (implied)
+.br
+.br
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .br
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
@@ -1774,8 +1777,6 @@ Convert LV to type vdopool.
 .br
 [ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--type\fP \fBvdo-pool\fP ]
-.br
 [    \fB--metadataprofile\fP \fIString\fP ]
 .br
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
@@ -1875,12 +1876,13 @@ origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .RS 4
 .ad l
+[ \fB--type snapshot\fP ] (implied)
+.br
+.br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
 .br
-[    \fB--type\fP \fBsnapshot\fP ]
-.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index c73d1bafc..b642ad0c2 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -225,9 +225,9 @@ Create a linear LV.
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB--type linear\fP ] (implied)
 .br
-[    \fB--type\fP \fBlinear\fP ]
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -238,19 +238,19 @@ Create a linear LV.
 .P
 \(em
 .P
-Create a striped LV (infers --type striped).
+Create a striped LV.
 .br
 .P
 \fBlvcreate\fP \fB-i\fP|\fB--stripes\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
+[ \fB--type striped\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBstriped\fP ]
-.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -260,16 +260,16 @@ Create a striped LV (infers --type striped).
 .P
 \(em
 .P
-Create a raid1 or mirror LV (infers --type raid1|mirror).
+Create a raid1 or mirror LV.
 .br
 .P
 \fBlvcreate\fP \fB-m\fP|\fB--mirrors\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB--type raid1\fP|\fBmirror\fP ] (implied)
 .br
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
@@ -336,6 +336,8 @@ Create a raid10 LV.
 .br
 .RS 4
 .ad l
+[ \fB--type raid10\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
@@ -362,6 +364,8 @@ Create a COW snapshot LV of an origin LV.
 .br
 .RS 4
 .ad l
+[ \fB--type snapshot\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -370,8 +374,6 @@ Create a COW snapshot LV of an origin LV.
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBsnapshot\fP ]
-.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -455,16 +457,17 @@ Create a cache pool.
 .P
 \(em
 .P
-Create a thin LV in a thin pool (infers --type thin).
+Create a thin LV in a thin pool.
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB--type thin\fP ] (implied)
+.br
 .br
-[    \fB--type\fP \fBthin\fP ]
+[ \fB-T\fP|\fB--thin\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -472,16 +475,15 @@ Create a thin LV in a thin pool (infers --type thin).
 .P
 \(em
 .P
-Create a thin LV that is a snapshot of an existing thin LV 
-.br
-(infers --type thin).
+Create a thin LV that is a snapshot of an existing thin LV.
 .br
 .P
 \fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fILV1\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[ \fB--type thin\fP ] (implied)
+.br
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -1685,13 +1687,15 @@ Create a sparse COW snapshot LV of a virtual origin LV
 .P
 \(em
 .P
-Create a thin pool (infers --type thin-pool).
+Create a thin pool.
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
+[ \fB--type thin-pool\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -1700,8 +1704,6 @@ Create a thin pool (infers --type thin-pool).
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBthin-pool\fP ]
-.br
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .br
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
@@ -1719,15 +1721,15 @@ Create a thin pool (infers --type thin-pool).
 .P
 \(em
 .P
-Create a thin pool named by the --thinpool arg 
-.br
-(infers --type thin-pool).
+Create a thin pool named in --thinpool.
 .br
 .P
 \fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP \fIVG\fP
 .br
 .RS 4
 .ad l
+[ \fB--type thin-pool\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -1738,8 +1740,6 @@ Create a thin pool named by the --thinpool arg
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBthin-pool\fP ]
-.br
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .br
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
@@ -1841,18 +1841,17 @@ LV1 types: thinpool
 .P
 Create a thin LV in the thin pool named in the first arg 
 .br
-(variant, infers --type thin, also see --thinpool for 
-.br
-naming pool.)
+(also see --thinpool for naming pool.)
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB--type thin\fP ] (implied)
 .br
-[    \fB--type\fP \fBthin\fP ]
+.br
+[ \fB-T\fP|\fB--thin\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -1883,16 +1882,15 @@ LV1 types: thin
 .P
 \(em
 .P
-Create a thin LV that is a snapshot of an existing thin LV 
-.br
-(infers --type thin).
+Create a thin LV that is a snapshot of an existing thin LV.
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fILV1\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[ \fB--type thin\fP ] (implied)
+.br
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -1904,16 +1902,15 @@ LV1 types: thin
 .P
 \(em
 .P
-Create a thin LV that is a snapshot of an external origin LV 
-.br
-(infers --type thin).
+Create a thin LV that is a snapshot of an external origin LV.
 .br
 .P
 \fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB--thinpool\fP \fILV\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[ \fB--type thin\fP ] (implied)
+.br
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -1928,6 +1925,8 @@ Create a VDO LV with VDO pool.
 .br
 .RS 4
 .ad l
+[ \fB--type vdo\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -1936,8 +1935,6 @@ Create a VDO LV with VDO pool.
 .br
 [ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--type\fP \fBvdo\fP ]
-.br
 [    \fB--vdopool\fP \fILV\fP\fI_new\fP ]
 .br
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
@@ -1960,6 +1957,8 @@ Create a VDO LV with VDO pool.
 .br
 .RS 4
 .ad l
+[ \fB--type vdo\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -1968,10 +1967,6 @@ Create a VDO LV with VDO pool.
 .br
 [ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--vdo\fP ]
-.br
-[    \fB--type\fP \fBvdo\fP ]
-.br
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
@@ -2026,9 +2021,7 @@ where the new thin pool is named by the --thinpool arg.
 .P
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the --thinpool arg 
-.br
-(variant, infers --type thin).
+where the new thin pool is named by --thinpool.
 .br
 .P
 \fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -2038,6 +2031,8 @@ where the new thin pool is named by the --thinpool arg
 .br
 .RS 4
 .ad l
+[ \fB--type thin\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -2048,8 +2043,6 @@ where the new thin pool is named by the --thinpool arg
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBthin\fP ]
-.br
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .br
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
@@ -2116,7 +2109,7 @@ where the new thin pool is named in the first arg,
 .br
 or the new thin pool name is generated when the first 
 .br
-arg is a VG name (variant, infers --type thin).
+arg is a VG name.
 .br
 .P
 \fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
@@ -2126,6 +2119,8 @@ arg is a VG name (variant, infers --type thin).
 .br
 .RS 4
 .ad l
+[ \fB--type thin\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -2134,8 +2129,6 @@ arg is a VG name (variant, infers --type thin).
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBthin\fP ]
-.br
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .br
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
@@ -2153,15 +2146,11 @@ arg is a VG name (variant, infers --type thin).
 .P
 \(em
 .P
-Create a thin LV, first creating a thin pool for it 
-.br
-(infers --type thin). 
+Create a thin LV, first creating a thin pool for it. 
 .br
 Create a sparse snapshot of a virtual origin LV 
 .br
-(infers --type snapshot). 
-.br
-Chooses --type thin or --type snapshot according to 
+Chooses type thin or snapshot according to 
 .br
 config setting sparse_segtype_default.
 .br
@@ -2170,6 +2159,8 @@ config setting sparse_segtype_default.
 .br
 .RS 4
 .ad l
+[ \fB--type thin\fP|\fBsnapshot\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -2182,8 +2173,6 @@ config setting sparse_segtype_default.
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fIString\fP ]
-.br
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .br
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
@@ -2203,15 +2192,15 @@ config setting sparse_segtype_default.
 .P
 Create a new LV, then attach the specified cachepool 
 .br
-which converts the new LV to type cache 
-.br
-(variant, infers --type cache.)
+which converts the new LV to type cache.
 .br
 .P
 \fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP \fIVG\fP
 .br
 .RS 4
 .ad l
+[ \fB--type cache\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
@@ -2222,8 +2211,6 @@ which converts the new LV to type cache
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBcache\fP ]
-.br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .br
 [    \fB--cachepolicy\fP \fIString\fP ]
@@ -2302,6 +2289,8 @@ and attach it to the LV arg (alternative, use lvconvert.)
 .br
 .RS 4
 .ad l
+[ \fB--type cache\fP ] (implied)
+.br
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .br
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
@@ -2310,8 +2299,6 @@ and attach it to the LV arg (alternative, use lvconvert.)
 .br
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--type\fP \fBcache\fP ]
-.br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .br
 [    \fB--cachepolicy\fP \fIString\fP ]
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index fc4d55233..fa0aec63a 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -456,7 +456,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
+Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 13522bb70..0a659e1c8 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -234,7 +234,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
+Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 4e27cf4ee..36c1760fc 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -409,7 +409,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
+Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]


