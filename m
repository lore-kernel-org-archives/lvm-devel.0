From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:57 +0000 (UTC)
Subject: master - cache: add validate_lv_cache_create
Message-ID: <20141006133257.B8EE0609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a366918432bf4f825d2ddbb00780943c0761a0d
Commit:        5a366918432bf4f825d2ddbb00780943c0761a0d
Parent:        a8497e329b3c70c88feb5f0121e05464d32b2433
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 18:37:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

cache: add validate_lv_cache_create

Move validation tests into separate function.
---
 lib/metadata/cache_manip.c       |   98 +++++++++++++++++++++++++-------------
 lib/metadata/metadata-exported.h |    2 +
 2 files changed, 67 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a44bba8..80214c9 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -90,6 +90,63 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 }
 
 /*
+ * Validate arguments for converting origin into cached volume with given cache pool.
+ *
+ * Always validates origin_lv, and when it is known also cache pool_lv
+ */
+int validate_lv_cache_create(const struct logical_volume *pool_lv,
+			     const struct logical_volume *origin_lv)
+{
+	struct lv_segment *seg;
+
+	if (pool_lv) {
+		if (!lv_is_cache_pool(pool_lv)) {
+			log_error("Logical volume %s is not a cache pool.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+
+		if (origin_lv == pool_lv) {
+			log_error("Can't use same LV %s for cache pool and cache volume.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+
+		if (!dm_list_empty(&pool_lv->segs_using_this_lv)) {
+			seg = get_only_segment_using_this_lv(pool_lv);
+			log_error("Logical volume %s is already in use by %s",
+				  display_lvname(pool_lv),
+				  seg ? display_lvname(seg->lv) : "another LV");
+			return 0;
+		}
+	}
+
+	/* For now we only support conversion of thin pool data volume */
+	if (!lv_is_visible(origin_lv) && !lv_is_thin_pool_data(origin_lv)) {
+		log_error("Can't convert internal LV %s.", display_lvname(origin_lv));
+		return 0;
+	}
+
+	/*
+	 * Only linear, striped or raid supported.
+	 * FIXME Tidy up all these type restrictions.
+	 */
+	if (lv_is_cache_type(origin_lv) ||
+	    lv_is_mirror_type(origin_lv) ||
+	    lv_is_thin_volume(origin_lv) || lv_is_thin_pool_metadata(origin_lv) ||
+	    lv_is_origin(origin_lv) || lv_is_merging_origin(origin_lv) ||
+	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
+	    lv_is_external_origin(origin_lv) ||
+	    lv_is_virtual(origin_lv)) {
+		log_error("Cache is not supported with origin LV %s type.",
+			  display_lvname(origin_lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
  * lv_cache_create
  * @pool
  * @origin
@@ -99,57 +156,32 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
  *
  * Returns: cache LV on success, NULL on failure
  */
-struct logical_volume *lv_cache_create(struct logical_volume *pool,
-				       struct logical_volume *origin)
+struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
+				       struct logical_volume *origin_lv)
 {
 	const struct segment_type *segtype;
-	struct cmd_context *cmd = pool->vg->cmd;
-	struct logical_volume *cache_lv;
+	struct cmd_context *cmd = pool_lv->vg->cmd;
+	struct logical_volume *cache_lv = origin_lv;
 	struct lv_segment *seg;
 
-	if (!lv_is_cache_pool(pool)) {
-		log_error(INTERNAL_ERROR
-			  "%s is not a cache_pool LV", pool->name);
-		return NULL;
-	}
-
-	if (!dm_list_empty(&pool->segs_using_this_lv)) {
-		seg = get_only_segment_using_this_lv(pool);
-		log_error("%s is already in use by %s",
-			  pool->name, seg ? seg->lv->name : "another LV");
-		return NULL;
-	}
-
-	if (lv_is_cache_type(origin)) {
-		/*
-		 * FIXME: We can layer caches, insert_layer_for_lv() would
-		 * have to do a better job renaming the LVs in the stack
-		 * first so that there isn't a name collision with <name>_corig.
-		 * The origin under the origin would become *_corig_corig
-		 * before renaming the origin above to *_corig.
-		 */
-		log_error("Creating a cache LV from an existing cache LV is"
-			  "not yet supported.");
-		return NULL;
-	}
+	if (!validate_lv_cache_create(pool_lv, origin_lv))
+		return_NULL;
 
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
 		return_NULL;
 
-	cache_lv = origin;
-	if (!(origin = insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig")))
+	if (!insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig"))
 		return_NULL;
 
 	seg = first_seg(cache_lv);
 	seg->segtype = segtype;
 
-	if (!attach_pool_lv(seg, pool, NULL, NULL))
+	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
 		return_NULL;
 
 	return cache_lv;
 }
 
-
 /*
  * Cleanup orphan device in the table with temporary activation
  * since in the suspend() we can't deactivate unused nodes
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b392bde..d04d987 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1074,6 +1074,8 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
+int validate_lv_cache_create(const struct logical_volume *pool_lv,
+			     const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);


