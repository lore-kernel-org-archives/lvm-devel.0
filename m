From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Oct 2012 01:08:56 +0000 (UTC)
Subject: master - lvmetad: document and tidy cmdline args
Message-ID: <20121015010856.82190A0E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0e60d27ff91c46a1febf58a955c6b88539ba982
Commit:        a0e60d27ff91c46a1febf58a955c6b88539ba982
Parent:        2393b468a4703be81f1d38ea7968931d30046087
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 15 02:06:27 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 15 02:06:27 2012 +0100

lvmetad: document and tidy cmdline args

Try to bring the lvmetad usage text and man page closer to the code.
There seem to be 3 useful ways to use -d with lvmetad at the moment:
  -d all
  -d wire
  -d debug
(They can also be comma-separated like -d wire,debug.)
Prior to the last release, -d, -dd and -ddd were supported.
Fail if an unrecognised debug arg is supplied on the command line.
Change -V to report the same version as the lvm binary: previously it
just reported version 0.
---
 WHATS_NEW                        |    2 ++
 daemons/lvmetad/lvmetad-core.c   |   17 +++++++++--------
 libdaemon/server/daemon-server.c |    6 ++++--
 man/lvmetad.8.in                 |   23 ++++++++++++++++-------
 4 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d60cad5..5d27c8c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -65,6 +65,8 @@ Version 2.02.98 -
   Use proper condition to check for unsupported discards settings.
   Update lvs manpage with discards (2.02.97).
   Add support for lvcreate --discards.
+  Change lvmetad logging syntax from -ddd to -d {all|wire|debug}.
+  Add new libdaemon logging infrastructure.
 
 Version 2.02.97 - 7th August 2012
 =================================
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1992467..ad59847 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -19,6 +19,7 @@
 #include "config-util.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
+#include "lvm-version.h"
 
 #include <assert.h>
 #include <pthread.h>
@@ -1066,9 +1067,8 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "vg_lookup"))
 		return vg_lookup(state, r);
 
-	if (!strcmp(rq, "pv_list")) {
+	if (!strcmp(rq, "pv_list"))
 		return pv_list(state, r);
-	}
 
 	if (!strcmp(rq, "vg_list"))
 		return vg_list(state, r);
@@ -1098,7 +1098,8 @@ static int init(daemon_state *s)
 	ls->token[0] = 0;
 
 	/* Set up stderr logging depending on the -d option. */
-	daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1);
+	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1))
+		return 0;
 
 	DEBUG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
 	if (!ls->pvid_to_vgid || !ls->vgid_to_metadata)
@@ -1134,12 +1135,12 @@ static int fini(daemon_state *s)
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-d [info[,debug[,wire]]]] [-f] [-s path]\n\n"
+		"%s [-V] [-h] [-d {all|wire|debug}] [-f] [-s path]\n\n"
 		"   -V       Show version of lvmetad\n"
 		"   -h       Show this help information\n"
-		"   -s       Set path to the socket to listen on\n"
-		"   -d       Log messages to stderr (-d info,wire,debug)\n"
-		"   -f       Don't fork, run in the foreground\n\n", prog);
+		"   -d       Log messages to stderr (-d {all|wire|debug})\n"
+		"   -f       Don't fork, run in the foreground\n"
+		"   -s       Set path to the socket to listen on\n\n", prog);
 }
 
 int main(int argc, char *argv[])
@@ -1184,7 +1185,7 @@ int main(int argc, char *argv[])
 			_socket_override = 1;
 			break;
 		case 'V':
-			printf("lvmetad version 0\n");
+			printf("lvmetad version: " LVM_VERSION "\n");
 			exit(1);
 		}
 	}
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index b02621f..3711419 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -506,7 +506,8 @@ void daemon_start(daemon_state s)
 		kill(getppid(), SIGTERM);
 
 	if (s.daemon_init)
-		s.daemon_init(&s);
+		if (!s.daemon_init(&s))
+			failed = 1;
 
 	while (!_shutdown_requested && !failed) {
 		fd_set in;
@@ -525,7 +526,8 @@ void daemon_start(daemon_state s)
 			perror("unlink error");
 
 	if (s.daemon_fini)
-		s.daemon_fini(&s);
+		if (!s.daemon_fini(&s))
+			failed = 1;
 
 	INFO(&s, "%s shutting down", s.name);
 
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index d43a8f1..07cedd9 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -3,8 +3,12 @@
 lvmetad \- LVM metadata cache daemon
 .SH SYNOPSIS
 .B lvmetad
-.RB [ \-d ]
-.RB [ \-s ]
+.RB [ \-d
+.RI {all|wire|debug}
+.RB ]
+.RB [ \-s
+.RI path
+.RB ]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-V ]
@@ -18,10 +22,15 @@ consistent image of the volume groups available in the system.
 By default, lvmetad, even if running, is not used by LVM. See \fBlvm.conf\fP(5).
 .SH OPTIONS
 .TP
-.B \-d
-Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
-debug messages sent to syslog.
-Each extra d adds more debugging information.
+.BR \-d " {" \fIall | \fIwire | \fIdebug }
+Select the type of log messages to generate.
+Messages are logged by syslog.  
+Additionally, when -f is given they are also sent to standard error.
+Since release 2.02.98, there are two classes of messages: wire and debug.
+Selecting 'all' supplies both and is equivalent to a comma-separated list
+-d wire,debug.
+Prior to release 2.02.98, repeating from 1 to 3 times, viz. -d, -dd, -ddd,
+increased the detail of messages.
 .TP
 .B \-f
 Don't fork, run in the foreground.
@@ -29,7 +38,7 @@ Don't fork, run in the foreground.
 .BR \-h ", " \-?
 Show help information.
 .TP
-.B \-s
+.B \-s \fIpath
 Path to the socket file to use. The option overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
 LVM_LVMETAD_SOCKET.


