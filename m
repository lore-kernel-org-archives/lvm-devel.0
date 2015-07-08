From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 11:08:22 +0000 (UTC)
Subject: master - config: replace find_config_tree_node with find_config_tree_array where appropriate
Message-ID: <20150708110822.48F6361406@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b6840e0997dd4df0ea711c2036871e3cc2fe40a
Commit:        3b6840e0997dd4df0ea711c2036871e3cc2fe40a
Parent:        67a61cce1b26e91eb765a682f66be67bd997f09f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 11:22:24 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 13:03:08 2015 +0200

config: replace find_config_tree_node with find_config_tree_array where appropriate

---
 lib/activate/activate.c       |    6 +++---
 lib/activate/dev_manager.c    |   28 +++++++++-------------------
 lib/commands/toolcontext.c    |   30 ++++++++++++------------------
 lib/config/config.c           |    6 +++---
 lib/config/config.h           |    2 +-
 lib/config/defaults.h         |    5 -----
 lib/device/dev-cache.c        |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/metadata/lv_manip.c       |    2 +-
 lib/metadata/metadata.c       |    2 +-
 lib/misc/lvm-globals.c        |    2 +-
 lib/thin/thin.c               |    2 +-
 tools/lvconvert.c             |   24 +++++++++---------------
 tools/vgchange.c              |    2 +-
 14 files changed, 44 insertions(+), 71 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2e58c3b..7d2adf1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -180,7 +180,7 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG, NULL))) {
+	if (!(cn = find_config_tree_array(cmd, activation_auto_activation_volume_list_CFG, NULL))) {
 		log_verbose("activation/auto_activation_volume_list configuration setting "
 			    "not defined: All logical volumes will be auto-activated.");
 		return 1;
@@ -467,7 +467,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_volume_list_CFG, NULL))) {
+	if (!(cn = find_config_tree_array(cmd, activation_volume_list_CFG, NULL))) {
 		log_verbose("activation/volume_list configuration setting "
 			    "not defined: Checking only host tags for %s/%s",
 			    lv->vg->name, lv->name);
@@ -496,7 +496,7 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_read_only_volume_list_CFG, NULL)))
+	if (!(cn = find_config_tree_array(cmd, activation_read_only_volume_list_CFG, NULL)))
 		return 0;
 
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6a4da3c..0e29bcd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1918,7 +1918,6 @@ struct pool_cb_data {
 	int skip_zero;  /* to skip zeroed device header (check first 64B) */
 	int exec;       /* which binary to call */
 	int opts;
-	const char *defaults;
 	const char *global;
 };
 
@@ -1926,7 +1925,6 @@ static int _pool_callback(struct dm_tree_node *node,
 			  dm_node_callback_t type, void *cb_data)
 {
 	int ret, status, fd;
-	char *split;
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const struct pool_cb_data *data = cb_data;
@@ -1941,23 +1939,17 @@ static int _pool_callback(struct dm_tree_node *node,
 	if (!*argv[0])
 		return 1; /* Checking disabled */
 
-	if ((cn = find_config_tree_node(mlv->vg->cmd, data->opts, NULL))) {
-		for (cv = cn->v; cv && args < 16; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Invalid string in config file: "
-					  "global/%s_check_options",
-					  data->global);
-				return 0;
-			}
-			argv[++args] = cv->v.str;
-		}
-	} else {
-		/* Use default options (no support for options with spaces) */
-		if (!(split = dm_pool_strdup(data->dm->mem, data->defaults))) {
-			log_error("Failed to duplicate defaults.");
+	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL)))
+		return_0;
+
+	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Invalid string in config file: "
+				  "global/%s_check_options",
+				  data->global);
 			return 0;
 		}
-		args = dm_split_words(split, 16, 0, (char**) argv + 1);
+		argv[++args] = cv->v.str;
 	}
 
 	if (args == 16) {
@@ -2048,14 +2040,12 @@ static int _pool_register_callback(struct dev_manager *dm,
 		data->skip_zero = 1;
 		data->exec = global_thin_check_executable_CFG;
 		data->opts = global_thin_check_options_CFG;
-		data->defaults = DEFAULT_THIN_CHECK_OPTION1 " " DEFAULT_THIN_CHECK_OPTION2;
 		data->global = "thin";
 	} else if (lv_is_cache(lv)) { /* cache pool */
 		data->pool_lv = first_seg(lv)->pool_lv;
 		data->skip_zero = dm->activation;
 		data->exec = global_cache_check_executable_CFG;
 		data->opts = global_cache_check_options_CFG;
-		data->defaults = DEFAULT_CACHE_CHECK_OPTION1 " " DEFAULT_CACHE_CHECK_OPTION2;
 		data->global = "cache";
 	} else {
 		log_error(INTERNAL_ERROR "Registering unsupported pool callback.");
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 00db078..002627b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -245,8 +245,8 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int debug_classes = 0;
 
-	if (!(cn = find_config_tree_node(cmd, log_debug_classes_CFG, NULL)))
-		return DEFAULT_LOGGED_DEBUG_CLASSES;
+	if (!(cn = find_config_tree_array(cmd, log_debug_classes_CFG, NULL)))
+		return -1;
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
@@ -652,7 +652,7 @@ static int _process_config(struct cmd_context *cmd)
 		}
 	}
 
-	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL)))
+	if ((cn = find_config_tree_array(cmd, activation_mlock_filter_CFG, NULL)))
 		for (cv = cn->v; cv; cv = cv->next) 
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
@@ -1016,14 +1016,10 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
 	if (!(cn = find_config_tree_node(cmd, devices_scan_CFG, NULL))) {
-		if (!dev_cache_add_dir("/dev")) {
-			log_error("Failed to add /dev to internal "
-				  "device cache");
-			return 0;
-		}
-		log_verbose("device/scan not in config file: "
-			    "Defaulting to /dev");
-		return 1;
+		log_verbose("device/scan not in config file, "
+			    "using defaults.");
+		if (!(cn = find_config_tree_array(cmd, devices_scan_CFG, NULL)))
+			return_0;
 	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -1061,7 +1057,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		}
 	}
 
-	if (!(cn = find_config_tree_node(cmd, devices_loopfiles_CFG, NULL)))
+	if (!(cn = find_config_tree_array(cmd, devices_loopfiles_CFG, NULL)))
 		return 1;
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -1235,8 +1231,6 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		cmd->lvmetad_filter = NULL;
 	}
 
-	cn = find_config_tree_array(cmd, devices_filter_CFG, NULL);
-
 	/* filter component 1 */
 	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
 		if (!(filter_components[1] = regex_filter_create(cn->v)))
@@ -1355,7 +1349,7 @@ static int _init_formats(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, global_format_libraries_CFG, NULL))) {
+	    (cn = find_config_tree_array(cmd, global_format_libraries_CFG, NULL))) {
 
 		const struct dm_config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
@@ -1521,7 +1515,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, global_segment_libraries_CFG, NULL))) {
+	    (cn = find_config_tree_array(cmd, global_segment_libraries_CFG, NULL))) {
 
 		const struct dm_config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
@@ -1827,7 +1821,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		goto_out;
 
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
-						find_config_tree_node(cmd, devices_types_CFG, NULL))))
+						find_config_tree_array(cmd, devices_types_CFG, NULL))))
 		goto_out;
 
 	if (!_init_dev_cache(cmd))
@@ -2042,7 +2036,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 		return_0;
 
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
-						find_config_tree_node(cmd, devices_types_CFG, NULL))))
+						find_config_tree_array(cmd, devices_types_CFG, NULL))))
 		return_0;
 
 	if (!_init_dev_cache(cmd))
diff --git a/lib/config/config.c b/lib/config/config.c
index 9458107..6aaeef1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1386,12 +1386,12 @@ static struct dm_config_node *_get_array_def_node(struct cmd_context *cmd,
 	return cn;
 }
 
-struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
+const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
 	int profile_applied;
-	struct dm_config_node *cn;
+	const struct dm_config_node *cn;
 
 	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
@@ -1400,7 +1400,7 @@ struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, s
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as array.", path);
 
 	if (_config_disabled(cmd, item, path) ||
-	    !(cn = dm_config_find_node(cmd->cft->root, path)))
+	    !(cn = find_config_tree_node(cmd, id, profile)))
 		cn = _get_array_def_node(cmd, item, profile);
 
 	if (profile_applied)
diff --git a/lib/config/config.h b/lib/config/config.h
index a20fd8f..03319bf 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -272,7 +272,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile);
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile);
-struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile);
+const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile);
 
 /*
  * Functions for configuration settings for which the default
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 33f9d08..c568340 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -152,11 +152,6 @@
 #  define DEFAULT_LOG_FACILITY LOG_USER
 #endif
 
-#define DEFAULT_LOGGED_DEBUG_CLASSES (LOG_CLASS_MEM | LOG_CLASS_DEVS | \
-    LOG_CLASS_ACTIVATION | LOG_CLASS_ALLOC | LOG_CLASS_LVMETAD | \
-    LOG_CLASS_METADATA | LOG_CLASS_CACHE | LOG_CLASS_LOCKING | \
-    LOG_CLASS_LVMPOLLD)
-
 #define DEFAULT_SYSLOG 1
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_SILENT 0
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d594dd4..136921b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -681,7 +681,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	_cache.preferred_names_matcher = NULL;
 
-	if (!(cn = find_config_tree_node(cmd, devices_preferred_names_CFG, NULL)) ||
+	if (!(cn = find_config_tree_array(cmd, devices_preferred_names_CFG, NULL)) ||
 	    cn->v->type == DM_CFG_EMPTY_ARRAY) {
 		log_very_verbose("devices/preferred_names not found in config file: "
 				 "using built-in preferences");
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index fc759fb..1d7dc3c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2491,7 +2491,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		goto bad;
 	}
 
-	if ((cn = find_config_tree_node(cmd, metadata_dirs_CFG, NULL))) {
+	if ((cn = find_config_tree_array(cmd, metadata_dirs_CFG, NULL))) {
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a447f08..9decf32 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3255,7 +3255,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->parallel_areas = parallel_areas;
 
-	if ((ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL)))
+	if ((ah->cling_tag_list_cn = find_config_tree_array(cmd, allocation_cling_tag_list_CFG, NULL)))
 		(void) _validate_tag_list(ah->cling_tag_list_cn);
 
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 08bfe91..07ef54e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4602,7 +4602,7 @@ static int _allow_system_id(struct cmd_context *cmd, const char *system_id)
 	const struct dm_config_value *cv;
 	const char *str;
 
-	if (!(cn = find_config_tree_node(cmd, local_extra_system_ids_CFG, NULL)))
+	if (!(cn = find_config_tree_array(cmd, local_extra_system_ids_CFG, NULL)))
 		return 0;
 
 	for (cv = cn->v; cv; cv = cv->next) {
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 4fa0779..60397e5 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -33,7 +33,7 @@ static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static unsigned _external_device_info_source = DEV_EXT_NONE;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
-static int _debug_classes_logged = DEFAULT_LOGGED_DEBUG_CLASSES;
+static int _debug_classes_logged = 0;
 static int _log_cmd_name = 0;
 static int _ignorelockingfailure = 0;
 static int _security_level = SECURITY_LEVEL;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 6993249..4c4636f 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -687,7 +687,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 	if (attributes) {
 		if (!_feature_mask) {
 			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
-			if ((cn = find_config_tree_node(cmd, global_thin_disabled_features_CFG, NULL))) {
+			if ((cn = find_config_tree_array(cmd, global_thin_disabled_features_CFG, NULL))) {
 				for (cv = cn->v; cv; cv = cv->next) {
 					if (cv->type != DM_CFG_STRING) {
 						log_error("Ignoring invalid string in config file %s.",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c7e797b..528c351 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2299,7 +2299,7 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 	int ret = 0, status;
 	int args = 0;
 	const char *argv[19]; /* Max supported 10 args */
-	char *split, *dm_name, *trans_id_str;
+	char *dm_name, *trans_id_str;
 	char meta_path[PATH_MAX];
 	char pms_path[PATH_MAX];
 	uint64_t trans_id;
@@ -2339,22 +2339,16 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((cn = find_config_tree_node(cmd, global_thin_repair_options_CFG, NULL))) {
-		for (cv = cn->v; cv && args < 16; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Invalid string in config file: "
-					  "global/thin_repair_options");
-				return 0;
-			}
-			argv[++args] = cv->v.str;
-		}
-	} else {
-		/* Use default options (no support for options with spaces) */
-		if (!(split = dm_pool_strdup(cmd->mem, DEFAULT_THIN_REPAIR_OPTIONS))) {
-			log_error("Failed to duplicate thin repair string.");
+	if (!(cn = find_config_tree_array(cmd, global_thin_repair_options_CFG, NULL)))
+		return_0;
+
+	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Invalid string in config file: "
+				  "global/thin_repair_options");
 			return 0;
 		}
-		args = dm_split_words(split, 16, 0, (char**) argv + 1);
+		argv[++args] = cv->v.str;
 	}
 
 	if (args == 10) {
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 076fcb8..92c854b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -818,7 +818,7 @@ static int _passes_lock_start_filter(struct cmd_context *cmd,
 
 	/* undefined list means no restrictions, all vg names pass */
 
-	cn = find_config_tree_node(cmd, cfg_id, NULL);
+	cn = find_config_tree_array(cmd, cfg_id, NULL);
 	if (!cn)
 		return 1;
 


