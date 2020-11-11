From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Nov 2020 21:29:49 +0000 (GMT)
Subject: main - tests: integrity mismatch checks for all raid levels
Message-ID: <20201111212949.106B73857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cc75317f95def9521af535f4c58fb79df816b8c
Commit:        1cc75317f95def9521af535f4c58fb79df816b8c
Parent:        5fef89361d45797d2e478419caff4528b5ac6150
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 11 15:13:46 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 11 15:13:46 2020 -0600

tests: integrity mismatch checks for all raid levels

Verify that corruption is corrected for raid levels other
than raid1.  For other raid levels, attempt to corrupt the
given file pattern on each underlying device, since we don't
know which device contains the file being corrupted.
This ensures that corruption is actually be introduced
when testing the other raid levels.

Verify that corruption is being corrected by checking
the integritymismatches count is non-zero for the raid LV,
which includes the total from all images (since we don't
know which image will have the corruption.)
---
 test/shell/integrity-syncaction.sh |  6 ++++
 test/shell/integrity.sh            | 56 ++++++++++++++++++++++++--------------
 2 files changed, 41 insertions(+), 21 deletions(-)

diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index d26855665..a1d96fb0e 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -176,6 +176,8 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
 _test1
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -187,6 +189,8 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
 _test2
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -199,6 +203,8 @@ _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/$lv1
 _test1
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index e17862595..ffac50902 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -61,20 +61,18 @@ _test_fs_with_read_repair() {
 	umount $mnt
 	lvchange -an $vg/$lv1
 
-	xxd "$dev1" > dev1.txt
-	# corrupt fileB
-	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
-	rm -f dev1.txt
-	xxd -r dev1.bad > "$dev1"
-	rm -f dev1.bad
+	for dev in "$@"; do
+		xxd "$dev" > dev.txt
+		# corrupt fileB
+		sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev.txt > dev.bad
+		rm -f dev.txt
+		xxd -r dev.bad > "$dev"
+		rm -f dev.bad
+	done
 
 	lvchange -ay $vg/$lv1
 
-	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-	grep 0 mismatch
-
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-
 	cmp -b $mnt/fileA fileA
 	cmp -b $mnt/fileB fileB
 	cmp -b $mnt/fileC fileC
@@ -174,9 +172,11 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -188,9 +188,11 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev2"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -202,10 +204,12 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -217,10 +221,12 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -234,12 +240,14 @@ _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvs -o integritymismatches $vg/${lv1}_rimage_3
 lvs -o integritymismatches $vg/${lv1}_rimage_4
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -252,11 +260,13 @@ _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvs -o integritymismatches $vg/${lv1}_rimage_3
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -611,32 +621,36 @@ vgremove -ff $vg
 # Repeat many of the tests above using bitmap mode
 
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1 "$dev2"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
 _wait_recalc $vg/$lv1
-_test_fs_with_read_repair
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvs -o integritymismatches $vg/${lv1}_rimage_3
 lvs -o integritymismatches $vg/${lv1}_rimage_4
+lvs -o integritymismatches $vg/$lv1 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -644,7 +658,7 @@ vgremove -ff $vg
 
 # remove from active lv
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _add_new_data_to_mnt


