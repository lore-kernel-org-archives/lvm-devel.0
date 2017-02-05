From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  5 Feb 2017 16:56:41 +0000 (UTC)
Subject: master - cleanup: rename to use track_ prefix
Message-ID: <20170205165641.2099D60C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb3f4ed72d6be15e99fdfe490049264eecc07997
Commit:        fb3f4ed72d6be15e99fdfe490049264eecc07997
Parent:        dae4f53acb269219e876c229c8f034fcdaf3ff5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 4 15:02:34 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 5 17:55:37 2017 +0100

cleanup: rename to use track_  prefix

Since we use 'track_' prefix for other deps tracking,
convert skip_external_lv to use same logical meaning.
(just converts  1->0  0->1)
---
 lib/activate/dev_manager.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6df254a..d36f113 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -61,7 +61,7 @@ struct dev_manager {
 	int flush_required;
 	int activation;                 /* building activation tree */
 	int suspend;			/* building suspend tree */
-	int skip_external_lv;
+	unsigned track_external_lv_deps;
 	struct dm_list pending_delete;	/* str_list of dlid(s) with pending delete */
 	unsigned track_pending_delete;
 	unsigned track_pvmove_deps;
@@ -2039,16 +2039,16 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 #endif
 	}
 
-	if (origin_only && dm->activation && !dm->skip_external_lv &&
+	if (origin_only && dm->activation && dm->track_external_lv_deps &&
 	    lv_is_external_origin(lv)) {
 		/* Find possible users of external origin lv */
-		dm->skip_external_lv = 1; /* avoid recursion */
+		dm->track_external_lv_deps = 0; /* avoid recursion */
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			/* Match only external_lv users */
 			if ((sl->seg->external_lv == lv) &&
 			    !_add_lv_to_dtree(dm, dtree, sl->seg->lv, 1))
 				return_0;
-		dm->skip_external_lv = 0;
+		dm->track_external_lv_deps = 1;
 	}
 
 	if (lv_is_thin_pool(lv)) {
@@ -2148,7 +2148,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->external_lv && !dm->skip_external_lv &&
+		if (seg->external_lv && dm->track_external_lv_deps &&
 		    !_add_lv_to_dtree(dm, dtree, seg->external_lv, 1)) /* stack */
 			return_0;
 		if (seg->log_lv &&
@@ -2158,7 +2158,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
 		if (seg->pool_lv &&
-		    (lv_is_cache_pool(seg->pool_lv) || !dm->skip_external_lv) &&
+		    (lv_is_cache_pool(seg->pool_lv) || dm->track_external_lv_deps) &&
 		    /* When activating and not origin_only detect linear 'overlay' over pool */
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, dm->activation ? origin_only : 1))
 			return_0;
@@ -2575,7 +2575,7 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	struct seg_list *sl;
 
 	/* Do not want to recursively add externals again */
-	if (dm->skip_external_lv)
+	if (!dm->track_external_lv_deps)
 		return 1;
 
 	/*
@@ -2583,7 +2583,7 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	 * process all LVs related to this LV, and we want to
 	 * skip repeated invocation of external lv processing
 	 */
-	dm->skip_external_lv = 1;
+	dm->track_external_lv_deps = 0;
 
 	log_debug_activation("Adding external origin LV %s and all active users.",
 			     display_lvname(external_lv));
@@ -2609,7 +2609,7 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	log_debug_activation("Finished adding external origin LV %s and all active users.",
 			     display_lvname(external_lv));
 
-	dm->skip_external_lv = 0;
+	dm->track_external_lv_deps = 1;
 
 	return 1;
 }
@@ -3085,6 +3085,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	/* Some targets may build bigger tree for activation */
 	dm->activation = ((action == PRELOAD) || (action == ACTIVATE));
 	dm->suspend = (action == SUSPEND_WITH_LOCKFS) || (action == SUSPEND);
+	dm->track_external_lv_deps = 1;
 
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;


