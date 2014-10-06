From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:36 +0000 (UTC)
Subject: master - pool: use validation
Message-ID: <20141006133336.ABF2F61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59ced3c28186e6d45e2e8374b04e32256f636a82
Commit:        59ced3c28186e6d45e2e8374b04e32256f636a82
Parent:        a2aa609810d7d0d6b8ff5b9fe8c6e1e13fbfbbac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:22:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

pool: use validation

---
 lib/metadata/cache_manip.c       |   18 ++++--------------
 lib/metadata/metadata-exported.h |    6 ++++--
 lib/metadata/pool_manip.c        |    4 ++--
 lib/metadata/thin_manip.c        |   16 ++++------------
 4 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 350a18e..895eaff 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -39,7 +39,8 @@ const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
 	return "unknown";
 }
 
-int update_cache_pool_params(struct volume_group *vg, unsigned attr,
+int update_cache_pool_params(const struct segment_type *segtype,
+			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
@@ -50,19 +51,8 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
 
-	if ((*chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
-	    (*chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)) {
-		log_error("Chunk size must be in the range %s to %s.",
-			  display_size(vg->cmd, DM_CACHE_MIN_DATA_BLOCK_SIZE),
-			  display_size(vg->cmd, DM_CACHE_MAX_DATA_BLOCK_SIZE));
-		return 0;
-	}
-
-	if (*chunk_size & (DM_CACHE_MIN_DATA_BLOCK_SIZE - 1)) {
-		log_error("Chunk size must be a multiple of %s.",
-			  display_size(vg->cmd, DM_CACHE_MIN_DATA_BLOCK_SIZE));
-		return 0;
-	}
+	if (!validate_pool_chunk_size(vg->cmd, segtype, *chunk_size))
+		return_0;
 
 	/*
 	 * Default meta size is:
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b8e7415..f8a84de 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -743,7 +743,8 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				  int passed_args, int *chunk_size_calc_method,
 				  uint32_t *chunk_size, thin_discards_t *discards,
 				  int *zero);
-int update_thin_pool_params(struct volume_group *vg, unsigned attr,
+int update_thin_pool_params(const struct segment_type *segtype,
+			    struct volume_group *vg, unsigned attr,
 			    int passed_args, uint32_t data_extents,
 			    uint64_t *pool_metadata_size,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
@@ -1071,7 +1072,8 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv
 
 /* ++  metadata/cache_manip.c */
 const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
-int update_cache_pool_params(struct volume_group *vg, unsigned attr,
+int update_cache_pool_params(const struct segment_type *segtype,
+			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 4621c57..6e2f2fe 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -364,11 +364,11 @@ int update_pool_params(const struct segment_type *segtype,
 		       thin_discards_t *discards, int *zero)
 {
 	if (segtype_is_cache_pool(segtype) || segtype_is_cache(segtype)) {
-		if (!update_cache_pool_params(vg, target_attr, passed_args,
+		if (!update_cache_pool_params(segtype, vg, target_attr, passed_args,
 					      data_extents, pool_metadata_size,
 					      chunk_size_calc_policy, chunk_size))
 			return_0;
-	} else if (!update_thin_pool_params(vg, target_attr, passed_args,
+	} else if (!update_thin_pool_params(segtype, vg, target_attr, passed_args,
 					    data_extents, pool_metadata_size,
 					    chunk_size_calc_policy, chunk_size,
 					    discards, zero)) /* thin-pool */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b781e02..b830350 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -394,7 +394,8 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return ret;
 }
 
-int update_thin_pool_params(struct volume_group *vg,
+int update_thin_pool_params(const struct segment_type *segtype,
+			    struct volume_group *vg,
 			    unsigned attr, int passed_args, uint32_t data_extents,
 			    uint64_t *pool_metadata_size,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
@@ -425,13 +426,8 @@ int update_thin_pool_params(struct volume_group *vg,
 		}
 	}
 
-	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-		log_error("Chunk size must be in the range %s to %s.",
-			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
-			  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
-		return 0;
-	}
+	if (!validate_pool_chunk_size(cmd, segtype, *chunk_size))
+		return_0;
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {
 		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
@@ -449,10 +445,6 @@ int update_thin_pool_params(struct volume_group *vg,
 	    (*chunk_size & (*chunk_size - 1))) {
 		log_error("Chunk size must be a power of 2 for this thin target version.");
 		return 0;
-	} else if (*chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
-		log_error("Chunk size must be multiple of %s.",
-			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE));
-		return 0;
 	}
 
 	if (!*pool_metadata_size) {


