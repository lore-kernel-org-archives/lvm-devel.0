From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:24 -0500
Subject: master - daemon: better error path handling for shutdown
Message-ID: <70008.119111116462000673@us-mta-285.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc865749ae443cca276ac411f302fd8989a843ef
Commit:        cc865749ae443cca276ac411f302fd8989a843ef
Parent:        43db8f8d5d7c773d4fe93f3bbf7ee03be4f6e36e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:07:06 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

daemon: better error path handling for shutdown

Report errors for open in better order.
Ensure descriptors are not leaked.
---
 libdaemon/server/daemon-server.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0b1810c..b45c0e5 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -505,19 +505,22 @@ static int _handle_connect(daemon_state s)
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
 	if (client.socket_fd < 0) {
-		if (errno != EAGAIN || !_shutdown_requested)
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
 
 	if (!(ts = malloc(sizeof(thread_state)))) {
-		if (close(client.socket_fd))
-			perror("close");
 		ERROR(&s, "Failed to allocate thread state");
-		return 0;
+		goto bad;
 	}
 
 	ts->next = s.threads->next;
@@ -529,10 +532,16 @@ static int _handle_connect(daemon_state s)
 
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



