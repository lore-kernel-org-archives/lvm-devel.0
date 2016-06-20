From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Jun 2016 18:26:10 +0000 (UTC)
Subject: master - lvmetad: process new connections after shutdown signal
Message-ID: <20160620182610.8FF0D60CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b12961e7ebd6fb29d760daafd3c16e4ba3e54e80
Commit:        b12961e7ebd6fb29d760daafd3c16e4ba3e54e80
Parent:        6ae22125c62ddea4340916a5e255d55844bfd087
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 20 13:19:02 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 20 13:19:02 2016 -0500

lvmetad: process new connections after shutdown signal

Currently, a shutdown signal will cause lvmetad to quit
responding to new connections, but not actually exit until
all connections are gone.  If a program is maintaining a
long running connection (e.g. lvmlockd, or even an lvm
command) when lvmetad gets a shutdown signal, then all
further commands will hang indefinately waiting for a
response that won't be sent.

With this patch, make lvmetad continue handling new
connections even after a shutdown signal.  It will exit
once all connections are gone.
---
 libdaemon/server/daemon-server.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index d18bd4b..7911dd6 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -490,8 +490,10 @@ static int handle_connect(daemon_state s)
 	socklen_t sl = sizeof(sockaddr);
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
-	if (client.socket_fd < 0)
+	if (client.socket_fd < 0) {
+		ERROR(&s, "Failed to accept connection.");
 		return 0;
+	}
 
 	 if (fcntl(client.socket_fd, F_SETFD, FD_CLOEXEC))
 		WARN(&s, "setting CLOEXEC on client socket fd %d failed", client.socket_fd);
@@ -510,8 +512,10 @@ static int handle_connect(daemon_state s)
 	ts->s = s;
 	ts->client = client;
 
-	if (pthread_create(&ts->client.thread_id, NULL, client_thread, ts))
+	if (pthread_create(&ts->client.thread_id, NULL, client_thread, ts)) {
+		ERROR(&s, "Failed to create client thread.");
 		return 0;
+	}
 
 	return 1;
 }
@@ -622,7 +626,7 @@ void daemon_start(daemon_state s)
 		if (!s.daemon_init(&s))
 			failed = 1;
 
-	while (!_shutdown_requested && !failed) {
+	while (!failed) {
 		_reset_timeout(s);
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
@@ -630,12 +634,14 @@ void daemon_start(daemon_state s)
 			perror("select error");
 		if (FD_ISSET(s.socket_fd, &in)) {
 			timeout_count = 0;
-			if (!_shutdown_requested && !handle_connect(s))
-				ERROR(&s, "Failed to handle a client connection.");
+			handle_connect(s);
 		}
 
 		reap(s, 0);
 
+		if (_shutdown_requested && !s.threads->next)
+			break;
+
 		/* s.idle == NULL equals no shutdown on timeout */
 		if (_is_idle(s)) {
 			DEBUGLOG(&s, "timeout occured");


