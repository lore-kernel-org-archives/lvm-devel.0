From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 May 2016 08:57:09 +0000 (UTC)
Subject: master - refactor: split _report fn further into init and config part
Message-ID: <20160524085710.0290E60D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=adeb624c3bdfa5b444becb6918486b49a8d9ce4d
Commit:        adeb624c3bdfa5b444becb6918486b49a8d9ce4d
Parent:        8c872852cdbc4c3f9572379bc87e1455b28fbe6f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 23 11:18:50 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 24 10:56:57 2016 +0200

refactor: split _report fn further into init and config part

---
 tools/reporter.c |  123 +++++++++++++++++++++++++++++------------------------
 1 files changed, 67 insertions(+), 56 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 4004f9b..04ef8f2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -628,6 +628,9 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args)
 	unsigned i;
 	int rescan_done = 0;
 
+	if (!args->argv)
+		return;
+
 	args->args_are_pvs = (args->report_type == PVS ||
 			     args->report_type == LABEL ||
 			     args->report_type == PVSEGS) ? 1 : 0;
@@ -898,76 +901,62 @@ out:
 	return r;
 }
 
-static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t report_type)
+static int _config_report(struct cmd_context *cmd, struct report_args *args)
 {
-	struct report_args args = {0};
-
-	/*
-	 * Include foreign VGs that contain active LVs.
-	 * That shouldn't happen in general, but if it does by some
-	 * mistake, then we want to display those VGs and allow the
-	 * LVs to be deactivated.
-	 */
-	cmd->include_active_foreign_vgs = 1;
-
-	args.argc = argc;
-	args.argv = argv;
-	args.report_type = report_type;
-
-	args.aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
-	args.buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
-	args.headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
-	args.separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
-	args.field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
-	args.quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
-	args.columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
+	args->aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
+	args->buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
+	args->headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
+	args->separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
+	args->field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
+	args->quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
+	args->columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
 
 	/* Check PV specifics and do extra changes/actions if needed. */
-	_check_pv_list(cmd, &args);
+	_check_pv_list(cmd, args);
 
-	switch (args.report_type) {
+	switch (args->report_type) {
 		case DEVTYPES:
-			args.keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
 			break;
 		case LVS:
-			args.keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
 			break;
 		case VGS:
-			args.keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
 			break;
 		case LABEL:
 		case PVS:
-			args.keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
 			break;
 		case SEGS:
-			args.keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
 			break;
 		case PVSEGS:
-			args.keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
+			args->keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
 			if (!arg_count(cmd, verbose_ARG))
-				args.options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
 			else
-				args.options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
+				args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
 		default:
 			log_error(INTERNAL_ERROR "_report: unknown report type.");
@@ -976,35 +965,57 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 
 	/* If -o supplied use it, else use default for report_type */
 	if (arg_count(cmd, options_ARG) &&
-	    (_get_report_options(cmd, &args) != ECMD_PROCESSED))
+	    (_get_report_options(cmd, args) != ECMD_PROCESSED))
 		return_0;
 
-	if (!args.fields_to_compact)
-		args.fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
+	if (!args->fields_to_compact)
+		args->fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
 
 	/* -O overrides default sort settings */
-	args.keys = arg_str_value(cmd, sort_ARG, args.keys);
+	args->keys = arg_str_value(cmd, sort_ARG, args->keys);
 
-	args.separator = arg_str_value(cmd, separator_ARG, args.separator);
+	args->separator = arg_str_value(cmd, separator_ARG, args->separator);
 	if (arg_count(cmd, separator_ARG))
-		args.aligned = 0;
+		args->aligned = 0;
 	if (arg_count(cmd, aligned_ARG))
-		args.aligned = 1;
+		args->aligned = 1;
 	if (arg_count(cmd, unbuffered_ARG) && !arg_count(cmd, sort_ARG))
-		args.buffered = 0;
+		args->buffered = 0;
 	if (arg_count(cmd, noheadings_ARG))
-		args.headings = 0;
+		args->headings = 0;
 	if (arg_count(cmd, nameprefixes_ARG)) {
-		args.aligned = 0;
-		args.field_prefixes = 1;
+		args->aligned = 0;
+		args->field_prefixes = 1;
 	}
 	if (arg_count(cmd, unquoted_ARG))
-		args.quoted = 0;
+		args->quoted = 0;
 	if (arg_count(cmd, rows_ARG))
-		args.columns_as_rows = 1;
+		args->columns_as_rows = 1;
 
 	if (arg_count(cmd, select_ARG))
-		args.selection = arg_str_value(cmd, select_ARG, NULL);
+		args->selection = arg_str_value(cmd, select_ARG, NULL);
+
+	return 1;
+}
+
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
+	if (!_config_report(cmd, &args))
+		return_ECMD_FAILED;
 
 	return _do_report(cmd, &args);
 }


