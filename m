From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:58 +0000 (UTC)
Subject: master - report: check report type and options used for full report's subreports
Message-ID: <20160620094058.F395460FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31aaa3be71597ec53262177bea76365605e9199f
Commit:        31aaa3be71597ec53262177bea76365605e9199f
Parent:        b864a062217cf31d86343f37ecbefeeeb15610cf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 3 11:42:55 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: check report type and options used for full report's subreports

If we have fullreport, make sure that the options/sort keys used for
each report doesn't change its type - we want to preserve the original
type so it's always 5 different subreports within fullreport (vg, lv, pv,
seg, pvseg). Since we have all report types within fullreport, users
should add fields under proper subreport type - this minimizes
duplication of info displayed on output.
---
 tools/reporter.c |   36 ++++++++++++++++++++++++------------
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 9dd302a..1fcb338 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -439,7 +439,8 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
 
-static int _get_final_report_type(int args_are_pvs,
+static int _get_final_report_type(struct report_args *args,
+				  struct single_report_args *single_args,
 				  report_type_t report_type,
 				  int *lv_info_needed,
 				  int *lv_segment_status_needed,
@@ -457,8 +458,11 @@ static int _get_final_report_type(int args_are_pvs,
 	if (report_type & PVSEGS)
 		report_type |= PVS;
 	if ((report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS)) &&
-	    (report_type & (PVS | LABEL)) && !args_are_pvs) {
-		log_error("Can't report LV and PV fields at the same time");
+	    (report_type & (PVS | LABEL)) && !(single_args->args_are_pvs || (args->full_report_vg && single_args->report_type == PVSEGS))) {
+		log_error("Can't report LV and PV fields at the same time in %sreport type \"%s\"%s%s.",
+			  args->full_report_vg ? "sub" : "" , single_args->report_prefix,
+			  args->full_report_vg ? " in VG " : "",
+			  args->full_report_vg ? args->full_report_vg->name: "");
 		return 0;
 	}
 
@@ -476,6 +480,13 @@ static int _get_final_report_type(int args_are_pvs,
 	else if (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))
 		report_type = LVS;
 
+	if (args->full_report_vg && (report_type != single_args->report_type)) {
+		/* FIXME: Tell user about which columns exactly are incorrectly used for that report type... */
+		log_error("Subreport of type \"%s\" for VG %s contains columns which lead to change of report type. "
+			  "Add these columns to proper subreport type.", single_args->report_prefix, args->full_report_vg->name);
+		return 0;
+	}
+
 	*final_report_type = report_type;
 	return 1;
 }
@@ -579,15 +590,18 @@ int report_for_selection(struct cmd_context *cmd,
 			 struct logical_volume *lv)
 {
 	struct selection_handle *sh = parent_handle->selection_handle;
-	int args_are_pvs = sh->orig_report_type == PVS;
+	struct report_args args = {0};
+	struct single_report_args *single_args = &args.single_args[REPORT_IDX_SINGLE];
 	int do_lv_info, do_lv_seg_status;
 	struct processing_handle *handle;
 	int r = 0;
 
-	if (!_get_final_report_type(args_are_pvs,
-				    sh->orig_report_type | sh->report_type,
-				    &do_lv_info,
-				    &do_lv_seg_status,
+	single_args->report_type = sh->orig_report_type | sh->report_type;
+	single_args->args_are_pvs = sh->orig_report_type == PVS;
+
+	if (!_get_final_report_type(&args, single_args,
+				    single_args->report_type,
+				    &do_lv_info, &do_lv_seg_status,
 				    &sh->report_type))
 		return_0;
 
@@ -1023,10 +1037,8 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 
 	handle->custom_handle = report_handle;
 
-	if (!_get_final_report_type(single_args->args_are_pvs,
-				    report_type, &lv_info_needed,
-				    &lv_segment_status_needed,
-				    &report_type))
+	if (!_get_final_report_type(args, single_args, report_type, &lv_info_needed,
+				    &lv_segment_status_needed, &report_type))
 		goto_out;
 
 	if (handle->report_group) {


