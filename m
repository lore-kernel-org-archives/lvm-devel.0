From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2010 20:41:40 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20100111204140.19992.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-11 20:41:40

Modified files:
	lib/log        : log.c 

Log message:
	Use _LOG_FATAL when aborting on an internal error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/lib/log/log.c	2010/01/11 20:30:32	1.56
+++ LVM2/lib/log/log.c	2010/01/11 20:41:39	1.57
@@ -179,16 +179,20 @@
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
-	int internal_error = 0;
+	int fatal_internal_error = 0;
 
 	level &= ~_LOG_STDERR;
 
 	if (_abort_on_internal_errors &&
 	    !strncmp(format, INTERNAL_ERROR,
-		     strlen(INTERNAL_ERROR)))
-		internal_error = 1;
-	else if (_log_suppress == 2)
+		     strlen(INTERNAL_ERROR))) {
+		fatal_internal_error = 1;
 		/* Internal errors triggering abort cannot be suppressed. */
+		_log_suppress = 0;
+		level = _LOG_FATAL;
+	}
+
+	if (_log_suppress == 2)
 		return;
 
 	if (level <= _LOG_ERR)
@@ -245,7 +249,7 @@
 			if (!strcmp("<backtrace>", format) &&
 			    verbose_level() <= _LOG_DEBUG)
 				break;
-			if (internal_error || verbose_level() >= _LOG_DEBUG) {
+			if (verbose_level() >= _LOG_DEBUG) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -256,7 +260,7 @@
 			break;
 
 		case _LOG_INFO:
-			if (internal_error || verbose_level() >= _LOG_INFO) {
+			if (verbose_level() >= _LOG_INFO) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -266,7 +270,7 @@
 			}
 			break;
 		case _LOG_NOTICE:
-			if (internal_error || verbose_level() >= _LOG_NOTICE) {
+			if (verbose_level() >= _LOG_NOTICE) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -276,7 +280,7 @@
 			}
 			break;
 		case _LOG_WARN:
-			if (internal_error || verbose_level() >= _LOG_WARN) {
+			if (verbose_level() >= _LOG_WARN) {
 				fprintf(use_stderr ? stderr : stdout, "%s%s",
 					log_command_name(), _msg_prefix);
 				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
@@ -284,7 +288,7 @@
 			}
 			break;
 		case _LOG_ERR:
-			if (internal_error || verbose_level() >= _LOG_ERR) {
+			if (verbose_level() >= _LOG_ERR) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
@@ -293,7 +297,7 @@
 			break;
 		case _LOG_FATAL:
 		default:
-			if (internal_error || verbose_level() >= _LOG_FATAL) {
+			if (verbose_level() >= _LOG_FATAL) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
@@ -304,7 +308,7 @@
 		va_end(ap);
 	}
 
-	if (internal_error)
+	if (fatal_internal_error)
 		abort();
 
 	if (level > debug_level())


