From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:42:01 +0000 (UTC)
Subject: master - thin and cache: unify pool common code
Message-ID: <20140722204201.72D2E6024D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=894eda4707dbcf9e160922d95621703c0fa58f94
Commit:        894eda4707dbcf9e160922d95621703c0fa58f94
Parent:        8c56c5fbacf6a4e9a0130b6f1fdc5683d6f108ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 22 22:20:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:41:38 2014 +0200

thin and cache: unify pool common code

Fix get_pool_params to only read params.
Add poolmetadataspare option to get_pool_params.
Move all profile code into update_pool_params.
Move recalculate code into pool_manip.c
---
 WHATS_NEW                        |    1 +
 lib/config/config.c              |    6 +-
 lib/metadata/cache_manip.c       |   11 ++--
 lib/metadata/lv_manip.c          |  104 +++-------------------------------
 lib/metadata/metadata-exported.h |   24 +++++---
 lib/metadata/pool_manip.c        |  116 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/thin_manip.c        |   63 +++++++--------------
 tools/lvconvert.c                |   84 ++++++++-------------------
 tools/lvcreate.c                 |   57 +++++-------------
 tools/toollib.c                  |   69 +++++++++++++----------
 tools/toollib.h                  |    6 +-
 11 files changed, 253 insertions(+), 288 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c800dd0..88319bf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Improve code sharing for lvconvert and lvcreate and pools (cache & thin).
   Improve lvconvert --merge validation.
   Improve lvconvert --splitsnapshot validation.
   Add report/list_item_separator lvm.conf option.
diff --git a/lib/config/config.c b/lib/config/config.c
index 8148a18..a71cbdc 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1988,9 +1988,9 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 	}
 
 	if (!strcasecmp(str, "generic"))
-		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE;
+		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
 	else if (!strcasecmp(str, "performance"))
-		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE;
+		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
 	else {
 		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
 		return 0;
@@ -2001,5 +2001,5 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 
 int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile)
 {
-	return DEFAULT_CACHE_POOL_CHUNK_SIZE;
+	return DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
 }
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 8a5e5e3..e6b6551 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -23,14 +23,15 @@
 #include "defaults.h"
 
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
-			     int passed_args,
-			     uint32_t data_extents, uint32_t extent_size,
-			     int *chunk_size_calc_method, uint32_t *chunk_size,
-			     thin_discards_t *discards,
-			     uint64_t *pool_metadata_size, int *zero)
+			     int passed_args, uint32_t data_extents,
+			     uint64_t *pool_metadata_size,
+			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
 
+	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
+		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
+
 	if ((*chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)) {
 		log_error("Chunk size must be in the range %s to %s.",
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c55b31f..0d39166 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6040,97 +6040,6 @@ int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
 	return 1;
 }
 
-/* Greatest common divisor */
-static unsigned long _gcd(unsigned long n1, unsigned long n2)
-{
-	unsigned long remainder;
-
-	do {
-		remainder = n1 % n2;
-		n1 = n2;
-		n2 = remainder;
-	} while (n2);
-
-	return n1;
-}
-
-/* Least common multiple */
-static unsigned long _lcm(unsigned long n1, unsigned long n2)
-{
-	if (!n1 || !n2)
-		return 0;
-	return (n1 * n2) / _gcd(n1, n2);
-}
-
-static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *lp,
-						       struct logical_volume *pool_lv)
-{
-	struct logical_volume *pool_data_lv;
-	struct lv_segment *seg;
-	struct physical_volume *pv;
-	struct cmd_context *cmd = pool_lv->vg->cmd;
-	unsigned long previous_hint = 0, hint = 0;
-	uint32_t chunk_size = lp->chunk_size;
-	uint32_t default_chunk_size;
-	uint32_t min_chunk_size, max_chunk_size;
-
-	if (lp->passed_args & PASS_ARG_CHUNK_SIZE)
-		goto out;
-
-	if (seg_is_thin_pool(lp)) {
-		if (find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
-			goto out;
-
-		min_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-		max_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-		default_chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, NULL) * 2;
-	} else if (seg_is_cache_pool(lp)) {
-		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
-			goto out;
-		min_chunk_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
-		max_chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
-		default_chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd, NULL) * 2;
-	} else {
-		log_error(INTERNAL_ERROR "%s is not a thin pool or cache pool",
-			  pool_lv->name);
-		return 0;
-	}
-
-	pool_data_lv = seg_lv(first_seg(pool_lv), 0);
-
-	dm_list_iterate_items(seg, &pool_data_lv->segments) {
-		pv = seg_pv(seg, 0);
-		if (lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
-			hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
-		else
-			hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
-
-		if (!hint)
-			continue;
-		if (previous_hint)
-			hint = _lcm(previous_hint, hint);
-		previous_hint = hint;
-	}
-
-	if (!hint) {
-		log_debug_alloc("No usable device hint found while recalculating"
-				" thin pool chunk size for %s.", pool_lv->name);
-		goto out;
-	}
-
-	if ((hint < min_chunk_size) || (hint > max_chunk_size)) {
-		log_debug_alloc("Calculated chunk size value of %ld sectors for"
-				" thin pool %s is out of allowed range (%d-%d).",
-				hint, pool_lv->name,
-				min_chunk_size, max_chunk_size);
-	} else
-		chunk_size = (hint >= default_chunk_size) ?
-			hint : default_chunk_size;
-out:
-	first_seg(pool_lv)->chunk_size = chunk_size;
-	return 1;
-}
-
 static int _should_wipe_lv(struct lvcreate_params *lp, struct logical_volume *lv) {
 	int r = lp->zero | lp->wipe_signatures;
 
@@ -6496,16 +6405,21 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 	if (seg_is_cache_pool(lp)) {
-		if (!_recalculate_pool_chunk_size_with_dev_hints(lp, lv))
-			return_NULL;
+		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->feature_flags = lp->feature_flags;
-	} else if (seg_is_thin_pool(lp)) {
-		if (!_recalculate_pool_chunk_size_with_dev_hints(lp, lv))
+		/* TODO: some calc_policy solution for cache ? */
+		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
+								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC))
 			return_NULL;
+	} else if (seg_is_thin_pool(lp)) {
+		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
 		first_seg(lv)->discards = lp->discards;
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
 		first_seg(lv)->low_water_mark = 0;
+		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
+								lp->thin_chunk_size_calc_policy))
+			return_NULL;
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 		if (!(first_seg(lv)->device_id =
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9d7a653..fa96a1a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -703,17 +703,25 @@ struct logical_volume *find_pool_lv(const struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
 int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
 int thin_pool_feature_supported(const struct logical_volume *pool_lv, int feature);
+int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
+					       int passed_args,
+					       int chunk_size_calc_policy);
 int update_pool_lv(struct logical_volume *lv, int activate);
+int update_pool_params(const struct segment_type *segtype,
+		       struct volume_group *vg, unsigned target_attr,
+		       int passed_args, uint32_t data_extents,
+		       uint64_t *pool_metadata_size,
+		       int *chunk_size_calc_policy, uint32_t *chunk_size,
+		       thin_discards_t *discards, int *zero);
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
 				  int passed_args, int *chunk_size_calc_method,
 				  uint32_t *chunk_size, thin_discards_t *discards,
 				  int *zero);
 int update_thin_pool_params(struct volume_group *vg, unsigned attr,
-			    int passed_args,
-			    uint32_t data_extents, uint32_t extent_size,
+			    int passed_args, uint32_t data_extents,
+			    uint64_t *pool_metadata_size,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
-			    thin_discards_t *discards,
-			    uint64_t *pool_metadata_size, int *zero);
+			    thin_discards_t *discards, int *zero);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
@@ -1043,11 +1051,9 @@ int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv);
 
 /* ++  metadata/cache_manip.c */
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
-			     int passed_args,
-			     uint32_t data_extents, uint32_t extent_size,
-			     int *chunk_size_calc_method, uint32_t *chunk_size,
-			     thin_discards_t *discards,
-			     uint64_t *pool_metadata_size, int *zero);
+			     int passed_args, uint32_t data_extents,
+			     uint64_t *pool_metadata_size,
+			     int *chunk_size_calc_method, uint32_t *chunk_size);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index e32b109..0ed5d64 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -23,7 +23,9 @@
 #include "segtype.h"
 #include "lv_alloc.h"
 #include "defaults.h"
+#include "dev-type.h"
 #include "display.h"
+#include "toolcontext.h"
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
@@ -230,6 +232,120 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 	return pool_seg;
 }
 
+/* Greatest common divisor */
+static unsigned long _gcd(unsigned long n1, unsigned long n2)
+{
+	unsigned long remainder;
+
+	do {
+		remainder = n1 % n2;
+		n1 = n2;
+		n2 = remainder;
+	} while (n2);
+
+	return n1;
+}
+
+/* Least common multiple */
+static unsigned long _lcm(unsigned long n1, unsigned long n2)
+{
+	if (!n1 || !n2)
+		return 0;
+	return (n1 * n2) / _gcd(n1, n2);
+}
+
+int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
+					       int passed_args,
+					       int chunk_size_calc_policy)
+{
+	struct logical_volume *pool_data_lv;
+	struct lv_segment *seg;
+	struct physical_volume *pv;
+	struct cmd_context *cmd = pool_lv->vg->cmd;
+	unsigned long previous_hint = 0, hint = 0;
+	uint32_t default_chunk_size;
+	uint32_t min_chunk_size, max_chunk_size;
+
+	if (passed_args & PASS_ARG_CHUNK_SIZE)
+		return 1;
+
+	if (lv_is_thin_pool(pool_lv)) {
+		if (find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
+			return 1;
+		min_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		max_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		default_chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, NULL);
+	} else if (lv_is_cache_pool(pool_lv)) {
+		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
+			return 1;
+		min_chunk_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
+		max_chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+		default_chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd, NULL);
+	} else {
+		log_error(INTERNAL_ERROR "%s is not a pool logical volume.", display_lvname(pool_lv));
+		return 0;
+	}
+
+	pool_data_lv = seg_lv(first_seg(pool_lv), 0);
+	dm_list_iterate_items(seg, &pool_data_lv->segments) {
+		pv = seg_pv(seg, 0);
+		if (chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
+			hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
+		else
+			hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
+		if (!hint)
+			continue;
+		if (previous_hint)
+			hint = _lcm(previous_hint, hint);
+		previous_hint = hint;
+	}
+
+	if (!hint)
+		log_debug_alloc("No usable device hint found while recalculating "
+				"pool chunk size for %s.", display_lvname(pool_lv));
+	else if ((hint < min_chunk_size) || (hint > max_chunk_size))
+		log_debug_alloc("Calculated chunk size %s for pool %s "
+				"is out of allowed range (%s-%s).",
+				display_size(cmd, hint), display_lvname(pool_lv),
+				display_size(cmd, min_chunk_size),
+				display_size(cmd, max_chunk_size));
+	else
+		first_seg(pool_lv)->chunk_size =
+			(hint >= default_chunk_size) ? hint : default_chunk_size;
+
+	return 1;
+}
+
+int update_pool_params(const struct segment_type *segtype,
+		       struct volume_group *vg, unsigned target_attr,
+		       int passed_args, uint32_t data_extents,
+		       uint64_t *pool_metadata_size,
+		       int *chunk_size_calc_policy, uint32_t *chunk_size,
+		       thin_discards_t *discards, int *zero)
+{
+	if (segtype_is_cache_pool(segtype) || segtype_is_cache(segtype)) {
+		if (!update_cache_pool_params(vg, target_attr, passed_args,
+					      data_extents, pool_metadata_size,
+					      chunk_size_calc_policy, chunk_size))
+			return_0;
+	} else if (!update_thin_pool_params(vg, target_attr, passed_args,
+					    data_extents, pool_metadata_size,
+					    chunk_size_calc_policy, chunk_size,
+					    discards, zero)) /* thin-pool */
+			return_0;
+
+	if ((uint64_t) *chunk_size > (uint64_t) data_extents * vg->extent_size) {
+		log_error("Chunk size %s is bigger then pool data size.",
+			  display_size(vg->cmd, *chunk_size));
+		return 0;
+	}
+
+	log_verbose("Using pool metadata size %s.",
+		    display_size(vg->cmd, *pool_metadata_size));
+
+	return 1;
+}
+
 int create_pool(struct logical_volume *pool_lv,
 		const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size)
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 28b6bbf..07246f7 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -348,11 +348,16 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
-int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
-				  int passed_args, int *chunk_size_calc_method,
-				  uint32_t *chunk_size, thin_discards_t *discards,
-				  int *zero)
+int update_thin_pool_params(struct volume_group *vg,
+			    unsigned attr, int passed_args, uint32_t data_extents,
+			    uint64_t *pool_metadata_size,
+			    int *chunk_size_calc_method, uint32_t *chunk_size,
+			    thin_discards_t *discards, int *zero)
 {
+	struct cmd_context *cmd = vg->cmd;
+	struct profile *profile = vg->profile;
+	uint32_t extent_size = vg->extent_size;
+	size_t estimate_chunk_size;
 	const char *str;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
@@ -369,7 +374,8 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
 				return 0;
 			}
-			*chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, profile) * 2;
+			if (!(*chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, profile)))
+				return_0;
 		}
 	}
 
@@ -393,24 +399,6 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	if (!(passed_args & PASS_ARG_ZERO))
 		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
 
-	return 1;
-}
-
-int update_thin_pool_params(struct volume_group *vg, unsigned attr,
-			    int passed_args,
-			    uint32_t data_extents, uint32_t extent_size,
-			    int *chunk_size_calc_method, uint32_t *chunk_size,
-			    thin_discards_t *discards,
-			    uint64_t *pool_metadata_size, int *zero)
-{
-	size_t estimate_chunk_size;
-	struct cmd_context *cmd = vg->cmd;
-
-	if (!update_profilable_pool_params(cmd, vg->profile, passed_args,
-					   chunk_size_calc_method, chunk_size,
-					   discards, zero))
-		return_0;
-
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    (*chunk_size & (*chunk_size - 1))) {
 		log_error("Chunk size must be a power of 2 for this thin target version.");
@@ -435,11 +423,10 @@ int update_thin_pool_params(struct volume_group *vg, unsigned attr,
 			}
 			log_verbose("Setting chunk size to %s.",
 				    display_size(cmd, *chunk_size));
-		} else if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		} else if (*pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
 			/* Suggest bigger chunk size */
 			estimate_chunk_size = (uint64_t) data_extents * extent_size /
-				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
-				 (SECTOR_SIZE / UINT64_C(64)));
+				(DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2 * (SECTOR_SIZE / UINT64_C(64)));
 			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
 				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
 		}
@@ -448,19 +435,17 @@ int update_thin_pool_params(struct volume_group *vg, unsigned attr,
 		if (*pool_metadata_size % extent_size)
 			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
 	} else {
-		estimate_chunk_size =  (uint64_t) data_extents * extent_size /
+		estimate_chunk_size = (uint64_t) data_extents * extent_size /
 			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		if (estimate_chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
+			estimate_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		else if (estimate_chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
+			estimate_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+
 		/* Check to eventually use bigger chunk size */
 		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 			*chunk_size = estimate_chunk_size;
-
-			if (*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
-				*chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
-				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-
-			log_verbose("Setting chunk size %s.",
-				    display_size(cmd, *chunk_size));
+			log_verbose("Setting chunk size %s.", display_size(cmd, *chunk_size));
 		} else if (*chunk_size < estimate_chunk_size) {
 			/* Suggest bigger chunk size */
 			log_warn("WARNING: Chunk size is smaller then suggested minimum size %s.",
@@ -468,11 +453,6 @@ int update_thin_pool_params(struct volume_group *vg, unsigned attr,
 		}
 	}
 
-	if ((uint64_t) *chunk_size > (uint64_t) data_extents * extent_size) {
-		log_error("Chunk size is bigger then pool data size.");
-		return 0;
-	}
-
 	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
 		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
@@ -485,9 +465,6 @@ int update_thin_pool_params(struct volume_group *vg, unsigned attr,
 				 display_size(cmd, *pool_metadata_size));
 	}
 
-	log_verbose("Setting pool metadata size to %s.",
-		    display_size(cmd, *pool_metadata_size));
-
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 61b1660..333459d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -290,38 +290,24 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	if (thinpool || cachepool) {
 		if (arg_from_list_is_set(cmd, "is invalid with pools",
 					 merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
-					 splitmirrors_ARG, -1))
+					 splitmirrors_ARG, splitsnapshot_ARG, -1))
 			return_0;
 
-		if (arg_count(cmd, poolmetadatasize_ARG)) {
-			if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-				log_error("Negative pool metadata size is invalid.");
-				return 0;
-			}
-			if (arg_count(cmd, poolmetadata_ARG)) {
-				log_error("Please specify either metadata logical volume or its size.");
-				return 0;
-			}
-			/* value is read in get_pool_params() */
-		}
-
-		if ((lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
-			if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
-				log_error("Can't use --stripes and --stripesize with --poolmetadata.");
-				return 0;
-			}
+		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
+			return_0;
 
-			if (arg_count(cmd, readahead_ARG)) {
-				log_error("Can't use --readahead with --poolmetadata.");
-				return 0;
-			}
-		}
+		if (!get_pool_params(cmd, lp->segtype, &lp->passed_args,
+				     &lp->pool_metadata_size,
+				     &lp->poolmetadataspare,
+				     &lp->chunk_size, &lp->discards,
+				     &lp->zero))
+			return_0;
 
-		if (arg_count(cmd, chunksize_ARG) &&
-		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
+		if ((lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL)) &&
+		    arg_from_list_is_set(cmd, "is invalid with --poolmetadata",
+					 stripesize_ARG, stripes_long_ARG,
+					 readahead_ARG, -1))
+			return_0;
 
 		if (!lp->pool_data_lv_name) {
 			if (!*pargc) {
@@ -334,12 +320,11 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 
 		if (!lp->thin && !lp->cache)
 			lp->lv_name_full = lp->pool_data_lv_name;
+
 		/* Hmm _read_activation_params */
 		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 						cmd->default_settings.read_ahead);
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
-			return_0;
 	} else if (arg_from_list_is_set(cmd, "is valid only with pools",
 					poolmetadatasize_ARG, poolmetadataspare_ARG,
 					-1))
@@ -638,9 +623,6 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		} /* else segtype will default to current type */
 	}
 
-	/* TODO: default in lvm.conf ? */
-	lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
-					      DEFAULT_POOL_METADATA_SPARE);
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
@@ -2663,26 +2645,16 @@ revert_new_lv:
 static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 					 struct lvconvert_params *lp)
 {
-	if (seg_is_cache_pool(lp))
-		return update_cache_pool_params(pool_lv->vg, lp->target_attr,
-						lp->passed_args,
-						pool_lv->le_count,
-						pool_lv->vg->extent_size,
-						&lp->thin_chunk_size_calc_policy,
-						&lp->chunk_size,
-						&lp->discards,
-						&lp->pool_metadata_size,
-						&lp->zero);
-
-	return update_thin_pool_params(pool_lv->vg, lp->target_attr,
-				       lp->passed_args,
-				       pool_lv->le_count,
-				       pool_lv->vg->extent_size,
-				       &lp->thin_chunk_size_calc_policy,
-				       &lp->chunk_size,
-				       &lp->discards,
-				       &lp->pool_metadata_size,
-				       &lp->zero);
+	return update_pool_params(lp->segtype,
+				  pool_lv->vg,
+				  lp->target_attr,
+				  lp->passed_args,
+				  pool_lv->le_count,
+				  &lp->pool_metadata_size,
+				  &lp->thin_chunk_size_calc_policy,
+				  &lp->chunk_size,
+				  &lp->discards,
+				  &lp->zero);
 }
 
 /*
@@ -3156,12 +3128,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 	} else if (segtype_is_pool(lp->segtype) || lp->thin || lp->cache) {
-		if (!get_pool_params(cmd, lv_config_profile(lv),
-				     &lp->passed_args, &lp->thin_chunk_size_calc_policy,
-				     &lp->chunk_size, &lp->discards,
-				     &lp->pool_metadata_size, &lp->zero))
-			return_ECMD_FAILED;
-
 		if (!_lvconvert_pool(cmd, lv, lp))
 			return_ECMD_FAILED;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e9a170c..541fd51 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -267,20 +267,11 @@ static int _determine_snapshot_type(struct volume_group *vg,
 static int _lvcreate_update_pool_params(struct volume_group *vg,
 					struct lvcreate_params *lp)
 {
-	if (seg_is_cache_pool(lp))
-		return update_cache_pool_params(vg, lp->target_attr,
-						lp->passed_args,
-						lp->extents, vg->extent_size,
-						&lp->thin_chunk_size_calc_policy,
-						&lp->chunk_size, &lp->discards,
-						&lp->poolmetadatasize,
-						&lp->zero);
-
-	return update_thin_pool_params(vg, lp->target_attr, lp->passed_args,
-				       lp->extents, vg->extent_size,
-				       &lp->thin_chunk_size_calc_policy,
-				       &lp->chunk_size, &lp->discards,
-				       &lp->poolmetadatasize, &lp->zero);
+	return update_pool_params(lp->segtype, vg, lp->target_attr,
+				  lp->passed_args, lp->extents,
+				  &lp->poolmetadatasize,
+				  &lp->thin_chunk_size_calc_policy, &lp->chunk_size,
+				  &lp->discards, &lp->zero);
 }
 
 /*
@@ -320,9 +311,6 @@ static int _determine_cache_argument(struct volume_group *vg,
 	} else {
 		lp->pool = NULL;
 		lp->create_pool = 1;
-		lp->poolmetadataspare = arg_int_value(vg->cmd,
-						      poolmetadataspare_ARG,
-						      DEFAULT_POOL_METADATA_SPARE);
 	}
 
 	return 1;
@@ -505,7 +493,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 		lp->create_pool = 1;
 
 	if (!lp->create_pool && arg_count(cmd, poolmetadatasize_ARG)) {
-		log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
+		log_error("--poolmetadatasize may only be specified when allocating the pool.");
 		return 0;
 	}
 
@@ -705,14 +693,6 @@ static int _read_cache_pool_params(struct lvcreate_params *lp,
 	if (!segtype_is_cache_pool(lp->segtype))
 		return 1;
 
-	if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Negative chunk size is invalid.");
-		return 0;
-	}
-
-	lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
-					DEFAULT_CACHE_POOL_CHUNK_SIZE * 2);
-
 	if ((str_arg = arg_str_value(cmd, cachemode_ARG, NULL)) &&
 	    !get_cache_mode(str_arg, &lp->feature_flags))
 		return_0;
@@ -884,6 +864,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
+	else if (arg_count(cmd, cache_ARG) || arg_count(cmd, cachepool_ARG))
+		segtype_str = "cache";
 	else
 		segtype_str = "striped";
 
@@ -907,12 +889,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
 
-	if (seg_is_cache_pool(lp))
-		lp->create_pool = 1;
-
-	if (seg_is_thin_pool(lp)) {
+	if (seg_is_pool(lp)) {
 		if (lp->snapshot) {
-			log_error("Snapshots are incompatible with thin_pool segment_type.");
+			log_error("Snapshots are incompatible with pool segment_type.");
 			return 0;
 		}
 		lp->create_pool = 1;
@@ -1035,10 +1014,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_pool &&
-	     !get_pool_params(cmd, NULL, &lp->passed_args,
-			      &lp->thin_chunk_size_calc_policy,
-			      &lp->chunk_size, &lp->discards,
-			      &lp->poolmetadatasize, &lp->zero)) ||
+	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
+			      &lp->poolmetadatasize, &lp->poolmetadataspare,
+			      &lp->chunk_size, &lp->discards, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd) ||
 	    !_read_cache_pool_params(lp, cmd))
@@ -1061,12 +1039,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (lp->create_pool) {
-		/* TODO: add lvm.conf default y|n */
-		lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
-						      DEFAULT_POOL_METADATA_SPARE);
-	} else if (arg_count(cmd, poolmetadataspare_ARG)) {
-		log_error("--poolmetadataspare is only available with thin pool creation.");
+	if (!lp->create_pool &&
+	    arg_count(cmd, poolmetadataspare_ARG)) {
+		log_error("--poolmetadataspare is only available with pool creation.");
 		return 0;
 	}
 	/*
diff --git a/tools/toollib.c b/tools/toollib.c
index 312a76d..d6ef845 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1650,59 +1650,68 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * Read pool options from cmdline
+ */
 int get_pool_params(struct cmd_context *cmd,
-		    struct profile *profile,
+		    const struct segment_type *segtype,
 		    int *passed_args,
-		    int *chunk_size_calc_method,
+		    uint64_t *pool_metadata_size,
+		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
-		    uint64_t *pool_metadata_size,
 		    int *zero)
 {
-	int cache_pool = 0;
-
-	if (!strcmp("cache-pool", arg_str_value(cmd, type_ARG, "")))
-		cache_pool = 1;
-
 	*passed_args = 0;
-	if (!cache_pool && arg_count(cmd, zero_ARG)) {
-		*passed_args |= PASS_ARG_ZERO;
-		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-		log_very_verbose("Setting pool zeroing: %u", *zero);
-	}
 
-	if (!cache_pool && arg_count(cmd, discards_ARG)) {
-		*passed_args |= PASS_ARG_DISCARDS;
-		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
-		log_very_verbose("Setting pool discards: %s",
-				 get_pool_discards_name(*discards));
+	if (segtype_is_thin_pool(segtype) || segtype_is_thin(segtype)) {
+		if (arg_count(cmd, zero_ARG)) {
+			*passed_args |= PASS_ARG_ZERO;
+			*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+			log_very_verbose("Setting pool zeroing: %u", *zero);
+		}
+
+		if (arg_count(cmd, discards_ARG)) {
+			*passed_args |= PASS_ARG_DISCARDS;
+			*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
+			log_very_verbose("Setting pool discards: %s",
+					 get_pool_discards_name(*discards));
+		}
 	}
 
 	if (arg_count(cmd, chunksize_ARG)) {
+		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative chunk size is invalid.");
+			return 0;
+		}
+
 		*passed_args |= PASS_ARG_CHUNK_SIZE;
-		*chunk_size = arg_uint_value(cmd, chunksize_ARG, cache_pool ?
-					     DM_CACHE_MIN_DATA_BLOCK_SIZE :
-					     DM_THIN_MIN_DATA_BLOCK_SIZE);
+		*chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	}
 
-	if (cache_pool) {
-		//FIXME: add cache_pool support to update_profilable_pool_params
-		if (!(*passed_args & PASS_ARG_CHUNK_SIZE))
-			*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
-	} else if (!update_profilable_pool_params(cmd, profile, *passed_args,
-						  chunk_size_calc_method,
-						  chunk_size, discards, zero))
-		return_0;
-
 	if (arg_count(cmd, poolmetadatasize_ARG)) {
+		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative pool metadata size is invalid.");
+			return 0;
+		}
+
+		if (arg_count(cmd, poolmetadata_ARG)) {
+			log_error("Please specify either metadata logical volume or its size.");
+			return 0;
+		}
+
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
 		*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
 						       UINT64_C(0));
 	} else if (arg_count(cmd, poolmetadata_ARG))
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE; /* fixed size */
 
+	/* TODO: default in lvm.conf ? */
+	*pool_metadata_spare = arg_int_value(cmd, poolmetadataspare_ARG,
+					     DEFAULT_POOL_METADATA_SPARE);
+
 	return 1;
 }
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 54636ab..b51c637 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -125,12 +125,12 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);
 
 int get_pool_params(struct cmd_context *cmd,
-		    struct profile *profile,
+		    const struct segment_type *segtype,
 		    int *passed_args,
-		    int *chunk_size_calc_method,
+		    uint64_t *pool_metadata_size,
+		    int *pool_metadataspare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
-		    uint64_t *pool_metadata_size,
 		    int *zero);
 
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,


