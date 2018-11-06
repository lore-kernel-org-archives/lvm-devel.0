From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:42:37 -0500
Subject: master - cache: factor settings text import export
Message-ID: <201811062142.wA6LgbNp004711@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3f3d6066b82523867a7e7cdaa3d64ae73a44b2e
Commit:        f3f3d6066b82523867a7e7cdaa3d64ae73a44b2e
Parent:        8d7075528f0c6e3a0ddeb737c25540683a1946a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 15:23:23 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: factor settings text import export

Pull out the export/import of settings text so
it can be used later from elsewhere.
---
 lib/cache_segtype/cache.c |  130 ++++++++++++++++++++++++++------------------
 1 files changed, 77 insertions(+), 53 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ab9f942..cb86212 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -99,32 +99,16 @@ static void _fix_missing_defaults(struct lv_segment *cpool_seg)
 	}
 }
 
-static int _cache_pool_text_import(struct lv_segment *seg,
-				   const struct dm_config_node *sn,
-				   struct dm_hash_table *pv_hash __attribute__((unused)))
+static int _settings_text_import(struct lv_segment *seg,
+				 const struct dm_config_node *sn)
 {
-	struct logical_volume *data_lv, *meta_lv;
 	const char *str = NULL;
 	struct dm_pool *mem = seg->lv->vg->vgmem;
 
-	if (!dm_config_has_node(sn, "data"))
-		return SEG_LOG_ERROR("Cache data not specified in");
-	if (!(str = dm_config_find_str(sn, "data", NULL)))
-		return SEG_LOG_ERROR("Cache data must be a string in");
-	if (!(data_lv = find_lv(seg->lv->vg, str)))
-		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-				     "cache data in", str);
-
-	if (!dm_config_has_node(sn, "metadata"))
-		return SEG_LOG_ERROR("Cache metadata not specified in");
-	if (!(str = dm_config_find_str(sn, "metadata", NULL)))
-		return SEG_LOG_ERROR("Cache metadata must be a string in");
-	if (!(meta_lv = find_lv(seg->lv->vg, str)))
-		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-				     "cache metadata in", str);
-
-	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
-		return SEG_LOG_ERROR("Couldn't read cache chunk_size in");
+	if (dm_config_has_node(sn, "chunk_size")) {
+		if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
+			return SEG_LOG_ERROR("Couldn't read cache chunk_size in");
+	}
 
 	/*
 	 * Read in features:
@@ -146,16 +130,6 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
 	}
 
-	if (dm_config_has_node(sn, "metadata_format")) {
-		if (!dm_config_get_uint32(sn, "metadata_format", &seg->cache_metadata_format) ||
-		    ((seg->cache_metadata_format != CACHE_METADATA_FORMAT_1) &&
-		     (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)))
-			return SEG_LOG_ERROR("Unknown cache metadata format %u number in",
-					     seg->cache_metadata_format);
-		if (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2)
-			seg->lv->status |= LV_METADATA_FORMAT;
-	}
-
 	/*
 	 * Read in policy args:
 	 *   policy_settings {
@@ -184,6 +158,75 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return_0;
 	}
 
+	return 1;
+}
+
+static int _settings_text_export(const struct lv_segment *seg,
+				 struct formatter *f)
+{
+	if (seg->chunk_size)
+		outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
+
+	if (seg->cache_mode != CACHE_MODE_UNSELECTED) {
+		const char *cache_mode;
+		if (!(cache_mode = cache_mode_num_to_str(seg->cache_mode)))
+			return_0;
+		outf(f, "cache_mode = \"%s\"", cache_mode);
+	}
+
+	if (seg->policy_name) {
+		outf(f, "policy = \"%s\"", seg->policy_name);
+
+		if (seg->policy_settings) {
+			if (strcmp(seg->policy_settings->key, "policy_settings")) {
+				log_error(INTERNAL_ERROR "Incorrect policy_settings tree, %s.",
+					  seg->policy_settings->key);
+				return 0;
+			}
+			if (seg->policy_settings->child)
+				out_config_node(f, seg->policy_settings);
+		}
+	}
+
+	return 1;
+}
+
+static int _cache_pool_text_import(struct lv_segment *seg,
+				   const struct dm_config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct logical_volume *data_lv, *meta_lv;
+	const char *str = NULL;
+
+	if (!dm_config_has_node(sn, "data"))
+		return SEG_LOG_ERROR("Cache data not specified in");
+	if (!(str = dm_config_find_str(sn, "data", NULL)))
+		return SEG_LOG_ERROR("Cache data must be a string in");
+	if (!(data_lv = find_lv(seg->lv->vg, str)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+				     "cache data in", str);
+
+	if (!dm_config_has_node(sn, "metadata"))
+		return SEG_LOG_ERROR("Cache metadata not specified in");
+	if (!(str = dm_config_find_str(sn, "metadata", NULL)))
+		return SEG_LOG_ERROR("Cache metadata must be a string in");
+	if (!(meta_lv = find_lv(seg->lv->vg, str)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+				     "cache metadata in", str);
+
+	if (dm_config_has_node(sn, "metadata_format")) {
+		if (!dm_config_get_uint32(sn, "metadata_format", &seg->cache_metadata_format) ||
+		    ((seg->cache_metadata_format != CACHE_METADATA_FORMAT_1) &&
+		     (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)))
+			return SEG_LOG_ERROR("Unknown cache metadata format %u number in",
+					     seg->cache_metadata_format);
+		if (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2)
+			seg->lv->status |= LV_METADATA_FORMAT;
+	}
+
+	if (!_settings_text_import(seg, sn))
+		return_0;
+
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
 	if (!attach_pool_metadata_lv(seg, meta_lv))
@@ -207,11 +250,8 @@ static int _cache_pool_text_import_area_count(const struct dm_config_node *sn,
 static int _cache_pool_text_export(const struct lv_segment *seg,
 				   struct formatter *f)
 {
-	const char *cache_mode;
-
 	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
-	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
 
 	switch (seg->cache_metadata_format) {
 	case CACHE_METADATA_FORMAT_UNSELECTED:
@@ -237,25 +277,9 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	 * but not worth to break backward compatibility, by shifting
 	 * content to cache segment
 	 */
-	if (seg->cache_mode != CACHE_MODE_UNSELECTED) {
-		if (!(cache_mode = get_cache_mode_name(seg)))
-			return_0;
-		outf(f, "cache_mode = \"%s\"", cache_mode);
-	}
 
-	if (seg->policy_name) {
-		outf(f, "policy = \"%s\"", seg->policy_name);
-
-		if (seg->policy_settings) {
-			if (strcmp(seg->policy_settings->key, "policy_settings")) {
-				log_error(INTERNAL_ERROR "Incorrect policy_settings tree, %s.",
-					  seg->policy_settings->key);
-				return 0;
-			}
-			if (seg->policy_settings->child)
-				out_config_node(f, seg->policy_settings);
-		}
-	}
+	if (!_settings_text_export(seg, f))
+		return_0;
 
 	return 1;
 }


