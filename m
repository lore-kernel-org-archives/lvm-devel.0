From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Jun 2020 17:31:34 +0000 (GMT)
Subject: master - integrity: avoid increasing logical block size of active LV
Message-ID: <20200616173134.4BA42388E813@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48872b0369af5ee048c947586d7da82d9769f5c3
Commit:        48872b0369af5ee048c947586d7da82d9769f5c3
Parent:        a014c4f3411f6b2f6c4c721a84253eed46cc3de6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 11:59:59 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 12:27:22 2020 -0500

integrity: avoid increasing logical block size of active LV

When adding integrity to an active LV, avoid choosing an
integrity block size that would result in increasing the
logical block size of the LV.
---
 lib/metadata/integrity_manip.c      | 12 +++++++++---
 test/shell/integrity-blocksize-2.sh | 39 +++++++++++++++++++------------------
 test/shell/integrity-blocksize-3.sh | 39 +++++++++++++++++++------------------
 test/shell/integrity-blocksize.sh   | 20 +++++++++++++++----
 test/shell/integrity-large.sh       |  2 +-
 5 files changed, 66 insertions(+), 46 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 790642dbb..334452711 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -278,7 +278,7 @@ int lv_remove_integrity_from_raid(struct logical_volume *lv)
 	return 1;
 }
 
-static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_volume *lv,
+static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_volume *lv, int is_active,
 				     struct integrity_settings *settings,
 				     int lbs_4k, int lbs_512, int pbs_4k, int pbs_512)
 {
@@ -375,7 +375,13 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		}
 
 		if (!settings->block_size) {
-			if (fs_block_size <= 4096)
+			if (is_active && lbs_512) {
+				/* increasing the lbs from 512 to 4k under an active LV could cause problems
+				   for an application that expects a given io size/alignment is possible. */
+				settings->block_size = 512;
+				if (fs_block_size > 512)
+					log_print("Limiting integrity block size to 512 because the LV is active.");
+			} else if (fs_block_size <= 4096)
 				settings->block_size = fs_block_size;
 			else
 				settings->block_size = 4096; /* dm-integrity max is 4096 */
@@ -602,7 +608,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 	 * integrity block size chosen based on device logical block size and
 	 * file system block size.
 	 */
-	if (!_set_integrity_block_size(cmd, lv, settings, lbs_4k, lbs_512, pbs_4k, pbs_512)) {
+	if (!_set_integrity_block_size(cmd, lv, is_active, settings, lbs_4k, lbs_512, pbs_4k, pbs_512)) {
 		if (!is_active && !deactivate_lv(cmd, lv))
 			stack;
 		goto_bad;
diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
index a7bb71f9a..5e0fd9ad1 100644
--- a/test/shell/integrity-blocksize-2.sh
+++ b/test/shell/integrity-blocksize-2.sh
@@ -81,28 +81,29 @@ umount $mnt
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
-# FIXME: the second xfs mount fails related to block size and converting active LV, bug 1847180
 # add integrity while LV is active, fs unmounted
-#lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
-#lvchange -an $vg/$lv1
-#lvchange -ay $vg/$lv1
-#mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-#echo "hello world" > $mnt/hello
-#umount $mnt
-#lvchange -an $vg
-#lvchange -ay $vg
-#lvconvert --raidintegrity y $vg/$lv1
-#_wait_recalc $vg/${lv1}_rimage_0
-#_wait_recalc $vg/${lv1}_rimage_1
-#lvs -a -o+devices $vg
-#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-#cat $mnt/hello | grep "hello world"
-#umount $mnt
-#lvchange -an $vg/$lv1
-#lvremove $vg/$lv1
+# lvconvert will use ribs 512 to avoid increasing LBS from 512 to 4k on active LV
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvchange -ay $vg
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
 
 # add integrity while LV is active, fs mounted
+# lvconvert will use ribs 512 to avoid increasing LBS from 512 to 4k on active LV
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
diff --git a/test/shell/integrity-blocksize-3.sh b/test/shell/integrity-blocksize-3.sh
index 7170aa907..4aea97253 100644
--- a/test/shell/integrity-blocksize-3.sh
+++ b/test/shell/integrity-blocksize-3.sh
@@ -236,28 +236,29 @@ umount $mnt
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
-# FIXME: second xfs mount fails related to block size and converting active LV, bug 1847180
 # add integrity while LV is active, fs unmounted
-#lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
-#lvchange -an $vg/$lv1
-#lvchange -ay $vg/$lv1
-#mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-#echo "hello world" > $mnt/hello
-#umount $mnt
-#lvchange -an $vg
-#lvchange -ay $vg
-#lvconvert --raidintegrity y $vg/$lv1
-#_wait_recalc $vg/${lv1}_rimage_0
-#_wait_recalc $vg/${lv1}_rimage_1
-#lvs -a -o+devices $vg
-#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-#cat $mnt/hello | grep "hello world"
-#umount $mnt
-#lvchange -an $vg/$lv1
-#lvremove $vg/$lv1
+# lvconvert will use ribs 512 to avoid increasing LBS from 512 to 4k on active LV
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvchange -ay $vg
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
 
 # add integrity while LV is active, fs mounted
+# lvconvert will use ribs 512 to avoid increasing LBS from 512 to 4k on active LV
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index a829502d1..eb6a364f2 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -140,7 +140,7 @@ umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
 
-# lvconvert on dev512, ext4 1024, result 1024 
+# lvconvert on dev512, ext4 1024, result 1024 (LV active when adding)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
@@ -149,6 +149,20 @@ lvconvert --raidintegrity y $vg1/$lv1
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvconvert on dev512, ext4 1024, result 1024 (LV inactive when adding)
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+lvchange -an $vg1/$lv1
+lvconvert --raidintegrity y $vg1/$lv1
+lvchange -ay $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
 lvremove -y $vg1/$lv1
 
@@ -176,15 +190,13 @@ umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
-# FIXME: if lv is active while integrity is added, then xfs mount fails related to block size, bug 1847180
 # lvconvert --bs 1024 on dev512, xfs 4096, result 1024
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
-# TODO: also test adding integrity when the lv is active,
-# and also when the lv is active and fs is mounted?
 lvchange -an $vg1/$lv1
+# lv needs to be inactive to increase LBS from 512
 lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
 lvchange -ay $vg1/$lv1
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 016d100d9..1df9e6b53 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -115,8 +115,8 @@ lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
 _add_data_to_lv
+# lv needs to be inactive when adding integrity to increase LBS from 512 and get a ribs of 4k
 lvchange -an $vg/$lv1
-# FIXME: if lv remains active during convert, then xfs mount fails related to block size, bug 1847180
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0


