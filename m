From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  8 Apr 2016 12:23:42 +0000 (UTC)
Subject: master - report: remove superfluous SEGSSTATUS report type
Message-ID: <20160408122342.156F160E0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed0c779bd120e7c36cb7f100df3c6edc98e8cc52
Commit:        ed0c779bd120e7c36cb7f100df3c6edc98e8cc52
Parent:        50866034a2e612250c45116674765da08820fb27
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 8 14:18:00 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 8 14:21:47 2016 +0200

report: remove superfluous SEGSSTATUS report type

We don't have any report field of this type yet. Return this patch into
the play if we really need that. Currenly we always report status
(result of "status" dm ioctl) for an LV as a whole where we choose
segment which represents the LV, not calling status for each possible
segment it contains - we don't need this now so I'm removing it to
not make the code more complex uselessly.
---
 lib/report/report.c |    1 -
 lib/report/report.h |    7 +++----
 tools/reporter.c    |    8 +++-----
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 5009ecc..08a6097 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3667,7 +3667,6 @@ static const struct dm_report_object_type _report_types[] = {
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
 	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
-	{ SEGSSTATUS, "Logical Volume Device Segment Status", "seg_", _obj_get_lv_with_info_and_seg_status },
 	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
 	{ 0, "", "", NULL },
 };
diff --git a/lib/report/report.h b/lib/report/report.h
index 182f294..088a1ca 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -28,10 +28,9 @@ typedef enum {
 	PVS		= 16,
 	VGS		= 32,
 	SEGS		= 64,
-	SEGSSTATUS	= 128,
-	PVSEGS		= 256,
-	LABEL		= 512,
-	DEVTYPES	= 1024
+	PVSEGS		= 128,
+	LABEL		= 256,
+	DEVTYPES	= 512
 } report_type_t;
 
 /*
diff --git a/tools/reporter.c b/tools/reporter.c
index 220e307..a4cae60 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -409,10 +409,10 @@ static int _get_final_report_type(int args_are_pvs,
 	*lv_info_needed = (report_type & (LVSINFO | LVSINFOSTATUS)) ? 1 : 0;
 
 	/* Do we need to acquire LV device status in addition? */
-	*lv_segment_status_needed = (report_type & (SEGSSTATUS | LVSSTATUS | LVSINFOSTATUS)) ? 1 : 0;
+	*lv_segment_status_needed = (report_type & (LVSSTATUS | LVSINFOSTATUS)) ? 1 : 0;
 
 	/* Ensure options selected are compatible */
-	if (report_type & (SEGS | SEGSSTATUS))
+	if (report_type & SEGS)
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
@@ -429,7 +429,7 @@ static int _get_final_report_type(int args_are_pvs,
 	else if ((report_type & PVS) ||
 		 ((report_type & LABEL) && (report_type & VGS)))
 		report_type = PVS;
-	else if (report_type & (SEGS | SEGSSTATUS))
+	else if (report_type & SEGS)
 		report_type = SEGS;
 	else if (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))
 		report_type = LVS;
@@ -907,8 +907,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_vg(cmd, argc, argv, NULL, 0,
 					    handle, &_pvs_in_vg);
 		break;
-	case SEGSSTATUS:
-		/* fall through */
 	case SEGS:
 		r = process_each_lv(cmd, argc, argv, 0, handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :


