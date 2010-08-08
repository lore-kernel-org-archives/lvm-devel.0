From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:21 +0200
Subject: [PATCH 09/25] Replicator: improve detection of replicated segment
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <429fb8190b94a30694861eacfa199406de3f6c99.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Switch from replicator-dev to replicated.
Check for NULL replicator pointer in replicated segment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/merge.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 3b8895c..314a7de 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -73,7 +73,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	struct seg_list *sl;
 	int error_count = 0;
 	struct replicator_site *rsite;
-	struct replicator_device *rdev;
+	struct replicated_device *rdev;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -218,15 +218,21 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			if (lv == seg_lv(seg, s))
 				seg_found++;
 		}
-		if (seg_is_replicator_dev(seg)) {
-			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-				dm_list_iterate_items(rdev, &rsite->rdevices) {
-					if (lv == rdev->lv || lv == rdev->slog)
-						seg_found++;
+		if (seg_is_replicated(seg)) {
+			if (!seg->replicator) {
+				log_error("LV %s has replicated segment "
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
1.7.2.1


