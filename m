From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:52 +0000 (UTC)
Subject: master - libdaemon-client: Fix a memory leak in daemon_send.
Message-ID: <20121009055252.AC9142473@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a19a5953433c86811df80c59de7ec6346c62be32
Commit:        a19a5953433c86811df80c59de7ec6346c62be32
Parent:        4b4c2833d984f6b6a8dde394168b4653cdd47863
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 18:35:30 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

libdaemon-client: Fix a memory leak in daemon_send.

---
 libdaemon/client/daemon-client.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index e34a2a0..c87856c 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -73,12 +73,13 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
 	daemon_reply reply = { .cft = NULL, .error = 0 };
 	assert(h.socket_fd >= 0);
+	char *buffer = rq.buffer;
 
-	if (!rq.buffer)
-		dm_config_write_node(rq.cft->root, buffer_line, &rq.buffer);
+	if (!buffer)
+		dm_config_write_node(rq.cft->root, buffer_line, &buffer);
 
-	assert(rq.buffer);
-	if (!write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer)))
+	assert(buffer);
+	if (!write_buffer(h.socket_fd, buffer, strlen(buffer)))
 		reply.error = errno;
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
@@ -88,6 +89,9 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 	} else
 		reply.error = errno;
 
+	if (buffer != rq.buffer)
+		dm_free(buffer);
+
 	return reply;
 }
 


