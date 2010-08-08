From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:29 +0200
Subject: [PATCH 17/25] Replicator: update of dev_manager.c
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <b2b1f9f28872b18a21df467c4271d08ab80a602f.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change related to replicator-dev to replicated switch.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9b27616..a4dc651 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -927,7 +927,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 }
 
 /*
- * Add replicator devices
+ * Add replicated devices
  *
  * Using _add_dev_to_dtree() directly instead of _add_lv_to_dtree()
  * to avoid extra checks with extensions.
@@ -937,19 +937,19 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 					    struct logical_volume *lv)
 {
 	struct logical_volume *rlv = first_seg(lv)->replicator;
-	struct replicator_device *rdev;
+	struct replicated_device *rdev;
 	struct replicator_site *rsite;
 	struct dm_tree_node *rep_node, *rdev_node;
 	const char *uuid;
 
-	if (!lv_is_active_replicator_dev(lv)) {
+	if (!lv_is_active_replicated(lv)) {
 		if (!_add_dev_to_dtree(dm, dtree, lv->rdevice->lv,
 				      NULL))
 			return_0;
 		return 1;
 	}
 
-	/* Add _rlog and replicator device */
+	/* Add _rlog and replicated device */
 	if (!_add_dev_to_dtree(dm, dtree, first_seg(rlv)->rlog_lv, NULL))
 		return_0;
 
@@ -969,16 +969,16 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 				if (!_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
 					return_0;
 
-				/* Add replicator-dev LV, except of the already added one */
-				if ((lv != rdev->replicator_dev->lv) &&
+				/* Add replicated LV, except of the already added one */
+				if ((lv != rdev->replicated_seg->lv) &&
 				    !_add_dev_to_dtree(dm, dtree,
-						       rdev->replicator_dev->lv, NULL))
+						       rdev->replicated_seg->lv, NULL))
 					return_0;
 
 				/* If replicator exists - try connect existing heads */
 				if (rep_node) {
 					uuid = build_dm_uuid(dm->mem,
-							     rdev->replicator_dev->lv->lvid.s,
+							     rdev->replicated_seg->lv->lvid.s,
 							     NULL);
 					if (!uuid)
 						return_0;
@@ -1024,7 +1024,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 		return_0;
 
 	/* Adding LV head of replicator adds all other related devs */
-	if (lv_is_replicator_dev(lv) &&
+	if (lv_is_replicated(lv) &&
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
 		return_0;
 
@@ -1263,15 +1263,15 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				  struct logical_volume *lv, const char *layer);
 
 /* Add all replicators' LVs */
-static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
+static int _add_replicated_seg_target_to_dtree(struct dev_manager *dm,
 					       struct dm_tree *dtree,
 					       struct lv_segment *seg)
 {
-	struct replicator_device *rdev;
+	struct replicated_device *rdev;
 	struct replicator_site *rsite;
 
 	/* For inactive replicator add linear mapping */
-	if (!lv_is_active_replicator_dev(seg->lv)) {
+	if (!lv_is_active_replicated(seg->lv)) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
 			return_0;
 		return 1;
@@ -1285,7 +1285,7 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
 	    return_0;
 
-	/* Activation of one replicator_dev node activates all other nodes */
+	/* Activation of one replicated node activates all other nodes */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
 			if (rdev->lv &&
@@ -1298,17 +1298,17 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 				return_0;
 		}
 	}
-	/* Add remaining replicator-dev nodes in the second loop
+	/* Add remaining replicated nodes in the second loop
 	 * to avoid multiple retries for inserting all elements */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
 		if (rsite->state != REPLICATOR_STATE_ACTIVE)
 			continue;
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rdev->replicator_dev->lv == seg->lv)
+			if (rdev->replicated_seg->lv == seg->lv)
 				continue;
-			if (!rdev->replicator_dev->lv ||
+			if (!rdev->replicated_seg->lv ||
 			    !_add_new_lv_to_dtree(dm, dtree,
-						  rdev->replicator_dev->lv,
+						  rdev->replicated_seg->lv,
 						  NULL))
 				return_0;
 		}
@@ -1347,8 +1347,8 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
-	if (seg_is_replicator_dev(seg)) {
-		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+	if (seg_is_replicated(seg)) {
+		if (!_add_replicated_seg_target_to_dtree(dm, dtree, seg))
 			return_0;
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
-- 
1.7.2.1


