From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:42 +0000 (GMT)
Subject: main - tests: added check for kernel version
Message-ID: <20210317000042.6A24F386185F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53bad89a7b802890067e1c006775345098cfa4dc
Commit:        53bad89a7b802890067e1c006775345098cfa4dc
Parent:        8b2cdd8d3a8ad0b3048f38580a0dc20f6e1e492d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 20:54:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: added check for kernel version

With older kernels this test can't work reliable,
since 'suspend' used to clean all dirty blocks
(taking even several seconds).
---
 test/shell/lvconvert-cache-abort.sh | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 652c9f421..ecb0ff44d 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -50,14 +50,15 @@ test "$(get lv_field $vg/$lv1 cache_dirty_blocks)" -gt 0 || {
 	skip "Cannot make a dirty writeback cache LV."
 }
 
-LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >logconvert 2>&1 &
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -vvvv --splitcache $vg/$lv1 >logconvert 2>&1 &
 PID_CONVERT=$!
 for i in {1..50}; do
-	dmsetup table "$vg-$lv1" | grep cleaner && break
-	test "$i" -ge 100 && die "Waited for cleaner policy on $vg/$lv1 too long!"
-	echo "Waiting for cleaner policy on $vg/$lv1"
+	dmsetup table "$vg-$lv1" |& tee out
+	grep cleaner out && break
+	echo "$i: Waiting for cleaner policy on $vg/$lv1"
 	sleep .05
 done
+test "$i" -ge 49 && die "Waited for cleaner policy on $vg/$lv1 too long!"
 
 # While lvconvert updated table to 'cleaner' policy now it 
 # should be running in 'Flushing' loop and just 1 KILL should
@@ -68,9 +69,16 @@ wait
 
 #cat logconvert || true
 
+# Problem of this test is, in older kernels, even the initial change to cleaner
+# policy table line causes long suspend which in practice is cleaning all the
+# dirty blocks - so the test can't really break the cache clearing.
+#
+# So the failure of test is reported only for recent kernels > 5.6
+# ans skipped otherwise - as those can't be fixed anyway
 grep -E "Flushing.*aborted" logconvert || {
 	cat logconvert || true
 	vgremove -f $vg
+	aux kernel_at_least 5 6 || skip "Cache missed to abort flushing with older kernel"
 	die "Flushing of $vg/$lv1 not aborted ?"
 }
 


