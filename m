From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:05 +0000 (UTC)
Subject: master - lvconvert: remove unused calls for repair and replace
Message-ID: <20170213181005.A94DD60EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=254bffb95d6330662632eda472991b2fc0008d94
Commit:        254bffb95d6330662632eda472991b2fc0008d94
Parent:        35b9d4d6e9406396c90a75574f04a7018f3d6258
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 17 16:04:59 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: remove unused calls for repair and replace

repair and replace are no longer called from the
monolithic lvconvert code, so remove the unused code.
---
 tools/lvconvert.c |  237 ++--------------------------------------------------
 1 files changed, 10 insertions(+), 227 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 79b1525..1c5c6ff 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -67,12 +67,6 @@ typedef enum {
 	/* Reconstruct a snapshot from its origin and COW */
 	CONV_SNAPSHOT = 8,
 
-	/* Replace devices in a raid LV with alternatives */
-	CONV_REPLACE = 9,
-
-	/* Repair a mirror, raid or thin LV */
-	CONV_REPAIR = 10,
-
 	/* Convert normal LV into one in a thin pool */
 	CONV_THIN = 11,
 
@@ -90,8 +84,6 @@ struct lvconvert_params {
 	int cache;		/* 6 */
 	int uncache;		/* 7 */
 	int snapshot;		/* 8 */
-	int replace;		/* 9 */
-	int repair;		/* 10 */
 	int thin;		/* 11 */
 	/* other */		/* 12 */
 
@@ -147,10 +139,6 @@ struct lvconvert_params {
 	char **pvs;
 	struct dm_list *pvh;
 
-	int replace_pv_count;
-	char **replace_pvs;
-	struct dm_list *replace_pvh;
-
 	struct logical_volume *lv_to_poll;
 	struct dm_list idls;
 
@@ -298,7 +286,6 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
  	 *        It is the duty of lvcreate/lvrename to avoid reserved names.
  	 */
 	if (!lp->merge_mirror &&
-	    !lp->repair &&
 	    !lp->keep_mimages &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
@@ -498,9 +485,6 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			struct lvconvert_params *lp)
 {
-	int i;
-	const char *tmp_str;
-	struct arg_value_group_list *group;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
@@ -530,16 +514,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return_0;
 		lp->merge = 1;
 		_set_conv_type(lp, CONV_MERGE);
-	} else if (arg_is_set(cmd, repair_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
-					    repair_ARG,
-					    alloc_ARG, usepolicies_ARG,
-					    background_ARG, interval_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->repair = 1;
-		_set_conv_type(lp, CONV_REPAIR);
 	} else if (arg_is_set(cmd, split_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
 					    split_ARG,
@@ -573,9 +547,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return_0;
 		lp->uncache = 1;
 		_set_conv_type(lp, CONV_UNCACHE);
-	} else if (arg_is_set(cmd, replace_ARG)) {
-		lp->replace = 1;
-		_set_conv_type(lp, CONV_REPLACE);
 	}
 
 	if (arg_is_set(cmd, cache_ARG)) {
@@ -663,13 +634,13 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	/* If no other case was identified, then use of --stripes means --type striped */
 	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str && !lp->merge && !lp->splitsnapshot &&
 	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
-	    !lp->replace && !lp->repair && !lp->mirrorlog && !lp->corelog &&
+	    !lp->mirrorlog && !lp->corelog &&
 	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
 		lp->type_str = SEG_TYPE_NAME_STRIPED;
 
 	if ((_snapshot_type_requested(cmd, lp->type_str) || lp->merge) &&
 	    (lp->mirrorlog || _mirror_or_raid_type_requested(cmd, lp->type_str) ||
-	     lp->repair || arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(lp->type_str) ||
+	     arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(lp->type_str) ||
 	     _striped_type_requested(lp->type_str))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
 			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped/--type linear, "
@@ -679,7 +650,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
 	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(lp->type_str) ||
-	      _raid0_type_requested(lp->type_str) || lp->repair || arg_is_set(cmd, thinpool_ARG))) {
+	      _raid0_type_requested(lp->type_str) || arg_is_set(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
 			  "with --mirrors/--type mirror/--type raid*/--type striped/--type linear, --repair and --thinpool");
 		return 0;
@@ -696,7 +667,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	/* We should have caught all these cases already. */
 	if (lp->merge + lp->splitsnapshot + lp->splitcache + lp->split + lp->uncache +
-	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace + lp->repair > 1) {
+	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot > 1) {
 		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
 		return 0;
 	}
@@ -713,8 +684,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 *   lp->thin
 	 *   lp->keep_mimages
 	 *   lp->snapshot
-	 *   lp->replace
-	 *   lp->repair
 	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
@@ -727,7 +696,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	case CONV_CACHE:
 	case CONV_UNCACHE:
 	case CONV_THIN:
-	case CONV_REPAIR:
                 break;
 	case CONV_SNAPSHOT:	/* Snapshot creation from pre-existing cow */
 		if (!argc) {
@@ -765,28 +733,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
 		break;
 
-	case CONV_REPLACE:	/* RAID device replacement */
-		lp->replace_pv_count = arg_count(cmd, replace_ARG);
-		lp->replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * lp->replace_pv_count);
-		if (!lp->replace_pvs)
-			return_0;
-
-		i = 0;
-		dm_list_iterate_items(group, &cmd->arg_value_groups) {
-			if (!grouped_arg_is_set(group->arg_values, replace_ARG))
-				continue;
-			if (!(tmp_str = grouped_arg_str_value(group->arg_values,
-							      replace_ARG,
-							      NULL))) {
-				log_error("Failed to get '--replace' argument");
-				return 0;
-			}
-			if (!(lp->replace_pvs[i++] = dm_pool_strdup(cmd->mem,
-								    tmp_str)))
-				return_0;
-		}
-		break;
-
 	case CONV_OTHER:
 		if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
 			   lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
@@ -1315,7 +1261,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 */
 	if (!lp->mirrors_supplied && !lp->mirrorlog &&
 	    !lp->corelog && !arg_is_set(cmd, regionsize_ARG) &&
-	    !lp->keep_mimages && !lp->repair) {
+	    !lp->keep_mimages) {
 		*new_mimage_count = *old_mimage_count;
 		*new_log_count = *old_log_count;
 
@@ -1820,12 +1766,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	/* Nothing to do?  (Probably finishing collapse.) */
 	if ((old_mimage_count == new_mimage_count) &&
-	    (old_log_count == new_log_count) && !lp->repair)
+	    (old_log_count == new_log_count))
 		return 1;
 
-	if (lp->repair)
-		return _lvconvert_mirrors_repair(cmd, lv, lp, lp->pvh);
-
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 				    new_mimage_count, new_log_count, lp->pvh))
 		return_0;
@@ -1858,33 +1801,6 @@ static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 	return 1;
 }
 
-static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
-				       struct lvconvert_params *lp,
-				       int *replace_dev)
-{
-	const char *dev_policy;
-
-	*replace_dev = 1;
-
-	if (arg_is_set(cmd, usepolicies_ARG)) {
-		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG, NULL);
-
-		if (!strcmp(dev_policy, "allocate") ||
-		    !strcmp(dev_policy, "replace"))
-			return;
-
-		/* else if (!strcmp(dev_policy, "anything_else")) -- no replace */
-		*replace_dev = 0;
-		return;
-	}
-
-	if (!lp->yes &&
-	    yes_no_prompt("Attempt to replace failed RAID images "
-			  "(requires full device resync)? [y/n]: ") == 'n') {
-		*replace_dev = 0;
-	}
-}
-
 /* Check for dm-raid target supporting raid4 conversion properly. */
 static int _raid4_conversion_supported(struct logical_volume *lv, struct lvconvert_params *lp)
 {
@@ -1906,8 +1822,7 @@ static int _raid4_conversion_supported(struct logical_volume *lv, struct lvconve
 
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
-	int replace = 0, image_count = 0;
-	struct dm_list *failed_pvs;
+	int image_count = 0;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
@@ -2013,7 +1928,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!lp->repair && !lp->replace && !arg_is_set(cmd, regionsize_ARG) && (!*lp->type_str || seg->segtype == lp->segtype)) {
+	} else if (!arg_is_set(cmd, regionsize_ARG) && (!*lp->type_str || seg->segtype == lp->segtype)) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
@@ -2054,52 +1969,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 1;
 	}
 
-	if (lp->replace)
-		return lv_raid_replace(lv, lp->force, lp->replace_pvh, lp->pvh);
-
-	if (lp->repair) {
-		if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-			log_error("%s must be active %sto perform this operation.",
-				  display_lvname(lv),
-				  vg_is_clustered(lv->vg) ?
-				  "exclusive locally " : "");
-			return 0;
-		}
-
-		if (seg_is_striped(seg)) {
-			log_error("Cannot repair LV %s of type raid0.",
-				  display_lvname(lv));
-			return 0;
-		}
-
-		if (!lv_check_transient(lv)) /* TODO check this in lib for all commands? */
-			stack; /* TODO: break here upon fail or always try to fix it? */
-
-		_lvconvert_raid_repair_ask(cmd, lp, &replace);
-
-		if (replace) {
-			if (!(failed_pvs = _failed_pv_list(lv->vg)))
-				return_0;
-
-			if (!lv_raid_replace(lv, lp->force, failed_pvs, lp->pvh)) {
-				log_error("Failed to replace faulty devices in %s.",
-					  display_lvname(lv));
-				return 0;
-			}
-
-			log_print_unless_silent("Faulty devices in %s successfully replaced.",
-						display_lvname(lv));
-			return 1;
-		}
-
-		/* "warn" if policy not set to replace */
-		if (arg_is_set(cmd, usepolicies_ARG))
-			log_warn("Use 'lvconvert --repair %s' to replace "
-				 "failed device.", display_lvname(lv));
-		return 1;
-	}
-
-
 try_new_takeover_or_reshape:
 
 	if (!_raid4_conversion_supported(lv, lp))
@@ -3641,16 +3510,6 @@ static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_vo
 }
 
 /*
- * Repair a thin pool LV.
- * lvconvert --repair LV
- */
-static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_volume *lv,
-				     struct lvconvert_params *lp)
-{
-	return _lvconvert_thin_pool_repair(cmd, lv, lp->pvh, lp->poolmetadataspare);
-}
-
-/*
  * Convert the data portion of a thin pool LV to a cache LV.
  * lvconvert --type cache LV
  *
@@ -3869,29 +3728,6 @@ static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *l
 }
 
 /*
- * Replace failed PVs in a mirror LV.
- * lvconvert --repair LV
- *
- * Auxiliary operation:
- * Removes missing, empty PVs from the VG, like vgreduce.
- */
-static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	struct dm_list *failed_pvs;
-	int ret;
-
-	ret = _lvconvert_mirrors_repair(cmd, lv, lp, lp->pvh);
-
-	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
-		if ((failed_pvs = _failed_pv_list(lv->vg)))
-			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	}
-
-	return ret;
-}
-
-/*
  * Convert mirror LV to linear LV.
  * lvconvert --type linear LV
  *
@@ -3951,41 +3787,6 @@ static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *l
 }
 
 /*
- * Replace failed PVs in a raid* LV.
- * lvconvert --repair LV
- *
- * Auxiliary operation:
- * Removes missing, empty PVs from the VG, like vgreduce.
- */
-static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *lv,
-				struct lvconvert_params *lp)
-{
-	struct dm_list *failed_pvs;
-	int ret;
-
-	/* FIXME: split the repair section out of _lvconvert_raid and call it here. */
-	ret = _lvconvert_raid(lv, lp);
-
-	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
-		if ((failed_pvs = _failed_pv_list(lv->vg)))
-			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	}
-
-	return ret;
-}
-
-/*
- * Replace a specific PV in a raid* LV with another PV.
- * lvconvert --replace PV LV
- */
-static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	/* FIXME: remove the replace section from _lvconvert_raid */
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
  * Combine a raid* LV with a snapshot LV that was previously
  * split from the raid* LV using --splitsnapshot.
  * lvconvert --type snapshot LV SnapshotLV
@@ -4297,9 +4098,6 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 	if (lp->cache)
 		return _convert_thin_pool_cache(cmd, lv, lp);
 
-	if (lp->repair)
-		return _convert_thin_pool_repair(cmd, lv, lp);
-
 	/* FIXME: swapping the thin pool metadata LV needs a specific option like --swapmetadata */
 	if (arg_is_set(cmd, poolmetadata_ARG))
 		return _convert_thin_pool_swapmetadata(cmd, lv, lp);
@@ -4382,9 +4180,6 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrorlog_ARG) || arg_is_set(cmd, corelog_ARG))
 		return _convert_mirror_log(cmd, lv, lp);
 
-	if (lp->repair)
-		return _convert_mirror_repair(cmd, lv, lp);
-
 	if (_linear_type_requested(lp->type_str))
 		return _convert_mirror_linear(cmd, lv, lp);
 
@@ -4454,12 +4249,6 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
-	if (lp->repair)
-		return _convert_raid_repair(cmd, lv, lp);
-
-	if (arg_is_set(cmd, replace_ARG))
-		return _convert_raid_replace(cmd, lv, lp);
-
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_raid_splitmirrors(cmd, lv, lp);
 
@@ -4648,7 +4437,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	/* Process striping parameters */
 	/* FIXME This is incomplete */
 	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
-	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
+	    _striped_type_requested(lp->type_str) || lp->mirrorlog || lp->corelog) {
 		/* FIXME Handle +/- adjustments too? */
 		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
 			goto_out;
@@ -4788,12 +4577,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else
 		lp->pvh = &vg->pvs;
 
-	if (lp->replace_pv_count &&
-	    !(lp->replace_pvh = create_pv_list(cmd->mem, vg,
-					       lp->replace_pv_count,
-					       lp->replace_pvs, 0)))
-			return_ECMD_FAILED;
-
 	lp->lv_to_poll = lv;
 
 	return _lvconvert_and_add_to_poll_list(cmd, lp, lv);
@@ -4838,7 +4621,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	} else {
 		int saved_ignore_suspended_devices = ignore_suspended_devices();
 
-		if (lp.repair || lp.uncache) {
+		if (lp.uncache) {
 			init_ignore_suspended_devices(1);
 			cmd->handles_missing_pvs = 1;
 		}


