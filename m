From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:45 -0400
Subject: master - tests: update testing to not use delay dev
Message-ID: <201804232043.w3NKhjAu005031@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc3ed8856f445079de43cd33f64582cee9bc80ea
Commit:        fc3ed8856f445079de43cd33f64582cee9bc80ea
Parent:        c492fbb51ce783ca32efd7ed8414d809daaf4ca5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 23 21:26:05 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

tests: update testing to not use delay dev

Instead of using delayer device user 'zero' device and let mirror
do some real work which takes some time.

In case the test machine is too fast - mirror might need to be made bigger
to meet needed criteria.

Also move all test needed this 'zero' PV trick to the end of test
so  $dev2  and $dev4 are covered with 'zero' and can take any amount of
write without consuming any real space.
---
 test/shell/lvconvert-mirror.sh |  129 +++++++++++++++++++++-------------------
 1 files changed, 68 insertions(+), 61 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 4e18212..a45e6e7 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,7 +17,7 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-aux prepare_pvs 5 20
+aux prepare_pvs 5 100
 get_devs
 
 # proper DEVRANGE needs to be set according to extent size
@@ -78,56 +78,6 @@ lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 "$dev1"
 lvremove -ff $vg
 
-# Start w/ 3-way mirror
-# Test pulling primary image before mirror in-sync (should fail)
-# Test pulling primary image after mirror in-sync (should work)
-# Test that the correct devices remain in the mirror
-offset=$(get first_extent_sector "$dev2")
-offset=$(( offset + 2 ))
-# put 1 single slowing delayed sector
-# update in case  mirror ever gets faster and allows parallel read
-aux delay_dev "$dev2" 0 10 ${offset}:1
-
-lvcreate -aey -l10 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
-lvs -a -o+seg_pe_ranges $vg
-not lvconvert -m-1 $vg/$lv1 "$dev1"
-lvconvert $vg/$lv1 # wait
-lvs -a $vg
-aux enable_dev "$dev2"
-lvconvert $vg/$lv1 # wait
-lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
-
-aux wait_for_sync $vg $lv1
-lvconvert -m-1 $vg/$lv1 "$dev1"
-check mirror_images_on $vg $lv1 "$dev2" "$dev4"
-lvconvert -m-1 $vg/$lv1 "$dev2"
-check linear $vg $lv1
-check lv_on $vg $lv1 "$dev4"
-lvremove -ff $vg
-
-# FIXME: lots of unneeded extents here for log - it needs to be at least region_size in size
-# No parallel lvconverts on a single LV please
-
-lvcreate -aey -Zn -Wn -l8 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
-check mirror $vg $lv1
-check mirror_legs $vg $lv1 2
-
-offset=$(get first_extent_sector "$dev4")
-offset=$(( offset + 2 ))
-aux delay_dev "$dev4" 0 2000 ${offset}:
-LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
-
-# Next convert should fail b/c we can't have 2 at once
-not lvconvert -m+1 $vg/$lv1 "$dev5"
-aux enable_dev "$dev4"
-lvconvert $vg/$lv1 # wait
-lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
-
-check mirror $vg $lv1 "$dev3"
-check mirror_no_temporaries $vg $lv1
-check mirror_legs $vg $lv1 3
-lvremove -ff $vg
-
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
 lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
@@ -240,13 +190,6 @@ lvremove -ff $vg
 
 # ---------------------------------------------------------------------
 
-# "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-lvcreate -aey -l "$(get pv_field "$dev1" pe_count)" --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
-aux wait_for_sync $vg $lv1
-lvconvert -m0 $vg/$lv1 "$dev1"
-check linear $vg $lv1
-lvremove -ff $vg
-
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute
 # after being down and the up converted"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 --nosync $vg
@@ -300,6 +243,7 @@ lvcreate -aey -l15 -n $lv1 $vg
 not lvconvert --type mirror -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
 
+
 # Linear to mirror with mirrored log using --alloc anywhere
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 if test -e LOCAL_CLVMD; then
@@ -311,9 +255,10 @@ check mirror $vg $lv1
 fi
 lvremove -ff $vg
 
-# FIXME - cases which needs to be fixed to work in cluster
-test -e LOCAL_CLVMD && exit 0
 
+if test -e LOCAL_CLVMD; then
+: # FIXME - cases which needs to be fixed to work in cluster
+else
 # Should not be able to add images to --nosync mirror
 # but should be able to after 'lvchange --resync'
 lvcreate -aey --type mirror -m 1 -l1 -n $lv1 $vg --nosync
@@ -359,5 +304,67 @@ lvcreate -l2 -n $lv1 $vg
 lvconvert --type mirror -i1 -m1 $vg/$lv1 | tee out
 grep -e "$vg/$lv1: Converted:" out || die "Missing sync info in foreground mode"
 lvremove -ff $vg
+fi
+
+
+#########################################################################
+# Start w/ 3-way mirror
+# Test that the correct devices remain in the mirror
+# Make $dev2 & $dev4  zero backend device so large mirrors can be user
+# without consuming any real space. Clearly such mirrors can't be read back
+# but tests here are validating possibilies of those conversions
+#
+# Test pulling primary image before mirror in-sync (should fail)
+# Test pulling primary image after mirror in-sync (should work)
+#
+aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
+aux zero_dev "$dev4" $(get first_extent_sector "$dev4"):
+
+# Use large enough mirror that takes time to sychronize with small regionsize
+lvcreate -aey -L80 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
+grep "not in-sync" out
+
+lvconvert $vg/$lv1 # wait
+
+lvconvert -m-1 $vg/$lv1 "$dev1"
+check mirror_images_on $vg $lv1 "$dev2" "$dev4"
+lvconvert -m-1 $vg/$lv1 "$dev2"
+check linear $vg $lv1
+check lv_on $vg $lv1 "$dev4"
+lvremove -ff $vg
+
+# No parallel lvconverts on a single LV please
+# Use big enough mirror size and small regionsize to run on all test machines succesfully
+lvcreate -aey -Zn -Wn -L80 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
+check mirror $vg $lv1
+check mirror_legs $vg $lv1 2
+
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
+# ATM upconversion should be running
+
+# Next convert should fail b/c we can't have 2 at once
+not lvconvert -m+1 $vg/$lv1 "$dev5"  2>&1 | tee out
+grep "is already being converted" out
+
+lvconvert $vg/$lv1 # wait
+check mirror $vg $lv1 "$dev3"
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+lvremove -ff $vg
+
+lvs -a $vg
+dmsetup table
+losetup -a
+ls -lRa $PWD
+
+# "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
+lvcreate -aey -l "$(get pv_field "$dev1" pe_count)" --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvs -a -o+seg_pe_ranges $vg
+aux wait_for_sync $vg $lv1
+lvconvert -m0 $vg/$lv1 "$dev1"
+check linear $vg $lv1
+lvremove -ff $vg
+
 
 vgremove -ff $vg


