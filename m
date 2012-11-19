From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:49:05 +0000 (UTC)
Subject: master - thin: lvcreate use common functions
Message-ID: <20121119134905.8BE5C1698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1794f777f48be29184ef8030b6e11b3a8e61757b
Commit:        1794f777f48be29184ef8030b6e11b3a8e61757b
Parent:        b21d3e3592e380cb79e5e45f2aa8164ae0747e15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 12:47:34 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

thin: lvcreate use common functions

Use common functions from toollib and eliminate code from here.
---
 tools/lvcreate.c |  100 +++++++++++-------------------------------------------
 1 files changed, 20 insertions(+), 80 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index dad0ba7..470084c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -234,7 +234,6 @@ static int _update_extents_params(struct volume_group *vg,
 {
 	uint32_t pv_extent_count;
 	struct logical_volume *origin = NULL;
-	int changed = 0;
 	uint32_t size_rest;
 	uint32_t stripesize_extents;
 
@@ -308,38 +307,11 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_thin_pool) {
-		if (!arg_count(vg->cmd, poolmetadatasize_ARG)) {
-			/* Defaults to nr_pool_blocks * 64b */
-			lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
-				(uint64_t) (lp->chunk_size * (SECTOR_SIZE / UINT64_C(64)));
-
-			/* Check if we could eventually use bigger chunk size */
-			if (!arg_count(vg->cmd, chunksize_ARG)) {
-				while ((lp->poolmetadatasize >
-					(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
-				       (lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-					lp->chunk_size <<= 1;
-					lp->poolmetadatasize >>= 1;
-					changed++;
-				}
-				if (changed)
-					log_verbose("Changed chunksize to %u sectors.",
-						    lp->chunk_size);
-			}
-		}
-
-		if (lp->poolmetadatasize > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-			if (arg_count(vg->cmd, poolmetadatasize_ARG))
-				log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
-			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-		} else if (lp->poolmetadatasize < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-			if (arg_count(vg->cmd, poolmetadatasize_ARG))
-				log_warn("WARNING: Minimum supported pool metadata size is 2M.");
-			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-		}
-
-		log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
-			    lp->poolmetadatasize);
+		if (!update_pool_params(vg->cmd, lp->target_attr,
+					lp->extents, vg->extent_size,
+					&lp->chunk_size, &lp->discards,
+					&lp->poolmetadatasize))
+			return_0;
 
 		if (!(lp->poolmetadataextents =
 		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
@@ -386,16 +358,9 @@ static int _read_size_params(struct lvcreate_params *lp,
 	if (lp->thin && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
 		lp->create_thin_pool = 1;
 
-	if (arg_count(cmd, poolmetadatasize_ARG)) {
-		if (!seg_is_thin(lp)) {
-			log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
-			return 0;
-		}
-		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative poolmetadatasize is invalid.");
-			return 0;
-		}
-		lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+	if (arg_count(cmd, poolmetadatasize_ARG) && !seg_is_thin(lp)) {
+		log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
+		return 0;
 	}
 
 	/* Size returned in kilobyte units; held in sectors */
@@ -820,13 +785,13 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !get_pool_params(cmd, &lp->chunk_size, &lp->discards,
+			     &lp->poolmetadatasize, &lp->zero) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd))
 		return_0;
 
-	if (lp->create_thin_pool)
-		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-	else if (arg_count(cmd, discards_ARG)) {
+	if (!lp->create_thin_pool && arg_count(cmd, discards_ARG)) {
 		log_error("--discards is only available for thin pool creation.");
 		return 0;
 	}
@@ -836,48 +801,23 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	else if (lp->thin && !lp->create_thin_pool) {
 		if (arg_count(cmd, chunksize_ARG))
 			log_warn("WARNING: Ignoring --chunksize when using an existing pool.");
-	} else if (lp->snapshot || lp->create_thin_pool) {
+	} else if (lp->snapshot) {
 		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
-		if (lp->snapshot) {
-			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-			if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-			    (lp->chunk_size & (lp->chunk_size - 1))) {
-				log_error("Chunk size must be a power of 2 in the "
-					  "range 4K to 512K");
-				return 0;
-			}
-		} else {
-			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
-							DM_THIN_MIN_DATA_BLOCK_SIZE);
-			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-				log_error("Chunk size must be in the range %uK to %uK",
-					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
-					  (DM_THIN_MAX_DATA_BLOCK_SIZE / 2));
-				return 0;
-			}
-			if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
-			    (lp->chunk_size & (lp->chunk_size - 1))) {
-				log_error("Chunk size must be a power of 2 for this thin target version.");
-				return 0;
-			} else if (lp->chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
-				log_error("Chunk size must be multiple of %uK.",
-					  DM_THIN_MIN_DATA_BLOCK_SIZE / 2);
-				return 0;
-			} else if ((lp->discards != THIN_DISCARDS_IGNORE) &&
-				   (lp->chunk_size & (lp->chunk_size - 1))) {
-				log_warn("WARNING: Using discards ignore for chunk size non power of 2.");
-				lp->discards = THIN_DISCARDS_IGNORE;
-			}
+		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+		    (lp->chunk_size & (lp->chunk_size - 1))) {
+			log_error("Chunk size must be a power of 2 in the "
+				  "range 4K to 512K");
+			return 0;
 		}
-		log_verbose("Setting chunksize to %u sectors.", lp->chunk_size);
+		log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
 
 		if (!lp->thin && lp->snapshot && !(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
-	} else if (arg_count(cmd, chunksize_ARG)) {
+	} else if (arg_count(cmd, chunksize_ARG) && !lp->create_thin_pool) {
 		log_error("-c is only available with snapshots and thin pools");
 		return 0;
 	}


