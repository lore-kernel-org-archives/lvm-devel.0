From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:09 +0000 (UTC)
Subject: master - lvmetad: move initialization in the inner loop
Message-ID: <20121013172209.C07F522CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88c547d1ca83426f4de5371baac885f5500b5487
Commit:        88c547d1ca83426f4de5371baac885f5500b5487
Parent:        7c7ab99843837bd9099ea502c8a34c05fad495c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:15:15 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:15:15 2012 +0200

lvmetad: move initialization in the inner loop

Set append to NULL in the front of cycle, so the INTERNAL error path
is not leading to double-free of append pointer.
---
 libdaemon/client/config-util.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 9b893c6..1f4b55b 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -23,7 +23,7 @@
 
 int buffer_append_vf(struct buffer *buf, va_list ap)
 {
-	char *append = NULL;
+	char *append;
 	char *next;
 	int keylen;
 	int64_t value;
@@ -31,6 +31,7 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 	char *block;
 
 	while ((next = va_arg(ap, char *))) {
+		append = NULL;
 		if (!strchr(next, '=')) {
 			log_error(INTERNAL_ERROR "Bad format string at '%s'", next);
 			goto fail;


