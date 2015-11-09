From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 11:29:11 +0000 (UTC)
Subject: master - tests: update test to check for race better
Message-ID: <20151109112911.9B71860E09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7103012754884a964da481626cf96fd6f64b5175
Commit:        7103012754884a964da481626cf96fd6f64b5175
Parent:        ab4773671b1738abb4fb6c1504fcdd953760d80b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 12:16:56 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 12:21:17 2015 +0100

tests: update test to check for race better

Use  delay_dev to slow down mirror sync so we could more
easily check for race and proper reject of parallel mirror
leg addition/reduction.

Also expose fail in mirror allocation of parallel leg.
---
 test/shell/lvconvert-mirror.sh |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 5c7aad3..bd6d00e 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -14,7 +14,7 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-aux prepare_pvs 5 10
+aux prepare_pvs 5 20
 # proper DEVRANGE needs to be set according to extent size
 DEVRANGE="0-32"
 vgcreate -s 32k $vg $(cat DEVICES)
@@ -77,12 +77,14 @@ lvremove -ff $vg
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -aey -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
-# FIXME:
-#  This is somewhat timing dependent - sync /could/ finish before
-#  we get a chance to have this command fail
+offset=$(get first_extent_sector "$dev2")
+offset=$(( offset + 2 ))
+# put 1 single slowing delayed sector
+# update in case  mirror ever gets faster and allows parallel read
+aux delay_dev "$dev2" 0 2000 ${offset}:1
+lvcreate -aey -l5 -Zn -Wn --type mirror --regionsize 16K -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 should not lvconvert -m-1 $vg/$lv1 "$dev1"
-
+aux enable_dev "$dev2"
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
@@ -94,15 +96,21 @@ check linear $vg $lv1
 check lv_on $vg $lv1 "$dev4"
 lvremove -ff $vg
 
+# FIXME: lots of unneeded extents here for log - it needs to be at least region_size in size
 # No parallel lvconverts on a single LV please
 
-lvcreate -aey -l5 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -Zn -Wn -l8 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
+
+offset=$(get first_extent_sector "$dev4")
+offset=$(( offset + 2 ))
+aux delay_dev "$dev4" 0 2000 ${offset}:
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 
 # Next convert should fail b/c we can't have 2 at once
 should not lvconvert -m+1 $vg/$lv1 "$dev5"
+aux enable_dev "$dev4"
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
@@ -225,7 +233,7 @@ lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
 lvcreate -aey -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
-lvconvert --type mirror -m1 $vg/$lv1
+lvconvert --type mirror -vvvv -m1 $vg/$lv1
 
 should check mirror $vg $lv1
 check mirror_legs $vg $lv1 2


