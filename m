From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 27 Sep 2014 13:11:13 +0000 (UTC)
Subject: master - Revert "man: lvmcache should use clearer cache pool options"
Message-ID: <20140927131113.04C406115C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f120c954fc065d67c1aacd5cfba58843eb552b0f
Commit:        f120c954fc065d67c1aacd5cfba58843eb552b0f
Parent:        17a1869df506a3641d49d52c413b5bc04ec2adc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 15:10:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 27 15:10:44 2014 +0200

Revert "man: lvmcache should use clearer cache pool options"

Revert: --cachepool  and --thipnpool is the right way

they both take arg

This is a major difference from  --cache   and --thin
---
 man/lvmcache.7.in |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 6d7109a..cc92673 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -88,15 +88,11 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
-.br
-.RS
-.B VG/CacheDataLV
-.RE
+.B lvconvert \-\-cachepool VG/CacheDataLV \-\-poolmetadata VG/CacheMetaLV
 
 .I Example
 .br
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache0meta vg/cache0
+# lvconvert \-\-cachepool vg/cache0 \-\-poolmetadata vg/cache0meta
 
 .nf
 # lvs -a vg
@@ -197,21 +193,21 @@ pool sub-LVs redundant.
 
 .nf
 0. Create an origin LV we wish to cache
-# lvcreate \-L 10G \-n lv1 vg /dev/slow_devs
+# lvcreate \-L 10G \-n lvx vg /dev/slow_devs
 
 1. Create a 2-way RAID1 cache data LV
-# lvcreate \-\-type raid1 \-m 1 \-L 1G -n cache1 vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 1G -n lvx_cache vg \\
 	/dev/fast1 /dev/fast2
 
 2. Create a 2-way RAID1 cache metadata LV
-# lvcreate \-\-type raid1 \-m 1 \-L 8M -n cache1meta vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 8M -n lvx_cache_meta vg \\
 	/dev/fast1 /dev/fast2
 
 3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta vg/cache1
+# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta
 
 4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
+# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
 .SS Writethough caching
@@ -227,20 +223,20 @@ cache pool LV, properties of the cache can be specified - in this case,
 
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
-# lvcreate \-L 10G \-n lv1 vg /dev/slow
+# lvcreate \-L 10G \-n lvx vg /dev/slow
 
 1. Create a cache data LV
-# lvcreate \-L 1G \-n cache1 vg /dev/fast
+# lvcreate \-L 1G \-n lvx_cache vg /dev/fast
 
 2. Create a cache metadata LV
-# lvcreate \-L 8M \-n cache1meta vg /dev/fast
+# lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast
 
 3. Create a cache pool LV specifying cache mode "writethrough"
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta \\
-	\-\-cachemode writethrough vg/cache1
+# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta \\
+	\-\-cachemode writethrough
 
 4. Create a cache LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
+# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
 .SS Spare metadata LV
@@ -262,7 +258,7 @@ the same VG.
 
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert --type cache\-pool VG/CacheDataLV
+.B lvconvert --cachepool VG/CacheDataLV
 
 
 .SH SEE ALSO


