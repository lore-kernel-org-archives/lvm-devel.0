From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 15:12:59 -0400
Subject: master - tests: delay read of cache pool data
Message-ID: <201707131912.v6DJCx9A013578@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e88534b680f52a98e72b43f5b6c1d65f158e5680
Commit:        e88534b680f52a98e72b43f5b6c1d65f158e5680
Parent:        490e6e9ef1bbc30dff81873e9eeb99924688004e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 13 21:08:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 13 21:11:16 2017 +0200

tests: delay read of cache pool data

It's better to delay read of cached data.
Limit loop checking for cleaner policy.
---
 test/shell/lvconvert-cache-abort.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 468f8aa..701a41d 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -38,7 +38,7 @@ done
 
 
 # Delay dev to ensure we have some time to 'capture' interrupt in flush
-aux delay_dev "$dev1" 0 500 "$(get first_extent_sector "$dev1"):"
+aux delay_dev "$dev1" 100 0 "$(get first_extent_sector "$dev1"):"
 
 lvdisplay --maps $vg
 sync
@@ -46,7 +46,9 @@ dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
 
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >logconvert 2>&1 &
 PID_CONVERT=$!
-while ! (dmsetup table $vg-$lv1 | grep cleaner) ; do
+for i in {1..50}; do
+	dmsetup table "$vg-$lv1" | grep cleaner && break
+	test "$i" -ge 100 && die "Waited for cleaner policy on $vg/$lv1 too long!"
 	echo "Waiting for cleaner policy on $vg/$lv1"
 	sleep .05
 done
@@ -56,6 +58,7 @@ wait
 
 grep -E "Flushing.*aborted" logconvert || {
 	cat logconvert || true
+	vgremove -f $vg
 	die "Flushing of $vg/$lv1 not aborted ?"
 }
 


