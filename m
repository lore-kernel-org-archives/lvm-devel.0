From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:36 -0400
Subject: master - tests: used cache_pool adds _cpool
Message-ID: <201910211333.x9LDXavL019660@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0e40bad1d7c2a93d0dfd9ad27542673ee5300a5
Commit:        a0e40bad1d7c2a93d0dfd9ad27542673ee5300a5
Parent:        dd7629ea090d4e55de057b772e9eb9470a49e05b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 15:11:51 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 15:32:35 2019 +0200

tests: used cache_pool adds _cpool

---
 test/shell/cache-single-options.sh     |    2 +-
 test/shell/component-cache.sh          |    4 +-
 test/shell/lvconvert-cache-raid.sh     |   48 ++++++++++++++++----------------
 test/shell/lvconvert-snapshot-cache.sh |   18 ++++++------
 test/shell/lvcreate-cache.sh           |   22 +++++++-------
 test/shell/lvrename-cache-thin.sh      |    6 ++--
 test/shell/pvmove-cache-segtypes.sh    |   12 ++++----
 7 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 6b71b2f..3be88d2 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -262,7 +262,7 @@ lvs -a -o+segtype $vg
 check lv_field $vg/$lv5 segtype cache
 
 # check lv_field doesn't work for hidden lvs
-lvs -a -o segtype $vg/$lv3 > segtype
+lvs -a -o segtype $vg/${lv3}_cpool > segtype
 grep cache-pool segtype
 
 lvconvert --splitcache $vg/$lv5
diff --git a/test/shell/component-cache.sh b/test/shell/component-cache.sh
index 87ca958..7234504 100644
--- a/test/shell/component-cache.sh
+++ b/test/shell/component-cache.sh
@@ -29,7 +29,7 @@ for j in 1 2
 do
 
 # Activate supported components
-for i in cpool_cmeta cpool_cdata corigin_corig
+for i in cpool_cpool_cmeta cpool_cpool_cdata corigin_corig
 do
 	test ! -e "$DM_DEV_DIR/$vg/$i"
 	lvchange -ay -y $vg/$i
@@ -73,7 +73,7 @@ lvcreate -H -L 4 -n tpool --cachepool $vg/cpool
 lvchange -an $vg
 lvs -a $vg
 # Cannot convert to thin-pool with component LV active
-lvchange -ay -y $vg/cpool_cmeta
+lvchange -ay -y $vg/cpool_cpool_cmeta
 
 # Conversion does not need to activate data device, so it can proceed ??
 lvconvert -y --thinpool $vg/tpool
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 465def7..033376d 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -60,25 +60,25 @@ lvs -a -o+seg_pe_ranges $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 
-lvchange --syncaction repair $vg/cpool_cmeta
-aux wait_for_sync $vg cpool_cmeta
+lvchange --syncaction repair $vg/cpool_cpool_cmeta
+aux wait_for_sync $vg cpool_cpool_cmeta
 
-lvchange --syncaction repair $vg/cpool_cdata
-aux wait_for_sync $vg cpool_cdata
+lvchange --syncaction repair $vg/cpool_cpool_cdata
+aux wait_for_sync $vg cpool_cpool_cdata
 
-lvconvert -y --repair $vg/cpool_cmeta
-lvconvert -y --repair $vg/cpool_cdata
+lvconvert -y --repair $vg/cpool_cpool_cmeta
+lvconvert -y --repair $vg/cpool_cpool_cdata
 
 # do not allow reserved names for *new* LVs
-not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
-not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
+not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cpool_cmeta "$dev1"
+not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cpool_cdata "$dev1"
 
 # but allow manipulating existing LVs with reserved names
-aux wait_for_sync $vg cpool_cmeta
-aux wait_for_sync $vg cpool_cdata
-lvconvert --yes --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
-lvconvert --yes --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
-not lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
+aux wait_for_sync $vg cpool_cpool_cmeta
+aux wait_for_sync $vg cpool_cpool_cdata
+lvconvert --yes --splitmirrors 1 --name split_meta $vg/cpool_cpool_cmeta "$dev1"
+lvconvert --yes --splitmirrors 1 --name split_data $vg/cpool_cpool_cdata "$dev1"
+not lvconvert --splitmirrors 1 --name split_data $vg/cpool_cpool_cdata "$dev1"
 
 lvremove -f $vg
 
@@ -91,24 +91,24 @@ lvconvert -y --type cache-pool $vg/cp1
 lvcreate -l 20 -n co1 $vg
 lvconvert -y --type cache --cachepool cp1 $vg/co1
 
-lvconvert -y -m +1 --type raid1 $vg/cp1_cmeta
-check lv_field $vg/cp1_cmeta layout "raid,raid1"
-check lv_field $vg/cp1_cmeta role "private,cache,pool,metadata"
+lvconvert -y -m +1 --type raid1 $vg/cp1_cpool_cmeta
+check lv_field $vg/cp1_cpool_cmeta layout "raid,raid1"
+check lv_field $vg/cp1_cpool_cmeta role "private,cache,pool,metadata"
 
-lvconvert -y -m +1 --type raid1 $vg/cp1_cdata
-check lv_field $vg/cp1_cdata layout "raid,raid1"
-check lv_field $vg/cp1_cdata role "private,cache,pool,data"
+lvconvert -y -m +1 --type raid1 $vg/cp1_cpool_cdata
+check lv_field $vg/cp1_cpool_cdata layout "raid,raid1"
+check lv_field $vg/cp1_cpool_cdata role "private,cache,pool,data"
 
 sleep 5
 
 lvs -a -o+devices $vg
 
-not lvconvert -m -1  $vg/cp1_cmeta
+not lvconvert -m -1  $vg/cp1_cpool_cmeta
 
-lvconvert -y -m -1  $vg/cp1_cmeta
-check lv_field $vg/cp1_cmeta layout "linear"
-lvconvert -y -m -1  $vg/cp1_cdata
-check lv_field $vg/cp1_cdata layout "linear"
+lvconvert -y -m -1  $vg/cp1_cpool_cmeta
+check lv_field $vg/cp1_cpool_cmeta layout "linear"
+lvconvert -y -m -1  $vg/cp1_cpool_cdata
+check lv_field $vg/cp1_cpool_cdata layout "linear"
 
 lvremove -f $vg
 
diff --git a/test/shell/lvconvert-snapshot-cache.sh b/test/shell/lvconvert-snapshot-cache.sh
index d32f4c2..9cb383a 100644
--- a/test/shell/lvconvert-snapshot-cache.sh
+++ b/test/shell/lvconvert-snapshot-cache.sh
@@ -32,38 +32,38 @@ lvcreate -aey -L1 -n ch $vg
 lvcreate -H -L1 -n cpool $vg/ch
 
 # Cannot create snapshot of cpool
-not lvcreate -s -L1 $vg/cpool 2>&1 | tee err
+not lvcreate -s -L1 $vg/cpool_cpool 2>&1 | tee err
 grep "not supported" err
 
 # Cannot create snapshot of cpool's meta
-not lvcreate -s -L1 $vg/cpool_cmeta 2>&1 | tee err
+not lvcreate -s -L1 $vg/cpool_cpool_cmeta 2>&1 | tee err
 grep "not supported" err
 
 # Cannot create snapshot of cpool's data
-not lvcreate -s -L1 $vg/cpool_cdata 2>&1 | tee err
+not lvcreate -s -L1 $vg/cpool_cpool_cdata 2>&1 | tee err
 grep "not supported" err
 
 # Cannot use cache-type as COW
 not lvconvert --yes --type snapshot $vg/cow $vg/ch 2>&1 | tee err
 grep "not accept" err
 
-not lvconvert --yes --type snapshot $vg/cow $vg/cpool 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cpool 2>&1 | tee err
 grep "not accept" err
 
-not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cdata 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cpool_cdata 2>&1 | tee err
 grep "lv_is_visible" err
 
-not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cmeta 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cow $vg/cpool_cpool_cmeta 2>&1 | tee err
 grep "lv_is_visible" err
 
 # Cannot use thin-pool, _tdata, _tmeta as origin
-not lvconvert --yes --type snapshot $vg/cpool $vg/cow 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cpool_cpool $vg/cow 2>&1 | tee err
 grep "not supported" err
 
-not lvconvert --yes --type snapshot $vg/cpool_cdata $vg/cow 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cpool_cpool_cdata $vg/cow 2>&1 | tee err
 grep "not supported" err
 
-not lvconvert --yes --type snapshot $vg/cpool_cmeta $vg/cow 2>&1 | tee err
+not lvconvert --yes --type snapshot $vg/cpool_cpool_cmeta $vg/cow 2>&1 | tee err
 grep "not supported" err
 
 lvconvert --yes -s $vg/ch $vg/cow
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 0663033..2c46e21 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -98,11 +98,11 @@ check lv_field $vg/$lv1 copy_percent "0.00"
 # there should be something present (value differs per policy version)
 test -n "$(get lv_field $vg/$lv1 data_percent)"
 test -n "$(get lv_field $vg/$lv1 metadata_percent)"
-check lv_field $vg/cpool copy_percent "0.00"
-test -n "$(get lv_field $vg/cpool data_percent)"
-test -n "$(get lv_field $vg/cpool metadata_percent)"
+check lv_field $vg/cpool_cpool copy_percent "0.00"
+test -n "$(get lv_field $vg/cpool_cpool data_percent)"
+test -n "$(get lv_field $vg/cpool_cpool metadata_percent)"
 # check we also display percent value for segmented output (-o+devices)
-lvs -a -o+devices $vg/cpool | tee out
+lvs -a -o+devices $vg/cpool_cpool | tee out
 grep "0.00" out
 lvremove -f $vg
 
@@ -155,8 +155,8 @@ check lv_not_exists $vg $lv1 pool1 pool1_cdata pool1_cmeta
 
 # Removal of cache pool leaves origin uncached
 check lv_field $vg/$lv2 segtype "cache"
-lvremove -f $vg/pool2
-check lv_not_exists $vg pool2 pool2_cdata pool2_cmeta
+lvremove -f $vg/pool2_cpool
+check lv_not_exists $vg pool2_cpool pool2_cpool_cdata pool2_cpool_cmeta
 check lv_field $vg/$lv2 segtype "linear"
 
 lvremove -f $vg
@@ -193,7 +193,7 @@ lvcreate -an -l1 -n $vg/$lv1
 # do not allow stripping for cache-pool
 fail lvcreate -H -i 2 -l1 -n cpool1 $vg/$lv1
 lvcreate -H -l1 -n cpool1 $vg/$lv1
-check lv_attr_bit perm $vg/cpool1 "w"
+check lv_attr_bit perm $vg/cpool1_cpool "w"
 check lv_attr_bit perm $vg/${lv1}_corig "w"
 check lv_attr_bit perm $vg/$lv1 "w"
 
@@ -204,16 +204,16 @@ fail lvcreate -H -l1 -pr -n cpool2 $vg/$lv2
 # read-only origin and -pr => read-only cache + origin
 lvcreate -an -pr -l1 -n $vg/$lv3
 lvcreate -an -H -l1 -pr -n cpool3 $vg/$lv3
-check lv_attr_bit perm $vg/cpool3 "w"
+check lv_attr_bit perm $vg/cpool3_cpool "w"
 check lv_attr_bit perm $vg/${lv3}_corig "r"
 check lv_attr_bit perm $vg/$lv3 "r"
 check inactive $vg $lv3
-check inactive $vg cpool3
+check inactive $vg cpool3_cpool
 
 # read-only origin and 'default' => read-only cache + origin
 lvcreate -an -pr -l1 -n $vg/$lv4
 lvcreate -H -l1 -n cpool4 $vg/$lv4
-check lv_attr_bit perm $vg/cpool4 "w"
+check lv_attr_bit perm $vg/cpool4_cpool "w"
 check lv_attr_bit perm $vg/${lv4}_corig "r"
 check lv_attr_bit perm $vg/$lv4 "r"
 
@@ -224,7 +224,7 @@ fail lvcreate -H -l1 -prw -n cpool5 $vg/$lv5
 # cached volume respects permissions
 lvcreate --type cache-pool -l1 -n $vg/cpool
 lvcreate -H -l1 -pr -n $lv6 $vg/cpool
-check lv_attr_bit perm $vg/cpool "w"
+check lv_attr_bit perm $vg/cpool_cpool "w"
 check lv_attr_bit perm $vg/$lv6 "r"
 
 lvremove -f $vg
diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
index 0697d1c..a77a2c1 100644
--- a/test/shell/lvrename-cache-thin.sh
+++ b/test/shell/lvrename-cache-thin.sh
@@ -38,14 +38,14 @@ lvcreate -V10 $vg/tpool
 # check cache pool remains same after thin-pool rename
 lvrename $vg/tpool  $vg/newpool
 
-check lv_exists $vg newpool cpool
+check lv_exists $vg newpool cpool_cpool
 check lv_not_exists $vg tpool
 
 # allowing rename of internal cache pool
-lvrename $vg/cpool  $vg/cachepool
+lvrename $vg/cpool_cpool  $vg/cachepool
 
 check lv_exists $vg cachepool
-check lv_not_exists $vg cpool
+check lv_not_exists $vg cpool_cpool
 
 lvs -a $vg
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index b5b341d..0cd3a16 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -60,7 +60,7 @@ lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev5"
 lvcreate --type cache -n $lv1 -l 8 $vg/${lv1}_pool "$dev1"
 
 check lv_tree_on $vg ${lv1}_foo "$dev1"
-check lv_tree_on $vg ${lv1}_pool "$dev5"
+check lv_tree_on $vg ${lv1}_pool_cpool "$dev5"
 check lv_tree_on $vg ${lv1} "$dev1"
 
 aux mkdev_md5sum $vg $lv1
@@ -86,7 +86,7 @@ lvcreate --type raid1 -m 1 -l 8 -n $lv1 $vg "$dev1" "$dev2"
 lvcreate --type cache -l 4 -n ${lv1}_pool $vg/$lv1 "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg ${lv1} "$dev1" "$dev2"
-check lv_tree_on $vg ${lv1}_pool "$dev5"
+check lv_tree_on $vg ${lv1}_pool_cpool "$dev5"
 
 aux mkdev_md5sum $vg $lv1
 pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
@@ -113,7 +113,7 @@ lvconvert --yes --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
 lvcreate --type cache -n $lv1 -L 8M $vg/${lv1}_pool "$dev5"
 
 check lv_tree_on $vg ${lv1}_foo "$dev1"
-check lv_tree_on $vg ${lv1}_pool "$dev1" "$dev2"
+check lv_tree_on $vg ${lv1}_pool_cpool "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1} "$dev5"
 
 aux mkdev_md5sum $vg $lv1
@@ -121,7 +121,7 @@ aux mkdev_md5sum $vg $lv1
 #  LVs, both of which contain a RAID1 _rimage & _rmeta LV - 5 total LVs
 pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
-not check lv_tree_on $vg ${lv1}_pool "$dev1"
+not check lv_tree_on $vg ${lv1}_pool_cpool "$dev1"
 #check lv_tree_on $vg ${lv1} "$dev5"
 #check dev_md5sum $vg $lv1
 
@@ -152,7 +152,7 @@ lvconvert --yes --thinpool $vg/thinpool --poolmetadata $vg/meta
 lvcreate -T $vg/thinpool -V 20 -n thin_lv
 
 check lv_tree_on $vg ${lv1}_foo "$dev1"
-check lv_tree_on $vg cachepool "$dev1" "$dev2"
+check lv_tree_on $vg cachepool_cpool "$dev1" "$dev2"
 check lv_tree_on $vg thinpool "$dev1" "$dev3" "$dev4"
 
 aux mkdev_md5sum $vg thin_lv
@@ -161,7 +161,7 @@ lvs -a -o name,attr,devices $vg
 pvmove $mode "$dev1" "$dev5" 2>&1 | tee out
 lvs -a -o name,attr,devices $vg
 check lv_tree_on $vg ${lv1}_foo "$dev5"
-not check lv_tree_on $vg cachepool "$dev1"
+not check lv_tree_on $vg cachepool_cpool "$dev1"
 check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
 #check dev_md5sum $vg/thin_lv
 


