From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 22:36:37 +0000 (UTC)
Subject: master - libdaemon: Fix a subtle race in worker thread creation.
Message-ID: <20131009223637.AD144610C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d299ecbb3a56f1633f17f746f864c02cd344c85
Commit:        7d299ecbb3a56f1633f17f746f864c02cd344c85
Parent:        cb613d4c101d7e9f51d70d55c1c71a471e6588ab
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 22:20:36 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 10 00:34:35 2013 +0200

libdaemon: Fix a subtle race in worker thread creation.

---
 libdaemon/server/daemon-server.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index df2c852..b114b9f 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -381,6 +381,7 @@ static void *client_thread(void *baton)
 	request req;
 	response res;
 
+	b->client.thread_id = pthread_self();
 	buffer_init(&req.buffer);
 
 	while (1) {
@@ -431,6 +432,7 @@ static int handle_connect(daemon_state s)
 	struct sockaddr_un sockaddr;
 	client_handle client = { .thread_id = 0 };
 	socklen_t sl = sizeof(sockaddr);
+	pthread_t tid;
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
 	if (client.socket_fd < 0)
@@ -446,10 +448,10 @@ static int handle_connect(daemon_state s)
 	baton->s = s;
 	baton->client = client;
 
-	if (pthread_create(&baton->client.thread_id, NULL, client_thread, baton))
+	if (pthread_create(&tid, NULL, client_thread, baton))
 		return 0;
 
-	pthread_detach(baton->client.thread_id);
+	pthread_detach(tid);
 
 	return 1;
 }


