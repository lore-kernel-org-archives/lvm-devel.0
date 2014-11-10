From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:42 +0000 (UTC)
Subject: master - cleanup: indents comments backtraces
Message-ID: <20141110210642.939D460C9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5d3f812854b23ef5e7e51f96a3f89fa02c093fa
Commit:        e5d3f812854b23ef5e7e51f96a3f89fa02c093fa
Parent:        1e97d2dd286a184fc1d26a9abb60fea9e2b7d44d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 6 20:36:53 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cleanup: indents comments backtraces

---
 lib/activate/activate.c    |    3 ++-
 lib/activate/dev_manager.c |    2 +-
 lib/cache_segtype/cache.c  |   11 +++++------
 lib/metadata/cache_manip.c |    3 ++-
 lib/metadata/lv_manip.c    |    1 +
 libdm/mm/pool-debug.c      |    2 +-
 libdm/mm/pool-fast.c       |    2 +-
 7 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7adb90f..93f9b9c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1687,7 +1687,8 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 	struct lv_list *lvl_pre;
 
 	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
-		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) && (!lv_is_cow(lv) || !lv_is_cow(lvl_pre->lv)) &&
+		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) &&
+		    (!lv_is_cow(lv) || !lv_is_cow(lvl_pre->lv)) &&
 		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
 			return_0;
 	}
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2c6ed50..ffd7ff3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1207,7 +1207,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 		goto_out;
 
 	c = (*status)->cache;
-	(*status)->mem = dm->mem; /* User can destroy this mem pool later */
+	(*status)->mem = dm->mem; /* User has to destroy this mem pool later */
 	(*status)->data_usage = dm_make_percent(c->used_blocks,
 						c->total_blocks);
 	(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 11c5b10..ab9d4a0 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -45,7 +45,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Cache data must be a string in");
 	if (!(data_lv = find_lv(seg->lv->vg, str)))
 		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-			  "cache data in", str);
+				     "cache data in", str);
 
 	if (!dm_config_has_node(sn, "metadata"))
 		return SEG_LOG_ERROR("Cache metadata not specified in");
@@ -53,7 +53,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Cache metadata must be a string in");
 	if (!(meta_lv = find_lv(seg->lv->vg, str)))
 		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-			  "cache metadata in", str);
+				     "cache metadata in", str);
 
 	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
 		return SEG_LOG_ERROR("Couldn't read cache chunk_size in");
@@ -199,7 +199,7 @@ static int _cache_text_import(struct lv_segment *seg,
 			      struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	struct logical_volume *pool_lv, *origin_lv;
-	const char *name = NULL;
+	const char *name;
 
 	if (!dm_config_has_node(sn, "cache_pool"))
 		return SEG_LOG_ERROR("cache_pool not specified in");
@@ -207,7 +207,7 @@ static int _cache_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("cache_pool must be a string in");
 	if (!(pool_lv = find_lv(seg->lv->vg, name)))
 		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-			  "cache_pool in", name);
+				     "cache_pool in", name);
 
 	if (!dm_config_has_node(sn, "origin"))
 		return SEG_LOG_ERROR("Cache origin not specified in");
@@ -215,8 +215,7 @@ static int _cache_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Cache origin must be a string in");
 	if (!(origin_lv = find_lv(seg->lv->vg, name)))
 		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
-			  "cache origin in", name);
-
+				     "cache origin in", name);
 	if (!set_lv_segment_area_lv(seg, 0, origin_lv, 0, 0))
 		return_0;
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e50b796..6c74e57 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -342,8 +342,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 */
 	corigin_lv = seg_lv(cache_seg, 0);
 	lv_set_visible(corigin_lv);
+
 	if (!remove_layer_from_lv(cache_lv, corigin_lv))
-			return_0;
+		return_0;
 
 	/* Replace 'error' with 'cache' segtype */
 	cache_seg = first_seg(corigin_lv);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 30944c1..220f894 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7018,6 +7018,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_cache(lp)) {
 		/* TODO: support remote exclusive activation? */
+		/* Not yet 'cache' LV, it is stripe volume for wiping */
 		if (is_change_activating(lp->activate) &&
 		    !activate_lv_excl_local(cmd, lv)) {
 			log_error("Aborting. Failed to activate LV %s locally exclusively.",
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index afaa39e..a2767cd 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -170,7 +170,7 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment)
 	struct block *b = _new_block(s, alignment);
 
 	if (!b)
-		return NULL;
+		return_NULL;
 
 	_append_block(p, b);
 
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index edb31a0..803842c 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -107,7 +107,7 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment)
 			       needed : p->chunk_size);
 
 		if (!c)
-			return NULL;
+			return_NULL;
 
 		_align_chunk(c, alignment);
 	}


