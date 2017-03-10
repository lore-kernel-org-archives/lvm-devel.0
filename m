From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:49 -0500
Subject: master - cache: extend usability of cache_set_params
Message-ID: <201703101835.v2AIZnx4009236@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36003df7e39bd2b3faf7b9d3f651109ddf30cebb
Commit:        36003df7e39bd2b3faf7b9d3f651109ddf30cebb
Parent:        dcf038c7a616cb415ea55e3d19a1c1ee0d0086b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 27 14:53:45 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: extend usability of cache_set_params

Fix missing reset of '*settings' pointer when no args were given.

Handle cache_chunk settings like all other settings, so it is properly
updated only with non-zero settings and the existing cache-pool
chunk_size is not being reconfigured.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   28 ++++++++++++++++++++++++----
 lib/metadata/lv_manip.c    |    2 --
 tools/lvconvert.c          |    2 --
 tools/toollib.c            |   40 ++++++++++++++++++++++------------------
 5 files changed, 47 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index da541d2..00465cc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Improve cache_set_params support for chunk_size selection.
   Fix metadata profile allocation/cache_[mode|policy] setting.
   Fix missing support for using allocation/cache_pool_chunk_size setting.
   Upstream git moved to https://sourceware.org/git/?p=lvm2
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 92f368e..8d6896b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -772,6 +772,7 @@ int cache_set_params(struct lv_segment *seg,
 		     const struct dm_config_tree *policy_settings)
 {
 	struct lv_segment *pool_seg;
+	struct cmd_context *cmd = seg->lv->vg->cmd;
 
 	if (!cache_set_cache_mode(seg, mode))
 		return_0;
@@ -782,16 +783,35 @@ int cache_set_params(struct lv_segment *seg,
 	pool_seg = seg_is_cache(seg) ? first_seg(seg->pool_lv) : seg;
 
 	if (chunk_size) {
-		if (!validate_lv_cache_chunk_size(pool_seg->lv, chunk_size))
+		if (seg_is_cache(seg) &&
+		    !validate_lv_cache_chunk_size(pool_seg->lv, chunk_size))
 			return_0;
 		pool_seg->chunk_size = chunk_size;
-	} else {
-		/* TODO: some calc_policy solution for cache ? */
-		if (!recalculate_pool_chunk_size_with_dev_hints(pool_seg->lv, 0,
+	} else if (seg_is_cache(seg)) {
+		/* Chunk size in profile has priority over cache-pool chunk size */
+		if ((chunk_size = find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG,
+						       seg->lv->profile) * 2)) {
+			if (!validate_lv_cache_chunk_size(pool_seg->lv, chunk_size))
+				return_0;
+			if (pool_seg->chunk_size != chunk_size)
+				log_verbose("Replacing chunk size %s in cache pool %s with "
+					    "chunk size %s from profile.",
+					    display_size(cmd, pool_seg->chunk_size),
+					    display_lvname(seg->lv),
+					    display_size(cmd, chunk_size));
+			pool_seg->chunk_size = chunk_size;
+		}
+	} else if (seg_is_cache_pool(seg)) {
+		if (!pool_seg->chunk_size &&
+		    /* TODO: some calc_policy solution for cache ? */
+		    !recalculate_pool_chunk_size_with_dev_hints(pool_seg->lv,
 								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC))
 			return_0;
 	}
 
+	if (seg_is_cache(seg))
+		cache_check_for_warns(seg);
+
 	return 1;
 }
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6528811..e78a9ac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7887,8 +7887,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				      lp->policy_settings))
 			return_NULL; /* revert? */
 
-		cache_check_for_warns(first_seg(lv));
-
 		if (!lv_update_and_reload(lv)) {
 			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f7210cc..9641a16 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3193,8 +3193,6 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!cache_set_params(first_seg(cache_lv), chunk_size, cache_mode, policy_name, policy_settings))
 		goto_bad;
 
-	cache_check_for_warns(first_seg(cache_lv));
-
 	if (!lv_update_and_reload(cache_lv))
 		goto_bad;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 3c00045..bd19ac4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1358,14 +1358,19 @@ int get_cache_params(struct cmd_context *cmd,
 	struct dm_config_node *cn;
 	int ok = 0;
 
-	if (cache_mode)
-		*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNSELECTED);
+	if (arg_is_set(cmd, chunksize_ARG)) {
+		*chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 
-	if (name)
-		*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
+		if (!validate_cache_chunk_size(cmd, *chunk_size))
+			return_0;
 
-	if (!settings)
-		return 1;
+		log_very_verbose("Setting pool chunk size to %s.",
+				 display_size(cmd, *chunk_size));
+	}
+
+	*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNSELECTED);
+
+	*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
 
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
@@ -1386,23 +1391,22 @@ int get_cache_params(struct cmd_context *cmd,
 			goto_out;
 	}
 
-	if (!current)
-		return 1;
+	if (current) {
+		if (!(result = dm_config_flatten(current)))
+			goto_out;
 
-	if (!(result = dm_config_flatten(current)))
-		goto_out;
+		if (result->root) {
+			if (!(cn = dm_config_create_node(result, "policy_settings")))
+				goto_out;
 
-	if (result->root) {
-		if (!(cn = dm_config_create_node(result, "policy_settings")))
-			goto_out;
+			cn->child = result->root;
+			result->root = cn;
+		}
 
-		cn->child = result->root;
-		result->root = cn;
+		if (!_validate_cachepool_params(*name, result))
+			goto_out;
 	}
 
-	if (!_validate_cachepool_params(*name, result))
-		goto_out;
-
 	ok = 1;
 out:
 	if (!ok && result) {


