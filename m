From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:03 +0000 (UTC)
Subject: master - cleanup: rename function
Message-ID: <20141103132403.9923960E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b439a0b8e6fc99bcc66fe74c8675ceb4ab430d2
Commit:        1b439a0b8e6fc99bcc66fe74c8675ceb4ab430d2
Parent:        228e7ff767b916a033da6d83cfa6970c5cfaba00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 20:59:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: rename function

Make more clear dm_info type.
---
 lib/activate/dev_manager.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7b43e09..266c80a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -543,10 +543,10 @@ out:
 	return r;
 }
 
-static const struct dm_info *_cached_info(struct dm_pool *mem,
-					  struct dm_tree *dtree,
-					  const struct logical_volume *lv,
-					  const char *layer)
+static const struct dm_info *_cached_dm_info(struct dm_pool *mem,
+					     struct dm_tree *dtree,
+					     const struct logical_volume *lv,
+					     const char *layer)
 {
 	char *dlid;
 	const struct dm_tree_node *dnode;
@@ -1925,7 +1925,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!dm->activation) {
 			/* Setup callback for non-activation partial tree */
 			/* Activation gets own callback when needed */
-			/* TODO: extend _cached_info() to return dnode */
+			/* TODO: extend _cached_dm_info() to return dnode */
 			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 				return_0;
 			if ((node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
@@ -1938,7 +1938,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!dm->activation) {
 			/* Setup callback for non-activation partial tree */
 			/* Activation gets own callback when needed */
-			/* TODO: extend _cached_info() to return dnode */
+			/* TODO: extend _cached_dm_info() to return dnode */
 			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 				return_0;
 			if ((node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
@@ -2409,8 +2409,8 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	dm_list_iterate_items(sl, &external_lv->segs_using_this_lv)
 		if ((sl->seg->external_lv == external_lv) &&
 		    /* Add only active layered devices (also avoids loop) */
-		    _cached_info(dm->mem, dtree, sl->seg->lv,
-				 lv_layer(sl->seg->lv)) &&
+		    _cached_dm_info(dm->mem, dtree, sl->seg->lv,
+				    lv_layer(sl->seg->lv)) &&
 		    !_add_new_lv_to_dtree(dm, dtree, sl->seg->lv,
 					  laopts, lv_layer(sl->seg->lv)))
 			return_0;
@@ -2585,11 +2585,11 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 *   so just use the tree's existing nodes' info
 		 */
 		/* An activating merging origin won't have a node in the tree yet */
-		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
+		if (((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL)) &&
 		     dinfo->open_count) ||
-		    ((dinfo = _cached_info(dm->mem, dtree,
-					   seg_is_thin_volume(seg) ?
-					   seg->lv : seg->cow, NULL)) &&
+		    ((dinfo = _cached_dm_info(dm->mem, dtree,
+					      seg_is_thin_volume(seg) ?
+					      seg->lv : seg->cow, NULL)) &&
 		     dinfo->open_count)) {
 			if (seg_is_thin_volume(seg) ||
 			    /* FIXME Is there anything simpler to check for instead? */


