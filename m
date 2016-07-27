From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Jul 2016 14:21:38 +0000 (UTC)
Subject: master - tests: adapt for new cache-pool zeroing
Message-ID: <20160727142138.505B960268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c3a09f1d7423c077ae513baecd2260928500ade
Commit:        0c3a09f1d7423c077ae513baecd2260928500ade
Parent:        eaf7d06a82aef60cd4f0dec2f858998f215c4417
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 23 21:18:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 27 16:20:57 2016 +0200

tests: adapt for new cache-pool zeroing

---
 test/shell/lvconvert-cache-raid.sh   |    2 +-
 test/shell/lvconvert-cache.sh        |    4 ++--
 test/shell/lvconvert-repair-cache.sh |    2 +-
 test/shell/pvmove-cache-segtypes.sh  |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 551c00f..ebb9f79 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -27,7 +27,7 @@ aux prepare_vg 5 80
 # lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
 lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
 lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvconvert --cache -Zy --cachepool $vg/${lv1}_cachepool $vg/$lv1
 check lv_exists $vg/${lv1}_corig_rimage_0 # ensure images are properly renamed
 dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
 lvremove -f $vg
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 3bffb32..76116ea 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -73,7 +73,7 @@ lvremove -ff $vg
 
 lvcreate -L 2 -n $lv1 $vg
 lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --cache --cachepool $vg/${lv1}_cachepool --cachemode writeback $vg/$lv1
+lvconvert --cache --cachepool $vg/${lv1}_cachepool --cachemode writeback -Zy $vg/$lv1
 check lv_field $vg/$lv1 cache_mode "writeback"
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 
@@ -81,7 +81,7 @@ dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 #lvconvert --cachepool $vg/${lv1}_cachepool --poolmetadatasize 20 "$dev3"
 
 
-fail lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+fail lvconvert --type cache --cachepool $vg/${lv1}_cachepool -Zy $vg/$lv1
 
 # Test --splitcache leaves both cache origin and cache pool
 lvconvert --splitcache $vg/$lv1
diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 568d66b..f907289 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -57,7 +57,7 @@ aux enable_dev "$dev1"
 ##################
 
 lvcreate --type cache-pool -L10 $vg/cpool "$dev1"
-lvconvert -H --cachemode writethrough --cachepool $vg/cpool $lv1
+lvconvert -H --cachemode writethrough --cachepool $vg/cpool -Zy $lv1
 
 aux disable_dev "$dev2"
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 679997f..bd624bc 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -153,7 +153,7 @@ lvconvert --yes --type cache-pool $vg/cachepool --poolmetadata $vg/meta
 # RAID for thin pool data LV
 lvcreate --type raid1 -m 1 -L 8 -n thinpool $vg "$dev3" "$dev4"
 # Convert thin pool data to a cached LV
-lvconvert --type cache $vg/thinpool --cachepool $vg/cachepool
+lvconvert --type cache -Zy $vg/thinpool --cachepool $vg/cachepool
 # Create simple thin pool meta
 lvcreate -L 2M -n meta $vg "$dev1"
 # Use thin pool data LV to build a thin pool


