From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 10:57:27 +0100
Subject: [PATCH 1/1] Critical section
In-Reply-To: <cover.1297418125.git.zkabelac@redhat.com>
References: <cover.1297418125.git.zkabelac@redhat.com>
Message-ID: <8a22f213958fd478b8594cb4afec129797c95953.1297418125.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New strategy for memory locking to decrease the number of call to
to un/lock memory when processing critical lvm functions.

Introducing function for critical section.

Inside the critical section - memory is always locked.
When leaving critical section, the memory stays locked
until memlock_munlock() is called - this happend with
sync_local_dev_names() and sync_dev_names() function call.

memlock_reset() is needed to reset locking numbers after fork
(polldaemon).

The patch itself is mostly rename:

memlock_inc  -> critical_section_inc
memlock_dec  -> critical_section_dec
memlock      -> critical_section

Daemons (clmvd, dmevent) are using memlock_daemon_inc&dec
(mlockall()) thus they will never release or relock memory they've
already locked memory.

Macros sync_local_dev_names() and sync_dev_names() are functions.
It's better for debugging - and also we do not need to add memlock.h
to locking.h header (for memlock_munlock() prototyp).
IMHO all other lock macros should be turned to functions.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   14 +++---
 lib/activate/activate.c       |   16 +++---
 lib/activate/fs.c             |    4 +-
 lib/cache/lvmcache.c          |    6 +-
 lib/device/dev-io.c           |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/locking/locking.c         |   20 +++++++-
 lib/locking/locking.h         |    8 +--
 lib/log/log.c                 |    6 +-
 lib/metadata/metadata.c       |   12 ++--
 lib/metadata/mirror.c         |    2 +-
 lib/mm/memlock.c              |  104 ++++++++++++++++++++++++++++-------------
 lib/mm/memlock.h              |   10 ++--
 13 files changed, 129 insertions(+), 77 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 81e8b88..155edcd 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -377,9 +377,9 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 		goto error;
 
 	if (lvi.suspended) {
-		memlock_inc(cmd);
+		critical_section_inc(cmd);
 		if (!lv_resume(cmd, resource, 0)) {
-			memlock_dec(cmd);
+			critical_section_dec(cmd);
 			goto error;
 		}
 	}
@@ -487,8 +487,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
@@ -549,7 +549,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
 
-	DEBUGLOG("Command return is %d, memlock is %d\n", status, memlock());
+	DEBUGLOG("Command return is %d, critical_section is %d\n", status, critical_section());
 	return status;
 }
 
@@ -697,8 +697,8 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 	if (strncmp(resource, "P_#", 3) && !strncmp(resource, "P_", 2))
 		lock_cmd |= LCK_CACHE;
 
-	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), critical_section());
 
 	/* P_#global causes a full cache refresh */
 	if (!strcmp(resource, "P_" VG_GLOBAL)) {
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9edb011..ad9459a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1096,7 +1096,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		if (!error_if_not_suspended) {
 			r = 1;
 			if (info.suspended)
-				memlock_inc(cmd);
+				critical_section_inc(cmd);
 		}
 		goto out;
 	}
@@ -1118,14 +1118,14 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
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
@@ -1192,7 +1192,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
@@ -1283,9 +1283,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
 
-	memlock_inc(cmd);
+	critical_section_inc(cmd);
 	r = _lv_deactivate(lv);
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
@@ -1380,10 +1380,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
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
index 7acfc6b..e39c012 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -433,7 +433,7 @@ static int _fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 		  const char *lv_name, const char *dev, const char *old_lv_name,
 		  int check_udev)
 {
-	if (memlock()) {
+	if (critical_section()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
 				  old_lv_name, check_udev))
 			return_0;
@@ -479,7 +479,7 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 
 void fs_unlock(void)
 {
-	if (!memlock()) {
+	if (!critical_section()) {
 		log_debug("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e9cae1..3f5f417 100644
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
index dadaed3..13e1668 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1601,7 +1601,7 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 		return 1;
 
 	/* Perform full scan (just the first time) and try again */
-	if (!scan_label_only && !memlock() && !full_scan_done()) {
+	if (!scan_label_only && !critical_section() && !full_scan_done()) {
 		lvmcache_label_scan(info->fmt->cmd, 2);
 
 		if (_get_pv_if_in_vg(info, pv))
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 520b25e..6bea3cd 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
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
@@ -568,3 +570,15 @@ int remote_lock_held(const char *vol, int *exclusive)
 
 	return mode == LCK_NULL ? 0 : 1;
 }
+
+int sync_local_dev_names(struct cmd_context* cmd)
+{
+	memlock_munlock(cmd);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL);
+}
+
+int sync_dev_names(struct cmd_context* cmd)
+{
+	memlock_munlock(cmd);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE);
+}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index f30a76c..49ba252 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -175,10 +175,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
-#define sync_local_dev_names(cmd)	\
-	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
-#define sync_dev_names(cmd)	\
-	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE)
+int sync_local_dev_names(struct cmd_context* cmd);
+int sync_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
diff --git a/lib/log/log.c b/lib/log/log.c
index 86b4988..ec72b7a 100644
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
index 771cdb0..c626398 100644
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
index 062b765..63f3a0e 100644
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
@@ -28,15 +28,27 @@
 
 #ifndef DEVMAPPER_SUPPORT
 
-void memlock_inc(struct cmd_context *cmd)
+void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	return;
 }
-void memlock_dec(struct cmd_context *cmd)
+
+void memlock_dec_daemon(struct cmd_context *cmd)
 {
 	return;
 }
-int memlock(void)
+
+void critical_section_inc(struct cmd_context *cmd)
+{
+	return;
+}
+
+void critical_section_dec(struct cmd_context *cmd)
+{
+	return;
+}
+
+int critical_section(void)
 {
 	return 0;
 }
@@ -45,6 +57,16 @@ void memlock_init(struct cmd_context *cmd)
 	return;
 }
 
+void memlock_munlock(struct cmd_context *cmd)
+{
+	return;
+}
+
+void memlock_reset(void)
+{
+	return;
+}
+
 #else				/* DEVMAPPER_SUPPORT */
 
 static size_t _size_stack;
@@ -52,7 +74,8 @@ static size_t _size_malloc_tmp;
 static size_t _size_malloc = 2000000;
 
 static void *_malloc_mem = NULL;
-static int _memlock_count = 0;
+static int _mem_locked;
+static int _critical_section_count = 0;
 static int _memlock_count_daemon = 0;
 static int _priority;
 static int _default_priority;
@@ -333,46 +356,59 @@ static void _unlock_mem(struct cmd_context *cmd)
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
-	if ((_memlock_count + _memlock_count_daemon) == 1)
+	if (!_mem_locked &&
+	    ((_critical_section_count + _memlock_count_daemon) == 1)) {
+		_mem_locked = 1;
 		_lock_mem(cmd);
+	}
 }
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	if ((_memlock_count + _memlock_count_daemon) == 0)
+	log_debug("UnlockMem l:%d cs:%d md:%d", _mem_locked,
+		  _critical_section_count, _memlock_count_daemon);
+	if (_mem_locked &&
+	    !_critical_section_count &&
+	    !_memlock_count_daemon) {
 		_unlock_mem(cmd);
+		_mem_locked = 0;
+	}
 }
 
-void memlock_inc(struct cmd_context *cmd)
+void critical_section_inc(struct cmd_context *cmd)
 {
-	++_memlock_count;
+	++_critical_section_count;
+	log_debug("critical_section_inc to %d", _critical_section_count);
 	_lock_mem_if_needed(cmd);
-	log_debug("memlock_count inc to %d", _memlock_count);
 }
 
-void memlock_dec(struct cmd_context *cmd)
+void critical_section_dec(struct cmd_context *cmd)
 {
-	if (!_memlock_count)
-		log_error(INTERNAL_ERROR "_memlock_count has dropped below 0.");
-	--_memlock_count;
-	_unlock_mem_if_possible(cmd);
-	log_debug("memlock_count dec to %d", _memlock_count);
+	if (!_critical_section_count)
+		log_error(INTERNAL_ERROR "_critical_section has dropped below 0.");
+	--_critical_section_count;
+	log_debug("critical_section_dec to %d", _critical_section_count);
+}
+
+int critical_section(void)
+{
+	return _critical_section_count;
 }
 
 /*
  * The memlock_*_daemon functions will force the mlockall() call that we need
  * to stay in memory, but they will have no effect on device scans (unlike
- * normal memlock_inc and memlock_dec). Memory is kept locked as long as either
- * of memlock or memlock_daemon is in effect.
+ * normal critical_section_inc/dec). Memory is kept locked as long as either
+ * of critical_section or memlock_daemon is in effect.
  */
 
 void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	++_memlock_count_daemon;
-	if (_memlock_count_daemon == 1 && _memlock_count > 0)
-                log_error(INTERNAL_ERROR "_memlock_inc_daemon used after _memlock_inc.");
-	_lock_mem_if_needed(cmd);
+	if (_memlock_count_daemon == 1 && _critical_section_count > 0)
+                log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
 	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
+	_lock_mem_if_needed(cmd);
 }
 
 void memlock_dec_daemon(struct cmd_context *cmd)
@@ -380,19 +416,8 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 	if (!_memlock_count_daemon)
 		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
-	_unlock_mem_if_possible(cmd);
 	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
-}
-
-/*
- * This disregards the daemon (dmeventd) locks, since we use memlock() to check
- * whether it is safe to run a device scan, which would normally coincide with
- * !memlock() -- but the daemon global memory lock breaks this assumption, so
- * we do not take those into account here.
- */
-int memlock(void)
-{
-	return _memlock_count;
+	_unlock_mem_if_possible(cmd);
 }
 
 void memlock_init(struct cmd_context *cmd)
@@ -408,4 +433,17 @@ void memlock_init(struct cmd_context *cmd)
 					    DEFAULT_PROCESS_PRIORITY);
 }
 
+void memlock_reset(void)
+{
+	log_debug("memlock reset.");
+	_mem_locked = 0;
+	_critical_section_count = 0;
+	_memlock_count_daemon = 0;
+}
+
+void memlock_munlock(struct cmd_context *cmd)
+{
+	_unlock_mem_if_possible(cmd);
+}
+
 #endif
diff --git a/lib/mm/memlock.h b/lib/mm/memlock.h
index fd19317..b236229 100644
--- a/lib/mm/memlock.h
+++ b/lib/mm/memlock.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,11 +18,13 @@
 
 struct cmd_context;
 
-void memlock_inc(struct cmd_context *cmd);
-void memlock_dec(struct cmd_context *cmd);
+void critical_section_inc(struct cmd_context *cmd);
+void critical_section_dec(struct cmd_context *cmd);
+int critical_section(void);
 void memlock_inc_daemon(struct cmd_context *cmd);
 void memlock_dec_daemon(struct cmd_context *cmd);
-int memlock(void);
 void memlock_init(struct cmd_context *cmd);
+void memlock_reset(void);
+void memlock_munlock(struct cmd_context *cmd);
 
 #endif
-- 
1.7.4


