From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:22 +0000 (GMT)
Subject: stable-2.02 - cache: reuse code for metadata min_max
Message-ID: <20210201133822.D35AC3834437@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd2501d64b02ae8426e501771272e9445be2ed8c
Commit:        dd2501d64b02ae8426e501771272e9445be2ed8c
Parent:        72b12033a9ffb45b858d738b956dc39f71782ecd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 30 16:32:51 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

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
index 05a6efdf1..ffce73761 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -161,6 +161,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
 			     unsigned attr,
 			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
+			     struct logical_volume *metadata_lv,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
@@ -206,39 +207,26 @@ int update_cache_pool_params(struct cmd_context *cmd,
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
index 629b3a457..16b5e654c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1282,6 +1282,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
 			     unsigned attr,
 			     uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
+			     struct logical_volume *metadata_lv,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size);
 int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 50f438672..b885f9241 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3093,6 +3093,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					      pool_segtype, target_attr,
 					      lv->le_count,
 					      &meta_extents,
+					      metadata_lv,
 					      &chunk_calc,
 					      &chunk_size))
 			goto_bad;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d54f152a3..0bbb03301 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -402,6 +402,7 @@ static int _update_extents_params(struct volume_group *vg,
 						      lp->segtype, lp->target_attr,
 						      lp->extents,
 						      &lp->pool_metadata_extents,
+						      NULL,
 						      &lp->thin_chunk_size_calc_policy,
 						      &lp->chunk_size))
 				return_0;


