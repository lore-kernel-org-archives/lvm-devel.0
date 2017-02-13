From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:20 +0000 (UTC)
Subject: master - lvconvert: use command defs for raid/mirror types
Message-ID: <20170213181020.516D26039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46b2599d5c4e01eee66be7c45aa6cf36d7cbc50f
Commit:        46b2599d5c4e01eee66be7c45aa6cf36d7cbc50f
Parent:        a801b92b2c81213dddccc9f9a09794208f92bfc9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 19 15:53:21 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: use command defs for raid/mirror types

All lvconvert functionality has been moved out of the
previous monolithic lvconvert code, except conversions
related to raid/mirror/striped/linear.  This switches
that remaining code to be based on command defs, and
standard process_each_lv arg processing.  This final
switch results in quite a bit of dead code that is
also removed.
---
 tools/command-lines.in |    7 +
 tools/lvconvert.c      | 1105 ++++++++++++++----------------------------------
 tools/lvmcmdline.c     |   13 +-
 tools/tools.h          |    3 +
 4 files changed, 327 insertions(+), 801 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index a529685..ebe7006 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -337,24 +337,28 @@ OO: OO_LVCONVERT_RAID, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to striped.
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --type mirror LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1).
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --type raid LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid.
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --mirrors SNumber LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.
+RULE: all not lv_is_locked lv_is_pvmove
 
 ---
 
@@ -366,12 +370,14 @@ OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_split_mirror_images
 DESC: Split images from a raid1 or mirror LV and use them to create a new LV.
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --splitmirrors Number --trackchanges LV_raid1_cache
 OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_split_mirror_images
 DESC: Split images from a raid1 LV and track changes to origin.
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --mergemirrors LV_linear_raid|VG|Tag ...
 OO: OO_LVCONVERT
@@ -384,6 +390,7 @@ OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_change_mirrorlog
 DESC: Change the type of mirror log used by a mirror LV.
+RULE: all not lv_is_locked lv_is_pvmove
 
 ---
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 296d4e2..642d6b7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -39,40 +39,15 @@
  */
 
 typedef enum {
-	/* Merge:
-	 *   If merge_snapshot is also set:
-	 *     merge thin snapshot LV into its origin
-	 *     merge old snapshot COW into its origin
-	 *   or if merge_mirror is also set
-	 *     merge LV previously split from mirror back into mirror
-	 */
-	CONV_MERGE = 1,
-
 	/* Split:
-	 *   For a snapshot, split it apart into COW and origin for future recombination
-	 *   For a cached LV, split it apart into the cached LV and its pool
 	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
 	 *     future changes to the main mirror to allow future recombination.
 	 */
-	CONV_SPLIT = 2,
-	CONV_SPLIT_SNAPSHOT = 3,
-	CONV_SPLIT_CACHE = 4,
-	CONV_SPLIT_MIRRORS = 5,
-
-	/* Start to cache an LV */
-	CONV_CACHE = 6,
-
-	/* Destroy the cache attached to a cached LV */
-	CONV_UNCACHE = 7,
-
-	/* Reconstruct a snapshot from its origin and COW */
-	CONV_SNAPSHOT = 8,
-
-	/* Convert normal LV into one in a thin pool */
-	CONV_THIN = 11,
+	CONV_SPLIT = 1,
+	CONV_SPLIT_MIRRORS = 2,
 
 	/* Every other segment type or mirror log conversion we haven't separated out */
-	CONV_OTHER = 12,
+	CONV_OTHER = 3,
 } conversion_type_t;
 
 struct lvconvert_params {
@@ -170,165 +145,6 @@ static void _set_conv_type(struct lvconvert_params *lp, int conv_type)
 	lp->conv_type = conv_type;
 }
 
-static int _lvconvert_validate_names(struct lvconvert_params *lp)
-{
-	unsigned i, j;
-	const char *names[] = {
-		(lp->lv_name == lp->pool_data_name) ? NULL : lp->lv_name, "converted",
-		lp->pool_data_name, "pool",
-		lp->pool_metadata_name, "pool metadata",
-		lp->origin_name, "origin",
-	};
-
-	for (i = 0; i < DM_ARRAY_SIZE(names); i += 2)
-		if (names[i])
-			for (j = i + 2; j < DM_ARRAY_SIZE(names); j += 2)
-				if (names[j] && !strcmp(names[i], names[j])) {
-					log_error("Can't use same name %s for %s and %s volume.",
-						  names[i], names[i + 1], names[j + 1]);
-					return 0;
-				}
-
-	return 1;
-}
-
-static int _lvconvert_name_params(struct lvconvert_params *lp,
-				  struct cmd_context *cmd,
-				  int *pargc, char ***pargv)
-{
-	if (lp->merge) {
-		/* FIXME Multiple arguments that mix snap and mirror? */
-		if (!*pargc) {
-			log_error("Please specify a logical volume path.");
-			return 0;
-		}
-
-		if (!strstr((*pargv)[0], "_rimage_")) {	/* Snapshot */
-			lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
-			lp->merge_snapshot = 1;
-
-			return 1;
-		}
-
-		/* Mirror */
-		lp->merge_mirror = 1;
-	}
-
-	if (!*pargc) {
-		if (lp->cache) {
-			log_error("Logical volume name for caching is missing.");
-			return 0;
-		}
-		if (lp->thin) {
-			log_error("Please specify a logical volume to act as "
-				  "the external origin.");
-			return 0;
-		}
-		if (lp->snapshot) {
-			log_error("Please specify a logical volume to act as "
-				  "the snapshot exception store.");
-			return 0;
-		}
-		if (lp->split) {
-			log_error("Logical volume for split is missing.");
-			return 0;
-		}
-		if (lp->splitcache) {
-			log_error("Cache logical volume for split is missing.");
-			return 0;
-		}
-		if (lp->uncache) {
-			log_error("Cache logical volume for uncache is missing.");
-			return 0;
-		}
-		if (!lp->lv_name_full) {
-			log_error("Please provide logical volume path.");
-			return 0;
-		}
-	} else if (!lp->lv_name_full) {
-		lp->lv_name_full = (*pargv)[0];
-		(*pargv)++, (*pargc)--;
-	}
-
-	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_name))
-		return_0;
-
-	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->pool_data_name))
-		return_0;
-
-	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
-		return_0;
-
-	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
-		return_0;
-
-	if (!lp->vg_name && !strchr(lp->lv_name_full, '/')) {
-		/* Check for $LVM_VG_NAME */
-		if (!(lp->vg_name = extract_vgname(cmd, NULL))) {
-			log_error("Please specify a logical volume path.");
-			return 0;
-		}
-	}
-
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name_full))
-		return_0;
-
-	lp->lv_name = lp->lv_name_full;
-
-	if (!validate_name(lp->vg_name)) {
-		log_error("Please provide a valid volume group name");
-		return 0;
-	}
-
-	/*
-	 * FIXME: avoid this distinct validation out of scope of _convert_*()
-	 *
- 	 *        We should not rely on namespace here any more!
- 	 *        It is the duty of lvcreate/lvrename to avoid reserved names.
- 	 */
-	if (!lp->merge_mirror &&
-	    !lp->keep_mimages &&
-	    !strstr(lp->lv_name, "_tdata") &&
-	    !strstr(lp->lv_name, "_tmeta") &&
-	    !strstr(lp->lv_name, "_cdata") &&
-	    !strstr(lp->lv_name, "_cmeta") &&
-	    !strstr(lp->lv_name, "_corig") &&
-	    !apply_lvname_restrictions(lp->lv_name))
-		return_0;
-
-	if (*pargc) {
-		if (lp->snapshot) {
-			log_error("Too many arguments provided for snapshots.");
-			return 0;
-		}
-		if (lp->splitsnapshot) {
-			log_error("Too many arguments provided with --splitsnapshot.");
-			return 0;
-		}
-		if (lp->splitcache) {
-			log_error("Too many arguments provided with --splitcache.");
-			return 0;
-		}
-		if (lp->split) {
-			log_error("Too many arguments provided with --split.");
-			return 0;
-		}
-		if (lp->uncache) {
-			log_error("Too many arguments provided with --uncache.");
-			return 0;
-		}
-		if (lp->pool_data_name && lp->pool_metadata_name) {
-			log_error("Too many arguments provided for pool.");
-			return 0;
-		}
-	}
-
-	if (!_lvconvert_validate_names(lp))
-		return_0;
-
-	return 1;
-}
-
 /* -s/--snapshot and --type snapshot are synonyms */
 static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str)
 {
@@ -379,113 +195,9 @@ static int _read_conversion_type(struct cmd_context *cmd,
 	return 0;
 }
 
-static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
-			     struct lvconvert_params *lp)
-{
-	int cachepool = 0;
-	int thinpool = 0;
-	struct segment_type *segtype;
-
-	if ((lp->pool_data_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
-		if (lp->type_str[0] &&
-		    strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) &&
-		    strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL)) {
-			log_error("--cachepool argument is only valid with "
-				  "the cache or cache-pool segment type.");
-			return 0;
-		}
-		cachepool = 1;
-		lp->type_str = SEG_TYPE_NAME_CACHE_POOL;
-	} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL))
-		cachepool = 1;
-	else if ((lp->pool_data_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
-		if (lp->type_str[0] &&
-		    strcmp(lp->type_str, SEG_TYPE_NAME_THIN) &&
-		    strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL)) {
-			log_error("--thinpool argument is only valid with "
-				  "the thin or thin-pool segment type.");
-			return 0;
-		}
-		thinpool = 1;
-		lp->type_str = SEG_TYPE_NAME_THIN_POOL;
-	} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL))
-		thinpool = 1;
-
-	if (lp->cache && !cachepool) {
-		log_error("--cache requires --cachepool.");
-		return 0;
-	}
-
-	if ((lp->cache || cachepool) &&
-	    !get_cache_params(cmd, &lp->cache_mode, &lp->policy_name, &lp->policy_settings)) {
-		log_error("Failed to parse cache policy and/or settings.");
-		return 0;
-	}
-
-	if (thinpool) {
-		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-		lp->origin_name = arg_str_value(cmd, originname_ARG, NULL);
-	} else {
-		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
-					 discards_ARG, originname_ARG, thinpool_ARG,
-					 -1))
-			return_0;
-		if (lp->thin) {
-			log_error("--thin requires --thinpool.");
-			return 0;
-		}
-	}
-
-	if (thinpool || cachepool) {
-		if (arg_from_list_is_set(cmd, "is invalid with pools",
-					 merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
-					 splitmirrors_ARG, splitsnapshot_ARG, -1))
-			return_0;
-
-		if (!(segtype = get_segtype_from_string(cmd, lp->type_str)))
-			return_0;
-
-		if (!get_pool_params(cmd, segtype, &lp->passed_args,
-				     &lp->pool_metadata_size,
-				     &lp->poolmetadataspare,
-				     &lp->chunk_size, &lp->discards,
-				     &lp->zero))
-			return_0;
-
-		if ((lp->pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL)) &&
-		    arg_from_list_is_set(cmd, "is invalid with --poolmetadata",
-					 stripesize_ARG, stripes_long_ARG,
-					 readahead_ARG, -1))
-			return_0;
-
-		if (!lp->pool_data_name) {
-			if (!*pargc) {
-				log_error("Please specify the pool data LV.");
-				return 0;
-			}
-			lp->pool_data_name = (*pargv)[0];
-			(*pargv)++, (*pargc)--;
-		}
-
-		if (!lp->thin && !lp->cache)
-			lp->lv_name_full = lp->pool_data_name;
-
-		/* Hmm _read_activation_params */
-		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
-						cmd->default_settings.read_ahead);
-
-	} else if (arg_from_list_is_set(cmd, "is valid only with pools",
-					poolmetadatasize_ARG, poolmetadataspare_ARG,
-					zero_ARG,
-					-1))
-		return_0;
-
-	return 1;
-}
-
-static int _read_params(struct cmd_context *cmd, int argc, char **argv,
-			struct lvconvert_params *lp)
+static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
+	const char *vg_name = NULL;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
@@ -506,16 +218,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->mirrorlog = 1;
 	}
 
-	if (arg_is_set(cmd, merge_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --merge",
-					    merge_ARG,
-					    background_ARG, interval_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->merge = 1;
-		_set_conv_type(lp, CONV_MERGE);
-	} else if (arg_is_set(cmd, split_ARG)) {
+	if (arg_is_set(cmd, split_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
 					    split_ARG,
 					    name_ARG,
@@ -524,79 +227,17 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return_0;
 		lp->split = 1;
 		_set_conv_type(lp, CONV_SPLIT);
-	} else if (arg_is_set(cmd, splitcache_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --splitcache",
-					    splitcache_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->splitcache = 1;
-		_set_conv_type(lp, CONV_SPLIT_CACHE);
-	} else if (arg_is_set(cmd, splitsnapshot_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --splitsnapshot",
-					    splitsnapshot_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->splitsnapshot = 1;
-		_set_conv_type(lp, CONV_SPLIT_SNAPSHOT);
-	} else if (arg_is_set(cmd, uncache_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --uncache",
-					    uncache_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->uncache = 1;
-		_set_conv_type(lp, CONV_UNCACHE);
-	}
-
-	if (arg_is_set(cmd, cache_ARG)) {
-		lp->cache = 1;
-		_set_conv_type(lp, CONV_CACHE);
-	}
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE))
-		lp->cache = 1;
-	else if (lp->cache) {
-		if (lp->type_str[0]) {
-			log_error("--cache is incompatible with --type %s", lp->type_str);
-			return 0;
-		}
-		lp->type_str = SEG_TYPE_NAME_CACHE;
-	}
-
-	if (arg_is_set(cmd, thin_ARG)) {
-		lp->thin = 1;
-		_set_conv_type(lp, CONV_THIN);
-	}
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN))
-		lp->thin = 1;
-	else if (lp->thin) {
-		if (lp->type_str[0]) {
-			log_error("--thin is incompatible with --type %s", lp->type_str);
-			return 0;
-		}
-		lp->type_str = SEG_TYPE_NAME_THIN;
 	}
-
+	
 	if (arg_is_set(cmd, trackchanges_ARG))
 		lp->track_changes = 1;
 
-	if (!_read_pool_params(cmd, &argc, &argv, lp))
-		return_0;
-
-	if (_snapshot_type_requested(cmd, lp->type_str)) {
-		if (lp->merge) {
-			log_error("--snapshot and --merge are mutually exclusive.");
-			return 0;
+	if (lp->split) {
+		if ((lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL))) {
+			if (!validate_restricted_lvname_param(cmd, &vg_name, &lp->lv_split_name))
+				return_0;
 		}
-		lp->snapshot = 1;
-		_set_conv_type(lp, CONV_SNAPSHOT);
-	}
 
-	if (lp->split) {
-		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 
 	/*
 	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
@@ -616,7 +257,11 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return 0;
 		}
 
-		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
+		if ((lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL))) {
+			if (!validate_restricted_lvname_param(cmd, &vg_name, &lp->lv_split_name))
+				return_0;
+		}
+
 		lp->keep_mimages = 1;
 		_set_conv_type(lp, CONV_SPLIT_MIRRORS);
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
@@ -633,22 +278,11 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	/* If no other case was identified, then use of --stripes means --type striped */
-	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str && !lp->merge && !lp->splitsnapshot &&
-	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
-	    !lp->mirrorlog && !lp->corelog &&
+	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str &&
+	    !lp->split && !lp->mirrorlog && !lp->corelog &&
 	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
 		lp->type_str = SEG_TYPE_NAME_STRIPED;
 
-	if ((_snapshot_type_requested(cmd, lp->type_str) || lp->merge) &&
-	    (lp->mirrorlog || _mirror_or_raid_type_requested(cmd, lp->type_str) ||
-	     arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(lp->type_str) ||
-	     _striped_type_requested(lp->type_str))) {
-		log_error("--snapshot/--type snapshot or --merge argument "
-			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped/--type linear, "
-			  "--mirrorlog, --repair or --thinpool.");
-		return 0;
-	}
-
 	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
 	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(lp->type_str) ||
 	      _raid0_type_requested(lp->type_str) || arg_is_set(cmd, thinpool_ARG))) {
@@ -667,72 +301,22 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 	/* We should have caught all these cases already. */
-	if (lp->merge + lp->splitsnapshot + lp->splitcache + lp->split + lp->uncache +
-	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot > 1) {
+	if (lp->split + lp->keep_mimages > 1) {
 		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
 		return 0;
 	}
 
-
 	/*
 	 * Final checking of each case:
-	 *   lp->merge
-	 *   lp->splitsnapshot
-	 *   lp->splitcache
 	 *   lp->split
-	 *   lp->uncache
-	 *   lp->cache
-	 *   lp->thin
 	 *   lp->keep_mimages
-	 *   lp->snapshot
 	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
 	switch(lp->conv_type) {
-	case CONV_MERGE:	/* Snapshot or mirror merge */
 	case CONV_SPLIT:
-	case CONV_SPLIT_CACHE:
 	case CONV_SPLIT_MIRRORS:
-	case CONV_SPLIT_SNAPSHOT:	/* Destroy snapshot retaining cow as separate LV */
-	case CONV_CACHE:
-	case CONV_UNCACHE:
-	case CONV_THIN:
                 break;
-	case CONV_SNAPSHOT:	/* Snapshot creation from pre-existing cow */
-		if (!argc) {
-			log_error("Please provide logical volume path for snapshot origin.");
-			return 0;
-		}
-		lp->origin_name = argv[0];
-		argv++, argc--;
-
-		if (arg_is_set(cmd, regionsize_ARG)) {
-			log_error("--regionsize is only available with mirrors");
-			return 0;
-		}
-
-		if (arg_is_set(cmd, stripesize_ARG) || arg_is_set(cmd, stripes_long_ARG)) {
-			log_error("--stripes and --stripesize are only available with striped mirrors");
-			return 0;
-		}
-
-		if (arg_is_set(cmd, chunksize_ARG) &&
-		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
-
-		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    !is_power_of_2(lp->chunk_size)) {
-			log_error("Chunk size must be a power of 2 in the "
-				  "range 4K to 512K");
-			return 0;
-		}
-		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
-
-		lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
-		break;
 
 	case CONV_OTHER:
 		if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
@@ -803,15 +387,10 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
-	if (!_lvconvert_name_params(lp, cmd, &argc, &argv))
-		return_0;
-
-	lp->pv_count = argc;
-	lp->pvs = argv;
-
 	return 1;
 }
 
+
 static struct poll_functions _lvconvert_mirror_fns = {
 	.poll_progress = poll_mirror_progress,
 	.finish_copy = lvconvert_mirror_finish,
@@ -1256,22 +835,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	}
 
 	/*
-	 * Collapsing a stack of mirrors:
-	 *
-	 * If called with no argument, try collapsing the resync layers
-	 */
-	if (!lp->mirrors_supplied && !lp->mirrorlog &&
-	    !lp->corelog && !arg_is_set(cmd, regionsize_ARG) &&
-	    !lp->keep_mimages) {
-		*new_mimage_count = *old_mimage_count;
-		*new_log_count = *old_log_count;
-
-		if (find_temporary_mirror(lv) || lv_is_converting(lv))
-			lp->need_polling = 1;
-		return 1;
-	}
-
-	/*
 	 * Adjusting mimage count?
 	 */
 	if (!lp->mirrors_supplied && !lp->keep_mimages)
@@ -4431,7 +3994,7 @@ static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logic
 static int _convert_cache_volume_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 					  struct lvconvert_params *lp)
 {
-	return _lvconvert_snapshot(cmd, lv, lp);
+	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
 }
 
 /*
@@ -4969,79 +4532,21 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (segtype_is_raid(lp->segtype))
 		return _convert_mirror_raid(cmd, lv, lp);
 
-	/*
-	 * FIXME: this is here to preserve old behavior, but an
-	 * explicit option should be added to enable this case,
-	 * rather than making it the result of an ambiguous
-	 * "lvconvert vg/lv" command.
-	 * Add 'lvconvert --poll-mirror vg/lv' for this case.
-	 *
-	 * Old behavior was described as:
-	 *   "Collapsing a stack of mirrors.
-	 *    If called with no argument, try collapsing the resync layers"
-	 */
-	log_debug("Checking if LV %s is converting.", display_lvname(lv));
-	if (lv_is_converting(lv)) {
-		lp->need_polling = 1;
-		return 1;
-	}
-
-	log_error("Operation not permitted on mirror LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a mirror LV are:\n"
-		  "  --mirrors\n"
-		  "  --splitmirrors\n"
-		  "  --mirrorlog\n"
-		  "  --repair\n"
-		  "  --type linear\n"
-		  "  --type raid*\n");
-
+	log_error("Unknown operation on mirror LV %s.", display_lvname(lv));
 	return 0;
 }
 
 static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			 struct lvconvert_params *lp)
 {
-	/* Permitted convert options on visible or hidden RaidLVs */
-	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
-	const char *permitted_options = lv_is_visible(lv) ?
-		"  --mirrors\n"
-		"  --splitmirrors\n"
-		"  --merge\n"
-		"  --repair\n"
-		"  --replace\n"
-		"  --type snapshot\n"
-		"  --type thin\n"
-		"  --type cache\n"
-		"  --type thin-pool\n"
-		"  --type cache-pool\n"
-		"  --type raid*\n"
-		"  --type mirror\n"
-		"  --type striped\n"
-		"  --type linear\n"
-		:
-		"  --mirrors\n"
-		"  --splitmirrors\n"
-		"  --repair\n"
-		"  --replace\n"
-		"  --type raid*\n"
-		"  --type mirror\n"
-		"  --type striped\n"
-		"  --type linear\n";
-
-	/* Applicable to any hidden _or_ visible LVs. */
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_raid_splitmirrors(cmd, lv, lp);
 
-	if (segtype_is_raid(lp->segtype)) {
-		/* Only --type allowed on hidden RaidLV. */
-		if (!lv_is_visible(lv) && !arg_is_set(cmd, type_ARG))
-			goto out;
-
+	if (segtype_is_raid(lp->segtype))
 		return _convert_raid_raid(cmd, lv, lp);
-	}
 
 	if (segtype_is_mirror(lp->segtype))
 		return _convert_raid_mirror(cmd, lv, lp);
@@ -5052,33 +4557,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (_linear_type_requested(lp->type_str))
 		return _convert_raid_linear(cmd, lv, lp);
 
-	/* Applicable to visible LVs only. */
-	if (lv_is_visible(lv)) {
-		if (lp->merge)
-			return _convert_raid_merge(cmd, lv, lp);
-
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
-			return _convert_raid_snapshot(cmd, lv, lp);
-
-		if (lp->thin)
-			return _convert_raid_thin(cmd, lv, lp);
-
-		if (lp->cache)
-			return _convert_raid_cache(cmd, lv, lp);
-
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
-		    arg_is_set(cmd, thinpool_ARG))
-			return _convert_raid_thin_pool(cmd, lv, lp);
-
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL)  ||
-		    arg_is_set(cmd, cachepool_ARG))
-			return _convert_raid_cache_pool(cmd, lv, lp);
-	}
-
-out:
-	log_error("Operation not permitted on raid LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a raid LV are:\n%s", permitted_options);
-
+	log_error("Unknown operation on raid LV %s.", display_lvname(lv));
 	return 0;
 }
 
@@ -5087,27 +4566,6 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 
-	/* FIXME: add --merge-mirror to make this distinct from --merge-snapshot. */
-	if (lp->merge)
-		return _convert_striped_merge(cmd, lv, lp);
-
-	if (lp->snapshot || !strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT))
-		return _convert_striped_snapshot(cmd, lv, lp);
-
-	if (lp->thin)
-		return _convert_striped_thin(cmd, lv, lp);
-
-	if (lp->cache)
-		return _convert_striped_cache(cmd, lv, lp);
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
-	    arg_is_set(cmd, thinpool_ARG))
-		return _convert_striped_thin_pool(cmd, lv, lp);
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) ||
-	    arg_is_set(cmd, cachepool_ARG))
-		return _convert_striped_cache_pool(cmd, lv, lp);
-
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
 		return _convert_striped_mirror(cmd, lv, lp);
 
@@ -5122,19 +4580,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_RAID1))
 		return _convert_striped_raid(cmd, lv, lp);
 
-	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
-
-	log_error("Operation not permitted on striped or linear LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a striped or linear LV are:\n"
-		  "  --merge\n"
-		  "  --type snapshot\n"
-		  "  --type thin\n"
-		  "  --type cache\n"
-		  "  --type thin-pool\n"
-		  "  --type cache-pool\n"
-		  "  --type mirror\n"
-		  "  --type raid*\n");
-
+	log_error("Unknown operation on striped or linear LV %s.", display_lvname(lv));
 	return 0;
 }
 
@@ -5163,39 +4609,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 	int ret = 0;
 
-	/*
-	 * Check some conditions that can never be processed.
-	 */
-
-	if (lv_is_locked(lv)) {
-		log_error("Cannot convert locked LV %s.", display_lvname(lv));
-		goto out;
-	}
-
-	if (lv_is_pvmove(lv)) {
-		log_error("Cannot convert pvmove LV %s.", display_lvname(lv));
-		goto out;
-	}
-
-	if (!lv_is_visible(lv)) {
-		/*
-		 * FIXME: there are some exceptions to the rule of only
-		 * operating on visible LVs.  These should be fixed by running
-		 * the command on the visible LV with an option indicating
-		 * which sub LV is intended rather than naming the !visible LV.
-		 */
-		if (!lv_is_cache_pool_metadata(lv) &&
-		    !lv_is_cache_pool_data(lv) &&
-		    !lv_is_thin_pool_metadata(lv) &&
-		    !lv_is_thin_pool_data(lv) &&
-		    !lv_is_used_cache_pool(lv) &&
-		    !lv_is_mirrored(lv) &&
-		    !lv_is_raid(lv)) {
-			log_error("Cannot convert internal LV %s.", display_lvname(lv));
-			goto out;
-		}
-	}
-
 	/* Set up segtype either from type_str or else to match the existing one. */
 	if (!*lp->type_str)
 		lp->segtype = seg->segtype;
@@ -5232,45 +4645,16 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 				lp->stripes = 0;
 	}
 
-	if (lp->snapshot)
-		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
+	if (lv_is_cache(lv))
+		lv = seg_lv(first_seg(lv), 0);
 
-	/*
-	 * Each LV type that can be converted.
-	 * (The existing type of the LV, not a requested type.)
-	 */
-	if (lv_is_cow(lv)) {
-		ret = _convert_cow_snapshot(cmd, lv, lp);
+	if (lv_is_mirror(lv)) {
+		ret = _convert_mirror(cmd, lv, lp);
 		goto out;
 	}
 
-	if (lv_is_thin_volume(lv)) {
-		ret = _convert_thin_volume(cmd, lv, lp);
-		goto out;
-	}
-
-	if (lv_is_thin_pool(lv)) {
-		ret = _convert_thin_pool(cmd, lv, lp);
-		goto out;
-	}
-
-	if (lv_is_cache(lv)) {
-		ret = _convert_cache_volume(cmd, lv, lp);
-		goto out;
-	}
-
-	if (lv_is_cache_pool(lv)) {
-		ret = _convert_cache_pool(cmd, lv, lp);
-		goto out;
-	}
-
-	if (lv_is_mirror(lv)) {
-		ret = _convert_mirror(cmd, lv, lp);
-		goto out;
-	}
-
-	if (lv_is_raid(lv)) {
-		ret = _convert_raid(cmd, lv, lp);
+	if (lv_is_raid(lv)) {
+		ret = _convert_raid(cmd, lv, lp);
 		goto out;
 	}
 
@@ -5315,149 +4699,6 @@ static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_cont
 	return idl;
 }
 
-static int _lvconvert_and_add_to_poll_list(struct cmd_context *cmd,
-					    struct lvconvert_params *lp,
-					    struct logical_volume *lv)
-{
-	int ret;
-	struct lvinfo info;
-	struct convert_poll_id_list *idl;
-
-	/* _lvconvert() call may alter the reference in lp->lv_to_poll */
-	if ((ret = _lvconvert(cmd, lv, lp)) != ECMD_PROCESSED)
-		stack;
-	else if (lp->need_polling) {
-		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
-			log_print_unless_silent("Conversion starts after activation.");
-		else {
-			if (!(idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll)))
-				return_ECMD_FAILED;
-			dm_list_add(&lp->idls, &idl->list);
-		}
-	}
-
-	return ret;
-}
-
-static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
-			     struct processing_handle *handle)
-{
-	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
-	struct volume_group *vg = lv->vg;
-
-	if (test_mode() && is_lockd_type(vg->lock_type)) {
-		log_error("Test mode is not yet supported with lock type %s.",
-			  vg->lock_type);
-		return ECMD_FAILED;
-	}
-
-	/*
-	 * lp->pvh holds the list of PVs available for allocation or removal
-	 */
-	if (lp->pv_count) {
-		if (!(lp->pvh = create_pv_list(cmd->mem, vg, lp->pv_count, lp->pvs, 0)))
-			return_ECMD_FAILED;
-	} else
-		lp->pvh = &vg->pvs;
-
-	lp->lv_to_poll = lv;
-
-	return _lvconvert_and_add_to_poll_list(cmd, lp, lv);
-}
-
-static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
-				   struct processing_handle *handle)
-{
-	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
-
-	lp->lv_to_poll = lv;
-
-	return _lvconvert_and_add_to_poll_list(cmd, lp, lv);
-}
-
-int lvconvert(struct cmd_context * cmd, int argc, char **argv)
-{
-	int poll_ret, ret;
-	struct convert_poll_id_list *idl;
-	struct lvconvert_params lp = {
-		.conv_type = CONV_OTHER,
-		.target_attr = ~0,
-		.idls = DM_LIST_HEAD_INIT(lp.idls),
-	};
-	struct processing_handle *handle = init_processing_handle(cmd, NULL);
-
-	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
-
-	if (!handle) {
-		log_error("Failed to initialize processing handle.");
-		return ECMD_FAILED;
-	}
-
-	handle->custom_handle = &lp;
-
-	if (!_read_params(cmd, argc, argv, &lp)) {
-		ret = EINVALID_CMD_LINE;
-		goto_out;
-	}
-
-	if (lp.merge) {
-		ret = process_each_lv(cmd, argc, argv, NULL, NULL,
-				      READ_FOR_UPDATE, handle, NULL, &_lvconvert_merge_single);
-	} else {
-		int saved_ignore_suspended_devices = ignore_suspended_devices();
-
-		if (lp.uncache) {
-			init_ignore_suspended_devices(1);
-			cmd->handles_missing_pvs = 1;
-		}
-
-		ret = process_each_lv(cmd, 0, NULL, lp.vg_name, lp.lv_name,
-				      READ_FOR_UPDATE, handle, NULL, &_lvconvert_single);
-
-		init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	}
-
-	dm_list_iterate_items(idl, &lp.idls) {
-		poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
-						 lp.wait_completion ? 0 : 1U,
-						 idl->is_merging_origin,
-						 idl->is_merging_origin_thin);
-		if (poll_ret > ret)
-			ret = poll_ret;
-	}
-
-out:
-	if (lp.policy_settings)
-		dm_config_destroy(lp.policy_settings);
-
-	destroy_processing_handle(cmd, handle);
-
-	return ret;
-}
-
-/*
- * Below is code that has transitioned to using command defs.
- * ----------------------------------------------------------
- *
- * This code does not use read_params (or any other param reading
- * functions associated with it), or the lp struct.  Those have
- * been primary vehicles for entangling all the lvconvert operations,
- * so avoiding them is important for untangling.  They were also
- * heavily used for trying to figure out what the lvconvert operation
- * was meant to be doing, and that is no longer needed since the
- * command def provides it.
- *
- * All input data is already available from cmd->arg_values and
- * cmd->position_argv (the --option args in the former, the position
- * args in the later.)  There is no need to copy these values into
- * another redundant struct of input values which just obfuscates.
- *
- * The new lvconvert_result struct, passed via custom_handle, is
- * used for *returning* data from processing, not for passing data
- * into processing.
- */
-
-
 /*
  * Data/results accumulated during processing.
  */
@@ -6399,9 +5640,274 @@ int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv
 			       NULL, NULL, &_lvconvert_split_cachepool_single);
 }
 
+static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     struct processing_handle *handle)
+{
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
+	struct dm_list *use_pvh;
+	struct convert_poll_id_list *idl;
+	struct lvinfo info;
+	int ret;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+		lp->pv_count = cmd->position_argc - 1;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	lp->pvh = use_pvh;
+
+	lp->lv_to_poll = lv;
+
+	ret = _lvconvert(cmd, lv, lp);
+
+	if (ret != ECMD_PROCESSED)
+		return_ECMD_FAILED;
+
+	if (lp->need_polling) {
+		/* _lvconvert() call may alter the reference in lp->lv_to_poll */
+		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
+			log_print_unless_silent("Conversion starts after activation.");
+		else {
+			if (!(idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll)))
+				return_ECMD_FAILED;
+			dm_list_add(&lp->idls, &idl->list);
+		}
+	}
+
+	return ECMD_PROCESSED;
+}
+
+static int _lvconvert_raid_types_check(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle,
+			int lv_is_named_arg)
+{
+	int lvt_enum = get_lvt_enum(lv);
+	struct lv_types *lvtype = get_lv_type(lvt_enum);
+
+	if (!lv_is_visible(lv)) {
+		if (!lv_is_cache_pool_metadata(lv) &&
+		    !lv_is_cache_pool_data(lv) &&
+		    !lv_is_thin_pool_metadata(lv) &&
+		    !lv_is_thin_pool_data(lv) &&
+		    !lv_is_used_cache_pool(lv) &&
+		    !lv_is_mirrored(lv) &&
+		    !lv_is_raid(lv))
+			goto fail_hidden;
+	}
+
+	/*
+	 * FIXME: this validation could be done by command defs.
+	 *
+	 * Outside the standard linear/striped/mirror/raid LV
+	 * types, cache is the only special LV type that is handled
+	 * (the command is redirected to origin).
+	 */
+	switch (lvt_enum) {
+	case thin_LVT:
+	case thinpool_LVT:
+	case cachepool_LVT:
+	case snapshot_LVT:
+		log_error("Operation not permitted (%s %d) on LV %s type %s.",
+			  cmd->command->command_line_id, cmd->command->command_line_enum,
+			  display_lvname(lv), lvtype ? lvtype->name : "unknown");
+		return 0;
+	}
+
+	return 1;
+
+ fail_hidden:
+	log_error("Operation not permitted (%s %d) on hidden LV %s.",
+		  cmd->command->command_line_id, cmd->command->command_line_enum,
+		  display_lvname(lv));
+	return 0;
+}
+
+int lvconvert_raid_types_cmd(struct cmd_context * cmd, int argc, char **argv)
+{
+	int poll_ret, ret;
+	int saved_ignore_suspended_devices;
+	struct processing_handle *handle;
+	struct convert_poll_id_list *idl;
+	struct lvconvert_params lp = {
+		.conv_type = CONV_OTHER,
+		.target_attr = ~0,
+		.idls = DM_LIST_HEAD_INIT(lp.idls),
+	};
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lp;
+
+	if (!_read_params(cmd, &lp)) {
+		ret = EINVALID_CMD_LINE;
+		goto_out;
+	}
+
+	saved_ignore_suspended_devices = ignore_suspended_devices();
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, &_lvconvert_raid_types_check, &_lvconvert_raid_types_single);
+
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+
+	dm_list_iterate_items(idl, &lp.idls) {
+		poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						 lp.wait_completion ? 0 : 1U,
+						 idl->is_merging_origin,
+						 idl->is_merging_origin_thin);
+		if (poll_ret > ret)
+			ret = poll_ret;
+	}
+
+out:
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
+/*
+ * change mirror log
+ */
+
+static int _lvconvert_visible_check(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle,
+			int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		log_error("Operation not permitted (%s %d) on hidden LV %s.",
+			  cmd->command->command_line_id, cmd->command->command_line_enum,
+			  display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _lvconvert_change_mirrorlog_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     struct processing_handle *handle)
+{
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
+	struct dm_list *use_pvh;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+		lp->pv_count = cmd->position_argc - 1;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	lp->pvh = use_pvh;
+
+	/* FIXME: extract the mirrorlog functionality out of _lvconvert()? */
+	return _lvconvert(cmd, lv, lp);
+}
+
+int lvconvert_change_mirrorlog_cmd(struct cmd_context * cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_params lp = {
+		.conv_type = CONV_OTHER,
+		.target_attr = ~0,
+		.idls = DM_LIST_HEAD_INIT(lp.idls),
+	};
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lp;
+
+	/* FIXME: extract the relevant bits of read_params and put here. */
+	if (!_read_params(cmd, &lp)) {
+		ret = EINVALID_CMD_LINE;
+		goto_out;
+	}
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, &_lvconvert_visible_check, &_lvconvert_change_mirrorlog_single);
+
+out:
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
+/*
+ * split mirror images
+ */
+
+static int _lvconvert_split_mirror_images_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     struct processing_handle *handle)
+{
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
+	struct dm_list *use_pvh;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+		lp->pv_count = cmd->position_argc - 1;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	lp->pvh = use_pvh;
+
+	/* FIXME: extract the split functionality out of _lvconvert()? */
+	return _lvconvert(cmd, lv, lp);
+}
+
+int lvconvert_split_mirror_images_cmd(struct cmd_context * cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_params lp = {
+		.conv_type = CONV_OTHER,
+		.target_attr = ~0,
+		.idls = DM_LIST_HEAD_INIT(lp.idls),
+	};
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lp;
+
+	/* FIXME: extract the relevant bits of read_params and put here. */
+	if (!_read_params(cmd, &lp)) {
+		ret = EINVALID_CMD_LINE;
+		goto_out;
+	}
+
+	/* FIXME: are there any hidden LVs that should be disallowed? */
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_split_mirror_images_single);
+
+out:
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
+/*
+ * merge mirror images
+ *
+ * Called from both lvconvert --mergemirrors and lvconvert --merge.
+ */
+
 static int _lvconvert_merge_mirror_images_single(struct cmd_context *cmd,
-					  struct logical_volume *lv,
-					  struct processing_handle *handle)
+                                          struct logical_volume *lv,
+                                          struct processing_handle *handle)
 {
 	if (!lv_raid_merge(lv))
 		return ECMD_FAILED;
@@ -6411,10 +5917,11 @@ static int _lvconvert_merge_mirror_images_single(struct cmd_context *cmd,
 
 int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	/* arg can be a VG name, which is the standard option usage */
 	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
 
 	return process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_merge_mirror_images_single);
+			       NULL, &_lvconvert_visible_check, &_lvconvert_merge_mirror_images_single);
 }
 
 static int _lvconvert_merge_generic_single(struct cmd_context *cmd,
@@ -6471,3 +5978,15 @@ int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
+/*
+ * All lvconvert command defs have their own function,
+ * so the generic function name is unused.
+ */
+
+int lvconvert(struct cmd_context *cmd, int argc, char **argv)
+{
+	log_error(INTERNAL_ERROR "Missing function for command definition %s.",
+		  cmd->command->command_line_id);
+	return ECMD_FAILED;
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c100311..4f1718b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -147,20 +147,17 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 
+	/* lvconvert raid-related type conversions */
+	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_cmd },
+
 	/* lvconvert utilities for raid/mirror */
-	{ lvconvert_merge_mirror_images_CMD,		lvconvert_merge_mirror_images_cmd },
-#if 0
-	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_cmd },
+	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_cmd},
 	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_cmd },
-#endif
+	{ lvconvert_merge_mirror_images_CMD,		lvconvert_merge_mirror_images_cmd },
 
 	/* redirected to merge_snapshot/merge_thin/merge_mirrors */
 	{ lvconvert_merge_CMD, lvconvert_merge_cmd },
 
-#if 0
-	/* all raid-related type conversions */
-	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_cmd },
-#endif
 };
 
 
diff --git a/tools/tools.h b/tools/tools.h
index 4bba46c..89ee8ad 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -271,7 +271,10 @@ int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **a
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_raid_types_cmd(struct cmd_context * cmd, int argc, char **argv);
+int lvconvert_split_mirror_images_cmd(struct cmd_context * cmd, int argc, char **argv);
 int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_change_mirrorlog_cmd(struct cmd_context * cmd, int argc, char **argv);
 
 int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
 


