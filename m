From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:41:23 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100330144123.19431.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:41:23

Modified files:
	lib/mm         : memlock.c 

Log message:
	Update memlock
	
	Code moves initilization of stats values to _memlock_maps().
	For dmeventd we need to use mlockall() - so avoid reading config value
	and go with _use_mlockall code path.
	
	Patch assumes dmeventd uses C locales!
	Patch needs the call or memlock_inc_daemon() before memlock_inc()
	(which is our common use case).
	
	Some minor code cleanup patch for _un/_lock_mem_if_needed().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/mm/memlock.c	2010/03/09 12:31:51	1.22
+++ LVM2/lib/mm/memlock.c	2010/03/30 14:41:23	1.23
@@ -227,6 +227,10 @@
 #endif
 	}
 
+	/* Reset statistic counters */
+	memset(mstats, 0, sizeof(*mstats));
+	rewind(_mapsh);
+
 	while ((n = getline(&line, &len, _mapsh)) != -1) {
 		line[n > 0 ? n - 1 : 0] = '\0'; /* remove \n */
 		if (!(ret = _maps_line(cmd, lock, line, mstats)))
@@ -246,12 +250,16 @@
 {
 	_allocate_memory();
 
-	_use_mlockall = find_config_tree_bool(cmd, "activation/use_mlockall", DEFAULT_USE_MLOCKALL);
+	/*
+	 * For daemon we need to use mlockall()
+	 * so even future adition of thread which may not even use lvm lib
+	 * will not block memory locked thread
+	 * Note: assuming _memlock_count_daemon is updated before _memlock_count
+         */
+	_use_mlockall = _memlock_count_daemon ? 1 :
+		find_config_tree_bool(cmd, "activation/use_mlockall", DEFAULT_USE_MLOCKALL);
 
 	if (!_use_mlockall) {
-		/* Reset statistic counters */
-		memset(&_mstats, 0, sizeof(_mstats));
-
 		if (!*_procselfmaps &&
 		    dm_snprintf(_procselfmaps, sizeof(_procselfmaps),
 				"%s" SELF_MAPS, cmd->proc_dir) < 0) {
@@ -280,13 +288,10 @@
 
 static void _unlock_mem(struct cmd_context *cmd)
 {
-	struct maps_stats unlock_mstats = { 0 };
+	struct maps_stats unlock_mstats;
 
 	log_very_verbose("Unlocking memory");
 
-	if (!_use_mlockall)
-		rewind(_mapsh);
-
 	if (!_memlock_maps(cmd, LVM_MUNLOCK, &unlock_mstats))
 		stack;
 
@@ -294,24 +299,26 @@
 		if (fclose(_mapsh))
 			log_sys_error("fclose", _procselfmaps);
 
-		if (memcmp(&_mstats, &unlock_mstats, sizeof(unlock_mstats)))
-			log_error(INTERNAL_ERROR "Maps size mismatch (%ld,%ld,%ld) != (%ld,%ld,%ld)",
+		if (_mstats.r_size < unlock_mstats.r_size)
+			log_error(INTERNAL_ERROR "Maps lock(%ld,%ld,%ld) < unlock(%ld,%ld,%ld)",
 				  (long)_mstats.r_size, (long)_mstats.w_size, (long)_mstats.x_size,
 				  (long)unlock_mstats.r_size, (long)unlock_mstats.w_size, (long)unlock_mstats.x_size);
 	}
 
-	_release_memory();
 	if (setpriority(PRIO_PROCESS, 0, _priority))
 		log_error("setpriority %u failed: %s", _priority,
 			  strerror(errno));
+	_release_memory();
 }
 
-static void _lock_mem_if_needed(struct cmd_context *cmd) {
+static void _lock_mem_if_needed(struct cmd_context *cmd)
+{
 	if ((_memlock_count + _memlock_count_daemon) == 1)
 		_lock_mem(cmd);
 }
 
-static void _unlock_mem_if_possible(struct cmd_context *cmd) {
+static void _unlock_mem_if_possible(struct cmd_context *cmd)
+{
 	if ((_memlock_count + _memlock_count_daemon) == 0)
 		_unlock_mem(cmd);
 }
@@ -342,6 +349,8 @@
 void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	++_memlock_count_daemon;
+	if (_memlock_count_daemon == 1 && _memlock_count > 0)
+                log_error(INTERNAL_ERROR "_memlock_inc_daemon used after _memlock_inc.");
 	_lock_mem_if_needed(cmd);
 	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
 }


