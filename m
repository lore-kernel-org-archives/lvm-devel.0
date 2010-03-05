From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2010 14:48:36 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/activate ...
Message-ID: <20100305144836.4339.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-05 14:48:34

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/activate   : activate.c 
	lib/config     : defaults.h 
	lib/locking    : locking.c 
	lib/mm         : memlock.c memlock.h 
	tools          : lvmcmdlib.c 

Log message:
	mlockall() -> mlock()
	
	This patch adds a new implementation of locking function instead
	of mlockall() that may lock way too much memory (>100MB).
	New function instead uses mlock() system call and selectively locks
	memory areas from /proc/self/maps trying to avoid locking areas
	unused during lock-ed state.
	
	Patch also adds struct cmd_context to all memlock() calls to have
	access to configuration.
	
	For backward compatibility functionality of mlockall()
	is preserved with "activation/use_mlockall" flag.
	
	As a simple check, locking and unlocking counts the amount of memory
	and compares whether values are matching.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1454&r2=1.1455
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2010/03/04 12:12:34	1.1454
+++ LVM2/WHATS_NEW	2010/03/05 14:48:33	1.1455
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Reimplement mlockall() with mlock() to reduce mmaped memory size.
   Define and use internal makefile variable UDEV_LIBS.
   Define and use internal makefile variable DL_LIBS.
   Update check for selinux libraries and link them only when needed.
--- LVM2/doc/example.conf	2010/01/07 19:54:21	1.54
+++ LVM2/doc/example.conf	2010/03/05 14:48:33	1.55
@@ -413,6 +413,21 @@
 
     mirror_log_fault_policy = "allocate"
     mirror_image_fault_policy = "remove"
+
+    # While activating devices, I/O to devices being (re)configured is
+    # suspended, and as a precaution against deadlocks, LVM2 needs to pin
+    # any memory it is using so it is not paged out.  Groups of pages that
+    # are known not to be accessed during activation need not be pinned
+    # into memory.  Each string listed in this setting is compared against
+    # each line in /proc/self/maps, and the pages corresponding to any
+    # lines that match are not pinned.  On some systems locale-archive was
+    # found to make up over 80% of the memory used by the process.
+    # mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
+
+    # Set to 1 to revert to the default behaviour prior to version 2.02.62
+    # which used mlockall() to pin the whole process's memory while activating
+    # devices.
+    # use_mlockall = 0
 }
 
 
--- LVM2/lib/activate/activate.c	2010/02/24 20:01:41	1.166
+++ LVM2/lib/activate/activate.c	2010/03/05 14:48:34	1.167
@@ -849,7 +849,7 @@
 		if (!error_if_not_suspended) {
 			r = 1;
 			if (info.suspended)
-				memlock_inc();
+				memlock_inc(cmd);
 		}
 		goto out;
 	}
@@ -868,13 +868,13 @@
 		/* FIXME Consider aborting here */
 		stack;
 
-	memlock_inc();
+	memlock_inc(cmd);
 
 	if (lv_is_origin(lv_pre) || lv_is_cow(lv_pre))
 		lockfs = 1;
 
 	if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
-		memlock_dec();
+		memlock_dec(cmd);
 		fs_unlock();
 		goto out;
 	}
@@ -930,7 +930,7 @@
 	if (!_lv_activate_lv(lv))
 		goto_out;
 
-	memlock_dec();
+	memlock_dec(cmd);
 	fs_unlock();
 
 	if (!monitor_dev_for_events(cmd, lv, 1))
@@ -1019,9 +1019,9 @@
 	if (!monitor_dev_for_events(cmd, lv, 0))
 		stack;
 
-	memlock_inc();
+	memlock_inc(cmd);
 	r = _lv_deactivate(lv);
-	memlock_dec();
+	memlock_dec(cmd);
 	fs_unlock();
 
 	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
@@ -1112,10 +1112,10 @@
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
-	memlock_inc();
+	memlock_inc(cmd);
 	if (!(r = _lv_activate_lv(lv)))
 		stack;
-	memlock_dec();
+	memlock_dec(cmd);
 	fs_unlock();
 
 	if (r && !monitor_dev_for_events(cmd, lv, 1))
--- LVM2/lib/config/defaults.h	2010/01/07 19:54:22	1.58
+++ LVM2/lib/config/defaults.h	2010/03/05 14:48:34	1.59
@@ -43,6 +43,7 @@
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
+#define DEFAULT_USE_MLOCKALL 0
 
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
--- LVM2/lib/locking/locking.c	2010/02/15 16:46:56	1.74
+++ LVM2/lib/locking/locking.c	2010/03/05 14:48:34	1.75
@@ -161,22 +161,22 @@
 	_signals_blocked = 0;
 }
 
-static void _lock_memory(lv_operation_t lv_op)
+static void _lock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
 
 	if (lv_op == LV_SUSPEND)
-		memlock_inc();
+		memlock_inc(cmd);
 }
 
-static void _unlock_memory(lv_operation_t lv_op)
+static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
 
 	if (lv_op == LV_RESUME)
-		memlock_dec();
+		memlock_dec(cmd);
 }
 
 void reset_locking(void)
@@ -363,7 +363,7 @@
 	int ret = 0;
 
 	_block_signals(flags);
-	_lock_memory(lv_op);
+	_lock_memory(cmd, lv_op);
 
 	assert(resource);
 
@@ -390,7 +390,7 @@
 		_update_vg_lock_count(resource, flags);
 	}
 
-	_unlock_memory(lv_op);
+	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
 
 	return ret;
--- LVM2/lib/mm/memlock.c	2009/12/16 19:22:12	1.15
+++ LVM2/lib/mm/memlock.c	2010/03/05 14:48:34	1.16
@@ -28,11 +28,11 @@
 
 #ifndef DEVMAPPER_SUPPORT
 
-void memlock_inc(void)
+void memlock_inc(struct cmd_context *cmd)
 {
 	return;
 }
-void memlock_dec(void)
+void memlock_dec(struct cmd_context *cmd)
 {
 	return;
 }
@@ -57,6 +57,30 @@
 static int _priority;
 static int _default_priority;
 
+/* list of maps, that are unconditionaly ignored */
+static const char * const _ignore_maps[] = {
+    "[vsyscall]"
+};
+
+/* default blacklist for maps */
+static const char * const _blacklist_maps[] = {
+    "locale/locale-archive",
+    "gconv/gconv-modules.cache",
+    "/libreadline.so.",	/* not using readline during mlock */
+    "/libncurses.so.",	/* not using readline during mlock */
+    "/libdl-",		/* not using dlopen,dlsym during mlock */
+    /* "/libdevmapper-event.so" */
+};
+
+typedef enum { LVM_MLOCK, LVM_MUNLOCK } lvmlock_t;
+
+struct maps_stats {
+	size_t r_size;
+	size_t w_size;
+	size_t x_size;
+};
+static struct maps_stats ms; /* statistic for maps locking */
+
 static void _touch_memory(void *mem, size_t size)
 {
 	size_t pagesize = lvm_getpagesize();
@@ -90,17 +114,147 @@
 	free(_malloc_mem);
 }
 
-/* Stop memory getting swapped out */
-static void _lock_mem(void)
+/*
+ * mlock/munlock memory areas from /proc/self/maps
+ * format described in kernel/Documentation/filesystem/proc.txt
+ */
+static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
+		      const char* line, struct maps_stats* ms)
 {
+	const struct config_node *cn;
+	struct config_value *cv;
+	long from, to;
+	int pos, i;
+	char fr, fw, fx, fp;
+	size_t sz;
+
+	if (sscanf(line, "%lx-%lx %c%c%c%c%n",
+		   &from, &to, &fr, &fw, &fx, &fp, &pos) != 6) {
+		log_error("Failed to parse maps line: %s", line);
+		return 0;
+	}
+
+	/* skip  ---p,  select with r,w,x */
+	if (fr != 'r' && fw != 'w' && fx != 'x')
+		return 1;
+
+	/* always ignored areas */
+	for (i = 0; i < sizeof(_ignore_maps) / sizeof(_ignore_maps[0]); ++i)
+		if (strstr(line + pos, _ignore_maps[i]))
+			return 1;
+
+	sz = to - from;
+	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
+		  (lock == LVM_MLOCK) ? "Mlock" : "Munlock",
+		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
+
+	if (!(cn = find_config_tree_node(cmd, "activation/mlock_filter"))) {
+		/* If no blacklist configured, use an internal set */
+		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
+			if (strstr(line + pos, _blacklist_maps[i])) {
+				log_debug("Filtered by string '%s' (%s)",
+					  _blacklist_maps[i], line);
+				return 1;
+			}
+	} else {
+		for (cv = cn->v; cv; cv = cv->next) {
+			if ((cv->type != CFG_STRING) || !cv->v.str[0]) {
+				log_error("Ignoring invalid string in config file "
+					  "activation/mlock_filter");
+				continue;
+			}
+			if (strstr(line + pos, cv->v.str)) {
+				log_debug("Filtered by string '%s' (%s)",
+					  cv->v.str, line);
+				return 1;
+			}
+		}
+	}
+
+	if (fr == 'r')
+		ms->r_size += sz;
+	if (fw == 'w')
+		ms->w_size += sz;
+	if (fx == 'x')
+		ms->x_size += sz;
+
+	if (lock == LVM_MLOCK) {
+		if (mlock((const void*)from, sz) < 0) {
+			log_sys_error("mlock", line);
+			return 0;
+		}
+	} else {
+		if (munlock((const void*)from, sz) < 0) {
+			log_sys_error("munlock", line);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, struct maps_stats* ms)
+{
+	static const char selfmaps[] = "/self/maps";
+	char *procselfmaps = alloca(strlen(cmd->proc_dir) + sizeof(selfmaps));
+	FILE *fh;
+	char *line = NULL;
+	size_t len;
+	ssize_t r;
+	int ret = 0;
+
+	if (find_config_tree_bool(cmd, "activation/use_mlockall",
+				  DEFAULT_USE_MLOCKALL)) {
 #ifdef MCL_CURRENT
-	if (mlockall(MCL_CURRENT | MCL_FUTURE))
-		log_sys_error("mlockall", "");
-	else
-		log_very_verbose("Locking memory");
+		if (lock == LVM_MLOCK) {
+			if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
+				log_sys_error("mlockall", "");
+				return 0;
+			}
+		} else {
+			if (munlockall()) {
+				log_sys_error("munlockall", "");
+				return 0;
+			}
+		}
+		return 1;
+#else
+		return 0;
 #endif
+	}
+
+	strcpy(procselfmaps, cmd->proc_dir);
+	strcat(procselfmaps, selfmaps);
+
+	if ((fh = fopen(procselfmaps, "r")) == NULL) {
+		log_sys_error("fopen", procselfmaps);
+		return 0;
+	}
+
+	while ((r = getline(&line, &len, fh)) != -1) {
+		line[r > 0 ? r - 1 : 0] = '\0'; /* remove \n */
+		if (!(ret = _maps_line(cmd, lock, line, ms)))
+			break;
+	}
+
+	free(line);
+	fclose(fh);
+
+	log_debug("Mapped sizes:  r=%ld,  w=%ld,  x=%ld",
+		  (long)ms->r_size,  (long)ms->w_size, (long)ms->x_size);
+
+	return ret;
+}
+
+/* Stop memory getting swapped out */
+static void _lock_mem(struct cmd_context *cmd)
+{
 	_allocate_memory();
 
+	memset(&ms, 0, sizeof(ms));
+	if (_memlock_maps(cmd, LVM_MLOCK, &ms))
+		log_very_verbose("Locking memory");
+
 	errno = 0;
 	if (((_priority = getpriority(PRIO_PROCESS, 0)) == -1) && errno)
 		log_sys_error("getpriority", "");
@@ -110,43 +264,47 @@
 				  _default_priority, strerror(errno));
 }
 
-static void _unlock_mem(void)
+static void _unlock_mem(struct cmd_context *cmd)
 {
-#ifdef MCL_CURRENT
-	if (munlockall())
-		log_sys_error("munlockall", "");
-	else
+	struct maps_stats ums = { 0 };
+
+	if (_memlock_maps(cmd, LVM_MUNLOCK, &ums))
 		log_very_verbose("Unlocking memory");
-#endif
+
+	if (memcmp(&ms, &ums, sizeof(ms)))
+		log_error(INTERNAL_ERROR "Maps size mismatch (%ld,%ld,%ld) != (%ld,%ld,%ld)",
+			  (long)ms.r_size,  (long)ms.w_size, (long)ms.x_size,
+			  (long)ums.r_size, (long)ums.w_size, (long)ums.x_size);
+
 	_release_memory();
 	if (setpriority(PRIO_PROCESS, 0, _priority))
 		log_error("setpriority %u failed: %s", _priority,
 			  strerror(errno));
 }
 
-static void _lock_mem_if_needed(void) {
+static void _lock_mem_if_needed(struct cmd_context *cmd) {
 	if ((_memlock_count + _memlock_count_daemon) == 1)
-		_lock_mem();
+		_lock_mem(cmd);
 }
 
-static void _unlock_mem_if_possible(void) {
+static void _unlock_mem_if_possible(struct cmd_context *cmd) {
 	if ((_memlock_count + _memlock_count_daemon) == 0)
-		_unlock_mem();
+		_unlock_mem(cmd);
 }
 
-void memlock_inc(void)
+void memlock_inc(struct cmd_context *cmd)
 {
 	++_memlock_count;
-	_lock_mem_if_needed();
+	_lock_mem_if_needed(cmd);
 	log_debug("memlock_count inc to %d", _memlock_count);
 }
 
-void memlock_dec(void)
+void memlock_dec(struct cmd_context *cmd)
 {
 	if (!_memlock_count)
 		log_error(INTERNAL_ERROR "_memlock_count has dropped below 0.");
 	--_memlock_count;
-	_unlock_mem_if_possible();
+	_unlock_mem_if_possible(cmd);
 	log_debug("memlock_count dec to %d", _memlock_count);
 }
 
@@ -157,19 +315,19 @@
  * of memlock or memlock_daemon is in effect.
  */
 
-void memlock_inc_daemon(void)
+void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	++_memlock_count_daemon;
-	_lock_mem_if_needed();
+	_lock_mem_if_needed(cmd);
 	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
 }
 
-void memlock_dec_daemon(void)
+void memlock_dec_daemon(struct cmd_context *cmd)
 {
 	if (!_memlock_count_daemon)
 		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
-	_unlock_mem_if_possible();
+	_unlock_mem_if_possible(cmd);
 	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
 }
 
--- LVM2/lib/mm/memlock.h	2009/11/19 01:11:57	1.5
+++ LVM2/lib/mm/memlock.h	2010/03/05 14:48:34	1.6
@@ -18,10 +18,10 @@
 
 struct cmd_context;
 
-void memlock_inc(void);
-void memlock_dec(void);
-void memlock_inc_daemon(void);
-void memlock_dec_daemon(void);
+void memlock_inc(struct cmd_context *cmd);
+void memlock_dec(struct cmd_context *cmd);
+void memlock_inc_daemon(struct cmd_context *cmd);
+void memlock_dec_daemon(struct cmd_context *cmd);
 int memlock(void);
 void memlock_init(struct cmd_context *cmd);
 
--- LVM2/tools/lvmcmdlib.c	2009/12/11 13:16:39	1.11
+++ LVM2/tools/lvmcmdlib.c	2010/03/05 14:48:34	1.12
@@ -82,9 +82,9 @@
 	/* FIXME Temporary - move to libdevmapper */
 	ret = ECMD_PROCESSED;
 	if (!strcmp(cmdline, "_memlock_inc"))
-		memlock_inc_daemon();
+		memlock_inc_daemon(cmd);
 	else if (!strcmp(cmdline, "_memlock_dec"))
-		memlock_dec_daemon();
+		memlock_dec_daemon(cmd);
 	else
 		ret = lvm_run_command(cmd, argc, argv);
 


