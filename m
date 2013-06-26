From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:05 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_bool
Message-ID: <20130626145605.2C47061605@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00255dc6d473f20364960fff2acda69c50697e1d
Commit:        00255dc6d473f20364960fff2acda69c50697e1d
Parent:        9f80cc1b92f1ac038f3eba11e85522621f413dc5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:31:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_bool

---
 lib/activate/dev_manager.c |    2 +-
 lib/commands/toolcontext.c |   64 ++++++++++++++++++++++----------------------
 lib/config/config.c        |   16 +++++++++--
 lib/config/config.h        |    2 +-
 lib/display/display.c      |    2 +-
 lib/locking/file_locking.c |    2 +-
 lib/locking/locking.c      |    6 ++--
 lib/metadata/lv_manip.c    |    8 +++---
 lib/metadata/metadata.c    |    6 ++--
 lib/metadata/pv_manip.c    |    2 +-
 lib/mm/memlock.c           |    2 +-
 tools/lvmcmdline.c         |    2 +-
 tools/pvcreate.c           |    2 +-
 tools/pvscan.c             |    2 +-
 tools/reporter.c           |   12 ++++----
 tools/toollib.c            |    6 ++--
 16 files changed, 73 insertions(+), 63 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d07e04a..85bd724 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1342,7 +1342,7 @@ static int _check_udev_fallback(struct cmd_context *cmd)
 	 * variable or udev rules are switched off.
 	 */
 	settings->udev_fallback = !settings->udev_rules ? 1 :
-		find_config_tree_bool(cmd, activation_verify_udev_operations_CFG);
+		find_config_tree_bool(cmd, activation_verify_udev_operations_CFG, NULL);
 
 	/* Do not rely fully on udev if the udev support is known to be incomplete. */
 	if (!settings->udev_fallback && !_dm_driver_has_stable_udev_support()) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f5e0541..d736521 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -175,7 +175,7 @@ static void _init_logging(struct cmd_context *cmd)
 	char timebuf[26];
 
 	/* Syslog */
-	cmd->default_settings.syslog = find_config_tree_bool(cmd, log_syslog_CFG);
+	cmd->default_settings.syslog = find_config_tree_bool(cmd, log_syslog_CFG, NULL);
 	if (cmd->default_settings.syslog != 1)
 		fin_syslog();
 
@@ -192,30 +192,30 @@ static void _init_logging(struct cmd_context *cmd)
 	 * Once set to 1, there is no facility to change it back to 0.
 	 */
 	cmd->default_settings.silent = silent_mode() ? :
-	    find_config_tree_bool(cmd, log_silent_CFG);
+	    find_config_tree_bool(cmd, log_silent_CFG, NULL);
 	init_silent(cmd->default_settings.silent);
 
 	/* Verbose level for tty output */
-	cmd->default_settings.verbose = find_config_tree_bool(cmd, log_verbose_CFG);
+	cmd->default_settings.verbose = find_config_tree_bool(cmd, log_verbose_CFG, NULL);
 	init_verbose(cmd->default_settings.verbose + VERBOSE_BASE_LEVEL);
 
 	/* Log message formatting */
-	init_indent(find_config_tree_bool(cmd, log_indent_CFG));
-	init_abort_on_internal_errors(find_config_tree_bool(cmd, global_abort_on_internal_errors_CFG));
+	init_indent(find_config_tree_bool(cmd, log_indent_CFG, NULL));
+	init_abort_on_internal_errors(find_config_tree_bool(cmd, global_abort_on_internal_errors_CFG, NULL));
 
 	cmd->default_settings.msg_prefix = find_config_tree_str_allow_empty(cmd, log_prefix_CFG, NULL);
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
-	cmd->default_settings.cmd_name = find_config_tree_bool(cmd, log_command_names_CFG);
+	cmd->default_settings.cmd_name = find_config_tree_bool(cmd, log_command_names_CFG, NULL);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
 	/* Test mode */
 	cmd->default_settings.test =
-	    find_config_tree_bool(cmd, global_test_CFG);
+	    find_config_tree_bool(cmd, global_test_CFG, NULL);
 	init_test(cmd->default_settings.test);
 
 	/* Settings for logging to file */
-	if (find_config_tree_bool(cmd, log_overwrite_CFG))
+	if (find_config_tree_bool(cmd, log_overwrite_CFG, NULL))
 		append = 0;
 
 	log_file = find_config_tree_str(cmd, log_file_CFG, NULL);
@@ -230,7 +230,7 @@ static void _init_logging(struct cmd_context *cmd)
 	if (log_file)
 		init_log_direct(log_file, append);
 
-	init_log_while_suspended(find_config_tree_bool(cmd, log_activation_CFG));
+	init_log_while_suspended(find_config_tree_bool(cmd, log_activation_CFG, NULL));
 
 	cmd->default_settings.debug_classes = _parse_debug_classes(cmd);
 	log_debug("Setting log debug classes to %d", cmd->default_settings.debug_classes);
@@ -276,7 +276,7 @@ static int _process_config(struct cmd_context *cmd)
 	int udev_disabled = 0;
 	char sysfs_dir[PATH_MAX];
 
-	if (!config_def_check(cmd, 0, 0, 0) && find_config_tree_bool(cmd, config_abort_on_errors_CFG)) {
+	if (!config_def_check(cmd, 0, 0, 0) && find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL)) {
 		log_error("LVM configuration invalid.");
 		return 0;
 	}
@@ -319,10 +319,10 @@ static int _process_config(struct cmd_context *cmd)
 	dm_set_sysfs_dir(sysfs_dir);
 
 	/* activation? */
-	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG);
+	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG, NULL);
 	set_activation(cmd->default_settings.activation);
 
-	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG);
+	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 
 	if (!(cmd->default_settings.unit_factor =
 	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG, NULL),
@@ -351,10 +351,10 @@ static int _process_config(struct cmd_context *cmd)
 	udev_disabled = _check_disable_udev("manage logical volume symlinks in device directory");
 
 	cmd->default_settings.udev_rules = udev_disabled ? 0 :
-		find_config_tree_bool(cmd, activation_udev_rules_CFG);
+		find_config_tree_bool(cmd, activation_udev_rules_CFG, NULL);
 
 	cmd->default_settings.udev_sync = udev_disabled ? 0 :
-		find_config_tree_bool(cmd, activation_udev_sync_CFG);
+		find_config_tree_bool(cmd, activation_udev_sync_CFG, NULL);
 
 	/*
 	 * Set udev_fallback lazily on first use since it requires
@@ -364,11 +364,11 @@ static int _process_config(struct cmd_context *cmd)
 	 */
 	cmd->default_settings.udev_fallback = udev_disabled ? 1 : -1;
 
-	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG));
+	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG, NULL));
 
-	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG));
+	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG, NULL));
 
-	cmd->use_linear_target = find_config_tree_bool(cmd, activation_use_linear_target_CFG);
+	cmd->use_linear_target = find_config_tree_bool(cmd, activation_use_linear_target_CFG, NULL);
 
 	cmd->stripe_filler = find_config_tree_str(cmd, activation_missing_stripe_filler_CFG, NULL);
 
@@ -392,14 +392,14 @@ static int _process_config(struct cmd_context *cmd)
 		}
 	}
 
-	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG);
+	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
 
 	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL)))
 		for (cv = cn->v; cv; cv = cv->next) 
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
 
-	cmd->metadata_read_only = find_config_tree_bool(cmd, global_metadata_read_only_CFG);
+	cmd->metadata_read_only = find_config_tree_bool(cmd, global_metadata_read_only_CFG, NULL);
 
 	pv_min_kb = find_config_tree_int64(cmd, devices_pv_min_size_CFG, NULL);
 	if (pv_min_kb < PV_MIN_SIZE_KB) {
@@ -411,7 +411,7 @@ static int _process_config(struct cmd_context *cmd)
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
 	init_detect_internal_vg_cache_corruption
-		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG));
+		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
 	lvmetad_disconnect();
 
@@ -428,12 +428,12 @@ static int _process_config(struct cmd_context *cmd)
 	lvmetad_set_token(cn ? cn->v : NULL);
 
 	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
-	    find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
+	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
 		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
 		lvmetad_set_active(0);
 	} else
-		lvmetad_set_active(find_config_tree_bool(cmd, global_use_lvmetad_CFG));
+		lvmetad_set_active(find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
 
 	lvmetad_init(cmd);
 
@@ -498,7 +498,7 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 		return 1;
 
 	/* NB hosttags 0 when already 1 intentionally does not delete the tag */
-	if (!cmd->hosttags && find_config_tree_bool(cmd, tags_hosttags_CFG)) {
+	if (!cmd->hosttags && find_config_tree_bool(cmd, tags_hosttags_CFG, NULL)) {
 		/* FIXME Strip out invalid chars: only A-Za-z0-9_+.- */
 		if (!_set_tag(cmd, cmd->hostname))
 			return_0;
@@ -808,7 +808,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		device_list_from_udev = 0;
 	else
 		device_list_from_udev = udev_is_running() ?
-			find_config_tree_bool(cmd, devices_obtain_device_list_from_udev_CFG) : 0;
+			find_config_tree_bool(cmd, devices_obtain_device_list_from_udev_CFG, NULL) : 0;
 
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
@@ -899,7 +899,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	 * Listed first because it's very efficient at eliminating
 	 * unavailable devices.
 	 */
-	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG)) {
+	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG, NULL)) {
 		if ((filters[nr_filt] = sysfs_filter_create()))
 			nr_filt++;
 	}
@@ -923,14 +923,14 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	nr_filt++;
 
 	/* md component filter. Optional, non-critical. */
-	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG)) {
+	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG, NULL)) {
 		init_md_filtering(1);
 		if ((filters[nr_filt] = md_filter_create(cmd->dev_types)))
 			nr_filt++;
 	}
 
 	/* mpath component filter. Optional, non-critical. */
-	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG)) {
+	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL)) {
 		if ((filters[nr_filt] = mpath_filter_create(cmd->dev_types)))
 			nr_filt++;
 	}
@@ -963,7 +963,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	if (!(f3 = _init_filter_components(cmd)))
 		goto_bad;
 
-	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG));
+	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
 
 	/*
 	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
@@ -1000,7 +1000,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	}
 
 	/* Should we ever dump persistent filter state? */
-	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG))
+	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG, NULL))
 		cmd->dump_filter = 1;
 
 	if (!*cmd->system_dir)
@@ -1011,7 +1011,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	 * than the config file and this is not a long-lived process. Also avoid
 	 * it when lvmetad is enabled.
 	 */
-	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG) &&
+	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL) &&
 	    load_persistent_cache && !cmd->is_long_lived &&
 	    !stat(dev_cache, &st) &&
 	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
@@ -1331,7 +1331,7 @@ static int _init_backup(struct cmd_context *cmd)
 
 	/* set up archiving */
 	cmd->default_settings.archive =
-	    find_config_tree_bool(cmd, backup_archive_CFG);
+	    find_config_tree_bool(cmd, backup_archive_CFG, NULL);
 
 	days = (uint32_t) find_config_tree_int(cmd, backup_retain_days_CFG, NULL);
 
@@ -1355,7 +1355,7 @@ static int _init_backup(struct cmd_context *cmd)
 	}
 
 	/* set up the backup */
-	cmd->default_settings.backup = find_config_tree_bool(cmd, backup_backup_CFG);
+	cmd->default_settings.backup = find_config_tree_bool(cmd, backup_backup_CFG, NULL);
 
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
diff --git a/lib/config/config.c b/lib/config/config.c
index 731de1f..b6ddcb7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -669,7 +669,7 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 		def->flags &= ~(CFG_USED | CFG_VALID);
 	}
 
-	if (!force && !find_config_tree_bool(cmd, config_checks_CFG)) {
+	if (!force && !find_config_tree_bool(cmd, config_checks_CFG, NULL)) {
 		if (cmd->cft_def_hash) {
 			dm_hash_destroy(cmd->cft_def_hash);
 			cmd->cft_def_hash = NULL;
@@ -866,15 +866,25 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	return f;
 }
 
-int find_config_tree_bool(struct cmd_context *cmd, int id)
+int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	int b;
 
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	return dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_BOOL));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_BOOL));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return b;
 }
 
 /* Insert cn2 after cn1 */
diff --git a/lib/config/config.h b/lib/config/config.h
index 8ec4e75..483d8a5 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -166,6 +166,6 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile);
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile);
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile);
-int find_config_tree_bool(struct cmd_context *cmd, int id);
+int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile);
 
 #endif
diff --git a/lib/display/display.c b/lib/display/display.c
index 26bc384..121a85e 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -526,7 +526,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 	log_print("--- Logical volume ---");
 
-	lvm1compat = find_config_tree_bool(cmd, global_lvdisplay_shows_full_device_path_CFG);
+	lvm1compat = find_config_tree_bool(cmd, global_lvdisplay_shows_full_device_path_CFG, NULL);
 
 	if (lvm1compat)
 		/* /dev/vgname/lvname doen't actually exist for internal devices */
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 9cfd8eb..5e49bc4 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -355,7 +355,7 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	strcpy(_lock_dir, locking_dir);
 
 	_prioritise_write_locks =
-	    find_config_tree_bool(cmd, global_prioritise_write_locks_CFG);
+	    find_config_tree_bool(cmd, global_prioritise_write_locks_CFG, NULL);
 
 	(void) dm_prepare_selinux_context(_lock_dir, S_IFDIR);
 	r = dm_create_dir(_lock_dir);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 7d9db60..cdd6ac4 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -227,7 +227,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 	if (type < 0)
 		type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
 
-	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG);
+	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG, NULL);
 
 	switch (type) {
 	case 0:
@@ -254,7 +254,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 			if (init_external_locking(&_locking, cmd, suppress_messages))
 				return 1;
 		}
-		if (!find_config_tree_bool(cmd, global_fallback_to_clustered_locking_CFG)) {
+		if (!find_config_tree_bool(cmd, global_fallback_to_clustered_locking_CFG, NULL)) {
 			log_error_suppress(suppress_messages, "External locking initialisation failed.");
 			break;
 		}
@@ -287,7 +287,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 	}
 
 	if ((type == 2 || type == 3) &&
-	    find_config_tree_bool(cmd, global_fallback_to_local_locking_CFG)) {
+	    find_config_tree_bool(cmd, global_fallback_to_local_locking_CFG, NULL)) {
 		log_warn_suppress(suppress_messages, "WARNING: Falling back to local file-based locking.");
 		log_warn_suppress(suppress_messages,
 				  "Volume Groups with the clustered attribute will "
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e74b6f1..c9af654 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1015,7 +1015,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * a correct area_multiple.
 	 */
 	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
-	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG);
+	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
@@ -1042,7 +1042,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		ah->log_len = ah->region_size;
 		ah->region_size = 0;
 		ah->mirror_logs_separate =
-			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG);
+			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG, NULL);
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -1057,7 +1057,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL);
 
-	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG);
+	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
 
 	return ah;
 }
@@ -3481,7 +3481,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* FIXME Ensure not referred to by another existing LVs */
-	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG);
+	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0dfb23b..e12e1b0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -83,7 +83,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	/*
 	 * Align to stripe-width of underlying md device if present
 	 */
-	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG, NULL)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->dev_types, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
@@ -96,7 +96,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * - optimal_io_size - the device's preferred unit of receiving I/O
 	 *   (e.g. MD's stripe width)
 	 */
-	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG, NULL)) {
 		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->dev_types, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
@@ -128,7 +128,7 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 	if (!pv->dev)
 		goto out;
 
-	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_offset_detection_CFG)) {
+	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_offset_detection_CFG, NULL)) {
 		int align_offset = dev_alignment_offset(pv->fmt->cmd->dev_types, pv->dev);
 		/* must handle a -1 alignment_offset; means dev is misaligned */
 		if (align_offset < 0)
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index dea49f8..2f4f51e 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -203,7 +203,7 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 	 * Only issue discards if enabled in lvm.conf and both
 	 * the device and kernel (>= 2.6.35) supports discards.
 	 */
-	if (!find_config_tree_bool(peg->pv->fmt->cmd, devices_issue_discards_CFG))
+	if (!find_config_tree_bool(peg->pv->fmt->cmd, devices_issue_discards_CFG, NULL))
 		return 1;
  
 	/* Missing PV? */
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 3ce2519..9a38280 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -320,7 +320,7 @@ static void _lock_mem(struct cmd_context *cmd)
 	 * Note: assuming _memlock_count_daemon is updated before _memlock_count
 	 */
 	_use_mlockall = _memlock_count_daemon ? 1 :
-		find_config_tree_bool(cmd, activation_use_mlockall_CFG);
+		find_config_tree_bool(cmd, activation_use_mlockall_CFG, NULL);
 
 	if (!_use_mlockall) {
 		if (!*_procselfmaps &&
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e41fea6..e87842b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1468,7 +1468,7 @@ static int _lvm1_fallback(struct cmd_context *cmd)
 	char vsn[80];
 	int dm_present;
 
-	if (!find_config_tree_bool(cmd, global_fallback_to_lvm1_CFG) ||
+	if (!find_config_tree_bool(cmd, global_fallback_to_lvm1_CFG, NULL) ||
 	    strncmp(cmd->kernel_vsn, "2.4.", 4))
 		return 0;
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index d3703b4..7570c52 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -38,7 +38,7 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 
 	if (!arg_count(cmd, restorefile_ARG) && arg_count(cmd, uuidstr_ARG)) {
 		if (!arg_count(cmd, norestorefile_ARG) &&
-		    find_config_tree_bool(cmd, devices_require_restorefile_with_uuid_CFG)) {
+		    find_config_tree_bool(cmd, devices_require_restorefile_with_uuid_CFG, NULL)) {
 			log_error("--restorefile is required with --uuid");
 			return 0;
 		}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index dbf7e3a..815e96e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -149,7 +149,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	/* TODO: Remove this once lvmetad + cluster supported! */
 	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 ||
-	    !find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
+	    !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
 		log_debug_lvmetad("_pvscan_lvmetad: immediate return");
 		return ret;
 	}
diff --git a/tools/reporter.c b/tools/reporter.c
index beabda5..9693083 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -234,13 +234,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int columns_as_rows;
 	unsigned args_are_pvs;
 
-	aligned = find_config_tree_bool(cmd, report_aligned_CFG);
-	buffered = find_config_tree_bool(cmd, report_buffered_CFG);
-	headings = find_config_tree_bool(cmd, report_headings_CFG);
+	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
+	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
+	headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
 	separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
-	field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG);
-	quoted = find_config_tree_bool(cmd, report_quoted_CFG);
-	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG);
+	field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
+	quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
+	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
 
 	args_are_pvs = (report_type == PVS ||
 			report_type == LABEL ||
diff --git a/tools/toollib.c b/tools/toollib.c
index 9ce378d..3107f9d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1444,7 +1444,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
 						   DEFAULT_PVMETADATAIGNORE);
 	else
-		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG);
+		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
 
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
@@ -1533,7 +1533,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 						 DEFAULT_DMEVENTD_MONITOR);
 	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
 		 arg_count(cmd, sysinit_ARG) ||
-		 !find_config_tree_bool(cmd, activation_monitoring_CFG))
+		 !find_config_tree_bool(cmd, activation_monitoring_CFG, NULL))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
 
 	return 1;
@@ -1553,7 +1553,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
 	} else
-		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG);
+		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, NULL);
 
 	if (arg_count(cmd, discards_ARG)) {
 		*passed_args |= PASS_ARG_DISCARDS;


