From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:40 +0000 (UTC)
Subject: master - cleanup: use extents to pass size to /lib
Message-ID: <20141103132340.9F8B3602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=913f025d3e481fc4ffe6ab7b29f7e7b27c0f1b19
Commit:        913f025d3e481fc4ffe6ab7b29f7e7b27c0f1b19
Parent:        d2e9802ba7eb48af8d78cee2420897201d57c406
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 13:04:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cleanup: use extents to pass size to /lib

Lib takes sizes in extens - do the same for pool_metadata.
---
 lib/metadata/cache_manip.c       |   27 +++++++++++++---------
 lib/metadata/metadata-exported.h |   14 ++++++------
 lib/metadata/pool_manip.c        |   19 +++++++---------
 lib/metadata/thin_manip.c        |   44 +++++++++++++++++++++----------------
 tools/lvconvert.c                |   10 +++++++-
 tools/lvcreate.c                 |   10 +++++---
 6 files changed, 70 insertions(+), 54 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index bff64a3..eba7a50 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -41,12 +41,13 @@ const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
 
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
-			     int passed_args, uint32_t data_extents,
-			     uint64_t *pool_metadata_size,
+			     int passed_args, uint32_t pool_data_extents,
+			     uint32_t *pool_metadata_extents,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
 	uint32_t extent_size = vg->extent_size;
+	uint64_t pool_metadata_size = *pool_metadata_extents * vg->extent_size;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
@@ -58,7 +59,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 	 * Default meta size is:
 	 * (Overhead + mapping size + hint size)
 	 */
-	min_meta_size = (uint64_t) data_extents * extent_size / *chunk_size;	/* nr_chunks */
+	min_meta_size = (uint64_t) pool_data_extents * extent_size / *chunk_size;	/* nr_chunks */
 	min_meta_size *= (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
 	min_meta_size = (min_meta_size + (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;	/* in sectors */
 	min_meta_size += DM_TRANSACTION_OVERHEAD * (1024 >> SECTOR_SHIFT);
@@ -67,23 +68,27 @@ int update_cache_pool_params(const struct segment_type *segtype,
 	if (min_meta_size % extent_size)
 		min_meta_size += extent_size - min_meta_size % extent_size;
 
-	if (!*pool_metadata_size)
-		*pool_metadata_size = min_meta_size;
+	if (!pool_metadata_size)
+		pool_metadata_size = min_meta_size;
 
-	if (*pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
-		*pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
+	if (pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
+		pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(vg->cmd, *pool_metadata_size));
-	} else if (*pool_metadata_size < min_meta_size) {
+				 display_size(vg->cmd, pool_metadata_size));
+	} else if (pool_metadata_size < min_meta_size) {
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Minimum required pool metadata size is %s "
 				 "(needs extra %s).",
 				 display_size(vg->cmd, min_meta_size),
-				 display_size(vg->cmd, min_meta_size - *pool_metadata_size));
-		*pool_metadata_size = min_meta_size;
+				 display_size(vg->cmd, min_meta_size - pool_metadata_size));
+		pool_metadata_size = min_meta_size;
 	}
 
+	if (!(*pool_metadata_extents =
+	      extents_from_size(vg->cmd, pool_metadata_size, extent_size)))
+		return_0;
+
 	return 1;
 }
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 723a9c1..ecab56e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -748,8 +748,8 @@ int validate_pool_chunk_size(struct cmd_context *cmd, const struct segment_type
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_pool_params(const struct segment_type *segtype,
 		       struct volume_group *vg, unsigned target_attr,
-		       int passed_args, uint32_t data_extents,
-		       uint64_t *pool_metadata_size,
+		       int passed_args, uint32_t pool_data_extents,
+		       uint32_t *pool_metadata_extents,
 		       int *chunk_size_calc_policy, uint32_t *chunk_size,
 		       thin_discards_t *discards, int *zero);
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
@@ -758,8 +758,8 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				  int *zero);
 int update_thin_pool_params(const struct segment_type *segtype,
 			    struct volume_group *vg, unsigned attr,
-			    int passed_args, uint32_t data_extents,
-			    uint64_t *pool_metadata_size,
+			    int passed_args, uint32_t pool_data_extents,
+			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, int *zero);
 int get_pool_discards(const char *str, thin_discards_t *discards);
@@ -767,7 +767,7 @@ const char *get_pool_discards_name(thin_discards_t discards);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   const char *name, uint32_t read_ahead,
 					   uint32_t stripes, uint32_t stripe_size,
-					   uint64_t size, alloc_policy_t alloc,
+					   uint32_t extents, alloc_policy_t alloc,
 					   struct dm_list *pvh);
 int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 			       struct dm_list *pvh, int poolmetadataspare);
@@ -1090,8 +1090,8 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv
 const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
-			     int passed_args, uint32_t data_extents,
-			     uint64_t *pool_metadata_size,
+			     int passed_args, uint32_t pool_data_extents,
+			     uint32_t *pool_metadata_extents,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
 int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
 int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index c7c07e5..7152c51 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -363,30 +363,30 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 
 int update_pool_params(const struct segment_type *segtype,
 		       struct volume_group *vg, unsigned target_attr,
-		       int passed_args, uint32_t data_extents,
-		       uint64_t *pool_metadata_size,
+		       int passed_args, uint32_t pool_data_extents,
+		       uint32_t *pool_metadata_extents,
 		       int *chunk_size_calc_policy, uint32_t *chunk_size,
 		       thin_discards_t *discards, int *zero)
 {
 	if (segtype_is_cache_pool(segtype) || segtype_is_cache(segtype)) {
 		if (!update_cache_pool_params(segtype, vg, target_attr, passed_args,
-					      data_extents, pool_metadata_size,
+					      pool_data_extents, pool_metadata_extents,
 					      chunk_size_calc_policy, chunk_size))
 			return_0;
 	} else if (!update_thin_pool_params(segtype, vg, target_attr, passed_args,
-					    data_extents, pool_metadata_size,
+					    pool_data_extents, pool_metadata_extents,
 					    chunk_size_calc_policy, chunk_size,
 					    discards, zero)) /* thin-pool */
 			return_0;
 
-	if ((uint64_t) *chunk_size > (uint64_t) data_extents * vg->extent_size) {
+	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * vg->extent_size) {
 		log_error("Size of %s data volume cannot be smaller then chunk size %s.",
 			  segtype->name, display_size(vg->cmd, *chunk_size));
 		return 0;
 	}
 
 	log_verbose("Using pool metadata size %s.",
-		    display_size(vg->cmd, *pool_metadata_size));
+		    display_size(vg->cmd, (uint64_t)*pool_metadata_extents * vg->extent_size));
 
 	return 1;
 }
@@ -518,7 +518,7 @@ bad:
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   const char *name, uint32_t read_ahead,
 					   uint32_t stripes, uint32_t stripe_size,
-					   uint64_t size, alloc_policy_t alloc,
+					   uint32_t extents, alloc_policy_t alloc,
 					   struct dm_list *pvh)
 {
 	struct logical_volume *metadata_lv;
@@ -526,6 +526,7 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_ALY,
 		.alloc = alloc,
+		.extents = extents,
 		.major = -1,
 		.minor = -1,
 		.permission = LVM_READ | LVM_WRITE,
@@ -538,10 +539,6 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.zero = 1,
 	};
 
-	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
-					      pool_lv->vg->extent_size)))
-		return_0;
-
 	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
 		return_0;
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b830350..8569ac1 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -396,14 +396,16 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 
 int update_thin_pool_params(const struct segment_type *segtype,
 			    struct volume_group *vg,
-			    unsigned attr, int passed_args, uint32_t data_extents,
-			    uint64_t *pool_metadata_size,
+			    unsigned attr, int passed_args,
+			    uint32_t pool_data_extents,
+			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, int *zero)
 {
 	struct cmd_context *cmd = vg->cmd;
 	struct profile *profile = vg->profile;
 	uint32_t extent_size = vg->extent_size;
+	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 	size_t estimate_chunk_size;
 	const char *str;
 
@@ -447,34 +449,34 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		return 0;
 	}
 
-	if (!*pool_metadata_size) {
+	if (!pool_metadata_size) {
 		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
-		*pool_metadata_size = (uint64_t) data_extents * extent_size /
+		pool_metadata_size = (uint64_t) pool_data_extents * extent_size /
 			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
 		/* Check if we could eventually use bigger chunk size */
 		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
-			while ((*pool_metadata_size >
+			while ((pool_metadata_size >
 				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
 			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
 				*chunk_size <<= 1;
-				*pool_metadata_size >>= 1;
+				pool_metadata_size >>= 1;
 			}
 			log_verbose("Setting chunk size to %s.",
 				    display_size(cmd, *chunk_size));
-		} else if (*pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
+		} else if (pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
 			/* Suggest bigger chunk size */
-			estimate_chunk_size = (uint64_t) data_extents * extent_size /
+			estimate_chunk_size = (uint64_t) pool_data_extents * extent_size /
 				(DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2 * (SECTOR_SIZE / UINT64_C(64)));
 			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
 				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
 		}
 
-		/* Round up to extent size */
-		if (*pool_metadata_size % extent_size)
-			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
+		/* Round up to extent size silently */
+		if (pool_metadata_size % extent_size)
+			pool_metadata_size += extent_size - pool_metadata_size % extent_size;
 	} else {
-		estimate_chunk_size = (uint64_t) data_extents * extent_size /
-			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		estimate_chunk_size = (uint64_t) pool_data_extents * extent_size /
+			(pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
 		if (estimate_chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
 			estimate_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
 		else if (estimate_chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
@@ -491,18 +493,22 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		}
 	}
 
-	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+	if (pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(cmd, *pool_metadata_size));
-	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+				 display_size(cmd, pool_metadata_size));
+	} else if (pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Minimum supported pool metadata size is %s.",
-				 display_size(cmd, *pool_metadata_size));
+				 display_size(cmd, pool_metadata_size));
 	}
 
+	if (!(*pool_metadata_extents =
+	      extents_from_size(vg->cmd, pool_metadata_size, extent_size)))
+		return_0;
+
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a512709..fbd8b04 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -65,6 +65,7 @@ struct lvconvert_params {
 
 	struct logical_volume *lv_to_poll;
 
+	uint32_t pool_metadata_extents;
 	int passed_args;
 	uint64_t pool_metadata_size;
 	const char *origin_name;
@@ -2743,12 +2744,17 @@ revert_new_lv:
 static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 					 struct lvconvert_params *lp)
 {
+	if (lp->pool_metadata_size &&
+	    !(lp->pool_metadata_extents =
+	      extents_from_size(pool_lv->vg->cmd, lp->pool_metadata_size, pool_lv->vg->extent_size)))
+		return_0;
+
 	return update_pool_params(lp->segtype,
 				  pool_lv->vg,
 				  lp->target_attr,
 				  lp->passed_args,
 				  pool_lv->le_count,
-				  &lp->pool_metadata_size,
+				  &lp->pool_metadata_extents,
 				  &lp->thin_chunk_size_calc_policy,
 				  &lp->chunk_size,
 				  &lp->discards,
@@ -3014,7 +3020,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
 							lp->read_ahead, lp->stripes,
 							lp->stripe_size,
-							lp->pool_metadata_size,
+							lp->pool_metadata_extents,
 							lp->alloc, lp->pvh)))
 			return_0;
 	} else {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b6768ba..2e01561 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -350,16 +350,18 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_pool) {
+		if (lp->pool_metadata_size &&
+		    !(lp->pool_metadata_extents =
+		      extents_from_size(vg->cmd, lp->pool_metadata_size, vg->extent_size)))
+			return_0;
+
 		if (!update_pool_params(lp->segtype, vg, lp->target_attr,
 					lp->passed_args, lp->extents,
-					&lp->pool_metadata_size,
+					&lp->pool_metadata_extents,
 					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
 					&lp->discards, &lp->zero))
 			return_0;
 
-		if (!(lp->pool_metadata_extents =
-		      extents_from_size(vg->cmd, lp->pool_metadata_size, vg->extent_size)))
-			return_0;
 		if (lcp->percent == PERCENT_FREE) {
 			if (lp->extents <= (2 * lp->pool_metadata_extents)) {
 				log_error("Not enough space for thin pool creation.");


