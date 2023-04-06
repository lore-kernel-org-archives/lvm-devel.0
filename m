From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:39 +0000 (GMT)
Subject: main - tests: use less demanding ext4
Message-ID: <20230406114739.D57EA385843E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e59e7aa0ab9dd2d45a1cac46620ffb8d1d2e765c
Commit:        e59e7aa0ab9dd2d45a1cac46620ffb8d1d2e765c
Parent:        7b5291a8ed7917a396232024880b252ecf6ab23f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 6 13:40:16 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 13:41:30 2023 +0200

tests: use less demanding ext4

---
 test/shell/integrity-caching.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 158a31932..5539ac575 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -49,7 +49,7 @@ _prepare_vg() {
 }
 
 _test_fs_with_read_repair() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -103,7 +103,7 @@ _test_fs_with_read_repair() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 

