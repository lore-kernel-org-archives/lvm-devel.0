From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:08:55 +0000 (UTC)
Subject: master - lvconvert: add comments describing conversions
Message-ID: <20160630220855.DE84A611B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=103c188681fce748ef193115c126bfbbc65fbab9
Commit:        103c188681fce748ef193115c126bfbbc65fbab9
Parent:        aed8bc8ae7b2f1c20a84470b033daababfb7c166
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 30 12:02:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 30 17:08:50 2016 -0500

lvconvert: add comments describing conversions

---
 tools/lvconvert.c |  387 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 352 insertions(+), 35 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3b98116..795deef 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -18,6 +18,25 @@
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
 
+/*
+ * Guidelines for mapping options to operations.
+ *
+ * There should be a clear and unique correspondence between an option
+ * name and the operation to be performed.
+ *
+ * An option with a given name should always perform the same operation.
+ * If the same operation applies to two types of LV, then the same option
+ * name can be used with both LV types.  But, a given option name should
+ * not be used to perform different operations depending on the LV type it
+ * is used with.
+ *
+ * --merge and --split are examples where a single option name has been
+ * overloaded with different operations.  The case of --split has been
+ * corrected with the clear and unique variations --splitcache,
+ * --splitsnapshot, --splitmirror, which should allow --split to be
+ * deprecated.  (The same is still needed for --merge.)
+ */
+
 struct lvconvert_params {
 	/* Exactly one of these options is chosen */
 	int merge;		/* Either merge_snapshot or merge_mirror is also set */
@@ -3295,24 +3314,44 @@ static int _lvconvert_cache(struct cmd_context *cmd,
  * moved into the _convert_lvtype_operation() functions below.
  */
 
+/*
+ * Separate a COW snapshot LV from its origin.
+ * lvconvert --splitsnapshot LV
+ */
+
 static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct logical_volume *lv,
 			                       struct lvconvert_params *lp)
 {
 	return _lvconvert_splitsnapshot(cmd, lv, lp);
 }
 
+/*
+ * Merge a COW snapshot LV into its origin.
+ * lvconvert --merge LV
+ */
+
 static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_volume *lv,
 			               struct lvconvert_params *lp)
 {
 	return _lvconvert_merge_old_snapshot(cmd, lv, lp);
 }
 
+/*
+ * Merge a snapshot thin LV into its origin.
+ * lvconvert --merge LV
+ */
+
 static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_volume *lv,
 			              struct lvconvert_params *lp)
 {
 	return _lvconvert_merge_thin_snapshot(cmd, lv, lp);
 }
 
+/*
+ * Split and preserve a cache pool from the data portion of a thin pool LV.
+ * lvconvert --splitcache LV
+ */
+
 static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
 				         struct lvconvert_params *lp)
 {
@@ -3328,6 +3367,11 @@ static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical
 	return _lvconvert_split_cached(cmd, sublv1);
 }
 
+/*
+ * Split and remove a cache pool from the data portion of a thin pool LV.
+ * lvconvert --uncache LV
+ */
+
 static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_volume *lv,
 				      struct lvconvert_params *lp)
 {
@@ -3343,16 +3387,35 @@ static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_vo
 	return _lvconvert_uncache(cmd, sublv1, lp);
 }
 
+/*
+ * Repair a thin pool LV.
+ * lvconvert --repair LV
+ */
+
 static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_volume *lv,
 			             struct lvconvert_params *lp)
 {
 	return _lvconvert_thin_pool_repair(cmd, lv, lp);
 }
 
+/*
+ * Convert the data portion of a thin pool LV to a cache LV.
+ * lvconvert --type cache LV
+ *
+ * Required options:
+ * --cachepool LV
+ *
+ * Auxiliary operation:
+ * Converts the --cachepool arg to a cache pool if it is not already.
+ *
+ * Alternate syntax:
+ * lvconvert --cache LV
+ */
+
 static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volume *lv,
 			            struct lvconvert_params *lp)
 {
-	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
+	/* lvconvert --type cache includes an implicit conversion of the cachepool arg to type cache-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
 		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
 		return 0;
@@ -3363,24 +3426,49 @@ static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volu
 	return _lvconvert_cache(cmd, lv, lp);
 }
 
+/*
+ * Replace the metadata LV in a thin pool LV.
+ * lvconvert --poolmetadata NewLV --thinpool LV
+ * FIXME: this will change so --swap-poolmetadata defines the operation.
+ * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
+ */
+
 static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
 			                   struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Split and preserve a cache pool from a cache LV.
+ * lvconvert --splitcache LV
+ */
+
 static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
 			                    struct lvconvert_params *lp)
 {
 	return _lvconvert_split_cached(cmd, lv);
 }
 
+/*
+ * Split and remove a cache pool from a cache LV.
+ * lvconvert --uncache LV
+ */
+
 static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical_volume *lv,
 			                 struct lvconvert_params *lp)
 {
 	return _lvconvert_uncache(cmd, lv, lp);
 }
 
+/*
+ * Split images from the raid1|mirror origin of a cache LV and use them to create a new LV.
+ * lvconvert --splitmirrors Number LV
+ *
+ * Required options:
+ * --trackchanges | --name Name
+ */
+
 static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			                     struct lvconvert_params *lp)
 {
@@ -3398,12 +3486,26 @@ static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct lo
 	return 0;
 }
 
+/*
+ * Convert a cache LV to a thin pool (using the cache LV for thin pool data).
+ * lvconvert --type thin-pool LV
+ *
+ * Alternate syntax:
+ * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
+ * lvconvert --thinpool LV
+ */
+
 static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			                   struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Split a cache volume from a cache pool LV.
+ * lvconvert --splitcache LV
+ */
+
 static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
 					  struct lvconvert_params *lp)
 {
@@ -3429,30 +3531,63 @@ static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logica
 	return _lvconvert_split_cached(cmd, sublv1);
 }
 
+/*
+ * Replace the metadata LV in a cache pool LV.
+ * lvconvert --poolmetadata NewLV --cachepool LV
+ * FIXME: this will change so --swap-poolmetadata defines the operation.
+ * FIXME: should be lvconvert --swap-poolmetadata NewLV LV
+ */
+
 static int _convert_cache_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
 			                    struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Change the number of images in a mirror LV.
+ * lvconvert --mirrors Number LV
+ */
+
 static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
 
+/*
+ * Split images from a mirror LV and use them to create a new LV.
+ * lvconvert --splitmirrors Number LV
+ *
+ * Required options:
+ * --name Name
+ */
+
 static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			                struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
 
+/*
+ * Change the type of log used by a mirror LV.
+ * lvconvert --mirrorlog Type LV
+ */
+
 static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
 
+/*
+ * Replace failed PVs in a mirror LV.
+ * lvconvert --repair LV
+ *
+ * Auxiliary operation:
+ * Removes missing, empty PVs from the VG, like vgreduce.
+ */
+
 static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
 {
@@ -3469,18 +3604,38 @@ static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume
 	return ret;
 }
 
+/*
+ * Convert mirror LV to raid1 LV.
+ * lvconvert --type raid1 LV
+ *
+ * FIXME: this is not yet implemented in the raid code.
+ */
+
 static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			        struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Change the number of images in a raid1 LV.
+ * lvconvert --mirrors Number LV
+ */
+
 static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *lv,
 			        struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Split images from a raid1 LV and use them to create a new LV.
+ * lvconvert --splitmirrors Number LV
+ *
+ * Required options:
+ * --trackchanges | --name Name
+ */
+
 static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			    	      struct lvconvert_params *lp)
 {
@@ -3488,6 +3643,12 @@ static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_vo
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Merge a raid1 LV into originalLV if the raid1 LV was
+ * previously split from the originalLV using --trackchanges.
+ * lvconvert --merge LV
+ */
+
 static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
@@ -3495,6 +3656,14 @@ static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *l
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Replace failed PVs in a raid* LV.
+ * lvconvert --repair LV
+ *
+ * Auxiliary operation:
+ * Removes missing, empty PVs from the VG, like vgreduce.
+ */
+
 static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *lv,
 			        struct lvconvert_params *lp)
 {
@@ -3512,6 +3681,11 @@ static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *
 	return ret;
 }
 
+/*
+ * Replace a specific PV in a raid* LV with another PV.
+ * lvconvert --replace PV LV 
+ */
+
 static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume *lv,
 			         struct lvconvert_params *lp)
 {
@@ -3519,12 +3693,35 @@ static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Combine a raid* LV with a snapshot LV that was previously
+ * split from the raid* LV using --splitsnapshot.
+ * lvconvert --type snapshot LV SnapshotLV
+ *
+ * Alternate syntax:
+ * lvconvert --snapshot LV SnapshotLV
+ */
+
 static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
 {
 	return _lvconvert_snapshot(cmd, lv, lp);
 }
 
+/*
+ * Convert a raid* LV to a thin LV with an external origin.
+ * lvconvert --type thin LV
+ *
+ * Required options:
+ * --thinpool LV
+ *
+ * Auxiliary operation:
+ * Converts the --thinpool arg to a thin pool if it is not already.
+ *
+ * Alternate syntax:
+ * lvconvert --thin LV
+ */
+
 static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -3537,10 +3734,24 @@ static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv
 	return _lvconvert_thin(cmd, lv, lp);
 }
 
+/*
+ * Convert a raid* LV to a cache LV.
+ * lvconvert --type cache LV
+ *
+ * Required options:
+ * --cachepool LV
+ *
+ * Auxiliary operation:
+ * Converts the --cachepool arg to a cache pool if it is not already.
+ *
+ * Alternate syntax:
+ * lvconvert --cache LV
+ */
+
 static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
-	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
+	/* lvconvert --type cache includes an implicit conversion of the cachepool arg to type cache-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
 		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
 		return 0;
@@ -3549,41 +3760,74 @@ static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *l
 	return _lvconvert_cache(cmd, lv, lp);
 }
 
+/*
+ * Convert a raid* LV to a thin-pool LV.
+ * lvconvert --type thin-pool LV
+ *
+ * Alternate syntax:
+ * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
+ * lvconvert --thinpool LV
+ */
+
 static int _convert_raid_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			           struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Convert a raid* LV to cache-pool LV.
+ * lvconvert --type cache-pool LV
+ */
+
 static int _convert_raid_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			            struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Convert a raid* LV to use a different raid level.
+ * lvconvert --type raid* LV
+ */
+
 static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Convert a raid* LV to a striped LV.
+ * lvconvert --type striped LV
+ *
+ * FIXME: this is not yet implemented in the raid code.
+ */
+
 static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
 			         struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Convert a raid* LV to a linear LV.
+ * lvconvert --type linear LV
+ *
+ * FIXME: this is not yet implemented in the raid code.
+ */
+
 static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,
 			        struct lvconvert_params *lp)
 {
 	return _lvconvert_raid(lv, lp);
 }
 
-static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
-			             struct lvconvert_params *lp)
-{
-	return _lvconvert_snapshot(cmd, lv, lp);
-}
+/*
+ * Merge a striped/linear LV into a raid1 LV if the striped/linear LV was
+ * previously split from the raid1 LV using --trackchanges.
+ * lvconvert --merge LV
+ */
 
 static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
@@ -3591,6 +3835,35 @@ static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume
 	return _lvconvert_raid(lv, lp);
 }
 
+/*
+ * Combine a linear/striped LV with a snapshot LV that was previously
+ * split from the linear/striped LV using --splitsnapshot.
+ * lvconvert --type snapshot LV SnapshotLV
+ *
+ * Alternate syntax:
+ * lvconvert --snapshot LV SnapshotLV
+ */
+
+static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
+			             struct lvconvert_params *lp)
+{
+	return _lvconvert_snapshot(cmd, lv, lp);
+}
+
+/*
+ * Convert a striped/linear LV to a thin LV with an external origin.
+ * lvconvert --type thin LV
+ *
+ * Required options:
+ * --thinpool LV
+ *
+ * Auxiliary operation:
+ * Converts the --thinpool arg to a thin pool if it is not already.
+ *
+ * Alternate syntax:
+ * lvconvert --thin LV
+ */
+
 static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume *lv,
 			         struct lvconvert_params *lp)
 {
@@ -3603,6 +3876,20 @@ static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume
 	return _lvconvert_thin(cmd, lv, lp);
 }
 
+/*
+ * Convert a striped/linear LV to a cache LV.
+ * lvconvert --type cache LV
+ *
+ * Required options:
+ * --cachepool LV
+ *
+ * Auxiliary operation:
+ * Converts the --cachepool arg to a cache pool if it is not already.
+ *
+ * Alternate syntax:
+ * lvconvert --cache LV
+ */
+
 static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume *lv,
 			          struct lvconvert_params *lp)
 {
@@ -3615,24 +3902,62 @@ static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume
 	return _lvconvert_cache(cmd, lv, lp);
 }
 
+/*
+ * Convert a striped/linear LV to a thin-pool LV.
+ * lvconvert --type thin-pool LV
+ *
+ * Alternate syntax:
+ * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
+ * lvconvert --thinpool LV
+ */
+
 static int _convert_striped_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			              struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
+/*
+ * Convert a striped/linear LV to a cache-pool LV.
+ * lvconvert --type cache-pool LV
+ */
+
 static int _convert_striped_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			               struct lvconvert_params *lp)
 {
 	return _lvconvert_pool(cmd, lv, lp);
 }
 
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
+
 static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 			           struct lvconvert_params *lp)
 {
 	return _lvconvert_mirrors(cmd, lv, lp);
 }
 
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
+
 static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			         struct lvconvert_params *lp)
 {
@@ -3696,9 +4021,9 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 
 	log_error("Operation not permitted on thin pool LV %s", display_lvname(lv));
 	log_error("Operations permitted on a thin pool LV are:\n"
-		  "  --splitcache   (operates on cache sub LV)\n"
-		  "  --uncache      (operates on cache sub LV)\n"
-		  "  --cache        (operates on data sub LV)\n"
+		  "  --splitcache           (operates on cache sub LV)\n"
+		  "  --uncache              (operates on cache sub LV)\n"
+		  "  --type cache | --cache (operates on data sub LV)\n"
 		  "  --repair\n");
 	return 0;
 }
@@ -3718,12 +4043,12 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
 
-	/* The --thinpool alias is ambiguous and not preferred. */
+	/* Using --thinpool is ambiguous and not preferred. */
 
 	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
-	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
 	log_error("Operation not permitted on cache LV %s", display_lvname(lv));
 	log_error("Operations permitted on a cache LV are:\n"
@@ -3782,6 +4107,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	 * explicit option should be added to enable this case,
 	 * rather than making it the result of an ambiguous
 	 * "lvconvert vg/lv" command.
+	 * Add 'lvconvert --poll-mirror vg/lv' for this case.
 	 *
 	 * Old behavior was described as:
 	 *   "Collapsing a stack of mirrors.
@@ -3837,7 +4163,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->cache)
 		return _convert_raid_cache(cmd, lv, lp);
 
-	/* The --thinpool alias is ambiguous and not preferred. */
+	/* Using --thinpool is ambiguous and not preferred. */
 
 	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_raid_thin_pool(cmd, lv, lp);
@@ -3854,7 +4180,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (new_type && !strcmp(new_type, "linear"))
 		return _convert_raid_linear(cmd, lv, lp);
 
-	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
 	log_error("Operation not permitted on raid LV %s", display_lvname(lv));
 	log_error("Operations permitted on a raid LV are:\n"
@@ -3863,9 +4189,9 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --merge\n"
 		  "  --repair\n"
 		  "  --replace\n"
-		  "  --snapshot\n"
-		  "  --thin\n"
-		  "  --cache\n"
+		  "  --type snapshot | --snapshot\n"
+		  "  --type thin | --thin\n"
+		  "  --type cache | --cache\n"
 		  "  --type thin-pool\n"
 		  "  --type cache-pool\n"
 		  "  --type raid*\n"
@@ -3884,20 +4210,20 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (new_type)
 		new_segtype = get_segtype_from_string(cmd, new_type);
 
-	if (lp->snapshot)
-		return _convert_striped_snapshot(cmd, lv, lp);
-
 	/* FIXME: add a new option to make this case more clear, e.g. --merge-splitmirror */
 	if (lp->merge)
 		return _convert_striped_merge(cmd, lv, lp);
 
+	if (lp->snapshot)
+		return _convert_striped_snapshot(cmd, lv, lp);
+
 	if (lp->thin)
 		return _convert_striped_thin(cmd, lv, lp);
 
 	if (lp->cache)
 		return _convert_striped_cache(cmd, lv, lp);
 
-	/* The --thinpool alias is ambiguous and not preferred. */
+	/* Using --thinpool is ambiguous and not preferred. */
 
 	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
@@ -3919,14 +4245,14 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, "raid1"))
 		return _convert_striped_raid(cmd, lv, lp);
 
-	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
 	log_error("Operation not permitted on striped or linear LV %s", display_lvname(lv));
 	log_error("Operations permitted on a striped or linear LV are:\n"
-		  "  --snapshot\n"
 		  "  --merge\n"
-		  "  --thin\n"
-		  "  --cache\n"
+		  "  --type snapshot | --snapshot\n"
+		  "  --type thin | --thin\n"
+		  "  --type cache | --cache\n"
 		  "  --type thin-pool\n"
 		  "  --type cache-pool\n"
 		  "  --type mirror | --mirrors\n"
@@ -3949,6 +4275,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
  *     _convert_lvtype();
  *         for each lp->operation
  *             _convert_lvtype_operation();
+ *
  */
 
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
@@ -3957,12 +4284,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lv_segment *lv_seg = first_seg(lv);
 	int ret = 0;
 
-	log_debug("lvconvert lv %s is type %s status %llx to type %s",
-		  display_lvname(lv),
-		  lv_seg->segtype->name,
-		  (unsigned long long)lv->status,
-		  arg_str_value(cmd, type_ARG, ""));
-
 	/*
 	 * Check some conditions that can never be processed.
 	 */
@@ -4048,10 +4369,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/*
-	 * Check for LV types that cannot be converted and print an error.
-	 */
-
-	/*
 	 * The intention is to explicitly check all cases above and never
 	 * reach here, but this covers anything that was missed.
 	 */


