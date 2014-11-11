From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:12:35 +0000 (UTC)
Subject: master - report: add new LVSSTATUS and SEGSSTATUS report type
Message-ID: <20141111121235.A7B8361079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f90ad84c1f9bbc51a833b7ebb6459842405de52
Commit:        7f90ad84c1f9bbc51a833b7ebb6459842405de52
Parent:        d7e5f038887be820874522674a51071705439c8e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 21 12:01:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 08:53:28 2014 +0100

report: add new LVSSTATUS and SEGSSTATUS report type

Similar to LVSINFO type which gathers LV + its DM_DEVICE_INFO, the
new LVSSTATUS/SEGSSTATUS report type will gather LV/segment + its
DM_DEVICE_STATUS.

Since we can report status only for certain segment, in case
of LVSSTATUS we need to choose which segment related to the LV
should be processed that represents the "LV status". In case of
SEGSSTATUS type it's clear - the status is reported for the
segment just processed.
---
 lib/report/report.c |    2 +
 lib/report/report.h |   14 +++---
 tools/reporter.c    |  122 ++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 121 insertions(+), 17 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 511d6cb..74ba4bc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1749,9 +1749,11 @@ static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
 	{ LVSINFO, "Logical Volume Device Info", "lv_", _obj_get_lv_with_info_and_seg_status },
+	{ LVSSTATUS, "Logical Volume Device Status", "lv_", _obj_get_lv_with_info_and_seg_status },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
 	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
+	{ SEGSSTATUS, "Logical Volume Device Segment Status", "seg_", _obj_get_lv_with_info_and_seg_status },
 	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
 	{ 0, "", "", NULL },
 };
diff --git a/lib/report/report.h b/lib/report/report.h
index e4b302e..20fb6bd 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -23,12 +23,14 @@
 typedef enum {
 	LVS		= 1,
 	LVSINFO		= 2,
-	PVS		= 4,
-	VGS		= 8,
-	SEGS		= 16,
-	PVSEGS		= 32,
-	LABEL		= 64,
-	DEVTYPES	= 128
+	LVSSTATUS	= 4,
+	PVS		= 8,
+	VGS		= 16,
+	SEGS		= 32,
+	SEGSSTATUS	= 64,
+	PVSEGS		= 128,
+	LABEL		= 256,
+	DEVTYPES	= 512
 } report_type_t;
 
 struct field;
diff --git a/tools/reporter.c b/tools/reporter.c
index 959e884..d8c19eb 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -56,6 +56,11 @@ static void _get_lv_info_for_report(struct cmd_context *cmd,
 		lvinfo->exists = 0;
 }
 
+static void _get_lv_info_with_segment_status_for_report(struct cmd_context *cmd,
+							struct lv_with_info_and_seg_status *lvdm)
+{
+}
+
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
 				 void *handle)
 {
@@ -68,6 +73,58 @@ static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume
 	return ECMD_PROCESSED;
 }
 
+static void _choose_lv_segment_for_status_report(struct lv_with_info_and_seg_status *lvdm)
+{
+	/*
+	 * By default, take the first LV segment to report status for.
+	 * If there's any other specific segment that needs to be
+	 * reported instead for the LV, choose it here and assign it
+	 * to lvdm->seg_status->seg. This is the segment whose
+	 * status line will be used for report exactly.
+	 */
+	lvdm->seg_status->seg = first_seg(lvdm->lv);
+}
+
+static int _lvs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
+				   void *handle)
+{
+	struct lvinfo lvinfo;
+	struct lv_seg_status lv_seg_status = { .mem = lv->vg->vgmem,
+					       .type = SEG_STATUS_NONE,
+					       .status = NULL };
+	struct lv_with_info_and_seg_status lvdm = { .lv = lv,
+						    .seg_status = &lv_seg_status };
+	int r = ECMD_FAILED;
+
+	_choose_lv_segment_for_status_report(&lvdm);
+
+	if (lvdm.seg_status->seg->lv != lv) {
+		/*
+		 * If the info is requested on one LV and segment
+		 * status on another LV, we need to call these separately.
+		 */
+		_get_lv_info_for_report(cmd, lv, &lvinfo);
+		lvdm.info = NULL;
+		_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
+	} else {
+		/*
+		 * If the info is requested on the same LV as status,
+		 * we can get info and status in one go!
+		 */
+		lvdm.info = &lvinfo;
+		_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
+	}
+
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, lvdm.seg_status, NULL))
+		goto out;
+
+	r = ECMD_PROCESSED;
+out:
+	if (lvdm.seg_status->status)
+		dm_pool_free(lvdm.seg_status->mem, lvdm.seg_status->status);
+	return r;
+}
+
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
@@ -89,6 +146,30 @@ static int _segs_with_lv_info_single(struct cmd_context *cmd __attribute__((unus
 	return ECMD_PROCESSED;
 }
 
+static int _segs_with_lv_status_single(struct cmd_context *cmd __attribute__((unused)),
+				       struct lv_segment *seg, void *handle)
+{
+	struct lvinfo lvinfo;
+	struct lv_seg_status lv_seg_status = { .seg = seg,
+					       .mem = seg->lv->vg->vgmem,
+					       .type = SEG_STATUS_NONE,
+					       .status = NULL };
+	struct lv_with_info_and_seg_status lvdm = { .lv = seg->lv,
+						    .info = &lvinfo,
+						    .seg_status = &lv_seg_status };
+	int r = ECMD_FAILED;
+
+	_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, lvdm.info, lvdm.seg_status, NULL))
+		goto_out;
+
+	r = ECMD_PROCESSED;
+out:
+	if (lvdm.seg_status->status)
+		dm_pool_free(lvdm.seg_status->mem, lvdm.seg_status->status);
+	return r;
+}
+
 static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 				 struct volume_group *vg,
 				 struct pv_segment *pvseg,
@@ -182,6 +263,16 @@ static int _lvsegs_with_lv_info_single(struct cmd_context *cmd,
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_lv_info_single);
 }
 
+static int _lvsegs_with_lv_status_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 void *handle)
+{
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
+
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_lv_status_single);
+}
+
 static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
 			  struct physical_volume *pv, void *handle)
 {
@@ -254,7 +345,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
-	unsigned args_are_pvs, lv_info_needed;
+	unsigned args_are_pvs, lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
@@ -373,15 +464,18 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					  columns_as_rows, selection)))
 		return_ECMD_FAILED;
 
-	/* Do we need lv_info to be called for LV device status? */
+	/* Do we need to acquire LV device info in addition? */
 	lv_info_needed = (report_type & LVSINFO) ? 1 : 0;
 
+	/* Do we need to acquire LV device status in addition? */
+	lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS)) ? 1 : 0;
+
 	/* Ensure options selected are compatible */
-	if (report_type & SEGS)
+	if (report_type & (SEGS | SEGSSTATUS))
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
-	if ((report_type & (LVS | LVSINFO)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
+	if ((report_type & (LVS | LVSINFO | LVSSTATUS)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
@@ -389,15 +483,15 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	/* Change report type if fields specified makes this necessary */
 	if ((report_type & PVSEGS) ||
-	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO))))
+	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS))))
 		report_type = PVSEGS;
 	else if ((report_type & LABEL) && (report_type & VGS))
 		report_type = PVS;
 	else if (report_type & PVS)
 		report_type = PVS;
-	else if (report_type & SEGS)
+	else if (report_type & (SEGS | SEGSSTATUS))
 		report_type = SEGS;
-	else if (report_type & (LVS | LVSINFO))
+	else if (report_type & (LVS | LVSINFO | LVSSTATUS))
 		report_type = LVS;
 
 	/*
@@ -419,10 +513,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case LVSINFO:
 		/* fall through */
+	case LVSSTATUS:
+		/* fall through */
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    lv_info_needed ? &_lvs_with_info_single
-						   : &_lvs_single);
+				    lv_segment_status_needed ? &_lvs_with_status_single
+							     : lv_info_needed ? &_lvs_with_info_single
+									      : &_lvs_single);
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, 0,
@@ -440,10 +537,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvs_in_vg);
 		break;
+	case SEGSSTATUS:
+		/* fall through */
 	case SEGS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    lv_info_needed ? &_lvsegs_with_lv_info_single
-						   : &_lvsegs_single);
+				    lv_segment_status_needed ? &_lvsegs_with_lv_status_single
+							     :lv_info_needed ? &_lvsegs_with_lv_info_single
+									     : &_lvsegs_single);
 		break;
 	case PVSEGS:
 		if (args_are_pvs)


