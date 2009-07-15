From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 23:57:57 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090715235757.549.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 23:57:55

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	doc            : example_cmdlib.c 
	lib/commands   : toolcontext.c 
	lib/log        : log.c lvm-logging.h 
	po             : pogen.h 
	tools          : lvmcmdline.c 

Log message:
	Store any errno and error messages issued while processing each command.
	(Enabled by default while we test it, but in due course we'll only store
	the error messages when we need to.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1189&r2=1.1190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example_cmdlib.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/pogen.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2009/07/15 20:02:46	1.1189
+++ LVM2/WHATS_NEW	2009/07/15 23:57:54	1.1190
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Store any errno and error messages issued while processing each command.
   Use log_error macro consistently throughout in place of log_err.
 
 Version 2.02.49 - 15th July 2009
--- LVM2/daemons/clvmd/lvm-functions.c	2009/07/13 19:49:48	1.64
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/07/15 23:57:55	1.65
@@ -714,7 +714,7 @@
 	return NULL;
 }
 
-static void lvm2_log_fn(int level, const char *file, int line,
+static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
 			const char *message)
 {
 
@@ -723,7 +723,7 @@
  	   We need to NULL the function ptr otherwise it will just call
 	   back into here! */
 	init_log_fn(NULL);
-	print_log(level, file, line, "%s", message);
+	print_log(level, file, line, dm_errno, "%s", message);
 	init_log_fn(lvm2_log_fn);
 
 	/*
--- LVM2/doc/example_cmdlib.c	2004/03/30 19:54:59	1.1
+++ LVM2/doc/example_cmdlib.c	2009/07/15 23:57:55	1.2
@@ -15,7 +15,8 @@
 #include "lvm2cmd.h"
 
 /* All output gets passed to this function line-by-line */
-void test_log_fn(int level, const char *file, int line, const char *format)
+void test_log_fn(int level, int dm_errno, const char *file, int line,
+		 const char *format)
 {
 	/* Extract and process output here rather than printing it */
 
--- LVM2/lib/commands/toolcontext.c	2009/07/15 20:02:46	1.80
+++ LVM2/lib/commands/toolcontext.c	2009/07/15 23:57:55	1.81
@@ -190,7 +190,7 @@
 
 	/* Tell device-mapper about our logging */
 #ifdef DEVMAPPER_SUPPORT
-	dm_log_init(print_log);
+	dm_log_with_errno_init(print_log);
 #endif
 }
 
@@ -1161,6 +1161,7 @@
 	cmd->current_settings = cmd->default_settings;
 
 	cmd->config_valid = 1;
+	reset_lvm_errno(1);  /* FIXME Move to top when cmd returned on error */
 	return cmd;
 
       error:
@@ -1288,6 +1289,8 @@
 		persistent_filter_dump(cmd->filter);
 
 	cmd->config_valid = 1;
+
+	reset_lvm_errno(1);
 	return 1;
 }
 
@@ -1317,4 +1320,5 @@
 	activation_exit();
 	fin_log();
 	fin_syslog();
+	reset_lvm_errno(0);
 }
--- LVM2/lib/log/log.c	2008/10/30 17:27:27	1.49
+++ LVM2/lib/log/log.c	2009/07/15 23:57:55	1.50
@@ -38,6 +38,10 @@
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
+static int _lvm_errno = 0;
+static int _store_errmsg = 0;
+static char *_lvm_errmsg = NULL;
+
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
 	if (log_fn)
@@ -136,13 +140,37 @@
 	_indent = indent;
 }
 
-void print_log(int level, const char *file, int line, const char *format, ...)
+void reset_lvm_errno(int store_errmsg)
+{
+	_lvm_errno = 0;
+
+	if (_lvm_errmsg) {
+		dm_free(_lvm_errmsg);
+		_lvm_errmsg = NULL;
+	}
+
+	_store_errmsg = store_errmsg;
+}
+
+int lvm_errno(void)
+{
+	return _lvm_errno;
+}
+
+const char *lvm_errmsg(void)
+{
+	return _lvm_errmsg ? : "";
+}
+
+void print_log(int level, const char *file, int line, int dm_errno,
+	       const char *format, ...)
 {
 	va_list ap;
 	char buf[1024], buf2[4096], locn[4096];
 	int bufused, n;
 	const char *message;
 	const char *trformat;		/* Translated format string */
+	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
 
 	level &= ~_LOG_STDERR;
@@ -155,7 +183,10 @@
 
 	trformat = _(format);
 
-	if (_lvm2_log_fn) {
+	if (dm_errno && !_lvm_errno)
+		_lvm_errno = dm_errno;
+
+	if (_lvm2_log_fn || (_store_errmsg && (level == _LOG_ERR))) {
 		va_start(ap, format);
 		n = vsnprintf(buf2, sizeof(buf2) - 1, trformat, ap);
 		va_end(ap);
@@ -168,8 +199,21 @@
 
 		buf2[sizeof(buf2) - 1] = '\0';
 		message = &buf2[0];
+	}
 
-		_lvm2_log_fn(level, file, line, message);
+	if (_store_errmsg && (level == _LOG_ERR)) {
+		if (!_lvm_errmsg)
+			_lvm_errmsg = dm_strdup(message);
+		else if ((newbuf = dm_realloc(_lvm_errmsg,
+ 					      strlen(_lvm_errmsg) +
+					      strlen(message) + 2))) {
+			_lvm_errmsg = strcat(newbuf, "\n");
+			_lvm_errmsg = strcat(newbuf, message);
+		}
+	}
+
+	if (_lvm2_log_fn) {
+		_lvm2_log_fn(level, file, line, 0, message);
 
 		return;
 	}
--- LVM2/lib/log/lvm-logging.h	2009/07/10 09:59:37	1.3
+++ LVM2/lib/log/lvm-logging.h	2009/07/15 23:57:55	1.4
@@ -16,15 +16,16 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-void print_log(int level, const char *file, int line, const char *format, ...)
-    __attribute__ ((format(printf, 4, 5)));
+void print_log(int level, const char *file, int line, int dm_errno,
+	       const char *format, ...)
+    __attribute__ ((format(printf, 5, 6)));
 
-#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
+#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , 0, ## x)
 
 #include "log.h"
 
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
-			       const char *message);
+			       int dm_errno, const char *message);
 
 void init_log_fn(lvm2_log_fn_t log_fn);
 
@@ -42,6 +43,9 @@
 void fin_syslog(void);
 
 int error_message_produced(void);
+void reset_lvm_errno(int store_errmsg);
+int lvm_errno(void);
+const char *lvm_errmsg(void);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
 /* Returns previous setting */
--- LVM2/po/pogen.h	2009/07/10 09:59:38	1.4
+++ LVM2/po/pogen.h	2009/07/15 23:57:55	1.5
@@ -19,8 +19,8 @@
  * different architectures.
  */
 
-#define print_log(level, file, line, format, args...) print_log(format, args)
+#define print_log(level, dm_errno, file, line, format, args...) print_log(format, args)
 #define dm_log(level, file, line, format, args...) dm_log(format, args)
-#define dm_log_with_errno(level, file, line, format, dm_errno, args...) \
-    dm_log(format, args)
+#define dm_log_with_errno(level, dm_errno, file, line, format, args...) \
+    dm_log(level, file, line, format, args)
 
--- LVM2/tools/lvmcmdline.c	2009/07/15 20:02:48	1.100
+++ LVM2/tools/lvmcmdline.c	2009/07/15 23:57:55	1.101
@@ -1054,6 +1054,8 @@
 	 */
 	dm_pool_empty(cmd->mem);
 
+	reset_lvm_errno(1);
+
 	return ret;
 }
 


