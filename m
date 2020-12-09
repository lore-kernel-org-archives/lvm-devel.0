From: David Teigland <teigland@sourceware.org>
Date: Wed,  9 Dec 2020 23:40:45 +0000 (GMT)
Subject: main - cache: activation cache_check on cachevol
Message-ID: <20201209234045.A9E0A386F820@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fe7aba251ff24c14277dfdf9be2d861a7699230
Commit:        9fe7aba251ff24c14277dfdf9be2d861a7699230
Parent:        57594fe673587ea33a6521733376862055ecbd65
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 9 17:36:09 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 9 17:36:09 2020 -0600

cache: activation cache_check on cachevol

When using cache with a cachevol, the cache_check tool was
not being run on the cache metadata during activation.
cache_check clears the needs_check flag in the cache
metadata, so if the flag was set due to an unclean
shutdown, the activation would fail.
---
 lib/activate/dev_manager.c | 36 ++++++++++++++++++++++++------------
 lib/metadata/lv.c          | 31 +++++++++++++++++++++++++++++++
 lib/metadata/lv.h          |  3 +++
 3 files changed, 58 insertions(+), 12 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 85cfda246..8d27bd363 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2270,21 +2270,31 @@ static int _pool_callback(struct dm_tree_node *node,
 	const struct pool_cb_data *data = cb_data;
 	const struct logical_volume *pool_lv = data->pool_lv;
 	const struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
+	struct cmd_context *cmd = pool_lv->vg->cmd;
 	long buf[64 / sizeof(long)]; /* buffer for short disk header (64B) */
 	int args = 0;
 	char *mpath;
 	const char *argv[19] = { /* Max supported 15 args */
-		find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL)
+		find_config_tree_str_allow_empty(cmd, data->exec, NULL)
 	};
 
 	if (!*argv[0]) /* *_check tool is unconfigured/disabled with "" setting */
 		return 1;
 
-	if (!(mpath = lv_dmpath_dup(data->dm->mem, mlv))) {
-		log_error("Failed to build device path for checking pool metadata %s.",
-			  display_lvname(mlv));
-		return 0;
+	if (lv_is_cache_vol(pool_lv)) {
+		if (!(mpath = lv_dmpath_suffix_dup(data->dm->mem, pool_lv, "-cmeta"))) {
+			log_error("Failed to build device path for checking cachevol metadata %s.",
+			  	 display_lvname(pool_lv));
+			return 0;
+		}
+	} else {
+		if (!(mpath = lv_dmpath_dup(data->dm->mem, mlv))) {
+			log_error("Failed to build device path for checking pool metadata %s.",
+			  	 display_lvname(mlv));
+			return 0;
+		}
 	}
+	log_debug("Running check command on %s", mpath);
 
 	if (data->skip_zero) {
 		if ((fd = open(mpath, O_RDONLY)) < 0) {
@@ -2312,7 +2322,7 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 	}
 
-	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL))) {
+	if (!(cn = find_config_tree_array(cmd, data->opts, NULL))) {
 		log_error(INTERNAL_ERROR "Unable to find configuration for pool check options.");
 		return 0;
 	}
@@ -2334,7 +2344,7 @@ static int _pool_callback(struct dm_tree_node *node,
 
 	argv[++args] = mpath;
 
-	if (!(ret = exec_cmd(pool_lv->vg->cmd, (const char * const *)argv,
+	if (!(ret = exec_cmd(cmd, (const char * const *)argv,
 			     &status, 0))) {
 		if (status == ENOENT) {
 			log_warn("WARNING: Check is skipped, please install recommended missing binary %s!",
@@ -2343,7 +2353,7 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 
 		if ((data->version.maj || data->version.min || data->version.patch) &&
-		    !_check_tool_version(pool_lv->vg->cmd, argv[0],
+		    !_check_tool_version(cmd, argv[0],
 					 data->version.maj, data->version.min, data->version.patch)) {
 			log_warn("WARNING: Check is skipped, please upgrade installed version of %s!",
 				 argv[0]);
@@ -2387,10 +2397,6 @@ static int _pool_register_callback(struct dev_manager *dm,
 		return 1;
 #endif
 
-	/* Skip for single-device cache pool */
-	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv))
-		return 1;
-
 	if (!(data = dm_pool_zalloc(dm->mem, sizeof(*data)))) {
 		log_error("Failed to allocated path for callback.");
 		return 0;
@@ -3483,6 +3489,12 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv) &&
+	    /* Register callback only for layer activation or non-layered cache LV */
+	    (layer || !lv_layer(lv)) &&
+	    !_pool_register_callback(dm, dnode, lv))
+		return_0;
+
 	/*
 	 * Update tables for ANY PVMOVE holders for active LV where the name starts with 'pvmove',
 	 * but it's not anymore PVMOVE LV and also it's not a PVMOVE _mimage LV.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index fac47e530..475f21191 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1034,6 +1034,37 @@ char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return repstr;
 }
 
+/* maybe factor a common function with lv_dmpath_dup */
+char *lv_dmpath_suffix_dup(struct dm_pool *mem, const struct logical_volume *lv,
+			   const char *suffix)
+{
+	char *name;
+	char *repstr;
+	size_t len;
+
+	if (!*lv->vg->name)
+		return dm_pool_strdup(mem, "");
+
+	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
+		log_error("dm_build_dm_name failed");
+		return NULL;
+	}
+
+	len = strlen(dm_dir()) + strlen(name) + strlen(suffix) + 2;
+
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (dm_snprintf(repstr, len, "%s/%s%s", dm_dir(), name, suffix) < 0) {
+		log_error("lv_dmpath snprintf failed");
+		return NULL;
+	}
+
+	return repstr;
+}
+
 char *lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return id_format_and_copy(mem ? mem : lv->vg->vgmem, &lv->lvid.id[1]);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index e2e640f5d..28bd4b869 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -194,6 +194,9 @@ char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 
+char *lv_dmpath_suffix_dup(struct dm_pool *mem, const struct logical_volume *lv,
+                           const char *suffix);
+
 typedef enum {
 	PERCENT_GET_DATA = 0,
 	PERCENT_GET_METADATA,


