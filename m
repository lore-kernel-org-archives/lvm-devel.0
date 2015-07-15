From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:50 +0000 (UTC)
Subject: master - cache: handle policy_name separately
Message-ID: <20150715111050.E31AF609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9e35b011e084616f97ede9a31305259e70f883d
Commit:        e9e35b011e084616f97ede9a31305259e70f883d
Parent:        86a4d47215570517804fa0e7acedf8d0473c5e07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 15 11:06:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cache: handle policy_name separately

Keep policy name separate from policy settings and avoid
to mangling and demangling this string from same config tree.
Ensure policy_name is always defined.
---
 WHATS_NEW                        |    1 +
 lib/metadata/cache_manip.c       |   28 +++++++++++++++-------------
 lib/metadata/lv_manip.c          |    5 +----
 lib/metadata/metadata-exported.h |    6 ++++--
 tools/lvchange.c                 |   14 ++++++++------
 tools/lvconvert.c                |   13 +++++++++++++
 tools/lvcreate.c                 |   19 +++++++++----------
 tools/toollib.c                  |   32 ++++++++++++--------------------
 tools/toollib.h                  |    4 +++-
 9 files changed, 66 insertions(+), 56 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca50a1e..43fa004 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix handling of cache policy name.
   Set cache policy before with the first lvm2 cache pool metadata commit.
   Fix detection of thin-pool overprovisioning (2.02.124).
   Fix lvmpolld segfaults on 32 bit architectures.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5a93031..91fcd3b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -395,13 +395,13 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 	return seg && lv_is_cache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
-int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
+int lv_cache_set_policy(struct logical_volume *lv, const char *name,
+			const struct dm_config_tree *settings)
 {
-	struct lv_segment *seg = first_seg(lv);
-	const char *name;
 	struct dm_config_node *cn;
 	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
 	int r = 0;
+	struct lv_segment *seg = first_seg(lv);
 
 	if (lv_is_cache(lv))
 		seg = first_seg(seg->pool_lv);
@@ -411,20 +411,21 @@ int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
 			goto_out;
 		if (!(new = dm_config_create()))
 			goto_out;
-		new->root = policy->root;
+		new->root = settings->root;
 		old->root = seg->policy_settings;
 		new->cascade = old;
-		if (!(tmp = policy = dm_config_flatten(new)))
+		if (!(tmp = dm_config_flatten(new)))
 			goto_out;
 	}
 
-	if ((cn = dm_config_find_node(policy->root, "policy_settings")) &&
+	if ((cn = dm_config_find_node((tmp) ? tmp->root : settings->root, "policy_settings")) &&
 	    !(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, cn, 0)))
 		goto_out;
 
-	if ((name = dm_config_find_str(policy->root, "policy", NULL)) &&
-	    !(seg->policy_name = dm_pool_strdup(lv->vg->vgmem, name)))
-		goto_out;
+	if (name && !(seg->policy_name = dm_pool_strdup(lv->vg->vgmem, name))) {
+		log_error("Failed to duplicate policy name.");
+		goto out;
+	}
 
 restart: /* remove any 'default" nodes */
 	cn = seg->policy_settings ? seg->policy_settings->child : NULL;
@@ -439,12 +440,13 @@ restart: /* remove any 'default" nodes */
 	r = 1;
 
 out:
-	if (old)
-		dm_config_destroy(old);
-	if (new)
-		dm_config_destroy(new);
 	if (tmp)
 		dm_config_destroy(tmp);
+	if (new)
+		dm_config_destroy(new);
+	if (old)
+		dm_config_destroy(old);
+
 	return r;
 }
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b2e5601..19d0ca7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7245,7 +7245,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_cache_pool(lp) || seg_is_cache(lp)) {
 		pool_lv = pool_lv ? : lv;
-		if (!lv_cache_setpolicy(pool_lv, lp->cache_policy))
+		if (!lv_cache_set_policy(pool_lv, lp->policy_name, lp->policy_settings))
 			return_NULL; /* revert? */
 		first_seg(pool_lv)->chunk_size = lp->chunk_size;
 		first_seg(pool_lv)->feature_flags = lp->feature_flags;
@@ -7458,9 +7458,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		lv = tmp_lv;
 
-		if (lp->cache_policy && !lv_cache_setpolicy(lv, lp->cache_policy))
-			return NULL; /* revert? */
-
 		if (!lv_update_and_reload(lv)) {
 			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 80e3ca3..7c1752a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -902,7 +902,8 @@ struct lvcreate_params {
 	uint32_t max_recovery_rate; /* RAID */
 
 	uint64_t feature_flags; /* cache */
-	struct dm_config_tree *cache_policy; /* cache */
+	const char *policy_name; /* cache */
+	struct dm_config_tree *policy_settings; /* cache */
 
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */
@@ -1164,7 +1165,8 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int lv_cache_setpolicy(struct logical_volume *cache_lv, struct dm_config_tree *pol);
+int lv_cache_set_policy(struct logical_volume *cache_lv, const char *name,
+			const struct dm_config_tree *settings);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 939614e..58e0fb2 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -680,25 +680,27 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 
 static int _lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	struct dm_config_tree *policy = NULL;
+	const char *name;
+	struct dm_config_tree *settings = NULL;
 	int r = 0;
 
 	if (!lv_is_cache(lv) && !lv_is_cache_pool(lv)) {
 		log_error("LV %s is not a cache LV.", lv->name);
 		log_error("Only cache or cache pool devices can have --cachepolicy set.");
-		goto_out;
+		goto out;
 	}
 
-	if (!(policy = get_cachepolicy_params(cmd)))
+	if (!get_cache_policy_params(cmd, &name, &settings))
 		goto_out;
-	if (!lv_cache_setpolicy(lv, policy))
+	if (!lv_cache_set_policy(lv, name, settings))
 		goto_out;
 	if (!lv_update_and_reload(lv))
 		goto_out;
 	r = 1;
 out:
-	if (policy)
-		dm_config_destroy(policy);
+	if (settings)
+		dm_config_destroy(settings);
+
 	return r;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e824e8c..e673f53 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -52,6 +52,8 @@ struct lvconvert_params {
 	uint32_t stripe_size;
 	uint32_t read_ahead;
 	uint64_t feature_flags; /* cache_pool */
+	const char *policy_name; /* cache */
+	struct dm_config_tree *policy_settings; /* cache */
 
 	const struct segment_type *segtype;
 	unsigned target_attr;
@@ -297,6 +299,11 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 
 		if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
 			return_0;
+
+		if (!get_cache_policy_params(cmd, &lp->policy_name, &lp->policy_settings)) {
+			log_error("Failed to parse cache policy and/or settings.");
+			return 0;
+		}
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
 					 cachepool_ARG, cachemode_ARG, -1))
@@ -3053,6 +3060,10 @@ mda_write:
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
 	seg->feature_flags = lp->feature_flags; /* cache-pool */
 
+	if ((lp->policy_name || lp->policy_settings) &&
+	    !lv_cache_set_policy(seg->lv, lp->policy_name, lp->policy_settings))
+		return_0;
+
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
 	if (lp->pool_metadata_name &&
@@ -3523,6 +3534,8 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	} else
 		ret = lvconvert_single(cmd, &lp);
 out:
+	if (lp.policy_settings)
+		dm_config_destroy(lp.policy_settings);
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 4019b5d..2595130 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -578,6 +578,11 @@ static int _read_cache_params(struct cmd_context *cmd,
 	if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
 		return_0;
 
+	if (!get_cache_policy_params(cmd, &lp->policy_name, &lp->policy_settings)) {
+		log_error("Failed to parse cache policy and/or settings.");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -1036,13 +1041,6 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) &&
-	    !(lp->cache_policy = get_cachepolicy_params(cmd)))
-	{
-		log_error("Failed to parse cache policy and/or settings.");
-		return 0;
-	}
-
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(current_group->arg_values, addtag_ARG))
 			continue;
@@ -1439,9 +1437,10 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 
 static void _destroy_lvcreate_params(struct lvcreate_params *lp)
 {
-	if (lp->cache_policy)
-		dm_config_destroy(lp->cache_policy);
-	lp->cache_policy = NULL;
+	if (lp->policy_settings) {
+		dm_config_destroy(lp->policy_settings);
+		lp->policy_settings = NULL;
+	}
 }
 
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
diff --git a/tools/toollib.c b/tools/toollib.c
index 76fc63d..7bbe897 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1393,12 +1393,14 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 	return _validate_stripe_params(cmd, stripes, stripe_size);
 }
 
-static int _validate_cachepool_params(struct dm_config_tree *tree)
+static int _validate_cachepool_params(const char *name,
+				      const struct dm_config_tree *settings)
 {
 	return 1;
 }
 
-struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
+int get_cache_policy_params(struct cmd_context *cmd, const char **name,
+			    struct dm_config_tree **settings)
 {
 	const char *str;
 	struct arg_value_group_list *group;
@@ -1406,12 +1408,13 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 	struct dm_config_node *cn;
 	int ok = 0;
 
+	*name = arg_str_value(cmd, cachepolicy_ARG, DEFAULT_CACHE_POOL_POLICY);
+
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
 			continue;
 
-		current = dm_config_create();
-		if (!current)
+		if (!(current = dm_config_create()))
 			goto_out;
 		if (prev)
 			current->cascade = prev;
@@ -1437,24 +1440,10 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 		result->root = cn;
 	}
 
-	if (arg_count(cmd, cachepolicy_ARG)) {
-		if (!(cn = dm_config_create_node(result, "policy")))
-			goto_out;
-
-		cn->sib = result->root;
-		result->root = cn;
-		if (!(cn->v = dm_config_create_value(result)))
-			goto_out;
-
-		cn->v->type = DM_CFG_STRING;
-		cn->v->v.str = arg_str_value(cmd, cachepolicy_ARG, NULL);
-	}
-
-	if (!_validate_cachepool_params(result))
+	if (!_validate_cachepool_params(*name, result))
 		goto_out;
 
 	ok = 1;
-
 out:
 	if (!ok && result) {
 		dm_config_destroy(result);
@@ -1465,7 +1454,10 @@ out:
 		dm_config_destroy(prev);
 		prev = current;
 	}
-	return result;
+
+	*settings = result;
+
+	return ok;
 }
 
 /* FIXME move to lib */
diff --git a/tools/toollib.h b/tools/toollib.h
index 75eed87..c57cb84 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -190,7 +190,9 @@ int get_pool_params(struct cmd_context *cmd,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
-struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd);
+int get_cache_policy_params(struct cmd_context *cmd,
+			    const char **name,
+			    struct dm_config_tree **settings);
 
 int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	       struct logical_volume *lv, struct physical_volume *pv, int arg);


