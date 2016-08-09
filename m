From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:47 +0000 (UTC)
Subject: master - lvm: shell: extend log report to cover whole lvm shell's main loop
Message-ID: <20160809173947.DE03D6072E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f21afddeb71c052617afb41fed9a2bd68ad532cf
Commit:        f21afddeb71c052617afb41fed9a2bd68ad532cf
Parent:        7d1125e5b785014d3bae34acd158c528a4222871
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 13:42:57 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:10 2016 +0200

lvm: shell: extend log report to cover whole lvm shell's main loop

When lvm commands are executed in lvm shell, we cover the whole lvm
command execution within this shell now. That means, all messages logged
and status caught during each command execution is now recorded in the
log report, including overall command's return code.
---
 lib/commands/toolcontext.c |    5 ---
 tools/lvm.c                |   64 +++++++++++++++++++++++++++++++++++--------
 tools/reporter.c           |   25 +++++++----------
 tools/toollib.c            |   14 ++++++---
 4 files changed, 71 insertions(+), 37 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 57d3bdc..a7f76ba 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2218,11 +2218,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->cft_def_hash)
 		dm_hash_destroy(cmd->cft_def_hash);
 
-	if (cmd->cmd_report.log_rh) {
-		dm_report_free(cmd->cmd_report.log_rh);
-		cmd->cmd_report.log_rh = NULL;
-	}
-
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
diff --git a/tools/lvm.c b/tools/lvm.c
index c2d5096..2b95c41 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -200,6 +200,12 @@ static int _log_shell_command_status(struct cmd_context *cmd, int ret_code)
 			     stored_errno(), ret_code);
 }
 
+static void _discard_log_report_content(struct cmd_context *cmd)
+{
+	if (cmd->cmd_report.log_rh)
+		dm_report_destroy_rows(cmd->cmd_report.log_rh);
+}
+
 int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
@@ -210,65 +216,76 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	rl_attempted_completion_function = (rl_completion_func_t *) _completion;
 
 	_read_history(cmd);
-
 	_cmdline = cmdline;
 
 	cmd->is_interactive = 1;
+
+	if (!report_format_init(cmd))
+		return_ECMD_FAILED;
+
 	log_set_report_context(LOG_REPORT_CONTEXT_SHELL);
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
 
 	while (1) {
+		log_set_report(cmd->cmd_report.log_rh);
 		log_set_report_object_name_and_id(NULL, NULL);
+
 		free(input);
 		input = readline("lvm> ");
 
 		/* EOF */
 		if (!input) {
+			_discard_log_report_content(cmd);
 			/* readline sends prompt to stdout */
 			printf("\n");
 			break;
 		}
 
 		/* empty line */
-		if (!*input)
+		if (!*input) {
+			_discard_log_report_content(cmd);
 			continue;
+		}
 
 		add_history(input);
 
 		argv = args;
 
 		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
+			_discard_log_report_content(cmd);
 			log_error("Too many arguments, sorry.");
 			continue;
 		}
 
-		if (!argc)
+		if (!argc) {
+			_discard_log_report_content(cmd);
 			continue;
+		}
 
 		if (!strcmp(argv[0], "lvm")) {
 			argv++;
 			argc--;
 		}
 
-		if (!argc)
+		if (!argc) {
+			_discard_log_report_content(cmd);
 			continue;
+		}
 
 		log_set_report_object_name_and_id(argv[0], NULL);
 
+		is_lastlog_cmd = !strcmp(argv[0], "lastlog");
+
+		if (!is_lastlog_cmd)
+			_discard_log_report_content(cmd);
+
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
+			_discard_log_report_content(cmd);
 			remove_history(history_length - 1);
 			log_error("Exiting.");
 			break;
 		}
 
-		is_lastlog_cmd = !strcmp(argv[0], "lastlog");
-
-		if (cmd->cmd_report.log_rh && !is_lastlog_cmd) {
-			/* drop old log report */
-			dm_report_free(cmd->cmd_report.log_rh);
-			cmd->cmd_report.log_rh = NULL;
-		}
-
 		ret = lvm_run_command(cmd, argc, argv);
 		if (ret == ENO_SUCH_CMD)
 			log_error("No such command '%s'.  Try 'help'.",
@@ -282,12 +299,35 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		if (!is_lastlog_cmd)
 			_log_shell_command_status(cmd, ret);
+
+		log_set_report(NULL);
+		dm_report_group_output_and_pop_all(cmd->cmd_report.report_group);
+
+		if (cmd->cmd_report.log_rh &&
+		    !(dm_report_group_push(cmd->cmd_report.report_group,
+					   cmd->cmd_report.log_rh,
+					   (void *) cmd->cmd_report.log_name))) {
+			log_set_report(NULL);
+			log_error("Failed to add log report.");
+			break;
+		}
 	}
 
 	log_restore_report_state(saved_log_report_state);
 	cmd->is_interactive = 0;
 
 	free(input);
+
+	if (cmd->cmd_report.report_group) {
+		dm_report_group_destroy(cmd->cmd_report.report_group);
+		cmd->cmd_report.report_group = NULL;
+	}
+
+	if (cmd->cmd_report.log_rh) {
+		dm_report_free(cmd->cmd_report.log_rh);
+		cmd->cmd_report.report_group = NULL;
+	}
+
 	return 0;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index d386efc..4a622ed 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1387,6 +1387,11 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 	} else
 		r = _do_report(cmd, handle, &args, single_args);
 
+	if (!args.log_only && !dm_report_group_pop(cmd->cmd_report.report_group)) {
+		log_error("Failed to finalize main report section in report group.");
+		r = ECMD_FAILED;
+	}
+
 	destroy_processing_handle(cmd, handle);
 	return r;
 }
@@ -1508,32 +1513,22 @@ bad:
 	return 0;
 }
 
-int lastlog(struct cmd_context *cmd, int argc, char **argv)
+int lastlog(struct cmd_context *cmd, int argc __attribute((unused)), char **argv __attribute__((unused)))
 {
-	struct dm_report_group *report_group = NULL;
 	const char *selection;
-	int r = ECMD_FAILED;
 
 	if (!cmd->cmd_report.log_rh) {
 		log_error("No log report stored.");
-		goto out;
+		return ECMD_FAILED;
 	}
 
 	if (!_do_report_get_selection(cmd, CMDLOG, 1, NULL, &selection))
-		goto_out;
+		return_ECMD_FAILED;
 
 	if (!dm_report_set_selection(cmd->cmd_report.log_rh, selection)) {
 		log_error("Failed to set selection for log report.");
-		goto out;
+		return ECMD_FAILED;
 	}
 
-	if (!dm_report_output(cmd->cmd_report.log_rh) ||
-	    !dm_report_group_pop(report_group))
-		goto_out;
-
-	r = ECMD_PROCESSED;
-out:
-	if (!dm_report_group_destroy(report_group))
-		stack;
-	return r;
+	return ECMD_PROCESSED;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index bcf94ea..e24946f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1798,11 +1798,15 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 
 		log_restore_report_state(cmd->cmd_report.saved_log_report_state);
 
-		if (!dm_report_group_destroy(cmd->cmd_report.report_group))
-			stack;
-		if (!cmd->is_interactive && cmd->cmd_report.log_rh) {
-			dm_report_free(cmd->cmd_report.log_rh);
-			cmd->cmd_report.log_rh = NULL;
+		if (!cmd->is_interactive) {
+			if (!dm_report_group_destroy(cmd->cmd_report.report_group))
+				stack;
+			cmd->cmd_report.report_group = NULL;
+
+			if (cmd->cmd_report.log_rh) {
+				dm_report_free(cmd->cmd_report.log_rh);
+				cmd->cmd_report.log_rh = NULL;
+			}
 		}
 		/*
 		 * TODO: think about better alternatives:


