From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:40:02 +0000 (UTC)
Subject: master - report: add report_reset_cmdlog_seqnum and call it for each new cmd executed in lvm shell
Message-ID: <20160809174002.9E8286072F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ac008116be94797f7f9f39d61cb1bd96c60669c
Commit:        5ac008116be94797f7f9f39d61cb1bd96c60669c
Parent:        29f7dc292295bc6cad92e888691cb949d83c0413
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 15:45:46 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

report: add report_reset_cmdlog_seqnum and call it for each new cmd executed in lvm shell

---
 lib/report/report.c |   12 +++++++++---
 lib/report/report.h |    1 +
 tools/lvm.c         |    1 +
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index fab6379..ea36795 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -38,6 +38,9 @@ struct lvm_report_object {
 	struct label *label;
 };
 
+static uint32_t log_seqnum = 1;
+
+
 /*
  *  Enum for field_num index to use in per-field reserved value definition.
  *  Each field is represented by enum value with name "field_<id>" where <id>
@@ -3867,9 +3870,7 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 		  const char *object_group_id, const char *msg,
 		  int current_errno, int ret_code)
 {
-	static uint32_t seq_num = 1;
-
-	struct cmd_log_item log_item = {seq_num++, type, context, object_type_name,
+	struct cmd_log_item log_item = {log_seqnum++, type, context, object_type_name,
 					object_name ? : "", object_id ? : "",
 					object_group ? : "", object_group_id ? : "",
 					msg ? : "", current_errno, ret_code};
@@ -3880,6 +3881,11 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 	return 1;
 }
 
+void report_reset_cmdlog_seqnum(void)
+{
+	log_seqnum = 1;
+}
+
 int report_current_object_cmdlog(const char *type, const char *msg, int32_t ret_code)
 {
 	log_report_t log_state = log_get_report_state();
diff --git a/lib/report/report.h b/lib/report/report.h
index cf4145e..c787f56 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -111,6 +111,7 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 		  const char *object_id, const char *object_group,
 		  const char *object_group_id, const char *msg,
 		  int current_errno, int ret_code);
+void report_reset_cmdlog_seqnum(void);
 #define REPORT_OBJECT_CMDLOG_NAME "status"
 #define REPORT_OBJECT_CMDLOG_SUCCESS "success"
 #define REPORT_OBJECT_CMDLOG_FAILURE "failure"
diff --git a/tools/lvm.c b/tools/lvm.c
index 628a29d..b3af020 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -229,6 +229,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
 
 	while (1) {
+		report_reset_cmdlog_seqnum();
 		if (cmd->cmd_report.log_rh) {
 			/*
 			 * If previous command was lastlog, reset log report selection to


