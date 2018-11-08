From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 10:50:13 -0500
Subject: master - tests: enable writeback in cache-single-options
Message-ID: <201811081550.wA8FoD1Y024017@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1e33e75e7e1c1907017aa151be7253f63075f34
Commit:        e1e33e75e7e1c1907017aa151be7253f63075f34
Parent:        8c5fbd5fac7de820f7b4106a070b993a1565c112
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 8 09:40:41 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 09:40:41 2018 -0600

tests: enable writeback in cache-single-options

---
 test/shell/cache-single-options.sh |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 4eb4d1c..00c1b1d 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -164,16 +164,16 @@ mount_umount $lv1
 #mount_umount $lv1
 
 
-#lvconvert -y --type cache --cachepool $lv2 --cachemode writeback $vg/$lv1
+lvconvert -y --type cache --cachepool $lv2 --cachemode writeback $vg/$lv1
 
-#check lv_field $vg/$lv1 cachemode "writeback"
+check lv_field $vg/$lv1 cachemode "writeback"
 
-#mkfs_mount_umount $lv1
+mkfs_mount_umount $lv1
 
-#lvconvert --splitcache $vg/$lv1
-#check lv_field $vg/$lv1 segtype linear
-#check lv_field $vg/$lv2 segtype linear
-#mount_umount $lv1
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
 
 
 #


