From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 11 Jul 2014 08:42:14 +0000 (UTC)
Subject: master - report: display 'unknown' value for LVSINFO fields if unable to get info
Message-ID: <20140711084214.1068760E10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52af0dfbc0ebc442d3f1163e944e9ad88d05d46e
Commit:        52af0dfbc0ebc442d3f1163e944e9ad88d05d46e
Parent:        f33d75e2e586a88ddeb20d860765f091098b8ab5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 11 10:18:59 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 11 10:18:59 2014 +0200

report: display 'unknown' value for LVSINFO fields if unable to get info

If the lv_info call fails for whatever reason/INFO dm ioctl fails or
the dm driver communication is disabled (--driverloaded n), make
sure we always display "unknown" for LVSINFO fields as that's exactly
what happens - we don't know the state.

Before the patch:

$ lvs -o name,device_open --driverloaded n
  WARNING: Activation disabled. No device-mapper interaction will be attempted.
  Command failed with status code 5.

With this patch applied:

$ lvs -o name,device_open --driverloaded n
  WARNING: Activation disabled. No device-mapper interaction will be attempted.
  LV        DevOpen
  lvol1        unknown
---
 lib/report/report.c |    4 +++-
 tools/reporter.c    |   22 +++++++++++++---------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index d193c47..061e39e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1394,7 +1394,9 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (!(lvi->lv->status & PVMOVE)) {
 		if (lvi->lv->status & LVM_WRITE) {
-			if (lvi->info->read_only)
+			if (!lvi->info->exists)
+				perms = _str_unknown;
+			else if (lvi->info->read_only)
 				perms = FIRST_NAME(lv_permissions_r_override);
 			else
 				perms = FIRST_NAME(lv_permissions_rw);
diff --git a/tools/reporter.c b/tools/reporter.c
index 0780283..462ca8a 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -48,14 +48,20 @@ static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return ECMD_PROCESSED;
 }
 
+static void _get_lv_info_for_report(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct lvinfo *lvinfo)
+{
+	if (!lv_info(cmd, lv, 0, lvinfo, 1, 1))
+		lvinfo->exists = 0;
+}
+
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
 				 void *handle)
 {
 	struct lvinfo lvinfo;
 
-	if (!lv_info(cmd, lv, 0, &lvinfo, 1, 1))
-		return_ECMD_FAILED;
-
+	_get_lv_info_for_report(cmd, lv, &lvinfo);
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, NULL))
 		return_ECMD_FAILED;
 
@@ -76,8 +82,8 @@ static int _segs_with_lv_info_single(struct cmd_context *cmd __attribute__((unus
 {
 	struct lvinfo lvinfo;
 
-	if (!lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1) ||
-	    !report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL))
+	_get_lv_info_for_report(cmd, seg->lv, &lvinfo);
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -137,10 +143,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	lvinfo.exists = 0;
-	if (seg && lv_info_needed && !lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1)) {
-		ret = ECMD_FAILED;
-		goto_out;
-	}
+	if (seg && lv_info_needed)
+	    _get_lv_info_for_report(cmd, seg->lv, &lvinfo);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg, &lvinfo, pv_label(pvseg->pv))) {


