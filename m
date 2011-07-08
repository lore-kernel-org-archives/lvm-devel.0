From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 12:48:42 -0000
Subject: LVM2/lib activate/activate.c metadata/lv_manip ...
Message-ID: <20110708124842.14065.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 12:48:42

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c snapshot_manip.c 

Log message:
	Move snapshot deactivation logic into lib/activate, fixing the
	teardown sequence.  (Previously the snapshot was deactivated while its
	origin was active and before its removal was committed to disk, so
	restarting after a crash at the point would leave corruption.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.266&r2=1.267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/lib/activate/activate.c	2011/07/05 18:36:37	1.207
+++ LVM2/lib/activate/activate.c	2011/07/08 12:48:41	1.208
@@ -1112,7 +1112,7 @@
 	struct lv_list *lvl_pre;
 
 	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
-		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) && !lv_is_cow(lv) &&
+		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) && (!lv_is_cow(lv) || !lv_is_cow(lvl_pre->lv)) &&
 		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
 			return_0;
 	}
@@ -1126,6 +1126,7 @@
 	struct logical_volume *lv = NULL, *lv_pre = NULL, *pvmove_lv = NULL;
 	struct lv_list *lvl_pre;
 	struct seg_list *sl;
+        struct lv_segment *snap_seg;
 	struct lvinfo info;
 	int r = 0, lockfs = 0, flush_required = 0;
 	struct detached_lv_data detached;
@@ -1180,8 +1181,7 @@
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
 			if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, sl->seg->lv->name))) {
-				/* FIXME Internal error? */
-				log_error("LV %s missing from preload metadata", sl->seg->lv->name);
+				log_error(INTERNAL_ERROR "LV %s missing from preload metadata", sl->seg->lv->name);
 				goto out;
 			}
 			if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
@@ -1189,8 +1189,7 @@
 		}
 		/* Now preload the PVMOVE LV itself */
 		if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, pvmove_lv->name))) {
-			/* FIXME Internal error? */
-			log_error("LV %s missing from preload metadata", pvmove_lv->name);
+			log_error(INTERNAL_ERROR "LV %s missing from preload metadata", pvmove_lv->name);
 			goto out;
 		}
 		if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
@@ -1209,6 +1208,22 @@
 
 		if (!for_each_sub_lv(cmd, lv, &_preload_detached_lv, &detached))
 			goto_out;
+
+		/*
+		 * Preload any snapshots that are being removed.
+		 */
+		if (!laopts->origin_only && lv_is_origin(lv)) {
+        		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
+				if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, snap_seg->cow->name))) {
+					log_error(INTERNAL_ERROR "LV %s missing from preload metadata",
+						  snap_seg->cow->name);
+					goto out;
+				}
+				if (!lv_is_cow(lvl_pre->lv) &&
+				    !_lv_preload(lvl_pre->lv, laopts, &flush_required))
+					goto_out;
+			}
+		}
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
--- LVM2/lib/metadata/lv_manip.c	2011/06/30 18:25:18	1.266
+++ LVM2/lib/metadata/lv_manip.c	2011/07/08 12:48:41	1.267
@@ -2683,8 +2683,6 @@
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
-	int was_merging = 0;
-	int reload_required = 0;
 
 	vg = lv->vg;
 
@@ -2739,9 +2737,8 @@
 
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
-		was_merging = lv_is_merging_origin(origin);
 		log_verbose("Removing snapshot %s", lv->name);
-		/* vg_remove_snapshot() will preload origin if it was merging */
+		/* vg_remove_snapshot() will preload origin/former snapshots */
 		if (!vg_remove_snapshot(lv))
 			return_0;
 	}
@@ -2759,26 +2756,13 @@
 		return 0;
 	}
 
-	/* If no snapshots left, and was not merging, reload without -real. */
-	if (origin && (!lv_is_origin(origin) && !was_merging))
-		reload_required = 1;
-
 	/* store it on disks */
 	if (!vg_write(vg))
 		return_0;
 
-	if (reload_required && !suspend_lv(cmd, origin))
-		log_error("Failed to refresh %s without snapshot.", origin->name);
-		/* FIXME Falls through because first part of change already in kernel! */
-
 	if (!vg_commit(vg))
 		return_0;
 
-	if (reload_required && !resume_lv(cmd, origin)) {
-		log_error("Failed to resume %s.", origin->name);
-		return 0;
-	}
-
 	backup(vg);
 
 	if (lv_is_visible(lv))
--- LVM2/lib/metadata/snapshot_manip.c	2010/04/23 02:57:43	1.49
+++ LVM2/lib/metadata/snapshot_manip.c	2011/07/08 12:48:41	1.50
@@ -172,7 +172,7 @@
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
-	int preload_origin = 0;
+	int merging_snapshot = 0;
 	struct logical_volume *origin = origin_from_cow(cow);
 
 	dm_list_del(&cow->snapshot->origin_list);
@@ -193,7 +193,7 @@
 			 *   when transitioning from "snapshot-merge" to
 			 *   "snapshot-origin after a merge completes.
 			 */
-			preload_origin = 1;
+			merging_snapshot = 1;
 		}
 	}
 
@@ -206,20 +206,22 @@
 	cow->snapshot = NULL;
 	lv_set_visible(cow);
 
-	if (preload_origin) {
-		if (!vg_write(origin->vg))
-			return_0;
-		if (!suspend_lv(origin->vg->cmd, origin)) {
-			log_error("Failed to refresh %s without snapshot.",
-				  origin->name);
-			return 0;
-		}
-		if (!vg_commit(origin->vg))
-			return_0;
-		if (!resume_lv(origin->vg->cmd, origin)) {
-			log_error("Failed to resume %s.", origin->name);
-			return 0;
-		}
+	if (!vg_write(origin->vg))
+		return_0;
+	if (!suspend_lv(origin->vg->cmd, origin)) {
+		log_error("Failed to refresh %s without snapshot.",
+			  origin->name);
+		return 0;
+	}
+	if (!vg_commit(origin->vg))
+		return_0;
+	if (!merging_snapshot && !resume_lv(origin->vg->cmd, cow)) {
+		log_error("Failed to resume %s.", cow->name);
+		return 0;
+	}
+	if (!resume_lv(origin->vg->cmd, origin)) {
+		log_error("Failed to resume %s.", origin->name);
+		return 0;
 	}
 
 	return 1;


