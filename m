From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:36 +0000 (UTC)
Subject: master - report: add --logonly arg to report only log for a command
Message-ID: <20160620094136.D442360DFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92caebab95353e13b37fc724a6f31c23c8fd2cac
Commit:        92caebab95353e13b37fc724a6f31c23c8fd2cac
Parent:        3e8e8ddb4619bbc16e28ba0d84d43868271516e5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 15 13:35:27 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

report: add --logonly arg to report only log for a command

---
 WHATS_NEW           |    1 +
 lib/report/report.h |    2 +-
 tools/args.h        |    1 +
 tools/commands.h    |   52 +++++++++++++++++++++++++++++---------------------
 tools/reporter.c    |   28 +++++++++++++++++---------
 tools/toollib.c     |    3 +-
 tools/toollib.h     |    1 +
 7 files changed, 54 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8a4f7d5..86a53ce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add --logonly option to report only cmd log for a command, not other reports.
   Add log/command_log_selection to configure default selection used on cmd log.
   Use 'orphan' object type in cmd log for groups to collect PVs not yet in VGs.
   Add lvm lastlog command for query and display of last cmd's log in lvm shell.
diff --git a/lib/report/report.h b/lib/report/report.h
index 9d9d01f..b9028fe 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -83,7 +83,7 @@ typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 
 int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
 		       struct dm_report_group **report_group, struct dm_report **log_rh,
-		       log_report_t *saved_log_report_state);
+		       int *log_only, log_report_t *saved_log_report_state);
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
diff --git a/tools/args.h b/tools/args.h
index b7b2262..670d6a0 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -55,6 +55,7 @@ arg(lockopt_ARG, '\0', "lockopt", string_arg, 0, 0)
 arg(lockstart_ARG, '\0', "lockstart", NULL, 0, 0)
 arg(lockstop_ARG, '\0', "lockstop", NULL, 0, 0)
 arg(locktype_ARG, '\0', "locktype", locktype_arg, 0, 0)
+arg(logonly_ARG, '\0', "logonly", NULL, 0, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0, 0)
 arg(merge_ARG, '\0', "merge", NULL, 0, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0, 0)
diff --git a/tools/commands.h b/tools/commands.h
index d54a50c..4bebcd4 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -149,6 +149,7 @@ xx(fullreport,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -169,10 +170,10 @@ xx(fullreport,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
-   rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
+   reportformat_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG,
+   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lastlog,
    "Display last command's log report",
@@ -486,6 +487,7 @@ xx(lvdisplay,
    "\t[-H|--history]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
@@ -504,7 +506,7 @@ xx(lvdisplay,
 
     aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
     history_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-    maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG,
+    logonly_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG,
     partial_ARG, readonly_ARG, reportformat_ARG, segments_ARG, select_ARG,
     separator_ARG, shared_ARG, unbuffered_ARG, units_ARG)
 
@@ -730,6 +732,7 @@ xx(lvs,
    "\t[-H|--history]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -751,11 +754,11 @@ xx(lvs,
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG, history_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, reportformat_ARG, rows_ARG, segments_ARG, select_ARG,
-   separator_ARG, shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
-   units_ARG, unquoted_ARG)
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
+   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
+   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -918,6 +921,7 @@ xx(pvdisplay,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
@@ -933,7 +937,7 @@ xx(pvdisplay,
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG, maps_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG, reportformat_ARG,
    select_ARG, separator_ARG, shared_ARG, short_ARG, sort_ARG, unbuffered_ARG,
    units_ARG)
@@ -1014,6 +1018,7 @@ xx(pvs,
    "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -1035,10 +1040,11 @@ xx(pvs,
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
-   rows_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
+   reportformat_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
+   unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1265,6 +1271,7 @@ xx(vgdisplay,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
@@ -1282,9 +1289,9 @@ xx(vgdisplay,
 
    activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
    foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   reportformat_ARG, select_ARG, shared_ARG, short_ARG, separator_ARG,
-   sort_ARG, unbuffered_ARG, units_ARG)
+   logonly_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG, reportformat_ARG, select_ARG, shared_ARG, short_ARG,
+   separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1446,6 +1453,7 @@ xx(vgs,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
+   "\t[--logonly]\n"
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
@@ -1466,10 +1474,10 @@ xx(vgs,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
-   rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
+   reportformat_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG,
+   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/reporter.c b/tools/reporter.c
index f65676e..c7dee20 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -54,6 +54,7 @@ struct report_args {
 	int columns_as_rows;
 	const char *separator;
 	struct volume_group *full_report_vg;
+	int log_only;
 	struct single_report_args single_args[REPORT_IDX_COUNT];
 };
 
@@ -1047,7 +1048,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 				    &lv_segment_status_needed, &report_type))
 		goto_out;
 
-	if (handle->report_group) {
+	if (!(args->log_only && (single_args->report_type != CMDLOG))) {
 		if (!dm_report_group_push(handle->report_group, report_handle, (void *) single_args->report_name))
 			goto_out;
 		report_in_group = 1;
@@ -1160,7 +1161,8 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 			log_error("Failed to compact given columns in report output.");
 	}
 
-	dm_report_output(report_handle);
+	if (!(args->log_only && (single_args->report_type != CMDLOG)))
+		dm_report_output(report_handle);
 
 	if (lock_global)
 		unlock_vg(cmd, VG_GLOBAL);
@@ -1189,7 +1191,7 @@ static int _full_report_single(struct cmd_context *cmd,
 
 	args->full_report_vg = vg;
 
-	if (!dm_report_group_push(handle->report_group, NULL, NULL))
+	if (!args->log_only && !dm_report_group_push(handle->report_group, NULL, NULL))
 		goto out;
 
 	if (orphan) {
@@ -1205,7 +1207,7 @@ static int _full_report_single(struct cmd_context *cmd,
 			stack;
 	}
 
-	if (!dm_report_group_pop(handle->report_group))
+	if (!args->log_only && !dm_report_group_pop(handle->report_group))
 		goto_out;
 out:
 	args->full_report_vg = NULL;
@@ -1360,13 +1362,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 
 	args.report_group_type = handle->report_group_type;
+	args.log_only = handle->log_only;
 
 	if (!_config_report(cmd, &args, single_args)) {
 		destroy_processing_handle(cmd, handle);
 		return_ECMD_FAILED;
 	}
 
-	if (!dm_report_group_push(handle->report_group, NULL, report_name)) {
+	if (!args.log_only && !dm_report_group_push(handle->report_group, NULL, report_name)) {
 		log_error("Failed to add main report section to report group.");
 		destroy_processing_handle(cmd, handle);
 		return ECMD_FAILED;
@@ -1426,20 +1429,23 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 
 int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
 		       struct dm_report_group **report_group, struct dm_report **log_rh,
-		       log_report_t *saved_log_report_state)
+		       int *log_only, log_report_t *saved_log_report_state)
 {
 	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
 	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
 	const char *format_str = arg_str_value(cmd, reportformat_ARG, config_set ? config_format_str : NULL);
-	int report_command_log = find_config_tree_bool(cmd, log_report_command_log_CFG, NULL);
+	int report_command_log;
 	struct report_args args = {0};
 	struct single_report_args *single_args;
 	struct dm_report_group *new_report_group;
 	struct dm_report *tmp_log_rh = NULL;
 
+	args.log_only = arg_is_set(cmd, logonly_ARG) || *log_rh;
+	report_command_log = args.log_only || find_config_tree_bool(cmd, log_report_command_log_CFG, NULL);
+
 	if (!format_str || !strcmp(format_str, REPORT_FORMAT_NAME_BASIC)) {
-		args.report_group_type = report_command_log ? DM_REPORT_GROUP_BASIC
-							    : DM_REPORT_GROUP_SINGLE;
+		args.report_group_type = (report_command_log && !args.log_only) ? DM_REPORT_GROUP_BASIC
+										: DM_REPORT_GROUP_SINGLE;
 	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_JSON)) {
 		args.report_group_type = DM_REPORT_GROUP_JSON;
 	} else {
@@ -1452,6 +1458,8 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 
 	if (report_group_type)
 		*report_group_type = args.report_group_type;
+	if (log_only)
+		*log_only = args.log_only;
 
 	if (!(new_report_group = dm_report_group_create(args.report_group_type, NULL))) {
 		log_error("Failed to create report group.");
@@ -1517,7 +1525,7 @@ int lastlog(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL))
+	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL, NULL))
 		goto_out;
 
 	if (arg_count(cmd, select_ARG) &&
diff --git a/tools/toollib.c b/tools/toollib.c
index 0eb2887..fe9f9c0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1733,7 +1733,8 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct
 
 	if (!parent_handle) {
 		if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
-					&handle->log_rh, &handle->saved_log_report_state)) {
+					&handle->log_rh, &handle->log_only,
+					&handle->saved_log_report_state)) {
 			dm_pool_free(cmd->mem, handle);
 			return NULL;
 		}
diff --git a/tools/toollib.h b/tools/toollib.h
index 1144793..42e7f7a 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -76,6 +76,7 @@ struct processing_handle {
 	dm_report_group_type_t report_group_type;
 	struct dm_report_group *report_group;
 	struct dm_report *log_rh;
+	int log_only;
 	log_report_t saved_log_report_state;
 	void *custom_handle;
 };


