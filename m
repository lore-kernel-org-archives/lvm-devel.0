From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Feb 2016 09:22:48 +0000 (UTC)
Subject: master - coverity: helping coverity with NULL pointer
Message-ID: <20160226092248.A8A8D60DC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2988fa3c21cf84071446bc11cb61d5b8507c088c
Commit:        2988fa3c21cf84071446bc11cb61d5b8507c088c
Parent:        85a593c1911f5c7ef5a8de38178b085c02ad3965
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 10:15:24 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 26 10:21:36 2016 +0100

coverity: helping coverity with NULL pointer

Helping with understanding we will not try to deref NULL pointer,
as if the sizes are initialized to NULL it also means 'mem' would
be NULL, but thats too hard to model so make it obvious.
---
 libdaemon/client/config-util.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 7a7dfed..e262182 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -366,9 +366,9 @@ int buffer_append(struct buffer *buf, const char *string)
 {
 	int len = strlen(string);
 
-	if ((buf->allocated - buf->used <= len) &&
+	if ((!buf->mem || (buf->allocated - buf->used <= len)) &&
 	    !buffer_realloc(buf, len + 1))
-                return 0;
+		return 0;
 
 	strcpy(buf->mem + buf->used, string);
 	buf->used += len;


