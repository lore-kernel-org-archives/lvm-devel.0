From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 15 Jul 2009 18:21:35 +0200
Subject: [PATCH 1/2] Add cmd logging for liblvm error reporting: All logging functions have an additional argument: The error code
In-Reply-To: <1247674896-4718-1-git-send-email-twoerner@redhat.com>
References: <1247674896-4718-1-git-send-email-twoerner@redhat.com>
Message-ID: <1247674896-4718-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    7 +++++-
 lib/commands/toolcontext.c    |   26 ++++++++++++---------
 lib/commands/toolcontext.h    |    6 +++++
 lib/log/log.c                 |   51 +++++++++++++++++++++++++++++++++++++----
 lib/log/log.h                 |   18 ++++++++------
 lib/log/lvm-logging.h         |   11 ++++++--
 libdm/misc/dm-logging.h       |    6 ++--
 libdm/mm/dbg_malloc.c         |    2 +-
 liblvm/lvm.h                  |    3 ++
 liblvm/lvm_base.c             |   17 ++++++++++++-
 tools/lvmcmdline.c            |    5 ++++
 11 files changed, 118 insertions(+), 34 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index d559b3a..028698c 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -788,7 +788,12 @@ void lvm_do_backup(const char *vgname)
 int init_lvm(int using_gulm)
 {
 	if (!(cmd = create_toolcontext(1, NULL))) {
-		log_error("Failed to allocate command context");
+		log_error(LVM_GEN_ERR, "Failed to allocate command context");
+		return 0;
+	}
+
+	if (lvm_error(cmd) != 0) {
+		log_error(LVM_GEN_ERR, "Failed to create command context");
 		return 0;
 	}
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 17b168a..bfe1ad5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -190,7 +190,7 @@ static void _init_logging(struct cmd_context *cmd)
 
 	/* Tell device-mapper about our logging */
 #ifdef DEVMAPPER_SUPPORT
-	dm_log_init(print_log);
+	dm_log_with_errno_init(print_log);
 #endif
 }
 
@@ -1083,6 +1083,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
+	/* Log to command */
+	init_log_cmd(cmd);
+
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -1164,16 +1167,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	return cmd;
 
       error:
-	_destroy_tag_configs(cmd);
-	dev_cache_exit();
-	if (cmd->filter)
-		cmd->filter->destroy(cmd->filter);
-	if (cmd->mem)
-		dm_pool_destroy(cmd->mem);
-	if (cmd->libmem)
-		dm_pool_destroy(cmd->libmem);
-	dm_free(cmd);
-	return NULL;
+	return cmd;
 }
 
 static void _destroy_formats(struct dm_list *formats)
@@ -1318,3 +1312,13 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	fin_log();
 	fin_syslog();
 }
+
+int cmd_error(struct cmd_context *cmd)
+{
+	return cmd->error;
+}
+
+const char *cmd_strerror(struct cmd_context *cmd)
+{
+	return cmd->err_string;
+}
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 374b38f..41f947a 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -92,6 +92,9 @@ struct cmd_context {
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
 	char sysfs_dir[PATH_MAX];
+
+	int error;
+	char err_string[8192]; /* fixed size error srting */
 };
 
 /*
@@ -105,4 +108,7 @@ int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 
+int cmd_error(struct cmd_context *cmd);
+const char *cmd_strerror(struct cmd_context *cmd);
+
 #endif
diff --git a/lib/log/log.c b/lib/log/log.c
index 1f67b3f..9b692d6 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "lvm-file.h"
 #include "defaults.h"
+#include "toolcontext.h"
 
 #include <stdarg.h>
 #include <syslog.h>
@@ -37,6 +38,7 @@ static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
+static struct cmd_context *_lvm_log_cmd = NULL;
 
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
@@ -69,6 +71,31 @@ void init_log_direct(const char *log_file, int append)
 	_log_direct = 1;
 }
 
+void init_log_cmd(struct cmd_context *cmd)
+{
+	if (_lvm_log_cmd != NULL) {
+		fprintf(stderr, "Already logging to a context.\n");
+		return;
+	}
+
+	_lvm_log_cmd = cmd;
+}
+
+void release_log_cmd(struct cmd_context *cmd)
+{
+	if (cmd == _lvm_log_cmd)
+		_lvm_log_cmd = NULL;
+}
+
+void reset_log_cmd(struct cmd_context *cmd)
+{
+	if (_lvm_log_cmd == NULL)
+		return;
+
+	_lvm_log_cmd->error = 0;
+	memset(_lvm_log_cmd->err_string, 0, sizeof(_lvm_log_cmd->err_string));
+}
+
 void init_log_while_suspended(int log_while_suspended)
 {
 	_log_while_suspended = log_while_suspended;
@@ -136,7 +163,7 @@ void init_indent(int indent)
 	_indent = indent;
 }
 
-void print_log(int level, const char *file, int line, const char *format, ...)
+void print_log(int level, const char *file, int line, int code, const char *format, ...)
 {
 	va_list ap;
 	char buf[1024], buf2[4096], locn[4096];
@@ -155,7 +182,7 @@ void print_log(int level, const char *file, int line, const char *format, ...)
 
 	trformat = _(format);
 
-	if (_lvm2_log_fn) {
+	if (_lvm2_log_fn || (_lvm_log_cmd && level == _LOG_ERR)) {
 		va_start(ap, format);
 		n = vsnprintf(buf2, sizeof(buf2) - 1, trformat, ap);
 		va_end(ap);
@@ -169,9 +196,23 @@ void print_log(int level, const char *file, int line, const char *format, ...)
 		buf2[sizeof(buf2) - 1] = '\0';
 		message = &buf2[0];
 
-		_lvm2_log_fn(level, file, line, message);
-
-		return;
+		if (_lvm_log_cmd && level == _LOG_ERR) {
+			if (_lvm_log_cmd->error == 0) {
+				_lvm_log_cmd->error = code;
+				_lvm_log_cmd->err_string[0] = '\0';
+				strncpy(_lvm_log_cmd->err_string, message,
+					sizeof(_lvm_log_cmd->err_string));
+			} else {
+				int l = strlen(_lvm_log_cmd->err_string);
+				strncat(_lvm_log_cmd->err_string + l, message,
+					sizeof(_lvm_log_cmd->err_string) - l);
+			}
+			_lvm_log_cmd->err_string[sizeof(_lvm_log_cmd->err_string) - 1] = '\0';			
+		}
+		if (_lvm2_log_fn) {
+			_lvm2_log_fn(level, file, line, message);
+			return;
+		}
 	}
 
       log_it:
diff --git a/lib/log/log.h b/lib/log/log.h
index 110f1b0..e0dcd26 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -50,22 +50,24 @@
 #define _LOG_ERR 3
 #define _LOG_FATAL 2
 
-#define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
-#define log_info(x...) LOG_LINE(_LOG_INFO, x)
-#define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)
-#define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, x)
-#define log_err(x...) LOG_LINE(_LOG_ERR, x)
-#define log_fatal(x...) LOG_LINE(_LOG_FATAL, x)
+#define LVM_GEN_ERR -1
+
+#define log_debug(x...) LOG_LINE(_LOG_DEBUG, 0, x)
+#define log_info(x...) LOG_LINE(_LOG_INFO, 0, x)
+#define log_notice(x...) LOG_LINE(_LOG_NOTICE, 0, x)
+#define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, 0, x)
+#define log_err(c, x...) LOG_LINE(_LOG_ERR, c, x)
+#define log_fatal(x...) LOG_LINE(_LOG_FATAL, 0, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
-#define log_print(args...) LOG_LINE(_LOG_WARN, args)
+#define log_print(args...) LOG_LINE(_LOG_WARN, 0, args)
 #define log_error(args...) log_err(args)
 
 /* System call equivalents */
 #define log_sys_error(x, y) \
-		log_err("%s: %s failed: %s", y, x, strerror(errno))
+		log_err(errno, "%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_very_verbose(x, y) \
 		log_info("%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_debug(x, y) \
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index d267e23..3b67813 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,13 +16,15 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-void print_log(int level, const char *file, int line, const char *format, ...)
-    __attribute__ ((format(printf, 4, 5)));
+void print_log(int level, const char *file, int line, int code, const char *format, ...)
+    __attribute__ ((format(printf, 5, 6)));
 
-#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
+#define LOG_LINE(l, c, x...) print_log(l, __FILE__, __LINE__ , c, ## x)
 
 #include "log.h"
 
+struct cmd_context;
+
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
 			       const char *message);
 
@@ -34,14 +36,17 @@ void init_msg_prefix(const char *prefix);
 void init_log_file(const char *log_file, int append);
 void init_log_direct(const char *log_file, int append);
 void init_log_while_suspended(int log_while_suspended);
+void init_log_cmd(struct cmd_context *cmd);
 
 void fin_log(void);
 void release_log_memory(void);
+void release_log_cmd(struct cmd_context *cmd);
 
 void init_syslog(int facility);
 void fin_syslog(void);
 
 int error_message_produced(void);
+void reset_log_cmd(struct cmd_context *cmd);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
 /* Returns previous setting */
diff --git a/libdm/misc/dm-logging.h b/libdm/misc/dm-logging.h
index ee3ed34..d3d2094 100644
--- a/libdm/misc/dm-logging.h
+++ b/libdm/misc/dm-logging.h
@@ -21,15 +21,15 @@
 extern dm_log_fn dm_log;
 extern dm_log_with_errno_fn dm_log_with_errno;
 
-#define LOG_MESG(l, f, ln, x...) \
+#define LOG_MESG(l, f, ln, c, x...)		\
 	do { \
 		if (dm_log_is_non_default()) \
 			dm_log(l, f, ln, ## x); \
 		else \
-			dm_log_with_errno(l, f, ln, 0, ## x); \
+			dm_log_with_errno(l, f, ln, c, ## x); \
 	} while (0)
 
-#define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, ## x)
+#define LOG_LINE(l, c, x...) LOG_MESG(l, __FILE__, __LINE__, c, ## x)
 
 #include "log.h"
 
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index ea97208..3c51b61 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -205,7 +205,7 @@ int dm_dump_memory_debug(void)
 		}
 		str[sizeof(str) - 1] = '\0';
 
-		LOG_MESG(_LOG_INFO, mb->file, mb->line,
+		LOG_MESG(_LOG_INFO, mb->file, mb->line, LVM_GEN_ERR,
 			 "block %d at %p, size %" PRIsize_t "\t [%s]",
 			 mb->id, mb->magic, mb->length, str);
 		tot += mb->length;
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 19ab5dd..83a85de 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -71,6 +71,9 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+int lvm_error(lvm_t libh);
+const char *lvm_strerror(lvm_t libh);
+
 /**
  * Create a VG with default parameters.
  *
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 4fa8541..2bf72d6 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -30,6 +30,9 @@ lvm_t lvm_create(const char *system_dir)
 	if (!cmd)
 		return NULL;
 	/*
+	if (cmd_error(cmd) != 0)
+		return (lvm_t) cmd;
+
 	 * FIXME: if an non memory error occured, return the cmd (maybe some
 	 * cleanup needed).
 	 */
@@ -58,11 +61,21 @@ lvm_t lvm_create(const char *system_dir)
 void lvm_destroy(lvm_t libh)
 {
 	/* FIXME: error handling */
-	destroy_toolcontext((struct cmd_context *)libh);
+	destroy_toolcontext((struct cmd_context *) libh);
 }
 
 int lvm_reload_config(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
-	return refresh_toolcontext((struct cmd_context *)libh);
+	return refresh_toolcontext((struct cmd_context *) libh);
+}
+
+int lvm_error(lvm_t libh)
+{
+	return cmd_error((struct cmd_context *) libh);
+}
+
+const char *lvm_strerror(lvm_t libh)
+{
+	return cmd_strerror((struct cmd_context *) libh);
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 10cbb12..283d139 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1179,6 +1179,11 @@ struct cmd_context *init_lvm(void)
 	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
+	if (cmd_error(cmd) != 0) {
+		destroy_toolcontext(cmd);
+		return_NULL;
+	}
+
 	return cmd;
 }
 
-- 
1.6.2.5


