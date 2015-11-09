From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 13:05:36 +0000 (UTC)
Subject: master - libdaemon: prohibit use of %d for 64bit numbres
Message-ID: <20151109130536.6FDE560160@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36ee36734382b2aa845a435e27fa1fb834be1152
Commit:        36ee36734382b2aa845a435e27fa1fb834be1152
Parent:        0b5a75c9af1be5959ed946fea816aa642b5f918a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 14:03:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 14:03:25 2015 +0100

libdaemon: prohibit use of %d for 64bit numbres

Do not let pass %d and print internal error when found one.
Require all users to use  FMTd64 - it's seriously confusing.
---
 libdaemon/client/config-util.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index ec5ea98..bbf4218 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -38,7 +38,12 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 			goto fail;
 		}
 		keylen = strchr(next, '=') - next;
-		if (strstr(next, "%d") || strstr(next, FMTd64)) {
+		if (strstr(next, "%d")) {
+                        /* Use of plain %d is prohibited, use  FMTd64 */
+			log_error(INTERNAL_ERROR "Do not use  %%d and use correct 64bit form");
+			goto fail;
+		}
+		if (strstr(next, FMTd64)) {
 			value = va_arg(ap, int64_t);
 			if (dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value) < 0)
 				goto fail;


