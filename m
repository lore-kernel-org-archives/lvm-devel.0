From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:55 +0000 (UTC)
Subject: master - lvconvert: options splitcache, split, uncache
Message-ID: <20141006133255.A0895609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8497e329b3c70c88feb5f0121e05464d32b2433
Commit:        a8497e329b3c70c88feb5f0121e05464d32b2433
Parent:        4e9fbb4b96ad4beed5dd004f221cdbfb874e1094
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 4 15:32:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

lvconvert: options splitcache, split, uncache

  --splitcache
  Splits only cached LV (also pool could be specified).
  Detaches cachepool from cached LV.

  --split
  Should be univerzal command to split various complex targets.
  At this moment it knows cache.

  --uncache
  Opposite command to --cache. Detaches and DELETES cachepool for
  cached LV.

Note: we support thin pool cached metadata device for uncaching.
Also use may specify wither cached LV or association cachepool device
to request split of cache.
---
 WHATS_NEW         |    1 +
 tools/args.h      |    3 +
 tools/commands.h  |   23 ++++++-
 tools/lvconvert.c |  182 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 205 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9847730..8341d8d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Support lvconvert --splitcache and --uncache of cached LV.
   Option --cache has also shortcut -H (i.e. lvcreate -H).
   Refactor lvcreate code and better preserve --type argument.
   Refactor process_each_vg in toollib.
diff --git a/tools/args.h b/tools/args.h
index c1999bd..531148c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -108,6 +108,9 @@ arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
+arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
+arg(uncache_ARG, '\0', "uncache", NULL, 0)
+arg(split_ARG, '\0', "split", NULL, 0)
 arg(readonly_ARG, '\0', "readonly", NULL, 0)
 arg(atomic_ARG, '\0', "atomic", NULL, 0)
 arg(activationmode_ARG, '\0', "activationmode", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index ed911fa..2e99fb1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -184,7 +184,23 @@ xx(lvconvert,
    "--splitsnapshot\n"
    COMMON_OPTS
    "\tSnapshotLogicalVolume[Path]\n\n"
-   
+
+   "lvconvert "
+   "--splitcache\n"
+   COMMON_OPTS
+   "\tCacheLogicalVolume[Path]\n\n"
+
+   "lvconvert "
+   "--split\n"
+   "\t[--name SplitLogicalVolumeName]\n"
+   COMMON_OPTS
+   "\tSplitableLogicalVolume[Path]\n\n"
+
+   "lvconvert "
+   "--uncache\n"
+   COMMON_OPTS
+   "\tCacheLogicalVolume[Path]\n\n"
+
    "lvconvert "
    "[--type snapshot|-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
@@ -229,9 +245,10 @@ xx(lvconvert,
    corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
    mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
-   repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG, splitsnapshot_ARG,
+   repair_ARG, replace_ARG, snapshot_ARG,
+   split_ARG, splitcache_ARG, splitmirrors_ARG, splitsnapshot_ARG,
    stripes_long_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   trackchanges_ARG, type_ARG, use_policies_ARG, zero_ARG)
+   trackchanges_ARG, type_ARG, uncache_ARG, use_policies_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0d800ec..03118cb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -20,11 +20,14 @@ struct lvconvert_params {
 	int cache;
 	int force;
 	int snapshot;
+	int split;
+	int splitcache;
 	int splitsnapshot;
 	int merge;
 	int merge_mirror;
 	int poolmetadataspare;
 	int thin;
+	int uncache;
 	int yes;
 	int zero;
 
@@ -102,6 +105,18 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  "the snapshot exception store.");
 			return 0;
 		}
+		if (lp->split) {
+			log_error("Logical volume for split is missing.");
+			return 0;
+		}
+		if (lp->splitcache) {
+			log_error("Cache logical volume for split is missing.");
+			return 0;
+		}
+		if (lp->uncache) {
+			log_error("Cache logical volume for uncache is missing.");
+			return 0;
+		}
 		if (!lp->lv_name_full) {
 			log_error("Please provide logical volume path.");
 			return 0;
@@ -159,6 +174,18 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 			log_error("Too many arguments provided with --splitsnapshot.");
 			return 0;
 		}
+		if (lp->splitcache) {
+			log_error("Too many arguments provided with --splitcache.");
+			return 0;
+		}
+		if (lp->split) {
+			log_error("Too many arguments provided with --split.");
+			return 0;
+		}
+		if (lp->uncache) {
+			log_error("Too many arguments provided with --uncache.");
+			return 0;
+		}
 		if (lp->pool_data_lv_name && lp->pool_metadata_lv_name) {
 			log_error("Too many arguments provided for pool.");
 			return 0;
@@ -345,6 +372,34 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->splitsnapshot = 1;
 	}
 
+	if (arg_is_set(cmd, split_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
+					    split_ARG,
+                                            name_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->split = 1;
+	}
+
+	if (arg_is_set(cmd, splitcache_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --splitcache",
+					    splitcache_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->splitcache = 1;
+	}
+
+	if (arg_is_set(cmd, uncache_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --uncache",
+					    uncache_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->uncache = 1;
+	}
+
 	if ((_snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
 	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
@@ -404,13 +459,15 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->snapshot = 1;
 	}
 
+	if (lp->split) {
+		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 	/*
 	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
 	 * (note the minus sign), except that it signifies the additional
 	 * intent to keep the mimage that is detached, rather than
 	 * discarding it.
 	 */
-	if (arg_count(cmd, splitmirrors_ARG)) {
+	} else if (arg_count(cmd, splitmirrors_ARG)) {
 		if (_mirror_or_raid_type_requested(cmd, type_str)) {
 			log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 				  "mutually exclusive.");
@@ -1971,6 +2028,111 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	return ECMD_PROCESSED;
 }
 
+
+static int _lvconvert_split_cached(struct cmd_context *cmd,
+				   struct logical_volume *lv)
+{
+	struct logical_volume *cache_pool_lv = first_seg(lv)->pool_lv;
+
+	log_debug("Detaching cache pool %s from cached LV %s.",
+		  display_lvname(cache_pool_lv), display_lvname(lv));
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
+				display_lvname(lv), display_lvname(cache_pool_lv));
+
+	return 1;
+}
+
+static int _lvconvert_splitcache(struct cmd_context *cmd,
+				 struct logical_volume *lv,
+				 struct lvconvert_params *lp)
+{
+	struct lv_segment *seg;
+
+	if (lv_is_thin_pool(lv))
+		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
+
+	/* When passed used cache-pool of used cached LV -> split cached LV */
+	if (lv_is_cache_pool(lv) &&
+	    (dm_list_size(&lv->segs_using_this_lv) == 1) &&
+	    (seg = get_only_segment_using_this_lv(lv)) &&
+	    seg_is_cache(seg))
+		lv = seg->lv;
+
+	/* Supported LV types for split */
+	if (!lv_is_cache(lv)) {
+		log_error("Split of %s is not cache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!_lvconvert_split_cached(cmd, lv))
+		return_0;
+
+	return 1;
+}
+
+static int _lvconvert_split(struct cmd_context *cmd,
+			    struct logical_volume *lv,
+			    struct lvconvert_params *lp)
+{
+	struct lv_segment *seg;
+
+	if (lv_is_thin_pool(lv) &&
+	    lv_is_cache(seg_lv(first_seg(lv), 0)))
+		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
+
+	/* When passed used cache-pool of used cached LV -> split cached LV */
+	if (lv_is_cache_pool(lv) &&
+	    (dm_list_size(&lv->segs_using_this_lv) == 1) &&
+	    (seg = get_only_segment_using_this_lv(lv)) &&
+	    seg_is_cache(seg))
+		lv = seg->lv;
+
+	/* Supported LV types for split */
+	if (lv_is_cache(lv)) {
+		if (!_lvconvert_split_cached(cmd, lv))
+			return_0;
+	/* Add more types here */
+	} else {
+		log_error("Split of %s is unsupported.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _lvconvert_uncache(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	if (lv_is_thin_pool(lv))
+		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
+
+	if (!lv_is_cache(lv)) {
+		log_error("Cannot uncache non-cached logical volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, lp->force, 0))
+		return_0;
+
+	log_print_unless_silent("Logical volume %s is not cached.", display_lvname(lv));
+
+	return 1;
+}
+
 static int _lvconvert_snapshot(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       struct lvconvert_params *lp)
@@ -3087,6 +3249,24 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->splitsnapshot)
 		return _lvconvert_splitsnapshot(cmd, lv, lp);
 
+	if (lp->splitcache) {
+		if (!_lvconvert_splitcache(cmd, lv, lp))
+			return_ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
+
+	if (lp->split) {
+		if (!_lvconvert_split(cmd, lv, lp))
+			return_ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
+
+	if (lp->uncache) {
+		if (!_lvconvert_uncache(cmd, lv, lp))
+			return_ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
+
 	if (arg_count(cmd, repair_ARG)) {
 		if (lv_is_pool(lv)) {
 			if (!_lvconvert_pool_repair(cmd, lv, lp))


