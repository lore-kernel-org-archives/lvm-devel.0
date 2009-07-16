From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jul 2009 13:13:34 -0000
Subject: LVM2/lib/log log.c log.h
Message-ID: <20090716131334.1221.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-16 13:13:34

Modified files:
	lib/log        : log.c log.h 

Log message:
	Fix so only log_error and log_fatal set EUNCLASSIFIED.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/log/log.c	2009/07/16 00:36:59	1.51
+++ LVM2/lib/log/log.c	2009/07/16 13:13:33	1.52
@@ -186,7 +186,7 @@
 	if (dm_errno && !_lvm_errno)
 		_lvm_errno = dm_errno;
 
-	if (_lvm2_log_fn || (_store_errmsg && (level == _LOG_ERR))) {
+	if (_lvm2_log_fn || (_store_errmsg && (level <= _LOG_ERR))) {
 		va_start(ap, format);
 		n = vsnprintf(buf2, sizeof(buf2) - 1, trformat, ap);
 		va_end(ap);
@@ -201,7 +201,7 @@
 		message = &buf2[0];
 	}
 
-	if (_store_errmsg && (level == _LOG_ERR)) {
+	if (_store_errmsg && (level <= _LOG_ERR)) {
 		if (!_lvm_errmsg)
 			_lvm_errmsg = dm_strdup(message);
 		else if ((newbuf = dm_realloc(_lvm_errmsg,
--- LVM2/lib/log/log.h	2009/07/16 00:52:09	1.45
+++ LVM2/lib/log/log.h	2009/07/16 13:13:33	1.46
@@ -43,6 +43,8 @@
 #include <string.h>		/* strerror() */
 #include <errno.h>
 
+#define EUNCLASSIFIED -1	/* Generic error code */
+
 #define _LOG_STDERR 128 /* force things to go to stderr, even if loglevel
 			   would make them go to stdout */
 #define _LOG_DEBUG 7
@@ -56,8 +58,8 @@
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
 #define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)
 #define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, x)
-#define log_err(x...) LOG_LINE(_LOG_ERR, x)
-#define log_fatal(x...) LOG_LINE(_LOG_FATAL, x)
+#define log_err(x...) LOG_LINE_WITH_ERRNO(_LOG_ERR, EUNCLASSIFIED, x)
+#define log_fatal(x...) LOG_LINE_WITH_ERRNO(_LOG_FATAL, EUNCLASSIFIED, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
 #define log_very_verbose(args...) log_info(args)


