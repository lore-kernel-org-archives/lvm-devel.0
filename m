From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:47:59 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100521144759.3751.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:47:59

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Replicator: update _create_partial_dtree()
	
	Adding function _add_partial_replicator_to_dtree() to create
	partial tree for Replicator target.
	
	Using dm_tree_node_set_presuspend_node() for Replicator.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1589&r2=1.1590
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192

--- LVM2/WHATS_NEW	2010/05/21 14:34:01	1.1589
+++ LVM2/WHATS_NEW	2010/05/21 14:47:58	1.1590
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Add _add_partial_replicator_to_dtree().
   Activation code read and releases also remote VGs (Replicator).
   Check for missing VGs before taking lock_vol (Replicator).
   Update process_each_lv_in_vg() to use cmd_vg structure.
--- LVM2/lib/activate/dev_manager.c	2010/05/14 12:39:52	1.191
+++ LVM2/lib/activate/dev_manager.c	2010/05/21 14:47:59	1.192
@@ -865,6 +865,84 @@
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
+	/* Add all related devices for replicator */
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
+				/* If replicator exists - try connect existing heads */
+				if (rep_node) {
+					uuid = build_dm_uuid(dm->mem,
+							     rdev->replicator_dev->lv->lvid.s,
+							     NULL);
+					if (!uuid)
+						return_0;
+
+					rdev_node = dm_tree_find_node_by_uuid(dtree, uuid);
+					if (rdev_node)
+						dm_tree_node_set_presuspend_node(rdev_node,
+										 rep_node);
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
@@ -883,6 +961,11 @@
 	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
+	/* Adding LV head of replicator adds all other related devs */
+	if (lv_is_replicator_dev(lv) &&
+	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
+		return_0;
+
 	return 1;
 }
 


