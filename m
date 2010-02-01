From: Milan Broz <mbroz@redhat.com>
Date: Mon,  1 Feb 2010 11:51:18 +0100
Subject: [PATCH] Add mirror log to dependency tree using its UUID.
Message-ID: <1265021478-17029-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now depencecy tree calculation tries to add log device using
"_mlog" layer. It is wrong because log device do not use layering
(it has its own UUID without layer suffix).
It currently works because query is done only by name.

Because I plan to change all kernel dm info queries to use UUID only,
it must be rewritten to use proper UUID.

In ideal world we can use log_lv directly. Unfortunately the lvconvert
code is currently broken, so code must search for log_lv according to name
(it doesn't provide log_lv when it should).

(mornfall: please can we fix lvconvert to use proper LV struct
with log lv prepared? See _lv_update_log_type() confusion where
new log_lv get lost...)

For now, the patch below works... (with my later changes)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/dev_manager.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6023574..23cea2e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -823,8 +823,32 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
 	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if (!_add_dev_to_dtree(dm, dtree, lv, "_mlog"))
-		return_0;
+	return 1;
+}
+
+static int _add_mirrored_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+				     struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct lv_list *lvl;
+	char log_name[NAME_LEN];
+
+	if (seg->log_lv) {
+		if (!_add_dev_to_dtree(dm, dtree, seg->log_lv, NULL))
+			return_0;
+	} else {
+		/*
+		 * FIXME: This should not be needed at all!
+		 * Mirrored LV should have log_lv always updated, unfortunately
+		 * some convert operations use old LV struct here.
+		 * For now, try to find log LV using its reserved name.
+		 */
+		if (dm_snprintf(log_name, NAME_LEN, "%s_mlog", lv->name) < 0)
+			return_0;
+		if ((lvl = find_lv_in_vg(lv->vg, log_name)) &&
+		    !_add_dev_to_dtree(dm, dtree, lvl->lv, NULL))
+			return_0;
+	}
 
 	return 1;
 }
@@ -849,6 +873,9 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 		if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow))
 			goto_bad;
 
+	if ((lv->status & MIRRORED) && !_add_mirrored_lv_to_dtree(dm, dtree, lv))
+		goto_bad;
+
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
-- 
1.6.6.1


