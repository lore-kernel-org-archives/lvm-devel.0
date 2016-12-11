From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:49 +0000 (UTC)
Subject: master - libdm: validate vsnprintf
Message-ID: <20161211223449.84E466038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f84d3c69cdc161508fcc29e82f1167334466084
Commit:        6f84d3c69cdc161508fcc29e82f1167334466084
Parent:        3903f915f83634f91946550fda85d60b72ce3a88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 22:54:08 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:17 2016 +0100

libdm: validate vsnprintf

Avoid using buffer when no output has been generated.
Missed in ee13f265f043b47a1b023321fb9e8470fb5703c1.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 73707b6..f402113 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Validation vsnprintf result in runtime translate of dm_log (1.02.136).
   Separate filemap extent allocation from region table.
   Fix segmentation fault when filemap region creation fails
   Fix performance of region cleanup for failed filemap creation.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 476f018..d8cf946 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -173,14 +173,16 @@ static void _log_to_default_log(int level,
 	    const char *file, int line, int dm_errno_or_class,
 	    const char *f, ...)
 {
+	int n;
 	va_list ap;
 	char buf[2 * PATH_MAX + 256]; /* big enough for most messages */
 
 	va_start(ap, f);
-	vsnprintf(buf, sizeof(buf), f, ap);
+	n = vsnprintf(buf, sizeof(buf), f, ap);
 	va_end(ap);
 
-	dm_log(level, file, line, "%s", buf);
+	if (n > 0) /* Could be truncated */
+		dm_log(level, file, line, "%s", buf);
 }
 
 /*
@@ -195,14 +197,16 @@ __attribute__((format(printf, 4, 5)))
 static void _log_to_default_log_with_errno(int level,
 	    const char *file, int line, const char *f, ...)
 {
+	int n;
 	va_list ap;
 	char buf[2 * PATH_MAX + 256]; /* big enough for most messages */
 
 	va_start(ap, f);
-	vsnprintf(buf, sizeof(buf), f, ap);
+	n = vsnprintf(buf, sizeof(buf), f, ap);
 	va_end(ap);
 
-	dm_log_with_errno(level, file, line, 0, "%s", buf);
+	if (n > 0) /* Could be truncated */
+		dm_log_with_errno(level, file, line, 0, "%s", buf);
 }
 
 void dm_log_init(dm_log_fn fn)


