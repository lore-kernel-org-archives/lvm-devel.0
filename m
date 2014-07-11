From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:24 +0000 (UTC)
Subject: master - pool: callback handle cache
Message-ID: <20140711113424.594EB60F72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0c1ada88eef8e112515f5415dc4dd89b4191214
Commit:        c0c1ada88eef8e112515f5415dc4dd89b4191214
Parent:        120bd2d6b13fb7a297ff6cfc9fe59c0b241ab46f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 9 17:24:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:57:45 2014 +0200

pool: callback handle cache

Extend the callback functionality to handle also cache pools.

cache_check is now executed on cachepool metadata when
it's activated and deactivated.
---
 lib/activate/dev_manager.c |  172 +++++++++++++++++++++++++++++---------------
 1 files changed, 114 insertions(+), 58 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0305bb4..d5fe620 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1703,114 +1703,153 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 	return 1;
 }
 
-struct thin_cb_data {
-	const struct logical_volume *pool_lv;
+struct pool_cb_data {
 	struct dev_manager *dm;
+	const struct logical_volume *pool_lv;
+
+	int skip_zero;  /* to skip zeroed device header (check first 64B) */
+	int exec;       /* which binary to call */
+	int opts;
+	const char *defaults;
+	const char *global;
 };
 
-static int _thin_pool_callback(struct dm_tree_node *node,
-			       dm_node_callback_t type, void *cb_data)
+static int _pool_callback(struct dm_tree_node *node,
+			  dm_node_callback_t type, void *cb_data)
 {
-	int ret, status;
-	const struct thin_cb_data *data = cb_data;
-	const char *dmdir = dm_dir();
+	int ret, status, fd;
+	char *split;
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
-	const char *thin_check =
-		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd, global_thin_check_executable_CFG, NULL);
-	const struct logical_volume *mlv = first_seg(data->pool_lv)->metadata_lv;
-	size_t len = strlen(dmdir) + 2 * (strlen(mlv->vg->name) + strlen(mlv->name)) + 3;
-	char meta_path[len];
+	const struct pool_cb_data *data = cb_data;
+	const struct logical_volume *pool_lv = data->pool_lv;
+	const struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
+	long buf[64 / sizeof(long)]; /* buffer for short disk header (64B) */
 	int args = 0;
-	const char *argv[19]; /* Max supported 15 args */
-	char *split, *dm_name;
+	const char *argv[19] = { /* Max supported 15 args */
+		find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL) /* argv[0] */
+	};
 
-	if (!thin_check[0])
+	if (!*argv[0])
 		return 1; /* Checking disabled */
 
-	if (!(dm_name = dm_build_dm_name(data->dm->mem, mlv->vg->name,
-					 mlv->name, NULL)) ||
-	    (dm_snprintf(meta_path, len, "%s/%s", dmdir, dm_name) < 0)) {
-		log_error("Failed to build thin metadata path.");
-		return 0;
-	}
-
-	if ((cn = find_config_tree_node(mlv->vg->cmd, global_thin_check_options_CFG, NULL))) {
+	if ((cn = find_config_tree_node(mlv->vg->cmd, data->opts, NULL))) {
 		for (cv = cn->v; cv && args < 16; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
-					  "global/thin_check_options");
+					  "global/%s_check_options",
+					  data->global);
 				return 0;
 			}
 			argv[++args] = cv->v.str;
 		}
 	} else {
 		/* Use default options (no support for options with spaces) */
-		if (!(split = dm_pool_strdup(data->dm->mem, DEFAULT_THIN_CHECK_OPTIONS))) {
-			log_error("Failed to duplicate thin check string.");
+		if (!(split = dm_pool_strdup(data->dm->mem, data->defaults))) {
+			log_error("Failed to duplicate defaults.");
 			return 0;
 		}
 		args = dm_split_words(split, 16, 0, (char**) argv + 1);
 	}
 
 	if (args == 16) {
-		log_error("Too many options for thin check command.");
+		log_error("Too many options for %s command.", argv[0]);
 		return 0;
 	}
 
-	argv[0] = thin_check;
-	argv[++args] = meta_path;
-	argv[++args] = NULL;
+	if (!(argv[++args] = lv_dmpath_dup(data->dm->mem, mlv))) {
+		log_error("Failed to build pool metadata path.");
+		return 0;
+	}
 
-	if (!(ret = exec_cmd(data->pool_lv->vg->cmd, (const char * const *)argv,
+	if (data->skip_zero) {
+		if ((fd = open(argv[args], O_RDONLY)) < 0) {
+			log_sys_error("open", argv[args]);
+			return 0;
+		}
+		/* let's assume there is no problem to read 64 bytes */
+		if (read(fd, buf, sizeof(buf)) < sizeof(buf)) {
+			log_sys_error("read", argv[args]);
+			return 0;
+		}
+		for (ret = 0; ret < DM_ARRAY_SIZE(buf); ++ret)
+			if (buf[ret])
+				break;
+
+		if (close(fd))
+			log_sys_error("close", argv[args]);
+
+		if (ret == DM_ARRAY_SIZE(buf)) {
+			log_debug("%s skipped, detect empty disk header on %s.",
+				  argv[0], argv[args]);
+			return 1;
+		}
+	}
+
+	if (!(ret = exec_cmd(pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {
 		switch (type) {
 		case DM_NODE_CALLBACK_PRELOADED:
-			log_err_once("Check of thin pool %s/%s failed (status:%d). "
-				     "Manual repair required (thin_dump --repair %s)!",
-				     data->pool_lv->vg->name, data->pool_lv->name,
-				     status, meta_path);
+			log_err_once("Check of pool %s failed (status:%d). "
+				     "Manual repair required!",
+				     display_lvname(pool_lv), status);
 			break;
 		default:
-			log_warn("WARNING: Integrity check of metadata for thin pool "
-				 "%s/%s failed.",
-				 data->pool_lv->vg->name, data->pool_lv->name);
+			log_warn("WARNING: Integrity check of metadata for pool "
+				 "%s failed.", display_lvname(pool_lv));
 		}
 		/*
 		 * FIXME: What should we do here??
 		 *
 		 * Maybe mark the node, so it's not activating
-		 * as thin_pool but as error/linear and let the
+		 * as pool but as error/linear and let the
 		 * dm tree resolve the issue.
 		 */
 	}
 
-	dm_pool_free(data->dm->mem, dm_name);
-
 	return ret;
 }
 
-static int _thin_pool_register_callback(struct dev_manager *dm,
-					struct dm_tree_node *node,
-					const struct logical_volume *lv)
+static int _pool_register_callback(struct dev_manager *dm,
+				   struct dm_tree_node *node,
+				   const struct logical_volume *lv)
 {
-	struct thin_cb_data *data;
+	struct pool_cb_data *data;
 
-	/* Skip metadata testing for unused pool. */
-	if (!first_seg(lv)->transaction_id ||
-	    ((first_seg(lv)->transaction_id == 1) &&
-	     pool_has_message(first_seg(lv), NULL, 0)))
+	/* Skip metadata testing for unused thin pool. */
+	if (lv_is_thin_pool(lv) &&
+	    (!first_seg(lv)->transaction_id ||
+	     ((first_seg(lv)->transaction_id == 1) &&
+	      pool_has_message(first_seg(lv), NULL, 0))))
 		return 1;
 
-	if (!(data = dm_pool_alloc(dm->mem, sizeof(*data)))) {
+	if (!(data = dm_pool_zalloc(dm->mem, sizeof(*data)))) {
 		log_error("Failed to allocated path for callback.");
 		return 0;
 	}
 
 	data->dm = dm;
-	data->pool_lv = lv;
 
-	dm_tree_node_set_callback(node, _thin_pool_callback, data);
+	if (lv_is_thin_pool(lv)) {
+		data->pool_lv = lv;
+		data->skip_zero = 1;
+		data->exec = global_thin_check_executable_CFG;
+		data->opts = global_thin_check_options_CFG;
+		data->defaults = DEFAULT_THIN_CHECK_OPTIONS;
+		data->global = "thin";
+	} else if (lv_is_cache(lv)) { /* cache pool */
+		data->pool_lv = first_seg(lv)->pool_lv;
+		data->skip_zero = dm->activation;
+		data->exec = global_cache_check_executable_CFG;
+		data->opts = global_cache_check_options_CFG;
+		data->defaults = DEFAULT_CACHE_CHECK_OPTIONS;
+		data->global = "cache";
+	} else {
+		log_error(INTERNAL_ERROR "Registering unsupported pool callback.");
+		return 0;
+	}
+
+	dm_tree_node_set_callback(node, _pool_callback, data);
 
 	return 1;
 }
@@ -1825,7 +1864,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct seg_list *sl;
 	struct dm_list *snh;
 	struct lv_segment *seg;
-	struct dm_tree_node *thin_node;
+	struct dm_tree_node *node;
 	const char *uuid;
 
 	if (lv_is_cache_pool(lv)) {
@@ -1857,8 +1896,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* FIXME Implement dm_tree_node_skip_childrens optimisation */
 		if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 			return_0;
-		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
-			dm_tree_node_skip_childrens(thin_node, 1);
+		if ((node = dm_tree_find_node_by_uuid(dtree, uuid)))
+			dm_tree_node_skip_childrens(node, 1);
 #endif
 	}
 
@@ -1887,8 +1926,21 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			/* TODO: extend _cached_info() to return dnode */
 			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 				return_0;
-			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
-			    !_thin_pool_register_callback(dm, thin_node, lv))
+			if ((node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
+			    !_pool_register_callback(dm, node, lv))
+				return_0;
+		}
+	}
+
+	if (!origin_only && lv_is_cache(lv)) {
+		if (!dm->activation) {
+			/* Setup callback for non-activation partial tree */
+			/* Activation gets own callback when needed */
+			/* TODO: extend _cached_info() to return dnode */
+			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+				return_0;
+			if ((node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
+			    !_pool_register_callback(dm, node, lv))
 				return_0;
 		}
 	}
@@ -2633,7 +2685,11 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* Setup thin pool callback */
 	if (lv_is_thin_pool(lv) && layer &&
-	    !_thin_pool_register_callback(dm, dnode, lv))
+	    !_pool_register_callback(dm, dnode, lv))
+		return_0;
+
+	if (lv_is_cache(lv) &&
+	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 
 	if (read_ahead == DM_READ_AHEAD_AUTO) {


