From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:53 +0000 (UTC)
Subject: master - activation: simplify activation code
Message-ID: <20130223094153.CF1F040A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3679bb1cd9f48a0dc4a557ad1c3c3b3713e840bf
Commit:        3679bb1cd9f48a0dc4a557ad1c3c3b3713e840bf
Parent:        0631d233d84cc451380155b8062bd37c6f22c2f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 21 10:39:47 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:30:03 2013 +0100

activation: simplify activation code

Reorder activation code to look similar for preload tree and
activation tree.

Its also give much better suppport for device stacking,
since now we also support activation of snapshot which might
be then used for other devices.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.h    |    1 -
 lib/activate/dev_manager.c |  249 +++++++++++++++++++++-----------------------
 lib/thin/thin.c            |   15 ---
 4 files changed, 121 insertions(+), 145 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 68baaf1..273f152 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Improve activation code for better support of stacked devices.
   Add _add_layer_target_to_dtree() for adding linear layer into dtree.
   Extend _cached_info() to accept layer string.
   Allow identical table reload for RAID to restore transiently failed PVs.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index df4120c..bf1f7a0 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -34,7 +34,6 @@ struct lv_activate_opts {
 	int exclusive;
 	int origin_only;
 	int no_merging;
-	int real_pool;
 	int send_messages;
 	int skip_in_use;
 	unsigned revert;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5f0457b..5ce099e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1556,6 +1556,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 {
 	uint32_t s;
 	struct seg_list *sl;
+	struct dm_list *snh;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_tree_node *thin_node;
 	const char *uuid;
@@ -1570,14 +1571,34 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if ((lv->status & MIRRORED) && seg->log_lv &&
-	    !_add_dev_to_dtree(dm, dtree, seg->log_lv, NULL))
-		return_0;
+	if (origin_only && lv_is_thin_volume(lv)) {
+		if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+			return_0;
+#if 0
+		/* ? Use origin_only to avoid 'deep' thin pool suspend ? */
+		/* FIXME Implement dm_tree_node_skip_children optimisation */
+		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_lauer(lv))))
+			return_0;
+		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
+			dm_tree_node_skip_children(thin_node, 1);
+#endif
+	}
+
+	if (lv_is_thin_pool(lv)) {
+		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
+			return_0;
+		/* Setup callback for deactivation based on partial tree */
+		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+			return_0;
+		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
+		    !_thin_pool_register_callback(dm, thin_node, lv))
+			return_0;
+	}
 
-	if (lv->status & RAID)
-		for (s = 0; s < seg->area_count; s++)
-			if (!_add_dev_to_dtree(dm, dtree,
-					       seg_metalv(seg, s), NULL))
+	/* Add any snapshots of this LV */
+	if (lv_is_origin(lv) && !origin_only)
+		dm_list_iterate(snh, &lv->snapshot_segs)
+			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
@@ -1591,39 +1612,29 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
 		return_0;
 
-	if (lv_is_thin_volume(lv)) {
-		if (origin_only) {
-			/* origin_only has special meaning for thin volumes */
-			if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
-				return_0;
-#if 0
-			/* FIXME Implement dm_tree_node_skip_children optimisation */
-			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
-				return_0;
-			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
-				dm_tree_node_skip_children(thin_node, 1);
-#endif
-		} else {
-			/* Add thin pool LV layer */
-			lv = seg->pool_lv;
-			seg = first_seg(lv);
-		}
-	}
-
-	if (!origin_only && lv_is_thin_pool(lv)) {
-		if (!_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
-			return_0;
-		/* FIXME code from _create_partial_dtree() should be moved here */
-		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), 0))
-			return_0;
-		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
+	/* Add any LVs used by segments in this LV */
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg->log_lv &&
+		    !_add_lv_to_dtree(dm, dtree, seg->log_lv, origin_only))
 			return_0;
-		/* If the partial tree is used for deactivation, setup callback */
-		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+		if (seg->metadata_lv &&
+		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, origin_only))
 			return_0;
-		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
-		    !_thin_pool_register_callback(dm, thin_node, lv))
+		if (seg->pool_lv &&
+		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
 			return_0;
+
+		for (s = 0; s < seg->area_count; s++) {
+			/* FIXME: raid requires to use  '0' instead of preserving
+			 * origin_only value for stacking */
+			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
+			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
+				return_0;
+			/* FIXME: raid tests fails with origin_only */
+			if (seg_is_raid(seg) &&
+			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
+				return_0;
+		}
 	}
 
 	return 1;
@@ -1632,9 +1643,6 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, int origin_only)
 {
 	struct dm_tree *dtree;
-	struct dm_list *snh;
-	struct lv_segment *seg;
-	uint32_t s;
 
 	if (!(dtree = dm_tree_create())) {
 		log_debug_activation("Partial dtree creation failed for %s.", lv->name);
@@ -1644,20 +1652,6 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 	if (!_add_lv_to_dtree(dm, dtree, lv, (lv_is_origin(lv) || lv_is_thin_volume(lv)) ? origin_only : 0))
 		goto_bad;
 
-	/* Add any snapshots of this LV */
-	if (!origin_only && lv_is_origin(lv))
-		dm_list_iterate(snh, &lv->snapshot_segs)
-			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
-				goto_bad;
-
-	/* Add any LVs used by segments in this LV */
-	dm_list_iterate_items(seg, &lv->segments)
-		for (s = 0; s < seg->area_count; s++)
-			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
-				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
-					goto_bad;
-			}
-
 	return dtree;
 
 bad:
@@ -2015,10 +2009,9 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				 const char *layer)
 {
 	uint32_t s;
-	struct dm_list *snh;
+	struct seg_list *sl;
 	struct lv_segment *seg_present;
 	const char *target_name;
-	struct lv_activate_opts lva;
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
@@ -2042,75 +2035,36 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
 		return_0;
+	/* Add thin pool metadata */
+	if (seg->metadata_lv &&
+	    !_add_new_lv_to_dtree(dm, dtree, seg->metadata_lv, laopts, NULL))
+		return_0;
+	/* Add thin pool layer */
+	if (seg->pool_lv &&
+	    !_add_new_lv_to_dtree(dm, dtree, seg->pool_lv, laopts,
+				  lv_layer(seg->pool_lv)))
+		return_0;
 
 	if (seg_is_replicator_dev(seg)) {
 		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg, laopts))
 			return_0;
-	/* If this is a snapshot origin, add real LV */
-	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
-	} else if (lv_is_origin(seg->lv) && !layer) {
-		if (!laopts->no_merging && lv_is_merging_origin(seg->lv)) {
-			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_merging_cow(seg->lv)->cow, laopts, "cow"))
-				return_0;
-			/*
-			 * Must also add "real" LV for use when
-			 * snapshot-merge target is added
-			 */
-		}
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
-			return_0;
-	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
-			return_0;
-	} else if ((layer != lv_layer(seg->lv)) && seg_is_thin(seg)) {
-		lva = *laopts;
-		lva.real_pool = 1;
-		if (!_add_new_lv_to_dtree(dm, dtree, seg_is_thin_pool(seg) ?
-					  seg->lv : seg->pool_lv, &lva,
-					  seg_is_thin_pool(seg) ?
-					  lv_layer(seg->lv) : lv_layer(seg->pool_lv)))
+	}
+
+	/* Add any LVs used by this segment */
+	for (s = 0; s < seg->area_count; ++s) {
+		if ((seg_type(seg, s) == AREA_LV) &&
+		    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
+					   laopts, NULL)))
 			return_0;
-	} else {
-		if (seg_is_thin_pool(seg) &&
-		    !_add_new_lv_to_dtree(dm, dtree, seg->metadata_lv, laopts, NULL))
+		if (seg_is_raid(seg) &&
+		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
+					  laopts, NULL))
 			return_0;
-
-		/* Add any LVs used by this segment */
-		for (s = 0; s < seg->area_count; s++) {
-			if ((seg_type(seg, s) == AREA_LV) &&
-			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-						   laopts, NULL)))
-				return_0;
-			if (seg_is_raid(seg) &&
-			    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
-						  laopts, NULL))
-				return_0;
-		}
 	}
 
-	/* Now we've added its dependencies, we can add the target itself */
-	if (lv_is_origin(seg->lv) && !layer) {
-		if (laopts->no_merging || !lv_is_merging_origin(seg->lv)) {
-			if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
-				return_0;
-		} else {
-			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, seg->lv))
-				return_0;
-		}
-	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
-			return_0;
-	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
+	if (!_add_target_to_dtree(dm, dnode, seg, laopts))
 		return_0;
 
-	if (lv_is_origin(seg->lv) && !layer)
-		/* Add any snapshots of this LV */
-		dm_list_iterate(snh, &seg->lv->snapshot_segs)
-			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
-						  laopts, NULL))
-				return_0;
-
 	return 1;
 }
 
@@ -2172,6 +2126,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct seg_list *sl;
+	struct dm_list *snh;
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
 	char *name, *dlid;
@@ -2242,21 +2197,62 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, laopts, layer))
+
+	/* If this is a snapshot origin, add real LV */
+	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
+	if (lv_is_origin(lv) && !layer) {
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, "real"))
 			return_0;
-		/* These aren't real segments in the LVM2 metadata */
-		if (lv_is_origin(lv) && !layer)
-			break;
-		if (!laopts->no_merging && lv_is_cow(lv) && !layer)
-			break;
-		if (max_stripe_size < seg->stripe_size * seg->area_count)
-			max_stripe_size = seg->stripe_size * seg->area_count;
+		if (!laopts->no_merging && lv_is_merging_origin(lv)) {
+			if (!_add_new_lv_to_dtree(dm, dtree,
+			     find_merging_cow(lv)->cow, laopts, "cow"))
+				return_0;
+			/*
+			 * Must also add "real" LV for use when
+			 * snapshot-merge target is added
+			 */
+			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, lv))
+				return_0;
+		} else if (!_add_origin_target_to_dtree(dm, dnode, lv))
+			return_0;
+
+		/* Add any snapshots of this LV */
+		dm_list_iterate(snh, &lv->snapshot_segs)
+			if (!_add_new_lv_to_dtree(dm, dtree,
+						  dm_list_struct_base(snh, struct lv_segment,
+								      origin_list)->cow,
+						  laopts, NULL))
+				return_0;
+	} else if (lv_is_cow(lv) && !layer) {
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, "cow"))
+			return_0;
+		if (!_add_snapshot_target_to_dtree(dm, dnode, lv, laopts))
+			return_0;
+	} else if (lv_is_thin_pool(lv) && !layer) {
+		/* External origin or Thin pool is using layer */
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, lv_layer(lv)))
+			return_0;
+		if (!_add_layer_target_to_dtree(dm, dnode, lv))
+			return_0;
+	} else {
+		/* Add 'real' segments for LVs */
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (!_add_segment_to_dtree(dm, dtree, dnode, seg, laopts, layer))
+				return_0;
+			if (max_stripe_size < seg->stripe_size * seg->area_count)
+				max_stripe_size = seg->stripe_size * seg->area_count;
+		}
 	}
 
+	/* Setup thin pool callback */
+	if (lv_is_thin_pool(lv) && layer &&
+	    !_thin_pool_register_callback(dm, dnode, lv))
+		return_0;
+
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
+		/* FIXME: layered device read-ahead */
 		if (!read_ahead)
 			lv_calculate_readahead(lv, &read_ahead);
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
@@ -2264,11 +2260,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
-	/* Setup thin pool callback */
-	if (layer && lv_is_thin_pool(lv) &&
-	    !_thin_pool_register_callback(dm, dnode, lv))
-		return_0;
-
 	/* Add any LVs referencing a PVMOVE LV unless told not to */
 	if (dm->track_pvmove_deps && (lv->status & PVMOVE))
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 06ab67b..4b9bb8b 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -251,21 +251,6 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!laopts->real_pool) {
-		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
-			log_error("Failed to build uuid for thin pool LV %s.", seg->pool_lv->name);
-			return 0;
-		}
-
-		if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
-					      cmd->use_linear_target,
-					      seg->lv->vg->name, seg->lv->name) ||
-		    !dm_tree_node_add_target_area(node, NULL, pool_dlid, 0))
-			return_0;
-
-		return 1;
-	}
-
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->metadata_lv->lvid.s, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
 			  seg->metadata_lv->name);


