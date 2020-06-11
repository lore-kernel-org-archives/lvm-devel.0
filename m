From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jun 2020 18:06:41 +0000 (GMT)
Subject: master - tests: expand integrity-blocksize
Message-ID: <20200611180641.120E6383F859@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f32e85ae519d9c278d7e76329438f976e91ac317
Commit:        f32e85ae519d9c278d7e76329438f976e91ac317
Parent:        b528a9ce9060ed8d66466f7df86c0eafa7c94ec8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 12:46:47 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 11 12:46:47 2020 -0500

tests: expand integrity-blocksize

---
 test/shell/integrity-blocksize.sh | 82 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 76 insertions(+), 6 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 444e3db4c..8c4b94d49 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -48,6 +48,9 @@ aux extend_filter "a|$LOOP4|"
 
 aux lvmconf 'devices/scan = "/dev"'
 
+mnt="mnt"
+mkdir -p $mnt
+
 vgcreate $vg1 $LOOP1 $LOOP2
 vgcreate $vg2 $LOOP3 $LOOP4
 
@@ -105,7 +108,11 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 lvconvert --raidintegrity y $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
@@ -113,7 +120,11 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
 
@@ -121,7 +132,11 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
 lvremove -y $vg1/$lv1
 
@@ -129,7 +144,11 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvremove -y $vg2/$lv1
 
@@ -137,23 +156,36 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
+# FIXME: kernel error reported, disallow this combination?
 # lvconvert --bs 1024 on dev512, xfs 4096, result 1024
-lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-aux wipefs_a /dev/$vg1/$lv1
-mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
-pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
-lvremove -y $vg1/$lv1
+#lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+#aux wipefs_a /dev/$vg1/$lv1
+#mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+#blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+#lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
+#blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+#mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+#umount $mnt
+#pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+#lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev512, ext4 1024, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
@@ -169,6 +201,44 @@ lvremove -y $vg2/$lv1
 # FIXME: lvconvert --bs 512, fsunknown, LBS 512, PBS 4k: result 512
 # FIXME: lvconvert --bs 4k, fsunknown, LBS 512, PBS 4k: result 4k
 
+# lvconvert on dev512, xfs 512, result 512, (detect fs with LV inactive)
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+echo "test" > $mnt/test
+umount $mnt
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+lvchange -an $vg1/$lv1
+lvconvert --raidintegrity y $vg1/$lv1
+lvchange -ay $vg1/$lv1
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+cat $mnt/test
+umount $mnt
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvchange -an $vg1/$lv1
+lvremove -y $vg1/$lv1
+
+# lvconvert on dev4k, xfs 4096, result 4096 (detect fs with LV inactive)
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+aux wipefs_a /dev/$vg2/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
+mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
+echo "test" > $mnt/test
+umount $mnt
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+lvchange -an $vg2/$lv1
+lvconvert --raidintegrity y $vg2/$lv1
+lvchange -ay $vg2/$lv1
+mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
+cat $mnt/test
+umount $mnt
+blkid "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+lvchange -an $vg2/$lv1
+lvremove -y $vg2/$lv1
+
 vgremove -ff $vg1
 vgremove -ff $vg2
 


