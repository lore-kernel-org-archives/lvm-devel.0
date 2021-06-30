From: David Teigland <teigland@sourceware.org>
Date: Wed, 30 Jun 2021 17:02:45 +0000 (GMT)
Subject: main - tests: skip tests that require blkid BLOCK_SIZE
Message-ID: <20210630170245.BBB79385E008@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a47e20a0929bc0d399851c398e7e3d06e97daf65
Commit:        a47e20a0929bc0d399851c398e7e3d06e97daf65
Parent:        39f497b9d8d35c77716014a3ba7074a2fc8955ac
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 30 11:56:42 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 30 11:56:42 2021 -0500

tests: skip tests that require blkid BLOCK_SIZE

Recent commit 84bd394cf9aaa581b4bf980f764544dda26a0305
  "writecache: use block size 4096 when no fs is found"

changed the default writecache block size from 512 to 4096
when no file system is detected.  The fs block size detection
requires the libblkid BLOCK_SIZE feature, so skip tests on
systems without this.  Otherwise, 4096 writecache added to
512 xfs leads fs io or mount failures.
---
 test/shell/lvextend-caches-on-thindata.sh  | 8 ++++++++
 test/shell/writecache-cache-blocksize-2.sh | 8 ++++++++
 test/shell/writecache.sh                   | 8 ++++++++
 3 files changed, 24 insertions(+)

diff --git a/test/shell/lvextend-caches-on-thindata.sh b/test/shell/lvextend-caches-on-thindata.sh
index aab571611..ef47d76d0 100644
--- a/test/shell/lvextend-caches-on-thindata.sh
+++ b/test/shell/lvextend-caches-on-thindata.sh
@@ -118,6 +118,14 @@ mkdir -p "$mount_dir"
 
 aux prepare_devs 6 70 # want 64M of usable space from each dev
 
+# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
+vgcreate $vg "$dev1"
+lvcreate -n $lv1 -L50 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+lvchange -an $vg
+vgremove -ff $vg
+
 # generate random data
 dd if=/dev/urandom of=pattern bs=512K count=1
 
diff --git a/test/shell/writecache-cache-blocksize-2.sh b/test/shell/writecache-cache-blocksize-2.sh
index af4f60e1d..dfb4f19a1 100644
--- a/test/shell/writecache-cache-blocksize-2.sh
+++ b/test/shell/writecache-cache-blocksize-2.sh
@@ -159,6 +159,14 @@ _run_test() {
 aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
 aux prepare_devs 2 64
 
+# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
+vgcreate $vg "$dev1"
+lvcreate -n $lv1 -L50 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+lvchange -an $vg
+vgremove -ff $vg
+
 # loopa/loopb have LBS 512 PBS 512
 which fallocate || skip
 fallocate -l 64M loopa
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index e549b113c..421c5bb4f 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -25,6 +25,14 @@ check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "512"
 aux prepare_devs 2 64
 
+# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
+vgcreate $vg "$dev1"
+lvcreate -n $lv1 -L50 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+lvchange -an $vg
+vgremove -ff $vg
+
 # scsi_debug devices with 512 LBS and 4K PBS
 #aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
 #check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"


