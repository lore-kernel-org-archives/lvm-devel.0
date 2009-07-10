From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2009 09:59:39 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/log/log.h lib/log/lvm- ...
Message-ID: <20090710095939.28791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-10 09:59:38

Modified files:
	.              : WHATS_NEW_DM 
	lib/log        : log.h lvm-logging.h 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	libdm/misc     : dm-logging.h 
	libdm/mm       : dbg_malloc.c 
	po             : pogen.h 

Log message:
	Add dm_log_with_errno and dm_log_with_errno_init, deprecating the old
	Change plog to use dm_log_with_errno unless deprecated dm_log_init was used.
	Rename plog macro to LOG_LINE and use in dm_dump_memory_debug.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.284&r2=1.285
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-logging.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/pogen.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW_DM	2009/07/07 17:19:38	1.284
+++ LVM2/WHATS_NEW_DM	2009/07/10 09:59:37	1.285
@@ -1,5 +1,8 @@
 Version 1.02.34 - 
 ================================
+  Rename plog macro to LOG_LINE and use in dm_dump_memory_debug.
+  Change plog to use dm_log_with_errno unless deprecated dm_log_init was used.
+  Add dm_log_with_errno and dm_log_with_errno_init, deprecating the old fns.
   Fix whitespace in linear target line to fix identical table line detection.
   Add device number to more log messages during activation.
 
--- LVM2/lib/log/log.h	2008/10/30 17:27:27	1.43
+++ LVM2/lib/log/log.h	2009/07/10 09:59:37	1.44
@@ -50,17 +50,17 @@
 #define _LOG_ERR 3
 #define _LOG_FATAL 2
 
-#define log_debug(x...) plog(_LOG_DEBUG, x)
-#define log_info(x...) plog(_LOG_INFO, x)
-#define log_notice(x...) plog(_LOG_NOTICE, x)
-#define log_warn(x...) plog(_LOG_WARN | _LOG_STDERR, x)
-#define log_err(x...) plog(_LOG_ERR, x)
-#define log_fatal(x...) plog(_LOG_FATAL, x)
+#define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
+#define log_info(x...) LOG_LINE(_LOG_INFO, x)
+#define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)
+#define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, x)
+#define log_err(x...) LOG_LINE(_LOG_ERR, x)
+#define log_fatal(x...) LOG_LINE(_LOG_FATAL, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
-#define log_print(args...) plog(_LOG_WARN, args)
+#define log_print(args...) LOG_LINE(_LOG_WARN, args)
 #define log_error(args...) log_err(args)
 
 /* System call equivalents */
--- LVM2/lib/log/lvm-logging.h	2008/11/03 18:59:58	1.2
+++ LVM2/lib/log/lvm-logging.h	2009/07/10 09:59:37	1.3
@@ -19,7 +19,7 @@
 void print_log(int level, const char *file, int line, const char *format, ...)
     __attribute__ ((format(printf, 4, 5)));
 
-#define plog(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
+#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
 
 #include "log.h"
 
--- LVM2/libdm/.exported_symbols	2009/06/17 20:55:24	1.37
+++ LVM2/libdm/.exported_symbols	2009/07/10 09:59:38	1.38
@@ -6,6 +6,9 @@
 dm_get_library_version
 dm_log
 dm_log_init
+dm_log_is_non_default
+dm_log_with_errno
+dm_log_with_errno_init
 dm_log_init_verbose
 dm_task_create
 dm_task_destroy
--- LVM2/libdm/libdevmapper.h	2009/06/17 20:55:24	1.90
+++ LVM2/libdm/libdevmapper.h	2009/07/10 09:59:38	1.91
@@ -30,30 +30,40 @@
 #include <stdio.h>
 
 /*****************************************************************
- * The first section of this file provides direct access to the 
- * individual device-mapper ioctls.
+ * The first section of this file provides direct access to the
+ * individual device-mapper ioctls.  Since it is quite laborious to
+ * build the ioctl arguments for the device-mapper, people are
+ * encouraged to use this library.
  ****************************************************************/
 
 /*
- * Since it is quite laborious to build the ioctl
- * arguments for the device-mapper people are
- * encouraged to use this library.
- *
- * You will need to build a struct dm_task for
- * each ioctl command you want to execute.
+ * The library user may wish to register their own
+ * logging function.  By default errors go to stderr.
+ * Use dm_log_with_errno_init(NULL) to restore the default log fn.
  */
 
+typedef void (*dm_log_with_errno_fn) (int level, const char *file, int line,
+				      int dm_errno, const char *f, ...)
+    __attribute__ ((format(printf, 5, 6)));
+
+void dm_log_with_errno_init(dm_log_with_errno_fn fn);
+void dm_log_init_verbose(int level);
+
+/*
+ * Original version of this function.
+ * dm_errno is set to 0.
+ *
+ * Deprecated: Use the _with_errno_ versions above instead.
+ */
 typedef void (*dm_log_fn) (int level, const char *file, int line,
 			   const char *f, ...)
     __attribute__ ((format(printf, 4, 5)));
-
+void dm_log_init(dm_log_fn fn);
 /*
- * The library user may wish to register their own
- * logging function, by default errors go to stderr.
- * Use dm_log_init(NULL) to restore the default log fn.
+ * For backward-compatibility, indicate that dm_log_init() was used
+ * to set a non-default value of dm_log().
  */
-void dm_log_init(dm_log_fn fn);
-void dm_log_init_verbose(int level);
+int dm_log_is_non_default(void);
 
 enum {
 	DM_DEVICE_CREATE,
@@ -87,6 +97,11 @@
 	DM_DEVICE_SET_GEOMETRY
 };
 
+/*
+ * You will need to build a struct dm_task for
+ * each ioctl command you want to execute.
+ */
+
 struct dm_task;
 
 struct dm_task *dm_task_create(int type);
--- LVM2/libdm/libdm-common.c	2009/06/17 20:55:24	1.65
+++ LVM2/libdm/libdm-common.c	2009/07/10 09:59:38	1.66
@@ -42,10 +42,12 @@
  * Library users can provide their own logging
  * function.
  */
-static void _default_log(int level, const char *file __attribute((unused)),
-			 int line __attribute((unused)), const char *f, ...)
+
+static void _default_log_line(int level,
+	    const char *file __attribute((unused)),
+	    int line __attribute((unused)), int dm_errno, 
+	    const char *f, va_list ap)
 {
-	va_list ap;
 	int use_stderr = level & _LOG_STDERR;
 
 	level &= ~_LOG_STDERR;
@@ -53,22 +55,41 @@
 	if (level > _LOG_WARN && !_verbose)
 		return;
 
-	va_start(ap, f);
-
 	if (level < _LOG_WARN)
 		vfprintf(stderr, f, ap);
 	else
 		vfprintf(use_stderr ? stderr : stdout, f, ap);
 
-	va_end(ap);
-
 	if (level < _LOG_WARN)
 		fprintf(stderr, "\n");
 	else
 		fprintf(use_stderr ? stderr : stdout, "\n");
 }
 
+static void _default_log_with_errno(int level,
+	    const char *file __attribute((unused)),
+	    int line __attribute((unused)), int dm_errno, 
+	    const char *f, ...)
+{
+	va_list ap;
+
+	va_start(ap, f);
+	_default_log_line(level, file, line, dm_errno, f, ap);
+	va_end(ap);
+}
+
+static void _default_log(int level, const char *file,
+			 int line, const char *f, ...)
+{
+	va_list ap;
+
+	va_start(ap, f);
+	_default_log_line(level, file, line, 0, f, ap);
+	va_end(ap);
+}
+
 dm_log_fn dm_log = _default_log;
+dm_log_with_errno_fn dm_log_with_errno = _default_log_with_errno;
 
 void dm_log_init(dm_log_fn fn)
 {
@@ -76,6 +97,23 @@
 		dm_log = fn;
 	else
 		dm_log = _default_log;
+
+	dm_log_with_errno = _default_log_with_errno;
+}
+
+int dm_log_is_non_default(void)
+{
+	return (dm_log == _default_log) ? 0 : 1;
+}
+
+void dm_log_with_errno_init(dm_log_with_errno_fn fn)
+{
+	if (fn)
+		dm_log_with_errno = fn;
+	else
+		dm_log_with_errno = _default_log_with_errno;
+
+	dm_log = _default_log;
 }
 
 void dm_log_init_verbose(int level)
--- LVM2/libdm/misc/dm-logging.h	2008/10/30 17:54:12	1.1
+++ LVM2/libdm/misc/dm-logging.h	2009/07/10 09:59:38	1.2
@@ -19,8 +19,15 @@
 #include "libdevmapper.h"
 
 extern dm_log_fn dm_log;
+extern dm_log_with_errno_fn dm_log_with_errno;
 
-#define plog(l, x...) dm_log(l, __FILE__, __LINE__, ## x)
+#define LOG_LINE(l, x...) \
+	do { \
+		if (dm_log_is_non_default()) \
+			dm_log(l, __FILE__, __LINE__, ## x); \
+		else \
+			dm_log_with_errno(l, __FILE__, __LINE__, 0, ## x); \
+	} while (0)
 
 #include "log.h"
 
--- LVM2/libdm/mm/dbg_malloc.c	2008/11/03 18:59:59	1.13
+++ LVM2/libdm/mm/dbg_malloc.c	2009/07/10 09:59:38	1.14
@@ -205,9 +205,9 @@
 		}
 		str[sizeof(str) - 1] = '\0';
 
-		dm_log(_LOG_INFO, mb->file, mb->line,
-		       "block %d at %p, size %" PRIsize_t "\t [%s]",
-		       mb->id, mb->magic, mb->length, str);
+		LOG_LINE(_LOG_INFO, mb->file, mb->line,
+			 "block %d at %p, size %" PRIsize_t "\t [%s]",
+			 mb->id, mb->magic, mb->length, str);
 		tot += mb->length;
 	}
 
--- LVM2/po/pogen.h	2008/10/31 22:32:54	1.3
+++ LVM2/po/pogen.h	2009/07/10 09:59:38	1.4
@@ -21,3 +21,6 @@
 
 #define print_log(level, file, line, format, args...) print_log(format, args)
 #define dm_log(level, file, line, format, args...) dm_log(format, args)
+#define dm_log_with_errno(level, file, line, format, dm_errno, args...) \
+    dm_log(format, args)
+


