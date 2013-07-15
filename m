From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:11 +0000 (UTC)
Subject: master - thin: improve external origin tree creation
Message-ID: <20130715140311.EA9D460E80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a060948242e830555436678f5b15b84bca70b04
Commit:        9a060948242e830555436678f5b15b84bca70b04
Parent:        57be501aa3d723fcd41781e6c37579991a714751
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 9 12:34:49 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 16:00:06 2013 +0200

thin: improve external origin tree creation

When tree for thin LVs was using external_lv, there has been
far less optimal solution, that has tried to add certain
existing dependencie only when new node was added.
However this has lead to way to complex tree construction since
many repeated checks have been made during such tree build.

This patch move this detection to the proper _partial_tree generation
code and uses for it new  'activation' flag, which is set when
tree for ACTIVATION or PRELOAD is generated.

It increases performance when thins with external origins are used.

(in release update)
---
 lib/activate/dev_manager.c |  115 +++++++++++++++++++++++++++-----------------
 1 files changed, 70 insertions(+), 45 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6a2cc68..281041b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -48,6 +48,8 @@ struct dev_manager {
 	void *target_state;
 	uint32_t pvmove_mirror_count;
 	int flush_required;
+	int activation;                 /* building activation tree */
+	int skip_external_lv;
 	unsigned track_pvmove_deps;
 
 	char *vg_name;
@@ -1695,19 +1697,39 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 #endif
 	}
 
+	if (origin_only && dm->activation && !dm->skip_external_lv &&
+	    lv_is_external_origin(lv)) {
+		/* Find possible users of external origin lv */
+		dm->skip_external_lv = 1; /* avoid recursion */
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+			/* Match only external_lv users */
+			if ((sl->seg->external_lv == lv) &&
+			    !_add_lv_to_dtree(dm, dtree, sl->seg->lv, 1))
+				return_0;
+		dm->skip_external_lv = 0;
+	}
+
 	if (lv_is_thin_pool(lv)) {
+		/*
+		 * For both origin_only and !origin_only
+		 * skips test for -tpool-real and tpool-cow
+		 */
 		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
 			return_0;
-		/* Setup callback for deactivation based on partial tree */
-		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
-			return_0;
-		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
-		    !_thin_pool_register_callback(dm, thin_node, lv))
-			return_0;
+		if (!dm->activation) {
+			/* Setup callback for non-activation partial tree */
+			/* Activation gets own callback when needed */
+			/* TODO: extend _cached_info() to return dnode */
+			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+				return_0;
+			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
+			    !_thin_pool_register_callback(dm, thin_node, lv))
+				return_0;
+		}
 	}
 
 	/* Add any snapshots of this LV */
-	if (lv_is_origin(lv) && (lv_is_external_origin(lv) || !origin_only))
+	if (!origin_only && lv_is_origin(lv))
 		dm_list_iterate(snh, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				return_0;
@@ -1726,7 +1748,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->external_lv &&
+		if (seg->external_lv && !dm->skip_external_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->external_lv, 1)) /* stack */
 			return_0;
 		if (seg->log_lv &&
@@ -1735,7 +1757,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (seg->metadata_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
-		if (seg->pool_lv &&
+		if (seg->pool_lv && !dm->skip_external_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
 			return_0;
 
@@ -2113,41 +2135,49 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 	return 1;
 }
 
-static int _add_active_externals_to_dtree(struct dev_manager *dm,
-					  struct dm_tree *dtree,
-					  struct lv_segment *seg,
-					  struct lv_activate_opts *laopts)
+static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
+					 struct dm_tree *dtree,
+					 struct logical_volume *external_lv,
+					 struct lv_activate_opts *laopts)
 {
 	struct seg_list *sl;
 
-	/* Add any ACTIVE LVs using this external origin LV */
-	log_debug_activation("Adding active users of external lv %s",
-			     seg->external_lv->name);
-	dm_list_iterate_items(sl, &seg->external_lv->segs_using_this_lv) {
-		if (sl->seg->external_lv != seg->external_lv ||
-		    sl->seg == seg)
-			continue;
+	/* Do not want to recursively add externals again */
+	if (dm->skip_external_lv)
+		return 1;
 
-		/*
-		 * Find if the LV is active
-		 * These LVs are not scanned the generic partial dtree
-		 * since in most cases we do not want to work with them.
-		 * However when new EO user is added all users must be known.
-		 *
-		 * As EO could have been chained and passed to a new
-		 * volume, whole device needs to be tested, so the
-		 * removal of layered EO (-real) happens.
-		 */
-		if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, 0))
-			return_0;
+	/*
+	 * Any LV can have only 1 external origin, so we will
+	 * process all LVs related to this LV, and we want to
+	 * skip repeated invocation of external lv processing
+	 */
+	dm->skip_external_lv = 1;
+
+	log_debug_activation("Adding external origin lv %s and all active users.",
+			     external_lv->name);
 
-		/* Only layer check is needed here (also avoids loop) */
-		if (_cached_info(dm->mem, dtree, sl->seg->lv,
+	if (!_add_new_lv_to_dtree(dm, dtree, external_lv, laopts,
+				  lv_layer(external_lv)))
+		return_0;
+
+	/*
+	 * Add all ACTIVE LVs using this external origin LV. This is
+	 * needed because of conversion of thin which could have been
+	 * also an old-snapshot to external origin.
+	 */
+	//if (lv_is_origin(external_lv))
+	dm_list_iterate_items(sl, &external_lv->segs_using_this_lv)
+		if ((sl->seg->external_lv == external_lv) &&
+		    /* Add only active layered devices (also avoids loop) */
+		    _cached_info(dm->mem, dtree, sl->seg->lv,
 				 lv_layer(sl->seg->lv)) &&
 		    !_add_new_lv_to_dtree(dm, dtree, sl->seg->lv,
 					  laopts, lv_layer(sl->seg->lv)))
 			return_0;
-	}
+
+	log_debug_activation("Finished adding  external origin lv %s and all active users.",
+			     external_lv->name);
+	dm->skip_external_lv = 0;
 
 	return 1;
 }
@@ -2182,16 +2212,9 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	}
 
 	/* Add external origin layer */
-	if (seg->external_lv) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->external_lv, laopts,
-					  lv_layer(seg->external_lv)))
-			return_0;
-
-		if (!layer &&
-		    !_add_active_externals_to_dtree(dm, dtree, seg, laopts))
-			return_0;
-	}
-
+	if (seg->external_lv &&
+	    !_add_new_external_lv_to_dtree(dm, dtree, seg->external_lv, laopts))
+		return_0;
 	/* Add mirror log */
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
@@ -2567,6 +2590,8 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	char *dlid;
 	int r = 0;
 
+	/* Some targets may build bigger tree for activation */
+	dm->activation = ((action == PRELOAD) || (action == ACTIVATE));
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 


