From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:34 +0000 (UTC)
Subject: master - report: use report type description for report's name if using DM_REPORT_GROUP_BASIC output format
Message-ID: <20160620094134.B70EA60DFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e8e8ddb4619bbc16e28ba0d84d43868271516e5
Commit:        3e8e8ddb4619bbc16e28ba0d84d43868271516e5
Parent:        5b93db65660c5dbb5b68d458ffa4c034a4c37211
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 16:44:52 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

report: use report type description for report's name if using DM_REPORT_GROUP_BASIC output format

---
 lib/report/report.c |   14 ++++++++++----
 lib/report/report.h |    4 +++-
 tools/reporter.c    |   20 +++++++++++++-------
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 3b9693d..512986e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3769,7 +3769,9 @@ void *report_init_for_selection(struct cmd_context *cmd,
 					     cmd);
 }
 
-const char *report_get_field_prefix(report_type_t report_type_id)
+int report_get_prefix_and_desc(report_type_t report_type_id,
+			       const char **report_prefix,
+			       const char **report_desc)
 {
 	const struct dm_report_object_type *report_types, *report_type;
 
@@ -3781,11 +3783,15 @@ const char *report_get_field_prefix(report_type_t report_type_id)
 		report_types = _report_types;
 
 	for (report_type = report_types; report_type->id; report_type++) {
-		if (report_type_id & report_type->id)
-			return report_type->prefix;
+		if (report_type_id & report_type->id) {
+			*report_prefix = report_type->prefix;
+			*report_desc = report_type->desc;
+			return 1;
+		}
 	}
 
-	return "";
+	*report_prefix = *report_desc = "";
+	return 0;
 }
 
 /*
diff --git a/lib/report/report.h b/lib/report/report.h
index e6fbc8d..9d9d01f 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -93,7 +93,9 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 int report_get_single_selection(struct cmd_context *cmd, const char **selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
-const char *report_get_field_prefix(report_type_t report_type);
+int report_get_prefix_and_desc(report_type_t report_type_id,
+			       const char **report_prefix,
+			       const char **report_desc);
 int report_for_selection(struct cmd_context *cmd,
 			 struct processing_handle *parent_handle,
 			 struct physical_volume *pv,
diff --git a/tools/reporter.c b/tools/reporter.c
index 8564133..f65676e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -985,9 +985,10 @@ int report_get_single_selection(struct cmd_context *cmd, const char **selection)
 	return _do_report_get_selection(cmd, NULL, NULL, expected_idxs, selection);
 }
 
-static int _set_report_prefix_and_name(struct single_report_args *single_args)
+static int _set_report_prefix_and_name(struct report_args *args,
+				       struct single_report_args *single_args)
 {
-	const char *report_prefix;
+	const char *report_prefix, *report_desc;
 	size_t len;
 
 	if (single_args->report_type == FULL) {
@@ -996,7 +997,8 @@ static int _set_report_prefix_and_name(struct single_report_args *single_args)
 		return 1;
 	}
 
-	report_prefix = report_get_field_prefix(single_args->report_type);
+	(void) report_get_prefix_and_desc(single_args->report_type,
+					  &report_prefix, &report_desc);
 	len = strlen(report_prefix);
 	if (report_prefix[len - 1] == '_')
 		len--;
@@ -1012,7 +1014,11 @@ static int _set_report_prefix_and_name(struct single_report_args *single_args)
 		return 0;
 	}
 	single_args->report_prefix[len] = '\0';
-	single_args->report_name = single_args->report_prefix;
+
+	if (args->report_group_type != DM_REPORT_GROUP_BASIC)
+		single_args->report_name = single_args->report_prefix;
+	else
+		single_args->report_name = report_desc;
 
 	return 1;
 }
@@ -1211,7 +1217,7 @@ out:
 		args->single_args[REPORT_IDX_FULL_ ## type].report_type = type; \
 		args->single_args[REPORT_IDX_FULL_ ## type].keys = find_config_tree_str(cmd, report_ ## name ## _sort_full_CFG, NULL); \
 		args->single_args[REPORT_IDX_FULL_ ## type].options = find_config_tree_str(cmd, report_ ## name ## _cols_full_CFG, NULL); \
-		if (!_set_report_prefix_and_name(&args->single_args[REPORT_IDX_FULL_ ## type])) \
+		if (!_set_report_prefix_and_name(args, &args->single_args[REPORT_IDX_FULL_ ## type])) \
 			return_0; \
 	} while (0)
 
@@ -1228,7 +1234,7 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 	/* Check PV specifics and do extra changes/actions if needed. */
 	_check_pv_list(cmd, args, single_args);
 
-	if (!_set_report_prefix_and_name(single_args))
+	if (!_set_report_prefix_and_name(args, single_args))
 		return_0;
 
 	switch (single_args->report_type) {
@@ -1472,7 +1478,7 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 			 * We reusing existing log report handle.
 			 * Just get report's name and prefix now.
 			 */
-			if (!_set_report_prefix_and_name(single_args))
+			if (!_set_report_prefix_and_name(&args, single_args))
 				goto_bad;
 		}
 


