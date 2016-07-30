From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 01:11:26 +0000 (UTC)
Subject: master - tools: Unify stripesize parameter validation.
Message-ID: <20160730011126.45CEF61007@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ffe15bf6aec1ef8a14d3c070fc6b9bbb40cd4b0
Commit:        4ffe15bf6aec1ef8a14d3c070fc6b9bbb40cd4b0
Parent:        d01b1b6cc14885670516653771077fefc9e94788
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 02:05:50 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 02:05:50 2016 +0100

tools: Unify stripesize parameter validation.

Move it all into get_stripe_params().
Some code paths missed --stripesize checks.
E.g. lvcreate --type raid4 -i1
---
 WHATS_NEW              |    1 +
 lib/metadata/segtype.h |    3 +++
 tools/lvconvert.c      |    6 +++---
 tools/lvcreate.c       |   14 ++------------
 tools/toollib.c        |   40 ++++++++++++++++++++++++----------------
 tools/toollib.h        |    4 ++--
 6 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8474644..2e81ab0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Unify stripe size validation into get_stripe_params to catch missing cases.
   Further lvconvert validation logic refactoring.
 
 Version 2.02.162 - 28th July 2016
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2afb02a..f39007f 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -131,6 +131,9 @@ struct dev_manager;
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 #define segtype_is_unknown(segtype)	((segtype)->flags & SEG_UNKNOWN ? 1 : 0)
 
+#define segtype_supports_stripe_size(segtype)	\
+	((segtype_is_striped(segtype) || (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
+
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4a5956e..33c7ffb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -812,11 +812,10 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	/* FIXME This is incomplete */
 	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
 	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
 			return_0;
 
 		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
-
 			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
 			/* The default keeps existing number of stripes, handled inside the library code */
 			if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
@@ -3145,7 +3144,8 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+		if (!get_stripe_params(cmd, get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED),
+				       &lp->stripes, &lp->stripe_size))
 			return_0;
 
 		if (!archive(vg))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5e3ddbb..253fab8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -495,9 +495,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 				  lp->segtype->name);
 			return 0;
 		}
-
-	} else if (!lp->stripe_size)
-		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+	}
 
 	if (arg_is_set(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
 	    !segtype_is_raid1(lp->segtype) && !segtype_is_raid10(lp->segtype)) {
@@ -572,14 +570,6 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/*
-	 * FIXME This is working around a bug in get_stripe_params() where 
-	 * stripes is incorrectly assumed to be 1 when it is not supplied
-	 * leading to the actual value of stripesize getting lost.
-	 */
-	if (arg_is_set(cmd, stripesize_ARG))
-		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
-
 	if (!is_power_of_2(lp->region_size)) {
 		log_error("Region size (%" PRIu32 ") must be a power of 2",
 			  lp->region_size);
@@ -1044,7 +1034,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 	if (!_lvcreate_name_params(cmd, &argc, &argv, lp) ||
 	    !_read_size_params(cmd, lp, lcp) ||
-	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_pool &&
 	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
diff --git a/tools/toollib.c b/tools/toollib.c
index a76599c..4cd9020 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1273,18 +1273,32 @@ int get_pool_params(struct cmd_context *cmd,
 /*
  * Generic stripe parameter checks.
  */
-static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
-				   uint32_t *stripe_size)
+static int _validate_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
+				   uint32_t *stripes, uint32_t *stripe_size)
 {
-	if (*stripes == 1 && *stripe_size) {
+	int stripe_size_required = segtype_supports_stripe_size(segtype);
+
+	if (!stripe_size_required && *stripe_size) {
+		log_print_unless_silent("Ignoring stripesize argument for %s devices.", segtype->name);
+		*stripe_size = 0;
+	} else if (segtype_is_striped(segtype) && *stripes == 1 && *stripe_size) {
 		log_print_unless_silent("Ignoring stripesize argument with single stripe.");
+		stripe_size_required = 0;
 		*stripe_size = 0;
 	}
 
-	if (*stripes > 1 && !*stripe_size) {
-		*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-		log_print_unless_silent("Using default stripesize %s.",
-			  display_size(cmd, (uint64_t) *stripe_size));
+	if (stripe_size_required) {
+		if (!*stripe_size) {
+			*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+			log_print_unless_silent("Using default stripesize %s.",
+						display_size(cmd, (uint64_t) *stripe_size));
+		}
+
+		if (*stripe_size < STRIPE_SIZE_MIN || !is_power_of_2(*stripe_size)) {
+			log_error("Invalid stripe size %s.",
+				  display_size(cmd, (uint64_t) *stripe_size));
+			return 0;
+		}
 	}
 
 	if (*stripes < 1 || *stripes > MAX_STRIPES) {
@@ -1293,13 +1307,6 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		return 0;
 	}
 
-	if (*stripes > 1 && (*stripe_size < STRIPE_SIZE_MIN ||
-			     !is_power_of_2(*stripe_size))) {
-		log_error("Invalid stripe size %s.",
-			  display_size(cmd, (uint64_t) *stripe_size));
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -1309,9 +1316,10 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
  * power of 2, we must divide UINT_MAX by four and add 1 (to round it
  * up to the power of 2)
  */
-int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stripe_size)
+int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t *stripes, uint32_t *stripe_size)
 {
 	/* stripes_long_ARG takes precedence (for lvconvert) */
+	/* FIXME Cope with relative +/- changes for lvconvert. */
 	*stripes = arg_uint_value(cmd, arg_is_set(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
 
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
@@ -1328,7 +1336,7 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 		}
 	}
 
-	return _validate_stripe_params(cmd, stripes, stripe_size);
+	return _validate_stripe_params(cmd, segtype, stripes, stripe_size);
 }
 
 static int _validate_cachepool_params(const char *name,
diff --git a/tools/toollib.h b/tools/toollib.h
index 42e7f7a..ed5ec76 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -201,8 +201,8 @@ int get_pool_params(struct cmd_context *cmd,
 		    thin_discards_t *discards,
 		    int *zero);
 
-int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
-		      uint32_t *stripe_size);
+int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
+		      uint32_t *stripes, uint32_t *stripe_size);
 
 int get_cache_params(struct cmd_context *cmd,
 		     cache_mode_t *cache_mode,


