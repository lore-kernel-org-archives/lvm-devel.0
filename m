From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:05 +0000 (UTC)
Subject: master - thin: move update_pool_params
Message-ID: <20130313141605.D9164A0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b36a776a7fed84fa6228ffa287b4c9ccdf355ddf
Commit:        b36a776a7fed84fa6228ffa287b4c9ccdf355ddf
Parent:        f06dd8725a85d344820eda91835c58f489097563
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 11 12:37:09 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: move update_pool_params

Now we may recongnize preset arguments, move
the code for updating thin pool related values
into /lib portion of the code.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    4 ++
 lib/metadata/thin_manip.c        |   88 ++++++++++++++++++++++++++++++++++++++
 tools/toollib.c                  |   87 -------------------------------------
 tools/toollib.h                  |    5 +--
 5 files changed, 94 insertions(+), 91 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 082b414..68a7d03 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Move update_pool_params() from /tools to /lib for better reuse.
   Give precedence to EMC power2 devices with duplicate PVIDs.
   Add --validate option to lvm dumpconfig to validate current config on demand.
   Add --ignoreadvanced and --ignoreunsupported switch to lvm dumpconfig.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5ed8f3e..c2728d5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -576,6 +576,10 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 
 int pool_is_active(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
+int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
+		       uint32_t data_extents, uint32_t extent_size,
+		       uint32_t *chunk_size, thin_discards_t *discards,
+		       uint64_t *pool_metadata_size);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c994a2e..10c8f43 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -20,6 +20,7 @@
 #include "lv_alloc.h"
 #include "archiver.h"
 #include "defaults.h"
+#include "display.h"
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume *metadata_lv)
 {
@@ -523,6 +524,93 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
+int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
+		       uint32_t data_extents, uint32_t extent_size,
+		       uint32_t *chunk_size, thin_discards_t *discards,
+		       uint64_t *pool_metadata_size)
+{
+	size_t estimate_chunk_size;
+
+	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    (*chunk_size & (*chunk_size - 1))) {
+		log_error("Chunk size must be a power of 2 for this thin target version.");
+		return 0;
+	} else if (*chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
+		log_error("Chunk size must be multiple of %s.",
+			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE));
+		return 0;
+	}
+
+	if (!*pool_metadata_size) {
+		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
+		*pool_metadata_size = (uint64_t) data_extents * extent_size /
+			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check if we could eventually use bigger chunk size */
+		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+			while ((*pool_metadata_size >
+				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+				*chunk_size <<= 1;
+				*pool_metadata_size >>= 1;
+			}
+			log_verbose("Setting chunk size to %s.",
+				    display_size(cmd, *chunk_size));
+		} else if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+			/* Suggest bigger chunk size */
+			estimate_chunk_size = (uint64_t) data_extents * extent_size /
+				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
+				 (SECTOR_SIZE / UINT64_C(64)));
+			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
+				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
+		}
+
+		/* Round up to extent size */
+		if (*pool_metadata_size % extent_size)
+			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
+	} else {
+		estimate_chunk_size =  (uint64_t) data_extents * extent_size /
+			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check to eventually use bigger chunk size */
+		if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+			*chunk_size = estimate_chunk_size;
+
+			if (*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+
+			log_verbose("Setting chunk size %s.",
+				    display_size(cmd, *chunk_size));
+		} else if (*chunk_size < estimate_chunk_size) {
+			/* Suggest bigger chunk size */
+			log_warn("WARNING: Chunk size is smaller then suggested minimum size %s.",
+				 display_size(cmd, estimate_chunk_size));
+		}
+	}
+
+	if ((uint64_t) *chunk_size > (uint64_t) data_extents * extent_size) {
+		log_error("Chunk size is bigger then pool data size.");
+		return 0;
+	}
+
+	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+			log_warn("WARNING: Maximum supported pool metadata size is %s.",
+				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+			log_warn("WARNING: Minimum supported pool metadata size is %s.",
+				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+	}
+
+	log_verbose("Setting pool metadata size to %s.",
+		    display_size(cmd, *pool_metadata_size));
+
+	return 1;
+}
+
 int get_pool_discards(const char *str, thin_discards_t *discards)
 {
 	if (!strcasecmp(str, "passdown"))
diff --git a/tools/toollib.c b/tools/toollib.c
index 10ada7c..f00988a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1583,93 +1583,6 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 	return 1;
 }
 
-int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
-		       uint32_t data_extents, uint32_t extent_size,
-		       uint32_t *chunk_size, thin_discards_t *discards,
-		       uint64_t *pool_metadata_size)
-{
-	size_t estimate_chunk_size;
-
-	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
-	    (*chunk_size & (*chunk_size - 1))) {
-		log_error("Chunk size must be a power of 2 for this thin target version.");
-		return 0;
-	} else if (*chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
-		log_error("Chunk size must be multiple of %s.",
-			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE));
-		return 0;
-	}
-
-	if (!*pool_metadata_size) {
-		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
-		*pool_metadata_size = (uint64_t) data_extents * extent_size /
-			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
-		/* Check if we could eventually use bigger chunk size */
-		if (!arg_count(cmd, chunksize_ARG)) {
-			while ((*pool_metadata_size >
-				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
-			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-				*chunk_size <<= 1;
-				*pool_metadata_size >>= 1;
-			}
-			log_verbose("Setting chunk size to %s.",
-				    display_size(cmd, *chunk_size));
-		} else if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-			/* Suggest bigger chunk size */
-			estimate_chunk_size = (uint64_t) data_extents * extent_size /
-				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
-				 (SECTOR_SIZE / UINT64_C(64)));
-			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
-				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
-		}
-
-		/* Round up to extent size */
-		if (*pool_metadata_size % extent_size)
-			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
-	} else {
-		estimate_chunk_size =  (uint64_t) data_extents * extent_size /
-			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
-		/* Check to eventually use bigger chunk size */
-		if (!arg_count(cmd, chunksize_ARG)) {
-			*chunk_size = estimate_chunk_size;
-
-			if (*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
-				*chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
-				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-
-			log_verbose("Setting chunk size %s.",
-				    display_size(cmd, *chunk_size));
-		} else if (*chunk_size < estimate_chunk_size) {
-			/* Suggest bigger chunk size */
-			log_warn("WARNING: Chunk size is smaller then suggested minimum size %s.",
-				 display_size(cmd, estimate_chunk_size));
-		}
-	}
-
-	if ((uint64_t) *chunk_size > (uint64_t) data_extents * extent_size) {
-		log_error("Chunk size is bigger then pool data size.");
-		return 0;
-	}
-
-	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-		if (arg_count(cmd, poolmetadatasize_ARG))
-			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-		if (arg_count(cmd, poolmetadatasize_ARG))
-			log_warn("WARNING: Minimum supported pool metadata size is %s.",
-				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-	}
-
-	log_verbose("Setting pool metadata size to %s.",
-		    display_size(cmd, *pool_metadata_size));
-
-	return 1;
-}
-
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   alloc_policy_t alloc,
 					   const char *name,
diff --git a/tools/toollib.h b/tools/toollib.h
index 9a4743d..2ca7951 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -117,10 +117,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
 		    int *zero);
-int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
-		       uint32_t data_extents, uint32_t extent_size,
-		       uint32_t *chunk_size, thin_discards_t *discards,
-		       uint64_t *pool_metadata_size);
+
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   alloc_policy_t alloc, const char *name,
 					   struct dm_list *pvh, uint32_t read_ahead,


