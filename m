From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:14:54 -0400
Subject: master - lvconvert: support repair of cache/cachepool
Message-ID: <201709201314.v8KDEsCR009471@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a65649b45d0d0a417b64bf9918b2aeedb7f3993b
Commit:        a65649b45d0d0a417b64bf9918b2aeedb7f3993b
Parent:        aeb4f2bf3d25927e6cac2e37842498b207fefd1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 18 11:33:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:14:16 2017 +0200

lvconvert: support repair of cache/cachepool

Extend repair for cache and cachepool target
and user 'lvconvert_repair' routine name.
---
 WHATS_NEW              |    1 +
 tools/command-lines.in |   11 ++-
 tools/lvconvert.c      |  206 +++++++++++++++++++++++++++++++++++++++++++++---
 tools/lvmcmdline.c     |    4 +-
 tools/tools.h          |    2 +-
 5 files changed, 209 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e76214d..7927673 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  Support lvconvert --repair with cache and cachepool volumes.
   lvconvert --repair respects --poolmetadataspare option.
 
 Version 2.02.174 - 13th September 2017
diff --git a/tools/command-lines.in b/tools/command-lines.in
index e915483..ec02fa4 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -658,17 +658,24 @@ FLAGS: SECONDARY_SYNTAX
 # lvconvert --repair-thinpool LV_thinpool
 # DESC: Repair a thin pool.
 #
+# lvconvert --repair-cache LV_cache
+# DESC: Repair a cache.
+#
+# lvconvert --repair-cachepool LV_cachepool
+# DESC: Repair a cachepool.
+#
 # lvm may want to do different things, or allow different options 
 # depending on which operation is being run, but as it stands, it
 # cannot do anything operation-specific until after the VG is read
 # and the LV type is known.
 
-lvconvert --repair LV_raid_mirror_thinpool
+lvconvert --repair LV_cache_cachepool_mirror_raid_thinpool
 OO: --usepolicies, --interval Number, --poolmetadataspare Bool, OO_LVCONVERT
 OP: PV ...
-ID: lvconvert_repair_pvs_or_thinpool
+ID: lvconvert_repair
 DESC: Replace failed PVs in a raid or mirror LV.
 DESC: Repair a thin pool.
+DESC: Repair a cache pool.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: --poolmetadataspare Bool and LV_cache LV_cachepool LV_thinpool
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 94dee9d..77d9174 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2386,6 +2386,180 @@ deactivate_pmslv:
 	return 1;
 }
 
+/* TODO: lots of similar code with  thinpool repair
+ *       investigate possible better code sharing...
+ */
+static int _lvconvert_cache_repair(struct cmd_context *cmd,
+				   struct logical_volume *cache_lv,
+				   struct dm_list *pvh, int poolmetadataspare)
+{
+	const char *dmdir = dm_dir();
+	const char *cache_repair =
+		find_config_tree_str_allow_empty(cmd, global_cache_repair_executable_CFG, NULL);
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	int ret = 0, status;
+	int args = 0;
+	const char *argv[19]; /* Max supported 10 args */
+	char *dm_name;
+	char meta_path[PATH_MAX];
+	char pms_path[PATH_MAX];
+	struct logical_volume *pool_lv;
+	struct logical_volume *pmslv;
+	struct logical_volume *mlv;
+
+	pool_lv = lv_is_cache_pool(cache_lv) ? cache_lv : first_seg(cache_lv)->pool_lv;
+	mlv = first_seg(pool_lv)->metadata_lv;
+
+	if (!cache_repair || !cache_repair[0]) {
+		log_error("Cache repair commnand is not configured. Repair is disabled.");
+		return 0; /* Checking disabled */
+	}
+
+	pmslv = cache_lv->vg->pool_metadata_spare_lv;
+
+	/* Check we have pool metadata spare LV */
+	if (!handle_pool_metadata_spare(cache_lv->vg, 0, pvh, 1))
+		return_0;
+
+	if (pmslv != cache_lv->vg->pool_metadata_spare_lv) {
+		if (!vg_write(cache_lv->vg) || !vg_commit(cache_lv->vg))
+			return_0;
+		pmslv = cache_lv->vg->pool_metadata_spare_lv;
+	}
+
+	if (!(dm_name = dm_build_dm_name(cmd->mem, mlv->vg->name,
+					 mlv->name, NULL)) ||
+	    (dm_snprintf(meta_path, sizeof(meta_path), "%s/%s", dmdir, dm_name) < 0)) {
+		log_error("Failed to build cache metadata path.");
+		return 0;
+	}
+
+	if (!(dm_name = dm_build_dm_name(cmd->mem, pmslv->vg->name,
+					 pmslv->name, NULL)) ||
+	    (dm_snprintf(pms_path, sizeof(pms_path), "%s/%s", dmdir, dm_name) < 0)) {
+		log_error("Failed to build pool metadata spare path.");
+		return 0;
+	}
+
+	if (!(cn = find_config_tree_array(cmd, global_cache_repair_options_CFG, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for global/cache_repair_options");
+		return 0;
+	}
+
+	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Invalid string in config file: "
+				  "global/cache_repair_options");
+			return 0;
+		}
+		argv[++args] = cv->v.str;
+	}
+
+	if (args == 10) {
+		log_error("Too many options for cache repair command.");
+		return 0;
+	}
+
+	argv[0] = cache_repair;
+	argv[++args] = "-i";
+	argv[++args] = meta_path;
+	argv[++args] = "-o";
+	argv[++args] = pms_path;
+	argv[++args] = NULL;
+
+	if (lv_is_active(cache_lv)) {
+		log_error("Only inactive cache can be repaired.");
+		return 0;
+	}
+
+	if (!activate_lv_local(cmd, pmslv)) {
+		log_error("Cannot activate pool metadata spare volume %s.",
+			  pmslv->name);
+		return 0;
+	}
+
+	if (!activate_lv_local(cmd, mlv)) {
+		log_error("Cannot activate cache pool metadata volume %s.",
+			  mlv->name);
+		goto deactivate_pmslv;
+	}
+
+	if (!(ret = exec_cmd(cmd, (const char * const *)argv, &status, 1))) {
+		log_error("Repair of cache metadata volume of cache %s failed (status:%d). "
+			  "Manual repair required!",
+			  display_lvname(cache_lv), status);
+		goto deactivate_mlv;
+	}
+
+	/* TODO: any active validation of cache-pool metadata? */
+
+deactivate_mlv:
+	if (!deactivate_lv(cmd, mlv)) {
+		log_error("Cannot deactivate pool metadata volume %s.",
+			  mlv->name);
+		return 0;
+	}
+
+deactivate_pmslv:
+	if (!deactivate_lv(cmd, pmslv)) {
+		log_error("Cannot deactivate pool metadata spare volume %s.",
+			  mlv->name);
+		return 0;
+	}
+
+	if (!ret)
+		return 0;
+
+	if (pmslv == cache_lv->vg->pool_metadata_spare_lv) {
+		cache_lv->vg->pool_metadata_spare_lv = NULL;
+		pmslv->status &= ~POOL_METADATA_SPARE;
+		lv_set_visible(pmslv);
+	}
+
+	/* Try to allocate new pool metadata spare LV */
+	if (!handle_pool_metadata_spare(cache_lv->vg, 0, pvh, poolmetadataspare))
+		stack;
+
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", cache_lv->name) < 0) {
+		log_error("Can't prepare new metadata name for %s.", cache_lv->name);
+		return 0;
+	}
+
+	if (!generate_lv_name(cache_lv->vg, meta_path, pms_path, sizeof(pms_path))) {
+		log_error("Can't generate new name for %s.", meta_path);
+		return 0;
+	}
+
+	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
+		return_0;
+
+	/* Swap _pmspare and _cmeta name */
+	if (!swap_lv_identifiers(cmd, mlv, pmslv))
+		return_0;
+
+	if (!attach_pool_metadata_lv(first_seg(pool_lv), pmslv))
+		return_0;
+
+	/* Used _cmeta (now _pmspare) becomes _meta%d */
+	if (!lv_rename_update(cmd, mlv, pms_path, 0))
+		return_0;
+
+	if (!vg_write(cache_lv->vg) || !vg_commit(cache_lv->vg))
+		return_0;
+
+	/* FIXME: just as with  thinpool repair - fix the warning
+	 *        where moving doesn't make any sense (same disk storage)
+         */
+	log_warn("WARNING: If everything works, remove %s volume.",
+		 display_lvname(mlv));
+
+	log_warn("WARNING: Use pvmove command to move %s on the best fitting PV.",
+		 display_lvname(first_seg(pool_lv)->metadata_lv));
+
+	return 1;
+}
+
 static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 			   struct logical_volume *lv,
 			   struct logical_volume *thinpool_lv)
@@ -3371,12 +3545,11 @@ static int _lvconvert_repair_pvs(struct cmd_context *cmd, struct logical_volume
 	return ret ? ECMD_PROCESSED : ECMD_FAILED;
 }
 
-static int _lvconvert_repair_thinpool(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lvconvert_repair_cachepool_thinpool(struct cmd_context *cmd, struct logical_volume *lv,
 			struct processing_handle *handle)
 {
 	int poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE);
 	struct dm_list *use_pvh;
-	int ret;
 
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */
@@ -3385,28 +3558,41 @@ static int _lvconvert_repair_thinpool(struct cmd_context *cmd, struct logical_vo
 	} else
 		use_pvh = &lv->vg->pvs;
 
-	ret = _lvconvert_thin_pool_repair(cmd, lv, use_pvh, poolmetadataspare);
+	if (lv_is_thin_pool(lv)) {
+		if (!_lvconvert_thin_pool_repair(cmd, lv, use_pvh, poolmetadataspare))
+			return_ECMD_FAILED;
+	} else /* cache */ {
+		if (!_lvconvert_cache_repair(cmd, lv, use_pvh, poolmetadataspare))
+			return_ECMD_FAILED;
+	}
 
-	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+	return ECMD_PROCESSED;
 }
 
-static int _lvconvert_repair_pvs_or_thinpool_single(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lvconvert_repair_single(struct cmd_context *cmd, struct logical_volume *lv,
 			struct processing_handle *handle)
 {
-	if (lv_is_thin_pool(lv))
-		return _lvconvert_repair_thinpool(cmd, lv, handle);
+	if (lv_is_thin_pool(lv) ||
+	    lv_is_cache(lv) ||
+	    lv_is_cache_pool(lv))
+		return _lvconvert_repair_cachepool_thinpool(cmd, lv, handle);
 
 	if (lv_is_raid(lv) || lv_is_mirror(lv))
 		return _lvconvert_repair_pvs(cmd, lv, handle);
 
-	return_ECMD_FAILED;
+	log_error("Unsupported volume type for repair of volume %s.",
+		  display_lvname(lv));
+
+	return ECMD_FAILED;
 }
 
 /*
  * FIXME: add option --repair-pvs to call _lvconvert_repair_pvs() directly,
  * and option --repair-thinpool to call _lvconvert_repair_thinpool().
+ * and option --repair-cache to call _lvconvert_repair_cache().
+ * and option --repair-cachepool to call _lvconvert_repair_cachepool().
  */
-int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char **argv)
+int lvconvert_repair_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
 	struct lvconvert_result lr = { 0 };
@@ -3429,7 +3615,7 @@ int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char
 	cmd->handles_missing_pvs = 1;
 
 	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			      handle, NULL, &_lvconvert_repair_pvs_or_thinpool_single);
+			      handle, NULL, &_lvconvert_repair_single);
 
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 55f72ac..fc4b3bb 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -109,7 +109,7 @@ static const struct command_function command_functions[CMD_COUNT] = {
 	{ vgchange_systemid_CMD, vgchange_systemid_cmd },
 
 	/* lvconvert utilities related to repair. */
-	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
+	{ lvconvert_repair_CMD,	lvconvert_repair_cmd },
 	{ lvconvert_replace_pv_CMD, lvconvert_replace_pv_cmd },
 
 	/* lvconvert utilities related to snapshots. */
@@ -2877,7 +2877,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		lvmetad_make_unused(cmd);
 	}
 
-	if (cmd->command->command_enum == lvconvert_repair_pvs_or_thinpool_CMD) {
+	if (cmd->command->command_enum == lvconvert_repair_CMD) {
 		log_warn("WARNING: Disabling lvmetad cache for repair command.");
 		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
 		log_warn("WARNING: Not using lvmetad because of repair.");
diff --git a/tools/tools.h b/tools/tools.h
index ba4edeb..53f8ddc 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -240,7 +240,7 @@ int lvchange_rebuild_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv);
 
-int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_repair_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 int lvconvert_merge_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);


