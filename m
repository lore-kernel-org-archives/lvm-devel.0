From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Feb 2015 09:11:50 +0000 (UTC)
Subject: master - toollib: select: issue an error message for failed VG/LV/PV selection
Message-ID: <20150211091150.83B8C60D7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc1bb7f8c5cd38bdebe18ebbee270882a4ee82d3
Commit:        bc1bb7f8c5cd38bdebe18ebbee270882a4ee82d3
Parent:        3505e88b18edfc60bb06ffccab8dd91f69356c2d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 11 09:36:09 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 11 09:36:09 2015 +0100

toollib: select: issue an error message for failed VG/LV/PV selection

---
 tools/toollib.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index a452676..bdf6494 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1639,8 +1639,10 @@ int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = VGS;
 
-	if (!report_for_selection(sh, NULL, vg, NULL))
-		return_0;
+	if (!report_for_selection(sh, NULL, vg, NULL)) {
+		log_error("Selection failed for VG %s.", vg->name);
+		return 0;
+	}
 
 	sh->orig_report_type = 0;
 	*selected = sh->selected;
@@ -1660,8 +1662,10 @@ int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = LVS;
 
-	if (!report_for_selection(sh, NULL, vg, lv))
-		return_0;
+	if (!report_for_selection(sh, NULL, vg, lv)) {
+		log_error("Selection failed for LV %s.", lv->name);
+		return 0;
+	}
 
 	sh->orig_report_type = 0;
 	*selected = sh->selected;
@@ -1681,8 +1685,10 @@ int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = PVS;
 
-	if (!report_for_selection(sh, pv, vg, NULL))
-		return_0;
+	if (!report_for_selection(sh, pv, vg, NULL)) {
+		log_error("Selection failed for PV %s.", dev_name(pv->dev));
+		return 0;
+	}
 
 	sh->orig_report_type = 0;
 	*selected = sh->selected;


