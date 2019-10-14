From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:31 -0400
Subject: master - cachevol: put _cvol as protected suffix.
Message-ID: <201910141322.x9EDMVId018819@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a454a1b4ea478ce117808c8b2dd480ff4d5eb2d4
Commit:        a454a1b4ea478ce117808c8b2dd480ff4d5eb2d4
Parent:        8d8047883ea56e633007f3bcca6e87e6cb14cef4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 7 14:58:26 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:16:05 2019 +0200

cachevol: put _cvol as protected suffix.

This revert "drop cvol dm uuid suffix for cachevol LVs"
commit 5191057d9df3e5b92db3f80c412b99aea1074358.
Start using -cvol for  DM UUID.
---
 WHATS_NEW                   |    1 +
 lib/activate/dev_manager.c  |    2 +-
 lib/misc/lvm-string.c       |    2 ++
 lib/writecache/writecache.c |    2 +-
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6d1700a..6458f4c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Add _cvol in list of protected suffixes and start use it with DM UUID.
   Rename LV converted to cachevol to use _cvol suffix.
   Use normal LVs for wiping of cachevols.
   Reload cleanered cache DM only with cleaner policy.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 32e795d..dfcccce 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -46,7 +46,7 @@ typedef enum {
 } action_t;
 
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
-const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", NULL};
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "cvol", "tdata", "tmeta", "vdata", "vpool", NULL};
 
 struct dlid_list {
 	struct dm_list list;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index bb66214..4034b40 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -157,6 +157,7 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_cdata",
 		"_cmeta",
 		"_corig",
+		"_cvol",
 		"_wcorig",
 		"_mimage",
 		"_mlog",
@@ -253,6 +254,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
+			lv_is_cache_vol(lv) ? "cvol" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
 			//lv_is_mirror_image(lv) ? "mimage" :
 			//lv_is_mirror_log(lv) ? "mlog" :
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 07a2d63..0a5b485 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -263,7 +263,7 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), "real")))
 		return_0;
 
-	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, NULL)))
+	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, "cvol")))
 		return_0;
 
 	if (!dm_tree_node_add_writecache_target(node, len,


