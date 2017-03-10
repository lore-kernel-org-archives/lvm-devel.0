From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:11 -0500
Subject: master - pool: split chunk size validation
Message-ID: <201703101835.v2AIZBxU020438@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acfc82ae29eea2b107fb97e4d6fd350b3347f925
Commit:        acfc82ae29eea2b107fb97e4d6fd350b3347f925
Parent:        375e4bb3dae71bad55359f22aec6061c0b5f4296
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 5 17:41:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

pool: split chunk size validation

Move cache and thin bits into their respective manipulation files.
When possible directly call respective chunk_size validator.
---
 lib/metadata/cache_manip.c       |   26 +++++++++++++++++++++++++-
 lib/metadata/merge.c             |    8 +++++---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/pool_manip.c        |   36 +++---------------------------------
 lib/metadata/thin_manip.c        |   26 +++++++++++++++++++++++++-
 5 files changed, 60 insertions(+), 38 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 19008e3..5779f2d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -196,7 +196,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 		return 0;
 	}
 
-	if (!validate_pool_chunk_size(vg->cmd, segtype, *chunk_size))
+	if (!validate_cache_chunk_size(vg->cmd, *chunk_size))
 		return_0;
 
 	min_meta_size = _cache_min_metadata_size((uint64_t) pool_data_extents * extent_size, *chunk_size);
@@ -333,6 +333,30 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	return 1;
 }
 
+int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size)
+{
+	const uint32_t min_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
+	const uint32_t max_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+	int r = 1;
+
+	if ((chunk_size < min_size) || (chunk_size > max_size)) {
+		log_error("Cache chunk size %s is not in the range %s to %s.",
+			  display_size(cmd, chunk_size),
+			  display_size(cmd, min_size),
+			  display_size(cmd, max_size));
+		r = 0;
+	}
+
+	if (chunk_size & (min_size - 1)) {
+		log_error("Cache chunk size %s must be a multiple of %s.",
+			  display_size(cmd, chunk_size),
+			  display_size(cmd, min_size));
+		r = 0;
+	}
+
+	return r;
+}
+
 /*
  * lv_cache_create
  * @pool
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f82e1e7..b600bc4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -339,6 +339,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			if (!seg->policy_name)
 				seg_error("is missing cache policy name");
 		}
+		if (!validate_cache_chunk_size(lv->vg->cmd, seg->chunk_size))
+			seg_error("has invalid chunk size.");
 	} else { /* !cache_pool */
 		if (seg->cache_mode)
 			seg_error("sets cache mode");
@@ -380,9 +382,6 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("is missing a pool metadata LV");
 		} else if (!(seg2 = first_seg(seg->metadata_lv)) || (find_pool_seg(seg2) != seg))
 			seg_error("metadata LV does not refer back to pool LV");
-
-		if (!validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size))
-			seg_error("has invalid chunk size.");
 	} else { /* !thin_pool && !cache_pool */
 		if (seg->metadata_lv)
 			seg_error("must not have pool metadata LV set");
@@ -394,6 +393,9 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 		if (lv_is_thin_volume(lv))
 			seg_error("is a thin volume that must not contain thin pool segment");
+
+		if (!validate_thin_pool_chunk_size(lv->vg->cmd, seg->chunk_size))
+			seg_error("has invalid chunk size.");
 	} else { /* !thin_pool */
 		if (seg->zero_new_blocks)
 			seg_error("sets zero_new_blocks");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index dce2d44..c80a3c5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -847,6 +847,8 @@ int thin_pool_feature_supported(const struct logical_volume *pool_lv, int featur
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 					       int passed_args,
 					       int chunk_size_calc_policy);
+int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
+int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_pool_chunk_size(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t chunk_size);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_pool_params(const struct segment_type *segtype,
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index a0fe11c..aea11b6 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -394,40 +394,10 @@ int validate_pool_chunk_size(struct cmd_context *cmd,
 			     const struct segment_type *segtype,
 			     uint32_t chunk_size)
 {
-	uint32_t min_size, max_size;
-	const char *name;
-	int r = 1;
-
-	if (segtype_is_cache(segtype) || segtype_is_cache_pool(segtype)) {
-		min_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
-		max_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
-		name = "Cache";
-	} else if (segtype_is_thin(segtype)) {
-		min_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-		max_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-		name = "Thin";
-	} else {
-		log_error(INTERNAL_ERROR "Cannot validate chunk size of "
-			  "%s segtype.", segtype->name);
-		return 0;
-	}
-
-	if ((chunk_size < min_size) || (chunk_size > max_size)) {
-		log_error("%s pool chunk size %s is not in the range %s to %s.",
-			  name, display_size(cmd, chunk_size),
-			  display_size(cmd, min_size),
-			  display_size(cmd, max_size));
-		r = 0;
-	}
-
-	if (chunk_size & (min_size - 1)) {
-		log_error("%s pool chunk size %s must be a multiple of %s.",
-			  name, display_size(cmd, chunk_size),
-			  display_size(cmd, min_size));
-		r = 0;
-	}
+	if (segtype_is_cache(segtype) || segtype_is_cache_pool(segtype))
+		return validate_cache_chunk_size(cmd, chunk_size);
 
-	return r;
+	return validate_thin_pool_chunk_size(cmd, chunk_size);
 }
 
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 27daf6a..7748cd3 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -622,7 +622,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		}
 	}
 
-	if (!validate_pool_chunk_size(cmd, segtype, *chunk_size))
+	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
 		return_0;
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {
@@ -830,3 +830,27 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 
 	return 1;
 }
+
+int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size)
+{
+	const uint32_t min_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+	const uint32_t max_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+	int r = 1;
+
+	if ((chunk_size < min_size) || (chunk_size > max_size)) {
+		log_error("Thin pool chunk size %s is not in the range %s to %s.",
+			  display_size(cmd, chunk_size),
+			  display_size(cmd, min_size),
+			  display_size(cmd, max_size));
+		r = 0;
+	}
+
+	if (chunk_size & (min_size - 1)) {
+		log_error("Thin pool chunk size %s must be a multiple of %s.",
+			  display_size(cmd, chunk_size),
+			  display_size(cmd, min_size));
+		r = 0;
+	}
+
+	return r;
+}


