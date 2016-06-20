From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:56 +0000 (UTC)
Subject: master - report: recognize selection (-S|--select) for each subreport; make -S|--select groupable
Message-ID: <20160620094056.D46E060FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b864a062217cf31d86343f37ecbefeeeb15610cf
Commit:        b864a062217cf31d86343f37ecbefeeeb15610cf
Parent:        e081203f3e2ee5e3270c7f5f2753ed446d8b72cb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 26 15:20:27 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: recognize selection (-S|--select) for each subreport; make -S|--select groupable

---
 WHATS_NEW           |    1 +
 lib/report/report.h |    1 +
 tools/args.h        |    2 +-
 tools/reporter.c    |   54 ++++++++++++++++++++++++++++++++++++++++++++++----
 tools/toollib.c     |    7 ++++-
 5 files changed, 57 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fb5d3e7..01d6bbc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Make -S|--select option groupable that allows this option to be repeated.
   Make -O|--sort option groupable that allows this option to be repeated.
   Add --configreport option to select report for which next options are applied.
   Add support for priorities on grouping command arguments.
diff --git a/lib/report/report.h b/lib/report/report.h
index 20ccd99..f5df51e 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -88,6 +88,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
 		  int quoted, int columns_as_rows, const char *selection);
+int report_get_single_selection(struct cmd_context *cmd, const char **selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
 const char *report_get_field_prefix(report_type_t report_type);
diff --git a/tools/args.h b/tools/args.h
index 985f5d1..b7b2262 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -206,7 +206,7 @@ arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0, 0)
 arg(snapshot_ARG, 's', "snapshot", NULL, 0, 0)
 arg(short_ARG, 's', "short", NULL, 0, 0)
 arg(stdin_ARG, 's', "stdin", NULL, 0, 0)
-arg(select_ARG, 'S', "select", string_arg, 0, 0)
+arg(select_ARG, 'S', "select", string_arg, ARG_GROUPABLE, 0)
 arg(test_ARG, 't', "test", NULL, 0, 0)
 arg(thin_ARG, 'T', "thin", NULL, 0, 0)
 arg(uuid_ARG, 'u', "uuid", NULL, 0, 0)
diff --git a/tools/reporter.c b/tools/reporter.c
index 8165288..9dd302a 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -915,16 +915,60 @@ out:
 	return r;
 }
 
+static int _do_report_get_selection(struct cmd_context *cmd,
+				    struct report_args *args,
+				    struct single_report_args *single_args,
+				    report_idx_t expected_idxs[],
+				    const char **ret_selection)
+{
+	struct arg_value_group_list *current_group;
+	const char *final_selection = "", *selection = NULL;
+	const char *report_name = NULL;
+	report_idx_t idx = REPORT_IDX_SINGLE;
+	int i;
+
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, select_ARG))
+			continue;
+
+		if (grouped_arg_is_set(current_group->arg_values, configreport_ARG)) {
+			report_name = grouped_arg_str_value(current_group->arg_values, configreport_ARG, NULL);
+			if ((idx = _get_report_idx_from_name(single_args->report_type, report_name)) == REPORT_IDX_NULL)
+				return_0;
+		}
+
+		selection = grouped_arg_str_value(current_group->arg_values, select_ARG, NULL);
+
+		if (single_args) {
+			if (!_should_process_report_idx(single_args->report_type, idx))
+				continue;
+			args->single_args[idx].selection = selection;
+			final_selection = selection;
+		} else {
+			for (i = 0; expected_idxs[i] != REPORT_IDX_NULL; i++) {
+				if (idx == expected_idxs[i])
+					final_selection = selection;
+			}
+		}
+	}
+
+	if (ret_selection)
+		*ret_selection = final_selection;
+
+	return 1;
+}
+
 static int _get_report_selection(struct cmd_context *cmd,
 				 struct report_args *args,
 				 struct single_report_args *single_args)
 {
-	int r = ECMD_PROCESSED;
-
-	if (arg_count(cmd, select_ARG))
-		single_args->selection = arg_str_value(cmd, select_ARG, NULL);
+	return _do_report_get_selection(cmd, args, single_args, NULL, NULL) ? ECMD_PROCESSED : ECMD_FAILED;
+}
 
-	return r;
+int report_get_single_selection(struct cmd_context *cmd, const char **selection)
+{
+	report_idx_t expected_idxs[] = {REPORT_IDX_SINGLE, REPORT_IDX_NULL};
+	return _do_report_get_selection(cmd, NULL, NULL, expected_idxs, selection);
 }
 
 static int _set_report_prefix_and_name(struct single_report_args *single_args)
diff --git a/tools/toollib.c b/tools/toollib.c
index 3b2ad6a..e67e47a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1742,15 +1742,18 @@ int init_selection_handle(struct cmd_context *cmd, struct processing_handle *han
 			  report_type_t initial_report_type)
 {
 	struct selection_handle *sh;
+	const char *selection;
 
 	if (!(sh = dm_pool_zalloc(cmd->mem, sizeof(struct selection_handle)))) {
 		log_error("_init_selection_handle: failed to allocate memory for selection handle");
 		return 0;
 	}
 
+	if (!report_get_single_selection(cmd, &selection))
+		return_0;
+
 	sh->report_type = initial_report_type;
-	if (!(sh->selection_rh = report_init_for_selection(cmd, &sh->report_type,
-					arg_str_value(cmd, select_ARG, NULL)))) {
+	if (!(sh->selection_rh = report_init_for_selection(cmd, &sh->report_type, selection))) {
 		dm_pool_free(cmd->mem, sh);
 		return_0;
 	}


