From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 19 Aug 2016 16:00:03 +0000 (UTC)
Subject: master - libdaemon: add errno to error message
Message-ID: <20160819160003.3F967601A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf0eaafa6b81a271d40031b337c614bb9b56159a
Commit:        bf0eaafa6b81a271d40031b337c614bb9b56159a
Parent:        e192fde6878a0e32316125b2e4c9813f4a95bede
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 19 10:59:46 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 19 10:59:46 2016 -0500

libdaemon: add errno to error message

---
 libdaemon/server/daemon-server.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 4d65466..0e37dfb 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -491,7 +491,7 @@ static int handle_connect(daemon_state s)
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
 	if (client.socket_fd < 0) {
-		ERROR(&s, "Failed to accept connection.");
+		ERROR(&s, "Failed to accept connection errno %d.", errno);
 		return 0;
 	}
 
@@ -513,7 +513,7 @@ static int handle_connect(daemon_state s)
 	ts->client = client;
 
 	if (pthread_create(&ts->client.thread_id, NULL, _client_thread, ts)) {
-		ERROR(&s, "Failed to create client thread.");
+		ERROR(&s, "Failed to create client thread errno %d.", errno);
 		return 0;
 	}
 


