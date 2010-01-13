From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:43:33 -0000
Subject: LVM2/lib/activate activate.c dev_manager.c
Message-ID: <20100113014333.6274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:43:32

Modified files:
	lib/activate   : activate.c dev_manager.c 

Log message:
	Conditionally push down either the "snapshot-origin" or
	"snapshot-merge" target based on whether the LV is a merging snapshot.
	
	When activating a snapshot-merge target do not attempt to monitor the
	LV for events; the polldaemon will monitor the snapshot as it is
	merged.
	
	Allow "snapshot-merge" target's usage to be parsed via standard
	"snapshot" methods.
	
	NOTE: follow on fixes to the _percent_run change are still needed

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/lib/activate/activate.c	2010/01/05 21:08:34	1.161
+++ LVM2/lib/activate/activate.c	2010/01/13 01:43:32	1.162
@@ -754,7 +754,7 @@
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv))
+	if (lv_is_cow(lv) && !(find_cow(lv)->status & SNAPSHOT_MERGE))
 		return monitor_dev_for_events(cmd, lv->snapshot->lv, monitor);
 
 	/*
--- LVM2/lib/activate/dev_manager.c	2010/01/07 19:54:21	1.168
+++ LVM2/lib/activate/dev_manager.c	2010/01/13 01:43:32	1.169
@@ -395,10 +395,16 @@
 			seg = dm_list_item(segh, struct lv_segment);
 		}
 
-		if (!type || !params || strcmp(type, target_type))
+                /*
+                 * If target status doesn't have 'params' or 'type' is not in the same
+                 * target base class as 'target_type' (e.g. snapshot*, mirror*) skip it
+                 * - allows the situation when 'type' is "snapshot-merge" and
+                 *   'target_type' is "snapshot"
+                 */
+		if (!type || !params || strncmp(type, target_type, strlen(target_type)))
 			continue;
 
-		if (!(segtype = get_segtype_from_string(dm->cmd, type)))
+		if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
 			continue;
 
 		if (segtype->ops->target_percent &&
@@ -890,6 +896,29 @@
 	return 1;
 }
 
+static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
+					       struct dm_tree_node *dnode,
+					       struct logical_volume *lv)
+{
+	const char *origin_dlid, *cow_dlid, *merge_dlid;
+
+	if (!(origin_dlid = build_dlid(dm, lv->lvid.s, "real")))
+		return_0;
+
+	if (!(cow_dlid = build_dlid(dm, lv->merging_snapshot->cow->lvid.s, "cow")))
+		return_0;
+
+	if (!(merge_dlid = build_dlid(dm, lv->merging_snapshot->cow->lvid.s, NULL)))
+		return_0;
+
+	if (!dm_tree_node_add_snapshot_merge_target(dnode, lv->size, origin_dlid,
+						    cow_dlid, merge_dlid,
+						    lv->merging_snapshot->chunk_size))
+		return_0;
+
+	return 1;
+}
+
 static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 					   struct dm_tree_node *dnode,
 					   struct logical_volume *lv)
@@ -904,6 +933,9 @@
 		return 0;
 	}
 
+	if (snap_seg->status & SNAPSHOT_MERGE)
+		return 1;
+
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
@@ -971,11 +1003,21 @@
 		return_0;
 
 	/* If this is a snapshot origin, add real LV */
+	/* If this is a snapshot origin w/ merging snapshot, add cow and real LV */
 	if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
 		}
+		if (seg->lv->merging_snapshot) {
+			if (!_add_new_lv_to_dtree(dm, dtree,
+			     seg->lv->merging_snapshot->cow, "cow"))
+				return_0;
+			/*
+			 * Must also add "real" LV for use when
+			 * snapshot-merge target is added
+			 */
+		}
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "real"))
 			return_0;
 	} else if (lv_is_cow(seg->lv) && !layer) {
@@ -992,8 +1034,13 @@
 
 	/* Now we've added its dependencies, we can add the target itself */
 	if (lv_is_origin(seg->lv) && !layer) {
-		if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
-			return_0;
+		if (!seg->lv->merging_snapshot) {
+			if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
+				return_0;
+		} else {
+			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, seg->lv))
+				return_0;
+		}
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv))
 			return_0;
@@ -1021,6 +1068,9 @@
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
+	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE && !layer)
+		return 1;
+
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 


