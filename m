From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:58 +0000 (UTC)
Subject: master - cache: man updates
Message-ID: <20150812124058.1234C61086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cde12a013f006c1b27b878593fe0f1e73a5f79a
Commit:        6cde12a013f006c1b27b878593fe0f1e73a5f79a
Parent:        feb8e9a7907c91bd55769b4e3ae625434f2ba589
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 20 11:55:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:17 2015 +0200

cache: man updates

Better man for cachepolicy and cachesettings.
---
 man/lvconvert.8.in |   17 ++++++++++++++++-
 man/lvcreate.8.in  |   24 +++++++++++++++---------
 2 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 576859b..562de1e 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -162,6 +162,10 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
 .RI { writeback | writethrough }]
+.RB [ \-\-cachepolicy
+.IR policy ]
+.RB [ \-\-cachesettings
+.IR key=value ]
 .RB [ \-\-poolmetadata
 .IR CachePoolMetadataLogicalVolume { Name | Path }
 |
@@ -222,10 +226,21 @@ Converts logical volume to a cached LV with the use of cache pool
 specified with \fB\-\-cachepool\fP.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .TP
+.B \-\-cachepolicy \fIpolicy
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache policy. \fImq\fP is the basic policy name. \fIsqm\fP is more advanced
+version available in newer kernels.
+.TP
 .BR \-\-cachepool " " \fICachePoolLV
 This argument is necessary when converting a logical volume to a cache LV.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .TP
+.BR \-\-cachesettings " " \fIkey=value
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache tunable settings. In most use-cases, default values should be adequate.
+Special string value \fIdefault\fP switches setting back to its default kernel value
+and removes it from the list of settings stored in lvm2 metadata.
+.TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
 For example, "\fB\-m 1\fP" would convert the original logical
@@ -496,7 +511,7 @@ See \fBlvmthin\fP(7) for more info about thin provisioning support.
 Uncaches \fICacheLogicalVolume\fP.
 Before the volume becomes uncached, cache is flushed.
 Unlike with \fB\-\-splitcache\fP the cache pool volume is removed.
-This option could seen as an inverse of \fB\-\-cache\fP.
+This option could be seen as an inverse of \fB\-\-cache\fP.
 
 .SH Examples
 Converts the linear logical volume "vg00/lvol1" to a two-way mirror
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 5f5f74b..5f922b4 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -13,13 +13,13 @@ lvcreate \- create a logical volume in an existing volume group
 .RI { y | n }]
 .RB [ \-H | \-\-cache ]
 .RB [ \-\-cachemode
-.RI { writeback | writethrough }]
+.RI { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
 .IR policy ]
-.RB [ \-\-cachesettings
-.IR key=value ]
 .RB [ \-\-cachepool
 .IR CachePoolLogicalVolume { Name | Path }
+.RB [ \-\-cachesettings
+.IR key=value ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-commandprofile
@@ -188,7 +188,7 @@ See \fBlvmcache\fP(7) for more info about caching support.
 Note that the cache segment type requires a dm-cache kernel module version
 1.3.0 or greater.
 .TP
-.IR \fB\-\-cachemode " {" writeback | writethrough }
+.IR \fB\-\-cachemode " {" passthrough | writeback | writethrough }
 Specifying a cache mode determines when the writes to a cache LV
 are considered complete.  When \fIwriteback\fP is specified, a write is
 considered complete as soon as it is stored in the cache pool LV.
@@ -198,10 +198,21 @@ While \fIwritethrough\fP may be slower for writes, it is more
 resilient if something should happen to a device associated with the
 cache pool LV.
 .TP
+.B \-\-cachepolicy \fIpolicy
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache policy. \fImq\fP is the basic policy name. \fIsqm\fP is more advanced
+version available in newer kernels.
+.TP
 .IR \fB\-\-cachepool " " CachePoolLogicalVolume { Name | Path }
 Specifies the name of cache pool volume name. The other way to specify pool name
 is to append name to Volume group name argument.
 .TP
+.BR \-\-cachesettings " " \fIkey=value
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache tunable settings. In most use-cases, default values should be adequate.
+Special string value \fIdefault\fP switches setting back to its default kernel value
+and removes it from the list of settings stored in lvm2 metadata.
+.TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
@@ -251,11 +262,6 @@ Ignore the flag to skip Logical Volumes during activation.
 Use \fB\-\-setactivationskip\fP option to set or reset
 activation skipping flag persistently for logical volume.
 .TP
-.BR  \-\-cachepolicy " " policy ", " \-\-cachesettings " " key=value
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy and its associated tunable settings. In most use-cases,
-default values should be adequate.
-.TP
 .B \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
 is specified.


