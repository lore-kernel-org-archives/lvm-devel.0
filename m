From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  1 Oct 2014 15:44:39 +0000 (UTC)
Subject: master - Revert "Revert "man: lvmcache should use clearer cache pool options""
Message-ID: <20141001154439.406EB60F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33b96bef5bd8cfda3cf24007b84597f61a2cf0b6
Commit:        33b96bef5bd8cfda3cf24007b84597f61a2cf0b6
Parent:        a5f01dad224929ea39fd3a53753b8341028017b8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 1 10:43:53 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 1 10:43:53 2014 -0500

Revert "Revert "man: lvmcache should use clearer cache pool options""

This reverts commit f120c954fc065d67c1aacd5cfba58843eb552b0f.
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


