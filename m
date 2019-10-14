From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:11 -0400
Subject: master - cache: enhance removal function to work with cvol
Message-ID: <201910141322.x9EDMBUo018757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=615e18f5b2356bd1fd134bc24ea790fa6ec0653f
Commit:        615e18f5b2356bd1fd134bc24ea790fa6ec0653f
Parent:        6ee83f699b5f3e5ffc09a7264de44425e8634970
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 10:43:04 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:14:25 2019 +0200

cache: enhance removal function to work with cvol

To keep things simple, use same code for all cache removal functions,
not just for cachepools but also cachevols.
---
 lib/metadata/cache_manip.c |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 1a5482b..9ace494 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -747,7 +747,7 @@ int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush)
  * @cache_lv
  *
  * Given a cache LV, remove the cache layer.  This will unlink
- * the origin and cache_pool, remove the cache LV layer, and promote
+ * the origin and cache_pool/cachevol, remove the cache LV layer, and promote
  * the origin to a usable non-cached LV of the same name as the
  * given cache_lv.
  *
@@ -758,6 +758,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
+	const struct id *data_id, *metadata_id;
+	uint64_t data_len, metadata_len;
 	cache_mode_t cache_mode;
 	int is_clear;
 
@@ -767,11 +769,6 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
-	if (lv_is_cache_vol(cache_seg->pool_lv)) {
-		log_error(INTERNAL_ERROR "Incorrect remove for cache single");
-		return 0;
-	}
-
 	if (lv_is_pending_delete(cache_lv)) {
 		log_debug(INTERNAL_ERROR "LV %s is already dropped cache volume.",
 			  display_lvname(cache_lv));
@@ -849,6 +846,13 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!remove_layer_from_lv(cache_lv, corigin_lv))
 		return_0;
 
+	/* Preserve currently imortant data from original cache segment.
+	 * TODO: can it be done without this ? */
+	data_id = &cache_seg->data_id;
+	data_len = cache_seg->data_len;
+	metadata_id = &cache_seg->metadata_id;
+	metadata_len = cache_seg->metadata_len;
+
 	/* Replace 'error' with 'cache' segtype */
 	cache_seg = first_seg(corigin_lv);
 	if (!(cache_seg->segtype = get_segtype_from_string(corigin_lv->vg->cmd, SEG_TYPE_NAME_CACHE)))
@@ -864,6 +868,18 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	corigin_lv->size = cache_lv->size;
 	corigin_lv->status |= LV_PENDING_DELETE;
 
+	/* Restore preserved data into a new cache segment that is going to be removed. */
+	if ((cache_seg->data_len = data_len)) {
+		cache_seg->metadata_len = metadata_len;
+		memcpy(&cache_seg->data_id, data_id, sizeof(struct id));
+		memcpy(&cache_seg->metadata_id, metadata_id, sizeof(struct id));
+		cache_pool_lv->status |= LV_CACHE_VOL;
+		/* Unused settings set only for passing metadata validation. */
+		cache_seg->cache_mode = CACHE_MODE_WRITETHROUGH;
+		cache_seg->chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+		cache_seg->cache_metadata_format = CACHE_METADATA_FORMAT_2;
+	}
+
 	/* Reattach cache pool */
 	if (!attach_pool_lv(cache_seg, cache_pool_lv, NULL, NULL, NULL))
 		return_0;
@@ -879,6 +895,8 @@ remove:
 	if (!lv_remove(cache_lv)) /* Will use LV_PENDING_DELETE */
 		return_0;
 
+	/* CachePool or CacheVol is left inactivate for further manipulation */
+
 	return 1;
 }
 


