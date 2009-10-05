From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:34 +0200
Subject: [PATCH 07/13] Replicator: update _create_partial_dtree()
In-Reply-To: <1254751240-17431-6-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-5-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-6-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-7-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Creating partial tree for Replicator target.
Using dm_tree_set_priority() to set higher priority for Replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 55daf14..8ad737b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -730,6 +730,9 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 	struct dm_list *snh, *snht;
 	struct lv_segment *seg;
 	uint32_t s;
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	const char *replog_dlid;
 
 	if (!(dtree = dm_tree_create())) {
 		log_error("Partial dtree creation failed for %s.", lv->name);
@@ -745,12 +748,34 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 			goto_bad;
 
 	/* Add any LVs used by segments in this LV */
-	dm_list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
 				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s)))
 					goto_bad;
 			}
+		if (seg->replicator) {
+                        /* Add all replicator-dev from same replicator */
+			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+				dm_list_iterate_items(rdev, &rsite->rdevices) {
+					if (rsite->state == REPLICATOR_STATE_ACTIVE) {
+						if (!rdev->replicator_dev->lv)
+							goto_bad;
+						if (lv == rdev->replicator_dev->lv)
+                                                        continue;
+						/* Add replicator-dev LV */
+						if (!_add_lv_to_dtree(dm, dtree, rdev->replicator_dev->lv))
+							goto_bad;
+					}
+				}
+			}
+
+			if (!(replog_dlid = build_dlid(dm, seg->replicator->lvid.s, NULL)))
+				goto_bad;
+			if (!dm_tree_set_priority(dtree, replog_dlid, 1))
+				goto_bad;
+		}
+	}
 
 	return dtree;
 
-- 
1.6.5.rc2


