From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 Jan 2015 15:12:39 +0000 (UTC)
Subject: master - report: add separate LVSINFOSTATUS field type for info+status combined fields
Message-ID: <20150120151239.6F8AD60B37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=158e9988768be344c0c97acdf52d1c020ab8c83e
Commit:        158e9988768be344c0c97acdf52d1c020ab8c83e
Parent:        75b786c5ef557b690e5638b6702ad19f20cb13f1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 20 16:02:48 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 20 16:10:59 2015 +0100

report: add separate LVSINFOSTATUS field type for info+status combined fields

Add separate LVSINFOSTATUS field type for fields which display both
dm info-like and dm status-like information.

The internal interface is there with the introduction of LVSSTATUS
field type which can cope with the combination of LVSSTATUS
and LVSINFO field types (several fields).

However, till now, we considered that *single* field can display
either LVSINFO or LVSSTATUS, but not both at the same time.

Till now, we haven't had single field which needs both - hence
add LVSINFOSTATUS field type for such fields as we currently
need this for the lv_attr field which requires combination of
info and status.

This patch just adds interface for an ability to register such fields
(the code that copes with this is already in).
---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |    1 +
 lib/report/report.h  |   15 ++++++++-------
 tools/reporter.c     |   12 +++++++-----
 4 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 2b788c1..25eca80 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -38,7 +38,7 @@ FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV in
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
-FIELD(LVSINFO, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVSINFOSTATUS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
 FIELD(LVS, lv, STR_LIST, "Role", lvid, 10, lvrole, lv_role, "LV role.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 01e8f06..b3365b0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1904,6 +1904,7 @@ static const struct dm_report_object_type _report_types[] = {
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
 	{ LVSINFO, "Logical Volume Device Info", "lv_", _obj_get_lv_with_info_and_seg_status },
 	{ LVSSTATUS, "Logical Volume Device Status", "lv_", _obj_get_lv_with_info_and_seg_status },
+	{ LVSINFOSTATUS, "Logical Volume Device Info and Status Combined", "lv_", _obj_get_lv_with_info_and_seg_status },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
 	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
diff --git a/lib/report/report.h b/lib/report/report.h
index 8ff3454..563f684e18 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -24,13 +24,14 @@ typedef enum {
 	LVS		= 1,
 	LVSINFO		= 2,
 	LVSSTATUS	= 4,
-	PVS		= 8,
-	VGS		= 16,
-	SEGS		= 32,
-	SEGSSTATUS	= 64,
-	PVSEGS		= 128,
-	LABEL		= 256,
-	DEVTYPES	= 512
+	LVSINFOSTATUS   = 8,
+	PVS		= 16,
+	VGS		= 32,
+	SEGS		= 64,
+	SEGSSTATUS	= 128,
+	PVSEGS		= 256,
+	LABEL		= 512,
+	DEVTYPES	= 1024
 } report_type_t;
 
 struct field;
diff --git a/tools/reporter.c b/tools/reporter.c
index b5edfa6..29d326c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -523,17 +523,17 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		return_ECMD_FAILED;
 
 	/* Do we need to acquire LV device info in addition? */
-	lv_info_needed = (report_type & LVSINFO) ? 1 : 0;
+	lv_info_needed = (report_type & (LVSINFO | LVSINFOSTATUS)) ? 1 : 0;
 
 	/* Do we need to acquire LV device status in addition? */
-	lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS)) ? 1 : 0;
+	lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS | LVSINFOSTATUS)) ? 1 : 0;
 
 	/* Ensure options selected are compatible */
 	if (report_type & (SEGS | SEGSSTATUS))
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
-	if ((report_type & (LVS | LVSINFO | LVSSTATUS)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
+	if ((report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS)) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
@@ -541,7 +541,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	/* Change report type if fields specified makes this necessary */
 	if ((report_type & PVSEGS) ||
-	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS))))
+	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
 		report_type = PVSEGS;
 	else if ((report_type & LABEL) && (report_type & VGS))
 		report_type = PVS;
@@ -549,7 +549,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		report_type = PVS;
 	else if (report_type & (SEGS | SEGSSTATUS))
 		report_type = SEGS;
-	else if (report_type & (LVS | LVSINFO | LVSSTATUS))
+	else if (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))
 		report_type = LVS;
 
 	/*
@@ -574,6 +574,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		/* fall through */
 	case LVSSTATUS:
 		/* fall through */
+	case LVSINFOSTATUS:
+		/* fall through */
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :


