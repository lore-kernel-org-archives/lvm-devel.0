From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:54 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_str
Message-ID: <20130626145554.B4AE260F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7735b82bacd3263ac8a1bf42e81238458383b51
Commit:        c7735b82bacd3263ac8a1bf42e81238458383b51
Parent:        c9b8a02c1ffd7ccd34b998c1b84a04a18f11b084
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:29:54 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_str

---
 daemons/clvmd/lvm-functions.c  |    2 +-
 lib/activate/activate.c        |    2 +-
 lib/commands/toolcontext.c     |   28 ++++++++++++++--------------
 lib/config/config.c            |   14 ++++++++++++--
 lib/config/config.h            |    2 +-
 lib/locking/external_locking.c |    2 +-
 lib/locking/file_locking.c     |    2 +-
 lib/mirror/mirrored.c          |    2 +-
 lib/misc/sharedlib.c           |    2 +-
 lib/raid/raid.c                |    2 +-
 lib/snapshot/snapshot.c        |    2 +-
 lib/thin/thin.c                |    2 +-
 tools/lvconvert.c              |   11 ++++++-----
 tools/lvcreate.c               |    4 ++--
 tools/reporter.c               |   32 ++++++++++++++++----------------
 tools/toollib.c                |    2 +-
 16 files changed, 61 insertions(+), 50 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c7f3488..5be9ee1 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -811,7 +811,7 @@ static void check_config(void)
 	if (locking_type == 2) { /* External library, check name */
 		const char *libname;
 
-		libname = find_config_tree_str(cmd, global_locking_library_CFG);
+		libname = find_config_tree_str(cmd, global_locking_library_CFG, NULL);
 		if (libname && strstr(libname, "liblvm2clusterlock.so"))
 			return;
 
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 5a4b111..2f1718b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1286,7 +1286,7 @@ static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd
 	if (!(dmevh = dm_event_handler_create()))
 		return_NULL;
 
-	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, dmeventd_executable_CFG)))
+	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, dmeventd_executable_CFG, NULL)))
 		goto_bad;
 
 	if (dm_event_handler_set_dso(dmevh, dso))
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3e28378..fda150e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -218,7 +218,7 @@ static void _init_logging(struct cmd_context *cmd)
 	if (find_config_tree_bool(cmd, log_overwrite_CFG))
 		append = 0;
 
-	log_file = find_config_tree_str(cmd, log_file_CFG);
+	log_file = find_config_tree_str(cmd, log_file_CFG, NULL);
 
 	if (log_file) {
 		release_log_memory();
@@ -226,7 +226,7 @@ static void _init_logging(struct cmd_context *cmd)
 		init_log_file(log_file, append);
 	}
 
-	log_file = find_config_tree_str(cmd, log_activate_file_CFG);
+	log_file = find_config_tree_str(cmd, log_activate_file_CFG, NULL);
 	if (log_file)
 		init_log_direct(log_file, append);
 
@@ -291,7 +291,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	/* dev dir */
 	if (dm_snprintf(cmd->dev_dir, sizeof(cmd->dev_dir), "%s/",
-			 find_config_tree_str(cmd, devices_dir_CFG)) < 0) {
+			 find_config_tree_str(cmd, devices_dir_CFG, NULL)) < 0) {
 		log_error("Device directory given in config file too long");
 		return 0;
 	}
@@ -304,7 +304,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	/* proc dir */
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
-			 find_config_tree_str(cmd, global_proc_CFG)) < 0) {
+			 find_config_tree_str(cmd, global_proc_CFG, NULL)) < 0) {
 		log_error("Device directory given in config file too long");
 		return 0;
 	}
@@ -325,13 +325,13 @@ static int _process_config(struct cmd_context *cmd)
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG);
 
 	if (!(cmd->default_settings.unit_factor =
-	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG),
+	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG, NULL),
 			     &cmd->default_settings.unit_type))) {
 		log_error("Invalid units specification");
 		return 0;
 	}
 
-	read_ahead = find_config_tree_str(cmd, activation_readahead_CFG);
+	read_ahead = find_config_tree_str(cmd, activation_readahead_CFG, NULL);
 	if (!strcasecmp(read_ahead, "auto"))
 		cmd->default_settings.read_ahead = DM_READ_AHEAD_AUTO;
 	else if (!strcasecmp(read_ahead, "none"))
@@ -370,7 +370,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	cmd->use_linear_target = find_config_tree_bool(cmd, activation_use_linear_target_CFG);
 
-	cmd->stripe_filler = find_config_tree_str(cmd, activation_missing_stripe_filler_CFG);
+	cmd->stripe_filler = find_config_tree_str(cmd, activation_missing_stripe_filler_CFG, NULL);
 
 	/* FIXME Missing error code checks from the stats, not log_warn?, notify if setting overridden, delay message/check till it is actually used (eg consider if lvm shell - file could appear later after this check)? */
 	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
@@ -685,7 +685,7 @@ static int _init_profiles(struct cmd_context *cmd)
 		return 0;
 	}
 
-	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG))) {
+	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG, NULL))) {
 		if (dm_snprintf(default_dir, sizeof(default_dir), "%s/%s",
 				cmd->system_dir, DEFAULT_PROFILE_SUBDIR) == -1) {
 			log_error("Couldn't create default profile path '%s/%s'.",
@@ -968,8 +968,8 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	/*
 	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
 	 */
-	cache_dir = find_config_tree_str(cmd, devices_cache_dir_CFG);
-	cache_file_prefix = find_config_tree_str(cmd, devices_cache_file_prefix_CFG);
+	cache_dir = find_config_tree_str(cmd, devices_cache_dir_CFG, NULL);
+	cache_file_prefix = find_config_tree_str(cmd, devices_cache_file_prefix_CFG, NULL);
 
 	if (cache_dir || cache_file_prefix) {
 		if (dm_snprintf(cache_file, sizeof(cache_file),
@@ -981,7 +981,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 			log_error("Persistent cache filename too long.");
 			goto bad;
 		}
-	} else if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG)) &&
+	} else if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)) &&
 		   (dm_snprintf(cache_file, sizeof(cache_file),
 				"%s/%s/%s.cache",
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
@@ -1122,7 +1122,7 @@ static int _init_formats(struct cmd_context *cmd)
 
 	cmd->fmt_backup = fmt;
 
-	format = find_config_tree_str(cmd, global_format_CFG);
+	format = find_config_tree_str(cmd, global_format_CFG, NULL);
 
 	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (!strcasecmp(fmt->name, format) ||
@@ -1345,7 +1345,7 @@ static int _init_backup(struct cmd_context *cmd)
 		return 0;
 	}
 
-	if (!(dir = find_config_tree_str(cmd, backup_archive_dir_CFG)))
+	if (!(dir = find_config_tree_str(cmd, backup_archive_dir_CFG, NULL)))
 		dir = default_dir;
 
 	if (!archive_init(cmd, dir, days, min,
@@ -1365,7 +1365,7 @@ static int _init_backup(struct cmd_context *cmd)
 		return 0;
 	}
 
-	if (!(dir = find_config_tree_str(cmd, backup_backup_dir_CFG)))
+	if (!(dir = find_config_tree_str(cmd, backup_backup_dir_CFG, NULL)))
 		dir = default_dir;
 
 	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
diff --git a/lib/config/config.c b/lib/config/config.c
index 0653529..0a08ac1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -759,15 +759,25 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 	return cn;
 }
 
-const char *find_config_tree_str(struct cmd_context *cmd, int id)
+const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	const char *str;
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 
-	return dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return str;
 }
 
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index a2a62fa..039738f 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -161,7 +161,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
  * These versions check an override tree, if present, first.
  */
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile);
-const char *find_config_tree_str(struct cmd_context *cmd, int id);
+const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id);
 int find_config_tree_int(struct cmd_context *cmd, int id);
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id);
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index d5c39d7..8b63a29 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -80,7 +80,7 @@ int init_external_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->reset_locking = _reset_external_locking;
 	locking->flags = 0;
 
-	if (!(libname = find_config_tree_str(cmd, global_locking_library_CFG)))
+	if (!(libname = find_config_tree_str(cmd, global_locking_library_CFG, NULL)))
 		libname = DEFAULT_LOCKING_LIB;
 
 	if (!(_locking_lib = load_shared_library(cmd, libname, "locking", 1)))
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 934bfe2..9cfd8eb 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -346,7 +346,7 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->flags = 0;
 
 	/* Get lockfile directory from config file */
-	locking_dir = find_config_tree_str(cmd, global_locking_dir_CFG);
+	locking_dir = find_config_tree_str(cmd, global_locking_dir_CFG, NULL);
 	if (strlen(locking_dir) >= sizeof(_lock_dir)) {
 		log_error("Path for locking_dir %s is invalid.", locking_dir);
 		return 0;
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 6ce929d..c3eb27b 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -540,7 +540,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 #ifdef DMEVENTD
 static const char *_get_mirror_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_mirror_library_CFG));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_mirror_library_CFG, NULL));
 }
 
 /* FIXME Cache this */
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index b899781..fca079b 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -30,7 +30,7 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 	/* If libname doesn't begin with '/' then use lib_dir/libname,
 	 * if present */
 	if (libname[0] == '/' ||
-	    !(lib_dir = find_config_tree_str(cmd, global_library_dir_CFG)) ||
+	    !(lib_dir = find_config_tree_str(cmd, global_library_dir_CFG, NULL)) ||
 	    (dm_snprintf(path, path_len, "%s/%s", lib_dir,
 			 libname) == -1) || stat(path, &info) == -1) {
 		strncpy(path, libname, path_len - 1);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index bc00691..6d627fe 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -343,7 +343,7 @@ static void _raid_destroy(struct segment_type *segtype)
 #ifdef DMEVENTD
 static const char *_get_raid_dso_path(struct cmd_context *cmd)
 {
-	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG);
+	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
 	return get_monitor_dso_path(cmd, config_str);
 }
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 453d96a..506d618 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -171,7 +171,7 @@ static int _snap_target_present(struct cmd_context *cmd,
 
 static const char *_get_snapshot_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_snapshot_library_CFG));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_snapshot_library_CFG, NULL));
 }
 
 /* FIXME Cache this */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index f4f785f..1867ef9 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -379,7 +379,7 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 #  ifdef DMEVENTD
 static const char *_get_thin_dso_path(struct cmd_context *cmd)
 {
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_thin_library_CFG));
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_thin_library_CFG, NULL));
 }
 
 /* FIXME Cache this */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be6b55f..9100e32 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -490,7 +490,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG)));
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,
+			find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)));
 		if (!lp->segtype)
 			return_0;
 	}
@@ -861,10 +862,10 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 	*replace_log = *replace_mirrors = 1;
 
 	if (arg_count(cmd, use_policies_ARG)) {
-		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG);
+		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
 		if (!leg_policy)
-			leg_policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG);
-		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG);
+			leg_policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG, NULL);
+		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
 		*replace_mirrors = strcmp(leg_policy, "remove");
 		*replace_log = strcmp(log_policy, "remove");
 		return;
@@ -1591,7 +1592,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 	*replace_dev = 1;
 
 	if (arg_count(cmd, use_policies_ARG)) {
-		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG);
+		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG, NULL);
 
 		if (!strcmp(dev_policy, "allocate") ||
 		    !strcmp(dev_policy, "replace"))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 80ca1bc..5ee38e3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -724,9 +724,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (arg_count(cmd, mirrors_ARG))
 		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
 				   stripes_long_ARG : stripes_ARG, 1) > 1) {
-			segtype_str = find_config_tree_str(cmd, global_raid10_segtype_default_CFG);;
+			segtype_str = find_config_tree_str(cmd, global_raid10_segtype_default_CFG, NULL);;
 		} else {
-			segtype_str = find_config_tree_str(cmd, global_mirror_segtype_default_CFG);
+			segtype_str = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
diff --git a/tools/reporter.c b/tools/reporter.c
index 2744fcd..beabda5 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -237,7 +237,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG);
 	headings = find_config_tree_bool(cmd, report_headings_CFG);
-	separator = find_config_tree_str(cmd, report_separator_CFG);
+	separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
 	field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG);
 	quoted = find_config_tree_bool(cmd, report_quoted_CFG);
 	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG);
@@ -248,40 +248,40 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	switch (report_type) {
 	case LVS:
-		keys = find_config_tree_str(cmd, report_lvs_sort_CFG);
+		keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_lvs_cols_CFG);
+			options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
 		else
-			options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG);
+			options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
 		break;
 	case VGS:
-		keys = find_config_tree_str(cmd, report_vgs_sort_CFG);
+		keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_vgs_cols_CFG);
+			options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
 		else
-			options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG);
+			options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
 		break;
 	case LABEL:
 	case PVS:
-		keys = find_config_tree_str(cmd, report_pvs_sort_CFG);
+		keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_pvs_cols_CFG);
+			options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
 		else
-			options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG);
+			options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
 		break;
 	case SEGS:
-		keys = find_config_tree_str(cmd, report_segs_sort_CFG);
+		keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_segs_cols_CFG);
+			options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
 		else
-			options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG);
+			options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
 		break;
 	case PVSEGS:
-		keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG);
+		keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_pvsegs_cols_CFG);
+			options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
 		else
-			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG);
+			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 		break;
 	default:
 		log_error(INTERNAL_ERROR "Unknown report type.");
diff --git a/tools/toollib.c b/tools/toollib.c
index b238a61..03fa0c0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1561,7 +1561,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		log_very_verbose("Setting pool discards: %s",
 				 get_pool_discards_name(*discards));
 	} else {
-		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG);
+		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, NULL);
 		if (!get_pool_discards(dstr, discards))
 			return_0;
 	}


