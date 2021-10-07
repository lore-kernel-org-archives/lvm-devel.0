From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:26 +0000 (GMT)
Subject: main - logging: to the systemd journal
Message-ID: <20211007174326.5451F385843E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbf8e7db74d744c1462a63ae2bc64f4d46e8db9f
Commit:        bbf8e7db74d744c1462a63ae2bc64f4d46e8db9f
Parent:        0b6782fa0139e412f827cc9d1f0cd96ea38e27b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 24 14:19:54 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:06:49 2021 -0500

logging: to the systemd journal

Configure via lvm.conf log/journal or command line --journal.

Possible values:
"command" records command information.
"output" records default command output.
"debug" records full command debugging.

Multiple values can be set in lvm.conf as an array.
One value can be set in --journal which is added to
values set in lvm.conf
---
 lib/commands/toolcontext.c   | 30 +++++++++++++++
 lib/commands/toolcontext.h   |  1 +
 lib/config/config_settings.h |  6 +++
 lib/log/log.c                | 91 ++++++++++++++++++++++++++++++++++++++++++++
 lib/log/log.h                |  4 ++
 lib/log/lvm-logging.h        |  6 +++
 tools/args.h                 |  8 ++++
 tools/command-lines.in       |  2 +-
 tools/lvmcmdline.c           | 12 ++++++
 9 files changed, 159 insertions(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8991aebcf..f939c3e76 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -340,6 +340,33 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 	return debug_classes;
 }
 
+static uint32_t _parse_log_journal(struct cmd_context *cmd, int cfg, const char *cfgname)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	uint32_t fields = 0;
+	uint32_t val;
+
+	if (!(cn = find_config_tree_array(cmd, cfg, NULL))) {
+		log_debug("Unable to find configuration for log/%s.", cfgname);
+		return 0;
+	}
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_verbose("log/%s contains a value which is not a string.  Ignoring.", cfgname);
+			continue;
+		}
+
+		if ((val = log_journal_str_to_val(cv->v.str)))
+			fields |= val;
+		else
+			log_verbose("Unrecognised value for log/%s: %s", cfgname, cv->v.str);
+	}
+
+	return fields;
+}
+
 static void _init_logging(struct cmd_context *cmd)
 {
 	int append = 1;
@@ -408,6 +435,9 @@ static void _init_logging(struct cmd_context *cmd)
 	init_debug_file_fields(_parse_debug_fields(cmd, log_debug_file_fields_CFG, "debug_file_fields"));
 	init_debug_output_fields(_parse_debug_fields(cmd, log_debug_output_fields_CFG, "debug_output_fields"));
 
+	cmd->default_settings.journal = _parse_log_journal(cmd, log_journal_CFG, "journal");
+	init_log_journal(cmd->default_settings.journal);
+
 	t = time(NULL);
 	ctime_r(&t, &timebuf[0]);
 	timebuf[24] = '\0';
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 731cc7ee0..7ccee4571 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -42,6 +42,7 @@ struct config_info {
 	int udev_sync;
 	int udev_fallback;
 	int issue_discards;
+	uint32_t journal;
 	const char *msg_prefix;
 	const char *fmt_name;
 	const char *dmeventd_executable;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index aad0d5989..d280e7adb 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -873,6 +873,12 @@ cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_B
 cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Write error and debug log messages to a file specified here.\n")
 
+cfg_array(log_journal_CFG, "journal", log_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 3, 12), NULL, 0, NULL,
+	  "Record lvm information in the systemd journal.\n"
+	  "command: record commands that are run.\n"
+	  "output: record default output from commands.\n"
+	  "debug: record debug messages from commands.\n")
+
 cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Overwrite the log file each time the program is run.\n")
 
diff --git a/lib/log/log.c b/lib/log/log.c
index 53ff5b156..8ebbf947a 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -25,6 +25,7 @@
 #include <syslog.h>
 #include <ctype.h>
 #include <time.h>
+#include <systemd/sd-journal.h>
 
 static FILE *_log_file;
 static char _log_file_path[PATH_MAX];
@@ -40,6 +41,7 @@ static char _msg_prefix[30] = "  ";
 static int _abort_on_internal_errors_config = 0;
 static uint32_t _debug_file_fields;
 static uint32_t _debug_output_fields;
+static uint32_t _log_journal = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -455,6 +457,11 @@ void init_debug_output_fields(uint32_t debug_fields)
 	_debug_output_fields = debug_fields;
 }
 
+void init_log_journal(uint32_t fields)
+{
+	_log_journal = fields;
+}
+
 static void _set_time_prefix(char *prefix, int buflen)
 {
 
@@ -609,6 +616,33 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	}
 
       log_it:
+
+	if (_log_journal) {
+		int to_journal = 0;
+
+		/* By default the visible command output is _LOG_WARN or less. */
+
+		if (_log_journal & LOG_JOURNAL_DEBUG)
+			to_journal = 1;
+		if ((_log_journal & LOG_JOURNAL_OUTPUT) && (log_level(level) <= _LOG_WARN))
+			to_journal = 1;
+
+		if (to_journal) {
+			int prio;
+			switch (log_level(level)) {
+			case _LOG_ERR:    prio = LOG_ERR; break;
+			case _LOG_WARN:   prio = LOG_WARNING; break;
+			case _LOG_INFO:   prio = LOG_INFO; break;
+			case _LOG_NOTICE: prio = LOG_NOTICE; break;
+			case _LOG_DEBUG:  prio = LOG_DEBUG; break;
+			default:          prio = LOG_INFO;
+			}
+			va_copy(ap, orig_ap);
+			sd_journal_printv(prio, trformat, ap);
+			va_end(ap);
+		}
+	}
+
 	if (!logged_via_report && ((verbose_level() >= level) && !_log_suppress)) {
 		if (verbose_level() > _LOG_DEBUG) {
 			memset(buf, 0, sizeof(buf));
@@ -792,3 +826,60 @@ void log_set_report_object_name_and_id(const char *name, const char *id)
 	_log_report.object_name = name;
 	_log_report.object_id = id;
 }
+
+/*
+ * TODO: log/journal=["daemon_command"]
+ *       daemon_command: record commands that are run by an lvm daemon.
+ *       (i.e. not commands run directly by a user.)
+ *       For this we need to be able to clearly identify when a command is
+ *       being run by dmeventd/lvmpolld/lvmdbusd.
+ *
+ * TODO: log/journal_commmand_names=["lvcreate","lvconvert"]
+ * This would restrict log/journal=["command"] to the listed command names.
+ * Also allow "!command" to exclude a command, e.g. ["!pvs"]
+ *
+ * TODO: log/journal_daemon_command_names=["lvcreate","lvconvert"]
+ * This would restrict log/journal=["dameon_command"] to the listed command names.
+ *
+ * TODO: log/journal_daemon_names=["dmeventd"]
+ * This would restrict log/journal=["daemon_command"] to commands run by
+ * the named daemon.
+ *
+ * TODO: log/command_to_file=<path> would write this info to the file.
+ *
+ * TODO: log/debug_to_file=<path> would write full debugging to the file.
+ *       (the same effect as log/file=<path> log/level=7)
+ */
+
+void log_command(const char *cmd_line, const char *cmd_name, const char *cmd_id)
+{
+	if (_log_journal & LOG_JOURNAL_COMMAND) {
+
+		/*
+		 * TODO: DAEMON=dmeventd|lvmpolld|lvmdbusd,
+		 * Could we include caller info such as libblkid, udev rule, etc?
+		 * Does systemd already record the caller for us?
+		 */
+
+		/* The command line, pid, and other things are automatically included. */
+
+		sd_journal_send("MESSAGE=lvm command %s", cmd_name,
+				"MESSAGE_ID=3ca432788c374e4ba684b834188eca36",
+				"LVM_CMD_NAME=%s", cmd_name,
+				"LVM_CMD_ID=%s", cmd_id,
+				"PRIORITY=%i", LOG_INFO,
+				NULL);
+	}
+}
+
+uint32_t log_journal_str_to_val(const char *str)
+{
+	if (!strcasecmp(str, "command"))
+		return LOG_JOURNAL_COMMAND;
+	if (!strcasecmp(str, "output"))
+		return LOG_JOURNAL_OUTPUT;
+	if (!strcasecmp(str, "debug"))
+		return LOG_JOURNAL_DEBUG;
+	return 0;
+}
+
diff --git a/lib/log/log.h b/lib/log/log.h
index d3848a4f0..b5f05f29b 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -63,6 +63,10 @@
 #define LOG_DEBUG_FIELD_FILELINE	0x0004
 #define LOG_DEBUG_FIELD_MESSAGE		0x0008
 
+#define LOG_JOURNAL_COMMAND             0x0001
+#define LOG_JOURNAL_OUTPUT              0x0002
+#define LOG_JOURNAL_DEBUG               0x0004
+
 
 /*
  * Classes available for debug log messages.
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 39108fc60..fb18a4159 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -62,6 +62,12 @@ void reset_log_duplicated(void);
 void init_syslog(int facility);
 void fin_syslog(void);
 
+void init_log_journal(uint32_t fields);
+uint32_t log_journal_str_to_val(const char *str);
+
+void log_command(const char *cmd_line, const char *cmd_name, const char *cmd_id);
+
+
 int error_message_produced(void);
 void reset_lvm_errno(int store_errmsg);
 int stored_errno(void);
diff --git a/tools/args.h b/tools/args.h
index 8ce176739..774ce33f4 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -323,6 +323,14 @@ arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0,
 arg(importdevices_ARG, '\0', "importdevices", 0, 0, 0,
     "Add devices to the devices file.\n")
 
+arg(journal_ARG, '\0', "journal", string_VAL, 0, 0,
+    "Record information in the systemd journal.\n"
+    "This information is in addition to information\n"
+    "enabled by the lvm.conf log/journal setting.\n"
+    "command: record information about the command.\n"
+    "output: record the default command output.\n"
+    "debug: record full command debugging.\n")
+
 arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
     "By default the PV is labelled with an LVM2 identifier in its second\n"
     "sector (sector 1). This lets you use a different sector near the\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 332ad8a3b..10b23e75d 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -204,7 +204,7 @@
 #
 OO_ALL: --commandprofile String, --config String, --debug,
 --driverloaded Bool, --help, --nolocking, --lockopt String, --longhelp, --profile String, --quiet,
---verbose, --version, --yes, --test, --devicesfile String, --devices PV, --nohints
+--verbose, --version, --yes, --test, --devicesfile String, --devices PV, --nohints --journal String
 
 #
 # options for pvs, lvs, vgs, fullreport
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d82c374c6..1e12bedca 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2017,6 +2017,8 @@ out:
 	log_debug("Recognised command %s (id %d / enum %d).",
 		  commands[best_i].command_id, best_i, commands[best_i].command_enum);
 
+	log_command(cmd->cmd_line, commands[best_i].name, commands[best_i].command_id);
+
 	return &commands[best_i];
 }
 
@@ -2405,6 +2407,15 @@ static void _get_current_output_settings_from_args(struct cmd_context *cmd)
 		cmd->current_settings.verbose = 0;
 		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
+
+	/*
+	 * default_settings.journal is already set from config and has already been
+	 * applied using init_log_journal().
+	 * current_settings have been set to default_settings.
+	 * now --journal value adds to current_settings.
+	 */
+	if (arg_is_set(cmd, journal_ARG))
+		cmd->current_settings.journal |= log_journal_str_to_val(arg_str_value(cmd, journal_ARG, ""));
 }
 
 static void _apply_current_output_settings(struct cmd_context *cmd)
@@ -2414,6 +2425,7 @@ static void _apply_current_output_settings(struct cmd_context *cmd)
 	init_debug_classes_logged(cmd->default_settings.debug_classes);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_silent(cmd->current_settings.silent);
+	init_log_journal(cmd->current_settings.journal);
 }
 
 static int _read_devices_list(struct cmd_context *cmd)


