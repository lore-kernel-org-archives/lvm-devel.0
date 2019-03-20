From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:07 -0400
Subject: master - man: basic vdo stacking support
Message-ID: <201903201340.x2KDe7oU012565@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=597113646d10e14044e0b89712342ae73b77b697
Commit:        597113646d10e14044e0b89712342ae73b77b697
Parent:        4411fe2ba855b9c42b5d1393fc08faf01b1d2636
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:57:36 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:39:11 2019 +0100

man: basic vdo stacking support

Document some basic lvconvert stacking posibilities.
---
 man/lvconvert.8_pregen |    8 ++++----
 man/lvmvdo.7_main      |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 26bcf5f..842be37 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -570,7 +570,7 @@ Convert LV to a thin LV, using the original LV as an external origin.
 Attach a cache to an LV, converts the LV to type cache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
 .br
 .RS 4
 .ad l
@@ -783,7 +783,7 @@ Convert LV to type vdopool.
 Detach a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool_writecache\fP
+\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool_vdopool_writecache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -1692,7 +1692,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 Attach a cache to an LV (infers --type cache).
 .br
 .P
-\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
 .br
 .RS 4
 .ad l
@@ -1782,7 +1782,7 @@ Convert LV to type vdopool.
 Detach and delete a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache_writecache\fP
+\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache_vdopool_writecache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 2572b46..d42c1bd 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -276,6 +276,48 @@ be activated. User has to deactivate VDODataLV first to continue to use VDOPoolL
 
 
 .SH VDO Topics
+
+.SS 1. Stacking VDO
+
+User can convert/stack VDO with existing volumes.
+
+.SS 2. VDO on top of raid
+
+Using Raid type LV for VDO Data LV.
+
+.I Example
+.br
+.nf
+# lvcreate --type raid1 -L 5G -n vpool vg
+# lvconvert --type vdo-pool -V 10G vg/vpool
+.fi
+
+.SS 3. Caching VDODataLV, VDOPoolLV
+
+Cache VDO Data LV (accepts also VDOPoolLV.
+
+.I Example
+.br
+.nf
+# lvcreate -L 5G -V 10G -n vdo1 vg/vpool
+# lvcreate --type cache-pool -L 1G -n cpool vg
+# lvconvert --cache --cachepool vg/cpool vg/vpool
+# lvconvert --uncache vg/vpool
+.fi
+
+.SS 3. Caching VDOLV
+
+Cache VDO LV.
+
+.I Example
+.br
+.nf
+# lvcreate -L 5G -V 10G -n vdo1 vg/vpool
+# lvcreate --type cache-pool -L 1G -n cpool vg
+# lvconvert --cache --cachepool vg/cpool vg/vdo1
+# lvconvert --uncache vg/vdo1
+.fi
+
 .br
 
 \&


