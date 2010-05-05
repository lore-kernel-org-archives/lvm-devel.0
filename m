From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 May 2010 22:37:59 -0000
Subject: LVM2 lib/commands/toolcontext.c lib/device/dev ...
Message-ID: <20100505223759.23255.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-05 22:37:53

Modified files:
	lib/commands   : toolcontext.c 
	lib/device     : dev-io.c 
	lib/format_text: import_vsn1.c 
	lib/log        : log.c log.h lvm-logging.h 
	tools          : lvmcmdline.c 

Log message:
	Suppress duplicate error messages about read failures and missing devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/lib/commands/toolcontext.c	2010/04/30 12:37:05	1.95
+++ LVM2/lib/commands/toolcontext.c	2010/05/05 22:37:52	1.96
@@ -194,6 +194,7 @@
 #ifdef DEVMAPPER_SUPPORT
 	dm_log_with_errno_init(print_log);
 #endif
+	reset_log_duplicated();
 }
 
 static int _process_config(struct cmd_context *cmd)
@@ -1361,6 +1362,7 @@
 
 	release_log_memory();
 	activation_exit();
+	reset_log_duplicated();
 	fin_log();
 	fin_syslog();
 	reset_lvm_errno(0);
--- LVM2/lib/device/dev-io.c	2010/04/01 14:30:51	1.67
+++ LVM2/lib/device/dev-io.c	2010/05/05 22:37:53	1.68
@@ -95,12 +95,12 @@
 		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
 
 		if (n < 0)
-			log_error("%s: %s failed after %" PRIu64 " of %" PRIu64
-				  "@%" PRIu64 ": %s", dev_name(where->dev),
-				  should_write ? "write" : "read",
-				  (uint64_t) total,
-				  (uint64_t) where->size,
-				  (uint64_t) where->start, strerror(errno));
+			log_error_once("%s: %s failed after %" PRIu64 " of %" PRIu64
+				       " at %" PRIu64 ": %s", dev_name(where->dev),
+				       should_write ? "write" : "read",
+				       (uint64_t) total,
+				       (uint64_t) where->size,
+				       (uint64_t) where->start, strerror(errno));
 
 		if (n <= 0)
 			break;
--- LVM2/lib/format_text/import_vsn1.c	2010/04/08 00:28:58	1.74
+++ LVM2/lib/format_text/import_vsn1.c	2010/05/05 22:37:53	1.75
@@ -198,7 +198,7 @@
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
 		if (report_missing_devices)
-			log_error("Couldn't find device with uuid %s.", buffer);
+			log_error_once("Couldn't find device with uuid %s.", buffer);
 		else
 			log_very_verbose("Couldn't find device with uuid %s.", buffer);
 	}
--- LVM2/lib/log/log.c	2010/03/23 18:18:49	1.58
+++ LVM2/lib/log/log.c	2010/05/05 22:37:53	1.59
@@ -169,6 +169,14 @@
 	return _lvm_errmsg ? : "";
 }
 
+static struct dm_hash_table *_duplicated = NULL;
+
+void reset_log_duplicated(void) {
+	if (_duplicated)
+		dm_hash_destroy(_duplicated);
+	_duplicated = NULL;
+}
+
 void print_log(int level, const char *file, int line, int dm_errno,
 	       const char *format, ...)
 {
@@ -179,9 +187,10 @@
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
+	int log_once = level & _LOG_ONCE;
 	int fatal_internal_error = 0;
 
-	level &= ~_LOG_STDERR;
+	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
 	if (_abort_on_internal_errors &&
 	    !strncmp(format, INTERNAL_ERROR,
@@ -203,7 +212,9 @@
 	if (dm_errno && !_lvm_errno)
 		_lvm_errno = dm_errno;
 
-	if (_lvm2_log_fn || (_store_errmsg && (level <= _LOG_ERR))) {
+	if (_lvm2_log_fn ||
+	    (_store_errmsg && (level <= _LOG_ERR)) ||
+	    log_once) {
 		va_start(ap, format);
 		n = vsnprintf(buf2, sizeof(buf2) - 1, trformat, ap);
 		va_end(ap);
@@ -229,6 +240,16 @@
 		}
 	}
 
+	if (log_once) {
+		if (!_duplicated)
+			_duplicated = dm_hash_create(128);
+		if (_duplicated) {
+			if (dm_hash_lookup(_duplicated, message))
+				level = _LOG_NOTICE;
+			dm_hash_insert(_duplicated, message, (void*)1);
+		}
+	}
+
 	if (_lvm2_log_fn) {
 		_lvm2_log_fn(level, file, line, 0, message);
 		if (fatal_internal_error)
--- LVM2/lib/log/log.h	2010/02/15 16:46:56	1.48
+++ LVM2/lib/log/log.h	2010/05/05 22:37:53	1.49
@@ -47,6 +47,7 @@
 
 #define _LOG_STDERR 128 /* force things to go to stderr, even if loglevel
 			   would make them go to stdout */
+#define _LOG_ONCE 256 /* downgrade to NOTICE if this has been already logged */
 #define _LOG_DEBUG 7
 #define _LOG_INFO 6
 #define _LOG_NOTICE 5
@@ -62,6 +63,7 @@
 #define log_warn_suppress(s, x...) LOG_LINE(s ? _LOG_NOTICE : _LOG_WARN | _LOG_STDERR, x)
 #define log_err(x...) LOG_LINE_WITH_ERRNO(_LOG_ERR, EUNCLASSIFIED, x)
 #define log_err_suppress(s, x...) LOG_LINE_WITH_ERRNO(s ? _LOG_NOTICE : _LOG_ERR, EUNCLASSIFIED, x)
+#define log_err_once(x...) LOG_LINE_WITH_ERRNO(_LOG_ERR | _LOG_ONCE, EUNCLASSIFIED, x)
 #define log_fatal(x...) LOG_LINE_WITH_ERRNO(_LOG_FATAL, EUNCLASSIFIED, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
@@ -70,6 +72,7 @@
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
 #define log_error(args...) log_err(args)
 #define log_error_suppress(s, args...) log_err_suppress(s, args)
+#define log_error_once(args...) log_err_once(args)
 #define log_errno(args...) LOG_LINE_WITH_ERRNO(_LOG_ERR, args)
 
 /* System call equivalents */
--- LVM2/lib/log/lvm-logging.h	2009/11/30 17:17:12	1.8
+++ LVM2/lib/log/lvm-logging.h	2010/05/05 22:37:53	1.9
@@ -43,6 +43,7 @@
 
 void fin_log(void);
 void release_log_memory(void);
+void reset_log_duplicated(void);
 
 void init_syslog(int facility);
 void fin_syslog(void);
--- LVM2/tools/lvmcmdline.c	2010/04/30 13:47:11	1.120
+++ LVM2/tools/lvmcmdline.c	2010/05/05 22:37:53	1.121
@@ -1087,6 +1087,7 @@
 	dm_pool_empty(cmd->mem);
 
 	reset_lvm_errno(1);
+	reset_log_duplicated();
 
 	return ret;
 }


