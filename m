From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:06 +0000 (GMT)
Subject: main - tests: cache use 300M XFS
Message-ID: <20220907130506.B0572385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19db3b3e456010fe8e2e3815bf12deba690c7303
Commit:        19db3b3e456010fe8e2e3815bf12deba690c7303
Parent:        e295610d42904e41f295e58b02e0c0577c26c702
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 7 01:02:29 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: cache use 300M XFS

---
 test/shell/cache-single-options.sh |  4 ++--
 test/shell/cache-single-split.sh   | 16 ++++++++--------
 test/shell/cache-single-types.sh   |  6 +++---
 test/shell/cache-single-usage.sh   |  4 ++--
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 3be88d222..c736e5220 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -25,11 +25,11 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 5 64
+aux prepare_devs 5 310
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 lvcreate -n $lv3 -l 4 -an $vg "$dev3"
 lvcreate -n $lv4 -l 4 -an $vg "$dev4"
diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index ffe4292de..fa4c3fd9d 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -59,11 +59,11 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 4
+aux prepare_devs 4 310
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 #
@@ -227,7 +227,7 @@ vgextend --restoremissing $vg "$dev2"
 #
 
 lvremove $vg/$lv2
-lvcreate -n $lv2 -l 14 -an $vg "$dev2" "$dev3"
+lvcreate -n $lv2 -l 14 -an $vg "$dev2:0-10" "$dev3"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
 
@@ -263,7 +263,7 @@ mount_umount $lv1
 #
 
 lvremove $vg/$lv2
-lvcreate -n $lv2 -l 14 -an $vg "$dev2" "$dev3"
+lvcreate -n $lv2 -l 14 -an $vg "$dev2:0-10" "$dev3"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
 
@@ -301,7 +301,7 @@ vgextend --restoremissing $vg "$dev3"
 lvremove $vg/$lv1
 lvremove $vg/$lv2
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1:0-10" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
@@ -330,7 +330,7 @@ mount_umount $lv1
 
 lvremove $vg/$lv1
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1:0-10" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
@@ -364,7 +364,7 @@ mount_umount $lv1
 
 lvremove $vg/$lv1
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1:0-10" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
@@ -395,7 +395,7 @@ mount_umount $lv1
 
 lvremove $vg/$lv1
 
-lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1:0-10" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index 85582420d..1e67e7eda 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -26,11 +26,11 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 4 64
+aux prepare_devs 4 310
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-lvcreate --type raid1 -m 1 -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -n $lv1 -L 300 --nosync $vg "$dev1" "$dev2"
 
 lvcreate --type raid1 -m 1 -n $lv2 -l 4 $vg "$dev3" "$dev4"
 
@@ -69,7 +69,7 @@ lvchange -an $vg/$lv1
 lvconvert --splitcache $vg/$lv1
 
 check lv_field $vg/$lv1 segtype raid1
-check lv_field $vg/$lv2 segtype raid1 
+check lv_field $vg/$lv2 segtype raid1
 
 lvchange -ay $vg/$lv1
 lvchange -ay $vg/$lv2
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 9bc9b67c5..2c47d05e0 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -28,13 +28,13 @@ mkdir -p "$mount_dir"
 # generate random data
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
-aux prepare_devs 2 64
+aux prepare_devs 2 310
 
 vgcreate $SHARED $vg "$dev1"
 
 vgextend $vg "$dev2"
 
-lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv1 -L 300 -an $vg "$dev1"
 
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 

