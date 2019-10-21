From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 Oct 2019 12:35:58 -0400
Subject: master - man: lvmcache naming updates
Message-ID: <201910211635.x9LGZwVr029246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=018cf39316923f26e42c25fc6e885b0ca46c88ba
Commit:        018cf39316923f26e42c25fc6e885b0ca46c88ba
Parent:        0c01a4c2a6bee3faaffe301ea74d76fa75eb8f91
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 21 11:35:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 21 11:35:28 2019 -0500

man: lvmcache naming updates

---
 man/lvmcache.7_main |   73 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 0eefc89..985b79a 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -44,10 +44,10 @@ cache.
 .nf
   $ lvcreate -n fast -L Size vg /dev/fast
 
-  $ lvs vg -o+devices
-  LV   VG  Attr       LSize   Devices
-  fast vg -wi-------  xx.00m /dev/fast(0)
-  main vg -wi------- yyy.00m /dev/slow(0)
+  $ lvs -a
+  LV   Attr       Type   Devices
+  fast -wi------- linear /dev/fast
+  main -wi------- linear /dev/slow
 .fi
 
 .B 3. Start caching the main LV
@@ -64,35 +64,45 @@ using dm-writecache:
 
   $ lvconvert --type writecache --cachevol fast vg/main
 
-using dm-cache with a cache pool:
+using dm-cache (with cachepool):
 
-  $ lvconvert --type cache --cachepool fastpool vg/main
+  $ lvconvert --type cache --cachepool fast vg/main
 .fi
 
 .B 4. Display LVs
 
 Once the fast LV has been attached to the main LV, lvm reports the main LV
 type as either \fBcache\fP or \fBwritecache\fP depending on the type used.
-While attached, the fast LV is hidden, and only displayed when lvs is
-given -a.  The _corig or _wcorig LV represents the original LV without the
-cache.
+While attached, the fast LV is hidden, and renamed with a _cvol or _cpool
+suffix.  It is displayed by lvs -a.  The _corig or _wcorig LV represents
+the original LV without the cache.
 
 .nf
 using dm-cache:
 
-  $ lvs -a -o name,vgname,lvattr,origin,segtype,devices vg
-  LV           VG Attr       Origin       Type   Devices       
-  [fast]       vg Cwi-aoC---                     linear /dev/fast(xx)
-  main         vg Cwi-a-C--- [main_corig] cache  main_corig(0) 
-  [main_corig] vg owi-aoC---                     linear /dev/slow(0) 
+  $ lvs -a
+  LV           Pool        Type   Devices       
+  main         [fast_cvol] cache  main_corig(0) 
+  [fast_cvol]              linear /dev/fast
+  [main_corig]             linear /dev/slow
 
 using dm-writecache:
 
-  $ lvs -a -o name,vgname,lvattr,origin,segtype,devices vg
-  LV            VG Attr       Origin        Type       Devices       
-  [fast]        vg -wi-ao----               linear     /dev/fast(xx)
-  main          vg Cwi-a----- [main_wcorig] writecache main_wcorig(0)
-  [main_wcorig] vg -wi-ao----               linear     /dev/slow(0)   
+  $ lvs -a
+  LV            Pool        Type       Devices       
+  main          [fast_cvol] writecache main_wcorig(0)
+  [fast_cvol]               linear     /dev/fast
+  [main_wcorig]             linear     /dev/slow
+
+using dm-cache (with cachepool):
+
+  $ lvs -a
+  LV                 Pool         Type       Devices        
+  main               [fast_cpool] cache      main_corig(0)  
+  [fast_cpool]                    cache-pool fast_pool_cdata(0)  
+  [fast_cpool_cdata]              linear     /dev/fast
+  [fast_cpool_cmeta]              linear     /dev/fast
+  [main_corig]                    linear     /dev/slow
 .fi
 
 .B 5. Use the main LV
@@ -106,7 +116,12 @@ changes the type of the main LV back to what it was before the cache was
 attached.
 
 .nf
-   $ lvconvert --splitcache vg/main
+  $ lvconvert --splitcache vg/main
+
+  $ lvs -a
+  LV   VG Attr       Type   Devices    
+  fast vg -wi------- linear /dev/fast
+  main vg -wi------- linear /dev/slow
 .fi
 
 
@@ -122,7 +137,7 @@ attached.
 .I LV
 .br
 
-Pass this option a standard LV.  With a cache vol, cache data and metadata
+Pass this option a standard LV.  With a cachevol, cache data and metadata
 are contained within the single LV.  This is used with dm-writecache or
 dm-cache.
 
@@ -252,15 +267,15 @@ LV that references two sub LVs, one for data and one for metadata.
 To create a cache pool from two separate LVs:
 
 .nf
-$ lvcreate -n fastpool -L DataSize vg /dev/fast1
-$ lvcreate -n fastpoolmeta -L MetadataSize vg /dev/fast2
-$ lvconvert --type cache-pool --poolmetadata fastpoolmeta vg/fastpool
+$ lvcreate -n fast -L DataSize vg /dev/fast1
+$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast2
+$ lvconvert --type cache-pool --poolmetadata fastmeta vg/fast
 .fi
 
 Then use the cache pool LV to start caching the main LV:
 
 .nf
-$ lvconvert --type cache --cachepool fastpool vg/main
+$ lvconvert --type cache --cachepool fast vg/main
 .fi
 
 A variation of the same procedure automatically creates a cache pool when
@@ -271,10 +286,9 @@ cache pool LV from the two specified LVs, and use the cache pool to start
 caching the main LV.
 
 .nf
-$ lvcreate -n fastpool -L DataSize vg /dev/fast1
-$ lvcreate -n fastpoolmeta -L MetadataSize vg /dev/fast2
-$ lvconvert --type cache --cachepool fastpool \\
-	--poolmetadata fastpoolmeta vg/main
+$ lvcreate -n fast -L DataSize vg /dev/fast1
+$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast2
+$ lvconvert --type cache --cachepool fast --poolmetadata fastmeta vg/main
 .fi
 
 .SS dm-cache cache modes
@@ -433,7 +447,6 @@ normal lvcreate commands in which --type specifies the type of the newly
 created LV.  In this case, an LV with type cache-pool is being created,
 and the existing main LV is being converted to type cache.)
 
-\&
 
 .SH SEE ALSO
 .BR lvm.conf (5),


