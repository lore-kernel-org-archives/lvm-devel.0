From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 10:46:30 -0400
Subject: [PATCH] Test that all snapshots are not open before deactivating volume.
Message-ID: <1254235590-30312-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test that all snapshots are not open before deactivating volume.

This prevents very weird misbehavior when we have closed origin, open snapshot
and deactivate the origin with lvchange -an or vgchange -an command --- the
origin is closed, the snapshot remains open and cannot be deactivated.

There is still race condition if the snapshot is open immediately after the
test, but it is inevitable --- and the patch prevents misbehavior in most common
case.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 lib/activate/activate.c |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -1001,10 +1001,28 @@ int lv_deactivate(struct cmd_context *cm
 		goto out;
 	}
 
-	if (info.open_count && lv_is_visible(lv)) {
-		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
-			  lv->name);
-		goto out;
+	if (lv_is_visible(lv)) {
+		if (info.open_count) {
+			log_error("LV %s/%s in use: not deactivating",
+				  lv->vg->name, lv->name);
+			goto out;
+		}
+		if (lv_is_origin(lv)) {
+			struct lv_segment *snap_seg;
+			dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
+						  origin_list) {
+				struct logical_volume *snap = snap_seg->cow;
+				if (!lv_info(cmd, snap, &info, 1, 0))
+					goto out;
+
+				if (info.exists && info.open_count) {
+					log_error("LV %s/%s has open snapshot %s: "
+						  "not deactivating",
+						  lv->vg->name, lv->name, snap->name);
+					goto out;
+				}
+			}
+		}
 	}
 
 	lv_calculate_readahead(lv, NULL);


