From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Sep 2022 12:59:03 +0000 (GMT)
Subject: main - tests: integrity switch to ext4
Message-ID: <20220921125903.610D7385742E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bf1aca544e6d422d34aea356e69d6dbf0bdf3ba
Commit:        1bf1aca544e6d422d34aea356e69d6dbf0bdf3ba
Parent:        9c2ed7422105c59446c4d8a894c87feb37c5de7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 13:33:28 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 14:58:34 2022 +0200

tests: integrity switch to ext4

Since we would need to create a lot of 300M filesystem,
switch this test suite to ext4.
---
 test/shell/integrity-blocksize-2.sh |  7 +++----
 test/shell/integrity-blocksize-3.sh | 20 +++++++++-----------
 test/shell/integrity-dmeventd.sh    |  5 ++---
 3 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
index ae0e72ec6..b2e0fb06e 100644
--- a/test/shell/integrity-blocksize-2.sh
+++ b/test/shell/integrity-blocksize-2.sh
@@ -67,7 +67,7 @@ blockdev --getpbsz "$dev2"
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -88,7 +88,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -109,7 +109,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
@@ -127,4 +127,3 @@ lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
 vgremove -ff $vg
-
diff --git a/test/shell/integrity-blocksize-3.sh b/test/shell/integrity-blocksize-3.sh
index 7034bc362..300cc1895 100644
--- a/test/shell/integrity-blocksize-3.sh
+++ b/test/shell/integrity-blocksize-3.sh
@@ -66,7 +66,7 @@ blockdev --getpbsz "$dev2"
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -86,7 +86,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -106,7 +106,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
@@ -143,7 +143,7 @@ blockdev --getpbsz "$dev2"
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -163,7 +163,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -183,7 +183,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
@@ -220,7 +220,7 @@ blockdev --getpbsz "$dev2"
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -241,7 +241,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 umount $mnt
@@ -262,7 +262,7 @@ lvremove $vg/$lv1
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
@@ -281,5 +281,3 @@ lvremove $vg/$lv1
 
 vgremove -ff $vg
 aux cleanup_scsi_debug_dev
-sleep 1
-
diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 9049eb0f7..44121a186 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -14,7 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-which mkfs.xfs || skip
+which mkfs.ext4 || skip
 aux have_integrity 1 5 0 || skip
 # Avoid 4K ramdisk devices on older kernels
 aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
@@ -41,7 +41,7 @@ _prepare_vg() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
         mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -294,4 +294,3 @@ lvchange -an $vg/$lv1
 _verify_data_on_lv
 lvremove $vg/$lv1
 vgremove -ff $vg
-

