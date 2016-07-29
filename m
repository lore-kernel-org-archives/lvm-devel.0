From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Jul 2016 23:23:30 +0000 (UTC)
Subject: master - lvconvert: Rearrange code that decides segtype.
Message-ID: <20160729232330.D109960FEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d01b1b6cc14885670516653771077fefc9e94788
Commit:        d01b1b6cc14885670516653771077fefc9e94788
Parent:        a8e479081088d0649e93a24b8f3bc852eb396226
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 00:22:13 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 00:22:13 2016 +0100

lvconvert: Rearrange code that decides segtype.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   91 ++++++++++++++++++++++-------------------------------
 2 files changed, 39 insertions(+), 53 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2ef2e09..8474644 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Further lvconvert validation logic refactoring.
 
 Version 2.02.162 - 28th July 2016
 =================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0f9286c..4a5956e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -155,9 +155,9 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		}
 
 		if (!strstr((*pargv)[0], "_rimage_")) {	/* Snapshot */
-			if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
-				return_0;
+			lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
 			lp->merge_snapshot = 1;
+
 			return 1;
 		}
 
@@ -702,10 +702,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
 
 		lp->type_str = SEG_TYPE_NAME_SNAPSHOT;
-		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-			return_0;
-
-		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
 
 	} else if (lp->replace) { /* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
@@ -784,36 +780,27 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			/* down-converting to linear/stripe? */
 			lp->type_str = SEG_TYPE_NAME_STRIPED;
 
-		if (*lp->type_str)
-			/* changing mirror type? */
-			if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-				return_0;
-
-		/* Default is never striped, regardless of existing LV configuration. */
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
-			return_0;
 	} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
 		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
 					 -1))
 			return_0;
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-			return_0;
-
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
-			return_0;
-
-		/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
-		/* The default keeps existing number of stripes, handled inside the library code */
-		if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
-			lp->stripes = 0;
-
 	} /* else segtype will default to current type */
 
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
+	if (!_lvconvert_name_params(lp, cmd, &argc, &argv))
+		return_0;
+
+	lp->pv_count = argc;
+	lp->pvs = argv;
+
+	/* If we have type_str, set up the segtype to match. */
+	if (*lp->type_str && !(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+		return_0;
+
 	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -821,11 +808,23 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	if (!_lvconvert_name_params(lp, cmd, &argc, &argv))
-		return_0;
+	/* Process striping parameters */
+	/* FIXME This is incomplete */
+	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
+	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
 
-	lp->pv_count = argc;
-	lp->pvs = argv;
+		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
+
+			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
+			/* The default keeps existing number of stripes, handled inside the library code */
+			if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
+				lp->stripes = 0;
+	}
+
+	if (lp->snapshot)
+		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
 
 	return 1;
 }
@@ -1848,9 +1847,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct lv_segment *seg = first_seg(lv);
 	dm_percent_t sync_percent;
 
-	if (!lp->segtype)
-		lp->segtype = seg->segtype;
-
 	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
 			log_error("Cannot specify mirrors with linear type.");
@@ -4169,11 +4165,6 @@ static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *l
 static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 			   struct lvconvert_params *lp)
 {
-	const struct segment_type *new_segtype = NULL;
-
-	if (*lp->type_str)
-		new_segtype = get_segtype_from_string(cmd, lp->type_str);
-
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_mirror_number(cmd, lv, lp);
 
@@ -4189,7 +4180,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (_linear_type_requested(lp->type_str))
 		return _convert_mirror_linear(cmd, lv, lp);
 
-	if (new_segtype && segtype_is_raid(new_segtype))
+	if (segtype_is_raid(lp->segtype))
 		return _convert_mirror_raid(cmd, lv, lp);
 
 	/*
@@ -4224,11 +4215,6 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			 struct lvconvert_params *lp)
 {
-	const struct segment_type *new_segtype = NULL;
-
-	if (*lp->type_str)
-		new_segtype = get_segtype_from_string(cmd, lp->type_str);
-
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
@@ -4263,7 +4249,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
-	if (new_segtype && segtype_is_raid(new_segtype))
+	if (segtype_is_raid(lp->segtype))
 		return _convert_raid_raid(cmd, lv, lp);
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED))
@@ -4295,12 +4281,8 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 			    struct lvconvert_params *lp)
 {
-	const struct segment_type *new_segtype = NULL;
 	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 
-	if (*lp->type_str)
-		new_segtype = get_segtype_from_string(cmd, lp->type_str);
-
 	/* FIXME: add --merge-mirror to make this distinct from --merge-snapshot. */
 	if (arg_is_set(cmd, merge_ARG))
 		return _convert_striped_merge(cmd, lv, lp);
@@ -4327,7 +4309,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
 		return _convert_striped_mirror(cmd, lv, lp);
 
-	if (new_segtype && segtype_is_raid(new_segtype))
+	if (segtype_is_raid(lp->segtype))
 		return _convert_striped_raid(cmd, lv, lp);
 
 	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
@@ -4369,7 +4351,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvconvert_params *lp)
 {
-	struct lv_segment *lv_seg = first_seg(lv);
+	struct lv_segment *seg = first_seg(lv);
 	int ret = 0;
 
 	/*
@@ -4407,11 +4389,14 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	/* If we don't have a specific new segtype to use, keep the existing one. */
+	if (!lp->segtype)
+		lp->segtype = seg->segtype;
+
 	/*
 	 * Each LV type that can be converted.
 	 * (The existing type of the LV, not a requested type.)
 	 */
-
 	if (lv_is_cow(lv)) {
 		ret = _convert_cow_snapshot(cmd, lv, lp);
 		goto out;
@@ -4449,10 +4434,10 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/*
 	 * FIXME: add lv_is_striped() and lv_is_linear()?
-	 * This does not include raid0.
+	 * This does not include raid0 which is caught by the test above.
 	 * If operations differ between striped and linear, split this case.
 	 */
-	if (segtype_is_striped(lv_seg->segtype) || segtype_is_linear(lv_seg->segtype)) {
+	if (segtype_is_striped(seg->segtype) || segtype_is_linear(seg->segtype)) {
 		ret = _convert_striped(cmd, lv, lp);
 		goto out;
 	}


