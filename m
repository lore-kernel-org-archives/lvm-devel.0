From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:01 +0000 (UTC)
Subject: master - dmeventd: support logging on stdout
Message-ID: <20151013140401.02516602BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b9533f38f32143e73979542161e62801438922a
Commit:        8b9533f38f32143e73979542161e62801438922a
Parent:        903e9af1b2c1972a897b7dd61e6e463a03cad648
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 15:14:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:57 2015 +0200

dmeventd: support logging on stdout

Add new supported option '-l' log to stdout/stderr.

It has to be paired with '-f' (foreground run).
---
 daemons/dmeventd/dmeventd.c |   33 ++++++++++++++++++++++++++-------
 man/dmeventd.8.in           |    7 +++++++
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f775fb9..e2daef4 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -104,7 +104,8 @@ static pthread_mutex_t _global_mutex;
 
 #define THREAD_STACK_SIZE (300*1024)
 
-int dmeventd_debug = 0;
+static int _debug_level = 0;
+static int _use_syslog = 1;
 static int _systemd_activation = 0;
 static int _foreground = 0;
 static int _restart = 0;
@@ -2051,10 +2052,11 @@ bad:
 static void _usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-d [-d [-d]]] [-f] [-h] [-R] [-V] [-?]\n\n"
+		"%s [-d [-d [-d]]] [-f] [-h] [-l] [-R] [-V] [-?]\n\n"
 		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
 		"   -f       Don't fork, run in the foreground\n"
 		"   -h       Show this help information\n"
+		"   -l       Log to stdout,stderr instead of syslog\n"
 		"   -?       Show this help information on stderr\n"
 		"   -R       Restart dmeventd\n"
 		"   -V       Show version of dmeventd\n\n", prog);
@@ -2075,7 +2077,7 @@ int main(int argc, char *argv[])
 	opterr = 0;
 	optind = 0;
 
-	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVdlR")) != EOF) {
 		switch (opt) {
 		case 'h':
 			_usage(argv[0], stdout);
@@ -2090,7 +2092,10 @@ int main(int argc, char *argv[])
 			_foreground++;
 			break;
 		case 'd':
-			dmeventd_debug++;
+			_debug_level++;
+			break;
+		case 'l':
+			_use_syslog = 0;
 			break;
 		case 'V':
 			printf("dmeventd version: %s\n", DM_LIB_VERSION);
@@ -2098,6 +2103,10 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (!_foreground && !_use_syslog) {
+		printf("WARNING: Ignoring logging to stdout, needs options -f\n");
+		_use_syslog = 1;
+	}
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file
 	 * used by some glibc (on some distributions it takes over 100MB).
@@ -2116,8 +2125,10 @@ int main(int argc, char *argv[])
 	if (!_foreground)
 		_daemonize();
 
-	openlog("dmeventd", LOG_PID, LOG_DAEMON);
+	if (_use_syslog)
+		openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
+	dm_event_log_set(_debug_level, _use_syslog);
 	dm_log_init(_dmeventd_log);
 
 	(void) dm_prepare_selinux_context(DMEVENTD_PIDFILE, S_IFREG);
@@ -2180,12 +2191,20 @@ int main(int argc, char *argv[])
 		_cleanup_unused_threads();
 	}
 
-	_exit_dm_lib();
 
 	pthread_mutex_destroy(&_global_mutex);
 
 	log_notice("dmeventd shutting down.");
-	closelog();
+
+	if (close(fifos.client))
+		log_sys_error("client close", fifos.client_path);
+	if (close(fifos.server))
+		log_sys_error("server close", fifos.server_path);
+
+	if (_use_syslog)
+		closelog();
+
+	_exit_dm_lib();
 
 	exit(EXIT_SUCCESS);
 }
diff --git a/man/dmeventd.8.in b/man/dmeventd.8.in
index 15e003b..aa62451 100644
--- a/man/dmeventd.8.in
+++ b/man/dmeventd.8.in
@@ -12,6 +12,7 @@ dmeventd \(em Device-mapper event daemon
 .RB [ \-d ]]]
 .RB [ \-f ]
 .RB [ \-h ]
+.RB [ \-l ]
 .RB [ \-R ]
 .RB [ \-V ]
 .RB [ \-? ]
@@ -81,6 +82,12 @@ Don't fork, run in the foreground.
 Show help information.
 .
 .HP
+.BR \-l
+.br
+Log through stdout and stderr instead of syslog.
+This option works only with option \-f, otherwise it is ignored.
+.
+.HP
 .BR \-?
 .br
 Show help information on stderr.


