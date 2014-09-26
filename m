From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 26 Sep 2014 19:44:03 +0000 (UTC)
Subject: master - man: lvmcache should use clearer cache pool options
Message-ID: <20140926194403.7754A6101A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b53504ed37d3b0aa8dac193cb4539ea91120253d
Commit:        b53504ed37d3b0aa8dac193cb4539ea91120253d
Parent:        26dd17f8345f512a48768f7fcf74e0c65558032c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 26 14:40:40 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 26 14:40:40 2014 -0500

man: lvmcache should use clearer cache pool options

Previously, this was the recommended form for creating a cache pool:

lvconvert --cachepool VG/CacheDataLV --poolmetadata VG/CacheMetaLV

but this is confusing, because --cachepool does not actually take
an arg, and is more natually used to specify an existing cache pool.

The new recommended form is:

lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV VG/CacheDataLV
---
 man/lvmcache.7.in |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index cc92673..6d7109a 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -88,11 +88,15 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-cachepool VG/CacheDataLV \-\-poolmetadata VG/CacheMetaLV
+.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
+.br
+.RS
+.B VG/CacheDataLV
+.RE
 
 .I Example
 .br
-# lvconvert \-\-cachepool vg/cache0 \-\-poolmetadata vg/cache0meta
+# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache0meta vg/cache0
 
 .nf
 # lvs -a vg
@@ -193,21 +197,21 @@ pool sub-LVs redundant.
 
 .nf
 0. Create an origin LV we wish to cache
-# lvcreate \-L 10G \-n lvx vg /dev/slow_devs
+# lvcreate \-L 10G \-n lv1 vg /dev/slow_devs
 
 1. Create a 2-way RAID1 cache data LV
-# lvcreate \-\-type raid1 \-m 1 \-L 1G -n lvx_cache vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 1G -n cache1 vg \\
 	/dev/fast1 /dev/fast2
 
 2. Create a 2-way RAID1 cache metadata LV
-# lvcreate \-\-type raid1 \-m 1 \-L 8M -n lvx_cache_meta vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 8M -n cache1meta vg \\
 	/dev/fast1 /dev/fast2
 
 3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta
+# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta vg/cache1
 
 4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
+# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
 .fi
 
 .SS Writethough caching
@@ -223,20 +227,20 @@ cache pool LV, properties of the cache can be specified - in this case,
 
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
-# lvcreate \-L 10G \-n lvx vg /dev/slow
+# lvcreate \-L 10G \-n lv1 vg /dev/slow
 
 1. Create a cache data LV
-# lvcreate \-L 1G \-n lvx_cache vg /dev/fast
+# lvcreate \-L 1G \-n cache1 vg /dev/fast
 
 2. Create a cache metadata LV
-# lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast
+# lvcreate \-L 8M \-n cache1meta vg /dev/fast
 
 3. Create a cache pool LV specifying cache mode "writethrough"
-# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta \\
-	\-\-cachemode writethrough
+# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta \\
+	\-\-cachemode writethrough vg/cache1
 
 4. Create a cache LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
+# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
 .fi
 
 .SS Spare metadata LV
@@ -258,7 +262,7 @@ the same VG.
 
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert --cachepool VG/CacheDataLV
+.B lvconvert --type cache\-pool VG/CacheDataLV
 
 
 .SH SEE ALSO


