From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 May 2016 12:05:02 +0000 (UTC)
Subject: master - refactor: separate original _report fn into _report and _do_report fn
Message-ID: <20160510120502.4504960D4C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c18b0ce9c5e4f94cce83a98cb2d996875cfa812
Commit:        5c18b0ce9c5e4f94cce83a98cb2d996875cfa812
Parent:        04987e7f49b7e4752b9716f04a0a10221f2ada8b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 10 13:57:23 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 10 14:00:13 2016 +0200

refactor: separate original _report fn into _report and _do_report fn

The _report fn is getting big - separate it in two:

  - _report fn to get all the options and arguments
  - _do_report fn for reporting itself

Also, place all the variables/arguments in one structure for easier
handling of the variables around.
---
 tools/reporter.c |  403 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 215 insertions(+), 188 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index fb09263..4e27159 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -17,6 +17,24 @@
 
 #include "report.h"
 
+struct report_args {
+	int argc;
+	char **argv;
+	report_type_t report_type;
+	int args_are_pvs;
+	int aligned;
+	int buffered;
+	int headings;
+	int field_prefixes;
+	int quoted;
+	int columns_as_rows;
+	const char *keys;
+	const char *options;
+	const char *fields_to_compact;
+	const char *separator;
+	const char *selection;
+};
+
 static int _process_each_devtype(struct cmd_context *cmd, int argc,
 				 struct processing_handle *handle)
 {
@@ -605,31 +623,30 @@ int report_for_selection(struct cmd_context *cmd,
 	return r;
 }
 
-static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
-			   report_type_t *report_type, unsigned *args_are_pvs)
+static void _check_pv_list(struct cmd_context *cmd, struct report_args *args)
 {
 	unsigned i;
 	int rescan_done = 0;
 
-	*args_are_pvs = (*report_type == PVS ||
-			 *report_type == LABEL ||
-			 *report_type == PVSEGS) ? 1 : 0;
+	args->args_are_pvs = (args->report_type == PVS ||
+			     args->report_type == LABEL ||
+			     args->report_type == PVSEGS) ? 1 : 0;
 
-	if (*args_are_pvs && argc) {
-		for (i = 0; i < argc; i++) {
-			if (!rescan_done && !dev_cache_get(argv[i], cmd->full_filter)) {
+	if (args->args_are_pvs && args->argc) {
+		for (i = 0; i < args->argc; i++) {
+			if (!rescan_done && !dev_cache_get(args->argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);
 				/* FIXME scan only one device */
 				lvmcache_label_scan(cmd);
 				rescan_done = 1;
 			}
-			if (*argv[i] == '@') {
+			if (*args->argv[i] == '@') {
 				/*
 				 * Tags are metadata related, not label
 				 * related, change report type accordingly!
 				 */
-				if (*report_type == LABEL)
-					*report_type = PVS;
+				if (args->report_type == LABEL)
+					args->report_type = PVS;
 				/*
 				 * If we changed the report_type and we did rescan,
 				 * no need to iterate over dev list further - nothing
@@ -679,11 +696,9 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 }
 
 static int _get_report_options(struct cmd_context *cmd,
-			       report_type_t report_type,
-			       const char **options,
-			       const char **fields_to_compact)
+			       struct report_args *args)
 {
-	const char *prefix = report_get_field_prefix(report_type);
+	const char *prefix = report_get_field_prefix(args->report_type);
 	size_t prefix_len = strlen(prefix);
 	struct arg_value_group_list *current_group;
 	struct dm_list *final_opts_list;
@@ -699,7 +714,7 @@ static int _get_report_options(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
-	if (!(final_opts_list = str_to_str_list(mem, *options, ",", 1))) {
+	if (!(final_opts_list = str_to_str_list(mem, args->options, ",", 1))) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
@@ -746,13 +761,13 @@ static int _get_report_options(struct cmd_context *cmd,
 		}
 	}
 
-	if (!(*options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
+	if (!(args->options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
 	if (final_compact_list &&
-	    !(*fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
-		dm_pool_free(cmd->mem, (char *) *options);
+	    !(args->fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
+		dm_pool_free(cmd->mem, (char *) args->options);
 		r = ECMD_FAILED;
 		goto_out;
 	}
@@ -762,131 +777,30 @@ out:
 	return r;
 }
 
-static int _report(struct cmd_context *cmd, int argc, char **argv,
-		   report_type_t report_type)
+static int _do_report(struct cmd_context *cmd, struct report_args *args)
 {
-	void *report_handle = NULL;
 	struct processing_handle *handle = NULL;
-	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
-	int r = ECMD_FAILED;
-	int aligned, buffered, headings, field_prefixes, quoted;
-	int columns_as_rows;
-	unsigned args_are_pvs;
-	int lv_info_needed, lv_segment_status_needed;
+	report_type_t report_type = args->report_type;
+	void *report_handle = NULL;
 	int lock_global = 0;
-	const char *fields_to_compact = NULL;
-
-	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
-	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
-	headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
-	separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
-	field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
-	quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
-	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
-
-	/*
-	 * Include foreign VGs that contain active LVs.
-	 * That shouldn't happen in general, but if it does by some
-	 * mistake, then we want to display those VGs and allow the
-	 * LVs to be deactivated.
-	 */
-	cmd->include_active_foreign_vgs = 1;
-
-	/* Check PV specifics and do extra changes/actions if needed. */
-	_check_pv_list(cmd, argc, argv, &report_type, &args_are_pvs);
-
-	switch (report_type) {
-	case DEVTYPES:
-		keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
-		break;
-	case LVS:
-		keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
-		break;
-	case VGS:
-		keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
-		break;
-	case LABEL:
-	case PVS:
-		keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
-		break;
-	case SEGS:
-		keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
-		break;
-	case PVSEGS:
-		keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
-		if (!arg_count(cmd, verbose_ARG))
-			options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
-		else
-			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
-		break;
-	default:
-		log_error(INTERNAL_ERROR "Unknown report type.");
-		goto out;
-	}
-
-	/* If -o supplied use it, else use default for report_type */
-	if (arg_count(cmd, options_ARG) &&
-	    ((r = _get_report_options(cmd, report_type, &options, &fields_to_compact) != ECMD_PROCESSED)))
-		goto_out;
-
-	/* -O overrides default sort settings */
-	keys = arg_str_value(cmd, sort_ARG, keys);
-
-	separator = arg_str_value(cmd, separator_ARG, separator);
-	if (arg_count(cmd, separator_ARG))
-		aligned = 0;
-	if (arg_count(cmd, aligned_ARG))
-		aligned = 1;
-	if (arg_count(cmd, unbuffered_ARG) && !arg_count(cmd, sort_ARG))
-		buffered = 0;
-	if (arg_count(cmd, noheadings_ARG))
-		headings = 0;
-	if (arg_count(cmd, nameprefixes_ARG)) {
-		aligned = 0;
-		field_prefixes = 1;
-	}
-	if (arg_count(cmd, unquoted_ARG))
-		quoted = 0;
-	if (arg_count(cmd, rows_ARG))
-		columns_as_rows = 1;
-
-	if (arg_count(cmd, select_ARG))
-		selection = arg_str_value(cmd, select_ARG, NULL);
+	int lv_info_needed;
+	int lv_segment_status_needed;
+	int r = ECMD_FAILED;
 
 	if (!(handle = init_processing_handle(cmd)))
 		goto_out;
 
-	if (!(report_handle = report_init(cmd, options, keys, &report_type,
-					  separator, aligned, buffered,
-					  headings, field_prefixes, quoted,
-					  columns_as_rows, selection)))
+	if (!(report_handle = report_init(cmd, args->options, args->keys, &report_type,
+					  args->separator, args->aligned, args->buffered,
+					  args->headings, args->field_prefixes, args->quoted,
+					  args->columns_as_rows, args->selection)))
 		goto_out;
 
 	handle->internal_report_for_select = 0;
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 	handle->custom_handle = report_handle;
 
-	if (!_get_final_report_type(args_are_pvs,
+	if (!_get_final_report_type(args->args_are_pvs,
 				    report_type, &lv_info_needed,
 				    &lv_segment_status_needed,
 				    &report_type))
@@ -896,7 +810,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	 * We lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.
 	 */
-	if (args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
+	if (args->args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
 	    !lvmetad_used()) {
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
@@ -906,67 +820,69 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	switch (report_type) {
-	case DEVTYPES:
-		r = _process_each_devtype(cmd, argc, handle);
-		break;
-	case LVSINFO:
-		/* fall through */
-	case LVSSTATUS:
-		/* fall through */
-	case LVSINFOSTATUS:
-		/* fall through */
-	case LVS:
-		r = process_each_lv(cmd, argc, argv, 0, handle,
-				    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
-				    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
-				    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
-										 &_lvs_single);
-		break;
-	case VGS:
-		r = process_each_vg(cmd, argc, argv, NULL, 0,
-				    handle, &_vgs_single);
-		break;
-	case LABEL:
-		r = process_each_label(cmd, argc, argv,
-				       handle, &_label_single);
-		break;
-	case PVS:
-		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL,
-					    arg_is_set(cmd, all_ARG), 0,
-					    handle, &_pvs_single);
-		else
-			r = process_each_vg(cmd, argc, argv, NULL, 0,
-					    handle, &_pvs_in_vg);
-		break;
-	case SEGS:
-		r = process_each_lv(cmd, argc, argv, 0, handle,
-				    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
-				    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
-				    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
-										 &_lvsegs_single);
-		break;
-	case PVSEGS:
-		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL,
-					    arg_is_set(cmd, all_ARG), 0,
-					    handle,
-					    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
-					    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
-					    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
-											 &_pvsegs_single);
-		else
-			r = process_each_vg(cmd, argc, argv, NULL, 0,
-					    handle, &_pvsegs_in_vg);
-		break;
+		case DEVTYPES:
+			r = _process_each_devtype(cmd, args->argc, handle);
+			break;
+		case LVSINFO:
+			/* fall through */
+		case LVSSTATUS:
+			/* fall through */
+		case LVSINFOSTATUS:
+			/* fall through */
+		case LVS:
+			r = process_each_lv(cmd, args->argc, args->argv, 0, handle,
+					    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
+					    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
+					    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
+											 &_lvs_single);
+			break;
+		case VGS:
+			r = process_each_vg(cmd, args->argc, args->argv, NULL, 0,
+					    handle, &_vgs_single);
+			break;
+		case LABEL:
+			r = process_each_label(cmd, args->argc, args->argv,
+					       handle, &_label_single);
+			break;
+		case PVS:
+			if (args->args_are_pvs)
+				r = process_each_pv(cmd, args->argc, args->argv, NULL,
+						    arg_is_set(cmd, all_ARG), 0,
+						    handle, &_pvs_single);
+			else
+				r = process_each_vg(cmd, args->argc, args->argv, NULL,
+						    0, handle, &_pvs_in_vg);
+			break;
+		case SEGS:
+			r = process_each_lv(cmd, args->argc, args->argv, 0, handle,
+					    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
+					    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
+					    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
+											 &_lvsegs_single);
+			break;
+		case PVSEGS:
+			if (args->args_are_pvs)
+				r = process_each_pv(cmd, args->argc, args->argv, NULL,
+						    arg_is_set(cmd, all_ARG), 0,
+						    handle,
+						    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
+						    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
+						    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
+												 &_pvsegs_single);
+			else
+				r = process_each_vg(cmd, args->argc, args->argv, NULL,
+						    0, handle, &_pvsegs_in_vg);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_do_report: unknown report type.");
+			return 0;
 	}
 
 	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL)) {
 		if (!dm_report_compact_fields(report_handle))
 			log_error("Failed to compact report output.");
-	} else if (fields_to_compact ||
-		   (fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL))) {
-		if (!dm_report_compact_given_fields(report_handle, fields_to_compact))
+	} else if (args->fields_to_compact) {
+		if (!dm_report_compact_given_fields(report_handle, args->fields_to_compact))
 			log_error("Failed to compact given columns in report output.");
 	}
 
@@ -982,6 +898,117 @@ out:
 	return r;
 }
 
+static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t report_type)
+{
+	struct report_args args = {0};
+
+	/*
+	 * Include foreign VGs that contain active LVs.
+	 * That shouldn't happen in general, but if it does by some
+	 * mistake, then we want to display those VGs and allow the
+	 * LVs to be deactivated.
+	 */
+	cmd->include_active_foreign_vgs = 1;
+
+	args.argc = argc;
+	args.argv = argv;
+	args.report_type = report_type;
+
+	args.aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
+	args.buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
+	args.headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
+	args.separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
+	args.field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
+	args.quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
+	args.columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
+
+	/* Check PV specifics and do extra changes/actions if needed. */
+	_check_pv_list(cmd, &args);
+
+	switch (args.report_type) {
+		case DEVTYPES:
+			args.keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
+			break;
+		case LVS:
+			args.keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
+			break;
+		case VGS:
+			args.keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
+			break;
+		case LABEL:
+		case PVS:
+			args.keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
+			break;
+		case SEGS:
+			args.keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
+			break;
+		case PVSEGS:
+			args.keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
+			if (!arg_count(cmd, verbose_ARG))
+				args.options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
+			else
+				args.options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_report: unknown report type.");
+			return 0;
+	}
+
+	/* If -o supplied use it, else use default for report_type */
+	if (arg_count(cmd, options_ARG) &&
+	    (_get_report_options(cmd, &args) != ECMD_PROCESSED))
+		return_0;
+
+	if (!args.fields_to_compact)
+		args.fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
+
+	/* -O overrides default sort settings */
+	args.keys = arg_str_value(cmd, sort_ARG, args.keys);
+
+	args.separator = arg_str_value(cmd, separator_ARG, args.separator);
+	if (arg_count(cmd, separator_ARG))
+		args.aligned = 0;
+	if (arg_count(cmd, aligned_ARG))
+		args.aligned = 1;
+	if (arg_count(cmd, unbuffered_ARG) && !arg_count(cmd, sort_ARG))
+		args.buffered = 0;
+	if (arg_count(cmd, noheadings_ARG))
+		args.headings = 0;
+	if (arg_count(cmd, nameprefixes_ARG)) {
+		args.aligned = 0;
+		args.field_prefixes = 1;
+	}
+	if (arg_count(cmd, unquoted_ARG))
+		args.quoted = 0;
+	if (arg_count(cmd, rows_ARG))
+		args.columns_as_rows = 1;
+
+	if (arg_count(cmd, select_ARG))
+		args.selection = arg_str_value(cmd, select_ARG, NULL);
+
+	return _do_report(cmd, &args);
+}
+
 int lvs(struct cmd_context *cmd, int argc, char **argv)
 {
 	report_type_t type;


