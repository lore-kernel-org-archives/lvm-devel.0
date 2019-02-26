From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Feb 2019 15:43:55 -0500
Subject: master - logging: new config settings to specify debug fields
Message-ID: <201902262043.x1QKhtks000907@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90149c303e3c0d2d09b14d218924d0bc6c91469d
Commit:        90149c303e3c0d2d09b14d218924d0bc6c91469d
Parent:        74460f70efca7c8ed76e5980b300668a1a328cc4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 14:31:44 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 26 14:42:16 2019 -0600

logging: new config settings to specify debug fields

For users who do not want all of the fields included
in debug lines, let them specify in lvm.conf which
fields to include.  timestamp, command[pid], and
file:line fields can all be disabled.
---
 lib/commands/toolcontext.c   |   42 +++++++++++++++++++++++++++++++++
 lib/config/config_settings.h |    8 ++++++
 lib/log/log.c                |   52 ++++++++++++++++++++++++++++++++++++-----
 lib/log/log.h                |    7 +++++
 lib/log/lvm-logging.h        |    3 ++
 5 files changed, 105 insertions(+), 7 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8abe0df..29c1bd8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -232,6 +232,45 @@ static void _get_sysfs_dir(struct cmd_context *cmd, char *buf, size_t buf_size)
 	strncpy(buf, sys_mnt, buf_size);
 }
 
+static uint32_t _parse_debug_fields(struct cmd_context *cmd, int cfg, const char *cfgname)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	uint32_t debug_fields = 0;
+
+	if (!(cn = find_config_tree_array(cmd, cfg, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for log/%s.", cfgname);
+		return 0;
+	}
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_verbose("log/%s contains a value which is not a string.  Ignoring.", cfgname);
+			continue;
+		}
+
+		if (!strcasecmp(cv->v.str, "all"))
+			return 0;
+
+		if (!strcasecmp(cv->v.str, "time"))
+			debug_fields |= LOG_DEBUG_FIELD_TIME;
+
+		else if (!strcasecmp(cv->v.str, "command"))
+			debug_fields |= LOG_DEBUG_FIELD_COMMAND;
+
+		else if (!strcasecmp(cv->v.str, "fileline"))
+			debug_fields |= LOG_DEBUG_FIELD_FILELINE;
+
+		else if (!strcasecmp(cv->v.str, "message"))
+			debug_fields |= LOG_DEBUG_FIELD_MESSAGE;
+
+		else
+			log_verbose("Unrecognised value for log/%s: %s", cfgname, cv->v.str);
+	}
+
+	return debug_fields;
+}
+
 static int _parse_debug_classes(struct cmd_context *cmd)
 {
 	const struct dm_config_node *cn;
@@ -350,6 +389,9 @@ static void _init_logging(struct cmd_context *cmd)
 	log_debug("Setting log debug classes to %d", cmd->default_settings.debug_classes);
 	init_debug_classes_logged(cmd->default_settings.debug_classes);
 
+	init_debug_file_fields(_parse_debug_fields(cmd, log_debug_file_fields_CFG, "debug_file_fields"));
+	init_debug_output_fields(_parse_debug_fields(cmd, log_debug_output_fields_CFG, "debug_output_fields"));
+
 	t = time(NULL);
 	ctime_r(&t, &timebuf[0]);
 	timebuf[24] = '\0';
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 0e305e4..c8e629f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -838,6 +838,14 @@ cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMP
 	"available: memory, devices, io, activation, allocation,\n"
 	"metadata, cache, locking, lvmpolld. Use \"all\" to see everything.\n")
 
+cfg_array(log_debug_file_fields_CFG, "debug_file_fields", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, "#Stime#Scommand#Sfileline#Smessage", vsn(2, 3, 2), NULL, 0, NULL,
+	  "The fields included in debug output written to log file.\n"
+	  "Use \"all\" to include everything (the default).\n")
+
+cfg_array(log_debug_output_fields_CFG, "debug_output_fields", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, "#Stime#Scommand#Sfileline#Smessage", vsn(2, 3, 2), NULL, 0, NULL,
+	  "The fields included in debug output written to stderr.\n"
+	  "Use \"all\" to include everything (the default).\n")
+
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain a backup of the current metadata configuration.\n"
 	"Think very hard before turning this off!\n")
diff --git a/lib/log/log.c b/lib/log/log.c
index 8cea402..cb850dc 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -42,6 +42,8 @@ static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
 static int _abort_on_internal_errors_config = 0;
+static uint32_t _debug_file_fields;
+static uint32_t _debug_output_fields;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -472,6 +474,16 @@ const char *log_get_report_object_type_name(log_report_object_type_t object_type
 	return log_object_type_names[object_type];
 }
 
+void init_debug_file_fields(uint32_t debug_fields)
+{
+	_debug_file_fields = debug_fields;
+}
+
+void init_debug_output_fields(uint32_t debug_fields)
+{
+	_debug_output_fields = debug_fields;
+}
+
 static void _set_time_prefix(char *prefix, int buflen)
 {
 
@@ -506,6 +518,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	va_list ap;
 	char buf[1024], message[4096];
 	char time_prefix[32] = "";
+	const char *command_prefix = NULL;
 	int bufused, n;
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
@@ -629,12 +642,24 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		if (verbose_level() > _LOG_DEBUG) {
 			memset(buf, 0, sizeof(buf));
 
-			if (!time_prefix[0])
-				_set_time_prefix(time_prefix, sizeof(time_prefix));
+			if (!_debug_output_fields || (_debug_output_fields & LOG_DEBUG_FIELD_TIME)) {
+				if (!time_prefix[0])
+					_set_time_prefix(time_prefix, sizeof(time_prefix));
+				else
+					time_prefix[0] = '\0';
+			}
 
-			(void) dm_snprintf(buf, sizeof(buf), "%s%s %s:%d",
-					   time_prefix, log_command_file(), file, line);
+			if (!_debug_output_fields || (_debug_output_fields & LOG_DEBUG_FIELD_COMMAND))
+				command_prefix = log_command_file();
+			else
+				command_prefix = NULL;
 
+			if (!_debug_output_fields || (_debug_output_fields & LOG_DEBUG_FIELD_FILELINE))
+				(void) dm_snprintf(buf, sizeof(buf), "%s%s %s:%d",
+					   	   time_prefix, command_prefix ?: "", file, line);
+			else
+				(void) dm_snprintf(buf, sizeof(buf), "%s%s",
+					   	   time_prefix, command_prefix ?: "");
 		} else {
 			memset(buf, 0, sizeof(buf));
 
@@ -682,10 +707,23 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	}
 
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
-		if (!time_prefix[0])
-			_set_time_prefix(time_prefix, sizeof(time_prefix));
 
-		fprintf(_log_file, "%s%s %s:%d%s", time_prefix, log_command_file(), file, line, _msg_prefix);
+		if (!_debug_file_fields || (_debug_file_fields & LOG_DEBUG_FIELD_TIME)) {
+			if (!time_prefix[0])
+				_set_time_prefix(time_prefix, sizeof(time_prefix));
+			else
+				time_prefix[0] = '\0';
+		}
+
+		if (!_debug_file_fields || (_debug_file_fields & LOG_DEBUG_FIELD_COMMAND))
+			command_prefix = log_command_file();
+		else
+			command_prefix = NULL;
+
+		if (!_debug_file_fields || (_debug_file_fields & LOG_DEBUG_FIELD_FILELINE))
+			fprintf(_log_file, "%s%s %s:%d%s", time_prefix, command_prefix ?: "", file, line, _msg_prefix);
+		else
+			fprintf(_log_file, "%s%s %s", time_prefix, command_prefix ?: "", _msg_prefix);
 
 		va_copy(ap, orig_ap);
 		vfprintf(_log_file, trformat, ap);
diff --git a/lib/log/log.h b/lib/log/log.h
index 256fed0..d3848a4 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -57,6 +57,13 @@
 
 #define INTERNAL_ERROR "Internal error: "
 
+#define LOG_DEBUG_FIELD_ALL		0x0000
+#define LOG_DEBUG_FIELD_TIME		0x0001
+#define LOG_DEBUG_FIELD_COMMAND		0x0002
+#define LOG_DEBUG_FIELD_FILELINE	0x0004
+#define LOG_DEBUG_FIELD_MESSAGE		0x0008
+
+
 /*
  * Classes available for debug log messages.
  * These are also listed in doc/example.conf
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index ca93ff4..8a0c0e5 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -48,6 +48,9 @@ void init_log_fn(lvm2_log_fn_t log_fn);
 void init_indent(int indent);
 void init_msg_prefix(const char *prefix);
 
+void init_debug_file_fields(uint32_t debug_fields);
+void init_debug_output_fields(uint32_t debug_fields);
+
 void init_log_file(const char *log_file, int append);
 void unlink_log_file(int ret);
 void init_log_direct(const char *log_file, int append);


