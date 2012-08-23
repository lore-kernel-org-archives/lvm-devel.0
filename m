From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:07 +0000 (UTC)
Subject: master - lvmetad: fix memleak on error path
Message-ID: <20120823124207.B9D08A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3685701529e0d25a17a7fd7874e276fc441cad7c
Commit:        3685701529e0d25a17a7fd7874e276fc441cad7c
Parent:        8edc0e450da2c0959c44da4811901782cc399649
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 23 11:00:02 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:33:27 2012 +0200

lvmetad: fix memleak on error path

Release allocated buffer on error path.
---
 libdaemon/server/daemon-server.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index c69da36..27a3a05 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -400,8 +400,10 @@ static void *client_thread(void *baton)
 
 		if (!res.buffer) {
 			dm_config_write_node(res.cft->root, buffer_line, &res);
-			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL))
+			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL)) {
+				dm_free(req.buffer);
 				goto fail;
+			}
 			dm_config_destroy(res.cft);
 		}
 


