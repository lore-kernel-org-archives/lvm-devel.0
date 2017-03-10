From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:34 -0500
Subject: master - lvconvert: replacing with goto
Message-ID: <201703101835.v2AIZYls004128@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=861992d874a7f42619559bf3768750977b4b1446
Commit:        861992d874a7f42619559bf3768750977b4b1446
Parent:        2d11fc695e7c2baff1b919fb9f92e491e49d5db1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 18:10:35 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvconvert: replacing with goto

Split-off patch that just replaces returns with 'goto bad'
so there is single place to release  policy_settings.

In the next patch we will start to use some shared
function call between lvconvert and lvcreate
(effectively restoring previous logic which has got lost).
---
 tools/lvconvert.c |   84 +++++++++++++++++++++++++++--------------------------
 1 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4ed5018..45c5a49 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2680,6 +2680,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	uint32_t meta_extents;
 	uint32_t chunk_size;
 	int chunk_calc;
+	struct dm_config_tree *policy_settings = NULL;
 	int r = 0;
 
 	/* for handling lvmlockd cases */
@@ -2825,7 +2826,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					      &meta_extents,
 					      &chunk_calc,
 					      &chunk_size))
-			return_0;
+			goto_bad;
 	} else {
 		if (!update_thin_pool_params(pool_segtype, vg, target_attr,
 					     passed_args, lv->le_count,
@@ -2833,7 +2834,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					     &chunk_calc,
 					     &chunk_size,
 					     NULL, NULL))
-			return_0;
+			goto_bad;
 	}
 
 	if ((uint64_t)chunk_size > ((uint64_t)lv->le_count * vg->extent_size)) {
@@ -2841,13 +2842,13 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			  display_lvname(lv),
 			  display_size(cmd, (uint64_t)lv->le_count * vg->extent_size),
 			  display_size(cmd, chunk_size));
-		return 0;
+		goto bad;
 	}
 
 	if (metadata_lv && (meta_extents > metadata_lv->le_count)) {
 		log_error("Pool metadata LV %s is too small (%u extents) for required metadata (%u extents).",
 			  display_lvname(metadata_lv), metadata_lv->le_count, meta_extents);
-		return 0;
+		goto bad;
 	}
 
 	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
@@ -2875,7 +2876,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			  metadata_lv ? " and " : "",
 			  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
 		log_error("Conversion aborted.");
-		return 0;
+		goto bad;
 	}
 
 	/*
@@ -2898,13 +2899,13 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				       &meta_stripe_size,
 				       &meta_stripes_supplied,
 				       &meta_stripe_size_supplied))
-			return_0;
+			goto_bad;
 
 		meta_readahead = arg_uint_value(cmd, readahead_ARG, cmd->default_settings.read_ahead);
 		meta_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 		if (!archive(vg))
-			return_0;
+			goto_bad;
 
 		if (!(metadata_lv = alloc_pool_metadata(lv,
 							meta_name,
@@ -2914,28 +2915,28 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 							meta_extents,
 							meta_alloc,
 							use_pvh)))
-			return_0;
+			goto_bad;
 	} else {
 		if (!deactivate_lv(cmd, metadata_lv)) {
 			log_error("Aborting. Failed to deactivate %s.",
 				  display_lvname(metadata_lv));
-			return 0;
+			goto bad;
 		}
 
 		if (!archive(vg))
-			return_0;
+			goto_bad;
 
 		if (zero_metadata) {
 			metadata_lv->status |= LV_TEMPORARY;
 			if (!activate_lv_local(cmd, metadata_lv)) {
 				log_error("Aborting. Failed to activate metadata lv.");
-				return 0;
+				goto bad;
 			}
 			metadata_lv->status &= ~LV_TEMPORARY;
 
 			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
 				log_error("Aborting. Failed to wipe metadata lv.");
-				return 0;
+				goto bad;
 			}
 		}
 	}
@@ -2948,13 +2949,13 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (!deactivate_lv(cmd, metadata_lv)) {
 		log_error("Aborting. Failed to deactivate metadata lv. "
 			  "Manual intervention required.");
-		return 0;
+		goto bad;
 	}
 
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Aborting. Failed to deactivate logical volume %s.",
 			  display_lvname(lv));
-		return 0;
+		goto bad;
 	}
 
 	/*
@@ -2984,7 +2985,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 */
 
 	if (!lv_rename_update(cmd, data_lv, data_name, 0))
-		return_0;
+		goto_bad;
 
 	/*
 	 * Create LV structures for the new pool LV object,
@@ -2995,14 +2996,14 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					(to_cachepool ? CACHE_POOL : THIN_POOL) | VISIBLE_LV | LVM_READ | LVM_WRITE,
 					ALLOC_INHERIT, vg))) {
 		log_error("Creation of pool LV failed.");
-		return 0;
+		goto bad;
 	}
 
 	/* Allocate a new pool segment */
 	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count, 0,
 				     pool_lv->status, 0, NULL, 1,
 				     data_lv->le_count, 0, 0, 0, 0, NULL)))
-		return_0;
+		goto_bad;
 
 	/* Add the new segment to the layer LV */
 	dm_list_add(&pool_lv->segments, &seg->list);
@@ -3010,7 +3011,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	pool_lv->size = data_lv->size;
 
 	if (!attach_pool_data_lv(seg, data_lv))
-		return_0;
+		goto_bad;
 
 	/*
 	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock.
@@ -3044,21 +3045,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (to_cachepool) {
 		cache_mode_t cache_mode = 0;
 		const char *policy_name = NULL;
-		struct dm_config_tree *policy_settings = NULL;
 
 		if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
-			return_0;
+			goto_bad;
 
 		if (cache_mode &&
 		    !cache_set_cache_mode(seg, cache_mode))
-			return_0;
+			goto_bad;
 
 		if ((policy_name || policy_settings) &&
 		    !cache_set_policy(seg, policy_name, policy_settings))
-			return_0;
-
-		if (policy_settings)
-			dm_config_destroy(policy_settings);
+			goto_bad;
 	} else {
 		const char *discards_name;
 
@@ -3071,9 +3068,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
 		else {
 			if (!(discards_name = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, vg->profile)))
-				return_0;
+				goto_bad;
 			if (!set_pool_discards(&seg->discards, discards_name))
-				return_0;
+				goto_bad;
 		}
 	}
 
@@ -3083,19 +3080,19 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 */
 	if (pool_metadata_name &&
 	    !lv_rename_update(cmd, metadata_lv, meta_name, 0))
-		return_0;
+		goto_bad;
 
 	if (!attach_pool_metadata_lv(seg, metadata_lv))
-		return_0;
+		goto_bad;
 
 	if (!handle_pool_metadata_spare(vg,
 					metadata_lv->le_count,
 					use_pvh,
 					arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE)))
-		return_0;
+		goto_bad;
 
 	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
+		goto_bad;
 
 	if ((seg->zero_new_blocks == THIN_ZERO_YES) &&
 	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
@@ -3146,6 +3143,9 @@ out:
 			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
 		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
 	}
+bad:
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
 
 	return r;
 #if 0
@@ -3175,37 +3175,39 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	cache_mode_t cache_mode = 0;
 	const char *policy_name = NULL;
 	struct dm_config_tree *policy_settings = NULL;
+	int r = 0;
 
 	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
 	if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
-		return_0;
+		goto_bad;
 
 	if (!archive(lv->vg))
-		return_0;
+		goto_bad;
 
 	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
-		return_0;
+		goto_bad;
 
 	if (!cache_set_cache_mode(first_seg(cache_lv), cache_mode))
-		return_0;
+		goto_bad;
 
 	if (!cache_set_policy(first_seg(cache_lv), policy_name, policy_settings))
-		return_0;
-
-	if (policy_settings)
-		dm_config_destroy(policy_settings);
+		goto_bad;
 
 	cache_check_for_warns(first_seg(cache_lv));
 
 	if (!lv_update_and_reload(cache_lv))
-		return_0;
+		goto_bad;
 
 	log_print_unless_silent("Logical volume %s is now cached.",
 				display_lvname(cache_lv));
+	r = 1;
+bad:
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
 
-	return 1;
+	return r;
 }
 
 static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_context *cmd,


