From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:19 +0200
Subject: [PATCH 01/11] Introduce laopts structure
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <ca7a79af2d1201b8d77d8f167cf16792c5419ee1.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

To avoid modification of 'read-only' volume group structure
add a new structure to pass local data around the code for LV
activation.

As origin_only is one such flag - replace this parameter with new
struct lv_activate_opts.

More parameters might eventually become part of lv_activate_opts.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c    |   80 ++++++++++++++++++++++++----------------
 lib/activate/activate.h    |    8 +++-
 lib/activate/dev_manager.c |   88 ++++++++++++++++++++++++-------------------
 lib/activate/dev_manager.h |   10 +++--
 4 files changed, 110 insertions(+), 76 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1ec518d..47d27be 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -626,7 +626,7 @@ static int _lv_open_count(struct cmd_context *cmd, struct logical_volume *lv)
 	return info.open_count;
 }
 
-static int _lv_activate_lv(struct logical_volume *lv, unsigned origin_only)
+static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
 	int r;
 	struct dev_manager *dm;
@@ -634,14 +634,15 @@ static int _lv_activate_lv(struct logical_volume *lv, unsigned origin_only)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_activate(dm, lv, origin_only)))
+	if (!(r = dev_manager_activate(dm, lv, laopts)))
 		stack;
 
 	dev_manager_destroy(dm);
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv, unsigned origin_only, int *flush_required)
+static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopts,
+		       int *flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -649,7 +650,7 @@ static int _lv_preload(struct logical_volume *lv, unsigned origin_only, int *flu
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_preload(dm, lv, origin_only, flush_required)))
+	if (!(r = dev_manager_preload(dm, lv, laopts, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -671,7 +672,8 @@ static int _lv_deactivate(struct logical_volume *lv)
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, unsigned origin_only, int lockfs, int flush_required)
+static int _lv_suspend_lv(struct logical_volume *lv, struct lv_activate_opts *laopts,
+			  int lockfs, int flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -679,7 +681,7 @@ static int _lv_suspend_lv(struct logical_volume *lv, unsigned origin_only, int l
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_suspend(dm, lv, origin_only, lockfs, flush_required)))
+	if (!(r = dev_manager_suspend(dm, lv, laopts, lockfs, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -1078,7 +1080,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
-		       unsigned origin_only, int error_if_not_suspended)
+		       struct lv_activate_opts *laopts, int error_if_not_suspended)
 {
 	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
@@ -1096,15 +1098,15 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
 	if (!lv_is_origin(lv) || !lv_is_origin(lv_pre))
-		origin_only = 0;
+		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Suspending %s%s.", lv->name, origin_only ? " origin without snapshots" : "");
+		_skip("Suspending %s%s.", lv->name, laopts->origin_only ? " origin without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
+	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || info.suspended) {
@@ -1123,23 +1125,23 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!_lv_preload(lv_pre, origin_only, &flush_required)) {
+		if (!_lv_preload(lv_pre, laopts, &flush_required)) {
 			/* FIXME Revert preloading */
 			goto_out;
 		}
 	}
 
-	if (!monitor_dev_for_events(cmd, lv, origin_only, 0))
+	if (!monitor_dev_for_events(cmd, lv, laopts->origin_only, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
 	critical_section_inc(cmd);
 
-	if (!origin_only &&
+	if (!laopts->origin_only &&
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
+	if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
 		critical_section_dec(cmd);
 		goto out;
 	}
@@ -1159,7 +1161,9 @@ out:
 /* Returns success if the device is not active */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_suspend(cmd, lvid_s, origin_only, 0);
+	struct lv_activate_opts laopts = { .origin_only = origin_only };
+
+	return _lv_suspend(cmd, lvid_s, &laopts, 0);
 }
 
 /* No longer used */
@@ -1181,8 +1185,7 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
   * @error_if_not_active
   */
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
-		      unsigned origin_only, unsigned exclusive,
-		      int error_if_not_active)
+		      struct lv_activate_opts *laopts, int error_if_not_active)
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
@@ -1195,15 +1198,15 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	if (!lv_is_origin(lv))
-		origin_only = 0;
+		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Resuming %s%s.", lv->name, origin_only ? " without snapshots" : "");
+		_skip("Resuming %s%s.", lv->name, laopts->origin_only ? " without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
+	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || !info.suspended) {
@@ -1218,15 +1221,15 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	 * non-clustered target should be used.  This only happens
 	 * if ACTIVATE_EXCL is set in lv->status.
 	 */
-	if (exclusive)
+	if (laopts->exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
-	if (!_lv_activate_lv(lv, origin_only))
+	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
 
 	critical_section_dec(cmd);
 
-	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
+	if (!monitor_dev_for_events(cmd, lv, laopts->origin_only, 1))
 		stack;
 
 	r = 1;
@@ -1241,12 +1244,24 @@ out:
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, exclusive, 0);
+	struct lv_activate_opts laopts = {
+		.origin_only = origin_only,
+		/*
+		 * When targets are activated exclusively in a cluster, the
+		 * non-clustered target should be used.  This only happens
+		 * if exclusive is set.
+		 */
+		.exclusive = exclusive
+	};
+
+	return _lv_resume(cmd, lvid_s, &laopts, 0);
 }
 
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, 0, 1);
+	struct lv_activate_opts laopts = { .origin_only = origin_only, };
+
+	return _lv_resume(cmd, lvid_s, &laopts, 1);
 }
 
 static int _lv_has_open_snapshots(struct logical_volume *lv)
@@ -1361,7 +1376,7 @@ out:
 }
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
-			int exclusive, int filter)
+			struct lv_activate_opts *laopts, int filter)
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
@@ -1410,11 +1425,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (exclusive)
-		lv->status |= ACTIVATE_EXCL;
-
 	critical_section_inc(cmd);
-	if (!(r = _lv_activate_lv(lv, 0)))
+	if (!(r = _lv_activate_lv(lv, laopts)))
 		stack;
 	critical_section_dec(cmd);
 
@@ -1433,7 +1445,9 @@ out:
 /* Activate LV */
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	if (!_lv_activate(cmd, lvid_s, exclusive, 0))
+	struct lv_activate_opts laopts = { .exclusive = exclusive };
+
+	if (!_lv_activate(cmd, lvid_s, &laopts, 0))
 		return_0;
 
 	return 1;
@@ -1442,7 +1456,9 @@ int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 /* Activate LV only if it passes filter */
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	if (!_lv_activate(cmd, lvid_s, exclusive, 1))
+	struct lv_activate_opts laopts = { .exclusive = exclusive };
+
+	if (!_lv_activate(cmd, lvid_s, &laopts, 1))
 		return_0;
 
 	return 1;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 145fefb..b136d59 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -30,6 +30,12 @@ struct lvinfo {
 	uint32_t read_ahead;
 };
 
+struct lv_activate_opts {
+	int exclusive;
+	int origin_only;
+	int no_merging;
+};
+
 /* target attribute flags */
 #define MIRROR_LOG_CLUSTERED	0x00000001U
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9f4b2da..b07030a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1037,7 +1037,7 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 /*
  * Add LV and any known dependencies
  */
-static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, unsigned origin_only)
+static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, int origin_only)
 {
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
@@ -1061,7 +1061,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 	return 1;
 }
 
-static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
+static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, int origin_only)
 {
 	struct dm_tree *dtree;
 	struct dm_list *snh, *snht;
@@ -1291,41 +1291,46 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				  struct logical_volume *lv, const char *layer);
+				struct logical_volume *lv,
+				struct lv_activate_opts *laopts,
+				const char *layer);
 
 /* Add all replicators' LVs */
 static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 					       struct dm_tree *dtree,
-					       struct lv_segment *seg)
+					       struct lv_segment *seg,
+					       struct lv_activate_opts *laopts)
 {
 	struct replicator_device *rdev;
 	struct replicator_site *rsite;
 
 	/* For inactive replicator add linear mapping */
 	if (!lv_is_active_replicator_dev(seg->lv)) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, laopts, NULL))
 			return_0;
 		return 1;
 	}
 
 	/* Add rlog and replicator nodes */
 	if (!seg->replicator ||
-            !first_seg(seg->replicator)->rlog_lv ||
+	    !first_seg(seg->replicator)->rlog_lv ||
 	    !_add_new_lv_to_dtree(dm, dtree,
-				  first_seg(seg->replicator)->rlog_lv, NULL) ||
-	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+				  first_seg(seg->replicator)->rlog_lv,
+				  laopts, NULL) ||
+	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, laopts, NULL))
 	    return_0;
 
 	/* Activation of one replicator_dev node activates all other nodes */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
 			if (rdev->lv &&
-			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv, NULL))
+			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv,
+						  laopts, NULL))
 				return_0;
 
 			if (rdev->slog &&
-			    !_add_new_lv_to_dtree(dm, dtree,
-						  rdev->slog, NULL))
+			    !_add_new_lv_to_dtree(dm, dtree, rdev->slog,
+						  laopts, NULL))
 				return_0;
 		}
 	}
@@ -1340,7 +1345,7 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 			if (!rdev->replicator_dev->lv ||
 			    !_add_new_lv_to_dtree(dm, dtree,
 						  rdev->replicator_dev->lv,
-						  NULL))
+						  laopts, NULL))
 				return_0;
 		}
 	}
@@ -1349,10 +1354,11 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_segment_to_dtree(struct dev_manager *dm,
-				   struct dm_tree *dtree,
-				   struct dm_tree_node *dnode,
-				   struct lv_segment *seg,
-				   const char *layer)
+				 struct dm_tree *dtree,
+				 struct dm_tree_node *dnode,
+				 struct lv_segment *seg,
+				 struct lv_activate_opts *laopts,
+				 const char *layer)
 {
 	uint32_t s;
 	struct dm_list *snh;
@@ -1379,35 +1385,35 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 
 	/* Add mirror log */
 	if (seg->log_lv &&
-	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
+	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
 		return_0;
 
 	if (seg_is_replicator_dev(seg)) {
-		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg, laopts))
 			return_0;
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_merging_cow(seg->lv)->cow, "cow"))
+			     find_merging_cow(seg->lv)->cow, laopts, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when
 			 * snapshot-merge target is added
 			 */
 		}
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "real"))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
 			return_0;
 	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "cow"))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
 	} else {
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++)
 			if ((seg_type(seg, s) == AREA_LV) &&
 			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-						   NULL)))
+						   laopts, NULL)))
 				return_0;
 	}
 
@@ -1429,14 +1435,16 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	if (lv_is_origin(seg->lv) && !layer)
 		/* Add any snapshots of this LV */
 		dm_list_iterate(snh, &seg->lv->snapshot_segs)
-			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, NULL))
+			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
+						  laopts, NULL))
 				return_0;
 
 	return 1;
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				  struct logical_volume *lv, const char *layer)
+				struct logical_volume *lv, struct lv_activate_opts *laopts,
+				const char *layer)
 {
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
@@ -1507,7 +1515,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, layer))
+		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, laopts, layer))
 			return_0;
 		/* These aren't real segments in the LVM2 metadata */
 		if (lv_is_origin(lv) && !layer)
@@ -1645,14 +1653,14 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 }
 
 static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, action_t action)
+			struct lv_activate_opts *laopts, action_t action)
 {
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
 	char *dlid;
 	int r = 0;
 
-	if (!(dtree = _create_partial_dtree(dm, lv, origin_only)))
+	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
@@ -1663,14 +1671,14 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	/* Restore fs cookie */
 	dm_tree_set_cookie(root, fs_get_cookie());
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, laopts->origin_only ? "real" : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
 	switch(action) {
 	case CLEAN:
 		/* Deactivate any unused non-toplevel nodes */
-		if (!_clean_tree(dm, root, origin_only ? dlid : NULL))
+		if (!_clean_tree(dm, root, laopts->origin_only ? dlid : NULL))
 			goto_out;
 		break;
 	case DEACTIVATE:
@@ -1693,7 +1701,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, origin_only ? "real" : NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, laopts->origin_only ? "real" : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
@@ -1732,23 +1740,24 @@ out_no_root:
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+			 struct lv_activate_opts *laopts)
 {
-	if (!_tree_action(dm, lv, origin_only, ACTIVATE))
+	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
-	return _tree_action(dm, lv, origin_only, CLEAN);
+	return _tree_action(dm, lv, laopts, CLEAN);
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int *flush_required)
+			struct lv_activate_opts *laopts, int *flush_required)
 {
 	/* FIXME Update the pvmove implementation! */
 	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
 		return 1;
 
-	if (!_tree_action(dm, lv, origin_only, PRELOAD))
+	if (!_tree_action(dm, lv, laopts, PRELOAD))
 		return 0;
 
 	*flush_required = dm->flush_required;
@@ -1758,19 +1767,20 @@ int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
 {
+	struct lv_activate_opts laopts = { 0 };
 	int r;
 
-	r = _tree_action(dm, lv, 0, DEACTIVATE);
+	r = _tree_action(dm, lv, &laopts, DEACTIVATE);
 
 	return r;
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int lockfs, int flush_required)
+			struct lv_activate_opts *laopts, int lockfs, int flush_required)
 {
 	dm->flush_required = flush_required;
 
-	return _tree_action(dm, lv, origin_only, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
+	return _tree_action(dm, lv, laopts, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
 /*
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index b0bb275..4d7a7ee 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,7 @@
 #include "metadata-exported.h"
 
 struct logical_volume;
+struct lv_activate_opts;
 struct volume_group;
 struct cmd_context;
 struct dev_manager;
@@ -51,10 +52,11 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
 			       percent_t *percent, uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int lockfs, int flush_required);
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only);
+			struct lv_activate_opts *laopts, int lockfs, int flush_required);
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+			 struct lv_activate_opts *laopts);
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int *flush_required);
+			struct lv_activate_opts *laopts, int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
-- 
1.7.5.2


