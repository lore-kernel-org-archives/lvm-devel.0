From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:18 -0500
Subject: master - cache: use conditional in warning message
Message-ID: <201711241511.vAOFBIp9000743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e88d3a89b353ad4d286d453dcc24042b09efaf9
Commit:        5e88d3a89b353ad4d286d453dcc24042b09efaf9
Parent:        5b5c5cc618bbfaa2945d6fe2211443b28588764a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 20 16:33:43 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

cache: use conditional in warning message

In some cases the message could be slightly misleading so use
here rather conditional.

TODO:

In future we may possibly further tune the message in case we are
certain the level of redundancy protection has not been reduced.
---
 lib/metadata/cache_manip.c         |    2 +-
 test/shell/lvconvert-cache-raid.sh |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5e0e5c4..55ed724 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -129,7 +129,7 @@ void cache_check_for_warns(const struct lv_segment *seg)
 
 	if (lv_is_raid(origin_lv) &&
 	    first_seg(seg->pool_lv)->cache_mode == CACHE_MODE_WRITEBACK)
-		log_warn("WARNING: Data redundancy is lost with writeback "
+		log_warn("WARNING: Data redundancy could be lost with writeback "
 			 "caching of raid logical volume!");
 
 	if (lv_is_thin_pool_data(seg->lv))
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 9e4f55c..ec9b1e4 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -39,7 +39,7 @@ lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
 lvcreate --type raid1 -m 1 --nosync -l 2 -n ${lv1}_cachepool $vg
 #should lvs -a $vg/${lv1}_cdata_rimage_0  # ensure images are properly renamed
 lvconvert --yes --type cache --cachemode writeback --cachepool $vg/${lv1}_cachepool $vg/$lv1 2>&1 | tee out
-grep "WARNING: Data redundancy is lost" out
+grep "WARNING: Data redundancy could be lost" out
 check lv_exists $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
 dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
 lvremove -f $vg
@@ -47,7 +47,7 @@ lvremove -f $vg
 
 lvcreate -n corigin -m 1 --type raid1 --nosync -l 10 $vg
 lvcreate -n cpool --type cache $vg/corigin --cachemode writeback -l 10 2>&1 | tee out
-grep "WARNING: Data redundancy is lost" out
+grep "WARNING: Data redundancy could be lost" out
 not lvconvert --splitmirrors 1 --name split $vg/corigin "$dev1"
 lvconvert --yes --splitmirrors 1 --name split $vg/corigin "$dev1"
 


