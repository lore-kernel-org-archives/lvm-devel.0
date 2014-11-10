From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:25 +0000 (UTC)
Subject: master - cleanup: cache API get/set
Message-ID: <20141110210625.8092D60D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3dbcd2a1c9027c08faab726a1f1a24085046f0df
Commit:        3dbcd2a1c9027c08faab726a1f1a24085046f0df
Parent:        2e0c926d56f93880f4b7a7813cec7c3a774a8280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 9 18:51:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

cleanup: cache API get/set

---
 lib/cache_segtype/cache.c        |   22 +++++---------------
 lib/metadata/cache_manip.c       |   40 ++++++++++++++++++++++---------------
 lib/metadata/metadata-exported.h |    4 +-
 3 files changed, 32 insertions(+), 34 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index dceb3c0..e5512bf 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -69,7 +69,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (dm_config_has_node(sn, "cache_mode")) {
 		if (!(str = dm_config_find_str(sn, "cache_mode", NULL)))
 			return SEG_LOG_ERROR("cache_mode must be a string in");
-		if (!get_cache_mode(str, &seg->feature_flags))
+		if (!set_cache_pool_feature(&seg->feature_flags, str))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
 	}
 
@@ -167,25 +167,15 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 {
 	unsigned i;
 	char buf[256]; //FIXME: IS THERE AN 'outf' THAT DOESN'T DO NEWLINE?!?
-	uint32_t feature_flags = seg->feature_flags;
+	const char *cache_mode;
+
+	if (!(cache_mode = get_cache_pool_cachemode_name(seg)))
+		return_0;
 
 	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
-
-	if (feature_flags) {
-		if (feature_flags & DM_CACHE_FEATURE_WRITETHROUGH) {
-			outf(f, "cache_mode = \"writethrough\"");
-			feature_flags &= ~DM_CACHE_FEATURE_WRITETHROUGH;
-		} else if (feature_flags & DM_CACHE_FEATURE_WRITEBACK) {
-			outf(f, "cache_mode = \"writeback\"");
-			feature_flags &= ~DM_CACHE_FEATURE_WRITEBACK;
-		} else {
-			log_error(INTERNAL_ERROR "Unknown feature flags "
-				  "in cache_pool segment for %s", seg->lv->name);
-			return 0;
-		}
-	}
+	outf(f, "cache_mode = \"%s\"", cache_mode);
 
 	if (seg->core_argc) {
 		outf(f, "core_argc = %u", seg->core_argc);
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index ec7f444..69a51ef 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -28,7 +28,7 @@
 #define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
 #define DM_MAX_HINT_WIDTH		(4+16)  /* bytes,  TODO: configurable ?? */
 
-const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
+const char *get_cache_pool_cachemode_name(const struct lv_segment *seg)
 {
 	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
 		return "writeback";
@@ -36,7 +36,29 @@ const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
 	if (seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
 		return "writethrough";
 
-	return "unknown";
+	if (seg->feature_flags & DM_CACHE_FEATURE_PASSTHROUGH)
+		return "passthrough";
+
+	log_error("LV %s has uknown feature flags %" PRIu64,
+		  display_lvname(seg->lv), seg->feature_flags);
+
+	return NULL;
+}
+
+int set_cache_pool_feature(uint64_t *feature_flags, const char *str)
+{
+	if (!strcmp(str, "writeback"))
+		*feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+	else if (!strcmp(str, "writethrough"))
+		*feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+	else if (!strcmp(str, "passhrough"))
+		*feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
+	else {
+		log_error("Cache pool feature \"%s\" is unknown.", str);
+		return 0;
+	}
+
+	return 1;
 }
 
 int update_cache_pool_params(const struct segment_type *segtype,
@@ -354,20 +376,6 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	return 1;
 }
 
-int get_cache_mode(const char *str, uint32_t *flags)
-{
-	if (!strcmp(str, "writethrough"))
-		*flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-	else if (!strcmp(str, "writeback"))
-		*flags |= DM_CACHE_FEATURE_WRITEBACK;
-	else {
-		log_error("Cache pool cachemode \"%s\" is unknown.", str);
-		return 0;
-	}
-
-	return 1;
-}
-
 int lv_is_cache_origin(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9afce35..4c15fee 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1095,7 +1095,8 @@ struct lv_status_cache {
 	dm_percent_t dirty_usage;
 };
 
-const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
+const char *get_cache_pool_cachemode_name(const struct lv_segment *seg);
+int set_cache_pool_feature(uint64_t *feature_flags, const char *str);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t pool_data_extents,
@@ -1106,7 +1107,6 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int get_cache_mode(const char *str, uint32_t *flags);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 


