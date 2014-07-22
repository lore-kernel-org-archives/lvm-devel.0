From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:41:57 +0000 (UTC)
Subject: master - tools: switch logic for new arg_ func
Message-ID: <20140722204157.4649C60FA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab7bcc26f60edd529fc498a856f0dde2479919be
Commit:        ab7bcc26f60edd529fc498a856f0dde2479919be
Parent:        864ff3cb181183ccfabc8a2e3c53ddcd1e36390f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 18 21:56:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:38:59 2014 +0200

tools: switch logic for new arg_ func

Revert logic and rename new arg_ functions to:

arg_from_list_is_set()
arg_outside_list_is_set()

When err_found is given, log_error message is automaticaly
printed.
---
 tools/lvconvert.c  |   58 ++++++++++++++++++++++++++--------------------------
 tools/lvmcmdline.c |   28 ++++++++++++++----------
 tools/tools.h      |    4 +-
 3 files changed, 47 insertions(+), 43 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 63a1d98..206c041 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -266,9 +266,9 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
 		lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL);
 	} else {
-		if (!arg_is_any_set(cmd, "is valid only with thin pools",
-				    discards_ARG, originname_ARG, zero_ARG,
-				    -1))
+		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
+					 discards_ARG, originname_ARG, zero_ARG,
+					 -1))
 			return_0;
 		if (lp->thin) {
 			log_error("--thin requires --thinpool.");
@@ -281,8 +281,8 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 		    !get_cache_mode(tmp_str, &lp->feature_flags))
 			return_0;
 	} else {
-		if (!arg_is_any_set(cmd, "is valid only with cache pools",
-				    cachemode_ARG, -1))
+		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
+					 cachemode_ARG, -1))
 			return_0;
 		if (lp->cache) {
 			log_error("--cache requires --cachepool.");
@@ -291,9 +291,9 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	}
 
 	if (thinpool || cachepool) {
-		if (!arg_is_any_set(cmd, "is invalid with pools",
-				    merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
-				    splitmirrors_ARG, -1))
+		if (arg_from_list_is_set(cmd, "is invalid with pools",
+					 merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
+					 splitmirrors_ARG, -1))
 			return_0;
 
 		if (arg_count(cmd, poolmetadatasize_ARG)) {
@@ -349,9 +349,9 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
 			return_0;
-	} else if (!arg_is_any_set(cmd, "is valid only with pools",
-				   poolmetadatasize_ARG, poolmetadataspare_ARG,
-				   -1))
+	} else if (arg_from_list_is_set(cmd, "is valid only with pools",
+					poolmetadatasize_ARG, poolmetadataspare_ARG,
+					-1))
 		return_0;
 
 	return 1;
@@ -374,12 +374,12 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return_0;
 
 	if (arg_count(cmd, repair_ARG) &&
-	    !arg_is_only_set(cmd, "cannot be used with --repair",
-			     repair_ARG,
-			     alloc_ARG, use_policies_ARG,
-			     stripes_long_ARG, stripesize_ARG,
-			     force_ARG, noudevsync_ARG, test_ARG,
-			     -1))
+	    arg_outside_list_is_set(cmd, "cannot be used with --repair",
+				    repair_ARG,
+				    alloc_ARG, use_policies_ARG,
+				    stripes_long_ARG, stripesize_ARG,
+				    force_ARG, noudevsync_ARG, test_ARG,
+				    -1))
 		return_0;
 
 	if (arg_is_set(cmd, mirrorlog_ARG) && arg_is_set(cmd, corelog_ARG)) {
@@ -388,10 +388,10 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	}
 
 	if (arg_is_set(cmd, splitsnapshot_ARG)) {
-		if (!arg_is_only_set(cmd, "cannot be used with --splitsnapshot",
-				     splitsnapshot_ARG,
-				     force_ARG, noudevsync_ARG, test_ARG,
-				     -1))
+		if (arg_outside_list_is_set(cmd, "cannot be used with --splitsnapshot",
+					    splitsnapshot_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
 			return_0;
 		lp->splitsnapshot = 1;
 	}
@@ -504,11 +504,11 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	/* There are six types of lvconvert. */
 	if (lp->merge) {	/* Snapshot merge */
-		if (!arg_is_only_set(cmd, "cannot be used with --merge",
-				     merge_ARG,
-				     background_ARG, interval_ARG,
-				     force_ARG, noudevsync_ARG, test_ARG,
-				     -1))
+		if (arg_outside_list_is_set(cmd, "cannot be used with --merge",
+					    merge_ARG,
+					    background_ARG, interval_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
 			return_0;
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
@@ -2796,9 +2796,9 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		lp->pool_data_lv = pool_lv;
 
 		if (!metadata_lv) {
-			if (!arg_is_any_set(cmd, "is invalid with existing pool",
-					    cachemode_ARG,chunksize_ARG, discards_ARG,
-					    zero_ARG, poolmetadatasize_ARG, -1))
+			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
+						 cachemode_ARG,chunksize_ARG, discards_ARG,
+						 zero_ARG, poolmetadatasize_ARG, -1))
 				return_0;
 			return 1;
 		}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4654978..10dac8f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -68,25 +68,26 @@ unsigned arg_is_set(const struct cmd_context *cmd, int a)
 	return arg_count(cmd, a) ? 1 : 0;
 }
 
-int arg_is_any_set(const struct cmd_context *cmd, const char *err, ...)
+int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, ...)
 {
 	int arg;
 	va_list ap;
 
-	va_start(ap, err);
+	va_start(ap, err_found);
 	while ((arg = va_arg(ap, int)) != -1 && !arg_count(cmd, arg))
 		/* empty */;
 	va_end(ap);
 
-	if (arg != -1) {
-		log_error("%s %s.", arg_long_option_name(arg), err);
+	if (arg == -1)
 		return 0;
-	}
+
+	if (err_found)
+		log_error("%s %s.", arg_long_option_name(arg), err_found);
 
 	return 1;
 }
 
-int arg_is_only_set(const struct cmd_context *cmd, const char *err, ...)
+int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found, ...)
 {
 	int i, arg;
 	va_list ap;
@@ -109,18 +110,21 @@ int arg_is_only_set(const struct cmd_context *cmd, const char *err, ...)
 		}
 		if (!arg_count(cmd, i))
 			continue; /* unset */
-		va_start(ap, err);
+		va_start(ap, err_found);
 		while (((arg = va_arg(ap, int)) != -1) && (arg != i))
 			/* empty */;
 		va_end(ap);
 
-		if (arg != i) {
-			log_error("Option %s %s.", arg_long_option_name(i), err);
-			return 0;
-		}
+		if (arg == i)
+			continue; /* set and in list */
+
+		if (err_found)
+			log_error("Option %s %s.", arg_long_option_name(i), err_found);
+
+		return 1;
 	}
 
-	return 1;
+	return 0;
 }
 
 unsigned grouped_arg_is_set(const struct arg_values *av, int a)
diff --git a/tools/tools.h b/tools/tools.h
index a92845a..beb1671 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -144,8 +144,8 @@ int major_minor_valid(const struct cmd_context * cmd, const struct format_type *
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
-int arg_is_any_set(const struct cmd_context *cmd, const char *err, ...);
-int arg_is_only_set(const struct cmd_context *cmd, const char *err, ...);
+int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
+int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
 const char *arg_long_option_name(int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);


