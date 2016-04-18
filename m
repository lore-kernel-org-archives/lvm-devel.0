From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 10:59:03 +0000 (UTC)
Subject: master - thin: improve recognizing of merge in progress
Message-ID: <20160418105903.BAD5661B7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cccf5245a97a64f900f253fcf948edd5d7ba8c0
Commit:        9cccf5245a97a64f900f253fcf948edd5d7ba8c0
Parent:        e2cd882f2eef93f02711c34a741bd85d6313eb6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 11:04:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 12:32:52 2016 +0200

thin: improve recognizing of merge in progress

Rewrite too condensed condition in more readable form,
wher decision are clearly separated and commented and
also add debug messages for them.
---
 lib/activate/dev_manager.c |   59 ++++++++++++++++++++++++++++++++------------
 1 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6659190..2b108c9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2764,25 +2764,52 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
 		 * either origin or merging snapshot are open
-		 * - but use "snapshot-merge" if it is already in use
+		 * - for old snaps use "snapshot-merge" if it is already in use
 		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
 		 *   so just use the tree's existing nodes' info
 		 */
-		/* An activating merging origin won't have a node in the tree yet */
-		if (((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL)) &&
-		     dinfo->open_count) ||
-		    ((dinfo = _cached_dm_info(dm->mem, dtree,
-					      seg_is_thin_volume(seg) ?
-					      seg->lv : seg->cow, NULL)) &&
-		     dinfo->open_count))
-			snap_dev_is_open = 1;
-
-		/* Preload considers open devices. */
-		/* Resume looks at the table that will be the live one after the operation. */
-		if ((!laopts->resuming && snap_dev_is_open && (seg_is_thin_volume(seg) || !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) ||
-		    (laopts->resuming &&
-		     ((!seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE)) ||
-		      (seg_is_thin_volume(seg) && !_thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id))))) {
+		if ((dinfo = _cached_dm_info(dm->mem, dtree,
+					     seg_is_thin_volume(seg) ?
+					     seg->lv : seg->cow, NULL))) {
+			if (seg_is_thin_volume(seg)) {
+				/* Active thin snapshot prevents merge */
+				log_debug_activation("Merging thin snapshot %s is active.",
+						     display_lvname(seg->lv));
+			} else if (dinfo->open_count) {
+				log_debug_activation("Merging snapshot LV %s is openned.",
+						     display_lvname(seg->lv));
+				snap_dev_is_open = 1;
+			}
+		}
+
+		if ((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL))) {
+			if (dinfo->open_count) {
+				log_debug_activation("Merging origin volume %s is openned.", display_lvname(seg->lv));
+				snap_dev_is_open = 1;
+			}
+
+			/* Check if decision needs to be preserved.
+			 * Merging origin LV needs to be present in table in this case. */
+			if (!laopts->resuming) {
+				if ((seg_is_thin_volume(seg) && _thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
+				    (!seg_is_thin_volume(seg) && lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+					log_debug_activation("Merging of snapshot volume %s is in progress.",
+							     display_lvname(seg->lv));
+					/* Merging is already running and cannot be switched */
+					snap_dev_is_open = 0;
+				}
+			} else {
+				if ((seg_is_thin_volume(seg) && !_thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
+				    (!seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+					log_debug_activation("Merging of snapshot volume %s was not started before suspend.",
+							     display_lvname(seg->lv));
+					/* Merging targe table cannot be reloaded when suspend */
+					snap_dev_is_open = 1;
+				}
+			}
+		}
+
+		if (snap_dev_is_open) {
 			log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
 			laopts->no_merging = 1;
 		}


