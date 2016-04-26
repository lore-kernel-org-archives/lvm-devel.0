From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:30 +0000 (UTC)
Subject: master - cache: check for clean cache as separete function
Message-ID: <20160426213130.3278260509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b5967e1e3313e8f9caa8065e170dd35ada8e57a
Commit:        8b5967e1e3313e8f9caa8065e170dd35ada8e57a
Parent:        588455d03ea40ffa37f466023691b0ec2bdf5e82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 26 21:45:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:24:17 2016 +0200

cache: check for clean cache as separete function

---
 lib/metadata/cache_manip.c       |   98 ++++++++++++++++++++++----------------
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 58 insertions(+), 41 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 46cb6a8..bf3d405 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -279,6 +279,61 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 }
 
 /*
+ * Checks cache status and loops until there are not dirty blocks
+ * Set 1 to *is_clean when there are no dirty blocks on return.
+ */
+int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
+{
+	struct lv_segment *cache_seg = first_seg(cache_lv);
+	struct lv_status_cache *status;
+	int cleaner_policy;
+	uint64_t dirty_blocks;
+
+	*is_clean = 0;
+
+	//FIXME: use polling to do this...
+	for (;;) {
+		if (!lv_cache_status(cache_lv, &status))
+			return_0;
+		if (status->cache->fail) {
+			dm_pool_destroy(status->mem);
+			log_warn("WARNING: Skippping flush for failed cache.");
+			return 1;
+		}
+
+		cleaner_policy = !strcmp(status->cache->policy_name, "cleaner");
+		dirty_blocks = status->cache->dirty_blocks;
+
+		/* No clear policy and writeback mode means dirty */
+		if (!cleaner_policy &&
+		    (status->cache->feature_flags & DM_CACHE_FEATURE_WRITEBACK))
+			dirty_blocks++;
+		dm_pool_destroy(status->mem);
+
+		if (!dirty_blocks)
+			break;
+
+		if (cleaner_policy) {
+		    log_print_unless_silent(FMTu64 " blocks must still be flushed.",
+					    dirty_blocks);
+		    sleep(1);
+                    continue;
+		}
+
+		/* Switch to cleaner policy to flush the cache */
+		log_print_unless_silent("Flushing cache for %s.",
+					display_lvname(cache_lv));
+		cache_seg->cleaner_policy = 1;
+		/* Reaload kernel with "cleaner" policy */
+		if (!lv_update_and_reload_origin(cache_lv))
+		    return_0;
+	}
+
+	*is_clean = 1;
+
+	return 1;
+}
+/*
  * lv_cache_remove
  * @cache_lv
  *
@@ -291,12 +346,10 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
  */
 int lv_cache_remove(struct logical_volume *cache_lv)
 {
-	int is_cleaner;
-	uint64_t dirty_blocks;
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
-	struct lv_status_cache *status;
+	int is_clear;
 
 	if (!lv_is_cache(cache_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not cache volume.",
@@ -356,45 +409,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 * remove the cache_pool then without waiting for the flush to
 	 * complete.
 	 */
-	if (!lv_cache_status(cache_lv, &status))
+	if (!lv_cache_wait_for_clean(cache_lv, &is_clear))
 		return_0;
-	if (!status->cache->fail) {
-		is_cleaner = !strcmp(status->cache->policy_name, "cleaner");
-		dirty_blocks = status->cache->dirty_blocks;
-		if (!(status->cache->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
-			dirty_blocks++; /* Not writethrough - always dirty */
-	} else {
-		log_warn("WARNING: Skippping flush for failed cache.");
-		is_cleaner = 0;
-		dirty_blocks = 0;
-	}
-	dm_pool_destroy(status->mem);
-
-	if (dirty_blocks && !is_cleaner) {
-		/* Switch to cleaner policy to flush the cache */
-		log_print_unless_silent("Flushing cache for %s.", cache_lv->name);
-		cache_seg->cleaner_policy = 1;
-		/* update the kernel to put the cleaner policy in place */
-		if (!lv_update_and_reload_origin(cache_lv))
-			return_0;
-	}
-
-	//FIXME: use polling to do this...
-	while (dirty_blocks) {
-		if (!lv_cache_status(cache_lv, &status))
-			return_0;
-		if (status->cache->fail) {
-			log_warn("WARNING: Flushing of failing cache skipped.");
-			break;
-		}
-		dirty_blocks = status->cache->dirty_blocks;
-		dm_pool_destroy(status->mem);
-		if (dirty_blocks) {
-			log_print_unless_silent(FMTu64 " blocks must still be flushed.",
-						dirty_blocks);
-			sleep(1);
-		}
-	}
 
 	cache_pool_lv = cache_seg->pool_lv;
 	if (!detach_pool_lv(cache_seg))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 039708e..8c4dfc3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1226,6 +1226,7 @@ int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
 int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
+int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */


