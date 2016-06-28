From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:17 +0000 (UTC)
Subject: master - reporter: simplify --configreport handling for -S|--select and fix an issue reported by coverity
Message-ID: <20160628013317.F32DB60237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b11f09d2a3bd3f6421776a004e62215054fa835
Commit:        1b11f09d2a3bd3f6421776a004e62215054fa835
Parent:        f0768f636edb8da08e46b029380779fd623399de
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 27 10:14:17 2016 +0200
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:27:19 2016 +0100

reporter: simplify --configreport handling for -S|--select and fix an issue reported by coverity

Simplify code around _do_get_report_selection - remove "expected_idxs[]"
argument which is superfluous and add "allow_single" switch instead to
allow for recognition of "--configreport <report_name> -S" as well as
single "-S" if needed.

Null pointer dereferences  (FORWARD_NULL) /safe/guest2/covscan/LVM2.2.02.158/tools/reporter.c: 961 in _do_report_get_selection()
Null pointer dereferences  (FORWARD_NULL) Dereferencing null pointer "single_args".
---
 lib/report/report.h |    2 +-
 tools/reporter.c    |   60 +++++++++++++++++++++++----------------------------
 tools/toollib.c     |    2 +-
 3 files changed, 29 insertions(+), 35 deletions(-)

diff --git a/lib/report/report.h b/lib/report/report.h
index b9028fe..ba3a8fa 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -90,7 +90,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int aligned, int buffered, int headings, int field_prefixes,
 		  int quoted, int columns_as_rows, const char *selection,
 		  int multiple_output);
-int report_get_single_selection(struct cmd_context *cmd, const char **selection);
+int report_get_single_selection(struct cmd_context *cmd, report_type_t report_type, const char **selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
 int report_get_prefix_and_desc(report_type_t report_type_id,
diff --git a/tools/reporter.c b/tools/reporter.c
index 40d449c..6f8ed8f 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -29,6 +29,8 @@ typedef enum {
 	REPORT_IDX_COUNT
 } report_idx_t;
 
+#define REPORT_IDX_FULL_START REPORT_IDX_FULL_VGS
+
 struct single_report_args {
 	report_type_t report_type;
 	char report_prefix[32];
@@ -748,12 +750,10 @@ static report_idx_t _get_report_idx_from_name(report_type_t report_type, const c
 		return REPORT_IDX_NULL;
 
 	/* Change to basic report type for comparison. */
-	if (report_type == LABEL)
+	if ((report_type == LABEL) || (report_type == PVSEGS))
 		report_type = PVS;
 	else if (report_type == SEGS)
 		report_type = LVS;
-	else if (report_type == PVSEGS)
-		report_type = PVSEGS;
 
 	if (!strcasecmp(name, "log"))
 		idx = REPORT_IDX_LOG;
@@ -778,11 +778,11 @@ static report_idx_t _get_report_idx_from_name(report_type_t report_type, const c
 	return idx;
 }
 
-static int _should_process_report_idx(report_type_t report_type, report_idx_t idx)
+static int _should_process_report_idx(report_type_t report_type, int allow_single, report_idx_t idx)
 {
 	if (((idx == REPORT_IDX_LOG) && (report_type != CMDLOG)) ||
-	    ((idx == REPORT_IDX_SINGLE) && ((report_type == FULL) || (report_type == CMDLOG))) ||
-	    ((idx > REPORT_IDX_LOG) && report_type != FULL))
+	    ((idx == REPORT_IDX_SINGLE) && !allow_single) ||
+	    ((idx >= REPORT_IDX_FULL_START) && report_type != FULL))
 		return 0;
 
 	return 1;
@@ -867,7 +867,7 @@ static int _get_report_options(struct cmd_context *cmd,
 				action = OPTS_REPLACE;
 		}
 
-		if (!_should_process_report_idx(single_args->report_type, idx))
+		if (!_should_process_report_idx(single_args->report_type, !(single_args->report_type & (CMDLOG | FULL)), idx))
 			continue;
 
 		if ((action != OPTS_COMPACT) &&
@@ -932,6 +932,9 @@ static int _get_report_keys(struct cmd_context *cmd,
 				goto_out;
 		}
 
+		if (!_should_process_report_idx(single_args->report_type, !(single_args->report_type & (CMDLOG | FULL)), idx))
+			continue;
+
 		args->single_args[idx].keys = grouped_arg_str_value(current_group->arg_values, sort_ARG, NULL);
 	}
 
@@ -941,16 +944,15 @@ out:
 }
 
 static int _do_report_get_selection(struct cmd_context *cmd,
+				    report_type_t report_type,
+				    int allow_single,
 				    struct report_args *args,
-				    struct single_report_args *single_args,
-				    report_idx_t expected_idxs[],
-				    const char **ret_selection)
+				    const char **last_selection)
 {
 	struct arg_value_group_list *current_group;
-	const char *final_selection = "", *selection = NULL;
+	const char *final_selection = NULL, *selection = NULL;
 	const char *report_name = NULL;
 	report_idx_t idx = REPORT_IDX_SINGLE;
-	int i;
 
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(current_group->arg_values, select_ARG))
@@ -958,27 +960,21 @@ static int _do_report_get_selection(struct cmd_context *cmd,
 
 		if (grouped_arg_is_set(current_group->arg_values, configreport_ARG)) {
 			report_name = grouped_arg_str_value(current_group->arg_values, configreport_ARG, NULL);
-			if ((idx = _get_report_idx_from_name(single_args->report_type, report_name)) == REPORT_IDX_NULL)
+			if ((idx = _get_report_idx_from_name(report_type, report_name)) == REPORT_IDX_NULL)
 				return_0;
 		}
 
 		selection = grouped_arg_str_value(current_group->arg_values, select_ARG, NULL);
 
-		if (single_args) {
-			if (!_should_process_report_idx(single_args->report_type, idx))
-				continue;
+		if (!_should_process_report_idx(report_type, allow_single, idx))
+			continue;
+		if (args)
 			args->single_args[idx].selection = selection;
-			final_selection = selection;
-		} else {
-			for (i = 0; expected_idxs[i] != REPORT_IDX_NULL; i++) {
-				if (idx == expected_idxs[i])
-					final_selection = selection;
-			}
-		}
+		final_selection = selection;
 	}
 
-	if (ret_selection)
-		*ret_selection = final_selection;
+	if (last_selection)
+		*last_selection = final_selection;
 
 	return 1;
 }
@@ -987,13 +983,13 @@ static int _get_report_selection(struct cmd_context *cmd,
 				 struct report_args *args,
 				 struct single_report_args *single_args)
 {
-	return _do_report_get_selection(cmd, args, single_args, NULL, NULL) ? ECMD_PROCESSED : ECMD_FAILED;
+	return _do_report_get_selection(cmd, single_args->report_type, !(single_args->report_type & (CMDLOG | FULL)),
+					args, NULL) ? ECMD_PROCESSED : ECMD_FAILED;
 }
 
-int report_get_single_selection(struct cmd_context *cmd, const char **selection)
+int report_get_single_selection(struct cmd_context *cmd, report_type_t report_type, const char **selection)
 {
-	report_idx_t expected_idxs[] = {REPORT_IDX_SINGLE, REPORT_IDX_NULL};
-	return _do_report_get_selection(cmd, NULL, NULL, expected_idxs, selection);
+	return _do_report_get_selection(cmd, report_type, 1, NULL, selection);
 }
 
 static int _set_report_prefix_and_name(struct report_args *args,
@@ -1525,9 +1521,8 @@ bad:
 
 int lastlog(struct cmd_context *cmd, int argc, char **argv)
 {
-	static report_idx_t expected_idxs[] = {REPORT_IDX_SINGLE, REPORT_IDX_LOG, REPORT_IDX_NULL};
 	struct dm_report_group *report_group = NULL;
-	const char *selection = NULL;
+	const char *selection;
 	int r = ECMD_FAILED;
 
 	if (!cmd->log_rh) {
@@ -1538,8 +1533,7 @@ int lastlog(struct cmd_context *cmd, int argc, char **argv)
 	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL, NULL))
 		goto_out;
 
-	if (arg_is_set(cmd, select_ARG) &&
-	    !_do_report_get_selection(cmd, NULL, NULL, expected_idxs, &selection))
+	if (!_do_report_get_selection(cmd, CMDLOG, 1, NULL, &selection))
 		goto_out;
 
 	if (!dm_report_set_selection(cmd->log_rh, selection)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 80d0f32..4c24b16 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1771,7 +1771,7 @@ int init_selection_handle(struct cmd_context *cmd, struct processing_handle *han
 		return 0;
 	}
 
-	if (!report_get_single_selection(cmd, &selection))
+	if (!report_get_single_selection(cmd, initial_report_type, &selection))
 		return_0;
 
 	sh->report_type = initial_report_type;


