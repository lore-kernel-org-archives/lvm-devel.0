From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Sep 2015 18:05:10 +0000 (UTC)
Subject: master - segtypes: Use SEG_TYPE_NAME_ string constants.
Message-ID: <20150922180510.A83BF60253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=214e2cddf639e4b5a610e34ac24dbe2fd4618fb6
Commit:        214e2cddf639e4b5a610e34ac24dbe2fd4618fb6
Parent:        0ce150280ed703aad27f8d5c37db02dfa63da382
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 22 19:04:12 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 22 19:04:12 2015 +0100

segtypes: Use SEG_TYPE_NAME_ string constants.

---
 lib/activate/dev_manager.c      |   10 +++++-----
 lib/cache_segtype/cache.c       |    4 ++--
 lib/error/errseg.c              |    2 +-
 lib/format1/import-extents.c    |    4 ++--
 lib/format_pool/import_export.c |    5 ++---
 lib/format_text/import_vsn1.c   |    2 +-
 lib/freeseg/freeseg.c           |    2 +-
 lib/locking/lvmlockd.c          |    2 +-
 lib/metadata/cache_manip.c      |    6 +++---
 lib/metadata/lv_manip.c         |   34 +++++++++++++++++-----------------
 lib/metadata/mirror.c           |   18 ++++++++----------
 lib/metadata/pool_manip.c       |    6 +++---
 lib/metadata/raid_manip.c       |    6 +++---
 lib/metadata/segtype.h          |    9 +++++++++
 lib/metadata/snapshot_manip.c   |    2 +-
 lib/mirror/mirrored.c           |    2 +-
 lib/snapshot/snapshot.c         |    2 +-
 lib/striped/striped.c           |    4 ++--
 lib/zero/zero.c                 |    2 +-
 liblvm/lvm_lv.c                 |   10 +++++-----
 tools/lvconvert.c               |    8 ++++----
 tools/lvcreate.c                |   14 +++++++-------
 tools/lvmcmdline.c              |    2 +-
 tools/pvmove.c                  |    2 +-
 24 files changed, 82 insertions(+), 76 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c8e9589..5a1e18b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -143,23 +143,23 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		return 0;
 	}
 
-	if (!strcmp(segtype->name, "cache")) {
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_CACHE)) {
 		if (!dm_get_status_cache(seg_status->mem, params, &(seg_status->cache)))
 			return_0;
 		seg_status->type = SEG_STATUS_CACHE;
-	} else if (!strcmp(segtype->name, "raid")) {
+	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID)) {
 		if (!dm_get_status_raid(seg_status->mem, params, &seg_status->raid))
 			return_0;
 		seg_status->type = SEG_STATUS_RAID;
-	} else if (!strcmp(segtype->name, "thin")) {
+	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_THIN)) {
 		if (!dm_get_status_thin(seg_status->mem, params, &seg_status->thin))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN;
-	} else if (!strcmp(segtype->name, "thin-pool")) {
+	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_THIN_POOL)) {
 		if (!dm_get_status_thin_pool(seg_status->mem, params, &seg_status->thin_pool))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN_POOL;
-	} else if (!strcmp(segtype->name, "snapshot")) {
+	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_SNAPSHOT)) {
 		if (!dm_get_status_snapshot(seg_status->mem, params, &seg_status->snapshot))
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 85cba18..733c330 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -420,7 +420,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		return 0;
 	}
 
-	segtype->name = "cache-pool";
+	segtype->name = SEG_TYPE_NAME_CACHE_POOL;
 	segtype->flags = SEG_CACHE_POOL | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE;
 	segtype->ops = &_cache_pool_ops;
 
@@ -434,7 +434,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		return 0;
 	}
 
-	segtype->name = "cache";
+	segtype->name = SEG_TYPE_NAME_CACHE;
 	segtype->flags = SEG_CACHE | SEG_ONLY_EXCLUSIVE;
 	segtype->ops = &_cache_ops;
 
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index fa0b9c0..26b07d8 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -95,7 +95,7 @@ struct segment_type *init_error_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_error_ops;
-	segtype->name = "error";
+	segtype->name = SEG_TYPE_NAME_ERROR;
 	segtype->flags = SEG_CAN_SPLIT | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index bfcf0de..992edc3 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -219,7 +219,7 @@ static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 	struct lv_segment *seg;
 	struct segment_type *segtype;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	while (le < lvm->lv->le_count) {
@@ -281,7 +281,7 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 
 	total_area_len = lvm->lv->le_count / lvm->stripes;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	while (first_area_le < total_area_len) {
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 1aeabe2..99155ce 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -188,8 +188,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 
 	area_len = (usp->devs[0].blocks) / POOL_PE_SIZE;
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd,
-						     "striped")))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
@@ -226,7 +225,7 @@ static int _add_linear_seg(struct dm_pool *mem,
 	unsigned j;
 	uint32_t area_len;
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	for (j = 0; j < usp->num_devs; j++) {
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 7888695..d63192e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -375,7 +375,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 		return 0;
 	}
 
-	segtype_str = "striped";
+	segtype_str = SEG_TYPE_NAME_STRIPED;
 
 	if (!dm_config_get_str(sn_child, "type", &segtype_str)) {
 		log_error("Segment type must be a string.");
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 71d7f8c..5afdcac 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -33,7 +33,7 @@ struct segment_type *init_free_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_freeseg_ops;
-	segtype->name = "free";
+	segtype->name = SEG_TYPE_NAME_FREE;
 	segtype->flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 728dd99..e20920c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -337,7 +337,7 @@ static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	dm_list_init(&lp.tags);
 
-	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
+	if (!(lp.segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	lv = lv_create_single(vg, &lp);
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 04b8308..12b6d66 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -261,7 +261,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	if (lv_is_thin_pool(cache_lv))
 		cache_lv = seg_lv(first_seg(cache_lv), 0); /* cache _tdata */
 
-	if (!(segtype = get_segtype_from_string(cmd, "cache")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE)))
 		return_NULL;
 
 	if (!insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig"))
@@ -407,7 +407,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	/* Replace 'error' with 'cache' segtype */
 	cache_seg = first_seg(corigin_lv);
-	if (!(cache_seg->segtype = get_segtype_from_string(corigin_lv->vg->cmd, "cache")))
+	if (!(cache_seg->segtype = get_segtype_from_string(corigin_lv->vg->cmd, SEG_TYPE_NAME_CACHE)))
 		return_0;
 
 	if (!(cache_seg->areas = dm_pool_zalloc(cache_lv->vg->vgmem, sizeof(*cache_seg->areas))))
@@ -453,7 +453,7 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 
 static const char *_get_default_cache_policy(struct cmd_context *cmd)
 {
-	const struct segment_type *segtype = get_segtype_from_string(cmd, "cache");
+	const struct segment_type *segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE);
 	unsigned attr = ~0;
         const char *def = NULL;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 46213fe..7e8301b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1013,7 +1013,7 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 	struct lv_segment *seg;
 	const struct segment_type *segtype;
 
-	segtype = get_segtype_from_string(lv->vg->cmd, "snapshot");
+	segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_SNAPSHOT);
 	if (!segtype) {
 		log_error("Failed to find snapshot segtype");
 		return NULL;
@@ -1393,7 +1393,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 
 	/* FIXME Check for any attached LVs that will become orphans e.g. mirror logs */
 
-	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, "error")))
+	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR)))
 		return_0;
 
 	return 1;
@@ -3401,7 +3401,7 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 		return NULL;
 	}
 
-	if (!(newseg = alloc_lv_segment(get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
+	if (!(newseg = alloc_lv_segment(get_segtype_from_string(seg->lv->vg->cmd, SEG_TYPE_NAME_MIRROR),
 					seg->lv, seg->le, seg->len,
 					seg->status, seg->stripe_size,
 					log_lv,
@@ -3494,7 +3494,7 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 	if (!lv_add_mirror_lvs(lv, &copy_lv, 1, MIRROR_IMAGE, region_size))
 		return_0;
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
@@ -3608,7 +3608,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 		return 0;
 	}
 
-	mirror_segtype = get_segtype_from_string(lv->vg->cmd, "mirror");
+	mirror_segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_MIRROR);
 	if (seg->segtype != mirror_segtype)
 		if (!(seg = _convert_seg_to_mirror(seg, region_size, NULL)))
 			return_0;
@@ -3668,7 +3668,7 @@ int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
 
 	return lv_add_segment(ah, ah->area_count + first_area, 1, log_lv,
 			      get_segtype_from_string(log_lv->vg->cmd,
-						      "striped"),
+						      SEG_TYPE_NAME_STRIPED),
 			      0, status, 0);
 }
 
@@ -3769,7 +3769,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	uint32_t fa, s;
 	int clear_metadata = 0;
 
-	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+	segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED);
 
 	/*
 	 * The component devices of a "striped" LV all go in the same
@@ -6209,7 +6209,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 
 			/* Replace mirror with error segment */
 			if (!(lseg->segtype =
-			      get_segtype_from_string(lv->vg->cmd, "error"))) {
+			      get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR))) {
 				log_error("Missing error segtype");
 				return 0;
 			}
@@ -6343,7 +6343,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 		return_0;
 
 	/* Replace the empty layer with error segment */
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "error")))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR)))
 		return_0;
 	if (!lv_add_virtual_segment(layer_lv, 0, parent_lv->le_count, segtype))
 		return_0;
@@ -6407,7 +6407,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	if (lv_is_active(lv_where) && strstr(name, "_mimagetmp")) {
 		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
-		segtype = get_segtype_from_string(cmd, "error");
+		segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_ERROR);
 
 		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
 			log_error("Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
@@ -6455,7 +6455,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	if (!move_lv_segments(layer_lv, lv_where, 0, 0))
 		return_NULL;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 		return_NULL;
 
 	/* allocate a new linear segment */
@@ -6505,7 +6505,7 @@ static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
 	if (seg_type(seg, s) != AREA_PV && seg_type(seg, s) != AREA_LV)
 		return_0;
 
-	if (!(segtype = get_segtype_from_string(layer_lv->vg->cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(layer_lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	/* FIXME Incomplete message? Needs more context */
@@ -6778,7 +6778,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	char vorigin_name[NAME_LEN];
 	struct logical_volume *lv;
 
-	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_ZERO))) {
 		log_error("Zero segment type for virtual origin not found");
 		return NULL;
 	}
@@ -7113,7 +7113,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		/* Create cache origin for cache pool */
 		/* FIXME Eventually support raid/mirrors with -m */
-		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
+		if (!(create_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
 			return_0;
 	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
 		if (is_change_activating(lp->activate) && (lp->activate != CHANGE_AEY) &&
@@ -7229,7 +7229,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return_NULL;
 
 		/* The snapshot segment gets created later */
-		if (!(create_segtype = get_segtype_from_string(cmd, "striped")))
+		if (!(create_segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 			return_NULL;
 
 		/* Must zero cow */
@@ -7626,7 +7626,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 	if (lp->create_pool && !seg_is_pool(lp)) {
 		segtype = lp->segtype;
 		if (seg_is_thin_volume(lp)) {
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN_POOL)))
 				return_NULL;
 
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
@@ -7638,7 +7638,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 				return NULL;
 			}
 			/* origin_name is defined -> creates cache LV with new cache pool */
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_CACHE_POOL)))
 				return_NULL;
 
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f0d8f00..d4d2104 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -83,7 +83,7 @@ int cluster_mirror_is_available(struct cmd_context *cmd)
        unsigned attr = 0;
        const struct segment_type *segtype;
 
-       if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+       if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
                return_0;
 
        if (!segtype->ops->target_present)
@@ -112,7 +112,7 @@ uint32_t lv_mirror_count(const struct logical_volume *lv)
 	seg = first_seg(lv);
 
 	/* FIXME: RAID10 only supports 2 copies right now */
-	if (!strcmp(seg->segtype->name, "raid10"))
+	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_RAID10))
 		return 2;
 
 	if (lv_is_pvmove(lv))
@@ -1493,8 +1493,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 			}
 		} else {
 			if (!lv_add_segment(ah, m * stripes, stripes, img_lvs[m],
-					    get_segtype_from_string(lv->vg->cmd,
-								    "striped"),
+					    get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED),
 					    stripe_size, 0, 0)) {
 				log_error("Aborting. Failed to add mirror image segment "
 					  "to %s. Remove new LV and retry.",
@@ -1547,8 +1546,7 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 		seg->area_count = new_mirrors + 1;
 
 		if (!new_mirrors)
-			seg->segtype = get_segtype_from_string(lv->vg->cmd,
-							       "striped");
+			seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED);
 	}
 
 	return 1;
@@ -1720,7 +1718,7 @@ int fixup_imported_mirrors(struct volume_group *vg)
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		dm_list_iterate_items(seg, &lvl->lv->segments) {
 			if (seg->segtype !=
-			    get_segtype_from_string(vg->cmd, "mirror"))
+			    get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_MIRROR))
 				continue;
 
 			if (seg->log_lv && !add_seg_to_segs_using_this_lv(seg->log_lv, seg))
@@ -1748,7 +1746,7 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 1, 0)))
 		return_0;
 
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
 	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
@@ -2033,7 +2031,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
 		return_0;
 
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
@@ -2106,7 +2104,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
 		return_0;
 
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
 	ah = allocate_extents(lv->vg, NULL, segtype,
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 95b5867..a57d90e 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -438,7 +438,7 @@ int create_pool(struct logical_volume *pool_lv,
 	}
 
 	/* LV is not yet a pool, so it's extension from lvcreate */
-	if (!(striped = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+	if (!(striped = get_segtype_from_string(pool_lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	if (activation() && striped->ops->target_present &&
@@ -561,7 +561,7 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.zero = 1,
 	};
 
-	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	/* FIXME: allocate properly space for metadata_lv */
@@ -597,7 +597,7 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		.zero = 1,
 	};
 
-	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
+	if (!(lp.segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	/* FIXME: Maybe using silent mode ? */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 118bd06..87e6c8c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -408,7 +408,7 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
 
 	if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
@@ -867,7 +867,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 					sizeof(*lvl_array) * extract * 2)))
 		return_0;
 
-	if (!(error_segtype = get_segtype_from_string(lv->vg->cmd, "error")))
+	if (!(error_segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR)))
 		return_0;
 
 	/*
@@ -1475,7 +1475,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!strcmp(seg->segtype->name, "mirror") &&
+	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_MIRROR) &&
 	    (!strcmp(new_segtype->name, SEG_TYPE_NAME_RAID1)))
 	    return _convert_mirror_to_raid1(lv, new_segtype);
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 7a5195c..010c8db 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -51,6 +51,15 @@ struct dev_manager;
 #define SEG_TYPE_NAME_LINEAR		"linear"
 #define SEG_TYPE_NAME_STRIPED		"striped"
 #define SEG_TYPE_NAME_MIRROR		"mirror"
+#define SEG_TYPE_NAME_SNAPSHOT		"snapshot"
+#define SEG_TYPE_NAME_THIN		"thin"
+#define SEG_TYPE_NAME_THIN_POOL		"thin-pool"
+#define SEG_TYPE_NAME_CACHE		"cache"
+#define SEG_TYPE_NAME_CACHE_POOL	"cache-pool"
+#define SEG_TYPE_NAME_ERROR		"error"
+#define SEG_TYPE_NAME_FREE		"free"
+#define SEG_TYPE_NAME_ZERO		"zero"
+#define SEG_TYPE_NAME_RAID		"raid"
 #define SEG_TYPE_NAME_RAID1		"raid1"
 #define SEG_TYPE_NAME_RAID10		"raid10"
 #define SEG_TYPE_NAME_RAID4		"raid4"
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e6a420f..8245619 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -44,7 +44,7 @@ static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
 	unsigned attrs = 0;
 
 	if (activation() &&
-	    (segtype = get_segtype_from_string(cmd, "snapshot")) &&
+	    (segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)) &&
 	    segtype->ops->target_present &&
 	    segtype->ops->target_present(cmd, NULL, &attrs) &&
 	    (attrs & SNAPSHOT_FEATURE_FIXED_LEAK))
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 2156165..6e189b2 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -620,7 +620,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_mirrored_ops;
-	segtype->name = "mirror";
+	segtype->name = SEG_TYPE_NAME_MIRROR;
 	segtype->flags = SEG_MIRROR | SEG_AREAS_MIRRORED;
 
 #ifdef DEVMAPPER_SUPPORT
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 0886206..4a8f005 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -259,7 +259,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_snapshot_ops;
-	segtype->name = "snapshot";
+	segtype->name = SEG_TYPE_NAME_SNAPSHOT;
 	segtype->flags = SEG_SNAPSHOT | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE;
 
 #ifdef DEVMAPPER_SUPPORT
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 1803077..edf1ae2 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -29,7 +29,7 @@
 
 static const char *_striped_name(const struct lv_segment *seg)
 {
-	return (seg->area_count == 1) ? "linear" : seg->segtype->name;
+	return (seg->area_count == 1) ? SEG_TYPE_NAME_LINEAR : seg->segtype->name;
 }
 
 static void _striped_display(const struct lv_segment *seg)
@@ -229,7 +229,7 @@ struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_striped_ops;
-	segtype->name = "striped";
+	segtype->name = SEG_TYPE_NAME_STRIPED;
 	segtype->flags =
 	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED | SEG_FORMAT1_SUPPORT;
 
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 4efa0ce..33ae9d3 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -89,7 +89,7 @@ struct segment_type *init_zero_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_zero_ops;
-	segtype->name = "zero";
+	segtype->name = SEG_TYPE_NAME_ZERO;
 	segtype->flags = SEG_CAN_SPLIT | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 95d8492..fb9d19f 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -205,7 +205,7 @@ static void _lv_set_default_params(struct lvcreate_params *lp,
 }
 
 static struct segment_type * _get_segtype(struct cmd_context *cmd) {
-	struct segment_type *rc = get_segtype_from_string(cmd, "striped");
+	struct segment_type *rc = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED);
 	if (!rc) {
 		log_error(INTERNAL_ERROR "Segtype striped not found.");
 	}
@@ -503,7 +503,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 	_lv_set_default_params(lp, vg, pool_name, extents);
 
 	lp->create_pool = 1;
-	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
+	lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN_POOL);
 	lp->stripes = 1;
 
 	if (!meta_size) {
@@ -611,7 +611,7 @@ static int _lv_set_thin_params(struct lvcreate_params *lp,
 	_lv_set_default_params(lp, vg, lvname, 0);
 
 	lp->pool_name = pool_name;
-	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
+	lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN);
 	lp->virtual_extents = extents;
 	lp->stripes = 1;
 
@@ -655,14 +655,14 @@ static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
 
 		if (size) {
-			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "snapshot"))) {
+			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_SNAPSHOT))) {
 				log_error("Segtype snapshot not found.");
 				return NULL;
 			}
 			lvcp->lvp.chunk_size = 8;
 			lvcp->lvp.snapshot = 1;
 		} else {
-			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin"))) {
+			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_THIN))) {
 				log_error("Segtype thin not found.");
 				return NULL;
 			}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b5658f2..0e06160 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -550,7 +550,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 					    -1))
 			return_0;
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+		if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
 			return_0;
 	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
 		;
@@ -587,7 +587,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		}
 		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+		if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_SNAPSHOT)))
 			return_0;
 
 		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
@@ -675,7 +675,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (arg_count(cmd, mirrors_ARG) && !lp->mirrors) {
 			/* down-converting to linear/stripe? */
 			if (!(lp->segtype =
-			      get_segtype_from_string(cmd, "striped")))
+			      get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 				return_0;
 		} else if (arg_count(cmd, type_ARG)) {
 			/* changing mirror type? */
@@ -2575,7 +2575,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	if (!pool_supports_external_origin(first_seg(pool_lv), lv))
 		return_0;
 
-	if (!(lvc.segtype = get_segtype_from_string(cmd, "thin")))
+	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN)))
 		return_0;
 
 	if (!archive(vg))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7bba761..e19ae01 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -661,14 +661,14 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		   (arg_is_set(cmd, virtualoriginsize_ARG) ||
 		   !arg_is_set(cmd, virtualsize_ARG)))
 		/* Snapshot has higher priority then thin */
-		segtype_str = "snapshot"; /* --thinpool makes thin volume */
+		segtype_str = SEG_TYPE_NAME_SNAPSHOT; /* --thinpool makes thin volume */
 	else if (arg_is_set(cmd, cache_ARG) || arg_is_set(cmd, cachepool_ARG))
-		segtype_str = "cache";
+		segtype_str = SEG_TYPE_NAME_CACHE;
 	else if (arg_is_set(cmd, thin_ARG) || arg_is_set(cmd, thinpool_ARG))
-		segtype_str = "thin";
+		segtype_str = SEG_TYPE_NAME_THIN;
 	else if (arg_is_set(cmd, virtualsize_ARG)) {
 		if (arg_is_set(cmd, virtualoriginsize_ARG))
-			segtype_str = "snapshot"; /* --virtualoriginsize incompatible with pools */
+			segtype_str = SEG_TYPE_NAME_SNAPSHOT; /* --virtualoriginsize incompatible with pools */
 		else
 			segtype_str = find_config_tree_str(cmd, global_sparse_segtype_default_CFG, NULL);
 	} else if (arg_uint_value(cmd, mirrors_ARG, 0)) {
@@ -677,7 +677,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			? global_raid10_segtype_default_CFG : global_mirror_segtype_default_CFG;
 		segtype_str = find_config_tree_str(cmd, mirror_default_cfg, NULL);
 	} else
-		segtype_str = "striped";
+		segtype_str = SEG_TYPE_NAME_STRIPED;
 
 	if (!(lp->segtype = get_segtype_from_string(cmd, segtype_str)))
 		return_0;
@@ -906,7 +906,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 				}
 
 				log_debug_metadata("Switching from thin to thin pool segment type.");
-				if (!(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+				if (!(lp->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN_POOL)))
 					return_0;
 			} else	/* Parse free arg as snapshot origin */
 				lp->snapshot = 1;
@@ -1183,7 +1183,7 @@ static int _determine_snapshot_type(struct volume_group *vg,
 	}
 
 	log_debug_metadata("Switching from snapshot to thin segment type.");
-	if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+	if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN)))
 		return_0;
 	lp->snapshot = 0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d3bace7..6577977 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -643,7 +643,7 @@ int locktype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_val
 int segtype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	struct segment_type *segtype;
-	const char *str = (!strcmp(av->value, "linear")) ? "striped" : av->value;
+	const char *str = (!strcmp(av->value, SEG_TYPE_NAME_LINEAR)) ? SEG_TYPE_NAME_STRIPED : av->value;
 
 	if (!(segtype = get_segtype_from_string(cmd, str)))
 		return_0;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index d6403ad..a7943fa 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -32,7 +32,7 @@ static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 	if (clustered && _clustered_found >= 0)
 		return _clustered_found;
 
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&


