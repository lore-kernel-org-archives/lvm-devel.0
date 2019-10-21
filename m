From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:16 -0400
Subject: master - cache: use _cpool for used cache-pools
Message-ID: <201910211333.x9LDXG7t019606@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd7629ea090d4e55de057b772e9eb9470a49e05b
Commit:        dd7629ea090d4e55de057b772e9eb9470a49e05b
Parent:        23f660cf98fd966525672309ee821348edebd014
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 12:03:19 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 15:31:33 2019 +0200

cache: use _cpool for used cache-pools

When LV gets cached and uses cache-pool - such cache-pool
will now get _cpool suffix automatically.

Thus 'Pool' column for cached LV will now show either _cvol
or _cpool LV.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   12 ++++++++++++
 tools/lvconvert.c          |   12 ++++++------
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d6e4c9a..001a12b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Add _cpool suffix to cache-pool LV name when used by caching LV.
   No longer store extra UUID for cmeta and cdata cachevol layer.
   Enhance activation of cache devices with cachevols.
   Add _cvol in list of protected suffixes and start use it with DM UUID.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5275d24..c20cc49 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -430,6 +430,7 @@ int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size)
 struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 				       struct logical_volume *origin_lv)
 {
+	char cpool_name[NAME_LEN];
 	const struct segment_type *segtype;
 	struct cmd_context *cmd = pool_lv->vg->cmd;
 	struct logical_volume *cache_lv = origin_lv;
@@ -454,6 +455,17 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_NULL;
 
+	if (lv_is_cache_pool(pool_lv)) {
+		/* Used cache-pool gets  _cpool suffix (easy to recognize from _cvol usage) */
+		if (dm_snprintf(cpool_name, sizeof(cpool_name), "%s_cpool", pool_lv->name) < 0) {
+			log_error("Can't prepare new cachepool name for %s.", display_lvname(pool_lv));
+			return NULL;
+		}
+
+		if (!lv_rename_update(cmd, pool_lv, cpool_name, 0))
+			return_NULL;
+	}
+
 	if (!seg->lv->profile) /* Inherit profile from cache-pool */
 		seg->lv->profile = seg->pool_lv->profile;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9159f57..e033e71 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4287,6 +4287,7 @@ static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 					  struct logical_volume *lv,
 					  struct processing_handle *handle)
 {
+	struct lv_segment *seg;
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cachepool_lv;
 	const char *cachepool_name;
@@ -4333,15 +4334,14 @@ static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 			goto out;
 		}
 
-		if (!(cachepool_lv = find_lv(vg, cachepool_name))) {
-			log_error("LV %s cannot be found.", display_lvname(cachepool_lv));
+		/* cachepool_lv is converted into cache-pool data LV */
+		if (!(seg = get_only_segment_using_this_lv(cachepool_lv))) {
+			log_error(INTERNAL_ERROR "LV %s is not a cache pool data volume.",
+				  display_lvname(cachepool_lv));
 			goto out;
 		}
 
-		if (!lv_is_cache_pool(cachepool_lv)) {
-			log_error("LV %s is not a cache pool.", display_lvname(cachepool_lv));
-			goto out;
-		}
+		cachepool_lv = seg->lv;
 	} else {
 		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
 			log_error("Cache pool %s is already in use.", cachepool_name);


