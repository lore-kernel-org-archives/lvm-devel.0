From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:48:58 +0000 (UTC)
Subject: master - thin: add common pool functions
Message-ID: <20121119134858.685D41698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4137640f60af5377615a1b9e50238b593cf272b
Commit:        f4137640f60af5377615a1b9e50238b593cf272b
Parent:        2e96ea4a899a0d0a5adb5e3d8fa09e04fd7a4173
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 15 14:48:32 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

thin: add common pool functions

Move common functions for lvcreate and lvconvert.

get_pool_params() - read thin pool args.
update_pool_params() - updates/validates some thin args.

It is getting complicated and even few more things will be
implemented, so to avoid reimplementing things differently
in lvcreate and lvconvert  code has been splitted
into 2 common functions that allow some future extension.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    9 ++++
 3 files changed, 139 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8117165..59a69da 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Move common functionality for thin lvcreate and lvconvert to toollib.
   Mirrored log is now fixed before its mirror when double-fault occurs.
   Add python-lvm unit test case
   Exit pvscan --cache immediately if cluster locking used or lvmetad not used.
diff --git a/tools/toollib.c b/tools/toollib.c
index 62f59d8..c3c6381 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include <sys/stat.h>
+#include <strings.h>
 
 const char *command_name(struct cmd_context *cmd)
 {
@@ -1521,6 +1522,134 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	return 1;
 }
 
+int get_pool_params(struct cmd_context *cmd,
+		    uint32_t *chunk_size,
+		    thin_discards_t *discards,
+		    uint64_t *pool_metadata_size,
+		    int *zero)
+{
+	if (arg_count(cmd, zero_ARG))
+		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+	else
+		*zero = 1; /* TODO: Make default configurable */
+
+	*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG,
+						     THIN_DISCARDS_PASSDOWN);
+
+	if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Negative chunk size is invalid.");
+		return 0;
+	}
+	*chunk_size = arg_uint_value(cmd, chunksize_ARG,
+				     DM_THIN_MIN_DATA_BLOCK_SIZE);
+
+	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+		log_error("Chunk size must be in the range %s to %s.",
+			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
+			  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
+		return 0;
+	}
+
+	if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Negative pool metadata size is invalid.");
+		return 0;
+	}
+	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+
+	return 1;
+}
+
+int update_pool_params(struct cmd_context *cmd, unsigned attr,
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
+	} else if ((*discards != THIN_DISCARDS_IGNORE) &&
+		   (*chunk_size & (*chunk_size - 1))) {
+		log_warn("WARNING: Using discards ignore for chunk size non power of 2.");
+		*discards = THIN_DISCARDS_IGNORE;
+	}
+
+	if (!*pool_metadata_size) {
+		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
+		*pool_metadata_size = (uint64_t) data_extents * extent_size /
+			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check if we could eventually use bigger chunk size */
+		if (!arg_count(cmd, chunksize_ARG)) {
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
+				 display_size(cmd, 1 << (ffs(estimate_chunk_size) + 1)));
+		}
+
+		/* Round up to extent size */
+		if (*pool_metadata_size % extent_size)
+			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
+	} else {
+		estimate_chunk_size =  (uint64_t) data_extents * extent_size /
+			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check to eventually use bigger chunk size */
+		if (!arg_count(cmd, chunksize_ARG)) {
+			*chunk_size = estimate_chunk_size;
+
+			if (*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+
+			log_verbose("Setting chunk size %uKiB.", *chunk_size / 2);
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
+		if (arg_count(cmd, poolmetadatasize_ARG))
+			log_warn("WARNING: Maximum supported pool metadata size is %s.",
+				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		if (arg_count(cmd, poolmetadatasize_ARG))
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
 /*
  * Generic stripe parameter checks.
  */
diff --git a/tools/toollib.h b/tools/toollib.h
index b3b0a7c..09071b3 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -111,6 +111,15 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);
+int get_pool_params(struct cmd_context *cmd,
+		    uint32_t *chunk_size,
+		    thin_discards_t *discards,
+		    uint64_t *pool_metadata_size,
+		    int *zero);
+int update_pool_params(struct cmd_context *cmd, unsigned attr,
+		       uint32_t data_extents, uint32_t extent_size,
+		       uint32_t *chunk_size, thin_discards_t *discards,
+		       uint64_t *pool_metadata_size);
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 


