From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 09:37:46 +0000 (UTC)
Subject: master - lvmetad: fix test for dm_asprintf
Message-ID: <20121012093746.E381DA0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a958655ddd63a7e9feeda444788313f9380aef1
Commit:        5a958655ddd63a7e9feeda444788313f9380aef1
Parent:        d6d207006a8f337e9d6919ffddedfa08dac128c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 11:34:15 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 11:36:01 2012 +0200

lvmetad: fix test for dm_asprintf

---
 libdaemon/client/config-util.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 8a6dced..9b893c6 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -38,18 +38,18 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 		keylen = strchr(next, '=') - next;
 		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
 			value = va_arg(ap, int64_t);
-			if (!dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value) < 0)
+			if (dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value) < 0)
 				goto fail;
 		} else if (strstr(next, "%s")) {
 			string = va_arg(ap, char *);
-			if (!dm_asprintf(&append, "%.*s= \"%s\"\n", keylen, next, string) < 0)
+			if (dm_asprintf(&append, "%.*s= \"%s\"\n", keylen, next, string) < 0)
 				goto fail;
 		} else if (strstr(next, "%b")) {
 			if (!(block = va_arg(ap, char *)))
 				continue;
-			if (!dm_asprintf(&append, "%.*s%s", keylen, next, block) < 0)
+			if (dm_asprintf(&append, "%.*s%s", keylen, next, block) < 0)
 				goto fail;
-		} else if (!dm_asprintf(&append, "%s", next) < 0)
+		} else if (dm_asprintf(&append, "%s", next) < 0)
 			goto fail;
 
 		if (!append ||


