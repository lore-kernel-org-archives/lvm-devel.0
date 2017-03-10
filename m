From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:33 -0500
Subject: master - cleanup: minor cosmetics
Message-ID: <201703101836.v2AIaXEr021860@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9b78d26b13fb759d3dbf2834c3ce365aaba44b2
Commit:        a9b78d26b13fb759d3dbf2834c3ce365aaba44b2
Parent:        21c265adcffa5a2a8b5f308556e53dbe46c242d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 28 12:31:36 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cleanup: minor cosmetics

Update some return value to match return type.
Drop unused function and declaration.
---
 conf/cache-smq.profile           |    2 +-
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |   10 ----------
 lib/metadata/pool_manip.c        |   32 --------------------------------
 4 files changed, 2 insertions(+), 44 deletions(-)

diff --git a/conf/cache-smq.profile b/conf/cache-smq.profile
index c0d6266..c457481 100644
--- a/conf/cache-smq.profile
+++ b/conf/cache-smq.profile
@@ -9,6 +9,6 @@ allocation {
 	cache_mode = "writethrough"
 	cache_policy = "smq"
 	cache_settings {
-	        # currently no settins for "smq" policy
+	        # currently no settings for "smq" policy
 	}
 }
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5475e7a..5068788 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7425,7 +7425,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				if (!activate_lv_excl_local(cmd, pool_lv)) {
 					log_error("Aborting. Failed to locally activate thin pool %s.",
 						  display_lvname(pool_lv));
-					return 0;
+					return NULL;
 				}
 				if (!pool_below_threshold(first_seg(pool_lv))) {
 					log_error("Cannot create new thin volume, free space in "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 28dd2a6..3486902 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -857,16 +857,6 @@ int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_pool_chunk_size(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t chunk_size);
 int update_pool_lv(struct logical_volume *lv, int activate);
-int update_pool_params(const struct segment_type *segtype,
-		       struct volume_group *vg, unsigned target_attr,
-		       int passed_args, uint32_t pool_data_extents,
-		       uint32_t *pool_metadata_extents,
-		       int *chunk_size_calc_policy, uint32_t *chunk_size,
-		       thin_discards_t *discards, int *zero);
-int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
-				  int passed_args, int *chunk_size_calc_method,
-				  uint32_t *chunk_size, thin_discards_t *discards,
-				  int *zero);
 int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct profile *profile,
 						uint32_t *chunk_size, int *chunk_size_calc_method);
 int update_thin_pool_params(struct cmd_context *cmd,
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 3c938c1..18e4e65 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -467,38 +467,6 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 	return 1;
 }
 
-#if 0
-int update_pool_params(const struct segment_type *segtype,
-		       struct volume_group *vg, unsigned target_attr,
-		       int passed_args, uint32_t pool_data_extents,
-		       uint32_t *pool_metadata_extents,
-		       int *chunk_size_calc_policy, uint32_t *chunk_size,
-		       thin_discards_t *discards, int *zero)
-{
-	if (segtype_is_cache_pool(segtype) || segtype_is_cache(segtype)) {
-		if (!update_cache_pool_params(segtype, vg, target_attr, passed_args,
-					      pool_data_extents, pool_metadata_extents,
-					      chunk_size_calc_policy, chunk_size))
-			return_0;
-	} else if (!update_thin_pool_params(segtype, vg, target_attr, passed_args,
-					    pool_data_extents, pool_metadata_extents,
-					    chunk_size_calc_policy, chunk_size,
-					    discards, zero)) /* thin-pool */
-			return_0;
-
-	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * vg->extent_size) {
-		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
-			  segtype->name, display_size(vg->cmd, *chunk_size));
-		return 0;
-	}
-
-	log_verbose("Preferred pool metadata size %s.",
-		    display_size(vg->cmd, (uint64_t)*pool_metadata_extents * vg->extent_size));
-
-	return 1;
-}
-#endif
-
 int create_pool(struct logical_volume *pool_lv,
 		const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size)


