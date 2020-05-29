From: David Teigland <teigland@sourceware.org>
Date: Fri, 29 May 2020 16:01:06 +0000 (GMT)
Subject: master - tests: integrity wait for sync
Message-ID: <20200529160106.19FE23894417@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b04ed07ba2e68f527ebb4f8d2b2bd092692f2d2
Commit:        7b04ed07ba2e68f527ebb4f8d2b2bd092692f2d2
Parent:        5410dd5441aa827b381ff64dfc6be6e4589d87a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 29 10:57:56 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 29 10:57:56 2020 -0500

tests: integrity wait for sync

The test was using a raid+integrity LV without
first waiting for the integrity sync, which could
cause the test to fail (depending on init speed)
where it depends on integrity to work in uninitialized
areas.

Also use cmp instead of diff.
---
 test/shell/integrity.sh | 46 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 77e9430fe..0143129e6 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -78,14 +78,14 @@ _test_fs_with_error() {
 	dd if=$mnt/fileA of=tmp bs=1k
 	ls -l tmp
 	stat -c %s tmp
-	diff fileA tmp
+	cmp -b fileA tmp
 	rm tmp
 
 	# read partial fileB which was corrupted
 	not dd if=$mnt/fileB of=tmp bs=1k
 	ls -l tmp
 	stat -c %s tmp | grep 12288
-	not diff fileB tmp
+	not cmp -b fileB tmp
 	rm tmp
 
 	umount $mnt
@@ -118,14 +118,14 @@ _test_fs_with_raid() {
 	dd if=$mnt/fileA of=tmp bs=1k
 	ls -l tmp
 	stat -c %s tmp | grep 16384
-	diff fileA tmp
+	cmp -b fileA tmp
 	rm tmp
 
 	# read complete fileB, corruption is corrected by raid
 	dd if=$mnt/fileB of=tmp bs=1k
 	ls -l tmp
 	stat -c %s tmp | grep 16384
-	diff fileB tmp
+	cmp -b fileB tmp
 	rm tmp
 
 	umount $mnt
@@ -161,15 +161,15 @@ _add_more_data_to_mnt() {
 }
 
 _verify_data_on_mnt() {
-	diff randA $mnt/randA
-	diff randB $mnt/randB
-	diff randC $mnt/randC
-	diff fileA $mnt/1/fileA
-	diff fileB $mnt/1/fileB
-	diff fileC $mnt/1/fileC
-	diff fileA $mnt/2/fileA
-	diff fileB $mnt/2/fileB
-	diff fileC $mnt/2/fileC
+	cmp -b randA $mnt/randA
+	cmp -b randB $mnt/randB
+	cmp -b randC $mnt/randC
+	cmp -b fileA $mnt/1/fileA
+	cmp -b fileB $mnt/1/fileB
+	cmp -b fileC $mnt/1/fileC
+	cmp -b fileA $mnt/2/fileA
+	cmp -b fileB $mnt/2/fileB
+	cmp -b fileC $mnt/2/fileC
 }
 
 _verify_data_on_lv() {
@@ -221,6 +221,8 @@ _wait_recalc() {
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
@@ -229,6 +231,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
@@ -237,6 +242,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
@@ -245,6 +253,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
@@ -253,6 +264,11 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
@@ -261,6 +277,10 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
 _test_fs_with_raid
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1


