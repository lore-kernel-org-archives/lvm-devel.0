From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Sep 2020 22:36:05 +0000 (GMT)
Subject: master - tests: resolve missing removal of loopdevice on error path
Message-ID: <20200917223605.761BF39450FE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d40859e29c03c867c788c4927076b4192192214
Commit:        8d40859e29c03c867c788c4927076b4192192214
Parent:        a5e867139d31b42e3bd084ecd0aefe1eabfa380c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 00:31:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 00:31:11 2020 +0200

tests: resolve missing removal of loopdevice on error path

In case of test failure, loop device leaked and occupied space forever.
---
 test/shell/integrity-blocksize.sh | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 61d58e2a3..60513e516 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -18,6 +18,21 @@ aux have_integrity 1 5 0 || skip
 
 losetup -h | grep sector-size || skip
 
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mnt" || true
+	vgremove -ff $vg1 $vg2 || true
+	losetup -d $LOOP1 || true
+	losetup -d $LOOP2 || true
+	losetup -d $LOOP3 || true
+	losetup -d $LOOP4 || true
+
+	rm -f loop{abcd}
+	aux teardown
+}
+
+
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 aux prepare_devs 1
 vgcreate $vg "$dev1"
@@ -27,6 +42,8 @@ blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
+trap 'cleanup_mounted_and_teardown' EXIT
+
 dd if=/dev/zero of=loopa bs=$((1024*1024)) count=64 2> /dev/null
 dd if=/dev/zero of=loopb bs=$((1024*1024)) count=64 2> /dev/null
 dd if=/dev/zero of=loopc bs=$((1024*1024)) count=64 2> /dev/null
@@ -270,15 +287,4 @@ pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvchange -an $vg2/$lv1
 lvremove -y $vg2/$lv1
 
-vgremove -ff $vg1
-vgremove -ff $vg2
-
-losetup -d $LOOP1
-losetup -d $LOOP2
-losetup -d $LOOP3
-losetup -d $LOOP4
-rm loopa
-rm loopb
-rm loopc
-rm loopd
-
+# remove of $vg1, $vg2 and loops in cleanup_mounted_and_teardown()


