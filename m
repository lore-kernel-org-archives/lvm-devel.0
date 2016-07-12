From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Jul 2016 11:23:22 +0000 (UTC)
Subject: master - cleanup: lvconvert display_lvname and indent updates
Message-ID: <20160712112322.D21DC60F8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=525497141810752c98e6ab0ed013ae36f5dd702f
Commit:        525497141810752c98e6ab0ed013ae36f5dd702f
Parent:        fd53d86eeada2b03fff2ca0ebb8ad25280b90cdd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 11:05:34 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 12 13:20:20 2016 +0200

cleanup: lvconvert  display_lvname and indent updates

Use display_lvname() for printing vg/lv names.
Add some missing dots.
Some indents.
---
 tools/lvconvert.c |  272 ++++++++++++++++++++++++-----------------------------
 1 files changed, 121 insertions(+), 151 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 72dc381..b8c1959 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -359,6 +359,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 		log_error("--cache requires --cachepool.");
 		return 0;
 	}
+
 	if ((lp->cache || cachepool) &&
 	    !get_cache_params(cmd, &lp->cache_mode, &lp->policy_name, &lp->policy_settings)) {
 		log_error("Failed to parse cache policy and/or settings.");
@@ -636,15 +637,15 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return_0;
 	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
 		;
-	else if (lp->splitcache)	
+	else if (lp->splitcache)
 		;
-	else if (lp->split)	
+	else if (lp->split)
 		;
-	else if (lp->uncache)	
+	else if (lp->uncache)
 		;
-	else if (lp->cache)	
+	else if (lp->cache)
 		;
-	else if (lp->thin)	
+	else if (lp->thin)
 		;
 	else if (lp->keep_mimages)	/* --splitmirrors */
 		;
@@ -726,7 +727,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (arg_is_set(cmd, regionsize_ARG)) {
 			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
 				    SIGN_MINUS) {
-				log_error("Negative regionsize is invalid");
+				log_error("Negative regionsize is invalid.");
 				return 0;
 			}
 			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
@@ -734,7 +735,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			region_size = get_default_region_size(cmd);
 			if (region_size < 0) {
 				log_error("Negative regionsize in "
-					  "configuration file is invalid");
+					  "configuration file is invalid.");
 				return 0;
 			}
 			lp->region_size = region_size;
@@ -743,14 +744,14 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
 			log_error("Region size (%" PRIu32 ") must be "
 				  "a multiple of machine memory "
-				  "page size (%d)",
+				  "page size (%d).",
 				  lp->region_size, pagesize >> SECTOR_SHIFT);
 			return 0;
 		}
 
 		if (!is_power_of_2(lp->region_size)) {
 			log_error("Region size (%" PRIu32
-				  ") must be a power of 2", lp->region_size);
+				  ") must be a power of 2.", lp->region_size);
 			return 0;
 		}
 
@@ -773,7 +774,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			/* changing mirror type? */
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
-		} 
+		}
 	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or linear or raid0 */
 		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
@@ -798,7 +799,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", lp->segtype->name);
+			  "detected in your kernel.", lp->segtype->name);
 		return 0;
 	}
 
@@ -1171,8 +1172,8 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 			return_0;
 		/*
 		 * FIXME: This simple approach won't work in cluster mirrors,
-		 *        but it doesn't matter because we don't support
-		 *        mirrored logs in cluster mirrors.
+		 *	  but it doesn't matter because we don't support
+		 *	  mirrored logs in cluster mirrors.
 		 */
 		if (old_log_count &&
 		    !lv_update_and_reload(log_lv))
@@ -1231,7 +1232,7 @@ static void _remove_missing_empty_pv(struct volume_group *vg, struct dm_list *re
  *  2) Parses the CLI args to find the new desired values
  *  3) Adjusts 'lp->mirrors' to the appropriate absolute value.
  *     (Remember, 'lp->mirrors' is specified in terms of the number of "copies"
- *      vs. the number of mimages.  It can also be a relative value.)
+ *     vs. the number of mimages.  It can also be a relative value.)
  *  4) Sets 'lp->need_polling' if collapsing
  *  5) Validates other mirror params
  *
@@ -1326,11 +1327,11 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 * log daemon is multi-threaded.
 	 */
 	if ((*new_log_count == MIRROR_LOG_MIRRORED) && vg_is_clustered(lv->vg)) {
-		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
 		return 0;
 	}
 
-	log_verbose("Setting logging type to %s", get_mirror_log_name(*new_log_count));
+	log_verbose("Setting logging type to %s.", get_mirror_log_name(*new_log_count));
 
 	/*
 	 * Region size must not change on existing mirrors
@@ -1348,14 +1349,13 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 */
 	if (lv_is_mirrored(lv) && dm_list_size(&lv->segments) != 1) {
 		log_error("Logical volume %s has multiple "
-			  "mirror segments.", lv->name);
+			  "mirror segments.", display_lvname(lv));
 		return 0;
 	}
 
 	return 1;
 }
 
-
 /*
  * _lvconvert_mirrors_aux
  *
@@ -1378,7 +1378,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 	if ((lp->mirrors == 1) && !lv_is_mirrored(lv)) {
 		log_warn("Logical volume %s is already not mirrored.",
-			 lv->name);
+			 display_lvname(lv));
 		return 1;
 	}
 
@@ -1433,7 +1433,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		 */
 		if (lv_is_origin(lv)) {
 			log_error("Can't add additional mirror images to "
-				  "mirrors that are under snapshots");
+				  "mirrors that are under snapshots,");
 			return 0;
 		}
 
@@ -1443,7 +1443,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		 */
 		if (find_temporary_mirror(lv) || lv_is_converting(lv)) {
 			log_error("%s is already being converted.  Unable to start another conversion.",
-				  lv->name);
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -1459,7 +1459,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
-			log_error("Failed to insert resync layer");
+			log_error("Failed to insert resync layer.");
 			return 0;
 		}
 
@@ -1477,7 +1477,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 			    !vg_commit(lv->vg)) {
 				log_error("ABORTING: Failed to remove "
 					  "temporary mirror layer %s.",
-					  layer_lv->name);
+					  display_lvname(layer_lv));
 				log_error("Manual cleanup with vgcfgrestore "
 					  "and dmsetup may be required.");
 				return 0;
@@ -1505,7 +1505,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		if (lp->keep_mimages) {
 			if (arg_is_set(cmd, trackchanges_ARG)) {
 				log_error("--trackchanges is not available "
-					  "to 'mirror' segment type");
+					  "to 'mirror' segment type.");
 				return 0;
 			}
 			if (!lv_split_mirror_images(lv, lp->lv_split_name,
@@ -1548,7 +1548,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 	if (force && _failed_mirrors_count(lv) == (int)lv_mirror_count(lv)) {
 		log_error("No usable images left in %s.", display_lvname(lv));
 		return lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0);
-        }
+	}
 
 	/*
 	 * We must adjust the log first, or the entire mirror
@@ -1692,6 +1692,7 @@ static int _lvconvert_validate_thin(struct logical_volume *lv,
 		  display_lvname(seg_lv(first_seg(lv), 0)));
 	log_error("For pool metadata volume conversion use %s.",
 		  display_lvname(first_seg(lv)->metadata_lv));
+
 	return 0;
 }
 
@@ -1713,7 +1714,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	if (lp->merge_mirror) {
 		log_error("Unable to merge mirror images"
-			  "of segment type 'mirror'");
+			  "of segment type 'mirror'.");
 		return 0;
 	}
 
@@ -1750,14 +1751,14 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 					     &new_mimage_count, &new_log_count))
 		return 0;
 
-        if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
-             (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
-            lp->pv_count) {
+	if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
+	     (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
+	    lp->pv_count) {
 		log_error("Cannot both allocate and free extents when "
 			  "specifying physical volumes to use.");
 		log_error("Please specify the operation in two steps.");
 		return 0;
-        }
+	}
 
 	/* Nothing to do?  (Probably finishing collapse.) */
 	if ((old_mimage_count == new_mimage_count) &&
@@ -1772,9 +1773,11 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 
 	if (!lp->need_polling)
-		log_print_unless_silent("Logical volume %s converted.", lv->name);
+		log_print_unless_silent("Logical volume %s converted.",
+					display_lvname(lv));
 
 	backup(lv->vg);
+
 	return 1;
 }
 
@@ -1845,7 +1848,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 	/* Can only change image count for raid1 and linear */
 	if (lp->mirrors_supplied && !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
-		log_error("'--mirrors/-m' is not compatible with %s",
+		log_error("'--mirrors/-m' is not compatible with %s.",
 			  lvseg_name(seg));
 		return 0;
 	}
@@ -1854,14 +1857,14 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return_0;
 
 	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype)) {
-		log_error("Unable to convert %s/%s from %s to %s",
-			  lv->vg->name, lv->name,
-			  lvseg_name(seg), lp->segtype->name);
+		log_error("Unable to convert %s from %s to %s.",
+			  display_lvname(lv), lvseg_name(seg),
+			  lp->segtype->name);
 		return 0;
 	}
 
 	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
-		log_error("Raid conversions require -m/--mirrors");
+		log_error("Raid conversions require -m/--mirrors.");
 		return 0;
 	}
 
@@ -1876,7 +1879,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			image_count = lp->mirrors + 1;
 
 		if (image_count < 1) {
-			log_error("Unable to %s images by specified amount",
+			log_error("Unable to %s images by specified amount.",
 				  lp->keep_mimages ? "split" : "reduce");
 			return 0;
 		}
@@ -1904,7 +1907,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size, lp->pvh))
 			return_0;
-		log_print_unless_silent("Logical volume %s successfully converted", display_lvname(lv));
+		log_print_unless_silent("Logical volume %s successfully converted.",
+					display_lvname(lv));
 		return 1;
 	}
 
@@ -1913,8 +1917,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 	if (lp->repair) {
 		if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-			log_error("%s/%s must be active %sto perform this"
-				  " operation.", lv->vg->name, lv->name,
+			log_error("%s must be active %sto perform this operation.",
+				  display_lvname(lv),
 				  vg_is_clustered(lv->vg) ?
 				  "exclusive locally " : "");
 			return 0;
@@ -1922,14 +1926,14 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		if (!seg_is_striped(seg) && !seg_is_any_raid0(seg) &&
 		    !lv_raid_percent(lv, &sync_percent)) {
-			log_error("Unable to determine sync status of %s/%s.",
-				  lv->vg->name, lv->name);
+			log_error("Unable to determine sync status of %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 
 		if (sync_percent != DM_PERCENT_100) {
-			log_warn("WARNING: %s/%s is not in-sync.",
-				 lv->vg->name, lv->name);
+			log_warn("WARNING: %s is not in-sync.",
+				 display_lvname(lv));
 			log_warn("WARNING: Portions of the array may be unrecoverable.");
 
 			/*
@@ -1947,24 +1951,25 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 				return_0;
 
 			if (!lv_raid_replace(lv, failed_pvs, lp->pvh)) {
-				log_error("Failed to replace faulty devices in"
-					  " %s/%s.", lv->vg->name, lv->name);
+				log_error("Failed to replace faulty devices in %s.",
+					  display_lvname(lv));
 				return 0;
 			}
 
-			log_print_unless_silent("Faulty devices in %s/%s successfully"
-						" replaced.", lv->vg->name, lv->name);
+			log_print_unless_silent("Faulty devices in %s successfully"
+						" replaced.", display_lvname(lv));
 			return 1;
 		}
 
 		/* "warn" if policy not set to replace */
 		if (arg_is_set(cmd, usepolicies_ARG))
-			log_warn("Use 'lvconvert --repair %s/%s' to replace "
-				 "failed device.", lv->vg->name, lv->name);
+			log_warn("Use 'lvconvert --repair %s' to replace "
+				 "failed device.", display_lvname(lv));
 		return 1;
 	}
 
 	log_error("Conversion operation not yet supported.");
+
 	return 0;
 }
 
@@ -2006,7 +2011,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 
 	if (is_lockd_type(vg->lock_type)) {
 		/* FIXME: we need to create a lock for the new LV. */
-		log_error("Unable to split snapshots in VG with lock_type %s", vg->lock_type);
+		log_error("Unable to split snapshots in VG with lock_type %s.", vg->lock_type);
 		return 0;
 	}
 
@@ -2213,7 +2218,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
-		log_warn("WARNING: %s not zeroed", snap_name);
+		log_warn("WARNING: %s not zeroed.", snap_name);
 	else {
 		lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, lv) ||
@@ -2351,7 +2356,8 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 					"next activation of %s.",
 					display_lvname(lv), display_lvname(origin));
 	else
-		log_print_unless_silent("Merging of volume %s started.", lv->name);
+		log_print_unless_silent("Merging of volume %s started.",
+					display_lvname(lv));
 
 	return 1;
 }
@@ -2442,6 +2448,7 @@ out:
 		log_print_unless_silent("Merging of thin snapshot %s will occur on "
 					"next activation of %s.",
 					display_lvname(lv), display_lvname(origin));
+
 	return r;
 }
 
@@ -2543,9 +2550,9 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	}
 
 	if (!(ret = exec_cmd(cmd, (const char * const *)argv, &status, 1))) {
-		log_error("Repair of thin metadata volume of thin pool %s/%s failed (status:%d). "
+		log_error("Repair of thin metadata volume of thin pool %s failed (status:%d). "
 			  "Manual repair required!",
-			  pool_lv->vg->name, pool_lv->name, status);
+			  display_lvname(pool_lv), status);
 		goto deactivate_mlv;
 	}
 
@@ -2632,11 +2639,11 @@ deactivate_pmslv:
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
-	log_warn("WARNING: If everything works, remove \"%s/%s\".",
-		 mlv->vg->name, mlv->name);
+	log_warn("WARNING: If everything works, remove %s volume.",
+		 display_lvname(mlv));
 
-	log_warn("WARNING: Use pvmove command to move \"%s/%s\" on the best fitting PV.",
-		 pool_lv->vg->name, first_seg(pool_lv)->metadata_lv->name);
+	log_warn("WARNING: Use pvmove command to move %s on the best fitting PV.",
+		 display_lvname(first_seg(pool_lv)->metadata_lv));
 
 	return 1;
 }
@@ -3230,7 +3237,7 @@ mda_write:
 			 "provisioning.", display_size(cmd, seg->chunk_size));
 
 	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
-		log_error("Failed to lock pool LV %s/%s", vg->name, pool_lv->name);
+		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
 		goto out;
 	}
 
@@ -3240,9 +3247,11 @@ mda_write:
 			  display_lvname(pool_lv));
 		/* Deactivate subvolumes */
 		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
-			log_error("Failed to deactivate pool data logical volume.");
+			log_error("Failed to deactivate pool data logical volume %s.",
+				  display_lvname(seg_lv(seg, 0)));
 		if (!deactivate_lv(cmd, seg->metadata_lv))
-			log_error("Failed to deactivate pool metadata logical volume.");
+			log_error("Failed to deactivate pool metadata logical volume %s.",
+				  display_lvname(seg->metadata_lv));
 		goto out;
 	}
 
@@ -3277,7 +3286,7 @@ out:
 	return r;
 #if 0
 revert_new_lv:
-        /* TBD */
+	/* TBD */
 	if (!lp->pool_metadata_lv_name) {
 		if (!deactivate_lv(cmd, metadata_lv)) {
 			log_error("Failed to deactivate metadata lv.");
@@ -3350,9 +3359,8 @@ static int _lvconvert_cache(struct cmd_context *cmd,
  * Separate a COW snapshot LV from its origin.
  * lvconvert --splitsnapshot LV
  */
-
 static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct logical_volume *lv,
-			                       struct lvconvert_params *lp)
+					       struct lvconvert_params *lp)
 {
 	return _lvconvert_splitsnapshot(cmd, lv, lp);
 }
@@ -3361,9 +3369,8 @@ static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct l
  * Merge a COW snapshot LV into its origin.
  * lvconvert --merge LV
  */
-
 static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_volume *lv,
-			               struct lvconvert_params *lp)
+				       struct lvconvert_params *lp)
 {
 	return _lvconvert_merge_old_snapshot(cmd, lv, lp);
 }
@@ -3374,7 +3381,7 @@ static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_v
  */
 
 static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_volume *lv,
-			              struct lvconvert_params *lp)
+				      struct lvconvert_params *lp)
 {
 	return _lvconvert_merge_thin_snapshot(cmd, lv, lp);
 }
@@ -3383,9 +3390,8 @@ static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_vo
  * Split and preserve a cache pool from the data portion of a thin pool LV.
  * lvconvert --splitcache LV
  */
-
 static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
-				         struct lvconvert_params *lp)
+					 struct lvconvert_params *lp)
 {
 	struct logical_volume *sublv1;
 
@@ -3403,7 +3409,6 @@ static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical
  * Split and remove a cache pool from the data portion of a thin pool LV.
  * lvconvert --uncache LV
  */
-
 static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_volume *lv,
 				      struct lvconvert_params *lp)
 {
@@ -3423,9 +3428,8 @@ static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_vo
  * Repair a thin pool LV.
  * lvconvert --repair LV
  */
-
 static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_volume *lv,
-			             struct lvconvert_params *lp)
+				     struct lvconvert_params *lp)
 {
 	return _lvconvert_thin_pool_repair(cmd, lv, lp);
 }
@@ -3443,9 +3447,8 @@ static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_vol
  * Alternate syntax:
  * lvconvert --cache LV
  */
-
 static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volume *lv,
-			            struct lvconvert_params *lp)
+				    struct lvconvert_params *lp)
 {
 	/* lvconvert --type cache includes an implicit conversion of the cachepool arg to type cache-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
@@ -3464,9 +3467,8 @@ static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volu
  * FIXME: this will change so --swap-poolmetadata defines the operation.
  * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
  */
-
 static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
-			                   struct lvconvert_params *lp)
+					   struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3475,9 +3477,8 @@ static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logic
  * Split and preserve a cache pool from a cache LV.
  * lvconvert --splitcache LV
  */
-
 static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
-			                    struct lvconvert_params *lp)
+					    struct lvconvert_params *lp)
 {
 	return _lvconvert_split_cached(cmd, lv);
 }
@@ -3486,9 +3487,8 @@ static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logi
  * Split and remove a cache pool from a cache LV.
  * lvconvert --uncache LV
  */
-
 static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical_volume *lv,
-			                 struct lvconvert_params *lp)
+					 struct lvconvert_params *lp)
 {
 	return _lvconvert_uncache(cmd, lv, lp);
 }
@@ -3500,9 +3500,8 @@ static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical
  * Required options:
  * --trackchanges | --name Name
  */
-
 static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-			                     struct lvconvert_params *lp)
+					     struct lvconvert_params *lp)
 {
 	struct logical_volume *sublv1;
 
@@ -3526,9 +3525,8 @@ static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct lo
  * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
  * lvconvert --thinpool LV
  */
-
 static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			                   struct lvconvert_params *lp)
+					   struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3537,7 +3535,6 @@ static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logic
  * Split a cache volume from a cache pool LV.
  * lvconvert --splitcache LV
  */
-
 static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
 					  struct lvconvert_params *lp)
 {
@@ -3569,9 +3566,8 @@ static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logica
  * FIXME: this will change so --swap-poolmetadata defines the operation.
  * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
  */
-
 static int _convert_cache_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
-			                    struct lvconvert_params *lp)
+					    struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3580,9 +3576,8 @@ static int _convert_cache_pool_swapmetadata(struct cmd_context *cmd, struct logi
  * Change the number of images in a mirror LV.
  * lvconvert --mirrors Number LV
  */
-
 static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
@@ -3596,7 +3591,7 @@ static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume
  */
 
 static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-			                struct lvconvert_params *lp)
+					struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
@@ -3605,9 +3600,8 @@ static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_
  * Change the type of log used by a mirror LV.
  * lvconvert --mirrorlog Type LV
  */
-
 static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
@@ -3619,9 +3613,8 @@ static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *l
  * Auxiliary operation:
  * Removes missing, empty PVs from the VG, like vgreduce.
  */
-
 static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	struct dm_list *failed_pvs;
 	int ret;
@@ -3643,9 +3636,8 @@ static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume
  * Alternate syntax:
  * lvconvert --mirrors 0 LV
  */
-
 static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
@@ -3654,9 +3646,8 @@ static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume
  * Convert mirror LV to raid1 LV.
  * lvconvert --type raid1 LV
  */
-
 static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
-			        struct lvconvert_params *lp)
+				struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -3665,9 +3656,8 @@ static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *
  * Change the number of images in a raid1 LV.
  * lvconvert --mirrors Number LV
  */
-
 static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *lv,
-			        struct lvconvert_params *lp)
+				struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -3679,9 +3669,8 @@ static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *
  * Required options:
  * --trackchanges | --name Name
  */
-
 static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-			    	      struct lvconvert_params *lp)
+				      struct lvconvert_params *lp)
 {
 	/* FIXME: split the splitmirrors section out of _lvconvert_raid and call it here. */
 	return _lvconvert_raid(lv, lp);
@@ -3692,7 +3681,6 @@ static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_vo
  * previously split from the originalLV using --trackchanges.
  * lvconvert --merge LV
  */
-
 static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
@@ -3707,9 +3695,8 @@ static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *l
  * Auxiliary operation:
  * Removes missing, empty PVs from the VG, like vgreduce.
  */
-
 static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *lv,
-			        struct lvconvert_params *lp)
+				struct lvconvert_params *lp)
 {
 	struct dm_list *failed_pvs;
 	int ret;
@@ -3727,11 +3714,10 @@ static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *
 
 /*
  * Replace a specific PV in a raid* LV with another PV.
- * lvconvert --replace PV LV 
+ * lvconvert --replace PV LV
  */
-
 static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume *lv,
-			         struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	/* FIXME: remove the replace section from _lvconvert_raid */
 	return _lvconvert_raid(lv, lp);
@@ -3745,9 +3731,8 @@ static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume
  * Alternate syntax:
  * lvconvert --snapshot LV SnapshotLV
  */
-
 static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	return _lvconvert_snapshot(cmd, lv, lp);
 }
@@ -3765,7 +3750,6 @@ static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume
  * Alternate syntax:
  * lvconvert --thin LV
  */
-
 static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -3791,7 +3775,6 @@ static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv
  * Alternate syntax:
  * lvconvert --cache LV
  */
-
 static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
@@ -3812,9 +3795,8 @@ static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *l
  * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
  * lvconvert --thinpool LV
  */
-
 static int _convert_raid_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			           struct lvconvert_params *lp)
+				   struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3823,9 +3805,8 @@ static int _convert_raid_thin_pool(struct cmd_context *cmd, struct logical_volum
  * Convert a raid* LV to cache-pool LV.
  * lvconvert --type cache-pool LV
  */
-
 static int _convert_raid_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			            struct lvconvert_params *lp)
+				    struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3834,7 +3815,6 @@ static int _convert_raid_cache_pool(struct cmd_context *cmd, struct logical_volu
  * Convert a raid* LV to use a different raid level.
  * lvconvert --type raid* LV
  */
-
 static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -3845,9 +3825,8 @@ static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv
  * Convert a raid* LV to a striped LV.
  * lvconvert --type striped LV
  */
-
 static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
-			         struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -3856,9 +3835,8 @@ static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume
  * Convert a raid* LV to a linear LV.
  * lvconvert --type linear LV
  */
-
 static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,
-			        struct lvconvert_params *lp)
+				struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -3868,9 +3846,8 @@ static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *
  * previously split from the raid1 LV using --trackchanges.
  * lvconvert --merge LV
  */
-
 static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -3883,9 +3860,8 @@ static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume
  * Alternate syntax:
  * lvconvert --snapshot LV SnapshotLV
  */
-
 static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-			             struct lvconvert_params *lp)
+				     struct lvconvert_params *lp)
 {
 	return _lvconvert_snapshot(cmd, lv, lp);
 }
@@ -3903,9 +3879,8 @@ static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_vol
  * Alternate syntax:
  * lvconvert --thin LV
  */
-
 static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume *lv,
-			         struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
@@ -3931,7 +3906,7 @@ static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume
  */
 
 static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume *lv,
-			          struct lvconvert_params *lp)
+				  struct lvconvert_params *lp)
 {
 	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
@@ -3950,9 +3925,8 @@ static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume
  * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
  * lvconvert --thinpool LV
  */
-
 static int _convert_striped_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			              struct lvconvert_params *lp)
+				      struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3961,9 +3935,8 @@ static int _convert_striped_thin_pool(struct cmd_context *cmd, struct logical_vo
  * Convert a striped/linear LV to a cache-pool LV.
  * lvconvert --type cache-pool LV
  */
-
 static int _convert_striped_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			               struct lvconvert_params *lp)
+				       struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
@@ -3979,9 +3952,8 @@ static int _convert_striped_cache_pool(struct cmd_context *cmd, struct logical_v
  * This is equivalent to above when global/mirror_segtype_default="mirror".
  * lvconvert --mirrors Number LV
  */
-
 static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volume *lv,
-			           struct lvconvert_params *lp)
+				   struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
@@ -3997,9 +3969,8 @@ static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volum
  * This is equivalent to above when global/mirror_segtype_default="raid1".
  * lvconvert --mirrors Number LV
  */
-
 static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume *lv,
-			         struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
@@ -4009,9 +3980,8 @@ static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume
  *
  * _convert_<lvtype>
  */
-
 static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-		                 struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	if (arg_is_set(cmd, splitsnapshot_ARG))
 		return _convert_cow_snapshot_splitsnapshot(cmd, lv, lp);
@@ -4020,7 +3990,7 @@ static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume
 	if (arg_is_set(cmd, merge_ARG))
 		return _convert_cow_snapshot_merge(cmd, lv, lp);
 
-	log_error("Operation not permitted on COW snapshot LV %s", display_lvname(lv));
+	log_error("Operation not permitted on COW snapshot LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a COW snapshot LV are:\n"
 		  "  --splitsnapshot\n"
 		  "  --merge\n");
@@ -4034,7 +4004,7 @@ static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *
 	if (arg_is_set(cmd, merge_ARG))
 		return _convert_thin_volume_merge(cmd, lv, lp);
 
-	log_error("Operation not permitted on thin LV %s", display_lvname(lv));
+	log_error("Operation not permitted on thin LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a thin LV are:\n"
 		  "  --merge\n");
 	return 0;
@@ -4068,7 +4038,7 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 
 	/* FIXME: add --swapmetadata to list of permitted operations. */
 
-	log_error("Operation not permitted on thin pool LV %s", display_lvname(lv));
+	log_error("Operation not permitted on thin pool LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a thin pool LV are:\n"
 		  "  --splitcache  (operates on cache sub LV)\n"
 		  "  --uncache     (operates on cache sub LV)\n"
@@ -4078,7 +4048,7 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 }
 
 static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume *lv,
-			         struct lvconvert_params *lp)
+				 struct lvconvert_params *lp)
 {
 	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
 
@@ -4103,7 +4073,7 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
-	log_error("Operation not permitted on cache LV %s", display_lvname(lv));
+	log_error("Operation not permitted on cache LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a cache LV are:\n"
 		  "  --splitcache\n"
 		  "  --uncache\n"
@@ -4129,7 +4099,7 @@ static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *l
 
 	/* FIXME: add --swapmetadata to list of permitted operations. */
 
-	log_error("Operation not permitted on cache pool LV %s", display_lvname(lv));
+	log_error("Operation not permitted on cache pool LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a cache pool LV are:\n"
 		  "  --splitcache    (operates on cache LV)\n");
 	return 0;
@@ -4179,7 +4149,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 		return 1;
 	}
 
-	log_error("Operation not permitted on mirror LV %s", display_lvname(lv));
+	log_error("Operation not permitted on mirror LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a mirror LV are:\n"
 		  "  --mirrors\n"
 		  "  --splitmirrors\n"
@@ -4187,6 +4157,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --repair\n"
 		  "  --type linear\n"
 		  "  --type raid*\n");
+
 	return 0;
 }
 
@@ -4242,7 +4213,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
-	log_error("Operation not permitted on raid LV %s", display_lvname(lv));
+	log_error("Operation not permitted on raid LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a raid LV are:\n"
 		  "  --mirrors\n"
 		  "  --splitmirrors\n"
@@ -4307,7 +4278,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
-	log_error("Operation not permitted on striped or linear LV %s", display_lvname(lv));
+	log_error("Operation not permitted on striped or linear LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a striped or linear LV are:\n"
 		  "  --merge\n"
 		  "  --type snapshot\n"
@@ -4317,6 +4288,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --type cache-pool\n"
 		  "  --type mirror\n"
 		  "  --type raid*\n");
+
 	return 0;
 }
 
@@ -4332,7 +4304,6 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
  *             _convert_lvtype_operation();
  *
  */
-
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvconvert_params *lp)
 {
@@ -4433,7 +4404,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 out:
 	return ret ? ECMD_PROCESSED : ECMD_FAILED;
-
 }
 
 static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_context *cmd,
@@ -4488,7 +4458,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 
 	if (test_mode() && is_lockd_type(vg->lock_type)) {
-		log_error("Test mode is not yet supported with lock type %s",
+		log_error("Test mode is not yet supported with lock type %s.",
 			  vg->lock_type);
 		return ECMD_FAILED;
 	}


