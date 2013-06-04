From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:58 +0000 (UTC)
Subject: dev-mornfall-activate - libdaemon: Print a diagnostic when we fail to lock the pidfile.
Message-ID: <20130604192358.9D81D60E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dce8d06af7e5a14a1507bea0e64e6cc27556cbc7
Commit:        dce8d06af7e5a14a1507bea0e64e6cc27556cbc7
Parent:        9495a3d807b890f7a639e5761b2b37ba495b5d9b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Apr 15 09:43:30 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Apr 15 16:07:07 2013 +0200

libdaemon: Print a diagnostic when we fail to lock the pidfile.

---
 libdaemon/server/daemon-server.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 735a0ea..1db7ca7 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -52,6 +52,8 @@ static void _exit_handler(int sig __attribute__((unused)))
 	_shutdown_requested = 1;
 }
 
+#define EXIT_ALREADYRUNNING 13
+
 #ifdef linux
 
 #include <stddef.h>
@@ -261,7 +263,7 @@ static void remove_lockfile(const char *file)
 		perror("unlink failed");
 }
 
-static void _daemonise(void)
+static void _daemonise(daemon_state s)
 {
 	int child_status;
 	int fd;
@@ -296,8 +298,14 @@ static void _daemonise(void)
 		if (_shutdown_requested) /* Child has signaled it is ok - we can exit now */
 			exit(0);
 
-		/* Problem with child.  Determine what it is by exit code */
-		fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
+		switch (WEXITSTATUS(child_status)) {
+		case EXIT_ALREADYRUNNING:
+			fprintf(stderr, "Failed to acquire lock on %s. Already running?\n", s.pidfile);
+			break;
+		default:
+			/* Problem with child.  Determine what it is by exit code */
+			fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
+		}
 		exit(WEXITSTATUS(child_status));
 	}
 
@@ -464,7 +472,7 @@ void daemon_start(daemon_state s)
 #endif
 
 	if (!s.foreground)
-		_daemonise();
+		_daemonise(s);
 
 	s.log = &_log;
 	s.log->name = s.name;
@@ -481,7 +489,7 @@ void daemon_start(daemon_state s)
 		 * after this point.
 		 */
 		if (dm_create_lockfile(s.pidfile) == 0)
-			exit(1);
+			exit(EXIT_ALREADYRUNNING);
 
 		(void) dm_prepare_selinux_context(NULL, 0);
 	}


