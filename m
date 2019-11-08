From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:14:58 -0500
Subject: stable-2.02 - daemon: better error path handling for shutdown
Message-ID: <201911081414.xA8EEwlt008297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9b2148dab3a1f501637b628978c93be4d2be086
Commit:        e9b2148dab3a1f501637b628978c93be4d2be086
Parent:        34bde8b6c7e517239a05334683a09f2b5075fdcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:07:06 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 15:12:51 2019 +0100

daemon: better error path handling for shutdown

Report errors for open in better order.
Ensure descriptors are not leaked.
---
 libdaemon/server/daemon-server.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 51e5866..aa9ff2a 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -513,20 +513,23 @@ static int _handle_connect(daemon_state s)
 	socklen_t sl = sizeof(sockaddr);
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
-	if (client.socket_fd < 0 || _shutdown_requested) {
-		if (errno != EAGAIN || !_shutdown_requested)
+	if (client.socket_fd < 0) {
+		if (errno != EAGAIN)
 			ERROR(&s, "Failed to accept connection: %s.", strerror(errno));
-		return 0;
+		goto bad;
+	}
+
+	if (_shutdown_requested) {
+		ERROR(&s, "Shutdown requested.");
+		goto bad;
 	}
 
-	 if (fcntl(client.socket_fd, F_SETFD, FD_CLOEXEC))
+	if (fcntl(client.socket_fd, F_SETFD, FD_CLOEXEC))
 		WARN(&s, "setting CLOEXEC on client socket fd %d failed", client.socket_fd);
 
 	if (!(ts = dm_malloc(sizeof(thread_state)))) {
-		if (close(client.socket_fd))
-			perror("close");
 		ERROR(&s, "Failed to allocate thread state");
-		return 0;
+		goto bad;
 	}
 
 	ts->next = s.threads->next;
@@ -538,10 +541,16 @@ static int _handle_connect(daemon_state s)
 
 	if ((errno = pthread_create(&ts->client.thread_id, NULL, _client_thread, ts))) {
 		ERROR(&s, "Failed to create client thread: %s.", strerror(errno));
-		return 0;
+		ts->active = 0;
+		goto bad;
 	}
 
 	return 1;
+bad:
+	if ((client.socket_fd >= 0) && close(client.socket_fd))
+		perror("close");
+
+	return 0;
 }
 
 static void _reap(daemon_state s, int waiting)


