From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:52 +0000 (UTC)
Subject: master - report: recognize list of fields to report (-o|--options) for each subreport
Message-ID: <20160620094052.A491A60F36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd26684d5d9f44f7677f6e30a461542d4280a1b9
Commit:        bd26684d5d9f44f7677f6e30a461542d4280a1b9
Parent:        80ffaefb88917f77eafdf36dd4f882cc65706050
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 4 14:07:45 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: recognize list of fields to report (-o|--options) for each subreport

---
 tools/reporter.c |  124 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 81 insertions(+), 43 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 103ae2c..c081e1c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -694,7 +694,6 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 	struct dm_str_list *sl;
 	const char *a = str, *b;
 
-	prefix_len--;
 	dm_list_uniterate(slh, sll, sll) {
 		sl = dm_list_item(slh, struct dm_str_list);
 
@@ -764,38 +763,61 @@ static int _should_process_report_idx(report_type_t report_type, report_idx_t id
 	return 1;
 }
 
+enum opts_list_type {
+	OPTS_REPLACE,
+	OPTS_ADD,
+	OPTS_REMOVE,
+	OPTS_COMPACT
+};
+
 static int _get_report_options(struct cmd_context *cmd,
 			       struct report_args *args,
 			       struct single_report_args *single_args)
 {
-	const char *prefix = report_get_field_prefix(single_args->report_type);
-	size_t prefix_len = strlen(prefix);
+	int action;
 	struct arg_value_group_list *current_group;
-	struct dm_list *final_opts_list;
-	struct dm_list *final_compact_list = NULL;
+	struct dm_list *final_opts_list[REPORT_IDX_COUNT];
 	struct dm_list *opts_list = NULL;
 	struct dm_str_list *sl;
-	const char *opts;
 	struct dm_pool *mem;
-	int r = ECMD_PROCESSED;
+	const char *report_name = NULL;
+	const char *opts;
+	report_idx_t idx = REPORT_IDX_SINGLE;
+	int r = ECMD_FAILED;
 
 	if (!arg_count(cmd, options_ARG))
 		return ECMD_PROCESSED;
 
 	if (!(mem = dm_pool_create("report_options", 128))) {
 		log_error("Failed to create temporary mempool to process report options.");
-		return ECMD_FAILED;
+		goto out;
 	}
 
-	if (!(final_opts_list = str_to_str_list(mem, single_args->options, ",", 1))) {
-		r = ECMD_FAILED;
-		goto_out;
+	if (single_args->report_type == CMDLOG) {
+		if (!(final_opts_list[REPORT_IDX_LOG] = str_to_str_list(mem, single_args->options, ",", 1)))
+			goto_out;
+	} else if (single_args->report_type == FULL) {
+		if (!(final_opts_list[REPORT_IDX_FULL_VGS] = str_to_str_list(mem, args->single_args[REPORT_IDX_FULL_VGS].options, ",", 1)) ||
+		    !(final_opts_list[REPORT_IDX_FULL_PVS] = str_to_str_list(mem, args->single_args[REPORT_IDX_FULL_PVS].options, ",", 1)) ||
+		    !(final_opts_list[REPORT_IDX_FULL_LVS] = str_to_str_list(mem, args->single_args[REPORT_IDX_FULL_LVS].options, ",", 1)) ||
+		    !(final_opts_list[REPORT_IDX_FULL_PVSEGS] = str_to_str_list(mem, args->single_args[REPORT_IDX_FULL_PVSEGS].options, ",", 1)) ||
+		    !(final_opts_list[REPORT_IDX_FULL_SEGS] = str_to_str_list(mem, args->single_args[REPORT_IDX_FULL_SEGS].options, ",", 1)))
+			goto_out;
+	} else {
+		if (!(final_opts_list[REPORT_IDX_SINGLE] = str_to_str_list(mem, single_args->options, ",", 1)))
+			goto_out;
 	}
 
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(current_group->arg_values, options_ARG))
 			continue;
 
+		if (grouped_arg_is_set(current_group->arg_values, configreport_ARG)) {
+			report_name = grouped_arg_str_value(current_group->arg_values, configreport_ARG, NULL);
+			if ((idx = _get_report_idx_from_name(single_args->report_type, report_name)) == REPORT_IDX_NULL)
+				goto_out;
+		}
+
 		opts = grouped_arg_str_value(current_group->arg_values, options_ARG, NULL);
 		if (!opts || !*opts) {
 			log_error("Invalid options string: %s", opts);
@@ -805,48 +827,64 @@ static int _get_report_options(struct cmd_context *cmd,
 
 		switch (*opts) {
 			case '+':
-				/* fall through */
+				action = OPTS_ADD;
+				opts++;
+				break;
 			case '-':
-				/* fall through */
+				action = OPTS_REMOVE;
+				opts++;
+				break;
 			case '#':
-				if (!(opts_list = str_to_str_list(mem, opts + 1, ",", 1))) {
-					r = ECMD_FAILED;
-					goto_out;
-				}
-				if (*opts == '+') {
-					dm_list_splice(final_opts_list, opts_list);
-				} else if (*opts == '-') {
-					dm_list_iterate_items(sl, opts_list)
-						_del_option_from_list(final_opts_list, prefix,
-								      prefix_len, sl->str);
-				} else if (*opts == '#') {
-					if (!final_compact_list)
-						final_compact_list = opts_list;
-					else
-						dm_list_splice(final_compact_list, opts_list);
-				}
+				action = OPTS_COMPACT;
+				opts++;
 				break;
 			default:
-				if (!(final_opts_list = str_to_str_list(mem, opts, ",", 1))) {
-					r = ECMD_FAILED;
-					goto_out;
-				}
+				action = OPTS_REPLACE;
 		}
-	}
 
-	if (!(single_args->options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
-		r = ECMD_FAILED;
-		goto_out;
+		if (!_should_process_report_idx(single_args->report_type, idx))
+			continue;
+
+		if ((action != OPTS_COMPACT) &&
+		    !(opts_list = str_to_str_list(mem, opts, ",", 1)))
+			goto_out;
+
+		switch (action) {
+			case OPTS_ADD:
+				dm_list_splice(final_opts_list[idx], opts_list);
+				break;
+			case OPTS_REMOVE:
+				dm_list_iterate_items(sl, opts_list)
+					_del_option_from_list(final_opts_list[idx], args->single_args[idx].report_prefix,
+							      strlen(args->single_args[idx].report_prefix), sl->str);
+				break;
+			case OPTS_COMPACT:
+				args->single_args[idx].fields_to_compact = opts;
+				break;
+			case OPTS_REPLACE:
+				final_opts_list[idx] = opts_list;
+				break;
+		}
 	}
-	if (final_compact_list &&
-	    !(single_args->fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
-		dm_pool_free(cmd->mem, (char *) single_args->options);
-		r = ECMD_FAILED;
-		goto_out;
+
+	if (single_args->report_type == CMDLOG) {
+		if (!(single_args->options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_LOG], ",")))
+			goto_out;
+	} else if (single_args->report_type == FULL) {
+		if (!(args->single_args[REPORT_IDX_FULL_VGS].options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_FULL_VGS], ",")) ||
+		    !(args->single_args[REPORT_IDX_FULL_PVS].options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_FULL_PVS], ",")) ||
+		    !(args->single_args[REPORT_IDX_FULL_LVS].options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_FULL_LVS], ",")) ||
+		    !(args->single_args[REPORT_IDX_FULL_PVSEGS].options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_FULL_PVSEGS], ",")) ||
+		    !(args->single_args[REPORT_IDX_FULL_SEGS].options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_FULL_SEGS], ",")))
+			goto_out;
+	} else {
+		if (!(single_args->options = str_list_to_str(cmd->mem, final_opts_list[REPORT_IDX_SINGLE], ",")))
+			goto_out;
 	}
+
+	r = ECMD_PROCESSED;
 out:
 	dm_pool_destroy(mem);
-
 	return r;
 }
 


