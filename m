From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:12 +0200
Subject: [PATCH 17/23] Replicator: update _create_partial_dtree()
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <8a40de9704d32b741f8934a429fc862c1b06560d.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding function _add_partial_replicator_to_dtree() to create
partial tree for Replicator target.

Using dm_tree_node_set_presuspend() for Replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   78 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2846175..8acb5fa 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -865,6 +865,80 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 }
 
 /*
+ * Add replicator devices
+ *
+ * Using _add_dev_to_dtree() directly instead of _add_lv_to_dtree()
+ * to avoid extra checks with extensions.
+ */
+static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
+					    struct dm_tree *dtree,
+					    struct logical_volume *lv)
+{
+	struct logical_volume *rlv = first_seg(lv)->replicator;
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	struct dm_tree_node *rep_node, *rdev_node;
+	const char *uuid;
+
+	if (!lv_is_active_replicator_dev(lv)) {
+		if (!_add_dev_to_dtree(dm, dtree, lv->rdevice->lv,
+				      NULL))
+			return_0;
+		return 1;
+	}
+
+	/* Add _rlog and replicator device */
+	if (!_add_dev_to_dtree(dm, dtree, first_seg(rlv)->rlog_lv, NULL))
+		return_0;
+
+	if (!_add_dev_to_dtree(dm, dtree, rlv, NULL))
+		return_0;
+
+	if (!(uuid = build_dm_uuid(dm->mem, rlv->lvid.s, NULL)))
+		return_0;
+
+	rep_node = dm_tree_find_node_by_uuid(dtree, uuid);
+
+	/* Add all related devs for replicator */
+	dm_list_iterate_items(rsite, &rlv->rsites)
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rsite->state == REPLICATOR_STATE_ACTIVE) {
+				/* Add _rimage LV */
+				if (!_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
+					return_0;
+
+				/* Add replicator-dev LV, except of the already added one */
+				if ((lv != rdev->replicator_dev->lv) &&
+				    !_add_dev_to_dtree(dm, dtree,
+						       rdev->replicator_dev->lv, NULL))
+					return_0;
+
+				if (rep_node) {
+					if (!(uuid = build_dm_uuid(dm->mem,
+								   rdev->replicator_dev->lv->lvid.s,
+								   NULL)))
+						return_0;
+					/* Set presuspend node for replicator device */
+					if ((rdev_node = dm_tree_find_node_by_uuid(dtree, uuid)))
+						dm_tree_node_set_presuspend(rdev_node, rep_node);
+				}
+			}
+
+			if (!rdev->rsite->vg_name)
+				continue;
+
+			if (!_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
+				return_0;
+
+			if (rdev->slog &&
+			    !_add_dev_to_dtree(dm, dtree, rdev->slog, NULL))
+				return_0;
+		}
+
+	return 1;
+}
+
+/*
  * Add LV and any known dependencies
  */
 static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv)
@@ -883,6 +957,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
+	if (lv_is_replicator_dev(lv) &&
+	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
+		return_0;
+
 	return 1;
 }
 
-- 
1.7.0.1


