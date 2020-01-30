From: David Teigland <teigland@sourceware.org>
Date: Thu, 30 Jan 2020 15:10:03 -0500
Subject: master - man: updates to lvmcache
Message-ID: <05702.120013015095801141@us-mta-302.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2444e830a90fe84721bd61f950946eedcbce0af7
Commit:        2444e830a90fe84721bd61f950946eedcbce0af7
Parent:        8810c11bc924e8871f97aa25c61e73b3b3f1fa87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 30 14:09:21 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 30 14:09:21 2020 -0600

man: updates to lvmcache

---
 man/lvmcache.7_main | 99 +++++++++++++++++++++++++++++------------------------
 1 file changed, 54 insertions(+), 45 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 985b79a..fb91be8 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -5,24 +5,32 @@ lvmcache \(em LVM caching
 .SH DESCRIPTION
 
 \fBlvm\fP(8) includes two kinds of caching that can be used to improve the
-performance of a Logical Volume (LV). Typically, a smaller, faster device
-is used to improve i/o performance of a larger, slower LV. To do this, a
-separate LV is created from the faster device, and then the original LV is
-converted to start using the fast LV.
+performance of a Logical Volume (LV). When caching, varying subsets of an
+LV's data are temporarily stored on a smaller, faster device (e.g. an SSD)
+to improve the performance of the LV.
+
+To do this with lvm, a new special LV is first created from the faster
+device. This LV will hold the cache. Then, the new fast LV is attached to
+the main LV by way of an lvconvert command. lvconvert inserts one of the
+device mapper caching targets into the main LV's i/o path. The device
+mapper target combines the main LV and fast LV into a hybrid device that looks
+like the main LV, but has better performance. While the main LV is being
+used, portions of its data will be temporarily and transparently stored on
+the special fast LV.
 
 The two kinds of caching are:
 
 .IP \[bu] 2
-A read and write hot-spot cache, using the dm-cache kernel module.  This
-cache is slow moving, and adjusts the cache content over time so that the
-most used parts of the LV are kept on the faster device.  Both reads and
-writes use the cache. LVM refers to this using the LV type \fBcache\fP.
+A read and write hot-spot cache, using the dm-cache kernel module.
+This cache tracks access patterns and adjusts its content deliberately so
+that commonly used parts of the main LV are likely to be found on the fast
+storage. LVM refers to this using the LV type \fBcache\fP.
 
 .IP \[bu] 2
-A streaming write cache, using the dm-writecache kernel module.  This
-cache is intended to be used with SSD or PMEM devices to speed up all
-writes to an LV.  Reads do not use this cache.  LVM refers to this using
-the LV type \fBwritecache\fP.
+A write cache, using the dm-writecache kernel module.  This cache can be
+used with SSD or PMEM devices to speed up all writes to the main LV. Data
+read from the main LV is not stored in the cache, only newly written data.
+LVM refers to this using the LV type \fBwritecache\fP.
 
 .SH USAGE
 
@@ -30,30 +38,31 @@ Both kinds of caching use similar lvm commands:
 
 .B 1. Identify main LV that needs caching
 
-A main LV exists on slower devices.
+The main LV may already exist, and is located on larger, slower devices.
+A main LV would be created with a command like:
 
 .nf
-  $ lvcreate -n main -L Size vg /dev/slow
+  $ lvcreate -n main -L Size vg /dev/slow_hhd
 .fi
 
 .B 2. Identify fast LV to use as the cache
 
-A fast LV exists on faster devices.  This LV will be used to hold the
-cache.
+A fast LV is created using one or more fast devices, like an SSD.  This
+special LV will be used to hold the cache:
 
 .nf
-  $ lvcreate -n fast -L Size vg /dev/fast
+  $ lvcreate -n fast -L Size vg /dev/fast_ssd
 
   $ lvs -a
   LV   Attr       Type   Devices
-  fast -wi------- linear /dev/fast
-  main -wi------- linear /dev/slow
+  fast -wi------- linear /dev/fast_ssd
+  main -wi------- linear /dev/slow_hhd
 .fi
 
 .B 3. Start caching the main LV
 
-To start caching the main LV using the fast LV, convert the main LV to the
-desired caching type, and specify the fast LV to use:
+To start caching the main LV, convert the main LV to the desired caching
+type, and specify the fast LV to use as the cache:
 
 .nf
 using dm-cache:
@@ -83,16 +92,16 @@ using dm-cache:
   $ lvs -a
   LV           Pool        Type   Devices       
   main         [fast_cvol] cache  main_corig(0) 
-  [fast_cvol]              linear /dev/fast
-  [main_corig]             linear /dev/slow
+  [fast_cvol]              linear /dev/fast_ssd
+  [main_corig]             linear /dev/slow_hhd
 
 using dm-writecache:
 
   $ lvs -a
   LV            Pool        Type       Devices       
   main          [fast_cvol] writecache main_wcorig(0)
-  [fast_cvol]               linear     /dev/fast
-  [main_wcorig]             linear     /dev/slow
+  [fast_cvol]               linear     /dev/fast_ssd
+  [main_wcorig]             linear     /dev/slow_hhd
 
 using dm-cache (with cachepool):
 
@@ -100,9 +109,9 @@ using dm-cache (with cachepool):
   LV                 Pool         Type       Devices        
   main               [fast_cpool] cache      main_corig(0)  
   [fast_cpool]                    cache-pool fast_pool_cdata(0)  
-  [fast_cpool_cdata]              linear     /dev/fast
-  [fast_cpool_cmeta]              linear     /dev/fast
-  [main_corig]                    linear     /dev/slow
+  [fast_cpool_cdata]              linear     /dev/fast_ssd
+  [fast_cpool_cmeta]              linear     /dev/fast_ssd
+  [main_corig]                    linear     /dev/slow_hhd
 .fi
 
 .B 5. Use the main LV
@@ -120,8 +129,8 @@ attached.
 
   $ lvs -a
   LV   VG Attr       Type   Devices    
-  fast vg -wi------- linear /dev/fast
-  main vg -wi------- linear /dev/slow
+  fast vg -wi------- linear /dev/fast_ssd
+  main vg -wi------- linear /dev/slow_hhd
 .fi
 
 
@@ -137,21 +146,21 @@ attached.
 .I LV
 .br
 
-Pass this option a standard LV.  With a cachevol, cache data and metadata
-are contained within the single LV.  This is used with dm-writecache or
-dm-cache.
+Pass this option a fast LV that should be used to hold the cache.  With a
+cachevol, cache data and metadata are stored in different parts of the
+same fast LV.  This option can be used with dm-writecache or dm-cache.
 
 .B --cachepool
 .IR CachePoolLV | LV
 .br
 
-Pass this option a cache pool object.  With a cache pool, lvm places cache
-data and cache metadata on different LVs.  The two LVs together are called
-a cache pool.  This permits specific placement of data and metadata.  A
-cache pool is represented as a special type of LV that cannot be used
-directly.  (If a standard LV is passed to this option, lvm will first
-convert it to a cache pool by combining it with another LV to use for
-metadata.)  This can be used with dm-cache.
+Pass this option a cachepool LV or a standard LV.  When using a cache
+pool, lvm places cache data and cache metadata on different LVs.  The two
+LVs together are called a cache pool.  This permits specific placement of
+data and metadata.  A cache pool is represented as a special type of LV
+that cannot be used directly.  If a standard LV is passed with this
+option, lvm will first convert it to a cache pool by combining it with
+another LV to use for metadata.  This option can be used with dm-cache.
 
 \&
 
@@ -267,8 +276,8 @@ LV that references two sub LVs, one for data and one for metadata.
 To create a cache pool from two separate LVs:
 
 .nf
-$ lvcreate -n fast -L DataSize vg /dev/fast1
-$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast2
+$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
 $ lvconvert --type cache-pool --poolmetadata fastmeta vg/fast
 .fi
 
@@ -286,8 +295,8 @@ cache pool LV from the two specified LVs, and use the cache pool to start
 caching the main LV.
 
 .nf
-$ lvcreate -n fast -L DataSize vg /dev/fast1
-$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast2
+$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
 $ lvconvert --type cache --cachepool fast --poolmetadata fastmeta vg/main
 .fi
 
@@ -418,7 +427,7 @@ and metadata LVs, each of the sub-LVs can use raid1.)
 
 .nf
 $ lvcreate -n main -L Size vg /dev/slow
-$ lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/fast1 /dev/fast2
+$ lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/ssd1 /dev/ssd2
 $ lvconvert --type cache --cachevol fast vg/main
 .fi
 



