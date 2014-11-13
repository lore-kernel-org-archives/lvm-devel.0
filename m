From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 10:56:43 +0000 (UTC)
Subject: master - pool: fix removal of pool metadata spare
Message-ID: <20141113105643.2705260D56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d39504b6bd904e7b4812d6226c31a29ad2937e6
Commit:        1d39504b6bd904e7b4812d6226c31a29ad2937e6
Parent:        fba86dd42b57626aa276e4f31e56e5d2a4384e48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 11:53:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 11:55:53 2014 +0100

pool: fix removal of pool metadata spare

Since we support device stack of pools over pool
(thin-pool with cache data volume) the existing code
is no longer able to detect orphan _pmspare.

So instead do a _pmspare check after volume removal,
and remove spare afterwards.
---
 lib/metadata/lv_manip.c             |   85 +++++++++++++++++++----------------
 test/shell/pvmove-cache-segtypes.sh |    5 ++
 2 files changed, 51 insertions(+), 39 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 543f070..ab2ffa1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1318,6 +1318,11 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	if (!delete)
 		return 1;
 
+	if (lv == lv->vg->pool_metadata_spare_lv) {
+		lv->status &= ~POOL_METADATA_SPARE;
+		lv->vg->pool_metadata_spare_lv = NULL;
+	}
+
 	/* Remove the LV if it is now empty */
 	if (!lv->le_count && !unlink_lv_from_vg(lv))
 		return_0;
@@ -5334,7 +5339,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int ask_discard;
 	struct lv_list *lvl;
 	struct seg_list *sl;
-	int is_last_pool;
+	int is_last_pool = lv_is_pool(lv);
 
 	vg = lv->vg;
 
@@ -5428,11 +5433,32 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			log_print_unless_silent("Ignoring uncache failure of %s.",
 						display_lvname(lv));
 		}
+		is_last_pool = 1;
+	}
+
+	if ((!lv_is_cache_pool(lv) || dm_list_empty(&lv->segs_using_this_lv)) &&
+	    !deactivate_lv(cmd, lv)) {
+		/* FIXME Review and fix the snapshot error paths! */
+		log_error("Unable to deactivate logical volume %s.",
+			  display_lvname(lv));
+		return 0;
 	}
 
 	if (!archive(vg))
 		return 0;
 
+	/* Clear thin pool stacked messages */
+	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
+	    !update_pool_lv(pool_lv, 1)) {
+		if (force < DONT_PROMPT_OVERRIDE) {
+			log_error("Failed to update pool %s.", display_lvname(pool_lv));
+			return 0;
+		}
+		log_print_unless_silent("Ignoring update failure of pool %s.",
+					display_lvname(pool_lv));
+		pool_lv = NULL; /* Do not retry */
+	}
+
 	/* When referenced by the LV with pending delete flag, remove this deleted LV first */
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 		if (lv_is_pending_delete(sl->seg->lv) && !lv_remove(sl->seg->lv)) {
@@ -5452,27 +5478,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 	}
 
-	if (lv_is_pool(lv) && lv->vg->pool_metadata_spare_lv) {
-		/* When removing last pool, also remove the spare */
-		is_last_pool = 1;
-		dm_list_iterate_items(lvl, &lv->vg->lvs)
-			if (lv_is_pool(lvl->lv) &&
-			    lvl->lv != lv) {
-				is_last_pool = 0;
-				break;
-			}
-		if (is_last_pool) {
-			/* This is purely internal LV volume, no question */
-			if (!deactivate_lv(cmd, lv->vg->pool_metadata_spare_lv)) {
-				log_error("Unable to deactivate logical volume %s",
-					  display_lvname(lv->vg->pool_metadata_spare_lv));
-				return 0;
-			}
-			if (!lv_remove(lv->vg->pool_metadata_spare_lv))
-				return_0;
-		}
-	}
-
 	if (lv_is_cache_pool(lv)) {
 		/* Cache pool removal drops cache layer
 		 * If the cache pool is not linked, we can simply remove it. */
@@ -5483,23 +5488,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			if (!lv_cache_remove(cache_seg->lv))
 				return_0;
 		}
-	} else if (!deactivate_lv(cmd, lv)) {
-		/* FIXME Review and fix the snapshot error paths! */
-		log_error("Unable to deactivate logical volume \"%s\"",
-			  lv->name);
-		return 0;
-	}
-
-	/* Clear thin pool stacked messages */
-	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
-	    !update_pool_lv(pool_lv, 1)) {
-		if (force < DONT_PROMPT_OVERRIDE) {
-			log_error("Failed to update pool %s.", display_lvname(pool_lv));
-			return 0;
-		}
-		log_print_unless_silent("Ignoring update failure of pool %s.",
-					display_lvname(pool_lv));
-		pool_lv = NULL; /* Do not retry */
 	}
 
 	visible = lv_is_visible(lv);
@@ -5510,6 +5498,25 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (is_last_pool && vg->pool_metadata_spare_lv) {
+		/* When removed last pool, also remove the spare */
+		dm_list_iterate_items(lvl, &vg->lvs)
+			if (lv_is_pool_metadata(lvl->lv)) {
+				is_last_pool = 0;
+				break;
+			}
+		if (is_last_pool) {
+			/* This is purely internal LV volume, no question */
+			if (!deactivate_lv(cmd, vg->pool_metadata_spare_lv)) {
+				log_error("Unable to deactivate spare logical volume %s.",
+					  display_lvname(vg->pool_metadata_spare_lv));
+				return 0;
+			}
+			if (!lv_remove(vg->pool_metadata_spare_lv))
+				return_0;
+		}
+	}
+
 	/*
 	 * Old format1 code: If no snapshots left reload without -real.
 	 */
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 9eaf186..2f09596 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -56,6 +56,7 @@ not check lv_tree_on $vg ${lv1}_pool "$dev5"
 #check lv_tree_on $vg ${lv1}_foo "$dev5"
 
 lvremove -ff $vg
+dmsetup info -c | not grep $vg
 
 # Testing pvmove of origin LV
 #############################
@@ -82,6 +83,7 @@ not check lv_tree_on $vg ${lv1} "$dev3"
 #check lv_tree_on $vg ${lv1} "$dev1"
 #check dev_md5sum $vg $lv1
 lvremove -ff $vg
+dmsetup info -c | not grep $vg
 
 # Testing pvmove of a RAID origin LV
 ####################################
@@ -106,6 +108,7 @@ not check lv_tree_on $vg ${lv1} "$dev2" "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
 #check dev_md5sum $vg $lv1
 lvremove -ff $vg
+dmsetup info -c | not grep $vg
 
 # Testing pvmove of a RAID cachepool (metadata and data)
 ########################################################
@@ -137,6 +140,7 @@ not check lv_tree_on $vg ${lv1}_pool "$dev2" "$dev3"
 #check lv_tree_on $vg ${lv1} "$dev5"
 #check dev_md5sum $vg $lv1
 lvremove -ff $vg
+dmsetup info -c | not grep $vg
 
 # Testing pvmove of Thin-pool on cache LV on RAID
 #################################################
@@ -177,5 +181,6 @@ check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
 #check dev_md5sum $vg/thin_lv
 
 lvremove -ff $vg
+dmsetup info -c | not grep $vg
 
 done


