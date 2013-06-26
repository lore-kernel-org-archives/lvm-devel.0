From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:52 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_node
Message-ID: <20130626145552.8461C60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9b8a02c1ffd7ccd34b998c1b84a04a18f11b084
Commit:        c9b8a02c1ffd7ccd34b998c1b84a04a18f11b084
Parent:        5b4199cec9fa8ba4a7dd3bc2d949146c23e8d2ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:29:33 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_node

---
 lib/activate/activate.c       |    6 +++---
 lib/activate/dev_manager.c    |    2 +-
 lib/commands/toolcontext.c    |   24 ++++++++++++------------
 lib/config/config.c           |   15 +++++++++++++--
 lib/config/config.h           |    2 +-
 lib/device/dev-cache.c        |    2 +-
 lib/format_text/format-text.c |    4 ++--
 lib/metadata/lv_manip.c       |    2 +-
 lib/mm/memlock.c              |    2 +-
 lib/thin/thin.c               |    2 +-
 10 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2cdda49..5a4b111 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -430,7 +430,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_volume_list_CFG))) {
+	if (!(cn = find_config_tree_node(cmd, activation_volume_list_CFG, NULL))) {
 		log_verbose("activation/volume_list configuration setting "
 			    "not defined: Checking only host tags for %s/%s",
 			    lv->vg->name, lv->name);
@@ -459,7 +459,7 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_read_only_volume_list_CFG)))
+	if (!(cn = find_config_tree_node(cmd, activation_read_only_volume_list_CFG, NULL)))
 		return 0;
 
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
@@ -470,7 +470,7 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG))) {
+	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG, NULL))) {
 		log_verbose("activation/auto_activation_volume_list configuration setting "
 			    "not defined: All logical volumes will be auto-activated.");
 		return 1;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e471f95..7054656 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1578,7 +1578,7 @@ static int _thin_pool_callback(struct dm_tree_node *node,
 		return 0;
 	}
 
-	if ((cn = find_config_tree_node(mlv->vg->cmd, global_thin_check_options_CFG))) {
+	if ((cn = find_config_tree_node(mlv->vg->cmd, global_thin_check_options_CFG, NULL))) {
 		for (cv = cn->v; cv && args < 16; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b4658f5..3e28378 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -130,7 +130,7 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int debug_classes = 0;
 
-	if (!(cn = find_config_tree_node(cmd, log_debug_classes_CFG)))
+	if (!(cn = find_config_tree_node(cmd, log_debug_classes_CFG, NULL)))
 		return DEFAULT_LOGGED_DEBUG_CLASSES;
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -394,7 +394,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG);
 
-	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG)))
+	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL)))
 		for (cv = cn->v; cv; cv = cv->next) 
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
@@ -424,7 +424,7 @@ static int _process_config(struct cmd_context *cmd)
 						      DEFAULT_RUN_DIR "/lvmetad.socket");
 	*/
 	lvmetad_set_socket(lvmetad_socket);
-	cn = find_config_tree_node(cmd, devices_global_filter_CFG);
+	cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL);
 	lvmetad_set_token(cn ? cn->v : NULL);
 
 	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 &&
@@ -494,7 +494,7 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	const char *tag;
 	int passes;
 
-	if (!(tn = find_config_tree_node(cmd, tags_CFG_SECTION)) || !tn->child)
+	if (!(tn = find_config_tree_node(cmd, tags_CFG_SECTION, NULL)) || !tn->child)
 		return 1;
 
 	/* NB hosttags 0 when already 1 intentionally does not delete the tag */
@@ -812,7 +812,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
-	if (!(cn = find_config_tree_node(cmd, devices_scan_CFG))) {
+	if (!(cn = find_config_tree_node(cmd, devices_scan_CFG, NULL))) {
 		if (!dev_cache_add_dir("/dev")) {
 			log_error("Failed to add /dev to internal "
 				  "device cache");
@@ -858,7 +858,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		}
 	}
 
-	if (!(cn = find_config_tree_node(cmd, devices_loopfiles_CFG)))
+	if (!(cn = find_config_tree_node(cmd, devices_loopfiles_CFG, NULL)))
 		return 1;
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -905,7 +905,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	}
 
 	/* regex filter. Optional. */
-	if (!(cn = find_config_tree_node(cmd, devices_filter_CFG)))
+	if (!(cn = find_config_tree_node(cmd, devices_filter_CFG, NULL)))
 		log_very_verbose("devices/filter not found in config file: "
 				 "no regex filter installed");
 
@@ -1019,7 +1019,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
 
-	if (!(cn = find_config_tree_node(cmd, devices_global_filter_CFG))) {
+	if (!(cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
 		cmd->filter = f4;
 	} else if (!(cmd->lvmetad_filter = regex_filter_create(cn->v)))
 		goto_bad;
@@ -1081,7 +1081,7 @@ static int _init_formats(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, global_format_libraries_CFG))) {
+	    (cn = find_config_tree_node(cmd, global_format_libraries_CFG, NULL))) {
 
 		const struct dm_config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
@@ -1243,7 +1243,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, global_segment_libraries_CFG))) {
+	    (cn = find_config_tree_node(cmd, global_segment_libraries_CFG, NULL))) {
 
 		const struct dm_config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
@@ -1550,7 +1550,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		goto_out;
 
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
-						find_config_tree_node(cmd, devices_types_CFG))))
+						find_config_tree_node(cmd, devices_types_CFG, NULL))))
 		goto_out;
 
 	if (!_init_dev_cache(cmd))
@@ -1738,7 +1738,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 		return 0;
 
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
-						find_config_tree_node(cmd, devices_types_CFG))))
+						find_config_tree_node(cmd, devices_types_CFG, NULL))))
 		return 0;
 
 	if (!_init_dev_cache(cmd))
diff --git a/lib/config/config.c b/lib/config/config.c
index a4c45b7..0653529 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -743,9 +743,20 @@ out:
 	return r;
 }
 
-const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id)
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
 {
-	return dm_config_tree_find_node(cmd->cft, cfg_def_get_path(cfg_def_get_item_p(id)));
+	int profile_applied = 0;
+	const struct dm_config_node *cn;
+
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	cn = dm_config_tree_find_node(cmd->cft, cfg_def_get_path(cfg_def_get_item_p(id)));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return cn;
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index a09382e..a2a62fa 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -160,7 +160,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 /*
  * These versions check an override tree, if present, first.
  */
-const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id);
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str(struct cmd_context *cmd, int id);
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id);
 int find_config_tree_int(struct cmd_context *cmd, int id);
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9981967..24046ca 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -676,7 +676,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	_cache.preferred_names_matcher = NULL;
 
-	if (!(cn = find_config_tree_node(cmd, devices_preferred_names_CFG)) ||
+	if (!(cn = find_config_tree_node(cmd, devices_preferred_names_CFG, NULL)) ||
 	    cn->v->type == DM_CFG_EMPTY_ARRAY) {
 		log_very_verbose("devices/preferred_names not found in config file: "
 				 "using built-in preferences");
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3157252..e2be81d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2442,7 +2442,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		goto bad;
 	}
 
-	if ((cn = find_config_tree_node(cmd, metadata_dirs_CFG))) {
+	if ((cn = find_config_tree_node(cmd, metadata_dirs_CFG, NULL))) {
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
@@ -2459,7 +2459,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		}
 	}
 
-	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG))) {
+	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG, NULL))) {
 		for (cn = cn->child; cn; cn = cn->sib) {
 			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
 				goto_bad;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8acca49..ef7c75a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1055,7 +1055,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->parallel_areas = parallel_areas;
 
-	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG);
+	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL);
 
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG);
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 08876b0..78e50fc 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -293,7 +293,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 	}
 
 	line = _maps_buffer;
-	cn = find_config_tree_node(cmd, activation_mlock_filter_CFG);
+	cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL);
 
 	while ((line_end = strchr(line, '\n'))) {
 		*line_end = '\0'; /* remove \n */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 116b7e1..f4f785f 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -601,7 +601,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 	if (attributes) {
 		if (!_feature_mask) {
 			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
-			if ((cn = find_config_tree_node(cmd, global_thin_disabled_features_CFG))) {
+			if ((cn = find_config_tree_node(cmd, global_thin_disabled_features_CFG, NULL))) {
 				for (cv = cn->v; cv; cv = cv->next) {
 					if (cv->type != DM_CFG_STRING) {
 						log_error("Ignoring invalid string in config file %s.",


