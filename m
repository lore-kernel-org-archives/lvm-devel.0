From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:18 +0000 (UTC)
Subject: master - tests: use swapmetadata
Message-ID: <20170213181018.3BAEF6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a801b92b2c81213dddccc9f9a09794208f92bfc9
Commit:        a801b92b2c81213dddccc9f9a09794208f92bfc9
Parent:        86d8ab493bbfbc0130a2bbe7717557ecc7fa33fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 9 15:54:59 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

tests: use swapmetadata

and some other pool/cache/thin related changes
---
 test/shell/lvconvert-cache.sh                 |   42 ++++++++++++------------
 test/shell/lvconvert-repair-thin.sh           |    8 ++--
 test/shell/lvextend-thin-full.sh              |    2 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh |   12 +++---
 test/shell/thin-flags.sh                      |    2 +-
 5 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 31fe4e8..5263028 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -60,7 +60,7 @@ check lv_field $vg/$lv2 cache_settings "random_threshold=56,sequential_threshold
 # Check swap of cache pool metadata
 lvconvert --yes --type cache-pool --poolmetadata $lv4 $vg/$lv3
 UUID=$(get lv_field $vg/$lv5 uuid)
-lvconvert --yes --cachepool $vg/$lv3 --poolmetadata $lv5
+lvconvert --yes --swapmetadata --poolmetadata $lv5 $vg/$lv3
 check lv_field $vg/${lv3}_cmeta uuid "$UUID"
 
 
@@ -108,30 +108,30 @@ lvcreate -an -Zn -L 8 -n $lv4 $vg
 invalid lvconvert --type cache --poolmetadata $vg/$lv2 $vg/$lv1
 
 # Cannot mix with thins
-invalid lvconvert --type cache --poolmetadata $vg/$lv2 --thinpool $vg/$lv1
-invalid lvconvert --type cache --thin --poolmetadata $vg/$lv2 $vg/$lv1
+not lvconvert --type cache --poolmetadata $vg/$lv2 --thinpool $vg/$lv1
+not lvconvert --type cache --thin --poolmetadata $vg/$lv2 $vg/$lv1
 
 # Undefined cached volume
-invalid lvconvert --type cache --cachepool $vg/$lv1
-invalid lvconvert --cache --cachepool $vg/$lv1
+not lvconvert --type cache --cachepool $vg/$lv1
+not lvconvert --cache --cachepool $vg/$lv1
 
 # Single vg is required
-invalid lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
-invalid lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
-invalid lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
-invalid lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
+not lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
+not lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
+not lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
+not lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
 
-invalid lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2
+not lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2
 
 # Invalid syntax, vg is unknown
-invalid lvconvert --yes --cachepool $lv3 --poolmetadata $lv4
+not lvconvert --yes --cachepool $lv3 --poolmetadata $lv4
 
 # Invalid chunk size is <32KiB >1GiB
-invalid lvconvert --type cache-pool --chunksize 16 --poolmetadata $lv2 $vg/$lv1
-invalid lvconvert --type cache-pool --chunksize 2G --poolmetadata $lv2 $vg/$lv1
+not lvconvert --type cache-pool --chunksize 16 --poolmetadata $lv2 $vg/$lv1
+not lvconvert --type cache-pool --chunksize 2G --poolmetadata $lv2 $vg/$lv1
 
 # Invalid chunk size is bigger then data size, needs to open VG
-fail lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$lv1
+not lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$lv1
 
 lvremove -f $vg
 
@@ -142,7 +142,7 @@ lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 
 # unsupported yet
-fail lvconvert --repair $vg/cpool 2>&1 | tee out
+not lvconvert --repair $vg/cpool 2>&1 | tee out
 #grep "Cannot convert internal LV" out
 
 lvremove -f $vg
@@ -154,13 +154,13 @@ lvcreate --type cache-pool -L10 $vg/$lv1
 lvcreate --cache -L20 $vg/$lv1
 lvcreate -L10 -n $lv2 $vg
 
-fail lvconvert --yes --type cache $vg/$lv2 --cachepool $vg/$lv1
-fail lvconvert --yes --type cache $vg/$lv1 --cachepool $vg/$lv2
-fail lvconvert --yes --type cache-pool $vg/$lv1
-fail lvconvert --yes --type mirror -m1 $vg/$lv1
+not lvconvert --yes --type cache $vg/$lv2 --cachepool $vg/$lv1
+not lvconvert --yes --type cache $vg/$lv1 --cachepool $vg/$lv2
+not lvconvert --yes --type cache-pool $vg/$lv1
+not lvconvert --yes --type mirror -m1 $vg/$lv1
 not aux have_raid 1 0 0 || fail lvconvert --yes --type raid1 -m1 $vg/$lv1
-fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
-fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
+not lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
+not lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
 not aux have_thin 1 0 0 || fail lvconvert --yes -T --thinpool $vg/$lv2 $vg/$lv1
 
 lvremove -f $vg
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 8930894..923b9c8 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -45,7 +45,7 @@ lvchange -an $vg/$lv2 $vg/$lv1 $vg/pool $vg/repair
 
 # Manual repair steps:
 # Test swapping - swap out thin-pool's metadata with our repair volume
-lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
+lvconvert -y -f --swapmetadata --poolmetadata $vg/repair $vg/pool
 
 lvchange -ay $vg/repair
 
@@ -74,7 +74,7 @@ not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 lvchange -an $vg
 
 # Swap repaired metadata back
-lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
+lvconvert -y -f --swapmetadata --poolmetadata $vg/fixed $vg/pool
 
 # Check pool still preserves its original settings
 check lv_field $vg/pool chunksize "128.00k"
@@ -87,7 +87,7 @@ vgchange -ay $vg
 vgchange -an $vg
 
 # Put back 'broken' metadata
-lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
+lvconvert -y -f --swapmetadata --poolmetadata $vg/repair $vg/pool
 
 # Check --repair usage
 lvconvert -v --repair $vg/pool
@@ -98,7 +98,7 @@ lvchange -ay $vg/pool
 vgchange -an $vg
 
 # Restore damaged metadata
-lvconvert -y -f --poolmetadata $vg/pool_meta0 --thinpool $vg/pool
+lvconvert -y -f --swapmetadata --poolmetadata $vg/pool_meta0 $vg/pool
 
 # Check lvremove -ff works even with damaged pool
 lvremove -ff $vg
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 3bafad4..5b7b9e7 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -38,7 +38,7 @@ lvchange -an $vg
 
 lvcreate -L2M -n $lv1 $vg
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 
 # Cannot resize if set to 0%
 not lvextend --use-policies --config 'activation{thin_pool_autoextend_percent = 0}' $vg/pool 2>&1 | tee err
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 6d27600..2cfa1c3 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -78,7 +78,7 @@ fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 
 # Not alllowed when thin-pool metadata free space is <75% for 2M meta
 fail lvcreate -V20 $vg/pool
@@ -91,7 +91,7 @@ lvchange -an $vg/pool
 fake_metadata_ 7400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv2
+lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv2 $vg/pool
 lvchange -ay $vg/pool
 # Check generated metadata consume more then 88%
 test "$(meta_percent_)" -gt "88"
@@ -138,7 +138,7 @@ lvchange -an $vg/thin $vg/thin2 $vg/pool
 # Transaction_id is lower by 1 and there are no messages -> ERROR
 fake_metadata_ 10 0 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
 
@@ -147,7 +147,7 @@ check inactive $vg pool_tmeta
 # Transaction_id is higher by 1
 fake_metadata_ 10 3 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
 
@@ -158,7 +158,7 @@ fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 
 vgchange -ay $vg
 
@@ -173,7 +173,7 @@ fake_metadata_ 350 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
-lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 lvchange -ay $vg/pool  $vg/$lv1
 lvs -a $vg
 
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 7d87553..cbf9d19 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -71,7 +71,7 @@ aux prepare_thin_metadata 490 1 | tee data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
 
 lvchange -ay $vg
 


