From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:46 +0000 (UTC)
Subject: master - cache: lv_cache_status
Message-ID: <20141103132346.E07CB60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab491204659ef08a9a71379cab835650901b31ac
Commit:        ab491204659ef08a9a71379cab835650901b31ac
Parent:        13e6369d7f3b44b50e583e48868fb075a9f31757
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 3 12:52:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: lv_cache_status

Replace lv_cache_block_info() and lv_cache_policy_info()
with lv_cache_status() which directly returns
dm_status_cache structure together with some calculated
values.

After use  mem pool stored inside lv_status_cache structure
needs to be destroyed.
---
 lib/activate/activate.c          |  151 ++++----------------------------------
 lib/activate/activate.h          |    8 +--
 lib/activate/dev_manager.c       |   24 +++++-
 lib/activate/dev_manager.h       |    2 +-
 lib/metadata/cache_manip.c       |   21 +++--
 lib/metadata/metadata-exported.h |    8 ++
 6 files changed, 60 insertions(+), 154 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 69011f7..49e86e7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -968,158 +968,39 @@ out:
 	return r;
 }
 
-int lv_cache_block_info(struct logical_volume *lv,
-			uint32_t *chunk_size, uint64_t *dirty_count,
-			uint64_t *used_count, uint64_t *total_count)
+/*
+ * Return dm_status_cache for cache volume, accept also cache pool
+ *
+ * As there are too many variable for cache volumes, and it hard
+ * to make good API - so let's obtain dm_status_cache and return
+ * all info we have - user just has to release struct after its use.
+ */
+int lv_cache_status(const struct logical_volume *cache_lv,
+		    struct lv_status_cache **status)
 {
-	struct lv_segment *cache_seg;
-	struct logical_volume *cache_lv;
 	struct dev_manager *dm;
-	struct dm_status_cache *status;
-
-	/* The user is free to choose which args they are interested in */
-	if (chunk_size)
-		*chunk_size = 0;
-	if (dirty_count)
-		*dirty_count = 0;
-	if (used_count)
-		*used_count = 0;
-	if (total_count)
-		*total_count = 0;
-
-	if (lv_is_cache(lv))
-		cache_lv = lv;
-	else if (lv_is_cache_pool(lv)) {
-		if (dm_list_empty(&lv->segs_using_this_lv)) {
-			//FIXME: Ok to return value not sourced from kernel?
-			//       This could be valuable - esp for 'lvs' output
-			log_error(INTERNAL_ERROR "Unable to get block info"
-				  " of unlinked cache_pool, %s", lv->name);
-			//FIXME: ... because we could do this:
-			if (chunk_size)
-				*chunk_size = first_seg(lv)->chunk_size;
-			/* Unlinked cache_pools have 0 dirty & used blocks */
-			if (total_count) {
-				*total_count = lv->size; /* in sectors */
-				*total_count /= first_seg(lv)->chunk_size;
-			}
-
-			return 1;
-		}
-		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
-			return_0;
-		cache_lv = cache_seg->lv;
-	} else {
-		log_error(INTERNAL_ERROR
-			  "Unable to get block info of non-cache LV, %s",
-			  lv->name);
-		return 0;
-	}
-
-	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
-		return_0;
-
-	log_debug_activation("Checking cache block info for LV %s/%s",
-			     cache_lv->vg->name, cache_lv->name);
-
-	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
-		return_0;
-
-	if (!dev_manager_cache_status(dm, cache_lv, &status)) {
-		dev_manager_destroy(dm);
-		return_0;
-	}
-
-	if (chunk_size)
-		*chunk_size = status->block_size;
-	if (dirty_count)
-		*dirty_count = status->dirty_blocks;
-	if (used_count)
-		*used_count = status->used_blocks;
-	if (total_count)
-		*total_count = status->total_blocks;
-
-	dev_manager_destroy(dm);
-
-	return 1;
-}
-
-int lv_cache_policy_info(struct logical_volume *lv,
-			 const char **policy_name, int *policy_argc,
-			 const char ***policy_argv)
-{
-	int i;
 	struct lv_segment *cache_seg;
-	struct logical_volume *cache_lv;
-	struct dev_manager *dm;
-	struct dm_status_cache *status;
-	struct dm_pool *mem = lv->vg->cmd->mem;
-
-	/* The user is free to choose which args they are interested in */
-	if (policy_name)
-		*policy_name = NULL;
-	if (policy_argc)
-		*policy_argc = 0;
-	if (policy_argv)
-		*policy_argv = NULL;
-
-	if (lv_is_cache(lv))
-		cache_lv = lv;
-	else if (lv_is_cache_pool(lv)) {
-		if (dm_list_empty(&lv->segs_using_this_lv)) {
-			//FIXME: Ok to return value not sourced from kernel?
-			log_error(INTERNAL_ERROR "Unable to get policy info"
-				  " of unlinked cache_pool, %s", lv->name);
-			//FIXME: ... because we could do this:
-			if (policy_name)
-				*policy_name = first_seg(lv)->policy_name;
-			if (policy_argc)
-				*policy_argc = first_seg(lv)->policy_argc;
-			if (policy_argv)
-				*policy_argv = first_seg(lv)->policy_argv;
 
-			return 1;
-		}
-		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+	if (lv_is_cache_pool(cache_lv) && !dm_list_empty(&cache_lv->segs_using_this_lv)) {
+		if (!(cache_seg = get_only_segment_using_this_lv(cache_lv)))
 			return_0;
 		cache_lv = cache_seg->lv;
-	} else {
-		log_error(INTERNAL_ERROR
-			  "Unable to get policy info of non-cache LV, %s",
-			  lv->name);
-		return 0;
 	}
 
 	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
-		return_0;
+		return 0;
 
-	log_debug_activation("Checking cache policy for LV %s/%s",
-			     cache_lv->vg->name, cache_lv->name);
+	log_debug_activation("Checking cache status for LV %s.",
+			     display_lvname(cache_lv));
 
 	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
 		return_0;
 
-	if (!dev_manager_cache_status(dm, cache_lv, &status)) {
+	if (!dev_manager_cache_status(dm, cache_lv, status)) {
 		dev_manager_destroy(dm);
 		return_0;
 	}
-
-	if (policy_name &&
-	    !(*policy_name = dm_pool_strdup(mem, status->policy_name)))
-		return_0;
-	if (policy_argc)
-		*policy_argc = status->policy_argc;
-	if (policy_argv) {
-		if (!(*policy_argv =
-		      dm_pool_zalloc(mem, sizeof(char *) * status->policy_argc)))
-			return_0;
-		for (i = 0; i < status->policy_argc; ++i)
-			if (!((*policy_argv)[i] =
-			      dm_pool_strdup(mem, status->policy_argv[i])))
-				return_0;
-	}
-
-	dev_manager_destroy(dm);
+	/* User has to call dm_pool_destroy(status->mem)! */
 
 	return 1;
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4c170c1..9dfbcfa 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -120,12 +120,8 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
-int lv_cache_block_info(struct logical_volume *lv,
-			uint32_t *chunk_size, uint64_t *dirty_count,
-			uint64_t *used_count, uint64_t *total_count);
-int lv_cache_policy_info(struct logical_volume *lv,
-			 const char **policy_name, int *policy_argc,
-			 const char ***policy_argv);
+int lv_cache_status(const struct logical_volume *lv,
+		    struct lv_status_cache **status);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b7e496e..e9b6816 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1164,7 +1164,7 @@ out:
 
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     struct dm_status_cache **status)
+			     struct lv_status_cache **status)
 {
 	int r = 0;
 	const char *dlid;
@@ -1173,9 +1173,12 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	const char *layer = lv_layer(lv);
+	struct dm_status_cache *c;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+		return_0;
+
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
@@ -1195,9 +1198,22 @@ int dev_manager_cache_status(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (!dm_get_status_cache(dm->mem, params, status))
+	/*
+	 * FIXME:
+	 * ->target_percent() API is able to transfer only a single value.
+	 * Needs to be able to pass whole structure.
+	 */
+	if (!dm_get_status_cache(dm->mem, params, &((*status)->cache)))
 		goto_out;
 
+	c = (*status)->cache;
+	(*status)->mem = dm->mem; /* User can destroy this mem pool later */
+	(*status)->data_usage = dm_make_percent(c->used_blocks,
+						c->total_blocks);
+	(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
+						    c->metadata_total_blocks);
+	(*status)->dirty_usage = dm_make_percent(c->dirty_blocks,
+						 c->used_blocks);
 	r = 1;
 out:
 	dm_task_destroy(dmt);
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 8325bf9..f4f989c 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -62,7 +62,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 			     const char *msg);
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     struct dm_status_cache **status);
+			     struct lv_status_cache **status);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index eba7a50..a9f21ad 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -233,11 +233,12 @@ static int _cleanup_orphan_lv(struct logical_volume *lv)
  */
 int lv_cache_remove(struct logical_volume *cache_lv)
 {
-	const char *policy_name;
+	int is_cleaner;
 	uint64_t dirty_blocks;
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
+	struct lv_status_cache *status;
 
 	if (!lv_is_cache(cache_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not cached.", cache_lv->name);
@@ -271,10 +272,12 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 * remove the cache_pool then without waiting for the flush to
 	 * complete.
 	 */
-	if (!lv_cache_policy_info(cache_lv, &policy_name, NULL, NULL))
+	if (!lv_cache_status(cache_lv, &status))
 		return_0;
+	is_cleaner = !strcmp(status->cache->policy_name, "cleaner");
+	dm_pool_destroy(status->mem);
 
-	if (strcmp(policy_name, "cleaner")) {
+	if (!is_cleaner) {
 		/* We must swap in the cleaner to flush the cache */
 		log_print_unless_silent("Flushing cache for %s.", cache_lv->name);
 
@@ -293,13 +296,15 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	//FIXME: use polling to do this...
 	do {
-		if (!lv_cache_block_info(cache_lv, NULL,
-					 &dirty_blocks, NULL, NULL))
+		if (!lv_cache_status(cache_lv, &status))
 			return_0;
-		log_print_unless_silent("%" PRIu64 " blocks must still be flushed.",
-					dirty_blocks);
-		if (dirty_blocks)
+		dirty_blocks = status->cache->dirty_blocks;
+		dm_pool_destroy(status->mem);
+		if (dirty_blocks) {
+			log_print_unless_silent("%" PRIu64 " blocks must still be flushed.",
+						dirty_blocks);
 			sleep(1);
+		}
 	} while (dirty_blocks);
 
 	cache_pool_lv = cache_seg->pool_lv;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 39d91a1..736b0b5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1086,6 +1086,14 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
+struct lv_status_cache {
+	struct dm_pool *mem;
+	struct dm_status_cache *cache;
+	dm_percent_t data_usage;
+	dm_percent_t metadata_usage;
+	dm_percent_t dirty_usage;
+};
+
 const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,


