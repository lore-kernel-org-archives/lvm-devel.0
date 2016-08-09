From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:40:00 +0000 (UTC)
Subject: master - conf: mark selected settings with CFG_DISALLOW_INTERACTIVE flag
Message-ID: <20160809174000.8CDB16072F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29f7dc292295bc6cad92e888691cb949d83c0413
Commit:        29f7dc292295bc6cad92e888691cb949d83c0413
Parent:        e8985c71bc7c6e8316adf97f2397ac32ab67191b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 10:43:33 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

conf: mark selected settings with CFG_DISALLOW_INTERACTIVE flag

---
 lib/config/config_settings.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7d2cdd5..1084224 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -167,7 +167,7 @@ cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL, 0, NULL,
 	"Abort the LVM process if a configuration mismatch is found.\n")
 
-cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99), 0, NULL,
+cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, vsn(2, 2, 99), 0, NULL,
 	"Directory where LVM looks for configuration profiles.\n")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL, 0, NULL,
@@ -554,7 +554,7 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
-cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
+cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Enable or disable LVM log reporting.\n"
 	"If enabled, LVM will collect a log of operations, messages,\n"
 	"per-object return codes with object identification and associated\n"
@@ -570,17 +570,17 @@ cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFI
 	"You can also use log/command_log_selection to define selection\n"
 	"criteria used each time the log is reported.\n")
 
-cfg(log_command_log_sort_CFG, "command_log_sort", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SORT, vsn(2, 2, 158), NULL, 0, NULL,
+cfg(log_command_log_sort_CFG, "command_log_sort", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"List of columns to sort by when reporting command log.\n"
 	"See <lvm command> --logonly --configreport log -o help\n"
 	"for the list of possible fields.\n")
 
-cfg(log_command_log_cols_CFG, "command_log_cols", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_COLS, vsn(2, 2, 158), NULL, 0, NULL,
+cfg(log_command_log_cols_CFG, "command_log_cols", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_COLS, vsn(2, 2, 158), NULL, 0, NULL,
 	"List of columns to report when reporting command log.\n"
 	"See <lvm command> --logonly --configreport log -o help\n"
 	"for the list of possible fields.\n")
 
-cfg(log_command_log_selection_CFG, "command_log_selection", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SELECTION, vsn(2, 2, 158), NULL, 0, NULL,
+cfg(log_command_log_selection_CFG, "command_log_selection", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SELECTION, vsn(2, 2, 158), NULL, 0, NULL,
 	"Selection criteria used when reporting command log.\n"
 	"You can define selection criteria that are applied each\n"
 	"time log is reported. This way, it is possible to control the\n"
@@ -1510,7 +1510,7 @@ cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UN
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg(report_output_format_CFG, "output_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_OUTPUT_FORMAT, vsn(2, 2, 158), NULL, 0, NULL,
+cfg(report_output_format_CFG, "output_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, DEFAULT_REP_OUTPUT_FORMAT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Format of LVM command's report output.\n"
 	"If there is more than one report per command, then the format\n"
 	"is applied for all reports. You can also change output format\n"


