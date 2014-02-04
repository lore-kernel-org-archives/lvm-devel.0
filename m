From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  4 Feb 2014 17:50:40 +0000 (UTC)
Subject: master - cache pool: Add 'update_cache_pool_params'
Message-ID: <20140204175040.411E260ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=013cf27bff2d46f273505d6ee437085ad9cab5f2
Commit:        013cf27bff2d46f273505d6ee437085ad9cab5f2
Parent:        8ddc7f641ced0a32801d978cd4e8a70883c4897a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 4 11:50:27 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 4 11:50:27 2014 -0600

cache pool: Add 'update_cache_pool_params'

Similar function to 'update_thin_pool_params', but for cache.  Performs
the adjustements for chunk_size, metdata device size, etc.
---
 lib/config/defaults.h            |    2 +
 lib/metadata/cache_manip.c       |   52 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    6 ++++
 tools/lvcreate.c                 |    9 ++++++
 4 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 4f53b3f..437cec7 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -81,6 +81,8 @@
 
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
+#define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
+#define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 2456171..a3a3608 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -28,6 +28,58 @@
 #include "defaults.h"
 #include "lvm-exec.h"
 
+int update_cache_pool_params(struct volume_group *vg, unsigned attr,
+			     int passed_args,
+			     uint32_t data_extents, uint32_t extent_size,
+			     int *chunk_size_calc_method, uint32_t *chunk_size,
+			     thin_discards_t *discards,
+			     uint64_t *pool_metadata_size, int *zero)
+{
+	uint64_t min_meta_size;
+
+	if ((*chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
+	    (*chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)) {
+		log_error("Chunk size must be in the range %s to %s.",
+			  display_size(vg->cmd, DM_CACHE_MIN_DATA_BLOCK_SIZE),
+			  display_size(vg->cmd, DM_CACHE_MAX_DATA_BLOCK_SIZE));
+		return 0;
+	}
+
+	if (*chunk_size & (DM_CACHE_MIN_DATA_BLOCK_SIZE - 1)) {
+		log_error("Chunk size must be a multiple of %u sectors.",
+			  DM_CACHE_MIN_DATA_BLOCK_SIZE);
+		return 0;
+	}
+
+	/*
+	 * Default meta size is:
+	 * (4MiB + (16 Bytes for each chunk-sized block))
+	 * ... plus a good amount of padding (2x) to cover any
+	 * policy hint data that may be added in the future.
+	 */
+	min_meta_size = 16 * (data_extents * vg->extent_size);
+	min_meta_size /= *chunk_size; /* # of Bytes we need */
+	min_meta_size *= 2;              /* plus some padding */
+	min_meta_size /= 512;            /* in sectors */
+	min_meta_size += 4*1024*2;       /* plus 4MiB */
+
+	if (!*pool_metadata_size)
+		*pool_metadata_size = min_meta_size;
+
+	if (*pool_metadata_size < min_meta_size) {
+		*pool_metadata_size = min_meta_size;
+		log_print("Increasing metadata device size to %"
+			  PRIu64 " sectors", *pool_metadata_size);
+	}
+	if (*pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
+		*pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
+		log_print("Reducing metadata device size to %" PRIu64 " sectors",
+			  *pool_metadata_size);
+	}
+
+	return 1;
+}
+
 /*
  * lv_cache_create
  * @pool
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8258b24..b37d91a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1020,6 +1020,12 @@ int lv_raid_remove_missing(struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
+int update_cache_pool_params(struct volume_group *vg, unsigned attr,
+			     int passed_args,
+			     uint32_t data_extents, uint32_t extent_size,
+			     int *chunk_size_calc_method, uint32_t *chunk_size,
+			     thin_discards_t *discards,
+			     uint64_t *pool_metadata_size, int *zero);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ba7df2a..137c0a2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -230,6 +230,15 @@ static int _determine_snapshot_type(struct volume_group *vg,
 static int _lvcreate_update_pool_params(struct volume_group *vg,
 					struct lvcreate_params *lp)
 {
+	if (seg_is_cache_pool(lp))
+		return update_cache_pool_params(vg, lp->target_attr,
+						lp->passed_args,
+						lp->extents, vg->extent_size,
+						&lp->thin_chunk_size_calc_policy,
+						&lp->chunk_size, &lp->discards,
+						&lp->poolmetadatasize,
+						&lp->zero);
+
 	return update_thin_pool_params(vg, lp->target_attr, lp->passed_args,
 				       lp->extents, vg->extent_size,
 				       &lp->thin_chunk_size_calc_policy,


