From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:41:59 +0000 (UTC)
Subject: master - lvconvert: better testing order
Message-ID: <20140722204159.5F15E60FA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c56c5fbacf6a4e9a0130b6f1fdc5683d6f108ec
Commit:        8c56c5fbacf6a4e9a0130b6f1fdc5683d6f108ec
Parent:        ab7bcc26f60edd529fc498a856f0dde2479919be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 18 12:19:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:38:59 2014 +0200

lvconvert: better testing order

Avoid duplicate tests through implicit calls - check directly
result of string assignment.
---
 tools/lvconvert.c |   49 ++++++++++++++++++++-----------------------------
 1 files changed, 20 insertions(+), 29 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 206c041..61b1660 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -234,7 +234,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	int cachepool = 0;
 	int thinpool = 0;
 
-	if (arg_count(cmd, cachepool_ARG)) {
+	if ((lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
 		if (type_str[0] &&
 		    strcmp(type_str, "cache") &&
 		    strcmp(type_str, "cache-pool")) {
@@ -242,13 +242,11 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				  " the cache or cache-pool segment type.");
 			return 0;
 		}
-		lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL);
 		cachepool = 1;
 		type_str = "cache-pool";
 	} else if (!strcmp(type_str, "cache-pool"))
 		cachepool = 1;
-
-	if (arg_count(cmd, thinpool_ARG)) {
+	else if ((lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
 		if (type_str[0] &&
 		    strcmp(type_str, "thin") &&
 		    strcmp(type_str, "thin-pool")) {
@@ -256,33 +254,18 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				  " the thin or thin-pool segment type.");
 			return 0;
 		}
-		lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL);
 		thinpool = 1;
 		type_str = "thin-pool";
 	} else if (!strcmp(type_str, "thin-pool"))
 		thinpool = 1;
 
-	if (thinpool) {
-		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-		lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL);
-	} else {
-		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
-					 discards_ARG, originname_ARG, zero_ARG,
-					 -1))
-			return_0;
-		if (lp->thin) {
-			log_error("--thin requires --thinpool.");
-			return 0;
-		}
-	}
-
 	if (cachepool) {
 		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL)) &&
 		    !get_cache_mode(tmp_str, &lp->feature_flags))
 			return_0;
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
-					 cachemode_ARG, -1))
+					 cachepool_ARG, cachemode_ARG, -1))
 			return_0;
 		if (lp->cache) {
 			log_error("--cache requires --cachepool.");
@@ -290,6 +273,20 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 		}
 	}
 
+	if (thinpool) {
+		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+		lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL);
+	} else {
+		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
+					 discards_ARG, originname_ARG, thinpool_ARG,
+					 zero_ARG, -1))
+			return_0;
+		if (lp->thin) {
+			log_error("--thin requires --thinpool.");
+			return 0;
+		}
+	}
+
 	if (thinpool || cachepool) {
 		if (arg_from_list_is_set(cmd, "is invalid with pools",
 					 merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
@@ -308,7 +305,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 			/* value is read in get_pool_params() */
 		}
 
-		if (arg_count(cmd, poolmetadata_ARG)) {
+		if ((lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
 			if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
 				log_error("Can't use --stripes and --stripesize with --poolmetadata.");
 				return 0;
@@ -318,11 +315,6 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				log_error("Can't use --readahead with --poolmetadata.");
 				return 0;
 			}
-
-			if (!(lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
-				log_error("Missing --poolmetadata argument.");
-				return 0;
-			}
 		}
 
 		if (arg_count(cmd, chunksize_ARG) &&
@@ -331,14 +323,13 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 			return 0;
 		}
 
-		if (!arg_count(cmd, cachepool_ARG) &&
-		    !arg_count(cmd, thinpool_ARG)) {
+		if (!lp->pool_data_lv_name) {
 			if (!*pargc) {
 				log_error("Please specify the pool data LV.");
 				return 0;
 			}
 			lp->pool_data_lv_name = (*pargv)[0];
-                        (*pargv)++, (*pargc)--;
+			(*pargv)++, (*pargc)--;
 		}
 
 		if (!lp->thin && !lp->cache)


