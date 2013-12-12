From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:26 +0000 (UTC)
Subject: master - cleanup: simplify logging code
Message-ID: <20131212124326.66FF06038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b53e9ba66a53e68fdad7700bcccb9d38e24e39d6
Commit:        b53e9ba66a53e68fdad7700bcccb9d38e24e39d6
Parent:        877418b1a2edfba6903314797ab3676ec7f2385a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 26 13:50:44 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:27:59 2013 +0100

cleanup: simplify logging code

Condense code for logging.
---
 WHATS_NEW     |    1 +
 lib/log/log.c |   83 ++++++++++++++++----------------------------------------
 2 files changed, 25 insertions(+), 59 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e985922..0d6a9df 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Reodered and simplified logging code.
   Fix SYSTEMD_READY assignment for foreign devices in lvmetad udev rules.
   Disable online thin pool metadata resize for 1.9 kernel thin target.
   Shortened code for initialization of raid segment types.
diff --git a/lib/log/log.c b/lib/log/log.c
index 1af9616..194fdd3 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -199,6 +199,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	int log_once = level & _LOG_ONCE;
 	int fatal_internal_error = 0;
 	size_t msglen;
+	const char *indent_spaces = "";
+	FILE *stream;
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
@@ -278,76 +280,39 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	}
 
       log_it:
-	if (!_log_suppress) {
-		if (verbose_level() > _LOG_DEBUG)
-			(void) dm_snprintf(locn, sizeof(locn), "#%s:%d ",
+	if ((verbose_level() >= level) && !_log_suppress) {
+		if (verbose_level() > _LOG_DEBUG) {
+			(void) dm_snprintf(buf, sizeof(buf), "#%s:%d ",
 					   file, line);
-		else
-			locn[0] = '\0';
+		} else
+			buf[0] = '\0';
+
+		if (_indent)
+			switch (level) {
+			case _LOG_NOTICE: indent_spaces = "  "; break;
+			case _LOG_INFO:   indent_spaces = "    "; break;
+			case _LOG_DEBUG:  indent_spaces = "      "; break;
+			default: /* nothing to do */;
+			}
 
 		va_start(ap, format);
 		switch (level) {
 		case _LOG_DEBUG:
-			if (!strcmp("<backtrace>", format) &&
-			    verbose_level() <= _LOG_DEBUG)
+			if ((verbose_level() == level) &&
+			    (strcmp("<backtrace>", format) == 0))
 				break;
 			if (verbose_level() < _LOG_DEBUG)
 				break;
 			if (!debug_class_is_logged(dm_errno_or_class))
 				break;
-			fprintf(stderr, "%s%s%s", locn, log_command_name(),
-				_msg_prefix);
-			if (_indent)
-				fprintf(stderr, "      ");
-			vfprintf(stderr, trformat, ap);
-			fputc('\n', stderr);
-			break;
-
-		case _LOG_INFO:
-			if (verbose_level() >= _LOG_INFO) {
-				fprintf(stderr, "%s%s%s", locn, log_command_name(),
-					_msg_prefix);
-				if (_indent)
-					fprintf(stderr, "    ");
-				vfprintf(stderr, trformat, ap);
-				fputc('\n', stderr);
-			}
-			break;
-		case _LOG_NOTICE:
-			if (verbose_level() >= _LOG_NOTICE) {
-				fprintf(stderr, "%s%s%s", locn, log_command_name(),
-					_msg_prefix);
-				if (_indent)
-					fprintf(stderr, "  ");
-				vfprintf(stderr, trformat, ap);
-				fputc('\n', stderr);
-			}
-			break;
-		case _LOG_WARN:
-			if (verbose_level() >= _LOG_WARN) {
-				fprintf(use_stderr ? stderr : stdout, "%s%s",
-					log_command_name(), _msg_prefix);
-				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
-				fputc('\n', use_stderr ? stderr : stdout);
-			}
-			break;
-		case _LOG_ERR:
-			if (verbose_level() >= _LOG_ERR) {
-				fprintf(stderr, "%s%s%s", locn, log_command_name(),
-					_msg_prefix);
-				vfprintf(stderr, trformat, ap);
-				fputc('\n', stderr);
-			}
-			break;
-		case _LOG_FATAL:
+			/* fall through */
 		default:
-			if (verbose_level() >= _LOG_FATAL) {
-				fprintf(stderr, "%s%s%s", locn, log_command_name(),
-					_msg_prefix);
-				vfprintf(stderr, trformat, ap);
-				fputc('\n', stderr);
-			}
-			break;
+			/* Typically only log_warn goes to stdout */
+			stream = (use_stderr || (level != _LOG_WARN)) ? stderr : stdout;
+			fprintf(stream, "%s%s%s%s", buf, log_command_name(),
+				_msg_prefix, indent_spaces);
+			vfprintf(stream, trformat, ap);
+			fputc('\n', stream);
 		}
 		va_end(ap);
 	}


