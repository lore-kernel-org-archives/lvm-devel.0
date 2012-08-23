From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:10 +0000 (UTC)
Subject: master - lvmetad: do not deref NULL pointer
Message-ID: <20120823124210.4686DA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed53b4b6740973411acee52a31fca9c48c585dab
Commit:        ed53b4b6740973411acee52a31fca9c48c585dab
Parent:        3685701529e0d25a17a7fd7874e276fc441cad7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 23 11:01:00 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:34:54 2012 +0200

lvmetad: do not deref NULL pointer

Call log only for req.cft != NULL.
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dc3b29e..1dcc5c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98
 =================================
+  Fix dereference of NULL in lvmetad error path logging.
   Fix buffer memory leak in lvmetad logging.
   Use 'ignore' discards for thin metadata created with older versions.
   Use proper condition to check for unsupported discards settings.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 27a3a05..df75ac7 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -389,10 +389,12 @@ static void *client_thread(void *baton)
 			goto fail;
 
 		req.cft = dm_config_from_string(req.buffer);
+
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
+		else
+			daemon_log_cft(b->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 
-		daemon_log_cft(b->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 		res = builtin_handler(b->s, b->client, req);
 
 		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */


