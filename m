From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:31 -0500
Subject: master - cache: enable usage of --cachemetadataformat
Message-ID: <201703101837.v2AIbVSS019977@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d2b1a06603d09e815af5bf8687972a000683841
Commit:        4d2b1a06603d09e815af5bf8687972a000683841
Parent:        7b748b7cb88fc3a197df4453305173b4269c24c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 26 20:18:37 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: enable usage of --cachemetadataformat

lvcreate and lvconvert may select cache metadata format when caching LV.
By default lvm2 picks best available format.
---
 WHATS_NEW                        |    1 +
 lib/metadata/cache_manip.c       |   96 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c          |    2 +
 lib/metadata/metadata-exported.h |    2 +
 tools/lvchange.c                 |    3 +-
 tools/lvconvert.c                |   10 ++--
 tools/lvcreate.c                 |    2 +
 tools/toollib.c                  |    4 ++
 tools/toollib.h                  |    1 +
 9 files changed, 116 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4a5b0f6..1cc3e13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add option for lvcreate/lvconvert --cachemetadataformat auto|1|2.
   Support cache segment with configurable metadata format.
   Add allocation/cache_metadata_format profilable setttings.
   Use function cache_set_params() for both lvcreate and lvconvert.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a3e4d95..e7da899 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -675,6 +675,26 @@ static const char *_get_default_cache_policy(struct cmd_context *cmd)
 	return def;
 }
 
+/* Autodetect best available cache metadata format for a user */
+static cache_metadata_format_t _get_default_cache_metadata_format(struct cmd_context *cmd)
+{
+	const struct segment_type *segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE);
+	unsigned attr;
+	cache_metadata_format_t f;
+
+	if (!segtype ||
+	    !segtype->ops->target_present ||
+	    !segtype->ops->target_present(cmd, NULL, &attr)) {
+		f = CACHE_METADATA_FORMAT_1;
+		log_warn("WARNING: Cannot detect default cache metadata format, using format: %u.", f);
+	} else {
+		f = (attr & CACHE_FEATURE_METADATA2) ? CACHE_METADATA_FORMAT_2 : CACHE_METADATA_FORMAT_1;
+		log_debug_metadata("Detected default cache metadata format: %u.", f);
+	}
+
+	return f;
+}
+
 int cache_set_policy(struct lv_segment *seg, const char *name,
 		     const struct dm_config_tree *settings)
 {
@@ -774,11 +794,84 @@ out:
 }
 
 /*
+ * Sets metadata format on cache pool segment with these rules:
+ * 1. When 'cache-pool' segment is passed, sets only for selected formats (1 or 2).
+ * 2. For 'cache' segment passed in we know cache pool segment.
+ *      When passed format is 0 (UNSELECTED) with 'cache' segment - it's the moment
+ *      lvm2 has to figure out 'default' metadata format (1 or 2) from
+ *      configuration or profiles.
+ * 3. If still unselected or selected format is != 1, figure the best supported format
+ *    and either use it or validate users settings is possible.
+ *
+ * Reasoning: A user may create cache-pool and may or may not specify CMFormat.
+ * If the CMFormat has been selected (1 or 2) store this in metadata, otherwise
+ * for an unused cache-pool UNSELECTED CMFormat is used. When caching LV, CMFormat
+ * must be decided and from this moment it's always stored. To support backward
+ * compatibility 'CMFormat 1' is used when it is NOT specified for a cached LV in
+ * lvm2 metadata (no metadata_format=#F element in cache-pool segment).
+ */
+int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t format)
+{
+	cache_metadata_format_t best;
+	struct profile *profile = seg->lv->profile;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+	else if (seg_is_cache_pool(seg)) {
+		if (format == CACHE_METADATA_FORMAT_UNSELECTED)
+			return 1; /* Format can be selected later when caching LV */
+	} else {
+		log_error(INTERNAL_ERROR "Cannot set cache metadata format for non cache volume %s.",
+			  display_lvname(seg->lv));
+		return 0;
+	}
+
+	/* Check if we need to search for configured cache metadata format */
+	if (format == CACHE_METADATA_FORMAT_UNSELECTED) {
+		if (seg->cache_metadata_format != CACHE_METADATA_FORMAT_UNSELECTED)
+			return 1; /* Format already selected in cache pool */
+
+		/* Check configurations and profiles */
+		format = find_config_tree_int(seg->lv->vg->cmd, allocation_cache_metadata_format_CFG,
+					      profile);
+	}
+
+	/* See what is a 'best' available cache metadata format
+	 * when the specifed format is other then always existing CMFormat 1 */
+	if (format != CACHE_METADATA_FORMAT_1) {
+		best = _get_default_cache_metadata_format(seg->lv->vg->cmd);
+
+		/* Format was not selected, so use best present on a system */
+		if (format == CACHE_METADATA_FORMAT_UNSELECTED)
+			format = best;
+		else if (format != best) {
+			/* Format is not valid (Only Format 1 or 2 is supported ATM) */
+			log_error("Cache metadata format %u is not supported by kernel target.", format);
+			return 0;
+		}
+	}
+
+	switch (format) {
+	case CACHE_METADATA_FORMAT_2: seg->lv->status |= LV_METADATA_FORMAT; break;
+	case CACHE_METADATA_FORMAT_1: seg->lv->status &= ~LV_METADATA_FORMAT; break;
+	default:
+		log_error(INTERNAL_ERROR "Invalid cache metadata format %u for cache volume %s.",
+			  format, display_lvname(seg->lv));
+		return 0;
+	}
+
+	seg->cache_metadata_format = format;
+
+	return 1;
+}
+
+/*
  * Universal 'wrapper' function  do-it-all
  * to update all commonly specified cache parameters
  */
 int cache_set_params(struct lv_segment *seg,
 		     uint32_t chunk_size,
+		     cache_metadata_format_t format,
 		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings)
@@ -786,6 +879,9 @@ int cache_set_params(struct lv_segment *seg,
 	struct lv_segment *pool_seg;
 	struct cmd_context *cmd = seg->lv->vg->cmd;
 
+	if (!cache_set_metadata_format(seg, format))
+		return_0;
+
 	if (!cache_set_cache_mode(seg, mode))
 		return_0;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5068788..a249d29 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7664,6 +7664,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lv_is_cache_pool(lv)) {
 		if (!cache_set_params(first_seg(lv),
 				      lp->chunk_size,
+				      lp->cache_metadata_format,
 				      lp->cache_mode,
 				      lp->policy_name,
 				      lp->policy_settings)) {
@@ -7872,6 +7873,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		if (!cache_set_params(first_seg(lv),
 				      lp->chunk_size,
+				      lp->cache_metadata_format,
 				      lp->cache_mode,
 				      lp->policy_name,
 				      lp->policy_settings))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c11899d..3e6da63 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1267,10 +1267,12 @@ const char *display_cache_mode(const struct lv_segment *seg);
 const char *get_cache_mode_name(const struct lv_segment *cache_seg);
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode);
 int cache_set_cache_mode(struct lv_segment *cache_seg, cache_mode_t mode);
+int cache_set_metadata_format(struct lv_segment *cache_seg, cache_metadata_format_t format);
 int cache_set_policy(struct lv_segment *cache_seg, const char *name,
 		     const struct dm_config_tree *settings);
 int cache_set_params(struct lv_segment *seg,
 		     uint32_t chunk_size,
+		     cache_metadata_format_t format,
 		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3804041..abb557a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -622,6 +622,7 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 
 static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 {
+	cache_metadata_format_t format;
 	cache_mode_t mode;
 	const char *name;
 	struct dm_config_tree *settings = NULL;
@@ -632,7 +633,7 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 	if (lv_is_cache(lv))
 		pool_seg = first_seg(pool_seg->pool_lv);
 
-	if (!get_cache_params(cmd, &chunk_size, &mode, &name, &settings))
+	if (!get_cache_params(cmd, &chunk_size, &format, &mode, &name, &settings))
 		goto_out;
 
 	if ((mode != CACHE_MODE_UNSELECTED) &&
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6950c07..41d32df 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2679,6 +2679,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	uint32_t meta_extents;
 	uint32_t chunk_size;
 	int chunk_calc;
+	cache_metadata_format_t cache_metadata_format;
 	cache_mode_t cache_mode;
 	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
@@ -2795,7 +2796,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		goto_bad;
 
 	if (to_cachepool &&
-	    !get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
+	    !get_cache_params(cmd, &chunk_size, &cache_metadata_format, &cache_mode, &policy_name, &policy_settings))
 		goto_bad;
 
 	if (metadata_lv)
@@ -3020,7 +3021,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	/* Apply settings to the new pool seg */
 	if (to_cachepool) {
-		if (!cache_set_params(seg, chunk_size, cache_mode, policy_name, policy_settings))
+		if (!cache_set_params(seg, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
 			goto_bad;
 	} else {
 		seg->transaction_id = 0;
@@ -3127,6 +3128,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 {
 	struct logical_volume *cache_lv;
 	uint32_t chunk_size = 0;
+	cache_metadata_format_t cache_metadata_format;
 	cache_mode_t cache_mode;
 	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
@@ -3135,7 +3137,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
-	if (!get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
+	if (!get_cache_params(cmd, &chunk_size, &cache_metadata_format, &cache_mode, &policy_name, &policy_settings))
 		goto_bad;
 
 	if (!archive(lv->vg))
@@ -3144,7 +3146,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
 		goto_bad;
 
-	if (!cache_set_params(first_seg(cache_lv), chunk_size, cache_mode, policy_name, policy_settings))
+	if (!cache_set_params(first_seg(cache_lv), chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
 		goto_bad;
 
 	if (!lv_update_and_reload(cache_lv))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 52f01a7..f775290 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -645,6 +645,7 @@ static int _read_cache_params(struct cmd_context *cmd,
 
 	if (!get_cache_params(cmd,
 			      &lp->chunk_size,
+			      &lp->cache_metadata_format,
 			      &lp->cache_mode,
 			      &lp->policy_name,
 			      &lp->policy_settings))
@@ -787,6 +788,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	type_ARG
 
 #define CACHE_POOL_ARGS \
+	cachemetadataformat_ARG,\
 	cachemode_ARG,\
 	cachepool_ARG,\
 	cachepolicy_ARG,\
diff --git a/tools/toollib.c b/tools/toollib.c
index 8bb9c0a..1d7b01d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1343,6 +1343,7 @@ static int _validate_cachepool_params(const char *name,
 
 int get_cache_params(struct cmd_context *cmd,
 		     uint32_t *chunk_size,
+		     cache_metadata_format_t *cache_metadata_format,
 		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings)
@@ -1363,6 +1364,9 @@ int get_cache_params(struct cmd_context *cmd,
 				 display_size(cmd, *chunk_size));
 	}
 
+	*cache_metadata_format = (cache_metadata_format_t)
+		arg_uint_value(cmd, cachemetadataformat_ARG, CACHE_METADATA_FORMAT_UNSELECTED);
+
 	*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNSELECTED);
 
 	*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
diff --git a/tools/toollib.h b/tools/toollib.h
index d5fc0b6..0c9404c 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -221,6 +221,7 @@ int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtyp
 
 int get_cache_params(struct cmd_context *cmd,
 		     uint32_t *chunk_size,
+		     cache_metadata_format_t *format,
 		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings);


