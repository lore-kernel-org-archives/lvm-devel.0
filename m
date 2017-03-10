From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:24 -0500
Subject: master - pool: rework handling of passed args
Message-ID: <201703101836.v2AIaO3O032394@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d0793f0ec7c02fb4bec9ad092746e6fe027823f
Commit:        4d0793f0ec7c02fb4bec9ad092746e6fe027823f
Parent:        7c52d550e92ec82a44b7652c285642d46a35ca69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 16:24:28 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

pool: rework handling of passed args

As now we can properly recognize all paramerters for pool creation,
we may drop PASS_ARG_  defines and rely on '_UNSELECTED' or 0 entries
as being those without user given args.

When setting are not given on command line - 'update' function
fill them from profiles or configuration. For this  'profile' arg
was needed to be passed around and since  'VG' itself is not needed,
it's been all replaced with 'cmd, profile, extents_size' args.
---
 lib/metadata/cache_manip.c       |   57 +++++++++++++++++++-------------
 lib/metadata/lv_manip.c          |    3 +-
 lib/metadata/metadata-exported.h |   27 +++++++--------
 lib/metadata/pool_manip.c        |   24 ++++++-------
 lib/metadata/thin_manip.c        |   68 +++++++++++++++++++------------------
 tools/lvconvert.c                |   13 ++++---
 tools/lvcreate.c                 |   23 +++++++++---
 tools/toollib.c                  |   17 +++------
 tools/toollib.h                  |    1 -
 9 files changed, 123 insertions(+), 110 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 8d6896b..536a444 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -153,28 +153,30 @@ static uint64_t _cache_min_metadata_size(uint64_t data_size, uint32_t chunk_size
 	return min_meta_size;
 }
 
-int update_cache_pool_params(const struct segment_type *segtype,
-			     struct volume_group *vg, unsigned attr,
-			     int passed_args, uint32_t pool_data_extents,
+int update_cache_pool_params(struct cmd_context *cmd,
+			     struct profile *profile,
+			     uint32_t extent_size,
+			     const struct segment_type *segtype,
+			     unsigned attr,
+			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
-	uint32_t extent_size = vg->extent_size;
 	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 	uint64_t pool_data_size = (uint64_t) pool_data_extents * extent_size;
 	const uint64_t max_chunks =
-		get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, vg->profile);
+		get_default_allocation_cache_pool_max_chunks_CFG(cmd, profile);
 	/* min chunk size in a multiple of DM_CACHE_MIN_DATA_BLOCK_SIZE */
 	uint64_t min_chunk_size = (((pool_data_size + max_chunks - 1) / max_chunks +
 				    DM_CACHE_MIN_DATA_BLOCK_SIZE - 1) /
 				   DM_CACHE_MIN_DATA_BLOCK_SIZE) * DM_CACHE_MIN_DATA_BLOCK_SIZE;
 
-	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
-		if (!(*chunk_size = find_config_tree_int(vg->cmd, allocation_cache_pool_chunk_size_CFG,
-							 vg->profile) * 2))
-			*chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(vg->cmd,
-										       vg->profile);
+	if (!*chunk_size) {
+		if (!(*chunk_size = find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG,
+							 profile) * 2))
+			*chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd,
+										       profile);
 		if (*chunk_size < min_chunk_size) {
 			/*
 			 * When using more then 'standard' default,
@@ -182,25 +184,25 @@ int update_cache_pool_params(const struct segment_type *segtype,
 			 */
 			log_print_unless_silent("Using %s chunk size instead of default %s, "
 						"so cache pool has less then " FMTu64 " chunks.",
-						display_size(vg->cmd, min_chunk_size),
-						display_size(vg->cmd, *chunk_size),
+						display_size(cmd, min_chunk_size),
+						display_size(cmd, *chunk_size),
 						max_chunks);
 			*chunk_size = min_chunk_size;
 		} else
 			log_verbose("Setting chunk size to %s.",
-				    display_size(vg->cmd, *chunk_size));
+				    display_size(cmd, *chunk_size));
 	} else if (*chunk_size < min_chunk_size) {
 		log_error("Chunk size %s is less then required minimal chunk size %s "
 			  "for a cache pool of %s size and limit " FMTu64 " chunks.",
-			  display_size(vg->cmd, *chunk_size),
-			  display_size(vg->cmd, min_chunk_size),
-			  display_size(vg->cmd, pool_data_size),
+			  display_size(cmd, *chunk_size),
+			  display_size(cmd, min_chunk_size),
+			  display_size(cmd, pool_data_size),
 			  max_chunks);
 		log_error("To allow use of more chunks, see setting allocation/cache_pool_max_chunks.");
 		return 0;
 	}
 
-	if (!validate_cache_chunk_size(vg->cmd, *chunk_size))
+	if (!validate_cache_chunk_size(cmd, *chunk_size))
 		return_0;
 
 	min_meta_size = _cache_min_metadata_size((uint64_t) pool_data_extents * extent_size, *chunk_size);
@@ -214,22 +216,31 @@ int update_cache_pool_params(const struct segment_type *segtype,
 
 	if (pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
 		pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
-		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+		if (*pool_metadata_extents)
 			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(vg->cmd, pool_metadata_size));
+				 display_size(cmd, pool_metadata_size));
 	} else if (pool_metadata_size < min_meta_size) {
-		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+		if (*pool_metadata_extents)
 			log_warn("WARNING: Minimum required pool metadata size is %s "
 				 "(needs extra %s).",
-				 display_size(vg->cmd, min_meta_size),
-				 display_size(vg->cmd, min_meta_size - pool_metadata_size));
+				 display_size(cmd, min_meta_size),
+				 display_size(cmd, min_meta_size - pool_metadata_size));
 		pool_metadata_size = min_meta_size;
 	}
 
 	if (!(*pool_metadata_extents =
-	      extents_from_size(vg->cmd, pool_metadata_size, extent_size)))
+	      extents_from_size(cmd, pool_metadata_size, extent_size)))
 		return_0;
 
+	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * extent_size) {
+		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
+			  segtype->name, display_size(cmd, *chunk_size));
+		return 0;
+	}
+
+	log_verbose("Preferred pool metadata size %s.",
+		    display_size(cmd, (uint64_t)*pool_metadata_extents * extent_size));
+
 	return 1;
 }
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 120eb58..5475e7a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7677,8 +7677,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero_new_blocks;
 		first_seg(lv)->discards = lp->discards;
-		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
-								lp->thin_chunk_size_calc_policy)) {
+		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->thin_chunk_size_calc_policy)) {
 			stack;
 			goto revert_new_lv;
 		}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c0b6359..28dd2a6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -852,7 +852,6 @@ int pool_is_active(const struct logical_volume *pool_lv);
 int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
 int thin_pool_feature_supported(const struct logical_volume *pool_lv, int feature);
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
-					       int passed_args,
 					       int chunk_size_calc_policy);
 int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
@@ -870,9 +869,12 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				  int *zero);
 int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct profile *profile,
 						uint32_t *chunk_size, int *chunk_size_calc_method);
-int update_thin_pool_params(const struct segment_type *segtype,
-			    struct volume_group *vg, unsigned attr,
-			    int passed_args, uint32_t pool_data_extents,
+int update_thin_pool_params(struct cmd_context *cmd,
+			    struct profile *profile,
+			    uint32_t extent_size,
+			    const struct segment_type *segtype,
+			    unsigned attr,
+			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
@@ -952,14 +954,6 @@ struct lvcreate_params {
 
 	const char *lock_args;
 
-	/* Keep args given by the user on command line */
-	/* FIXME: create some more universal solution here */
-#define PASS_ARG_CHUNK_SIZE		0x01
-#define PASS_ARG_DISCARDS		0x02
-#define PASS_ARG_POOL_METADATA_SIZE	0x04
-#define PASS_ARG_ZERO			0x08
-	int passed_args;
-
 	uint32_t stripes; /* striped/RAID */
 	uint32_t stripe_size; /* striped/RAID */
 	uint32_t chunk_size; /* snapshot */
@@ -1281,9 +1275,12 @@ int cache_set_params(struct lv_segment *seg,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings);
 void cache_check_for_warns(const struct lv_segment *seg);
-int update_cache_pool_params(const struct segment_type *segtype,
-			     struct volume_group *vg, unsigned attr,
-			     int passed_args, uint32_t pool_data_extents,
+int update_cache_pool_params(struct cmd_context *cmd,
+			     struct profile *profile,
+			     uint32_t extent_size,
+			     const struct segment_type *segtype,
+			     unsigned attr,
+			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size);
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index aea11b6..3c938c1 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -401,7 +401,6 @@ int validate_pool_chunk_size(struct cmd_context *cmd,
 }
 
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
-					       int passed_args,
 					       int chunk_size_calc_policy)
 {
 	struct logical_volume *pool_data_lv;
@@ -409,24 +408,17 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 	struct physical_volume *pv;
 	struct cmd_context *cmd = pool_lv->vg->cmd;
 	unsigned long previous_hint = 0, hint = 0;
-	uint32_t default_chunk_size;
 	uint32_t min_chunk_size, max_chunk_size;
 
-	if (passed_args & PASS_ARG_CHUNK_SIZE)
-		return 1;
+	if (!chunk_size_calc_policy)
+		return 1; /* Chunk size was specified by user */
 
 	if (lv_is_thin_pool(pool_lv)) {
-		if (find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
-			return 1;
 		min_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
 		max_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-		default_chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, NULL);
 	} else if (lv_is_cache_pool(pool_lv)) {
-		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
-			return 1;
 		min_chunk_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
 		max_chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
-		default_chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd, NULL);
 	} else {
 		log_error(INTERNAL_ERROR "%s is not a pool logical volume.", display_lvname(pool_lv));
 		return 0;
@@ -464,13 +456,18 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 				display_size(cmd, hint), display_lvname(pool_lv),
 				display_size(cmd, min_chunk_size),
 				display_size(cmd, max_chunk_size));
-	else
-		first_seg(pool_lv)->chunk_size =
-			(hint >= default_chunk_size) ? hint : default_chunk_size;
+	else if (hint > first_seg(pool_lv)->chunk_size) {
+		log_debug_alloc("Updating chunk size %s for pool %s to %s.",
+				display_size(cmd, first_seg(pool_lv)->chunk_size),
+				display_lvname(pool_lv),
+				display_size(cmd, hint));
+		first_seg(pool_lv)->chunk_size = hint;
+	}
 
 	return 1;
 }
 
+#if 0
 int update_pool_params(const struct segment_type *segtype,
 		       struct volume_group *vg, unsigned target_attr,
 		       int passed_args, uint32_t pool_data_extents,
@@ -500,6 +497,7 @@ int update_pool_params(const struct segment_type *segtype,
 
 	return 1;
 }
+#endif
 
 int create_pool(struct logical_volume *pool_lv,
 		const struct segment_type *segtype,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index ee54d1a..ce5b95c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -615,35 +615,31 @@ int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct
 	return 1;
 }
 
-int update_thin_pool_params(const struct segment_type *segtype,
-			    struct volume_group *vg,
-			    unsigned attr, int passed_args,
+int update_thin_pool_params(struct cmd_context *cmd,
+			    struct profile *profile,
+			    uint32_t extent_size,
+			    const struct segment_type *segtype,
+			    unsigned attr,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks)
 {
-	struct cmd_context *cmd = vg->cmd;
-	struct profile *profile = vg->profile;
-	uint32_t extent_size = vg->extent_size;
 	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
-	size_t estimate_chunk_size;
+	uint32_t estimate_chunk_size;
 	const char *str;
 
-	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
-		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
-			if (!get_default_allocation_thin_pool_chunk_size(cmd, profile,
-									 chunk_size,
-									 chunk_size_calc_method))
-				return_0;
-		}
-	}
+	if (!*chunk_size &&
+	    find_config_tree_node(cmd, allocation_thin_pool_chunk_size_CFG, profile))
+		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
 
-	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
-		return_0;
+	if (*chunk_size && !(attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    !is_power_of_2(*chunk_size)) {
+		log_error("Chunk size must be a power of 2 for this thin target version.");
+		return 0;
+	}
 
-	if (discards &&
-	    (*discards == THIN_DISCARDS_UNSELECTED) &&
+	if ((*discards == THIN_DISCARDS_UNSELECTED) &&
 	    find_config_tree_node(cmd, allocation_thin_pool_discards_CFG, profile)) {
 		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
 			log_error(INTERNAL_ERROR "Could not find configuration.");
@@ -659,12 +655,6 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		*zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile)
 			? THIN_ZERO_YES : THIN_ZERO_NO;
 
-	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
-	    !is_power_of_2(*chunk_size)) {
-		log_error("Chunk size must be a power of 2 for this thin target version.");
-		return 0;
-	}
-
 	if (!pool_metadata_size) {
 		if (!*chunk_size) {
 			if (!get_default_allocation_thin_pool_chunk_size(cmd, profile,
@@ -704,7 +694,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 							   pool_metadata_size, attr);
 
 		/* Check to eventually use bigger chunk size */
-		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+		if (!*chunk_size) {
 			*chunk_size = estimate_chunk_size;
 			log_verbose("Setting chunk size %s.", display_size(cmd, *chunk_size));
 		} else if (*chunk_size < estimate_chunk_size) {
@@ -714,29 +704,41 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		}
 	}
 
+	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
+		return_0;
+
 	if (pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
 		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+		if (*pool_metadata_extents)
 			log_warn("WARNING: Maximum supported pool metadata size is %s.",
 				 display_size(cmd, pool_metadata_size));
 	} else if (pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
 		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+		if (*pool_metadata_extents)
 			log_warn("WARNING: Minimum supported pool metadata size is %s.",
 				 display_size(cmd, pool_metadata_size));
 	}
 
 	if (!(*pool_metadata_extents =
-	      extents_from_size(vg->cmd, pool_metadata_size, extent_size)))
+	      extents_from_size(cmd, pool_metadata_size, extent_size)))
 		return_0;
 
-	if (discards && (*discards == THIN_DISCARDS_UNSELECTED))
-		if (!set_pool_discards(discards, DEFAULT_THIN_POOL_DISCARDS))
-			return_0;
+	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * extent_size) {
+		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
+			  segtype->name, display_size(cmd, *chunk_size));
+		return 0;
+	}
 
-	if (zero_new_blocks && (*zero_new_blocks == THIN_ZERO_UNSELECTED))
+	if ((*discards == THIN_DISCARDS_UNSELECTED) &&
+	    !set_pool_discards(discards, DEFAULT_THIN_POOL_DISCARDS))
+		return_0;
+
+	if (*zero_new_blocks == THIN_ZERO_UNSELECTED)
 		*zero_new_blocks = (DEFAULT_THIN_POOL_ZERO) ? THIN_ZERO_YES : THIN_ZERO_NO;
 
+	log_verbose("Preferred pool metadata size %s.",
+		    display_size(cmd, (uint64_t)*pool_metadata_extents * extent_size));
+
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7500746..6950c07 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2673,7 +2673,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct segment_type *pool_segtype;          /* thinpool or cachepool */
 	struct lv_segment *seg;
 	unsigned int target_attr = ~0;
-	unsigned int passed_args = 0;
 	unsigned int activate_pool;
 	unsigned int zero_metadata;
 	uint64_t meta_size;
@@ -2790,7 +2789,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
-	if (!get_pool_params(cmd, pool_segtype, &passed_args,
+	if (!get_pool_params(cmd, pool_segtype,
 			     &meta_size, &pool_metadata_spare,
 			     &chunk_size, &discards, &zero_new_blocks))
 		goto_bad;
@@ -2812,15 +2811,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 */
 
 	if (to_cachepool) {
-		if (!update_cache_pool_params(pool_segtype, vg, target_attr,
-					      passed_args, lv->le_count,
+		if (!update_cache_pool_params(cmd, vg->profile, vg->extent_size,
+					      pool_segtype, target_attr,
+					      lv->le_count,
 					      &meta_extents,
 					      &chunk_calc,
 					      &chunk_size))
 			goto_bad;
 	} else {
-		if (!update_thin_pool_params(pool_segtype, vg, target_attr,
-					     passed_args, lv->le_count,
+		if (!update_thin_pool_params(cmd, vg->profile, vg->extent_size,
+					     pool_segtype, target_attr,
+					     lv->le_count,
 					     &meta_extents,
 					     &chunk_calc,
 					     &chunk_size,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 01bd4b6..52f01a7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -361,11 +361,22 @@ static int _update_extents_params(struct volume_group *vg,
 		      extents_from_size(vg->cmd, lp->pool_metadata_size, vg->extent_size)))
 			return_0;
 
-		if (!update_pool_params(lp->segtype, vg, lp->target_attr,
-					lp->passed_args, lp->extents,
-					&lp->pool_metadata_extents,
-					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
-					&lp->discards, &lp->zero))
+		if (segtype_is_thin_pool(lp->segtype) || segtype_is_thin(lp->segtype)) {
+			if (!update_thin_pool_params(vg->cmd, vg->profile, vg->extent_size,
+						     lp->segtype, lp->target_attr,
+						     lp->extents,
+						     &lp->pool_metadata_extents,
+						     &lp->thin_chunk_size_calc_policy,
+						     &lp->chunk_size,
+						     &lp->discards,
+						     &lp->zero_new_blocks))
+				return_0;
+		} else if (!update_cache_pool_params(vg->cmd, vg->profile, vg->extent_size,
+						     lp->segtype, lp->target_attr,
+						     lp->extents,
+						     &lp->pool_metadata_extents,
+						     &lp->thin_chunk_size_calc_policy,
+						     &lp->chunk_size))
 			return_0;
 
 		if (lcp->percent == PERCENT_FREE || lcp->percent == PERCENT_PVS) {
@@ -1078,7 +1089,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	    !_read_size_params(cmd, lp, lcp) ||
 	    !get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied) ||
 	    (lp->create_pool &&
-	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
+	     !get_pool_params(cmd, lp->segtype,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
 			      &lp->chunk_size, &lp->discards, &lp->zero_new_blocks)) ||
 	    !_read_cache_params(cmd, lp) ||
diff --git a/tools/toollib.c b/tools/toollib.c
index bd19ac4..8bb9c0a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1194,18 +1194,14 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
  */
 int get_pool_params(struct cmd_context *cmd,
 		    const struct segment_type *segtype,
-		    int *passed_args,
 		    uint64_t *pool_metadata_size,
 		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    thin_zero_t *zero_new_blocks)
 {
-	*passed_args = 0;
-
 	if (segtype_is_thin_pool(segtype) || segtype_is_thin(segtype)) {
 		if (arg_is_set(cmd, zero_ARG)) {
-			*passed_args |= PASS_ARG_ZERO;
 			*zero_new_blocks = arg_int_value(cmd, zero_ARG, 0) ? THIN_ZERO_YES : THIN_ZERO_NO;
 			log_very_verbose("%s pool zeroing.",
 					 (*zero_new_blocks == THIN_ZERO_YES) ? "Enabling" : "Disabling");
@@ -1213,7 +1209,6 @@ int get_pool_params(struct cmd_context *cmd,
 			*zero_new_blocks = THIN_ZERO_UNSELECTED;
 
 		if (arg_is_set(cmd, discards_ARG)) {
-			*passed_args |= PASS_ARG_DISCARDS;
 			*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 			log_very_verbose("Setting pool discards to %s.",
 					 get_pool_discards_name(*discards));
@@ -1236,7 +1231,6 @@ int get_pool_params(struct cmd_context *cmd,
 		return_0;
 
 	if (arg_is_set(cmd, chunksize_ARG)) {
-		*passed_args |= PASS_ARG_CHUNK_SIZE;
 		*chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 
 		if (!validate_pool_chunk_size(cmd, segtype, *chunk_size))
@@ -1244,7 +1238,8 @@ int get_pool_params(struct cmd_context *cmd,
 
 		log_very_verbose("Setting pool chunk size to %s.",
 				 display_size(cmd, *chunk_size));
-	}
+	} else
+		*chunk_size = 0;
 
 	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
 		if (arg_is_set(cmd, poolmetadata_ARG)) {
@@ -1252,13 +1247,13 @@ int get_pool_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
 		*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
 						       UINT64_C(0));
-	} else if (arg_is_set(cmd, poolmetadata_ARG))
-		*passed_args |= PASS_ARG_POOL_METADATA_SIZE; /* fixed size */
+	} else
+		*pool_metadata_size = 0;
+
 
-	/* TODO: default in lvm.conf ? */
+	/* TODO: default in lvm.conf and metadata profile ? */
 	*pool_metadata_spare = arg_int_value(cmd, poolmetadataspare_ARG,
 					     DEFAULT_POOL_METADATA_SPARE);
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 22ae491..d5fc0b6 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -209,7 +209,6 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 
 int get_pool_params(struct cmd_context *cmd,
 		    const struct segment_type *segtype,
-		    int *passed_args,
 		    uint64_t *pool_metadata_size,
 		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,


