From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 14:21:49 +0000 (UTC)
Subject: master - conf: add more comments for new settings related to output format and log report
Message-ID: <20160620142149.7710C6096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1d3820219f6b0906bc0b3980b6eefcc187999d9
Commit:        d1d3820219f6b0906bc0b3980b6eefcc187999d9
Parent:        99ea03571a835c3a56b364be4ccebcc745d09dbe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 16:21:38 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 16:21:38 2016 +0200

conf: add more comments for new settings related to output format and log report

---
 conf/example.conf.in         |   49 +++++++++++++++++++++++++++++++---------
 lib/config/config_settings.h |   51 ++++++++++++++++++++++++++++++++----------
 2 files changed, 77 insertions(+), 23 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index bf8f177..f7cebf9 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -479,30 +479,51 @@ allocation {
 log {
 
 	# Configuration option log/report_command_log.
-	# If enabled, LVM will collect log during command processing.
-	# After that the log is reported using current output format
-	# as defined by report/output_format setting.
+	# Enable or disable LVM log reporting.
+	# If enabled, LVM will collect a log of operations, messages,
+	# per-object return codes with object identification and associated
+	# error numbers (errnos) during LVM command processing. Then the
+	# log is either reported solely or in addition to any existing
+	# reports, depending on LVM command used. If it is a reporting command
+	# (e.g. pvs, vgs, lvs, lvm fullreport), then the log is reported in
+	# addition to any existing reports. Otherwise, there's only log report
+	# on output. For all applicable LVM commands, you can request that
+	# the output has only log report by using --logonly command line
+	# option. Use log/command_log_cols and log/command_log_sort settings
+	# to define fields to display and sort fields for the log report.
+	# You can also use log/command_log_selection to define selection
+	# criteria used each time the log is reported.
 	# This configuration option has an automatic default value.
 	# report_command_log = 0
 
 	# Configuration option log/command_log_sort.
 	# List of columns to sort by when reporting command log.
-	# Possible fields are: log_seq_num, log_type, log_context, log_object_type,
-	# log_object_name, log_object_id, log_object_group, log_object_group_id,
-	# log_message, log_errno, log_ret_code.
+	# See <lvm command> --logonly --configreport log -o help
+	# for the list of possible fields.
 	# This configuration option has an automatic default value.
 	# command_log_sort = "log_seq_num"
 
 	# Configuration option log/command_log_cols.
 	# List of columns to report when reporting command log.
-	# Possible fields are: log_seq_num, log_type, log_context, log_object_type,
-	# log_object_name, log_object_id, log_object_group, log_object_group_id,
-	# log_message, log_errno, log_ret_code.
+	# See <lvm command> --logonly --configreport log -o help
+	# for the list of possible fields.
 	# This configuration option has an automatic default value.
 	# command_log_cols = "log_seq_num,log_type,log_context,log_object_type,log_object_name,log_object_id,log_object_group,log_object_group_id,log_message,log_errno,log_ret_code"
 
 	# Configuration option log/command_log_selection.
 	# Selection criteria used when reporting command log.
+	# You can define selection criteria that are applied each
+	# time log is reported. This way, it is possible to control the
+	# amount of log that is displayed on output and you can select
+	# only parts of the log that are important for you. To define
+	# selection criteria, use fields from log report. See also
+	# <lvm command> --logonly --configreport log -S help for the
+	# list of possible fields and selection operators. You can also
+	# define selection criteria for log report on command line directly
+	# using <lvm command> --configreport log -S <selection criteria>
+	# which has precedence over log/command_log_selection setting.
+	# For more information about selection criteria in general, see
+	# lvm(8) man page.
 	# This configuration option has an automatic default value.
 	# command_log_selection = "!(log_type=status && message=success)"
 
@@ -1580,10 +1601,16 @@ activation {
 # report {
 
 	# Configuration option report/output_format.
-	# Format of LVM2 command report output.
+	# Format of LVM command's report output.
+	# If there is more than one report per command, then the format
+	# is applied for all reports. You can also change output format
+	# directly on command line using --reportformat option which
+	# has precedence over log/output_format setting.
 	# Accepted values:
 	#   basic
-	#     Original format with columns and rows.
+	#     Original format with columns and rows. If there is more than
+	#     one report per command, each report is prefixed with report's
+	#     name for identification.
 	#   json
 	#     JSON format.
 	# This configuration option has an automatic default value.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 64859e4..25914ea 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -548,24 +548,45 @@ cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_
 	"Default physical extent size in KiB to use for new VGs.\n")
 
 cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
-	"If enabled, LVM will collect log during command processing.\n"
-	"After that the log is reported using current output format\n"
-	"as defined by report/output_format setting.\n")
+	"Enable or disable LVM log reporting.\n"
+	"If enabled, LVM will collect a log of operations, messages,\n"
+	"per-object return codes with object identification and associated\n"
+	"error numbers (errnos) during LVM command processing. Then the\n"
+	"log is either reported solely or in addition to any existing\n"
+	"reports, depending on LVM command used. If it is a reporting command\n"
+	"(e.g. pvs, vgs, lvs, lvm fullreport), then the log is reported in\n"
+	"addition to any existing reports. Otherwise, there's only log report\n"
+	"on output. For all applicable LVM commands, you can request that\n"
+	"the output has only log report by using --logonly command line\n"
+	"option. Use log/command_log_cols and log/command_log_sort settings\n"
+	"to define fields to display and sort fields for the log report.\n"
+	"You can also use log/command_log_selection to define selection\n"
+	"criteria used each time the log is reported.\n")
 
 cfg(log_command_log_sort_CFG, "command_log_sort", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"List of columns to sort by when reporting command log.\n"
-	"Possible fields are: log_seq_num, log_type, log_context, log_object_type,\n"
-	"log_object_name, log_object_id, log_object_group, log_object_group_id,\n"
-	"log_message, log_errno, log_ret_code.\n")
+	"See <lvm command> --logonly --configreport log -o help\n"
+	"for the list of possible fields.\n")
 
 cfg(log_command_log_cols_CFG, "command_log_cols", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_COLS, vsn(2, 2, 158), NULL, 0, NULL,
 	"List of columns to report when reporting command log.\n"
-	"Possible fields are: log_seq_num, log_type, log_context, log_object_type,\n"
-	"log_object_name, log_object_id, log_object_group, log_object_group_id,\n"
-	"log_message, log_errno, log_ret_code.\n")
+	"See <lvm command> --logonly --configreport log -o help\n"
+	"for the list of possible fields.\n")
 
 cfg(log_command_log_selection_CFG, "command_log_selection", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SELECTION, vsn(2, 2, 158), NULL, 0, NULL,
-	"Selection criteria used when reporting command log.\n")
+	"Selection criteria used when reporting command log.\n"
+	"You can define selection criteria that are applied each\n"
+	"time log is reported. This way, it is possible to control the\n"
+	"amount of log that is displayed on output and you can select\n"
+	"only parts of the log that are important for you. To define\n"
+	"selection criteria, use fields from log report. See also\n"
+	"<lvm command> --logonly --configreport log -S help for the\n"
+	"list of possible fields and selection operators. You can also\n"
+	"define selection criteria for log report on command line directly\n"
+	"using <lvm command> --configreport log -S <selection criteria>\n"
+	"which has precedence over log/command_log_selection setting.\n"
+	"For more information about selection criteria in general, see\n"
+	"lvm(8) man page.\n")
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
@@ -1483,10 +1504,16 @@ cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg(report_output_format_CFG, "output_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_OUTPUT_FORMAT, vsn(2, 2, 158), NULL, 0, NULL,
-	"Format of LVM2 command report output.\n"
+	"Format of LVM command's report output.\n"
+	"If there is more than one report per command, then the format\n"
+	"is applied for all reports. You can also change output format\n"
+	"directly on command line using --reportformat option which\n"
+	"has precedence over log/output_format setting.\n"
 	"Accepted values:\n"
 	"  basic\n"
-	"    Original format with columns and rows.\n"
+	"    Original format with columns and rows. If there is more than\n"
+	"    one report per command, each report is prefixed with report's\n"
+	"    name for identification.\n"
 	"  json\n"
 	"    JSON format.\n")
 


