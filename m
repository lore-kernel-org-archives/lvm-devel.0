From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:26 +0000 (UTC)
Subject: master - config: refer to config nodes using assigned IDs
Message-ID: <20130306111526.BB866A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=386886f71c3da0945f47edf1a7063a04ba9b56d1
Commit:        386886f71c3da0945f47edf1a7063a04ba9b56d1
Parent:        a3d891a29042e51a0f43ed02273a6dce194d6569
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 17:00:43 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:14:33 2013 +0100

config: refer to config nodes using assigned IDs

For example, the old call and reference:

  find_config_tree_str(cmd, "devices/dir", DEFAULT_DEV_DIR)

...now becomes:

  find_config_tree_str(cmd, devices_dir_CFG)

So we're referring to the named configuration ID instead
of passing the configuration path and the default value
is taken from central config definition in config_settings.h
automatically.
---
 daemons/clvmd/lvm-functions.c  |    7 +-
 lib/activate/activate.c        |   18 +++--
 lib/activate/dev_manager.c     |    6 +-
 lib/commands/toolcontext.c     |  175 ++++++++++++++++------------------------
 lib/commands/toolcontext.h     |    1 +
 lib/config/config.c            |   71 ++++++++++++-----
 lib/config/config.h            |   21 ++---
 lib/config/defaults.h          |    1 -
 lib/device/dev-cache.c         |    2 +-
 lib/display/display.c          |    3 +-
 lib/format_text/format-text.c  |    8 +-
 lib/locking/external_locking.c |    4 +-
 lib/locking/file_locking.c     |    6 +-
 lib/locking/locking.c          |   13 +--
 lib/metadata/lv_manip.c        |   17 ++---
 lib/metadata/metadata.c        |   15 +---
 lib/metadata/mirror.c          |   15 ++--
 lib/metadata/pv_manip.c        |    3 +-
 lib/metadata/thin_manip.c      |    4 +-
 lib/mirror/mirrored.c          |    3 +-
 lib/misc/sharedlib.c           |    2 +-
 lib/mm/memlock.c               |   15 +---
 lib/raid/raid.c                |    3 +-
 lib/snapshot/snapshot.c        |    3 +-
 lib/thin/thin.c                |    5 +-
 liblvm/lvm_base.c              |    4 +-
 tools/lvconvert.c              |   13 +--
 tools/lvcreate.c               |    8 +-
 tools/lvm.c                    |    3 +-
 tools/lvmcmdline.c             |    3 +-
 tools/lvresize.c               |   16 +---
 tools/polldaemon.c             |    6 +-
 tools/pvcreate.c               |    4 +-
 tools/pvscan.c                 |    4 +-
 tools/reporter.c               |   76 +++++------------
 tools/toollib.c                |   46 +++-------
 tools/vgconvert.c              |    8 +--
 37 files changed, 246 insertions(+), 366 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 6793752..416d4f0 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -808,7 +808,7 @@ static void check_config(void)
 {
 	int locking_type;
 
-	locking_type = find_config_tree_int(cmd, "global/locking_type", 1);
+	locking_type = find_config_tree_int(cmd, global_locking_type_CFG);
 
 	if (locking_type == 3) /* compiled-in cluster support */
 		return;
@@ -816,9 +816,8 @@ static void check_config(void)
 	if (locking_type == 2) { /* External library, check name */
 		const char *libname;
 
-		libname = find_config_tree_str(cmd, "global/locking_library",
-					  "");
-		if (strstr(libname, "liblvm2clusterlock.so"))
+		libname = find_config_tree_str(cmd, global_locking_library_CFG);
+		if (libname && strstr(libname, "liblvm2clusterlock.so"))
 			return;
 
 		log_error("Incorrect LVM locking library specified in lvm.conf, cluster operations may not work.");
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f19dff7..26d357b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -333,12 +333,14 @@ int activation(void)
 }
 
 static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
-				     const struct dm_config_node *cn, const char *config_path)
+				     const struct dm_config_node *cn, const int cfg_id)
 {
 	const struct dm_config_value *cv;
 	const char *str;
+	static char config_path[PATH_MAX];
 	static char path[PATH_MAX];
 
+	config_def_get_path(config_path, sizeof(config_path), cfg_id);
 	log_verbose("%s configuration setting defined: "
 		    "Checking the list to match %s/%s",
 		    config_path, lv->vg->name, lv->name);
@@ -413,7 +415,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
+	if (!(cn = find_config_tree_node(cmd, activation_volume_list_CFG))) {
 		log_verbose("activation/volume_list configuration setting "
 			    "not defined: Checking only host tags for %s/%s",
 			    lv->vg->name, lv->name);
@@ -434,7 +436,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		return 0;
 	}
 
-	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, activation_volume_list_CFG);
 }
 
 static int _passes_readonly_filter(struct cmd_context *cmd,
@@ -442,10 +444,10 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, "activation/read_only_volume_list")))
+	if (!(cn = find_config_tree_node(cmd, activation_read_only_volume_list_CFG)))
 		return 0;
 
-	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
 }
 
 
@@ -453,13 +455,13 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 {
 	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_tree_node(cmd, "activation/auto_activation_volume_list"))) {
+	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG))) {
 		log_verbose("activation/auto_activation_volume_list configuration setting "
 			    "not defined: All logical volumes will be auto-activated.");
 		return 1;
 	}
 
-	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/auto_activation_volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, activation_auto_activation_volume_list_CFG);
 }
 
 int library_version(char *version, size_t size)
@@ -1152,7 +1154,7 @@ static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd
 	if (!(dmevh = dm_event_handler_create()))
 		return_NULL;
 
-	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, "dmeventd/executable", NULL)))
+	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, dmeventd_executable_CFG)))
 		goto_bad;
 
 	if (dm_event_handler_set_dso(dmevh, dso))
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index bffa8a5..8aa49fc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1450,9 +1450,7 @@ static int _thin_pool_callback(struct dm_tree_node *node,
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const char *thin_check =
-		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd,
-						 "global/thin_check_executable",
-						 THIN_CHECK_CMD);
+		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd, global_thin_check_executable_CFG);
 	const struct logical_volume *mlv = first_seg(data->pool_lv)->metadata_lv;
 	size_t len = strlen(dmdir) + 2 * (strlen(mlv->vg->name) + strlen(mlv->name)) + 3;
 	char meta_path[len];
@@ -1470,7 +1468,7 @@ static int _thin_pool_callback(struct dm_tree_node *node,
 		return 0;
 	}
 
-	if ((cn = find_config_tree_node(mlv->vg->cmd, "global/thin_check_options"))) {
+	if ((cn = find_config_tree_node(mlv->vg->cmd, global_thin_check_options_CFG))) {
 		for (cv = cn->v; cv && args < 16; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d5dd430..1cee204 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -128,7 +128,7 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int debug_classes = 0;
 
-	if (!(cn = find_config_tree_node(cmd, "log/debug_classes")))
+	if (!(cn = find_config_tree_node(cmd, log_debug_classes_CFG)))
 		return DEFAULT_LOGGED_DEBUG_CLASSES;
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -173,8 +173,7 @@ static void _init_logging(struct cmd_context *cmd)
 	char timebuf[26];
 
 	/* Syslog */
-	cmd->default_settings.syslog =
-	    find_config_tree_int(cmd, "log/syslog", DEFAULT_SYSLOG);
+	cmd->default_settings.syslog = find_config_tree_bool(cmd, log_syslog_CFG);
 	if (cmd->default_settings.syslog != 1)
 		fin_syslog();
 
@@ -182,8 +181,7 @@ static void _init_logging(struct cmd_context *cmd)
 		init_syslog(cmd->default_settings.syslog);
 
 	/* Debug level for log file output */
-	cmd->default_settings.debug =
-	    find_config_tree_int(cmd, "log/level", DEFAULT_LOGLEVEL);
+	cmd->default_settings.debug = find_config_tree_int(cmd, log_level_CFG);
 	init_debug(cmd->default_settings.debug);
 
 	/*
@@ -192,40 +190,33 @@ static void _init_logging(struct cmd_context *cmd)
 	 * Once set to 1, there is no facility to change it back to 0.
 	 */
 	cmd->default_settings.silent = silent_mode() ? :
-	    find_config_tree_int(cmd, "log/silent", DEFAULT_SILENT);
+	    find_config_tree_bool(cmd, log_silent_CFG);
 	init_silent(cmd->default_settings.silent);
 
 	/* Verbose level for tty output */
-	cmd->default_settings.verbose =
-	    find_config_tree_int(cmd, "log/verbose", DEFAULT_VERBOSE);
+	cmd->default_settings.verbose = find_config_tree_bool(cmd, log_verbose_CFG);
 	init_verbose(cmd->default_settings.verbose + VERBOSE_BASE_LEVEL);
 
 	/* Log message formatting */
-	init_indent(find_config_tree_int(cmd, "log/indent",
-					 DEFAULT_INDENT));
-	init_abort_on_internal_errors(find_config_tree_int(cmd, "global/abort_on_internal_errors",
-							   DEFAULT_ABORT_ON_INTERNAL_ERRORS));
-
-	cmd->default_settings.msg_prefix =
-		find_config_tree_str_allow_empty(cmd, "log/prefix", DEFAULT_MSG_PREFIX);
+	init_indent(find_config_tree_bool(cmd, log_indent_CFG));
+	init_abort_on_internal_errors(find_config_tree_bool(cmd, global_abort_on_internal_errors_CFG));
 
+	cmd->default_settings.msg_prefix = find_config_tree_str_allow_empty(cmd, log_prefix_CFG);
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
-	cmd->default_settings.cmd_name = find_config_tree_int(cmd,
-							 "log/command_names",
-							 DEFAULT_CMD_NAME);
+	cmd->default_settings.cmd_name = find_config_tree_bool(cmd, log_command_names_CFG);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
 	/* Test mode */
 	cmd->default_settings.test =
-	    find_config_tree_int(cmd, "global/test", 0);
+	    find_config_tree_bool(cmd, global_test_CFG);
 	init_test(cmd->default_settings.test);
 
 	/* Settings for logging to file */
-	if (find_config_tree_int(cmd, "log/overwrite", DEFAULT_OVERWRITE))
+	if (find_config_tree_bool(cmd, log_overwrite_CFG))
 		append = 0;
 
-	log_file = find_config_tree_str(cmd, "log/file", 0);
+	log_file = find_config_tree_str(cmd, log_file_CFG);
 
 	if (log_file) {
 		release_log_memory();
@@ -233,12 +224,11 @@ static void _init_logging(struct cmd_context *cmd)
 		init_log_file(log_file, append);
 	}
 
-	log_file = find_config_tree_str(cmd, "log/activate_file", 0);
+	log_file = find_config_tree_str(cmd, log_activate_file_CFG);
 	if (log_file)
 		init_log_direct(log_file, append);
 
-	init_log_while_suspended(find_config_tree_int(cmd,
-						 "log/activation", 0));
+	init_log_while_suspended(find_config_tree_bool(cmd, log_activation_CFG));
 
 	cmd->default_settings.debug_classes = _parse_debug_classes(cmd);
 	log_debug("Setting log debug classes to %d", cmd->default_settings.debug_classes);
@@ -301,9 +291,7 @@ static int _process_config(struct cmd_context *cmd)
 	int udev_disabled = 0;
 
 	/* umask */
-	cmd->default_settings.umask = find_config_tree_int(cmd,
-						      "global/umask",
-						      DEFAULT_UMASK);
+	cmd->default_settings.umask = find_config_tree_int(cmd, global_umask_CFG);
 
 	if ((old_umask = umask((mode_t) cmd->default_settings.umask)) !=
 	    (mode_t) cmd->default_settings.umask)
@@ -312,8 +300,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	/* dev dir */
 	if (dm_snprintf(cmd->dev_dir, sizeof(cmd->dev_dir), "%s/",
-			 find_config_tree_str(cmd, "devices/dir",
-					 DEFAULT_DEV_DIR)) < 0) {
+			 find_config_tree_str(cmd, devices_dir_CFG)) < 0) {
 		log_error("Device directory given in config file too long");
 		return 0;
 	}
@@ -326,8 +313,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	/* proc dir */
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
-			 find_config_tree_str(cmd, "global/proc",
-					 DEFAULT_PROC_DIR)) < 0) {
+			 find_config_tree_str(cmd, global_proc_CFG)) < 0) {
 		log_error("Device directory given in config file too long");
 		return 0;
 	}
@@ -344,25 +330,19 @@ static int _process_config(struct cmd_context *cmd)
 	dm_set_sysfs_dir(cmd->sysfs_dir);
 
 	/* activation? */
-	cmd->default_settings.activation = find_config_tree_int(cmd,
-							   "global/activation",
-							   DEFAULT_ACTIVATION);
+	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG);
 	set_activation(cmd->default_settings.activation);
 
-	cmd->default_settings.suffix = find_config_tree_int(cmd,
-						       "global/suffix",
-						       DEFAULT_SUFFIX);
+	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG);
 
 	if (!(cmd->default_settings.unit_factor =
-	      units_to_bytes(find_config_tree_str(cmd,
-					     "global/units",
-					     DEFAULT_UNITS),
+	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG),
 			     &cmd->default_settings.unit_type))) {
 		log_error("Invalid units specification");
 		return 0;
 	}
 
-	read_ahead = find_config_tree_str(cmd, "activation/readahead", DEFAULT_READ_AHEAD);
+	read_ahead = find_config_tree_str(cmd, activation_readahead_CFG);
 	if (!strcasecmp(read_ahead, "auto"))
 		cmd->default_settings.read_ahead = DM_READ_AHEAD_AUTO;
 	else if (!strcasecmp(read_ahead, "none"))
@@ -382,16 +362,14 @@ static int _process_config(struct cmd_context *cmd)
 	udev_disabled = _check_disable_udev("manage logical volume symlinks in device directory");
 
 	cmd->default_settings.udev_rules = udev_disabled ? 0 :
-		find_config_tree_int(cmd, "activation/udev_rules", DEFAULT_UDEV_RULES);
+		find_config_tree_bool(cmd, activation_udev_rules_CFG);
 
 	cmd->default_settings.udev_sync = udev_disabled ? 0 :
-		find_config_tree_int(cmd, "activation/udev_sync", DEFAULT_UDEV_SYNC);
+		find_config_tree_bool(cmd, activation_udev_sync_CFG);
 
-	init_retry_deactivation(find_config_tree_int(cmd, "activation/retry_deactivation",
-							DEFAULT_RETRY_DEACTIVATION));
+	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG));
 
-	init_activation_checks(find_config_tree_int(cmd, "activation/checks",
-						      DEFAULT_ACTIVATION_CHECKS));
+	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG));
 
 #ifdef UDEV_SYNC_SUPPORT
 	/*
@@ -400,7 +378,7 @@ static int _process_config(struct cmd_context *cmd)
 	 * variable or udev rules are switched off.
 	 */
 	cmd->default_settings.udev_fallback = !cmd->default_settings.udev_rules || udev_disabled ? 1 :
-		find_config_tree_int(cmd, "activation/verify_udev_operations", DEFAULT_VERIFY_UDEV_OPERATIONS);
+		find_config_tree_bool(cmd, activation_verify_udev_operations_CFG);
 
 	/* Do not rely fully on udev if the udev support is known to be incomplete. */
 	if (!cmd->default_settings.udev_fallback && !_dm_driver_has_stable_udev_support()) {
@@ -414,13 +392,9 @@ static int _process_config(struct cmd_context *cmd)
 	cmd->default_settings.udev_fallback = 1;
 #endif
 
-	cmd->use_linear_target = find_config_tree_int(cmd,
-						      "activation/use_linear_target",
-						       DEFAULT_USE_LINEAR_TARGET);
+	cmd->use_linear_target = find_config_tree_bool(cmd, activation_use_linear_target_CFG);
 
-	cmd->stripe_filler = find_config_tree_str(cmd,
-						  "activation/missing_stripe_filler",
-						  DEFAULT_STRIPE_FILLER);
+	cmd->stripe_filler = find_config_tree_str(cmd, activation_missing_stripe_filler_CFG);
 
 	/* FIXME Missing error code checks from the stats, not log_warn?, notify if setting overridden, delay message/check till it is actually used (eg consider if lvm shell - file could appear later after this check)? */
 	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
@@ -442,19 +416,16 @@ static int _process_config(struct cmd_context *cmd)
 		}
 	}
 
-	cmd->si_unit_consistency = find_config_tree_int(cmd,
-						  "global/si_unit_consistency",
-						  DEFAULT_SI_UNIT_CONSISTENCY);
+	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG);
 
-	if ((cn = find_config_tree_node(cmd, "activation/mlock_filter")))
+	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG)))
 		for (cv = cn->v; cv; cv = cv->next) 
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
 
-	cmd->metadata_read_only = find_config_tree_int(cmd, "global/metadata_read_only",
-						       DEFAULT_METADATA_READ_ONLY);
+	cmd->metadata_read_only = find_config_tree_bool(cmd, global_metadata_read_only_CFG);
 
-	pv_min_kb = find_config_tree_int64(cmd, "devices/pv_min_size", DEFAULT_PV_MIN_SIZE_KB);
+	pv_min_kb = find_config_tree_int64(cmd, devices_pv_min_size_CFG);
 	if (pv_min_kb < PV_MIN_SIZE_KB) {
 		log_warn("Ignoring too small pv_min_size %" PRId64 "KB, using default %dKB.",
 			 pv_min_kb, PV_MIN_SIZE_KB);
@@ -464,8 +435,7 @@ static int _process_config(struct cmd_context *cmd)
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
 	init_detect_internal_vg_cache_corruption
-		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption",
-				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
+		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG));
 
 	lvmetad_disconnect();
 
@@ -478,16 +448,16 @@ static int _process_config(struct cmd_context *cmd)
 						      DEFAULT_RUN_DIR "/lvmetad.socket");
 	*/
 	lvmetad_set_socket(lvmetad_socket);
-	cn = find_config_tree_node(cmd, "devices/global_filter");
+	cn = find_config_tree_node(cmd, devices_global_filter_CFG);
 	lvmetad_set_token(cn ? cn->v : NULL);
 
-	if (find_config_tree_int(cmd, "global/locking_type", 1) == 3 &&
-	    find_config_tree_int(cmd, "global/use_lvmetad", 0)) {
+	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 &&
+	    find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
 		log_warn("WARNING: configuration setting use_lvmetad overriden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
 		lvmetad_set_active(0);
 	} else
-		lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+		lvmetad_set_active(find_config_tree_bool(cmd, global_use_lvmetad_CFG));
 
 	lvmetad_init(cmd);
 
@@ -548,12 +518,11 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	const char *tag;
 	int passes;
 
-	if (!(tn = dm_config_find_node(cft->root, "tags")) || !tn->child)
+	if (!(tn = find_config_tree_node(cmd, tags_CFG_SECTION)) || !tn->child)
 		return 1;
 
 	/* NB hosttags 0 when already 1 intentionally does not delete the tag */
-	if (!cmd->hosttags && dm_config_find_int(cft->root, "tags/hosttags",
-					      DEFAULT_HOSTTAGS)) {
+	if (!cmd->hosttags && find_config_tree_bool(cmd, tags_hosttags_CFG)) {
 		/* FIXME Strip out invalid chars: only A-Za-z0-9_+.- */
 		if (!_set_tag(cmd, cmd->hostname))
 			return_0;
@@ -754,8 +723,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	int device_list_from_udev;
 
 	init_dev_disable_after_error_count(
-		find_config_tree_int(cmd, "devices/disable_after_error_count",
-				     DEFAULT_DISABLE_AFTER_ERROR_COUNT));
+		find_config_tree_int(cmd, devices_disable_after_error_count_CFG));
 
 	if (!dev_cache_init(cmd))
 		return_0;
@@ -769,12 +737,11 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		device_list_from_udev = 0;
 	else
 		device_list_from_udev = udev_is_running() ?
-			find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
-					      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0;
+			find_config_tree_bool(cmd, devices_obtain_device_list_from_udev_CFG) : 0;
 
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
-	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
+	if (!(cn = find_config_tree_node(cmd, devices_scan_CFG))) {
 		if (!dev_cache_add_dir("/dev")) {
 			log_error("Failed to add /dev to internal "
 				  "device cache");
@@ -817,7 +784,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		}
 	}
 
-	if (!(cn = find_config_tree_node(cmd, "devices/loopfiles")))
+	if (!(cn = find_config_tree_node(cmd, devices_loopfiles_CFG)))
 		return 1;
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -858,14 +825,13 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	 * Listed first because it's very efficient at eliminating
 	 * unavailable devices.
 	 */
-	if (find_config_tree_bool(cmd, "devices/sysfs_scan",
-			     DEFAULT_SYSFS_SCAN)) {
+	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG)) {
 		if ((filters[nr_filt] = sysfs_filter_create(cmd->sysfs_dir)))
 			nr_filt++;
 	}
 
 	/* regex filter. Optional. */
-	if (!(cn = find_config_tree_node(cmd, "devices/filter")))
+	if (!(cn = find_config_tree_node(cmd, devices_filter_CFG)))
 		log_very_verbose("devices/filter not found in config file: "
 				 "no regex filter installed");
 
@@ -876,7 +842,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 		nr_filt++;
 
 	/* device type filter. Required. */
-	cn = find_config_tree_node(cmd, "devices/types");
+	cn = find_config_tree_node(cmd, devices_types_CFG);
 	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->proc_dir, cn))) {
 		log_error("Failed to create lvm type filter");
 		goto bad;
@@ -884,16 +850,14 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	nr_filt++;
 
 	/* md component filter. Optional, non-critical. */
-	if (find_config_tree_bool(cmd, "devices/md_component_detection",
-			     DEFAULT_MD_COMPONENT_DETECTION)) {
+	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG)) {
 		init_md_filtering(1);
 		if ((filters[nr_filt] = md_filter_create()))
 			nr_filt++;
 	}
 
 	/* mpath component filter. Optional, non-critical. */
-	if (find_config_tree_bool(cmd, "devices/multipath_component_detection",
-			     DEFAULT_MULTIPATH_COMPONENT_DETECTION)) {
+	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG)) {
 		if ((filters[nr_filt] = mpath_filter_create(cmd->sysfs_dir)))
 			nr_filt++;
 	}
@@ -926,14 +890,13 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	if (!(f3 = _init_filter_components(cmd)))
 		goto_bad;
 
-	init_ignore_suspended_devices(find_config_tree_int(cmd,
-	    "devices/ignore_suspended_devices", DEFAULT_IGNORE_SUSPENDED_DEVICES));
+	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG));
 
 	/*
 	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
 	 */
-	cache_dir = find_config_tree_str(cmd, "devices/cache_dir", NULL);
-	cache_file_prefix = find_config_tree_str(cmd, "devices/cache_file_prefix", NULL);
+	cache_dir = find_config_tree_str(cmd, devices_cache_dir_CFG);
+	cache_file_prefix = find_config_tree_str(cmd, devices_cache_file_prefix_CFG);
 
 	if (cache_dir || cache_file_prefix) {
 		if (dm_snprintf(cache_file, sizeof(cache_file),
@@ -945,7 +908,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 			log_error("Persistent cache filename too long.");
 			goto bad;
 		}
-	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
+	} else if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG)) &&
 		   (dm_snprintf(cache_file, sizeof(cache_file),
 				"%s/%s/%s.cache",
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
@@ -964,7 +927,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	}
 
 	/* Should we ever dump persistent filter state? */
-	if (find_config_tree_int(cmd, "devices/write_cache_state", 1))
+	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG));
 		cmd->dump_filter = 1;
 
 	if (!*cmd->system_dir)
@@ -981,7 +944,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
 
-	if (!(cn = find_config_tree_node(cmd, "devices/global_filter"))) {
+	if (!(cn = find_config_tree_node(cmd, devices_global_filter_CFG))) {
 		cmd->filter = f4;
 	} else if (!(cmd->lvmetad_filter = regex_filter_create(cn->v)))
 		goto_bad;
@@ -1043,7 +1006,7 @@ static int _init_formats(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
+	    (cn = find_config_tree_node(cmd, global_format_libraries_CFG))) {
 
 		const struct dm_config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
@@ -1084,8 +1047,7 @@ static int _init_formats(struct cmd_context *cmd)
 
 	cmd->fmt_backup = fmt;
 
-	format = find_config_tree_str(cmd, "global/format",
-				 DEFAULT_FORMAT);
+	format = find_config_tree_str(cmd, global_format_CFG);
 
 	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (!strcasecmp(fmt->name, format) ||
@@ -1206,7 +1168,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
-	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
+	    (cn = find_config_tree_node(cmd, global_segment_libraries_CFG))) {
 
 		const struct dm_config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
@@ -1294,14 +1256,11 @@ static int _init_backup(struct cmd_context *cmd)
 
 	/* set up archiving */
 	cmd->default_settings.archive =
-	    find_config_tree_bool(cmd, "backup/archive",
-			     DEFAULT_ARCHIVE_ENABLED);
+	    find_config_tree_bool(cmd, backup_archive_CFG);
 
-	days = (uint32_t) find_config_tree_int(cmd, "backup/retain_days",
-					  DEFAULT_ARCHIVE_DAYS);
+	days = (uint32_t) find_config_tree_int(cmd, backup_retain_days_CFG);
 
-	min = (uint32_t) find_config_tree_int(cmd, "backup/retain_min",
-					 DEFAULT_ARCHIVE_NUMBER);
+	min = (uint32_t) find_config_tree_int(cmd, backup_retain_min_CFG);
 
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
@@ -1311,8 +1270,8 @@ static int _init_backup(struct cmd_context *cmd)
 		return 0;
 	}
 
-	dir = find_config_tree_str(cmd, "backup/archive_dir",
-			      default_dir);
+	if (!(dir = find_config_tree_str(cmd, backup_archive_dir_CFG)))
+		dir = default_dir;
 
 	if (!archive_init(cmd, dir, days, min,
 			  cmd->default_settings.archive)) {
@@ -1321,9 +1280,7 @@ static int _init_backup(struct cmd_context *cmd)
 	}
 
 	/* set up the backup */
-	cmd->default_settings.backup =
-	    find_config_tree_bool(cmd, "backup/backup",
-			     DEFAULT_BACKUP_ENABLED);
+	cmd->default_settings.backup = find_config_tree_bool(cmd, backup_backup_CFG);
 
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
@@ -1333,7 +1290,8 @@ static int _init_backup(struct cmd_context *cmd)
 		return 0;
 	}
 
-	dir = find_config_tree_str(cmd, "backup/backup_dir", default_dir);
+	if (!(dir = find_config_tree_str(cmd, backup_backup_dir_CFG)))
+		dir = default_dir;
 
 	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
 		log_debug("backup_init failed.");
@@ -1758,6 +1716,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	}
 #endif
 
+	if (cmd->cft_def_hash)
+		dm_hash_destroy(cmd->cft_def_hash);
+
 	dm_free(cmd);
 
 	lvmetad_release_token();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c21ec13..b79ebe2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -100,6 +100,7 @@ struct cmd_context {
 	struct dm_config_tree *cft;
 	struct config_info default_settings;
 	struct config_info current_settings;
+	struct dm_hash_table *cft_def_hash; /* cft definition hash used for validity check */
 
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
diff --git a/lib/config/config.c b/lib/config/config.c
index f2ee9e7..8234cf4 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -334,44 +334,77 @@ int config_def_get_path(char *buf, size_t buf_size, int id)
 	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id));
 }
 
-const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
-						   const char *path)
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_node(cmd->cft, path);
+	return dm_config_tree_find_node(cmd->cft, cfg_def_get_path(cfg_def_get_item_p(id)));
 }
 
-const char *find_config_tree_str(struct cmd_context *cmd,
-				 const char *path, const char *fail)
+const char *find_config_tree_str(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_str(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_STRING)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
+
+	return dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
 }
 
-const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
-					     const char *path, const char *fail)
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_str_allow_empty(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_STRING)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
+	if (!(item->flags & CFG_ALLOW_EMPTY))
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
+
+	return dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
 }
 
-int find_config_tree_int(struct cmd_context *cmd, const char *path,
-			 int fail)
+int find_config_tree_int(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_int(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_INT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
+
+	return dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
 }
 
-int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path, int64_t fail)
+int64_t find_config_tree_int64(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_int64(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_INT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
+
+	return dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
 }
 
-float find_config_tree_float(struct cmd_context *cmd, const char *path,
-			     float fail)
+float find_config_tree_float(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_float(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_FLOAT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
+
+	return dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_FLOAT));
 }
 
-int find_config_tree_bool(struct cmd_context *cmd, const char *path, int fail)
+int find_config_tree_bool(struct cmd_context *cmd, int id)
 {
-	return dm_config_tree_find_bool(cmd->cft, path, fail);
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	const char *path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_BOOL)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
+
+	return dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_BOOL));
 }
 
 /* Insert cn2 after cn1 */
diff --git a/lib/config/config.h b/lib/config/config.h
index 2317348..a239e1d 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -113,19 +113,12 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 /*
  * These versions check an override tree, if present, first.
  */
-const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
-						   const char *path);
-const char *find_config_tree_str(struct cmd_context *cmd,
-				 const char *path, const char *fail);
-const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
-					     const char *path, const char *fail);
-int find_config_tree_int(struct cmd_context *cmd, const char *path,
-			 int fail);
-int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path,
-			     int64_t fail);
-float find_config_tree_float(struct cmd_context *cmd, const char *path,
-			     float fail);
-
-int find_config_tree_bool(struct cmd_context *cmd, const char *path, int fail);
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id);
+const char *find_config_tree_str(struct cmd_context *cmd, int id);
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id);
+int find_config_tree_int(struct cmd_context *cmd, int id);
+int64_t find_config_tree_int64(struct cmd_context *cmd, int id);
+float find_config_tree_float(struct cmd_context *cmd, int id);
+int find_config_tree_bool(struct cmd_context *cmd, int id);
 
 #endif
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d39995e..cad9862 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -86,7 +86,6 @@
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_PVMETADATAIGNORE 0
-#define DEFAULT_PVMETADATAIGNORE_STR "n"
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_VGMETADATACOPIES 0
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9905045..0933549 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -675,7 +675,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	_cache.preferred_names_matcher = NULL;
 
-	if (!(cn = find_config_tree_node(cmd, "devices/preferred_names")) ||
+	if (!(cn = find_config_tree_node(cmd, devices_preferred_names_CFG)) ||
 	    cn->v->type == DM_CFG_EMPTY_ARRAY) {
 		log_very_verbose("devices/preferred_names not found in config file: "
 				 "using built-in preferences");
diff --git a/lib/display/display.c b/lib/display/display.c
index c0d0cd9..c766674 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -526,8 +526,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 	log_print("--- Logical volume ---");
 
-	lvm1compat = find_config_tree_int(cmd, "global/lvdisplay_shows_full_device_path",
-					  DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH);
+	lvm1compat = find_config_tree_bool(cmd, global_lvdisplay_shows_full_device_path_CFG);
 
 	if (lvm1compat)
 		/* /dev/vgname/lvname doen't actually exist for internal devices */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 774f6ce..951ec76 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1477,9 +1477,7 @@ static int _text_pv_initialise(const struct format_type *fmt,
 	unsigned long adjustment, final_alignment = 0;
 
 	if (!data_alignment)
-		data_alignment = find_config_tree_int(pv->fmt->cmd,
-					      "devices/data_alignment",
-					      0) * 2;
+		data_alignment = find_config_tree_int(pv->fmt->cmd, devices_data_alignment_CFG) * 2;
 
 	if (set_pe_align(pv, data_alignment) != data_alignment &&
 	    data_alignment) {
@@ -2443,7 +2441,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		goto bad;
 	}
 
-	if ((cn = find_config_tree_node(cmd, "metadata/dirs"))) {
+	if ((cn = find_config_tree_node(cmd, metadata_dirs_CFG))) {
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
@@ -2460,7 +2458,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		}
 	}
 
-	if ((cn = find_config_tree_node(cmd, "metadata/disk_areas"))) {
+	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG))) {
 		for (cn = cn->child; cn; cn = cn->sib) {
 			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
 				goto_bad;
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index 4dacbe4..1076174 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -80,8 +80,8 @@ int init_external_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->reset_locking = _reset_external_locking;
 	locking->flags = 0;
 
-	libname = find_config_tree_str(cmd, "global/locking_library",
-				       DEFAULT_LOCKING_LIB);
+	if (!(libname = find_config_tree_str(cmd, global_locking_library_CFG)))
+		libname = DEFAULT_LOCKING_LIB;
 
 	if (!(_locking_lib = load_shared_library(cmd, libname, "locking", 1)))
 		return_0;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 2b7bfe2..4711fa2 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -346,8 +346,7 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->flags = 0;
 
 	/* Get lockfile directory from config file */
-	locking_dir = find_config_tree_str(cmd, "global/locking_dir",
-					   DEFAULT_LOCK_DIR);
+	locking_dir = find_config_tree_str(cmd, global_locking_dir_CFG);
 	if (strlen(locking_dir) >= sizeof(_lock_dir)) {
 		log_error("Path for locking_dir %s is invalid.", locking_dir);
 		return 0;
@@ -356,8 +355,7 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	strcpy(_lock_dir, locking_dir);
 
 	_prioritise_write_locks =
-	    find_config_tree_bool(cmd, "global/prioritise_write_locks",
-				  DEFAULT_PRIORITISE_WRITE_LOCKS);
+	    find_config_tree_bool(cmd, global_prioritise_write_locks_CFG);
 
 	(void) dm_prepare_selinux_context(_lock_dir, S_IFDIR);
 	r = dm_create_dir(_lock_dir);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 6f31ba8..63f946f 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -225,10 +225,9 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 		suppress_messages = 1;
 
 	if (type < 0)
-		type = find_config_tree_int(cmd, "global/locking_type", 1);
+		type = find_config_tree_int(cmd, global_locking_type_CFG);
 
-	_blocking_supported = find_config_tree_int(cmd,
-	    "global/wait_for_locks", DEFAULT_WAIT_FOR_LOCKS);
+	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG);
 
 	switch (type) {
 	case 0:
@@ -255,9 +254,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 			if (init_external_locking(&_locking, cmd, suppress_messages))
 				return 1;
 		}
-		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
-			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
-						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))) {
+		if (!find_config_tree_bool(cmd, global_fallback_to_clustered_locking_CFG)) {
 			log_error_suppress(suppress_messages, "External locking initialisation failed.");
 			break;
 		}
@@ -290,9 +287,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 	}
 
 	if ((type == 2 || type == 3) &&
-	    find_config_tree_int(cmd, "locking/fallback_to_local_locking",
-	    	    find_config_tree_int(cmd, "global/fallback_to_local_locking",
-					 DEFAULT_FALLBACK_TO_LOCAL_LOCKING))) {
+	    find_config_tree_bool(cmd, global_fallback_to_local_locking_CFG)) {
 		log_warn_suppress(suppress_messages, "WARNING: Falling back to local file-based locking.");
 		log_warn_suppress(suppress_messages,
 				  "Volume Groups with the clustered attribute will "
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ef9f643..ad8160e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -95,8 +95,8 @@ int get_default_region_size(struct cmd_context *cmd)
 	 * 'mirror_region_size' is the old setting.  It is overridden
 	 * by the new setting, 'raid_region_size'.
 	 */
-	mrs = 2 * find_config_tree_int(cmd, "activation/mirror_region_size", 0);
-	rrs = 2 * find_config_tree_int(cmd, "activation/raid_region_size", 0);
+	mrs = 2 * find_config_tree_int(cmd, activation_mirror_region_size_CFG);
+	rrs = 2 * find_config_tree_int(cmd, activation_raid_region_size_CFG);
 
 	if (!mrs && !rrs)
 		return DEFAULT_RAID_REGION_SIZE * 2;
@@ -921,8 +921,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * a correct area_multiple.
 	 */
 	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
-	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs",
-							 DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
+	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG);
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
@@ -949,8 +948,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		ah->log_len = ah->region_size;
 		ah->region_size = 0;
 		ah->mirror_logs_separate =
-			find_config_tree_bool(cmd, "allocation/thin_pool_metadata_require_separate_pvs",
-					      DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS);
+			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG);
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -963,9 +961,9 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->parallel_areas = parallel_areas;
 
-	ah->cling_tag_list_cn = find_config_tree_node(cmd, "allocation/cling_tag_list");
+	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG);
 
-	ah->maximise_cling = find_config_tree_bool(cmd, "allocation/maximise_cling", DEFAULT_MAXIMISE_CLING);
+	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG);
 
 	return ah;
 }
@@ -3389,8 +3387,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* FIXME Ensure not referred to by another existing LVs */
-	ask_discard = find_config_tree_bool(cmd,
-					    "devices/issue_discards", DEFAULT_ISSUE_DISCARDS);
+	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG);
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0996184..403d86d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -74,9 +74,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 		goto out;
 	}
 
-	default_pe_align = find_config_tree_int(pv->fmt->cmd,
-						"devices/default_data_alignment",
-						DEFAULT_DATA_ALIGNMENT);
+	default_pe_align = find_config_tree_int(pv->fmt->cmd, devices_default_data_alignment_CFG);
 
 	if (default_pe_align)
 		/* align on 1 MiB multiple */
@@ -94,8 +92,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	/*
 	 * Align to stripe-width of underlying md device if present
 	 */
-	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
-				  DEFAULT_MD_CHUNK_ALIGNMENT)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
@@ -108,9 +105,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * - optimal_io_size - the device's preferred unit of receiving I/O
 	 *   (e.g. MD's stripe width)
 	 */
-	if (find_config_tree_bool(pv->fmt->cmd,
-				  "devices/data_alignment_detection",
-				  DEFAULT_DATA_ALIGNMENT_DETECTION)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
 		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
@@ -142,9 +137,7 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 	if (!pv->dev)
 		goto out;
 
-	if (find_config_tree_bool(pv->fmt->cmd,
-				  "devices/data_alignment_offset_detection",
-				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_offset_detection_CFG)) {
 		int align_offset = dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
 							pv->dev);
 		/* must handle a -1 alignment_offset; means dev is misaligned */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 2a78508..04a5638 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1230,19 +1230,16 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 static int _get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
 				   int log_policy)
 {
-	const char *policy;
-
+	const char *policy = NULL;
+/*
 	if (log_policy)
-		policy = dm_config_find_str(NULL, "activation/mirror_log_fault_policy",
-					 DEFAULT_MIRROR_LOG_FAULT_POLICY);
+		policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG);
 	else {
-		policy = dm_config_find_str(NULL, "activation/mirror_image_fault_policy",
-					 NULL);
+		policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG);
 		if (!policy)
-			policy = dm_config_find_str(NULL, "activation/mirror_device_fault_policy",
-						 DEFAULT_MIRROR_IMAGE_FAULT_POLICY);
+			policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG);
 	}
-
+*/
 	if (!strcmp(policy, "remove"))
 		return MIRROR_REMOVE;
 	else if (!strcmp(policy, "allocate"))
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 83aa9af..4a65a3e 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -203,8 +203,7 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 	 * Only issue discards if enabled in lvm.conf and both
 	 * the device and kernel (>= 2.6.35) supports discards.
 	 */
-	if (!find_config_tree_bool(peg->pv->fmt->cmd,
-				   "devices/issue_discards", DEFAULT_ISSUE_DISCARDS))
+	if (!find_config_tree_bool(peg->pv->fmt->cmd, devices_issue_discards_CFG))
 		return 1;
  
 	/* Missing PV? */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 59748de..c994a2e 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -312,9 +312,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	percent_t percent;
 	int threshold = PERCENT_1 *
-		find_config_tree_int(pool_seg->lv->vg->cmd,
-				     "activation/thin_pool_autoextend_threshold",
-				     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD);
+		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG);
 
 	/* Data */
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 58afab3..6ce929d 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -540,8 +540,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 #ifdef DMEVENTD
 static const char *_get_mirror_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/mirror_library",
-							      DEFAULT_DMEVENTD_MIRROR_LIB));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_mirror_library_CFG));
 }
 
 /* FIXME Cache this */
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 4c2d178..b899781 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -30,7 +30,7 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 	/* If libname doesn't begin with '/' then use lib_dir/libname,
 	 * if present */
 	if (libname[0] == '/' ||
-	    !(lib_dir = find_config_tree_str(cmd, "global/library_dir", 0)) ||
+	    !(lib_dir = find_config_tree_str(cmd, global_library_dir_CFG)) ||
 	    (dm_snprintf(path, path_len, "%s/%s", lib_dir,
 			 libname) == -1) || stat(path, &info) == -1) {
 		strncpy(path, libname, path_len - 1);
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 6defa66..098de9e 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -290,7 +290,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 	}
 
 	line = _maps_buffer;
-	cn = find_config_tree_node(cmd, "activation/mlock_filter");
+	cn = find_config_tree_node(cmd, activation_mlock_filter_CFG);
 
 	while ((line_end = strchr(line, '\n'))) {
 		*line_end = '\0'; /* remove \n */
@@ -317,7 +317,7 @@ static void _lock_mem(struct cmd_context *cmd)
 	 * Note: assuming _memlock_count_daemon is updated before _memlock_count
          */
 	_use_mlockall = _memlock_count_daemon ? 1 :
-		find_config_tree_bool(cmd, "activation/use_mlockall", DEFAULT_USE_MLOCKALL);
+		find_config_tree_bool(cmd, activation_use_mlockall_CFG);
 
 	if (!_use_mlockall) {
 		if (!*_procselfmaps &&
@@ -453,14 +453,9 @@ void memlock_init(struct cmd_context *cmd)
 {
 	/* When threaded, caller already limited stack size so just use the default. */
 	_size_stack = 1024ULL * (cmd->threaded ? DEFAULT_RESERVED_STACK :
-				 find_config_tree_int(cmd, "activation/reserved_stack",
-						      DEFAULT_RESERVED_STACK));
-	_size_malloc_tmp = find_config_tree_int(cmd,
-					   "activation/reserved_memory",
-					   DEFAULT_RESERVED_MEMORY) * 1024ULL;
-	_default_priority = find_config_tree_int(cmd,
-					    "activation/process_priority",
-					    DEFAULT_PROCESS_PRIORITY);
+				 find_config_tree_int(cmd, activation_reserved_stack_CFG));
+	_size_malloc_tmp = find_config_tree_int(cmd, activation_reserved_memory_CFG) * 1024ULL;
+	_default_priority = find_config_tree_int(cmd, activation_process_priority_CFG);
 }
 
 void memlock_reset(void)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 78fe074..1e28c73 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -282,8 +282,7 @@ static void _raid_destroy(struct segment_type *segtype)
 #ifdef DMEVENTD
 static const char *_get_raid_dso_path(struct cmd_context *cmd)
 {
-	const char *config_str = find_config_tree_str(cmd, "dmeventd/raid_library",
-						      DEFAULT_DMEVENTD_RAID_LIB);
+	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG);
 	return get_monitor_dso_path(cmd, config_str);
 }
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 662614c..3c03ea9 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -175,8 +175,7 @@ static int _snap_target_present(struct cmd_context *cmd,
 
 static const char *_get_snapshot_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/snapshot_library",
-							      DEFAULT_DMEVENTD_SNAPSHOT_LIB));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_snapshot_library_CFG));
 }
 
 /* FIXME Cache this */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 3e1da91..4bfae33 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -379,8 +379,7 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 #  ifdef DMEVENTD
 static const char *_get_thin_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/thin_library",
-							      DEFAULT_DMEVENTD_THIN_LIB));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_thin_library_CFG));
 }
 
 /* FIXME Cache this */
@@ -596,7 +595,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 	if (attributes) {
 		if (!_feature_mask) {
 			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
-			if ((cn = find_config_tree_node(cmd, _lvmconf))) {
+			if ((cn = find_config_tree_node(cmd, global_thin_disabled_features_CFG))) {
 				for (cv = cn->v; cv; cv = cv->next) {
 					if (cv->type != DM_CFG_STRING) {
 						log_error("Ignoring invalid string in config file %s.",
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index b4911df..53be709 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -96,7 +96,9 @@ int lvm_config_override(lvm_t libh, const char *config_settings)
 
 int lvm_config_find_bool(lvm_t libh, const char *config_path, int fail)
 {
-	return find_config_tree_bool((struct cmd_context *)libh, config_path, fail);
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+
+	return dm_config_tree_find_bool(cmd->cft, config_path, fail);
 }
 
 int lvm_errno(lvm_t libh)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 234eb41..fcfcddb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -837,15 +837,10 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 	*replace_log = *replace_mirrors = 1;
 
 	if (arg_count(cmd, use_policies_ARG)) {
-		leg_policy = find_config_tree_str(cmd,
-					"activation/mirror_image_fault_policy", NULL);
+		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG);
 		if (!leg_policy)
-			leg_policy = find_config_tree_str(cmd,
-					"activation/mirror_device_fault_policy",
-					DEFAULT_MIRROR_DEVICE_FAULT_POLICY);
-		log_policy = find_config_tree_str(cmd,
-					"activation/mirror_log_fault_policy",
-					DEFAULT_MIRROR_LOG_FAULT_POLICY);
+			leg_policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG);
+		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG);
 		*replace_mirrors = strcmp(leg_policy, "remove");
 		*replace_log = strcmp(log_policy, "remove");
 		return;
@@ -1571,7 +1566,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 	*replace_dev = 1;
 
 	if (arg_count(cmd, use_policies_ARG)) {
-		dev_policy = find_config_tree_str(cmd, "activation/raid_fault_policy", DEFAULT_RAID_FAULT_POLICY);
+		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG);
 
 		if (!strcmp(dev_policy, "allocate") ||
 		    !strcmp(dev_policy, "replace"))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a2626c0..4618321 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -506,9 +506,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 		}
 		/* No stripe argument was given - default to 2 */
 		lp->stripes = 2;
-		lp->stripe_size = find_config_tree_int(cmd,
-						       "metadata/stripesize",
-						       DEFAULT_STRIPESIZE) * 2;
+		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
 	}
 
 	/*
@@ -675,9 +673,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (arg_count(cmd, mirrors_ARG))
 		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
 				   stripes_long_ARG : stripes_ARG, 1) > 1) {
-			segtype_str = find_config_tree_str(cmd, "global/raid10_segtype_default", DEFAULT_RAID10_SEGTYPE);
+			segtype_str = find_config_tree_str(cmd, global_raid10_segtype_default_CFG);;
 		} else {
-			segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+			segtype_str = find_config_tree_str(cmd, global_mirror_segtype_default_CFG);
 		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
diff --git a/tools/lvm.c b/tools/lvm.c
index ec9674e..9b66516 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -158,8 +158,7 @@ static void _read_history(struct cmd_context *cmd)
 	if (read_history(hist_file))
 		log_very_verbose("Couldn't read history from %s.", hist_file);
 
-	stifle_history(find_config_tree_int(cmd, "shell/history_size",
-				       DEFAULT_MAX_HISTORY));
+	stifle_history(find_config_tree_int(cmd, shell_history_size_CFG));
 }
 
 static void _write_history(void)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c37ae25..c7820e0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1443,8 +1443,7 @@ static int _lvm1_fallback(struct cmd_context *cmd)
 	char vsn[80];
 	int dm_present;
 
-	if (!find_config_tree_int(cmd, "global/fallback_to_lvm1",
-			     DEFAULT_FALLBACK_TO_LVM1) ||
+	if (!find_config_tree_bool(cmd, global_fallback_to_lvm1_CFG) ||
 	    strncmp(cmd->kernel_vsn, "2.4.", 4))
 		return 0;
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index d49da8a..e44fd82 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -288,20 +288,16 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
-			find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
-					     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG) * PERCENT_1;
 		policy_amount =
-			find_config_tree_int(cmd, "activation/thin_pool_autoextend_percent",
-					     DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT);
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG);
 		if (!policy_amount && policy_threshold < PERCENT_100)
                         return 0;
 	} else {
 		policy_threshold =
-			find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
-					     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG) * PERCENT_1;
 		policy_amount =
-			find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
-					     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
+			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG);
 	}
 
 	if (policy_threshold >= PERCENT_100)
@@ -652,9 +648,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 				lp->stripe_size = seg_stripesize;
 			} else {
 				lp->stripe_size =
-					find_config_tree_int(cmd,
-							"metadata/stripesize",
-							DEFAULT_STRIPESIZE) * 2;
+					find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
 				log_print_unless_silent("Using default stripesize %s",
 							display_size(cmd, (uint64_t) lp->stripe_size));
 			}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index a9138a1..5724623 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -319,8 +319,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	if (interval_sign == SIGN_MINUS)
 		log_error("Argument to --interval cannot be negative");
 	parms.interval = arg_uint_value(cmd, interval_ARG,
-					find_config_tree_int(cmd, "activation/polling_interval",
-							     DEFAULT_INTERVAL));
+					find_config_tree_int(cmd, activation_polling_interval_CFG));
 	parms.wait_before_testing = (interval_sign == SIGN_PLUS);
 	parms.progress_display = 1;
 	parms.progress_title = progress_title;
@@ -337,8 +336,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 
 		/* FIXME Disabled multiple-copy wait_event */
 		if (!name)
-			parms.interval = find_config_tree_int(cmd, "activation/polling_interval",
-							      DEFAULT_INTERVAL);
+			parms.interval = find_config_tree_int(cmd, activation_polling_interval_CFG);
 	}
 
 	if (parms.background) {
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 5b83a18..da51eec 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -38,9 +38,7 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 
 	if (!arg_count(cmd, restorefile_ARG) && arg_count(cmd, uuidstr_ARG)) {
 		if (!arg_count(cmd, norestorefile_ARG) &&
-		    find_config_tree_bool(cmd,
-					  "devices/require_restorefile_with_uuid",
-					  DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID)) {
+		    find_config_tree_bool(cmd, devices_require_restorefile_with_uuid_CFG)) {
 			log_error("--restorefile is required with --uuid");
 			return 0;
 		}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index ff5ced2..ab58c5f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -146,8 +146,8 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	 * and to prevent hangs in clustered environment.
 	 */
 	/* TODO: Remove this once lvmetad + cluster supported! */
-	if (find_config_tree_int(cmd, "global/locking_type", 1) == 3 ||
-	    !find_config_tree_int(cmd, "global/use_lvmetad", 0)) {
+	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 ||
+	    !find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
 		log_debug_lvmetad("_pvscan_lvmetad: immediate return");
 		return ret;
 	}
diff --git a/tools/reporter.c b/tools/reporter.c
index 1c8e39d..3db8b83 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -234,20 +234,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int columns_as_rows;
 	unsigned args_are_pvs;
 
-	aligned = find_config_tree_int(cmd, "report/aligned",
-				  DEFAULT_REP_ALIGNED);
-	buffered = find_config_tree_int(cmd, "report/buffered",
-				   DEFAULT_REP_BUFFERED);
-	headings = find_config_tree_int(cmd, "report/headings",
-				   DEFAULT_REP_HEADINGS);
-	separator = find_config_tree_str(cmd, "report/separator",
-				    DEFAULT_REP_SEPARATOR);
-	field_prefixes = find_config_tree_int(cmd, "report/prefixes",
-					      DEFAULT_REP_PREFIXES);
-	quoted = find_config_tree_int(cmd, "report/quoted",
-				     DEFAULT_REP_QUOTED);
-	columns_as_rows = find_config_tree_int(cmd, "report/columns_as_rows",
-					       DEFAULT_REP_COLUMNS_AS_ROWS);
+	aligned = find_config_tree_bool(cmd, report_aligned_CFG);
+	buffered = find_config_tree_bool(cmd, report_buffered_CFG);
+	headings = find_config_tree_bool(cmd, report_headings_CFG);
+	separator = find_config_tree_str(cmd, report_separator_CFG);
+	field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG);
+	quoted = find_config_tree_bool(cmd, report_quoted_CFG);
+	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG);
 
 	args_are_pvs = (report_type == PVS ||
 			report_type == LABEL ||
@@ -255,65 +248,40 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	switch (report_type) {
 	case LVS:
-		keys = find_config_tree_str(cmd, "report/lvs_sort",
-				       DEFAULT_LVS_SORT);
+		keys = find_config_tree_str(cmd, report_lvs_sort_CFG);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd,
-						  "report/lvs_cols",
-						  DEFAULT_LVS_COLS);
+			options = find_config_tree_str(cmd, report_lvs_cols_CFG);
 		else
-			options = find_config_tree_str(cmd,
-						  "report/lvs_cols_verbose",
-						  DEFAULT_LVS_COLS_VERB);
+			options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG);
 		break;
 	case VGS:
-		keys = find_config_tree_str(cmd, "report/vgs_sort",
-				       DEFAULT_VGS_SORT);
+		keys = find_config_tree_str(cmd, report_vgs_sort_CFG);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd,
-						  "report/vgs_cols",
-						  DEFAULT_VGS_COLS);
+			options = find_config_tree_str(cmd, report_vgs_cols_CFG);
 		else
-			options = find_config_tree_str(cmd,
-						  "report/vgs_cols_verbose",
-						  DEFAULT_VGS_COLS_VERB);
+			options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG);
 		break;
 	case LABEL:
 	case PVS:
-		keys = find_config_tree_str(cmd, "report/pvs_sort",
-				       DEFAULT_PVS_SORT);
+		keys = find_config_tree_str(cmd, report_pvs_sort_CFG);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd,
-						  "report/pvs_cols",
-						  DEFAULT_PVS_COLS);
+			options = find_config_tree_str(cmd, report_pvs_cols_CFG);
 		else
-			options = find_config_tree_str(cmd,
-						  "report/pvs_cols_verbose",
-						  DEFAULT_PVS_COLS_VERB);
+			options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG);
 		break;
 	case SEGS:
-		keys = find_config_tree_str(cmd, "report/segs_sort",
-				       DEFAULT_SEGS_SORT);
+		keys = find_config_tree_str(cmd, report_segs_sort_CFG);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd,
-						  "report/segs_cols",
-						  DEFAULT_SEGS_COLS);
+			options = find_config_tree_str(cmd, report_segs_cols_CFG);
 		else
-			options = find_config_tree_str(cmd,
-						  "report/segs_cols_verbose",
-						  DEFAULT_SEGS_COLS_VERB);
+			options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG);
 		break;
 	case PVSEGS:
-		keys = find_config_tree_str(cmd, "report/pvsegs_sort",
-				       DEFAULT_PVSEGS_SORT);
+		keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd,
-						  "report/pvsegs_cols",
-						  DEFAULT_PVSEGS_COLS);
+			options = find_config_tree_str(cmd, report_pvsegs_cols_CFG);
 		else
-			options = find_config_tree_str(cmd,
-						  "report/pvsegs_cols_verbose",
-						  DEFAULT_PVSEGS_COLS_VERB);
+			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG);
 		break;
 	default:
 		log_error(INTERNAL_ERROR "Unknown report type.");
diff --git a/tools/toollib.c b/tools/toollib.c
index 7043ea4..6b00155 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1290,9 +1290,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	} else {
-		vp_new->vgmetadatacopies = find_config_tree_int(cmd,
-						   "metadata/vgmetadatacopies",
-						   DEFAULT_VGMETADATACOPIES);
+		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG);
 	}
 
 	return 1;
@@ -1426,17 +1424,12 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, metadataignore_ARG)) {
-		pp->metadataignore = !strcmp(arg_str_value(cmd,
-						metadataignore_ARG,
-						DEFAULT_PVMETADATAIGNORE_STR),
-					 "y");
-	} else {
-		pp->metadataignore = !strcmp(find_config_tree_str(cmd,
-					"metadata/pvmetadataignore",
-					DEFAULT_PVMETADATAIGNORE_STR),
-					"y");
-	}
+	if (arg_count(cmd, metadataignore_ARG))
+		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
+						   DEFAULT_PVMETADATAIGNORE);
+	else
+		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG);
+
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
 	    pp->metadataignore) {
@@ -1496,15 +1489,11 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 
 	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
 	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd,
-						 "metadata/pvmetadatasize",
-						 DEFAULT_PVMETADATASIZE);
+		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG);
 
 	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd,
-						   "metadata/pvmetadatacopies",
-						   DEFAULT_PVMETADATACOPIES);
+		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
 
 	pp->rp.ea_size = arg_uint64_value(cmd, embeddingareasize_ARG, pp->rp.ea_size);
 
@@ -1528,8 +1517,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 						 DEFAULT_DMEVENTD_MONITOR);
 	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
 		 arg_count(cmd, sysinit_ARG) ||
-		 !find_config_tree_bool(cmd, "activation/monitoring",
-					DEFAULT_DMEVENTD_MONITOR))
+		 !find_config_tree_bool(cmd, activation_monitoring_CFG))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
 
 	return 1;
@@ -1547,18 +1535,14 @@ int get_pool_params(struct cmd_context *cmd,
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
 	} else
-		*zero = find_config_tree_int(cmd,
-					     "allocation/thin_pool_zero",
-					     DEFAULT_THIN_POOL_ZERO);
+		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG);
 
 	if (arg_count(cmd, discards_ARG)) {
 		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 		log_very_verbose("Setting pool discards: %s",
 				 get_pool_discards_name(*discards));
 	} else {
-		dstr = find_config_tree_str(cmd,
-					    "allocation/thin_pool_discards",
-					    DEFAULT_THIN_POOL_DISCARDS);
+		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG);
 		if (!get_pool_discards(dstr, discards))
 			return_0;
 	}
@@ -1573,9 +1557,7 @@ int get_pool_params(struct cmd_context *cmd,
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	} else
-		*chunk_size = find_config_tree_int(cmd,
-						   "allocation/thin_pool_chunk_size",
-						   DEFAULT_THIN_POOL_CHUNK_SIZE) * 2;
+		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG) * 2;
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
@@ -1737,7 +1719,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 	}
 
 	if (*stripes > 1 && !*stripe_size) {
-		*stripe_size = find_config_tree_int(cmd, "metadata/stripesize", DEFAULT_STRIPESIZE) * 2;
+		*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
 		log_print_unless_silent("Using default stripesize %s",
 			  display_size(cmd, (uint64_t) *stripe_size));
 	}
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 3671767..cdadd9a 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -51,16 +51,12 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 						  UINT64_C(0));
 		if (!pvmetadatasize)
 			pvmetadatasize =
-			    find_config_tree_int(cmd,
-					    "metadata/pvmetadatasize",
-					    DEFAULT_PVMETADATASIZE);
+			    find_config_tree_int(cmd, metadata_pvmetadatasize_CFG);
 
 		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 		if (pvmetadatacopies < 0)
 			pvmetadatacopies =
-			    find_config_tree_int(cmd,
-					    "metadata/pvmetadatacopies",
-					     DEFAULT_PVMETADATACOPIES);
+			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
 	}
 
 	if (cmd->fmt->features & FMT_EAS) {


