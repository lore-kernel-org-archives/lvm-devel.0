From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:03 +0000 (UTC)
Subject: master - report: add report_for_selection and use it in select_match_{pv, vg, lv}
Message-ID: <20150210151303.7FDCE607A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=984ae7f72dee4f119eafc4e236a276a6c8a3fc95
Commit:        984ae7f72dee4f119eafc4e236a276a6c8a3fc95
Parent:        e5b345aff389af24bde7986b236a92e166435f38
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 1 14:19:30 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:36 2015 +0100

report: add report_for_selection and use it in select_match_{pv,vg,lv}

The report_for_selection does the actual "reporting for selection only".
The selection status will be saved in struct selection_handle's "selected"
variable.
---
 lib/report/report.h |    4 ++++
 tools/reporter.c    |    8 ++++++++
 tools/toollib.c     |   33 ++++++++++++++++++++++++++++++---
 3 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.h b/lib/report/report.h
index 80a75fd..5bd8b79 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -71,6 +71,10 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int quoted, int columns_as_rows, const char *selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
+int report_for_selection(struct selection_handle *sh,
+			 struct physical_volume *pv,
+			 struct volume_group *vg,
+			 struct logical_volume *lv);
 void report_free(void *handle);
 int report_object(void *handle, int selection_only, const struct volume_group *vg,
 		  const struct logical_volume *lv, const struct physical_volume *pv,
diff --git a/tools/reporter.c b/tools/reporter.c
index 4e41e90..7301956 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -447,6 +447,14 @@ static int _get_final_report_type(int args_are_pvs,
 	return 1;
 }
 
+int report_for_selection(struct selection_handle *sh,
+			 struct physical_volume *pv,
+			 struct volume_group *vg,
+			 struct logical_volume *lv)
+{
+	return 1;
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
diff --git a/tools/toollib.c b/tools/toollib.c
index 7d406ba..34286e3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1628,36 +1628,63 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, int *selected)
 {
+	struct selection_handle *sh = handle->selection_handle;
+
 	if (!handle->internal_report_for_select) {
 		*selected = 1;
 		return 1;
 	}
 
-	*selected = 1;
+	sh->orig_report_type = VGS;
+
+	if (!report_for_selection(sh, NULL, vg, NULL))
+		return_0;
+
+	sh->orig_report_type = 0;
+	*selected = sh->selected;
+
 	return 1;
 }
 
 int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, struct logical_volume *lv, int *selected)
 {
+	struct selection_handle *sh = handle->selection_handle;
+
 	if (!handle->internal_report_for_select) {
 		*selected = 1;
 		return 1;
 	}
 
-	*selected = 1;
+	sh->orig_report_type = LVS;
+
+	if (!report_for_selection(sh, NULL, vg, lv))
+		return_0;
+
+	sh->orig_report_type = 0;
+	*selected = sh->selected;
+
 	return 1;
 }
 
 int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, struct physical_volume *pv, int *selected)
 {
+	struct selection_handle *sh = handle->selection_handle;
+
 	if (!handle->internal_report_for_select) {
 		*selected = 1;
 		return 1;
 	}
 
-	*selected = 1;
+	sh->orig_report_type = PVS;
+
+	if (!report_for_selection(sh, pv, vg, NULL))
+		return_0;
+
+	sh->orig_report_type = 0;
+	*selected = sh->selected;
+
 	return 1;
 }
 


