From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 16:41:08 +0000 (UTC)
Subject: master - cache: comment out unsupported pooldatasize
Message-ID: <20141124164108.29EAB60CD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e50c9bd7cdf22690ee9d6de853a07d743806c3d8
Commit:        e50c9bd7cdf22690ee9d6de853a07d743806c3d8
Parent:        d184e8d0bac11f64ec7a5e8dc2a0fcd5b2714890
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 17:38:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 17:38:39 2014 +0100

cache: comment out unsupported pooldatasize

Support for pooldatasize is not yet finished, so keep it commented out
for now.
---
 man/lvconvert.8.in |   16 ++++++++--------
 man/lvcreate.8.in  |   29 +++++++++++++++--------------
 tools/commands.h   |    7 ++++---
 3 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 10bc478..7dd1051 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -154,10 +154,10 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .B \-\-type
 .BR \fIcache [ \fI\-pool ]| \-H | \-\-cache
 .RB [ \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
-|
-.B \-\-pooldatasize
-.IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]]
+.IR CachePoolLogicalVolume { Name | Path }]
+.\" |
+.\" .B \-\-pooldatasize
+.\" .IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -386,10 +386,10 @@ Without this option a default name of "lvol<n>" will be generated where
 This volume will be read-only and cannot be further modified as long,
 as it is being used as the external origin.
 .TP
-.IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
-Sets the size of pool's data logical volume.
-The option \fB\-\-size\fP could be still used with thin pools.
-.TP
+.\" .IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
+.\" Sets the size of pool's data logical volume.
+.\" The option \fB\-\-size\fP could be still used with thin pools.
+.\" .TP
 .BR \-\-poolmetadata " " \fIPoolMetadataLogicalVolume { \fIName | \fIPath }
 Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index e2b6d91..cc51546 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -60,9 +60,9 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
 .RB [ \-M | \-\-persistent
-.RI { y | n }
-.RB [ \-\-pooldatasize
-.IR DataVolumeSize [ bBsSkKmMgGtTpPeE ]]
+.RI { y | n }]
+.\" .RB [ \-\-pooldatasize
+.\" .IR DataVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-\-poolmetadatasize
 .IR MetadataVolumeSize [ bBsSkKmMgG ]]
 .RB [ \-\-poolmetadataspare
@@ -100,7 +100,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-l | \-\-extents
 .IR LogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
 |
-.BR \-L | \-\-size | \-\-pooldatasize
+.BR \-L | \-\-size
+.\" | \-\-pooldatasize
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
@@ -168,8 +169,8 @@ will activate only on the local node.
 Creates cache or cache pool logical volume or both.
 Specifying the optional argument \fB\-\-size\fP will cause the creation of
 the cache logical volume.
-Specifying the optional argument \fB\-\-pooldatasize\fP will cause
-the creation of the cache pool logical volume.
+.\" Specifying the optional argument \fB\-\-pooldatasize\fP will cause
+.\" the creation of the cache pool logical volume.
 Specifying both arguments will cause the creation of cache with its
 cache pool volume.
 When the Volume group name is specified together with existing logical volume
@@ -350,11 +351,11 @@ Pool volumes cannot have persistent major and minor numbers.
 Defaults to \fIy\fPes only when major or minor number is specified.
 Otherwise it is \fIn\fPo.
 .TP
-.IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
-Sets the size of pool's data logical volume.
-For thin pools you may also specify the size
-with the option \fB\-\-size\fP.
-.TP
+.\" .IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
+.\" Sets the size of pool's data logical volume.
+.\" For thin pools you may also specify the size
+.\" with the option \fB\-\-size\fP.
+.\" .TP
 .IR \fB\-\-poolmetadatasize " " MetadataVolumeSize [ bBsSkKmMgG ]
 Sets the size of pool's metadata logical volume.
 Supported values are in range between 2MiB and 16GiB for thin pool,
@@ -675,9 +676,9 @@ volume (i.e. the origin LV), creating a cache LV.
 .sp
 .B lvcreate \-\-type cache \-L 1G \-n my_lv_cachepool vg/my_lv /dev/fast1
 
-Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
-.sp
-.B lvcreate \-\-cache \-L 1G \-n lv --pooldatasize 10M vg00/pool
+.\" Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
+.\" .sp
+.\" .B lvcreate \-\-cache \-L 1G \-n lv --pooldatasize 10M vg00/pool
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/tools/commands.h b/tools/commands.h
index 4765923..852b675 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -281,7 +281,7 @@ xx(lvcreate,
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
-   "\t[--pooldatasize DataSize[bBsSkKmMgGtTpPeE]]\n"
+   //"\t[--pooldatasize DataSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
    "\t[--poolmetadataspare {y|n}]]\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
@@ -321,7 +321,7 @@ xx(lvcreate,
    "\t[-K|--ignoreactivationskip]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[--pooldatasize DataVolumeSize[bBsSkKmMgGtTpPeE]]\n"
+   //"\t[--pooldatasize DataVolumeSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
    "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
@@ -343,7 +343,8 @@ xx(lvcreate,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
    minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
    noudevsync_ARG, permission_ARG, persistent_ARG,
-   pooldatasize_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
+   //pooldatasize_ARG,
+   poolmetadatasize_ARG, poolmetadataspare_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
    readahead_ARG, regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG,
    stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,


