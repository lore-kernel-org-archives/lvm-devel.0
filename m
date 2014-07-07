From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Jul 2014 13:58:16 +0000 (UTC)
Subject: master - report: fix segfault while reporting PV/LV segment fields together with LV fields needeing device status (LVSINFO)
Message-ID: <20140707135816.7292B61229@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83b55c2dfba12db95fa5247039470278741372ab
Commit:        83b55c2dfba12db95fa5247039470278741372ab
Parent:        6dc7b783c80c6834aa724df49b5d47b9b5601506
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 7 15:54:13 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 7 15:54:13 2014 +0200

report: fix segfault while reporting PV/LV segment fields together with LV fields needeing device status (LVSINFO)

There was missing lv_info call for situations where there were
mixed PV/LV segment fields together with LVSINFO fields which
require extra lv_info call for LV device status. This ended up
with NULL lvinfo passed to the field reporting functions, hence
the segfault.
---
 tools/reporter.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 70 insertions(+), 9 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 524d6c4..5e9fb24 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -70,12 +70,28 @@ static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 
 	return ECMD_PROCESSED;
 }
-static int _pvsegs_sub_single(struct cmd_context *cmd,
-			      struct volume_group *vg,
-			      struct pv_segment *pvseg, void *handle)
+
+static int _segs_with_lv_info_single(struct cmd_context *cmd __attribute__((unused)),
+				     struct lv_segment *seg, void *handle)
+{
+	struct lvinfo lvinfo;
+
+	if (!lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1) ||
+	    !report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+static int _do_pvsegs_sub_single(struct cmd_context *cmd,
+				 struct volume_group *vg,
+				 struct pv_segment *pvseg,
+				 int lv_info_needed,
+				 void *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
+	struct lvinfo lvinfo = {.exists = 0};
 
 	struct volume_group _free_vg = {
 		.cmd = cmd,
@@ -120,8 +136,13 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.segs_using_this_lv);
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
+	if (seg && !lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1)) {
+		ret = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, NULL, pv_label(pvseg->pv))) {
+			   seg ? : &_free_lv_segment, pvseg, &lvinfo, pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -130,6 +151,21 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	return ret;
 }
 
+static int _pvsegs_sub_single(struct cmd_context *cmd,
+			      struct volume_group *vg,
+			      struct pv_segment *pvseg, void *handle)
+{
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, handle);
+}
+
+static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
+					   struct volume_group *vg,
+					   struct pv_segment *pvseg,
+					   void *handle)
+{
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, handle);
+}
+
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  void *handle)
 {
@@ -139,6 +175,16 @@ static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
 }
 
+static int _lvsegs_with_lv_info_single(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       void *handle)
+{
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+		return ECMD_PROCESSED;
+
+	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_lv_info_single);
+}
+
 static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
 			  struct physical_volume *pv, void *handle)
 {
@@ -146,6 +192,15 @@ static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
 					  _pvsegs_sub_single);
 }
 
+static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
+				       struct volume_group *vg,
+				       struct physical_volume *pv,
+				       void *handle)
+{
+	return process_each_segment_in_pv(cmd, vg, pv, handle,
+				_pvsegs_with_lv_info_sub_single);
+}
+
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
@@ -253,7 +308,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
-	unsigned args_are_pvs;
+	unsigned args_are_pvs, lv_info_needed;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
@@ -371,12 +426,15 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					  columns_as_rows, selection)))
 		return_ECMD_FAILED;
 
+	/* Do we need lv_info to be called for LV device status? */
+	lv_info_needed = (report_type & LVSINFO) ? 1 : 0;
+
 	/* Ensure options selected are compatible */
 	if (report_type & SEGS)
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
-	if ((report_type & LVS) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
+	if ((report_type & (LVS | LVSINFO)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
@@ -384,7 +442,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	/* Change report type if fields specified makes this necessary */
 	if ((report_type & PVSEGS) ||
-	    ((report_type & (PVS | LABEL)) && (report_type & LVS)))
+	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO))))
 		report_type = PVSEGS;
 	else if ((report_type & LABEL) && (report_type & VGS))
 		report_type = PVS;
@@ -427,12 +485,15 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case SEGS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    &_lvsegs_single);
+				    lv_info_needed ? &_lvsegs_with_lv_info_single
+						   : &_lvsegs_single);
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    0, report_handle, &_pvsegs_single);
+					    0, report_handle,
+					    lv_info_needed ? &_pvsegs_with_lv_info_single
+							   : &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);


