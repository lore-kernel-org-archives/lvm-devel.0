From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:06 +0000 (UTC)
Subject: master - pools: move removal of _pmspare
Message-ID: <20141006133306.580FA611CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb273fe16423a2868c0bdde7c8e56cb21131338d
Commit:        cb273fe16423a2868c0bdde7c8e56cb21131338d
Parent:        20803f2275d9eb08344c4882e62381cf23454eba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 23:34:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

pools: move removal of _pmspare

Since _pmspare is internal volume move it to
lv_remove_single -  so it's automatically removed with
last remove thin-pool.

lv_remove_with_dependencies() is not always used for pool removal.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   43 +++++++++++++++++++++++--------------------
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8341d8d..3d5f9c4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Always remove spare LV with last removed pool volume.
   Support lvconvert --splitcache and --uncache of cached LV.
   Option --cache has also shortcut -H (i.e. lvcreate -H).
   Refactor lvcreate code and better preserve --type argument.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 25342d6..00f0fbc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5369,6 +5369,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *pool_lv = NULL;
 	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
+	struct lv_list *lvl;
+	int is_last_pool;
 
 	vg = lv->vg;
 
@@ -5463,6 +5465,27 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 	}
 
+	if (lv_is_pool(lv) && lv->vg->pool_metadata_spare_lv) {
+		/* When removing last pool, also remove the spare */
+		is_last_pool = 1;
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_pool(lvl->lv) &&
+			    lvl->lv != lv) {
+				is_last_pool = 0;
+				break;
+			}
+		if (is_last_pool) {
+			/* This is purely internal LV volume, no question */
+			if (!deactivate_lv(cmd, lv->vg->pool_metadata_spare_lv)) {
+				log_error("Unable to deactivate logical volume %s",
+					  display_lvname(lv->vg->pool_metadata_spare_lv));
+				return 0;
+			}
+			if (!lv_remove(lv->vg->pool_metadata_spare_lv))
+				return_0;
+		}
+	}
+
 	if (lv_is_cache_pool(lv)) {
 		/* Cache pool removal drops cache layer
 		 * If the cache pool is not linked, we can simply remove it. */
@@ -5580,10 +5603,8 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	dm_percent_t snap_percent;
 	struct dm_list *snh, *snht;
-	struct lv_list *lvl;
 	struct lvinfo info;
 	struct logical_volume *origin;
-	int is_last_pool;
 
 	if (lv_is_cow(lv)) {
 		/*
@@ -5661,24 +5682,6 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
-	if ((lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) &&
-	    lv->vg->pool_metadata_spare_lv) {
-		/* When removing last pool, also remove the spare */
-		is_last_pool = 1;
-		dm_list_iterate_items(lvl, &lv->vg->lvs)
-			if ((lv_is_thin_pool(lvl->lv) ||
-			     lv_is_cache_pool(lvl->lv)) &&
-			    lvl->lv != lv) {
-				is_last_pool = 0;
-				break;
-			}
-
-		if (is_last_pool &&
-		    !lv_remove_with_dependencies(cmd, lv->vg->pool_metadata_spare_lv,
-						 DONT_PROMPT, level + 1))
-			return_0;
-	}
-
 	if (lv_is_pool_metadata_spare(lv) &&
 	    (force == PROMPT) &&
 	    (yes_no_prompt("Removal of pool metadata spare logical volume"


