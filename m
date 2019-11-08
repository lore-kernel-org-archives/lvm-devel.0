From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:14:58 -0500
Subject: stable-2.02 - cov: missing checks of syscalls
Message-ID: <201911081414.xA8EEwb4008298@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67bdae069751e4779e738283e3d8a5873622bfc0
Commit:        67bdae069751e4779e738283e3d8a5873622bfc0
Parent:        50fb24f5c208ff9b89b80a1f7aa32dcdafd98e12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 20:25:39 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 13:04:02 2019 +0100

cov: missing checks of syscalls

Check for sigaction,sigprocmask,pthread_sigmask errors
---
 daemons/clvmd/clvmd.c            |   10 ++++++----
 libdaemon/server/daemon-server.c |    9 ++++++---
 tools/toollib.c                  |    3 ++-
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 829c5e5..e1d8a79 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -887,7 +887,8 @@ static void main_loop(int cmd_timeout)
 	sigemptyset(&ss);
 	sigaddset(&ss, SIGINT);
 	sigaddset(&ss, SIGTERM);
-	pthread_sigmask(SIG_UNBLOCK, &ss, NULL);
+	if (pthread_sigmask(SIG_UNBLOCK, &ss, NULL))
+		log_warn("WARNING: Failed to unblock SIGCHLD.");
 	/* Main loop */
 	while (!quit) {
 		fd_set in;
@@ -1731,11 +1732,12 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 	   SIGUSR2 (kills subthreads) */
 	sigemptyset(&ss);
 	sigaddset(&ss, SIGUSR1);
-	pthread_sigmask(SIG_BLOCK, &ss, NULL);
-
+	if (pthread_sigmask(SIG_BLOCK, &ss, NULL))
+		log_warn("WARNING: Failed to block SIGUSR1.");
 	sigdelset(&ss, SIGUSR1);
 	sigaddset(&ss, SIGUSR2);
-	pthread_sigmask(SIG_UNBLOCK, &ss, NULL);
+	if (pthread_sigmask(SIG_UNBLOCK, &ss, NULL))
+		log_warn("WARNING: Failed to unblock SIGUSR2.");
 
 	/* Loop around doing PRE and POST functions until the client goes away */
 	while (!client->bits.localsock.finished) {
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 62f403a..51e5866 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -663,14 +663,17 @@ void daemon_start(daemon_state s)
 		FD_SET(s.socket_fd, &in);
 
 		_reap(s, 0);
-		sigprocmask(SIG_SETMASK, &new_set, NULL);
+		if (sigprocmask(SIG_SETMASK, &new_set, NULL))
+			perror("sigprocmask error");
 		if (_shutdown_requested && !s.threads->next) {
-			sigprocmask(SIG_SETMASK, &old_set, NULL);
+			if (sigprocmask(SIG_SETMASK, &old_set, NULL))
+				perror("sigprocmask error");
 			INFO(&s, "%s shutdown requested", s.name);
 			break;
 		}
 		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);
-		sigprocmask(SIG_SETMASK, &old_set, NULL);
+		if (sigprocmask(SIG_SETMASK, &old_set, NULL))
+			perror("sigprocmask error");
 
 		if (ret < 0) {
 			if (errno != EINTR && errno != EAGAIN &&
diff --git a/tools/toollib.c b/tools/toollib.c
index 42179d9..0c1c095 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -59,7 +59,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 
 	log_verbose("Forking background process from command: %s", cmd->cmd_line);
 
-	sigaction(SIGCHLD, &act, NULL);
+	if (sigaction(SIGCHLD, &act, NULL))
+		log_warn("WARNING: Failed to set SIGCHLD action.");
 
 	if (!skip_lvm)
 		if (!sync_local_dev_names(cmd)) { /* Flush ops and reset dm cookie */


