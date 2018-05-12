From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:17 -0400
Subject: master - tests: start to use 4k mkfs
Message-ID: <201805122139.w4CLdHQj005450@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9640320aea74e7cef0bde64c9be6e3471a85746e
Commit:        9640320aea74e7cef0bde64c9be6e3471a85746e
Parent:        ca87674ea4f6fd12b9049ea2a6498a5cf191893e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 23:22:20 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 23:22:20 2018 +0200

tests: start to use 4k mkfs

While newer system can detect need for 4K mkfs, on older test machines
running test suite over 4k is reporting problems.
Some more generic solution is needed thought.
---
 test/shell/thin-merge.sh       |    1 +
 test/shell/topology-support.sh |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 24dec96..457bd47 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -22,6 +22,7 @@ MKFS=mkfs.ext2
 which $MKFS  || skip
 which fsck || skip
 
+MKFS="$MKFS -b4096"
 #
 # Main
 #
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 98a6d9f..482205a 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -23,7 +23,7 @@ lvdev_() {
 
 test_snapshot_mount() {
     lvcreate -aey -L4M -n $lv1 $vg "$dev1"
-    mkfs.ext3 "$(lvdev_ $vg $lv1)"
+    mkfs.ext3 -b4096 "$(lvdev_ $vg $lv1)"
     mkdir test_mnt
     mount "$(lvdev_ $vg $lv1)" test_mnt
     lvcreate -L4M -n $lv2 -s $vg/$lv1


