From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Dec 2009 13:54:28 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20091201135428.24475.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-01 13:54:28

Modified files:
	lib/log        : log.c 

Log message:
	If aborting due to an internal error, always print the message causing this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/lib/log/log.c	2009/11/30 17:17:12	1.53
+++ LVM2/lib/log/log.c	2009/12/01 13:54:27	1.54
@@ -183,7 +183,8 @@
 
 	level &= ~_LOG_STDERR;
 
-	if (!strncmp(format, "Internal error:",
+	if (_abort_on_internal_errors &&
+	    !strncmp(format, "Internal error:",
 		     strlen("Internal error:")))
 		internal_error = 1;
 
@@ -244,7 +245,7 @@
 			if (!strcmp("<backtrace>", format) &&
 			    verbose_level() <= _LOG_DEBUG)
 				break;
-			if (verbose_level() >= _LOG_DEBUG) {
+			if (internal_error || verbose_level() >= _LOG_DEBUG) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -255,7 +256,7 @@
 			break;
 
 		case _LOG_INFO:
-			if (verbose_level() >= _LOG_INFO) {
+			if (internal_error || verbose_level() >= _LOG_INFO) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -265,7 +266,7 @@
 			}
 			break;
 		case _LOG_NOTICE:
-			if (verbose_level() >= _LOG_NOTICE) {
+			if (internal_error || verbose_level() >= _LOG_NOTICE) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
@@ -275,7 +276,7 @@
 			}
 			break;
 		case _LOG_WARN:
-			if (verbose_level() >= _LOG_WARN) {
+			if (internal_error || verbose_level() >= _LOG_WARN) {
 				fprintf(use_stderr ? stderr : stdout, "%s%s",
 					log_command_name(), _msg_prefix);
 				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
@@ -283,7 +284,7 @@
 			}
 			break;
 		case _LOG_ERR:
-			if (verbose_level() >= _LOG_ERR) {
+			if (internal_error || verbose_level() >= _LOG_ERR) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
@@ -292,7 +293,7 @@
 			break;
 		case _LOG_FATAL:
 		default:
-			if (verbose_level() >= _LOG_FATAL) {
+			if (internal_error || verbose_level() >= _LOG_FATAL) {
 				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
@@ -303,7 +304,7 @@
 		va_end(ap);
 	}
 
-	if (internal_error && _abort_on_internal_errors)
+	if (internal_error)
 		abort();
 
 	if (level > debug_level())


