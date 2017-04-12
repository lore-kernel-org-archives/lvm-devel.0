From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:39:21 -0400
Subject: master - tests: restore some test changes
Message-ID: <201704121939.v3CJdLVY012330@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8034e14e6c8012dbd51dc3c5e5fc1c0036e00a0
Commit:        f8034e14e6c8012dbd51dc3c5e5fc1c0036e00a0
Parent:        3018cdcaa7aa258a432738b95077098985fb0c74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 3 15:57:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:34:08 2017 +0200

tests: restore some test changes

Restore existing tests and separate new tests
for new options later.

Keep coverage for existing syntax

Reverts bits from commits:

a801b92b2c81213dddccc9f9a09794208f92bfc9.
d71aaca07b2c14049130ab368221510c65236af7
fa2a728a395639a32707bb75e6bb4197b02769de
1e2420bca85da9a37570871cd70192e9ae831786
46abc28a480069b3e8b2c5c7c3448ffa25ec17ba
0e3e611a137a264a343335d18d500fce7af8e0f7
---
 test/shell/lvconvert-cache-snapshot.sh             |    2 +-
 test/shell/lvconvert-cache.sh                      |   44 ++++++++++---------
 test/shell/lvconvert-mirror.sh                     |   18 ++++----
 test/shell/lvconvert-repair-thin.sh                |    8 ++--
 test/shell/lvconvert-thin-raid.sh                  |    6 ++-
 test/shell/lvconvert-thin.sh                       |   25 ++++++-----
 test/shell/lvcreate-cache.sh                       |    3 +-
 test/shell/lvextend-thin-full.sh                   |    2 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh      |   12 +++---
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    2 +-
 test/shell/snapshot-merge-stack.sh                 |    2 +-
 test/shell/snapshot-merge.sh                       |   16 ++++----
 test/shell/thin-flags.sh                           |    2 +-
 test/shell/thin-merge.sh                           |    6 +-
 test/shell/thin-vglock.sh                          |    2 +-
 test/shell/vgextend-restoremissing.sh              |    2 +
 16 files changed, 81 insertions(+), 71 deletions(-)

diff --git a/test/shell/lvconvert-cache-snapshot.sh b/test/shell/lvconvert-cache-snapshot.sh
index 4ecec70..8f0ab53 100644
--- a/test/shell/lvconvert-cache-snapshot.sh
+++ b/test/shell/lvconvert-cache-snapshot.sh
@@ -33,7 +33,7 @@ lvcreate -L3 -n cow $vg
 not lvconvert -s cow $vg/$lv1
 
 # Use cached LV with 'striped' cow volume
-lvconvert -y -s $vg/$lv1 $vg/cow
+lvconvert -y -s $vg/$lv1 cow
 check lv_field $vg/cow segtype linear
 check lv_field $vg/$lv1 segtype cache
 
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 5263028..6a8daa3 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -60,7 +60,7 @@ check lv_field $vg/$lv2 cache_settings "random_threshold=56,sequential_threshold
 # Check swap of cache pool metadata
 lvconvert --yes --type cache-pool --poolmetadata $lv4 $vg/$lv3
 UUID=$(get lv_field $vg/$lv5 uuid)
-lvconvert --yes --swapmetadata --poolmetadata $lv5 $vg/$lv3
+lvconvert --yes --cachepool $vg/$lv3 --poolmetadata $lv5
 check lv_field $vg/${lv3}_cmeta uuid "$UUID"
 
 
@@ -108,30 +108,32 @@ lvcreate -an -Zn -L 8 -n $lv4 $vg
 invalid lvconvert --type cache --poolmetadata $vg/$lv2 $vg/$lv1
 
 # Cannot mix with thins
-not lvconvert --type cache --poolmetadata $vg/$lv2 --thinpool $vg/$lv1
-not lvconvert --type cache --thin --poolmetadata $vg/$lv2 $vg/$lv1
+invalid lvconvert --type cache --poolmetadata $vg/$lv2 --thinpool $vg/$lv1
+invalid lvconvert --type cache --thin --poolmetadata $vg/$lv2 $vg/$lv1
 
 # Undefined cached volume
-not lvconvert --type cache --cachepool $vg/$lv1
-not lvconvert --cache --cachepool $vg/$lv1
+invalid lvconvert --type cache --cachepool $vg/$lv1
+invalid lvconvert --cache --cachepool $vg/$lv1
 
+# FIXME: temporarily we return error code 5
+INVALID=not
 # Single vg is required
-not lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
-not lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
-not lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
-not lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
+$INVALID lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
+$INVALID lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
+$INVALID lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
+$INVALID lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
 
-not lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2
+$INVALID lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2
 
 # Invalid syntax, vg is unknown
-not lvconvert --yes --cachepool $lv3 --poolmetadata $lv4
+$INVALID lvconvert --yes --cachepool $lv3 --poolmetadata $lv4
 
 # Invalid chunk size is <32KiB >1GiB
-not lvconvert --type cache-pool --chunksize 16 --poolmetadata $lv2 $vg/$lv1
-not lvconvert --type cache-pool --chunksize 2G --poolmetadata $lv2 $vg/$lv1
+$INVALID lvconvert --type cache-pool --chunksize 16 --poolmetadata $lv2 $vg/$lv1
+$INVALID lvconvert --type cache-pool --chunksize 2G --poolmetadata $lv2 $vg/$lv1
 
 # Invalid chunk size is bigger then data size, needs to open VG
-not lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$lv1
+fail lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$lv1
 
 lvremove -f $vg
 
@@ -142,7 +144,7 @@ lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 
 # unsupported yet
-not lvconvert --repair $vg/cpool 2>&1 | tee out
+fail lvconvert --repair $vg/cpool 2>&1 | tee out
 #grep "Cannot convert internal LV" out
 
 lvremove -f $vg
@@ -154,13 +156,13 @@ lvcreate --type cache-pool -L10 $vg/$lv1
 lvcreate --cache -L20 $vg/$lv1
 lvcreate -L10 -n $lv2 $vg
 
-not lvconvert --yes --type cache $vg/$lv2 --cachepool $vg/$lv1
-not lvconvert --yes --type cache $vg/$lv1 --cachepool $vg/$lv2
-not lvconvert --yes --type cache-pool $vg/$lv1
-not lvconvert --yes --type mirror -m1 $vg/$lv1
+fail lvconvert --yes --type cache $vg/$lv2 --cachepool $vg/$lv1
+fail lvconvert --yes --type cache $vg/$lv1 --cachepool $vg/$lv2
+fail lvconvert --yes --type cache-pool $vg/$lv1
+fail lvconvert --yes --type mirror -m1 $vg/$lv1
 not aux have_raid 1 0 0 || fail lvconvert --yes --type raid1 -m1 $vg/$lv1
-not lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
-not lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
+fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
+fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
 not aux have_thin 1 0 0 || fail lvconvert --yes -T --thinpool $vg/$lv2 $vg/$lv1
 
 lvremove -f $vg
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 1f059ca..7e8d663 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -87,7 +87,7 @@ aux delay_dev "$dev2" 0 2000 ${offset}:1
 lvcreate -aey -l5 -Zn -Wn --type mirror --regionsize 16K -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 should not lvconvert -m-1 $vg/$lv1 "$dev1"
 aux enable_dev "$dev2"
-lvconvert --startpoll $vg/$lv1 || true # wait
+should lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
 aux wait_for_sync $vg $lv1
@@ -113,7 +113,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # Next convert should fail b/c we can't have 2 at once
 should not lvconvert -m+1 $vg/$lv1 "$dev5"
 aux enable_dev "$dev4"
-lvconvert --startpoll $vg/$lv1 || true # wait
+should lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
 check mirror $vg $lv1 "$dev3"
@@ -156,7 +156,7 @@ lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -aey $vg/$lv1
-lvconvert --startpoll $vg/$lv1 || true # wait
+should lvconvert $vg/$lv1 # wait
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 lvremove -ff $vg
@@ -168,7 +168,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-lvconvert --startpoll $vg/$lv1 || true # wait
+should lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -179,7 +179,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-lvconvert --startpoll $vg/$lv1 || true # wait
+should lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -192,9 +192,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-lvconvert --startpoll $vg/$lv1 || true
+should lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-lvconvert --startpoll $vg/$lv1 || true
+should lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -207,9 +207,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-lvconvert --startpoll $vg/$lv1 || true
+should lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-lvconvert --startpoll $vg/$lv1 || true
+should lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 923b9c8..8930894 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -45,7 +45,7 @@ lvchange -an $vg/$lv2 $vg/$lv1 $vg/pool $vg/repair
 
 # Manual repair steps:
 # Test swapping - swap out thin-pool's metadata with our repair volume
-lvconvert -y -f --swapmetadata --poolmetadata $vg/repair $vg/pool
+lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
 lvchange -ay $vg/repair
 
@@ -74,7 +74,7 @@ not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 lvchange -an $vg
 
 # Swap repaired metadata back
-lvconvert -y -f --swapmetadata --poolmetadata $vg/fixed $vg/pool
+lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
 
 # Check pool still preserves its original settings
 check lv_field $vg/pool chunksize "128.00k"
@@ -87,7 +87,7 @@ vgchange -ay $vg
 vgchange -an $vg
 
 # Put back 'broken' metadata
-lvconvert -y -f --swapmetadata --poolmetadata $vg/repair $vg/pool
+lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
 # Check --repair usage
 lvconvert -v --repair $vg/pool
@@ -98,7 +98,7 @@ lvchange -ay $vg/pool
 vgchange -an $vg
 
 # Restore damaged metadata
-lvconvert -y -f --swapmetadata --poolmetadata $vg/pool_meta0 $vg/pool
+lvconvert -y -f --poolmetadata $vg/pool_meta0 --thinpool $vg/pool
 
 # Check lvremove -ff works even with damaged pool
 lvremove -ff $vg
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 807b1dc..b243a55 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -29,9 +29,11 @@ aux wait_for_sync $vg $lv1
 aux wait_for_sync $vg $lv2
 lvchange -an $vg/$lv1
 
+# FIXME: temporarily we return error code 5
+INVALID=not
 # conversion fails for internal volumes
-not lvconvert --thinpool $vg/${lv1}_rimage_0
-not lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
+$INVALID lvconvert --thinpool $vg/${lv1}_rimage_0
+$INVALID lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 2a54614..c73c648 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -57,14 +57,17 @@ lvchange -an $vg/$lv1
 
 # conversion fails for mirror segment type
 fail lvconvert --thinpool $vg/$lv1
+
+# FIXME: temporarily we return error code 5
+INVALID=not
 # cannot use same LV
-not lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
+$INVALID lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
 
 prepare_lvs
 
 # conversion fails for internal volumes
 # can't use --readahead with --poolmetadata
-not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
+invalid lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 prepare_lvs
@@ -81,9 +84,9 @@ grep "Pool zeroing and large" err
 UUID=$(get lv_field $vg/$lv2 uuid)
 # Fail is pool is active
 # TODO  maybe detect inactive pool and deactivate
-fail lvconvert --swapmetadata --yes --poolmetadata $lv2 $vg/$lv1
+fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
 lvchange -an $vg
-lvconvert --swapmetadata --yes --poolmetadata $lv2 $vg/$lv1
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
 check lv_field $vg/${lv1}_tmeta uuid "$UUID"
 lvremove -f $vg
 
@@ -96,20 +99,20 @@ lvcreate -L1M -n $lv3 $vg
 # chunk size is bigger then size of thin pool data
 fail lvconvert --yes -c 1G --thinpool $vg/$lv3
 # stripes can't be used with poolmetadata
-not lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too small metadata (<2M)
 fail lvconvert --yes -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
 # too small chunk size fails
-not lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+$INVALID lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too big chunk size fails
-not lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+$INVALID lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # negative chunk size fails
-not lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+$INVALID lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # non multiple of 64KiB fails
-not lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+$INVALID lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 # cannot use same LV for pool and convertion
-not lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
+$INVALID lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
 
 # Warning about smaller then suggested
 lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 2>&1 | tee err
@@ -129,7 +132,7 @@ if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
 lvconvert --yes -c 64 --thinpool $vg/$lv1 2>&1 | tee err
-grep "too small" err
+grep "WARNING: Chunk size is too small" err
 lvremove -f $vg
 fi
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 9222bea..646bd10 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -56,7 +56,8 @@ fail lvcreate -l 1 --cachepool pool8 $vg
 
 # no size specified
 invalid lvcreate --cachepool pool $vg 2>&1 | tee err
-# grep "specify either size or extents" err
+#grep "specify either size or extents" err
+grep "Incorrect syntax" err
 
 # Check nothing has been created yet
 check vg_field $vg lv_count 0
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 5b7b9e7..3bafad4 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -38,7 +38,7 @@ lvchange -an $vg
 
 lvcreate -L2M -n $lv1 $vg
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 # Cannot resize if set to 0%
 not lvextend --use-policies --config 'activation{thin_pool_autoextend_percent = 0}' $vg/pool 2>&1 | tee err
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 2cfa1c3..6d27600 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -78,7 +78,7 @@ fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 # Not alllowed when thin-pool metadata free space is <75% for 2M meta
 fail lvcreate -V20 $vg/pool
@@ -91,7 +91,7 @@ lvchange -an $vg/pool
 fake_metadata_ 7400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv2 $vg/pool
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv2
 lvchange -ay $vg/pool
 # Check generated metadata consume more then 88%
 test "$(meta_percent_)" -gt "88"
@@ -138,7 +138,7 @@ lvchange -an $vg/thin $vg/thin2 $vg/pool
 # Transaction_id is lower by 1 and there are no messages -> ERROR
 fake_metadata_ 10 0 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
 
@@ -147,7 +147,7 @@ check inactive $vg pool_tmeta
 # Transaction_id is higher by 1
 fake_metadata_ 10 3 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
 
@@ -158,7 +158,7 @@ fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 vgchange -ay $vg
 
@@ -173,7 +173,7 @@ fake_metadata_ 350 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
-lvconvert -y --chunksize 64k --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 lvchange -ay $vg/pool  $vg/$lv1
 lvs -a $vg
 
diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index 58afbed..34139df 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -54,7 +54,7 @@ mkdir test_mnt
 
 setup_merge_ $vg1 $lv1
 mount "$(lvdev_ $vg1 $lv1)" test_mnt
-lvconvert --mergesnapshot $vg1/$(snap_lv_name_ $lv1)
+lvconvert --merge $vg1/$(snap_lv_name_ $lv1)
 umount test_mnt
 vgchange -an $vg1
 
diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index f9d2e62..2fdfaa4 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -32,7 +32,7 @@ snap_and_merge() {
 	SLEEP_PID=$(aux hold_device_open $vg $lv1 20)
 
 	# initiate background merge
-	lvconvert -b --mergesnapshot $vg/$lv2
+	lvconvert -b --merge $vg/$lv2
 
 	lvs -a -o+lv_merging,lv_merge_failed $vg
 	get lv_field $vg/$lv1 lv_attr | grep "Owi-ao"
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 0d3e1cb..a301d22 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -51,15 +51,15 @@ mkdir test_mnt
 # test full merge of a single LV
 setup_merge_ $vg $lv1
 
-# make sure lvconvert --mergesnapshot requires explicit LV listing
-not lvconvert --mergesnapshot
-lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+# make sure lvconvert --merge requires explicit LV listing
+not lvconvert --merge
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
 # test that an actively merging snapshot may not be removed
 setup_merge_ $vg $lv1
-lvconvert -i+100 --mergesnapshot --background $vg/$(snap_lv_name_ $lv1)
+lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
 not lvremove -f $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
@@ -67,7 +67,7 @@ lvremove -f $vg/$lv1
 # "onactivate merge" test
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -88,7 +88,7 @@ lvremove -f $vg/$lv1
 #    to make sure preload of origin's metadata is _not_ performed
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -99,7 +99,7 @@ lvremove -f $vg/$lv1
 
 # test multiple snapshot merge; tests copy out that is driven by merge
 setup_merge_ $vg $lv1 1
-lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
@@ -108,7 +108,7 @@ setup_merge_ $vg $lv1
 setup_merge_ $vg $lv2
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
-lvconvert --mergesnapshot @this_is_a_test
+lvconvert --merge @this_is_a_test
 lvs $vg | tee out
 not grep $(snap_lv_name_ $lv1) out
 not grep $(snap_lv_name_ $lv2) out
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index cbf9d19..7d87553 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -71,7 +71,7 @@ aux prepare_thin_metadata 490 1 | tee data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --swapmetadata --poolmetadata $vg/$lv1 $vg/pool
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 lvchange -ay $vg
 
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index d932924..f044f57 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -44,7 +44,7 @@ touch mntsnap/test_snap
 
 lvs -o+tags,thin_id $vg
 
-lvconvert --mergethin $vg/snap
+lvconvert --merge $vg/snap
 
 umount mnt
 
@@ -102,12 +102,12 @@ lvcreate -s -n snap $vg/$lv1
 lvcreate -s -L10 -n oldsnapof_${lv1} $vg/$lv1
 not lvconvert --merge $vg/snap
 $MKFS "$DM_DEV_DIR/$vg/oldsnapof_${lv1}"
-lvconvert --mergesnapshot $vg/oldsnapof_${lv1}
+lvconvert --merge $vg/oldsnapof_${lv1}
 fsck -n "$DM_DEV_DIR/$vg/$lv1"
 check lv_not_exists $vg oldsnapof_${lv1}
 # Add old snapshot to thin snapshot
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
-lvconvert --mergethin $vg/snap
+lvconvert --merge $vg/snap
 lvremove -f $vg/oldsnapof_snap
 
 vgremove -ff $vg
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 0b96b4b..40f3adf 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -34,7 +34,7 @@ mount "$DM_DEV_DIR/$vg/$lv1" mnt
 lvcreate -s -n snap $vg/$lv1
 check lv_field $vg/snap thin_id "3"
 
-lvconvert --mergethin $vg/snap
+lvconvert --merge $vg/snap
 
 umount mnt
 
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 2a82115..7f8fee0 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -23,6 +23,8 @@ lvcreate -l 1 -n lv1 $vg "$dev1"
 invalid vgextend
 # --metadatacopies => use --pvmetadatacopies
 invalid vgextend --metadatacopies 3 $vg "$dev1" 2>&1 | tee out
+#grep -- "use --pvmetadatacopies" out
+grep -- "unrecognized option '--metadatacopies'" out
 
 # VG name should exist
 fail vgextend --restoremissing $vg-invalid "$dev1"


