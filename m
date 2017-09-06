From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 6 Sep 2017 05:46:35 -0400
Subject: master - deamonize: restore detection of errors
Message-ID: <201709060946.v869kZaR002689@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d19084af2565b1cbfe990835aca73c6709a1a034
Commit:        d19084af2565b1cbfe990835aca73c6709a1a034
Parent:        3071837e21fae8907c1d584f9181e0589b9ce7e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 4 14:09:58 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 6 11:19:38 2017 +0200

deamonize: restore detection of errors

Keep forked environment for daemon more strick and check even
for nearly impossible to happen errors.
---
 daemons/clvmd/clvmd.c            |   16 +++++++++++-----
 libdaemon/server/daemon-server.c |   19 +++++++++++++------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 46f5f44..9dbda89 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1111,12 +1111,18 @@ static void be_daemon(int timeout)
 	}
 
 	/* Detach ourself from the calling environment */
-	(void) dup2(devnull, STDIN_FILENO);
-	(void) dup2(devnull, STDOUT_FILENO);
-	(void) dup2(devnull, STDERR_FILENO);
+	if ((dup2(devnull, STDIN_FILENO) == -1) ||
+	    (dup2(devnull, STDOUT_FILENO) == -1) ||
+	    (dup2(devnull, STDERR_FILENO) == -1)) {
+		perror("Error setting terminal FDs to /dev/null");
+		log_error("Error setting terminal FDs to /dev/null: %m");
+		exit(5);
+	}
 
-	if (devnull > STDERR_FILENO)
-		(void) close(devnull);
+	if ((devnull > STDERR_FILENO) && close(devnull)) {
+		log_sys_error("close", "/dev/null");
+		exit(7);
+	}
 
 	if (chdir("/")) {
 		log_error("Error setting current directory to /: %m");
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0950c2e..0b32931 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -377,15 +377,22 @@ static void _daemonise(daemon_state s)
 		exit(WEXITSTATUS(child_status));
 	}
 
-	if (chdir("/"))
+	if (chdir("/")) {
+		perror("chdir", "/");
 		exit(1);
+	}
 
-	(void) dup2(fd, STDIN_FILENO);
-	(void) dup2(fd, STDOUT_FILENO);
-	(void) dup2(fd, STDERR_FILENO);
+	if ((dup2(fd, STDIN_FILENO) == -1) ||
+	    (dup2(fd, STDOUT_FILENO) == -1) ||
+	    (dup2(fd, STDERR_FILENO) == -1)) {
+		perror("Error setting terminal FDs to /dev/null");
+		exit(2);
+	}
 
-	if (fd > STDERR_FILENO)
-		(void) close(fd);
+	if ((fd > STDERR_FILENO) && close(fd)) {
+		perror("Failed to close /dev/null descriptor");
+		exit(3);
+	}
 
 	/* Switch to sysconf(_SC_OPEN_MAX) ?? */
 	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0)


