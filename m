From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Jul 2016 20:11:31 +0000 (UTC)
Subject: master - lvconvert: Remove hard-coded segment names.
Message-ID: <20160729201131.4E08260DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=800c0d3dd696b8574494788f38d61ca26ba68159
Commit:        800c0d3dd696b8574494788f38d61ca26ba68159
Parent:        237f84e0383c7e3003050be7c072ee0a092fd426
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 29 21:11:12 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 29 21:11:12 2016 +0100

lvconvert: Remove hard-coded segment names.

---
 tools/lvconvert.c |  116 ++++++++++++++++++++++++++--------------------------
 1 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 62c21bd..9e850b3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -53,8 +53,9 @@ struct lvconvert_params {
 	int thin;
 	int uncache;
 	const char *type_str;	/* When this is set, mirrors_supplied may optionally also be set */
+				/* Holds what you asked for based on --type or other arguments, else "" */
 
-	const struct segment_type *segtype;
+	const struct segment_type *segtype;	/* Holds what segment type you will get */
 
 	int merge_snapshot;	/* merge is also set */
 	int merge_mirror;	/* merge is also set */
@@ -273,57 +274,56 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	return 1;
 }
 
-static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
-{
-	if (!type_str || !*type_str)
-		return 1;
-
-	if (!strcmp(type_str, "mirror")) {
-		if (!arg_is_set(cmd, mirrors_ARG)) {
-			log_error("Conversions to --type mirror require -m/--mirrors");
-			return 0;
-		}
-		return 1;
-	}
-
-	/* FIXME: Check thin-pool and thin more thoroughly! */
-	if (!strcmp(type_str, "snapshot") || !strcmp(type_str, "linear") ||
-	    !strcmp(type_str, "striped") ||
-	    !strncmp(type_str, "raid", 4) ||
-	    !strcmp(type_str, "cache-pool") || !strcmp(type_str, "cache") ||
-	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
-		return 1;
-
-	log_error("Conversion using --type %s is not supported.", type_str);
-	return 0;
-}
-
 /* -s/--snapshot and --type snapshot are synonyms */
 static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str)
 {
-	return (arg_is_set(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
+	return (arg_is_set(cmd, snapshot_ARG) || !strcmp(type_str, SEG_TYPE_NAME_SNAPSHOT));
 }
 
-static int _raid0_type_requested(struct cmd_context *cmd, const char *type_str)
+static int _raid0_type_requested(const char *type_str)
 {
-	return (!strcmp(type_str, "raid0") || !strcmp(type_str, "raid0_meta"));
+	return (!strcmp(type_str, SEG_TYPE_NAME_RAID0) || !strcmp(type_str, SEG_TYPE_NAME_RAID0_META));
 }
 
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
 static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str)
 {
-	return (arg_is_set(cmd, mirrors_ARG) || !strcmp(type_str, "mirror") ||
-		(!strncmp(type_str, "raid", 4) && !_raid0_type_requested(cmd, type_str)));
+	return (arg_is_set(cmd, mirrors_ARG) || !strcmp(type_str, SEG_TYPE_NAME_MIRROR) ||
+		(!strncmp(type_str, SEG_TYPE_NAME_RAID, 4) && !_raid0_type_requested(type_str)));
 }
 
-static int _striped_type_requested(struct cmd_context *cmd, const char *type_str)
+static int _linear_type_requested(const char *type_str)
 {
-	return (!strcmp(type_str, SEG_TYPE_NAME_STRIPED) || !strcmp(type_str, SEG_TYPE_NAME_LINEAR));
+	return (!strcmp(type_str, SEG_TYPE_NAME_LINEAR));
 }
 
-static int _linear_type_requested(const char *type_str)
+static int _striped_type_requested(const char *type_str)
 {
-	return (!strcmp(type_str, SEG_TYPE_NAME_LINEAR));
+	return (!strcmp(type_str, SEG_TYPE_NAME_STRIPED) || _linear_type_requested(type_str));
+}
+
+static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
+{
+	if (!type_str || !*type_str)
+		return 1;
+
+	if (!strcmp(type_str, SEG_TYPE_NAME_MIRROR)) {
+		if (!arg_is_set(cmd, mirrors_ARG)) {
+			log_error("Conversions to --type mirror require -m/--mirrors");
+			return 0;
+		}
+		return 1;
+	}
+
+	/* FIXME: Check thin-pool and thin more thoroughly! */
+	if (!strcmp(type_str, SEG_TYPE_NAME_SNAPSHOT) || _striped_type_requested(type_str) ||
+	    !strncmp(type_str, SEG_TYPE_NAME_RAID, 4) ||
+	    !strcmp(type_str, SEG_TYPE_NAME_CACHE_POOL) || !strcmp(type_str, SEG_TYPE_NAME_CACHE) ||
+	    !strcmp(type_str, SEG_TYPE_NAME_THIN_POOL) || !strcmp(type_str, SEG_TYPE_NAME_THIN))
+		return 1;
+
+	log_error("Conversion using --type %s is not supported.", type_str);
+	return 0;
 }
 
 static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
@@ -334,27 +334,27 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 
 	if ((lp->pool_data_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
 		if (lp->type_str[0] &&
-		    strcmp(lp->type_str, "cache") &&
-		    strcmp(lp->type_str, "cache-pool")) {
+		    strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) &&
+		    strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL)) {
 			log_error("--cachepool argument is only valid with "
 				  "the cache or cache-pool segment type.");
 			return 0;
 		}
 		cachepool = 1;
-		lp->type_str = "cache-pool";
-	} else if (!strcmp(lp->type_str, "cache-pool"))
+		lp->type_str = SEG_TYPE_NAME_CACHE_POOL;
+	} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL))
 		cachepool = 1;
 	else if ((lp->pool_data_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
 		if (lp->type_str[0] &&
-		    strcmp(lp->type_str, "thin") &&
-		    strcmp(lp->type_str, "thin-pool")) {
+		    strcmp(lp->type_str, SEG_TYPE_NAME_THIN) &&
+		    strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL)) {
 			log_error("--thinpool argument is only valid with "
 				  "the thin or thin-pool segment type.");
 			return 0;
 		}
 		thinpool = 1;
-		lp->type_str = "thin-pool";
-	} else if (!strcmp(lp->type_str, "thin-pool"))
+		lp->type_str = SEG_TYPE_NAME_THIN_POOL;
+	} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL))
 		thinpool = 1;
 
 	if (lp->cache && !cachepool) {
@@ -505,27 +505,27 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (arg_is_set(cmd, cache_ARG))
 		lp->cache = 1;
 
-	if (!strcmp(lp->type_str, "cache"))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE))
 		lp->cache = 1;
 	else if (lp->cache) {
 		if (lp->type_str[0]) {
 			log_error("--cache is incompatible with --type %s", lp->type_str);
 			return 0;
 		}
-		lp->type_str = "cache";
+		lp->type_str = SEG_TYPE_NAME_CACHE;
 	}
 
 	if (arg_is_set(cmd, thin_ARG))
 		lp->thin = 1;
 
-	if (!strcmp(lp->type_str, "thin"))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN))
 		lp->thin = 1;
 	else if (lp->thin) {
 		if (lp->type_str[0]) {
 			log_error("--thin is incompatible with --type %s", lp->type_str);
 			return 0;
 		}
-		lp->type_str = "thin";
+		lp->type_str = SEG_TYPE_NAME_THIN;
 	}
 
 	/* May set lp->segtype */
@@ -594,12 +594,12 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
 	    !lp->replace && !lp->repair && !lp->mirrorlog && !lp->corelog &&
 	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
-		lp->type_str = "striped";
+		lp->type_str = SEG_TYPE_NAME_STRIPED;
 
 	if ((_snapshot_type_requested(cmd, lp->type_str) || lp->merge) &&
 	    (lp->mirrorlog || _mirror_or_raid_type_requested(cmd, lp->type_str) ||
-	     lp->repair || arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(cmd, lp->type_str) ||
-	     _striped_type_requested(cmd, lp->type_str))) {
+	     lp->repair || arg_is_set(cmd, thinpool_ARG) || _raid0_type_requested(lp->type_str) ||
+	     _striped_type_requested(lp->type_str))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
 			  "cannot be mixed with --mirrors/--type mirror/--type raid*/--stripes/--type striped/--type linear, "
 			  "--mirrorlog, --repair or --thinpool.");
@@ -607,8 +607,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
-	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str) ||
-	      _raid0_type_requested(cmd, lp->type_str) || lp->repair || arg_is_set(cmd, thinpool_ARG))) {
+	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(lp->type_str) ||
+	      _raid0_type_requested(lp->type_str) || lp->repair || arg_is_set(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
 			  "with --mirrors/--type mirror/--type raid*/--type striped/--type linear, --repair and --thinpool");
 		return 0;
@@ -786,7 +786,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
 		}
-	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or linear or raid0 */
+	} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
 		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
 					 -1))
@@ -1897,10 +1897,10 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		/* --trackchanges requires --splitmirrors which always has SIGN_MINUS */
 		if (lp->track_changes && lp->mirrors != 1) {
-                        log_error("Exactly one image must be split off from %s when tracking changes.",
+			log_error("Exactly one image must be split off from %s when tracking changes.",
 				  display_lvname(lv));
-                        return 0;
-                }
+			return 0;
+		}
 	}
 
 	if (lp->merge_mirror)
@@ -4366,8 +4366,8 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
  *
  * for each lvtype,
  *     _convert_lvtype();
- *         for each arg_is_set(operation)
- *             _convert_lvtype_operation();
+ *	 for each arg_is_set(operation)
+ *	     _convert_lvtype_operation();
  *
  */
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,


