From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:37 +0100
Subject: [PATCH 14/24] Critical section
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <9be0302642340f740dd248abaa6ca1043a32fa45.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New function to mark the critical section is introduced.

Inside the critical section - memory is always locked.
When the critical section is left, memory stays locked
until memory lock is decremeneted - during VG unlock.

memlock_reset() is needed to reset locking numbers after fork (polldaemon).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   10 +++---
 lib/activate/activate.c       |   16 +++++-----
 lib/activate/fs.c             |    4 +-
 lib/cache/lvmcache.c          |    6 ++--
 lib/device/dev-io.c           |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/locking/locking.c         |   14 ++++++++-
 lib/log/log.c                 |    6 ++--
 lib/metadata/metadata.c       |   12 ++++----
 lib/metadata/mirror.c         |    2 +-
 lib/mm/memlock.c              |   60 +++++++++++++++++++++++++++++++---------
 lib/mm/memlock.h              |    6 +++-
 12 files changed, 93 insertions(+), 47 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 1fa2348..2cf04cf 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -479,8 +479,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
@@ -541,7 +541,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
 
-	DEBUGLOG("Command return is %d, memlock is %d\n", status, memlock());
+	DEBUGLOG("Command return is %d, critical_section is %d\n", status, critical_section());
 	return status;
 }
 
@@ -689,8 +689,8 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 	if (strncmp(resource, "P_#", 3) && !strncmp(resource, "P_", 2))
 		lock_cmd |= LCK_CACHE;
 
-	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), critical_section());
 
 	/* P_#global causes a full cache refresh */
 	if (!strcmp(resource, "P_" VG_GLOBAL)) {
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d8f31ba..4e862f5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1027,7 +1027,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		if (!error_if_not_suspended) {
 			r = 1;
 			if (info.suspended)
-				memlock_inc(cmd);
+				critical_section_inc(cmd);
 		}
 		goto out;
 	}
@@ -1049,14 +1049,14 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		/* FIXME Consider aborting here */
 		stack;
 
-	memlock_inc(cmd);
+	critical_section_inc(cmd);
 
 	if (!origin_only &&
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
 	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
-		memlock_dec(cmd);
+		critical_section_dec(cmd);
 		fs_unlock();
 		goto out;
 	}
@@ -1123,7 +1123,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
@@ -1214,9 +1214,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
 
-	memlock_inc(cmd);
+	critical_section_inc(cmd);
 	r = _lv_deactivate(lv);
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
@@ -1311,10 +1311,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
-	memlock_inc(cmd);
+	critical_section_inc(cmd);
 	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 31a71b1..24bfd80 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -411,7 +411,7 @@ static int _fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 		  const char *lv_name, const char *dev, const char *old_lv_name,
 		  int check_udev)
 {
-	if (memlock()) {
+	if (critical_section()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
 				  old_lv_name, check_udev))
 			return_0;
@@ -457,7 +457,7 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 
 void fs_unlock(void)
 {
-	if (!memlock()) {
+	if (!critical_section()) {
 		log_debug("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 66e3aeb..06c9115 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -649,7 +649,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	 * Note that we do not clear the PRECOMMITTED flag.
 	 */
 	if ((precommitted && !vginfo->precommitted) ||
-	    (!precommitted && vginfo->precommitted && !memlock()))
+	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
 	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
@@ -783,7 +783,7 @@ struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 		}
 	}
 
-	if (memlock() || (scan_done_once && *scan_done_once))
+	if (critical_section() || (scan_done_once && *scan_done_once))
 		return NULL;
 
 	lvmcache_label_scan(cmd, 2);
@@ -1229,7 +1229,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
 	    mdas_empty_or_ignored(&info->mdas) &&
-	    !is_orphan_vg(info->vginfo->vgname) && memlock())
+	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
 	/* If moving PV from orphan to real VG, always mark it valid */
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index eb80a89..f4f8578 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -399,7 +399,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		dev_close_immediate(dev);
 	}
 
-	if (memlock())
+	if (critical_section())
 		/* FIXME Make this log_error */
 		log_verbose("dev_open(%s) called while suspended",
 			 dev_name(dev));
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 8abc564..7d355e4 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1603,7 +1603,7 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 		return 1;
 
 	/* Perform full scan (just the first time) and try again */
-	if (!scan_label_only && !memlock() && !full_scan_done()) {
+	if (!scan_label_only && !critical_section() && !full_scan_done()) {
 		lvmcache_label_scan(info->fmt->cmd, 2);
 
 		if (_get_pv_if_in_vg(info, pv))
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 645f25d..7fada41 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -167,7 +167,7 @@ static void _lock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 		return;
 
 	if (lv_op == LV_SUSPEND)
-		memlock_inc(cmd);
+		critical_section_inc(cmd);
 }
 
 static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
@@ -176,7 +176,7 @@ static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 		return;
 
 	if (lv_op == LV_RESUME)
-		memlock_dec(cmd);
+		critical_section_dec(cmd);
 }
 
 void reset_locking(void)
@@ -191,6 +191,8 @@ void reset_locking(void)
 
 	if (was_locked)
 		_unblock_signals();
+
+	memlock_reset();
 }
 
 static void _update_vg_lock_count(const char *resource, uint32_t flags)
@@ -358,6 +360,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		     uint32_t flags, lv_operation_t lv_op)
 {
 	int ret = 0;
+	int locked;
 
 	_block_signals(flags);
 	_lock_memory(cmd, lv_op);
@@ -392,7 +395,14 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 			dev_reset_error_count(cmd);
 		}
 
+		locked = _vg_lock_count;
 		_update_vg_lock_count(resource, flags);
+		if (locked != _vg_lock_count) {
+			if (locked < _vg_lock_count)
+				memlock_inc(cmd);
+			else
+				memlock_dec(cmd);
+		}
 	} else
 		stack;
 
diff --git a/lib/log/log.c b/lib/log/log.c
index 252d8d3..eb95b9b 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -336,7 +336,7 @@ void print_log(int level, const char *file, int line, int dm_errno,
 	if (level > debug_level())
 		return;
 
-	if (_log_to_file && (_log_while_suspended || !memlock())) {
+	if (_log_to_file && (_log_while_suspended || !critical_section())) {
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
 
@@ -348,14 +348,14 @@ void print_log(int level, const char *file, int line, int dm_errno,
 		fflush(_log_file);
 	}
 
-	if (_syslog && (_log_while_suspended || !memlock())) {
+	if (_syslog && (_log_while_suspended || !critical_section())) {
 		va_start(ap, format);
 		vsyslog(level, trformat, ap);
 		va_end(ap);
 	}
 
 	/* FIXME This code is unfinished - pre-extend & condense. */
-	if (!_already_logging && _log_direct && memlock()) {
+	if (!_already_logging && _log_direct && critical_section()) {
 		_already_logging = 1;
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a9c7830..f76e10a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2792,7 +2792,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		lvmcache_label_scan(cmd, 0);
 		if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && memlock())
+			if (!cmd->independent_metadata_areas && critical_section())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
 			if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
@@ -2921,7 +2921,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
 
-			if (memlock())
+			if (critical_section())
 				inconsistent = 1;
 			else {
 				free_vg(correct_vg);
@@ -2952,7 +2952,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		inconsistent = 0;
 
 		/* Independent MDAs aren't supported under low memory */
-		if (!cmd->independent_metadata_areas && memlock())
+		if (!cmd->independent_metadata_areas && critical_section())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
 		if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
@@ -3212,7 +3212,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
-	if (memlock())
+	if (critical_section())
 		return_NULL;
 
 	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
@@ -3891,10 +3891,10 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 		lvmcache_label_scan(cmd, 0);
 		if (!fmt_from_vgname(vgname, NULL, 1)) {
 			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && memlock()) {
+			if (!cmd->independent_metadata_areas && critical_section()) {
 				/*
 				 * FIXME: Disallow calling this function if
-				 * memlock() is true.
+				 * critical_section() is true.
 				 */
 				unlock_vg(cmd, vgname);
 				return FAILED_LOCKING;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5e0f8d8..318ac03 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -974,7 +974,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 
 	/* FIXME: second suspend should not be needed
 	 * Explicitly suspend temporary LV
-	 * This balance memlock_inc() calls with memlock_dec() in resume
+	 * This balance critical_section_inc() calls with critical_section_dec() in resume
 	 * (both localy and in cluster) and also properly propagates precommited
 	 * metadata into dm table on other nodes.
 	 * (visible flag set causes the suspend is not properly propagated?)
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 9ddc2a2..4a6b043 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -52,8 +52,10 @@ static size_t _size_malloc_tmp;
 static size_t _size_malloc = 2000000;
 
 static void *_malloc_mem = NULL;
+static int _mem_locked;
 static int _memlock_count = 0;
 static int _memlock_count_daemon = 0;
+static int _critical_section_count = 0;
 static int _priority;
 static int _default_priority;
 
@@ -339,14 +341,31 @@ static void _unlock_mem(struct cmd_context *cmd)
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
-	if ((_memlock_count + _memlock_count_daemon) == 1)
+	if (!_mem_locked && (_critical_section_count == 1) &&
+	    (_memlock_count + _memlock_count_daemon) == 1) {
+		_mem_locked = 1;
 		_lock_mem(cmd);
+	}
 }
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	if ((_memlock_count + _memlock_count_daemon) == 0)
+	log_debug("UnlockMem cd:%d mc:%d md:%d", _critical_section_count,
+		  _memlock_count, _memlock_count_daemon);
+	if ((_mem_locked == 1) && !_critical_section_count &&
+	    (_memlock_count + _memlock_count_daemon) == 0) {
 		_unlock_mem(cmd);
+		_mem_locked = 0;
+	}
+}
+
+void memlock_reset(void)
+{
+	log_debug("memlock reset.");
+	_mem_locked = 0;
+	_memlock_count = 0;
+	_memlock_count_daemon = 0;
+	_critical_section_count = 0;
 }
 
 void memlock_inc(struct cmd_context *cmd)
@@ -390,17 +409,6 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
 }
 
-/*
- * This disregards the daemon (dmeventd) locks, since we use memlock() to check
- * whether it is safe to run a device scan, which would normally coincide with
- * !memlock() -- but the daemon global memory lock breaks this assumption, so
- * we do not take those into account here.
- */
-int memlock(void)
-{
-	return _memlock_count;
-}
-
 void memlock_init(struct cmd_context *cmd)
 {
 	_size_stack = find_config_tree_int(cmd,
@@ -414,4 +422,28 @@ void memlock_init(struct cmd_context *cmd)
 					    DEFAULT_PROCESS_PRIORITY);
 }
 
+void critical_section_inc(struct cmd_context *cmd)
+{
+	++_critical_section_count;
+	if (_critical_section_count == 1 &&
+	    ((_memlock_count_daemon + _memlock_count) < 1))
+		log_error(INTERNAL_ERROR "_critical_section used before _memlock_inc.");
+	log_debug("critical_section_inc to %d", _critical_section_count);
+	_lock_mem_if_needed(cmd);
+}
+
+void critical_section_dec(struct cmd_context *cmd)
+{
+	if (!_critical_section_count)
+		log_error(INTERNAL_ERROR "_critical_section has dropped below 0.");
+	--_critical_section_count;
+	_unlock_mem_if_possible(cmd);
+	log_debug("critical_section_dec to %d", _critical_section_count);
+}
+
+int critical_section(void)
+{
+	return _critical_section_count;
+}
+
 #endif
diff --git a/lib/mm/memlock.h b/lib/mm/memlock.h
index fd19317..c955662 100644
--- a/lib/mm/memlock.h
+++ b/lib/mm/memlock.h
@@ -18,11 +18,15 @@
 
 struct cmd_context;
 
+void critical_section_inc(struct cmd_context *cmd);
+void critical_section_dec(struct cmd_context *cmd);
+int critical_section(void);
+
+void memlock_reset(void);
 void memlock_inc(struct cmd_context *cmd);
 void memlock_dec(struct cmd_context *cmd);
 void memlock_inc_daemon(struct cmd_context *cmd);
 void memlock_dec_daemon(struct cmd_context *cmd);
-int memlock(void);
 void memlock_init(struct cmd_context *cmd);
 
 #endif
-- 
1.7.3.5


