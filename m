From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 17 Feb 2010 22:59:47 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20100217225947.23391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-17 22:59:46

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/metadata   : lv_manip.c snapshot_manip.c 
	tools          : lvconvert.c 

Log message:
	Refactor snapshot-merge deptree and device removal to support info-by-uuid
	
	Add a merging snapshot to the deptree, using the "error" target, rather
	than avoid adding it entirely.  This allows proper cleanup of the -cow
	device without having to rename the -cow to use the origin's name as a
	prefix.
	
	Move the preloading of the origin LV, after a merge, from
	lv_remove_single() to vg_remove_snapshot().  Having vg_remove_snapshot()
	preload the origin allows the -cow device to be released so that it can
	be removed via deactivate_lv().  lv_remove_single()'s deactivate_lv()
	reliably removes the -cow device because the associated snapshot LV,
	that is to be removed when a snapshot-merge completes, is always added
	to the deptree (and kernel -- via "error" target).
	
	Now when the snapshot LV is removed both the -cow and -real devices
	get removed using uuid rather than device name.  This paves the way
	for us to switch over to info-by-uuid queries.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1435&r2=1.1436
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2010/02/16 01:14:34	1.1435
+++ LVM2/WHATS_NEW	2010/02/17 22:59:46	1.1436
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Refactor snapshot-merge deptree and device removal to support info-by-uuid.
 
 Version 2.02.61 - 15th February 2010
 ====================================
--- LVM2/lib/activate/dev_manager.c	2010/02/10 14:38:24	1.180
+++ LVM2/lib/activate/dev_manager.c	2010/02/17 22:59:46	1.181
@@ -1035,10 +1035,6 @@
 		return 0;
 	}
 
-	/* cow is to be merged so skip adding it */
-	if (lv_is_merging_cow(lv))
-		return 1;
-
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
@@ -1047,7 +1043,13 @@
 
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
@@ -1166,7 +1168,7 @@
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
-	char *name, *dlid, *lv_name;
+	char *name, *dlid;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
@@ -1192,22 +1194,7 @@
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
@@ -1220,7 +1207,7 @@
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
 		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  lv_name, layer);
+			  lv->name, layer);
 		return 0;
 	}
 
--- LVM2/lib/metadata/lv_manip.c	2010/01/20 21:53:10	1.207
+++ LVM2/lib/metadata/lv_manip.c	2010/02/17 22:59:46	1.208
@@ -2064,7 +2064,6 @@
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
-	int was_merging = 0, preload_origin = 0;
 
 	vg = lv->vg;
 
@@ -2117,24 +2116,18 @@
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
@@ -2144,20 +2137,15 @@
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
--- LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:56:18	1.47
+++ LVM2/lib/metadata/snapshot_manip.c	2010/02/17 22:59:46	1.48
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "locking.h"
 #include "toolcontext.h"
 #include "lv_alloc.h"
 
@@ -58,9 +59,9 @@
 
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
 
@@ -170,12 +171,22 @@
 
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
@@ -186,5 +197,21 @@
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
--- LVM2/tools/lvconvert.c	2010/02/06 07:44:16	1.120
+++ LVM2/tools/lvconvert.c	2010/02/17 22:59:46	1.121
@@ -1210,11 +1210,6 @@
 		goto out;
 	}
 
-	if (!deactivate_lv(cmd, lv)) {
-		log_warn("WARNING: Unable to deactivate merging snapshot %s", lv->name);
-		/* merge is running regardless of this deactivation failure */
-	}
-
 	lp->need_polling = 1;
 	lp->lv_to_poll = origin;
 


