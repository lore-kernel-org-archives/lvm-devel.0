From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:22 +0000 (UTC)
Subject: master - lvconvert: remove unused code
Message-ID: <20170213181022.6AF5F6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=041c2fef88ab2e546555625039a17ccbb7b1c9c5
Commit:        041c2fef88ab2e546555625039a17ccbb7b1c9c5
Parent:        46b2599d5c4e01eee66be7c45aa6cf36d7cbc50f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 20 15:17:48 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: remove unused code

---
 tools/lvconvert.c | 3170 +++++++++++++++--------------------------------------
 1 files changed, 882 insertions(+), 2288 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 642d6b7..757e8b4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -19,25 +19,6 @@
 #include "lvconvert_poll.h"
 #include "command-lines-count.h"
 
-/*
- * Guidelines for mapping options to operations.
- *
- * There should be a clear and unique correspondence between an option
- * name and the operation to be performed.
- *
- * An option with a given name should always perform the same operation.
- * If the same operation applies to two types of LV, then the same option
- * name can be used with both LV types.  But, a given option name should
- * not be used to perform different operations depending on the LV type it
- * is used with.
- *
- * --merge and --split are examples where a single option name has been
- * overloaded with different operations.  The case of --split has been
- * corrected with the clear and unique variations --splitcache,
- * --splitsnapshot, --splitmirror, which should allow --split to be
- * deprecated.  (The same is still needed for --merge.)
- */
-
 typedef enum {
 	/* Split:
 	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
@@ -52,23 +33,13 @@ typedef enum {
 
 struct lvconvert_params {
 	/* Exactly one of these 12 command categories is determined */
-	int merge;		/* 1 */
-	int split;		/* 2 */
-	int splitsnapshot;	/* 3 */
-	int splitcache;		/* 4 */
-	int keep_mimages;	/* 5 */	/* --splitmirrors */
-	int cache;		/* 6 */
-	int uncache;		/* 7 */
-	int snapshot;		/* 8 */
-	int thin;		/* 11 */
-	/* other */		/* 12 */
+	int split;		/* 1 */
+	int keep_mimages;	/* 2 */	/* --splitmirrors */
+	/* other */		/* 3 */
 
 	/* FIXME Eliminate all cases where more than one of the above are set then use conv_type instead */
 	conversion_type_t	conv_type;
 
-	int merge_snapshot;	/* CONV_MERGE is set */
-	int merge_mirror;	/* CONV_MERGE is set */
-
 	int track_changes;	/* CONV_SPLIT_MIRRORS is set */
 
 	int corelog;		/* Equivalent to --mirrorlog core */
@@ -80,7 +51,6 @@ struct lvconvert_params {
 
 	const struct segment_type *segtype;	/* Holds what segment type you will get */
 
-	int poolmetadataspare;
 	int force;
 	int yes;
 	int zero;
@@ -92,8 +62,6 @@ struct lvconvert_params {
 	int wait_completion;
 	int need_polling;
 
-	int thin_chunk_size_calc_policy;
-	uint32_t chunk_size;
 	uint32_t region_size;
 
 	uint32_t mirrors;
@@ -103,9 +71,6 @@ struct lvconvert_params {
 	unsigned stripes_supplied;
 	unsigned stripe_size_supplied;
 	uint32_t read_ahead;
-	cache_mode_t cache_mode; /* cache */
-	const char *policy_name; /* cache */
-	struct dm_config_tree *policy_settings; /* cache */
 
 	unsigned target_attr;
 
@@ -118,15 +83,7 @@ struct lvconvert_params {
 	struct logical_volume *lv_to_poll;
 	struct dm_list idls;
 
-	uint32_t pool_metadata_extents;
-	int passed_args;
-	uint64_t pool_metadata_size;
 	const char *origin_name;
-	const char *pool_data_name;
-	struct logical_volume *pool_data_lv;
-	const char *pool_metadata_name;
-	struct logical_volume *pool_metadata_lv;
-	thin_discards_t discards;
 };
 
 struct convert_poll_id_list {
@@ -145,12 +102,6 @@ static void _set_conv_type(struct lvconvert_params *lp, int conv_type)
 	lp->conv_type = conv_type;
 }
 
-/* -s/--snapshot and --type snapshot are synonyms */
-static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str)
-{
-	return (arg_is_set(cmd, snapshot_ARG) || !strcmp(type_str, SEG_TYPE_NAME_SNAPSHOT));
-}
-
 static int _raid0_type_requested(const char *type_str)
 {
 	return (!strcmp(type_str, SEG_TYPE_NAME_RAID0) || !strcmp(type_str, SEG_TYPE_NAME_RAID0_META));
@@ -1282,11 +1233,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lp->merge_mirror) {
-		log_error("Unable to merge mirror images of segment type 'mirror'.");
-		return 0;
-	}
-
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
@@ -1424,7 +1370,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype))
 		goto try_new_takeover_or_reshape;
 
-	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
+	if (seg_is_linear(seg) && !lp->mirrors_supplied) {
 		if (_raid0_type_requested(lp->type_str)) {
 			log_error("Linear LV %s cannot be converted to %s.",
 				  display_lvname(lv), lp->type_str);
@@ -1466,9 +1412,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 0;
 	}
 
-	if (lp->merge_mirror)
-		return lv_raid_merge(lv);
-
 	if (lp->track_changes)
 		return lv_raid_split_and_track(lv, lp->pvh);
 
@@ -1563,97 +1506,413 @@ try_new_takeover_or_reshape:
 	return 0;
 }
 
-static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow)
+/*
+ * Functions called to perform a specific operation on a specific LV type.
+ *
+ * _convert_<lvtype>_<operation>
+ *
+ * For cases where an operation does not apply to the LV itself, but
+ * is implicitly redirected to a sub-LV, these functions locate the
+ * correct sub-LV and call the operation on that sub-LV.  If a sub-LV
+ * of the proper type is not found, these functions report the error.
+ *
+ * FIXME: the _lvconvert_foo() functions can be cleaned up since they
+ * are now only called for valid combinations of LV type and operation.
+ * After that happens, the code remaining in those functions can be
+ * moved into the _convert_lvtype_operation() functions below.
+ */
+
+/*
+ * Change the number of images in a mirror LV.
+ * lvconvert --mirrors Number LV
+ */
+static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume *lv,
+				  struct lvconvert_params *lp)
 {
-	struct volume_group *vg = cow->vg;
-	const char *cow_name = display_lvname(cow);
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
 
-	if (lv_is_virtual_origin(origin_from_cow(cow))) {
-		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
-		return 0;
-	}
+/*
+ * Split images from a mirror LV and use them to create a new LV.
+ * lvconvert --splitmirrors Number LV
+ *
+ * Required options:
+ * --name Name
+ */
 
-	if (!(vg->fid->fmt->features & FMT_MDAS)) {
-		log_error("Unable to split off snapshot %s using old LVM1-style metadata.", cow_name);
-		return 0;
-	}
+static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
+					struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
 
-	if (is_lockd_type(vg->lock_type)) {
-		/* FIXME: we need to create a lock for the new LV. */
-		log_error("Unable to split snapshots in VG with lock_type %s.", vg->lock_type);
-		return 0;
-	}
+/*
+ * Change the type of log used by a mirror LV.
+ * lvconvert --mirrorlog Type LV
+ */
+static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+				  struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
 
-	if (lv_is_active_locally(cow)) {
-		if (!lv_check_not_in_use(cow, 1))
-			return_0;
+/*
+ * Convert mirror LV to linear LV.
+ * lvconvert --type linear LV
+ *
+ * Alternate syntax:
+ * lvconvert --mirrors 0 LV
+ */
+static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume *lv,
+				  struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
 
-		if ((arg_count(cmd, force_ARG) == PROMPT) &&
-		    !arg_count(cmd, yes_ARG) &&
-		    lv_is_visible(cow) &&
-		    lv_is_active(cow)) {
-			if (yes_no_prompt("Do you really want to split off active "
-					  "logical volume %s? [y/n]: ", display_lvname(cow)) == 'n') {
-				log_error("Logical volume %s not split.", display_lvname(cow));
-				return 0;
-			}
-		}
-	}
+/*
+ * Convert mirror LV to raid1 LV.
+ * lvconvert --type raid1 LV
+ */
+static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
+				struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	if (!archive(vg))
-		return_0;
+/*
+ * Change the number of images in a raid1 LV.
+ * lvconvert --mirrors Number LV
+ */
+static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *lv,
+				struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	log_verbose("Splitting snapshot %s from its origin.", display_lvname(cow));
+/*
+ * Split images from a raid1 LV and use them to create a new LV.
+ * lvconvert --splitmirrors Number LV
+ *
+ * Required options:
+ * --trackchanges | --name Name
+ */
+static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
+				      struct lvconvert_params *lp)
+{
+	/* FIXME: split the splitmirrors section out of _lvconvert_raid and call it here. */
+	return _lvconvert_raid(lv, lp);
+}
 
-	if (!vg_remove_snapshot(cow))
-		return_0;
+/*
+ * Convert a raid* LV to use a different raid level.
+ * lvconvert --type raid* LV
+ */
+static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	backup(vg);
+/*
+ * Convert a raid* LV to a mirror LV.
+ * lvconvert --type mirror LV
+ */
+static int _convert_raid_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	log_print_unless_silent("Logical Volume %s split from its origin.", display_lvname(cow));
+/*
+ * Convert a raid* LV to a striped LV.
+ * lvconvert --type striped LV
+ */
+static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
+				 struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	return 1;
+/*
+ * Convert a raid* LV to a linear LV.
+ * lvconvert --type linear LV
+ */
+static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,
+				struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
 }
 
-static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
-				   struct logical_volume *lv,
-				   struct logical_volume *cachepool_lv)
+/*
+ * Convert a striped/linear LV to a mirror LV.
+ * lvconvert --type mirror LV
+ *
+ * Required options:
+ * --mirrors Number
+ *
+ * Alternate syntax:
+ * This is equivalent to above when global/mirror_segtype_default="mirror".
+ * lvconvert --mirrors Number LV
+ */
+static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+				   struct lvconvert_params *lp)
 {
-	log_debug("Detaching cache pool %s from cache LV %s.",
-		  display_lvname(cachepool_lv), display_lvname(lv));
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
 
-	if (!archive(lv->vg))
-		return_0;
+/*
+ * Convert a striped/linear LV to a raid* LV.
+ * lvconvert --type raid* LV
+ *
+ * Required options:
+ * --mirrors Number
+ *
+ * Alternate syntax:
+ * This is equivalent to above when global/mirror_segtype_default="raid1".
+ * lvconvert --mirrors Number LV
+ */
+static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume *lv,
+				 struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
 
-	if (!lv_cache_remove(lv))
-		return_0;
+static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			   struct lvconvert_params *lp)
+{
+	if (arg_is_set(cmd, mirrors_ARG))
+		return _convert_mirror_number(cmd, lv, lp);
 
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_mirror_splitmirrors(cmd, lv, lp);
 
-	backup(lv->vg);
+	if (arg_is_set(cmd, mirrorlog_ARG) || arg_is_set(cmd, corelog_ARG))
+		return _convert_mirror_log(cmd, lv, lp);
 
-	log_print_unless_silent("Logical volume %s is not cached and cache pool %s is unused.",
-				display_lvname(lv), display_lvname(cachepool_lv));
+	if (_linear_type_requested(lp->type_str))
+		return _convert_mirror_linear(cmd, lv, lp);
 
-	return 1;
+	if (segtype_is_raid(lp->segtype))
+		return _convert_mirror_raid(cmd, lv, lp);
+
+	log_error("Unknown operation on mirror LV %s.", display_lvname(lv));
+	return 0;
 }
 
-static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
-				   struct logical_volume *lv,
-				   struct logical_volume *cachepool_lv)
+static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			 struct lvconvert_params *lp)
 {
-	struct lv_segment *seg;
-	struct logical_volume *remove_lv;
+	if (arg_is_set(cmd, mirrors_ARG))
+		return _convert_raid_number(cmd, lv, lp);
 
-	seg = first_seg(lv);
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_raid_splitmirrors(cmd, lv, lp);
 
-	if (lv_is_partial(seg_lv(seg, 0))) {
-		log_warn("WARNING: Cache origin logical volume %s is missing.",
-			 display_lvname(seg_lv(seg, 0)));
-		remove_lv = lv; /* When origin is missing, drop everything */
-	} else
-		remove_lv = seg->pool_lv;
+	if (segtype_is_raid(lp->segtype))
+		return _convert_raid_raid(cmd, lv, lp);
+
+	if (segtype_is_mirror(lp->segtype))
+		return _convert_raid_mirror(cmd, lv, lp);
+
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
+		return _convert_raid_striped(cmd, lv, lp);
+
+	if (_linear_type_requested(lp->type_str))
+		return _convert_raid_linear(cmd, lv, lp);
+
+	log_error("Unknown operation on raid LV %s.", display_lvname(lv));
+	return 0;
+}
+
+static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
+			    struct lvconvert_params *lp)
+{
+	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
+
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
+		return _convert_striped_mirror(cmd, lv, lp);
+
+	if (segtype_is_raid(lp->segtype))
+		return _convert_striped_raid(cmd, lv, lp);
+
+	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
+
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_MIRROR))
+		return _convert_striped_mirror(cmd, lv, lp);
+
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_RAID1))
+		return _convert_striped_raid(cmd, lv, lp);
+
+	log_error("Unknown operation on striped or linear LV %s.", display_lvname(lv));
+	return 0;
+}
+
+static int _lvconvert_raid_types(struct cmd_context *cmd, struct logical_volume *lv,
+				 struct lvconvert_params *lp)
+{
+	struct lv_segment *seg = first_seg(lv);
+	int ret = 0;
+
+	/* Set up segtype either from type_str or else to match the existing one. */
+	if (!*lp->type_str)
+		lp->segtype = seg->segtype;
+	else if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+		goto_out;
+
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
+		if (!lp->mirrors_supplied && !seg_is_raid1(seg)) {
+			log_error("Conversions to --type mirror require -m/--mirrors");
+			goto out;
+		}
+	}
+
+	/* lv->segtype can't be NULL */
+	if (activation() && lp->segtype->ops->target_present &&
+	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel.", lp->segtype->name);
+		goto out;
+	}
+
+	/* Process striping parameters */
+	/* FIXME This is incomplete */
+	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
+	    _striped_type_requested(lp->type_str) || lp->mirrorlog || lp->corelog) {
+		/* FIXME Handle +/- adjustments too? */
+		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
+			goto_out;
+
+		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
+			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
+			/* The default keeps existing number of stripes, handled inside the library code */
+			if (!arg_is_set(cmd, stripes_long_ARG))
+				lp->stripes = 0;
+	}
+
+	if (lv_is_cache(lv))
+		lv = seg_lv(first_seg(lv), 0);
+
+	if (lv_is_mirror(lv)) {
+		ret = _convert_mirror(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_raid(lv)) {
+		ret = _convert_raid(cmd, lv, lp);
+		goto out;
+	}
+
+	/*
+	 * FIXME: add lv_is_striped() and lv_is_linear()?
+	 * This does not include raid0 which is caught by the test above.
+	 * If operations differ between striped and linear, split this case.
+	 */
+	if (segtype_is_striped(seg->segtype) || segtype_is_linear(seg->segtype)) {
+		ret = _convert_striped(cmd, lv, lp);
+		goto out;
+	}
+
+	/*
+	 * The intention is to explicitly check all cases above and never
+	 * reach here, but this covers anything that was missed.
+	 */
+	log_error("Cannot convert LV %s.", display_lvname(lv));
+
+out:
+	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+}
+
+static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow)
+{
+	struct volume_group *vg = cow->vg;
+	const char *cow_name = display_lvname(cow);
+
+	if (lv_is_virtual_origin(origin_from_cow(cow))) {
+		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_MDAS)) {
+		log_error("Unable to split off snapshot %s using old LVM1-style metadata.", cow_name);
+		return 0;
+	}
+
+	if (is_lockd_type(vg->lock_type)) {
+		/* FIXME: we need to create a lock for the new LV. */
+		log_error("Unable to split snapshots in VG with lock_type %s.", vg->lock_type);
+		return 0;
+	}
+
+	if (lv_is_active_locally(cow)) {
+		if (!lv_check_not_in_use(cow, 1))
+			return_0;
+
+		if ((arg_count(cmd, force_ARG) == PROMPT) &&
+		    !arg_count(cmd, yes_ARG) &&
+		    lv_is_visible(cow) &&
+		    lv_is_active(cow)) {
+			if (yes_no_prompt("Do you really want to split off active "
+					  "logical volume %s? [y/n]: ", display_lvname(cow)) == 'n') {
+				log_error("Logical volume %s not split.", display_lvname(cow));
+				return 0;
+			}
+		}
+	}
+
+	if (!archive(vg))
+		return_0;
+
+	log_verbose("Splitting snapshot %s from its origin.", display_lvname(cow));
+
+	if (!vg_remove_snapshot(cow))
+		return_0;
+
+	backup(vg);
+
+	log_print_unless_silent("Logical Volume %s split from its origin.", display_lvname(cow));
+
+	return 1;
+}
+
+static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *cachepool_lv)
+{
+	log_debug("Detaching cache pool %s from cache LV %s.",
+		  display_lvname(cachepool_lv), display_lvname(lv));
+
+	if (!archive(lv->vg))
+		return_0;
+
+	if (!lv_cache_remove(lv))
+		return_0;
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+
+	log_print_unless_silent("Logical volume %s is not cached and cache pool %s is unused.",
+				display_lvname(lv), display_lvname(cachepool_lv));
+
+	return 1;
+}
+
+static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *cachepool_lv)
+{
+	struct lv_segment *seg;
+	struct logical_volume *remove_lv;
+
+	seg = first_seg(lv);
+
+	if (lv_is_partial(seg_lv(seg, 0))) {
+		log_warn("WARNING: Cache origin logical volume %s is missing.",
+			 display_lvname(seg_lv(seg, 0)));
+		remove_lv = lv; /* When origin is missing, drop everything */
+	} else
+		remove_lv = seg->pool_lv;
 
 	if (lv_is_partial(seg_lv(first_seg(seg->pool_lv), 0)))
 		log_warn("WARNING: Cache pool data logical volume %s is missing.",
@@ -2179,49 +2438,45 @@ deactivate_pmslv:
 	return 1;
 }
 
-/* Currently converts only to thin volume with external origin */
-static int _lvconvert_thin(struct cmd_context *cmd,
+static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 			   struct logical_volume *lv,
-			   struct lvconvert_params *lp)
+			   struct logical_volume *thinpool_lv)
 {
-	struct logical_volume *torigin_lv, *pool_lv = lp->pool_data_lv;
 	struct volume_group *vg = lv->vg;
+	struct logical_volume *thin_lv;
+	const char *origin_name;
+
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_AEY,
 		.alloc = ALLOC_INHERIT,
-		.lv_name = lp->origin_name,
 		.major = -1,
 		.minor = -1,
 		.suppress_zero_warn = 1, /* Suppress warning for this thin */
 		.permission = LVM_READ,
-		.pool_name = pool_lv->name,
+		.pool_name = thinpool_lv->name,
 		.pvh = &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
 		.virtual_extents = lv->le_count,
 	};
 
-	if (lv == pool_lv) {
+	if (lv == thinpool_lv) {
 		log_error("Can't use same LV %s for thin pool and thin volume.",
-			  display_lvname(pool_lv));
+			  display_lvname(thinpool_lv));
 		return 0;
 	}
 
-	if (lv_is_locked(lv) ||
-	    !lv_is_visible(lv) ||
-	    lv_is_cow(lv) ||
-	    lv_is_pool(lv) ||
-	    lv_is_pool_data(lv) ||
-	    lv_is_pool_metadata(lv)) {
-		log_error("Can't use%s%s %s %s as external origin.",
-			  lv_is_locked(lv) ? " locked" : "",
-			  lv_is_visible(lv) ? "" : " hidden",
-			  lvseg_name(first_seg(lv)),
-			  display_lvname(lv));
-		return 0;
-	}
+	if ((origin_name = arg_str_value(cmd, originname_ARG, NULL)))
+		if (!validate_restricted_lvname_param(cmd, &vg->name, &origin_name))
+			return_0;
+
+	/*
+	 * If NULL, an auto-generated 'lvol' name is used.
+	 * If set, the lv create code checks the name isn't used.
+	 */
+	lvc.lv_name = origin_name;
 
-	if (is_lockd_type(lv->vg->lock_type)) {
+	if (is_lockd_type(vg->lock_type)) {
 		/*
 		 * FIXME: external origins don't work in lockd VGs.
 		 * Prior to the lvconvert, there's a lock associated with
@@ -2233,13 +2488,13 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		 * lock for the new LV uuid used by the external LV.
 		 */
 		log_error("Can't use lock_type %s LV as external origin.",
-			  lv->vg->lock_type);
+			  vg->lock_type);
 		return 0;
 	}
 
 	dm_list_init(&lvc.tags);
 
-	if (!pool_supports_external_origin(first_seg(pool_lv), lv))
+	if (!pool_supports_external_origin(first_seg(thinpool_lv), lv))
 		return_0;
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN)))
@@ -2248,14 +2503,22 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	if (!archive(vg))
 		return_0;
 
-	/* New thin LV needs to be created (all messages sent to pool)
-	 * In this case thin volume is created READ-ONLY and
-	 * also warn about not zeroing is suppressed. */
-	if (!(torigin_lv = lv_create_single(vg, &lvc)))
+	/*
+	 * New thin LV needs to be created (all messages sent to pool) In this
+	 * case thin volume is created READ-ONLY and also warn about not
+	 * zeroing is suppressed.
+	 *
+	 * The new thin LV is created with the origin_name, or an autogenerated
+	 * 'lvol' name.  Then the names and ids are swapped between the thin LV
+	 * and the original/external LV.  So, the thin LV gets the name and id
+	 * of the original LV arg, and the original LV arg gets the origin_name
+	 * or the autogenerated name.
+	 */
+
+	if (!(thin_lv = lv_create_single(vg, &lvc)))
 		return_0;
 
-	/* Deactivate prepared Thin LV */
-	if (!deactivate_lv(cmd, torigin_lv)) {
+	if (!deactivate_lv(cmd, thin_lv)) {
 		log_error("Aborting. Unable to deactivate new LV. "
 			  "Manual intervention required.");
 		return 0;
@@ -2266,47 +2529,45 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	 * which could be easily removed by the user after i.e. power-off
 	 */
 
-	if (!swap_lv_identifiers(cmd, torigin_lv, lv)) {
+	if (!swap_lv_identifiers(cmd, thin_lv, lv)) {
 		stack;
 		goto revert_new_lv;
 	}
 
 	/* Preserve read-write status of original LV here */
-	torigin_lv->status |= (lv->status & LVM_WRITE);
+	thin_lv->status |= (lv->status & LVM_WRITE);
 
-	if (!attach_thin_external_origin(first_seg(torigin_lv), lv)) {
+	if (!attach_thin_external_origin(first_seg(thin_lv), lv)) {
 		stack;
 		goto revert_new_lv;
 	}
 
-	if (!lv_update_and_reload(torigin_lv)) {
+	if (!lv_update_and_reload(thin_lv)) {
 		stack;
 		goto deactivate_and_revert_new_lv;
 	}
 
-	log_print_unless_silent("Converted %s to thin volume with "
-				"external origin %s.",
-				display_lvname(torigin_lv),
-				display_lvname(lv));
+	log_print_unless_silent("Converted %s to thin volume with external origin %s.",
+				display_lvname(thin_lv), display_lvname(lv));
 
 	return 1;
 
 deactivate_and_revert_new_lv:
-	if (!swap_lv_identifiers(cmd, torigin_lv, lv))
+	if (!swap_lv_identifiers(cmd, thin_lv, lv))
 		stack;
 
-	if (!deactivate_lv(cmd, torigin_lv)) {
+	if (!deactivate_lv(cmd, thin_lv)) {
 		log_error("Unable to deactivate failed new LV. "
 			  "Manual intervention required.");
 		return 0;
 	}
 
-	if (!detach_thin_external_origin(first_seg(torigin_lv)))
+	if (!detach_thin_external_origin(first_seg(thin_lv)))
 		return_0;
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(torigin_lv) || !vg_write(vg) || !vg_commit(vg))
+	if (!lv_remove(thin_lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	else
@@ -2315,269 +2576,225 @@ revert_new_lv:
 	return 0;
 }
 
-static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
-			   struct logical_volume *lv,
-			   struct logical_volume *thinpool_lv)
+static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct logical_volume *metadata_lv)
 {
 	struct volume_group *vg = lv->vg;
-	struct logical_volume *thin_lv;
-	const char *origin_name;
+	struct logical_volume *prev_metadata_lv;
+	struct lv_segment *seg;
+	struct lv_types *lvtype;
+	char meta_name[NAME_LEN];
+	const char *swap_name;
+	uint32_t chunk_size;
+	int is_thinpool;
+	int is_cachepool;
+	int lvt_enum;
 
-	struct lvcreate_params lvc = {
-		.activate = CHANGE_AEY,
-		.alloc = ALLOC_INHERIT,
-		.major = -1,
-		.minor = -1,
-		.suppress_zero_warn = 1, /* Suppress warning for this thin */
-		.permission = LVM_READ,
-		.pool_name = thinpool_lv->name,
-		.pvh = &vg->pvs,
-		.read_ahead = DM_READ_AHEAD_AUTO,
-		.stripes = 1,
-		.virtual_extents = lv->le_count,
-	};
+	is_thinpool = lv_is_thin_pool(lv);
+	is_cachepool = lv_is_cache_pool(lv);
+	lvt_enum = get_lvt_enum(metadata_lv);
+	lvtype = get_lv_type(lvt_enum);
 
-	if (lv == thinpool_lv) {
-		log_error("Can't use same LV %s for thin pool and thin volume.",
-			  display_lvname(thinpool_lv));
+	if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
+		log_error("LV %s with type %s cannot be used as a metadata LV.",
+			  display_lvname(metadata_lv), lvtype ? lvtype->name : "unknown");
 		return 0;
 	}
 
-	if ((origin_name = arg_str_value(cmd, originname_ARG, NULL)))
-		if (!validate_restricted_lvname_param(cmd, &vg->name, &origin_name))
-			return_0;
+	if (!lv_is_visible(metadata_lv)) {
+		log_error("Can't convert internal LV %s.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
 
-	/*
-	 * If NULL, an auto-generated 'lvol' name is used.
-	 * If set, the lv create code checks the name isn't used.
-	 */
-	lvc.lv_name = origin_name;
+	if (lv_is_locked(metadata_lv)) {
+		log_error("Can't convert locked LV %s.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
 
-	if (is_lockd_type(vg->lock_type)) {
-		/*
-		 * FIXME: external origins don't work in lockd VGs.
-		 * Prior to the lvconvert, there's a lock associated with
-		 * the uuid of the external origin LV.  After the convert,
-		 * that uuid belongs to the new thin LV, and a new LV with
-		 * a new uuid exists as the non-thin, readonly external LV.
-		 * We'd need to remove the lock for the previous uuid
-		 * (the new thin LV will have no lock), and create a new
-		 * lock for the new LV uuid used by the external LV.
-		 */
-		log_error("Can't use lock_type %s LV as external origin.",
-			  vg->lock_type);
+	if (lv_is_origin(metadata_lv) ||
+	    lv_is_merging_origin(metadata_lv) ||
+	    lv_is_external_origin(metadata_lv) ||
+	    lv_is_virtual(metadata_lv)) {
+		log_error("Pool metadata LV %s is of an unsupported type.",
+			  display_lvname(metadata_lv));
 		return 0;
 	}
 
-	dm_list_init(&lvc.tags);
+	/* FIXME cache pool */
+	if (is_thinpool && pool_is_active(lv)) {
+		/* If any volume referencing pool active - abort here */
+		log_error("Cannot convert pool %s with active volumes.",
+			  display_lvname(lv));
+		return 0;
+	}
 
-	if (!pool_supports_external_origin(first_seg(thinpool_lv), lv))
-		return_0;
+	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, is_cachepool ? "_cmeta" : "_tmeta") < 0)) {
+                log_error("Failed to create internal lv names, pool name is too long.");
+                return 0;
+        }
 
-	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN)))
-		return_0;
+	seg = first_seg(lv);
 
-	if (!archive(vg))
-		return_0;
+	/* Normally do NOT change chunk size when swapping */
 
-	/*
-	 * New thin LV needs to be created (all messages sent to pool) In this
-	 * case thin volume is created READ-ONLY and also warn about not
-	 * zeroing is suppressed.
-	 *
-	 * The new thin LV is created with the origin_name, or an autogenerated
-	 * 'lvol' name.  Then the names and ids are swapped between the thin LV
-	 * and the original/external LV.  So, the thin LV gets the name and id
-	 * of the original LV arg, and the original LV arg gets the origin_name
-	 * or the autogenerated name.
-	 */
+	if (arg_is_set(cmd, chunksize_ARG)) {
+		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 
-	if (!(thin_lv = lv_create_single(vg, &lvc)))
-		return_0;
+		if ((chunk_size != seg->chunk_size) && !dm_list_empty(&lv->segs_using_this_lv)) {
+			if (arg_count(cmd, force_ARG) == PROMPT) {
+				log_error("Chunk size can be only changed with --force. Conversion aborted.");
+				return 0;
+			}
 
-	if (!deactivate_lv(cmd, thin_lv)) {
-		log_error("Aborting. Unable to deactivate new LV. "
-			  "Manual intervention required.");
-		return 0;
-	}
+			if (!validate_pool_chunk_size(cmd, seg->segtype, chunk_size))
+				return_0;
 
-	/*
-	 * Crashing till this point will leave plain thin volume
-	 * which could be easily removed by the user after i.e. power-off
-	 */
+			log_warn("WARNING: Changing chunk size %s to %s for %s pool volume.",
+				 display_size(cmd, seg->chunk_size),
+				 display_size(cmd, chunk_size),
+				 display_lvname(lv));
 
-	if (!swap_lv_identifiers(cmd, thin_lv, lv)) {
-		stack;
-		goto revert_new_lv;
-	}
+			/* Ok, user has likely some serious reason for this */
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Do you really want to change chunk size for %s pool volume? [y/n]: ",
+					  display_lvname(lv)) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+		}
 
-	/* Preserve read-write status of original LV here */
-	thin_lv->status |= (lv->status & LVM_WRITE);
+		seg->chunk_size = chunk_size;
+	}
 
-	if (!attach_thin_external_origin(first_seg(thin_lv), lv)) {
-		stack;
-		goto revert_new_lv;
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you want to swap metadata of %s pool with metadata volume %s? [y/n]: ",
+			  display_lvname(lv),
+			  display_lvname(metadata_lv)) == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
 	}
 
-	if (!lv_update_and_reload(thin_lv)) {
-		stack;
-		goto deactivate_and_revert_new_lv;
+	if (!deactivate_lv(cmd, metadata_lv)) {
+		log_error("Aborting. Failed to deactivate %s.",
+			  display_lvname(metadata_lv));
+		return 0;
 	}
 
-	log_print_unless_silent("Converted %s to thin volume with external origin %s.",
-				display_lvname(thin_lv), display_lvname(lv));
+	if (!archive(vg))
+		return_0;
 
-	return 1;
+	/* Swap names between old and new metadata LV */
 
-deactivate_and_revert_new_lv:
-	if (!swap_lv_identifiers(cmd, thin_lv, lv))
-		stack;
+	if (!detach_pool_metadata_lv(seg, &prev_metadata_lv))
+		return_0;
 
-	if (!deactivate_lv(cmd, thin_lv)) {
-		log_error("Unable to deactivate failed new LV. "
-			  "Manual intervention required.");
-		return 0;
-	}
+	swap_name = metadata_lv->name;
 
-	if (!detach_thin_external_origin(first_seg(thin_lv)))
+	if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
 		return_0;
 
-revert_new_lv:
-	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(thin_lv) || !vg_write(vg) || !vg_commit(vg))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned LV(s) before retrying.");
-	else
-		backup(vg);
+	/* Give the previous metadata LV the name of the LV replacing it. */
 
-	return 0;
-}
+	if (!lv_rename_update(cmd, prev_metadata_lv, swap_name, 0))
+		return_0;
 
-static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
-					 struct lvconvert_params *lp)
-{
-	if (lp->pool_metadata_size &&
-	    !(lp->pool_metadata_extents =
-	      extents_from_size(pool_lv->vg->cmd, lp->pool_metadata_size, pool_lv->vg->extent_size)))
+	/* Rename deactivated metadata LV to have _tmeta suffix */
+
+	if (!lv_rename_update(cmd, metadata_lv, meta_name, 0))
+		return_0;
+
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
+		return_0;
+
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	return update_pool_params(lp->segtype,
-				  pool_lv->vg,
-				  lp->target_attr,
-				  lp->passed_args,
-				  pool_lv->le_count,
-				  &lp->pool_metadata_extents,
-				  &lp->thin_chunk_size_calc_policy,
-				  &lp->chunk_size,
-				  &lp->discards,
-				  &lp->zero);
+	backup(vg);
+	return 1;
 }
 
 /*
- * Converts a data lv and a metadata lv into a thin or cache pool lv.
- *
- * Thin lvconvert version which
- *  rename metadata
- *  convert/layers thinpool over data
- *  attach metadata
- *
- * pool_lv might or might not already be a pool.
+ * Create a new pool LV, using the lv arg as the data sub LV.
+ * The metadata sub LV is either a new LV created here, or an
+ * existing LV specified by --poolmetadata.
  */
-static int _lvconvert_pool(struct cmd_context *cmd,
-			   struct logical_volume *pool_lv,
-			   struct lvconvert_params *lp)
+
+static int _lvconvert_to_pool(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      int to_thinpool,
+			      int to_cachepool,
+			      struct dm_list *use_pvh)
 {
-	int r = 0;
-	const char *old_name;
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *metadata_lv = NULL;  /* existing or created */
+	struct logical_volume *data_lv;             /* lv arg renamed */
+	struct logical_volume *pool_lv;             /* new lv created here */
+	const char *pool_metadata_name;             /* user-specified lv name */
+	const char *pool_name;                      /* name of original lv arg */
+	char meta_name[NAME_LEN];                   /* generated sub lv name */
+	char data_name[NAME_LEN];                   /* generated sub lv name */
+	struct segment_type *pool_segtype;          /* thinpool or cachepool */
 	struct lv_segment *seg;
-	struct volume_group *vg = pool_lv->vg;
-	struct logical_volume *data_lv;
-	struct logical_volume *metadata_lv = NULL;
-	struct logical_volume *pool_metadata_lv;
+	unsigned int target_attr = ~0;
+	unsigned int passed_args = 0;
+	unsigned int activate_pool;
+	unsigned int zero_metadata;
+	uint64_t meta_size;
+	uint32_t meta_extents;
+	uint32_t chunk_size;
+	int chunk_calc;
+	int r = 0;
+
+	/* for handling lvmlockd cases */
 	char *lockd_data_args = NULL;
 	char *lockd_meta_args = NULL;
 	char *lockd_data_name = NULL;
 	char *lockd_meta_name = NULL;
 	struct id lockd_data_id;
 	struct id lockd_meta_id;
-	char metadata_name[NAME_LEN], data_name[NAME_LEN];
-	int zero_metadata = 1;
-	int activate_pool;
-
-	if (lp->pool_data_name) {
-		if ((lp->thin || lp->cache) &&
-		    !strcmp(lp->pool_data_name, pool_lv->name)) {
-			log_error("Converted volume %s and pool volume must differ.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
-		if (!(pool_lv = find_lv(vg, lp->pool_data_name))) {
-			log_error("Unknown pool data LV %s.", lp->pool_data_name);
-			return 0;
-		}
-	}
-
-	/* An existing LV needs to have its lock freed once it becomes a data LV. */
-	if (is_lockd_type(vg->lock_type) && !lv_is_pool(pool_lv) && pool_lv->lock_args) {
-		lockd_data_args = dm_pool_strdup(cmd->mem, pool_lv->lock_args);
-		lockd_data_name = dm_pool_strdup(cmd->mem, pool_lv->name);
-		memcpy(&lockd_data_id, &pool_lv->lvid.id[1], sizeof(struct id));
-	}
 
-	if (!lv_is_visible(pool_lv)) {
-		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
-		return 0;
-	}
 
-	if (lv_is_locked(pool_lv)) {
-		log_error("Can't convert locked LV %s.", display_lvname(pool_lv));
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
+		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
 		return 0;
 	}
 
-	if (lv_is_thin_pool(pool_lv) && (segtype_is_cache_pool(lp->segtype) || lp->cache)) {
-		log_error("Can't convert thin pool LV %s.", display_lvname(pool_lv));
-		return 0;
-	}
+	pool_segtype = to_cachepool ? get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE_POOL) :
+				      get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN_POOL);
 
-	if (lv_is_cache(pool_lv) && !segtype_is_thin_pool(lp->segtype)) {
-		log_error("Cached LV %s could be only converted into a thin pool volume.",
-			  display_lvname(pool_lv));
+	if (!pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
+		log_error("%s: Required device-mapper target(s) not detected in your kernel.", pool_segtype->name);
 		return 0;
 	}
 
-	if (lv_is_cache_pool(pool_lv) && (segtype_is_thin_pool(lp->segtype) || lp->thin)) {
-		log_error("Cannot convert cache pool %s as pool data volume.",
-			  display_lvname(pool_lv));
-		return 0;
-	}
+	/* Allow to have only thinpool active and restore it's active state. */
+	activate_pool = to_thinpool && lv_is_active(lv);
 
-	if (lv_is_mirror(pool_lv)) {
-		log_error("Mirror logical volumes cannot be used as pools.");
-		log_print_unless_silent("Try \"%s\" segment type instead.", SEG_TYPE_NAME_RAID1);
-		return 0;
+	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
+	zero_metadata = to_cachepool ? arg_int_value(cmd, zero_ARG, 1) : 1;
+
+	/* An existing LV needs to have its lock freed once it becomes a data LV. */
+	if (is_lockd_type(vg->lock_type) && lv->lock_args) {
+		lockd_data_args = dm_pool_strdup(cmd->mem, lv->lock_args);
+		lockd_data_name = dm_pool_strdup(cmd->mem, lv->name);
+		memcpy(&lockd_data_id, &lv->lvid.id[1], sizeof(struct id));
 	}
 
 	/*
-	 * Only linear, striped and raid supported.
-	 * FIXME Tidy up all these type restrictions.
+	 * If an existing LV is to be used as the metadata LV,
+	 * verify that it's in a usable state.  These checks are
+	 * not done by command def rules because this LV is not
+	 * processed by process_each_lv.
 	 */
-	if (!lv_is_pool(pool_lv) &&
-	    (lv_is_thin_type(pool_lv) ||
-	     lv_is_cow(pool_lv) || lv_is_merging_cow(pool_lv) ||
-	     lv_is_origin(pool_lv) ||lv_is_merging_origin(pool_lv) ||
-	     lv_is_external_origin(pool_lv) ||
-	     lv_is_virtual(pool_lv))) {
-		log_error("Pool data LV %s is of an unsupported type.", display_lvname(pool_lv));
-		return 0;
-	}
 
-	if (lp->pool_metadata_name) {
-		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_name))) {
-			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_name);
+	if ((pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
+		if (!(metadata_lv = find_lv(vg, pool_metadata_name))) {
+			log_error("Unknown pool metadata LV %s.", pool_metadata_name);
 			return 0;
 		}
-		lp->pool_metadata_extents = lp->pool_metadata_lv->le_count;
-		metadata_lv = lp->pool_metadata_lv;
 
 		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
 		if (is_lockd_type(vg->lock_type) && metadata_lv->lock_args) {
@@ -2586,7 +2803,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
 		}
 
-		if (metadata_lv == pool_lv) {
+		if (metadata_lv == lv) {
 			log_error("Can't use same LV for pool data and metadata LV %s.",
 				  display_lvname(metadata_lv));
 			return 0;
@@ -2621,199 +2838,152 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 				  display_lvname(metadata_lv));
 			return 0;
 		}
-
-		if (!lv_is_pool(pool_lv)) {
-			if (!_lvconvert_update_pool_params(pool_lv, lp))
-				return_0;
-
-			if (lp->pool_metadata_extents > metadata_lv->le_count) {
-				log_error("Logical volume %s is too small for metadata.",
-					  display_lvname(metadata_lv));
-				return 0;
-			}
-		}
 	}
 
-	if (lv_is_pool(pool_lv)) {
-		lp->pool_data_lv = pool_lv;
+	/*
+	 * Determine the size of the metadata LV and the chunk size.  When an
+	 * existing LV is to be used for metadata, this introduces some
+	 * constraints/defaults.  When chunk_size=0 and/or meta_extents=0 are
+	 * passed to the "update params" function, defaults are calculated and
+	 * returned.
+	 */
 
-		if (!metadata_lv) {
-			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
-						 discards_ARG,
-						 poolmetadatasize_ARG, -1))
-				return_0;
+	if (arg_is_set(cmd, chunksize_ARG)) {
+		passed_args |= PASS_ARG_CHUNK_SIZE;
+		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
+		if (!validate_pool_chunk_size(cmd, pool_segtype, chunk_size))
+			return_0;
+	} else {
+		/* A default will be chosen by the "update" function. */
+		chunk_size = 0;
+	}
 
-			if (lp->thin &&
-			    arg_from_list_is_set(cmd, "is invalid with existing thin pool",
-						 chunksize_ARG, zero_ARG, -1))
-				return_0;
+	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
+		meta_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+		meta_extents = extents_from_size(cmd, meta_size, vg->extent_size);
+		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
+	} else if (metadata_lv) {
+		meta_extents = metadata_lv->le_count;
+		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
+	} else {
+		/* A default will be chosen by the "update" function. */
+		meta_extents = 0;
+	}
 
-			if (lp->cache) {
-				if (!lp->chunk_size)
-					lp->chunk_size = first_seg(pool_lv)->chunk_size;
-
-				if (!validate_lv_cache_chunk_size(pool_lv, lp->chunk_size))
-					return_0;
-
-				/* Check is user requested zeroing logic via [-Z y|n] */
-				if (!arg_is_set(cmd, zero_ARG)) {
-					/* Note: requires rather deep know-how to skip zeroing */
-					if (!lp->yes &&
-					    yes_no_prompt("Do you want wipe existing metadata of "
-							  "cache pool volume %s? [y/n]: ",
-							  display_lvname(pool_lv)) == 'n') {
-						log_error("Conversion aborted.");
-						log_error("To preserve cache metadata add option \"--zero n\".");
-						log_warn("WARNING: Reusing mismatched cache pool metadata "
-							 "MAY DESTROY YOUR DATA!");
-						return 0;
-					}
-					/* Wiping confirmed, go ahead */
-					if (!wipe_cache_pool(pool_lv))
-						return_0;
-				} else if (arg_int_value(cmd, zero_ARG, 0)) {
-					if (!wipe_cache_pool(pool_lv)) /* Wipe according to -Z y|n */
-						return_0;
-				} else
-					log_warn("WARNING: Reusing cache pool metadata %s "
-						 "for volume caching.", display_lvname(pool_lv));
-			}
+	/* Tell the "update" function to ignore these, they are handled below. */
+	passed_args |= PASS_ARG_DISCARDS | PASS_ARG_ZERO;
 
-			if (lp->thin || lp->cache)
-				/* already pool, can continue converting volume */
-				return 1;
+	/*
+	 * Validate and/or choose defaults for meta_extents and chunk_size,
+	 * this involves some complicated calculations.
+	 */
 
-			log_error("LV %s is already pool.", display_lvname(pool_lv));
-			return 0;
-		}
+	if (to_cachepool) {
+		if (!update_cache_pool_params(pool_segtype, vg, target_attr,
+					      passed_args, lv->le_count,
+					      &meta_extents,
+					      &chunk_calc,
+					      &chunk_size))
+			return_0;
+	} else {
+		if (!update_thin_pool_params(pool_segtype, vg, target_attr,
+					     passed_args, lv->le_count,
+					     &meta_extents,
+					     &chunk_calc,
+					     &chunk_size,
+					     NULL, NULL))
+			return_0;
+	}
 
-		if (lp->thin || lp->cache) {
-			log_error("--%s and pool metadata swap is not supported.",
-				  lp->thin ? "thin" : "cache");
-			return 0;
-		}
+	if ((uint64_t)chunk_size > ((uint64_t)lv->le_count * vg->extent_size)) {
+		log_error("Pool data LV %s is too small (%s) for specified chunk size (%s).",
+			  display_lvname(lv),
+			  display_size(cmd, (uint64_t)lv->le_count * vg->extent_size),
+			  display_size(cmd, chunk_size));
+		return 0;
+	}
 
-		/* FIXME cache pool */
-		if (lv_is_thin_pool(pool_lv) && pool_is_active(pool_lv)) {
-			/* If any volume referencing pool active - abort here */
-			log_error("Cannot convert pool %s with active volumes.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
+	if (metadata_lv && (meta_extents > metadata_lv->le_count)) {
+		log_error("Pool metadata LV %s is too small (%u extents) for required metadata (%u extents).",
+			  display_lvname(metadata_lv), metadata_lv->le_count, meta_extents);
+		return 0;
+	}
 
-		lp->passed_args |= PASS_ARG_CHUNK_SIZE | PASS_ARG_DISCARDS | PASS_ARG_ZERO;
-		seg = first_seg(pool_lv);
+	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
 
-		/* Normally do NOT change chunk size when swapping */
-		if (arg_is_set(cmd, chunksize_ARG) &&
-		    (lp->chunk_size != seg->chunk_size) &&
-		    !dm_list_empty(&pool_lv->segs_using_this_lv)) {
-			if (lp->force == PROMPT) {
-				log_error("Chunk size can be only changed with --force. Conversion aborted.");
-				return 0;
-			}
-			log_warn("WARNING: Changing chunk size %s to "
-				 "%s for %s pool volume.",
-				 display_size(cmd, seg->chunk_size),
-				 display_size(cmd, lp->chunk_size),
-				 display_lvname(pool_lv));
-			/* Ok, user has likely some serious reason for this */
-			if (!lp->yes &&
-			    yes_no_prompt("Do you really want to change chunk size "
-					  "for %s pool volume? [y/n]: ",
-					  display_lvname(pool_lv)) == 'n') {
-				log_error("Conversion aborted.");
-				return 0;
-			}
-		} else
-			lp->chunk_size = seg->chunk_size;
 
-		if (!_lvconvert_update_pool_params(pool_lv, lp))
-			return_0;
+	/*
+	 * Verify that user wants to use these LVs.
+	 */
 
-		if (metadata_lv->le_count < lp->pool_metadata_extents)
-			log_print_unless_silent("Continuing with swap...");
+	log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
+		 display_lvname(lv),
+		 metadata_lv ? " and " : "",
+		 metadata_lv ? display_lvname(metadata_lv) : "",
+		 to_cachepool ? "cache" : "thin",
+		 metadata_lv ? " and metadata volumes" : " volume",
+		 zero_metadata ? "with" : "WITHOUT");
 
-		if (!arg_is_set(cmd, discards_ARG))
-			lp->discards = seg->discards;
-		if (!arg_is_set(cmd, zero_ARG))
-			lp->zero = seg->zero_new_blocks;
+	if (zero_metadata)
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+	else if (to_cachepool)
+		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
 
-		if (!lp->yes &&
-		    yes_no_prompt("Do you want to swap metadata of %s "
-				  "pool with metadata volume %s? [y/n]: ",
-				  display_lvname(pool_lv),
-				  display_lvname(metadata_lv)) == 'n') {
-			log_error("Conversion aborted.");
-			return 0;
-		}
-	} else {
-		/* Only cache pool conversion may suppress metadata zeroing
-		 * TODO: Maybe similar support could be useful for thin-pool, but --zero
-		 * is already overloade and we would also need to possibly match transaction Id. */
-		if (segtype_is_cache_pool(lp->segtype) && metadata_lv)
-			/* Check is user requested zeroing logic via [-Z y|n] (default is yes) */
-			zero_metadata = arg_int_value(cmd, zero_ARG, 1);
-
-		log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
-			 display_lvname(pool_lv),
-			 metadata_lv ? " and " : "",
-			 metadata_lv ? display_lvname(metadata_lv) : "",
-			 segtype_is_cache_pool(lp->segtype) ? "cache" : "thin",
-			 metadata_lv ? " and metadata volumes" : " volume",
-			 zero_metadata ? "with" : "WITHOUT");
-
-		if (zero_metadata)
-			log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-		else /* ATM supported only for cache pools */
-			log_warn("WARNING: Using mismatched cache pool metadata "
-				 "MAY DESTROY YOUR DATA!");
-
-		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
-				  display_lvname(pool_lv),
-				  metadata_lv ? " and " : "",
-				  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
-			log_error("Conversion aborted.");
-			return 0;
-		}
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
+			  display_lvname(lv),
+			  metadata_lv ? " and " : "",
+			  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
 	}
 
-	if (segtype_is_cache_pool(lp->segtype))
-		activate_pool = 0; /* Cannot activate cache pool */
-	else
-		/* Allow to have only thinpool active and restore it's active state */
-		activate_pool = lv_is_active(pool_lv);
-
-	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
-			 pool_lv->name,
-			 (segtype_is_cache_pool(lp->segtype)) ?
-			  "_cmeta" : "_tmeta") < 0) ||
-	    (dm_snprintf(data_name, sizeof(data_name), "%s%s",
-			 pool_lv->name,
-			 (segtype_is_cache_pool(lp->segtype)) ?
-			 "_cdata" : "_tdata") < 0)) {
-		log_error("Failed to create internal lv names, "
-			  "pool name is too long.");
+	/*
+	 * The internal LV names for pool data/meta LVs.
+	 */
+
+	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, to_cachepool ? "_cmeta" : "_tmeta") < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s%s", lv->name, to_cachepool ? "_cdata" : "_tdata") < 0)) {
+		log_error("Failed to create internal lv names, pool name is too long.");
 		return 0;
 	}
 
+	/*
+	 * If a new metadata LV needs to be created, collect the settings for
+	 * the new LV and create it.
+	 *
+	 * If an existing LV is used for metadata, deactivate/activate/wipe it.
+	 */
+
 	if (!metadata_lv) {
-		if (!_lvconvert_update_pool_params(pool_lv, lp))
-			return_0;
+		uint32_t meta_stripes;
+		uint32_t meta_stripe_size;
+		uint32_t meta_readahead;
+		alloc_policy_t meta_alloc;
+		unsigned meta_stripes_supplied;
+		unsigned meta_stripe_size_supplied;
 
 		if (!get_stripe_params(cmd, get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED),
-				       &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
+				       &meta_stripes,
+				       &meta_stripe_size,
+				       &meta_stripes_supplied,
+				       &meta_stripe_size_supplied))
 			return_0;
 
+		meta_readahead = arg_uint_value(cmd, readahead_ARG, cmd->default_settings.read_ahead);
+		meta_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+
 		if (!archive(vg))
 			return_0;
 
-		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
-							lp->read_ahead, lp->stripes,
-							lp->stripe_size,
-							lp->pool_metadata_extents,
-							lp->alloc, lp->pvh)))
+		if (!(metadata_lv = alloc_pool_metadata(lv,
+							meta_name,
+							meta_readahead,
+							meta_stripes,
+							meta_stripe_size,
+							meta_extents,
+							meta_alloc,
+							use_pvh)))
 			return_0;
 	} else {
 		if (!deactivate_lv(cmd, metadata_lv)) {
@@ -2825,21 +2995,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (!archive(vg))
 			return_0;
 
-		/* Swap normal LV with pool's metadata LV ? */
-		if (lv_is_pool(pool_lv)) {
-			/* Swap names between old and new metadata LV */
-			seg = first_seg(pool_lv);
-			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
-				return_0;
-			old_name = metadata_lv->name;
-			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
-				return_0;
-			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
-				return_0;
-
-			goto mda_write;
-		}
-
 		if (zero_metadata) {
 			metadata_lv->status |= LV_TEMPORARY;
 			if (!activate_lv_local(cmd, metadata_lv)) {
@@ -2854,41 +3009,66 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		}
 	}
 
-	/* We are changing target type, so deactivate first */
+	/*
+	 * Deactivate the data LV and metadata LV.
+	 * We are changing target type, so deactivate first.
+	 */
+
 	if (!deactivate_lv(cmd, metadata_lv)) {
 		log_error("Aborting. Failed to deactivate metadata lv. "
 			  "Manual intervention required.");
 		return 0;
 	}
 
-	if (!deactivate_lv(cmd, pool_lv)) {
+	if (!deactivate_lv(cmd, lv)) {
 		log_error("Aborting. Failed to deactivate logical volume %s.",
-			  display_lvname(pool_lv));
+			  display_lvname(lv));
 		return 0;
 	}
 
-	data_lv = pool_lv;
-	old_name = data_lv->name; /* Use for pool name */
 	/*
+	 * When the LV referenced by the original function arg "lv"
+	 * is renamed, it is then referenced as "data_lv".
+	 *
+	 * pool_name    pool name taken from lv arg
+	 * data_name    sub lv name, generated
+	 * meta_name    sub lv name, generated
+	 *
+	 * pool_lv      new lv for pool object, created here
+	 * data_lv      sub lv, was lv arg, now renamed
+	 * metadata_lv  sub lv, existing or created here
+	 */
+
+	data_lv = lv;
+	pool_name = lv->name; /* Use original LV name for pool name */
+
+	/*
+	 * Rename the original LV arg to the internal data LV naming scheme.
+	 *
 	 * Since we wish to have underlaying devs to match _[ct]data
 	 * rename data LV to match pool LV subtree first,
 	 * also checks for visible LV.
+	 *
+	 * FIXME: any more types prohibited here?
 	 */
-	/* FIXME: any more types prohibited here? */
+
 	if (!lv_rename_update(cmd, data_lv, data_name, 0))
 		return_0;
 
-	if (!(pool_lv = lv_create_empty(old_name, NULL,
-					((segtype_is_cache_pool(lp->segtype)) ?
-					 CACHE_POOL : THIN_POOL) |
-					VISIBLE_LV | LVM_READ | LVM_WRITE,
+	/*
+	 * Create LV structures for the new pool LV object,
+	 * and connect it to the data/meta LVs.
+	 */
+
+	if (!(pool_lv = lv_create_empty(pool_name, NULL,
+					(to_cachepool ? CACHE_POOL : THIN_POOL) | VISIBLE_LV | LVM_READ | LVM_WRITE,
 					ALLOC_INHERIT, vg))) {
 		log_error("Creation of pool LV failed.");
 		return 0;
 	}
 
 	/* Allocate a new pool segment */
-	if (!(seg = alloc_lv_segment(lp->segtype, pool_lv, 0, data_lv->le_count,
+	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count,
 				     pool_lv->status, 0, NULL, 1,
 				     data_lv->le_count, 0, 0, 0, NULL)))
 		return_0;
@@ -2907,7 +3087,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	 * data and meta LVs (they are unlocked and deleted below.)
 	 */
 	if (is_lockd_type(vg->lock_type)) {
-		if (segtype_is_cache_pool(lp->segtype)) {
+		if (to_cachepool) {
 			data_lv->lock_args = NULL;
 			metadata_lv->lock_args = NULL;
 		} else {
@@ -2919,1763 +3099,182 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			else if (!strcmp(vg->lock_type, "dlm"))
 				pool_lv->lock_args = "dlm";
 			/* The lock_args will be set in vg_write(). */
-		}
-	}
-
-	/* FIXME: revert renamed LVs in fail path? */
-	/* FIXME: any common code with metadata/thin_manip.c  extend_pool() ? */
-
-	seg->transaction_id = 0;
-
-mda_write:
-	seg->chunk_size = lp->chunk_size;
-	seg->discards = lp->discards;
-	seg->zero_new_blocks = lp->zero ? 1 : 0;
-
-	if (lp->cache_mode &&
-	    !cache_set_cache_mode(seg, lp->cache_mode))
-		return_0;
-
-	if ((lp->policy_name || lp->policy_settings) &&
-	    !cache_set_policy(seg, lp->policy_name, lp->policy_settings))
-		return_0;
-
-	/* Rename deactivated metadata LV to have _tmeta suffix */
-	/* Implicit checks if metadata_lv is visible */
-	if (lp->pool_metadata_name &&
-	    !lv_rename_update(cmd, metadata_lv, metadata_name, 0))
-		return_0;
-
-	if (!attach_pool_metadata_lv(seg, metadata_lv))
-		return_0;
-
-	if (!handle_pool_metadata_spare(vg, metadata_lv->le_count,
-					lp->pvh, lp->poolmetadataspare))
-		return_0;
-
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
-
-	if (seg->zero_new_blocks &&
-	    seg->chunk_size  >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
-		log_warn("WARNING: Pool zeroing and large %s chunk size slows down "
-			 "provisioning.", display_size(cmd, seg->chunk_size));
-
-	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
-		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
-		goto out;
-	}
-
-	if (activate_pool &&
-	    !activate_lv_excl(cmd, pool_lv)) {
-		log_error("Failed to activate pool logical volume %s.",
-			  display_lvname(pool_lv));
-		/* Deactivate subvolumes */
-		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
-			log_error("Failed to deactivate pool data logical volume %s.",
-				  display_lvname(seg_lv(seg, 0)));
-		if (!deactivate_lv(cmd, seg->metadata_lv))
-			log_error("Failed to deactivate pool metadata logical volume %s.",
-				  display_lvname(seg->metadata_lv));
-		goto out;
-	}
-
-	r = 1;
-	lp->pool_data_lv = pool_lv;
-
-out:
-	backup(vg);
-
-	if (r)
-		log_print_unless_silent("Converted %s to %s pool.",
-					display_lvname(pool_lv),
-					(segtype_is_cache_pool(lp->segtype)) ?
-					"cache" : "thin");
-
-	/*
-	 * Unlock and free the locks from existing LVs that became pool data
-	 * and meta LVs.
-	 */
-	if (lockd_data_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
-			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
-		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
-	}
-
-	if (lockd_meta_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
-			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
-		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
-	}
-
-	return r;
-#if 0
-revert_new_lv:
-	/* TBD */
-	if (!lp->pool_metadata_lv_name) {
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Failed to deactivate metadata lv.");
-			return 0;
-		}
-		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
-			log_error("Manual intervention may be required to remove "
-				  "abandoned LV(s) before retrying.");
-		else
-			backup(vg);
-	}
-
-	return 0;
-#endif
-}
-
-static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
-					 struct logical_volume *lv,
-					 struct logical_volume *metadata_lv)
-{
-	struct volume_group *vg = lv->vg;
-	struct logical_volume *prev_metadata_lv;
-	struct lv_segment *seg;
-	struct lv_types *lvtype;
-	char meta_name[NAME_LEN];
-	const char *swap_name;
-	uint32_t chunk_size;
-	int is_thinpool;
-	int is_cachepool;
-	int lvt_enum;
-
-	is_thinpool = lv_is_thin_pool(lv);
-	is_cachepool = lv_is_cache_pool(lv);
-	lvt_enum = get_lvt_enum(metadata_lv);
-	lvtype = get_lv_type(lvt_enum);
-
-	if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
-		log_error("LV %s with type %s cannot be used as a metadata LV.",
-			  display_lvname(metadata_lv), lvtype ? lvtype->name : "unknown");
-		return 0;
-	}
-
-	if (!lv_is_visible(metadata_lv)) {
-		log_error("Can't convert internal LV %s.",
-			  display_lvname(metadata_lv));
-		return 0;
-	}
-
-	if (lv_is_locked(metadata_lv)) {
-		log_error("Can't convert locked LV %s.",
-			  display_lvname(metadata_lv));
-		return 0;
-	}
-
-	if (lv_is_origin(metadata_lv) ||
-	    lv_is_merging_origin(metadata_lv) ||
-	    lv_is_external_origin(metadata_lv) ||
-	    lv_is_virtual(metadata_lv)) {
-		log_error("Pool metadata LV %s is of an unsupported type.",
-			  display_lvname(metadata_lv));
-		return 0;
-	}
-
-	/* FIXME cache pool */
-	if (is_thinpool && pool_is_active(lv)) {
-		/* If any volume referencing pool active - abort here */
-		log_error("Cannot convert pool %s with active volumes.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, is_cachepool ? "_cmeta" : "_tmeta") < 0)) {
-                log_error("Failed to create internal lv names, pool name is too long.");
-                return 0;
-        }
-
-	seg = first_seg(lv);
-
-	/* Normally do NOT change chunk size when swapping */
-
-	if (arg_is_set(cmd, chunksize_ARG)) {
-		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
-
-		if ((chunk_size != seg->chunk_size) && !dm_list_empty(&lv->segs_using_this_lv)) {
-			if (arg_count(cmd, force_ARG) == PROMPT) {
-				log_error("Chunk size can be only changed with --force. Conversion aborted.");
-				return 0;
-			}
-
-			if (!validate_pool_chunk_size(cmd, seg->segtype, chunk_size))
-				return_0;
-
-			log_warn("WARNING: Changing chunk size %s to %s for %s pool volume.",
-				 display_size(cmd, seg->chunk_size),
-				 display_size(cmd, chunk_size),
-				 display_lvname(lv));
-
-			/* Ok, user has likely some serious reason for this */
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Do you really want to change chunk size for %s pool volume? [y/n]: ",
-					  display_lvname(lv)) == 'n') {
-				log_error("Conversion aborted.");
-				return 0;
-			}
-		}
-
-		seg->chunk_size = chunk_size;
-	}
-
-	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt("Do you want to swap metadata of %s pool with metadata volume %s? [y/n]: ",
-			  display_lvname(lv),
-			  display_lvname(metadata_lv)) == 'n') {
-		log_error("Conversion aborted.");
-		return 0;
-	}
-
-	if (!deactivate_lv(cmd, metadata_lv)) {
-		log_error("Aborting. Failed to deactivate %s.",
-			  display_lvname(metadata_lv));
-		return 0;
-	}
-
-	if (!archive(vg))
-		return_0;
-
-	/* Swap names between old and new metadata LV */
-
-	if (!detach_pool_metadata_lv(seg, &prev_metadata_lv))
-		return_0;
-
-	swap_name = metadata_lv->name;
-
-	if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
-		return_0;
-
-	/* Give the previous metadata LV the name of the LV replacing it. */
-
-	if (!lv_rename_update(cmd, prev_metadata_lv, swap_name, 0))
-		return_0;
-
-	/* Rename deactivated metadata LV to have _tmeta suffix */
-
-	if (!lv_rename_update(cmd, metadata_lv, meta_name, 0))
-		return_0;
-
-	if (!attach_pool_metadata_lv(seg, metadata_lv))
-		return_0;
-
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
-
-	backup(vg);
-	return 1;
-}
-
-/*
- * Create a new pool LV, using the lv arg as the data sub LV.
- * The metadata sub LV is either a new LV created here, or an
- * existing LV specified by --poolmetadata.
- */
-
-static int _lvconvert_to_pool(struct cmd_context *cmd,
-			      struct logical_volume *lv,
-			      int to_thinpool,
-			      int to_cachepool,
-			      struct dm_list *use_pvh)
-{
-	struct volume_group *vg = lv->vg;
-	struct logical_volume *metadata_lv = NULL;  /* existing or created */
-	struct logical_volume *data_lv;             /* lv arg renamed */
-	struct logical_volume *pool_lv;             /* new lv created here */
-	const char *pool_metadata_name;             /* user-specified lv name */
-	const char *pool_name;                      /* name of original lv arg */
-	char meta_name[NAME_LEN];                   /* generated sub lv name */
-	char data_name[NAME_LEN];                   /* generated sub lv name */
-	struct segment_type *pool_segtype;          /* thinpool or cachepool */
-	struct lv_segment *seg;
-	unsigned int target_attr = ~0;
-	unsigned int passed_args = 0;
-	unsigned int activate_pool;
-	unsigned int zero_metadata;
-	uint64_t meta_size;
-	uint32_t meta_extents;
-	uint32_t chunk_size;
-	int chunk_calc;
-	int r = 0;
-
-	/* for handling lvmlockd cases */
-	char *lockd_data_args = NULL;
-	char *lockd_meta_args = NULL;
-	char *lockd_data_name = NULL;
-	char *lockd_meta_name = NULL;
-	struct id lockd_data_id;
-	struct id lockd_meta_id;
-
-
-	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
-		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
-		return 0;
-	}
-
-	pool_segtype = to_cachepool ? get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE_POOL) :
-				      get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN_POOL);
-
-	if (!pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
-		log_error("%s: Required device-mapper target(s) not detected in your kernel.", pool_segtype->name);
-		return 0;
-	}
-
-	/* Allow to have only thinpool active and restore it's active state. */
-	activate_pool = to_thinpool && lv_is_active(lv);
-
-	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
-	zero_metadata = to_cachepool ? arg_int_value(cmd, zero_ARG, 1) : 1;
-
-	/* An existing LV needs to have its lock freed once it becomes a data LV. */
-	if (is_lockd_type(vg->lock_type) && lv->lock_args) {
-		lockd_data_args = dm_pool_strdup(cmd->mem, lv->lock_args);
-		lockd_data_name = dm_pool_strdup(cmd->mem, lv->name);
-		memcpy(&lockd_data_id, &lv->lvid.id[1], sizeof(struct id));
-	}
-
-	/*
-	 * If an existing LV is to be used as the metadata LV,
-	 * verify that it's in a usable state.  These checks are
-	 * not done by command def rules because this LV is not
-	 * processed by process_each_lv.
-	 */
-
-	if ((pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
-		if (!(metadata_lv = find_lv(vg, pool_metadata_name))) {
-			log_error("Unknown pool metadata LV %s.", pool_metadata_name);
-			return 0;
-		}
-
-		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
-		if (is_lockd_type(vg->lock_type) && metadata_lv->lock_args) {
-			lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
-			lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
-			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
-		}
-
-		if (metadata_lv == lv) {
-			log_error("Can't use same LV for pool data and metadata LV %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-
-		if (!lv_is_visible(metadata_lv)) {
-			log_error("Can't convert internal LV %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-
-		if (lv_is_locked(metadata_lv)) {
-			log_error("Can't convert locked LV %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-
-		if (lv_is_mirror(metadata_lv)) {
-			log_error("Mirror logical volumes cannot be used for pool metadata.");
-			log_print_unless_silent("Try \"%s\" segment type instead.", SEG_TYPE_NAME_RAID1);
-			return 0;
-		}
-
-		/* FIXME Tidy up all these type restrictions. */
-		if (lv_is_cache_type(metadata_lv) ||
-		    lv_is_thin_type(metadata_lv) ||
-		    lv_is_cow(metadata_lv) || lv_is_merging_cow(metadata_lv) ||
-		    lv_is_origin(metadata_lv) || lv_is_merging_origin(metadata_lv) ||
-		    lv_is_external_origin(metadata_lv) ||
-		    lv_is_virtual(metadata_lv)) {
-			log_error("Pool metadata LV %s is of an unsupported type.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-	}
-
-	/*
-	 * Determine the size of the metadata LV and the chunk size.  When an
-	 * existing LV is to be used for metadata, this introduces some
-	 * constraints/defaults.  When chunk_size=0 and/or meta_extents=0 are
-	 * passed to the "update params" function, defaults are calculated and
-	 * returned.
-	 */
-
-	if (arg_is_set(cmd, chunksize_ARG)) {
-		passed_args |= PASS_ARG_CHUNK_SIZE;
-		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
-		if (!validate_pool_chunk_size(cmd, pool_segtype, chunk_size))
-			return_0;
-	} else {
-		/* A default will be chosen by the "update" function. */
-		chunk_size = 0;
-	}
-
-	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
-		meta_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
-		meta_extents = extents_from_size(cmd, meta_size, vg->extent_size);
-		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	} else if (metadata_lv) {
-		meta_extents = metadata_lv->le_count;
-		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	} else {
-		/* A default will be chosen by the "update" function. */
-		meta_extents = 0;
-	}
-
-	/* Tell the "update" function to ignore these, they are handled below. */
-	passed_args |= PASS_ARG_DISCARDS | PASS_ARG_ZERO;
-
-	/*
-	 * Validate and/or choose defaults for meta_extents and chunk_size,
-	 * this involves some complicated calculations.
-	 */
-
-	if (to_cachepool) {
-		if (!update_cache_pool_params(pool_segtype, vg, target_attr,
-					      passed_args, lv->le_count,
-					      &meta_extents,
-					      &chunk_calc,
-					      &chunk_size))
-			return_0;
-	} else {
-		if (!update_thin_pool_params(pool_segtype, vg, target_attr,
-					     passed_args, lv->le_count,
-					     &meta_extents,
-					     &chunk_calc,
-					     &chunk_size,
-					     NULL, NULL))
-			return_0;
-	}
-
-	if ((uint64_t)chunk_size > ((uint64_t)lv->le_count * vg->extent_size)) {
-		log_error("Pool data LV %s is too small (%s) for specified chunk size (%s).",
-			  display_lvname(lv),
-			  display_size(cmd, (uint64_t)lv->le_count * vg->extent_size),
-			  display_size(cmd, chunk_size));
-		return 0;
-	}
-
-	if (metadata_lv && (meta_extents > metadata_lv->le_count)) {
-		log_error("Pool metadata LV %s is too small (%u extents) for required metadata (%u extents).",
-			  display_lvname(metadata_lv), metadata_lv->le_count, meta_extents);
-		return 0;
-	}
-
-	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
-
-
-	/*
-	 * Verify that user wants to use these LVs.
-	 */
-
-	log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
-		 display_lvname(lv),
-		 metadata_lv ? " and " : "",
-		 metadata_lv ? display_lvname(metadata_lv) : "",
-		 to_cachepool ? "cache" : "thin",
-		 metadata_lv ? " and metadata volumes" : " volume",
-		 zero_metadata ? "with" : "WITHOUT");
-
-	if (zero_metadata)
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-	else if (to_cachepool)
-		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
-
-	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
-			  display_lvname(lv),
-			  metadata_lv ? " and " : "",
-			  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
-		log_error("Conversion aborted.");
-		return 0;
-	}
-
-	/*
-	 * The internal LV names for pool data/meta LVs.
-	 */
-
-	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, to_cachepool ? "_cmeta" : "_tmeta") < 0) ||
-	    (dm_snprintf(data_name, sizeof(data_name), "%s%s", lv->name, to_cachepool ? "_cdata" : "_tdata") < 0)) {
-		log_error("Failed to create internal lv names, pool name is too long.");
-		return 0;
-	}
-
-	/*
-	 * If a new metadata LV needs to be created, collect the settings for
-	 * the new LV and create it.
-	 *
-	 * If an existing LV is used for metadata, deactivate/activate/wipe it.
-	 */
-
-	if (!metadata_lv) {
-		uint32_t meta_stripes;
-		uint32_t meta_stripe_size;
-		uint32_t meta_readahead;
-		alloc_policy_t meta_alloc;
-		unsigned meta_stripes_supplied;
-		unsigned meta_stripe_size_supplied;
-
-		if (!get_stripe_params(cmd, get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED),
-				       &meta_stripes,
-				       &meta_stripe_size,
-				       &meta_stripes_supplied,
-				       &meta_stripe_size_supplied))
-			return_0;
-
-		meta_readahead = arg_uint_value(cmd, readahead_ARG, cmd->default_settings.read_ahead);
-		meta_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
-
-		if (!archive(vg))
-			return_0;
-
-		if (!(metadata_lv = alloc_pool_metadata(lv,
-							meta_name,
-							meta_readahead,
-							meta_stripes,
-							meta_stripe_size,
-							meta_extents,
-							meta_alloc,
-							use_pvh)))
-			return_0;
-	} else {
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to deactivate %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-
-		if (!archive(vg))
-			return_0;
-
-		if (zero_metadata) {
-			metadata_lv->status |= LV_TEMPORARY;
-			if (!activate_lv_local(cmd, metadata_lv)) {
-				log_error("Aborting. Failed to activate metadata lv.");
-				return 0;
-			}
-
-			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
-				log_error("Aborting. Failed to wipe metadata lv.");
-				return 0;
-			}
-		}
-	}
-
-	/*
-	 * Deactivate the data LV and metadata LV.
-	 * We are changing target type, so deactivate first.
-	 */
-
-	if (!deactivate_lv(cmd, metadata_lv)) {
-		log_error("Aborting. Failed to deactivate metadata lv. "
-			  "Manual intervention required.");
-		return 0;
-	}
-
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Aborting. Failed to deactivate logical volume %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	/*
-	 * When the LV referenced by the original function arg "lv"
-	 * is renamed, it is then referenced as "data_lv".
-	 *
-	 * pool_name    pool name taken from lv arg
-	 * data_name    sub lv name, generated
-	 * meta_name    sub lv name, generated
-	 *
-	 * pool_lv      new lv for pool object, created here
-	 * data_lv      sub lv, was lv arg, now renamed
-	 * metadata_lv  sub lv, existing or created here
-	 */
-
-	data_lv = lv;
-	pool_name = lv->name; /* Use original LV name for pool name */
-
-	/*
-	 * Rename the original LV arg to the internal data LV naming scheme.
-	 *
-	 * Since we wish to have underlaying devs to match _[ct]data
-	 * rename data LV to match pool LV subtree first,
-	 * also checks for visible LV.
-	 *
-	 * FIXME: any more types prohibited here?
-	 */
-
-	if (!lv_rename_update(cmd, data_lv, data_name, 0))
-		return_0;
-
-	/*
-	 * Create LV structures for the new pool LV object,
-	 * and connect it to the data/meta LVs.
-	 */
-
-	if (!(pool_lv = lv_create_empty(pool_name, NULL,
-					(to_cachepool ? CACHE_POOL : THIN_POOL) | VISIBLE_LV | LVM_READ | LVM_WRITE,
-					ALLOC_INHERIT, vg))) {
-		log_error("Creation of pool LV failed.");
-		return 0;
-	}
-
-	/* Allocate a new pool segment */
-	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count,
-				     pool_lv->status, 0, NULL, 1,
-				     data_lv->le_count, 0, 0, 0, NULL)))
-		return_0;
-
-	/* Add the new segment to the layer LV */
-	dm_list_add(&pool_lv->segments, &seg->list);
-	pool_lv->le_count = data_lv->le_count;
-	pool_lv->size = data_lv->size;
-
-	if (!attach_pool_data_lv(seg, data_lv))
-		return_0;
-
-	/*
-	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock.
-	 * Locks are removed from existing LVs that are being converted to
-	 * data and meta LVs (they are unlocked and deleted below.)
-	 */
-	if (is_lockd_type(vg->lock_type)) {
-		if (to_cachepool) {
-			data_lv->lock_args = NULL;
-			metadata_lv->lock_args = NULL;
-		} else {
-			data_lv->lock_args = NULL;
-			metadata_lv->lock_args = NULL;
-
-			if (!strcmp(vg->lock_type, "sanlock"))
-				pool_lv->lock_args = "pending";
-			else if (!strcmp(vg->lock_type, "dlm"))
-				pool_lv->lock_args = "dlm";
-			/* The lock_args will be set in vg_write(). */
-		}
-	}
-
-	/*
-	 * Apply settings to the new pool seg, from command line, from
-	 * defaults, sometimes adjusted.
-	 */
-
-	seg->transaction_id = 0;
-	seg->chunk_size = chunk_size;
-
-	if (to_cachepool) {
-		cache_mode_t cache_mode = 0;
-		const char *policy_name = NULL;
-		struct dm_config_tree *policy_settings = NULL;
-
-		if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
-			return_0;
-
-		if (cache_mode &&
-		    !cache_set_cache_mode(seg, cache_mode))
-			return_0;
-
-		if ((policy_name || policy_settings) &&
-		    !cache_set_policy(seg, policy_name, policy_settings))
-			return_0;
-
-		if (policy_settings)
-			dm_config_destroy(policy_settings);
-	} else {
-		const char *discards_name;
-
-		if (arg_is_set(cmd, zero_ARG))
-			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0);
-		else
-			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile);
-
-		if (arg_is_set(cmd, discards_ARG))
-			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-		else {
-			if (!(discards_name = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, vg->profile)))
-				return_0;
-			if (!set_pool_discards(&seg->discards, discards_name))
-				return_0;
-		}
-	}
-
-	/*
-	 * Rename deactivated metadata LV to have _tmeta suffix.
-	 * Implicit checks if metadata_lv is visible.
-	 */
-	if (pool_metadata_name &&
-	    !lv_rename_update(cmd, metadata_lv, meta_name, 0))
-		return_0;
-
-	if (!attach_pool_metadata_lv(seg, metadata_lv))
-		return_0;
-
-	if (!handle_pool_metadata_spare(vg,
-					metadata_lv->le_count,
-					use_pvh,
-					arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE)))
-		return_0;
-
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
-
-	if (seg->zero_new_blocks &&
-	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
-		log_warn("WARNING: Pool zeroing and large %s chunk size slows down provisioning.",
-			 display_size(cmd, seg->chunk_size));
-
-	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
-		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
-		goto out;
-	}
-
-	if (activate_pool &&
-	    !activate_lv_excl(cmd, pool_lv)) {
-		log_error("Failed to activate pool logical volume %s.",
-			  display_lvname(pool_lv));
-		/* Deactivate subvolumes */
-		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
-			log_error("Failed to deactivate pool data logical volume %s.",
-				  display_lvname(seg_lv(seg, 0)));
-		if (!deactivate_lv(cmd, seg->metadata_lv))
-			log_error("Failed to deactivate pool metadata logical volume %s.",
-				  display_lvname(seg->metadata_lv));
-		goto out;
-	}
-
-	r = 1;
-
-out:
-	backup(vg);
-
-	if (r)
-		log_print_unless_silent("Converted %s to %s pool.",
-					display_lvname(lv),
-					to_cachepool ? "cache" : "thin");
-
-	/*
-	 * Unlock and free the locks from existing LVs that became pool data
-	 * and meta LVs.
-	 */
-	if (lockd_data_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
-			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
-		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
-	}
-
-	if (lockd_meta_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
-			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
-		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
-	}
-
-	return r;
-#if 0
-revert_new_lv:
-	/* TBD */
-	if (!pool_metadata_lv_name) {
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Failed to deactivate metadata lv.");
-			return 0;
-		}
-		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
-			log_error("Manual intervention may be required to remove "
-				  "abandoned LV(s) before retrying.");
-		else
-			backup(vg);
-	}
-
-	return 0;
-#endif
-}
-
-/*
- * Convert origin into a cache LV by attaching a cache pool.
- */
-static int _lvconvert_cache(struct cmd_context *cmd,
-			    struct logical_volume *origin_lv,
-			    struct lvconvert_params *lp)
-{
-	struct logical_volume *pool_lv = lp->pool_data_lv;
-	struct logical_volume *cache_lv;
-
-	if (!validate_lv_cache_create_pool(pool_lv))
-		return_0;
-
-	if (!archive(origin_lv->vg))
-		return_0;
-
-	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
-		return_0;
-
-	if (!cache_set_cache_mode(first_seg(cache_lv), lp->cache_mode))
-		return_0;
-
-	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
-		return_0;
-
-	cache_check_for_warns(first_seg(cache_lv));
-
-	if (!lv_update_and_reload(cache_lv))
-		return_0;
-
-	log_print_unless_silent("Logical volume %s is now cached.",
-				display_lvname(cache_lv));
-
-	return 1;
-}
-
-static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
-			    struct logical_volume *lv,
-			    struct logical_volume *cachepool_lv)
-{
-	struct logical_volume *cache_lv;
-	cache_mode_t cache_mode = 0;
-	const char *policy_name = NULL;
-	struct dm_config_tree *policy_settings = NULL;
-
-	if (!validate_lv_cache_create_pool(cachepool_lv))
-		return_0;
-
-	if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
-		return_0;
-
-	if (!archive(lv->vg))
-		return_0;
-
-	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
-		return_0;
-
-	if (!cache_set_cache_mode(first_seg(cache_lv), cache_mode))
-		return_0;
-
-	if (!cache_set_policy(first_seg(cache_lv), policy_name, policy_settings))
-		return_0;
-
-	if (policy_settings)
-		dm_config_destroy(policy_settings);
-
-	cache_check_for_warns(first_seg(cache_lv));
-
-	if (!lv_update_and_reload(cache_lv))
-		return_0;
-
-	log_print_unless_silent("Logical volume %s is now cached.",
-				display_lvname(cache_lv));
-
-	return 1;
-}
-
-/*
- * Functions called to perform a specific operation on a specific LV type.
- *
- * _convert_<lvtype>_<operation>
- *
- * For cases where an operation does not apply to the LV itself, but
- * is implicitly redirected to a sub-LV, these functions locate the
- * correct sub-LV and call the operation on that sub-LV.  If a sub-LV
- * of the proper type is not found, these functions report the error.
- *
- * FIXME: the _lvconvert_foo() functions can be cleaned up since they
- * are now only called for valid combinations of LV type and operation.
- * After that happens, the code remaining in those functions can be
- * moved into the _convert_lvtype_operation() functions below.
- */
-
-/*
- * Separate a COW snapshot LV from its origin.
- * lvconvert --splitsnapshot LV
- */
-static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct logical_volume *lv,
-					       struct lvconvert_params *lp)
-{
-	return _lvconvert_splitsnapshot(cmd, lv);
-}
-
-/*
- * Merge a COW snapshot LV into its origin.
- * lvconvert --merge LV
- */
-static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_volume *lv,
-				       struct lvconvert_params *lp)
-{
-	/* return _lvconvert_merge_old_snapshot(cmd, lv, lp); */
-}
-
-/*
- * Merge a snapshot thin LV into its origin.
- * lvconvert --merge LV
- */
-
-static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_volume *lv,
-				      struct lvconvert_params *lp)
-{
-	return _lvconvert_merge_thin_snapshot(cmd, lv);
-}
-
-/*
- * Split and preserve a cache pool from the data portion of a thin pool LV.
- * lvconvert --splitcache LV
- */
-static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
-					 struct lvconvert_params *lp)
-{
-	struct logical_volume *sublv1;
-
-	sublv1 = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
-
-	if (!lv_is_cache(sublv1)) {
-		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
-		return 0;
-	}
-
-	/* return _lvconvert_split_cached(cmd, sublv1); */
-	return 0;
-}
-
-/*
- * Split and remove a cache pool from the data portion of a thin pool LV.
- * lvconvert --uncache LV
- */
-static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_volume *lv,
-				      struct lvconvert_params *lp)
-{
-	struct logical_volume *sublv1 = NULL;
-
-	sublv1 = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
-
-	if (!lv_is_cache(sublv1)) {
-		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
-		return 0;
-	}
-
-	/* return _lvconvert_uncache(cmd, sublv1, lp); */
-	return 0;
-}
-
-/*
- * Convert the data portion of a thin pool LV to a cache LV.
- * lvconvert --type cache LV
- *
- * Required options:
- * --cachepool LV
- *
- * Auxiliary operation:
- * Converts the --cachepool arg to a cache pool if it is not already.
- *
- * Alternate syntax:
- * lvconvert --cache LV
- */
-static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volume *lv,
-				    struct lvconvert_params *lp)
-{
-	/* lvconvert --type cache includes an implicit conversion of the cachepool arg to type cache-pool. */
-	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
-		return 0;
-	}
-
-	/* Do we need to grab the tdata sub LV to pass on? */
-
-	return _lvconvert_cache(cmd, lv, lp);
-}
-
-/*
- * Replace the metadata LV in a thin pool LV.
- * lvconvert --poolmetadata NewLV --thinpool LV
- * FIXME: this will change so --swap-poolmetadata defines the operation.
- * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
- */
-static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
-					   struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Split and preserve a cache pool from a cache LV.
- * lvconvert --splitcache LV
- */
-static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
-					    struct lvconvert_params *lp)
-{
-	/* return _lvconvert_split_cached(cmd, lv); */
-	return 0;
-}
-
-/*
- * Split and remove a cache pool from a cache LV.
- * lvconvert --uncache LV
- */
-static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical_volume *lv,
-					 struct lvconvert_params *lp)
-{
-	/* return _lvconvert_uncache(cmd, lv, lp); */
-	return 0;
-}
-
-/*
- * Split images from the raid1|mirror origin of a cache LV and use them to create a new LV.
- * lvconvert --splitmirrors Number LV
- *
- * Required options:
- * --trackchanges | --name Name
- */
-static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-					     struct lvconvert_params *lp)
-{
-	struct logical_volume *sublv1;
-
-	sublv1 = seg_lv(first_seg(lv), 0);
-
-	if (lv_is_raid(sublv1))
-		return _lvconvert_raid(sublv1, lp);
-
-	if (lv_is_mirror(sublv1))
-		return _lvconvert_mirrors(cmd, lv, lp);
-
-	log_error("Sub LV %s must be raid or mirror.", display_lvname(sublv1));
-	return 0;
-}
-
-/*
- * Convert a cache LV to a thin pool (using the cache LV for thin pool data).
- * lvconvert --type thin-pool LV
- *
- * Convert a cache LV to a thin volume with cached external origin using given
- * thinpool tpLV (when not yet Thinpool convert it to thin-pool first).
- * Conversion is 2-step process in this case.
- * Only writethrough cacheLV can be converted as external origin is read-only.
- * lvconvert --thin cacheLV --thinpool tpLV
- *
- * Alternate syntax:
- * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
- * lvconvert --thinpool LV
- */
-static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-					   struct lvconvert_params *lp)
-{
-	int is_clean;
-	const struct lv_segment *pool_seg;
-
-	if (!_lvconvert_pool(cmd, lv, lp))
-		return_0;
-
-	if (lv_is_cache(lv) && !lv_is_pool_data(lv)) {
-		pool_seg = first_seg(first_seg(lv)->pool_lv);
-		if (pool_seg->cache_mode != CACHE_MODE_WRITETHROUGH) {
-			log_error("Cannot convert cache volume %s with %s cache mode to external origin.",
-				  display_lvname(lv),
-				  get_cache_mode_name(pool_seg));
-			log_error("To proceed, run 'lvchange --cachemode writethrough %s'.",
-				  display_lvname(lv));
-			return 0;
-		}
-
-		if (!lv_cache_wait_for_clean(lv, &is_clean))
-			return_0;
-
-		if (!is_clean) {
-			log_error("Cache %s is not clean, refusing to convert to external origin.",
-				  display_lvname(lv));
-			return 0;
-		}
-
-		if (!_lvconvert_thin(cmd, lv, lp))
-			return_0;
-	}
-
-	return 1;
-}
-
-/*
- * Convert/Recombine  cacheLV to be an origin for snapshot
- * lvconvert --type snapshot cacheLV snapshotLV
- */
-static int _convert_cache_volume_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-					  struct lvconvert_params *lp)
-{
-	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
-}
-
-/*
- * Split a cache volume from a cache pool LV.
- * lvconvert --splitcache LV
- */
-static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
-					  struct lvconvert_params *lp)
-{
-	struct logical_volume *sublv1;
-	struct lv_segment *seg;
-
-	/* When passed used cache-pool of used cached LV -> split cached LV */
-
-	if ((dm_list_size(&lv->segs_using_this_lv) == 1) &&
-	    (seg = get_only_segment_using_this_lv(lv)) &&
-	    seg_is_cache(seg))
-		sublv1 = seg->lv;
-	else {
-		log_error("Sub LV of cache type not found.");
-		return 0;
-	}
-
-	if (!lv_is_cache(sublv1)) {
-		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
-		return 0;
-	}
-
-	/* return _lvconvert_split_cached(cmd, sublv1); */
-	return 0;
-}
-
-/*
- * Replace the metadata LV in a cache pool LV.
- * lvconvert --poolmetadata NewLV --cachepool LV
- * FIXME: this will change so --swap-poolmetadata defines the operation.
- * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
- */
-static int _convert_cache_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
-					    struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Change the number of images in a mirror LV.
- * lvconvert --mirrors Number LV
- */
-static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	return _lvconvert_mirrors(cmd, lv, lp);
-}
-
-/*
- * Split images from a mirror LV and use them to create a new LV.
- * lvconvert --splitmirrors Number LV
- *
- * Required options:
- * --name Name
- */
-
-static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-					struct lvconvert_params *lp)
-{
-	return _lvconvert_mirrors(cmd, lv, lp);
-}
-
-/*
- * Change the type of log used by a mirror LV.
- * lvconvert --mirrorlog Type LV
- */
-static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	return _lvconvert_mirrors(cmd, lv, lp);
-}
-
-/*
- * Convert mirror LV to linear LV.
- * lvconvert --type linear LV
- *
- * Alternate syntax:
- * lvconvert --mirrors 0 LV
- */
-static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	return _lvconvert_mirrors(cmd, lv, lp);
-}
-
-/*
- * Convert mirror LV to raid1 LV.
- * lvconvert --type raid1 LV
- */
-static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
-				struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Change the number of images in a raid1 LV.
- * lvconvert --mirrors Number LV
- */
-static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *lv,
-				struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Split images from a raid1 LV and use them to create a new LV.
- * lvconvert --splitmirrors Number LV
- *
- * Required options:
- * --trackchanges | --name Name
- */
-static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
-				      struct lvconvert_params *lp)
-{
-	/* FIXME: split the splitmirrors section out of _lvconvert_raid and call it here. */
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Merge a raid1 LV into originalLV if the raid1 LV was
- * previously split from the originalLV using --trackchanges.
- * lvconvert --merge LV
- */
-static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *lv,
-			       struct lvconvert_params *lp)
-{
-	/* FIXME: split the merge section out of _lvconvert_raid and call it here. */
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Combine a raid* LV with a snapshot LV that was previously
- * split from the raid* LV using --splitsnapshot.
- * lvconvert --type snapshot LV SnapshotLV
- *
- * Alternate syntax:
- * lvconvert --snapshot LV SnapshotLV
- */
-static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
-}
-
-/*
- * Convert a raid* LV to a thin LV with an external origin.
- * lvconvert --type thin LV
- *
- * Required options:
- * --thinpool LV
- *
- * Auxiliary operation:
- * Converts the --thinpool arg to a thin pool if it is not already.
- *
- * Alternate syntax:
- * lvconvert --thin LV
- */
-static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
-{
-	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
-	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Implicit conversion of --thinpool arg to type thin-pool failed.");
-		return 0;
-	}
-
-	return _lvconvert_thin(cmd, lv, lp);
-}
-
-/*
- * Convert a raid* LV to a cache LV.
- * lvconvert --type cache LV
- *
- * Required options:
- * --cachepool LV
- *
- * Auxiliary operation:
- * Converts the --cachepool arg to a cache pool if it is not already.
- *
- * Alternate syntax:
- * lvconvert --cache LV
- */
-static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *lv,
-			       struct lvconvert_params *lp)
-{
-	/* lvconvert --type cache includes an implicit conversion of the cachepool arg to type cache-pool. */
-	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
-		return 0;
-	}
-
-	return _lvconvert_cache(cmd, lv, lp);
-}
-
-/*
- * Convert a raid* LV to a thin-pool LV.
- * lvconvert --type thin-pool LV
- *
- * Alternate syntax:
- * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
- * lvconvert --thinpool LV
- */
-static int _convert_raid_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-				   struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Convert a raid* LV to cache-pool LV.
- * lvconvert --type cache-pool LV
- */
-static int _convert_raid_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
-				    struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Convert a raid* LV to use a different raid level.
- * lvconvert --type raid* LV
- */
-static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Convert a raid* LV to a mirror LV.
- * lvconvert --type mirror LV
- */
-static int _convert_raid_mirror(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Convert a raid* LV to a striped LV.
- * lvconvert --type striped LV
- */
-static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Convert a raid* LV to a linear LV.
- * lvconvert --type linear LV
- */
-static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,
-				struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Merge a striped/linear LV into a raid1 LV if the striped/linear LV was
- * previously split from the raid1 LV using --trackchanges.
- * lvconvert --merge LV
- */
-static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Combine a linear/striped LV with a snapshot LV that was previously
- * split from the linear/striped LV using --splitsnapshot.
- * lvconvert --type snapshot LV SnapshotLV
- *
- * Alternate syntax:
- * lvconvert --snapshot LV SnapshotLV
- */
-static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-				     struct lvconvert_params *lp)
-{
-	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
-}
-
-/*
- * Convert a striped/linear LV to a thin LV with an external origin.
- * lvconvert --type thin LV
- *
- * Required options:
- * --thinpool LV
- *
- * Auxiliary operation:
- * Converts the --thinpool arg to a thin pool if it is not already.
- *
- * Alternate syntax:
- * lvconvert --thin LV
- */
-static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
-	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Conversion of --thinpool arg to type thin-pool failed.");
-		return 0;
-	}
-
-	return _lvconvert_thin(cmd, lv, lp);
-}
-
-/*
- * Convert a striped/linear LV to a cache LV.
- * lvconvert --type cache LV
- *
- * Required options:
- * --cachepool LV
- *
- * Auxiliary operation:
- * Converts the --cachepool arg to a cache pool if it is not already.
- *
- * Alternate syntax:
- * lvconvert --cache LV
- */
-
-static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume *lv,
-				  struct lvconvert_params *lp)
-{
-	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
-	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Conversion of --cachepool arg to type cache-pool failed.");
-		return 0;
-	}
-
-	return _lvconvert_cache(cmd, lv, lp);
-}
-
-/*
- * Convert a striped/linear LV to a thin-pool LV.
- * lvconvert --type thin-pool LV
- *
- * Alternate syntax:
- * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
- * lvconvert --thinpool LV
- */
-static int _convert_striped_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-				      struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Convert a striped/linear LV to a cache-pool LV.
- * lvconvert --type cache-pool LV
- */
-static int _convert_striped_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
-				       struct lvconvert_params *lp)
-{
-	return _lvconvert_pool(cmd, lv, lp);
-}
-
-/*
- * Convert a striped/linear LV to a mirror LV.
- * lvconvert --type mirror LV
- *
- * Required options:
- * --mirrors Number
- *
- * Alternate syntax:
- * This is equivalent to above when global/mirror_segtype_default="mirror".
- * lvconvert --mirrors Number LV
- */
-static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volume *lv,
-				   struct lvconvert_params *lp)
-{
-	return _lvconvert_mirrors(cmd, lv, lp);
-}
-
-/*
- * Convert a striped/linear LV to a raid* LV.
- * lvconvert --type raid* LV
- *
- * Required options:
- * --mirrors Number
- *
- * Alternate syntax:
- * This is equivalent to above when global/mirror_segtype_default="raid1".
- * lvconvert --mirrors Number LV
- */
-static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	return _lvconvert_raid(lv, lp);
-}
-
-/*
- * Functions called to perform all valid operations on a given LV type.
- *
- * _convert_<lvtype>
- */
-static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	if (lp->splitsnapshot)
-		return _convert_cow_snapshot_splitsnapshot(cmd, lv, lp);
-
-	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
-	if (lp->merge)
-		return _convert_cow_snapshot_merge(cmd, lv, lp);
-
-	log_error("Operation not permitted on COW snapshot LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a COW snapshot LV are:\n"
-		  "  --splitsnapshot\n"
-		  "  --merge\n");
-	return 0;
-}
-
-static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *lv,
-				struct lvconvert_params *lp)
-{
-	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
-	if (lp->merge)
-		return _convert_thin_volume_merge(cmd, lv, lp);
-
-	log_error("Operation not permitted on thin LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a thin LV are:\n"
-		  "  --merge\n");
-	return 0;
-}
-
-static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
-{
-	if (lp->splitcache)
-		return _convert_thin_pool_splitcache(cmd, lv, lp);
-
-	if (lp->split)
-		return _convert_thin_pool_splitcache(cmd, lv, lp);
-
-	if (lp->uncache)
-		return _convert_thin_pool_uncache(cmd, lv, lp);
-
-	if (lp->cache)
-		return _convert_thin_pool_cache(cmd, lv, lp);
-
-	/* FIXME: swapping the thin pool metadata LV needs a specific option like --swapmetadata */
-	if (arg_is_set(cmd, poolmetadata_ARG))
-		return _convert_thin_pool_swapmetadata(cmd, lv, lp);
-
-	/* FIXME: add --swapmetadata to list of permitted operations. */
-
-	log_error("Operation not permitted on thin pool LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a thin pool LV are:\n"
-		  "  --splitcache  (operates on cache sub LV)\n"
-		  "  --uncache     (operates on cache sub LV)\n"
-		  "  --type cache  (operates on data sub LV)\n"
-		  "  --repair\n");
-	return 0;
-}
-
-static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	if (lp->splitcache)
-		return _convert_cache_volume_splitcache(cmd, lv, lp);
-
-	if (lp->split)
-		return _convert_cache_volume_splitcache(cmd, lv, lp);
-
-	if (lp->uncache)
-		return _convert_cache_volume_uncache(cmd, lv, lp);
-
-	if (arg_is_set(cmd, splitmirrors_ARG))
-		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
-	    arg_is_set(cmd, thinpool_ARG))
-		return _convert_cache_volume_thin_pool(cmd, lv, lp);
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) ||
-	    arg_is_set(cmd, snapshot_ARG))
-		return _convert_cache_volume_snapshot(cmd, lv, lp);
-
-	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
-
-	log_error("Operation not permitted on cache LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a cache LV are:\n"
-		  "  --splitcache\n"
-		  "  --uncache\n"
-		  "  --splitmirrors (operates on mirror or raid sub LV)\n"
-		  "  --type thin-pool\n");
-	return 0;
-}
-
-static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
-			       struct lvconvert_params *lp)
-{
-	if (lp->splitcache)
-		return _convert_cache_pool_splitcache(cmd, lv, lp);
-
-	if (lp->split)
-		return _convert_cache_pool_splitcache(cmd, lv, lp);
+		}
+	}
 
-	/* FIXME: swapping the cache pool metadata LV needs a specific option like --swapmetadata */
-	if (arg_is_set(cmd, poolmetadata_ARG))
-		return _convert_cache_pool_swapmetadata(cmd, lv, lp);
+	/*
+	 * Apply settings to the new pool seg, from command line, from
+	 * defaults, sometimes adjusted.
+	 */
 
-	/* FIXME: add --swapmetadata to list of permitted operations. */
+	seg->transaction_id = 0;
+	seg->chunk_size = chunk_size;
 
-	log_error("Operation not permitted on cache pool LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a cache pool LV are:\n"
-		  "  --splitcache    (operates on cache LV)\n");
-	return 0;
-}
+	if (to_cachepool) {
+		cache_mode_t cache_mode = 0;
+		const char *policy_name = NULL;
+		struct dm_config_tree *policy_settings = NULL;
 
-static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
-			   struct lvconvert_params *lp)
-{
-	if (arg_is_set(cmd, mirrors_ARG))
-		return _convert_mirror_number(cmd, lv, lp);
+		if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
+			return_0;
 
-	if (arg_is_set(cmd, splitmirrors_ARG))
-		return _convert_mirror_splitmirrors(cmd, lv, lp);
+		if (cache_mode &&
+		    !cache_set_cache_mode(seg, cache_mode))
+			return_0;
 
-	if (arg_is_set(cmd, mirrorlog_ARG) || arg_is_set(cmd, corelog_ARG))
-		return _convert_mirror_log(cmd, lv, lp);
+		if ((policy_name || policy_settings) &&
+		    !cache_set_policy(seg, policy_name, policy_settings))
+			return_0;
 
-	if (_linear_type_requested(lp->type_str))
-		return _convert_mirror_linear(cmd, lv, lp);
+		if (policy_settings)
+			dm_config_destroy(policy_settings);
+	} else {
+		const char *discards_name;
 
-	if (segtype_is_raid(lp->segtype))
-		return _convert_mirror_raid(cmd, lv, lp);
+		if (arg_is_set(cmd, zero_ARG))
+			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0);
+		else
+			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile);
 
-	log_error("Unknown operation on mirror LV %s.", display_lvname(lv));
-	return 0;
-}
+		if (arg_is_set(cmd, discards_ARG))
+			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+		else {
+			if (!(discards_name = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, vg->profile)))
+				return_0;
+			if (!set_pool_discards(&seg->discards, discards_name))
+				return_0;
+		}
+	}
 
-static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
-			 struct lvconvert_params *lp)
-{
-	if (arg_is_set(cmd, mirrors_ARG))
-		return _convert_raid_number(cmd, lv, lp);
+	/*
+	 * Rename deactivated metadata LV to have _tmeta suffix.
+	 * Implicit checks if metadata_lv is visible.
+	 */
+	if (pool_metadata_name &&
+	    !lv_rename_update(cmd, metadata_lv, meta_name, 0))
+		return_0;
 
-	if (arg_is_set(cmd, splitmirrors_ARG))
-		return _convert_raid_splitmirrors(cmd, lv, lp);
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
+		return_0;
 
-	if (segtype_is_raid(lp->segtype))
-		return _convert_raid_raid(cmd, lv, lp);
+	if (!handle_pool_metadata_spare(vg,
+					metadata_lv->le_count,
+					use_pvh,
+					arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE)))
+		return_0;
 
-	if (segtype_is_mirror(lp->segtype))
-		return _convert_raid_mirror(cmd, lv, lp);
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
-		return _convert_raid_striped(cmd, lv, lp);
+	if (seg->zero_new_blocks &&
+	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
+		log_warn("WARNING: Pool zeroing and large %s chunk size slows down provisioning.",
+			 display_size(cmd, seg->chunk_size));
 
-	if (_linear_type_requested(lp->type_str))
-		return _convert_raid_linear(cmd, lv, lp);
+	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
+		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
+		goto out;
+	}
 
-	log_error("Unknown operation on raid LV %s.", display_lvname(lv));
-	return 0;
-}
+	if (activate_pool &&
+	    !activate_lv_excl(cmd, pool_lv)) {
+		log_error("Failed to activate pool logical volume %s.",
+			  display_lvname(pool_lv));
+		/* Deactivate subvolumes */
+		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
+			log_error("Failed to deactivate pool data logical volume %s.",
+				  display_lvname(seg_lv(seg, 0)));
+		if (!deactivate_lv(cmd, seg->metadata_lv))
+			log_error("Failed to deactivate pool metadata logical volume %s.",
+				  display_lvname(seg->metadata_lv));
+		goto out;
+	}
 
-static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
-			    struct lvconvert_params *lp)
-{
-	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
+	r = 1;
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
-		return _convert_striped_mirror(cmd, lv, lp);
+out:
+	backup(vg);
 
-	if (segtype_is_raid(lp->segtype))
-		return _convert_striped_raid(cmd, lv, lp);
+	if (r)
+		log_print_unless_silent("Converted %s to %s pool.",
+					display_lvname(lv),
+					to_cachepool ? "cache" : "thin");
 
-	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
+	/*
+	 * Unlock and free the locks from existing LVs that became pool data
+	 * and meta LVs.
+	 */
+	if (lockd_data_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
+		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
+	}
 
-	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_MIRROR))
-		return _convert_striped_mirror(cmd, lv, lp);
+	if (lockd_meta_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
+		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
+	}
 
-	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_RAID1))
-		return _convert_striped_raid(cmd, lv, lp);
+	return r;
+#if 0
+revert_new_lv:
+	/* TBD */
+	if (!pool_metadata_lv_name) {
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Failed to deactivate metadata lv.");
+			return 0;
+		}
+		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned LV(s) before retrying.");
+		else
+			backup(vg);
+	}
 
-	log_error("Unknown operation on striped or linear LV %s.", display_lvname(lv));
 	return 0;
+#endif
 }
 
-/*
- * Main entry point.
- * lvconvert performs a specific <operation> on a specific <lv_type>.
- *
- * The <operation> is specified by command line args.
- * The <lv_type> is found using lv_is_foo(lv) functions.
- *
- * for each lvtype,
- *     _convert_lvtype();
- *	 for each arg_is_set(operation)
- *	     _convert_lvtype_operation();
- *
- * FIXME: this code (identifying/routing each unique operation through
- * _convert_lvtype_op) was designed to work based on the new type that
- * the user entered after --type, not the final segment type in lp->type_str.
- * Sometimes the two differ because tricks are played with lp->type_str.
- * So, when the use of arg_type_str(type_ARG) here was replaced with
- * lp->type_str, some commands are no longer identified/routed correctly.
- */
-static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct lvconvert_params *lp)
+static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
+			    struct logical_volume *lv,
+			    struct logical_volume *cachepool_lv)
 {
-	struct lv_segment *seg = first_seg(lv);
-	int ret = 0;
+	struct logical_volume *cache_lv;
+	cache_mode_t cache_mode = 0;
+	const char *policy_name = NULL;
+	struct dm_config_tree *policy_settings = NULL;
 
-	/* Set up segtype either from type_str or else to match the existing one. */
-	if (!*lp->type_str)
-		lp->segtype = seg->segtype;
-	else if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-		goto_out;
+	if (!validate_lv_cache_create_pool(cachepool_lv))
+		return_0;
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
-		if (!lp->mirrors_supplied && !seg_is_raid1(seg)) {
-			log_error("Conversions to --type mirror require -m/--mirrors");
-			goto out;
-		}
-	}
+	if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
+		return_0;
 
-	/* lv->segtype can't be NULL */
-	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
-		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel.", lp->segtype->name);
-		goto out;
-	}
+	if (!archive(lv->vg))
+		return_0;
 
-	/* Process striping parameters */
-	/* FIXME This is incomplete */
-	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
-	    _striped_type_requested(lp->type_str) || lp->mirrorlog || lp->corelog) {
-		/* FIXME Handle +/- adjustments too? */
-		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
-			goto_out;
+	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
+		return_0;
 
-		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
-			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
-			/* The default keeps existing number of stripes, handled inside the library code */
-			if (!arg_is_set(cmd, stripes_long_ARG))
-				lp->stripes = 0;
-	}
+	if (!cache_set_cache_mode(first_seg(cache_lv), cache_mode))
+		return_0;
 
-	if (lv_is_cache(lv))
-		lv = seg_lv(first_seg(lv), 0);
+	if (!cache_set_policy(first_seg(cache_lv), policy_name, policy_settings))
+		return_0;
 
-	if (lv_is_mirror(lv)) {
-		ret = _convert_mirror(cmd, lv, lp);
-		goto out;
-	}
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
 
-	if (lv_is_raid(lv)) {
-		ret = _convert_raid(cmd, lv, lp);
-		goto out;
-	}
+	cache_check_for_warns(first_seg(cache_lv));
 
-	/*
-	 * FIXME: add lv_is_striped() and lv_is_linear()?
-	 * This does not include raid0 which is caught by the test above.
-	 * If operations differ between striped and linear, split this case.
-	 */
-	if (segtype_is_striped(seg->segtype) || segtype_is_linear(seg->segtype)) {
-		ret = _convert_striped(cmd, lv, lp);
-		goto out;
-	}
+	if (!lv_update_and_reload(cache_lv))
+		return_0;
 
-	/*
-	 * The intention is to explicitly check all cases above and never
-	 * reach here, but this covers anything that was missed.
-	 */
-	log_error("Cannot convert LV %s.", display_lvname(lv));
+	log_print_unless_silent("Logical volume %s is now cached.",
+				display_lvname(cache_lv));
 
-out:
-	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+	return 1;
 }
 
 static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_context *cmd,
@@ -4990,11 +3589,6 @@ int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 
 /*
- * snapshot-related lvconvert utilities
- */
-
-
-/*
  * Merge a COW snapshot LV into its origin.
  */
 
@@ -5661,7 +4255,7 @@ static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_
 
 	lp->lv_to_poll = lv;
 
-	ret = _lvconvert(cmd, lv, lp);
+	ret = _lvconvert_raid_types(cmd, lv, lp);
 
 	if (ret != ECMD_PROCESSED)
 		return_ECMD_FAILED;
@@ -5805,8 +4399,8 @@ static int _lvconvert_change_mirrorlog_single(struct cmd_context *cmd, struct lo
 
 	lp->pvh = use_pvh;
 
-	/* FIXME: extract the mirrorlog functionality out of _lvconvert()? */
-	return _lvconvert(cmd, lv, lp);
+	/* FIXME: extract the mirrorlog functionality out of _lvconvert_raid_types()? */
+	return _lvconvert_raid_types(cmd, lv, lp);
 }
 
 int lvconvert_change_mirrorlog_cmd(struct cmd_context * cmd, int argc, char **argv)
@@ -5861,8 +4455,8 @@ static int _lvconvert_split_mirror_images_single(struct cmd_context *cmd, struct
 
 	lp->pvh = use_pvh;
 
-	/* FIXME: extract the split functionality out of _lvconvert()? */
-	return _lvconvert(cmd, lv, lp);
+	/* FIXME: extract the split functionality out of _lvconvert_raid_types()? */
+	return _lvconvert_raid_types(cmd, lv, lp);
 }
 
 int lvconvert_split_mirror_images_cmd(struct cmd_context * cmd, int argc, char **argv)


