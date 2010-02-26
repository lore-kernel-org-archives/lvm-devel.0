From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Feb 2010 16:04:20 -0500
Subject: [PATCH 1/3] Use the origin's uuid as the basis for the shared cow's uuid.
In-Reply-To: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
References: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
Message-ID: <1267218262-23954-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is needed to allow proper cleanup of the shared cow now that we
only support info-by-uuid.  Using the cow's uuid relied on info-by-name
to cleanup the shared cow.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6583766..47de5d9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1179,8 +1179,12 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
 		unsigned n;
 		const char **snapids;
 		struct lv_list *lvl;
-		if (!(cow_dlid = build_dlid(dm,
-				     lv->shared_snapshot->cow->lvid.s, "cow")))
+		/*
+		 * Using origin uuid so info-by-uuid -cow cleanup works.
+		 * An origin with a shared snapshot store will only ever
+		 * have one -cow device.
+		 */
+		if (!(cow_dlid = build_dlid(dm, lv->lvid.s, "cow")))
 			return_0;
 		n = 0;
 		dm_list_iterate_items(lvl, &lv->vg->lvs) {
@@ -1300,8 +1304,9 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				  struct logical_volume *lv,
-				  const char *lv_name, const char *layer);
+				struct logical_volume *lv,
+				struct logical_volume *identity_lv,
+				const char *layer);
 
 static int _add_segment_to_dtree(struct dev_manager *dm,
 				   struct dm_tree *dtree,
@@ -1341,7 +1346,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 			return 0;
 		}
 		if (lv_is_multisnap_origin(seg->lv)) {
-			if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->shared_snapshot->cow, seg->lv->name, "cow"))
+			if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->shared_snapshot->cow, seg->lv, "cow"))
 				return_0;
 		} else if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
@@ -1394,7 +1399,8 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				struct logical_volume *lv,
-				const char *lv_name, const char *layer)
+				struct logical_volume *identity_lv,
+				const char *layer)
 {
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
@@ -1429,13 +1435,13 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_SHARED && !layer)
 		return 1;
 
-	if (!lv_name)
-		lv_name = lv->name;
+	if (!identity_lv)
+		identity_lv = lv;
 
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv_name, layer)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, identity_lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dlid(dm, identity_lv->lvid.s, layer)))
 		return_0;
 
 	/* We've already processed this node if it already has a context ptr */
@@ -1445,7 +1451,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
 		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  lv_name, layer);
+			  identity_lv->name, layer);
 		return 0;
 	}
 
-- 
1.6.5.2


