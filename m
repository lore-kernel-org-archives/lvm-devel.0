From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:00 +0000 (UTC)
Subject: master - toollib: get_cache_params
Message-ID: <20150812124100.3443B61086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=969ee25a74b50c42f9a2626b7b8991a3d60f750f
Commit:        969ee25a74b50c42f9a2626b7b8991a3d60f750f
Parent:        6cde12a013f006c1b27b878593fe0f1e73a5f79a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 23 15:35:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:18 2015 +0200

toollib: get_cache_params

Enhance  get_cache_params() to read common cache args.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    2 +-
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |   31 +++++++++----------------------
 tools/lvcreate.c                 |   19 +++++--------------
 tools/toollib.c                  |   18 +++++++++++++++---
 tools/toollib.h                  |    7 ++++---
 7 files changed, 36 insertions(+), 44 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index da0ef4d..7c35d13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Enhance toollib's get_cache_params().
   Runtime detect presence of cache smq policy.
   Add demo cache-mq  and cache-smq profiles.
   Add cmd profilable allocation/cache_policy,cache_settings,cache_mode.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7c1752a..03a866a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -901,7 +901,7 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
-	uint64_t feature_flags; /* cache */
+	const char *cache_mode; /* cache */
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 22a407a..a6ad343 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -690,7 +690,7 @@ static int _lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume
 		goto out;
 	}
 
-	if (!get_cache_policy_params(cmd, &name, &settings))
+	if (!get_cache_params(cmd, NULL, &name, &settings))
 		goto_out;
 	if (!lv_cache_set_policy(lv, name, settings))
 		goto_out;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3a7f9ae..d48af62 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -50,7 +50,7 @@ struct lvconvert_params {
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
-	uint64_t feature_flags; /* cache_pool */
+	const char *cache_mode; /* cache */
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */
 
@@ -299,26 +299,14 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 	} else if (!strcmp(type_str, "thin-pool"))
 		thinpool = 1;
 
-	if (cachepool) {
-		const char *cachemode = arg_str_value(cmd, cachemode_ARG, NULL);
-		if (!cachemode)
-			cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
-
-		if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
-			return_0;
-
-		if (!get_cache_policy_params(cmd, &lp->policy_name, &lp->policy_settings)) {
-			log_error("Failed to parse cache policy and/or settings.");
-			return 0;
-		}
-	} else {
-		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
-					 cachepool_ARG, cachemode_ARG, -1))
-			return_0;
-		if (lp->cache) {
-			log_error("--cache requires --cachepool.");
-			return 0;
-		}
+	if (lp->cache && !cachepool) {
+		log_error("--cache requires --cachepool.");
+		return 0;
+	}
+	if ((lp->cache || cachepool) &&
+	    !get_cache_params(cmd, &lp->cache_mode, &lp->policy_name, &lp->policy_settings)) {
+		log_error("Failed to parse cache policy and/or settings.");
+		return 0;
 	}
 
 	if (thinpool) {
@@ -3080,7 +3068,6 @@ mda_write:
 	seg->chunk_size = lp->chunk_size;
 	seg->discards = lp->discards;
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
-	seg->feature_flags = lp->feature_flags; /* cache-pool */
 
 	if ((lp->policy_name || lp->policy_settings) &&
 	    !lv_cache_set_policy(seg->lv, lp->policy_name, lp->policy_settings))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 12b5166..cc4ef20 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -567,21 +567,14 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 static int _read_cache_params(struct cmd_context *cmd,
 			      struct lvcreate_params *lp)
 {
-	const char *cachemode;
-
 	if (!seg_is_cache(lp) && !seg_is_cache_pool(lp))
 		return 1;
 
-	if (!(cachemode = arg_str_value(cmd, cachemode_ARG, NULL)))
-		cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
-
-	if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
-		return_0;
-
-	if (!get_cache_policy_params(cmd, &lp->policy_name, &lp->policy_settings)) {
-		log_error("Failed to parse cache policy and/or settings.");
-		return 0;
-	}
+	if (!get_cache_params(cmd,
+			      &lp->cache_mode,
+			      &lp->policy_name,
+			      &lp->policy_settings))
+		return_NULL;
 
 	return 1;
 }
@@ -1089,8 +1082,6 @@ static int _determine_cache_argument(struct volume_group *vg,
 		/* If cache args not given, use those from cache pool */
 		if (!arg_is_set(cmd, chunksize_ARG))
 			lp->chunk_size = first_seg(lv)->chunk_size;
-		if (!arg_is_set(cmd, cachemode_ARG))
-			lp->feature_flags = first_seg(lv)->feature_flags;
 	} else if (lv) {
 		/* Origin exists, create cache pool volume */
 		if (!validate_lv_cache_create_origin(lv))
diff --git a/tools/toollib.c b/tools/toollib.c
index 0d401e4..fde6c36 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1399,8 +1399,10 @@ static int _validate_cachepool_params(const char *name,
 	return 1;
 }
 
-int get_cache_policy_params(struct cmd_context *cmd, const char **name,
-			    struct dm_config_tree **settings)
+int get_cache_params(struct cmd_context *cmd,
+		     const char **mode,
+		     const char **name,
+		     struct dm_config_tree **settings)
 {
 	const char *str;
 	struct arg_value_group_list *group;
@@ -1408,7 +1410,14 @@ int get_cache_policy_params(struct cmd_context *cmd, const char **name,
 	struct dm_config_node *cn;
 	int ok = 0;
 
-	*name = arg_str_value(cmd, cachepolicy_ARG, DEFAULT_CACHE_POLICY);
+	if (mode)
+		*mode = arg_str_value(cmd, cachemode_ARG, NULL);
+
+	if (name)
+		*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
+
+	if (!settings)
+		return 1;
 
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
@@ -1429,6 +1438,9 @@ int get_cache_policy_params(struct cmd_context *cmd, const char **name,
 			goto_out;
 	}
 
+	if (!current)
+		return 1;
+
 	if (!(result = dm_config_flatten(current)))
 		goto_out;
 
diff --git a/tools/toollib.h b/tools/toollib.h
index c57cb84..2dc5ad7 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -190,9 +190,10 @@ int get_pool_params(struct cmd_context *cmd,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
-int get_cache_policy_params(struct cmd_context *cmd,
-			    const char **name,
-			    struct dm_config_tree **settings);
+int get_cache_params(struct cmd_context *cmd,
+		     const char **mode,
+		     const char **name,
+		     struct dm_config_tree **settings);
 
 int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	       struct logical_volume *lv, struct physical_volume *pv, int arg);


