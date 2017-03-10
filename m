From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:34:45 -0500
Subject: master - lvconvert: indent and code simplification
Message-ID: <201703101834.v2AIYjtZ020203@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ad57d55aff1f5647aed707fe22d2ff0d309d09d
Commit:        7ad57d55aff1f5647aed707fe22d2ff0d309d09d
Parent:        dd2881f277ab1ecb6510520b1504e17ad73c486c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 24 12:52:19 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvconvert: indent and code simplification

Simple modifications to existing  _lvconvert_to_pool().
---
 lib/metadata/cache_manip.c |    2 +-
 tools/lvconvert.c          |   24 ++++++++++--------------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index aee3db8..19008e3 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -292,7 +292,7 @@ int validate_lv_cache_create_pool(const struct logical_volume *pool_lv)
 
 	if (!dm_list_empty(&pool_lv->segs_using_this_lv)) {
 		seg = get_only_segment_using_this_lv(pool_lv);
-		log_error("Logical volume %s is already in use by %s",
+		log_error("Logical volume %s is already in use by %s.",
 			  display_lvname(pool_lv),
 			  seg ? display_lvname(seg->lv) : "another LV");
 		return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d5c8d49..4e8dbc8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2689,6 +2689,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	char *lockd_meta_name = NULL;
 	struct id lockd_data_id;
 	struct id lockd_meta_id;
+	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
 
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
@@ -2696,11 +2697,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	pool_segtype = to_cachepool ? get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE_POOL) :
-				      get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN_POOL);
+	pool_segtype = get_segtype_from_string(cmd, str_seg_type);
 
 	if (!pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
-		log_error("%s: Required device-mapper target(s) not detected in your kernel.", pool_segtype->name);
+		log_error("%s: Required device-mapper target(s) not detected in your kernel.",
+			  pool_segtype->name);
 		return 0;
 	}
 
@@ -2708,7 +2709,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	activate_pool = to_thinpool && lv_is_active(lv);
 
 	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
-	zero_metadata = to_cachepool ? arg_int_value(cmd, zero_ARG, 1) : 1;
+	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
 
 	/* An existing LV needs to have its lock freed once it becomes a data LV. */
 	if (is_lockd_type(vg->lock_type) && lv->lock_args) {
@@ -2787,10 +2788,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 		if (!validate_pool_chunk_size(cmd, pool_segtype, chunk_size))
 			return_0;
-	} else {
-		/* A default will be chosen by the "update" function. */
+	} else /* A default will be chosen by the "update" function. */
 		chunk_size = 0;
-	}
 
 	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
 		meta_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
@@ -2799,10 +2798,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	} else if (metadata_lv) {
 		meta_extents = metadata_lv->le_count;
 		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	} else {
-		/* A default will be chosen by the "update" function. */
+	} else /* A default will be chosen by the "update" function. */
 		meta_extents = 0;
-	}
 
 	/* Tell the "update" function to ignore these, they are handled below. */
 	passed_args |= PASS_ARG_DISCARDS | PASS_ARG_ZERO;
@@ -2935,6 +2932,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				log_error("Aborting. Failed to activate metadata lv.");
 				return 0;
 			}
+			metadata_lv->status &= ~LV_TEMPORARY;
 
 			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
 				log_error("Aborting. Failed to wipe metadata lv.");
@@ -3171,8 +3169,8 @@ revert_new_lv:
 }
 
 static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
-			    struct logical_volume *lv,
-			    struct logical_volume *cachepool_lv)
+				   struct logical_volume *lv,
+				   struct logical_volume *cachepool_lv)
 {
 	struct logical_volume *cache_lv;
 	cache_mode_t cache_mode = 0;
@@ -3894,7 +3892,6 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 			log_warn("WARNING: Reusing cache pool metadata %s for volume caching.",
 				 display_lvname(cachepool_lv));
 		}
-
 	}
 
 	/* When the lv arg is a thinpool, redirect command to data sub lv. */
@@ -4582,4 +4579,3 @@ int lvconvert(struct cmd_context *cmd, int argc, char **argv)
 		  cmd->command->command_index, cmd->command->command_id);
 	return ECMD_FAILED;
 }
-


