From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Nov 2014 13:30:55 +0000 (UTC)
Subject: master - cleanup: unify LV info and LV segment status reporting in combination with LVS, SEGS and PVSEGS reporting
Message-ID: <20141113133055.C70DC60B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4de7699855e06bf341d5f91b9c3fc4ba4de18cd6
Commit:        4de7699855e06bf341d5f91b9c3fc4ba4de18cd6
Parent:        83308fdff97e242f6124858b35437ede6ee6a7e8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 13 14:14:20 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 13 14:28:51 2014 +0100

cleanup: unify LV info and LV segment status reporting in combination with LVS, SEGS and PVSEGS reporting

Move common code into shared internal fn so the logic for getting the
LV info as well LV segment status is not scattered around - call common
_do_info_and_status to gather required parts in reporting handlers.
---
 tools/reporter.c |  291 +++++++++++++++++++++++++++++++++---------------------
 1 files changed, 179 insertions(+), 112 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 65edec5b..ec1feb2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -39,71 +39,111 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_PROCESSED;
 }
 
-static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
-		       void *handle)
+static void _choose_lv_segment_for_status_report(struct logical_volume *lv, struct lv_segment **lv_seg)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL, NULL, NULL))
-		return_ECMD_FAILED;
+	/*
+	 * By default, take the first LV segment to report status for.
+	 * If there's any other specific segment that needs to be
+	 * reported instead for the LV, choose it here and assign it
+	 * to lvdm->seg_status->seg. This is the segment whose
+	 * status line will be used for report exactly.
+	 */
+	*lv_seg = first_seg(lv);
+}
 
-	return ECMD_PROCESSED;
+static void _do_info_and_status(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       struct lvinfo *lvinfo,
+			       struct lv_segment *lv_seg,
+			       struct lv_seg_status *lv_seg_status,
+			       int do_info, int do_status)
+{
+	if (lv_seg_status) {
+		lv_seg_status->mem = lv->vg->vgmem;
+		lv_seg_status->type = SEG_STATUS_NONE;
+		lv_seg_status->status = NULL;
+	}
+
+	if (do_info && !do_status) {
+		/* info only */
+		if (!lv_info(cmd, lv, 0, lvinfo, 1, 1))
+			lvinfo->exists = 0;
+	} else if (!do_info && do_status) {
+		/* status only */
+		if (!lv_seg)
+			_choose_lv_segment_for_status_report(lv, &lv_seg);
+		if (!lv_status(cmd, lv_seg, lv_seg_status))
+			lvinfo->exists = 0;
+	} else if (do_info && do_status) {
+		/* both info and status */
+		if (!lv_seg)
+			_choose_lv_segment_for_status_report(lv, &lv_seg);
+		if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, lvinfo, lv_seg_status, 1, 1))
+			lvinfo->exists = 0;
+	}
 }
 
-static void _get_lv_info_for_report(struct cmd_context *cmd,
-				   struct logical_volume *lv,
-				   struct lvinfo *lvinfo)
+static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
+					       struct logical_volume *lv,
+					       int do_info, int do_status,
+					       void *handle)
 {
-	if (!lv_info(cmd, lv, 0, lvinfo, 1, 1))
-		lvinfo->exists = 0;
+	struct lvinfo lvinfo;
+	struct lv_seg_status lv_seg_status;
+	int r = ECMD_FAILED;
+
+	_do_info_and_status(cmd, lv, &lvinfo, NULL, &lv_seg_status, do_info, do_status);
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL,
+			   do_info ? &lvinfo : NULL,
+			   do_status ? &lv_seg_status : NULL,
+			   NULL))
+		goto out;
+
+	r = ECMD_PROCESSED;
+out:
+	if (lv_seg_status.status)
+		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
+	return r;
 }
 
-static void _get_lv_info_with_segment_status_for_report(struct cmd_context *cmd,
-							struct logical_volume *lv,
-							struct lvinfo *lvinfo,
-							struct lv_segment *lv_seg,
-							struct lv_seg_status *lv_seg_status)
+static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
+		       void *handle)
 {
-	if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, lvinfo, lv_seg_status, 1, 1))
-		lvinfo->exists = 0;
+	return _do_lvs_with_info_and_status_single(cmd, lv, 0, 0, handle);
 }
 
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
 				 void *handle)
 {
-	struct lvinfo lvinfo;
-
-	_get_lv_info_for_report(cmd, lv, &lvinfo);
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, NULL, NULL))
-		return_ECMD_FAILED;
+	return _do_lvs_with_info_and_status_single(cmd, lv, 1, 0, handle);
+}
 
-	return ECMD_PROCESSED;
+static int _lvs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
+				   void *handle)
+{
+	return _do_lvs_with_info_and_status_single(cmd, lv, 0, 1, handle);
 }
 
-static void _choose_lv_segment_for_status_report(struct logical_volume *lv, struct lv_segment **lv_seg)
+static int _lvs_with_info_and_status_single(struct cmd_context *cmd, struct logical_volume *lv,
+					    void *handle)
 {
-	/*
-	 * By default, take the first LV segment to report status for.
-	 * If there's any other specific segment that needs to be
-	 * reported instead for the LV, choose it here and assign it
-	 * to lvdm->seg_status->seg. This is the segment whose
-	 * status line will be used for report exactly.
-	 */
-	*lv_seg = first_seg(lv);
+	return _do_lvs_with_info_and_status_single(cmd, lv, 1, 1, handle);
 }
 
-static int _lvs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
-				   void *handle)
+static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
+						struct lv_segment *seg,
+						int do_info, int do_status,
+						void *handle)
 {
 	struct lvinfo lvinfo;
-	struct lv_segment *lv_seg;
-	struct lv_seg_status lv_seg_status = { .mem = lv->vg->vgmem,
-					       .type = SEG_STATUS_NONE,
-					       .status = NULL };
+	struct lv_seg_status lv_seg_status;
 	int r = ECMD_FAILED;
 
-	_choose_lv_segment_for_status_report(lv, &lv_seg);
-	_get_lv_info_with_segment_status_for_report(cmd, lv, &lvinfo, lv_seg, &lv_seg_status);
-
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, &lv_seg_status, NULL))
+	_do_info_and_status(cmd, seg->lv, &lvinfo, seg, &lv_seg_status, do_info, do_status);
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
+			   do_info ? &lvinfo : NULL,
+			   do_status ? &lv_seg_status : NULL,
+			   NULL))
 		goto out;
 
 	r = ECMD_PROCESSED;
@@ -113,58 +153,77 @@ out:
 	return r;
 }
 
-static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
-			struct lv_segment *seg, void *handle)
+static int _segs_single(struct cmd_context *cmd, struct lv_segment *seg,
+			void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL, NULL, NULL))
-		return_ECMD_FAILED;
+	return _do_segs_with_info_and_status_single(cmd, seg, 0, 0, handle);
+}
 
-	return ECMD_PROCESSED;
+static int _segs_with_info_single(struct cmd_context *cmd, struct lv_segment *seg,
+				  void *handle)
+{
+	return _do_segs_with_info_and_status_single(cmd, seg, 1, 0, handle);
 }
 
-static int _segs_with_lv_info_single(struct cmd_context *cmd __attribute__((unused)),
-				     struct lv_segment *seg, void *handle)
+static int _segs_with_status_single(struct cmd_context *cmd, struct lv_segment *seg,
+				    void *handle)
 {
-	struct lvinfo lvinfo;
+	return _do_segs_with_info_and_status_single(cmd, seg, 0, 1, handle);
+}
 
-	_get_lv_info_for_report(cmd, seg->lv, &lvinfo);
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL, NULL))
-		return_ECMD_FAILED;
+static int _segs_with_info_and_status_single(struct cmd_context *cmd, struct lv_segment *seg,
+					     void *handle)
+{
+	return _do_segs_with_info_and_status_single(cmd, seg, 1, 1, handle);
+}
 
-	return ECMD_PROCESSED;
+static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
+			  void *handle)
+{
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
+
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
 }
 
-static int _segs_with_lv_status_single(struct cmd_context *cmd __attribute__((unused)),
-				       struct lv_segment *seg, void *handle)
+static int _lvsegs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
+				    void *handle)
 {
-	struct lvinfo lvinfo;
-	struct lv_seg_status lv_seg_status = { .mem = seg->lv->vg->vgmem,
-					       .type = SEG_STATUS_NONE,
-					       .status = NULL };
-	int r = ECMD_FAILED;
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
 
-	_get_lv_info_with_segment_status_for_report(cmd, seg->lv, &lvinfo, seg, &lv_seg_status);
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, &lv_seg_status, NULL))
-		goto_out;
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_info_single);
+}
 
-	r = ECMD_PROCESSED;
-out:
-	if (lv_seg_status.status)
-		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
-	return r;
+static int _lvsegs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
+				      void *handle)
+{
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
+
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_status_single);
+}
+
+static int _lvsegs_with_info_and_status_single(struct cmd_context *cmd, struct logical_volume *lv,
+					       void *handle)
+{
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
+
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_info_and_status_single);
 }
 
 static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 				 struct volume_group *vg,
 				 struct pv_segment *pvseg,
-				 int lv_info_needed,
-				 int lv_seg_status_needed,
+				 int do_info,
+				 int do_status,
 				 void *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 	struct lvinfo lvinfo = { .exists = 0 };
-	struct lv_seg_status lv_seg_status;
+	struct lv_seg_status lv_seg_status = { .type = SEG_STATUS_NONE };
 
 	struct segment_type _freeseg_type = {
 		.name = "free",
@@ -199,8 +258,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.origin_list = DM_LIST_HEAD_INIT(_free_lv_segment.origin_list),
 	};
 
-	if (seg && lv_info_needed)
-	    _get_lv_info_for_report(cmd, seg->lv, &lvinfo);
+	if (seg)
+		_do_info_and_status(cmd, seg->lv, &lvinfo, seg, &lv_seg_status, do_info, do_status);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg, &lvinfo, &lv_seg_status,
@@ -215,7 +274,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 
 static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
-			      struct pv_segment *pvseg, void *handle)
+			      struct pv_segment *pvseg,
+			      void *handle)
 {
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, 0, handle);
 }
@@ -228,40 +288,28 @@ static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, 0, handle);
 }
 
-static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
-			  void *handle)
+static int _pvsegs_with_lv_status_sub_single(struct cmd_context *cmd,
+					     struct volume_group *vg,
+					     struct pv_segment *pvseg,
+					     void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
-	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, 1, handle);
 }
 
-static int _lvsegs_with_lv_info_single(struct cmd_context *cmd,
-				       struct logical_volume *lv,
-				       void *handle)
+static int _pvsegs_with_lv_info_and_status_sub_single(struct cmd_context *cmd,
+						      struct volume_group *vg,
+						      struct pv_segment *pvseg,
+						      void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
-	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_lv_info_single);
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, 1, handle);
 }
 
-static int _lvsegs_with_lv_status_single(struct cmd_context *cmd,
-					 struct logical_volume *lv,
-					 void *handle)
-{
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
-	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_lv_status_single);
-}
-
-static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
-			  struct physical_volume *pv, void *handle)
+static int _pvsegs_single(struct cmd_context *cmd,
+			  struct volume_group *vg,
+			  struct physical_volume *pv,
+			  void *handle)
 {
-	return process_each_segment_in_pv(cmd, vg, pv, handle,
-					  _pvsegs_sub_single);
+	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_sub_single);
 }
 
 static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
@@ -269,8 +317,23 @@ static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
 				       struct physical_volume *pv,
 				       void *handle)
 {
-	return process_each_segment_in_pv(cmd, vg, pv, handle,
-				_pvsegs_with_lv_info_sub_single);
+	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_info_sub_single);
+}
+
+static int _pvsegs_with_lv_status_single(struct cmd_context *cmd,
+					 struct volume_group *vg,
+					 struct physical_volume *pv,
+					 void *handle)
+{
+	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_status_sub_single);
+}
+
+static int _pvsegs_with_lv_info_and_status_single(struct cmd_context *cmd,
+						  struct volume_group *vg,
+						  struct physical_volume *pv,
+						  void *handle)
+{
+	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_info_and_status_sub_single);
 }
 
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
@@ -501,9 +564,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		/* fall through */
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    lv_segment_status_needed ? &_lvs_with_status_single
-							     : lv_info_needed ? &_lvs_with_info_single
-									      : &_lvs_single);
+				    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
+				    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
+				    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
+										 &_lvs_single);
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, 0,
@@ -525,16 +589,19 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		/* fall through */
 	case SEGS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    lv_segment_status_needed ? &_lvsegs_with_lv_status_single
-							     :lv_info_needed ? &_lvsegs_with_lv_info_single
-									     : &_lvsegs_single);
+				    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
+				    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
+				    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
+										 &_lvsegs_single);
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    report_handle,
-					    lv_info_needed ? &_pvsegs_with_lv_info_single
-							   : &_pvsegs_single);
+					    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
+					    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
+					    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
+											 &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);


