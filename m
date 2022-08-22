From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Mon, 22 Aug 2022 12:07:09 +0000 (GMT)
Subject: main - shell: add pre-cmd log report object type and enable lastlog for it
Message-ID: <20220822120709.D42DC3858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=508782a9135acf13b39b47605e675a5678495c58
Commit:        508782a9135acf13b39b47605e675a5678495c58
Parent:        8c3cfc75c72696ae8b620555fcc4f815b0c1d6b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 22 13:59:08 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 22 14:06:34 2022 +0200

shell: add pre-cmd log report object type and enable lastlog for it

If we failed or logged anything before we actually execute given command
in lvm shell, we couldn't report the log using lastlog command after.
This patch adds specific 'pre-cmd' log report object type to identify
such log messages and enables lastlog to report even this log.
---
 WHATS_NEW             |  1 +
 lib/log/log.c         |  1 +
 lib/log/lvm-logging.h |  1 +
 tools/lvm.c           | 11 +++++++----
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fac295336..90dd417b1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Fix lvm shell's lastlog command to report previous pre-command failures.
   Extend VDO and VDOPOOL without flushing and locking fs.
   Add --valuesonly option to lvmconfig to print only values without keys.
   Updates configure with recent autoconf tooling.
diff --git a/lib/log/log.c b/lib/log/log.c
index 5771a1d01..118a3ba42 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -446,6 +446,7 @@ const char *log_get_report_context_name(log_report_context_t context)
 const char *log_get_report_object_type_name(log_report_object_type_t object_type)
 {
 	static const char *log_object_type_names[LOG_REPORT_OBJECT_TYPE_COUNT] = {[LOG_REPORT_OBJECT_TYPE_NULL] = "",
+										  [LOG_REPORT_OBJECT_TYPE_PRE_CMD] = "pre-cmd",
 										  [LOG_REPORT_OBJECT_TYPE_CMD] = "cmd",
 										  [LOG_REPORT_OBJECT_TYPE_ORPHAN] = "orphan",
 										  [LOG_REPORT_OBJECT_TYPE_PV] = "pv",
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 5b975a6b8..f5a4277a8 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -91,6 +91,7 @@ typedef enum {
 
 typedef enum {
 	LOG_REPORT_OBJECT_TYPE_NULL,
+	LOG_REPORT_OBJECT_TYPE_PRE_CMD,
 	LOG_REPORT_OBJECT_TYPE_CMD,
 	LOG_REPORT_OBJECT_TYPE_ORPHAN,
 	LOG_REPORT_OBJECT_TYPE_PV,
diff --git a/tools/lvm.c b/tools/lvm.c
index 756328f3f..370dc49e3 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -231,7 +231,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 	orig_command_log_selection = dm_pool_strdup(cmd->libmem, find_config_tree_str(cmd, log_command_log_selection_CFG, NULL));
 	log_set_report_context(LOG_REPORT_CONTEXT_SHELL);
-	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PRE_CMD);
 
 	while (1) {
 		/*
@@ -255,6 +255,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 				log_error("Failed to reset log report selection.");
 		}
 
+		log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PRE_CMD);
 		log_set_report(cmd->cmd_report.log_rh);
 		log_set_report_object_name_and_id(NULL, NULL);
 
@@ -275,6 +276,8 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			continue;
 		}
 
+		log_set_report_object_name_and_id(input, NULL);
+
 		add_history(input);
 
 		for (i = 0; i < MAX_ARGS; i++)
@@ -285,8 +288,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
 			_discard_log_report_content(cmd);
 			log_error("Too many arguments, sorry.");
-			dm_report_group_output_and_pop_all(cmd->cmd_report.report_group);
-			continue;
+			goto report_log;
 		}
 
 		if (!argc) {
@@ -304,6 +306,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			continue;
 		}
 
+		log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
 		log_set_report_object_name_and_id(argv[0], NULL);
 
 		is_lastlog_cmd = !strcmp(argv[0], "lastlog");
@@ -331,7 +334,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		if (!is_lastlog_cmd)
 			_log_shell_command_status(cmd, ret);
-
+report_log:
 		log_set_report(NULL);
 		dm_report_group_output_and_pop_all(cmd->cmd_report.report_group);
 

