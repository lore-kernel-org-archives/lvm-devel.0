From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Jul 2016 20:46:21 +0000 (UTC)
Subject: master - lvconvert: Only obtain --type parameter once.
Message-ID: <20160729204621.335DC608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8e479081088d0649e93a24b8f3bc852eb396226
Commit:        a8e479081088d0649e93a24b8f3bc852eb396226
Parent:        800c0d3dd696b8574494788f38d61ca26ba68159
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 29 21:45:22 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 29 21:45:22 2016 +0100

lvconvert: Only obtain --type parameter once.

---
 tools/lvconvert.c |  106 +++++++++++++++++++++++++---------------------------
 1 files changed, 51 insertions(+), 55 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9e850b3..0f9286c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -440,7 +440,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	lp->type_str = arg_str_value(cmd, type_ARG, "");
 
-	if (arg_is_set(cmd, type_ARG) && !_check_conversion_type(cmd, lp->type_str))
+	if (*lp->type_str && !_check_conversion_type(cmd, lp->type_str))
 		return_0;
 
 	/* If --repair, check for incompatible args. */
@@ -625,6 +625,13 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
+	/* We should have caught all these cases already. */
+	if (lp->merge + lp->splitsnapshot + lp->splitcache + lp->split + lp->uncache +
+	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace > 1) {
+		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
+		return 0;
+	}
+
 	/*
 	 * Final checking of each case:
 	 *   lp->merge
@@ -634,6 +641,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 *   lp->uncache
 	 *   lp->cache
 	 *   lp->thin
+	 *   lp->keep_mimages
 	 *   lp->snapshot
 	 *   lp->replace
 	 *   --type mirror|raid  lp->repair lp->mirrorlog lp->corelog
@@ -693,11 +701,11 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		}
 		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
+		lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
+		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 			return_0;
 
-		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
-			? 0 : arg_int_value(cmd, zero_ARG, 1);
+		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
 
 	} else if (lp->replace) { /* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
@@ -771,27 +779,28 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return 0;
 		}
 
-		/* Default is never striped, regardless of existing LV configuration. */
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
-			return_0;
-
 		/* FIXME man page says in one place that --type and --mirrors can't be mixed */
-		if (lp->mirrors_supplied && !lp->mirrors) {
+		if (lp->mirrors_supplied && !lp->mirrors)
 			/* down-converting to linear/stripe? */
-			if (!(lp->segtype =
-			      get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
-				return_0;
-		} else if (arg_is_set(cmd, type_ARG)) {
+			lp->type_str = SEG_TYPE_NAME_STRIPED;
+
+		if (*lp->type_str)
 			/* changing mirror type? */
-			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
+			if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 				return_0;
-		}
+
+		/* Default is never striped, regardless of existing LV configuration. */
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
 	} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
 		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
 					 -1))
 			return_0;
 
+		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+			return_0;
+
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
@@ -800,8 +809,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
 			lp->stripes = 0;
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-			return_0;
 	} /* else segtype will default to current type */
 
 	lp->force = arg_count(cmd, force_ARG);
@@ -1717,7 +1724,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	const char *new_type;
 	uint32_t old_mimage_count;
 	uint32_t old_log_count;
 	uint32_t new_mimage_count;
@@ -1746,8 +1752,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((new_type = arg_str_value(cmd, type_ARG, NULL)) &&
-	    !strcmp(new_type, SEG_TYPE_NAME_LINEAR)) {
+	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
 			log_error("Cannot specify mirrors with linear type.");
 			return 0;
@@ -1837,7 +1842,6 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
-	const char *new_type;
 	int replace = 0, image_count = 0;
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
@@ -1847,8 +1851,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (!lp->segtype)
 		lp->segtype = seg->segtype;
 
-	if ((new_type = arg_str_value(cmd, type_ARG, NULL)) &&
-	    !strcmp(new_type, SEG_TYPE_NAME_LINEAR)) {
+	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
 			log_error("Cannot specify mirrors with linear type.");
 			return 0;
@@ -4081,8 +4084,6 @@ static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *
 static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
-
 	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
 
@@ -4092,7 +4093,7 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_thin_pool_uncache(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
 		return _convert_thin_pool_cache(cmd, lv, lp);
 
 	if (arg_is_set(cmd, repair_ARG))
@@ -4116,8 +4117,6 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume *lv,
 				 struct lvconvert_params *lp)
 {
-	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
-
 	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
 
@@ -4132,7 +4131,7 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4170,11 +4169,10 @@ static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *l
 static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 			   struct lvconvert_params *lp)
 {
-	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
 	const struct segment_type *new_segtype = NULL;
 
-	if (new_type)
-		new_segtype = get_segtype_from_string(cmd, new_type);
+	if (*lp->type_str)
+		new_segtype = get_segtype_from_string(cmd, lp->type_str);
 
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_mirror_number(cmd, lv, lp);
@@ -4188,10 +4186,10 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, repair_ARG))
 		return _convert_mirror_repair(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_LINEAR))
+	if (_linear_type_requested(lp->type_str))
 		return _convert_mirror_linear(cmd, lv, lp);
 
-	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+	if (new_segtype && segtype_is_raid(new_segtype))
 		return _convert_mirror_raid(cmd, lv, lp);
 
 	/*
@@ -4226,11 +4224,10 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			 struct lvconvert_params *lp)
 {
-	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
 	const struct segment_type *new_segtype = NULL;
 
-	if (new_type)
-		new_segtype = get_segtype_from_string(cmd, new_type);
+	if (*lp->type_str)
+		new_segtype = get_segtype_from_string(cmd, lp->type_str);
 
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
@@ -4247,32 +4244,32 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, replace_ARG))
 		return _convert_raid_replace(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_SNAPSHOT)) || arg_is_set(cmd, snapshot_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_raid_snapshot(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN)) || arg_is_set(cmd, thin_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || arg_is_set(cmd, thin_ARG))
 		return _convert_raid_thin(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
 		return _convert_raid_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_raid_thin_pool(cmd, lv, lp);
 
 	/* Using --cachepool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL)) || arg_is_set(cmd, cachepool_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
-	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+	if (new_segtype && segtype_is_raid(new_segtype))
 		return _convert_raid_raid(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_STRIPED))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
 		return _convert_raid_striped(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_LINEAR))
+	if (_linear_type_requested(lp->type_str))
 		return _convert_raid_linear(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4298,40 +4295,39 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 			    struct lvconvert_params *lp)
 {
-	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
 	const struct segment_type *new_segtype = NULL;
 	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 
-	if (new_type)
-		new_segtype = get_segtype_from_string(cmd, new_type);
+	if (*lp->type_str)
+		new_segtype = get_segtype_from_string(cmd, lp->type_str);
 
 	/* FIXME: add --merge-mirror to make this distinct from --merge-snapshot. */
 	if (arg_is_set(cmd, merge_ARG))
 		return _convert_striped_merge(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_SNAPSHOT)) || arg_is_set(cmd, snapshot_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN)) || arg_is_set(cmd, thin_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || arg_is_set(cmd, thin_ARG))
 		return _convert_striped_thin(cmd, lv, lp);
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE)) || arg_is_set(cmd, cache_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
 		return _convert_striped_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
 
 	/* Using --cachepool is ambiguous and not preferred. */
 
-	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL)) || arg_is_set(cmd, cachepool_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_striped_cache_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_MIRROR))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
 		return _convert_striped_mirror(cmd, lv, lp);
 
-	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+	if (new_segtype && segtype_is_raid(new_segtype))
 		return _convert_striped_raid(cmd, lv, lp);
 
 	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */


