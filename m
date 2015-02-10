From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:01 +0000 (UTC)
Subject: master - refactor: report: factor out code to determine final report type
Message-ID: <20150210151301.6053760C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5b345aff389af24bde7986b236a92e166435f38
Commit:        e5b345aff389af24bde7986b236a92e166435f38
Parent:        de273247118a9183eb8ba6a4615699edcb49dc2d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 1 14:04:29 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:35 2015 +0100

refactor: report: factor out code to determine final report type

The code to determine final report type based on combination of input
report type (determined from fields used for reporting to output and selection)
can be reused for pure reporting for selection - factor out this code into
_get_final_report_type function.
---
 tools/reporter.c |   71 ++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 3cba020..4e41e90 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -408,6 +408,45 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
 
+static int _get_final_report_type(int args_are_pvs,
+				  report_type_t report_type,
+				  int *lv_info_needed,
+				  int *lv_segment_status_needed,
+				  report_type_t *final_report_type)
+{
+	/* Do we need to acquire LV device info in addition? */
+	*lv_info_needed = (report_type & (LVSINFO | LVSINFOSTATUS)) ? 1 : 0;
+
+	/* Do we need to acquire LV device status in addition? */
+	*lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS | LVSINFOSTATUS)) ? 1 : 0;
+
+	/* Ensure options selected are compatible */
+	if (report_type & (SEGS | SEGSSTATUS))
+		report_type |= LVS;
+	if (report_type & PVSEGS)
+		report_type |= PVS;
+	if ((report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS)) &&
+	    (report_type & (PVS | LABEL)) && !args_are_pvs) {
+		log_error("Can't report LV and PV fields at the same time");
+		return 0;
+	}
+
+	/* Change report type if fields specified makes this necessary */
+	if ((report_type & PVSEGS) ||
+	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
+		report_type = PVSEGS;
+	else if ((report_type & PVS) ||
+		 ((report_type & LABEL) && (report_type & VGS)))
+		report_type = PVS;
+	else if (report_type & (SEGS | SEGSSTATUS))
+		report_type = SEGS;
+	else if (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))
+		report_type = LVS;
+
+	*final_report_type = report_type;
+	return 1;
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
@@ -419,7 +458,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
-	unsigned args_are_pvs, lv_info_needed, lv_segment_status_needed;
+	unsigned args_are_pvs;
+	int lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
@@ -538,35 +578,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					  columns_as_rows, selection)))
 		return_ECMD_FAILED;
 
-	/* Do we need to acquire LV device info in addition? */
-	lv_info_needed = (report_type & (LVSINFO | LVSINFOSTATUS)) ? 1 : 0;
-
-	/* Do we need to acquire LV device status in addition? */
-	lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS | LVSINFOSTATUS)) ? 1 : 0;
-
-	/* Ensure options selected are compatible */
-	if (report_type & (SEGS | SEGSSTATUS))
-		report_type |= LVS;
-	if (report_type & PVSEGS)
-		report_type |= PVS;
-	if ((report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
-		log_error("Can't report LV and PV fields at the same time");
+	if (!_get_final_report_type(args_are_pvs,
+				    report_type, &lv_info_needed,
+				    &lv_segment_status_needed,
+				    &report_type)) {
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
 	}
 
-	/* Change report type if fields specified makes this necessary */
-	if ((report_type & PVSEGS) ||
-	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
-		report_type = PVSEGS;
-	else if ((report_type & PVS) ||
-		 ((report_type & LABEL) && (report_type & VGS)))
-		report_type = PVS;
-	else if (report_type & (SEGS | SEGSSTATUS))
-		report_type = SEGS;
-	else if (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))
-		report_type = LVS;
-
 	/*
 	 * We lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.


