From: Thomas Woerner <twoerner@redhat.com>
Date: Tue,  7 Jul 2009 22:20:00 +0200
Subject: [PATCH 1/2] Add cmd logging for liblvm error reporting: All logging functions have an additional argument: The error code This makes the functions incompatible with the old ones.
In-Reply-To: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
Message-ID: <1246998001-17258-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: twoerner <twoerner@redhat.com>

The error code and message is bound to the command and therefore can be used
to have more accurate error conditions for dm, lvm and liblvm.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    7 +++++-
 lib/commands/toolcontext.c    |   33 ++++++++++++++++++------------
 lib/commands/toolcontext.h    |    6 +++++
 lib/log/log.c                 |   44 ++++++++++++++++++++++++++++++++++++----
 lib/log/log.h                 |   16 +++++++-------
 lib/log/lvm-logging.h         |   11 +++++++--
 libdm/libdevmapper.h          |    4 +-
 libdm/libdm-common.c          |    3 +-
 libdm/misc/dm-logging.h       |    2 +-
 libdm/mm/dbg_malloc.c         |    2 +-
 liblvm/Makefile.in            |    2 +
 liblvm/lvm.h                  |    3 ++
 liblvm/lvm_base.c             |   17 ++++++++++++++-
 tools/lvmcmdline.c            |    5 ++++
 tools/pvchange.c              |    5 +--
 tools/pvmove.c                |    6 +---
 16 files changed, 122 insertions(+), 44 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 078afd4..ab90ea6 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -788,7 +788,12 @@ void lvm_do_backup(const char *vgname)
 int init_lvm(int using_gulm)
 {
 	if (!(cmd = create_toolcontext(1, NULL))) {
-		log_error("Failed to allocate command context");
+		log_error(0, "Failed to allocate command context");
+		return 0;
+	}
+
+	if (lvm_error(cmd) != 0) {
+		log_error(0, "Failed to create command context");
 		return 0;
 	}
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4f6cf98..12b881b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1031,6 +1031,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
+	/* Log to command */
+	init_log_cmd(cmd);
+
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -1112,16 +1115,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
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
@@ -1240,12 +1234,15 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(&cmd->formats);
-	cmd->filter->destroy(cmd->filter);
-	dm_pool_destroy(cmd->mem);
+	if (cmd->filter)
+		cmd->filter->destroy(cmd->filter);
+	if (cmd->mem)
+		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
 	_destroy_tags(cmd);
 	_destroy_tag_configs(cmd);
-	dm_pool_destroy(cmd->libmem);
+	if (cmd->libmem)
+		dm_pool_destroy(cmd->libmem);
 	dm_free(cmd);
 
 	release_log_memory();
@@ -1253,3 +1250,13 @@ void destroy_toolcontext(struct cmd_context *cmd)
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
index b5d0e2e..1b01f65 100644
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
index 1f67b3f..6d8cb22 100644
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
@@ -169,9 +196,16 @@ void print_log(int level, const char *file, int line, const char *format, ...)
 		buf2[sizeof(buf2) - 1] = '\0';
 		message = &buf2[0];
 
-		_lvm2_log_fn(level, file, line, message);
-
-		return;
+		if (_lvm_log_cmd && level == _LOG_ERR) {
+			strncpy(_lvm_log_cmd->err_string, message,
+				sizeof(_lvm_log_cmd->err_string));
+			_lvm_log_cmd->err_string[sizeof(_lvm_log_cmd->err_string) - 1] = '\0';
+			_lvm_log_cmd->error = code;
+		}
+		if (_lvm2_log_fn) {
+			_lvm2_log_fn(level, file, line, message);
+			return;
+		}
 	}
 
       log_it:
diff --git a/lib/log/log.h b/lib/log/log.h
index 09a75ad..a55fe84 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -50,22 +50,22 @@
 #define _LOG_ERR 3
 #define _LOG_FATAL 2
 
-#define log_debug(x...) plog(_LOG_DEBUG, x)
-#define log_info(x...) plog(_LOG_INFO, x)
-#define log_notice(x...) plog(_LOG_NOTICE, x)
-#define log_warn(x...) plog(_LOG_WARN | _LOG_STDERR, x)
-#define log_err(x...) plog(_LOG_ERR, x)
-#define log_fatal(x...) plog(_LOG_FATAL, x)
+#define log_debug(x...) plog(_LOG_DEBUG, 0, x)
+#define log_info(x...) plog(_LOG_INFO, 0, x)
+#define log_notice(x...) plog(_LOG_NOTICE, 0, x)
+#define log_warn(x...) plog(_LOG_WARN | _LOG_STDERR, 0, x)
+#define log_err(c, x...) plog(_LOG_ERR, c, x)
+#define log_fatal(x...) plog(_LOG_FATAL, 0, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
-#define log_print(args...) plog(_LOG_WARN, args)
+#define log_print(args...) plog(_LOG_WARN, 0, args)
 #define log_error(args...) log_err(args)
 
 /* System call equivalents */
 #define log_sys_error(x, y) \
-		log_err("%s: %s failed: %s", y, x, strerror(errno))
+		log_err(errno, "%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_very_verbose(x, y) \
 		log_info("%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_debug(x, y) \
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 70693ea..d9202d8 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,13 +16,15 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-void print_log(int level, const char *file, int line, const char *format, ...)
-    __attribute__ ((format(printf, 4, 5)));
+void print_log(int level, const char *file, int line, int code, const char *format, ...)
+    __attribute__ ((format(printf, 5, 6)));
 
-#define plog(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
+#define plog(l, c, x...) print_log(l, __FILE__, __LINE__ , c, ## x)
 
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
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3cecf4c..6dd52a0 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -44,8 +44,8 @@
  */
 
 typedef void (*dm_log_fn) (int level, const char *file, int line,
-			   const char *f, ...)
-    __attribute__ ((format(printf, 4, 5)));
+			   int code, const char *f, ...)
+    __attribute__ ((format(printf, 5, 6)));
 
 /*
  * The library user may wish to register their own
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9246923..291a1b5 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -43,7 +43,8 @@ static int _verbose = 0;
  * function.
  */
 static void _default_log(int level, const char *file __attribute((unused)),
-			 int line __attribute((unused)), const char *f, ...)
+			 int line __attribute((unused)),
+			 int code __attribute((unused)), const char *f, ...)
 {
 	va_list ap;
 	int use_stderr = level & _LOG_STDERR;
diff --git a/libdm/misc/dm-logging.h b/libdm/misc/dm-logging.h
index b25bc55..6505b03 100644
--- a/libdm/misc/dm-logging.h
+++ b/libdm/misc/dm-logging.h
@@ -20,7 +20,7 @@
 
 extern dm_log_fn dm_log;
 
-#define plog(l, x...) dm_log(l, __FILE__, __LINE__, ## x)
+#define plog(l, c, x...) dm_log(l, __FILE__, __LINE__, c, ## x)
 
 #include "log.h"
 
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index ef53fc5..add285a 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -205,7 +205,7 @@ int dm_dump_memory_debug(void)
 		}
 		str[sizeof(str) - 1] = '\0';
 
-		dm_log(_LOG_INFO, mb->file, mb->line,
+		dm_log(_LOG_INFO, mb->file, mb->line, 0,
 		       "block %d at %p, size %" PRIsize_t "\t [%s]",
 		       mb->id, mb->magic, mb->length, str);
 		tot += mb->length;
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index fdd2ecc..3add2b3 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -28,6 +28,8 @@ LIB_STATIC = $(LIB_NAME).a
 endif
 LIB_SHARED = $(LIB_NAME).so
 
+LDDEPS = $(top_srcdir)/libdm/libdevmapper.so $(top_srcdir)/lib/liblvm-internal.a
+
 CLEAN_TARGETS += liblvm.cflow
 
 include $(top_srcdir)/make.tmpl
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 3b60510..ef37b1e 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -54,4 +54,7 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+int lvm_error(lvm_t libh);
+const char *lvm_strerror(lvm_t libh);
+
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 213246a..6d27c4d 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -29,6 +29,9 @@ lvm_t lvm_create(const char *system_dir)
 	cmd = create_toolcontext(1, system_dir);
 	if (!cmd)
 		return NULL;
+	if (cmd_error(cmd) != 0)
+		return (lvm_t) cmd;
+
 	/*
 	 * FIXME: if an non memory error occured, return the cmd (maybe some
 	 * cleanup needed).
@@ -52,11 +55,21 @@ lvm_t lvm_create(const char *system_dir)
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
index 1ad14d0..555be8f 100644
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
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index efc780b..def78cc 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -64,9 +64,8 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error
-			    ("Unable to find \"%s\" in volume group \"%s\"",
-			     pv_name, vg->name);
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_name, vg->name);
 			goto out;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 65b7606..2490863 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -400,15 +400,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 			log_error("Ignoring remaining command line arguments");
 
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-			log_error
-			    ("ABORTING: Failed to generate list of moving LVs");
+			log_error("ABORTING: Failed to generate list of moving LVs");
 			goto out;
 		}
 
 		/* Ensure mirror LV is active */
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			log_error
-			    ("ABORTING: Temporary mirror activation failed.");
+			log_error("ABORTING: Temporary mirror activation failed.");
 			goto out;
 		}
 
-- 
1.6.2.5


