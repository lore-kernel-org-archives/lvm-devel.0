From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:12 +0100
Subject: [PATCH 08/18] Replicator: update _create_partial_dtree()
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <643ce802e8a063a7c5e0f8e0ef65e6e52e077673.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Creating partial tree for Replicator target.
Using dm_tree_set_priority() to set higher priority for Replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   98 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index de47786..d1ebfce 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -791,6 +791,98 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 	return 1;
 }
 
+/*
+ * Add devices from replicator
+ * use _add_dev_to_dtree() directly instead of _add_lv_to_dtree()
+ * no need to extend its check with  _slog, _rlog, _rimage
+ */
+static int _create_partial_replicator(struct dev_manager *dm,
+				      struct dm_tree *dtree,
+				      struct lv_segment *seg)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	struct vg_name_list *vnl;
+	const char *replicator_dlid;
+	int vg_missing = 0;
+
+	if (!lv_is_active_replicator_dev(seg->lv)) {
+		if (!_add_dev_to_dtree(dm, dtree, seg->lv->rdevice->lv,
+				       NULL))
+			return_0;
+		return 1;
+	}
+
+	/* Check and fill needed VGs */
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		if (!rsite->vg_name)
+			continue;
+
+		if (!(vnl = vg_name_list_add(dm->cmd->mem, &dm->cmd->vgs_list,
+					     rsite->vg_name)))
+			return_0;
+
+		if ((rsite->vg = vnl->vg))
+			continue;
+
+		vg_missing++;
+		log_verbose("VG %s added as missing.", rsite->vg_name);
+	}
+
+	if (vg_missing) {
+		dm->cmd->vgs_missed++;
+		log_very_verbose("Some VGs are missing, retry with them.");
+		return 0;
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
+			/* Add _slog LV */
+			if (rdev->slog &&
+			    !_add_dev_to_dtree(dm, dtree, rdev->slog, NULL))
+				return_0;
+
+			/* Resolve and add remote LV  */
+			if (rdev->rsite->vg && rdev->name &&
+			    (!(rdev->lv = find_lv(rdev->rsite->vg, rdev->name)) ||
+			     !_add_dev_to_dtree(dm, dtree, rdev->lv, NULL)))
+				return_0;
+		}
+	}
+
+	/* Add rlog and replicator devices */
+	if (first_seg(seg->replicator)->rlog_lv &&
+	    !_add_dev_to_dtree(dm, dtree, first_seg(seg->replicator)->rlog_lv,
+			       NULL))
+		return_0;
+	if (!_add_dev_to_dtree(dm, dtree, seg->replicator, NULL))
+		return_0;
+
+	/* Set suspend priority for replicator device */
+	if (!(replicator_dlid = build_dlid(dm, seg->replicator->lvid.s, NULL)))
+		return_0;
+	if (!dm_tree_set_replicator_suspend(dtree, replicator_dlid))
+		return_0;
+
+	return 1;
+}
+
 static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv)
 {
 	struct dm_tree *dtree;
@@ -811,6 +903,12 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
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
1.6.6


