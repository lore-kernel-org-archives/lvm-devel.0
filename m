From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:26 +0000 (UTC)
Subject: master - cleanup: put easier tests first
Message-ID: <20150413143926.1C3A160F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29467abe59a2027be838aca65368c03d43741b60
Commit:        29467abe59a2027be838aca65368c03d43741b60
Parent:        0b99d648ef2be558e43e36fd12e7304a2433b44f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 11:39:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:31 2015 +0200

cleanup: put easier tests first

If we could 'break' before calling strcmp() do it.
Use fputc for single char output (\n).
---
 lib/log/log.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 83e5be4..2d1fe74 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -299,13 +299,13 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		va_start(ap, format);
 		switch (level) {
 		case _LOG_DEBUG:
-			if ((verbose_level() == level) &&
-			    (strcmp("<backtrace>", format) == 0))
-				break;
 			if (verbose_level() < _LOG_DEBUG)
 				break;
 			if (!debug_class_is_logged(dm_errno_or_class))
 				break;
+			if ((verbose_level() == level) &&
+			    (strcmp("<backtrace>", format) == 0))
+				break;
 			/* fall through */
 		default:
 			/* Typically only log_warn goes to stdout */
@@ -333,7 +333,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		vfprintf(_log_file, trformat, ap);
 		va_end(ap);
 
-		fprintf(_log_file, "\n");
+		fputc('\n', _log_file);
 		fflush(_log_file);
 	}
 


