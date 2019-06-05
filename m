From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 5 Jun 2019 05:24:55 -0400
Subject: stable-2.02 - tests: update cache test
Message-ID: <201906050924.x559Ot9e008515@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f633d68c542e62fe68b6df8ec03b9851fd6e74d9
Commit:        f633d68c542e62fe68b6df8ec03b9851fd6e74d9
Parent:        c733e9644537c7901caf245c1b3fdcdeba76cc12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 12:11:04 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 5 11:23:25 2019 +0200

tests: update cache test

Since migration_threshold is now protected to not be smaller
then 8*chunk_size - update tests to count with this modification.

(cherry picked from commit 2cac4bfc150ea1e5459580e3bac4907446ea7f3a)
---
 test/shell/lvchange-cache.sh |   22 +++++++++++-----------
 test/shell/lvcreate-cache.sh |   15 +++++++++------
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 7e95f61..ab7c8b0 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -38,27 +38,27 @@ check lv_field  $vg/corigin kernel_cache_policy "cleaner"
 # device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
 if aux have_cache 1 5 0 ; then
 
-lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
+lvchange --cachepolicy mq --cachesettings migration_threshold=1333 $vg/corigin
 
 # TODO once mq->smq happens we will get here some 0 for mq settings
 check lv_field $vg/corigin kernel_cache_policy "mq"
-get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=1333'
 
 lvchange --refresh $vg/corigin
-get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=1333'
 lvchange -an $vg
 lvchange -ay $vg
-get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=1333'
 
-lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
+lvchange --cachesettings 'migration_threshold = 1233 sequential_threshold = 13' $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
-grep 'migration_threshold=233' out
+grep 'migration_threshold=1233' out
 
 if grep 'sequential_threshold=13' out ; then
 
-lvchange --cachesettings 'migration_threshold = 17' $vg/corigin
+lvchange --cachesettings 'migration_threshold = 1117' $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
-grep 'migration_threshold=17' out
+grep 'migration_threshold=1117' out
 grep 'sequential_threshold=13' out
 
 lvchange --cachesettings 'migration_threshold = default' $vg/corigin
@@ -66,16 +66,16 @@ get lv_field $vg/corigin kernel_cache_settings | tee out
 grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 
-lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13 random_threshold = 1' $vg/corigin
+lvchange --cachesettings 'migration_threshold = 1233 sequential_threshold = 13 random_threshold = 1' $vg/corigin
 lvchange --cachesettings 'random_threshold = default migration_threshold = default' $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
 grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
-lvchange --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
+lvchange --cachesettings migration_threshold=1233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
-grep 'migration_threshold=233' out
+grep 'migration_threshold=1233' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=1' out
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 010c06f..0663033 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -256,20 +256,23 @@ lvdisplay --maps $vg
 
 lvremove -f $vg
 
+# migration_threshold is protected to not be smaller then  8*chunk_size
+# so even when user sets migration threshold to lower value,
+# activation will ensure the minimal size is preserved
 lvcreate --type cache-pool -L10 $vg/cpool
-lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachesettings migration_threshold=233
+lvcreate --type cache -l 1 --cachepool $vg/cpool -c 64k -n corigin $vg --cachesettings migration_threshold=233
 dmsetup status | grep $vg
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 1024'
 lvchange -an $vg
 lvchange -ay $vg
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 1024'
 
 lvremove -f $vg
 
-lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 $vg/cpool
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=1233 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
 dmsetup status | grep $vg
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 1233'
 
 lvremove -f $vg
 
@@ -281,7 +284,7 @@ lvremove -f $vg
 # Creation of read-only cache pool is not supported
 invalid lvcreate -pr --type cache-pool -l1 -n $vg/cpool
 
-# Atempt to use bigger chunk size then cache pool data size
+# Attempt to use bigger chunk size then cache pool data size
 fail lvcreate -l 1 --type cache-pool --chunksize 16M $vg 2>out
 grep "chunk size" out
 


