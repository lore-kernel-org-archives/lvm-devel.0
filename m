From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:03 +0000 (UTC)
Subject: master - lvmetad: use dm_ malloc wrappers
Message-ID: <20130618201403.5FEEB60ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3d39217794731402cedddb9cbaebf75c08c97ba
Commit:        e3d39217794731402cedddb9cbaebf75c08c97ba
Parent:        25629688643958e12859af0d53e818b8b111b4a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 18 21:57:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:11:31 2013 +0200

lvmetad: use dm_ malloc wrappers

Use matching dm_ functions for internally used buffers.
---
 libdaemon/client/config-util.c   |    2 +-
 libdaemon/server/daemon-server.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 34d755f..d40e94c 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -286,7 +286,7 @@ int buffer_realloc(struct buffer *buf, int needed)
 		alloc = needed;
 
 	buf->allocated += alloc;
-	new = realloc(buf->mem, buf->allocated);
+	new = dm_realloc(buf->mem, buf->allocated);
 	if (new)
 		buf->mem = new;
 	else { /* utter failure */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 1db7ca7..df2c852 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -436,7 +436,7 @@ static int handle_connect(daemon_state s)
 	if (client.socket_fd < 0)
 		return 0;
 
-	if (!(baton = malloc(sizeof(struct thread_baton)))) {
+	if (!(baton = dm_malloc(sizeof(struct thread_baton)))) {
 		if (close(client.socket_fd))
 			perror("close");
 		ERROR(&s, "Failed to allocate thread baton");


