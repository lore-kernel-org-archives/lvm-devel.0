From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Apr 2019 06:59:07 -0400
Subject: master - libdaemon: use pselect to avoid condition checking race
Message-ID: <201904161059.x3GAx74S016965@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44cfa558437634c15ec6da38507e73b4c86837c1
Commit:        44cfa558437634c15ec6da38507e73b4c86837c1
Parent:        116bd314cb8bb169336b2a14ff5ced78d9de9047
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 10 12:50:53 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 16 12:18:34 2019 +0200

libdaemon: use pselect to avoid condition checking race

To avoid tiny race on checking arrival of signal and entering select
(that can latter remain stuck as signal was already delivered) switch
to use  pselect().

If it would needed, we can eventually add extra code for older systems
without pselect(), but there are probably no such ancient systems in
use.
---
 WHATS_NEW                        |    1 +
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 libdaemon/server/daemon-server.c |   38 ++++++++++++++++++++++++++++----------
 libdaemon/server/daemon-server.h |    2 +-
 4 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f0c6ae..6ab973d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
   Skip autoactivation for a PV when PV size does not match device size.
   Remove first-pvscan-initialization which should no longer be needed.
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 3aac65f..af98843 100644
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
index a2216ac..e4ff8a1 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -85,7 +85,7 @@ static int _is_idle(daemon_state s)
 	return s.idle && s.idle->is_idle && !s.threads->next;
 }
 
-static struct timeval *_get_timeout(daemon_state s)
+static struct timespec *_get_timeout(daemon_state s)
 {
 	return s.idle ? s.idle->ptimeout : NULL;
 }
@@ -94,7 +94,7 @@ static void _reset_timeout(daemon_state s)
 {
 	if (s.idle) {
 		s.idle->ptimeout->tv_sec = 1;
-		s.idle->ptimeout->tv_usec = 0;
+		s.idle->ptimeout->tv_nsec = 0;
 	}
 }
 
@@ -559,6 +559,8 @@ void daemon_start(daemon_state s)
 	thread_state _threads = { .next = NULL };
 	unsigned timeout_count = 0;
 	fd_set in;
+	sigset_t new_set, old_set;
+	int ret;
 
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
@@ -626,8 +628,7 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
-	/*
-	 * Use daemon_main for daemon-specific init and polling, or
+	/*                                                                               	 * Use daemon_main for daemon-specific init and polling, or
 	 * use daemon_init for daemon-specific init and generic lib polling.
 	 */
 
@@ -641,22 +642,39 @@ void daemon_start(daemon_state s)
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
index f8c0ca6..18fd3ad 100644
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


