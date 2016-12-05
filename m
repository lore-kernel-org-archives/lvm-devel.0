From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:12 +0000 (UTC)
Subject: master - cleanup: swap test order
Message-ID: <20161205161512.118CA60238@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0089201588d65bf131d3fadd1cf5be67a562c4b1
Commit:        0089201588d65bf131d3fadd1cf5be67a562c4b1
Parent:        5ba2d58d28ace811c33e7e66b777fcca3f42149e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 30 13:43:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:05:23 2016 +0100

cleanup: swap test order

Check for lv != lvseg->lv.
Make the logic of following patches look better and easier to read.
---
 lib/activate/activate.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8fc45b7..efb8912 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -794,17 +794,17 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	if (!activation())
 		return 0;
 
-	if (lv == lv_seg->lv)
-		return _lv_info(cmd, lv, use_layer, &status->info, lv_seg, &status->seg_status,
-				with_open_count, with_read_ahead);
+	if (lv != lv_seg->lv)
+		/*
+		 * If the info is requested for an LV and segment
+		 * status for segment that belong to another LV,
+		 * we need to acquire info and status separately!
+		 */
+		return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
+			_lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
 
-	/*
-	 * If the info is requested for an LV and segment
-	 * status for segment that belong to another LV,
-	 * we need to acquire info and status separately!
-	 */
-	return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
-	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
+	return _lv_info(cmd, lv, use_layer, &status->info, lv_seg, &status->seg_status,
+			with_open_count, with_read_ahead);
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25


