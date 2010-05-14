From: agk@sourceware.org <agk@sourceware.org>
Date: 14 May 2010 14:56:40 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd. ...
Message-ID: <20100514145640.17416.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-14 14:56:40

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	test           : test-utils.sh 

Log message:
	Use -d to control level of messages sent to syslog by dmeventd.
	Change -d to -f to run dmeventd in foreground.
	(mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.368&r2=1.369
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW_DM	2010/05/13 13:31:30	1.368
+++ LVM2/WHATS_NEW_DM	2010/05/14 14:56:39	1.369
@@ -1,5 +1,7 @@
 Version 1.02.48 -
 =================================
+  Use -d to control level of messages sent to syslog by dmeventd.
+  Change -d to -f to run dmeventd in foreground.
   Do not print encryption key in message debug output (cryptsetup luksResume).
 
 Version 1.02.47 - 30th April 2010
--- LVM2/daemons/dmeventd/dmeventd.c	2010/04/14 18:54:37	1.61
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/05/14 14:56:39	1.62
@@ -54,7 +54,6 @@
 
 static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given to exit */
 static volatile sig_atomic_t _thread_registries_empty = 1;	/* registries are empty initially */
-static int _debug = 0;
 
 /* List (un)link macros. */
 #define	LINK(x, head)		dm_list_add(head, &(x)->list)
@@ -98,6 +97,9 @@
 
 #define DEBUGLOG(fmt, args...) _debuglog(fmt, ## args)
 
+int dmeventd_debug = 0;
+static int _foreground = 0;
+
 /* Data kept about a DSO. */
 struct dso_data {
 	struct dm_list list;
@@ -204,7 +206,7 @@
         time_t P;
         va_list ap;
  
-        if (!_debug)
+        if (!_foreground)
                 return;
  
         va_start(ap,fmt);
@@ -1662,11 +1664,12 @@
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n");
-	fprintf(file, "%s [Vhd]\n", prog);
+	fprintf(file, "%s [-V] [-h] [-d] [-d] [-d] [-f]\n", prog);
 	fprintf(file, "\n");
 	fprintf(file, "   -V       Show version of dmeventd\n");
 	fprintf(file, "   -h       Show this help information\n");
-	fprintf(file, "   -d       Don't fork, run in the foreground\n");
+	fprintf(file, "   -d       Log debug messages to syslog (-d, -dd, -ddd)\n");
+	fprintf(file, "   -f       Don't fork, run in the foreground\n");
 	fprintf(file, "\n");
 }
 
@@ -1680,7 +1683,7 @@
 	opterr = 0;
 	optind = 0;
 
-	while ((opt = getopt(argc, argv, "?hVd")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVd")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1688,8 +1691,11 @@
 		case '?':
 			usage(argv[0], stderr);
 			exit(0);
+		case 'f':
+			_foreground++;
+			break;
 		case 'd':
-			_debug++;
+			dmeventd_debug++;
 			break;
 		case 'V':
 			printf("dmeventd version: %s\n", DM_LIB_VERSION);
@@ -1706,7 +1712,7 @@
 	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
-	if (!_debug)
+	if (!_foreground)
 		_daemonize();
 
 	openlog("dmeventd", LOG_PID, LOG_DAEMON);
@@ -1738,7 +1744,7 @@
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */
-	if (!_debug)
+	if (!_foreground)
 		kill(getppid(), SIGTERM);
 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
 
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/03/30 14:38:56	1.2
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/05/14 14:56:39	1.3
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "log.h"
 
 #include "lvm2cmd.h"
 #include "errors.h"
@@ -22,6 +23,8 @@
 #include <pthread.h>
 #include <syslog.h>
 
+extern int dmeventd_debug;
+
 /*
  * register_device() is called first and performs initialisation.
  * Only one device may be registered or unregistered at a time.
@@ -40,19 +43,41 @@
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
-/* FIXME Remove this: Pass messages back to dmeventd core for processing. */
+/*
+ * FIXME Do not pass things directly to syslog, rather use the existing logging
+ * facilities to sort logging ... however that mechanism needs to be somehow
+ * configurable and we don't have that option yet
+ */
 static void _temporary_log_fn(int level,
 			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
 			      int dm_errno __attribute((unused)),
-			      const char *format)
+			      const char *message)
 {
-	level &= ~_LOG_STDERR;
+	level &= ~(_LOG_STDERR | _LOG_ONCE);
 
-	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
-		syslog(LOG_CRIT, "%s", format);
-	else
-		syslog(LOG_DEBUG, "%s", format);
+	switch (level) {
+	case _LOG_DEBUG:
+		if (dmeventd_debug >= 3)
+			syslog(LOG_DEBUG, "%s", message);
+		break;
+	case _LOG_INFO:
+		if (dmeventd_debug >= 2)
+			syslog(LOG_INFO, "%s", message);
+		break;
+	case _LOG_NOTICE:
+		if (dmeventd_debug >= 1)
+			syslog(LOG_NOTICE, "%s", message);
+		break;
+	case _LOG_WARN:
+		syslog(LOG_WARNING, "%s", message);
+		break;
+	case _LOG_ERR:
+		syslog(LOG_ERR, "%s", message);
+		break;
+	default:
+		syslog(LOG_CRIT, "%s", message);
+	}
 }
 
 void dmeventd_lvm2_lock(void)
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/05/11 08:32:22	1.34
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/05/14 14:56:39	1.35
@@ -160,7 +160,8 @@
 
 	r = dmeventd_lvm2_run(cmd_str);
 
-	syslog(LOG_INFO, "Repair of mirrored LV %s/%s %s.", vg, lv, (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
+	syslog(LOG_INFO, "Repair of mirrored LV %s/%s %s.", vg, lv,
+	       (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
 
 	return (r == ECMD_PROCESSED) ? 0 : -1;
 }
--- LVM2/test/test-utils.sh	2010/05/12 11:58:51	1.42
+++ LVM2/test/test-utils.sh	2010/05/14 14:56:40	1.43
@@ -87,9 +87,8 @@
 
 	trap_teardown
 
-	dmeventd -d &
+	dmeventd -f &
 	LOCAL_DMEVENTD="$!"
-	strace -p $LOCAL_DMEVENTD &
 }
 
 prepare_testroot() {


