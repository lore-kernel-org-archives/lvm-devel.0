From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 23 Jun 2016 12:22:18 +0000 (UTC)
Subject: master - log: move original print_log code to _vprint_log and make print_log a wrapper over _vprint_log
Message-ID: <20160623122218.476F860C5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=082dee738aea58800a6ec6d0c864fa68c5dfc629
Commit:        082dee738aea58800a6ec6d0c864fa68c5dfc629
Parent:        79eaaee50af92d2fd6f6590670787c87b9ce0225
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 23 13:39:38 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 23 14:21:06 2016 +0200

log: move original print_log code to _vprint_log and make print_log a wrapper over _vprint_log

Move code from original print_log fn to a separate _vprint_log function
that accepts va_list and make print_log a wrapper over _vprint_log.
The print_log just initializes the va_list and uses it for _vprint_log
call now. This way, we can reuse _vprint_log if needed.
---
 lib/log/log.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 0d253e7..d29628e 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -306,10 +306,10 @@ const char *log_get_report_object_type_name(log_report_object_type_t object_type
 	return log_object_type_names[object_type];
 }
 
-void print_log(int level, const char *file, int line, int dm_errno_or_class,
-	       const char *format, ...)
+__attribute__ ((format(printf, 5, 0)))
+static void _vprint_log(int level, const char *file, int line, int dm_errno_or_class,
+			const char *format, va_list ap)
 {
-	va_list ap;
 	char buf[1024], message[4096];
 	int bufused, n;
 	const char *trformat;		/* Translated format string */
@@ -360,9 +360,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
 	    (_log_report.report && !log_bypass_report && (use_stderr || (level <=_LOG_WARN))) ||
 	    log_once) {
-		va_start(ap, format);
 		n = vsnprintf(message, sizeof(message), trformat, ap);
-		va_end(ap);
 
 		/* When newer glibc returns >= sizeof(locn), we will just log what
                  * has fit into buffer, it's '\0' terminated string */
@@ -445,7 +443,6 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 			default: /* nothing to do */;
 			}
 
-		va_start(ap, format);
 		switch (level) {
 		case _LOG_DEBUG:
 			if (verbose_level() < _LOG_DEBUG)
@@ -466,7 +463,6 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 			vfprintf(stream, trformat, ap);
 			fputc('\n', stream);
 		}
-		va_end(ap);
 	}
 
 	if ((level > debug_level()) ||
@@ -480,19 +476,14 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
 
-		va_start(ap, format);
 		vfprintf(_log_file, trformat, ap);
-		va_end(ap);
 
 		fputc('\n', _log_file);
 		fflush(_log_file);
 	}
 
-	if (_syslog && (_log_while_suspended || !critical_section())) {
-		va_start(ap, format);
+	if (_syslog && (_log_while_suspended || !critical_section()))
 		vsyslog(level, trformat, ap);
-		va_end(ap);
-	}
 
 	if (fatal_internal_error)
 		abort();
@@ -509,10 +500,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 
 		bufused += n;		/* n does not include '\0' */
 
-		va_start(ap, format);
 		n = vsnprintf(buf + bufused, sizeof(buf) - bufused,
 			      trformat, ap);
-		va_end(ap);
 
 		if (n < 0)
 			goto done;
@@ -529,6 +518,16 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	}
 }
 
+void print_log(int level, const char *file, int line, int dm_errno_or_class,
+	       const char *format, ...)
+{
+	va_list ap;
+
+	va_start(ap, format);
+	_vprint_log(level, file, line, dm_errno_or_class, format, ap);
+	va_end(ap);
+}
+
 log_report_t log_get_report_state(void)
 {
 	return _log_report;


