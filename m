From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  7 Jan 2013 22:35:20 +0000 (UTC)
Subject: master - logging: add debug classes
Message-ID: <20130107223520.1CC94A0E47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f747a0d739c08eadf319da9c3973f83c97c82af
Commit:        7f747a0d739c08eadf319da9c3973f83c97c82af
Parent:        b617109fff859a5b970554b38852fc61deb29f77
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 7 22:25:19 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 7 22:25:19 2013 +0000

logging: add debug classes

Add log/debug_classes to lvm.conf to allow debug messages to be
classified and filtered at runtime.

The dm_errno field is only used by log_error(), so I've redefined it
for log_debug() messages to hold the message class.

By default, all existing messages appear, but we can add categories that
generate high volumes of data, such as logging all traffic to/from
lvmetad.
---
 WHATS_NEW                  |    1 +
 doc/example.conf.in        |    9 ++++++++
 lib/commands/toolcontext.c |   46 ++++++++++++++++++++++++++++++++++++++++++++
 lib/commands/toolcontext.h |    1 +
 lib/config/defaults.h      |    4 +++
 lib/log/log.c              |   27 +++++++++++++++----------
 lib/log/log.h              |   23 ++++++++++++++++++++++
 lib/log/lvm-logging.h      |    7 ++++-
 lib/misc/lvm-globals.c     |   15 ++++++++++++++
 lib/misc/lvm-globals.h     |    2 +
 libdm/libdevmapper.h       |    4 ++-
 libdm/libdm-common.c       |    6 ++--
 libdm/misc/dm-logging.h    |    3 ++
 13 files changed, 131 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5b81d52..d7e8c7d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add log/debug_classes to lvm.conf to control debug log messages.
   Synchronize with udev in pvscan --cache and fix dangling udev_sync cookies.
   Fix autoactivation to not autoactivate VG/LV on each change of the PVs used.
   Limit RAID device replacement to repair only if LV is not in-sync.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 872d6ef..256e012 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -307,6 +307,15 @@ log {
     # Set this if you want log messages during activation.
     # Don't use this in low memory situations (can deadlock).
     # activation = 0
+
+    # Some debugging messages are assigned to a class and only appear
+    # in debug output if the class is listed here.
+    # Classes currently available:
+    #   memory, devices, activation, allocation, lvmetad, metadata, cache,
+    #   locking
+    # Use "all" to see everything.
+    debug_classes = [ "memory", "devices", "activation", "allocation",
+		      "lvmetad", "metadata", "cache", "locking" ]
 }
 
 # Configuration of metadata backups and archiving.  In LVM2 when we
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 14152b7..d5dd430 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -122,6 +122,48 @@ static void _get_sysfs_dir(struct cmd_context *cmd)
 	strncpy(cmd->sysfs_dir, sys_mnt, sizeof(cmd->sysfs_dir));
 }
 
+static int _parse_debug_classes(struct cmd_context *cmd)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	int debug_classes = 0;
+
+	if (!(cn = find_config_tree_node(cmd, "log/debug_classes")))
+		return DEFAULT_LOGGED_DEBUG_CLASSES;
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_verbose("log/debug_classes contains a value "
+				    "which is not a string.  Ignoring.");
+			continue;
+		}
+
+		if (!strcasecmp(cv->v.str, "all"))
+			return -1;
+
+		if (!strcasecmp(cv->v.str, "memory"))
+			debug_classes |= LOG_CLASS_MEM;
+		else if (!strcasecmp(cv->v.str, "devices"))
+			debug_classes |= LOG_CLASS_DEVS;
+		else if (!strcasecmp(cv->v.str, "activation"))
+			debug_classes |= LOG_CLASS_ACTIVATION;
+		else if (!strcasecmp(cv->v.str, "allocation"))
+			debug_classes |= LOG_CLASS_ALLOC;
+		else if (!strcasecmp(cv->v.str, "lvmetad"))
+			debug_classes |= LOG_CLASS_LVMETAD;
+		else if (!strcasecmp(cv->v.str, "metadata"))
+			debug_classes |= LOG_CLASS_METADATA;
+		else if (!strcasecmp(cv->v.str, "cache"))
+			debug_classes |= LOG_CLASS_CACHE;
+		else if (!strcasecmp(cv->v.str, "locking"))
+			debug_classes |= LOG_CLASS_LOCKING;
+		else
+			log_verbose("Unrecognised value for log/debug_classes: %s", cv->v.str);
+	}
+
+	return debug_classes;
+}
+
 static void _init_logging(struct cmd_context *cmd)
 {
 	int append = 1;
@@ -198,6 +240,10 @@ static void _init_logging(struct cmd_context *cmd)
 	init_log_while_suspended(find_config_tree_int(cmd,
 						 "log/activation", 0));
 
+	cmd->default_settings.debug_classes = _parse_debug_classes(cmd);
+	log_debug("Setting log debug classes to %d", cmd->default_settings.debug_classes);
+	init_debug_classes_logged(cmd->default_settings.debug_classes);
+
 	t = time(NULL);
 	ctime_r(&t, &timebuf[0]);
 	timebuf[24] = '\0';
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 6e5803f..c21ec13 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -26,6 +26,7 @@
  */
 struct config_info {
 	int debug;
+	int debug_classes;
 	int verbose;
 	int silent;
 	int test;
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 348fa75..3518240 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -112,6 +112,10 @@
 #  define DEFAULT_LOG_FACILITY LOG_USER
 #endif
 
+#define DEFAULT_LOGGED_DEBUG_CLASSES (LOG_CLASS_MEM | LOG_CLASS_DEVS | \
+    LOG_CLASS_ACTIVATION | LOG_CLASS_ALLOC | LOG_CLASS_LVMETAD | \
+    LOG_CLASS_METADATA | LOG_CLASS_CACHE | LOG_CLASS_LOCKING)
+
 #define DEFAULT_SYSLOG 1
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_SILENT 0
diff --git a/lib/log/log.c b/lib/log/log.c
index 3c357f1..3b038f5 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -179,7 +179,7 @@ void reset_log_duplicated(void) {
 	}
 }
 
-void print_log(int level, const char *file, int line, int dm_errno,
+void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...)
 {
 	va_list ap;
@@ -212,8 +212,8 @@ void print_log(int level, const char *file, int line, int dm_errno,
 
 	trformat = _(format);
 
-	if (dm_errno && !_lvm_errno)
-		_lvm_errno = dm_errno;
+	if (level < _LOG_DEBUG && dm_errno_or_class && !_lvm_errno)
+		_lvm_errno = dm_errno_or_class;
 
 	if (_lvm2_log_fn ||
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
@@ -285,14 +285,16 @@ void print_log(int level, const char *file, int line, int dm_errno,
 			if (!strcmp("<backtrace>", format) &&
 			    verbose_level() <= _LOG_DEBUG)
 				break;
-			if (verbose_level() >= _LOG_DEBUG) {
-				fprintf(stderr, "%s%s%s", locn, log_command_name(),
-					_msg_prefix);
-				if (_indent)
-					fprintf(stderr, "      ");
-				vfprintf(stderr, trformat, ap);
-				fputc('\n', stderr);
-			}
+			if (verbose_level() < _LOG_DEBUG)
+				break;
+			if (!debug_class_is_logged(dm_errno_or_class))
+				break;
+			fprintf(stderr, "%s%s%s", locn, log_command_name(),
+				_msg_prefix);
+			if (_indent)
+				fprintf(stderr, "      ");
+			vfprintf(stderr, trformat, ap);
+			fputc('\n', stderr);
 			break;
 
 		case _LOG_INFO:
@@ -347,6 +349,9 @@ void print_log(int level, const char *file, int line, int dm_errno,
 	if (level > debug_level())
 		return;
 
+	if (level >= _LOG_DEBUG && !debug_class_is_logged(dm_errno_or_class))
+		return;
+
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
diff --git a/lib/log/log.h b/lib/log/log.h
index f0da64f..2e1c515 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -54,7 +54,30 @@
 #define _LOG_FATAL 2
 #define INTERNAL_ERROR "Internal error: "
 
+/*
+ * Classes available for debug log messages.
+ * These are also listed in doc/example.conf
+ * and lib/commands/toolcontext.c:_parse_debug_classes()
+ */
+#define LOG_CLASS_MEM		0x0001	/* "memory" */
+#define LOG_CLASS_DEVS		0x0002	/* "devices" */
+#define LOG_CLASS_ACTIVATION	0x0004	/* "activation" */
+#define LOG_CLASS_ALLOC		0x0008	/* "allocation" */
+#define LOG_CLASS_LVMETAD	0x0010	/* "lvmetad" */
+#define LOG_CLASS_METADATA	0x0020	/* "metadata" */
+#define LOG_CLASS_CACHE		0x0040	/* "cache" */
+#define LOG_CLASS_LOCKING	0x0080	/* "locking" */
+
 #define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
+#define log_debug_mem(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_MEM, x)
+#define log_debug_devs(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_DEVS, x)
+#define log_debug_activation(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_ACTIVATION, x)
+#define log_debug_alloc(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_ALLOC, x)
+#define log_debug_lvmetad(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LVMETAD, x)
+#define log_debug_metadata(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_METADATA, x)
+#define log_debug_cache(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_CACHE, x)
+#define log_debug_locking(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LOCKING, x)
+
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
 #define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)
 #define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, x)
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 1c0a580..52cd895 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-void print_log(int level, const char *file, int line, int dm_errno,
+void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...)
     __attribute__ ((format(printf, 5, 6)));
 
@@ -26,10 +26,13 @@ void print_log(int level, const char *file, int line, int dm_errno,
 #define LOG_LINE_WITH_ERRNO(l, e, x...) \
     print_log(l, __FILE__, __LINE__ , e, ## x)
 
+#define LOG_LINE_WITH_CLASS(l, c, x...) \
+    print_log(l, __FILE__, __LINE__ , c, ## x)
+
 #include "log.h"
 
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
-			       int dm_errno, const char *message);
+			       int dm_errno_or_class, const char *message);
 
 void init_log_fn(lvm2_log_fn_t log_fn);
 
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index fe38008..35d87ff 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -31,6 +31,7 @@ static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
+static int _debug_classes_logged = DEFAULT_LOGGED_DEBUG_CLASSES;
 static int _log_cmd_name = 0;
 static int _ignorelockingfailure = 0;
 static int _security_level = SECURITY_LEVEL;
@@ -263,6 +264,20 @@ void init_debug(int level)
 	_debug_level = level;
 }
 
+void init_debug_classes_logged(int classes)
+{
+	_debug_classes_logged = classes;
+}
+
+int debug_class_is_logged(int class)
+{
+	/* If no class given, log it */
+	if (!class)
+		return 1;
+
+	return (_debug_classes_logged & class) ? 1 : 0;
+}
+
 int verbose_level(void)
 {
 	return _verbose_level;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 7fe3288..f590fd6 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -29,6 +29,7 @@ void init_full_scan_done(int level);
 void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
+void init_debug_classes_logged(int classes);
 void init_cmd_name(int status);
 void init_ignorelockingfailure(int level);
 void init_lockingfailed(int level);
@@ -58,6 +59,7 @@ int trust_cache(void);
 int verbose_level(void);
 int silent_mode(void);
 int debug_level(void);
+int debug_class_is_logged(int class);
 int ignorelockingfailure(void);
 int lockingfailed(void);
 int security_level(void);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c853ab4..3963022 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -49,10 +49,12 @@ extern "C" {
  * The library user may wish to register their own
  * logging function.  By default errors go to stderr.
  * Use dm_log_with_errno_init(NULL) to restore the default log fn.
+ * Error messages may have a non-zero errno.
+ * Debug messages may have a non-zero class.
  */
 
 typedef void (*dm_log_with_errno_fn) (int level, const char *file, int line,
-				      int dm_errno, const char *f, ...)
+				      int dm_errno_or_class, const char *f, ...)
     __attribute__ ((format(printf, 5, 6)));
 
 void dm_log_with_errno_init(dm_log_with_errno_fn fn);
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 4a0ada8..3d95093 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -110,7 +110,7 @@ void dm_lib_init(void)
 __attribute__((format(printf, 5, 0)))
 static void _default_log_line(int level,
 	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno, 
+	    int line __attribute__((unused)), int dm_errno_or_class, 
 	    const char *f, va_list ap)
 {
 	int use_stderr = level & _LOG_STDERR;
@@ -134,13 +134,13 @@ static void _default_log_line(int level,
 __attribute__((format(printf, 5, 6)))
 static void _default_log_with_errno(int level,
 	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno, 
+	    int line __attribute__((unused)), int dm_errno_or_class, 
 	    const char *f, ...)
 {
 	va_list ap;
 
 	va_start(ap, f);
-	_default_log_line(level, file, line, dm_errno, f, ap);
+	_default_log_line(level, file, line, dm_errno_or_class, f, ap);
 	va_end(ap);
 }
 
diff --git a/libdm/misc/dm-logging.h b/libdm/misc/dm-logging.h
index 13ab804..ed3adfd 100644
--- a/libdm/misc/dm-logging.h
+++ b/libdm/misc/dm-logging.h
@@ -32,6 +32,9 @@ extern dm_log_with_errno_fn dm_log_with_errno;
 #define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, 0, ## x)
 #define LOG_LINE_WITH_ERRNO(l, e, x...) LOG_MESG(l, __FILE__, __LINE__, e, ## x)
 
+/* Debug messages may have a type instead of an errno */
+#define LOG_LINE_WITH_CLASS(l, c, x...) LOG_MESG(l, __FILE__, __LINE__, c, ## x)
+
 #include "log.h"
 
 #endif


