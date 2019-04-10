From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Apr 2019 07:31:25 -0400
Subject: stable-2.02 - libdaemon: use pselect to avoid condition checking race
Message-ID: <201904101131.x3ABVPw8014117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d4f36c2c7f782af31eca7eca63310791a4f8e93
Commit:        6d4f36c2c7f782af31eca7eca63310791a4f8e93
Parent:        63289b54c787fbc4f254b1d1144e147a12402d4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 10 12:50:53 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 10 13:28:45 2019 +0200

libdaemon: use pselect to avoid condition checking race

To avoid tiny race on checking arrival of signal and entering select
(that can latter remain stuck as signal was already delivered) switch
to use  pselect().

If it would needed, we can eventually add extra code for older systems
without pselect(), but there are probably no such ancient systems in
use.
---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/lvmetad-core.c   |    2 +-
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 libdaemon/server/daemon-server.c |   38 ++++++++++++++++++++++++++++----------
 libdaemon/server/daemon-server.h |    2 +-
 5 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 814873e..b15ffa3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
 
 Version 2.02.184 - 22nd March 2019
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 72473d7..9ae359b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2953,7 +2953,7 @@ static void usage(const char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	signed char opt;
-	struct timeval timeout;
+	struct timespec timeout;
 	daemon_idle di = { .ptimeout = &timeout };
 	lvmetad_state ls = { .log_config = "" };
 	daemon_state s = {
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index fd73272..f1056c3 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -915,7 +915,7 @@ int main(int argc, char *argv[])
 	int option_index = 0;
 	int client = 0, server = 0;
 	unsigned action = ACTION_MAX;
-	struct timeval timeout;
+	struct timespec timeout;
 	daemon_idle di = { .ptimeout = &timeout };
 	struct lvmpolld_state ls = { .log_config = "" };
 	daemon_state s = {
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3b19883..c61683a 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -87,7 +87,7 @@ static int _is_idle(daemon_state s)
 	return s.idle && s.idle->is_idle && !s.threads->next;
 }
 
-static struct timeval *_get_timeout(daemon_state s)
+static struct timespec *_get_timeout(daemon_state s)
 {
 	return s.idle ? s.idle->ptimeout : NULL;
 }
@@ -96,7 +96,7 @@ static void _reset_timeout(daemon_state s)
 {
 	if (s.idle) {
 		s.idle->ptimeout->tv_sec = 1;
-		s.idle->ptimeout->tv_usec = 0;
+		s.idle->ptimeout->tv_nsec = 0;
 	}
 }
 
@@ -561,6 +561,8 @@ void daemon_start(daemon_state s)
 	thread_state _threads = { .next = NULL };
 	unsigned timeout_count = 0;
 	fd_set in;
+	sigset_t new_set, old_set;
+	int ret;
 
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
@@ -628,8 +630,7 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
-	/*
-	 * Use daemon_main for daemon-specific init and polling, or
+	/*                                                                               	 * Use daemon_main for daemon-specific init and polling, or
 	 * use daemon_init for daemon-specific init and generic lib polling.
 	 */
 
@@ -643,22 +644,39 @@ void daemon_start(daemon_state s)
 		if (!s.daemon_init(&s))
 			failed = 1;
 
+	if (s.socket_fd >= FD_SETSIZE)
+		failed = 1; /* FD out of available selectable set */
+
+	sigfillset(&new_set);
+	sigprocmask(SIG_SETMASK, NULL, &old_set);
+
 	while (!failed) {
 		_reset_timeout(s);
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
-		if (select(FD_SETSIZE, &in, NULL, NULL, _get_timeout(s)) < 0 && errno != EINTR)
-			perror("select error");
+
+		sigprocmask(SIG_SETMASK, &new_set, NULL);
+		if (_shutdown_requested && !s.threads->next) {
+			sigprocmask(SIG_SETMASK, &old_set, NULL);
+			INFO(&s, "shutdown requested", s.name);
+			break;
+		}
+		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);
+		sigprocmask(SIG_SETMASK, &old_set, NULL);
+
+		if (ret < 0) {
+			if (errno != EINTR && errno != EAGAIN &&
+			    (EWOULDBLOCK == EAGAIN || errno != EWOULDBLOCK))
+				perror("select error");
+			continue;
+		}
+
 		if (FD_ISSET(s.socket_fd, &in)) {
 			timeout_count = 0;
 			_handle_connect(s);
 		}
-
 		_reap(s, 0);
 
-		if (_shutdown_requested && !s.threads->next)
-			break;
-
 		/* s.idle == NULL equals no shutdown on timeout */
 		if (_is_idle(s)) {
 			DEBUGLOG(&s, "timeout occured");
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index 2b9ceac..e77ac20 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -47,7 +47,7 @@ struct timeval;
 typedef struct {
 	volatile unsigned is_idle;
 	unsigned max_timeouts;
-	struct timeval *ptimeout;
+	struct timespec *ptimeout;
 } daemon_idle;
 
 struct daemon_state;


