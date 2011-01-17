From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jan 2011 23:13:15 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110117231315.21661.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-01-17 23:13:14

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c clvmd.c clvmd.h 
	man            : clvmd.8.in 

Log message:
	Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1883&r2=1.1884
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2011/01/17 18:16:18	1.1883
+++ LVM2/WHATS_NEW	2011/01/17 23:13:14	1.1884
@@ -1,5 +1,6 @@
 Version 2.02.82 -
 ===================================
+  Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
 
 Version 2.02.81 - 17th January 2011
 ===================================
--- LVM2/daemons/clvmd/clvmd-command.c	2011/01/12 20:42:50	1.47
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/01/17 23:13:14	1.48
@@ -63,7 +63,6 @@
 
 #include <sys/utsname.h>
 
-extern debug_t debug;
 extern struct cluster_ops *clops;
 static int restart_clvmd(void);
 
@@ -144,7 +143,7 @@
 		break;
 
 	case CLVMD_CMD_SET_DEBUG:
-		debug = args[0];
+		clvmd_set_debug(args[0]);
 		break;
 
 	case CLVMD_CMD_RESTART:
@@ -310,19 +309,16 @@
 		client->bits.localsock.private = 0;
 		break;
 
-	case CLVMD_CMD_LOCK_VG:
-	case CLVMD_CMD_VG_BACKUP:
-	case CLVMD_CMD_SYNC_NAMES:
-	case CLVMD_CMD_LOCK_QUERY:
-		/* Nothing to do here */
-		break;
-
 	case CLVMD_CMD_LOCK_LV:
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
 		status = post_lock_lv(lock_cmd, lock_flags, lockname);
 		break;
+
+	default:
+		/* Nothing to do here */
+		break;
 	}
 	return status;
 }
@@ -381,9 +377,9 @@
 		goto_out;
 
 	/* Propogate debug options */
-	if (debug) {
+	if (clvmd_get_debug()) {
 		if (!(debug_arg = malloc(16)) ||
-		    dm_snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
+		    dm_snprintf(debug_arg, 16, "-d%d", (int)clvmd_get_debug()) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
 	}
--- LVM2/daemons/clvmd/clvmd.c	2011/01/05 12:17:19	1.92
+++ LVM2/daemons/clvmd/clvmd.c	2011/01/17 23:13:14	1.93
@@ -81,7 +81,8 @@
 	char **argv;
 };
 
-debug_t debug;
+static debug_t debug = DEBUG_OFF;
+static int foreground_mode = 0;
 static pthread_t lvm_thread;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
@@ -145,12 +146,11 @@
 
 static void usage(const char *prog, FILE *file)
 {
-	fprintf(file, "Usage:\n"
-		"%s [Vhd]\n\n"
+	fprintf(file, "Usage: %s [options]\n"
 		"   -V       Show version of clvmd\n"
 		"   -h       Show this help information\n"
-		"   -d       Set debug level\n"
-		"            If starting clvmd then don't fork, run in the foreground\n"
+		"   -d[n]    Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
+		"   -f       Don't fork, run in the foreground\n"
 		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
 		"   -S       Restart clvmd, preserving exclusive locks\n"
 		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
@@ -209,14 +209,15 @@
 	va_list ap;
 	static int syslog_init = 0;
 
-	if (debug == DEBUG_STDERR) {
+	switch (clvmd_get_debug()) {
+	case DEBUG_STDERR:
 		va_start(ap,fmt);
 		time(&P);
 		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 );
 		vfprintf(stderr, fmt, ap);
 		va_end(ap);
-	}
-	if (debug == DEBUG_SYSLOG) {
+		break;
+	case DEBUG_SYSLOG:
 		if (!syslog_init) {
 			openlog("clvmd", LOG_PID, LOG_DAEMON);
 			syslog_init = 1;
@@ -225,9 +226,28 @@
 		va_start(ap,fmt);
 		vsyslog(LOG_DEBUG, fmt, ap);
 		va_end(ap);
+		break;
+	case DEBUG_OFF:
+		break;
 	}
 }
 
+void clvmd_set_debug(debug_t new_debug)
+{
+	if (!foreground_mode && new_debug == DEBUG_STDERR)
+		new_debug = DEBUG_SYSLOG;
+
+	if (new_debug > DEBUG_SYSLOG)
+		new_debug = DEBUG_SYSLOG;
+
+	debug = new_debug;
+}
+
+debug_t clvmd_get_debug(void)
+{
+	return debug;
+}
+
 static const char *decode_cmd(unsigned char cmdl)
 {
 	static char buf[128];
@@ -322,13 +342,14 @@
 	sigset_t ss;
 	int using_gulm = 0;
 	int debug_opt = 0;
+	debug_t debug_arg = DEBUG_OFF;
 	int clusterwide_opt = 0;
 	mode_t old_mask;
 
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhd::t:RST:CI:E:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?vVhfd::t:RST:CI:E:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -352,12 +373,14 @@
 
 		case 'd':
 			debug_opt = 1;
-			if (optarg)
-				debug = atoi(optarg);
-			else
-				debug = DEBUG_STDERR;
+			debug_arg = optarg ? atoi(optarg) : DEBUG_STDERR;
+			if (debug_arg == DEBUG_STDERR)
+				foreground_mode = 1;
 			break;
 
+		case 'f':
+			foreground_mode = 1;
+			break;
 		case 't':
 			cmd_timeout = atoi(optarg);
 			if (!cmd_timeout) {
@@ -391,15 +414,6 @@
 
 	check_permissions();
 
-	/* Setting debug options on an existing clvmd */
-	if (debug_opt && !check_local_clvmd()) {
-
-		/* Sending to stderr makes no sense for a detached daemon */
-		if (debug == DEBUG_STDERR)
-			debug = DEBUG_SYSLOG;
-		return debug_clvmd(debug, clusterwide_opt)==1?0:1;
-	}
-
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file
 	 * used by some glibc (on some distributions it takes over 100MB).
@@ -408,10 +422,15 @@
 	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
+	/* Setting debug options on an existing clvmd */
+	if (debug_opt && !check_local_clvmd())
+		return debug_clvmd(debug_arg, clusterwide_opt)==1?0:1;
+
+	clvmd_set_debug(debug_opt);
+
 	/* Fork into the background (unless requested not to) */
-	if (debug != DEBUG_STDERR) {
+	if (!foreground_mode)
 		be_daemon(start_timeout);
-	}
 
         dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
         old_mask = umask(0077);
--- LVM2/daemons/clvmd/clvmd.h	2010/07/28 13:55:43	1.12
+++ LVM2/daemons/clvmd/clvmd.h	2011/01/17 23:13:14	1.13
@@ -117,6 +117,9 @@
 extern void debuglog(const char *fmt, ... )
   __attribute__ ((format(printf, 1, 2)));
 
+void clvmd_set_debug(debug_t new_de);
+debug_t clvmd_get_debug(void);
+
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
 int sync_unlock(const char *resource, int lockid);
 
--- LVM2/man/clvmd.8.in	2010/04/30 14:49:44	1.4
+++ LVM2/man/clvmd.8.in	2011/01/17 23:13:14	1.5
@@ -3,7 +3,7 @@
 clvmd \- cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
-[\-d [<value>]] [\-C] [\-h]
+[\-d[<value>]] [\-C] [\-h]
 [\-R]
 [\-S]
 [\-t <timeout>]
@@ -15,19 +15,18 @@
 if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
-.I \-d [<value>]
+.I \-d[<value>]
 Enable debug logging. Value can be 0, 1 or 2.
 .br
-0 disables debug logging in a running clvmd
+0 disables debug logging
 .br
-1 sends debug logs to stderr (clvmd will not fork in this case)
+1 sends debug logs to stderr (implies -f option)
 .br
 2 sends debug logs to syslog
 .br
 If 
 .B -d 
-is specified without a value then 1 is assumed if you are starting a
-new clvmd, 2 if you are enabling debug in a running clvmd.
+is specified without a value then 1 is assumed.
 .TP
 .I \-C
 Only valid if 


