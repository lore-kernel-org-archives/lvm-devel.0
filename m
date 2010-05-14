From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:14 +0200
Subject: [PATCH 19/23] Replicator: add replicator to dtree
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <e6aa986e0a21b3c61f77378308c8010dea60c58f.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding all replicator related LVs to dtree.
Start of one replicator_dev initiate start of all other related.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   60 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8acb5fa..18b1809 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1195,6 +1195,61 @@ static int _add_target_to_dtree(struct dev_manager *dm,
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
+	/* Only active replicator */
+	if (!lv_is_active_replicator_dev(seg->lv)) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
+			return_0;
+		return 1;
+	}
+
+	/* Add rlog and replicator nodes */
+	if (!seg->replicator ||
+            !first_seg(seg->replicator)->rlog_lv ||
+	    !_add_new_lv_to_dtree(dm, dtree,
+				  first_seg(seg->replicator)->rlog_lv, NULL) ||
+	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+	    return_0;
+
+	/* Activation of one replicator_dev node activates all other nodes */
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->lv &&
+			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv, NULL))
+				return_0;
+
+			if (rdev->slog &&
+			    !_add_new_lv_to_dtree(dm, dtree,
+						  rdev->slog, NULL))
+				return_0;
+		}
+	}
+	/* Add remaining replicator-dev nodes in the second loop
+	 * to avoid multiple retries for inserting all elements */
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		if (rsite->state != REPLICATOR_STATE_ACTIVE)
+			continue;
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->replicator_dev->lv == seg->lv)
+				continue;
+			if (!rdev->replicator_dev->lv ||
+			    !_add_new_lv_to_dtree(dm, dtree,
+						  rdev->replicator_dev->lv,
+						  NULL))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
 static int _add_segment_to_dtree(struct dev_manager *dm,
 				   struct dm_tree *dtree,
 				   struct dm_tree_node *dnode,
@@ -1225,9 +1280,12 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
+	if (seg_is_replicator_dev(seg)) {
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+			return_0;
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
-	if (lv_is_origin(seg->lv) && !layer) {
+	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
-- 
1.7.0.1


