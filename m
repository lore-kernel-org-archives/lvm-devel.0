From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 21:13:58 +0000 (UTC)
Subject: master - snapshot: improve merge
Message-ID: <20160418211358.A2D2561E15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e5881dd131e6f521f8f419edc3bb42e575d693a
Commit:        7e5881dd131e6f521f8f419edc3bb42e575d693a
Parent:        d1c1f60047bb6973eee432ea14f93058a836faac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 22:54:27 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 23:05:17 2016 +0200

snapshot: improve merge

Improve code for snapshot merge for readabilty
and also reduce number of tests needed to decide
if merging can or cannot be started.

(Further improving 9cccf5245a97a64f900f253fcf948edd5d7ba8c0)
---
 lib/activate/dev_manager.c |   77 +++++++++++++++++++++-----------------------
 1 files changed, 37 insertions(+), 40 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b155039..5b1e226 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2741,7 +2741,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	int save_pending_delete = dm->track_pending_delete;
-	int snap_dev_is_open = 0;
+	int merge_in_progress = 0;
 
 	/* LV with pending delete is never put new into a table */
 	if (lv_is_pending_delete(lv) && !_cached_dm_info(dm->mem, dtree, lv, NULL))
@@ -2762,57 +2762,52 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!layer && lv_is_merging_origin(lv)) {
 		seg = find_snapshot(lv);
 		/*
-		 * Clear merge attributes if merge isn't currently possible:
+		 * Prevent merge if merge isn't currently possible:
 		 * either origin or merging snapshot are open
 		 * - for old snaps use "snapshot-merge" if it is already in use
 		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
 		 *   so just use the tree's existing nodes' info
 		 */
-		if ((dinfo = _cached_dm_info(dm->mem, dtree,
+		if ((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL))) {
+			/* Merging origin LV is present, check if mergins is already running. */
+			if ((seg_is_thin_volume(seg) && _thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
+			    (!seg_is_thin_volume(seg) && lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+				log_debug_activation("Merging of snapshot volume %s to origin %s is in progress.",
+						     display_lvname(seg->lv), display_lvname(seg->lv));
+				merge_in_progress = 1; /* Merge is already running */
+			} /* Merge is not yet running, so check if it can be started */
+			else if (laopts->resuming) {
+				log_debug_activation("Postponing pending snapshot merge for origin %s, "
+						     "merge was not started before suspend.",
+						     display_lvname(lv));
+				laopts->no_merging = 1; /* Cannot be reloaded in suspend */
+			} /* Non-resuming merge requires origin to be unused */
+			else if (dinfo->open_count) {
+				log_debug_activation("Postponing pending snapshot merge for origin %s, "
+						     "origin volume is opened.",
+						     display_lvname(lv));
+				laopts->no_merging = 1;
+			}
+		}
+
+		/* If merge would be still undecided, look as snapshot */
+		if (!merge_in_progress && !laopts->no_merging &&
+		    (dinfo = _cached_dm_info(dm->mem, dtree,
 					     seg_is_thin_volume(seg) ?
 					     seg->lv : seg->cow, NULL))) {
 			if (seg_is_thin_volume(seg)) {
 				/* Active thin snapshot prevents merge */
-				log_debug_activation("Merging thin snapshot %s is active.",
-						     display_lvname(seg->lv));
+				log_debug_activation("Postponing pending snapshot merge for origin volume %s, "
+						     "merging thin snapshot volume %s is active.",
+						     display_lvname(lv), display_lvname(seg->lv));
+				laopts->no_merging = 1;
 			} else if (dinfo->open_count) {
-				log_debug_activation("Merging snapshot LV %s is openned.",
-						     display_lvname(seg->lv));
-				snap_dev_is_open = 1;
+				log_debug_activation("Postponing pending snapshot merge for origin volume %s, "
+						     "merging snapshot volume %s is opened.",
+						     display_lvname(lv), display_lvname(seg->lv));
+				laopts->no_merging = 1;
 			}
 		}
-
-		if ((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL))) {
-			if (dinfo->open_count) {
-				log_debug_activation("Merging origin volume %s is openned.", display_lvname(seg->lv));
-				snap_dev_is_open = 1;
-			}
-
-			/* Check if decision needs to be preserved.
-			 * Merging origin LV needs to be present in table in this case. */
-			if (!laopts->resuming) {
-				if ((seg_is_thin_volume(seg) && _thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
-				    (!seg_is_thin_volume(seg) && lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
-					log_debug_activation("Merging of snapshot volume %s is in progress.",
-							     display_lvname(seg->lv));
-					/* Merging is already running and cannot be switched */
-					snap_dev_is_open = 0;
-				}
-			} else {
-				if ((seg_is_thin_volume(seg) && !_thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
-				    (!seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
-					log_debug_activation("Merging of snapshot volume %s was not started before suspend.",
-							     display_lvname(seg->lv));
-					/* Merging targe table cannot be reloaded when suspend */
-					snap_dev_is_open = 1;
-				}
-			}
-		}
-
-		if (snap_dev_is_open) {
-			log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
-			laopts->no_merging = 1;
-		}
 	}
 
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
@@ -3163,6 +3158,8 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
 			goto_out;
 
+		//if (action == PRELOAD) { log_debug("SLEEP"); sleep(7); }
+
 		if ((dm_tree_node_size_changed(root) < 0))
 			dm->flush_required = 1;
 		/* Currently keep the code require flush for any


