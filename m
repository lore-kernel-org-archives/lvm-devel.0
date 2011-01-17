From: Milan Broz <mbroz@redhat.com>
Date: Mon, 17 Jan 2011 20:33:54 +0100
Subject: [PATCH] Add -f (do not fork) option to clvmd.
Message-ID: <1295292835-7181-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently -d option is overloaded and controls forking too.

After the patch:
- daemon mode is controlled by f option
- log mode is controlled by -d option.

0 means no debug log, 1 steerr if running in foreground, 2 means syslog.

Patch also removes duplicate global debug variable and uses one defined
in clvmd.c.

Patch also fixes documentation, format od -d option is strictly -d[num]
(no space allowed).

Also removes some defines from do_postcommand (set_debug missing here)
Check for unknown command is already done in pre call, no need to do ti
here again.

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=596352
---
 daemons/clvmd/clvmd-command.c |   18 ++++------
 daemons/clvmd/clvmd.c         |   68 +++++++++++++++++++++++++++--------------
 daemons/clvmd/clvmd.h         |    3 ++
 man/clvmd.8.in                |   11 +++---
 test/lib/aux.sh               |    2 +-
 5 files changed, 61 insertions(+), 41 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index eee5bc3..2576dcf 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -63,7 +63,6 @@
 
 #include <sys/utsname.h>
 
-extern debug_t debug;
 extern struct cluster_ops *clops;
 static int restart_clvmd(void);
 
@@ -144,7 +143,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		break;
 
 	case CLVMD_CMD_SET_DEBUG:
-		debug = args[0];
+		clvmd_set_debug(args[0]);
 		break;
 
 	case CLVMD_CMD_RESTART:
@@ -310,19 +309,16 @@ int do_post_command(struct local_client *client)
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
@@ -381,9 +377,9 @@ static int restart_clvmd(void)
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
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index fb1b461..799ac21 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -81,7 +81,8 @@ struct lvm_startup_params {
 	char **argv;
 };
 
-debug_t debug;
+static debug_t debug = DEBUG_OFF;
+static int foreground_mode = 0;
 static pthread_t lvm_thread;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
@@ -145,12 +146,11 @@ static if_type_t get_cluster_type(void);
 
 static void usage(const char *prog, FILE *file)
 {
-	fprintf(file, "Usage:\n"
-		"%s [Vhd]\n\n"
+	fprintf(file, "Usage: %s [options]\n"
 		"   -V       Show version of clvmd\n"
 		"   -h       Show this help information\n"
-		"   -d       Set debug level\n"
-		"            If starting clvmd then don't fork, run in the foreground\n"
+		"   -d[n]    Set debug logging (0:none, 1:stderr (-f required), 2:syslog)\n"
+		"   -f       Don't fork, run in the foreground\n"
 		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
 		"   -S       Restart clvmd, preserving exclusive locks\n"
 		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
@@ -209,14 +209,15 @@ void debuglog(const char *fmt, ...)
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
@@ -225,9 +226,28 @@ void debuglog(const char *fmt, ...)
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
@@ -322,13 +342,14 @@ int main(int argc, char *argv[])
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
@@ -352,12 +373,12 @@ int main(int argc, char *argv[])
 
 		case 'd':
 			debug_opt = 1;
-			if (optarg)
-				debug = atoi(optarg);
-			else
-				debug = DEBUG_STDERR;
+			debug_arg = optarg ? atoi(optarg) : DEBUG_STDERR;
 			break;
 
+		case 'f':
+			foreground_mode = 1;
+			break;
 		case 't':
 			cmd_timeout = atoi(optarg);
 			if (!cmd_timeout) {
@@ -391,15 +412,6 @@ int main(int argc, char *argv[])
 
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
@@ -408,8 +420,18 @@ int main(int argc, char *argv[])
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
+	if (!foreground_mode) {
+		/* Foreground option was implicit, better warn user */
+		if (debug_arg == DEBUG_STDERR)
+			fprintf(stderr, "Using syslog instead of stderr in daemon mode "
+					"(use -f to run in foreground).\n");
 		be_daemon(start_timeout);
 	}
 
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index ccc79cc..95244e1 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -117,6 +117,9 @@ extern void process_message(struct local_client *client, const char *buf,
 extern void debuglog(const char *fmt, ... )
   __attribute__ ((format(printf, 1, 2)));
 
+void clvmd_set_debug(debug_t new_de);
+debug_t clvmd_get_debug(void);
+
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
 int sync_unlock(const char *resource, int lockid);
 
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 53a9113..c6353d3 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -3,7 +3,7 @@
 clvmd \- cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
-[\-d [<value>]] [\-C] [\-h]
+[\-d[<value>]] [\-C] [\-h]
 [\-R]
 [\-S]
 [\-t <timeout>]
@@ -15,19 +15,18 @@ It must be running on all nodes in the cluster and will give an error
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
+1 sends debug logs to stderr (to syslog in daemon mode)
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
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 04367ea..6dc3824 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -28,7 +28,7 @@ prepare_clvmd() {
 
 	lvmconf "activation/monitoring = 1"
 
-	clvmd -Isinglenode -d 1 &
+	clvmd -Isinglenode -d 1 -f &
 	LOCAL_CLVMD="$!"
 
 	# check that it is really running now
-- 
1.7.2.3


