From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 14 Apr 2016 13:24:54 +0000 (UTC)
Subject: master - refactor: factor out vg/lv/pv handling part from report_for_selection fn
Message-ID: <20160414132454.8F4C761BC4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f6e7f90cac72bd248c068f2893ef851d29cf1b9
Commit:        3f6e7f90cac72bd248c068f2893ef851d29cf1b9
Parent:        9a299d2d7a04759749bd6c01a86b90fd13f27b96
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 14 15:21:41 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 14 15:24:36 2016 +0200

refactor: factor out vg/lv/pv handling part from report_for_selection fn

Functionality will be reused by future patches. Also, it makes the code
more readable.
---
 tools/reporter.c |  160 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 96 insertions(+), 64 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index a4cae60..ab11be2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -438,13 +438,104 @@ static int _get_final_report_type(int args_are_pvs,
 	return 1;
 }
 
+static int _report_all_in_vg(struct cmd_context *cmd, struct processing_handle *handle,
+			     struct volume_group *vg, report_type_t type,
+			     int do_lv_info, int do_lv_seg_status)
+{
+	int r = 0;
+
+	switch (type) {
+		case VGS:
+			r = _vgs_single(cmd, vg->name, vg, handle);
+			break;
+		case LVS:
+			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle,
+						  do_lv_info && !do_lv_seg_status ? &_lvs_with_info_single :
+						  !do_lv_info && do_lv_seg_status ? &_lvs_with_status_single :
+						  do_lv_info && do_lv_seg_status ? &_lvs_with_info_and_status_single :
+										   &_lvs_single);
+			break;
+		case SEGS:
+			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle,
+						  do_lv_info && !do_lv_seg_status ? &_lvsegs_with_info_single :
+						  !do_lv_info && do_lv_seg_status ? &_lvsegs_with_status_single :
+						  do_lv_info && do_lv_seg_status ? &_lvsegs_with_info_and_status_single :
+										   &_lvsegs_single);
+			break;
+		case PVS:
+			r = process_each_pv_in_vg(cmd, vg, handle, &_pvs_single);
+			break;
+		case PVSEGS:
+			r = process_each_pv_in_vg(cmd, vg, handle,
+						  do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_single :
+						  !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_single :
+						  do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_single :
+										   &_pvsegs_single);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_report_all_in_vg: incorrect report type");
+			break;
+	}
+
+	return r;
+}
+
+static int _report_all_in_lv(struct cmd_context *cmd, struct processing_handle *handle,
+			     struct logical_volume *lv, report_type_t type,
+			     int do_lv_info, int do_lv_seg_status)
+{
+	int r = 0;
+
+	switch (type) {
+		case LVS:
+			r = _do_lvs_with_info_and_status_single(cmd, lv, do_lv_info, do_lv_seg_status, handle);
+			break;
+		case SEGS:
+			r = process_each_segment_in_lv(cmd, lv, handle,
+						       do_lv_info && !do_lv_seg_status ? &_segs_with_info_single :
+							       !do_lv_info && do_lv_seg_status ? &_segs_with_status_single :
+							       do_lv_info && do_lv_seg_status ? &_segs_with_info_and_status_single :
+												&_segs_single);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_report_all_in_lv: incorrect report type");
+			break;
+	}
+
+	return r;
+}
+
+static int _report_all_in_pv(struct cmd_context *cmd, struct processing_handle *handle,
+			     struct physical_volume *pv, report_type_t type,
+			     int do_lv_info, int do_lv_seg_status)
+{
+	int r = 0;
+
+	switch (type) {
+		case PVS:
+			r = _pvs_single(cmd, pv->vg, pv, handle);
+			break;
+		case PVSEGS:
+			r = process_each_segment_in_pv(cmd, pv->vg, pv, handle,
+						       do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_sub_single :
+						       !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_sub_single :
+						       do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_sub_single :
+											&_pvsegs_sub_single);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_report_all_in_pv: incorrect report type");
+			break;
+	}
+
+	return r;
+}
+
 int report_for_selection(struct cmd_context *cmd,
 			 struct selection_handle *sh,
 			 struct physical_volume *pv,
 			 struct volume_group *vg,
 			 struct logical_volume *lv)
 {
-	static const char *incorrect_report_type_msg = "report_for_selection: incorrect report type";
 	int args_are_pvs = sh->orig_report_type == PVS;
 	int do_lv_info, do_lv_seg_status;
 	struct processing_handle *handle;
@@ -491,75 +582,16 @@ int report_for_selection(struct cmd_context *cmd,
 	 */
 	switch (sh->orig_report_type) {
 		case LVS:
-			switch (sh->report_type) {
-				case LVS:
-					r = _do_lvs_with_info_and_status_single(vg->cmd, lv, do_lv_info, do_lv_seg_status, handle);
-					break;
-				case SEGS:
-					r = process_each_segment_in_lv(vg->cmd, lv, handle,
-								       do_lv_info && !do_lv_seg_status ? &_segs_with_info_single :
-								       !do_lv_info && do_lv_seg_status ? &_segs_with_status_single :
-								       do_lv_info && do_lv_seg_status ? &_segs_with_info_and_status_single :
-													&_segs_single);
-					break;
-				default:
-					log_error(INTERNAL_ERROR "%s for LVS", incorrect_report_type_msg);
-					break;
-			}
+			r = _report_all_in_lv(cmd, handle, lv, sh->report_type, do_lv_info, do_lv_seg_status);
 			break;
 		case VGS:
-			switch (sh->report_type) {
-				case VGS:
-					r = _vgs_single(vg->cmd, vg->name, vg, handle);
-					break;
-				case LVS:
-					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, handle,
-								  do_lv_info && !do_lv_seg_status ? &_lvs_with_info_single :
-								  !do_lv_info && do_lv_seg_status ? &_lvs_with_status_single :
-								  do_lv_info && do_lv_seg_status ? &_lvs_with_info_and_status_single :
-												   &_lvs_single);
-					break;
-				case SEGS:
-					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, handle,
-								  do_lv_info && !do_lv_seg_status ? &_lvsegs_with_info_single :
-								  !do_lv_info && do_lv_seg_status ? &_lvsegs_with_status_single :
-								  do_lv_info && do_lv_seg_status ? &_lvsegs_with_info_and_status_single :
-												   &_lvsegs_single);
-					break;
-				case PVS:
-					r = process_each_pv_in_vg(vg->cmd, vg, handle, &_pvs_single);
-					break;
-				case PVSEGS:
-					r = process_each_pv_in_vg(vg->cmd, vg, handle,
-								  do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_single :
-								  !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_single :
-								  do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_single :
-												   &_pvsegs_single);
-					break;
-				default:
-					log_error(INTERNAL_ERROR "%s for VGS", incorrect_report_type_msg);
-					break;
-			}
+			r = _report_all_in_vg(cmd, handle, vg, sh->report_type, do_lv_info, do_lv_seg_status);
 			break;
 		case PVS:
-			switch (sh->report_type) {
-				case PVS:
-					r = _pvs_single(vg->cmd, vg, pv, handle);
-					break;
-				case PVSEGS:
-					r = process_each_segment_in_pv(vg->cmd, vg, pv, handle,
-								       do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_sub_single :
-								       !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_sub_single :
-								       do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_sub_single :
-													&_pvsegs_sub_single);
-					break;
-				default:
-					log_error(INTERNAL_ERROR "%s for PVS", incorrect_report_type_msg);
-					break;
-			}
+			r = _report_all_in_pv(cmd, handle, pv, sh->report_type, do_lv_info, do_lv_seg_status);
 			break;
 		default:
-			log_error(INTERNAL_ERROR "%s", incorrect_report_type_msg);
+			log_error(INTERNAL_ERROR "report_for_selection: incorrect report type");
 			break;
 	}
 


