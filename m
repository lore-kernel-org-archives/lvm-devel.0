From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:03:01 +0000 (UTC)
Subject: master - report: update report_object API
Message-ID: <20150120140301.D524160D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae8b9baa04d8d24133ec7a2e80762ae5c7b6490f
Commit:        ae8b9baa04d8d24133ec7a2e80762ae5c7b6490f
Parent:        b3a348c03c67b490ad1a8517168454dc6d5563da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 13:16:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 14:58:43 2015 +0100

report: update report_object API

Internal API change - pass single struct for both info & seg_status.
---
 lib/activate/activate.c |    6 +++---
 lib/activate/activate.h |    2 +-
 lib/report/report.h     |    2 +-
 lib/report/values.h     |    1 +
 tools/reporter.c        |   32 +++++++++++++++++---------------
 5 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ed41058..20c7c98 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -246,7 +246,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	return 0;
 }
 int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      struct lv_seg_status *lv_seg_status)
+	      int use_layer, struct lv_seg_status *lv_seg_status)
 {
 	return 0;
 }
@@ -716,12 +716,12 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
  * else 0 on failure or if device not active locally.
  */
 int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      struct lv_seg_status *lv_seg_status)
+	      int use_layer, struct lv_seg_status *lv_seg_status)
 {
 	if (!activation())
 		return 0;
 
-	return _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, lv_seg_status, 0, 0);
+	return _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, lv_seg_status, 0, 0);
 }
 
 /*
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 306ebd8..01d6444 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -132,7 +132,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
  * else 0 on failure or if device not active locally.
  */
 int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      struct lv_seg_status *lv_seg_status);
+	      int use_layer, struct lv_seg_status *lv_seg_status);
 
 /*
  * Returns 1 if lv_info_and_seg_status structure has been populated,
diff --git a/lib/report/report.h b/lib/report/report.h
index a8e7405..8ff3454 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -47,7 +47,7 @@ void report_free(void *handle);
 int report_object(void *handle, const struct volume_group *vg,
 		  const struct logical_volume *lv, const struct physical_volume *pv,
 		  const struct lv_segment *seg, const struct pv_segment *pvseg,
-		  const struct lvinfo *lvinfo, const struct lv_seg_status *lv_seg_status,
+		  const struct lv_with_info_and_seg_status *lvdm,
 		  const struct label *label);
 int report_devtypes(void *handle);
 int report_output(void *handle);
diff --git a/lib/report/values.h b/lib/report/values.h
index 4323c17..2b2a4d3 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -88,6 +88,7 @@ FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_V
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(lv_health_status, health_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */
diff --git a/tools/reporter.c b/tools/reporter.c
index 6c278cb..b5edfa6 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -31,7 +31,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -83,7 +83,9 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 					       int do_info, int do_status,
 					       void *handle)
 {
-	struct lv_with_info_and_seg_status status;
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE
+	};
 	int r = ECMD_FAILED;
 
 	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status)) {
@@ -92,9 +94,7 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	}
 
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL,
-			   do_info ? &status.info : NULL,
-			   do_status ? &status.seg_status : NULL,
-			   NULL))
+			   &status, NULL))
 		goto_out;
 
 	r = ECMD_PROCESSED;
@@ -134,7 +134,9 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 						int do_info, int do_status,
 						void *handle)
 {
-	struct lv_with_info_and_seg_status status;
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE
+	};
 	int r = ECMD_FAILED;
 
 	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status)) {
@@ -143,9 +145,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	}
 
 	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
-			   do_info ? &status.info : NULL,
-			   do_status ? &status.seg_status : NULL,
-			   NULL))
+			   &status, NULL))
 		goto_out;
 
 	r = ECMD_PROCESSED;
@@ -225,9 +225,6 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
-	struct lv_with_info_and_seg_status status = {
-		.seg_status.type = SEG_STATUS_NONE
-	};
 
 	struct segment_type _freeseg_type = {
 		.name = "free",
@@ -262,11 +259,16 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.origin_list = DM_LIST_HEAD_INIT(_free_lv_segment.origin_list),
 	};
 
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE,
+		.lv = &_free_logical_volume
+	};
+
 	if (seg)
 		_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, &status.info, &status.seg_status,
+			   seg ? : &_free_lv_segment, pvseg, &status,
 			   pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
@@ -346,7 +348,7 @@ static int _pvsegs_with_lv_info_and_status_single(struct cmd_context *cmd,
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -355,7 +357,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 static int _label_single(struct cmd_context *cmd, struct label *label,
 		         void *handle)
 {
-	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, NULL, label))
+	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


