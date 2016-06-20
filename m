From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:25 +0000 (UTC)
Subject: master - conf: add report/output_format config setting
Message-ID: <20160620094025.657A76031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a08e02afbf6c72854d1996c03348a104cbbdaadb
Commit:        a08e02afbf6c72854d1996c03348a104cbbdaadb
Parent:        79a74e9aaecee0b02cfd83f544a99870f29e0016
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 24 12:05:42 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

conf: add report/output_format config setting

New report/output_format configuration sets the output format used
for all LVM commands globally. Currently, there are 2 formats
recognized:
   - basic (the classical basic output with columns and rows, used by default)
   - json (output is in json format)
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   10 ++++++++++
 lib/config/config_settings.h |    8 ++++++++
 lib/config/defaults.h        |    1 +
 tools/reporter.c             |    4 +++-
 5 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 90ae561..23f947f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add log/report_output_format to lvm.conf for default report output format.
   Recognize --reportformat {basic|json} option to select report output format.
   Add log/command_log_{sort,cols} to lvm.conf to configure command log report.
   Add log_object_{type,name,id,group,group_id} fields to cmd log.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index f5b4c4a..8423442 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1567,6 +1567,16 @@ activation {
 # This configuration section has an automatic default value.
 # report {
 
+	# Configuration option report/output_format.
+	# Format of LVM2 command report output.
+	# Accepted values:
+	#   basic
+	#     Original format with columns and rows.
+	#   json
+	#     JSON format.
+	# This configuration option has an automatic default value.
+	# output_format = "basic"
+
 	# Configuration option report/compact_output.
 	# Do not print empty values for all report fields.
 	# If enabled, all fields that don't have a value set for any of the
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 014f9b1..8332c3f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1474,6 +1474,14 @@ cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UN
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
+cfg(report_output_format_CFG, "output_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_OUTPUT_FORMAT, vsn(2, 2, 158), NULL, 0, NULL,
+	"Format of LVM2 command report output.\n"
+	"Accepted values:\n"
+	"  basic\n"
+	"    Original format with columns and rows.\n"
+	"  json\n"
+	"    JSON format.\n")
+
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty values for all report fields.\n"
 	"If enabled, all fields that don't have a value set for any of the\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 82e3716..abb2525 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -207,6 +207,7 @@
 #define DEFAULT_REP_LIST_ITEM_SEPARATOR ","
 #define DEFAULT_TIME_FORMAT "%Y-%m-%d %T %z"
 
+#define DEFAULT_REP_OUTPUT_FORMAT "basic"
 #define DEFAULT_COMPACT_OUTPUT_COLS ""
 
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
diff --git a/tools/reporter.c b/tools/reporter.c
index fa66064..6bf00c0 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1070,7 +1070,9 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 		       struct dm_report_group **report_group, struct dm_report **log_rh)
 {
 	static char log_report_name[] = "log";
-	const char *format_str = arg_str_value(cmd, reportformat_ARG, NULL);
+	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
+	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
+	const char *format_str = arg_str_value(cmd, reportformat_ARG, config_set ? config_format_str : NULL);
 	struct report_args args = {0};
 	struct dm_report_group *new_report_group;
 	struct dm_report *tmp_log_rh = NULL;


