From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 15 Feb 2010 17:43:02 -0500
Subject: [PATCH] snapshot: refactor snapshot-merge deptree and device removal
Message-ID: <1266273782-32641-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a merging snapshot using the "error" target rather than avoid
adding it entirely.  This allows proper cleanup of the -cow device
without having to rename the -cow to use the origin's name as a
prefix.

Moved the preloading of the origin LV, after a merge, from
lv_remove_single() to vg_remove_single().  Having vg_remove_single()
preload the origin free up the -cow device so that it can be removed
via deactivate_lv().  This is reliable because the associated snapshot
LV, that is to be removed when a snapshot-merge completes, is always
added no to the deptree (and kernel -- via "error" target).

Now when the snapshot LV is removed both the -cow and -real devices
get removed using uuid rather than device name.  This paves the way
for us to switch over to info-by-uuid queries.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c    |   33 ++++++++++-----------------------
 lib/metadata/lv_manip.c       |   32 ++++++++++----------------------
 lib/metadata/snapshot_manip.c |   37 ++++++++++++++++++++++++++++++++-----
 tools/lvconvert.c             |    5 -----
 4 files changed, 52 insertions(+), 55 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b31a303..f21a3cc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1035,10 +1035,6 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
-	/* cow is to be merged so skip adding it */
-	if (lv_is_merging_cow(lv))
-		return 1;
-
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
@@ -1047,7 +1043,13 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
 
-	if (!dm_tree_node_add_snapshot_target(dnode, size, origin_dlid, cow_dlid, 1, snap_seg->chunk_size))
+	if (lv_is_merging_cow(lv)) {
+		/* cow is to be merged so load the error target */
+		if (!dm_tree_node_add_error_target(dnode, size))
+			return_0;
+	}
+	else if (!dm_tree_node_add_snapshot_target(dnode, size, origin_dlid,
+						   cow_dlid, 1, snap_seg->chunk_size))
 		return_0;
 
 	return 1;
@@ -1166,7 +1168,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
-	char *name, *dlid, *lv_name;
+	char *name, *dlid;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
@@ -1192,22 +1194,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
-	lv_name = lv->name;
-	if (lv_is_cow(lv) && lv_is_merging_cow(lv)) {
-		if (layer) {
-			/*
-			 * use origin's name as basis for snapshot-merge device names;
-			 * this allows _clean_tree to automatically cleanup "-cow"
-			 * when the origin is resumed (after merge completes)
-			 */
-			lv_name = origin_from_cow(lv)->name;
-		} else {
-			/* top-level snapshot device is not needed during merge */
-			return 1;
-		}
-	}
-
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv_name, layer)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
 	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
@@ -1220,7 +1207,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
 		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  lv_name, layer);
+			  lv->name, layer);
 		return 0;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3af605a..f161ddb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2064,7 +2064,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
-	int was_merging = 0, preload_origin = 0;
 
 	vg = lv->vg;
 
@@ -2117,24 +2116,18 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!archive(vg))
 		return 0;
 
-	/* FIXME Snapshot commit out of sequence if it fails after here? */
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate logical volume \"%s\"",
-			  lv->name);
-		return 0;
-	}
-
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
-		was_merging = lv_is_merging_origin(origin);
 		log_verbose("Removing snapshot %s", lv->name);
+		/* vg_remove_snapshot() will preload origin if it was merging */
 		if (!vg_remove_snapshot(lv))
 			return_0;
-		if (was_merging && lv_is_origin(origin)) {
-			/* snapshot(s) still exist. preload new origin prior to suspend. */
-			/* FIXME Seek a simpler way of dealing with this within the tree. */
-			preload_origin = 1;
-		}
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate logical volume \"%s\"",
+			  lv->name);
+		return 0;
 	}
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
@@ -2144,20 +2137,15 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg))
-		return_0;
-
-	if (!preload_origin && !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	/* If no snapshots left or if we stopped merging, reload */
-	if (origin && (!lv_is_origin(origin) || was_merging)) {
+	/* If no snapshots left, reload without -real. */
+	if (origin && (!lv_is_origin(origin))) {
 		if (!suspend_lv(cmd, origin)) {
 			log_error("Failed to refresh %s without snapshot.", origin->name);
 			return 0;
 		}
-		if (preload_origin && !vg_commit(vg))
-			return_0;
 		if (!resume_lv(cmd, origin)) {
 			log_error("Failed to resume %s.", origin->name);
 			return 0;
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 19effe3..f7218c2 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "locking.h"
 #include "toolcontext.h"
 #include "lv_alloc.h"
 
@@ -58,9 +59,9 @@ int lv_is_merging_origin(const struct logical_volume *origin)
 
 struct lv_segment *find_merging_cow(const struct logical_volume *origin)
 {
-	/* FIXME: eliminate this wrapper and just use find_cow()?
-	 * - find_merging_cow() adds to code clarity in caller
-	 */
+	if (!lv_is_merging_origin(origin))
+		return NULL;
+
 	return find_cow(origin);
 }
 
@@ -170,12 +171,22 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
+	int preload_origin = 0;
 	struct logical_volume *origin = origin_from_cow(cow);
 
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
-	if (find_merging_cow(origin) == find_cow(cow))
-		clear_snapshot_merge(origin_from_cow(cow));
+	if (find_merging_cow(origin) == find_cow(cow)) {
+		clear_snapshot_merge(origin);
+		/*
+		 * preload origin to:
+		 * - allow proper release of -cow
+		 * - avoid allocations with other devices suspended
+		 *   when transitioning from "snapshot-merge" to
+		 *   "snapshot-origin after a merge completes.
+		 */
+		preload_origin = 1;
+	}
 
 	if (!lv_remove(cow->snapshot->lv)) {
 		log_error("Failed to remove internal snapshot LV %s",
@@ -186,5 +197,21 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	cow->snapshot = NULL;
 	lv_set_visible(cow);
 
+	if (preload_origin) {
+		if (!vg_write(origin->vg))
+			return_0;
+		if (!suspend_lv(origin->vg->cmd, origin)) {
+			log_error("Failed to refresh %s without snapshot.",
+				  origin->name);
+			return 0;
+		}
+		if (!vg_commit(origin->vg))
+			return_0;
+		if (!resume_lv(origin->vg->cmd, origin)) {
+			log_error("Failed to resume %s.", origin->name);
+			return 0;
+		}
+	}
+
 	return 1;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4fb04a1..914b681 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1210,11 +1210,6 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (!deactivate_lv(cmd, lv)) {
-		log_warn("WARNING: Unable to deactivate merging snapshot %s", lv->name);
-		/* merge is running regardless of this deactivation failure */
-	}
-
 	lp->need_polling = 1;
 	lp->lv_to_poll = origin;
 


