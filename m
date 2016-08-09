From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:52 +0000 (UTC)
Subject: master - lvm: shell: honor log/command_log_selection as default and reset to this value after lastlog
Message-ID: <20160809173952.1D4B1607C6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7111d4874822e900cc3216df3fb81d7fa5af359c
Commit:        7111d4874822e900cc3216df3fb81d7fa5af359c
Parent:        e805ef2d66bc8a06481de648497ff1369965d3c3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 18:15:54 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

lvm: shell: honor log/command_log_selection as default and reset to this value after lastlog

---
 tools/lvm.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 2b95c41..628a29d 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -209,7 +209,8 @@ static void _discard_log_report_content(struct cmd_context *cmd)
 int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
-	int is_lastlog_cmd, argc, ret;
+	char *orig_command_log_selection = NULL;
+	int is_lastlog_cmd = 0, argc, ret;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
 	rl_readline_name = "lvm";
@@ -223,10 +224,21 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	if (!report_format_init(cmd))
 		return_ECMD_FAILED;
 
+	orig_command_log_selection = dm_pool_strdup(cmd->libmem, find_config_tree_str(cmd, log_command_log_selection_CFG, NULL));
 	log_set_report_context(LOG_REPORT_CONTEXT_SHELL);
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
 
 	while (1) {
+		if (cmd->cmd_report.log_rh) {
+			/*
+			 * If previous command was lastlog, reset log report selection to
+			 * its original value as set by log/command_log_selection config setting.
+			 */
+			if (is_lastlog_cmd &&
+			    !dm_report_set_selection(cmd->cmd_report.log_rh, orig_command_log_selection))
+				log_error("Failed to reset log report selection.");
+		}
+
 		log_set_report(cmd->cmd_report.log_rh);
 		log_set_report_object_name_and_id(NULL, NULL);
 


