From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Aug 2011 11:00:32 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20110810110032.18699.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-10 11:00:32

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Initialise clvmd locks before lvm context to avoid open descriptor leaks.
	
	(At least /dev/mapper/control is open after lvm context init.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2054&r2=1.2055
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2011/08/09 18:11:00	1.2054
+++ LVM2/WHATS_NEW	2011/08/10 11:00:32	1.2055
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Initialise clvmd locks before lvm context to avoid open descriptor leaks.
   Remove obsoleted GULM clvmd cluster locking support.
   Suppress low-level locking errors and warnings while using --sysinit.
   Remove unused inconsistent_seqno variable in _vg_read().
--- LVM2/daemons/clvmd/lvm-functions.c	2011/08/09 18:11:00	1.120
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/08/10 11:00:32	1.121
@@ -721,7 +721,7 @@
  * but this may not be the case...
  * I suppose this also comes in handy if clvmd crashes, not that it would!
  */
-static void *get_initial_state(char **argv)
+static int get_initial_state(char **argv)
 {
 	int lock_mode;
 	char lv[64], vg[64], flags[25], vg_flags[25];
@@ -733,7 +733,7 @@
 	     "r");
 
 	if (!lvs)
-		return NULL;
+		return 1;
 
 	while (fgets(line, sizeof(line), lvs)) {
 	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
@@ -773,7 +773,7 @@
 	}
 	if (fclose(lvs))
 		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
-	return NULL;
+	return 0;
 }
 
 static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
@@ -886,6 +886,10 @@
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 
+	/* Initialise already held locks */
+	if (get_initial_state(argv))
+		log_error("Cannot load initial lock states.");
+
 	if (!(cmd = create_toolcontext(1, NULL, 0))) {
 		log_error("Failed to allocate command context");
 		return 0;
@@ -902,8 +906,6 @@
 	check_config();
 	init_ignore_suspended_devices(1);
 
-	get_initial_state(argv);
-
 	/* Trap log messages so we can pass them back to the user */
 	init_log_fn(lvm2_log_fn);
 	memlock_inc_daemon(cmd);


