From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:01 +0000 (UTC)
Subject: master - cache: use remove_layer_from_lv
Message-ID: <20140401185601.1A3676092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3004479cc0fa1fac3bd340cfb0c306a1f088280
Commit:        d3004479cc0fa1fac3bd340cfb0c306a1f088280
Parent:        0a15a210a532f7d1d46b042adbd8d3c65793f103
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 18:02:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:17:10 2014 +0200

cache: use remove_layer_from_lv

Since the usability problem were fixed, we can use this function.
Cleanup orphan LVs with TEMPORARY flags
(reduces couple blkid error reports, but couple of them
is still left...)
---
 lib/metadata/cache_manip.c |   91 +++++++++++++++++++++++++++----------------
 lib/metadata/lv_manip.c    |    2 -
 lib/metadata/pool_manip.c  |    1 +
 3 files changed, 58 insertions(+), 36 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 673d90e..4c41010 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -141,6 +141,30 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	return cache_lv;
 }
 
+
+/*
+ * Cleanup orphan device in the table with temporary activation
+ * since in the suspend() we can't deactivate unused nodes
+ * and the resume() phase mishandles orphan nodes.
+ *
+ * TODO: improve libdm to handle this case automatically
+ */
+static int _cleanup_orphan_lv(struct logical_volume *lv)
+{
+	lv->status |= LV_TEMPORARY;
+	if (!activate_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to activate temporary %s", lv->name);
+		return 0;
+	}
+	if (!deactivate_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to deactivate temporary %s", lv->name);
+		return 0;
+	}
+	lv->status &= ~LV_TEMPORARY;
+
+	return 1;
+}
+
 /*
  * lv_cache_remove
  * @cache_lv
@@ -157,14 +181,19 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct cmd_context *cmd = cache_lv->vg->cmd;
 	char *policy_name;
 	uint64_t dirty_blocks;
-	struct segment_type *segtype;
 	struct lv_segment *cache_seg = first_seg(cache_lv);
-	struct logical_volume *origin_lv;
+	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
 
 	if (!lv_is_cache(cache_lv))
 		return_0;
 
+	/* Active volume is needed (writeback only?) */
+	if (!activate_lv(cache_lv->vg->cmd, cache_lv)) {
+		log_error("Failed to active cache %s.", cache_lv->name);
+		return 0;
+	}
+
 	/*
 	 * FIXME:
 	 * Before the link can be broken, we must ensure that the
@@ -217,40 +246,24 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 			sleep(5);
 	} while (dirty_blocks);
 
-	cache_pool_lv = first_seg(cache_lv)->pool_lv;
-	if (!detach_pool_lv(first_seg(cache_lv)))
+	cache_pool_lv = cache_seg->pool_lv;
+	if (!detach_pool_lv(cache_seg))
 		return_0;
 
-	origin_lv = seg_lv(first_seg(cache_lv), 0);
-	lv_set_visible(origin_lv);
-
-//FIXME: We should be able to use 'remove_layer_from_lv', but
-//       there is a call to 'lv_empty' in there that recursively
-//       deletes everything down the tree - including the origin_lv
-//       that we are trying to preserve!
-//	if (!remove_layer_from_lv(cache_lv, origin_lv))
-//		return_0;
-
-	if (!remove_seg_from_segs_using_this_lv(origin_lv, first_seg(cache_lv)))
-		return_0;
-	if (!move_lv_segments(cache_lv, origin_lv, 0, 0))
-		return_0;
-
-	cache_lv->status &= ~CACHE;
-
-	segtype = get_segtype_from_string(cmd, "error");
-	if (!lv_add_virtual_segment(origin_lv, 0,
-				    cache_lv->le_count, segtype, NULL))
-		return_0;
+	/* Regular LV which user may remove if there are problems */
+	corigin_lv = seg_lv(cache_seg, 0);
+	lv_set_visible(corigin_lv);
+	if (!remove_layer_from_lv(cache_lv, corigin_lv))
+			return_0;
 
 	if (!vg_write(cache_lv->vg))
 		return_0;
 
 	/*
-	 * suspend_lv on this cache LV will suspend all of the components:
+	 * suspend_lv on this cache LV suspends all components:
 	 * - the top-level cache LV
 	 * - the origin
-	 * - the cache_pool and all of its sub-LVs
+	 * - the cache_pool _cdata and _cmeta
 	 */
 	if (!suspend_lv(cmd, cache_lv))
 		return_0;
@@ -258,20 +271,30 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!vg_commit(cache_lv->vg))
 		return_0;
 
+	/* resume_lv on this (former) cache LV will resume all */
 	/*
-	 * resume_lv on this (former) cache LV will resume all
-	 * but the cache_pool LV.  It must be resumed seperately.
+	 * FIXME: currently we can't easily avoid execution of
+	 * blkid on resumed error device
 	 */
 	if (!resume_lv(cmd, cache_lv))
 		return_0;
-	if (!resume_lv(cmd, cache_pool_lv))
-		return_0;
 
-	if (!activate_lv(cmd, origin_lv))
+	/*
+	 * cleanup orphan devices
+	 *
+	 * FIXME:
+	 * fix _add_dev() to support this case better
+	 * since the should be handled interanlly by resume_lv()
+	 * which should autoremove any orhpans
+	 */
+	if (!_cleanup_orphan_lv(corigin_lv))  /* _corig */
+		return_0;
+	if (!_cleanup_orphan_lv(seg_lv(first_seg(cache_pool_lv), 0))) /* _cdata */
 		return_0;
-	if (!deactivate_lv(cmd, origin_lv))
+	if (!_cleanup_orphan_lv(first_seg(cache_pool_lv)->metadata_lv)) /* _cmeta */
 		return_0;
-	if (!lv_remove(origin_lv))
+
+	if (!lv_remove(corigin_lv))
 		return_0;
 
 	return 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 618c1a1..b939479 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5228,8 +5228,6 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
-	//FIXME: why do we empty the parent?  It removes everything below.
-	//This makes the function unusable for 'lv_cache_remove'
 	if (!lv_empty(parent))
 		return_0;
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index f414f3f..fe14034 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -113,6 +113,7 @@ int detach_pool_lv(struct lv_segment *seg)
 	if (seg_is_cache(seg)) {
 		if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
 			return_0;
+		seg->lv->status &= ~CACHE;
 		seg->pool_lv = NULL;
 		return 1;
 	}


