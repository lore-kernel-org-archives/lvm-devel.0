From: okozina <okozina@fedoraproject.org>
Date: Wed, 29 Apr 2015 15:12:32 +0000 (UTC)
Subject: master - libdaemon: introduce support for exit on idle
Message-ID: <20150429151232.ACCA3611BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0a62b8fdc8d041c14ca523643e319431b80126f
Commit:        e0a62b8fdc8d041c14ca523643e319431b80126f
Parent:        b120454b505f88719735fd1b653dec48816d6036
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Apr 29 16:59:30 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 29 17:10:44 2015 +0200

libdaemon: introduce support for exit on idle

works with systemd activated daemons only as of now

each daemon implementation may decide to signalize its
internal idle state (i.e. all background tasks unrelated to
client threads are finished)
---
 libdaemon/server/daemon-server.c |   41 ++++++++++++++++++++++++++++++++++++-
 libdaemon/server/daemon-server.h |   19 +++++++++++++++++
 2 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 5ccf4e9..1869956 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -80,6 +80,29 @@ static void _exit_handler(int sig __attribute__((unused)))
 
 #  include <stdio.h>
 
+static int _is_idle(daemon_state s)
+{
+	return _systemd_activation && s.idle && s.idle->is_idle && !s.threads->next;
+}
+
+static struct timeval *_get_timeout(daemon_state s)
+{
+	return (_systemd_activation && s.idle) ? s.idle->ptimeout : NULL;
+}
+
+static void _reset_timeout(daemon_state s)
+{
+	if (s.idle) {
+		s.idle->ptimeout->tv_sec = 1;
+		s.idle->ptimeout->tv_usec = 0;
+	}
+}
+
+static unsigned _get_max_timeouts(daemon_state s)
+{
+	return s.idle ? s.idle->max_timeouts : 0;
+}
+
 static int _set_oom_adj(const char *oom_adj_path, int val)
 {
 	FILE *fp;
@@ -513,6 +536,7 @@ void daemon_start(daemon_state s)
 	int failed = 0;
 	log_state _log = { { 0 } };
 	thread_state _threads = { .next = NULL };
+	unsigned timeout_count = 0;
 
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
@@ -583,15 +607,28 @@ void daemon_start(daemon_state s)
 			failed = 1;
 
 	while (!_shutdown_requested && !failed) {
+		_reset_timeout(s);
 		fd_set in;
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
-		if (select(FD_SETSIZE, &in, NULL, NULL, NULL) < 0 && errno != EINTR)
+		if (select(FD_SETSIZE, &in, NULL, NULL, _get_timeout(s)) < 0 && errno != EINTR)
 			perror("select error");
-		if (FD_ISSET(s.socket_fd, &in))
+		if (FD_ISSET(s.socket_fd, &in)) {
+			timeout_count = 0;
 			if (!_shutdown_requested && !handle_connect(s))
 				ERROR(&s, "Failed to handle a client connection.");
+		}
+
 		reap(s, 0);
+
+		/* s.idle == NULL equals no shutdown on timeout */
+		if (_is_idle(s)) {
+			DEBUGLOG(&s, "timeout occured");
+			if (++timeout_count >= _get_max_timeouts(s)) {
+				INFO(&s, "Inactive for %d seconds. Exiting.", timeout_count);
+				break;
+			}
+		}
 	}
 
 	INFO(&s, "%s waiting for client threads to finish", s.name);
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index a7673d4..820e5e0 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -35,6 +35,21 @@ typedef struct {
 	struct buffer buffer;
 } response;
 
+struct timeval;
+
+/*
+ * is_idle:	 daemon implementation sets it to true when no background task
+ *		 is running
+ * max_timeouts: how many seconds do daemon allow to be idle before it shutdowns
+ * ptimeout:	 internal variable passed to select(). has to be reset to 1 second
+ *		 before each select
+ */
+typedef struct {
+	volatile unsigned is_idle;
+	unsigned max_timeouts;
+	struct timeval *ptimeout;
+} daemon_idle;
+
 struct daemon_state;
 
 /*
@@ -98,6 +113,10 @@ typedef struct daemon_state {
 
 	log_state *log;
 	struct thread_state *threads;
+
+	/* suport for shutdown on idle */
+	daemon_idle *idle;
+
 	void *private; /* the global daemon state */
 } daemon_state;
 


