From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:36 +0000 (UTC)
Subject: master - report: support "-o #field_name1, field_name2, ..."
Message-ID: <20151030145236.918AB609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77c31d0c39c3ba9caf7a5a70282f1c5a6b0f48e2
Commit:        77c31d0c39c3ba9caf7a5a70282f1c5a6b0f48e2
Parent:        baf320455b06141eb472faa687e7fcdc838bdd8c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 22 15:37:27 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

report: support "-o #field_name1,field_name2,..."

---
 tools/reporter.c |   34 +++++++++++++++++++++++++++++-----
 1 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index f4f9b71..89024c2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -642,17 +642,21 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 
 static int _get_report_options(struct cmd_context *cmd,
 			       report_type_t report_type,
-			       const char **options)
+			       const char **options,
+			       const char **fields_to_compact)
 {
 	const char *prefix = report_get_field_prefix(report_type);
 	size_t prefix_len = strlen(prefix);
 	struct arg_value_group_list *current_group;
 	struct dm_list *final_opts_list;
+	struct dm_list *final_compact_list = NULL;
 	struct dm_list *opts_list = NULL;
+	int opts_list_destroy = 1;
 	struct dm_str_list *sl;
 	const char *opts;
 	int r = ECMD_PROCESSED;
 
+
 	if (!(final_opts_list = str_to_str_list(NULL, *options, ",", 1))) {
 		r = ECMD_FAILED;
 		goto_out;
@@ -673,6 +677,8 @@ static int _get_report_options(struct cmd_context *cmd,
 			case '+':
 				/* fall through */
 			case '-':
+				/* fall through */
+			case '#':
 				if (!(opts_list = str_to_str_list(NULL, opts + 1, ",", 1))) {
 					r = ECMD_FAILED;
 					goto_out;
@@ -683,8 +689,17 @@ static int _get_report_options(struct cmd_context *cmd,
 					dm_list_iterate_items(sl, opts_list)
 						_del_option_from_list(final_opts_list, prefix,
 								      prefix_len, sl->str);
+				} else if (*opts == '#') {
+					if (!final_compact_list) {
+						final_compact_list = opts_list;
+						opts_list_destroy = 0;
+					} else
+						dm_list_splice(final_compact_list, opts_list);
 				}
-				str_list_destroy(opts_list, 1);
+				if (opts_list_destroy)
+					str_list_destroy(opts_list, 1);
+				else
+					opts_list_destroy = 1;
 				opts_list = NULL;
 				break;
 			default:
@@ -700,9 +715,17 @@ static int _get_report_options(struct cmd_context *cmd,
 		r = ECMD_FAILED;
 		goto out;
 	}
+	if (final_compact_list &&
+	    !(*fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
+		dm_pool_free(cmd->mem, (char *) *options);
+		r = ECMD_FAILED;
+		goto out;
+	}
 out:
 	if (opts_list)
 		str_list_destroy(final_opts_list, 1);
+	if (final_compact_list)
+		str_list_destroy(final_compact_list, 1);
 	if (final_opts_list)
 		str_list_destroy(final_opts_list, 1);
 	return r;
@@ -720,7 +743,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	unsigned args_are_pvs;
 	int lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
-	const char *fields_to_compact;
+	const char *fields_to_compact = NULL;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
@@ -792,7 +815,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	/* If -o supplied use it, else use default for report_type */
 	if (arg_count(cmd, options_ARG) &&
-	    ((r = _get_report_options(cmd, report_type, &options) != ECMD_PROCESSED)))
+	    ((r = _get_report_options(cmd, report_type, &options, &fields_to_compact) != ECMD_PROCESSED)))
 		return r;
 
 	/* -O overrides default sort settings */
@@ -909,7 +932,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL)) {
 		if (!dm_report_compact_fields(report_handle))
 			log_error("Failed to compact report output.");
-	} else if ((fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL))) {
+	} else if (fields_to_compact ||
+		   (fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL))) {
 		if (!dm_report_compact_given_fields(report_handle, fields_to_compact))
 			log_error("Failed to compact given columns in report output.");
 	}


