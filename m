From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:16 +0000 (UTC)
Subject: master - cache: function for min metadata size estimation
Message-ID: <20160505220116.9816060C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00dfca034c7478b88874d43bc36633e3176d1866
Commit:        00dfca034c7478b88874d43bc36633e3176d1866
Parent:        7c1e6011644abd00dac7f71baf330f69bd076381
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 28 18:08:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:30:02 2016 +0200

cache: function for min metadata size estimation

Move min code into reusable function.
---
 lib/metadata/cache_manip.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e998670..a514828 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -120,6 +120,23 @@ void cache_check_for_warns(const struct lv_segment *seg)
 			 "resized and require manual uncache before resize!");
 }
 
+/*
+ * Returns minimum size of cache metadata volume for give  data and chunk size
+ * (all values in sector)
+ * Default meta size is: (Overhead + mapping size + hint size)
+ */
+static uint64_t _cache_min_metadata_size(uint64_t data_size, uint32_t chunk_size)
+{
+	uint64_t min_meta_size;
+
+	min_meta_size = data_size / chunk_size;		/* nr_chunks */
+	min_meta_size *= (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
+	min_meta_size = (min_meta_size + (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;	/* in sectors */
+	min_meta_size += DM_TRANSACTION_OVERHEAD * (1024 >> SECTOR_SHIFT);
+
+	return min_meta_size;
+}
+
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t pool_data_extents,
@@ -128,7 +145,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 {
 	uint64_t min_meta_size;
 	uint32_t extent_size = vg->extent_size;
-	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * vg->extent_size;
+	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
@@ -136,14 +153,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 	if (!validate_pool_chunk_size(vg->cmd, segtype, *chunk_size))
 		return_0;
 
-	/*
-	 * Default meta size is:
-	 * (Overhead + mapping size + hint size)
-	 */
-	min_meta_size = (uint64_t) pool_data_extents * extent_size / *chunk_size;	/* nr_chunks */
-	min_meta_size *= (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
-	min_meta_size = (min_meta_size + (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;	/* in sectors */
-	min_meta_size += DM_TRANSACTION_OVERHEAD * (1024 >> SECTOR_SHIFT);
+	min_meta_size = _cache_min_metadata_size((uint64_t) pool_data_extents * extent_size, *chunk_size);
 
 	/* Round up to extent size */
 	if (min_meta_size % extent_size)


