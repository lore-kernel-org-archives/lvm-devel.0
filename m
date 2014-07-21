From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 21 Jul 2014 20:53:44 +0000 (UTC)
Subject: master - man: lvmcache updates
Message-ID: <20140721205344.C93C460A39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe5b282a4a51bcc2780da9ef7ab298d97c45f3db
Commit:        fe5b282a4a51bcc2780da9ef7ab298d97c45f3db
Parent:        1fe487043dadf189b08b9862f45d21438f197cf2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 21 15:41:42 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 21 15:41:42 2014 -0500

man: lvmcache updates

- use the lvconvert --cachepool syntax to match the lvmthin style
- rewrite removal information
- very minor formatting adjustments
---
 man/lvmcache.7.in |  101 +++++++++++++++++++++++++++++++---------------------
 1 files changed, 60 insertions(+), 41 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 87fb9f4..4b21a8a 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -18,7 +18,7 @@ on the origin LV or on the cache data LV).  Users should be familiar with
 these LVs if they wish to create the best and most robust cached
 logical volumes.
 
-.SS Cache Terms
+.SH Cache Terms
 .nf
 origin LV           OriginLV      large slow LV
 cache data LV       CacheDataLV   small fast LV for cache pool data
@@ -27,7 +27,7 @@ cache pool LV       CachePoolLV   CacheDataLV + CacheMetaLV
 cache LV            CacheLV       OriginLV + CachePoolLV
 .fi
 
-.SS Cache Steps
+.SH Cache Steps
 The steps to create a logical volume of \fIcache\fP type are as follows:
 .TP
 0.
@@ -63,34 +63,43 @@ They provide the most options and have the ability to create the
 most robust logical volumes.  The examples below illustrate how these
 steps might be used in practice.
 
-.SS Cache Commands
-.nf
+.SH Cache Commands
+
 0. create OriginLV
-lvcreate \-L LargeSize \-n OriginLV VG SlowPVs
+.br
+.B lvcreate \-L LargeSize \-n OriginLV VG SlowPVs
 
 1. create CacheDataLV
-lvcreate \-L CacheSize \-n CacheDataLV VG FastPVs
+.br
+.B lvcreate \-L CacheSize \-n CacheDataLV VG FastPVs
 
 2. create CacheMetaLV
-lvcreate \-L MetaSize \-n CacheMetaLV VG FastPVs
+.br
+.B lvcreate \-L MetaSize \-n CacheMetaLV VG FastPVs
 
 3. create CachePoolLV
-lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV VG/CacheDataLV
+.br
+.B lvconvert \-\-cachepool VG/CacheDataLV \-\-poolmetadata VG/CacheMetaLV
+.br
 CachePoolLV takes the name of CacheDataLV.
+.br
 CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
+.br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
 4. create CacheLV
-lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
+.br
+.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
+.br
 CacheLV takes the name of OriginLV.
+.br
 OriginLV is renamed OriginLV_corig and becomes hidden.
-.fi
 
-.SS Cache Examples
 
-.B Example 1:
-Creating a simple cache LV.
-.br
+.SH Cache Examples
+
+.SS Example 1
+Create a simple cache LV.
 
 .nf
 0. Create the origin LV
@@ -103,15 +112,14 @@ Creating a simple cache LV.
 # lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast_dev
 
 3. Create a cache pool LV, combining cache data LV and cache metadata LV
-# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
-	vg/lvx_cache
+# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta
 
 4. Create a cached LV by combining the cache pool LV and origin LV
 # lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
-.B Example 2:
-Creating a cache LV with a fault tolerant cache pool LV.
+.SS Example 2
+Create a cache LV with a fault tolerant cache pool LV.
 
 Users who are concerned about the possibility of failures in their fast devices
 that could lead to data loss might consider making their cache pool sub-LVs
@@ -131,15 +139,14 @@ redundant.  Example 2 illustrates how to do that.  Note that only steps
 	/dev/fast1 /dev/fast2
 
 3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
-	vg/lvx_cache
+# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta
 
 4. Create a cached LV by combining the cache pool LV and origin LV
 # lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
-.B Example 3:
-Creating a simple cache LV with \fIwritethough\fP caching.
+.SS Example 3
+Create a simple cache LV with \fIwritethough\fP caching.
 
 Some users wish to ensure that any data written will be stored both in the
 cache pool LV and on the origin LV.  The loss of a device associated with
@@ -160,30 +167,42 @@ in this case.
 # lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast
 
 3. Create a cache pool LV specifying cache mode "writethrough"
-# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
-	\-\-cachemode writethrough vg/lvx_cache
+# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta \\
+	\-\-cachemode writethrough
 
 4. Create a cache LV by combining the cache pool LV and origin LV
 # lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
-.SS Removing Cache Logical Volumes
-If you wish to remove all logical volumes associated with a cache
-LV, you must remove both top-level, user-visible devices.
-The cache metadata LV and cache data LV cannot be removed
-directly.  If only the cache pool LV is specfied for removal, any cached
-blocks not yet on the origin LV will be flush, the cache pool LV will be
-removed, and the now un-cached origin LV will remain.  If the user
-specifies a cache LV for removal, then the origin LV is
-removed and only the cache pool LV will remain.  The cache pool LV can then
-be used to create another cache LV with a different origin LV if desired.
-
-When users intend to remove all logical volumes associated with a
-cache LV, it is generally better to start with the origin LV and then
-remove the cache pool LV.  If the operations are performed in the
-reverse order, the user will have to wait for the contents of the
-cache pool LV to be flushed before the origin LV is removed.  This
-could take some time.
+.SH Cache Removal
+
+.SS Removing a cache pool LV without removing an associated origin LV
+
+This writes back data from the cache pool to the origin LV, then removes
+the cache pool LV, leaving the un-cached origin LV.  (If the origin LV
+will also be removed, the data flushing can be avoided; see "Removing
+both" below.)
+
+.B lvremove VG/CachePoolLV
+
+.SS Removing both an origin LV and its associated cache pool LV
+
+This removes the cache LV, which includes removing both the origin LV and
+its associated cache pool LV.  Data blocks from the cache pool are not
+written back to the origin LV.
+
+.B lvremove VG/CacheLV
+
+./" .SS Separating a cache pool LV from an origin LV
+./" This writes back data from the cache pool to the origin LV, then removes
+./" the association between the cache pool LV and the origin LV.
+./" .br
+./" Not yet implemented.
+
+./" .SS Removing an origin LV without removing an associated cache pool LV
+./" Separate the cache pool LV from the origin LV, then remove the origin LV.
+./" .br
+./" Not yet implemented.
 
 .SH SEE ALSO
 .BR lvm.conf (5),


