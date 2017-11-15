From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 15:00:53 -0500
Subject: master - tests: pvmove supports more cases
Message-ID: <201711152000.vAFK0re3029314@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0618f90116bb723e568e3aeec6cdcfde342d6b2
Commit:        b0618f90116bb723e568e3aeec6cdcfde342d6b2
Parent:        0f0dc1a2a5f779fbdae7bddd12c3e56397636833
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 11 00:15:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 21:00:29 2017 +0100

tests: pvmove supports more cases

pvmove handles cached LVs as well as snapshots now.
---
 test/shell/pvmove-cache-segtypes.sh |   37 ++++++++++++----------------------
 test/shell/pvmove-raid-segtypes.sh  |    1 -
 test/shell/pvmove-thin-segtypes.sh  |    1 -
 3 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index f95ba72..b5b341d 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -12,7 +12,6 @@
 
 test_description="ensure pvmove works with the cache segment types"
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
@@ -41,28 +40,22 @@ do
 
 # Testing pvmove of cache-pool LV (can't check contents though)
 ###############################################################
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg ${lv1}_pool "$dev1"
 
 pvmove $mode "$dev1" "$dev5" 2>&1 | tee out
-grep "Skipping cache-pool LV, ${lv1}_pool" out
-grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
-grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
+lvs -a -o+devices $vg
+check lv_tree_on $vg ${lv1}_pool "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
-not check lv_tree_on $vg ${lv1}_pool "$dev5"
-
-#pvmove $mode -n ${lv1}_pool "$dev5" "$dev4"
-#check lv_tree_on $vg ${lv1}_pool "$dev4"
-#check lv_tree_on $vg ${lv1}_foo "$dev5"
 
 lvremove -ff $vg
 dmsetup info -c | not grep $vg
 
 # Testing pvmove of origin LV
 #############################
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev5"
 lvcreate --type cache -n $lv1 -l 8 $vg/${lv1}_pool "$dev1"
 
@@ -72,11 +65,10 @@ check lv_tree_on $vg ${lv1} "$dev1"
 
 aux mkdev_md5sum $vg $lv1
 pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
-grep "Skipping cache LV, ${lv1}" out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
 lvs -a -o name,attr,devices $vg
-not check lv_tree_on $vg ${lv1} "$dev3"
+check lv_tree_on $vg ${lv1} "$dev3"
 #check dev_md5sum $vg $lv1
 
 #pvmove $mode -n $lv1 "$dev3" "$dev1"
@@ -89,7 +81,7 @@ dmsetup info -c | not grep $vg
 
 # Testing pvmove of a RAID origin LV
 ####################################
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type raid1 -m 1 -l 8 -n $lv1 $vg "$dev1" "$dev2"
 lvcreate --type cache -l 4 -n ${lv1}_pool $vg/$lv1 "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
@@ -98,9 +90,9 @@ check lv_tree_on $vg ${lv1}_pool "$dev5"
 
 aux mkdev_md5sum $vg $lv1
 pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
-grep "Skipping cache LV, ${lv1}" out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
-not check lv_tree_on $vg ${lv1} "$dev2" "$dev3"
+lvs -a -o+devices $vg
+not check lv_tree_on $vg ${lv1} "$dev1"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
 #check dev_md5sum $vg $lv1 -- THIS IS WHERE THINGS FAIL IF PVMOVE NOT DISALLOWED
 
@@ -114,7 +106,7 @@ dmsetup info -c | not grep $vg
 
 # Testing pvmove of a RAID cachepool (metadata and data)
 ########################################################
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type raid1 -L 6M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -L 4M -n ${lv1}_pool $vg "$dev1" "$dev2"
 lvconvert --yes --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
@@ -128,11 +120,8 @@ aux mkdev_md5sum $vg $lv1
 # This will move ${lv1}_foo and the cache-pool data & meta
 #  LVs, both of which contain a RAID1 _rimage & _rmeta LV - 5 total LVs
 pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
-grep "Skipping cache-pool LV, ${lv1}_pool" out
-grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
-grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
-not check lv_tree_on $vg ${lv1}_pool "$dev2" "$dev3"
+not check lv_tree_on $vg ${lv1}_pool "$dev1"
 #check lv_tree_on $vg ${lv1} "$dev5"
 #check dev_md5sum $vg $lv1
 
@@ -146,7 +135,7 @@ dmsetup info -c | not grep $vg
 
 # Testing pvmove of Thin-pool on cache LV on RAID
 #################################################
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 # RAID for cachepool
 lvcreate --type raid1 -m 1 -L 6M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -m 1 -L 4M -n cachepool $vg "$dev1" "$dev2"
@@ -156,7 +145,7 @@ lvcreate --type raid1 -m 1 -L 8 -n thinpool $vg "$dev3" "$dev4"
 # Convert thin pool data to a cached LV
 lvconvert --type cache -Zy $vg/thinpool --cachepool $vg/cachepool
 # Create simple thin pool meta
-lvcreate -L 2M -n meta $vg "$dev1"
+lvcreate -aey -L 2M -n meta $vg "$dev1"
 # Use thin pool data LV to build a thin pool
 lvconvert --yes --thinpool $vg/thinpool --poolmetadata $vg/meta
 # Create a thin lv for fun
@@ -172,7 +161,7 @@ lvs -a -o name,attr,devices $vg
 pvmove $mode "$dev1" "$dev5" 2>&1 | tee out
 lvs -a -o name,attr,devices $vg
 check lv_tree_on $vg ${lv1}_foo "$dev5"
-not check lv_tree_on $vg cachepool "$dev5" "$dev2"
+not check lv_tree_on $vg cachepool "$dev1"
 check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
 #check dev_md5sum $vg/thin_lv
 
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 667c7d9..be41547 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -12,7 +12,6 @@
 
 test_description="ensure pvmove works with raid segment types"
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 28f5233..01d98b4 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -12,7 +12,6 @@
 
 test_description="ensure pvmove works with thin segment types"
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
 
 . lib/inittest
 


