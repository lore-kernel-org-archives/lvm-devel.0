From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 9 Jul 2009 16:50:50 +0100
Subject: [PATCH 1/2] Add cmd logging for liblvm error reporting: All logging functions have an additional argument: The error code This makes the functions incompatible with the old ones.
In-Reply-To: <1246998001-17258-2-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
	<1246998001-17258-2-git-send-email-twoerner@redhat.com>
Message-ID: <20090709155050.GT11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the first patch I was thinking of for libdevmapper to
preserve compatibility.

Alasdair

Index: libdm/.exported_symbols
===================================================================
RCS file: /cvs/lvm2/LVM2/libdm/.exported_symbols,v
retrieving revision 1.37
diff -u -p -r1.37 .exported_symbols
--- libdm/.exported_symbols	17 Jun 2009 20:55:24 -0000	1.37
+++ libdm/.exported_symbols	9 Jul 2009 15:36:33 -0000
@@ -6,6 +6,9 @@ dm_fclose
 dm_get_library_version
 dm_log
 dm_log_init
+dm_log_is_non_default
+dm_log_with_errno
+dm_log_with_errno_init
 dm_log_init_verbose
 dm_task_create
 dm_task_destroy
Index: libdm/libdevmapper.h
===================================================================
RCS file: /cvs/lvm2/LVM2/libdm/libdevmapper.h,v
retrieving revision 1.90
diff -u -p -r1.90 libdevmapper.h
--- libdm/libdevmapper.h	17 Jun 2009 20:55:24 -0000	1.90
+++ libdm/libdevmapper.h	9 Jul 2009 15:36:34 -0000
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
@@ -87,6 +97,11 @@ enum {
 	DM_DEVICE_SET_GEOMETRY
 };
 
+/*
+ * You will need to build a struct dm_task for
+ * each ioctl command you want to execute.
+ */
+
 struct dm_task;
 
 struct dm_task *dm_task_create(int type);
Index: libdm/libdm-common.c
===================================================================
RCS file: /cvs/lvm2/LVM2/libdm/libdm-common.c,v
retrieving revision 1.65
diff -u -p -r1.65 libdm-common.c
--- libdm/libdm-common.c	17 Jun 2009 20:55:24 -0000	1.65
+++ libdm/libdm-common.c	9 Jul 2009 15:36:35 -0000
@@ -42,10 +42,12 @@ static int _verbose = 0;
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
@@ -53,22 +55,41 @@ static void _default_log(int level, cons
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
@@ -76,6 +97,23 @@ void dm_log_init(dm_log_fn fn)
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
Index: libdm/misc/dm-logging.h
===================================================================
RCS file: /cvs/lvm2/LVM2/libdm/misc/dm-logging.h,v
retrieving revision 1.1
diff -u -p -r1.1 dm-logging.h
--- libdm/misc/dm-logging.h	30 Oct 2008 17:54:12 -0000	1.1
+++ libdm/misc/dm-logging.h	9 Jul 2009 15:36:35 -0000
@@ -19,8 +19,15 @@
 #include "libdevmapper.h"
 
 extern dm_log_fn dm_log;
+extern dm_log_with_errno_fn dm_log_with_errno;
 
-#define plog(l, x...) dm_log(l, __FILE__, __LINE__, ## x)
+#define plog(l, x...) \
+	do { \
+		if (dm_log_is_non_default()) \
+			dm_log(l, __FILE__, __LINE__, ## x); \
+		else \
+			dm_log_with_errno(l, __FILE__, __LINE__, 0, ## x); \
+	} while (0)
 
 #include "log.h"
 


