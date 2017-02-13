From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:03 +0000 (UTC)
Subject: master - lvconvert: repair and replace: use command definitions
Message-ID: <20170213181003.8AC2960EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35b9d4d6e9406396c90a75574f04a7018f3d6258
Commit:        35b9d4d6e9406396c90a75574f04a7018f3d6258
Parent:        52c60b7e7bba400b2f8fb40f123ca90224c16d27
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 17 15:38:52 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: repair and replace: use command definitions

This lifts the lvconvert --repair and --replace commands
out of the monolithic lvconvert implementation.  The
previous calls into repair/replace can no longer be
reached and will be removed in a separate commit.
---
 tools/command-lines.in |    2 +-
 tools/lvconvert.c      |  337 +++++++++++++++++++++++++++++++++++++++++++++--
 tools/lvmcmdline.c     |    6 +-
 tools/tools.h          |    3 +
 4 files changed, 330 insertions(+), 18 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index c2995c2..597ebc5 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -547,7 +547,7 @@ DESC: Combine LV with a previously split snapshot LV.
 # and the LV type is known.
 
 lvconvert --repair LV_raid_mirror_thinpool
-OO: --usepolicies, OO_LVCONVERT
+OO: --usepolicies, --interval Number, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_repair_pvs_or_thinpool
 DESC: Replace failed PVs in a raid or mirror LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 132d66d..79b1525 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1421,7 +1421,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				  struct lvconvert_params *lp,
 				  struct dm_list *operable_pvs,
 				  uint32_t new_mimage_count,
-				  uint32_t new_log_count)
+				  uint32_t new_log_count,
+				  struct dm_list *pvh)
 {
 	uint32_t region_size;
 	struct lv_segment *seg = first_seg(lv);
@@ -1441,7 +1442,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 						  vg_is_clustered(lv->vg));
 
 	if (!operable_pvs)
-		operable_pvs = lp->pvh;
+		operable_pvs = pvh;
 
 	/*
 	 * Up-convert from linear to mirror
@@ -1450,7 +1451,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		/* FIXME Share code with lvcreate */
 
 		/*
-		 * FIXME should we give not only lp->pvh, but also all PVs
+		 * FIXME should we give not only pvh, but also all PVs
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.
 		 */
@@ -1459,7 +1460,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				    lp->alloc, MIRROR_BY_LV))
 			return_0;
 
-		if (lp->wait_completion)
+		if (!arg_is_set(cmd, background_ARG))
 			lp->need_polling = 1;
 
 		goto out;
@@ -1636,7 +1637,8 @@ int mirror_remove_missing(struct cmd_context *cmd,
  */
 static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 				     struct logical_volume *lv,
-				     struct lvconvert_params *lp)
+				     struct lvconvert_params *lp,
+				     struct dm_list *pvh)
 {
 	int failed_logs;
 	int failed_mimages;
@@ -1647,7 +1649,6 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	uint32_t original_mimages = lv_mirror_count(lv);
 	uint32_t original_logs = _get_log_count(lv);
 
-	cmd->handles_missing_pvs = 1;
 	cmd->partial_activation = 1;
 	lp->need_polling = 0;
 
@@ -1703,7 +1704,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	while (replace_mimages || replace_logs) {
 		log_warn("Trying to up-convert to %d images, %d logs.", lp->mirrors, log_count);
 		if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
-					   lp->mirrors, log_count))
+					   lp->mirrors, log_count, pvh))
 			break;
 		if (lp->mirrors > 2)
 			--lp->mirrors;
@@ -1823,10 +1824,10 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 1;
 
 	if (lp->repair)
-		return _lvconvert_mirrors_repair(cmd, lv, lp);
+		return _lvconvert_mirrors_repair(cmd, lv, lp, lp->pvh);
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
-				    new_mimage_count, new_log_count))
+				    new_mimage_count, new_log_count, lp->pvh))
 		return_0;
 
 	backup(lv->vg);
@@ -2614,7 +2615,7 @@ out:
 
 static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 				       struct logical_volume *pool_lv,
-				       struct lvconvert_params *lp)
+				       struct dm_list *pvh, int poolmetadataspare)
 {
 	const char *dmdir = dm_dir();
 	const char *thin_dump =
@@ -2643,7 +2644,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	pmslv = pool_lv->vg->pool_metadata_spare_lv;
 
 	/* Check we have pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh, 1))
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, pvh, 1))
 		return_0;
 
 	if (pmslv != pool_lv->vg->pool_metadata_spare_lv) {
@@ -2768,8 +2769,7 @@ deactivate_pmslv:
 	}
 
 	/* Try to allocate new pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh,
-					lp->poolmetadataspare))
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, pvh, poolmetadataspare))
 		stack;
 
 	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {
@@ -3647,7 +3647,7 @@ static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_vo
 static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_volume *lv,
 				     struct lvconvert_params *lp)
 {
-	return _lvconvert_thin_pool_repair(cmd, lv, lp);
+	return _lvconvert_thin_pool_repair(cmd, lv, lp->pvh, lp->poolmetadataspare);
 }
 
 /*
@@ -3881,7 +3881,7 @@ static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume
 	struct dm_list *failed_pvs;
 	int ret;
 
-	ret = _lvconvert_mirrors_repair(cmd, lv, lp);
+	ret = _lvconvert_mirrors_repair(cmd, lv, lp, lp->pvh);
 
 	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
 		if ((failed_pvs = _failed_pv_list(lv->vg)))
@@ -4866,3 +4866,310 @@ out:
 
 	return ret;
 }
+
+/*
+ * Below is code that has transitioned to using command defs.
+ * ----------------------------------------------------------
+ *
+ * This code does not use read_params (or any other param reading
+ * functions associated with it), or the lp struct.  Those have
+ * been primary vehicles for entangling all the lvconvert operations,
+ * so avoiding them is important for untangling.  They were also
+ * heavily used for trying to figure out what the lvconvert operation
+ * was meant to be doing, and that is no longer needed since the
+ * command def provides it.
+ *
+ * All input data is already available from cmd->arg_values and
+ * cmd->position_argv (the --option args in the former, the position
+ * args in the later.)  There is no need to copy these values into
+ * another redundant struct of input values which just obfuscates.
+ *
+ * The new lvconvert_result struct, passed via custom_handle, is
+ * used for *returning* data from processing, not for passing data
+ * into processing.
+ */
+
+
+/*
+ * Data/results accumulated during processing.
+ */
+struct lvconvert_result {
+	int need_polling;
+	struct dm_list poll_idls;
+};
+
+static int _lvconvert_repair_pvs_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle,
+			struct dm_list *use_pvh)
+{
+	struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
+	struct lvconvert_params lp = { 0 };
+	struct convert_poll_id_list *idl;
+	struct lvinfo info;
+	int ret;
+
+	/*
+	 * FIXME: temporary use of lp because _lvconvert_mirrors_repair()
+	 * and _aux() still use lp fields everywhere.
+	 * Migrate them away from using lp (for the most part just use
+	 * local variables, and check arg_values directly).
+	 */
+
+	/*
+	 * Fill in any lp fields here that this fn expects to be set before
+	 * it's called.  It's hard to tell what the old code expects in lp
+	 * for repair; it doesn't take the stripes option, but it seems to
+	 * expect lp.stripes to be set to 1.
+	 */
+	lp.alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+	lp.stripes = 1;
+
+	ret = _lvconvert_mirrors_repair(cmd, lv, &lp, use_pvh);
+
+	if (lp.need_polling) {
+		if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists)
+			log_print_unless_silent("Conversion starts after activation.");
+		else {
+			if (!(idl = _convert_poll_id_list_create(cmd, lv)))
+				return 0;
+			dm_list_add(&lr->poll_idls, &idl->list);
+		}
+		lr->need_polling = 1;
+	}
+
+	return ret;
+}
+
+static void _lvconvert_repair_pvs_raid_ask(struct cmd_context *cmd, int *do_it)
+{
+	const char *dev_policy;
+
+	*do_it = 1;
+
+	if (arg_is_set(cmd, usepolicies_ARG)) {
+		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG, NULL);
+
+		if (!strcmp(dev_policy, "allocate") ||
+		    !strcmp(dev_policy, "replace"))
+			return;
+
+		/* else if (!strcmp(dev_policy, "anything_else")) -- no replace */
+		*do_it = 0;
+		return;
+	}
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Attempt to replace failed RAID images "
+			  "(requires full device resync)? [y/n]: ") == 'n') {
+		*do_it = 0;
+	}
+}
+
+static int _lvconvert_repair_pvs_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle,
+			struct dm_list *use_pvh)
+{
+	struct dm_list *failed_pvs;
+	int do_it;
+
+	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
+		log_error("%s must be active %sto perform this operation.",
+			  display_lvname(lv),
+			  vg_is_clustered(lv->vg) ?
+			  "exclusive locally " : "");
+		return 0;
+	}
+
+	_lvconvert_repair_pvs_raid_ask(cmd, &do_it);
+
+	if (do_it) {
+		if (!(failed_pvs = _failed_pv_list(lv->vg)))
+			return_0;
+
+		if (!lv_raid_replace(lv, arg_count(cmd, force_ARG), failed_pvs, use_pvh)) {
+			log_error("Failed to replace faulty devices in %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		log_print_unless_silent("Faulty devices in %s successfully replaced.",
+					display_lvname(lv));
+		return 1;
+	}
+
+	/* "warn" if policy not set to replace */
+	if (arg_is_set(cmd, usepolicies_ARG))
+		log_warn("Use 'lvconvert --repair %s' to replace "
+			 "failed device.", display_lvname(lv));
+	return 1;
+}
+
+static int _lvconvert_repair_pvs(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle)
+{
+	struct dm_list *failed_pvs;
+	struct dm_list *use_pvh;
+	int ret;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	if (lv_is_raid(lv))
+		ret = _lvconvert_repair_pvs_raid(cmd, lv, handle, use_pvh);
+	else if (lv_is_mirror(lv))
+		ret = _lvconvert_repair_pvs_mirror(cmd, lv, handle, use_pvh);
+	else
+		ret = 0;
+
+	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
+		if ((failed_pvs = _failed_pv_list(lv->vg)))
+			_remove_missing_empty_pv(lv->vg, failed_pvs);
+	}
+
+	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+}
+
+static int _lvconvert_repair_thinpool(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle)
+{
+	int poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE);
+	struct dm_list *use_pvh;
+	int ret;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	ret = _lvconvert_thin_pool_repair(cmd, lv, use_pvh, poolmetadataspare);
+
+	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+}
+
+static int _lvconvert_repair_pvs_or_thinpool_single(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle)
+{
+	if (lv_is_thin_pool(lv))
+		return _lvconvert_repair_thinpool(cmd, lv, handle);
+	else if (lv_is_raid(lv) || lv_is_mirror(lv))
+		return _lvconvert_repair_pvs(cmd, lv, handle);
+	else
+		return_ECMD_FAILED;
+}
+
+/*
+ * FIXME: add option --repair-pvs to call _lvconvert_repair_pvs() directly,
+ * and option --repair-thinpool to call _lvconvert_repair_thinpool().
+ */
+int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	struct convert_poll_id_list *idl;
+	int saved_ignore_suspended_devices;
+	int ret, poll_ret;
+
+	dm_list_init(&lr.poll_idls);
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	saved_ignore_suspended_devices = ignore_suspended_devices();
+	init_ignore_suspended_devices(1);
+
+	cmd->handles_missing_pvs = 1;
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_repair_pvs_or_thinpool_single);
+
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+
+	if (lr.need_polling) {
+		dm_list_iterate_items(idl, &lr.poll_idls)
+			poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						arg_is_set(cmd, background_ARG), 0, 0);
+		if (poll_ret > ret)
+			ret = poll_ret;
+	}
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
+static int _lvconvert_replace_pv_single(struct cmd_context *cmd, struct logical_volume *lv,
+			struct processing_handle *handle)
+{
+	struct arg_value_group_list *group;
+	const char *tmp_str;
+	struct dm_list *use_pvh;
+	struct dm_list *replace_pvh;
+	char **replace_pvs;
+	int replace_pv_count;
+	int i;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	if (!(replace_pv_count = arg_count(cmd, replace_ARG)))
+		return_ECMD_FAILED;
+
+	if (!(replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * replace_pv_count)))
+		return_ECMD_FAILED;
+
+	i = 0;
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, replace_ARG))
+			continue;
+		if (!(tmp_str = grouped_arg_str_value(group->arg_values, replace_ARG, NULL))) {
+			log_error("Failed to get '--replace' argument");
+			return_ECMD_FAILED;
+		}
+		if (!(replace_pvs[i++] = dm_pool_strdup(cmd->mem, tmp_str)))
+			return_ECMD_FAILED;
+	}
+
+	if (!(replace_pvh = create_pv_list(cmd->mem, lv->vg, replace_pv_count, replace_pvs, 0)))
+		return_ECMD_FAILED;
+
+	if (!lv_raid_replace(lv, arg_count(cmd, force_ARG), replace_pvh, use_pvh))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_replace_pv_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d1613e1..866b2ae 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -122,6 +122,10 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvchange_monitor_CMD, lvchange_monitor_poll_cmd },
 	{ lvchange_poll_CMD, lvchange_monitor_poll_cmd },
 	{ lvchange_persistent_CMD, lvchange_persistent_cmd },
+
+	/* lvconvert utilities related to snapshots and repair. */
+	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
+	{ lvconvert_replace_pv_CMD, lvconvert_replace_pv_cmd },
 };
 #if 0
 	/* all raid-related type conversions */
@@ -147,8 +151,6 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 
 	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
 	{ lvconvert_combine_split_snapshot_CMD,		lvconvert_combine_split_snapshot_fn },
-	{ lvconvert_repair_pvs_or_thinpool_CMD,		lvconvert_repair_pvs_or_thinpool_fn },
-	{ lvconvert_replace_pv_CMD,			lvconvert_replace_pv_fn },
 	{ lvconvert_split_cow_snapshot_CMD,		lvconvert_split_cow_snapshot_fn },
 	{ lvconvert_poll_start_CMD,			lvconvert_poll_start_fn },
 
diff --git a/tools/tools.h b/tools/tools.h
index c42119c..9be1233 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -251,4 +251,7 @@ int lvchange_rebuild_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


