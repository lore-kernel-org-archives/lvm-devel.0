From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:05 +0000 (UTC)
Subject: master - report: add report_current_object_cmdlog fn as a shortcut for reporting current object's log item
Message-ID: <20160620094105.4397A60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe63715f25cf156b07e144a2e7b5cce56d32e39e
Commit:        fe63715f25cf156b07e144a2e7b5cce56d32e39e
Parent:        7d4a15e53a19dcc073b7037638d811eba3a85edf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 23 15:09:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: add report_current_object_cmdlog fn as a shortcut for reporting current object's log item

---
 lib/report/report.c |   11 +++++++++++
 lib/report/report.h |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index eec9756..1436cfe 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3869,3 +3869,14 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 
 	return 1;
 }
+
+int report_current_object_cmdlog(const char *type, const char *msg, int32_t ret_code)
+{
+	log_report_t log_state = log_get_report_state();
+
+	return report_cmdlog(log_state.report, type, log_get_report_context_name(log_state.context),
+			     log_get_report_object_type_name(log_state.object_type),
+			     log_state.object_name, log_state.object_id,
+			     log_state.object_group, log_state.object_group_id,
+			     msg, stored_errno(), ret_code);
+}
diff --git a/lib/report/report.h b/lib/report/report.h
index 37e1061..a6f17cd 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -110,6 +110,7 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 		  const char *object_id, const char *object_group,
 		  const char *object_group_id, const char *msg,
 		  int current_errno, int ret_code);
+int report_current_object_cmdlog(const char *type, const char *msg, int32_t ret_code);
 int report_output(void *handle);
 
 #endif


