From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:17 +0100
Subject: [PATCH 17/23] Replicator: add replicator to dtree
In-Reply-To: <1259581043-15308-17-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-13-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-14-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-15-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-16-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-17-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-18-git-send-email-zkabelac@redhat.com>
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
index 40f4df7..c9da595 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1024,6 +1024,58 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				  struct logical_volume *lv, const char *layer);
 
+/* Add all replicators' LVs from active segment */
+static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
+					       struct dm_tree *dtree,
+					       struct lv_segment *seg)
+{
+	const struct replicator_device *rdev;
+	struct replicator_site *rsite;
+
+	/* only active replicator */
+	if (!lv_is_active_replicator_dev(seg->lv)) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
+			return_0;
+		return 1;
+	}
+
+	/* activation of one replicator node activate all other nodes */
+	if (!seg->replicator ||
+	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+		return_0;
+
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (!rdev->lv || /* resolved in _partial */
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
+	/* add remaining replicator-dev nodes in the second loop
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
@@ -1054,8 +1106,14 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
+	if (seg_is_replicator_dev(seg)) {
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+			return_0;
+	} else if (seg_is_replicator(seg) && seg->rlog_lv) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->rlog_lv, NULL))
+			return_0;
 	/* If this is a snapshot origin, add real LV */
-	if (lv_is_origin(seg->lv) && !layer) {
+	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
-- 
1.6.5.3


