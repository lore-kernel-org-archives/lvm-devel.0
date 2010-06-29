From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:05 +0200
Subject: [PATCH 05/12] Replicator: improve detection of replicator-dev
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <470952ef39d6ac6edeb28dc82f03f29040c683a7.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for NULL replicator pointer in replicator-dev segment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/merge.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 3b8895c..11c58f9 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -219,14 +219,20 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
-			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-				dm_list_iterate_items(rdev, &rsite->rdevices) {
-					if (lv == rdev->lv || lv == rdev->slog)
-						seg_found++;
+			if (!seg->replicator) {
+				log_error("LV %s has replicator-dev segment "
+					  "without replicator", lv->name);
+				inc_error_count;
+			} else {
+				dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+					dm_list_iterate_items(rdev, &rsite->rdevices) {
+						if (lv == rdev->lv || lv == rdev->slog)
+							seg_found++;
+					}
 				}
+				if (lv == seg->replicator)
+					seg_found++;
 			}
-			if (lv == seg->replicator)
-				seg_found++;
 		}
 		if (seg_is_replicator(seg) && lv == seg->rlog_lv)
 				seg_found++;
-- 
1.7.1


