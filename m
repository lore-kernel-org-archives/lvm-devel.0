From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:43 +0000 (UTC)
Subject: master - config: add profile arg to find_config_tree_int
Message-ID: <20130702133243.B440660DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50bf2c0db14400d80b08afabe917deee51f32ac8
Commit:        50bf2c0db14400d80b08afabe917deee51f32ac8
Parent:        8ac4fcf8ffa4af3ee8d524add632f0f3139b929d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:30:34 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:19:09 2013 +0200

config: add profile arg to find_config_tree_int

---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |   12 ++++++------
 lib/config/config.c           |   14 ++++++++++++--
 lib/config/config.h           |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/locking/locking.c         |    2 +-
 lib/metadata/lv_manip.c       |    4 ++--
 lib/metadata/metadata.c       |    2 +-
 lib/metadata/thin_manip.c     |    2 +-
 lib/mm/memlock.c              |    6 +++---
 tools/lvcreate.c              |    2 +-
 tools/lvm.c                   |    2 +-
 tools/lvresize.c              |   10 +++++-----
 tools/polldaemon.c            |    4 ++--
 tools/pvscan.c                |    2 +-
 tools/toollib.c               |   10 +++++-----
 tools/vgconvert.c             |    4 ++--
 17 files changed, 46 insertions(+), 36 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5be9ee1..9d62675 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -803,7 +803,7 @@ static void check_config(void)
 {
 	int locking_type;
 
-	locking_type = find_config_tree_int(cmd, global_locking_type_CFG);
+	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
 
 	if (locking_type == 3) /* compiled-in cluster support */
 		return;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f5b8d48..8fce261 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -182,7 +182,7 @@ static void _init_logging(struct cmd_context *cmd)
 		init_syslog(cmd->default_settings.syslog);
 
 	/* Debug level for log file output */
-	cmd->default_settings.debug = find_config_tree_int(cmd, log_level_CFG);
+	cmd->default_settings.debug = find_config_tree_int(cmd, log_level_CFG, NULL);
 	init_debug(cmd->default_settings.debug);
 
 	/*
@@ -281,7 +281,7 @@ static int _process_config(struct cmd_context *cmd)
 	}
 
 	/* umask */
-	cmd->default_settings.umask = find_config_tree_int(cmd, global_umask_CFG);
+	cmd->default_settings.umask = find_config_tree_int(cmd, global_umask_CFG, NULL);
 
 	if ((old_umask = umask((mode_t) cmd->default_settings.umask)) !=
 	    (mode_t) cmd->default_settings.umask)
@@ -426,7 +426,7 @@ static int _process_config(struct cmd_context *cmd)
 	cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL);
 	lvmetad_set_token(cn ? cn->v : NULL);
 
-	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 &&
+	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
 	    find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
 		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
@@ -716,7 +716,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	int device_list_from_udev;
 
 	init_dev_disable_after_error_count(
-		find_config_tree_int(cmd, devices_disable_after_error_count_CFG));
+		find_config_tree_int(cmd, devices_disable_after_error_count_CFG, NULL));
 
 	if (!dev_cache_init(cmd))
 		return_0;
@@ -1255,9 +1255,9 @@ static int _init_backup(struct cmd_context *cmd)
 	cmd->default_settings.archive =
 	    find_config_tree_bool(cmd, backup_archive_CFG);
 
-	days = (uint32_t) find_config_tree_int(cmd, backup_retain_days_CFG);
+	days = (uint32_t) find_config_tree_int(cmd, backup_retain_days_CFG, NULL);
 
-	min = (uint32_t) find_config_tree_int(cmd, backup_retain_min_CFG);
+	min = (uint32_t) find_config_tree_int(cmd, backup_retain_min_CFG, NULL);
 
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
diff --git a/lib/config/config.c b/lib/config/config.c
index 1576153..ae00461 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -844,15 +844,25 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	return str;
 }
 
-int find_config_tree_int(struct cmd_context *cmd, int id)
+int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	int i;
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	return dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return i;
 }
 
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index 56ed4ea..a93cef9 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -167,7 +167,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile);
-int find_config_tree_int(struct cmd_context *cmd, int id);
+int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile);
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id);
 float find_config_tree_float(struct cmd_context *cmd, int id);
 int find_config_tree_bool(struct cmd_context *cmd, int id);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 96c4f8b..a5b9b6c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1478,7 +1478,7 @@ static int _text_pv_initialise(const struct format_type *fmt,
 	unsigned long adjustment, final_alignment = 0;
 
 	if (!data_alignment)
-		data_alignment = find_config_tree_int(pv->fmt->cmd, devices_data_alignment_CFG) * 2;
+		data_alignment = find_config_tree_int(pv->fmt->cmd, devices_data_alignment_CFG, NULL) * 2;
 
 	if (set_pe_align(pv, data_alignment) != data_alignment &&
 	    data_alignment) {
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 044570f..7d9db60 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -225,7 +225,7 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 		suppress_messages = 1;
 
 	if (type < 0)
-		type = find_config_tree_int(cmd, global_locking_type_CFG);
+		type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
 
 	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG);
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ef7c75a..e74b6f1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -182,8 +182,8 @@ int get_default_region_size(struct cmd_context *cmd)
 	 * 'mirror_region_size' is the old setting.  It is overridden
 	 * by the new setting, 'raid_region_size'.
 	 */
-	mrs = 2 * find_config_tree_int(cmd, activation_mirror_region_size_CFG);
-	rrs = 2 * find_config_tree_int(cmd, activation_raid_region_size_CFG);
+	mrs = 2 * find_config_tree_int(cmd, activation_mirror_region_size_CFG, NULL);
+	rrs = 2 * find_config_tree_int(cmd, activation_raid_region_size_CFG, NULL);
 
 	if (!mrs && !rrs)
 		return DEFAULT_RAID_REGION_SIZE * 2;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8a98aa6..0dfb23b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -65,7 +65,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 		goto out;
 	}
 
-	default_pe_align = find_config_tree_int(pv->fmt->cmd, devices_default_data_alignment_CFG);
+	default_pe_align = find_config_tree_int(pv->fmt->cmd, devices_default_data_alignment_CFG, NULL);
 
 	if (default_pe_align)
 		/* align on 1 MiB multiple */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 7ddadcf..9fccc6f 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -335,7 +335,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	percent_t percent;
 	int threshold = PERCENT_1 *
-		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG);
+		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG, NULL);
 
 	/* Data */
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index d2cb61c..594687e 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -463,9 +463,9 @@ void memlock_init(struct cmd_context *cmd)
 {
 	/* When threaded, caller already limited stack size so just use the default. */
 	_size_stack = 1024ULL * (cmd->threaded ? DEFAULT_RESERVED_STACK :
-				 find_config_tree_int(cmd, activation_reserved_stack_CFG));
-	_size_malloc_tmp = find_config_tree_int(cmd, activation_reserved_memory_CFG) * 1024ULL;
-	_default_priority = find_config_tree_int(cmd, activation_process_priority_CFG);
+				 find_config_tree_int(cmd, activation_reserved_stack_CFG, NULL));
+	_size_malloc_tmp = find_config_tree_int(cmd, activation_reserved_memory_CFG, NULL) * 1024ULL;
+	_default_priority = find_config_tree_int(cmd, activation_process_priority_CFG, NULL);
 }
 
 void memlock_reset(void)
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e49b9cb..dcd05d0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -542,7 +542,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 		}
 		/* No stripe argument was given - default to 2 */
 		lp->stripes = 2;
-		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
+		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 	}
 
 	/*
diff --git a/tools/lvm.c b/tools/lvm.c
index ebce811..51e9293 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -165,7 +165,7 @@ static void _read_history(struct cmd_context *cmd)
 	if (read_history(hist_file))
 		log_very_verbose("Couldn't read history from %s.", hist_file);
 
-	stifle_history(find_config_tree_int(cmd, shell_history_size_CFG));
+	stifle_history(find_config_tree_int(cmd, shell_history_size_CFG, NULL));
 }
 
 static void _write_history(void)
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 1ba5a5c..bd29bc6 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -306,16 +306,16 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
-			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG) * PERCENT_1;
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG, NULL) * PERCENT_1;
 		policy_amount =
-			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG);
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG, NULL);
 		if (!policy_amount && policy_threshold < PERCENT_100)
                         return 0;
 	} else {
 		policy_threshold =
-			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG) * PERCENT_1;
+			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL) * PERCENT_1;
 		policy_amount =
-			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG);
+			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG, NULL);
 	}
 
 	if (policy_threshold >= PERCENT_100)
@@ -754,7 +754,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 				lp->stripe_size = seg_stripesize;
 			} else {
 				lp->stripe_size =
-					find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
+					find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 				log_print_unless_silent("Using default stripesize %s",
 							display_size(cmd, (uint64_t) lp->stripe_size));
 			}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 5724623..c139d2b 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -319,7 +319,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	if (interval_sign == SIGN_MINUS)
 		log_error("Argument to --interval cannot be negative");
 	parms.interval = arg_uint_value(cmd, interval_ARG,
-					find_config_tree_int(cmd, activation_polling_interval_CFG));
+					find_config_tree_int(cmd, activation_polling_interval_CFG, NULL));
 	parms.wait_before_testing = (interval_sign == SIGN_PLUS);
 	parms.progress_display = 1;
 	parms.progress_title = progress_title;
@@ -336,7 +336,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 
 		/* FIXME Disabled multiple-copy wait_event */
 		if (!name)
-			parms.interval = find_config_tree_int(cmd, activation_polling_interval_CFG);
+			parms.interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
 	}
 
 	if (parms.background) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a194c68..f4d104a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -148,7 +148,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	 * and to prevent hangs in clustered environment.
 	 */
 	/* TODO: Remove this once lvmetad + cluster supported! */
-	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 ||
+	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 ||
 	    !find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
 		log_debug_lvmetad("_pvscan_lvmetad: immediate return");
 		return ret;
diff --git a/tools/toollib.c b/tools/toollib.c
index f1ceecb..879e7f9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1288,7 +1288,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	} else {
-		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG);
+		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG, NULL);
 	}
 
 	return 1;
@@ -1503,11 +1503,11 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 
 	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
 	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG);
+		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
 	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
+		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 
 	pp->rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->rp.ba_size);
 
@@ -1575,7 +1575,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	} else
-		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG) * 2;
+		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL) * 2;
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
@@ -1653,7 +1653,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 	}
 
 	if (*stripes > 1 && !*stripe_size) {
-		*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG) * 2;
+		*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 		log_print_unless_silent("Using default stripesize %s",
 			  display_size(cmd, (uint64_t) *stripe_size));
 	}
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 3c984d7..fbb1b4e 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -49,12 +49,12 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 						  UINT64_C(0));
 		if (!pvmetadatasize)
 			pvmetadatasize =
-			    find_config_tree_int(cmd, metadata_pvmetadatasize_CFG);
+			    find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
 		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 		if (pvmetadatacopies < 0)
 			pvmetadatacopies =
-			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
+			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 	}
 
 	if (cmd->fmt->features & FMT_BAS) {


