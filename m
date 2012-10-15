From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Oct 2012 09:46:59 +0000 (UTC)
Subject: master - lvmetad: use -l for logging level not -d
Message-ID: <20121015094659.AC6E8A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78dafcba994be668c540ecacd828f61d4a26ed85
Commit:        78dafcba994be668c540ecacd828f61d4a26ed85
Parent:        3ed2c32e0a8f36c6d5da347b5367aa16d52245aa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 15 10:44:43 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 15 10:44:43 2012 +0100

lvmetad: use -l for logging level not -d

---
 WHATS_NEW                        |    2 +-
 daemons/lvmetad/lvmetad-core.c   |   18 +++++++++---------
 libdaemon/server/daemon-server.h |    2 +-
 man/lvmetad.8.in                 |    8 ++++----
 test/lib/aux.sh                  |    2 +-
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d27c8c..179e52c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -65,7 +65,7 @@ Version 2.02.98 -
   Use proper condition to check for unsupported discards settings.
   Update lvs manpage with discards (2.02.97).
   Add support for lvcreate --discards.
-  Change lvmetad logging syntax from -ddd to -d {all|wire|debug}.
+  Change lvmetad logging syntax from -ddd to -l {all|wire|debug}.
   Add new libdaemon logging infrastructure.
 
 Version 2.02.97 - 7th August 2012
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ad59847..ebb8bc3 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -28,7 +28,7 @@
 
 typedef struct {
 	log_state *log; /* convenience */
-	const char *debug_config;
+	const char *log_config;
 
 	struct dm_hash_table *pvid_to_pvmeta;
 	struct dm_hash_table *device_to_pvid; /* shares locks with above */
@@ -1097,8 +1097,8 @@ static int init(daemon_state *s)
 	ls->lock.vg = dm_hash_create(32);
 	ls->token[0] = 0;
 
-	/* Set up stderr logging depending on the -d option. */
-	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1))
+	/* Set up stderr logging depending on the -l option. */
+	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->log_config, 1))
 		return 0;
 
 	DEBUG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
@@ -1135,11 +1135,11 @@ static int fini(daemon_state *s)
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-d {all|wire|debug}] [-f] [-s path]\n\n"
+		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n\n"
 		"   -V       Show version of lvmetad\n"
 		"   -h       Show this help information\n"
-		"   -d       Log messages to stderr (-d {all|wire|debug})\n"
 		"   -f       Don't fork, run in the foreground\n"
+		"   -l       Logging message level (-l {all|wire|debug})\n"
 		"   -s       Set path to the socket to listen on\n\n", prog);
 }
 
@@ -1163,10 +1163,10 @@ int main(int argc, char *argv[])
 	s.pidfile = LVMETAD_PIDFILE;
 	s.protocol = "lvmetad";
 	s.protocol_version = 1;
-	ls.debug_config = "";
+	ls.log_config = "";
 
 	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVd:s:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVl:s:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1177,8 +1177,8 @@ int main(int argc, char *argv[])
 		case 'f':
 			s.foreground = 1;
 			break;
-		case 'd':
-			ls.debug_config = optarg;
+		case 'l':
+			ls.log_config = optarg;
 			break;
 		case 's': // --socket
 			s.socket_path = optarg;
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index 2109602..f184853 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -151,7 +151,7 @@ void daemon_log_enable(log_state *s, int outlet, int type, int enable);
 /*
  * Set up logging on a given outlet using a list of message types (comma
  * separated) to log using that outlet. The list is expected to look like this,
- * "info,wire,debug". Returns 0 upon encountering an unknown message type.
+ * "all,wire,debug". Returns 0 upon encountering an unknown message type.
  */
 int daemon_log_parse(log_state *s, int outlet, const char *types, int enable);
 
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 07cedd9..ef1096d 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -3,7 +3,7 @@
 lvmetad \- LVM metadata cache daemon
 .SH SYNOPSIS
 .B lvmetad
-.RB [ \-d
+.RB [ \-l
 .RI {all|wire|debug}
 .RB ]
 .RB [ \-s
@@ -22,14 +22,14 @@ consistent image of the volume groups available in the system.
 By default, lvmetad, even if running, is not used by LVM. See \fBlvm.conf\fP(5).
 .SH OPTIONS
 .TP
-.BR \-d " {" \fIall | \fIwire | \fIdebug }
+.BR \-l " {" \fIall | \fIwire | \fIdebug }
 Select the type of log messages to generate.
 Messages are logged by syslog.  
 Additionally, when -f is given they are also sent to standard error.
 Since release 2.02.98, there are two classes of messages: wire and debug.
 Selecting 'all' supplies both and is equivalent to a comma-separated list
--d wire,debug.
-Prior to release 2.02.98, repeating from 1 to 3 times, viz. -d, -dd, -ddd,
+-l wire,debug.
+Prior to release 2.02.98, repeating -d from 1 to 3 times, viz. -d, -dd, -ddd,
 increased the detail of messages.
 .TP
 .B \-f
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 103318a..9094562 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -77,7 +77,7 @@ prepare_lvmetad() {
 	test -z "$LVM_VALGRIND_LVMETAD" || run_valgrind="run_valgrind"
 
 	echo "preparing lvmetad..."
-	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -d wire,debug &
+	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -l wire,debug &
 	echo $! > LOCAL_LVMETAD
 	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
 	echo ok


