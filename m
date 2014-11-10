From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:38 +0000 (UTC)
Subject: master - cache: use LV_PENDING_DELETE
Message-ID: <20141110210638.6654261069@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5e265a07fb3e083416d9f5cf17bd601a1e3f782
Commit:        f5e265a07fb3e083416d9f5cf17bd601a1e3f782
Parent:        f6932bfcf91cd317629d9c04007a495f2c05ae26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 10:56:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cache: use LV_PENDING_DELETE

---
 lib/activate/dev_manager.c       |   44 ++++++++++++++++++-
 lib/cache_segtype/cache.c        |    2 +
 lib/format_text/flags.c          |    1 +
 lib/metadata/cache_manip.c       |   86 ++++++++++++++++---------------------
 lib/metadata/lv.c                |    2 +
 lib/metadata/lv_manip.c          |   12 +++++-
 lib/metadata/metadata-exported.h |    5 ++-
 lib/misc/lvm-string.c            |    1 +
 lib/report/report.c              |    2 +-
 9 files changed, 100 insertions(+), 55 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e81c5d3..2c6ed50 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1941,8 +1941,14 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
-	if (!origin_only && lv_is_cache(lv)) {
-		if (!dm->activation) {
+	if (lv_is_cache(lv)) {
+		if (lv_is_pending_delete(lv)) {
+			if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, 1)) /* stack */
+				return_0;
+			/* Orhan cache LV exits here */
+			return 1;
+		}
+		if (!origin_only && !dm->activation) {
 			/* Setup callback for non-activation partial tree */
 			/* Activation gets own callback when needed */
 			/* TODO: extend _cached_dm_info() to return dnode */
@@ -1972,6 +1978,14 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		dm->track_pvmove_deps = 1;
 	}
 
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (lv_is_pending_delete(sl->seg->lv) && lv_is_cache(sl->seg->lv)) {
+			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+				return_0;
+			break;
+		}
+	}
+
 	/* Adding LV head of replicator adds all other related devs */
 	if (lv_is_replicator_dev(lv) &&
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
@@ -2652,6 +2666,30 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
 
+	if (lv_is_pending_delete(lv)) {
+		/* Handle LVs with pending delete */
+		if (lv_is_cache(lv)) {
+			/* Use 'error' for cache, metadata and data volumes */
+			seg = first_seg(lv);
+			if (!dm_tree_node_add_error_target(dnode, seg_lv(seg, 0)->size))
+				return_0;
+			seg = first_seg(seg->pool_lv);
+			if (!(dlid = build_dm_uuid(dm->mem, seg->metadata_lv, NULL)))
+				return_0;
+			if ((dnode = dm_tree_find_node_by_uuid(dtree, dlid)) &&
+			    !dm_tree_node_get_context(dnode) &&
+			    !dm_tree_node_add_error_target(dnode, seg->metadata_lv->size))
+				return_0;
+			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, 0), NULL)))
+				return_0;
+			if ((dnode = dm_tree_find_node_by_uuid(dtree, dlid)) &&
+			    !dm_tree_node_get_context(dnode) &&
+			    !dm_tree_node_add_error_target(dnode, seg_lv(seg, 0)->size))
+				return_0;
+		}
+		return 1;
+	}
+
 	/* This is unused cache-pool - make metadata accessible */
 	if (lv_is_cache_pool(lv))
 		lv = first_seg(lv)->metadata_lv;
@@ -2848,7 +2886,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 		}
 
 		/* Not meant to be top level? */
-		if (!*layer)
+		if (!*layer && (!(layer = strchr(uuid + 4, '-')) || strstr(layer, "-pool") || strstr(layer, "-tpool")))
 			continue;
 
 		/* If operation was performed on a partial tree, don't remove it */
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 6dcbf42..c53eb23 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -227,6 +227,8 @@ static int _cache_text_import(struct lv_segment *seg,
 	    !dm_config_get_uint32(sn, "cleaner", &seg->cleaner_policy))
 		return SEG_LOG_ERROR("Could not read cache cleaner in");
 
+	seg->lv->status |= strstr(seg->lv->name, "_corig") ? LV_PENDING_DELETE : 0;
+
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
 		return_0;
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 55681d4..21555d6 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -88,6 +88,7 @@ static const struct flag _lv_flags[] = {
 	{CACHE_POOL, NULL, 0},
 	{CACHE_POOL_DATA, NULL, 0},
 	{CACHE_POOL_METADATA, NULL, 0},
+	{LV_PENDING_DELETE, NULL, 0}, /* TODO: print as COMPATIBLE_FLAG */
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index b94b867..e50b796 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -21,6 +21,7 @@
 #include "segtype.h"
 #include "activate.h"
 #include "defaults.h"
+#include "lv_alloc.h"
 
 /* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
@@ -220,29 +221,6 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 }
 
 /*
- * Cleanup orphan device in the table with temporary activation
- * since in the suspend() we can't deactivate unused nodes
- * and the resume() phase mishandles orphan nodes.
- *
- * TODO: improve libdm to handle this case automatically
- */
-static int _cleanup_orphan_lv(struct logical_volume *lv)
-{
-	lv->status |= LV_TEMPORARY;
-	if (!activate_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to activate temporary %s", lv->name);
-		return 0;
-	}
-	if (!deactivate_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to deactivate temporary %s", lv->name);
-		return 0;
-	}
-	lv->status &= ~LV_TEMPORARY;
-
-	return 1;
-}
-
-/*
  * lv_cache_remove
  * @cache_lv
  *
@@ -268,6 +246,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
+	if (lv_is_pending_delete(cache_lv))
+		goto remove;  /* Already dropped */
+
 	/* Localy active volume is needed for writeback */
 	if (!lv_is_active_locally(cache_lv)) {
 		/* Give up any remote locks */
@@ -348,43 +329,50 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!detach_pool_lv(cache_seg))
 		return_0;
 
-	/* Regular LV which user may remove if there are problems */
+	/*
+	 * Drop layer from cache LV and make _corigin to appear again as regular LV
+	 * And use 'existing' _corigin  volume to keep reference on cache-pool
+	 * This way we still have a way to reference _corigin in dm table and we
+	 * know it's been 'cache' LV  and we can drop all needed table entries via
+	 * activation and deactivation of it.
+	 *
+	 * This 'cache' LV without origin is temporary LV, which still could be
+	 * easily operated by lvm2 commands - it could be activate/deactivated/removed.
+	 * However in the dm-table it will use 'error' target for _corigin volume.
+	 */
 	corigin_lv = seg_lv(cache_seg, 0);
 	lv_set_visible(corigin_lv);
 	if (!remove_layer_from_lv(cache_lv, corigin_lv))
 			return_0;
 
-	if (!lv_update_and_reload(cache_lv))
+	/* Replace 'error' with 'cache' segtype */
+	cache_seg = first_seg(corigin_lv);
+	if (!(cache_seg->segtype = get_segtype_from_string(corigin_lv->vg->cmd, "cache")))
 		return_0;
 
-	/*
-	 * suspend_lv on this cache LV suspends all components:
-	 * - the top-level cache LV
-	 * - the origin
-	 * - the cache_pool _cdata and _cmeta
-	 *
-	 * resume_lv on this (former) cache LV will resume all
-	 *
-	 * FIXME: currently we can't easily avoid execution of
-	 * blkid on resumed error device
-	 */
+	if (!(cache_seg->areas = dm_pool_zalloc(cache_lv->vg->vgmem, sizeof(*cache_seg->areas))))
+		return_0;
+	if (!set_lv_segment_area_lv(cache_seg, 0, cache_lv, 0, 0))
+		return_0;
 
-	/*
-	 * cleanup orphan devices
-	 *
-	 * FIXME:
-	 * fix _add_dev() to support this case better
-	 * since that should be handled internally by resume_lv()
-	 * which should autoremove any orphans
-	 */
-	if (!_cleanup_orphan_lv(corigin_lv))  /* _corig */
+	cache_seg->area_count = 1;
+	corigin_lv->le_count = cache_lv->le_count;
+	corigin_lv->size = cache_lv->size;
+	corigin_lv->status |= LV_PENDING_DELETE;
+
+	/* Reattach cache pool */
+	if (!attach_pool_lv(cache_seg, cache_pool_lv, NULL, NULL))
 		return_0;
-	if (!_cleanup_orphan_lv(seg_lv(first_seg(cache_pool_lv), 0))) /* _cdata */
+
+	/* Suspend/resume also deactivates deleted LV via support of LV_PENDING_DELETE */
+	if (!lv_update_and_reload(cache_lv))
 		return_0;
-	if (!_cleanup_orphan_lv(first_seg(cache_pool_lv)->metadata_lv)) /* _cmeta */
+	cache_lv = corigin_lv;
+remove:
+	if (!detach_pool_lv(cache_seg))
 		return_0;
 
-	if (!lv_remove(corigin_lv))
+	if (!lv_remove(cache_lv)) /* Will use LV_PENDING_DELETE */
 		return_0;
 
 	return 1;
@@ -400,7 +388,7 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 		return 0;
 
 	seg = get_only_segment_using_this_lv(lv);
-	return seg && lv_is_cache(seg->lv) && (seg_lv(seg, 0) == lv);
+	return seg && lv_is_cache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
 /*
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4ee751c..85076fa 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -990,6 +990,8 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 		if (lv_is_external_origin(lv) &&
 		    lv_is_thin_volume(sl->seg->lv))
 			continue; /* Skip external origin */
+		if (lv_is_pending_delete(sl->seg->lv))
+			continue; /* Skip deleted LVs */
 		return lv_lock_holder(sl->seg->lv);
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d664453..30944c1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1280,7 +1280,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 				return_0;
 
 			/* Remove cache origin only when removing (not on lv_empty()) */
-			if (delete && seg_is_cache(seg) && !lv_remove(seg_lv(seg, 0)))
+			if (delete && seg_is_cache(seg) &&
+			    !lv_is_pending_delete(seg->lv) && !lv_remove(seg_lv(seg, 0)))
 				return_0;
 
 			if ((pool_lv = seg->pool_lv)) {
@@ -5322,6 +5323,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
 	struct lv_list *lvl;
+	struct seg_list *sl;
 	int is_last_pool;
 
 	vg = lv->vg;
@@ -5420,6 +5422,14 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!archive(vg))
 		return 0;
 
+	/* When referenced by the LV with pending delete flag, remove this deleted LV first */
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+		if (lv_is_pending_delete(sl->seg->lv) && !lv_remove(sl->seg->lv)) {
+			log_error("Error releasing logical volume %s with pending delete.",
+				  display_lvname(sl->seg->lv));
+			return 0;
+		}
+
 	if (lv_is_cow(lv)) {
 		/* Old format1 code */
 		if (!(lv->vg->fid->fmt->features & FMT_MDAS))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5acc511..0ba1ed5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -117,7 +117,9 @@
 #define CACHE_POOL_METADATA	UINT64_C(0x0000800000000000)    /* LV - Internal use only */
 #define CACHE			UINT64_C(0x0001000000000000)    /* LV - Internal use only */
 
-/* Next unused flag:		UINT64_C(0x0004000000000000)    */
+#define LV_PENDING_DELETE	UINT64_C(0x0004000000000000)    /* LV - Internal use only */
+
+/* Next unused flag:		UINT64_C(0x0008000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -188,6 +190,7 @@
 #define lv_is_mirror(lv)	(((lv)->status & MIRROR) ? 1 : 0)
 #define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR | MIRROR_LOG | MIRROR_IMAGE)) ? 1 : 0)
 
+#define lv_is_pending_delete(lv) (((lv)->status & LV_PENDING_DELETE) ? 1 : 0)
 #define lv_is_pvmove(lv)	(((lv)->status & PVMOVE) ? 1 : 0)
 
 #define lv_is_raid(lv)		(((lv)->status & RAID) ? 1 : 0)
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 0101af9..4ed1b28 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -188,6 +188,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 */
 		/* Suffixes used here MUST match lib/activate/dev_manager.c */
 		layer = lv_is_cache_origin(lv) ? "real" :
+			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
diff --git a/lib/report/report.c b/lib/report/report.c
index 262b376..e6df787 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -518,7 +518,7 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_cow(lv))
 		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
 
-	if (lv_is_cache(lv))
+	if (lv_is_cache(lv) && !lv_is_pending_delete(lv))
 		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
 
 	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)


