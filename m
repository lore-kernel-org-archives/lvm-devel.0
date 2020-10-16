From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:29 +0000 (GMT)
Subject: stable-2.02 - tests: improve cache abort test
Message-ID: <20201016191129.43431396EC82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1f7c531eb20e580d02fc0950d12df34cb2fc51b
Commit:        d1f7c531eb20e580d02fc0950d12df34cb2fc51b
Parent:        4ebc8875d3f09cd446d1001361dc81af4cb8ded3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 13 11:33:13 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: improve cache abort test

Use bigger volume and slowdown writing to cache device.
This allows more simple to reach 'dirty' state.
Also document exactly 1 SIGINT has to fire aborting of flushing.
---
 test/shell/lvconvert-cache-abort.sh | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 404f44269..652c9f421 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -21,24 +21,28 @@ aux have_cache 1 3 0 || skip
 
 aux prepare_vg 2
 
+SIZE_MB=4
+
 # Data device on later delayed dev1
 lvcreate -L4 -n cpool $vg "$dev1"
 lvconvert -y --type cache-pool $vg/cpool "$dev2"
-lvcreate -H -L 4 -n $lv1 --chunksize 32k --cachemode writeback --cachepool $vg/cpool $vg "$dev2"
+lvcreate -H -L $SIZE_MB -n $lv1 --chunksize 32k --cachemode writeback --cachepool $vg/cpool $vg "$dev2"
 
 #
 # Ensure cache gets promoted blocks
 #
-for i in $(seq 1 10) ; do
+for i in $(seq 1 3) ; do
 echo 3 >/proc/sys/vm/drop_caches
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=64K count=20 conv=fdatasync || true
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=$SIZE_MB conv=fdatasync || true
 echo 3 >/proc/sys/vm/drop_caches
-dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=64K count=20 || true
+dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=1M count=$SIZE_MB || true
 done
 
+aux delay_dev "$dev2" 0 300 "$(get first_extent_sector "$dev2"):"
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=$SIZE_MB
 
+lvdisplay --maps $vg
 # Delay dev to ensure we have some time to 'capture' interrupt in flush
-aux delay_dev "$dev1" 100 0 "$(get first_extent_sector "$dev1"):"
 
 # TODO, how to make writeback cache dirty
 test "$(get lv_field $vg/$lv1 cache_dirty_blocks)" -gt 0 || {
@@ -46,9 +50,6 @@ test "$(get lv_field $vg/$lv1 cache_dirty_blocks)" -gt 0 || {
 	skip "Cannot make a dirty writeback cache LV."
 }
 
-sync
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
-
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >logconvert 2>&1 &
 PID_CONVERT=$!
 for i in {1..50}; do
@@ -57,10 +58,16 @@ for i in {1..50}; do
 	echo "Waiting for cleaner policy on $vg/$lv1"
 	sleep .05
 done
+
+# While lvconvert updated table to 'cleaner' policy now it 
+# should be running in 'Flushing' loop and just 1 KILL should
+# cause abortion of flushing
 kill -INT $PID_CONVERT
-aux enable_dev "$dev1"
+aux enable_dev "$dev2"
 wait
 
+#cat logconvert || true
+
 grep -E "Flushing.*aborted" logconvert || {
 	cat logconvert || true
 	vgremove -f $vg


