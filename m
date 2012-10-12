From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 08:59:56 +0000 (UTC)
Subject: master - lvmetad: validate dm_asprintf in buffer_append_vf
Message-ID: <20121012085956.877E2172E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2a5d3ae3a457059bc7de7cf3fce8eb092ac03dd
Commit:        f2a5d3ae3a457059bc7de7cf3fce8eb092ac03dd
Parent:        5c792f620b3448a6bbbe7dc10f9210ad3383d977
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 10:57:01 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 10:59:10 2012 +0200

lvmetad: validate dm_asprintf in buffer_append_vf

Check result of dm_asprintf
Check buffer_append result
Declare vars in front
---
 libdaemon/client/config-util.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index a65a2cc..8a6dced 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -23,9 +23,12 @@
 
 int buffer_append_vf(struct buffer *buf, va_list ap)
 {
-	char *append;
+	char *append = NULL;
 	char *next;
 	int keylen;
+	int64_t value;
+	char *string;
+	char *block;
 
 	while ((next = va_arg(ap, char *))) {
 		if (!strchr(next, '=')) {
@@ -34,21 +37,25 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 		}
 		keylen = strchr(next, '=') - next;
 		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
-			int64_t value = va_arg(ap, int64_t);
-			dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value);
+			value = va_arg(ap, int64_t);
+			if (!dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value) < 0)
+				goto fail;
 		} else if (strstr(next, "%s")) {
-			char *value = va_arg(ap, char *);
-			dm_asprintf(&append, "%.*s= \"%s\"\n", keylen, next, value);
+			string = va_arg(ap, char *);
+			if (!dm_asprintf(&append, "%.*s= \"%s\"\n", keylen, next, string) < 0)
+				goto fail;
 		} else if (strstr(next, "%b")) {
-			char *block = va_arg(ap, char *);
-			if (!block)
+			if (!(block = va_arg(ap, char *)))
 				continue;
-			dm_asprintf(&append, "%.*s%s", keylen, next, block);
-		} else {
-			dm_asprintf(&append, "%s", next);
-		}
-		if (!append) goto fail;
-		buffer_append(buf, append);
+			if (!dm_asprintf(&append, "%.*s%s", keylen, next, block) < 0)
+				goto fail;
+		} else if (!dm_asprintf(&append, "%s", next) < 0)
+			goto fail;
+
+		if (!append ||
+		    !buffer_append(buf, append))
+			return 0;
+
 		dm_free(append);
 	}
 


