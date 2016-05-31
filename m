From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 07:09:23 +0000 (UTC)
Subject: master - toollib: properly reset selection handle on selection failure in select_match_{pv, vg, lv}
Message-ID: <20160531070923.0299960D52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fb224a5532defa08d48b28add98606803035b9d
Commit:        4fb224a5532defa08d48b28add98606803035b9d
Parent:        e4ec6bcdd38505c6c229d578aa3eca006441b035
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 09:08:59 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 09:08:59 2016 +0200

toollib: properly reset selection handle on selection failure in select_match_{pv,vg,lv}

---
 tools/toollib.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b86b8ff..b41db0f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1766,49 +1766,49 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg)
 {
+	int r;
+
 	if (!handle->internal_report_for_select)
 		return 1;
 
 	handle->selection_handle->orig_report_type = VGS;
-	if (!report_for_selection(cmd, handle, NULL, vg, NULL)) {
+	if (!(r = report_for_selection(cmd, handle, NULL, vg, NULL)))
 		log_error("Selection failed for VG %s.", vg->name);
-		return 0;
-	}
 	handle->selection_handle->orig_report_type = 0;
 
-	return 1;
+	return r;
 }
 
 int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, struct logical_volume *lv)
 {
+	int r;
+
 	if (!handle->internal_report_for_select)
 		return 1;
 
 	handle->selection_handle->orig_report_type = LVS;
-	if (!report_for_selection(cmd, handle, NULL, vg, lv)) {
+	if (!(r = report_for_selection(cmd, handle, NULL, vg, lv)))
 		log_error("Selection failed for LV %s.", lv->name);
-		return 0;
-	}
 	handle->selection_handle->orig_report_type = 0;
 
-	return 1;
+	return r;
 }
 
 int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, struct physical_volume *pv)
 {
+	int r;
+
 	if (!handle->internal_report_for_select)
 		return 1;
 
 	handle->selection_handle->orig_report_type = PVS;
-	if (!report_for_selection(cmd, handle, pv, vg, NULL)) {
+	if (!(r = report_for_selection(cmd, handle, pv, vg, NULL)))
 		log_error("Selection failed for PV %s.", dev_name(pv->dev));
-		return 0;
-	}
 	handle->selection_handle->orig_report_type = 0;
 
-	return 1;
+	return r;
 }
 
 static int _select_matches(struct processing_handle *handle)


