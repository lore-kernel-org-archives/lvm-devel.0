From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:15 +0100
Subject: [PATCH 11/18] Replicator: add replicator to dtree
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <3a74428d3dc69ca1082a824b0d4c2787bbdbcfbd.1263389894.git.zkabelac@redhat.com>
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
index d1ebfce..8a24a96 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1118,6 +1118,58 @@ static int _add_target_to_dtree(struct dev_manager *dm,
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
+	/* Activation of one replicator node activate all other nodes */
+	if (!seg->replicator ||
+	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+		return_0;
+
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (!rdev->lv || /* Resolved in _partial */
+			    !_add_new_lv_to_dtree(dm, dtree,
+						  rdev->lv, NULL))
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
@@ -1148,9 +1200,15 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
+	if (seg_is_replicator_dev(seg)) {
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+			return_0;
+	} else if (seg_is_replicator(seg) && seg->rlog_lv) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->rlog_lv, NULL))
+			return_0;
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin w/ merging snapshot, add cow and real LV */
-	if (lv_is_origin(seg->lv) && !layer) {
+	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
-- 
1.6.6


