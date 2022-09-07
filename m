From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:59 +0000 (GMT)
Subject: main - tests: lvextend update for 300M XFS
Message-ID: <20220907130459.A6188385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a3e773f37483b30f1bd1c1406ffc2f0b1e00631
Commit:        1a3e773f37483b30f1bd1c1406ffc2f0b1e00631
Parent:        afcf954491416dab5845d25dc45c53c3e8000773
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 14:30:01 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: lvextend update for 300M XFS

---
 test/shell/lvextend-caches-on-thindata.sh | 12 ++++++------
 test/shell/lvextend-caches.sh             | 12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvextend-caches-on-thindata.sh b/test/shell/lvextend-caches-on-thindata.sh
index ef47d76d0..35b70546f 100644
--- a/test/shell/lvextend-caches-on-thindata.sh
+++ b/test/shell/lvextend-caches-on-thindata.sh
@@ -116,11 +116,11 @@ which mkfs.xfs || skip
 mount_dir="mnt"
 mkdir -p "$mount_dir"
 
-aux prepare_devs 6 70 # want 64M of usable space from each dev
+aux prepare_devs 6 400 # want 400M of usable space from each dev
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 vgcreate $vg "$dev1"
-lvcreate -n $lv1 -L50 $vg
+lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
@@ -141,7 +141,7 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 # lv3 is thin LV:       1G
 
 # attach writecache to thinpool data
-lvcreate --type thin-pool -n $lv1 -L128M --poolmetadataspare n $vg "$dev1" "$dev2"
+lvcreate --type thin-pool -n $lv1 -L228M --poolmetadataspare n $vg "$dev1" "$dev2"
 lvcreate --type thin -n $lv3 -V1G --thinpool $lv1 $vg
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
@@ -149,7 +149,7 @@ lvs -a $vg -o+devices
 do_test $lv1 $lv3
 
 # attach cache/writeback (cachevol) to thinpool data
-lvcreate --type thin-pool -n $lv1 -L128M --poolmetadataspare n $vg "$dev1" "$dev2"
+lvcreate --type thin-pool -n $lv1 -L228M --poolmetadataspare n $vg "$dev1" "$dev2"
 lvcreate --type thin -n $lv3 -V1G --thinpool $lv1 $vg
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
@@ -157,7 +157,7 @@ lvs -a $vg -o+devices
 do_test $lv1 $lv3
 
 # attach cache/writethrough (cachevol) to thinpool data
-lvcreate --type thin-pool -n $lv1 -L128M --poolmetadataspare n $vg "$dev1" "$dev2"
+lvcreate --type thin-pool -n $lv1 -L228M --poolmetadataspare n $vg "$dev1" "$dev2"
 lvcreate --type thin -n $lv3 -V1G --thinpool $lv1 $vg
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
@@ -165,7 +165,7 @@ lvs -a $vg -o+devices
 do_test $lv1 $lv3
 
 # attach cache (cachepool) to thinpool data
-lvcreate --type thin-pool -n $lv1 -L128M --poolmetadataspare n $vg "$dev1" "$dev2"
+lvcreate --type thin-pool -n $lv1 -L228M --poolmetadataspare n $vg "$dev1" "$dev2"
 lvcreate --type thin -n $lv3 -V1G --thinpool $lv1 $vg
 lvcreate -y --type cache-pool -n $lv2 -L64M --poolmetadataspare n $vg "$dev3" "$dev6"
 lvconvert -y --type cache --cachepool $lv2 --poolmetadataspare n $vg/$lv1
diff --git a/test/shell/lvextend-caches.sh b/test/shell/lvextend-caches.sh
index de9af6d2c..f2768903f 100644
--- a/test/shell/lvextend-caches.sh
+++ b/test/shell/lvextend-caches.sh
@@ -108,7 +108,7 @@ which mkfs.xfs || skip
 mount_dir="mnt"
 mkdir -p "$mount_dir"
 
-aux prepare_devs 6 66 # want 64M of usable space from each dev
+aux prepare_devs 6 200 # want 200M of usable space from each dev
 
 # generate random data
 dd if=/dev/urandom of=pattern bs=512K count=1
@@ -119,28 +119,28 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 # cache with cachepool|cachevol
 # cache with writeback|writethrough
 
-# lv1 is main LV: 128M
+# lv1 is main LV: 300M
 # lv2 is fast LV:  64M
 
-lvcreate -n $lv1 -L128M -an $vg "$dev1" "$dev2"
+lvcreate -n $lv1 -L300M -an $vg "$dev1" "$dev2"
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 lvs -a $vg -o+devices
 do_test
 
-lvcreate -n $lv1 -L128M -an $vg "$dev1" "$dev2"
+lvcreate -n $lv1 -L300M -an $vg "$dev1" "$dev2"
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
 lvs -a $vg -o+devices
 do_test
 
-lvcreate -n $lv1 -L128M -an $vg "$dev1" "$dev2"
+lvcreate -n $lv1 -L300M -an $vg "$dev1" "$dev2"
 lvcreate -n $lv2 -L64M -an $vg "$dev3"
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
 lvs -a $vg -o+devices
 do_test
 
-lvcreate -n $lv1 -L128M -an $vg "$dev1" "$dev2"
+lvcreate -n $lv1 -L300M -an $vg "$dev1" "$dev2"
 lvcreate -y --type cache-pool -n $lv2 -L64M --poolmetadataspare n $vg "$dev3" "$dev6"
 lvconvert -y --type cache --cachepool $lv2 --poolmetadataspare n $vg/$lv1
 lvs -a $vg -o+devices

