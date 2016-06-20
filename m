From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:21 +0000 (UTC)
Subject: master - conf: add log/command_log_{sort, cols} config settings
Message-ID: <20160620094021.2EFE26031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c36d4632a697f6e8f68a214a7c7db9f6fb25c09c
Commit:        c36d4632a697f6e8f68a214a7c7db9f6fb25c09c
Parent:        99c2a2b960d24d4826e3e66b4879de4bad13fbab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 13:10:29 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:40 2016 +0200

conf: add log/command_log_{sort,cols} config settings

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   16 ++++++++++++++++
 lib/config/config_settings.h |   12 ++++++++++++
 tools/reporter.c             |    4 ++--
 4 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c360cb..1e80d82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add log/command_log_{sort,cols} to lvm.conf to configure command log report.
   Add log_object_{type,name,id,group,group_id} fields to cmd log.
   Add log_{seq_num,type,context,message,errno,ret_code} fields to cmd log.
   Add CMDLOG report type - a separate report type for command logging.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index c34481e..f5b4c4a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -478,6 +478,22 @@ allocation {
 # How LVM log information is reported.
 log {
 
+	# Configuration option log/command_log_sort.
+	# List of columns to sort by when reporting command log.
+	# Possible fields are: log_seq_num, log_type, log_context, log_object_type,
+	# log_object_name, log_object_id, log_object_group, log_object_group_id,
+	# log_message, log_errno, log_ret_code.
+	# This configuration option has an automatic default value.
+	# command_log_sort = "log_seq_num"
+
+	# Configuration option log/command_log_cols.
+	# List of columns to report when reporting command log.
+	# Possible fields are: log_seq_num, log_type, log_context, log_object_type,
+	# log_object_name, log_object_id, log_object_group, log_object_group_id,
+	# log_message, log_errno, log_ret_code.
+	# This configuration option has an automatic default value.
+	# command_log_cols = "log_seq_num,log_type,log_context,log_object_type,log_object_name,log_object_id,log_object_group,log_object_group_id,log_message,log_errno,log_ret_code"
+
 	# Configuration option log/verbose.
 	# Controls the messages sent to stdout or stderr.
 	verbose = 0
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 0955d0a..014f9b1 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -547,6 +547,18 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
+cfg(log_command_log_sort_CFG, "command_log_sort", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_SORT, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting command log.\n"
+	"Possible fields are: log_seq_num, log_type, log_context, log_object_type,\n"
+	"log_object_name, log_object_id, log_object_group, log_object_group_id,\n"
+	"log_message, log_errno, log_ret_code.\n")
+
+cfg(log_command_log_cols_CFG, "command_log_cols", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMMAND_LOG_COLS, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report when reporting command log.\n"
+	"Possible fields are: log_seq_num, log_type, log_context, log_object_type,\n"
+	"log_object_name, log_object_id, log_object_group, log_object_group_id,\n"
+	"log_message, log_errno, log_ret_code.\n")
+
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 6ba1b5b..4714ae1 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -963,8 +963,8 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args)
 				args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
 		case CMDLOG:
-			args->keys = DEFAULT_COMMAND_LOG_SORT;
-			args->options = DEFAULT_COMMAND_LOG_COLS;
+			args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);
+			args->options = find_config_tree_str(cmd, log_command_log_cols_CFG, NULL);
 			break;
 		default:
 			log_error(INTERNAL_ERROR "_report: unknown report type.");


