From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:54 -0400
Subject: master - tests: use throttle_dm_mirror
Message-ID: <201805121625.w4CGPsKD007849@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5da325d701082edab568160824c9c8c7289cf15
Commit:        f5da325d701082edab568160824c9c8c7289cf15
Parent:        172d8fb3554c3c71ce4ba0d8efa65dce62a877c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:45:11 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: use throttle_dm_mirror

In this case it's better to use throttling of mirror sync,
that delay everything with dm_delay.
---
 test/shell/lvconvert-mirror.sh |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index a45e6e7..72a3978 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -17,7 +17,7 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-aux prepare_pvs 5 100
+aux prepare_pvs 5
 get_devs
 
 # proper DEVRANGE needs to be set according to extent size
@@ -319,10 +319,12 @@ fi
 #
 aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
 aux zero_dev "$dev4" $(get first_extent_sector "$dev4"):
+aux throttle_dm_mirror
 
 # Use large enough mirror that takes time to sychronize with small regionsize
-lvcreate -aey -L80 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvcreate -aey -L20 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
+aux restore_dm_mirror
 grep "not in-sync" out
 
 lvconvert $vg/$lv1 # wait
@@ -334,9 +336,11 @@ check linear $vg $lv1
 check lv_on $vg $lv1 "$dev4"
 lvremove -ff $vg
 
+
+aux throttle_dm_mirror
 # No parallel lvconverts on a single LV please
 # Use big enough mirror size and small regionsize to run on all test machines succesfully
-lvcreate -aey -Zn -Wn -L80 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
+lvcreate -aey -Zn -Wn -L20 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 
@@ -345,6 +349,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 
 # Next convert should fail b/c we can't have 2 at once
 not lvconvert -m+1 $vg/$lv1 "$dev5"  2>&1 | tee out
+aux restore_dm_mirror
 grep "is already being converted" out
 
 lvconvert $vg/$lv1 # wait


