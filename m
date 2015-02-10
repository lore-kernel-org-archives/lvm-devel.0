From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:05 +0000 (UTC)
Subject: master - report: implement report_for_selection
Message-ID: <20150210151305.A699260F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56846d787381e5dc90f3a3adbcc3de58154a4ed3
Commit:        56846d787381e5dc90f3a3adbcc3de58154a4ed3
Parent:        984ae7f72dee4f119eafc4e236a276a6c8a3fc95
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 1 15:40:03 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:06:53 2015 +0100

report: implement report_for_selection

We have 3 input report types:
  - LVS (representing "_select_match_lv")
  - VGS (representing "_select_match_vg")
  - PVS (representing "_select_match_pv")

The input report type is saved in struct selection_handle's "orig_report_type"
 variable.

However, users can use any combination of fields of different report types in
selection criteria - the resulting report type can thus differ. The struct
selection_handle's "report_type" variable stores this resulting report type.

The resulting report_type can end up as one of:
  - LVS
  - VGS
  - PVS
  - SEGS
  - PVSEGS

This patch adds logic to report_for_selection based on (sensible) combination
of orig_report_type and report_type and calls appropriate reporting functions
or iterates over multiple items that need reporting to determine the selection
result.
---
 WHATS_NEW        |    1 +
 tools/reporter.c |   96 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 96 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6488f44..860f92d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add infrastructure to support selection for non-reporting tools.
   Add LVM_COMMAND_PROFILE env var to set default command profile name to use.
   set CLOEXEC flag on file descriptors originating in libdaemon
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 7301956..dba97be 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -452,7 +452,101 @@ int report_for_selection(struct selection_handle *sh,
 			 struct volume_group *vg,
 			 struct logical_volume *lv)
 {
-	return 1;
+	static const char *incorrect_report_type_msg = "report_for_selection: incorrect report type";
+	int args_are_pvs = sh->orig_report_type == PVS;
+	int do_lv_info, do_lv_seg_status;
+	struct processing_handle handle = { .internal_report = 0,
+					    .selection_handle = sh,
+					    .custom_handle = NULL };
+	int r = 0;
+
+	if (!_get_final_report_type(args_are_pvs,
+				    sh->orig_report_type | sh->report_type,
+				    &do_lv_info,
+				    &do_lv_seg_status,
+				    &sh->report_type))
+		return_0;
+
+	/*
+	 * Remember:
+	 *   sh->orig_report_type is the original report type requested
+	 *   sh->report_type is the report type actually used (it counts with all types of fields used in selection)
+	 */
+	switch (sh->orig_report_type) {
+		case LVS:
+			switch (sh->report_type) {
+				case LVS:
+					r = _do_lvs_with_info_and_status_single(vg->cmd, lv, do_lv_info, do_lv_seg_status, &handle);
+					break;
+				case SEGS:
+					r = process_each_segment_in_lv(vg->cmd, lv, &handle,
+								       do_lv_info && !do_lv_seg_status ? &_segs_with_info_single :
+								       !do_lv_info && do_lv_seg_status ? &_segs_with_status_single :
+								       do_lv_info && do_lv_seg_status ? &_segs_with_info_and_status_single :
+													&_segs_single);
+					break;
+				default:
+					log_error(INTERNAL_ERROR "%s for LVS", incorrect_report_type_msg);
+					break;
+			}
+			break;
+		case VGS:
+			switch (sh->report_type) {
+				case VGS:
+					r = _vgs_single(vg->cmd, vg->name, vg, &handle);
+					break;
+				case LVS:
+					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, &handle,
+								  do_lv_info && !do_lv_seg_status ? &_lvs_with_info_single :
+								  !do_lv_info && do_lv_seg_status ? &_lvs_with_status_single :
+								  do_lv_info && do_lv_seg_status ? &_lvs_with_info_and_status_single :
+												   &_lvs_single);
+					break;
+				case SEGS:
+					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, &handle,
+								  do_lv_info && !do_lv_seg_status ? &_lvsegs_with_info_single :
+								  !do_lv_info && do_lv_seg_status ? &_lvsegs_with_status_single :
+								  do_lv_info && do_lv_seg_status ? &_lvsegs_with_info_and_status_single :
+												   &_lvsegs_single);
+					break;
+				case PVS:
+					r = process_each_pv_in_vg(vg->cmd, vg, &handle, &_pvs_single);
+					break;
+				case PVSEGS:
+					r = process_each_pv_in_vg(vg->cmd, vg, &handle,
+								  do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_single :
+								  !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_single :
+								  do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_single :
+												   &_pvsegs_single);
+					break;
+				default:
+					log_error(INTERNAL_ERROR "%s for VGS", incorrect_report_type_msg);
+					break;
+			}
+			break;
+		case PVS:
+			switch (sh->report_type) {
+				case PVS:
+					r = _pvs_single(vg->cmd, vg, pv, &handle);
+					break;
+				case PVSEGS:
+					r = process_each_segment_in_pv(vg->cmd, vg, pv, &handle,
+								       do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_sub_single :
+								       !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_sub_single :
+								       do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_sub_single :
+													&_pvsegs_sub_single);
+					break;
+				default:
+					log_error(INTERNAL_ERROR "%s for PVS", incorrect_report_type_msg);
+					break;
+			}
+			break;
+		default:
+			log_error(INTERNAL_ERROR "%s", incorrect_report_type_msg);
+			break;
+	}
+
+	return r;
 }
 
 static int _report(struct cmd_context *cmd, int argc, char **argv,


