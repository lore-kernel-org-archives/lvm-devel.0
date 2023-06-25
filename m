From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Jun 2023 11:04:02 +0000 (GMT)
Subject: main - tests: correct checked devices
Message-ID: <20230625110402.3F41C3858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04860b63240c19065f79453bdffbb7637f2f01eb
Commit:        04860b63240c19065f79453bdffbb7637f2f01eb
Parent:        5848f75278250835dd718fbcacc167133af66b35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 25 11:52:47 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 25 13:02:36 2023 +0200

tests: correct checked devices

Fix the testing logic.
With raid5 device the layout of files on a filesystem does not define
which leg will actually contain the block we try to damage.
So test will now figure out which device has damaged block.

Use 'check' functionality and also drop unneeded random write as we
now can identify easily in other way.
---
 test/shell/integrity-syncaction.sh | 59 ++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 34 deletions(-)

diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index 0f8ce17d2..2714aede1 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -43,12 +43,6 @@ _test1() {
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
-	# we don't want fileA to be located too early in the fs,
-	# otherwise activating the LV will trigger the corruption
-	# to be found and corrected, leaving nothing for syncaction
-	# to find and correct.
-	dd if=/dev/urandom of=$mnt/rand16M bs=1M count=16
-
 	cp fileA $mnt
 	cp fileB $mnt
 	cp fileC $mnt
@@ -56,19 +50,30 @@ _test1() {
 	umount $mnt
 	lvchange -an $vg/$lv1
 
-	aux corrupt_dev "$dev1" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
+	# Corrupting raid1 is simple - 1 leg needs to be modifed
+	# For raid5 corrupted block can be places on any of its leg.
+	for i in "$@" ; do
+		aux corrupt_dev "$i" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
+	done
 
 	lvchange -ay $vg/$lv1
 
-	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-	grep 0 mismatch
+	# so without synchecking the array - integrity doesn't know yet about failure
+	check lv_field $vg/${lv1}_rimage_0 integritymismatches "0"
+	check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
+	[ $# -gt 2 ] && check lv_field $vg/${lv1}_rimage_2 integritymismatches "0"
 
 	lvchange --syncaction check $vg/$lv1
 
 	aux wait_recalc $vg/$lv1
 
-	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-	not grep 0 mismatch
+	# after synaction check - integrity should recognize faulty devices
+	baddev=0
+	for i in 0 1 2 ; do
+		[ "$i" -gt 1 ] && [ $# -lt 3 ] && continue  # only  raid5 has rimage_2
+		[ "$(get lv_field $vg/${lv1}_rimage_${i} integritymismatches)" = "0" ] || baddev=$(( baddev + 1 ))
+	done
+	[ "$baddev" -eq 1 ] || die "Unexpected number of integritymismatched devices ($baddev)!"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 	cmp -b $mnt/fileA fileA
@@ -82,12 +87,6 @@ _test2() {
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
-	# we don't want fileA to be located too early in the fs,
-	# otherwise activating the LV will trigger the corruption
-	# to be found and corrected, leaving nothing for syncaction
-	# to find and correct.
-	dd if=/dev/urandom of=$mnt/rand16M bs=1M count=16
-
 	cp fileA $mnt
 	cp fileB $mnt
 	cp fileC $mnt
@@ -104,19 +103,15 @@ _test2() {
 
 	lvchange -ay $vg/$lv1
 
-	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-	grep 0 mismatch
-	lvs -o integritymismatches $vg/${lv1}_rimage_1 |tee mismatch
-	grep 0 mismatch
+	check lv_field $vg/${lv1}_rimage_0 integritymismatches "0"
+	check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
 
 	lvchange --syncaction check $vg/$lv1
 
 	aux wait_recalc $vg/$lv1
 
-	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-	not grep 0 mismatch
-	lvs -o integritymismatches $vg/${lv1}_rimage_1 |tee mismatch
-	not grep 0 mismatch
+	not check lv_field $vg/${lv1}_rimage_0 integritymismatches "0"
+	not check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 	cmp -b $mnt/fileA fileA
@@ -130,9 +125,8 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2"
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
-_test1
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
+_test1 "$dev1"
+not check $vg/$lv1 integritymismatches "0"
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -144,8 +138,7 @@ aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
 _test2
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
+not check $vg/$lv1 integritymismatches "0"
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -157,11 +150,9 @@ aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_recalc $vg/$lv1
-_test1
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
+_test1 "$dev1" "$dev2" "$dev3"
+not check $vg/$lv1 integritymismatches "0"
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
 vgremove -ff $vg
-

