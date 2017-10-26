From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Oct 2017 08:05:48 -0400
Subject: master - log: better message when reached log limit
Message-ID: <201710261205.v9QC5msT008060@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=837bfab75c712c28c161309f1381bb7a84eb17fb
Commit:        837bfab75c712c28c161309f1381bb7a84eb17fb
Parent:        1758614f9648d4dfba91377336c60aaf3cc5265c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 26 13:55:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 26 14:04:58 2017 +0200

log: better message when reached log limit

Add explaining message, when command was aborted due to the reach
of configure line number count (LVM_LOG_FILE_MAX_LINES)
for logging (used mainly with testing).
---
 lib/log/log.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 8ca60e4..c0789b4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -646,11 +646,16 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		vfprintf(_log_file, trformat, ap);
 		va_end(ap);
 
+		if (_log_file_max_lines && ++_log_file_lines >= _log_file_max_lines) {
+			fprintf(_log_file, "\n%s:%d %sAborting. Command has reached limit "
+				"for logged lines (LVM_LOG_FILE_MAX_LINES=" FMTu64 ").",
+				file, line, _msg_prefix,
+				_log_file_max_lines);
+			fatal_internal_error = 1;
+		}
+
 		fputc('\n', _log_file);
 		fflush(_log_file);
-
-		if (_log_file_max_lines && ++_log_file_lines >= _log_file_max_lines)
-			fatal_internal_error = 1;
 	}
 
 	if (_syslog && (_log_while_suspended || !critical_section())) {


