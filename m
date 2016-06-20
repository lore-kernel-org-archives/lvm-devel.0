From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:29 +0000 (UTC)
Subject: master - report: separate common report and per-report args
Message-ID: <20160620094029.9858D6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=213434d426622b34f2fd7bc2e74f6e5ca0c6c125
Commit:        213434d426622b34f2fd7bc2e74f6e5ca0c6c125
Parent:        bd0a0ae36b89c3a4ea9f84bfa519e363bc7e407c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 25 13:41:42 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

report: separate common report and per-report args

Separating common report and per-report arguments prepares the code for
handling several reports per one command (for example, the command log
report and LVM command report itself).

Each report can have sort keys, options (fields), list of fields to
compact and selection criteria set individually. Hooks for setting these
per report within one command will be a part of subsequent patches, this
patch only separates new struct single_report_args out of existing
struct report_args.
---
 tools/reporter.c |  177 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 110 insertions(+), 67 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index a4595f7..d8aac68 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -17,23 +17,36 @@
 
 #include "report.h"
 
+typedef enum {
+	REPORT_IDX_NULL = -1,
+	REPORT_IDX_SINGLE,
+	REPORT_IDX_LOG,
+	REPORT_IDX_COUNT
+} report_idx_t;
+
+struct single_report_args {
+	report_type_t report_type;
+	int args_are_pvs;
+	const char *keys;
+	const char *options;
+	const char *fields_to_compact;
+	const char *selection;
+};
+
+/* TODO: configure these common report args only once per cmd */
 struct report_args {
 	int argc;
 	char **argv;
 	dm_report_group_type_t report_group_type;
 	report_type_t report_type;
-	int args_are_pvs;
 	int aligned;
 	int buffered;
 	int headings;
 	int field_prefixes;
 	int quoted;
 	int columns_as_rows;
-	const char *keys;
-	const char *options;
-	const char *fields_to_compact;
 	const char *separator;
-	const char *selection;
+	struct single_report_args single_args[REPORT_IDX_COUNT];
 };
 
 static int _process_each_devtype(struct cmd_context *cmd, int argc,
@@ -625,7 +638,7 @@ int report_for_selection(struct cmd_context *cmd,
 	return r;
 }
 
-static void _check_pv_list(struct cmd_context *cmd, struct report_args *args)
+static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	unsigned i;
 	int rescan_done = 0;
@@ -633,11 +646,11 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args)
 	if (!args->argv)
 		return;
 
-	args->args_are_pvs = (args->report_type == PVS ||
-			     args->report_type == LABEL ||
-			     args->report_type == PVSEGS) ? 1 : 0;
+	single_args->args_are_pvs = (single_args->report_type == PVS ||
+				     single_args->report_type == LABEL ||
+				     single_args->report_type == PVSEGS) ? 1 : 0;
 
-	if (args->args_are_pvs && args->argc) {
+	if (single_args->args_are_pvs && args->argc) {
 		for (i = 0; i < args->argc; i++) {
 			if (!rescan_done && !dev_cache_get(args->argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);
@@ -650,8 +663,8 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args)
 				 * Tags are metadata related, not label
 				 * related, change report type accordingly!
 				 */
-				if (args->report_type == LABEL)
-					args->report_type = PVS;
+				if (single_args->report_type == LABEL)
+					single_args->report_type = PVS;
 				/*
 				 * If we changed the report_type and we did rescan,
 				 * no need to iterate over dev list further - nothing
@@ -701,9 +714,10 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 }
 
 static int _get_report_options(struct cmd_context *cmd,
-			       struct report_args *args)
+			       struct report_args *args,
+			       struct single_report_args *single_args)
 {
-	const char *prefix = report_get_field_prefix(args->report_type);
+	const char *prefix = report_get_field_prefix(single_args->report_type);
 	size_t prefix_len = strlen(prefix);
 	struct arg_value_group_list *current_group;
 	struct dm_list *final_opts_list;
@@ -714,12 +728,15 @@ static int _get_report_options(struct cmd_context *cmd,
 	struct dm_pool *mem;
 	int r = ECMD_PROCESSED;
 
+	if (!arg_count(cmd, options_ARG))
+		return ECMD_PROCESSED;
+
 	if (!(mem = dm_pool_create("report_options", 128))) {
 		log_error("Failed to create temporary mempool to process report options.");
 		return ECMD_FAILED;
 	}
 
-	if (!(final_opts_list = str_to_str_list(mem, args->options, ",", 1))) {
+	if (!(final_opts_list = str_to_str_list(mem, single_args->options, ",", 1))) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
@@ -766,13 +783,13 @@ static int _get_report_options(struct cmd_context *cmd,
 		}
 	}
 
-	if (!(args->options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
+	if (!(single_args->options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
 	if (final_compact_list &&
-	    !(args->fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
-		dm_pool_free(cmd->mem, (char *) args->options);
+	    !(single_args->fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
+		dm_pool_free(cmd->mem, (char *) single_args->options);
 		r = ECMD_FAILED;
 		goto_out;
 	}
@@ -782,10 +799,33 @@ out:
 	return r;
 }
 
-static int _do_report(struct cmd_context *cmd, struct report_args *args)
+static int _get_report_keys(struct cmd_context *cmd,
+			    struct report_args *args,
+			    struct single_report_args *single_args)
+{
+	int r = ECMD_PROCESSED;
+
+	single_args->keys = arg_str_value(cmd, sort_ARG, single_args->keys);
+
+	return r;
+}
+
+static int _get_report_selection(struct cmd_context *cmd,
+				 struct report_args *args,
+				 struct single_report_args *single_args)
+{
+	int r = ECMD_PROCESSED;
+
+	if (arg_count(cmd, select_ARG))
+		single_args->selection = arg_str_value(cmd, select_ARG, NULL);
+
+	return r;
+}
+
+static int _do_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	struct processing_handle *handle = NULL;
-	report_type_t report_type = args->report_type;
+	report_type_t report_type = single_args->report_type;
 	void *report_handle = NULL;
 	int lock_global = 0;
 	int lv_info_needed;
@@ -795,17 +835,17 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 	if (!(handle = init_processing_handle(cmd)))
 		goto_out;
 
-	if (!(report_handle = report_init(cmd, args->options, args->keys, &report_type,
+	if (!(report_handle = report_init(cmd, single_args->options, single_args->keys, &report_type,
 					  args->separator, args->aligned, args->buffered,
 					  args->headings, args->field_prefixes, args->quoted,
-					  args->columns_as_rows, args->selection)))
+					  args->columns_as_rows, single_args->selection)))
 		goto_out;
 
 	handle->internal_report_for_select = 0;
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 	handle->custom_handle = report_handle;
 
-	if (!_get_final_report_type(args->args_are_pvs,
+	if (!_get_final_report_type(single_args->args_are_pvs,
 				    report_type, &lv_info_needed,
 				    &lv_segment_status_needed,
 				    &report_type))
@@ -815,7 +855,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 	 * We lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.
 	 */
-	if (args->args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
+	if (single_args->args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
 	    !lvmetad_used()) {
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
@@ -850,7 +890,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 					       handle, &_label_single);
 			break;
 		case PVS:
-			if (args->args_are_pvs)
+			if (single_args->args_are_pvs)
 				r = process_each_pv(cmd, args->argc, args->argv, NULL,
 						    arg_is_set(cmd, all_ARG), 0,
 						    handle, &_pvs_single);
@@ -866,7 +906,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 											 &_lvsegs_single);
 			break;
 		case PVSEGS:
-			if (args->args_are_pvs)
+			if (single_args->args_are_pvs)
 				r = process_each_pv(cmd, args->argc, args->argv, NULL,
 						    arg_is_set(cmd, all_ARG), 0,
 						    handle,
@@ -889,8 +929,8 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL)) {
 		if (!dm_report_compact_fields(report_handle))
 			log_error("Failed to compact report output.");
-	} else if (args->fields_to_compact) {
-		if (!dm_report_compact_given_fields(report_handle, args->fields_to_compact))
+	} else if (single_args->fields_to_compact) {
+		if (!dm_report_compact_given_fields(report_handle, single_args->fields_to_compact))
 			log_error("Failed to compact given columns in report output.");
 	}
 
@@ -906,7 +946,7 @@ out:
 	return r;
 }
 
-static int _config_report(struct cmd_context *cmd, struct report_args *args)
+static int _config_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	args->aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	args->buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
@@ -917,71 +957,73 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args)
 	args->columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
 
 	/* Check PV specifics and do extra changes/actions if needed. */
-	_check_pv_list(cmd, args);
+	_check_pv_list(cmd, args, single_args);
 
-	switch (args->report_type) {
+	switch (single_args->report_type) {
 		case DEVTYPES:
-			args->keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
 			break;
 		case LVS:
-			args->keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
 			break;
 		case VGS:
-			args->keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
 			break;
 		case LABEL:
 		case PVS:
-			args->keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
 			break;
 		case SEGS:
-			args->keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
 			break;
 		case PVSEGS:
-			args->keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args->options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
 			else
-				args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
+				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
 		case CMDLOG:
-			args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);
-			args->options = find_config_tree_str(cmd, log_command_log_cols_CFG, NULL);
+			single_args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);
+			single_args->options = find_config_tree_str(cmd, log_command_log_cols_CFG, NULL);
 			break;
 		default:
 			log_error(INTERNAL_ERROR "_report: unknown report type.");
 			return 0;
 	}
 
+	single_args->fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
+
 	/* If -o supplied use it, else use default for report_type */
-	if (arg_count(cmd, options_ARG) &&
-	    (_get_report_options(cmd, args) != ECMD_PROCESSED))
+	if ((_get_report_options(cmd, args, single_args) != ECMD_PROCESSED))
 		return_0;
 
-	if (!args->fields_to_compact)
-		args->fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
-
 	/* -O overrides default sort settings */
-	args->keys = arg_str_value(cmd, sort_ARG, args->keys);
+	if ((_get_report_keys(cmd, args, single_args) != ECMD_PROCESSED))
+		return_0;
+
+	if ((_get_report_selection(cmd, args, single_args) != ECMD_PROCESSED))
+		return_0;
 
 	args->separator = arg_str_value(cmd, separator_ARG, args->separator);
 	if (arg_count(cmd, separator_ARG))
@@ -1001,15 +1043,13 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args)
 	if (arg_count(cmd, rows_ARG))
 		args->columns_as_rows = 1;
 
-	if (arg_count(cmd, select_ARG))
-		args->selection = arg_str_value(cmd, select_ARG, NULL);
-
 	return 1;
 }
 
 static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t report_type)
 {
 	struct report_args args = {0};
+	struct single_report_args *single_args = &args.single_args[REPORT_IDX_SINGLE];
 
 	/*
 	 * Include foreign VGs that contain active LVs.
@@ -1021,12 +1061,12 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 
 	args.argc = argc;
 	args.argv = argv;
-	args.report_type = report_type;
+	single_args->report_type = report_type;
 
-	if (!_config_report(cmd, &args))
+	if (!_config_report(cmd, &args, single_args))
 		return_ECMD_FAILED;
 
-	return _do_report(cmd, &args);
+	return _do_report(cmd, &args, single_args);
 }
 
 int lvs(struct cmd_context *cmd, int argc, char **argv)
@@ -1075,6 +1115,7 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 	const char *format_str = arg_str_value(cmd, reportformat_ARG, config_set ? config_format_str : NULL);
 	int report_command_log = find_config_tree_bool(cmd, log_report_command_log_CFG, NULL);
 	struct report_args args = {0};
+	struct single_report_args *single_args;
 	struct dm_report_group *new_report_group;
 	struct dm_report *tmp_log_rh = NULL;
 
@@ -1101,14 +1142,16 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 
 	if (report_command_log) {
 		if (!*log_rh) {
-			args.report_type = CMDLOG;
-			if (!_config_report(cmd, &args))
+			single_args = &args.single_args[REPORT_IDX_LOG];
+			single_args->report_type = CMDLOG;
+
+			if (!_config_report(cmd, &args, single_args))
 				goto_bad;
 
-			if (!(tmp_log_rh = report_init(NULL, args.options, args.keys, &args.report_type,
+			if (!(tmp_log_rh = report_init(NULL, single_args->options, single_args->keys, &single_args->report_type,
 							  args.separator, args.aligned, args.buffered, args.headings,
 							  args.field_prefixes, args.quoted, args.columns_as_rows,
-							  args.selection))) {
+							  single_args->selection))) {
 				log_error("Failed to create log report.");
 				goto bad;
 			}


