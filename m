From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:30 +0000 (UTC)
Subject: master - conf: add log/command_log_selection config setting
Message-ID: <20160620094130.9741961013@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1127b090bd07065a6a5046881ba1692bd507b9da
Commit:        1127b090bd07065a6a5046881ba1692bd507b9da
Parent:        cee1aedf12310866157b2112071850a59e6386b1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 13:25:03 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

conf: add log/command_log_selection config setting

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    5 +++++
 lib/config/config_settings.h |    3 +++
 lib/config/defaults.h        |    2 ++
 tools/reporter.c             |    1 +
 5 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25494cb..8a4f7d5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add log/command_log_selection to configure default selection used on cmd log.
   Use 'orphan' object type in cmd log for groups to collect PVs not yet in VGs.
   Add lvm lastlog command for query and display of last cmd's log in lvm shell.
   Report per-object return codes via cmd log while processing multiple objects.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1918a3d..bf8f177 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -501,6 +501,11 @@ log {
 	# This configuration option has an automatic default value.
 	# command_log_cols = "log_seq_num,log_type,log_context,log_object_type,log_object_name,log_object_id,log_object_group,log_object_group_id,log_message,log_errno,log_ret_code"
 
+	# Configuration option log/command_log_selection.
+	# Selection criteria used when reporting command log.
+	# This configuration option has an automatic default value.
+	# command_log_selection = "!(log_type=status && message=success)"
+
 	# Configuration option log/verbose.
 	# Controls the messages sent to stdout or stderr.
 	verbose = 0
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 89e0771..64859e4 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -564,6 +564,9 @@ cfg(log_command_log_cols_CFG, "command_log_cols", log_CFG_SECTION, CFG_PROFILABL
 	"log_object_name, log_object_id, log_object_group, log_object_group_id,\n"
 	"log_message, log_errno, log_ret_code.\n")
 
+cfg(log_command_log_selection_CFG, "command_log_selection", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SELECTION, vsn(2, 2, 158), NULL, 0, NULL,
+	"Selection criteria used when reporting command log.\n")
+
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6c7769a..3d449ff 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -211,6 +211,8 @@
 #define DEFAULT_REP_OUTPUT_FORMAT "basic"
 #define DEFAULT_COMPACT_OUTPUT_COLS ""
 
+#define DEFAULT_COMMAND_LOG_SELECTION "!(log_type=status && message=success)"
+
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
diff --git a/tools/reporter.c b/tools/reporter.c
index c732d0e..8564133 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1285,6 +1285,7 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 		case CMDLOG:
 			single_args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);
 			single_args->options = find_config_tree_str(cmd, log_command_log_cols_CFG, NULL);
+			single_args->selection = find_config_tree_str(cmd, log_command_log_selection_CFG, NULL);
 			break;
 		default:
 			log_error(INTERNAL_ERROR "_report: unknown report type.");


