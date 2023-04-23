From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 23 Apr 2023 11:09:34 +0000 (GMT)
Subject: main - tests: enforce 4K block for integrity fs
Message-ID: <20230423110934.C9B453858C66@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce8835d4c429bd87da5731e3015d9ddc9e3fb888
Commit:        ce8835d4c429bd87da5731e3015d9ddc9e3fb888
Parent:        7cf5feb7d245d22d4968b95f3b7cfb6467461ff2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 23 00:03:43 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 23 00:03:43 2023 +0200

tests: enforce 4K block for integrity fs

With raid tests it's important we don't get spread of 4K file
across 1K block on a multiple disk stripe - so use 4K block size
for ext4 fs.
---
 test/shell/integrity-caching.sh | 4 ++--
 test/shell/integrity.sh         | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 52aec98ce..73d33de18 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -45,7 +45,7 @@ _prepare_vg() {
 }
 
 _test_fs_with_read_repair() {
-	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -92,7 +92,7 @@ _test_fs_with_read_repair() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index c649bef11..b55855ab4 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -45,7 +45,7 @@ _prepare_vg() {
 }
 
 _test_fs_with_read_repair() {
-	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -73,7 +73,7 @@ _test_fs_with_read_repair() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.ext4 -b 4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 

