From: okozina <okozina@fedoraproject.org>
Date: Mon,  8 Jun 2015 14:01:59 +0000 (UTC)
Subject: master - lvmetad.h: rephrase API descriptions
Message-ID: <20150608140159.1447561137@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b89ad7e2d4a5dd5e1947c2b14941f6a87d354451
Commit:        b89ad7e2d4a5dd5e1947c2b14941f6a87d354451
Parent:        3225f8d17596b79b76ed9da5291843d02a2aa7b6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 22 14:25:54 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Jun 8 16:01:32 2015 +0200

lvmetad.h: rephrase API descriptions

Some of descritpions were misleading at least. Some were completely
off the reality.

lvmetad_init doesn't re-establish or initialise a connection
lvmetad_active and lvmetad_connect_or_warn can do so.
---
 lib/cache/lvmetad.h |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 6769f76..395bc41 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -29,8 +29,7 @@ typedef int (*activation_handler) (struct cmd_context *cmd,
 
 #ifdef LVMETAD_SUPPORT
 /*
- * Initialise the communication with lvmetad. Normally called by
- * lvmcache_init. Sets up a global handle for our process.
+ * Sets up a global handle for our process.
  */
 void lvmetad_init(struct cmd_context *);
 
@@ -59,7 +58,9 @@ int lvmetad_socket_present(void);
 
 /*
  * Check whether lvmetad is active (where active means both that it is running
- * and that we have a working connection with it).
+ * and that we have a working connection with it). It opens new connection
+ * with lvmetad in the process when lvmetad is supposed to be used and the
+ * connection is not open yet.
  */
 int lvmetad_active(void);
 
@@ -70,8 +71,9 @@ int lvmetad_active(void);
 void lvmetad_connect_or_warn(void);
 
 /*
- * Drop connection to lvmetad. A subsequent lvmetad_init() will re-establish
- * the connection (possibly at a different socket path).
+ * Drop connection to lvmetad. A subsequent lvmetad_connect_or_warn or
+ * lvmetad_active will re-establish the connection (possibly at a
+ * different socket path).
  */
 void lvmetad_disconnect(void);
 


