From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 12:42:04 -0400
Subject: master - Remove checking for locked VGs
Message-ID: <201806121642.w5CGg4wa007213@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4153a8dfca9defcea645818dcd547388858c51e
Commit:        c4153a8dfca9defcea645818dcd547388858c51e
Parent:        3b6b7f8f9be1841fc7d283203a1f3261e7e3622a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 11 12:25:52 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 09:46:04 2018 -0500

Remove checking for locked VGs

A few places were calling a function to check if a
VG lock was held.  The only place it was actually
needed is for pvcreate which wants to do its own
locking (and scanning) around process_each_pv.

The locking/scanning exceptions for pvcreate in
process_each_pv/vg_read can be enabled by just passing
a couple of flags instead of checking if the VG is
already locked.  This also means that these special
cases won't be enabled unknowingly in other places
where they shouldn't be used.
---
 lib/cache/lvmcache.c             |    8 ---
 lib/cache/lvmcache.h             |    1 -
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   18 ++-----
 tools/toollib.c                  |   94 +++++++++++---------------------------
 5 files changed, 34 insertions(+), 89 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 923fb2e..757ed88 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -142,14 +142,6 @@ void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unuse
 		_vgs_locked++;
 }
 
-int lvmcache_vgname_is_locked(const char *vgname)
-{
-	if (!_lock_hash)
-		return 0;
-
-	return dm_hash_lookup(_lock_hash, is_orphan_vg(vgname) ? VG_ORPHANS : vgname) ? 1 : 0;
-}
-
 void lvmcache_unlock_vgname(const char *vgname)
 {
 	if (!dm_hash_lookup(_lock_hash, vgname))
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 536f6fd..008f110 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -105,7 +105,6 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
-int lvmcache_vgname_is_locked(const char *vgname);
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bcd10a3..641bf49 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -178,6 +178,8 @@
 #define READ_OK_NOTFOUND	0x00040000U
 #define READ_WARN_INCONSISTENT	0x00080000U
 #define READ_FOR_UPDATE		0x00100000U /* A meta-flag, useful with toollib for_each_* functions. */
+#define PROCESS_SKIP_SCAN	 0x00200000U /* skip lvmcache_label_scan in process_each_pv */
+#define PROCESS_SKIP_ORPHAN_LOCK 0x00400000U /* skip lock_vol(VG_ORPHAN) in vg_read */
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff8f1a5..30b22c0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3049,12 +3049,6 @@ int vg_commit(struct volume_group *vg)
 	int cache_updated = 0;
 	struct pv_list *pvl;
 
-	if (!lvmcache_vgname_is_locked(vg->name)) {
-		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
-			  "without locking %s", vg->name);
-		return cache_updated;
-	}
-
 	cache_updated = _vg_commit_mdas(vg);
 
 	set_vg_notify(vg->cmd);
@@ -5032,7 +5026,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	uint32_t failure = 0;
 	uint32_t warn_flags = 0;
 	int is_shared = 0;
-	int already_locked;
+	int skip_lock = is_orphan_vg(vg_name) && (read_flags & PROCESS_SKIP_ORPHAN_LOCK);
 
 	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE))
 		consistent = 0;
@@ -5043,15 +5037,13 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		return NULL;
 	}
 
-	already_locked = lvmcache_vgname_is_locked(vg_name);
-
-	if (!already_locked &&
+	if (!skip_lock &&
 	    !lock_vol(cmd, vg_name, lock_flags, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
 
-	if (already_locked)
+	if (skip_lock)
 		log_very_verbose("Locking %s already done", vg_name);
 
 	if (is_orphan_vg(vg_name))
@@ -5119,13 +5111,13 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto_bad;
 
 	if (!(vg = _vg_make_handle(cmd, vg, failure)) || vg_read_error(vg))
-		if (!already_locked)
+		if (!skip_lock)
 			unlock_vg(cmd, vg, vg_name);
 
 	return vg;
 
 bad:
-	if (!already_locked)
+	if (!skip_lock)
 		unlock_vg(cmd, vg, vg_name);
 
 bad_no_unlock:
diff --git a/tools/toollib.c b/tools/toollib.c
index 7da1703..fb37d07 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1926,7 +1926,6 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	int skip;
 	int notfound;
 	int process_all = 0;
-	int already_locked;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
@@ -1969,8 +1968,6 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 			continue;
 		}
 
-		already_locked = lvmcache_vgname_is_locked(vg_name);
-
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
@@ -1998,7 +1995,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				ret_max = ret;
 		}
 
-		if (!vg_read_error(vg) && !already_locked)
+		if (!vg_read_error(vg))
 			unlock_vg(cmd, vg, vg_name);
 endvg:
 		release_vg(vg);
@@ -3577,7 +3574,6 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 	int ret;
 	int skip;
 	int notfound;
-	int already_locked;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
@@ -3638,8 +3634,6 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			continue;
 		}
 
-		already_locked = lvmcache_vgname_is_locked(vg_name);
-
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
@@ -3658,8 +3652,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (!already_locked)
-			unlock_vg(cmd, vg, vg_name);
+		unlock_vg(cmd, vg, vg_name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -4299,7 +4292,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int ret;
 	int skip;
 	int notfound;
-	int already_locked;
+	int skip_lock;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
@@ -4333,7 +4326,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 
 		log_debug("Processing PVs in VG %s", vg_name);
 
-		already_locked = lvmcache_vgname_is_locked(vg_name);
+		skip_lock = is_orphan_vg(vg_name) && (read_flags & PROCESS_SKIP_ORPHAN_LOCK);
 
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
@@ -4361,7 +4354,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (!skip && !already_locked)
+		if (!skip && !skip_lock)
 			unlock_vg(cmd, vg, vg->name);
 endvg:
 		release_vg(vg);
@@ -4400,7 +4393,6 @@ int process_each_pv(struct cmd_context *cmd,
 	struct device_id_list *dil;
 	int process_all_pvs;
 	int process_all_devices;
-	int orphans_locked;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
@@ -4448,8 +4440,6 @@ int process_each_pv(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
-	orphans_locked = lvmcache_vgname_is_locked(VG_ORPHANS);
-
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
 	process_all_devices = process_all_pvs && (cmd->cname->flags & ENABLE_ALL_DEVS) && all_is_set;
@@ -4460,22 +4450,8 @@ int process_each_pv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	/*
-	 * This full scan would be done by _get_all_devices() if
-	 * it were not done here first.  It's called here first
-	 * so that get_vgnameids() will look at any new devices.
-	 * When orphans is already locked, these steps are done
-	 * before process_each_pv is called.
-	 */
-	if (!trust_cache() && !orphans_locked) {
-		lvmcache_destroy(cmd, 1, 0);
-
-		/*
-		 * Scan all devices to populate lvmcache with initial
-		 * list of PVs and VGs.
-		 */
+	if (!(read_flags & PROCESS_SKIP_SCAN))
 		lvmcache_label_scan(cmd);
-	}
 
 	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
 		ret_max = ret;
@@ -4546,11 +4522,9 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ret;
 
 	/*
-	 * If the orphans lock was held, there shouldn't be missed devices.  If
-	 * there were, we cannot clear the cache while holding the orphans lock
-	 * anyway.
+	 * If the orphans lock was held, there shouldn't be missed devices.
 	 */
-	if (orphans_locked)
+	if (read_flags & PROCESS_SKIP_ORPHAN_LOCK)
 		goto skip_missed;
 
 	/*
@@ -4577,12 +4551,7 @@ int process_each_pv(struct cmd_context *cmd,
 
 		log_verbose("Some PVs were not found in first search, retrying.");
 
-		lvmcache_destroy(cmd, 0, 0);
-		if (!lvmcache_init(cmd)) {
-			log_error("Failed to initalize lvm cache.");
-			ret_max = ECMD_FAILED;
-			goto out;
-		}
+		lvmcache_label_scan(cmd);
 		lvmcache_seed_infos_from_lvmetad(cmd);
 
 		ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
@@ -5413,25 +5382,16 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		dm_list_add(&pp->arg_devices, &pd->list);
 	}
 
-	/*
-	 * Clear the cache before acquiring the orphan lock.  (Clearing the
-	 * cache with locks held is an error.)  We want the orphan lock
-	 * acquired before process_each_pv.  If the orphan lock is not held
-	 * when process_each_pv is called, then process_each_pv clears the
-	 * cache.
-	 */
-	lvmcache_destroy(cmd, 1, 0);
-
-	/*
-	 * If no prompts require a user response, this orphan lock is held
-	 * throughout, and pvcreate_each_device() returns with it held so that
-	 * vgcreate/vgextend use the PVs created here to add to a VG.
-	 */
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs.");
 		return 0;
 	}
 
+	/*
+	 * Scan before calling process_each_pv so we can set up the PV args
+	 * first.  We can then skip the scan that would normally occur at the
+	 * beginning of process_each_pv.
+	 */
 	lvmcache_label_scan(cmd);
 
 	/*
@@ -5455,8 +5415,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * If it's added to arg_process but needs a prompt or force option, then
 	 * a corresponding prompt entry is added to pp->prompts.
 	 */
-	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle,
-			pp->is_remove ? _pvremove_check_single : _pvcreate_check_single);
+	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN | PROCESS_SKIP_ORPHAN_LOCK,
+			handle, pp->is_remove ? _pvremove_check_single : _pvcreate_check_single);
 
 	/*
 	 * A fatal error was found while checking.
@@ -5538,9 +5498,11 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto do_command;
 
 	/*
-	 * Prompts require asking the user, so release the orphans lock, ask
-	 * the questions, reacquire the orphans lock, verify that the PVs were
-	 * not used during the questions, then do the create steps.
+	 * Prompts require asking the user and make take some time, during
+	 * which we don't want to block other commands.  So, release the lock
+	 * to prevent blocking other commands while we wait.  After a response
+	 * from the user, reacquire the lock, verify that the PVs were not used
+	 * during the wait, then do the create steps.
 	 */
 	unlock_vg(cmd, NULL, VG_ORPHANS);
 
@@ -5575,14 +5537,11 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	}
 
 	/*
-	 * Clear the cache, reacquire the orphans write lock, then check again
-	 * that the devices can still be used.  If the second loop finds them
-	 * changed, or can't find them any more, then they aren't used.
-	 * Clear the cache here before locking orphans, since it won't be
-	 * done by process_each_pv with orphans already locked.
+	 * Reacquire the lock that was released above before waiting, then
+	 * check again that the devices can still be used.  If the second loop
+	 * finds them changed, or can't find them any more, then they aren't
+	 * used.
 	 */
-	lvmcache_destroy(cmd, 1, 0);
-
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs.");
 		goto out;
@@ -5604,7 +5563,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 */
 	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
 
-	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pv_confirm_single);
+	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN | PROCESS_SKIP_ORPHAN_LOCK,
+			handle, _pv_confirm_single);
 
 	dm_list_iterate_items(pd, &pp->arg_confirm)
 		log_error("Device %s %s.", pd->name, dev_cache_filtered_reason(pd->name));


