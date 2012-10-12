From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 08:59:54 +0000 (UTC)
Subject: master - lvmetad: check result of buffer_realloc
Message-ID: <20121012085954.49537172E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c792f620b3448a6bbbe7dc10f9210ad3383d977
Commit:        5c792f620b3448a6bbbe7dc10f9210ad3383d977
Parent:        c4dcbf67a3d19bf4a91b4b72e3e230583a8ee2da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 10:50:07 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 10:59:10 2012 +0200

lvmetad: check result of buffer_realloc

---
 libdaemon/client/config-util.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 8aa9ed2..a65a2cc 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -289,8 +289,9 @@ int buffer_append(struct buffer *buf, const char *string)
 {
 	int len = strlen(string);
 
-	if (buf->allocated - buf->used <= len)
-		buffer_realloc(buf, len + 1);
+	if ((buf->allocated - buf->used <= len) &&
+	    !buffer_realloc(buf, len + 1))
+                return 0;
 
 	strcpy(buf->mem + buf->used, string);
 	buf->used += len;


