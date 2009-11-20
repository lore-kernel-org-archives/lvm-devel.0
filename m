From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:45 -0500
Subject: [PATCH 05/15] device-mapper-merging-store-needs-cow-suffix
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-6-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Merging device is loaded with "-cow" suffix and with base name of the
origin.  This is needed so that "-cow" device can be found and removed
when lvremove is performed.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
---
 lib/activate/dev_manager.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ed05f95..7208ecd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1047,16 +1047,28 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
-	char *name, *dlid;
+	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
-	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE && !layer)
-		return 1;
+	lv_name = lv->name;
+	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE) {
+		if (layer) {
+			/*
+			 * use origin's name as basis for snapshot-merge device names;
+			 * this allows _clean_tree to automatically cleanup "-cow"
+			 * when the origin is resumed (after merge completes)
+			 */
+			lv_name = origin_from_cow(lv)->name;
+		} else {
+			/* top-level snapshot device is not needed during merge */
+			return 1;
+		}
+	}
 
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv_name, layer)))
 		return_0;
 
 	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
@@ -1068,7 +1080,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
-		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv->name, layer);
+		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv_name, layer);
 		return 0;
 	}
 
-- 
1.6.5.2


