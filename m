From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:35 -0400
Subject: master - tests: happy using of 4K backend devices
Message-ID: <201805121625.w4CGPZs0007776@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f48741062710fec2eb5c58dd8d4364194bdbf44
Commit:        6f48741062710fec2eb5c58dd8d4364194bdbf44
Parent:        e2be14e2d5fc3136257034a8bc194d2127a7c2d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 15:58:13 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: happy using of 4K backend devices

When the backend device supports only 4K blocks (like ramdisk)
we cannot use for testing any smaller blocksize.

So recalc test for 4K extent size.

We may possibly introduce one list extra test that
can be executed on devices with 512b sectors to
check lvm2 support those min extent sizes...
---
 test/shell/lvconvert-snapshot.sh  |    2 +-
 test/shell/lvcreate-small-snap.sh |   12 ++++++------
 test/shell/snapshot-maxsize.sh    |    2 +-
 test/shell/snapshot-usage.sh      |   24 ++++++++++++------------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index f18115d..9a32776 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -20,7 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2
 get_devs
 
-vgcreate -s 1k "$vg" "${DEVICES[@]}"
+vgcreate -s 4k "$vg" "${DEVICES[@]}"
 
 lvcreate --type snapshot -V50 -L1 -n $lv1 -s $vg
 
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index 00ea0a0..08872fd 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -18,20 +18,20 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs
 get_devs
 
-vgcreate -s 1k "$vg" "${DEVICES[@]}"
+vgcreate -s 4k "$vg" "${DEVICES[@]}"
 
 # 3 Chunks
 lvcreate -aey -n one -l 10 $vg
-lvcreate -s -l 12 -n snapA $vg/one
-lvcreate -s -c 4k -l 12 -n snapX1 $vg/one
-lvcreate -s -c 8k -l 24 -n snapX2 $vg/one
+lvcreate -s -l 3 -n snapA $vg/one
+lvcreate -s -c 4k -l 3 -n snapX1 $vg/one
+lvcreate -s -c 8k -l 6 -n snapX2 $vg/one
 
 # Check that snapshots that are too small are caught with correct error.
-not lvcreate -s -c 8k -l 8 -n snapX3 $vg/one 2>&1 | tee lvcreate.out
+not lvcreate -s -c 8k -l 2 -n snapX3 $vg/one 2>&1 | tee lvcreate.out
 not grep "suspend origin one" lvcreate.out
 grep "smaller" lvcreate.out
 
-not lvcreate -s -l 4 -n snapB $vg/one 2>&1 | tee lvcreate.out
+not lvcreate -s -l 1 -n snapB $vg/one 2>&1 | tee lvcreate.out
 not grep "suspend origin one" lvcreate.out
 grep "smaller" lvcreate.out
 
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 9d8305c..9a1f4d7 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 1
 get_devs
 
-vgcreate -s 1K "$vg" "${DEVICES[@]}"
+vgcreate -s 4K "$vg" "${DEVICES[@]}"
 
 lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 14f74a1..307ab5f 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -27,7 +27,7 @@ fill() {
 
 cleanup_tail()
 {
-	test -z "$SLEEP_PID" || kill $SLEEP_PID || true
+	test -z "${SLEEP_PID-}" || kill $SLEEP_PID || true
 	wait
 	vgremove -ff $vg1 || true
 	vgremove -ff $vg
@@ -83,8 +83,7 @@ aux lvmconf "activation/snapshot_autoextend_percent = 20" \
 # Check usability with smallest (1k) extent size ($lv has 15P)
 pvcreate --yes --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
 trap 'cleanup_tail' EXIT
-vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
-
+vgcreate -s 4K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 # Play with small 1k 128 extents
 lvcreate -aey -L128K -n $lv $vg1
@@ -135,29 +134,30 @@ check lv_not_exists $vg1 $lv1
 # Check border size
 lvcreate -aey -L4095G $vg1
 lvcreate -s -L100K $vg1/lvol0
-fill 1K
+fill 4K
 check lv_field $vg1/lvol1 data_percent "12.00"
 
 lvremove -ff $vg1
 
-# Create 1KB snapshot, does not need to be active here
+# Create 4KB snapshot, does not need to be active here
 lvcreate -an -Zn -l1 -n $lv1 $vg1
 not lvcreate -s -l1 $vg1/$lv1
-not lvcreate -s -l3 $vg1/$lv1
+# snapshot cannot be smaller then 3 chunks (12K)
+not lvcreate -s -l2 $vg1/$lv1
 lvcreate -s -l30 -n $lv2 $vg1/$lv1
 check lv_field $vg1/$lv2 size "$EXPECT1"
 
-not lvcreate -s -c512 -l512 $vg1/$lv1
+not lvcreate -s -c512 -l128 $vg1/$lv1
 lvcreate -s -c128 -l1700 -n $lv3 $vg1/$lv1
 # 3 * 128
 check lv_field $vg1/$lv3 size "$EXPECT2"
 lvremove -ff $vg1
 
-lvcreate -aey -l20 $vg1
-lvcreate -s -l12 $vg1/lvol0
+lvcreate -aey -l5 $vg1
+lvcreate -s -l3 $vg1/lvol0
 
-# Fill 1KB -> 100% snapshot (1x 4KB chunk)
-fill 1K
+# Fill 4KB -> 100% snapshot (1x 4KB chunk)
+fill 4K
 check lv_field $vg1/lvol1 data_percent "100.00"
 
 # Check it resizes 100% full valid snapshot to fit threshold
@@ -168,7 +168,7 @@ fill 4K
 lvextend --use-policies $vg1/lvol1
 check lv_field $vg1/lvol1 size "24.00k"
 
-lvextend -l+33 $vg1/lvol1
+lvextend -l+8 $vg1/lvol1
 check lv_field $vg1/lvol1 size "$EXPECT3"
 
 fill 20K


