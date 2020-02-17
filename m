From: David Teigland <teigland@sourceware.org>
Date: Mon, 17 Feb 2020 14:07:37 -0500
Subject: master - writecache: drop real dm suffix
Message-ID: <44358.120021714073300603@us-mta-403.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4829f27b76742ed663de0a11babb5b9a5985b741
Commit:        4829f27b76742ed663de0a11babb5b9a5985b741
Parent:        db1d66859f8086467979b2d7e32843f70e4436e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 17 12:14:13 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 17 13:07:06 2020 -0600

writecache: drop real dm suffix

fixes the problem of adding writecache to an active LV
---
 lib/misc/lvm-string.c       |  1 -
 lib/writecache/writecache.c |  2 +-
 test/shell/writecache.sh    | 36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 0ee3403..d8b27cb 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -251,7 +251,6 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 */
 		/* Suffixes used here MUST match lib/activate/dev_manager.c */
 		layer = lv_is_cache_origin(lv) ? "real" :
-			lv_is_writecache_origin(lv) ? "real" :
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 130922a..08a306e 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -260,7 +260,7 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 	if ((pmem = lv_on_pmem(seg->writecache)) < 0)
 		return_0;
 
-	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), "real")))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
 		return_0;
 
 	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, "cvol")))
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 6cd4665..0a7f694 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -127,5 +127,41 @@ umount $mount_dir
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv2
 
+
+# test3: attach writecache to an active LV
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+ls -l $mount_dir
+
+lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype writecache
+
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
+grep linear out
+
+cp pattern1 $mount_dir/pattern1.after
+
+diff pattern1 $mount_dir/pattern1
+diff pattern1 $mount_dir/pattern1.after
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+diff pattern1 $mount_dir/pattern1.after
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
 vgremove -ff $vg
 



