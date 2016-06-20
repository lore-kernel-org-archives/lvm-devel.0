From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:27 +0000 (UTC)
Subject: master - conf: add log/report_command_log config setting
Message-ID: <20160620094027.83B6D6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd0a0ae36b89c3a4ea9f84bfa519e363bc7e407c
Commit:        bd0a0ae36b89c3a4ea9f84bfa519e363bc7e407c
Parent:        a08e02afbf6c72854d1996c03348a104cbbdaadb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 11:58:01 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

conf: add log/report_command_log config setting

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    7 +++++++
 lib/config/config_settings.h |    7 ++++++-
 lib/config/defaults.h        |    1 +
 tools/reporter.c             |   33 ++++++++++++++++++++-------------
 5 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 23f947f..ebddfd0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add log/report_command_log to lvm.conf to enable or disable cmd log report.
   Add log/report_output_format to lvm.conf for default report output format.
   Recognize --reportformat {basic|json} option to select report output format.
   Add log/command_log_{sort,cols} to lvm.conf to configure command log report.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 8423442..69bb668 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -478,6 +478,13 @@ allocation {
 # How LVM log information is reported.
 log {
 
+	# Configuration option log/report_command_log.
+	# If enabled, LVM will collect log during command processing.
+	# After that the log is reported using current output format
+	# as defined by report/output_format setting.
+	# This configuration option has an automatic default value.
+	# report_command_log = 0
+
 	# Configuration option log/command_log_sort.
 	# List of columns to sort by when reporting command log.
 	# Possible fields are: log_seq_num, log_type, log_context, log_object_type,
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8332c3f..09c9ab5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -124,7 +124,7 @@ cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), 0
 cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), 0, NULL,
 	"How LVM selects space and applies properties to LVs.\n")
 
-cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
+cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL,
 	"How LVM log information is reported.\n")
 
 cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
@@ -547,6 +547,11 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
+cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
+	"If enabled, LVM will collect log during command processing.\n"
+	"After that the log is reported using current output format\n"
+	"as defined by report/output_format setting.\n")
+
 cfg(log_command_log_sort_CFG, "command_log_sort", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"List of columns to sort by when reporting command log.\n"
 	"Possible fields are: log_seq_num, log_type, log_context, log_object_type,\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index abb2525..ae8134f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -160,6 +160,7 @@
 #  define DEFAULT_LOG_FACILITY LOG_USER
 #endif
 
+#define DEFAULT_COMMAND_LOG_REPORT 0
 #define DEFAULT_SYSLOG 1
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_SILENT 0
diff --git a/tools/reporter.c b/tools/reporter.c
index 6bf00c0..a4595f7 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1073,14 +1073,14 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
 	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
 	const char *format_str = arg_str_value(cmd, reportformat_ARG, config_set ? config_format_str : NULL);
+	int report_command_log = find_config_tree_bool(cmd, log_report_command_log_CFG, NULL);
 	struct report_args args = {0};
 	struct dm_report_group *new_report_group;
 	struct dm_report *tmp_log_rh = NULL;
 
-	if (!format_str) {
-		args.report_group_type = DM_REPORT_GROUP_SINGLE;
-	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_BASIC)) {
-		args.report_group_type = DM_REPORT_GROUP_BASIC;
+	if (!format_str || !strcmp(format_str, REPORT_FORMAT_NAME_BASIC)) {
+		args.report_group_type = report_command_log ? DM_REPORT_GROUP_BASIC
+							    : DM_REPORT_GROUP_SINGLE;
 	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_JSON)) {
 		args.report_group_type = DM_REPORT_GROUP_JSON;
 	} else {
@@ -1099,16 +1099,23 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 		return 0;
 	}
 
-	if (!*log_rh) {
-		args.report_type = CMDLOG;
-		if (!_config_report(cmd, &args))
-			goto_bad;
+	if (report_command_log) {
+		if (!*log_rh) {
+			args.report_type = CMDLOG;
+			if (!_config_report(cmd, &args))
+				goto_bad;
+
+			if (!(tmp_log_rh = report_init(NULL, args.options, args.keys, &args.report_type,
+							  args.separator, args.aligned, args.buffered, args.headings,
+							  args.field_prefixes, args.quoted, args.columns_as_rows,
+							  args.selection))) {
+				log_error("Failed to create log report.");
+				goto bad;
+			}
+		}
 
-		if (!(tmp_log_rh = report_init(NULL, args.options, args.keys, &args.report_type,
-						  args.separator, args.aligned, args.buffered, args.headings,
-						  args.field_prefixes, args.quoted, args.columns_as_rows,
-						  args.selection))) {
-			log_error("Failed to create log report.");
+		if (!(dm_report_group_push(new_report_group, *log_rh ? : tmp_log_rh, log_report_name))) {
+			log_error("Failed to add log report to report group.");
 			goto bad;
 		}
 	}


