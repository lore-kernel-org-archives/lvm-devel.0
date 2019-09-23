From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Sep 2019 15:22:05 -0400
Subject: master - drop cvol dm uuid suffix for cachevol LVs
Message-ID: <201909231922.x8NJM5e0026201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5191057d9df3e5b92db3f80c412b99aea1074358
Commit:        5191057d9df3e5b92db3f80c412b99aea1074358
Parent:        338a60bb417e413820a6d1faeed864222607c8ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 23 14:10:56 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 23 14:13:31 2019 -0500

drop cvol dm uuid suffix for cachevol LVs

The "-cvol" suffix on the uuid is interfering with
activation code, so drop the suffix for now.
---
 lib/activate/dev_manager.c  |    2 +-
 lib/misc/lvm-string.c       |    2 --
 lib/writecache/writecache.c |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b85237d..32e795d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -46,7 +46,7 @@ typedef enum {
 } action_t;
 
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
-const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", "cvol", NULL};
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", NULL};
 
 struct dlid_list {
 	struct dm_list list;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 4034b40..bb66214 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -157,7 +157,6 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_cdata",
 		"_cmeta",
 		"_corig",
-		"_cvol",
 		"_wcorig",
 		"_mimage",
 		"_mlog",
@@ -254,7 +253,6 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
-			lv_is_cache_vol(lv) ? "cvol" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
 			//lv_is_mirror_image(lv) ? "mimage" :
 			//lv_is_mirror_log(lv) ? "mlog" :
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 0a5b485..07a2d63 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -263,7 +263,7 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), "real")))
 		return_0;
 
-	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, "cvol")))
+	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_writecache_target(node, len,


