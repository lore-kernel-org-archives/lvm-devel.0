From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:27 +0000 (UTC)
Subject: master - report: show proper info for merging origin
Message-ID: <20161222223828.01F5F611D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77997c7673bfca56f51ae4eb55a50bc76e40fe79
Commit:        77997c7673bfca56f51ae4eb55a50bc76e40fe79
Parent:        2aee4769b43a08eed549bd324664af5f406a25b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 19:51:35 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

report: show proper info for merging origin

When there is 'merging' of an origin in progress, but metadata stil
do provide both origin and snapshot, we should show data from merged
snapshot.  This is important mainly for thin case, where there was
a window, where i.e. 'lvs -o+device_id' would report information
about 'already gone' origin thin LV.

This race window is usually hard to trigger but can be ocasionally hit.
Usually shortly after activation, but before polling process manages
to update metadata after merge.
---
 WHATS_NEW        |    1 +
 tools/reporter.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dcfd85a..e5bbfe0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Report thin LV date for merged LV when the merge is in progress.
   Detect if snapshot merge really started before polling for progress.
   Checking LV for merging origin requires also it has merged snapshot.
   Extend validation of metadata processing.
diff --git a/tools/reporter.c b/tools/reporter.c
index fc87c06..6c5996b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -113,6 +113,40 @@ static int _do_info_and_status(struct cmd_context *cmd,
 	return 1;
 }
 
+/* Check if this is really merging origin.
+ * In such case, origin is gone, and user should see
+ * only data from merged snapshot. Important for thin. */
+static int _check_merging_origin(const struct logical_volume *lv,
+				 struct lv_with_info_and_seg_status *status,
+				 int *merged)
+{
+	uint32_t device_id;
+
+	*merged = 0;
+
+	switch (status->seg_status.type) {
+	case SEG_STATUS_THIN:
+		/* Get 'device_id' from active dm-table */
+		if (!lv_thin_device_id(lv, &device_id))
+			return_0;
+
+		if (lv->snapshot->device_id != device_id)
+			return 1;
+		break;
+	case SEG_STATUS_SNAPSHOT:
+		break;
+	default:
+		return 1;
+	}
+
+	/* Origin is gone */
+	log_debug_activation("Merge is progress, reporting merged LV %s.",
+			     display_lvname(lv->snapshot->lv));
+	*merged = 1;
+
+	return 1;
+}
+
 static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 					       const struct logical_volume *lv,
 					       int do_info, int do_status,
@@ -123,10 +157,22 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 		.seg_status.type = SEG_STATUS_NONE
 	};
 	int r = ECMD_FAILED;
+	int merged;
+
+	if (lv_is_merging_origin(lv))
+		/* Status is need to know which LV should be shown */
+		do_status = 1;
 
 	if (!_do_info_and_status(cmd, first_seg(lv), &status, do_info, do_status))
 		goto_out;
 
+	if (lv_is_merging_origin(lv)) {
+		if (!_check_merging_origin(lv, &status, &merged))
+		      goto_out;
+		if (merged)
+			lv = lv->snapshot->lv;
+	}
+
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
 			   lv->vg, lv, NULL, NULL, NULL, &status, NULL))
 		goto out;
@@ -173,10 +219,22 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 		.seg_status.type = SEG_STATUS_NONE
 	};
 	int r = ECMD_FAILED;
+	int merged;
+
+	if (lv_is_merging_origin(seg->lv))
+		/* Status is need to know which LV should be shown */
+		do_status = 1;
 
 	if (!_do_info_and_status(cmd, seg, &status, do_info, do_status))
 		goto_out;
 
+	if (lv_is_merging_origin(seg->lv)) {
+		if (!_check_merging_origin(seg->lv, &status, &merged))
+			goto_out;
+		if (merged)
+			seg = seg->lv->snapshot;
+	}
+
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
 			   seg->lv->vg, seg->lv, NULL, seg, NULL, &status, NULL))
 	goto_out;


