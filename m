From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:11 +0000 (GMT)
Subject: main - log: also build without systemd_journal_support
Message-ID: <20211014213711.EE1A73858433@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bd5388b16e2a14285ecd91ebf9f5537b5b303cc
Commit:        0bd5388b16e2a14285ecd91ebf9f5537b5b303cc
Parent:        b73e1cd4b3edb5dabc631cca78f780012beb93fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 20:50:01 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

log: also build without systemd_journal_support

---
 lib/log/log.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/lib/log/log.c b/lib/log/log.c
index f9568792f..7b4d537b3 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -25,7 +25,10 @@
 #include <syslog.h>
 #include <ctype.h>
 #include <time.h>
+
+#ifdef SYSTEMD_JOURNAL_SUPPORT
 #include <systemd/sd-journal.h>
+#endif
 
 static FILE *_log_file;
 static char _log_file_path[PATH_MAX];
@@ -622,6 +625,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 
       log_it:
 
+#ifdef SYSTEMD_JOURNAL_SUPPORT
 	if (_log_journal) {
 		int to_journal = 0;
 
@@ -647,6 +651,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 			va_end(ap);
 		}
 	}
+#endif
 
 	if (!logged_via_report && ((verbose_level() >= level) && !_log_suppress)) {
 		if (verbose_level() > _LOG_DEBUG) {
@@ -858,6 +863,7 @@ void log_set_report_object_name_and_id(const char *name, const char *id)
 
 void log_command(const char *cmd_line, const char *cmd_name, const char *cmd_id)
 {
+#ifdef SYSTEMD_JOURNAL_SUPPORT
 	if (_log_journal & LOG_JOURNAL_COMMAND) {
 
 		/*
@@ -875,6 +881,7 @@ void log_command(const char *cmd_line, const char *cmd_name, const char *cmd_id)
 				"PRIORITY=%i", LOG_INFO,
 				NULL);
 	}
+#endif
 }
 
 uint32_t log_journal_str_to_val(const char *str)


