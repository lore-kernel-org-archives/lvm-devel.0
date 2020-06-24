From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:48 +0000 (GMT)
Subject: master - make: make generate
Message-ID: <20200624130248.5B9A53939C28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88b92d4225b90db82047f3bac55d8059918e9c1b
Commit:        88b92d4225b90db82047f3bac55d8059918e9c1b
Parent:        b7885dbb734de97e39dca28a38850cbb623cf57f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 12:19:35 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

make: make generate

update
---
 conf/example.conf.in   |   6 +-
 man/lvconvert.8_pregen |  58 ++++++++++++
 man/lvcreate.8_pregen  | 246 +++++++++++++++++++++++++++++++++++++++++++++----
 man/lvs.8_pregen       |   4 +
 man/vgck.8_pregen      |   9 ++
 5 files changed, 303 insertions(+), 20 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 05b085792..a3d8ca380 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -488,7 +488,7 @@ allocation {
 	# This configuration option does not have a default value defined.
 
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
-	# Thin pool metdata and data will always use different PVs.
+	# Thin pool metadata and data will always use different PVs.
 	thin_pool_metadata_require_separate_pvs = 0
 
 	# Configuration option allocation/thin_pool_zero.
@@ -526,6 +526,10 @@ allocation {
 	# This configuration option has an automatic default value.
 	# thin_pool_chunk_size_policy = "generic"
 
+	# Configuration option allocation/zero_metadata.
+	# Zero whole metadata area before use with thin or cache pool.
+	zero_metadata = 1
+
 	# Configuration option allocation/thin_pool_chunk_size.
 	# The minimal chunk size in KiB for thin pool volumes.
 	# Larger chunk sizes may improve performance for plain thin volumes,
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 74409848c..37b0a47d2 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -22,6 +22,10 @@ lvconvert - Change logical volume layout
  \fB-H\fP|\fB--cache\fP
 .ad b
 .br
+.ad l
+    \fB--cachedevice\fP \fIPV\fP
+.ad b
+.br
 .ad l
     \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .ad b
@@ -42,6 +46,10 @@ lvconvert - Change logical volume layout
     \fB--cachesettings\fP \fIString\fP
 .ad b
 .br
+.ad l
+    \fB--cachesize\fP \fISize\fP[m|UNIT]
+.ad b
+.br
 .ad l
     \fB--cachevol\fP \fILV\fP
 .ad b
@@ -738,6 +746,44 @@ Attach a cache to an LV, converts the LV to type cache.
 .br
 -
 
+Add a writecache to an LV, using a specified cache device.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP
+.br
+.RS 4
+.ad l
+[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
+Add a cache to an LV, using a specified cache device.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP
+.br
+.RS 4
+.ad l
+[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Convert LV to type thin-pool.
 .br
 .P
@@ -1135,6 +1181,12 @@ See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
 .HP
 .ad l
+\fB--cachedevice\fP \fIPV\fP
+.br
+The name of a device to use for a cache.
+.ad b
+.HP
+.ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
@@ -1182,6 +1234,12 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
+\fB--cachesize\fP \fISize\fP[m|UNIT]
+.br
+The size of cache to use.
+.ad b
+.HP
+.ad l
 \fB--cachevol\fP \fILV\fP
 .br
 The name of a cache volume.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index be8e78389..ee6903431 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -30,6 +30,10 @@ lvcreate - Create a logical volume
  \fB-H\fP|\fB--cache\fP
 .ad b
 .br
+.ad l
+    \fB--cachedevice\fP \fIPV\fP
+.ad b
+.br
 .ad l
     \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .ad b
@@ -50,6 +54,14 @@ lvcreate - Create a logical volume
     \fB--cachesettings\fP \fIString\fP
 .ad b
 .br
+.ad l
+    \fB--cachesize\fP \fISize\fP[m|UNIT]
+.ad b
+.br
+.ad l
+    \fB--cachevol\fP \fILV\fP
+.ad b
+.br
 .ad l
  \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .ad b
@@ -816,11 +828,9 @@ where the new thin pool is named by the --thinpool arg.
 .RE
 -
 
-Create a cache LV, first creating a new origin LV, 
+Create a new LV, then attach the specified cachepool 
 .br
-then combining it with the existing cache pool named 
-.br
-by the --cachepool arg.
+which converts the new LV to type cache.
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -881,6 +891,190 @@ by the --cachepool arg.
 .RE
 -
 
+Create a new LV, then attach the specified cachevol 
+.br
+which converts the new LV to type cache.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+.RS 5
+ \fB--cachevol\fP \fILV\fP \fIVG\fP
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachepolicy\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Create a new LV, then attach a cachevol created from 
+.br
+the specified cache device, which converts the 
+.br
+new LV to type cache.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+.RS 5
+ \fB--cachedevice\fP \fIPV\fP \fIVG\fP
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachepolicy\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Create a new LV, then attach the specified cachevol 
+.br
+which converts the new LV to type writecache.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBwritecache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+.RS 5
+ \fB--cachevol\fP \fILV\fP \fIVG\fP
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Create a new LV, then attach a cachevol created from 
+.br
+the specified cache device, which converts the 
+.br
+new LV to type writecache.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBwritecache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+.RS 5
+ \fB--cachedevice\fP \fIPV\fP \fIVG\fP
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
 Common options for command:
 .
 .RS 4
@@ -1091,6 +1285,12 @@ See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
 .HP
 .ad l
+\fB--cachedevice\fP \fIPV\fP
+.br
+The name of a device to use for a cache.
+.ad b
+.HP
+.ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
@@ -1138,6 +1338,18 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
+\fB--cachesize\fP \fISize\fP[m|UNIT]
+.br
+The size of cache to use.
+.ad b
+.HP
+.ad l
+\fB--cachevol\fP \fILV\fP
+.br
+The name of a cache volume.
+.ad b
+.HP
+.ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
@@ -2659,11 +2871,11 @@ config setting sparse_segtype_default.
 .RE
 -
 
-Create a cache LV, first creating a new origin LV, 
+Create a new LV, then attach the specified cachepool 
 .br
-then combining it with the existing cache pool named 
+which converts the new LV to type cache 
 .br
-by the --cachepool arg (variant, infers --type cache).
+(variant, infers --type cache.)
 .br
 .P
 \fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
@@ -2717,11 +2929,11 @@ by the --cachepool arg (variant, infers --type cache).
 .RE
 -
 
-Create a cache LV, first creating a new origin LV, 
+Create a new LV, then attach the specified cachepool 
 .br
-then combining it with the existing cache pool named 
+which converts the new LV to type cache. 
 .br
-in the first arg (variant, also use --cachepool).
+(variant, also use --cachepool).
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP\fI_cachepool\fP
@@ -2779,19 +2991,15 @@ in the first arg (variant, also use --cachepool).
 .RE
 -
 
-When LV is a cache pool, create a cache LV, 
-.br
-first creating a new origin LV, then combining it with 
-.br
-the existing cache pool named in the first arg 
+When the LV arg is a cachepool, then create a new LV and 
 .br
-(variant, infers --type cache, also use --cachepool). 
+attach the cachepool arg to it. 
 .br
-When LV is not a cache pool, convert the specified LV 
+(variant, use --type cache and --cachepool.) 
 .br
-to type cache after creating a new cache pool LV to use 
+When the LV arg is not a cachepool, then create a new cachepool 
 .br
-(use lvconvert).
+and attach it to the LV arg (alternative, use lvconvert.)
 .br
 .P
 \fBlvcreate\fP \fB-H\fP|\fB--cache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 8c3091dee..8aea3566a 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -577,6 +577,10 @@ Related to Thin Logical Volumes: (F)ailed.
 .br
 (F)ailed is set when related thin pool enters Failed state and no further I/O
 is permitted at all.
+.IP
+Related to writecache logical volumes: (E)rror.
+.br
+(E)rror is set dm-writecache reports an error.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
 .SH SEE ALSO
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index a66de5d7f..2a1ec2364 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -199,6 +199,15 @@ back metadata it believes has changed but hasn't.
 \fB--updatemetadata\fP
 .br
 Update VG metadata to correct problems.
+If VG metadata was updated while a PV was missing, and the PV
+reappears with an old version of metadata, then this option
+(or any other command that writes metadata) will update the
+metadata on the previously missing PV. If a PV was removed
+from a VG while it was missing, and the PV reappears, using
+this option will clear the outdated metadata from the previously
+missing PV. If metadata text is damaged on one PV, using this
+option will replace the damaged metadata text. For more severe
+damage, e.g. with headers, see \fBpvck\fP(8).
 .ad b
 .HP
 .ad l


