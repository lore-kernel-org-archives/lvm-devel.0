From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 22 Jun 2016 17:41:32 +0000 (UTC)
Subject: master - lvconvert: Refactor argument handling code.
Message-ID: <20160622174132.53C686096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfc516f9bfd35ec36c60165bd319a9b0008764a3
Commit:        dfc516f9bfd35ec36c60165bd319a9b0008764a3
Parent:        7e671e5dd0af699244902d5ce71a7159253c9e2b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 22 18:40:22 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 22 18:40:22 2016 +0100

lvconvert: Refactor argument handling code.

Begin disentangling the different lvconvert modes of operation
from each other.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    9 +-
 lib/metadata/raid_manip.c        |    9 +-
 tools/lvconvert.c                |  294 ++++++++++++++++++++++++-------------
 4 files changed, 206 insertions(+), 107 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 86a53ce..ce77b6c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Refactor lvconvert argument handling code.
   Add --logonly option to report only cmd log for a command, not other reports.
   Add log/command_log_selection to configure default selection used on cmd log.
   Use 'orphan' object type in cmd log for groups to collect PVs not yet in VGs.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a88ba1e..5948404 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1202,8 +1202,13 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    struct dm_list *splittable_pvs);
 int lv_raid_merge(struct logical_volume *lv);
-int lv_raid_reshape(struct logical_volume *lv,
-		    const struct segment_type *new_segtype);
+int lv_raid_convert(struct logical_volume *lv,
+		    const struct segment_type *new_segtype,
+		    int yes, int force,
+		    const unsigned image_count,
+		    const unsigned stripes,
+		    const unsigned new_stripe_size,
+		    struct dm_list *allocate_pvs);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 739e144..132eef3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1469,8 +1469,13 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
  *
  * Returns: 1 on success, 0 on failure
  */
-int lv_raid_reshape(struct logical_volume *lv,
-		    const struct segment_type *new_segtype)
+int lv_raid_convert(struct logical_volume *lv,
+		    const struct segment_type *new_segtype,
+		    int yes, int force,
+		    unsigned new_image_count,
+		    const unsigned new_stripes,
+		    const unsigned new_stripe_size,
+		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ae9b052..9c7f9c2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -19,18 +19,29 @@
 #include "lvconvert_poll.h"
 
 struct lvconvert_params {
+	/* Exactly one of these options is chosen */
+	int merge;		/* Either merge_snapshot or merge_mirror is also set */
 	int cache;
-	int force;
+	int corelog;
+	int mirrorlog;
+	int mirrors_supplied;	/* When type_str is not set, this may be set with keep_mimages for --splitmirrors */
+	int repair;
+	int replace;
 	int snapshot;
 	int split;
 	int splitcache;
 	int splitsnapshot;
-	int merge;
-	int merge_mirror;
-	int poolmetadataspare;
-	int repair;
 	int thin;
 	int uncache;
+	const char *type_str;	/* When this is set, mirrors_supplied may optionally also be set */
+
+	const struct segment_type *segtype;
+
+	int merge_snapshot;	/* merge is also set */
+	int merge_mirror;	/* merge is also set */
+
+	int poolmetadataspare;
+	int force;
 	int yes;
 	int zero;
 
@@ -55,7 +66,6 @@ struct lvconvert_params {
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */
 
-	const struct segment_type *segtype;
 	unsigned target_attr;
 
 	alloc_policy_t alloc;
@@ -116,11 +126,21 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  int *pargc, char ***pargv)
 {
 	if (lp->merge) {
+		/* FIXME Multiple arguments that mix snap and mirror? */
 		if (!*pargc) {
 			log_error("Please specify a logical volume path.");
 			return 0;
 		}
-		return 1;
+
+		if (!strstr((*pargv)[0], "_rimage_")) {	/* Snapshot */
+			if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
+				return_0;
+			lp->merge_snapshot = 1;
+			return 1;
+		}
+
+		/* Mirror */
+		lp->merge_mirror = 1;
 	}
 
 	if (!*pargc) {
@@ -191,7 +211,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if (!lp->merge_mirror &&
 	    !lp->repair &&
-	    !arg_is_set(cmd, splitmirrors_ARG) &&
+	    !lp->keep_mimages &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
 	    !strstr(lp->lv_name, "_cdata") &&
@@ -247,6 +267,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 
 	/* FIXME: Check thin-pool and thin more thoroughly! */
 	if (!strcmp(type_str, "snapshot") ||
+	    !strcmp(type_str, "striped") ||
 	    !strncmp(type_str, "raid", 4) ||
 	    !strcmp(type_str, "cache-pool") || !strcmp(type_str, "cache") ||
 	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
@@ -257,43 +278,57 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 }
 
 /* -s/--snapshot and --type snapshot are synonyms */
-static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str) {
+static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str)
+{
 	return (arg_is_set(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
 }
+
+static int _raid0_type_requested(struct cmd_context *cmd, const char *type_str)
+{
+	return (!strcmp(type_str, "raid0"));
+}
+
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
-static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str) {
-	return (arg_is_set(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
+static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str)
+{
+	return (arg_is_set(cmd, mirrors_ARG) || !strcmp(type_str, "mirror") ||
+		(!strncmp(type_str, "raid", 4) && !_raid0_type_requested(cmd, type_str)));
+}
+
+static int _striped_type_requested(struct cmd_context *cmd, const char *type_str)
+{
+	return (!strcmp(type_str, "striped"));
 }
 
 static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
-			     const char *type_str, struct lvconvert_params *lp)
+			     struct lvconvert_params *lp)
 {
 	int cachepool = 0;
 	int thinpool = 0;
 
 	if ((lp->pool_data_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
-		if (type_str[0] &&
-		    strcmp(type_str, "cache") &&
-		    strcmp(type_str, "cache-pool")) {
+		if (lp->type_str[0] &&
+		    strcmp(lp->type_str, "cache") &&
+		    strcmp(lp->type_str, "cache-pool")) {
 			log_error("--cachepool argument is only valid with "
 				  " the cache or cache-pool segment type.");
 			return 0;
 		}
 		cachepool = 1;
-		type_str = "cache-pool";
-	} else if (!strcmp(type_str, "cache-pool"))
+		lp->type_str = "cache-pool";
+	} else if (!strcmp(lp->type_str, "cache-pool"))
 		cachepool = 1;
 	else if ((lp->pool_data_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
-		if (type_str[0] &&
-		    strcmp(type_str, "thin") &&
-		    strcmp(type_str, "thin-pool")) {
+		if (lp->type_str[0] &&
+		    strcmp(lp->type_str, "thin") &&
+		    strcmp(lp->type_str, "thin-pool")) {
 			log_error("--thinpool argument is only valid with "
 				  " the thin or thin-pool segment type.");
 			return 0;
 		}
 		thinpool = 1;
-		type_str = "thin-pool";
-	} else if (!strcmp(type_str, "thin-pool"))
+		lp->type_str = "thin-pool";
+	} else if (!strcmp(lp->type_str, "thin-pool"))
 		thinpool = 1;
 
 	if (lp->cache && !cachepool) {
@@ -326,7 +361,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 					 splitmirrors_ARG, splitsnapshot_ARG, -1))
 			return_0;
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
+		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 			return_0;
 
 		if (!get_pool_params(cmd, lp->segtype, &lp->passed_args,
@@ -374,11 +409,13 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	struct arg_value_group_list *group;
 	int region_size;
 	int pagesize = lvm_getpagesize();
-	const char *type_str = arg_str_value(cmd, type_ARG, "");
 
-	if (!_check_conversion_type(cmd, type_str))
+	lp->type_str = arg_str_value(cmd, type_ARG, "");
+
+	if (arg_is_set(cmd, type_ARG) && !_check_conversion_type(cmd, lp->type_str))
 		return_0;
 
+	/* If --repair, check for incompatible args. */
 	if (arg_is_set(cmd, repair_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
 					    repair_ARG,
@@ -390,7 +427,12 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->repair = 1;
 	}
 
-	if (arg_is_set(cmd, mirrorlog_ARG) && arg_is_set(cmd, corelog_ARG)) {
+	if (arg_is_set(cmd, mirrorlog_ARG))
+		lp->mirrorlog = 1;
+	if (arg_is_set(cmd, corelog_ARG))
+		lp->corelog = 1;
+
+	if (lp->mirrorlog && lp->corelog) {
 		log_error("--mirrorlog and --corelog are incompatible.");
 		return 0;
 	}
@@ -432,57 +474,40 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->uncache = 1;
 	}
 
-	if ((_snapshot_type_requested(cmd, type_str) || arg_is_set(cmd, merge_ARG)) &&
-	    (arg_is_set(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
-	     lp->repair || arg_is_set(cmd, thinpool_ARG))) {
-		log_error("--snapshot/--type snapshot or --merge argument "
-			  "cannot be mixed with --mirrors/--type mirror/--type raid*, "
-			  "--mirrorlog, --repair or --thinpool.");
-		return 0;
-	}
-
-	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
-	    !(_mirror_or_raid_type_requested(cmd, type_str) ||
-	      lp->repair ||
-	      arg_is_set(cmd, thinpool_ARG))) {
-		log_error("--stripes or --stripesize argument is only valid "
-			  "with --mirrors/--type mirror/--type raid*, --repair and --thinpool");
-		return 0;
-	}
-
 	if (arg_is_set(cmd, cache_ARG))
 		lp->cache = 1;
 
-	if (!strcmp(type_str, "cache"))
+	if (!strcmp(lp->type_str, "cache"))
 		lp->cache = 1;
 	else if (lp->cache) {
-		if (type_str[0]) {
-			log_error("--cache is incompatible with --type %s", type_str);
+		if (lp->type_str[0]) {
+			log_error("--cache is incompatible with --type %s", lp->type_str);
 			return 0;
 		}
-		type_str = "cache";
+		lp->type_str = "cache";
 	}
 
 	if (arg_is_set(cmd, thin_ARG))
 		lp->thin = 1;
 
-	if (!strcmp(type_str, "thin"))
+	if (!strcmp(lp->type_str, "thin"))
 		lp->thin = 1;
 	else if (lp->thin) {
-		if (type_str[0]) {
-			log_error("--thin is incompatible with --type %s", type_str);
+		if (lp->type_str[0]) {
+			log_error("--thin is incompatible with --type %s", lp->type_str);
 			return 0;
 		}
-		type_str = "thin";
+		lp->type_str = "thin";
 	}
 
-	if (!_read_pool_params(cmd, &argc, &argv, type_str, lp))
+	/* May set lp->segtype */
+	if (!_read_pool_params(cmd, &argc, &argv, lp))
 		return_0;
 
 	if (!arg_is_set(cmd, background_ARG))
 		lp->wait_completion = 1;
 
-	if (_snapshot_type_requested(cmd, type_str)) {
+	if (_snapshot_type_requested(cmd, lp->type_str)) {
 		if (arg_is_set(cmd, merge_ARG)) {
 			log_error("--snapshot and --merge are mutually exclusive.");
 			return 0;
@@ -493,6 +518,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	if (lp->split) {
 		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
+
 	/*
 	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
 	 * (note the minus sign), except that it signifies the additional
@@ -500,7 +526,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 * discarding it.
 	 */
 	} else if (arg_is_set(cmd, splitmirrors_ARG)) {
-		if (_mirror_or_raid_type_requested(cmd, type_str)) {
+		if (_mirror_or_raid_type_requested(cmd, lp->type_str)) {
 			log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 				  "mutually exclusive.");
 			return 0;
@@ -521,38 +547,84 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	if (arg_is_set(cmd, merge_ARG)) {
-		if ((argc == 1) && strstr(argv[0], "_rimage_"))
-			lp->merge_mirror = 1;
-		else
-			lp->merge = 1;
+	if (arg_is_set(cmd, merge_ARG))
+		lp->merge = 1;
+
+	if (arg_is_set(cmd, replace_ARG))
+		lp->replace = 1;
+
+	/* If no other case was identified, then use of --stripes means --type striped */
+	if (!arg_is_set(cmd, type_ARG) && !lp->merge && !lp->splitsnapshot &&
+	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
+	    !lp->replace && !_mirror_or_raid_type_requested(cmd, lp->type_str) &&
+	    !lp->repair && !lp->mirrorlog && !lp->corelog &&
+	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
+		lp->type_str = "striped";
+
+	if ((_snapshot_type_requested(cmd, lp->type_str) || lp->merge) &&
+	    (lp->mirrorlog || _mirror_or_raid_type_requested(cmd, lp->type_str) ||
+	     lp->repair || arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(cmd, lp->type_str) ||
+	     _striped_type_requested(cmd, lp->type_str))) {
+		log_error("--snapshot/--type snapshot or --merge argument "
+			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped, "
+			  "--mirrorlog, --repair or --thinpool.");
+		return 0;
+	}
+
+	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
+	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str) ||
+	      _raid0_type_requested(cmd, lp->type_str) || lp->repair || arg_is_set(cmd, thinpool_ARG))) {
+		log_error("--stripes or --stripesize argument is only valid "
+			  "with --mirrors/--type mirror/--type raid*/--type striped, --repair and --thinpool");
+		return 0;
 	}
 
 	if (arg_is_set(cmd, mirrors_ARG)) {
 		/*
-		 * --splitmirrors has been chosen as the mechanism for
-		 * specifying the intent of detaching and keeping a mimage
-		 * versus an additional qualifying argument being added here.
+		 * --splitmirrors is the mechanism for detaching and keeping a mimage
 		 */
+		lp->mirrors_supplied = 1;
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
 	}
 
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	/* There are six types of lvconvert. */
-	if (lp->merge) {	/* Snapshot merge */
+	/*
+	 * Final checking of each case:
+	 *   lp->merge
+	 *   lp->splitsnapshot
+	 *   lp->splitcache
+	 *   lp->split
+	 *   lp->uncache
+	 *   lp->cache
+	 *   lp->thin
+	 *   lp->snapshot
+	 *   lp->replace
+	 *   --type mirror|raid  lp->repair lp->mirrorlog lp->corelog
+	 *   --type raid0|striped
+	 */
+	if (lp->merge) {	/* Snapshot or mirror merge */
 		if (arg_outside_list_is_set(cmd, "cannot be used with --merge",
 					    merge_ARG,
 					    background_ARG, interval_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;
-
-		if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
-			return_0;
 	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
 		;
+	else if (lp->splitcache)	
+		;
+	else if (lp->split)	
+		;
+	else if (lp->uncache)	
+		;
+	else if (lp->cache)	
+		;
+	else if (lp->thin)	
+		;
+	else if (lp->keep_mimages)	/* --splitmirrors */
+		;
 	else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
 		if (!argc) {
 			log_error("Please provide logical volume path for snapshot origin.");
@@ -592,7 +664,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
 			? 0 : arg_int_value(cmd, zero_ARG, 1);
 
-	} else if (arg_is_set(cmd, replace_ARG)) { /* RAID device replacement */
+	} else if (lp->replace) { /* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
 		lp->replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * lp->replace_pv_count);
 		if (!lp->replace_pvs)
@@ -612,10 +684,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (_mirror_or_raid_type_requested(cmd, type_str) ||
-		   arg_is_set(cmd, repair_ARG) ||
-		   arg_is_set(cmd, mirrorlog_ARG) ||
-		   arg_is_set(cmd, corelog_ARG)) { /* Mirrors (and some RAID functions) */
+	} else if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
+		   lp->repair || lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
 		if (arg_is_set(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;
@@ -630,7 +700,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		 * --regionsize is only valid if converting an LV into a mirror.
 		 * Checked when we know the state of the LV being converted.
 		 */
-
 		if (arg_is_set(cmd, regionsize_ARG)) {
 			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
 				    SIGN_MINUS) {
@@ -671,7 +740,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
-		if (arg_is_set(cmd, mirrors_ARG) && !lp->mirrors) {
+		/* FIXME man page says in one place that --type and --mirrors can't be mixed */
+		if (lp->mirrors_supplied && !lp->mirrors) {
 			/* down-converting to linear/stripe? */
 			if (!(lp->segtype =
 			      get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
@@ -681,6 +751,17 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
 		} /* else segtype will default to current type */
+	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or raid0 */
+		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped",
+					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
+					 -1))
+			return_0;
+
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+			return_0;
 	}
 
 	lp->force = arg_count(cmd, force_ARG);
@@ -1139,7 +1220,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
-	if (is_lockd_type(lv->vg->lock_type) && arg_is_set(cmd, splitmirrors_ARG)) {
+	if (is_lockd_type(lv->vg->lock_type) && lp->keep_mimages) {
 		/* FIXME: we need to create a lock for the new LV. */
 		log_error("Unable to split mirrors in VG with lock_type %s", lv->vg->lock_type);
 		return 0;
@@ -1150,9 +1231,9 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 *
 	 * If called with no argument, try collapsing the resync layers
 	 */
-	if (!arg_is_set(cmd, mirrors_ARG) && !arg_is_set(cmd, mirrorlog_ARG) &&
-	    !arg_is_set(cmd, corelog_ARG) && !arg_is_set(cmd, regionsize_ARG) &&
-	    !arg_is_set(cmd, splitmirrors_ARG) && !lp->repair) {
+	if (!lp->mirrors_supplied && !lp->mirrorlog &&
+	    !lp->corelog && !arg_is_set(cmd, regionsize_ARG) &&
+	    !lp->keep_mimages && !lp->repair) {
 		*new_mimage_count = *old_mimage_count;
 		*new_log_count = *old_log_count;
 
@@ -1164,7 +1245,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	/*
 	 * Adjusting mimage count?
 	 */
-	if (!arg_is_set(cmd, mirrors_ARG) && !arg_is_set(cmd, splitmirrors_ARG))
+	if (!lp->mirrors_supplied && !lp->keep_mimages)
 		lp->mirrors = *old_mimage_count;
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = *old_mimage_count + lp->mirrors;
@@ -1207,11 +1288,10 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 * position that the user would like a 'disk' log.
 	 */
 	*new_log_count = (*old_mimage_count > 1) ? *old_log_count : 1;
-	if (!arg_is_set(cmd, corelog_ARG) && !arg_is_set(cmd, mirrorlog_ARG))
+	if (!lp->corelog && !lp->mirrorlog)
 		return 1;
 
-	*new_log_count = arg_int_value(cmd, mirrorlog_ARG,
-				       arg_is_set(cmd, corelog_ARG) ? MIRROR_LOG_CORE : DEFAULT_MIRRORLOG);
+	*new_log_count = arg_int_value(cmd, mirrorlog_ARG, lp->corelog ? MIRROR_LOG_CORE : DEFAULT_MIRRORLOG);
 
 	/*
 	 * No mirrored logs for cluster mirrors until
@@ -1665,6 +1745,10 @@ static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 	if (from_segtype == to_segtype)
 		return 1;
 
+	/* Support raid0 <-> striped conversions */
+	if (segtype_is_striped(from_segtype) && segtype_is_striped(to_segtype))
+		return 1;
+
 	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
 		return_0;  /* Not converting to or from RAID? */
 
@@ -1710,8 +1794,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		lp->segtype = seg->segtype;
 
 	/* Can only change image count for raid1 and linear */
-	if (arg_is_set(cmd, mirrors_ARG) &&
-	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
+	if (lp->mirrors_supplied && !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
 			  lvseg_name(seg));
 		return 0;
@@ -1727,13 +1810,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 0;
 	}
 
-	if (seg_is_linear(seg) && !lp->merge_mirror && !arg_is_set(cmd, mirrors_ARG)) {
+	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
 		log_error("Raid conversions require -m/--mirrors");
 		return 0;
 	}
 
 	/* Change number of RAID1 images */
-	if (arg_is_set(cmd, mirrors_ARG) || arg_is_set(cmd, splitmirrors_ARG)) {
+	if (lp->mirrors_supplied || lp->keep_mimages) {
 		image_count = lv_raid_image_count(lv);
 		if (lp->mirrors_sign == SIGN_PLUS)
 			image_count += lp->mirrors;
@@ -1744,8 +1827,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		if (image_count < 1) {
 			log_error("Unable to %s images by specified amount",
-				  arg_is_set(cmd, splitmirrors_ARG) ?
-				  "split" : "reduce");
+				  lp->keep_mimages ? "split" : "reduce");
 			return 0;
 		}
 	}
@@ -1756,17 +1838,24 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (arg_is_set(cmd, trackchanges_ARG))
 		return lv_raid_split_and_track(lv, lp->pvh);
 
-	if (arg_is_set(cmd, splitmirrors_ARG))
+	if (lp->keep_mimages)
 		return lv_raid_split(lv, lp->lv_split_name,
 				     image_count, lp->pvh);
 
-	if (arg_is_set(cmd, mirrors_ARG))
+	if (lp->mirrors_supplied)
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);
 
-	if (arg_is_set(cmd, type_ARG))
-		return lv_raid_reshape(lv, lp->segtype);
+	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
+	    ((lp->type_str && lp->type_str[0]) || image_count)) {
+		if (segtype_is_any_raid0(lp->segtype) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
+			log_error("RAID module does not support RAID0.");
+			return 0;
+		}
+		return lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, image_count, lp->stripes, lp->stripe_size, lp->pvh);
+	}
 
-	if (arg_is_set(cmd, replace_ARG))
+	if (lp->replace)
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (lp->repair) {
@@ -1778,7 +1867,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (!lv_raid_percent(lv, &sync_percent)) {
+		if (!seg_is_striped(seg) && !seg_is_any_raid0(seg) &&
+		    !lv_raid_percent(lv, &sync_percent)) {
 			log_error("Unable to determine sync status of %s/%s.",
 				  lv->vg->name, lv->name);
 			return 0;
@@ -3256,7 +3346,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv) && !lp->merge && !lp->splitsnapshot) {
+	if (lv_is_cow(lv) && !lp->merge_snapshot && !lp->splitsnapshot) {
 		log_error("Cannot convert snapshot logical volume %s.",
 			  display_lvname(lv));
 		return ECMD_FAILED;
@@ -3331,8 +3421,8 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* forward splitmirror operations to the cache origin, which may be raid
 	 * or old-style mirror */
-	if (arg_is_set(cmd, splitmirrors_ARG) && lv_is_cache_type(lv)
-	    && (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
+	if (lp->keep_mimages && lv_is_cache_type(lv) &&
+	    (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
 		log_warn("WARNING: Selected operation does not work with cache-type LVs.");
 		log_warn("WARNING: Proceeding using the cache origin volume %s instead.",
 			 display_lvname(origin));
@@ -3348,12 +3438,12 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		 * the segtype was not specified, then we need
 		 * to consult the default.
 		 */
-		if (arg_is_set(cmd, mirrors_ARG) && !lv_is_mirrored(lv)) {
+		if (lp->mirrors_supplied && !lv_is_mirrored(lv)) {
 			if (!(lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL))))
 				return_ECMD_FAILED;
 		}
 	}
-	if (lp->merge) {
+	if (lp->merge_snapshot) {
 		if ((lv_is_thin_volume(lv) && !_lvconvert_merge_thin_snapshot(cmd, lv, lp)) ||
 		    (!lv_is_thin_volume(lv) && !_lvconvert_merge_old_snapshot(cmd, lv, lp))) {
 			log_print_unless_silent("Unable to merge volume %s into its origin.",
@@ -3384,9 +3474,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (lp->repair && arg_is_set(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	} else if (arg_is_set(cmd, mirrors_ARG) ||
-		   arg_is_set(cmd, splitmirrors_ARG) ||
-		   lv_is_mirrored(lv)) {
+	} else if (lp->mirrors_supplied || lp->keep_mimages || lv_is_mirrored(lv)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 


