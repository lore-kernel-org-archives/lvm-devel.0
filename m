From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:32:54 +0000 (UTC)
Subject: master - cache: pending_delete fixes
Message-ID: <20141111123254.179D160092@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8121074fda126cc6c0df05fba066cc9365e00255
Commit:        8121074fda126cc6c0df05fba066cc9365e00255
Parent:        9a6e3683a292adec96a8e2421c86f4aae4756797
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 11 13:31:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 11 13:32:41 2014 +0100

cache: pending_delete fixes

---
 lib/activate/dev_manager.c |   18 +++++++++++-------
 lib/metadata/cache_manip.c |    5 ++++-
 lib/metadata/lv_manip.c    |   19 +++++++++++++++----
 lib/metadata/pool_manip.c  |   19 ++++++++++++++++---
 4 files changed, 46 insertions(+), 15 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4dc08d2..4351bc9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1969,15 +1969,14 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	if (lv_is_cache_pool(lv)) {
 		if (!dm_list_empty(&lv->segs_using_this_lv)) {
-			/* origin_only is ignored */
-			/* cache pool is 'meta' LV and does not have a real device node */
 			if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), 0))
 				return_0;
 			if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->metadata_lv, 0))
 				return_0;
-		} else if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
-			return_0; /* For internal use - empty pool makes meta visible */
-		return 1;
+			/* Cache pool does not have a real device node */
+			return 1;
+		}
+		/* Unused cache pool is activated as metadata */
 	}
 
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
@@ -2988,14 +2987,19 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 			continue;
 
 		/* FIXME: we still occasionally need to activate these at top-level */
-		if (strstr(lvname, "_tmeta") || strstr(lvname, "_tdata"))
+		if (((name = strstr(lvname, "_tmeta")) && !name[6]) ||
+		    ((name = strstr(lvname, "_tdata")) && !name[6]))
 			continue;
 
 		/* If operation was performed on a partial tree, don't remove it */
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
+		if ((name = strstr(lvname, "_corig")) && !name[6]) {
+			/* FIXME: for now just for _corig deactivate LVM subtree, should be generic */
+			if (!dm_tree_deactivate_children(root, "LVM-", 4))
+				return_0;
+		} else if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
 			return_0;
 	}
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6c74e57..9c69970 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -246,8 +246,11 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
-	if (lv_is_pending_delete(cache_lv))
+	if (lv_is_pending_delete(cache_lv)) {
+		log_error(INTERNAL_ERROR "LV %s is already dropped cache volume.",
+			  display_lvname(cache_lv));
 		goto remove;  /* Already dropped */
+	}
 
 	/* Localy active volume is needed for writeback */
 	if (!lv_is_active_locally(cache_lv)) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 20bf76f..a6ab3d3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1280,9 +1280,19 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 				return_0;
 
 			/* Remove cache origin only when removing (not on lv_empty()) */
-			if (delete && seg_is_cache(seg) &&
-			    !lv_is_pending_delete(seg->lv) && !lv_remove(seg_lv(seg, 0)))
-				return_0;
+			if (delete && seg_is_cache(seg)) {
+				if (lv_is_pending_delete(seg->lv)) {
+					/* Just dropping reference on origin when pending delete */
+					if (!remove_seg_from_segs_using_this_lv(seg_lv(seg, 0), seg))
+						return_0;
+					seg_lv(seg, 0) = NULL;
+					seg_le(seg, 0) = 0;
+					seg_type(seg, 0) = AREA_UNASSIGNED;
+					if (seg->pool_lv && !detach_pool_lv(seg))
+						return_0;
+				} else if (!lv_remove(seg_lv(seg, 0)))
+					return_0;
+			}
 
 			if ((pool_lv = seg->pool_lv)) {
 				if (!detach_pool_lv(seg))
@@ -5383,6 +5393,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 
 		if ((force == PROMPT) &&
+		    !lv_is_pending_delete(lv) &&
 		    lv_is_visible(lv) &&
 		    lv_is_active(lv)) {
 			if (yes_no_prompt("Do you really want to remove%s active "
@@ -5406,7 +5417,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_cache(lv)) {
+	if (lv_is_cache(lv) && !lv_is_pending_delete(lv)) {
 		if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, force,
 				      suppress_remove_message)) {
 			if (force < DONT_PROMPT_OVERRIDE) {
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b2e99f1..70b5a23 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -217,10 +217,23 @@ int detach_pool_lv(struct lv_segment *seg)
 
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
-	struct lv_segment *pool_seg;
+	struct lv_segment *pool_seg = NULL;
+	struct seg_list *sl;
 
-	if (!(pool_seg = get_only_segment_using_this_lv(seg->lv)))
-		return_NULL;
+	dm_list_iterate_items(sl, &seg->lv->segs_using_this_lv) {
+		/* Needs to be he only item in list */
+		if (lv_is_pending_delete(sl->seg->lv))
+			continue;
+
+		if (pool_seg) {
+			log_error("%s is referenced by more then one segments (%s, %s).",
+				  display_lvname(seg->lv), display_lvname(pool_seg->lv),
+				  display_lvname(sl->seg->lv));
+			return NULL; /* More then one segment */
+		}
+
+		pool_seg = sl->seg;
+	}
 
 	if ((lv_is_thin_type(seg->lv) && !seg_is_pool(pool_seg))) {
 		log_error("%s on %s is not a %s pool segment",


