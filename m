From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:13 +0100
Subject: [PATCH 09/29] Remove check for lv is NULL
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <23421ea755e11ff7379ced9a1ea40b319b797fe7.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'lv' is deferenced in the begining of the function so any check
later is not helpful.

Parameters for dev_manager_transien() will be marked as nonnull.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cbb5378..cbd55f2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -614,14 +614,13 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &type,
 					  &params);
-		if (lv) {
-			if (!(segh = dm_list_next(&lv->segments, segh))) {
-				log_error("Number of segments in active LV %s "
-					  "does not match metadata", lv->name);
-				goto out;
-			}
-			seg = dm_list_item(segh, struct lv_segment);
+
+		if (!(segh = dm_list_next(&lv->segments, segh))) {
+		    log_error("Number of segments in active LV %s "
+			      "does not match metadata", lv->name);
+		    goto out;
 		}
+		seg = dm_list_item(segh, struct lv_segment);
 
 		if (!type || !params)
 			continue;
@@ -632,7 +631,7 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 
 	} while (next);
 
-	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+	if (segh = dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
-- 
1.7.3.2


