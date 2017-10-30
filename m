From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 09:39:48 -0400
Subject: master - tests: load reiserfs
Message-ID: <201710301339.v9UDdmeD015281@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3efd1f9c6e1e63c70d12cf3bc2f8eadcba47d7e5
Commit:        3efd1f9c6e1e63c70d12cf3bc2f8eadcba47d7e5
Parent:        83d5db056ba646ae69135b5f0114d1cc19b26044
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 13:28:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 14:39:16 2017 +0100

tests: load reiserfs

Preload reiserfs module for the case, fs is present/compiled for a
kernel but it's not present in memory.

Size reducition needs --yes confirmation to preceed for reiserfs.
---
 test/shell/fsadm-crypt.sh |    5 +++--
 test/shell/fsadm.sh       |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 5104feb..634fef3 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -55,6 +55,7 @@ grep xfs /proc/filesystems || check_xfs=${check_xfs:-no_xfs}
 
 which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
 which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
+modprobe reiserfs || true
 grep reiserfs /proc/filesystems || check_reiserfs=${check_reiserfs:-no_reiserfs}
 
 vg_lv=$vg/$lv1
@@ -295,8 +296,8 @@ test_reiserfs_resize() {
 test_reiserfs_small_shrink() {
 	mkfs.reiserfs -s 513 -f "$3"
 
-	lvresize -L-1 -r $1
-	lvresize -L-1 -r $1
+	lvresize -y -L-1 -r $1
+	lvresize -y -L-1 -r $1
 
 	fscheck_reiserfs "$3"
 }
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 35c3443..62eb7d3 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -36,6 +36,7 @@ grep xfs /proc/filesystems || check_xfs=${check_xfs:-no_xfs}
 
 which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
 which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
+modprobe reiserfs || true
 grep reiserfs /proc/filesystems || check_reiserfs=${check_reiserfs:-no_reiserfs}
 
 vg_lv=$vg/$lv1


