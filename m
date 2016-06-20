From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 12:06:17 +0000 (UTC)
Subject: master - report: compare --configreport value with basic report type
Message-ID: <20160620120617.BF72A60F60@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db6b4c1eef733769a3ca9f2f01c29c77cf83cc24
Commit:        db6b4c1eef733769a3ca9f2f01c29c77cf83cc24
Parent:        2593cab5c4f6cd05edab521b0ae997077790234b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 13:15:33 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 14:04:37 2016 +0200

report: compare --configreport value with basic report type

Reporting commands can be of different types (even if the command name
is the same):
  - pvs command can be either of PVS, PVSEGS or LABEL report type,
  - vgs command is of VGS report type,
  - lvs command is of LVS or SEGS report type.

Use basic report type when looking for report prefix used for
--configreport option.

This means that:
  - 'pvs --configreport pv' applies to PVS, PVSEGS or LABEL report type
  - 'vgs --configreport vg' applies to VGS report type
  - 'lvs --configreport lv' applies to LVS and SEGS report type
---
 tools/reporter.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index c7dee20..8d213cd 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -747,6 +747,14 @@ static report_idx_t _get_report_idx_from_name(report_type_t report_type, const c
 	if (!name || !*name)
 		return REPORT_IDX_NULL;
 
+	/* Change to basic report type for comparison. */
+	if (report_type == LABEL)
+		report_type = PVS;
+	else if (report_type == SEGS)
+		report_type = LVS;
+	else if (report_type == PVSEGS)
+		report_type = PVSEGS;
+
 	if (!strcasecmp(name, "log"))
 		idx = REPORT_IDX_LOG;
 	else if (!strcasecmp(name, "vg"))
@@ -755,10 +763,12 @@ static report_idx_t _get_report_idx_from_name(report_type_t report_type, const c
 		idx = _get_report_idx(report_type, PVS);
 	else if (!strcasecmp(name, "lv"))
 		idx = _get_report_idx(report_type, LVS);
-	else if (!strcasecmp(name, "pvseg"))
-		idx = _get_report_idx(report_type, PVSEGS);
-	else if (!strcasecmp(name, "seg"))
-		idx = _get_report_idx(report_type, SEGS);
+	else if (!strcasecmp(name, "pvseg")) {
+		idx = (report_type == FULL) ? _get_report_idx(report_type, PVSEGS)
+					    : _get_report_idx(report_type, PVS);
+	} else if (!strcasecmp(name, "seg"))
+		idx = (report_type == FULL) ? _get_report_idx(report_type, SEGS)
+					    : _get_report_idx(report_type, LVS);
 	else {
 		idx = REPORT_IDX_NULL;
 		log_error("Unknonwn report specifier in "


