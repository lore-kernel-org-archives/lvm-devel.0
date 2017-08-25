From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:23:58 -0400
Subject: master - daemonize: more unified code
Message-ID: <201708251223.v7PCNwtT005025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3b1e788e16c77f6784f30b8e984f68792f8fa1a
Commit:        b3b1e788e16c77f6784f30b8e984f68792f8fa1a
Parent:        5de944420224f3b629e843f9c190132ed9ff3dca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:55:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:57 2017 +0200

daemonize: more unified code

ATM we have several instances of daemonizing code.
Each has its 'special' logic so not completely easy
to unify them all into a single routine.

Start to unify them and use one strategy for rediricting
all input/outpus to /dev/null - use 'dup2' function for this
and open /dev/null before fork to make sure it's available.
---
 daemons/clvmd/clvmd.c            |   26 ++++++++++----------------
 libdaemon/server/daemon-server.c |   21 +++++++++++++++------
 2 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 79aa939..46f5f44 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1105,31 +1105,25 @@ static void be_daemon(int timeout)
 		break;
 
 	default:       /* Parent */
+		(void) close(devnull);
 		(void) close(child_pipe[1]);
-		wait_for_child(child_pipe[0], timeout);
+		wait_for_child(child_pipe[0], timeout); /* noreturn */
 	}
 
 	/* Detach ourself from the calling environment */
-	if (close(0) || close(1) || close(2)) {
-		perror("Error closing terminal FDs");
-		exit(4);
-	}
-	setsid();
+	(void) dup2(devnull, STDIN_FILENO);
+	(void) dup2(devnull, STDOUT_FILENO);
+	(void) dup2(devnull, STDERR_FILENO);
+
+	if (devnull > STDERR_FILENO)
+		(void) close(devnull);
 
-	if (dup2(devnull, 0) < 0 || dup2(devnull, 1) < 0
-	    || dup2(devnull, 2) < 0) {
-		perror("Error setting terminal FDs to /dev/null");
-		log_error("Error setting terminal FDs to /dev/null: %m");
-		exit(5);
-	}
-	if ((devnull > STDERR_FILENO) && close(devnull)) {
-		log_sys_error("close", "/dev/null");
-		exit(7);
-	}
 	if (chdir("/")) {
 		log_error("Error setting current directory to /: %m");
 		exit(6);
 	}
+
+	setsid();
 }
 
 static int verify_message(char *buf, int len)
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 6fdf195..0950c2e 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -334,6 +334,11 @@ static void _daemonise(daemon_state s)
 	struct timeval tval;
 	sigset_t my_sigset;
 
+	if ((fd = open("/dev/null", O_RDWR)) == -1) {
+		fprintf(stderr, "Unable to open /dev/null.\n");
+		exit(EXIT_FAILURE);
+	}
+
 	sigemptyset(&my_sigset);
 	if (sigprocmask(SIG_SETMASK, &my_sigset, NULL) < 0) {
 		fprintf(stderr, "Unable to restore signals.\n");
@@ -350,6 +355,7 @@ static void _daemonise(daemon_state s)
 		break;
 
 	default:
+		(void) close(fd);
 		/* Wait for response from child */
 		while (!waitpid(pid, &child_status, WNOHANG) && !_shutdown_requested) {
 			tval.tv_sec = 0;
@@ -374,12 +380,20 @@ static void _daemonise(daemon_state s)
 	if (chdir("/"))
 		exit(1);
 
+	(void) dup2(fd, STDIN_FILENO);
+	(void) dup2(fd, STDOUT_FILENO);
+	(void) dup2(fd, STDERR_FILENO);
+
+	if (fd > STDERR_FILENO)
+		(void) close(fd);
+
+	/* Switch to sysconf(_SC_OPEN_MAX) ?? */
 	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0)
 		fd = 256; /* just have to guess */
 	else
 		fd = rlim.rlim_cur;
 
-	for (--fd; fd >= 0; fd--) {
+	for (--fd; fd > STDERR_FILENO; fd--) {
 #ifdef __linux__
 		/* Do not close fds preloaded by systemd! */
 		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
@@ -388,11 +402,6 @@ static void _daemonise(daemon_state s)
 		(void) close(fd);
 	}
 
-	if ((open("/dev/null", O_RDONLY) < 0) ||
-	    (open("/dev/null", O_WRONLY) < 0) ||
-	    (open("/dev/null", O_WRONLY) < 0))
-		exit(1);
-
 	setsid();
 }
 


