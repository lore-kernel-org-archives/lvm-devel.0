From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 12 Feb 2014 15:51:50 +0000 (UTC)
Subject: master - cachepool: Ability to convert existing LVs to cachepool type
Message-ID: <20140212155150.A832660F46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8b6c4aee9a298a4c415d45c9e144d641bc7c6c6
Commit:        c8b6c4aee9a298a4c415d45c9e144d641bc7c6c6
Parent:        48aef76ec5e4eecfce4d0926ab60317bac763eb5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 12 09:51:42 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 12 09:51:42 2014 -0600

cachepool: Ability to convert existing LVs to cachepool type

This patch allows users to convert existing logical volumes into
cache pool LVs.  Since cache pool LVs consist of data and metadata
sub-LVs, there is also the '--poolmetadata' (similar to thin_pool)
which allows for the specification of the metadata device.
---
 tools/commands.h  |   21 +++++--
 tools/lvconvert.c |  177 ++++++++++++++++++++++++++++++++++++-----------------
 tools/toollib.c   |   35 ++++++++--
 3 files changed, 163 insertions(+), 70 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index dce5929..a078b16 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -212,13 +212,22 @@ xx(lvconvert,
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
-   "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
+   "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n\n"
 
-   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, discards_ARG,
-   force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
-   noudevsync_ARG, originname_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
-   poolmetadataspare_ARG, readahead_ARG, regionsize_ARG, repair_ARG,
-   replace_ARG, snapshot_ARG, splitmirrors_ARG, splitsnapshot_ARG,
+   "lvconvert "
+   "--type cache_pool\n"
+   "\t[--cachemode CacheMode]\n"
+   "\t[--chunksize size]\n"
+   "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
+   "\t [--poolmetadatasize size]\n"
+   "\t [--poolmetadataspare {y|n}]]\n"
+   "\tCacheDataLogicalVolume[Path]\n\n",
+
+   alloc_ARG, background_ARG, cachemode_ARG, chunksize_ARG,
+   corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
+   mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
+   poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
+   repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG, splitsnapshot_ARG,
    stripes_long_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
    trackchanges_ARG, type_ARG, use_policies_ARG, zero_ARG)
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7d28b43..5774e11 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -45,6 +45,7 @@ struct lvconvert_params {
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
+	uint32_t feature_flags; /* cache_pool */
 
 	const struct segment_type *segtype;
 	unsigned target_attr;
@@ -198,7 +199,9 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	}
 
 	/* FIXME: Check thin-pool and thin more thoroughly! */
-	if (!strcmp(type_str, "snapshot") || !strncmp(type_str, "raid", 4) ||
+	if (!strcmp(type_str, "snapshot") ||
+	    !strncmp(type_str, "raid", 4) ||
+	    !strcmp(type_str, "cache_pool") ||
 	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
 		return 1;
 
@@ -217,6 +220,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
 	int i;
+	int cache_pool = 0;
 	const char *tmp_str;
 	struct arg_value_group_list *group;
 	int region_size;
@@ -250,6 +254,20 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!strcmp(type_str, "cache_pool")) {
+		cache_pool = 1;
+		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL))) {
+			if (!strcmp(tmp_str, "writeback"))
+				lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+			else if (!strcmp(tmp_str, "writethrough"))
+				lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+			else {
+				log_error("Unknown cachemode argument");
+				return 0;
+			}
+		}
+	}
+
 	if (!arg_count(cmd, background_ARG))
 		lp->wait_completion = 1;
 
@@ -270,28 +288,31 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, thin_ARG))
 		lp->thin = 1;
 
-	if (arg_count(cmd, thinpool_ARG)) {
+	if (arg_count(cmd, thinpool_ARG) || cache_pool) {
 		if (arg_count(cmd, merge_ARG)) {
-			log_error("--thinpool and --merge are mutually exlusive.");
+			log_error("--%spool and --merge are mutually exlusive.",
+				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (mirror_or_raid_type_requested(cmd, type_str)) {
-			log_error("--thinpool and --mirrors/--type mirror/--type raid* are mutually exlusive.");
+			log_error("--%spool and --mirrors/--type mirror/--type raid* are mutually exlusive.", cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (arg_count(cmd, repair_ARG)) {
-			log_error("--thinpool and --repair are mutually exlusive.");
+			log_error("--%spool and --repair are mutually exlusive.",
+				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (snapshot_type_requested(cmd, type_str)) {
-			log_error("--thinpool and --snapshot/--type snapshot are mutually exlusive.");
+			log_error("--%spool and --snapshot/--type snapshot are mutually exlusive.", cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (arg_count(cmd, splitmirrors_ARG)) {
-			log_error("--thinpool and --splitmirrors are mutually exlusive.");
+			log_error("--%spool and --splitmirrors are mutually exlusive.", cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
-		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+		if (!cache_pool)
+			lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
 	} else if (lp->thin) {
 		log_error("--thin is only valid with --thinpool.");
 		return 0;
@@ -442,8 +463,15 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (arg_count(cmd, thinpool_ARG)) {
-		if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
+	} else if (arg_count(cmd, thinpool_ARG) || cache_pool) {
+		if (cache_pool) {
+			if (!argc) {
+				log_error("Please specify the pool data LV.");
+				return 0;
+			}
+			lp->pool_data_lv_name = argv[0];
+			argv++, argc--;
+		} else if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
 			log_error("Missing pool logical volume name.");
 			return 0;
 		}
@@ -469,7 +497,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 						cmd->default_settings.read_ahead);
 
-		/* If --thinpool contains VG name, extract it. */
+		/* If pool_data_lv_name contains VG name, extract it. */
 		if ((tmp_str = strchr(lp->pool_data_lv_name, (int) '/'))) {
 			if (!(lp->vg_name = extract_vgname(cmd, lp->pool_data_lv_name)))
 				return 0;
@@ -484,7 +512,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			}
 		}
 
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "thin-pool"));
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, cache_pool ? "cache_pool" : "thin-pool"));
 		if (!lp->segtype)
 			return_0;
 	} else { /* Mirrors (and some RAID functions) */
@@ -2552,17 +2580,46 @@ revert_new_lv:
 	return 0;
 }
 
+static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
+					 struct lvconvert_params *lp)
+{
+	if (seg_is_cache_pool(lp))
+		return update_cache_pool_params(pool_lv->vg, lp->target_attr,
+						lp->passed_args,
+						pool_lv->le_count,
+						pool_lv->vg->extent_size,
+						&lp->thin_chunk_size_calc_policy,
+						&lp->chunk_size,
+						&lp->discards,
+						&lp->poolmetadata_size,
+						&lp->zero);
+
+	return update_thin_pool_params(pool_lv->vg, lp->target_attr,
+				       lp->passed_args,
+				       pool_lv->le_count,
+				       pool_lv->vg->extent_size,
+				       &lp->thin_chunk_size_calc_policy,
+				       &lp->chunk_size,
+				       &lp->discards,
+				       &lp->poolmetadata_size,
+				       &lp->zero);
+}
+
+
+
 /*
  * Thin lvconvert version which
  *  rename metadata
  *  convert/layers thinpool over data
  *  attach metadata
  */
-static int _lvconvert_thinpool(struct cmd_context *cmd,
-			       struct logical_volume *pool_lv,
-			       struct lvconvert_params *lp)
+static int _lvconvert_to_pool(struct cmd_context *cmd,
+			      struct logical_volume *pool_lv,
+			      struct lvconvert_params *lp)
 {
 	int r = 0;
+	uint64_t min_metadata_size;
+	uint64_t max_metadata_size;
 	const char *old_name;
 	struct lv_segment *seg;
 	struct logical_volume *data_lv;
@@ -2635,25 +2692,21 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s_tmeta",
-			 pool_lv->name) < 0) ||
-	    (dm_snprintf(data_name, sizeof(data_name), "%s_tdata",
-			 pool_lv->name) < 0)) {
+	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
+			 pool_lv->name,
+			 (segtype_is_cache_pool(lp->segtype)) ?
+			  "_cmeta" : "_tmeta") < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s%s",
+			 pool_lv->name,
+			 (segtype_is_cache_pool(lp->segtype)) ?
+			 "_cdata" : "_tdata") < 0)) {
 		log_error("Failed to create internal lv names, "
-			  "thin pool name is too long.");
+			  "pool name is too long.");
 		return 0;
 	}
 
 	if (!lp->pool_metadata_lv_name) {
-		if (!update_thin_pool_params(pool_lv->vg, lp->target_attr,
-					     lp->passed_args,
-					     pool_lv->le_count,
-					     pool_lv->vg->extent_size,
-					     &lp->thin_chunk_size_calc_policy,
-					     &lp->chunk_size,
-					     &lp->discards,
-					     &lp->poolmetadata_size,
-					     &lp->zero))
+		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
@@ -2747,42 +2800,40 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 
 		lp->poolmetadata_size = metadata_lv->size;
-		if (lp->poolmetadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		max_metadata_size = (segtype_is_cache_pool(lp->segtype)) ?
+			DEFAULT_CACHE_POOL_MAX_METADATA_SIZE * 2 :
+			DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2;
+		min_metadata_size = (segtype_is_cache_pool(lp->segtype)) ?
+			DEFAULT_CACHE_POOL_MIN_METADATA_SIZE * 2 :
+			DEFAULT_THIN_POOL_MIN_METADATA_SIZE * 2;
+
+		if (lp->poolmetadata_size > max_metadata_size) {
 			log_warn("WARNING: Maximum size used by metadata is %s, rest is unused.",
-				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
-			lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-		} else if (lp->poolmetadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+				 display_size(cmd, max_metadata_size));
+			lp->poolmetadata_size = max_metadata_size;
+		} else if (lp->poolmetadata_size < min_metadata_size) {
 			log_error("Logical volume %s/%s is too small (<%s) for metadata.",
 				  metadata_lv->vg->name, metadata_lv->name,
-				  display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
+				  display_size(cmd, min_metadata_size));
 			return 0;
 		}
-		if (!update_thin_pool_params(pool_lv->vg, lp->target_attr,
-					     lp->passed_args,
-					     pool_lv->le_count,
-					     pool_lv->vg->extent_size,
-					     &lp->thin_chunk_size_calc_policy,
-					     &lp->chunk_size,
-					     &lp->discards,
-					     &lp->poolmetadata_size,
-					     &lp->zero))
+		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
 		metadata_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to activate thin metadata lv.");
+			log_error("Aborting. Failed to activate metadata lv.");
 			return 0;
 		}
 
-
 		if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
-			log_error("Aborting. Failed to wipe thin metadata lv.");
+			log_error("Aborting. Failed to wipe metadata lv.");
 			return 0;
 		}
 	}
 
 	if (!deactivate_lv(cmd, metadata_lv)) {
-		log_error("Aborting. Failed to deactivate thin metadata lv. "
+		log_error("Aborting. Failed to deactivate metadata lv. "
 			  "Manual intervention required.");
 		return 0;
 	}
@@ -2793,7 +2844,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 	old_name = data_lv->name; /* Use for pool name */
 	/*
-	 * Since we wish to have underlaying devs to match _tdata
+	 * Since we wish to have underlaying devs to match _[ct]data
 	 * rename data LV to match pool LV subtree first,
 	 * also checks for visible LV.
 	 */
@@ -2802,7 +2853,9 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return_0;
 
 	if (!(pool_lv = lv_create_empty(old_name, NULL,
-					THIN_POOL | VISIBLE_LV | LVM_READ | LVM_WRITE,
+					((segtype_is_cache_pool(lp->segtype)) ?
+					 CACHE_POOL : THIN_POOL) |
+					VISIBLE_LV | LVM_READ | LVM_WRITE,
 					ALLOC_INHERIT, data_lv->vg))) {
 		log_error("Creation of pool LV failed.");
 		return 0;
@@ -2810,8 +2863,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 	/* Allocate a new linear segment */
 	if (!(seg = alloc_lv_segment(lp->segtype, pool_lv, 0, data_lv->le_count,
-				     pool_lv->status, 0, NULL, NULL, 1, data_lv->le_count,
-				     0, 0, 0, NULL)))
+				     pool_lv->status, 0, NULL, NULL, 1,
+				     data_lv->le_count, 0, 0, 0, NULL)))
 		return_0;
 
 	/* Add the new segment to the layer LV */
@@ -2857,8 +2910,10 @@ mda_write:
 		goto out;
 	}
 
-	log_print_unless_silent("Converted %s/%s to thin pool.",
-				pool_lv->vg->name, pool_lv->name);
+	log_print_unless_silent("Converted %s/%s to %s pool.",
+				pool_lv->vg->name, pool_lv->name,
+				(segtype_is_cache_pool(lp->segtype)) ?
+				"cache" : "thin");
 
 	r = 1;
 out:
@@ -2903,7 +2958,9 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    !(lv->status & MIRRORED) && !(lv->status & RAID)) {
 		if (arg_count(cmd, use_policies_ARG))
 			return ECMD_PROCESSED; /* nothing to be done here */
-		log_error("Can't repair non-mirrored LV \"%s\".", lv->name);
+		log_error("Can't repair LV \"%s\" of segtype %s.",
+			  lv->name,
+			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
 		return ECMD_FAILED;
 	}
 
@@ -2939,11 +2996,18 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 
+	} else if (segtype_is_cache_pool(lp->segtype)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		if (!_lvconvert_to_pool(cmd, lv, lp))
+			return_ECMD_FAILED;
+
 	} else if (arg_count(cmd, thinpool_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
-		if (!_lvconvert_thinpool(cmd, lv, lp))
+		if (!_lvconvert_to_pool(cmd, lv, lp))
 			return_ECMD_FAILED;
 
 	} else if (segtype_is_raid(lp->segtype) ||
@@ -3038,8 +3102,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	if (!lv)
 		goto_out;
 
-	if (arg_count(cmd, thinpool_ARG) &&
-	    !get_pool_params(cmd, lv_config_profile(lv),
+	if (!get_pool_params(cmd, lv_config_profile(lv),
 			     &lp->passed_args, &lp->thin_chunk_size_calc_policy,
 			     &lp->chunk_size, &lp->discards,
 			     &lp->poolmetadata_size, &lp->zero))
diff --git a/tools/toollib.c b/tools/toollib.c
index 0662c9e..3dc76b8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1661,14 +1661,29 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint64_t *pool_metadata_size,
 		    int *zero)
 {
+	int cache_pool = 0;
+
+	if (!strcmp("cache_pool", arg_str_value(cmd, type_ARG, "none")))
+		cache_pool = 1;
+
+	if (!cache_pool && !arg_count(cmd, thinpool_ARG)) {
+		/* Check for arguments that should only go with pools */
+		if (arg_count(cmd, poolmetadata_ARG)) {
+			log_error("'--poolmetadata' argument is only valid when"
+				  " converting to pool LVs.");
+			return_0;
+		}
+		return 1;
+	}
+
 	*passed_args = 0;
-	if (arg_count(cmd, zero_ARG)) {
+	if (!cache_pool && arg_count(cmd, zero_ARG)) {
 		*passed_args |= PASS_ARG_ZERO;
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
 	}
 
-	if (arg_count(cmd, discards_ARG)) {
+	if (!cache_pool && arg_count(cmd, discards_ARG)) {
 		*passed_args |= PASS_ARG_DISCARDS;
 		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 		log_very_verbose("Setting pool discards: %s",
@@ -1681,15 +1696,20 @@ int get_pool_params(struct cmd_context *cmd,
 			return 0;
 		}
 		*passed_args |= PASS_ARG_CHUNK_SIZE;
-		*chunk_size = arg_uint_value(cmd, chunksize_ARG,
+		*chunk_size = arg_uint_value(cmd, chunksize_ARG, cache_pool ?
+					     DM_CACHE_MIN_DATA_BLOCK_SIZE :
 					     DM_THIN_MIN_DATA_BLOCK_SIZE);
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	}
 
-	if (!update_profilable_pool_params(cmd, profile, *passed_args,
-					   chunk_size_calc_method, chunk_size,
-					   discards, zero))
+	if (cache_pool) {
+		//FIXME: add cache_pool support to update_profilable_pool_params
+		if (!(*passed_args & PASS_ARG_CHUNK_SIZE))
+			*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
+	} else if (!update_profilable_pool_params(cmd, profile, *passed_args,
+						  chunk_size_calc_method,
+						  chunk_size, discards, zero))
 		return_0;
 
 	if (arg_count(cmd, poolmetadatasize_ARG)) {
@@ -1699,7 +1719,8 @@ int get_pool_params(struct cmd_context *cmd,
 		}
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
 	}
-	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
+					       UINT64_C(0));
 
 	return 1;
 }


