From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 May 2010 09:01:06 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100524090106.7042.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-24 09:01:05

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Replicator: add replicator to dtree
	
	Adding all replicator related LVs to dtree.
	Start of one replicator_dev initiate start of all other related.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1592&r2=1.1593
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193

--- LVM2/WHATS_NEW	2010/05/24 08:59:29	1.1592
+++ LVM2/WHATS_NEW	2010/05/24 09:01:05	1.1593
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Add Replicators' LVs to dtree for activation.
   Avoid print activation message if there is a missing VG (Replicator).
   Fixed scripts/relpath.awk to work in mawk
   Add _add_partial_replicator_to_dtree().
--- LVM2/lib/activate/dev_manager.c	2010/05/21 14:47:59	1.192
+++ LVM2/lib/activate/dev_manager.c	2010/05/24 09:01:05	1.193
@@ -1200,6 +1200,61 @@
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				  struct logical_volume *lv, const char *layer);
 
+/* Add all replicators' LVs */
+static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
+					       struct dm_tree *dtree,
+					       struct lv_segment *seg)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+
+	/* For inactive replicator add linear mapping */
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
@@ -1230,9 +1285,12 @@
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


