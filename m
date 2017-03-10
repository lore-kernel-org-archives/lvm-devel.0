From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:17 -0500
Subject: master - thin: single formula for estimation
Message-ID: <201703101836.v2AIaHfo009425@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c52d550e92ec82a44b7652c285642d46a35ca69
Commit:        7c52d550e92ec82a44b7652c285642d46a35ca69
Parent:        1cfc1be85d617516d077106372b6a4836f48c1a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 15:02:07 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

thin: single formula for estimation

Share the same formula for estimation chunk size or metadata size.
Use uint32_t matching type.
---
 lib/metadata/thin_manip.c |   66 +++++++++++++++++++++++++++++---------------
 1 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 5c74248..ee54d1a 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -547,19 +547,31 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return ret;
 }
 
-/* Estimate thin pool chunk size from data and metadata size (in sector units) */
-static size_t _estimate_chunk_size(uint64_t data_size, uint64_t metadata_size, int attr)
+static uint64_t _estimate_size(uint32_t data_extents, uint32_t extent_size, uint64_t size)
 {
 	/*
 	 * nr_pool_blocks = data_size / metadata_size
 	 * chunk_size = nr_pool_blocks * 64b / sector_size
 	 */
-	size_t chunk_size = data_size / (metadata_size * (SECTOR_SIZE / 64));
+	return (uint64_t) data_extents * extent_size / (size * (SECTOR_SIZE / UINT64_C(64)));
+}
+
+/* Estimate thin pool metadata size from data size and chunks size (in sector units) */
+static uint64_t _estimate_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size)
+{
+	return _estimate_size(data_extents, extent_size, chunk_size);
+}
+
+/* Estimate thin pool chunk size from data and metadata size (in sector units) */
+static uint32_t _estimate_chunk_size(uint32_t data_extents, uint32_t extent_size,
+				     uint64_t metadata_size, int attr)
+{
+	uint32_t chunk_size = _estimate_size(data_extents, extent_size, metadata_size);
 
 	if (attr & THIN_FEATURE_BLOCK_SIZE) {
 		/* Round up to 64KB */
 		chunk_size += DM_THIN_MIN_DATA_BLOCK_SIZE - 1;
-		chunk_size &= ~(size_t)(DM_THIN_MIN_DATA_BLOCK_SIZE - 1);
+		chunk_size &= ~(uint32_t)(DM_THIN_MIN_DATA_BLOCK_SIZE - 1);
 	} else {
 		/* Round up to nearest power of 2 */
 		chunk_size--;
@@ -571,6 +583,11 @@ static size_t _estimate_chunk_size(uint64_t data_size, uint64_t metadata_size, i
 		chunk_size++;
 	}
 
+	if (chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
+		chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+	else if (chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
+		chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+
 	return chunk_size;
 }
 
@@ -649,11 +666,15 @@ int update_thin_pool_params(const struct segment_type *segtype,
 	}
 
 	if (!pool_metadata_size) {
-		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
-		pool_metadata_size = (uint64_t) pool_data_extents * extent_size /
-			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
-		/* Check if we could eventually use bigger chunk size */
-		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+		if (!*chunk_size) {
+			if (!get_default_allocation_thin_pool_chunk_size(cmd, profile,
+									 chunk_size,
+									 chunk_size_calc_method))
+				return_0;
+
+			pool_metadata_size = _estimate_metadata_size(pool_data_extents, extent_size, *chunk_size);
+
+			/* Check if we should eventually use bigger chunk size */
 			while ((pool_metadata_size >
 				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
 			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
@@ -662,26 +683,25 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			}
 			log_verbose("Setting chunk size to %s.",
 				    display_size(cmd, *chunk_size));
-		} else if (pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
-			/* Suggest bigger chunk size */
-			estimate_chunk_size =
-				_estimate_chunk_size((uint64_t) pool_data_extents * extent_size,
-						     (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2), attr);
-			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
-				 display_size(cmd, estimate_chunk_size));
+		} else {
+			pool_metadata_size = _estimate_metadata_size(pool_data_extents, extent_size, *chunk_size);
+
+			if (pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
+				/* Suggest bigger chunk size */
+				estimate_chunk_size =
+					_estimate_chunk_size(pool_data_extents, extent_size,
+							     (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2), attr);
+				log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
+					 display_size(cmd, estimate_chunk_size));
+			}
 		}
 
 		/* Round up to extent size silently */
 		if (pool_metadata_size % extent_size)
 			pool_metadata_size += extent_size - pool_metadata_size % extent_size;
 	} else {
-		estimate_chunk_size =
-			_estimate_chunk_size((uint64_t) pool_data_extents * extent_size,
-					     pool_metadata_size, attr);
-		if (estimate_chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
-			estimate_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-		else if (estimate_chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
-			estimate_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		estimate_chunk_size = _estimate_chunk_size(pool_data_extents, extent_size,
+							   pool_metadata_size, attr);
 
 		/* Check to eventually use bigger chunk size */
 		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {


