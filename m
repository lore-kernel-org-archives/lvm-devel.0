From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:45 +0000 (UTC)
Subject: master - lvmetad: add check for failure dm_config_write_node
Message-ID: <20121215162545.0411CAAB82@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e8dbfaecf5168ff8717e3eebabee06c27b44fe6
Commit:        3e8dbfaecf5168ff8717e3eebabee06c27b44fe6
Parent:        4008f4f891c948c1629ed0ee50e04d4c26001d0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:36:27 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

lvmetad: add check for failure dm_config_write_node

Detect if dm_config_write_node failed and fail correctly.
---
 WHATS_NEW                        |    1 +
 libdaemon/client/daemon-client.c |    5 ++++-
 libdaemon/server/daemon-server.c |    3 ++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 701d502..b9cdfa7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Check for memory failure of dm_config_write_node() in lvmetad.
   Fix socket leak on error path in lvmetad's handle_connect.
   Check for failing id_read_format() in _pv_populate_lvmcache.
   Fix memleak on error path for lvmetad's pv_found.
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 53bfa86..371dc5c 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -77,7 +77,10 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 	buffer = rq.buffer;
 
 	if (!buffer.mem)
-		dm_config_write_node(rq.cft->root, buffer_line, &buffer);
+		if (!dm_config_write_node(rq.cft->root, buffer_line, &buffer)) {
+			reply.error = ENOMEM;
+			return reply;
+		}
 
 	assert(buffer.mem);
 	if (!buffer_write(h.socket_fd, &buffer))
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3c84e11..0237465 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -392,7 +392,8 @@ static void *client_thread(void *baton)
 			res = b->s.handler(b->s, b->client, req);
 
 		if (!res.buffer.mem) {
-			dm_config_write_node(res.cft->root, buffer_line, &res.buffer);
+			if (!dm_config_write_node(res.cft->root, buffer_line, &res.buffer))
+				goto fail;
 			if (!buffer_append(&res.buffer, "\n\n"))
 				goto fail;
 			dm_config_destroy(res.cft);


