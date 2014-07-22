From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:12:11 +0000 (UTC)
Subject: master - man: rework lvmcache to match lvmthin
Message-ID: <20140722201211.718F260DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=864ff3cb181183ccfabc8a2e3c53ddcd1e36390f
Commit:        864ff3cb181183ccfabc8a2e3c53ddcd1e36390f
Parent:        50961f43d03aec309dd06e121d03a6fd7b301850
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 22 15:10:35 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 22 15:12:02 2014 -0500

man: rework lvmcache to match lvmthin

Reorganize and rewrite parts to match lvmthin(7).
---
 man/lvmcache.7.in |  251 ++++++++++++++++++++++++++++++++--------------------
 1 files changed, 154 insertions(+), 97 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 4b21a8a..cc92673 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -4,7 +4,7 @@ lvmcache \(em LVM caching
 
 .SH DESCRIPTION
 
-The \fIcache\fP logical volume type uses a small and fast LV to improve
+The \fBcache\fP logical volume type uses a small and fast LV to improve
 the performance of a large and slow LV.  It does this by storing the
 frequently used blocks on the faster LV.
 LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
@@ -27,59 +27,60 @@ cache pool LV       CachePoolLV   CacheDataLV + CacheMetaLV
 cache LV            CacheLV       OriginLV + CachePoolLV
 .fi
 
-.SH Cache Steps
-The steps to create a logical volume of \fIcache\fP type are as follows:
-.TP
-0.
-Create an LV or identify an existing LV to be the origin LV.
-.TP
-1.
-Create the cache data LV.  The size of this LV is the size of the cache
-and will be reported as the size of the cache pool LV.
-.TP
-2.
-Create the cache metadata LV.
-The size of this LV should be 1000 times smaller than the cache data LV
-with a minimum size of 8MiB.
-.TP
-3.
-Create the cache pool LV by combining the cache data LV (from step 1)
-and cache metadata LV (from step 2).  When performing this step,
-behavioral characteristics of the cache pool LV can be set.
-The name of the cache pool LV takes the name of the cache data LV and
-the cache data LV and cache metadata LV are renamed
-to CachePoolLV_cdata and CachePoolLV_cmeta.
-.TP
-4.
-Create a cache LV by linking the cache pool LV to the origin LV.
-The user accessible cache LV takes the name of the origin LV,
-while the origin LV becomes a hidden LV with the name
-OriginLV_corig.  Users can perform this step while the origin LV
-is in use.
+.SH Cache Usage
 
-.P
-The steps above represent the best way to create a cache LV.
-They provide the most options and have the ability to create the
-most robust logical volumes.  The examples below illustrate how these
-steps might be used in practice.
+The primary method for using a cache type logical volume:
 
-.SH Cache Commands
 
-0. create OriginLV
-.br
-.B lvcreate \-L LargeSize \-n OriginLV VG SlowPVs
+.SS 0. create OriginLV
 
-1. create CacheDataLV
+Create an LV or identify an existing LV to be the origin LV.
+
+.B lvcreate \-n OriginLV \-L LargeSize VG SlowPVs
+
+.I Example
 .br
-.B lvcreate \-L CacheSize \-n CacheDataLV VG FastPVs
+# lvcreate \-n lvol0 \-L 100G vg
+
 
-2. create CacheMetaLV
+.SS 1. create CacheDataLV
+
+Create the cache data LV.  This LV will hold data blocks from the
+OriginLV.  The size of this LV is the size of the cache and will be
+reported as the size of the cache pool LV.  
+
+.B lvcreate \-n CacheDataLV \-L CacheSize VG FastPVs
+
+.I Example
 .br
-.B lvcreate \-L MetaSize \-n CacheMetaLV VG FastPVs
+# lvcreate \-n cache0 \-L 10G vg /dev/fast
+
 
-3. create CachePoolLV
+.SS 2. create CacheMetaLV
+
+Create the cache metadata LV.  This LV will hold cache pool metadata.  The
+size of this LV should be 1000 times smaller than the cache data LV, with
+a minimum size of 8MiB.
+
+.B lvcreate \-n CacheMetaLV \-L MetaSize VG FastPVs
+
+.I Example
 .br
-.B lvconvert \-\-cachepool VG/CacheDataLV \-\-poolmetadata VG/CacheMetaLV
+# lvcreate \-n cache0meta \-L 12M vg /dev/fast
+
+.nf
+# lvs -a vg
+  LV         VG   Attr       LSize   Pool Origin
+  cache0     vg   -wi-a-----  10.00g                                                    
+  cache0meta vg   -wi-a-----  12.00m                                                    
+  lvol0      vg   -wi-a----- 100.00g
+.fi
+
+
+.SS 3. create CachePoolLV
+
+Combine the data and metadata LVs into a cache pool LV.
+The behavior of the cache pool LV can be set in this step.
 .br
 CachePoolLV takes the name of CacheDataLV.
 .br
@@ -87,44 +88,108 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-4. create CacheLV
+.B lvconvert \-\-cachepool VG/CacheDataLV \-\-poolmetadata VG/CacheMetaLV
+
+.I Example
 .br
-.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
+# lvconvert \-\-cachepool vg/cache0 \-\-poolmetadata vg/cache0meta
+
+.nf
+# lvs -a vg
+  LV              VG   Attr       LSize   Pool Origin
+  cache0          vg   Cwi---C---  10.00g
+  [cache0_cdata]  vg   Cwi-------  10.00g
+  [cache0_cmeta]  vg   ewi-------  12.00m
+  lvol0           vg   -wi-a----- 100.00g
+.fi
+
+
+.SS 4. create CacheLV
+
+Create a cache LV by linking the cache pool LV to the origin LV.
+The user accessible cache LV takes the name of the origin LV,
+while the origin LV becomes a hidden LV with the name
+OriginLV_corig.  This can be done while the origin LV is in use.
 .br
 CacheLV takes the name of OriginLV.
 .br
 OriginLV is renamed OriginLV_corig and becomes hidden.
 
+.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
 
-.SH Cache Examples
+.I Example
+.br
+# lvconvert \-\-type cache \-\-cachepool vg/cache0 vg/lvol0
+
+.nf
+# lvs -a vg
+  LV              VG   Attr       LSize   Pool   Origin
+  cache0          vg   Cwi---C---  10.00g                                                             
+  [cache0_cdata]  vg   Cwi-ao----  10.00g                                                             
+  [cache0_cmeta]  vg   ewi-ao----  12.00m                                                             
+  lvol0           vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]                                        
+  [lvol0_corig]   vg   -wi-ao---- 100.00g                                                             
+.fi
+
+
+.SH Cache Removal
 
-.SS Example 1
-Create a simple cache LV.
+.SS Removing a cache pool LV without removing its linked origin LV
 
+\&
+
+This writes back data from the cache pool to the origin LV when necessary,
+then removes the cache pool LV, leaving the un-cached origin LV.
+
+.B lvremove VG/CachePoolLV
+
+.I Example
 .nf
-0. Create the origin LV
-# lvcreate \-L 10G \-n lvx vg /dev/slow_dev
+# lvs vg
+  LV     VG   Attr       LSize   Pool   Origin
+  cache0 vg   Cwi---C---  10.00g
+  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
 
-1. Create a cache data LV
-# lvcreate \-L 1G \-n lvx_cache vg /dev/fast_dev
+# lvremove vg/cache0
 
-2. Create a cache metadata LV (~1/1000th size of CacheDataLV or 8MiB)
-# lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast_dev
+# lvs vg
+  LV    VG   Attr       LSize   Pool Origin
+  lvol0 vg   -wi-a----- 100.00g
+.fi
 
-3. Create a cache pool LV, combining cache data LV and cache metadata LV
-# lvconvert \-\-cachepool vg/lvx_cache \-\-poolmetadata vg/lvx_cache_meta
+.SS Removing an origin LV without removing its linked cache pool LV
 
-4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
+\&
+
+This removes the origin LV, leaving the cache pool LV which can be linked
+to another origin LV.
+
+.B lvremove VG/CacheLV
+
+.I Example
+.nf
+# lvs vg
+  LV     VG   Attr       LSize   Pool   Origin
+  cache0 vg   Cwi---C---  10.00g
+  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
+
+# lvremove vg/lvol0
+
+# lvs vg
+  LV     VG   Attr       LSize  Pool Origin
+  cache0 vg   Cwi---C--- 10.00g
 .fi
 
-.SS Example 2
-Create a cache LV with a fault tolerant cache pool LV.
 
-Users who are concerned about the possibility of failures in their fast devices
-that could lead to data loss might consider making their cache pool sub-LVs
-redundant.  Example 2 illustrates how to do that.  Note that only steps
-1 & 2 change.
+.SH Cache Topics
+
+.SS Tolerate device failures in a cache pool LV
+
+\&
+
+Users who are concerned about the possibility of failures in their fast
+devices that could lead to data loss might consider making their cache
+pool sub-LVs redundant.
 
 .nf
 0. Create an origin LV we wish to cache
@@ -145,16 +210,16 @@ redundant.  Example 2 illustrates how to do that.  Note that only steps
 # lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
-.SS Example 3
-Create a simple cache LV with \fIwritethough\fP caching.
+.SS Writethough caching
 
-Some users wish to ensure that any data written will be stored both in the
-cache pool LV and on the origin LV.  The loss of a device associated with
-the cache pool LV in this case would not mean the loss of any data.  When
-combining the cache data LV and the cache metadata LV to form the cache pool
-LV, properties of the cache can be specified - in this case,
-\fIwritethrough\fP vs. \fIwriteback\fP.  Note that only step 3 is affected
-in this case.
+\&
+
+Writethrough caching ensures that any data written will be stored both in
+the cache pool LV and on the origin LV.  The loss of a device associated
+with the cache pool LV in this case would not mean the loss of any data.
+When combining the cache data LV and the cache metadata LV to form the
+cache pool LV, properties of the cache can be specified - in this case,
+\fIwritethrough\fP vs. \fIwriteback\fP.
 
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
@@ -174,35 +239,27 @@ in this case.
 # lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
-.SH Cache Removal
-
-.SS Removing a cache pool LV without removing an associated origin LV
+.SS Spare metadata LV
 
-This writes back data from the cache pool to the origin LV, then removes
-the cache pool LV, leaving the un-cached origin LV.  (If the origin LV
-will also be removed, the data flushing can be avoided; see "Removing
-both" below.)
+\&
 
-.B lvremove VG/CachePoolLV
+See
+.BR lvmthin (7)
+for a description of the "pool metadata spare" LV.
+The same concept is used for cache pools.
 
-.SS Removing both an origin LV and its associated cache pool LV
+.SS Automatic pool metadata LV
 
-This removes the cache LV, which includes removing both the origin LV and
-its associated cache pool LV.  Data blocks from the cache pool are not
-written back to the origin LV.
+\&
 
-.B lvremove VG/CacheLV
+A cache data LV can be converted to cache pool LV without specifying a
+cache pool metadata LV.  LVM will automatically create a metadata LV from
+the same VG.
 
-./" .SS Separating a cache pool LV from an origin LV
-./" This writes back data from the cache pool to the origin LV, then removes
-./" the association between the cache pool LV and the origin LV.
-./" .br
-./" Not yet implemented.
+.B lvcreate -n CacheDataLV -L CacheSize VG
+.br
+.B lvconvert --cachepool VG/CacheDataLV
 
-./" .SS Removing an origin LV without removing an associated cache pool LV
-./" Separate the cache pool LV from the origin LV, then remove the origin LV.
-./" .br
-./" Not yet implemented.
 
 .SH SEE ALSO
 .BR lvm.conf (5),


