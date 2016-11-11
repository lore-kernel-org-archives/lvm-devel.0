From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 11 Nov 2016 00:32:29 +0000 (UTC)
Subject: master - lvconvert: Introduce enum to separate cases.
Message-ID: <20161111003229.DB5A760509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8b3b0bc9a5758ab3cacf0de79ee48bb851b07a6
Commit:        f8b3b0bc9a5758ab3cacf0de79ee48bb851b07a6
Parent:        b11f4f93d70d307b997290713607c0742c3ea29e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 11 00:27:01 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 11 00:27:01 2016 +0000

lvconvert: Introduce enum to separate cases.

Start to separate out the different things that lvconvert does by using
an enum to identify 12 distinct cases.
---
 tools/lvconvert.c |  283 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 170 insertions(+), 113 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8376565..4563ade 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -37,19 +37,72 @@
  * deprecated.  (The same is still needed for --merge.)
  */
 
+typedef enum {
+	/* Merge:
+	 *   If merge_snapshot is also set:
+	 *     merge thin snapshot LV into its origin
+	 *     merge old snapshot COW into its origin
+	 *   or if merge_mirror is also set
+	 *     merge LV previously split from mirror back into mirror
+	 */
+	CONV_MERGE = 1,
+
+	/* Split:
+	 *   For a snapshot, split it apart into COW and origin for future recombination
+	 *   For a cached LV, split it apart into the cached LV and its pool
+	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
+	 *     future changes to the main mirror to allow future recombination.
+	 */
+	CONV_SPLIT = 2,
+	CONV_SPLIT_SNAPSHOT = 3,
+	CONV_SPLIT_CACHE = 4,
+	CONV_SPLIT_MIRRORS = 5,
+
+	/* Start to cache an LV */
+	CONV_CACHE = 6,
+
+	/* Destroy the cache attached to a cached LV */
+	CONV_UNCACHE = 7,
+
+	/* Reconstruct a snapshot from its origin and COW */
+	CONV_SNAPSHOT = 8,
+
+	/* Replace devices in a raid LV with alternatives */
+	CONV_REPLACE = 9,
+
+	/* Repair a mirror, raid or thin LV */
+	CONV_REPAIR = 10,
+
+	/* Convert normal LV into one in a thin pool */
+	CONV_THIN = 11,
+
+	/* Every other segment type or mirror log conversion we haven't separated out */
+	CONV_OTHER = 12,
+} conversion_type_t;
+
 struct lvconvert_params {
 	/* Exactly one of these 12 command categories is determined */
-	int merge;		/* Either merge_snapshot or merge_mirror is also set */
-	int cache;
-	int keep_mimages;	/* --splitmirrors */
-	int repair;
-	int replace;
-	int snapshot;
-	int split;
-	int splitcache;
-	int splitsnapshot;
-	int thin;
-	int uncache;
+	int merge;		/* 1 */
+	int split;		/* 2 */
+	int splitsnapshot;	/* 3 */
+	int splitcache;		/* 4 */
+	int keep_mimages;	/* 5 */	/* --splitmirrors */
+	int cache;		/* 6 */
+	int uncache;		/* 7 */
+	int snapshot;		/* 8 */
+	int replace;		/* 9 */
+	int repair;		/* 10 */
+	int thin;		/* 11 */
+	/* other */		/* 12 */
+
+	/* FIXME Eliminate all cases where more than one of the above are set then use conv_type instead */
+	conversion_type_t	conv_type;
+
+	int merge_snapshot;	/* CONV_MERGE is set */
+	int merge_mirror;	/* CONV_MERGE is set */
+
+	int track_changes;	/* CONV_SPLIT_MIRRORS is set */
+
 	int corelog;		/* Equivalent to --mirrorlog core */
 	int mirrorlog;		/* Only one of corelog and mirrorlog may be set */
 
@@ -59,11 +112,6 @@ struct lvconvert_params {
 
 	const struct segment_type *segtype;	/* Holds what segment type you will get */
 
-	int merge_snapshot;	/* merge is also set */
-	int merge_mirror;	/* merge is also set */
-
-	int track_changes;	/* keep_mimages is also set (--splitmirrors) */
-
 	int poolmetadataspare;
 	int force;
 	int yes;
@@ -124,6 +172,15 @@ struct convert_poll_id_list {
 	unsigned is_merging_origin_thin:1;
 };
 
+/* FIXME Temporary function until the enum replaces the separate variables */
+static void _set_conv_type(struct lvconvert_params *lp, int conv_type)
+{
+	if (lp->conv_type != CONV_OTHER)
+		log_error(INTERNAL_ERROR "Changing conv_type from %d to %d.", lp->conv_type, conv_type);
+
+	lp->conv_type = conv_type;
+}
+
 static int _lvconvert_validate_names(struct lvconvert_params *lp)
 {
 	unsigned i, j;
@@ -472,10 +529,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 					    -1))
 			return_0;
 		lp->merge = 1;
-	}
-
-	/* If --repair, check for incompatible args. */
-	if (arg_is_set(cmd, repair_ARG)) {
+		_set_conv_type(lp, CONV_MERGE);
+	} else if (arg_is_set(cmd, repair_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
 					    repair_ARG,
 					    alloc_ARG, usepolicies_ARG,
@@ -483,12 +538,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 					    -1))
 			return_0;
 		lp->repair = 1;
-	}
-
-	if (arg_is_set(cmd, replace_ARG))
-		lp->replace = 1;
-
-	if (arg_is_set(cmd, split_ARG)) {
+		_set_conv_type(lp, CONV_REPAIR);
+	} else if (arg_is_set(cmd, split_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
 					    split_ARG,
 					    name_ARG,
@@ -496,40 +547,40 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 					    -1))
 			return_0;
 		lp->split = 1;
-	}
-
-	if (arg_is_set(cmd, splitcache_ARG)) {
+		_set_conv_type(lp, CONV_SPLIT);
+	} else if (arg_is_set(cmd, splitcache_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --splitcache",
 					    splitcache_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;
 		lp->splitcache = 1;
-	}
-
-	if (arg_is_set(cmd, splitsnapshot_ARG)) {
+		_set_conv_type(lp, CONV_SPLIT_CACHE);
+	} else if (arg_is_set(cmd, splitsnapshot_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --splitsnapshot",
 					    splitsnapshot_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;
 		lp->splitsnapshot = 1;
-	}
-
-	if (arg_is_set(cmd, trackchanges_ARG))
-		lp->track_changes = 1;
-
-	if (arg_is_set(cmd, uncache_ARG)) {
+		_set_conv_type(lp, CONV_SPLIT_SNAPSHOT);
+	} else if (arg_is_set(cmd, uncache_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --uncache",
 					    uncache_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;
 		lp->uncache = 1;
+		_set_conv_type(lp, CONV_UNCACHE);
+	} else if (arg_is_set(cmd, replace_ARG)) {
+		lp->replace = 1;
+		_set_conv_type(lp, CONV_REPLACE);
 	}
 
-	if (arg_is_set(cmd, cache_ARG))
+	if (arg_is_set(cmd, cache_ARG)) {
 		lp->cache = 1;
+		_set_conv_type(lp, CONV_CACHE);
+	}
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE))
 		lp->cache = 1;
@@ -541,8 +592,10 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->type_str = SEG_TYPE_NAME_CACHE;
 	}
 
-	if (arg_is_set(cmd, thin_ARG))
+	if (arg_is_set(cmd, thin_ARG)) {
 		lp->thin = 1;
+		_set_conv_type(lp, CONV_THIN);
+	}
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN))
 		lp->thin = 1;
@@ -554,6 +607,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->type_str = SEG_TYPE_NAME_THIN;
 	}
 
+	if (arg_is_set(cmd, trackchanges_ARG))
+		lp->track_changes = 1;
+
 	if (!_read_pool_params(cmd, &argc, &argv, lp))
 		return_0;
 
@@ -563,6 +619,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return 0;
 		}
 		lp->snapshot = 1;
+		_set_conv_type(lp, CONV_SNAPSHOT);
 	}
 
 	if (lp->split) {
@@ -588,6 +645,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 		lp->keep_mimages = 1;
+		_set_conv_type(lp, CONV_SPLIT_MIRRORS);
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;
 	} else {
@@ -642,6 +700,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
+
 	/*
 	 * Final checking of each case:
 	 *   lp->merge
@@ -658,23 +717,18 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
-	if (lp->merge)			/* Snapshot or mirror merge */
-                ;
-	else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
-		;
-	else if (lp->splitcache)
-		;
-	else if (lp->split)
-		;
-	else if (lp->uncache)
-		;
-	else if (lp->cache)
-		;
-	else if (lp->thin)
-		;
-	else if (lp->keep_mimages)	/* --splitmirrors */
-		;
-	else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
+	switch(lp->conv_type) {
+	case CONV_MERGE:	/* Snapshot or mirror merge */
+	case CONV_SPLIT:
+	case CONV_SPLIT_CACHE:
+	case CONV_SPLIT_MIRRORS:
+	case CONV_SPLIT_SNAPSHOT:	/* Destroy snapshot retaining cow as separate LV */
+	case CONV_CACHE:
+	case CONV_UNCACHE:
+	case CONV_THIN:
+	case CONV_REPAIR:
+                break;
+	case CONV_SNAPSHOT:	/* Snapshot creation from pre-existing cow */
 		if (!argc) {
 			log_error("Please provide logical volume path for snapshot origin.");
 			return 0;
@@ -708,8 +762,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
 
 		lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
+		break;
 
-	} else if (lp->replace) { /* RAID device replacement */
+	case CONV_REPLACE:	/* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
 		lp->replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * lp->replace_pv_count);
 		if (!lp->replace_pvs)
@@ -729,72 +784,73 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (lp->repair)
-		;
-	else if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
-		   lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
-		if (arg_is_set(cmd, chunksize_ARG)) {
-			log_error("--chunksize is only available with snapshots or pools.");
-			return 0;
-		}
+		break;
 
-		if (arg_is_set(cmd, zero_ARG)) {
-			log_error("--zero is only available with snapshots or thin pools.");
-			return 0;
-		}
-
-		/*
-		 * --regionsize is only valid if converting an LV into a mirror.
-		 * Checked when we know the state of the LV being converted.
-		 */
-		if (arg_is_set(cmd, regionsize_ARG)) {
-			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
-				    SIGN_MINUS) {
-				log_error("Negative regionsize is invalid.");
+	case CONV_OTHER:
+		if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
+			   lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
+			if (arg_is_set(cmd, chunksize_ARG)) {
+				log_error("--chunksize is only available with snapshots or pools.");
 				return 0;
 			}
-			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-		} else {
-			region_size = get_default_region_size(cmd);
-			if (region_size < 0) {
-				log_error("Negative regionsize in "
-					  "configuration file is invalid.");
+
+			if (arg_is_set(cmd, zero_ARG)) {
+				log_error("--zero is only available with snapshots or thin pools.");
 				return 0;
 			}
-			lp->region_size = region_size;
-		}
 
-		if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-			log_error("Region size (%" PRIu32 ") must be "
-				  "a multiple of machine memory "
-				  "page size (%d).",
-				  lp->region_size, pagesize >> SECTOR_SHIFT);
-			return 0;
-		}
+			/*
+			 * --regionsize is only valid if converting an LV into a mirror.
+			 * Checked when we know the state of the LV being converted.
+			 */
+			if (arg_is_set(cmd, regionsize_ARG)) {
+				if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
+					    SIGN_MINUS) {
+					log_error("Negative regionsize is invalid.");
+					return 0;
+				}
+				lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
+			} else {
+				region_size = get_default_region_size(cmd);
+				if (region_size < 0) {
+					log_error("Negative regionsize in "
+						  "configuration file is invalid.");
+					return 0;
+				}
+				lp->region_size = region_size;
+			}
 
-		if (!is_power_of_2(lp->region_size)) {
-			log_error("Region size (%" PRIu32
-				  ") must be a power of 2.", lp->region_size);
-			return 0;
-		}
+			if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
+				log_error("Region size (%" PRIu32 ") must be "
+					  "a multiple of machine memory "
+					  "page size (%d).",
+					  lp->region_size, pagesize >> SECTOR_SHIFT);
+				return 0;
+			}
 
-		if (!lp->region_size) {
-			log_error("Non-zero region size must be supplied.");
-			return 0;
-		}
+			if (!is_power_of_2(lp->region_size)) {
+				log_error("Region size (%" PRIu32
+					  ") must be a power of 2.", lp->region_size);
+				return 0;
+			}
 
-		/* FIXME man page says in one place that --type and --mirrors can't be mixed */
-		if (lp->mirrors_supplied && !lp->mirrors)
-			/* down-converting to linear/stripe? */
-			lp->type_str = SEG_TYPE_NAME_STRIPED;
+			if (!lp->region_size) {
+				log_error("Non-zero region size must be supplied.");
+				return 0;
+			}
 
-	} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
-		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
-					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
-					 -1))
-			return_0;
+			/* FIXME man page says in one place that --type and --mirrors can't be mixed */
+			if (lp->mirrors_supplied && !lp->mirrors)
+				/* down-converting to linear/stripe? */
+				lp->type_str = SEG_TYPE_NAME_STRIPED;
 
-	} /* else segtype will default to current type */
+		} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
+			if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
+						 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
+						 -1))
+				return_0;
+		} /* else segtype will default to current type */
+	}
 
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
@@ -4693,6 +4749,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	int poll_ret, ret;
 	struct convert_poll_id_list *idl;
 	struct lvconvert_params lp = {
+		.conv_type = CONV_OTHER,
 		.target_attr = ~0,
 		.idls = DM_LIST_HEAD_INIT(lp.idls),
 	};


