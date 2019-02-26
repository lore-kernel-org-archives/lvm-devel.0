From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Feb 2019 11:03:58 -0500
Subject: master - logging: add command[pid] and timestamp to file and verbose output
Message-ID: <201902261603.x1QG3wQD016499@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9aea6ae956543995b30282c984af5fdad2347f07
Commit:        9aea6ae956543995b30282c984af5fdad2347f07
Parent:        ccfbd505fea2f259f7c89dc23b020b838363a611
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 22 12:01:20 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 26 10:03:44 2019 -0600

logging: add command[pid] and timestamp to file and verbose output

Without this, the output from different commands in a single
log file could not be separated.

Change the default "indent" setting to 0 so that the default
debug output does not include variable spaces in the middle
of debug lines.
---
 lib/commands/toolcontext.c   |    4 +-
 lib/commands/toolcontext.h   |    1 -
 lib/config/config_settings.h |    2 +-
 lib/config/defaults.h        |    2 +-
 lib/log/log.c                |   66 +++++++++++++++++++++++++++++++++--------
 lib/misc/lvm-globals.c       |   44 +++++++++++++++++++++++-----
 lib/misc/lvm-globals.h       |    4 ++-
 tools/lvmcmdline.c           |    7 ++--
 8 files changed, 100 insertions(+), 30 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 62e21f7..8abe0df 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -320,8 +320,8 @@ static void _init_logging(struct cmd_context *cmd)
 	cmd->default_settings.msg_prefix = find_config_tree_str_allow_empty(cmd, log_prefix_CFG, NULL);
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
-	cmd->default_settings.cmd_name = find_config_tree_bool(cmd, log_command_names_CFG, NULL);
-	init_cmd_name(cmd->default_settings.cmd_name);
+	/* so that file and verbose output have a command prefix */
+	init_log_command(0, 0);
 
 	/* Test mode */
 	cmd->default_settings.test =
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index e8ce312..959c153 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -44,7 +44,6 @@ struct config_info {
 	const char *fmt_name;
 	const char *dmeventd_executable;
 	uint64_t unit_factor;
-	int cmd_name;		/* Show command name? */
 	mode_t umask;
 	char unit_type;
 	char _padding[1];
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e15494d..0e305e4 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -812,7 +812,7 @@ cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL,
 	"There are 6 syslog-like log levels currently in use: 2 to 7 inclusive.\n"
 	"7 is the most verbose (LOG_DEBUG).\n")
 
-cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_indent_CFG, "indent", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL, 0, NULL,
 	"Indent messages according to their severity.\n")
 
 cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cb013c6..affb4c9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -221,7 +221,7 @@
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_SILENT 0
 #define DEFAULT_LOGLEVEL 0
-#define DEFAULT_INDENT 1
+#define DEFAULT_INDENT 0
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
 #define DEFAULT_UNITS "r"
 #define DEFAULT_SUFFIX 1
diff --git a/lib/log/log.c b/lib/log/log.c
index f6aaa04..8cea402 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -24,6 +24,7 @@
 #include <stdarg.h>
 #include <syslog.h>
 #include <ctype.h>
+#include <time.h>
 
 static FILE *_log_file;
 static char _log_file_path[PATH_MAX];
@@ -36,7 +37,7 @@ static uint64_t _log_file_max_lines = 0;
 static uint64_t _log_file_lines = 0;
 static int _log_direct = 0;
 static int _log_while_suspended = 0;
-static int _indent = 1;
+static int _indent = 0;
 static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
@@ -471,12 +472,40 @@ const char *log_get_report_object_type_name(log_report_object_type_t object_type
 	return log_object_type_names[object_type];
 }
 
+static void _set_time_prefix(char *prefix, int buflen)
+{
+
+	struct timespec ts;
+	struct tm time_info;
+	int len;
+
+	if (clock_gettime(CLOCK_REALTIME, &ts) < 0)
+		goto fail;
+
+	if (!localtime_r(&ts.tv_sec, &time_info))
+		goto fail;
+
+	len = strftime(prefix, buflen, "%H:%M:%S", &time_info);
+	if (!len)
+		goto fail;
+
+	len = dm_snprintf(prefix + len, buflen - len, ".%ld ", ts.tv_nsec/1000);
+	if (len < 0)
+		goto fail;
+
+	return;
+
+fail:
+	*prefix = '\0';
+}
+
 __attribute__ ((format(printf, 5, 0)))
 static void _vprint_log(int level, const char *file, int line, int dm_errno_or_class,
 			const char *format, va_list orig_ap)
 {
 	va_list ap;
 	char buf[1024], message[4096];
+	char time_prefix[32] = "";
 	int bufused, n;
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
@@ -598,10 +627,21 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
       log_it:
 	if (!logged_via_report && ((verbose_level() >= level) && !_log_suppress)) {
 		if (verbose_level() > _LOG_DEBUG) {
-			(void) dm_snprintf(buf, sizeof(buf), "#%s:%-5d ",
-					   file, line);
-		} else
-			buf[0] = '\0';
+			memset(buf, 0, sizeof(buf));
+
+			if (!time_prefix[0])
+				_set_time_prefix(time_prefix, sizeof(time_prefix));
+
+			(void) dm_snprintf(buf, sizeof(buf), "%s%s %s:%d",
+					   time_prefix, log_command_file(), file, line);
+
+		} else {
+			memset(buf, 0, sizeof(buf));
+
+			/* without -vvvv, command[pid] is controlled by config settings */
+
+			(void) dm_snprintf(buf, sizeof(buf), "%s", log_command_info());
+		}
 
 		if (_indent)
 			switch (level) {
@@ -627,8 +667,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 			stream = (use_stderr || (level != _LOG_WARN)) ? err_stream : out_stream;
 			if (stream == err_stream)
 				fflush(out_stream);
-			fprintf(stream, "%s%s%s%s", buf, log_command_name(),
-				_msg_prefix, indent_spaces);
+			fprintf(stream, "%s%s%s", buf, _msg_prefix, indent_spaces);
 			vfprintf(stream, trformat, ap);
 			fputc('\n', stream);
 		}
@@ -643,15 +682,17 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	}
 
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
-		fprintf(_log_file, "%s:%-5d %s%s", file, line, log_command_name(),
-			_msg_prefix);
+		if (!time_prefix[0])
+			_set_time_prefix(time_prefix, sizeof(time_prefix));
+
+		fprintf(_log_file, "%s%s %s:%d%s", time_prefix, log_command_file(), file, line, _msg_prefix);
 
 		va_copy(ap, orig_ap);
 		vfprintf(_log_file, trformat, ap);
 		va_end(ap);
 
 		if (_log_file_max_lines && ++_log_file_lines >= _log_file_max_lines) {
-			fprintf(_log_file, "\n%s:%-5d %sAborting. Command has reached limit "
+			fprintf(_log_file, "\n%s:%d %sAborting. Command has reached limit "
 				"for logged lines (LVM_LOG_FILE_MAX_LINES=" FMTu64 ").",
 				file, line, _msg_prefix,
 				_log_file_max_lines);
@@ -676,9 +717,8 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		_already_logging = 1;
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
-		if ((n = dm_snprintf(buf, sizeof(buf),
-				      "%s:%-5d %s%s", file, line, log_command_name(),
-				      _msg_prefix)) == -1)
+		if ((n = dm_snprintf(buf, sizeof(buf), "%s:%s %s:%d %s",
+				     time_prefix, log_command_file(), file, line, _msg_prefix)) == -1)
 			goto done;
 
 		bufused += n;		/* n does not include '\0' */
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9d169e7..1ddd2fb 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -34,9 +34,10 @@ static enum dev_ext_e _external_device_info_source = DEV_EXT_NONE;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _debug_classes_logged = 0;
-static int _log_cmd_name = 0;
 static int _security_level = SECURITY_LEVEL;
-static char _cmd_name[30] = "";
+static char _log_command_info[40] = "";
+static char _log_command_file[40] = "";
+static char _cmd_name[30] = "none";
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 /* When set, disables update of _dmeventd_monitor & _ignore_suspended_devices */
@@ -147,9 +148,34 @@ void init_ignore_lvm_mirrors(int scan)
 	_ignore_lvm_mirrors = scan;
 }
 
-void init_cmd_name(int status)
+void init_log_command(int log_name, int log_pid)
 {
-	_log_cmd_name = status;
+	memset(_log_command_info, 0, sizeof(_log_command_info));
+	memset(_log_command_file, 0, sizeof(_log_command_file));
+
+	/*
+	 * Always include command name and pid in file and verbose output.
+	 */
+
+	(void) dm_snprintf(_log_command_file, sizeof(_log_command_file), "%s[%d]",
+			   _cmd_name, getpid());
+
+	/*
+	 * This is the prefix that can be configured for each line of stdout.
+	 */
+
+	if (!log_name && !log_pid)
+		return;
+
+	else if (log_name && !log_pid)
+		(void) dm_strncpy(_log_command_info, _cmd_name, sizeof(_log_command_info));
+
+	else if (!log_name && log_pid)
+		(void) dm_snprintf(_log_command_info, sizeof(_log_command_info), "%d", getpid());
+
+	else
+		(void) dm_snprintf(_log_command_info, sizeof(_log_command_info), "%s[%d]",
+				   _cmd_name, getpid());
 }
 
 void init_is_static(unsigned value)
@@ -198,12 +224,14 @@ void set_sysfs_dir_path(const char *path)
 	(void) dm_strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path));
 }
 
-const char *log_command_name(void)
+const char *log_command_info(void)
 {
-	if (!_log_cmd_name)
-		return "";
+	return _log_command_info;
+}
 
-	return _cmd_name;
+const char *log_command_file(void)
+{
+	return _log_command_file;
 }
 
 void init_error_message_produced(int value)
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 793beca..c69b99a 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -36,6 +36,7 @@ void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_debug_classes_logged(int classes);
 void init_cmd_name(int status);
+void init_log_command(int log_name, int log_pid);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
@@ -73,7 +74,8 @@ int mirror_in_sync(void);
 int background_polling(void);
 int ignore_suspended_devices(void);
 int ignore_lvm_mirrors(void);
-const char *log_command_name(void);
+const char *log_command_info(void);
+const char *log_command_file(void);
 unsigned is_static(void);
 int udev_checking(void);
 const char *sysfs_dir_path(void);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 49a6038..b2fb00d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2492,7 +2492,6 @@ static void _apply_current_settings(struct cmd_context *cmd)
 	init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
 	init_msg_prefix(cmd->default_settings.msg_prefix);
-	init_cmd_name(cmd->default_settings.cmd_name);
 
 	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
@@ -2788,6 +2787,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	set_cmd_name(cmd->name);
+
+	init_log_command(find_config_tree_bool(cmd, log_command_names_CFG, NULL), 0);
+
 	configure_command_option_values(cmd->name);
 
 	/* eliminate '-' from all options starting with -- */
@@ -2855,8 +2858,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	cmd->position_argc = argc;
 	cmd->position_argv = argv;
 
-	set_cmd_name(cmd->name);
-
 	if (arg_is_set(cmd, config_ARG))
 		if (!override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;


