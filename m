From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:46 +0000 (GMT)
Subject: main - tests: some skips with 6.2 kernel
Message-ID: <20230223154846.A65C23858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5c0b68dde47f7a6feb9f84764a8055b033c21c4
Commit:        d5c0b68dde47f7a6feb9f84764a8055b033c21c4
Parent:        25cb6a042fab1af7ea4f4a164771a810e1acdef5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 15:06:17 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:01:50 2023 +0100

tests: some skips with 6.2 kernel

Fix did not managed to get to final release so skip test on this kernel.
---
 test/shell/cache-single-split.sh | 4 ++++
 test/shell/lvextend-caches.sh    | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index fa4c3fd9d..25f83b1ba 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -16,6 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+case "$(uname -r)" in
+6.2*) skip "Skippen test that kills this kernel" ;;
+esac
+
 mkfs_mount_umount()
 {
         lvt=$1
diff --git a/test/shell/lvextend-caches.sh b/test/shell/lvextend-caches.sh
index f2768903f..a1a862e40 100644
--- a/test/shell/lvextend-caches.sh
+++ b/test/shell/lvextend-caches.sh
@@ -16,6 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+case "$(uname -r)" in
+6.2*) skip "Skippen test that kills this kernel" ;;
+esac
+
 do_test()
 {
 	# create some initial data

