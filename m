From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:36:13 +0200
Subject: [PATCH 17/23] Replicator: update _create_partial_dtree()
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <5e6cdba13b191bc40f40fe95aa9208994ddf9526.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding function _create_partial_replicator() to create
partial tree for Replicator target.

Using dm_tree_set_suspend_priority() for Replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   76 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d52d46f..9913aae 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -869,6 +869,76 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 	return 1;
 }
 
+/*
+ * Add replicator devices
+ *
+ * Using _add_dev_to_dtree() directly instead of _add_lv_to_dtree()
+ * to avoid checks with extensions.
+ */
+static int _create_partial_replicator(struct dev_manager *dm,
+				      struct dm_tree *dtree,
+				      struct lv_segment *seg)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	const char *replicator_dlid;
+
+	if (!lv_is_active_replicator_dev(seg->lv)) {
+		if (!_add_dev_to_dtree(dm, dtree, seg->lv->rdevice->lv,
+				       NULL))
+			return_0;
+		return 1;
+	}
+
+	/* Add all related devs for replicator */
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rsite->state == REPLICATOR_STATE_ACTIVE) {
+				/* Add _rimage LV */
+				if (rdev->lv &&
+				    !_add_dev_to_dtree(dm, dtree,
+						       rdev->lv, NULL))
+					return_0;
+
+				/* Add replicator-dev LV */
+				if (seg->lv != rdev->replicator_dev->lv &&
+				    !_add_dev_to_dtree(dm, dtree,
+						       rdev->replicator_dev->lv,
+						       NULL))
+					return_0;
+			}
+
+			if (!rdev->rsite->vg_name)
+				continue;
+
+			if (rdev->lv &&
+			    !_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
+				return_0;
+
+			if (rdev->slog &&
+			    !_add_dev_to_dtree(dm, dtree, rdev->slog, NULL))
+				return_0;
+
+		}
+	}
+
+	/* Add rlog and replicator devices */
+	if (first_seg(seg->replicator)->rlog_lv &&
+	    !_add_dev_to_dtree(dm, dtree,
+			       first_seg(seg->replicator)->rlog_lv, NULL))
+		return_0;
+	if (!_add_dev_to_dtree(dm, dtree, seg->replicator, NULL))
+		return_0;
+
+	/* Set suspend priority for replicator device */
+	if (!(replicator_dlid = build_dm_uuid(dm->mem, seg->replicator->lvid.s, NULL)))
+		return_0;
+	if (!dm_tree_set_suspend_priority(dtree, replicator_dlid, 1))
+		return_0;
+
+	return 1;
+}
+
 static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv)
 {
 	struct dm_tree *dtree;
@@ -889,6 +959,12 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 		if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow))
 			goto_bad;
 
+	/* Add any replicator-dev LVs of this LV */
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg_is_replicator_dev(seg) &&
+		    !_create_partial_replicator(dm, dtree, seg))
+			goto_bad;
+
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
-- 
1.7.0.1


