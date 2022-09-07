From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:03 +0000 (GMT)
Subject: main - tests: use conv=fdatasync
Message-ID: <20220907130503.16BFD3858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6990cbc16659aa8b81cb0cd40728cebe8d1d4839
Commit:        6990cbc16659aa8b81cb0cd40728cebe8d1d4839
Parent:        9f3997734480deaae8cb195c4c30bff1e2cfc463
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 18:47:03 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: use conv=fdatasync

When we only need wait for result - avoid using slow 'oflag=sync'
with virtual layers
---
 test/shell/integrity-blocksize.sh |  8 ++++----
 test/shell/writecache-large.sh    | 10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index bf8def4ac..4e47ce427 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -53,10 +53,10 @@ trap 'cleanup_mounted_and_teardown' EXIT
 #truncate -s 64M loopc
 #truncate -s 64M loopd
 
-dd if=/dev/zero of=loopa bs=1M count=64 oflag=sync
-dd if=/dev/zero of=loopb bs=1M count=64 oflag=sync
-dd if=/dev/zero of=loopc bs=1M count=64 oflag=sync
-dd if=/dev/zero of=loopd bs=1M count=64 oflag=sync
+dd if=/dev/zero of=loopa bs=1M count=64 conv=fdatasync
+dd if=/dev/zero of=loopb bs=1M count=64 conv=fdatasync
+dd if=/dev/zero of=loopc bs=1M count=64 conv=fdatasync
+dd if=/dev/zero of=loopd bs=1M count=64 conv=fdatasync
 
 LOOP1=$(losetup -f loopa --show) || skip "Cannot find free loop device"
 LOOP2=$(losetup -f loopb --show) || skip "Cannot find free loop device"
diff --git a/test/shell/writecache-large.sh b/test/shell/writecache-large.sh
index 9a5a9f1dd..6391cef49 100644
--- a/test/shell/writecache-large.sh
+++ b/test/shell/writecache-large.sh
@@ -130,10 +130,10 @@ _add_new_data_to_mnt
 _add_more_data_to_mnt
 _verify_data_on_mnt
 
-dd if=/dev/zero of=$mnt/big1 bs=1M count=100 oflag=sync
-dd if=/dev/zero of=$mnt/big2 bs=1M count=100 oflag=sync
-dd if=/dev/zero of=$mnt/big3 bs=1M count=100 oflag=sync
-dd if=/dev/zero of=$mnt/big4 bs=1M count=100 oflag=sync
+dd if=/dev/zero of=$mnt/big1 bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of=$mnt/big2 bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of=$mnt/big3 bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of=$mnt/big4 bs=1M count=100 conv=fdatasync
 
 lvconvert --splitcache $vg/$lv1
 check lv_field $vg/$lv1 segtype linear
@@ -159,7 +159,7 @@ lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
 _add_new_data_to_mnt
 _add_more_data_to_mnt
-dd if=/dev/zero of=$mnt/big1 bs=1M count=100 oflag=sync
+dd if=/dev/zero of=$mnt/big1 bs=1M count=100 conv=fdatasync
 
 umount $mnt
 lvchange -an $vg/$lv1

