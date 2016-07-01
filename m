From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  1 Jul 2016 16:24:53 +0000 (UTC)
Subject: master - lvconvert: improve arg checks in new operation routing code
Message-ID: <20160701162453.71746613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1df98222242d89c5c88d1122427ba5ae233e435a
Commit:        1df98222242d89c5c88d1122427ba5ae233e435a
Parent:        b0d8a524a2c1d9ccf191392bf47a2023087ae362
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 1 10:18:05 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 1 11:24:41 2016 -0500

lvconvert: improve arg checks in new operation routing code

Use defines for segment types, and test args directly
instead of indirectly.
---
 tools/lvconvert.c |  101 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 56 insertions(+), 45 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 795deef..a6f2704 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3973,10 +3973,11 @@ static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume
 static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 		                 struct lvconvert_params *lp)
 {
-	if (lp->splitsnapshot)
+	if (arg_is_set(cmd, splitsnapshot_ARG))
 		return _convert_cow_snapshot_splitsnapshot(cmd, lv, lp);
 
-	if (lp->merge)
+	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
+	if (arg_is_set(cmd, merge_ARG))
 		return _convert_cow_snapshot_merge(cmd, lv, lp);
 
 	log_error("Operation not permitted on COW snapshot LV %s", display_lvname(lv));
@@ -3989,7 +3990,8 @@ static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume
 static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *lv,
 				struct lvconvert_params *lp)
 {
-	if (lp->merge)
+	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
+	if (arg_is_set(cmd, merge_ARG))
 		return _convert_thin_volume_merge(cmd, lv, lp);
 
 	log_error("Operation not permitted on thin LV %s", display_lvname(lv));
@@ -4001,16 +4003,23 @@ static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *
 static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	if (lp->splitcache || lp->split)
+	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
+
+	if (arg_is_set(cmd, splitcache_ARG))
+		return _convert_thin_pool_splitcache(cmd, lv, lp);
+
+	if (arg_is_set(cmd, split_ARG)) {
+		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
+	}
 
-	if (lp->uncache)
+	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_thin_pool_uncache(cmd, lv, lp);
 
-	if (lp->cache)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
 		return _convert_thin_pool_cache(cmd, lv, lp);
 
-	if (lp->repair)
+	if (arg_is_set(cmd, repair_ARG))
 		return _convert_thin_pool_repair(cmd, lv, lp);
 
 	/* FIXME: swapping the thin pool metadata LV needs a specific option like --swapmetadata */
@@ -4033,19 +4042,23 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 {
 	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
 
-	if (lp->splitcache || lp->split)
+	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
 
-	if (lp->uncache)
+	if (arg_is_set(cmd, split_ARG)) {
+		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
+		return _convert_cache_volume_splitcache(cmd, lv, lp);
+	}
+
+	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_cache_volume_uncache(cmd, lv, lp);
 
-	/* FIXME: add lp->splitmirrors to reflect the arg. */
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4062,8 +4075,13 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
-	if (lp->splitcache || lp->split)
+	if (arg_is_set(cmd, splitcache_ARG))
+		return _convert_cache_pool_splitcache(cmd, lv, lp);
+
+	if (arg_is_set(cmd, split_ARG)) {
+		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
 		return _convert_cache_pool_splitcache(cmd, lv, lp);
+	}
 
 	/* FIXME: swapping the cache pool metadata LV needs a specific option like --swapmetadata */
 	if (arg_is_set(cmd, poolmetadata_ARG))
@@ -4086,17 +4104,16 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (new_type)
 		new_segtype = get_segtype_from_string(cmd, new_type);
 
-	if (lp->mirrors_supplied)
+	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_mirror_number(cmd, lv, lp);
 
-	/* FIXME: add lp->splitmirrors to reflect the arg. */
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_mirror_splitmirrors(cmd, lv, lp);
 
-	if (lp->mirrorlog || lp->corelog)
+	if (arg_is_set(cmd, mirrorlog_ARG) || arg_is_set(cmd, corelog_ARG))
 		return _convert_mirror_log(cmd, lv, lp);
 
-	if (lp->repair)
+	if (arg_is_set(cmd, repair_ARG))
 		return _convert_mirror_repair(cmd, lv, lp);
 
 	if (new_type && new_segtype && segtype_is_raid(new_segtype))
@@ -4138,46 +4155,45 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (new_type)
 		new_segtype = get_segtype_from_string(cmd, new_type);
 
-	if (lp->mirrors_supplied)
+	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
-	/* FIXME: add lp->splitmirrors to reflect the arg. */
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_raid_splitmirrors(cmd, lv, lp);
 
-	if (lp->merge_mirror)
+	if (arg_is_set(cmd, merge_ARG))
 		return _convert_raid_merge(cmd, lv, lp);
 
-	if (lp->repair)
+	if (arg_is_set(cmd, repair_ARG))
 		return _convert_raid_repair(cmd, lv, lp);
 
-	if (lp->replace)
+	if (arg_is_set(cmd, replace_ARG))
 		return _convert_raid_replace(cmd, lv, lp);
 
-	if (lp->snapshot)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_SNAPSHOT)) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_raid_snapshot(cmd, lv, lp);
 
-	if (lp->thin)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN)) || arg_is_set(cmd, thin_ARG))
 		return _convert_raid_thin(cmd, lv, lp);
 
-	if (lp->cache)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
 		return _convert_raid_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_raid_thin_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "cache-pool"))
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
 	if (new_type && new_segtype && segtype_is_raid(new_segtype))
 		return _convert_raid_raid(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "striped"))
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_STRIPED))
 		return _convert_raid_striped(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "linear"))
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_LINEAR))
 		return _convert_raid_linear(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4210,28 +4226,28 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (new_type)
 		new_segtype = get_segtype_from_string(cmd, new_type);
 
-	/* FIXME: add a new option to make this case more clear, e.g. --merge-splitmirror */
-	if (lp->merge)
+	/* FIXME: add --merge-mirror to make this distinct from --merge-snapshot. */
+	if (arg_is_set(cmd, merge_ARG))
 		return _convert_striped_merge(cmd, lv, lp);
 
-	if (lp->snapshot)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_SNAPSHOT)) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
-	if (lp->thin)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN)) || arg_is_set(cmd, thin_ARG))
 		return _convert_striped_thin(cmd, lv, lp);
 
-	if (lp->cache)
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
 		return _convert_striped_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "cache-pool"))
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL))
 		return _convert_striped_cache_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "mirror"))
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_MIRROR))
 		return _convert_striped_mirror(cmd, lv, lp);
 
 	if (new_type && new_segtype && segtype_is_raid(new_segtype))
@@ -4239,10 +4255,10 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
 
-	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, "mirror"))
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_MIRROR))
 		return _convert_striped_mirror(cmd, lv, lp);
 
-	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, "raid1"))
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_RAID1))
 		return _convert_striped_raid(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4263,17 +4279,12 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 /*
  * lvconvert performs a specific <operation> on a specific <lv_type>.
  *
- * The <operation> is specified by command args found in lp fields.
+ * The <operation> is specified by command line args.
  * The <lv_type> is found using lv_is_foo(lv) functions.
  *
- * lvconvert --operation LV
- *
- * lp->operation = arg_value(operation);
- * lv_type = lv_is_foo(LV);
- *
  * for each lvtype,
  *     _convert_lvtype();
- *         for each lp->operation
+ *         for each arg_is_set(operation)
  *             _convert_lvtype_operation();
  *
  */


