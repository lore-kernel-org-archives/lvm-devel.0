From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:17 +0000 (UTC)
Subject: master - cache: use same alg for cache size calc
Message-ID: <20141006133317.1C47760DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f76f2ce1df4e95774b8fded602a8e35f8ae71fe1
Commit:        f76f2ce1df4e95774b8fded602a8e35f8ae71fe1
Parent:        d46c2f1c946e21393537a730eaa624665cb96bbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:22:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

cache: use same alg for cache size calc

Use the same algorithm for cache metadata size as the cache tool is using.
---
 lib/metadata/cache_manip.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index ed08726..350a18e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -22,6 +22,12 @@
 #include "activate.h"
 #include "defaults.h"
 
+/* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
+#define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
+#define DM_BYTES_PER_BLOCK		16 /* bytes */
+#define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
+#define DM_MAX_HINT_WIDTH		(4+16)  /* bytes,  TODO: configurable ?? */
+
 const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
 {
 	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
@@ -39,6 +45,7 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int *chunk_size_calc_method, uint32_t *chunk_size)
 {
 	uint64_t min_meta_size;
+	uint32_t extent_size = vg->extent_size;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
@@ -59,15 +66,16 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 
 	/*
 	 * Default meta size is:
-	 * (4MiB + (16 Bytes for each chunk-sized block))
-	 * ... plus a good amount of padding (2x) to cover any
-	 * policy hint data that may be added in the future.
+	 * (Overhead + mapping size + hint size)
 	 */
-	min_meta_size = (uint64_t)data_extents * vg->extent_size * 16;
-	min_meta_size /= *chunk_size; /* # of Bytes we need */
-	min_meta_size *= 2;              /* plus some padding */
-	min_meta_size /= 512;            /* in sectors */
-	min_meta_size += 4*1024*2;       /* plus 4MiB */
+	min_meta_size = (uint64_t) data_extents * extent_size / *chunk_size;	/* nr_chunks */
+	min_meta_size *= (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
+	min_meta_size = (min_meta_size + (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;	/* in sectors */
+	min_meta_size += DM_TRANSACTION_OVERHEAD * (1024 >> SECTOR_SHIFT);
+
+	/* Round up to extent size */
+	if (min_meta_size % extent_size)
+		min_meta_size += extent_size - min_meta_size % extent_size;
 
 	if (!*pool_metadata_size)
 		*pool_metadata_size = min_meta_size;
@@ -79,7 +87,7 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 				 display_size(vg->cmd, *pool_metadata_size));
 	} else if (*pool_metadata_size < min_meta_size) {
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
-			log_warn("WARNING: Minimum supported pool metadata size is %s "
+			log_warn("WARNING: Minimum required pool metadata size is %s "
 				 "(needs extra %s).",
 				 display_size(vg->cmd, min_meta_size),
 				 display_size(vg->cmd, min_meta_size - *pool_metadata_size));


