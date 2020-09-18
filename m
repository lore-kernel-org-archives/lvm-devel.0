From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 Sep 2020 15:31:13 +0000 (GMT)
Subject: master - tests: enhance low-disk-space behavior
Message-ID: <20200918153113.787BB395445A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94484762022329d7c9ff64841d26ba1cfe46409e
Commit:        94484762022329d7c9ff64841d26ba1cfe46409e
Parent:        206620018eaac4b8b771cebfe9707022864bb53b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:32:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:30:45 2020 +0200

tests: enhance low-disk-space behavior

Use new SKIP_WITH_LOW_SPACE and set higher requirement for free space.

But still this test can't run on system's tmpfs directories -
as they typically provide less then 2G of space and when the test
runs there it also provisioning for all READ pages!)
BRD (ramdisk) device should work.

Extend a _wait_recalc() loop for slower hw.
When creating large raid which do not need to be fully synchronized use
them on delay devices - so even less data needs read/write.
Remove unneeded lvchange as lvcreate is already leaving LV inactive.
Replace printf with awk as generator.

mm
---
 test/shell/integrity-large.sh | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 7d252590e..16e28fb9d 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -13,6 +13,7 @@
 # Test writecache usage
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LOW_SPACE=1100
 
 . lib/inittest
 
@@ -25,9 +26,24 @@ mkdir -p $mnt
 # raid1 LV needs to be extended to 512MB to test imeta being exended
 aux prepare_devs 4 632
 
-printf "%0.sA" {1..16384} >> fileA
-printf "%0.sB" {1..16384} >> fileB
-printf "%0.sC" {1..16384} >> fileC
+# this test may consume lot of disk space - so make sure cleaning works
+# also in failure case
+cleanup_mounted_and_teardown()
+{
+	umount "$mnt" 2>/dev/null || true
+	# Comment out this 'vgremove' when there is any need to analyze
+	# content of the failed test dir, otherwise all is deleted.
+	vgremove -ff $vg || true
+	aux teardown
+}
+
+trap 'cleanup_mounted_and_teardown' EXIT
+
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
@@ -84,7 +100,7 @@ _sync_percent() {
 _wait_recalc() {
 	local checklv=$1
 
-	for i in $(seq 1 10) ; do
+	for i in $(seq 1 20) ; do
 		sync=$(_sync_percent "$checklv")
 		echo "sync_percent is $sync"
 
@@ -159,10 +175,15 @@ check lv_field $vg/${lv1}_rimage_1_imeta size "20.00m"
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
+# As the test doesn't wait for full resync
+# delay legs so not all data need to be written.
+aux delay_dev "$dev1" 1000 0 "$(( $(get first_extent_sector "$dev1") + 16000 )):1200000"
+aux delay_dev "$dev2" 0 10 "$(( $(get first_extent_sector "$dev2") + 16000 )):1200000"
+
+
 # this succeeds because dev1,dev2 can hold rmeta+rimage
 lvcreate --type raid1 -n $lv1 -L 592M -an $vg "$dev1" "$dev2"
 lvs -a -o+devices $vg
-lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
 # this fails because dev1,dev2 can hold rmeta+rimage, but not imeta
@@ -185,4 +206,3 @@ lvcreate --type raid1 --raidintegrity y -n $lv1 -L 640M -an $vg
 lvs -a -o+devices $vg
 
 vgremove -ff $vg
-


