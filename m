From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 May 2011 11:02:32 -0000
Subject: LVM2/daemons/common daemon-client.h daemon-ser ...
Message-ID: <20110515110232.22303.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-15 11:02:29

Modified files:
	daemons/common : daemon-client.h daemon-server.c daemon-server.h 

Log message:
	More work on the common daemon framework. Make things compile, too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/common/daemon-client.h	2011/05/13 08:07:28	1.1
+++ LVM2/daemons/common/daemon-client.h	2011/05/15 11:02:29	1.2
@@ -32,7 +32,7 @@
 } daemon_request;
 
 typedef struct {
-	int errno; /* 0 for success */
+	int error; /* 0 for success */
 	char *reply; /* textual reply */
 	struct config_tree *cft; /* parsed reply, if available */
 } daemon_reply;
@@ -51,7 +51,7 @@
  * the daemon is synchronous. The function handles the IO details and parses the
  * response, handling common error conditions. See "daemon_reply" for details.
  */
-daemon_reply daemon_request(daemon_handle h, daemon_request r);
+daemon_reply daemon_send(daemon_handle h, daemon_request r);
 
 /* Shut down the communication to the daemon. Compulsory. */
 void daemon_close(daemon_handle h);
--- LVM2/daemons/common/daemon-server.c	2011/05/13 09:34:12	1.2
+++ LVM2/daemons/common/daemon-server.c	2011/05/15 11:02:29	1.3
@@ -18,11 +18,16 @@
 #include <sys/wait.h>
 #include <sys/time.h>
 #include <sys/resource.h>
+#include <netinet/in.h>
+#include <sys/un.h>
 #include <unistd.h>
 #include <signal.h>
 
 #include <syslog.h>
+#include "daemon-server.h"
+#include "libdevmapper.h"
 
+#if 0
 /* Create a device monitoring thread. */
 static int _pthread_create(pthread_t *t, void *(*fun)(void *), void *arg, int stacksize)
 {
@@ -34,6 +39,7 @@
 	pthread_attr_setstacksize(&attr, stacksize);
 	return pthread_create(t, &attr, fun, arg);
 }
+#endif
 
 static volatile sig_atomic_t _shutdown_requested = 0;
 
@@ -44,6 +50,7 @@
 
 #ifdef linux
 #  define OOM_ADJ_FILE "/proc/self/oom_adj"
+#  include <stdio.h>
 
 /* From linux/oom.h */
 #  define OOM_DISABLE (-17)
@@ -72,7 +79,7 @@
 	}
 
 	fprintf(fp, "%i", val);
-	if (dm_fclose(fp))
+	if (fclose(fp))
 		perror(OOM_ADJ_FILE ": fclose failed");
 
 	return 1;
@@ -91,13 +98,13 @@
 	/* Open local socket */
 	fd = socket(PF_UNIX, SOCK_STREAM, 0);
 	if (fd < 0) {
-		log_error("Can't create local socket: %m");
+		perror("Can't create local socket.");
 		goto error;
 	}
 
 	/* Set Close-on-exec & non-blocking */
 	if (fcntl(fd, F_SETFD, 1))
-		DEBUGLOG("setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
+		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
 	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
 
 	memset(&sockaddr, 0, sizeof(sockaddr));
@@ -105,11 +112,11 @@
 	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
-		log_error("can't bind local socket: %m");
+		perror("can't bind local socket.");
 		goto error;
 	}
 	if (listen(fd, 1) != 0) {
-		log_error("listen local: %m");
+		perror("listen local");
 		goto error;
 	}
 
@@ -129,7 +136,7 @@
 static void remove_lockfile(const char *file)
 {
 	if (unlink(file))
-		perror(file ": unlink failed");
+		perror("unlink failed");
 }
 
 static void _daemonise(void)
@@ -158,7 +165,7 @@
 
 	default:
 		/* Wait for response from child */
-		while (!waitpid(pid, &child_status, WNOHANG) && !_exit_now) {
+		while (!waitpid(pid, &child_status, WNOHANG) && !_shutdown_requested) {
 			tval.tv_sec = 0;
 			tval.tv_usec = 250000;	/* .25 sec */
 			select(0, NULL, NULL, NULL, &tval);
@@ -168,16 +175,7 @@
 			exit(0);
 
 		/* Problem with child.  Determine what it is by exit code */
-		switch (WEXITSTATUS(child_status)) {
-		case EXIT_DESC_CLOSE_FAILURE:
-		case EXIT_DESC_OPEN_FAILURE:
-		case EXIT_FIFO_FAILURE:
-		case EXIT_CHDIR_FAILURE:
-		default:
-			fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
-			break;
-		}
-
+		fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
 		exit(WEXITSTATUS(child_status));
 	}
 
@@ -200,7 +198,7 @@
 	setsid();
 }
 
-void daemon_start(daemon_state s, handle_request r)
+void daemon_start(daemon_state s)
 {
 	int failed = 0;
 	/*
--- LVM2/daemons/common/daemon-server.h	2011/05/13 09:34:12	1.3
+++ LVM2/daemons/common/daemon-server.h	2011/05/15 11:02:29	1.4
@@ -12,8 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef _LVM_DAEMON_COMMON_CLIENT_H
-#define _LVM_DAEMON_COMMON_CLIENT_H
+#include "daemon-client.h"
+
+#ifndef _LVM_DAEMON_COMMON_SERVER_H
+#define _LVM_DAEMON_COMMON_SERVER_H
 
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the client */
@@ -23,6 +25,26 @@
 } client_handle;
 
 typedef struct {
+	struct config_tree *cft;
+} request;
+
+typedef struct {
+	int error;
+	struct config_tree *cft;
+} response;
+
+struct daemon_state;
+
+/*
+ * The callback. Called once per request issued, in the respective client's
+ * thread. It is presented by a parsed request (in the form of a config tree).
+ * The output is a new config tree that is serialised and sent back to the
+ * client. The client blocks until the request processing is done and reply is
+ * sent.
+ */
+typedef response (*handle_request)(struct daemon_state s, client_handle h, request r);
+
+typedef struct daemon_state {
 	/*
 	 * The maximal stack size for individual daemon threads. This is
 	 * essential for daemons that need to be locked into memory, since
@@ -36,6 +58,9 @@
 	const char *name;
 	const char *pidfile;
 	const char *socket_path;
+	int log_level;
+	handle_request handler;
+	int (*setup_post)(struct daemon_state *st);
 
 	/* Global runtime info maintained by the framework. */
 	int socket_fd;
@@ -43,29 +68,12 @@
 	void *private; /* the global daemon state */
 } daemon_state;
 
-typedef struct {
-	struct config_tree *cft;
-} request;
-
-typedef struct {
-	struct config_tree *cft;
-} response;
-
-/*
- * The callback. Called once per request issued, in the respective client's
- * thread. It is presented by a parsed request (in the form of a config tree).
- * The output is a new config tree that is serialised and sent back to the
- * client. The client blocks until the request processing is done and reply is
- * sent.
- */
-typedef response (*handle_request)(daemon_state s, client_handle h, request r);
-
 /*
  * Start serving the requests. This does all the daemonisation, socket setup
  * work and so on. This function takes over the process, and upon failure, it
  * will terminate execution. It may be called@most once.
  */
-void daemon_start(daemon_state s, handle_request r);
+void daemon_start(daemon_state s);
 
 /*
  * Take over from an already running daemon. This function handles connecting


