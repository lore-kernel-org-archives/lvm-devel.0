From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:36 +0000 (GMT)
Subject: main - tests: convert to use ext4
Message-ID: <20230421125336.A6DFA3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e0aab74288390b633c25c1bcf3efdb127e3a364
Commit:        4e0aab74288390b633c25c1bcf3efdb127e3a364
Parent:        b2360437e027fc4735afb58d193dc53b61c592d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 13:16:36 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

tests: convert to use ext4

Convert test to use only ext4 instead of 300M demanding XFS.
Shorten  'B' files to 4K and use 4K strip size with >raid1 arrays
so we do not risk spreading of the file across stripe.

Also use easier 'aux corrupt_dev()' method to introduce a bit
corruption into a block device with integrity.

TODO: shorten _wait_recalc (should't be needed).
---
 test/shell/integrity-caching.sh    | 27 ++++++++++-----------------
 test/shell/integrity-syncaction.sh | 32 +++++++++-----------------------
 test/shell/integrity.sh            | 37 ++++++++++++++++---------------------
 3 files changed, 35 insertions(+), 61 deletions(-)

diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 23ade6838..71740dfb5 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -14,8 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which mkfs.xfs || skip
-which xfs_growfs || skip
+which mkfs.ext4 || skip
+which resize2fs || skip
 aux have_integrity 1 5 0 || skip
 # Avoid 4K ramdisk devices on older kernels
 aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
@@ -28,7 +28,7 @@ aux prepare_devs 6 80
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
@@ -78,18 +78,11 @@ _test_fs_with_read_repair() {
 
 	umount $mnt
 	lvchange -an $vg/$lv1
-
 	for dev in "$@"; do
-		xxd "$dev" > dev.txt
-		# corrupt fileB
-		sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev.txt > dev.bad
-		rm -f dev.txt
-		xxd -r dev.bad > "$dev"
-		rm -f dev.bad
+		aux corrupt_dev "$dev" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
 	done
 
 	lvchange -ay $vg/$lv1
-
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
 	cmp -b $mnt/fileA fileA
@@ -250,7 +243,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
@@ -328,7 +321,7 @@ lvchange -an $vg/$lv1
 lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_${suffix}_rimage_0
 _wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
@@ -351,7 +344,7 @@ lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_${suffix}_rimage_0
 _wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
@@ -363,7 +356,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -373,7 +366,7 @@ lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_${suffix}_rimage_0
 _wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
@@ -487,7 +480,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -I4 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index 32d7a43a5..03f0de8f4 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -14,8 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which mkfs.xfs || skip
-which xfs_growfs || skip
+which mkfs.ext4 || skip
 aux have_integrity 1 5 0 || skip
 # Avoid 4K ramdisk devices on older kernels
 aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
@@ -28,7 +27,7 @@ aux prepare_devs 3 40
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 _prepare_vg() {
@@ -40,7 +39,7 @@ _prepare_vg() {
 }
 
 _test1() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -57,12 +56,7 @@ _test1() {
 	umount $mnt
 	lvchange -an $vg/$lv1
 
-	xxd "$dev1" > dev1.txt
-	# corrupt fileB
-	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
-	rm -f dev1.txt
-	xxd -r dev1.bad > "$dev1"
-	rm -f dev1.bad
+	aux corrupt_dev "$dev1" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
 
 	lvchange -ay $vg/$lv1
 
@@ -84,7 +78,7 @@ _test1() {
 }
 
 _test2() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -102,19 +96,11 @@ _test2() {
 	lvchange -an $vg/$lv1
 
 	# corrupt fileB and fileC on dev1
-	xxd "$dev1" > dev1.txt
-	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
-	sed -e 's/4343 4343 4343 4343 4343 4343 4343 4343/4444 4444 4444 4444 4444 4444 4444 4444/' dev1.txt > dev1.bad
-	rm -f dev1.txt
-	xxd -r dev1.bad > "$dev1"
-	rm -f dev1.bad
+	aux corrupt_dev "$dev1" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
+	aux corrupt_dev "$dev1" CCCCCCCCCCCCCCCCC DDDDDDDDDDDDDDDDD
 
 	# corrupt fileA on dev2
-	xxd "$dev2" > dev2.txt
-	sed -e 's/4141 4141 4141 4141 4141 4141 4141 4141/4141 4141 4141 4141 4141 4141 4145 4141/' dev2.txt > dev2.bad
-	rm -f dev2.txt
-	xxd -r dev2.bad > "$dev2"
-	rm -f dev2.bad
+	aux corrupt_dev "$dev2" AAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAEAA
 
 	lvchange -ay $vg/$lv1
 
@@ -197,7 +183,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid5 --raidintegrity y -n $lv1 -I 4K -l 6 $vg "$dev1" "$dev2" "$dev3"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 290090e2d..96237632e 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -14,8 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which mkfs.xfs || skip
-which xfs_growfs || skip
+which mkfs.ext4 || skip
+which resize2fs || skip
 aux have_integrity 1 5 0 || skip
 # Avoid 4K ramdisk devices on older kernels
 aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
@@ -28,7 +28,7 @@ aux prepare_devs 5 64
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
@@ -45,7 +45,7 @@ _prepare_vg() {
 }
 
 _test_fs_with_read_repair() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -60,12 +60,7 @@ _test_fs_with_read_repair() {
 	lvchange -an $vg/$lv1
 
 	for dev in "$@"; do
-		xxd "$dev" > dev.txt
-		# corrupt fileB
-		sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev.txt > dev.bad
-		rm -f dev.txt
-		xxd -r dev.bad > "$dev"
-		rm -f dev.bad
+		aux corrupt_dev "$dev" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB
 	done
 
 	lvchange -ay $vg/$lv1
@@ -78,7 +73,7 @@ _test_fs_with_read_repair() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -200,7 +195,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid4 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
@@ -218,7 +213,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid5 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
@@ -236,7 +231,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid6 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
@@ -460,7 +455,7 @@ lvchange -an $vg/$lv1
 lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o name,segtype,devices,sync_percent $vg
@@ -487,7 +482,7 @@ lvchange -an $vg/$lv1
 lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o name,segtype,devices,sync_percent $vg
@@ -510,7 +505,7 @@ _wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
@@ -532,7 +527,7 @@ _wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
@@ -553,7 +548,7 @@ _wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
@@ -651,7 +646,7 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
@@ -713,7 +708,7 @@ _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-xfs_growfs $mnt
+resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt

