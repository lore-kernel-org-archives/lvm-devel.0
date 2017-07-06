From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 6 Jul 2017 09:55:15 -0400
Subject: master - lvmetad: Suppress accept error on clean shutdown
Message-ID: <201707061355.v66DtFQL021872@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdd00ecdd1fd51605be1b616d712a2220ced8875
Commit:        fdd00ecdd1fd51605be1b616d712a2220ced8875
Parent:        70c340dbc25523de18195a7916f27aa37b051e43
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 6 14:53:10 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 6 14:53:10 2017 +0100

lvmetad: Suppress accept error on clean shutdown

Also fix error message after pthread_create() error in handle_connect().
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3e72d83..062a440 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Suppress error message from accept() on clean lvmetad shutdown.
   Tidy clvmd client list processing and fix segfaults.
   Protect clvmd debug log messages with mutex and add client id.
   Fix shellcheck reported issues for script files.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 10cc8f7..6fdf195 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -491,7 +491,8 @@ static int handle_connect(daemon_state s)
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
 	if (client.socket_fd < 0) {
-		ERROR(&s, "Failed to accept connection errno %d.", errno);
+		if (errno != EAGAIN || !_shutdown_requested)
+			ERROR(&s, "Failed to accept connection: %s.", strerror(errno));
 		return 0;
 	}
 
@@ -512,8 +513,8 @@ static int handle_connect(daemon_state s)
 	ts->s = s;
 	ts->client = client;
 
-	if (pthread_create(&ts->client.thread_id, NULL, _client_thread, ts)) {
-		ERROR(&s, "Failed to create client thread errno %d.", errno);
+	if ((errno = pthread_create(&ts->client.thread_id, NULL, _client_thread, ts))) {
+		ERROR(&s, "Failed to create client thread: %s.", strerror(errno));
 		return 0;
 	}
 


