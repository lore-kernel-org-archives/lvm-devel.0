From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:35 +0000 (UTC)
Subject: master - shell: also collect last command's return code for subsequent 'lastlog' invocation
Message-ID: <20160809173935.41E54602F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef69934746e7c31aef224129b19ac0cfb8101b5b
Commit:        ef69934746e7c31aef224129b19ac0cfb8101b5b
Parent:        06ce9b4e4238da58d6c2acda7878dbc51245a8fc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 25 12:20:22 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

shell: also collect last command's return code for subsequent 'lastlog' invocation

Add new log_context=shell and with log_object_type=cmd and
log_object_name=<command_name> for command log report to collect
overall return code from last command (this is reported under
log_type=status).
---
 lib/log/log.c         |    2 ++
 lib/log/lvm-logging.h |    6 ++++++
 tools/lvm.c           |   37 +++++++++++++++++++++++++++++++++++--
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index d021ffe..c933154 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -449,6 +449,7 @@ static const char *_get_log_level_name(int use_stderr, int level)
 const char *log_get_report_context_name(log_report_context_t context)
 {
 	static const char *log_context_names[LOG_REPORT_CONTEXT_COUNT] = {[LOG_REPORT_CONTEXT_NULL] = "",
+									  [LOG_REPORT_CONTEXT_SHELL] = "shell",
 									  [LOG_REPORT_CONTEXT_PROCESSING] = "processing"};
 	return log_context_names[context];
 }
@@ -457,6 +458,7 @@ const char *log_get_report_context_name(log_report_context_t context)
 const char *log_get_report_object_type_name(log_report_object_type_t object_type)
 {
 	static const char *log_object_type_names[LOG_REPORT_OBJECT_TYPE_COUNT] = {[LOG_REPORT_OBJECT_TYPE_NULL] = "",
+										  [LOG_REPORT_OBJECT_TYPE_CMD] = "cmd",
 										  [LOG_REPORT_OBJECT_TYPE_ORPHAN] = "orphan",
 										  [LOG_REPORT_OBJECT_TYPE_PV] = "pv",
 										  [LOG_REPORT_OBJECT_TYPE_LABEL] = "label",
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 7ddbf2c..64c1928 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -77,12 +77,14 @@ void syslog_suppress(int suppress);
 /* Hooks to handle logging through report. */
 typedef enum {
 	LOG_REPORT_CONTEXT_NULL,
+	LOG_REPORT_CONTEXT_SHELL,
 	LOG_REPORT_CONTEXT_PROCESSING,
 	LOG_REPORT_CONTEXT_COUNT
 } log_report_context_t;
 
 typedef enum {
 	LOG_REPORT_OBJECT_TYPE_NULL,
+	LOG_REPORT_OBJECT_TYPE_CMD,
 	LOG_REPORT_OBJECT_TYPE_ORPHAN,
 	LOG_REPORT_OBJECT_TYPE_PV,
 	LOG_REPORT_OBJECT_TYPE_LABEL,
@@ -101,6 +103,10 @@ typedef struct log_report {
 	const char *object_group_id;
 } log_report_t;
 
+#define LOG_STATUS_NAME "status"
+#define LOG_STATUS_SUCCESS "success"
+#define LOG_STATUS_FAILURE "failure"
+
 log_report_t log_get_report_state(void);
 void log_restore_report_state(log_report_t log_report);
 
diff --git a/tools/lvm.c b/tools/lvm.c
index 62cc141..ec8a352 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -181,9 +181,29 @@ static void _write_history(void)
 		log_very_verbose("Couldn't write history to %s.", hist_file);
 }
 
+static int _log_shell_command_status(struct cmd_context *cmd, int ret_code)
+{
+	log_report_t log_state;
+
+	if (!cmd->log_rh)
+		return 1;
+
+	log_state = log_get_report_state();
+
+	return report_cmdlog(cmd->log_rh, REPORT_OBJECT_CMDLOG_NAME,
+			     log_get_report_context_name(log_state.context),
+			     log_get_report_object_type_name(log_state.object_type),
+			     log_state.object_name, log_state.object_id,
+			     log_state.object_group, log_state.object_group_id,
+			     ret_code == ECMD_PROCESSED ? REPORT_OBJECT_CMDLOG_SUCCESS
+							: REPORT_OBJECT_CMDLOG_FAILURE,
+			     stored_errno(), ret_code);
+}
+
 int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 {
-	int argc, ret;
+	log_report_t saved_log_report_state = log_get_report_state();
+	int is_lastlog_cmd, argc, ret;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
 	rl_readline_name = "lvm";
@@ -194,7 +214,11 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	_cmdline = cmdline;
 
 	cmd->is_interactive = 1;
+	log_set_report_context(LOG_REPORT_CONTEXT_SHELL);
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
+
 	while (1) {
+		log_set_report_object_name_and_id(NULL, NULL);
 		free(input);
 		input = readline("lvm> ");
 
@@ -229,13 +253,17 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		if (!argc)
 			continue;
 
+		log_set_report_object_name_and_id(argv[0], NULL);
+
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
 			remove_history(history_length - 1);
 			log_error("Exiting.");
 			break;
 		}
 
-		if (cmd->log_rh && strcmp(argv[0], "lastlog")) {
+		is_lastlog_cmd = !strcmp(argv[0], "lastlog");
+
+		if (cmd->log_rh && !is_lastlog_cmd) {
 			/* drop old log report */
 			dm_report_free(cmd->log_rh);
 			cmd->log_rh = NULL;
@@ -251,7 +279,12 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			log_error("Command failed with status code %d.", ret);
 		}
 		_write_history();
+
+		if (!is_lastlog_cmd)
+			_log_shell_command_status(cmd, ret);
 	}
+
+	log_restore_report_state(saved_log_report_state);
 	cmd->is_interactive = 0;
 
 	free(input);


