From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:20 +0000 (UTC)
Subject: master - libdm-common.c: remove trailing whitespace
Message-ID: <20150512152220.BE8E060403@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=257f7febc7e94f1e5b76593387f8791ac8c1b65d
Commit:        257f7febc7e94f1e5b76593387f8791ac8c1b65d
Parent:        24a92e08c0d9b7b9a5333c4413f6e95900f966f8
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 15:28:38 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:49 2015 +0200

libdm-common.c: remove trailing whitespace

---
 libdm/libdm-common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index fa533f8..6f56c60 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -110,7 +110,7 @@ void dm_lib_init(void)
 __attribute__((format(printf, 5, 0)))
 static void _default_log_line(int level,
 	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno_or_class, 
+	    int line __attribute__((unused)), int dm_errno_or_class,
 	    const char *f, va_list ap)
 {
 	static int _abort_on_internal_errors = -1;
@@ -138,7 +138,7 @@ static void _default_log_line(int level,
 __attribute__((format(printf, 5, 6)))
 static void _default_log_with_errno(int level,
 	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno_or_class, 
+	    int line __attribute__((unused)), int dm_errno_or_class,
 	    const char *f, ...)
 {
 	va_list ap;


