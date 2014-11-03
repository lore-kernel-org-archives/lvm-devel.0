From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:49 +0000 (UTC)
Subject: master - cache: support activation of empty cache-pool
Message-ID: <20141103132349.00A4460243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29bd3cccc8de8949754edfe3d5a4c490627d5fa5
Commit:        29bd3cccc8de8949754edfe3d5a4c490627d5fa5
Parent:        ab491204659ef08a9a71379cab835650901b31ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 19:34:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: support activation of empty cache-pool

When the cache pool is unused, lvm2 code will internally
allow to activate such cache-pool.

Cache-pool is activate as metadata LV, so lvm2 could easily
wipe such volume before cache-pool is reused.
---
 lib/activate/dev_manager.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e9b6816..9272742 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1867,12 +1867,15 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	const char *uuid;
 
 	if (lv_is_cache_pool(lv)) {
-		/* origin_only is ignored */
-		/* cache pool is 'meta' LV and does not have a real device node */
-		if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), 0))
-			return_0;
-		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->metadata_lv, 0))
-			return_0;
+		if (!dm_list_empty(&lv->segs_using_this_lv)) {
+			/* origin_only is ignored */
+			/* cache pool is 'meta' LV and does not have a real device node */
+			if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), 0))
+				return_0;
+			if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->metadata_lv, 0))
+				return_0;
+		} else if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+			return_0; /* For internal use - empty pool makes meta visible */
 		return 1;
 	}
 
@@ -2560,7 +2563,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 
-	if (lv_is_cache_pool(lv)) {
+	if (lv_is_cache_pool(lv) &&
+	    !dm_list_empty(&lv->segs_using_this_lv)) {
 		/* cache pool is 'meta' LV and does not have a real device node */
 		if (!_add_new_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), laopts, NULL))
 			return_0;
@@ -2637,6 +2641,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
 
+	/* This is unused cache-pool - make metadata accessible */
+	if (lv_is_cache_pool(lv))
+		lv = first_seg(lv)->metadata_lv;
+
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	/* Snapshot origin could be also external origin */
@@ -2853,7 +2861,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 
 	/* Some LV can be used for top level tree */
 	/* TODO: add more.... */
-	if (lv_is_cache_pool(lv)) {
+	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
 		log_error(INTERNAL_ERROR "Cannot create tree for %s.", lv->name);
 		return 0;
 	}


