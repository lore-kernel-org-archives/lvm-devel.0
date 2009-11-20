From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:44 -0500
Subject: [PATCH 04/15] device-mapper-merge-activation
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Conditionally push down either the "snapshot-origin" or
"snapshot-merge" target based on whether the LV is a merging snapshot.

When activating a snapshot-merge target do not attempt to monitor the
LV for events; the polldaemon will monitor the snapshot as it is
merged.

Allow "snapshot-merge" target's usage to be parsed via standard
"snapshot" methods.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |   58 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7256dab..edad15d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -750,7 +750,7 @@ int monitor_dev_for_events(struct cmd_context *cmd,
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv))
+	if (lv_is_cow(lv) && !(find_cow(lv)->status & SNAPSHOT_MERGE))
 		return monitor_dev_for_events(cmd, lv->snapshot->lv, monitor);
 
 	/*
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index af05f5c..ed05f95 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -395,10 +395,16 @@ static int _percent_run(struct dev_manager *dm, const char *name,
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
@@ -876,6 +882,29 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
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
@@ -890,6 +919,9 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
+	if (snap_seg->status & SNAPSHOT_MERGE)
+		return 1;
+
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
@@ -957,11 +989,21 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
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
@@ -977,8 +1019,13 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 
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
@@ -1006,6 +1053,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
+	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE && !layer)
+		return 1;
+
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-- 
1.6.5.2


