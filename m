From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Nov 2014 13:30:53 +0000 (UTC)
Subject: master - cleanup: cleanup internal interface to acquire segment status
Message-ID: <20141113133053.A2CB660B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83308fdff97e242f6124858b35437ede6ee6a7e8
Commit:        83308fdff97e242f6124858b35437ede6ee6a7e8
Parent:        efe5245e47201e1947ce0bf60990a7de2151e296
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 13 11:41:49 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 13 14:28:51 2014 +0100

cleanup: cleanup internal interface to acquire segment status

 - Add separate lv_status fn (if we're interested only in seg status,
   but not lv info at the same time as it is with existing
   lv_info_with_seg_status fn). So we 3 fns:

     - lv_info (existing one, runs only info ioctl, fills in struct lvinfo only)

     - lv_status (new one, runs status ioctl, fills in struct lv_seg_status only)

     - lv_info_with_seg_status (existing one, runs status ioctl, fills
       in struct lvinfo as well as lv_seg_status)

 - Add more comments in the code explaining the difference between lv_info,
   lv_status and lv_info_with_seg_status and their return values.

 - Move decision whether lv_info_with_seg_status needs to call only
   status ioctl (in case the segment for which we require status is from
   the LV for which we require info) or separate status and info ioctl
   (in case the segment for which we require status is from different
    LV that the one for which we require info) into
   lv_info_with_seg_status fn so caller doesn't need to bother about
   this at all.

 - Cleanup internal interface for this seg status so it's more readable.
---
 lib/activate/activate.c |   54 +++++++++++++++++++++++++++++++++++++------
 lib/activate/activate.h |   21 ++++++++++++++--
 tools/reporter.c        |   58 ++++++++++++++++------------------------------
 3 files changed, 84 insertions(+), 49 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ddbebf7..60dba1b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -618,7 +618,8 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 }
 
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
-		    int use_layer, struct lvinfo *info, struct lv_seg_status *seg_status,
+		    int use_layer, struct lvinfo *info,
+		    struct lv_segment *seg, struct lv_seg_status *seg_status,
 		    int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
@@ -640,6 +641,9 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (!use_layer && lv_is_new_thin_pool(lv))
 		use_layer = 1;
 
+	if (seg_status)
+		seg_status->seg = seg;
+
 	if (!dev_manager_info(cmd->mem, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
@@ -672,7 +676,7 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	if (!activation())
 		return 0;
 
-	return _lv_info(cmd, lv, use_layer, info, NULL, with_open_count, with_read_ahead);
+	return _lv_info(cmd, lv, use_layer, info, NULL, NULL, with_open_count, with_read_ahead);
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
@@ -690,19 +694,53 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 	return r;
 }
 
+/*
+ * Returns 1 if lv_seg_status structure populated,
+ * else 0 on failure or if device not active locally.
+ */
+int lv_status(struct cmd_context *cmd, struct lv_segment *lv_seg,
+	      struct lv_seg_status *lv_seg_status)
+{
+	if (!activation())
+		return 0;
+
+	return _lv_info(cmd, lv_seg->lv, 0, NULL, lv_seg, lv_seg_status, 0, 0);
+}
+
+/*
+ * Returns 1 if lv_with_info_and_seg_status structure populated,
+ * else 0 on failure or if device not active locally.
+ *
+ * This is the same as calling lv_info and lv_status,
+ * but* it's done in one go with one ioctl if possible!
+ */
 int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			   const struct lv_segment *lv_seg, int use_layer,
-			   struct lv_with_info_and_seg_status *lvdm,
+			   struct lv_segment *lv_seg, int use_layer,
+			   struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
 			   int with_open_count, int with_read_ahead)
 {
+	int r = 0;
+
 	if (!activation())
 		return 0;
 
-	if (!_lv_info(cmd, lv, use_layer, lvdm->info, lvdm->seg_status,
-		      with_open_count, with_read_ahead))
-		return 0;
+	if (lv == lv_seg->lv) {
+		r = _lv_info(cmd, lv, use_layer, lvinfo, lv_seg, lv_seg_status,
+			     with_open_count, with_read_ahead);
+		goto out;
+	}
 
-	return 1;
+	/*
+	 * If the info is requested for an LV and segment
+	 * status for segment that belong to another LV,
+	 * we need to acquire info and status separately!
+	 */
+	return _lv_info(cmd, lv, use_layer, lvinfo, NULL, NULL, with_open_count, with_read_ahead) &&
+	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, lv_seg_status, 0, 0);
+
+	r = 1;
+out:
+	return r;
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 86c53f5..ef375bd 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -111,16 +111,31 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
 
 /*
- * Returns 1 if info structure has been populated, else 0.
+ * Returns 1 if info structure has been populated, else 0 on failure.
+ * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
  */
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead);
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
+/*
+ * Returns 1 if lv_seg_status structure has been populated,
+ * else 0 on failure or if device not active locally.
+ */
+int lv_status(struct cmd_context *cmd, struct lv_segment *lv_seg,
+	      struct lv_seg_status *lv_seg_status);
+
+/*
+ * Returns 1 if lv_info_and_seg_status structure has been populated,
+ * else 0 on failure or if device not active locally.
+ *
+ * lv_info_with_seg_status is the same as calling lv_info and then lv_seg_status,
+ * but this fn tries to do that with one ioctl if possible.
+ */
 int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			    const struct lv_segment *lv_seg, int use_layer,
-			    struct lv_with_info_and_seg_status *lvdm,
+			    struct lv_segment *lv_seg, int use_layer,
+			    struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
 			    int with_open_count, int with_read_ahead);
 
 int lv_check_not_in_use(const struct logical_volume *lv);
diff --git a/tools/reporter.c b/tools/reporter.c
index 8fe5698..65edec5b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -57,10 +57,13 @@ static void _get_lv_info_for_report(struct cmd_context *cmd,
 }
 
 static void _get_lv_info_with_segment_status_for_report(struct cmd_context *cmd,
-							struct lv_with_info_and_seg_status *lvdm)
+							struct logical_volume *lv,
+							struct lvinfo *lvinfo,
+							struct lv_segment *lv_seg,
+							struct lv_seg_status *lv_seg_status)
 {
-	if (!lv_info_with_seg_status(cmd, lvdm->seg_status->seg->lv, lvdm->seg_status->seg, 0, lvdm, 1, 1))
-		lvdm->info->exists = 0;
+	if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, lvinfo, lv_seg_status, 1, 1))
+		lvinfo->exists = 0;
 }
 
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -75,7 +78,7 @@ static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume
 	return ECMD_PROCESSED;
 }
 
-static void _choose_lv_segment_for_status_report(struct lv_with_info_and_seg_status *lvdm)
+static void _choose_lv_segment_for_status_report(struct logical_volume *lv, struct lv_segment **lv_seg)
 {
 	/*
 	 * By default, take the first LV segment to report status for.
@@ -84,46 +87,29 @@ static void _choose_lv_segment_for_status_report(struct lv_with_info_and_seg_sta
 	 * to lvdm->seg_status->seg. This is the segment whose
 	 * status line will be used for report exactly.
 	 */
-	lvdm->seg_status->seg = first_seg(lvdm->lv);
+	*lv_seg = first_seg(lv);
 }
 
 static int _lvs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
 				   void *handle)
 {
 	struct lvinfo lvinfo;
+	struct lv_segment *lv_seg;
 	struct lv_seg_status lv_seg_status = { .mem = lv->vg->vgmem,
 					       .type = SEG_STATUS_NONE,
 					       .status = NULL };
-	struct lv_with_info_and_seg_status lvdm = { .lv = lv,
-						    .seg_status = &lv_seg_status };
 	int r = ECMD_FAILED;
 
-	_choose_lv_segment_for_status_report(&lvdm);
-
-	if (lvdm.seg_status->seg->lv != lv) {
-		/*
-		 * If the info is requested on one LV and segment
-		 * status on another LV, we need to call these separately.
-		 */
-		_get_lv_info_for_report(cmd, lv, &lvinfo);
-		lvdm.info = NULL;
-		_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
-	} else {
-		/*
-		 * If the info is requested on the same LV as status,
-		 * we can get info and status in one go!
-		 */
-		lvdm.info = &lvinfo;
-		_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
-	}
+	_choose_lv_segment_for_status_report(lv, &lv_seg);
+	_get_lv_info_with_segment_status_for_report(cmd, lv, &lvinfo, lv_seg, &lv_seg_status);
 
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, lvdm.seg_status, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, &lv_seg_status, NULL))
 		goto out;
 
 	r = ECMD_PROCESSED;
 out:
-	if (lvdm.seg_status->status)
-		dm_pool_free(lvdm.seg_status->mem, lvdm.seg_status->status);
+	if (lv_seg_status.status)
+		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
 	return r;
 }
 
@@ -152,23 +138,19 @@ static int _segs_with_lv_status_single(struct cmd_context *cmd __attribute__((un
 				       struct lv_segment *seg, void *handle)
 {
 	struct lvinfo lvinfo;
-	struct lv_seg_status lv_seg_status = { .seg = seg,
-					       .mem = seg->lv->vg->vgmem,
+	struct lv_seg_status lv_seg_status = { .mem = seg->lv->vg->vgmem,
 					       .type = SEG_STATUS_NONE,
 					       .status = NULL };
-	struct lv_with_info_and_seg_status lvdm = { .lv = seg->lv,
-						    .info = &lvinfo,
-						    .seg_status = &lv_seg_status };
 	int r = ECMD_FAILED;
 
-	_get_lv_info_with_segment_status_for_report(cmd, &lvdm);
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, lvdm.info, lvdm.seg_status, NULL))
+	_get_lv_info_with_segment_status_for_report(cmd, seg->lv, &lvinfo, seg, &lv_seg_status);
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, &lv_seg_status, NULL))
 		goto_out;
 
 	r = ECMD_PROCESSED;
 out:
-	if (lvdm.seg_status->status)
-		dm_pool_free(lvdm.seg_status->mem, lvdm.seg_status->status);
+	if (lv_seg_status.status)
+		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
 	return r;
 }
 


