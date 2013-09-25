From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Sep 2013 14:08:29 +0000 (UTC)
Subject: master - thin: use appropriate default value based on allocation/thin_pool_chunk_size_calculation setting
Message-ID: <20130925140829.A686160F43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc9e65c391f9070c4b06a94a0ffdb9c61cf89c13
Commit:        cc9e65c391f9070c4b06a94a0ffdb9c61cf89c13
Parent:        8bf425005c8a25e9b99a617a6cf7d9d826ad5f6a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 25 16:00:52 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 25 16:06:38 2013 +0200

thin: use appropriate default value based on allocation/thin_pool_chunk_size_calculation setting

If thin_pool_chunk_size_calculation is set to "default", use 64KiB,
otheriwse 512KiB for "performance".
---
 lib/config/config_settings.h     |    2 +-
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |   11 ++++++--
 lib/metadata/thin_manip.c        |   48 ++++++++++++++++++++++++++++++--------
 tools/lvconvert.c                |   15 ++++++-----
 tools/lvcreate.c                 |    2 +
 tools/toollib.c                  |    4 ++-
 tools/toollib.h                  |    1 +
 8 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8ea2c92..f7c1330 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -108,7 +108,7 @@ cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_chunk_size_calculation_CFG, "thin_pool_chunk_size_calculation", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION, vsn(2, 2, 101), NULL)
-cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_CHUNK_SIZE, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, 0, vsn(2, 2, 99), NULL)
 
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 361d927..5aacea1 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -73,6 +73,7 @@
 #define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION "default"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
+#define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3920385..71fe393 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -659,11 +659,13 @@ int pool_is_active(const struct logical_volume *pool_lv);
 int pool_can_resize_metadata(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
-				  int passed_args, uint32_t *chunk_size,
-				  thin_discards_t *discards, int *zero);
+				  int passed_args, int *chunk_size_calc_method,
+				  uint32_t *chunk_size, thin_discards_t *discards,
+				  int *zero);
 int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
-		       uint32_t *chunk_size, thin_discards_t *discards,
+		       int *chunk_size_calc_method, uint32_t *chunk_size,
+		       thin_discards_t *discards,
 		       uint64_t *pool_metadata_size, int *zero);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
@@ -724,6 +726,9 @@ struct lvcreate_params {
 	int activation_skip; /* activation skip flags */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
+#define THIN_CHUNK_SIZE_CALC_METHOD_DEFAULT 0x01
+#define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
+	int thin_chunk_size_calc_method;
 
 	const char *origin; /* snap */
 	const char *pool;   /* thin */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 971ffe6..c71b971 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -569,14 +569,40 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
+static int _get_pool_chunk_size_calc(const char *str,
+				     int *chunk_size_calc_method,
+				     uint32_t *chunk_size)
+{
+	if (!strcasecmp(str, "default")) {
+		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_DEFAULT;
+		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
+	}
+	else if (!strcasecmp(str, "performance")) {
+		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE;
+		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
+	}
+	else {
+		log_error("Thin pool chunk size calculation method \"%s\" is unknown.", str);
+		return 0;
+	}
+
+	return 1;
+}
+
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
-				  int passed_args, uint32_t *chunk_size,
-				  thin_discards_t *discards, int *zero)
+				  int passed_args, int *chunk_size_calc_method,
+				  uint32_t *chunk_size, thin_discards_t *discards,
+				  int *zero)
 {
-	const char *dstr;
+	const char *str;
 
-	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
-		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
+	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
+			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_calculation_CFG, profile);
+			if (!_get_pool_chunk_size_calc(str, chunk_size_calc_method, chunk_size))
+				return_0;
+		}
+	}
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
@@ -587,8 +613,8 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	}
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {
-		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
-		if (!get_pool_discards(dstr, discards))
+		str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
+		if (!get_pool_discards(str, discards))
 			return_0;
 	}
 
@@ -600,14 +626,16 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 
 int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
-		       uint32_t *chunk_size, thin_discards_t *discards,
-		       uint64_t *pool_metadata_size, int *zero)
+		       int *chunk_size_calc_method, uint32_t *chunk_size,
+		       thin_discards_t *discards, uint64_t *pool_metadata_size,
+		       int *zero)
 {
 	size_t estimate_chunk_size;
 	struct cmd_context *cmd = vg->cmd;
 
 	if (!update_profilable_pool_params(cmd, vg->profile, passed_args,
-					   chunk_size, discards, zero))
+					   chunk_size_calc_method, chunk_size,
+					   discards, zero))
 		return_0;
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2a3c827..bbcfff7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -34,6 +34,7 @@ struct lvconvert_params {
 	int wait_completion;
 	int need_polling;
 
+	int thin_chunk_size_calc_method;
 	uint32_t chunk_size;
 	uint32_t region_size;
 
@@ -2328,8 +2329,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	if (!lp->pool_metadata_lv_name) {
 		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadata_size, &lp->zero))
+					&lp->thin_chunk_size_calc_method, &lp->chunk_size,
+					&lp->discards, &lp->poolmetadata_size, &lp->zero))
 			return_0;
 
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
@@ -2440,8 +2441,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadata_size, &lp->zero))
+					&lp->thin_chunk_size_calc_method, &lp->chunk_size,
+					&lp->discards, &lp->poolmetadata_size, &lp->zero))
 			return_0;
 	}
 
@@ -2710,9 +2711,9 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 
 	if (arg_count(cmd, thinpool_ARG) &&
 	    !get_pool_params(cmd, lv_config_profile(lv),
-			     &lp->passed_args, &lp->chunk_size,
-			     &lp->discards, &lp->poolmetadata_size,
-			     &lp->zero))
+			     &lp->passed_args, &lp->thin_chunk_size_calc_method,
+			     &lp->chunk_size, &lp->discards,
+			     &lp->poolmetadata_size, &lp->zero))
 		goto_bad;
 
 	/*
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 095adbb..c5a2e20 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -336,6 +336,7 @@ static int _update_extents_params(struct volume_group *vg,
 	if (lp->create_thin_pool) {
 		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
 					lp->extents, vg->extent_size,
+					&lp->thin_chunk_size_calc_method,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadatasize, &lp->zero))
 			return_0;
@@ -876,6 +877,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_thin_pool &&
 	     !get_pool_params(cmd, NULL, &lp->passed_args,
+			      &lp->thin_chunk_size_calc_method,
 			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
diff --git a/tools/toollib.c b/tools/toollib.c
index 099e82b..9b3e842 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1631,6 +1631,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 int get_pool_params(struct cmd_context *cmd,
 		    struct profile *profile,
 		    int *passed_args,
+		    int *chunk_size_calc_method,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
@@ -1663,7 +1664,8 @@ int get_pool_params(struct cmd_context *cmd,
 	}
 
 	if (!update_profilable_pool_params(cmd, profile, *passed_args,
-					   chunk_size, discards, zero))
+					   chunk_size_calc_method, chunk_size,
+					   discards, zero))
 		return_0;
 
 	if (arg_count(cmd, poolmetadatasize_ARG)) {
diff --git a/tools/toollib.h b/tools/toollib.h
index cd9ca49..d831b95 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -119,6 +119,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 int get_pool_params(struct cmd_context *cmd,
 		    struct profile *profile,
 		    int *passed_args,
+		    int *chunk_size_calc_method,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,


