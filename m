From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 16:33:08 +0000 (GMT)
Subject: master - writecache: use two step detach
Message-ID: <20201001163308.7565E398B887@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c32d7fed4f78b4537f4ada4318866786a9fab493
Commit:        c32d7fed4f78b4537f4ada4318866786a9fab493
Parent:        d1b7438c9fb7ab9b0940ce433c0ece2fa17a6f03
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 13:33:40 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 11:33:02 2020 -0500

writecache: use two step detach

When detaching a writecache, use the cleaner setting
by default to writeback data prior to suspending the
lv to detach the writecache.  This avoids potentially
blocking for a long period with the device suspended.

Detaching a writecache first sets the cleaner option, waits
for a short period of time (less than a second), and checks
if the writecache has quickly become clean.  If so, the
writecache is detached immediately.  This optimizes the case
where little writeback is needed.

If the writecache does not quickly become clean, then the
detach command leaves the writecache attached with the
cleaner option set.  This leaves the LV in the same state
as if the user had set the cleaner option directly with
lvchange --cachesettings cleaner=1 LV.

After leaving the LV with the cleaner option set, the
detach command will wait and watch the writeback progress,
and will finally detach the writecache when the writeback
is finished.  The detach command does not need to wait
during the writeback phase, and can be canceled, in which
case the LV will remain with the writecache attached and
the cleaner option set.  When the user runs the detach
command again it will complete the detach.

To detach a writecache directly, without using the cleaner
step (which has been the approach previously), add the
option --cachesettings cleaner=0 to the detach command.
---
 lib/metadata/metadata-exported.h |   3 +
 lib/metadata/writecache_manip.c  |  63 ++++++++-
 lib/writecache/writecache.c      |  25 +++-
 tools/command-lines.in           |   4 +-
 tools/lvconvert.c                | 285 +++++++++++++++++++++++++++++++++++++--
 5 files changed, 357 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c4d51998b..37fe9d0ad 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1114,6 +1114,9 @@ int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_writecache_origin(const struct logical_volume *lv);
 int lv_is_writecache_cachevol(const struct logical_volume *lv);
 int writecache_settings_to_str_list(struct writecache_settings *settings, struct dm_list *result, struct dm_pool *mem);
+int lv_writecache_set_cleaner(struct logical_volume *lv);
+bool lv_writecache_is_clean(struct cmd_context *cmd, struct logical_volume *lv, uint64_t *dirty_blocks);
+bool writecache_cleaner_supported(struct cmd_context *cmd);
 
 int lv_is_integrity_origin(const struct logical_volume *lv);
 
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 0230d6160..5004aa989 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -58,9 +58,9 @@ int lv_is_writecache_cachevol(const struct logical_volume *lv)
 	return 0;
 }
 
-static int _get_writecache_kernel_error(struct cmd_context *cmd,
-					const struct logical_volume *lv,
-					uint32_t *kernel_error)
+static int _get_writecache_kernel_status(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct dm_status_writecache *status_out)
 {
 	struct lv_with_info_and_seg_status status;
 
@@ -91,7 +91,10 @@ static int _get_writecache_kernel_error(struct cmd_context *cmd,
 		goto fail;
 	}
 
-	*kernel_error = status.seg_status.writecache->error;
+	status_out->error = status.seg_status.writecache->error;
+	status_out->total_blocks = status.seg_status.writecache->total_blocks;
+	status_out->free_blocks = status.seg_status.writecache->free_blocks;
+	status_out->writeback_blocks = status.seg_status.writecache->writeback_blocks;
 
 	dm_pool_destroy(status.seg_status.mem);
 	return 1;
@@ -101,6 +104,35 @@ fail:
 	return 0;
 }
 
+static int _get_writecache_kernel_error(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					uint32_t *kernel_error)
+{
+	struct dm_status_writecache status = { 0 };
+
+	if (!_get_writecache_kernel_status(cmd, lv, &status))
+		return_0;
+
+	*kernel_error = status.error;
+	return 1;
+}
+
+bool lv_writecache_is_clean(struct cmd_context *cmd, struct logical_volume *lv, uint64_t *dirty_blocks)
+{
+	struct dm_status_writecache status = { 0 };
+
+	if (!_get_writecache_kernel_status(cmd, lv, &status)) 
+		return false;
+
+	if (dirty_blocks)
+		*dirty_blocks = status.total_blocks - status.free_blocks;
+
+	if (status.total_blocks == status.free_blocks)
+		return true;
+
+	return false;
+}
+
 static void _rename_detached_cvol(struct cmd_context *cmd, struct logical_volume *lv_fast)
 {
 	struct volume_group *vg = lv_fast->vg;
@@ -319,7 +351,7 @@ static int _lv_detach_writecache_cachevol_active(struct logical_volume *lv, int
 
 	log_debug("Checking writecache errors to detach.");
 
-	if (!_get_writecache_kernel_error(cmd, lv_old, &kernel_error)) {
+	if (!_get_writecache_kernel_error(cmd, (struct logical_volume *)lv_old, &kernel_error)) {
 		log_error("Failed to get writecache error status for %s.", display_lvname(lv_old));
 		return 0;
 	}
@@ -394,6 +426,27 @@ int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
 		return _lv_detach_writecache_cachevol_inactive(lv, noflush);
 }
 
+int lv_writecache_set_cleaner(struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	seg->writecache_settings.cleaner = 1;
+	seg->writecache_settings.cleaner_set = 1;
+
+	if (lv_is_active(lv)) {
+		if (!lv_update_and_reload(lv)) {
+			log_error("Failed to update VG and reload LV.");
+			return 0;
+		}
+	} else {
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+			log_error("Failed to update VG.");
+			return 0;
+		}
+	}
+	return 1;
+}
+
 static int _writecache_setting_str_list_add(const char *field, uint64_t val, char *val_str, struct dm_list *result, struct dm_pool *mem)
 {
 	char buf[128];
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index c7aea286d..4ecbf50df 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -238,13 +238,20 @@ static int _target_present(struct cmd_context *cmd,
 
 	if (!_writecache_checked) {
 		_writecache_checked = 1;
-		_writecache_present =  target_present(cmd, TARGET_NAME_WRITECACHE, 1);
+		_writecache_present = target_present(cmd, TARGET_NAME_WRITECACHE, 1);
 
-		if (!target_version(TARGET_NAME_WRITECACHE, &maj, &min, &patchlevel))
+		if (!_writecache_present) {
+			log_error("dm-writecache module not found in kernel.");
+			return 0;
+		}
+
+		if (!target_version(TARGET_NAME_WRITECACHE, &maj, &min, &patchlevel)) {
+			log_error("dm-writecache module version not found.");
 			return_0;
+		}
 
 		if (maj < 1) {
-			log_error("writecache target version older than minimum 1.0.0");
+			log_error("dm-writecache module version older than minimum 1.0.0");
 			return 0;
 		}
 
@@ -257,6 +264,12 @@ static int _target_present(struct cmd_context *cmd,
 	return _writecache_present;
 }
 
+bool writecache_cleaner_supported(struct cmd_context *cmd)
+{
+	_target_present(cmd, NULL, NULL);
+	return _writecache_cleaner_supported ? true : false;
+}
+
 static int _modules_needed(struct dm_pool *mem,
 			   const struct lv_segment *seg __attribute__((unused)),
 			   struct dm_list *modules)
@@ -268,6 +281,12 @@ static int _modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+
+#else
+bool writecache_cleaner_supported(struct cmd_context *cmd)
+{
+	return 0;
+}
 #endif /* DEVMAPPER_SUPPORT */
 
 #ifdef DEVMAPPER_SUPPORT
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1b0ca2227..5a8523966 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -620,14 +620,14 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvconvert --splitcache LV_cachepool_cache_thinpool_vdopool_writecache
-OO: OO_LVCONVERT
+OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_split_and_keep_cache
 DESC: Detach a cache from an LV.
 
 ---
 
 lvconvert --uncache LV_cache_thinpool_vdopool_writecache
-OO: OO_LVCONVERT
+OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_split_and_remove_cache
 DESC: Detach and delete a cache from an LV.
 FLAGS: SECONDARY_SYNTAX
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 60c0fca21..a4ec48ede 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3659,7 +3659,9 @@ static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_cont
  * Data/results accumulated during processing.
  */
 struct lvconvert_result {
-	int need_polling;
+	unsigned need_polling:1;
+	unsigned wait_cleaner_writecache:1;
+	unsigned active_begin:1;
 	struct dm_list poll_idls;
 };
 
@@ -4905,9 +4907,11 @@ int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_merge_thin_single);
 }
 
-static int _lvconvert_detach_writecache(struct cmd_context *cmd,
+static int _lvconvert_detach_writecache(struct cmd_context *cmd, struct processing_handle *handle,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast);
+static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
+						   struct lvconvert_result *lr);
 
 static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
@@ -4958,7 +4962,7 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 
 	if (lv_is_writecache(lv_main)) {
-		if (!_lvconvert_detach_writecache(cmd, lv_main, lv_fast))
+		if (!_lvconvert_detach_writecache(cmd, handle, lv_main, lv_fast))
 			return ECMD_FAILED;
 
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
@@ -5008,11 +5012,33 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 
 int lvconvert_split_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	int ret;
+
 	cmd->handles_missing_pvs = 1;
 	cmd->partial_activation = 1;
 
-	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_split_cache_single);
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       handle, NULL, &_lvconvert_split_cache_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	if (ret == ECMD_FAILED)
+		return ret;
+
+	if (lr.wait_cleaner_writecache)
+		if (!_lvconvert_detach_writecache_when_clean(cmd, &lr))
+			ret = ECMD_FAILED;
+
+	return ret;
 }
 
 static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -5478,12 +5504,37 @@ int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **arg
 			       NULL, NULL, &_lvconvert_to_vdopool_single);
 }
 
+/*
+ * Starts the detach process, and may complete it, or may defer the completion
+ * if cleaning is required, by returning a poll id.  If deferred, the caller
+ * will notice the poll id and call lvconvert_detach_writecache_when_clean
+ * to wait for the cleaning and complete the detach.  The command can be cancelled
+ * while waiting for cleaning and the same command be repeated to continue the
+ * process.
+ */
 static int _lvconvert_detach_writecache(struct cmd_context *cmd,
+					struct processing_handle *handle,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast)
 {
+	struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
+	struct writecache_settings settings;
+	struct convert_poll_id_list *idl;
+	uint32_t block_size_sectors;
+	int active_begin = 0;
+	int active_clean = 0;
+	int is_clean = 0;
 	int noflush = 0;
 
+	dm_list_init(&lr->poll_idls);
+
+	memset(&settings, 0, sizeof(settings));
+
+	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {
+		log_error("Invalid writecache settings.");
+		return 0;
+	}
+
 	if (!archive(lv->vg))
 		return_0;
 
@@ -5508,15 +5559,99 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	}
 
 	/*
-	 * TODO: send a message to writecache in the kernel to start writing
-	 * back cache data to the origin.  Then release the vg lock and monitor
-	 * the progress of that writeback.  When it's complete we can reacquire
-	 * the vg lock, rescan the vg (ensure it hasn't changed), and do the
-	 * detach which should be quick since the writeback is complete.  If
-	 * this command is canceled while monitoring writeback, it should just
-	 * be rerun.  The LV will continue to have the writecache until this
-	 * command is run to completion.
+	 * If the LV is inactive when we begin, then we want to
+	 * deactivate the LV at the end.
+	 */
+	active_begin = lv_is_active(lv);
+
+	if (!noflush) {
+		/*
+		 * --cachesettings cleaner=0 means to skip the use of the cleaner
+		 * and go directly to detach which will use a flush message.
+		 * (This is currently the only cachesetting used during detach.)
+		 */
+		if (settings.cleaner_set && !settings.cleaner) {
+			log_print_unless_silent("Detaching writecache skipping cleaner...");
+			goto detach;
+		}
+
+		if (!writecache_cleaner_supported(cmd)) {
+			log_print_unless_silent("Detaching writecache without cleaner...");
+			goto detach;
+		}
+
+		if (!active_begin && !activate_lv(cmd, lv)) {
+			log_error("Failed to activate LV to clean writecache.");
+			return 0;
+		}
+		active_clean = 1;
+
+		/*
+		 * If the user ran this command previously (or set cleaner
+		 * directly) the cache may already be empty and ready for
+		 * detach.
+		 */
+		if (lv_writecache_is_clean(cmd, lv, NULL)) {
+			log_print_unless_silent("Detaching writecache already clean.");
+			is_clean = 1;
+			goto detach;
+		}
+
+		/*
+		 * If the user has not already done lvchange --cachesettings cleaner=1
+		 * then do that here.  If the LV is inactive, this activates it
+		 * so that cache writeback can be done.
+		 */
+		log_print_unless_silent("Detaching writecache setting cleaner.");
+
+		if (!lv_writecache_set_cleaner(lv)) {
+			log_error("Failed to set cleaner cachesetting to flush cache.");
+			log_error("See lvchange --cachesettings cleaner=1");
+
+			if (!active_begin && active_clean && !deactivate_lv(cmd, lv))
+				stack;
+			return 0;
+		}
+
+		/*
+		 * The cache may have been nearly clean and will be empty with
+		 * a short dely.
+		 */
+		usleep(10000);
+		if (lv_writecache_is_clean(cmd, lv, NULL)) {
+			log_print_unless_silent("Detaching writecache finished cleaning.");
+			is_clean = 1;
+			goto detach;
+		}
+
+		if (!(idl = _convert_poll_id_list_create(cmd, lv))) {
+			log_error("Failed to monitor writecache cleaner progress.");
+			return 0;
+		}
+
+		/*
+		 * Monitor the writecache status until the cache is unused.
+		 * This is done at the end of the command where locks are not
+		 * held since the writeback can take some time.
+		 */
+		lr->wait_cleaner_writecache = 1;
+		lr->active_begin = active_begin;
+
+		dm_list_add(&lr->poll_idls, &idl->list);
+		return 1;
+	}
+
+ detach:
+
+	/*
+	 * If the LV was inactive before cleaning and activated to do cleaning,
+	 * then deactivate before the detach.
 	 */
+	if (!active_begin && active_clean && !deactivate_lv(cmd, lv))
+		stack;
+
+	if (is_clean)
+		noflush = 1;
 
 	if (!lv_detach_writecache_cachevol(lv, noflush))
 		return_0;
@@ -5528,6 +5663,128 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * _lvconvert_detach_writecache() set the cleaner option for the LV
+ * so writecache will begin writing back data from cache to origin.
+ * It then saved the LV name/id (lvconvert_result/poll_id), and
+ * exited process_each_lv (releasing the VG and VG lock).  Then
+ * this is called to monitor the progress of the cache writeback.
+ * When the cache is clean, this does the detach (writecache is removed
+ * in metadata and LV in kernel is updated.)
+ */
+static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
+						   struct lvconvert_result *lr)
+{
+	struct convert_poll_id_list *idl;
+	struct poll_operation_id *id;
+	struct volume_group *vg;
+	struct logical_volume *lv;
+	uint32_t lockd_state, error_flags;
+	uint64_t dirty;
+	int ret;
+
+	idl = dm_list_item(dm_list_first(&lr->poll_idls), struct convert_poll_id_list);
+	id = idl->id;
+
+	/*
+	 * TODO: we should be able to save info about the dm device for this LV
+	 * and monitor the dm device status without doing vg lock/read around
+	 * each check.  The vg lock/read/write would then happen only once when
+	 * status was finished and we want to finish the detach.  If the dm
+	 * device goes away while monitoring, it's no different and no worse
+	 * than the LV going away here.
+	 */
+
+ retry:
+	lockd_state = 0;
+	error_flags = 0;
+
+	if (!lockd_vg(cmd, id->vg_name, "ex", 0, &lockd_state)) {
+		log_error("Detaching writecache interrupted - locking VG failed.");
+		return 0;
+	}
+
+	vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
+
+	if (!vg) {
+		log_error("Detaching writecache interrupted - reading VG failed.");
+		ret = 0;
+		goto out_lockd;
+	}
+
+	if (error_flags) {
+		log_error("Detaching writecache interrupted - reading VG error %x.", error_flags);
+		ret = 0;
+		goto out_release;
+	}
+
+	lv = find_lv(vg, id->lv_name);
+
+	if (lv && id->uuid && strcmp(id->uuid, (char *)&lv->lvid))
+		lv = NULL;
+
+	if (!lv) {
+		log_error("Detaching writecache interrupted - LV not found.");
+		ret = 0;
+		goto out_release;
+	}
+
+	if (!lv_is_active(lv)) {
+		log_error("Detaching writecache interrupted - LV not active.");
+		ret = 0;
+		goto out_release;
+	}
+
+	if (!lv_writecache_is_clean(cmd, lv, &dirty)) {
+		unlock_and_release_vg(cmd, vg, vg->name);
+
+		if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
+			stack;
+
+		log_print_unless_silent("Detaching writecache cleaning %llu blocks", (unsigned long long)dirty);
+		log_print_unless_silent("This command can be cancelled and rerun to complete writecache detach.");
+		sleep(5);
+		goto retry;
+	}
+
+	if (!lr->active_begin) {
+		/*
+		 * The LV was not active to begin so we should leave it inactive at the end.
+		 * It will remain inactive during detach since it's clean and doesn't need
+		 * a flush message.
+		 */
+		if (!deactivate_lv(cmd, lv))
+			stack;
+	}
+
+	log_print("Detaching writecache completed cleaning.");
+
+	/*
+	 * When the cleaner has finished, we can detach with noflush since
+	 * the cleaner has done the flushing.
+	 */
+
+	if (!lv_detach_writecache_cachevol(lv, 1)) {
+		log_error("Detaching writecache cachevol failed.");
+		ret = 0;
+		goto out_release;
+	}
+
+	ret = 1;
+	backup(vg);
+
+out_release:
+	unlock_and_release_vg(cmd, vg, vg->name);
+
+out_lockd:
+	if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
+		stack;
+
+	if (ret)
+		log_print_unless_silent("Logical volume %s write cache has been detached.", display_lvname(lv));
+	return ret;
+}
+
 static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct wipe_params wp = {
@@ -5838,6 +6095,8 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	is_active = lv_is_active(lv);
 
+	is_active = lv_is_active(lv);
+
 	memset(&settings, 0, sizeof(settings));
 
 	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {


