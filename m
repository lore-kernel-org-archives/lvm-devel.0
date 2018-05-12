From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:27 -0400
Subject: master - tests: old systems do not have even throttling
Message-ID: <201805122139.w4CLdRmX005481@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e56fa6892093700273cf3501f6ad589545628a9
Commit:        0e56fa6892093700273cf3501f6ad589545628a9
Parent:        0a5edc1f12ddad72e0c34dddfecbb46cbfdb192f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 23:36:04 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 23:37:30 2018 +0200

tests: old systems do not have even throttling

When even throttling is not available, skip or use  should
with particular test piece.
---
 test/shell/lvconvert-mirror.sh |   10 ++++++----
 test/shell/pvmove-abort-all.sh |    7 ++++---
 test/shell/pvmove-abort.sh     |    7 ++++---
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 72a3978..91b8490 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -319,11 +319,13 @@ fi
 #
 aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
 aux zero_dev "$dev4" $(get first_extent_sector "$dev4"):
-aux throttle_dm_mirror
+
+SHOULD=
+aux throttle_dm_mirror || SHOULD=should
 
 # Use large enough mirror that takes time to sychronize with small regionsize
 lvcreate -aey -L20 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
-not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
+$SHOULD not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
 aux restore_dm_mirror
 grep "not in-sync" out
 
@@ -337,7 +339,7 @@ check lv_on $vg $lv1 "$dev4"
 lvremove -ff $vg
 
 
-aux throttle_dm_mirror
+aux throttle_dm_mirror || :
 # No parallel lvconverts on a single LV please
 # Use big enough mirror size and small regionsize to run on all test machines succesfully
 lvcreate -aey -Zn -Wn -L20 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
@@ -348,7 +350,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # ATM upconversion should be running
 
 # Next convert should fail b/c we can't have 2 at once
-not lvconvert -m+1 $vg/$lv1 "$dev5"  2>&1 | tee out
+$SHOULD not lvconvert -m+1 $vg/$lv1 "$dev5"  2>&1 | tee out
 aux restore_dm_mirror
 grep "is already being converted" out
 
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 5a86a37..893223f 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -22,6 +22,10 @@ export DM_ABORT_ON_INTERNAL_ERRORS=0
 
 aux lvmconf 'activation/raid_region_size = 16'
 
+aux target_at_least dm-mirror 1 10 0 || skip
+# Throttle mirroring
+aux throttle_dm_mirror || skip
+
 aux prepare_pvs 6 60
 
 vgcreate -s 512k $vg "$dev1" "$dev2"
@@ -31,9 +35,6 @@ vgcreate -s 512k $vg1 "$dev4" "$dev5"
 pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
-# Throttle mirroring
-aux throttle_dm_mirror
-
 for mode in "--atomic" "" ;
 do
 for backgroundarg in "-b" "" ;
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 5ca993b..49847c0 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -18,15 +18,16 @@ SKIP_WITH_LVMLOCKD=1
 
 aux lvmconf 'activation/raid_region_size = 16'
 
+aux target_at_least dm-mirror 1 10 0 || skip
+# Throttle mirroring
+aux throttle_dm_mirror || skip
+
 aux prepare_pvs 3 60
 
 vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
-# Throttle mirroring
-aux throttle_dm_mirror
-
 for mode in "--atomic" "" ;
 do
 for backgroundarg in "-b" "" ;


