From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:07:52 +0000 (UTC)
Subject: master - cleanup: postpone lv_is_thin_volume check
Message-ID: <20130204180752.D2DC03523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f433e6ee34c0ff94017c940aac301bc28d7e233
Commit:        9f433e6ee34c0ff94017c940aac301bc28d7e233
Parent:        38e7b37c897da9cfae8cb3b77ea585b7616d9813
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 2 00:44:07 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:00:19 2013 +0100

cleanup: postpone lv_is_thin_volume check

Code move to make it easier to follow and
call _add_dev_to_dtree() in the separate if() branch
for thin volumes.
---
 lib/activate/dev_manager.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 843823f..fda5bdc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1557,8 +1557,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct dm_tree_node *thin_node;
 	const char *uuid;
 
-	if ((!origin_only || lv_is_thin_volume(lv)) &&
-	    !_add_dev_to_dtree(dm, dtree, lv, NULL))
+	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
@@ -1590,18 +1589,22 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	if (lv_is_thin_volume(lv)) {
-#if 0
-		/* FIXME Implement dm_tree_node_skip_children optimisation */
 		if (origin_only) {
+			/* origin_only has special meaning for thin volumes */
+			if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+				return_0;
+#if 0
+			/* FIXME Implement dm_tree_node_skip_children optimisation */
 			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 				return_0;
 			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
 				dm_tree_node_skip_children(thin_node, 1);
-		}
 #endif
-		/* Add thin pool LV layer */
-		lv = seg->pool_lv;
-		seg = first_seg(lv);
+		} else {
+			/* Add thin pool LV layer */
+			lv = seg->pool_lv;
+			seg = first_seg(lv);
+		}
 	}
 
 	if (!origin_only && lv_is_thin_pool(lv)) {


