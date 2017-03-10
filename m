From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:04 -0500
Subject: master - lvconvert: share function for cache params
Message-ID: <201703101836.v2AIa4oi004530@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46820bfff3f40d58d28500ce9caafb8625211597
Commit:        46820bfff3f40d58d28500ce9caafb8625211597
Parent:        298d12c4590ccca26b92e1457c72c6369a32d3e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 27 14:54:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvconvert: share function for cache params

Reuse same code for getting/setting cache parameters with lvcreate.

So there is single one place how to get vars from profiles and configs.

Variables declarations are moved to start of function and
there is no need to initialize them as they are always
defined by functions get_cache_params() and get_pool_params().
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |  101 ++++++++++++++--------------------------------------
 2 files changed, 28 insertions(+), 74 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 61b01b6..ef3ec3f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Use function cache_set_params() for both lvcreate and lvconvert.
   Skip rounding on cache chunk size boudary when create cache LV.
   Improve cache_set_params support for chunk_size selection.
   Fix metadata profile allocation/cache_[mode|policy] setting.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9641a16..7500746 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2680,7 +2680,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	uint32_t meta_extents;
 	uint32_t chunk_size;
 	int chunk_calc;
+	cache_mode_t cache_mode;
+	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
+	int pool_metadata_spare;
+	thin_discards_t discards;
+	thin_zero_t zero_new_blocks;
 	int r = 0;
 
 	/* for handling lvmlockd cases */
@@ -2692,7 +2697,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct id lockd_meta_id;
 	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
-
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
 		return 0;
@@ -2786,34 +2790,21 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * Determine the size of the metadata LV and the chunk size.  When an
-	 * existing LV is to be used for metadata, this introduces some
-	 * constraints/defaults.  When chunk_size=0 and/or meta_extents=0 are
-	 * passed to the "update params" function, defaults are calculated and
-	 * returned.
-	 */
+	if (!get_pool_params(cmd, pool_segtype, &passed_args,
+			     &meta_size, &pool_metadata_spare,
+			     &chunk_size, &discards, &zero_new_blocks))
+		goto_bad;
 
-	if (arg_is_set(cmd, chunksize_ARG)) {
-		passed_args |= PASS_ARG_CHUNK_SIZE;
-		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
-		if (!validate_pool_chunk_size(cmd, pool_segtype, chunk_size))
-			return_0;
-	} else /* A default will be chosen by the "update" function. */
-		chunk_size = 0;
+	if (to_cachepool &&
+	    !get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
+		goto_bad;
 
-	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
-		meta_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
-		meta_extents = extents_from_size(cmd, meta_size, vg->extent_size);
-		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	} else if (metadata_lv) {
+	if (metadata_lv)
 		meta_extents = metadata_lv->le_count;
-		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	} else /* A default will be chosen by the "update" function. */
-		meta_extents = 0;
-
-	/* Tell the "update" function to ignore these, they are handled below. */
-	passed_args |= PASS_ARG_DISCARDS | PASS_ARG_ZERO;
+	else if (meta_size)
+		meta_extents = extents_from_size(cmd, meta_size, vg->extent_size);
+	else
+		meta_extents = 0; /* A default will be chosen by the "update" function. */
 
 	/*
 	 * Validate and/or choose defaults for meta_extents and chunk_size,
@@ -2833,18 +2824,10 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					     &meta_extents,
 					     &chunk_calc,
 					     &chunk_size,
-					     NULL, NULL))
+					     &discards, &zero_new_blocks))
 			goto_bad;
 	}
 
-	if ((uint64_t)chunk_size > ((uint64_t)lv->le_count * vg->extent_size)) {
-		log_error("Pool data LV %s is too small (%s) for specified chunk size (%s).",
-			  display_lvname(lv),
-			  display_size(cmd, (uint64_t)lv->le_count * vg->extent_size),
-			  display_size(cmd, chunk_size));
-		goto bad;
-	}
-
 	if (metadata_lv && (meta_extents > metadata_lv->le_count)) {
 		log_error("Pool metadata LV %s is too small (%u extents) for required metadata (%u extents).",
 			  display_lvname(metadata_lv), metadata_lv->le_count, meta_extents);
@@ -3034,44 +3017,15 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * Apply settings to the new pool seg, from command line, from
-	 * defaults, sometimes adjusted.
-	 */
-
-	seg->transaction_id = 0;
-	seg->chunk_size = chunk_size;
-
+	/* Apply settings to the new pool seg */
 	if (to_cachepool) {
-		cache_mode_t cache_mode = 0;
-		const char *policy_name = NULL;
-
-		if (!get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
-			goto_bad;
-
-		if (cache_mode &&
-		    !cache_set_cache_mode(seg, cache_mode))
-			goto_bad;
-
-		if ((policy_name || policy_settings) &&
-		    !cache_set_policy(seg, policy_name, policy_settings))
+		if (!cache_set_params(seg, chunk_size, cache_mode, policy_name, policy_settings))
 			goto_bad;
 	} else {
-		const char *discards_name;
-
-		if (arg_is_set(cmd, zero_ARG))
-			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0) ? THIN_ZERO_YES : THIN_ZERO_NO;
-		else
-			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile) ? THIN_ZERO_YES : THIN_ZERO_NO;
-
-		if (arg_is_set(cmd, discards_ARG))
-			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-		else {
-			if (!(discards_name = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, vg->profile)))
-				goto_bad;
-			if (!set_pool_discards(&seg->discards, discards_name))
-				goto_bad;
-		}
+		seg->transaction_id = 0;
+		seg->chunk_size = chunk_size;
+		seg->discards = discards;
+		seg->zero_new_blocks = zero_new_blocks;
 	}
 
 	/*
@@ -3087,8 +3041,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	if (!handle_pool_metadata_spare(vg,
 					metadata_lv->le_count,
-					use_pvh,
-					arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE)))
+					use_pvh, pool_metadata_spare))
 		goto_bad;
 
 	if (!vg_write(vg) || !vg_commit(vg))
@@ -3173,8 +3126,8 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 {
 	struct logical_volume *cache_lv;
 	uint32_t chunk_size = 0;
-	cache_mode_t cache_mode = 0;
-	const char *policy_name = NULL;
+	cache_mode_t cache_mode;
+	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
 	int r = 0;
 


