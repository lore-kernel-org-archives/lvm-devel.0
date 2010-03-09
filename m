From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2010 03:16:12 -0000
Subject: LVM2/lib commands/toolcontext.c mm/memlock.c
Message-ID: <20100309031612.13667.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-09 03:16:11

Modified files:
	lib/commands   : toolcontext.c 
	lib/mm         : memlock.c 

Log message:
	Misc cleanups in the new mlock code, incl. improving some variable names
	& messages; using more statics (for now) to avoid redundant
	recalculation; validating config file just once on loading; keeping maps
	file open.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/lib/commands/toolcontext.c	2010/01/19 13:25:00	1.91
+++ LVM2/lib/commands/toolcontext.c	2010/03/09 03:16:11	1.92
@@ -201,6 +201,8 @@
 	mode_t old_umask;
 	const char *read_ahead;
 	struct stat st;
+	const struct config_node *cn;
+	struct config_value *cv;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -303,6 +305,11 @@
 						  "global/si_unit_consistency",
 						  DEFAULT_SI_UNIT_CONSISTENCY);
 
+	if ((cn = find_config_tree_node(cmd, "activation/mlock_filter")))
+		for (cv = cn->v; cv; cv = cv->next) 
+			if ((cv->type != CFG_STRING) || !cv->v.str[0]) 
+				log_error("Ignoring invalid activation/mlock_filter entry in config file");
+
 	return 1;
 }
 
--- LVM2/lib/mm/memlock.c	2010/03/08 17:14:21	1.19
+++ LVM2/lib/mm/memlock.c	2010/03/09 03:16:11	1.20
@@ -75,12 +75,17 @@
 
 typedef enum { LVM_MLOCK, LVM_MUNLOCK } lvmlock_t;
 
+static unsigned _use_mlockall;
+static FILE *_mapsh;
+static char _procselfmaps[PATH_MAX] = "";
+static const char _selfmaps[] = "/self/maps";
+
 struct maps_stats {
 	size_t r_size;
 	size_t w_size;
 	size_t x_size;
 };
-static struct maps_stats _ms; /* statistic for maps locking */
+static struct maps_stats _mstats; /* statistic for maps locking */
 
 static void _touch_memory(void *mem, size_t size)
 {
@@ -120,7 +125,7 @@
  * format described in kernel/Documentation/filesystem/proc.txt
  */
 static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
-		      const char* line, struct maps_stats* ms)
+		      const char* line, struct maps_stats* mstats)
 {
 	const struct config_node *cn;
 	struct config_value *cv;
@@ -145,27 +150,20 @@
 			return 1;
 
 	sz = to - from;
-	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
-		  (lock == LVM_MLOCK) ? "Mlock" : "Munlock",
-		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
-
 	if (!(cn = find_config_tree_node(cmd, "activation/mlock_filter"))) {
 		/* If no blacklist configured, use an internal set */
 		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
 			if (strstr(line + pos, _blacklist_maps[i])) {
-				log_debug("Filtered by string '%s' (%s)",
+				log_debug("mlock default filter '%s' matches '%s': Skipping.",
 					  _blacklist_maps[i], line);
 				return 1;
 			}
 	} else {
 		for (cv = cn->v; cv; cv = cv->next) {
-			if ((cv->type != CFG_STRING) || !cv->v.str[0]) {
-				log_error("Ignoring invalid string in config file "
-					  "activation/mlock_filter");
+			if ((cv->type != CFG_STRING) || !cv->v.str[0])
 				continue;
-			}
 			if (strstr(line + pos, cv->v.str)) {
-				log_debug("Filtered by string '%s' (%s)",
+				log_debug("mlock_filter '%s' matches '%s': Skipping.",
 					  cv->v.str, line);
 				return 1;
 			}
@@ -173,11 +171,15 @@
 	}
 
 	if (fr == 'r')
-		ms->r_size += sz;
+		mstats->r_size += sz;
 	if (fw == 'w')
-		ms->w_size += sz;
+		mstats->w_size += sz;
 	if (fx == 'x')
-		ms->x_size += sz;
+		mstats->x_size += sz;
+
+	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
+		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
+		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
 
 	if (lock == LVM_MLOCK) {
 		if (mlock((const void*)from, sz) < 0) {
@@ -194,18 +196,14 @@
 	return 1;
 }
 
-static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, struct maps_stats* ms)
+static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, struct maps_stats *mstats)
 {
-	static const char selfmaps[] = "/self/maps";
-	char *procselfmaps = alloca(strlen(cmd->proc_dir) + sizeof(selfmaps));
-	FILE *fh;
 	char *line = NULL;
 	size_t len;
-	ssize_t r;
+	ssize_t n;
 	int ret = 0;
 
-	if (find_config_tree_bool(cmd, "activation/use_mlockall",
-				  DEFAULT_USE_MLOCKALL)) {
+	if (_use_mlockall) {
 #ifdef MCL_CURRENT
 		if (lock == LVM_MLOCK) {
 			if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
@@ -224,25 +222,16 @@
 #endif
 	}
 
-	strcpy(procselfmaps, cmd->proc_dir);
-	strcat(procselfmaps, selfmaps);
-
-	if ((fh = fopen(procselfmaps, "r")) == NULL) {
-		log_sys_error("fopen", procselfmaps);
-		return 0;
-	}
-
-	while ((r = getline(&line, &len, fh)) != -1) {
-		line[r > 0 ? r - 1 : 0] = '\0'; /* remove \n */
-		if (!(ret = _maps_line(cmd, lock, line, ms)))
+	while ((n = getline(&line, &len, _mapsh)) != -1) {
+		line[n > 0 ? n - 1 : 0] = '\0'; /* remove \n */
+		if (!(ret = _maps_line(cmd, lock, line, mstats)))
 			break;
 	}
 
 	free(line);
-	fclose(fh);
 
-	log_debug("Mapped sizes:  r=%ld,  w=%ld,  x=%ld",
-		  (long)ms->r_size,  (long)ms->w_size, (long)ms->x_size);
+	log_debug("Mapped sizes: r=%ld, w=%ld, x=%ld",
+		  (long)mstats->r_size,  (long)mstats->w_size, (long)mstats->x_size);
 
 	return ret;
 }
@@ -252,9 +241,27 @@
 {
 	_allocate_memory();
 
-	memset(&_ms, 0, sizeof(_ms));
-	if (_memlock_maps(cmd, LVM_MLOCK, &_ms))
-		log_very_verbose("Locking memory");
+	_use_mlockall = find_config_tree_bool(cmd, "activation/use_mlockall", DEFAULT_USE_MLOCKALL);
+
+	if (!_use_mlockall) {
+		/* Initialise static variables first time */
+		memset(&_mstats, 0, sizeof(_mstats));
+
+		if (!*_procselfmaps) {
+			_procselfmaps[PATH_MAX - 1] = '\0';
+			strncpy(_procselfmaps, cmd->proc_dir, PATH_MAX - 1);
+			strncat(_procselfmaps, _selfmaps, PATH_MAX - 1);
+		}
+
+		if (!(_mapsh = fopen(_procselfmaps, "r"))) {
+			log_sys_error("fopen", _procselfmaps);
+			return;
+		}
+	}
+
+	log_very_verbose("Locking memory");
+	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
+		stack;
 
 	errno = 0;
 	if (((_priority = getpriority(PRIO_PROCESS, 0)) == -1) && errno)
@@ -267,15 +274,25 @@
 
 static void _unlock_mem(struct cmd_context *cmd)
 {
-	struct maps_stats ums = { 0 };
+	struct maps_stats unlock_mstats = { 0 };
+
+	log_very_verbose("Unlocking memory");
+
+	if (!_use_mlockall)
+		rewind(_mapsh);
 
-	if (_memlock_maps(cmd, LVM_MUNLOCK, &ums))
-		log_very_verbose("Unlocking memory");
+	if (!_memlock_maps(cmd, LVM_MUNLOCK, &unlock_mstats))
+		stack;
 
-	if (memcmp(&_ms, &ums, sizeof(ums)))
-		log_error(INTERNAL_ERROR "Maps size mismatch (%ld,%ld,%ld) != (%ld,%ld,%ld)",
-			  (long)_ms.r_size, (long)_ms.w_size, (long)_ms.x_size,
-			  (long)ums.r_size, (long)ums.w_size, (long)ums.x_size);
+	if (!_use_mlockall) {
+		if (fclose(_mapsh))
+			log_sys_error("fclose", _procselfmaps);
+
+		if (memcmp(&_mstats, &unlock_mstats, sizeof(unlock_mstats)))
+			log_error(INTERNAL_ERROR "Maps size mismatch (%ld,%ld,%ld) != (%ld,%ld,%ld)",
+				  (long)_mstats.r_size, (long)_mstats.w_size, (long)_mstats.x_size,
+				  (long)unlock_mstats.r_size, (long)unlock_mstats.w_size, (long)unlock_mstats.x_size);
+	}
 
 	_release_memory();
 	if (setpriority(PRIO_PROCESS, 0, _priority))


