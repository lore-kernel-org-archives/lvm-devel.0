From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:49:03 +0000 (UTC)
Subject: master - thin: lvconvert update
Message-ID: <20121119134903.33C501698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b21d3e3592e380cb79e5e45f2aa8164ae0747e15
Commit:        b21d3e3592e380cb79e5e45f2aa8164ae0747e15
Parent:        b78609686399ee01a53d8a2e8685cd05389d8cc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 13:37:57 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

thin: lvconvert update

Use common function from toollib and support allocation
of metadata LV with give thin pool data LV.
---
 WHATS_NEW         |    1 +
 tools/commands.h  |    7 ++-
 tools/lvconvert.c |  162 +++++++++++++++++++++++++++++------------------------
 3 files changed, 94 insertions(+), 76 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 59a69da..84afb82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Support allocation of pool metadata with lvconvert command.
   Move common functionality for thin lvcreate and lvconvert to toollib.
   Mirrored log is now fixed before its mirror when double-fault occurs.
   Add python-lvm unit test case
diff --git a/tools/commands.h b/tools/commands.h
index 6415d34..8d5d190 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -147,13 +147,16 @@ xx(lvconvert,
    "--thinpool ThinPoolLogicalVolume[Path]\n"
    "\t[--chunksize size]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
-   "\t[[--poolmetadatasize size] | --poolmetadata ThinMetadataLogicalVolume[Path]]\n"
+   "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
+   "\t [--poolmetadatasize size]\n"
+   "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
+   readahead_ARG, regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG, thinpool_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7d03a5f..7a01cce 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -39,6 +39,7 @@ struct lvconvert_params {
 	uint32_t keep_mimages;
 	uint32_t stripes;
 	uint32_t stripe_size;
+	uint32_t read_ahead;
 
 	const struct segment_type *segtype;
 	unsigned target_attr;
@@ -336,53 +337,21 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
+		if (!get_pool_params(cmd,
+				     &lp->chunk_size,
+				     &lp->discards,
+				     &lp->poolmetadata_size,
+				     &lp->zero))
+			return_0;
+
 		if (arg_count(cmd, poolmetadata_ARG)) {
-			lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, "");
-		} else if (arg_count(cmd, poolmetadatasize_ARG)) {
-			if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-				log_error("Negative pool metadata size is invalid.");
+			if (arg_count(cmd, poolmetadatasize_ARG)) {
+				log_error("--poolmetadatasize is invalid with --poolmetadata.");
 				return 0;
 			}
-			lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
-
-			if (lp->poolmetadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-				if (arg_count(cmd, poolmetadatasize_ARG))
-					log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
-				lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-			} else if (lp->poolmetadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-				if (arg_count(cmd, poolmetadatasize_ARG))
-					log_warn("WARNING: Minimum supported pool metadata size is 2M.");
-				lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-			}
-
-			log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
-				    lp->poolmetadata_size);
+			lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, "");
 		}
 
-		if (arg_count(cmd, chunksize_ARG)) {
-			if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-				log_error("Negative chunk size is invalid.");
-				return 0;
-			}
-			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
-							DM_THIN_MIN_DATA_BLOCK_SIZE);
-
-			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-				log_error("Chunk size must be in the range %uK to %uK.",
-					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
-					  (DM_THIN_MAX_DATA_BLOCK_SIZE / 2));
-				return 0;
-			}
-		} else
-			lp->chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
-
-		log_verbose("Setting pool metadata chunk size to %u sectors.",
-			    lp->chunk_size);
-
-		if (arg_count(cmd, zero_ARG))
-			lp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-
 		/* If --thinpool contains VG name, extract it. */
 		if ((tmp_str = strchr(lp->pool_data_lv_name, (int) '/'))) {
 			if (!(lp->vg_name = extract_vgname(cmd, lp->pool_data_lv_name)))
@@ -1827,6 +1796,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	struct logical_volume *data_lv;
 	struct logical_volume *metadata_lv;
 
+	if (!lv_is_visible(pool_lv)) {
+		log_error("Can't convert internal LV %s/%s.",
+			  pool_lv->vg->name, pool_lv->name);
+		return 0;
+	}
+
 	if (lv_is_thin_type(pool_lv)) {
 		log_error("Can't use thin logical volume %s/%s for thin pool data.",
 			  pool_lv->vg->name, pool_lv->name);
@@ -1840,14 +1815,41 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	len = strlen(pool_lv->name) + 16;
+	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
+		log_error("Can't allocate new name.");
+		return 0;
+	}
+
+	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
+		return_0;
+
 	if (lp->pool_metadata_lv_name) {
+		if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
+			log_error("Can't use --stripes and --stripesize with --poolmetadata.");
+			return 0;
+		}
+		if (arg_count(cmd, readahead_ARG)) {
+			log_error("Can't use --readahead with --poolmetadata.");
+			return 0;
+		}
 		metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name);
 		if (!metadata_lv) {
-			log_error("Unknown metadata LV %s", lp->pool_metadata_lv_name);
+			log_error("Unknown metadata LV %s.", lp->pool_metadata_lv_name);
+			return 0;
+		}
+		if (!lv_is_visible(metadata_lv)) {
+			log_error("Can't convert internal LV %s/%s.",
+				  metadata_lv->vg->name, metadata_lv->name);
+			return 0;
+		}
+		if (metadata_lv->status & LOCKED) {
+			log_error("Can't convert locked LV %s/%s.",
+				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
 		if (metadata_lv == pool_lv) {
-			log_error("Can't use same LV for thin data and metadata LV %s",
+			log_error("Can't use same LV for thin pool data and metadata LV %s.",
 				  lp->pool_metadata_lv_name);
 			return 0;
 		}
@@ -1857,37 +1859,51 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
-	} else if (arg_count(cmd, poolmetadatasize_ARG)) {
-		/* FIXME: allocate metadata LV! */
-		metadata_lv = NULL;
-		log_error("Uncreated metadata.");
-		return 0;
-	} else {
-		log_error("Uknown metadata.");
-		return 0;
-	}
-
-	len = strlen(pool_lv->name) + 16;
-	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
-		log_error("Cannot allocate new name.");
-		return 0;
-	}
-
-	if (!lv_is_active(metadata_lv)) {
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Can't deactivate logical volume %s/%s.",
-				  metadata_lv->vg->name, metadata_lv->name);
+		if (!lv_is_active(metadata_lv) &&
+		    !activate_lv_local(cmd, metadata_lv)) {
+		    log_error("Aborting. Failed to activate thin metadata lv.");
+		    return 0;
+		}
+		if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
+			log_error("Aborting. Failed to wipe thin metadata lv.");
 			return 0;
 		}
-		if (!activate_lv_local(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to activate thin metadata lv.");
+
+		lp->poolmetadata_size =
+			(uint64_t) metadata_lv->le_count * metadata_lv->vg->extent_size;
+		if (lp->poolmetadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+			log_warn("WARNING: Maximum size used by metadata is %s, rest is unused.",
+				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
+			lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+		} else if (lp->poolmetadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+			log_error("Logical volume %s/%s is too small (<%s) for metadata.",
+				  metadata_lv->vg->name, metadata_lv->name,
+				  display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
 			return 0;
 		}
-	}
+		if (!update_pool_params(cmd, lp->target_attr,
+					pool_lv->le_count, pool_lv->vg->extent_size,
+					&lp->chunk_size, &lp->discards,
+					&lp->poolmetadata_size))
+			return_0;
+	} else {
+		if (!update_pool_params(cmd, lp->target_attr,
+					pool_lv->le_count, pool_lv->vg->extent_size,
+					&lp->chunk_size, &lp->discards,
+					&lp->poolmetadata_size))
+			return_0;
 
-	if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
-		log_error("Aborting. Failed to wipe thin metadata lv.");
-		return 0;
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
+		/* Hmm _read_activation_params */
+		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+						cmd->default_settings.read_ahead);
+
+		if (!(metadata_lv = alloc_pool_metadata(pool_lv, lp->alloc, name,
+							lp->pvh, lp->read_ahead,
+							lp->stripes, lp->stripe_size,
+							lp->poolmetadata_size)))
+			return_0;
 	}
 
 	if (!deactivate_lv(cmd, metadata_lv)) {
@@ -1896,12 +1912,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
-		return_0;
-
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
-	if (!lv_rename_update(cmd, metadata_lv, name, 0))
+	if (strcmp(metadata_lv->name, name) &&
+	    !lv_rename_update(cmd, metadata_lv, name, 0))
 		return_0;
 
 	/*


