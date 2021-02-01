From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:35 +0000 (GMT)
Subject: main - cache: reuse code for metadata min_max
Message-ID: <20210201114735.0E26B3836C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=abc9265a063670e277e6859ba0203d09ae20604d
Commit:        abc9265a063670e277e6859ba0203d09ae20604d
Parent:        f96b45550645e537af5b1a04d4d4476f62d86b63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 30 16:32:51 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:06:13 2021 +0100

cache: reuse code for metadata min_max

Use update_pool_metadata_min_max() which is shared with
thin-pool metadata min-max updating.

Gives improved messages when converting volumes to metadata.
---
 lib/metadata/cache_manip.c       | 40 ++++++++++++++--------------------------
 lib/metadata/metadata-exported.h |  1 +
 tools/lvconvert.c                |  1 +
 tools/lvcreate.c                 |  1 +
 4 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 2c4cc92fb..90ebd9404 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -204,6 +204,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
 			     unsigned attr,
 			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
+			     struct logical_volume *metadata_lv,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
@@ -252,39 +253,26 @@ int update_cache_pool_params(struct cmd_context *cmd,
 	if (!validate_cache_chunk_size(cmd, *chunk_size))
 		return_0;
 
-	min_meta_size = _cache_min_metadata_size((uint64_t) pool_data_extents * extent_size, *chunk_size);
+	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * extent_size) {
+		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
+			  segtype->name, display_size(cmd, *chunk_size));
+		return 0;
+	}
 
-	/* Round up to extent size */
-	if (min_meta_size % extent_size)
-		min_meta_size += extent_size - min_meta_size % extent_size;
+	min_meta_size = _cache_min_metadata_size((uint64_t) pool_data_extents * extent_size, *chunk_size);
+	min_meta_size = dm_round_up(min_meta_size, extent_size);
 
 	if (!pool_metadata_size)
 		pool_metadata_size = min_meta_size;
 
-	if (pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
-		pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
-		if (*pool_metadata_extents)
-			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(cmd, pool_metadata_size));
-	} else if (pool_metadata_size < min_meta_size) {
-		if (*pool_metadata_extents)
-			log_warn("WARNING: Minimum required pool metadata size is %s "
-				 "(needs extra %s).",
-				 display_size(cmd, min_meta_size),
-				 display_size(cmd, min_meta_size - pool_metadata_size));
-		pool_metadata_size = min_meta_size;
-	}
-
-	if (!(*pool_metadata_extents =
-	      extents_from_size(cmd, pool_metadata_size, extent_size)))
+	if (!update_pool_metadata_min_max(cmd, extent_size,
+					  min_meta_size,
+					  (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE),
+					  &pool_metadata_size,
+					  metadata_lv,
+					  pool_metadata_extents))
 		return_0;
 
-	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * extent_size) {
-		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
-			  segtype->name, display_size(cmd, *chunk_size));
-		return 0;
-	}
-
 	log_verbose("Preferred pool metadata size %s.",
 		    display_size(cmd, (uint64_t)*pool_metadata_extents * extent_size));
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b15e3dea4..ac384497b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1320,6 +1320,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
 			     unsigned attr,
 			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
+			     struct logical_volume *metadata_lv,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size);
 int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ce902791c..416e8a73a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3189,6 +3189,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					      pool_segtype, target_attr,
 					      lv->le_count,
 					      &meta_extents,
+					      metadata_lv,
 					      &chunk_calc,
 					      &chunk_size))
 			goto_bad;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1ee9e14c9..1ce561fc3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -403,6 +403,7 @@ static int _update_extents_params(struct volume_group *vg,
 						      lp->segtype, lp->target_attr,
 						      lp->extents,
 						      &lp->pool_metadata_extents,
+						      NULL,
 						      &lp->thin_chunk_size_calc_policy,
 						      &lp->chunk_size))
 				return_0;


