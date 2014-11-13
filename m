From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 10:56:41 +0000 (UTC)
Subject: master - cache: improve pending_delete
Message-ID: <20141113105641.0BC7960D56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fba86dd42b57626aa276e4f31e56e5d2a4384e48
Commit:        fba86dd42b57626aa276e4f31e56e5d2a4384e48
Parent:        359dc6fa76f765a5503b3fda7a596984272a4a4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 10:08:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 11:54:41 2014 +0100

cache: improve pending_delete

We need to stop guessing deleted names - so rather collect
deleted  UUID into a string list - and then remove them properly
in _clean_tree. Restore origin _clean_tree behaviour them for
currently unconverted removal of snapshots.

Pending delete feature now properly tracks whole subtree of cache
(so i.e. data or metadata as raid volumes).
It properly replaces all related volumes with 'errors' in suspend
preload, then resume them as error and remove collected UUIDs
from root - since they are not longer part of any volume deps.
---
 lib/activate/dev_manager.c |  121 +++++++++++++++++++++++--------------------
 1 files changed, 65 insertions(+), 56 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6e5b785..047e929 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -25,6 +25,7 @@
 #include "config.h"
 #include "activate.h"
 #include "lvm-exec.h"
+#include "str_list.h"
 
 #include <limits.h>
 #include <dirent.h>
@@ -44,6 +45,12 @@ typedef enum {
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
 const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", NULL};
 
+struct dlid_list {
+	struct dm_list list;
+	const char *dlid;
+	const struct logical_volume *lv;
+};
+
 struct dev_manager {
 	struct dm_pool *mem;
 
@@ -54,6 +61,8 @@ struct dev_manager {
 	int flush_required;
 	int activation;                 /* building activation tree */
 	int skip_external_lv;
+	struct dm_list pending_delete;	/* str_list of dlid(s) with pending delete */
+	unsigned track_pending_delete;
 	unsigned track_pvmove_deps;
 
 	char *vg_name;
@@ -1069,6 +1078,8 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 
 	dm_udev_set_sync_support(cmd->current_settings.udev_sync);
 
+	dm_list_init(&dm->pending_delete);
+
 	return dm;
 
       bad:
@@ -1726,6 +1737,12 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 0;
 	}
 
+	if (info.exists && dm->track_pending_delete) {
+		log_debug_activation("Tracking pending delete for %s (%s).", lv->name, dlid);
+		if (!str_list_add(dm->mem, &dm->pending_delete, dlid))
+			return_0;
+	}
+
 	return 1;
 }
 
@@ -2044,13 +2061,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (lv_is_cache(lv)) {
-		if (lv_is_pending_delete(lv)) {
-			if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, 1)) /* stack */
-				return_0;
-			/* Orhan cache LV exits here */
-			return 1;
-		}
-		if (!origin_only && !dm->activation) {
+		if (!origin_only && !dm->activation && !dm->track_pending_delete) {
 			/* Setup callback for non-activation partial tree */
 			/* Activation gets own callback when needed */
 			/* TODO: extend _cached_dm_info() to return dnode */
@@ -2080,13 +2091,16 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		dm->track_pvmove_deps = 1;
 	}
 
-	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
-		if (lv_is_pending_delete(sl->seg->lv) && lv_is_cache(sl->seg->lv)) {
-			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
-				return_0;
-			break;
+	if (!dm->track_pending_delete)
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+			if (lv_is_pending_delete(sl->seg->lv)) {
+				/* LV is referenced by 'cache pending delete LV */
+				dm->track_pending_delete = 1;
+				if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+					return_0;
+				dm->track_pending_delete = 0;
+			}
 		}
-	}
 
 	/* Adding LV head of replicator adds all other related devs */
 	if (lv_is_replicator_dev(lv) &&
@@ -2111,6 +2125,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
+			    /* origin only for cache without pending delete */
+			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 				return_0;
 			if (seg_is_raid(seg) &&
@@ -2554,21 +2570,24 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 {
 	uint32_t s;
 	struct lv_segment *seg_present;
+	const struct segment_type *segtype;
 	const char *target_name;
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_snapshot(seg->lv) ? : seg;
-	target_name = (seg_present->segtype->ops->target_name ?
-		       seg_present->segtype->ops->target_name(seg_present, laopts) :
-		       seg_present->segtype->name);
+	segtype = seg_present->segtype;
+
+	target_name = (segtype->ops->target_name ?
+		       segtype->ops->target_name(seg_present, laopts) :
+		       segtype->name);
 
 	log_debug_activation("Checking kernel supports %s segment type for %s%s%s",
 			     target_name, seg->lv->name,
 			     layer ? "-" : "", layer ? : "");
 
-	if (seg_present->segtype->ops->target_present &&
-	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
-						       seg_present, NULL)) {
+	if (segtype->ops->target_present &&
+	    !segtype->ops->target_present(seg_present->lv->vg->cmd,
+					  seg_present, NULL)) {
 		log_error("Can't process LV %s: %s target support missing "
 			  "from kernel?", seg->lv->name, target_name);
 		return 0;
@@ -2603,8 +2622,10 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	/* Add any LVs used by this segment */
 	for (s = 0; s < seg->area_count; ++s) {
 		if ((seg_type(seg, s) == AREA_LV) &&
-		    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-					   laopts, NULL)))
+		    /* origin only for cache without pending delete */
+		    (!dm->track_pending_delete || !seg_is_cache(seg)) &&
+		    !_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
+					  laopts, NULL))
 			return_0;
 		if (seg_is_raid(seg) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
@@ -2612,7 +2633,13 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 			return_0;
 	}
 
-	if (!_add_target_to_dtree(dm, dnode, seg, laopts))
+	if (dm->track_pending_delete) {
+		/* Replace target and all its used devs with error mapping */
+		log_debug_activation("Using error for pending delete %s.",
+				     seg->lv->name);
+		if (!dm_tree_node_add_error_target(dnode, (uint64_t)seg->lv->vg->extent_size * seg->len))
+			return_0;
+	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
 		return_0;
 
 	return 1;
@@ -2685,6 +2712,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
+	int save_pending_delete = dm->track_pending_delete;
 
 	/* LV with pending delete is never put new into a table */
 	if (lv_is_pending_delete(lv) && !_cached_dm_info(dm->mem, dtree, lv, NULL))
@@ -2772,29 +2800,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
 
-	if (lv_is_pending_delete(lv)) {
+	if (lv_is_pending_delete(lv))
 		/* Handle LVs with pending delete */
-		if (lv_is_cache(lv)) {
-			/* Use 'error' for cache, metadata and data volumes */
-			seg = first_seg(lv);
-			if (!dm_tree_node_add_error_target(dnode, seg_lv(seg, 0)->size))
-				return_0;
-			seg = first_seg(seg->pool_lv);
-			if (!(dlid = build_dm_uuid(dm->mem, seg->metadata_lv, NULL)))
-				return_0;
-			if ((dnode = dm_tree_find_node_by_uuid(dtree, dlid)) &&
-			    !dm_tree_node_get_context(dnode) &&
-			    !dm_tree_node_add_error_target(dnode, seg->metadata_lv->size))
-				return_0;
-			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, 0), NULL)))
-				return_0;
-			if ((dnode = dm_tree_find_node_by_uuid(dtree, dlid)) &&
-			    !dm_tree_node_get_context(dnode) &&
-			    !dm_tree_node_add_error_target(dnode, seg_lv(seg, 0)->size))
-				return_0;
-		}
-		return 1;
-	}
+		/* Fow now used only by cache segtype, TODO snapshots */
+		dm->track_pending_delete = 1;
 
 	/* This is unused cache-pool - make metadata accessible */
 	if (lv_is_cache_pool(lv))
@@ -2880,6 +2889,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 #endif
 
+	dm->track_pending_delete = save_pending_delete; /* restore */
+
 	return 1;
 }
 
@@ -2972,12 +2983,20 @@ static int _remove_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	return r;
 }
 
-static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *non_toplevel_tree_dlid)
+static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const char *non_toplevel_tree_dlid)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
+	struct dm_str_list *dl;
+
+	/* Deactivate any tracked pending delete nodes */
+	dm_list_iterate_items(dl, &dm->pending_delete) {
+		log_debug_activation("Deleting tracked UUID %s.", dl->str);
+		if (!dm_tree_deactivate_children(root, dl->str, strlen(dl->str)))
+			return_0;
+	}
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -2992,23 +3011,13 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 		}
 
 		/* Not meant to be top level? */
-		if (!*layer && (!(layer = strchr(uuid + 4, '-')) || strstr(layer, "-pool") || strstr(layer, "-tpool")))
-			continue;
-
-		/* FIXME: we still occasionally need to activate these at top-level */
-		if (((name = strstr(lvname, "_tmeta")) && !name[6]) ||
-		    ((name = strstr(lvname, "_tdata")) && !name[6]))
+		if (!*layer)
 			continue;
 
 		/* If operation was performed on a partial tree, don't remove it */
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		if ((name = strstr(lvname, "_corig")) && !name[6] &&
-		    /* FIXME: for now just for _corig deactivate LVM subtree, should be generic */
-		    !dm_tree_deactivate_children(child, "LVM-", 4))
-			return_0;
-
 		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
 			return_0;
 	}


