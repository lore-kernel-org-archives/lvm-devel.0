From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:38 -0500
Subject: master - cache: get and set cache params
Message-ID: <201703101835.v2AIZcGr031669@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c598e65de988663d2174f9d9b00408a1d50a075e
Commit:        c598e65de988663d2174f9d9b00408a1d50a075e
Parent:        861992d874a7f42619559bf3768750977b4b1446
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 16:20:44 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: get and set cache params

---
 tools/lvchange.c  |    3 ++-
 tools/lvconvert.c |   21 ++++-----------------
 tools/lvcreate.c  |    1 +
 tools/toollib.c   |    1 +
 tools/toollib.h   |    1 +
 5 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index d0d67b3..3804041 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -627,11 +627,12 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 	struct dm_config_tree *settings = NULL;
 	struct lv_segment *pool_seg = first_seg(lv);
 	int r = 0, is_clean;
+	uint32_t chunk_size = 0; /* FYI: lvchange does NOT support its change */
 
 	if (lv_is_cache(lv))
 		pool_seg = first_seg(pool_seg->pool_lv);
 
-	if (!get_cache_params(cmd, &mode, &name, &settings))
+	if (!get_cache_params(cmd, &chunk_size, &mode, &name, &settings))
 		goto_out;
 
 	if ((mode != CACHE_MODE_UNSELECTED) &&
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 45c5a49..f7210cc 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3046,7 +3046,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		cache_mode_t cache_mode = 0;
 		const char *policy_name = NULL;
 
-		if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
+		if (!get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
 			goto_bad;
 
 		if (cache_mode &&
@@ -3172,6 +3172,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 				   struct logical_volume *cachepool_lv)
 {
 	struct logical_volume *cache_lv;
+	uint32_t chunk_size = 0;
 	cache_mode_t cache_mode = 0;
 	const char *policy_name = NULL;
 	struct dm_config_tree *policy_settings = NULL;
@@ -3180,7 +3181,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
-	if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
+	if (!get_cache_params(cmd, &chunk_size, &cache_mode, &policy_name, &policy_settings))
 		goto_bad;
 
 	if (!archive(lv->vg))
@@ -3189,10 +3190,7 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
 		goto_bad;
 
-	if (!cache_set_cache_mode(first_seg(cache_lv), cache_mode))
-		goto_bad;
-
-	if (!cache_set_policy(first_seg(cache_lv), policy_name, policy_settings))
+	if (!cache_set_params(first_seg(cache_lv), chunk_size, cache_mode, policy_name, policy_settings))
 		goto_bad;
 
 	cache_check_for_warns(first_seg(cache_lv));
@@ -3814,7 +3812,6 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cachepool_lv;
 	const char *cachepool_name;
-	uint32_t chunk_size = 0;
 
 	if (!(cachepool_name = arg_str_value(cmd, cachepool_ARG, NULL)))
 		goto_out;
@@ -3863,16 +3860,6 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 			goto out;
 		}
 
-		if (arg_is_set(cmd, chunksize_ARG))
-			chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
-		if (!chunk_size)
-			chunk_size = first_seg(cachepool_lv)->chunk_size;
-
-		/* FIXME: why is chunk_size read and checked if it's not used? */
-
-		if (!validate_lv_cache_chunk_size(cachepool_lv, chunk_size))
-			goto_out;
-
 		/* Note: requires rather deep know-how to skip zeroing */
 		if (!arg_is_set(cmd, zero_ARG)) {
 		       	if (!arg_is_set(cmd, yes_ARG) &&
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 63b2c6d..80c97b0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -633,6 +633,7 @@ static int _read_cache_params(struct cmd_context *cmd,
 		return 1;
 
 	if (!get_cache_params(cmd,
+			      &lp->chunk_size,
 			      &lp->cache_mode,
 			      &lp->policy_name,
 			      &lp->policy_settings))
diff --git a/tools/toollib.c b/tools/toollib.c
index 4d746ea..3c00045 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1347,6 +1347,7 @@ static int _validate_cachepool_params(const char *name,
 }
 
 int get_cache_params(struct cmd_context *cmd,
+		     uint32_t *chunk_size,
 		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings)
diff --git a/tools/toollib.h b/tools/toollib.h
index 7c588fc..22ae491 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -221,6 +221,7 @@ int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtyp
 		      unsigned *stripes_supplied, unsigned *stripe_size_supplied);
 
 int get_cache_params(struct cmd_context *cmd,
+		     uint32_t *chunk_size,
 		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings);


