From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Nov 2013 20:57:10 +0000 (UTC)
Subject: master - lvmetad: extend socket/pid file handling
Message-ID: <20131129205711.017EA602B7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84394c0219e4fcee719663c710121f1bb731a538
Commit:        84394c0219e4fcee719663c710121f1bb731a538
Parent:        d2d5c24a68285a2f056977f877ab1a19e61b992f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 29 20:56:29 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 29 20:56:29 2013 +0000

lvmetad: extend socket/pid file handling

Make it easier to run a live lvmetad in debugging mode and
to avoid conflicts if multiple test instances need to be run
alongside a live one.

No longer require -s when -f is used: use built-in default.
Add -p to lvmetad to specify the pid file.
No longer disable pidfile if -f used to run in foreground.
If specified socket file appears to be genuine but stale, remove it
before use.
On error, only remove lvmetad socket file if created by the same
process.  (Previous code removes socket even while a running instance
is using it!)
---
 WHATS_NEW                        |    3 ++
 daemons/lvmetad/lvmetad-core.c   |   25 +++++++++++---------
 libdaemon/server/daemon-server.c |   46 +++++++++++++++++++++++++++++++++++--
 man/lvmetad.8.in                 |   36 +++++++++++++++++++++--------
 test/lib/test.sh                 |    1 +
 5 files changed, 87 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0101b49..043b7ef 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.105 -
 =====================================
+  Add -p and LVM_LVMETAD_PID env var to lvmetad to change pid file.
+  Allow lvmetad to reuse stale socket.
+  Only unlink lvmetad socket on error if created by the same process.
   Append missing newline to lvmetad missing socket path error message.
   Check for non-zero aligment in _text_pv_add_metadata_area() to not div by 0.
   Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 71254f4..2810faf 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1189,6 +1189,7 @@ static void usage(char *prog, FILE *file)
 		"   -h       Show this help information\n"
 		"   -f       Don't fork, run in the foreground\n"
 		"   -l       Logging message level (-l {all|wire|debug})\n"
+		"   -p       Set path to the pidfile\n"
 		"   -s       Set path to the socket to listen on\n\n", prog);
 }
 
@@ -1196,27 +1197,34 @@ int main(int argc, char *argv[])
 {
 	signed char opt;
 	lvmetad_state ls;
+	int _pidfile_override = 1;
 	int _socket_override = 1;
 	daemon_state s = {
 		.daemon_fini = fini,
 		.daemon_init = init,
 		.handler = handler,
 		.name = "lvmetad",
-		.pidfile = LVMETAD_PIDFILE,
+		.pidfile = getenv("LVM_LVMETAD_PIDFILE"),
 		.private = &ls,
 		.protocol = "lvmetad",
 		.protocol_version = 1,
 		.socket_path = getenv("LVM_LVMETAD_SOCKET"),
 	};
 
+	if (!s.pidfile) {
+		_pidfile_override = 0;
+		s.pidfile = LVMETAD_PIDFILE;
+	}
+
 	if (!s.socket_path) {
 		_socket_override = 0;
 		s.socket_path = LVMETAD_SOCKET;
 	}
+
 	ls.log_config = "";
 
 	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVl:s:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVl:p:s:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1230,6 +1238,10 @@ int main(int argc, char *argv[])
 		case 'l':
 			ls.log_config = optarg;
 			break;
+		case 'p':
+			s.pidfile = optarg;
+			_pidfile_override = 1;
+			break;
 		case 's': // --socket
 			s.socket_path = optarg;
 			_socket_override = 1;
@@ -1240,15 +1252,6 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (s.foreground) {
-		if (!_socket_override) {
-			fprintf(stderr, "A socket path (-s) is required in foreground mode.\n");
-			exit(2);
-		}
-
-		s.pidfile = NULL;
-	}
-
 	daemon_start(s);
 	return 0;
 }
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 156925a..914b803 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -207,7 +207,9 @@ out:
 static int _open_socket(daemon_state s)
 {
 	int fd = -1;
+	int file_created = 0;
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
+	struct stat buf;
 	mode_t old_mask;
 
 	(void) dm_prepare_selinux_context(s.socket_path, S_IFSOCK);
@@ -233,9 +235,47 @@ static int _open_socket(daemon_state s)
 	}
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
-		perror("can't bind local socket.");
-		goto error;
+		if (errno != EADDRINUSE) {
+			perror("can't bind local socket");
+			goto error;
+		}
+
+		/* Socket already exists. If it's stale, remove it. */
+		if (stat(sockaddr.sun_path, &buf)) {
+			perror("stat failed");
+			goto error;
+		}
+
+		if (S_ISSOCK(buf.st_mode)) {
+			fprintf(stderr, "%s: not a socket\n", sockaddr.sun_path);
+			goto error;
+		}
+
+		if (buf.st_uid || (buf.st_mode & (S_IRWXG | S_IRWXO))) {
+			fprintf(stderr, "%s: unrecognised permissions\n", sockaddr.sun_path);
+			goto error;
+		}
+
+		if (!connect(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+			fprintf(stderr, "Socket %s already in use\n", sockaddr.sun_path);
+			goto error;
+		}
+
+		fprintf(stderr, "removing stale socket %s\n", sockaddr.sun_path);
+
+		if (unlink(sockaddr.sun_path) && (errno != ENOENT)) {
+			perror("unlink failed");
+			goto error;
+		}
+
+		if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+			perror("local socket bind failed after unlink");
+			goto error;
+		}
 	}
+
+	file_created = 1;
+
 	if (listen(fd, 1) != 0) {
 		perror("listen local");
 		goto error;
@@ -250,7 +290,7 @@ error:
 	if (fd >= 0) {
 		if (close(fd))
 			perror("close failed");
-		if (unlink(s.socket_path))
+		if (file_created && unlink(s.socket_path))
 			perror("unlink failed");
 		fd = -1;
 	}
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 7110877..4956a3f 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -6,8 +6,11 @@ lvmetad \- LVM metadata cache daemon
 .RB [ \-l
 .RI {all|wire|debug}
 .RB ]
+.RB [ \-p
+.RI pidfile_path
+.RB ]
 .RB [ \-s
-.RI path
+.RI socket_path
 .RB ]
 .RB [ \-f ]
 .RB [ \-h ]
@@ -21,6 +24,15 @@ consistent image of the volume groups available in the system.
 
 By default, lvmetad, even if running, is not used by LVM. See \fBlvm.conf\fP(5).
 .SH OPTIONS
+
+To run the daemon in a test environment both the pidfile_path and the
+socket_path should be changed from the defaults.
+.TP
+.B \-f
+Don't fork, but run in the foreground.
+.TP
+.BR \-h ", " \-?
+Show help information.
 .TP
 .BR \-l " {" \fIall | \fIwire | \fIdebug }
 Select the type of log messages to generate.
@@ -32,23 +44,27 @@ Selecting 'all' supplies both and is equivalent to a comma-separated list
 Prior to release 2.02.98, repeating -d from 1 to 3 times, viz. -d, -dd, -ddd,
 increased the detail of messages.
 .TP
-.B \-f
-Don't fork, run in the foreground.
-.TP
-.BR \-h ", " \-?
-Show help information.
+.B \-p \fIpidfile_path
+Path to the pidfile. This overrides both the built-in default
+(#DEFAULT_PID_DIR#/lvmetad.pid) and the environment variable
+\fBLVM_LVMETAD_PIDFILE\fP.  This file is used to prevent more
+than one instance of the daemon running simultaneously.
 .TP
-.B \-s \fIpath
-Path to the socket file to use. The option overrides both the built-in default
+.B \-s \fIsocket_path
+Path to the socket file. This overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
-\fBLVM_LVMETAD_SOCKET\fP.
+\fBLVM_LVMETAD_SOCKET\fP.  To communicate successfully with lvmetad,
+all LVM2 processes should use the same socket path.
 .TP
 .B \-V
 Display the version of lvmetad daemon.
 .SH ENVIRONMENT VARIABLES
 .TP
+.B LVM_LVMETAD_PIDFILE
+Path for the pid file.
+.TP
 .B LVM_LVMETAD_SOCKET 
-override path for socket file to use.
+Path for the socket file.
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 563ef59..265d61d 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -83,6 +83,7 @@ aux prepare_clvmd
 test -n "$LVM_TEST_LVMETAD" && {
 	aux prepare_lvmetad
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
+	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
 }
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"


