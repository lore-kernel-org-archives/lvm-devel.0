From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:16:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110218141614.4633.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:16:12

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c fs.c 
	lib/cache      : lvmcache.c 
	lib/device     : dev-io.c 
	lib/format_text: format-text.c 
	lib/locking    : locking.c locking.h 
	lib/log        : log.c 
	lib/metadata   : metadata.c mirror.c 
	lib/mm         : memlock.c memlock.h 

Log message:
	Critical section
	
	New strategy for memory locking to decrease the number of call to
	to un/lock memory when processing critical lvm functions.
	
	Introducing functions for critical section.
	
	Inside the critical section - memory is always locked.
	When leaving the critical section, the memory stays locked
	until memlock_unlock() is called - this happens with
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
	to locking.h header (for memlock_unlock() prototyp).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1915&r2=1.1916
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.422&r2=1.423
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2011/02/18 14:11:22	1.1915
+++ LVM2/WHATS_NEW	2011/02/18 14:16:11	1.1916
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Change memory locking semantic and use critical sections.
   Add configurable pv_min_size to select block devices by its size.
   Add function to read 64bit ints from config find_config_tree_int64.
   Fix to make resuming exclusive cluster mirror use local target type.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/18 00:36:04	1.112
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/18 14:16:11	1.113
@@ -377,9 +377,9 @@
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
@@ -489,8 +489,8 @@
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
@@ -551,7 +551,7 @@
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
 
-	DEBUGLOG("Command return is %d, memlock is %d\n", status, memlock());
+	DEBUGLOG("Command return is %d, critical_section is %d\n", status, critical_section());
 	return status;
 }
 
@@ -699,8 +699,8 @@
 	if (strncmp(resource, "P_#", 3) && !strncmp(resource, "P_", 2))
 		lock_cmd |= LCK_CACHE;
 
-	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), memlock());
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
+		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), critical_section());
 
 	/* P_#global causes a full cache refresh */
 	if (!strcmp(resource, "P_" VG_GLOBAL)) {
--- LVM2/lib/activate/activate.c	2011/02/18 00:36:05	1.192
+++ LVM2/lib/activate/activate.c	2011/02/18 14:16:11	1.193
@@ -1096,7 +1096,7 @@
 		if (!error_if_not_suspended) {
 			r = 1;
 			if (info.suspended)
-				memlock_inc(cmd);
+				critical_section_inc(cmd);
 		}
 		goto out;
 	}
@@ -1118,14 +1118,14 @@
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
@@ -1210,7 +1210,7 @@
 	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
@@ -1302,9 +1302,9 @@
 	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
 
-	memlock_inc(cmd);
+	critical_section_inc(cmd);
 	r = _lv_deactivate(lv);
-	memlock_dec(cmd);
+	critical_section_dec(cmd);
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
@@ -1399,10 +1399,10 @@
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
--- LVM2/lib/activate/fs.c	2011/02/04 22:07:44	1.60
+++ LVM2/lib/activate/fs.c	2011/02/18 14:16:11	1.61
@@ -433,7 +433,7 @@
 		  const char *lv_name, const char *dev, const char *old_lv_name,
 		  int check_udev)
 {
-	if (memlock()) {
+	if (critical_section()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
 				  old_lv_name, check_udev))
 			return_0;
@@ -479,7 +479,7 @@
 
 void fs_unlock(void)
 {
-	if (!memlock()) {
+	if (!critical_section()) {
 		log_debug("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
--- LVM2/lib/cache/lvmcache.c	2011/01/10 13:15:57	1.102
+++ LVM2/lib/cache/lvmcache.c	2011/02/18 14:16:11	1.103
@@ -649,7 +649,7 @@
 	 * Note that we do not clear the PRECOMMITTED flag.
 	 */
 	if ((precommitted && !vginfo->precommitted) ||
-	    (!precommitted && vginfo->precommitted && !memlock()))
+	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
 	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
@@ -783,7 +783,7 @@
 		}
 	}
 
-	if (memlock() || (scan_done_once && *scan_done_once))
+	if (critical_section() || (scan_done_once && *scan_done_once))
 		return NULL;
 
 	lvmcache_label_scan(cmd, 2);
@@ -1229,7 +1229,7 @@
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
 	    mdas_empty_or_ignored(&info->mdas) &&
-	    !is_orphan_vg(info->vginfo->vgname) && memlock())
+	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
 	/* If moving PV from orphan to real VG, always mark it valid */
--- LVM2/lib/device/dev-io.c	2010/10/13 15:40:39	1.72
+++ LVM2/lib/device/dev-io.c	2011/02/18 14:16:11	1.73
@@ -399,7 +399,7 @@
 		dev_close_immediate(dev);
 	}
 
-	if (memlock())
+	if (critical_section())
 		/* FIXME Make this log_error */
 		log_verbose("dev_open(%s) called while suspended",
 			 dev_name(dev));
--- LVM2/lib/format_text/format-text.c	2011/02/03 01:41:03	1.154
+++ LVM2/lib/format_text/format-text.c	2011/02/18 14:16:12	1.155
@@ -1601,7 +1601,7 @@
 		return 1;
 
 	/* Perform full scan (just the first time) and try again */
-	if (!scan_label_only && !memlock() && !full_scan_done()) {
+	if (!scan_label_only && !critical_section() && !full_scan_done()) {
 		lvmcache_label_scan(info->fmt->cmd, 2);
 
 		if (_get_pv_if_in_vg(info, pv))
--- LVM2/lib/locking/locking.c	2011/02/04 20:30:18	1.92
+++ LVM2/lib/locking/locking.c	2011/02/18 14:16:12	1.93
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -167,7 +167,7 @@
 		return;
 
 	if (lv_op == LV_SUSPEND)
-		memlock_inc(cmd);
+		critical_section_inc(cmd);
 }
 
 static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
@@ -176,7 +176,7 @@
 		return;
 
 	if (lv_op == LV_RESUME)
-		memlock_dec(cmd);
+		critical_section_dec(cmd);
 }
 
 void reset_locking(void)
@@ -191,6 +191,8 @@
 
 	if (was_locked)
 		_unblock_signals();
+
+	memlock_reset();
 }
 
 static void _update_vg_lock_count(const char *resource, uint32_t flags)
@@ -568,3 +570,15 @@
 
 	return mode == LCK_NULL ? 0 : 1;
 }
+
+int sync_local_dev_names(struct cmd_context* cmd)
+{
+	memlock_unlock(cmd);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL);
+}
+
+int sync_dev_names(struct cmd_context* cmd)
+{
+	memlock_unlock(cmd);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE);
+}
--- LVM2/lib/locking/locking.h	2011/02/04 20:30:18	1.62
+++ LVM2/lib/locking/locking.h	2011/02/18 14:16:12	1.63
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -175,10 +175,14 @@
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
+/* cleanup later
 #define sync_local_dev_names(cmd)	\
 	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
 #define sync_dev_names(cmd)	\
 	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE)
+*/
+int sync_local_dev_names(struct cmd_context* cmd);
+int sync_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
--- LVM2/lib/log/log.c	2010/10/26 08:53:25	1.60
+++ LVM2/lib/log/log.c	2011/02/18 14:16:12	1.61
@@ -336,7 +336,7 @@
 	if (level > debug_level())
 		return;
 
-	if (_log_to_file && (_log_while_suspended || !memlock())) {
+	if (_log_to_file && (_log_while_suspended || !critical_section())) {
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
 
@@ -348,14 +348,14 @@
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
--- LVM2/lib/metadata/metadata.c	2011/02/18 14:11:23	1.422
+++ LVM2/lib/metadata/metadata.c	2011/02/18 14:16:12	1.423
@@ -2793,7 +2793,7 @@
 		lvmcache_label_scan(cmd, 0);
 		if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && memlock())
+			if (!cmd->independent_metadata_areas && critical_section())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
 			if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
@@ -2922,7 +2922,7 @@
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
 
-			if (memlock())
+			if (critical_section())
 				inconsistent = 1;
 			else {
 				free_vg(correct_vg);
@@ -2953,7 +2953,7 @@
 		inconsistent = 0;
 
 		/* Independent MDAs aren't supported under low memory */
-		if (!cmd->independent_metadata_areas && memlock())
+		if (!cmd->independent_metadata_areas && critical_section())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
 		if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
@@ -3213,7 +3213,7 @@
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
-	if (memlock())
+	if (critical_section())
 		return_NULL;
 
 	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
@@ -3892,10 +3892,10 @@
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
--- LVM2/lib/metadata/mirror.c	2011/01/24 14:19:05	1.141
+++ LVM2/lib/metadata/mirror.c	2011/02/18 14:16:12	1.142
@@ -974,7 +974,7 @@
 
 	/* FIXME: second suspend should not be needed
 	 * Explicitly suspend temporary LV
-	 * This balance memlock_inc() calls with memlock_dec() in resume
+	 * This balance critical_section_inc() calls with critical_section_dec() in resume
 	 * (both localy and in cluster) and also properly propagates precommited
 	 * metadata into dm table on other nodes.
 	 * (visible flag set causes the suspend is not properly propagated?)
--- LVM2/lib/mm/memlock.c	2010/12/20 13:12:57	1.33
+++ LVM2/lib/mm/memlock.c	2011/02/18 14:16:12	1.34
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
@@ -45,6 +57,16 @@
 	return;
 }
 
+void memlock_unlock(struct cmd_context *cmd)
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
@@ -52,7 +74,8 @@
 static size_t _size_malloc = 2000000;
 
 static void *_malloc_mem = NULL;
-static int _memlock_count = 0;
+static int _mem_locked = 0;
+static int _critical_section_count = 0;
 static int _memlock_count_daemon = 0;
 static int _priority;
 static int _default_priority;
@@ -333,46 +356,59 @@
 
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
@@ -380,19 +416,8 @@
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
@@ -408,4 +433,17 @@
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
+void memlock_unlock(struct cmd_context *cmd)
+{
+	_unlock_mem_if_possible(cmd);
+}
+
 #endif
--- LVM2/lib/mm/memlock.h	2010/03/05 14:48:34	1.6
+++ LVM2/lib/mm/memlock.h	2011/02/18 14:16:12	1.7
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
+void memlock_unlock(struct cmd_context *cmd);
 
 #endif


