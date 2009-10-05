From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:35 +0200
Subject: [PATCH 08/13] Replicator: add replicator/_dev to dtree
In-Reply-To: <1254751240-17431-7-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-5-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-6-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-7-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-8-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding all replicator related LVs to dtree.
Start of one replicator_dev initiate start of all other related.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   40 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8ad737b..ce2d7bf 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -950,6 +950,38 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				  struct logical_volume *lv, const char *layer);
 
+/* Add all replicators' LVs from active segment */
+static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
+					       struct dm_tree *dtree,
+					       struct lv_segment *seg)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+
+	if (lv_is_active_replicator_dev(seg->lv)) {
+		/* activation of one replicator node activate all other nodes */
+		if (!seg->replicator ||
+		    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+			return_0;
+
+		dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+			dm_list_iterate_items(rdev, &rsite->rdevices) {
+				if (rdev->slog && !_add_new_lv_to_dtree(dm, dtree, rdev->slog, NULL))
+					return_0;
+				if (rsite->state == REPLICATOR_STATE_ACTIVE &&
+				    (!rdev->lv ||
+				     !_add_new_lv_to_dtree(dm, dtree, rdev->lv, NULL) ||
+				     !rdev->replicator_dev->lv ||
+				     !_add_new_lv_to_dtree(dm, dtree, rdev->replicator_dev->lv, NULL)))
+					return_0;
+			}
+		}
+	} else if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
+		return_0;
+
+        return 1;
+}
+
 static int _add_segment_to_dtree(struct dev_manager *dm,
 				   struct dm_tree *dtree,
 				   struct dm_tree_node *dnode,
@@ -980,8 +1012,14 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
+	if (seg_is_replicator_dev(seg)) {
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+			return_0;
+        } else if (seg_is_replicator(seg) && seg->rlog_lv) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->rlog_lv, NULL))
+			return_0;
 	/* If this is a snapshot origin, add real LV */
-	if (lv_is_origin(seg->lv) && !layer) {
+	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
-- 
1.6.5.rc2


