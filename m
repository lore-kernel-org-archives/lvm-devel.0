From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:04 +0000 (UTC)
Subject: master - cache: api update
Message-ID: <20150812124104.63D206062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0c18fceb43d77b0a79685fc7b1c8bbe64df7e97
Commit:        f0c18fceb43d77b0a79685fc7b1c8bbe64df7e97
Parent:        22a1337a9ba1ebf73c3f0b27f621d9d8917bf6cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 11 14:01:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:32:24 2015 +0200

cache: api update

Change logic and naming of some internal API functions.

cache_set_mode() and cache_set_policy() both take segment.

cache mode is now correctly 'masked-in'.

If the passed segment is 'cache' segment - it will automatically
try to find 'defaults' according to profiles if the are NOT
specified on command line or they are NOT already set for cache-pool.

These defaults are never set for cache-pool.
---
 WHATS_NEW                        |    1 +
 lib/cache_segtype/cache.c        |   53 +++++++--------
 lib/metadata/cache_manip.c       |  129 ++++++++++++++++++++++++++++++--------
 lib/metadata/lv.c                |    2 +-
 lib/metadata/lv_manip.c          |   31 +++++++---
 lib/metadata/metadata-exported.h |    9 ++-
 lib/report/report.c              |    2 +-
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    8 ++-
 9 files changed, 166 insertions(+), 71 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7c35d13..7fcf49a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Enhance internal API cache_set_mode() and cache_set_policy().
   Enhance toollib's get_cache_params().
   Runtime detect presence of cache smq policy.
   Add demo cache-mq  and cache-smq profiles.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 93436a3..0526173 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -71,23 +71,15 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (dm_config_has_node(sn, "cache_mode")) {
 		if (!(str = dm_config_find_str(sn, "cache_mode", NULL)))
 			return SEG_LOG_ERROR("cache_mode must be a string in");
-		if (!set_cache_pool_feature(&seg->feature_flags, str))
+		if (!cache_set_mode(seg, str))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
-	} else
-		/* When missed in metadata, it's an old stuff - use writethrough */
-		seg->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+	}
 
 	if (dm_config_has_node(sn, "policy")) {
 		if (!(str = dm_config_find_str(sn, "policy", NULL)))
 			return SEG_LOG_ERROR("policy must be a string in");
 		if (!(seg->policy_name = dm_pool_strdup(mem, str)))
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
-	} else {
-		/* Cannot use 'just' default, so pick one */
-		seg->policy_name = DEFAULT_CACHE_POLICY; /* FIXME make configurable */
-		/* FIXME maybe here should be always 'mq' */
-		log_warn("WARNING: cache_policy undefined, using default \"%s\" policy.",
-			 seg->policy_name);
 	}
 
 	/*
@@ -136,28 +128,33 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 {
 	const char *cache_mode;
 
-	if (!(cache_mode = get_cache_pool_cachemode_name(seg)))
-		return_0;
-
-	if (!seg->policy_name) {
-		log_error(INTERNAL_ERROR "Policy name for %s is not defined.",
-			  display_lvname(seg->lv));
-		return 0;
-	}
-
 	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
-	outf(f, "cache_mode = \"%s\"", cache_mode);
-	outf(f, "policy = \"%s\"", seg->policy_name);
 
-	if (seg->policy_settings) {
-		if (strcmp(seg->policy_settings->key, "policy_settings")) {
-			log_error(INTERNAL_ERROR "Incorrect policy_settings tree, %s.",
-				  seg->policy_settings->key);
-			return 0;
+	/*
+	 * Cache pool used by a cache LV holds data. Not ideal,
+	 * but not worth to break backward compatibility, by shifting
+	 * content to cache segment
+	 */
+	if (cache_mode_is_set(seg)) {
+		if (!(cache_mode = get_cache_mode_name(seg)))
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
 		}
-		out_config_node(f, seg->policy_settings);
 	}
 
 	return 1;
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 91fcd3b..fbd0663 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -29,7 +29,17 @@
 #define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
 #define DM_MAX_HINT_WIDTH		(4+16)  /* bytes.  FIXME Configurable? */
 
-const char *get_cache_pool_cachemode_name(const struct lv_segment *seg)
+int cache_mode_is_set(const struct lv_segment *seg)
+{
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+
+	return (seg->feature_flags & (DM_CACHE_FEATURE_WRITEBACK |
+				      DM_CACHE_FEATURE_WRITETHROUGH |
+				      DM_CACHE_FEATURE_PASSTHROUGH)) ? 1 : 0;
+}
+
+const char *get_cache_mode_name(const struct lv_segment *seg)
 {
 	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
 		return "writeback";
@@ -46,19 +56,48 @@ const char *get_cache_pool_cachemode_name(const struct lv_segment *seg)
 	return NULL;
 }
 
-int set_cache_pool_feature(uint64_t *feature_flags, const char *str)
+int cache_set_mode(struct lv_segment *seg, const char *str)
 {
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	int id;
+	uint64_t mode;
+
+	if (!str && !seg_is_cache(seg))
+		return 1;			/* Defaults only for cache */
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+
+	if (!str) {
+		if (cache_mode_is_set(seg))
+			return 1;               /* Default already set in cache pool */
+
+		id = allocation_cache_mode_CFG;
+
+		/* If present, check backward compatible settings */
+		if (!find_config_node(cmd, cmd->cft, id) &&
+		    find_config_node(cmd, cmd->cft, allocation_cache_pool_cachemode_CFG))
+			id = allocation_cache_pool_cachemode_CFG;
+
+		str = find_config_tree_str(cmd, id, NULL);
+	}
+
 	if (!strcmp(str, "writeback"))
-		*feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+		mode = DM_CACHE_FEATURE_WRITEBACK;
 	else if (!strcmp(str, "writethrough"))
-		*feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-	else if (!strcmp(str, "passhrough"))
-		*feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
+		mode = DM_CACHE_FEATURE_WRITETHROUGH;
+	else if (!strcmp(str, "passthrough"))
+		mode = DM_CACHE_FEATURE_PASSTHROUGH;
 	else {
-		log_error("Cache pool feature \"%s\" is unknown.", str);
+		log_error("Cannot set unknown cache mode \"%s\".", str);
 		return 0;
 	}
 
+	seg->feature_flags &= ~(DM_CACHE_FEATURE_WRITEBACK |
+				DM_CACHE_FEATURE_WRITETHROUGH |
+				DM_CACHE_FEATURE_PASSTHROUGH);
+	seg->feature_flags |= mode;
+
 	return 1;
 }
 
@@ -395,36 +434,72 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 	return seg && lv_is_cache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
-int lv_cache_set_policy(struct logical_volume *lv, const char *name,
-			const struct dm_config_tree *settings)
+int cache_set_policy(struct lv_segment *seg, const char *name,
+		     const struct dm_config_tree *settings)
 {
 	struct dm_config_node *cn;
+	const struct dm_config_node *cns;
 	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
 	int r = 0;
-	struct lv_segment *seg = first_seg(lv);
+	const int passed_seg_is_cache = seg_is_cache(seg);
 
-	if (lv_is_cache(lv))
+	if (passed_seg_is_cache)
 		seg = first_seg(seg->pool_lv);
 
-	if (seg->policy_settings) {
-		if (!(old = dm_config_create()))
-			goto_out;
-		if (!(new = dm_config_create()))
-			goto_out;
-		new->root = settings->root;
-		old->root = seg->policy_settings;
-		new->cascade = old;
-		if (!(tmp = dm_config_flatten(new)))
+	if (name) {
+		if (!(seg->policy_name = dm_pool_strdup(seg->lv->vg->vgmem, name))) {
+			log_error("Failed to duplicate policy name.");
+			return 0;
+		}
+	} else if (!seg->policy_name && passed_seg_is_cache)
+		seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG, NULL);
+
+	if (settings) {
+		if (!seg->policy_name) {
+			log_error(INTERNAL_ERROR "Can't set policy settings without policy name.");
+			return 0;
+		}
+
+		if (seg->policy_settings) {
+			if (!(old = dm_config_create()))
+				goto_out;
+			if (!(new = dm_config_create()))
+				goto_out;
+			new->root = settings->root;
+			old->root = seg->policy_settings;
+			new->cascade = old;
+			if (!(tmp = dm_config_flatten(new)))
+				goto_out;
+		}
+
+		if ((cn = dm_config_find_node((tmp) ? tmp->root : settings->root, "policy_settings")) &&
+		    !(seg->policy_settings = dm_config_clone_node_with_mem(seg->lv->vg->vgmem, cn, 0)))
 			goto_out;
-	}
+	} else if (passed_seg_is_cache && /* Look for command's profile cache_policies */
+		   (cns = find_config_tree_node(seg->lv->vg->cmd, allocation_cache_settings_CFG_SECTION, NULL))) {
+		/* Try to find our section for given policy */
+		for (cn = cns->child; cn; cn = cn->sib) {
+			/* Only matching section names */
+			if (cn->v || strcmp(cn->key, seg->policy_name) != 0)
+				continue;
+
+			if (!cn->child)
+				break;
+
+			if (!(new = dm_config_create()))
+				goto_out;
 
-	if ((cn = dm_config_find_node((tmp) ? tmp->root : settings->root, "policy_settings")) &&
-	    !(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, cn, 0)))
-		goto_out;
+			if (!(new->root = dm_config_clone_node_with_mem(new->mem,
+									cn->child, 1)))
+				goto_out;
 
-	if (name && !(seg->policy_name = dm_pool_strdup(lv->vg->vgmem, name))) {
-		log_error("Failed to duplicate policy name.");
-		goto out;
+			if (!(seg->policy_settings = dm_config_create_node(new, "policy_settings")))
+				goto_out;
+
+			seg->policy_settings->child = new->root;
+
+			break; /* Only first match counts */
+		}
 	}
 
 restart: /* remove any 'default" nodes */
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index df784c1..c775077 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -131,7 +131,7 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	const char *name = get_cache_pool_cachemode_name(seg);
+	const char *name = get_cache_mode_name(seg);
 
 	if (!name)
 		return_NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b22773e..f13df1b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7264,17 +7264,26 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	memlock_unlock(vg->cmd);
 
 	if (seg_is_cache_pool(lp) || seg_is_cache(lp)) {
-		pool_lv = pool_lv ? : lv;
-		if (!lv_cache_set_policy(pool_lv, lp->policy_name, lp->policy_settings))
-			return_NULL; /* revert? */
-		first_seg(pool_lv)->chunk_size = lp->chunk_size;
-		first_seg(pool_lv)->feature_flags = lp->feature_flags;
-		/* TODO: some calc_policy solution for cache ? */
-		if (!recalculate_pool_chunk_size_with_dev_hints(pool_lv, lp->passed_args,
-								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC)) {
+		if (!cache_set_mode(first_seg(lv), lp->cache_mode)) {
+			stack;
+			goto revert_new_lv;
+		}
+
+		if (!cache_set_policy(first_seg(lv), lp->policy_name, lp->policy_settings)) {
 			stack;
 			goto revert_new_lv;
 		}
+
+		pool_lv = pool_lv ? : lv;
+		if (lp->chunk_size) {
+			first_seg(pool_lv)->chunk_size = lp->chunk_size;
+			/* TODO: some calc_policy solution for cache ? */
+			if (!recalculate_pool_chunk_size_with_dev_hints(pool_lv, lp->passed_args,
+									THIN_CHUNK_SIZE_CALC_METHOD_GENERIC)) {
+				stack;
+				goto revert_new_lv;
+			}
+		}
 	} else if (seg_is_raid(lp)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
@@ -7478,6 +7487,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		lv = tmp_lv;
 
+		if (!cache_set_mode(first_seg(lv), lp->cache_mode))
+			return_NULL; /* revert? */
+
+		if (!cache_set_policy(first_seg(lv), lp->policy_name, lp->policy_settings))
+			return_NULL; /* revert? */
+
 		if (!lv_update_and_reload(lv)) {
 			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 03a866a..fff24f0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1153,8 +1153,11 @@ struct lv_status_cache {
 	dm_percent_t dirty_usage;
 };
 
-const char *get_cache_pool_cachemode_name(const struct lv_segment *seg);
-int set_cache_pool_feature(uint64_t *feature_flags, const char *str);
+const char *get_cache_mode_name(const struct lv_segment *cache_seg);
+int cache_mode_is_set(const struct lv_segment *seg);
+int cache_set_mode(struct lv_segment *cache_seg, const char *str);
+int cache_set_policy(struct lv_segment *cache_seg, const char *name,
+		     const struct dm_config_tree *settings);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t pool_data_extents,
@@ -1165,8 +1168,6 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int lv_cache_set_policy(struct logical_volume *cache_lv, const char *name,
-			const struct dm_config_tree *settings);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/lib/report/report.c b/lib/report/report.c
index c2ab991..a17af32 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2079,7 +2079,7 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_cache_pool(seg)) {
-		if (!(cachemode_str = get_cache_pool_cachemode_name(seg)))
+		if (!(cachemode_str = get_cache_mode_name(seg)))
 			return_0;
 
 		return dm_report_field_string(rh, field, &cachemode_str);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index a6ad343..e24c07a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -692,7 +692,7 @@ static int _lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume
 
 	if (!get_cache_params(cmd, NULL, &name, &settings))
 		goto_out;
-	if (!lv_cache_set_policy(lv, name, settings))
+	if (!cache_set_policy(first_seg(lv), name, settings))
 		goto_out;
 	if (!lv_update_and_reload(lv))
 		goto_out;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d48af62..040272a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3070,7 +3070,7 @@ mda_write:
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
 
 	if ((lp->policy_name || lp->policy_settings) &&
-	    !lv_cache_set_policy(seg->lv, lp->policy_name, lp->policy_settings))
+	    !cache_set_policy(seg, lp->policy_name, lp->policy_settings))
 		return_0;
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
@@ -3178,6 +3178,12 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
 		return_0;
 
+	if (!cache_set_mode(first_seg(cache_lv), lp->cache_mode))
+		return_0;
+
+	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
+		return_0;
+
 	if (!lv_update_and_reload(cache_lv))
 		return_0;
 


