From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:22 +0200
Subject: [PATCH 04/11] Replace MERGING in activation
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <4dc0ab73e00126f416d10d3ef98b7dca0cd541d2.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Careful review is needed here.
Our test-suite passed correctly - but I might have missed some
code path - code is a bit tricky.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c    |    4 ++--
 lib/activate/dev_manager.c |   14 +++++++-------
 lib/snapshot/snapshot.c    |    2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 49fa3e1..4fd9c6a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -972,8 +972,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv) && !lv_is_merging_cow(lv))
-		return monitor_dev_for_events(cmd, lv->snapshot->lv, 0, monitor);
+	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv)))
+		return monitor_dev_for_events(cmd, lv->snapshot->lv, NULL, monitor);
 
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fe5e1da..53c8ac3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1260,7 +1260,7 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
 
-	if (lv_is_merging_cow(lv)) {
+	if (!laopts->no_merging && lv_is_merging_cow(lv)) {
 		/* cow is to be merged so load the error target */
 		if (!dm_tree_node_add_error_target(dnode, size))
 			return_0;
@@ -1396,7 +1396,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	} else if (lv_is_origin(seg->lv) && !layer) {
-		if (lv_is_merging_origin(seg->lv)) {
+		if (!laopts->no_merging && lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
 			     find_merging_cow(seg->lv)->cow, laopts, "cow"))
 				return_0;
@@ -1407,7 +1407,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		}
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
 			return_0;
-	} else if (lv_is_cow(seg->lv) && !layer) {
+	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
 	} else {
@@ -1421,14 +1421,14 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 
 	/* Now we've added its dependencies, we can add the target itself */
 	if (lv_is_origin(seg->lv) && !layer) {
-		if (!lv_is_merging_origin(seg->lv)) {
+		if (laopts->no_merging || !lv_is_merging_origin(seg->lv)) {
 			if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		} else {
 			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		}
-	} else if (lv_is_cow(seg->lv) && !layer) {
+	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
 		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
 			return_0;
 	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
@@ -1473,7 +1473,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
-				clear_snapshot_merge(lv);
+				laopts->no_merging = 1;
 		}
 	}
 
@@ -1522,7 +1522,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* These aren't real segments in the LVM2 metadata */
 		if (lv_is_origin(lv) && !layer)
 			break;
-		if (lv_is_cow(lv) && !layer)
+		if (!laopts->no_merging && lv_is_cow(lv) && !layer)
 			break;
 		if (max_stripe_size < seg->stripe_size * seg->area_count)
 			max_stripe_size = seg->stripe_size * seg->area_count;
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 3555f36..8c48308 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -31,7 +31,7 @@ static const char *_snap_name(const struct lv_segment *seg)
 static const char *_snap_target_name(const struct lv_segment *seg,
 				     const struct lv_activate_opts *laopts)
 {
-	if (seg->status & MERGING)
+	if (!laopts->no_merging && (seg->status & MERGING))
 		return "snapshot-merge";
 
 	return _snap_name(seg);
-- 
1.7.5.2


