From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:16 +0000 (UTC)
Subject: master - activation: lv_info_with_seg_status API change
Message-ID: <20161205161516.332F860243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fd20be629b6dceb96702c5f875a2e612e6f465d
Commit:        6fd20be629b6dceb96702c5f875a2e612e6f465d
Parent:        ed93f0973a307634d1266aeab5c0d2bbceab086e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 5 14:31:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:09:47 2016 +0100

activation: lv_info_with_seg_status API change

Drop LV from passed API arg - it's always segment being checked.
Also use_layer is now in full control of lv_info_with_seg_status().
It decides which device needs to be checked to get 'the most info'.

TODO: future version should be able to expose status from
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   47 +++++++++++++----------------------------------
 lib/activate/activate.h |   16 +++++-----------
 lib/metadata/lv.c       |    6 +++---
 tools/reporter.c        |   18 ++++++++----------
 5 files changed, 30 insertions(+), 58 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2b0e822..a097477 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Simplify internal lv_info_with_seg_status API.
   Decide which status is needed in one place for lv_info_with_seg_status.
   Fix matching of LV segment when checking for it info status.
   Report log_warn when status cannot be parsed.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1b1f7e4..afdf518 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -741,32 +741,24 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 }
 
 /*
- * Returns 1 if lv_seg_status structure populated,
- * else 0 on failure or if device not active locally.
- */
-int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      int use_layer, struct lv_seg_status *lv_seg_status)
-{
-	if (!activation())
-		return 0;
-
-	return _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, lv_seg_status, 0, 0);
-}
-
-/*
- * Returns 1 if lv_with_info_and_seg_status structure populated,
+ * Returns 1 if lv_with_info_and_seg_status info structure populated,
  * else 0 on failure or if device not active locally.
  *
  * When seg_status parsing had troubles it will set type to SEG_STATUS_UNKNOWN.
  *
- * This is the same as calling lv_info and lv_status,
- * but* it's done in one go with one ioctl if possible!                                                             ]
+ * Using usually one ioctl to obtain info and status.
+ * More complex segment do collect info from one device,
+ * but status from another device.
+ *
+ * TODO: further improve with more statuses (i.e. snapshot's origin/merge)
  */
-int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			    const struct lv_segment *lv_seg, int use_layer,
+int lv_info_with_seg_status(struct cmd_context *cmd,
+			    const struct lv_segment *lv_seg,
 			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead)
 {
+	const struct logical_volume *lv = status->lv = lv_seg->lv;
+
 	if (!activation())
 		return 0;
 
@@ -774,23 +766,10 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 		/* INFO is not set as cache-pool cannot be active.
 		 * STATUS is collected from cache LV */
 		lv_seg = get_only_segment_using_this_lv(lv);
-		(void) _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
+		(void) _lv_info(cmd, lv_seg->lv, 0, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
 	}
 
-	/* By default, take the first LV segment to report status for. */
-	if (!lv_seg)
-		lv_seg = first_seg(lv);
-
-	if (lv != lv_seg->lv)
-		/*
-		 * If the info is requested for an LV and segment
-		 * status for segment that belong to another LV,
-		 * we need to acquire info and status separately!
-		 */
-		return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
-			_lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
-
 	if (lv_is_thin_pool(lv)) {
 		/* Always collect status for '-tpool' */
 		if (_lv_info(cmd, lv, 1, &status->info, lv_seg, &status->seg_status, 0, 0) &&
@@ -824,7 +803,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 			 * When merge is in progress, query merging origin LV instead.
 			 * COW volume is already mapped as error target in this case.
 			 */
-			lv = origin_from_cow(lv);
+			status->lv = lv = origin_from_cow(lv);
 			lv_seg = first_seg(lv);
 			log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
 					     display_lvname(lv));
@@ -833,7 +812,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 			lv_seg = find_snapshot(lv);
 	}
 
-	return _lv_info(cmd, lv, use_layer, &status->info, lv_seg, &status->seg_status,
+	return _lv_info(cmd, lv, 0, &status->info, lv_seg, &status->seg_status,
 			with_open_count, with_read_ahead);
 }
 
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 3922d78..db8d997 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -54,11 +54,12 @@ struct lv_seg_status {
 };
 
 struct lv_with_info_and_seg_status {
-	const struct logical_volume *lv;	/* input */
 	int info_ok;
+	const struct logical_volume *lv;        /* output */
 	struct lvinfo info;			/* output */
 	int seg_part_of_lv;			/* output */
-	struct lv_seg_status seg_status;	/* input/output, see lv_seg_status */
+	struct lv_seg_status seg_status;	/* output, see lv_seg_status */
+	/* TODO: add extra status for snapshot origin */
 };
 
 struct lv_activate_opts {
@@ -133,21 +134,14 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
 /*
- * Returns 1 if lv_seg_status structure has been populated,
- * else 0 on failure or if device not active locally.
- */
-int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      int use_layer, struct lv_seg_status *lv_seg_status);
-
-/*
  * Returns 1 if lv_info_and_seg_status structure has been populated,
  * else 0 on failure or if device not active locally.
  *
  * lv_info_with_seg_status is the same as calling lv_info and then lv_status,
  * but this fn tries to do that with one ioctl if possible.
  */
-int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			    const struct lv_segment *lv_seg, int use_layer,
+int lv_info_with_seg_status(struct cmd_context *cmd,
+			    const struct lv_segment *lv_seg,
 			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead);
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index eb5066a..087b564 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -255,7 +255,7 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 		return_NULL;
 
-	if (!(status.info_ok = lv_info_with_seg_status(seg->lv->vg->cmd, seg->lv, seg, 1, &status, 0, 0)))
+	if (!(status.info_ok = lv_info_with_seg_status(seg->lv->vg->cmd, seg, &status, 0, 0)))
 		goto_bad;
 
 	ret = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, &status);
@@ -407,7 +407,7 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 			/* TODO: expose highest mapped sector */
 			p = DM_PERCENT_INVALID;
 		else {
-			seg = first_seg(lvdm->lv);
+			seg = lvdm->seg_status.seg;
 			/* Pool allocates whole chunk so round-up to nearest one */
 			csize = first_seg(seg->pool_lv)->chunk_size;
 			csize = ((seg->lv->size + csize - 1) / csize) * csize;
@@ -1318,7 +1318,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 		return_0;
 
-	if (!(status.info_ok = lv_info_with_seg_status(lv->vg->cmd, lv, first_seg(lv), 1, &status, 1, 1)))
+	if (!(status.info_ok = lv_info_with_seg_status(lv->vg->cmd, first_seg(lv), &status, 1, 1)))
 		goto_bad;
 
 	ret = lv_attr_dup_with_info_and_seg_status(mem, &status);
diff --git a/tools/reporter.c b/tools/reporter.c
index 0a9ca34..fc87c06 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -88,14 +88,13 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 }
 
 static int _do_info_and_status(struct cmd_context *cmd,
-				const struct logical_volume *lv,
 				const struct lv_segment *lv_seg,
 				struct lv_with_info_and_seg_status *status,
 				int do_info, int do_status)
 {
-	status->lv = lv;
+	status->lv = lv_seg->lv;
 
-	if (lv_is_historical(lv))
+	if (lv_is_historical(lv_seg->lv))
 		return 1;
 
 	if (do_status) {
@@ -104,13 +103,12 @@ static int _do_info_and_status(struct cmd_context *cmd,
 
 		if (do_info)
 			/* both info and status */
-			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 1, 1);
+			status->info_ok = lv_info_with_seg_status(cmd, lv_seg, status, 1, 1);
 		else
-			/* status only */
-			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 0, 0);
+			status->info_ok = lv_info_with_seg_status(cmd, lv_seg, status, 0, 0);
 	} else if (do_info)
 		/* info only */
-		status->info_ok = lv_info(cmd, lv, 0, &status->info, 1, 1);
+		status->info_ok = lv_info(cmd, status->lv, 0, &status->info, 1, 1);
 
 	return 1;
 }
@@ -126,7 +124,7 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	};
 	int r = ECMD_FAILED;
 
-	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status))
+	if (!_do_info_and_status(cmd, first_seg(lv), &status, do_info, do_status))
 		goto_out;
 
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
@@ -176,7 +174,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	};
 	int r = ECMD_FAILED;
 
-	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
+	if (!_do_info_and_status(cmd, seg, &status, do_info, do_status))
 		goto_out;
 
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
@@ -302,7 +300,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.lv = &_free_logical_volume
 	};
 
-	if (seg && !_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
+	if (seg && !_do_info_and_status(cmd, seg, &status, do_info, do_status))
 		goto_out;
 
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,


