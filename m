From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:37 +0000 (UTC)
Subject: master - refactor: move report grouping and log reporting handles from processing_handle to cmd_context
Message-ID: <20160809173937.6334A602F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1fde4bf4d08cbf579dbbe5eb08661eac67eb68f7
Commit:        1fde4bf4d08cbf579dbbe5eb08661eac67eb68f7
Parent:        ef69934746e7c31aef224129b19ac0cfb8101b5b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 3 15:37:14 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

refactor: move report grouping and log reporting handles from processing_handle to cmd_context

With patches that will follow, this will make it possible to widen log
report coverage when commands are executed from lvm shell so the amount
of messages that may end up in stderr/stdout instead of log report are
minimized.
---
 lib/commands/toolcontext.c |    6 ++-
 lib/commands/toolcontext.h |   13 ++++++-
 lib/report/report.h        |    4 +--
 tools/lvm.c                |   10 +++---
 tools/reporter.c           |   78 ++++++++++++++++++--------------------------
 tools/toollib.c            |   24 ++++---------
 tools/toollib.h            |    5 ---
 7 files changed, 61 insertions(+), 79 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 82e990e..57d3bdc 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2218,8 +2218,10 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->cft_def_hash)
 		dm_hash_destroy(cmd->cft_def_hash);
 
-	if (cmd->log_rh)
-		dm_report_free(cmd->log_rh);
+	if (cmd->cmd_report.log_rh) {
+		dm_report_free(cmd->cmd_report.log_rh);
+		cmd->cmd_report.log_rh = NULL;
+	}
 
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index ee849b5..c6d938d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -66,6 +66,15 @@ struct cmd_context_initialized_parts {
 	unsigned connections:1;
 };
 
+struct cmd_report {
+	int log_only;
+	dm_report_group_type_t report_group_type;
+	struct dm_report_group *report_group;
+	struct dm_report *log_rh;
+	const char *log_name;
+	log_report_t saved_log_report_state;
+};
+
 /* FIXME Split into tool & library contexts */
 /* command-instance-related variables needed by library */
 struct cmd_context {
@@ -186,9 +195,9 @@ struct cmd_context {
 	char proc_dir[PATH_MAX];
 
 	/*
-	 * Command log reporting.
+	 * Reporting.
 	 */
-	struct dm_report *log_rh;		/* keep log report of last cmd for further queries if cmd line is interactive (e.g. lvm shell) */
+	struct cmd_report cmd_report;
 
 	/*
 	 * Buffers.
diff --git a/lib/report/report.h b/lib/report/report.h
index ba3a8fa..cf4145e 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -81,9 +81,7 @@ struct processing_handle;
 typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 				const void *data);
 
-int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
-		       struct dm_report_group **report_group, struct dm_report **log_rh,
-		       int *log_only, log_report_t *saved_log_report_state);
+int report_format_init(struct cmd_context *cmd);
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
diff --git a/tools/lvm.c b/tools/lvm.c
index ec8a352..c2d5096 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -185,12 +185,12 @@ static int _log_shell_command_status(struct cmd_context *cmd, int ret_code)
 {
 	log_report_t log_state;
 
-	if (!cmd->log_rh)
+	if (!cmd->cmd_report.log_rh)
 		return 1;
 
 	log_state = log_get_report_state();
 
-	return report_cmdlog(cmd->log_rh, REPORT_OBJECT_CMDLOG_NAME,
+	return report_cmdlog(cmd->cmd_report.log_rh, REPORT_OBJECT_CMDLOG_NAME,
 			     log_get_report_context_name(log_state.context),
 			     log_get_report_object_type_name(log_state.object_type),
 			     log_state.object_name, log_state.object_id,
@@ -263,10 +263,10 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		is_lastlog_cmd = !strcmp(argv[0], "lastlog");
 
-		if (cmd->log_rh && !is_lastlog_cmd) {
+		if (cmd->cmd_report.log_rh && !is_lastlog_cmd) {
 			/* drop old log report */
-			dm_report_free(cmd->log_rh);
-			cmd->log_rh = NULL;
+			dm_report_free(cmd->cmd_report.log_rh);
+			cmd->cmd_report.log_rh = NULL;
 		}
 
 		ret = lvm_run_command(cmd, argc, argv);
diff --git a/tools/reporter.c b/tools/reporter.c
index ad0a356..d386efc 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1055,7 +1055,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 		goto_out;
 
 	if (!(args->log_only && (single_args->report_type != CMDLOG))) {
-		if (!dm_report_group_push(handle->report_group, report_handle, (void *) single_args->report_name))
+		if (!dm_report_group_push(cmd->cmd_report.report_group, report_handle, (void *) single_args->report_name))
 			goto_out;
 		report_in_group = 1;
 	}
@@ -1174,7 +1174,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 		unlock_vg(cmd, NULL, VG_GLOBAL);
 out:
 	if (report_handle) {
-		if (report_in_group && !dm_report_group_pop(handle->report_group))
+		if (report_in_group && !dm_report_group_pop(cmd->cmd_report.report_group))
 			stack;
 		dm_report_free(report_handle);
 	}
@@ -1197,7 +1197,7 @@ static int _full_report_single(struct cmd_context *cmd,
 
 	args->full_report_vg = vg;
 
-	if (!args->log_only && !dm_report_group_push(handle->report_group, NULL, NULL))
+	if (!args->log_only && !dm_report_group_push(cmd->cmd_report.report_group, NULL, NULL))
 		goto out;
 
 	if (orphan) {
@@ -1213,7 +1213,7 @@ static int _full_report_single(struct cmd_context *cmd,
 			stack;
 	}
 
-	if (!args->log_only && !dm_report_group_pop(handle->report_group))
+	if (!args->log_only && !dm_report_group_pop(cmd->cmd_report.report_group))
 		goto_out;
 out:
 	args->full_report_vg = NULL;
@@ -1367,15 +1367,15 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 	handle->internal_report_for_select = 0;
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 
-	args.report_group_type = handle->report_group_type;
-	args.log_only = handle->log_only;
+	args.report_group_type = cmd->cmd_report.report_group_type;
+	args.log_only = cmd->cmd_report.log_only;
 
 	if (!_config_report(cmd, &args, single_args)) {
 		destroy_processing_handle(cmd, handle);
 		return_ECMD_FAILED;
 	}
 
-	if (!args.log_only && !dm_report_group_push(handle->report_group, NULL, report_name)) {
+	if (!args.log_only && !dm_report_group_push(cmd->cmd_report.report_group, NULL, report_name)) {
 		log_error("Failed to add main report section to report group.");
 		destroy_processing_handle(cmd, handle);
 		return ECMD_FAILED;
@@ -1433,9 +1433,7 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 #define REPORT_FORMAT_NAME_BASIC "basic"
 #define REPORT_FORMAT_NAME_JSON "json"
 
-int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
-		       struct dm_report_group **report_group, struct dm_report **log_rh,
-		       int *log_only, log_report_t *saved_log_report_state)
+int report_format_init(struct cmd_context *cmd)
 {
 	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
 	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
@@ -1446,7 +1444,7 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 	struct dm_report_group *new_report_group;
 	struct dm_report *tmp_log_rh = NULL;
 
-	args.log_only = arg_is_set(cmd, logonly_ARG) || *log_rh;
+	args.log_only = arg_is_set(cmd, logonly_ARG);
 	report_command_log = args.log_only || find_config_tree_bool(cmd, log_report_command_log_CFG, NULL);
 
 	if (!format_str || !strcmp(format_str, REPORT_FORMAT_NAME_BASIC)) {
@@ -1462,10 +1460,8 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 		return 0;
 	}
 
-	if (report_group_type)
-		*report_group_type = args.report_group_type;
-	if (log_only)
-		*log_only = args.log_only;
+	cmd->cmd_report.report_group_type = args.report_group_type;
+	cmd->cmd_report.log_only = args.log_only;
 
 	if (!(new_report_group = dm_report_group_create(args.report_group_type, NULL))) {
 		log_error("Failed to create report group.");
@@ -1476,40 +1472,33 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 		single_args = &args.single_args[REPORT_IDX_LOG];
 		single_args->report_type = CMDLOG;
 
-		if (!*log_rh) {
-			if (!_config_report(cmd, &args, single_args))
-				goto_bad;
+		if (!_config_report(cmd, &args, single_args))
+			goto_bad;
 
-			if (!(tmp_log_rh = report_init(NULL, single_args->options, single_args->keys, &single_args->report_type,
-							  args.separator, args.aligned, args.buffered, args.headings,
-							  args.field_prefixes, args.quoted, args.columns_as_rows,
-							  single_args->selection, 1))) {
-				log_error("Failed to create log report.");
-				goto bad;
-			}
-		} else {
-			/*
-			 * We reusing existing log report handle.
-			 * Just get report's name and prefix now.
-			 */
-			if (!_set_report_prefix_and_name(&args, single_args))
-				goto_bad;
+		if (!(tmp_log_rh = report_init(NULL, single_args->options, single_args->keys, &single_args->report_type,
+						  args.separator, args.aligned, args.buffered, args.headings,
+						  args.field_prefixes, args.quoted, args.columns_as_rows,
+						  single_args->selection, 1))) {
+			log_error("Failed to create log report.");
+			goto bad;
 		}
 
-		if (!(dm_report_group_push(new_report_group, tmp_log_rh ? : *log_rh, (void *) single_args->report_name))) {
+		if (!(dm_report_group_push(new_report_group, tmp_log_rh, (void *) single_args->report_name))) {
 			log_error("Failed to add log report to report group.");
 			goto bad;
 		}
+
+		cmd->cmd_report.log_rh = tmp_log_rh;
+		if (!(cmd->cmd_report.log_name = dm_pool_strdup(cmd->libmem, single_args->report_name))) {
+			log_error("Failed to set log report name for command context.");
+			goto bad;
+		}
 	}
 
-	*report_group = new_report_group;
-	if (tmp_log_rh)
-		*log_rh = tmp_log_rh;
+	cmd->cmd_report.report_group = new_report_group;
+	cmd->cmd_report.saved_log_report_state = log_get_report_state();
+	log_set_report(cmd->cmd_report.log_rh);
 
-	if (saved_log_report_state) {
-		*saved_log_report_state = log_get_report_state();
-		log_set_report(*log_rh);
-	}
 	return 1;
 bad:
 	if (!dm_report_group_destroy(new_report_group))
@@ -1525,23 +1514,20 @@ int lastlog(struct cmd_context *cmd, int argc, char **argv)
 	const char *selection;
 	int r = ECMD_FAILED;
 
-	if (!cmd->log_rh) {
+	if (!cmd->cmd_report.log_rh) {
 		log_error("No log report stored.");
 		goto out;
 	}
 
-	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL, NULL))
-		goto_out;
-
 	if (!_do_report_get_selection(cmd, CMDLOG, 1, NULL, &selection))
 		goto_out;
 
-	if (!dm_report_set_selection(cmd->log_rh, selection)) {
+	if (!dm_report_set_selection(cmd->cmd_report.log_rh, selection)) {
 		log_error("Failed to set selection for log report.");
 		goto out;
 	}
 
-	if (!dm_report_output(cmd->log_rh) ||
+	if (!dm_report_output(cmd->cmd_report.log_rh) ||
 	    !dm_report_group_pop(report_group))
 		goto_out;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 4cd9020..bcf94ea 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1754,15 +1754,13 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct
 	handle->internal_report_for_select = arg_is_set(cmd, select_ARG);
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 
-	if (!parent_handle) {
-		if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
-					&handle->log_rh, &handle->log_only,
-					&handle->saved_log_report_state)) {
+	if (!parent_handle && !cmd->cmd_report.report_group) {
+		if (!report_format_init(cmd)) {
 			dm_pool_free(cmd->mem, handle);
 			return NULL;
 		}
 	} else
-		handle->saved_log_report_state = log_get_report_state();
+		cmd->cmd_report.saved_log_report_state = log_get_report_state();
 
 	log_set_report_context(LOG_REPORT_CONTEXT_PROCESSING);
 	return handle;
@@ -1798,19 +1796,13 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 		if (handle->selection_handle && handle->selection_handle->selection_rh)
 			dm_report_free(handle->selection_handle->selection_rh);
 
-		log_restore_report_state(handle->saved_log_report_state);
+		log_restore_report_state(cmd->cmd_report.saved_log_report_state);
 
-		if (!dm_report_group_destroy(handle->report_group))
+		if (!dm_report_group_destroy(cmd->cmd_report.report_group))
 			stack;
-		if (handle->log_rh) {
-			if (cmd->is_interactive) {
-				/*
-				 * Keep log report if we're interactive so
-				 * we can do further queries on this report.
-				 */
-				cmd->log_rh = handle->log_rh;
-			} else
-				dm_report_free(handle->log_rh);
+		if (!cmd->is_interactive && cmd->cmd_report.log_rh) {
+			dm_report_free(cmd->cmd_report.log_rh);
+			cmd->cmd_report.log_rh = NULL;
 		}
 		/*
 		 * TODO: think about better alternatives:
diff --git a/tools/toollib.h b/tools/toollib.h
index ed5ec76..d5de733 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -73,11 +73,6 @@ struct processing_handle {
 	int internal_report_for_select;
 	int include_historical_lvs;
 	struct selection_handle *selection_handle;
-	dm_report_group_type_t report_group_type;
-	struct dm_report_group *report_group;
-	struct dm_report *log_rh;
-	int log_only;
-	log_report_t saved_log_report_state;
 	void *custom_handle;
 };
 


