From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Feb 2019 09:54:17 -0500
Subject: master - Use "cachevol" to refer to cache on a single LV
Message-ID: <201902271454.x1REsHwJ019297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9eaab6bebe1919b476ec3a4d094a4d6c512920e
Commit:        a9eaab6bebe1919b476ec3a4d094a4d6c512920e
Parent:        c8fc18e8bfbf6e81fc26c7cde780711db748f112
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 30 09:55:34 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 27 08:52:34 2019 -0600

Use "cachevol" to refer to cache on a single LV

and "cachepool" to refer to a cache on a cache pool object.

The problem was that the --cachepool option was being used
to refer to both a cache pool object, and to a standard LV
used for caching.  This could be somewhat confusing, and it
made it less clear when each kind would be used.  By
separating them, it's clear when a cachepool or a cachevol
should be used.

Previously:

- lvm would use the cache pool approach when the user passed
  a cache-pool LV to the --cachepool option.

- lvm would use the cache vol approach when the user passed
  a standard LV in the --cachepool option.

Now:

- lvm will always use the cache pool approach when the user
  uses the --cachepool option.

- lvm will always use the cache vol approach when the user
  uses the --cachevol option.
---
 lib/activate/dev_manager.c         |   14 ++--
 lib/activate/dev_manager.h         |    4 +-
 lib/cache_segtype/cache.c          |   10 +-
 lib/format_text/flags.c            |    2 +-
 lib/locking/lvmlockd.c             |    2 +-
 lib/metadata/cache_manip.c         |   32 ++++----
 lib/metadata/lv.c                  |    6 +-
 lib/metadata/lv_manip.c            |    8 +-
 lib/metadata/merge.c               |    6 +-
 lib/metadata/metadata-exported.h   |   10 +-
 lib/report/report.c                |    8 +-
 man/lvmcache.7_main                |   83 ++++++++++++++++---
 test/shell/cache-single-options.sh |   26 +++---
 test/shell/cache-single-thin.sh    |    2 +-
 test/shell/cache-single-types.sh   |    2 +-
 test/shell/cache-single-usage.sh   |    4 +-
 test/shell/writecache.sh           |    4 +-
 tools/args.h                       |    5 +-
 tools/command-lines.in             |   20 +++--
 tools/lvchange.c                   |    2 +-
 tools/lvconvert.c                  |  153 ++++++++++++++++++++++++------------
 tools/lvmcmdline.c                 |    5 +-
 tools/tools.h                      |    5 +-
 tools/vgsplit.c                    |    2 +-
 24 files changed, 270 insertions(+), 145 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dc570c7..37ce2bf 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -833,7 +833,7 @@ static int _info(struct cmd_context *cmd,
 
 /* FIXME: could we just use dev_manager_info instead of this? */
 
-int get_cache_single_meta_data(struct cmd_context *cmd,
+int get_cache_vol_meta_data(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    struct logical_volume *pool_lv,
 				    struct dm_info *info_meta, struct dm_info *info_data)
@@ -876,7 +876,7 @@ int get_cache_single_meta_data(struct cmd_context *cmd,
  * devs?
  */
 
-int remove_cache_single_meta_data(struct cmd_context *cmd,
+int remove_cache_vol_meta_data(struct cmd_context *cmd,
 				       struct dm_info *info_meta, struct dm_info *info_data)
 {
 	struct dm_tree *dtree;
@@ -2375,7 +2375,7 @@ static int _pool_register_callback(struct dev_manager *dm,
 #endif
 
 	/* Skip for single-device cache pool */
-	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv))
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv))
 		return 1;
 
 	if (!(data = dm_pool_zalloc(dm->mem, sizeof(*data)))) {
@@ -2445,7 +2445,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* Unused cache pool is activated as metadata */
 	}
 
-	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv) && dm->activation) {
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv) && dm->activation) {
 		struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
 		struct lv_segment *lvseg = first_seg(lv);
 		struct dm_info info_meta;
@@ -2637,7 +2637,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				return_0;
 		}
 		if (seg->pool_lv &&
-		    (lv_is_cache_pool(seg->pool_lv) || lv_is_cache_single(seg->pool_lv) || dm->track_external_lv_deps) &&
+		    (lv_is_cache_pool(seg->pool_lv) || lv_is_cache_vol(seg->pool_lv) || dm->track_external_lv_deps) &&
 		    /* When activating and not origin_only detect linear 'overlay' over pool */
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, dm->activation ? origin_only : 1))
 			return_0;
@@ -3163,7 +3163,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 	}
 
-	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
 		struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
 		struct lv_segment *lvseg = first_seg(lv);
 		struct volume_group *vg = lv->vg;
@@ -3414,7 +3414,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 
-	if (lv_is_cache(lv) && !lv_is_cache_single(first_seg(lv)->pool_lv) &&
+	if (lv_is_cache(lv) && !lv_is_cache_vol(first_seg(lv)->pool_lv) &&
 	    /* Register callback only for layer activation or non-layered cache LV */
 	    (layer || !lv_layer(lv)) &&
 	    /* Register callback when metadata LV is NOT already active */
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 6456991..e8e8ae3 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -107,12 +107,12 @@ int dev_manager_device_uses_vg(struct device *dev,
 
 int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor);
 
-int get_cache_single_meta_data(struct cmd_context *cmd,
+int get_cache_vol_meta_data(struct cmd_context *cmd,
                                     struct logical_volume *lv,
                                     struct logical_volume *pool_lv,
                                     struct dm_info *info_meta, struct dm_info *info_data);
 
-int remove_cache_single_meta_data(struct cmd_context *cmd,
+int remove_cache_vol_meta_data(struct cmd_context *cmd,
                                        struct dm_info *info_meta, struct dm_info *info_data);
 
 #endif
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 8a97b30..20a4261 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -49,7 +49,7 @@ static void _cache_display(const struct lv_segment *seg)
 	const struct dm_config_node *n;
 	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -540,7 +540,7 @@ static int _cache_text_import(struct lv_segment *seg,
 		if (!id_read_format(&seg->data_id, uuid))
 			return SEG_LOG_ERROR("Couldn't format data_id in");
 	} else {
-		/* Do not call this when LV is cache_single. */
+		/* Do not call this when LV is cache_vol. */
 		/* load order is unknown, could be cache origin or pool LV, so check for both */
 		if (!dm_list_empty(&pool_lv->segments))
 			_fix_missing_defaults(first_seg(pool_lv));
@@ -570,7 +570,7 @@ static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 	if (seg->cleaner_policy)
 		outf(f, "cleaner = 1");
 
-	if (lv_is_cache_single(seg->pool_lv)) {
+	if (lv_is_cache_vol(seg->pool_lv)) {
 		outf(f, "metadata_format = " FMTu32, seg->cache_metadata_format);
 
 		if (!_settings_text_export(seg, f))
@@ -620,7 +620,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 
 	cache_pool_seg = first_seg(seg->pool_lv);
 
-	if (lv_is_cache_single(seg->pool_lv))
+	if (lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 	else
 		setting_seg = cache_pool_seg;
@@ -668,7 +668,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
 		return_0;
 
-	if (!lv_is_cache_single(seg->pool_lv)) {
+	if (!lv_is_cache_vol(seg->pool_lv)) {
 		/* We don't use start/len when using separate data/meta devices. */
 		if (seg->metadata_len || seg->data_len) {
 			log_error(INTERNAL_ERROR "LV %s using unsupported ranges with cache pool.",
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index cf5be00..1ae64a2 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -72,7 +72,7 @@ static const struct flag _lv_flags[] = {
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
-	{LV_CACHE_SINGLE, "CACHE_SINGLE", STATUS_FLAG},
+	{LV_CACHE_VOL, "CACHE_VOL", STATUS_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 9b2d050..5ecdc64 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2780,7 +2780,7 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 	if (lv_is_pool_metadata_spare(lv))
 		return 0;
 
-	if (lv_is_cache_single(lv))
+	if (lv_is_cache_vol(lv))
 		return 0;
 
 	if (lv_is_cache_pool(lv))
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index ee2a5c5..20deda3 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -61,7 +61,7 @@ const char *display_cache_mode(const struct lv_segment *seg)
 {
 	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -131,7 +131,7 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 	if (seg_is_cache_pool(seg) && (mode == CACHE_MODE_UNSELECTED))
 		return 1;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -337,7 +337,7 @@ int validate_lv_cache_create_pool(const struct logical_volume *pool_lv)
 {
 	struct lv_segment *seg;
 
-	if (!lv_is_cache_pool(pool_lv) && !lv_is_cache_single(pool_lv)) {
+	if (!lv_is_cache_pool(pool_lv) && !lv_is_cache_vol(pool_lv)) {
 		log_error("Logical volume %s is not a cache pool.",
 			  display_lvname(pool_lv));
 		return 0;
@@ -559,7 +559,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	return 1;
 }
 
-static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct logical_volume *cache_lv)
+static int _lv_detach_cache_vol_while_active(struct cmd_context *cmd, struct logical_volume *cache_lv)
 {
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
@@ -582,7 +582,7 @@ static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct
 	/*
 	 * This info is needed to remove the cmeta/cdata devs at the end.
 	 */
-	if (!get_cache_single_meta_data(cmd, cache_lv, cache_pool_lv, &info_meta, &info_data)) {
+	if (!get_cache_vol_meta_data(cmd, cache_lv, cache_pool_lv, &info_meta, &info_data)) {
 		log_error("Failed to get info about cdata/cmeta for %s", display_lvname(cache_pool_lv));
 		return 0;
 	}
@@ -604,7 +604,7 @@ static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct
 		return_0;
 	}
 
-	cache_pool_lv->status &= ~LV_CACHE_SINGLE;
+	cache_pool_lv->status &= ~LV_CACHE_VOL;
 
 	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
 		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
@@ -623,7 +623,7 @@ static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct
 	 */
 
 	/* These cmeta/cdata dm devs need to be removed since they are using cache_pool_lv. */
-	if (!remove_cache_single_meta_data(cmd, &info_meta, &info_data))
+	if (!remove_cache_vol_meta_data(cmd, &info_meta, &info_data))
 		log_error("Failed to remove cdata/cmeta devs for %s", display_lvname(cache_pool_lv));
 
 	if (!deactivate_lv(cmd, cache_pool_lv))
@@ -652,7 +652,7 @@ static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct
 	return 1;
 }
 
-static int _lv_detach_cache_single_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv)
+static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv)
 {
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
@@ -707,7 +707,7 @@ static int _lv_detach_cache_single_while_inactive(struct cmd_context *cmd, struc
 		return_0;
 	}
 
-	cache_pool_lv->status &= ~LV_CACHE_SINGLE;
+	cache_pool_lv->status &= ~LV_CACHE_VOL;
 
 	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
 		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
@@ -724,7 +724,7 @@ static int _lv_detach_cache_single_while_inactive(struct cmd_context *cmd, struc
 	return 1;
 }
 
-int lv_detach_cache_single(struct logical_volume *cache_lv)
+int lv_detach_cache_vol(struct logical_volume *cache_lv)
 {
 	struct cmd_context *cmd = cache_lv->vg->cmd;
 
@@ -734,9 +734,9 @@ int lv_detach_cache_single(struct logical_volume *cache_lv)
 	}
 
 	if (lv_is_active(cache_lv))
-		return _lv_detach_cache_single_while_active(cmd, cache_lv);
+		return _lv_detach_cache_vol_while_active(cmd, cache_lv);
 	else
-		return _lv_detach_cache_single_while_inactive(cmd, cache_lv);
+		return _lv_detach_cache_vol_while_inactive(cmd, cache_lv);
 }
 
 /*
@@ -763,7 +763,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
-	if (lv_is_cache_single(cache_seg->pool_lv)) {
+	if (lv_is_cache_vol(cache_seg->pool_lv)) {
 		log_error(INTERNAL_ERROR "Incorrect remove for cache single");
 		return 0;
 	}
@@ -952,7 +952,7 @@ int cache_set_policy(struct lv_segment *lvseg, const char *name,
 			return 1; /* Policy and settings can be selected later when caching LV */
 	}
 
-	if (seg_is_cache(lvseg) && lv_is_cache_single(lvseg->pool_lv))
+	if (seg_is_cache(lvseg) && lv_is_cache_vol(lvseg->pool_lv))
 		seg = lvseg;
 
 	else if (seg_is_cache_pool(lvseg))
@@ -1128,7 +1128,7 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 #define ONE_MB_S 2048 /* 1MB in sectors */
 #define ONE_GB_S 2097152 /* 1GB in sectors */
 
-int cache_single_set_params(struct cmd_context *cmd,
+int cache_vol_set_params(struct cmd_context *cmd,
 		     struct logical_volume *cache_lv,
 		     struct logical_volume *pool_lv,
 		     uint64_t poolmetadatasize,
@@ -1428,7 +1428,7 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv)
 	int r;
 
 	/* Only unused cache-pool could be activated and wiped */
-	if ((!lv_is_cache_pool(cache_pool_lv) && !lv_is_cache_single(cache_pool_lv)) ||
+	if ((!lv_is_cache_pool(cache_pool_lv) && !lv_is_cache_vol(cache_pool_lv)) ||
 	    !dm_list_empty(&cache_pool_lv->segs_using_this_lv)) {
 		log_error(INTERNAL_ERROR "Failed to wipe cache pool for volume %s.",
 			  display_lvname(cache_pool_lv));
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0e54323..e8f1fab 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -333,7 +333,7 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
-	else if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	else if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		size = (uint64_t) seg->chunk_size;
 	else if (seg_is_pool(seg))
 		size = (uint64_t) seg->chunk_size;
@@ -941,7 +941,7 @@ uint64_t lv_metadata_size(const struct logical_volume *lv)
 	if (!(seg = first_seg(lv)))
 		return 0;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		return seg->metadata_len;
 
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv))
@@ -1309,7 +1309,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
-	else if (lv_is_cache_pool(lv) || lv_is_cache_single(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
+	else if (lv_is_cache_pool(lv) || lv_is_cache_vol(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3b08d05..6360241 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -422,7 +422,7 @@ static int _lv_layout_and_role_cache(struct dm_pool *mem,
 	if (lv_is_cache(lv) &&
 	    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 		goto_bad;
-	else if (lv_is_cache_pool(lv) || lv_is_cache_single(lv)) {
+	else if (lv_is_cache_pool(lv) || lv_is_cache_vol(lv)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
@@ -4453,7 +4453,7 @@ static int _rename_skip_pools_externals_cb(struct logical_volume *lv, void *data
 {
 	if (lv_is_pool(lv) ||
 	    lv_is_vdo_pool(lv) ||
-	    lv_is_cache_single(lv) ||
+	    lv_is_cache_vol(lv) ||
 	    lv_is_external_origin(lv))
 		return -1; /* and skip subLVs */
 
@@ -6225,8 +6225,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv(cmd, lock_lv, "ex", LDLV_PERSISTENT))
 		return_0;
 
-	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
-		if (!lv_detach_cache_single(lv)) {
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
+		if (!lv_detach_cache_vol(lv)) {
 			log_error("Failed to detach cache from %s", display_lvname(lv));
 			return 0;
 		}
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index d3d1d95..08f8fbe 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -364,14 +364,14 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 		if (!seg->pool_lv) {
 			seg_error("is missing cache pool LV");
-		} else if (!lv_is_cache_pool(seg->pool_lv) && !lv_is_cache_single(seg->pool_lv))
+		} else if (!lv_is_cache_pool(seg->pool_lv) && !lv_is_cache_vol(seg->pool_lv))
 			seg_error("is not referencing cache pool LV");
 	} else { /* !cache */
 		if (seg->cleaner_policy)
 			seg_error("sets cleaner_policy");
 	}
 
-	if (lv_is_cache(lv) && seg->pool_lv && lv_is_cache_single(seg->pool_lv)) {
+	if (lv_is_cache(lv) && seg->pool_lv && lv_is_cache_vol(seg->pool_lv)) {
 		cache_setting_seg = seg;
 		no_metadata_format = 1;
 	}
@@ -805,7 +805,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if ((seg_count != 1) &&
 		    (lv_is_cache(lv) ||
 		     lv_is_cache_pool(lv) ||
-		     lv_is_cache_single(lv) ||
+		     lv_is_cache_vol(lv) ||
 		     lv_is_raid(lv) ||
 		     lv_is_snapshot(lv) ||
 		     lv_is_thin_pool(lv) ||
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c76e644..f451140 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -152,7 +152,7 @@
 #define LV_VDO_POOL		UINT64_C(0x0000000040000000)    /* LV - Internal user only */
 #define LV_VDO_POOL_DATA	UINT64_C(0x8000000000000000)    /* LV - Internal user only */
 
-#define LV_CACHE_SINGLE		UINT64_C(0x0010000000000000)	/* LV - also a PV flag */
+#define LV_CACHE_VOL		UINT64_C(0x0010000000000000)	/* LV - also a PV flag */
 
 
 /* Format features flags */
@@ -248,11 +248,11 @@
 
 #define lv_is_cache(lv)		(((lv)->status & CACHE) ? 1 : 0)
 #define lv_is_cache_pool(lv)	(((lv)->status & CACHE_POOL) ? 1 : 0)
-#define lv_is_cache_single(lv)	(((lv)->status & LV_CACHE_SINGLE) ? 1 : 0)
+#define lv_is_cache_vol(lv)	(((lv)->status & LV_CACHE_VOL) ? 1 : 0)
 #define lv_is_used_cache_pool(lv)	(lv_is_cache_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_cache_pool_data(lv)	(((lv)->status & CACHE_POOL_DATA) ? 1 : 0)
 #define lv_is_cache_pool_metadata(lv)	(((lv)->status & CACHE_POOL_METADATA) ? 1 : 0)
-#define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | LV_CACHE_SINGLE | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
+#define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | LV_CACHE_VOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
 #define lv_is_pool(lv)		(((lv)->status & (CACHE_POOL | THIN_POOL)) ? 1 : 0)
 #define lv_is_pool_data(lv)		(((lv)->status & (CACHE_POOL_DATA | THIN_POOL_DATA)) ? 1 : 0)
@@ -1254,7 +1254,7 @@ int cache_set_params(struct lv_segment *seg,
 		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings);
-int cache_single_set_params(struct cmd_context *cmd,
+int cache_vol_set_params(struct cmd_context *cmd,
 		     struct logical_volume *cache_lv,
 		     struct logical_volume *pool_lv,
 		     uint64_t poolmetadatasize,
@@ -1279,7 +1279,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 				       struct logical_volume *origin_lv);
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int lv_detach_cache_single(struct logical_volume *cache_lv);
+int lv_detach_cache_vol(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/lib/report/report.c b/lib/report/report.c
index ecec0a3..e1150f6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1430,7 +1430,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	struct _str_list_append_baton baton;
 	struct dm_list dummy_list; /* dummy list to display "nothing" */
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -1568,7 +1568,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -2753,7 +2753,7 @@ static int _cachemetadataformat_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *setting_seg = NULL;
 	const uint64_t *fmt;
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
@@ -3231,7 +3231,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
+	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
 		size = lv_metadata_size(lv);
 		return _size64_disp(rh, mem, field, &size, private);
 	}
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 89a1943..9f3e526 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -58,11 +58,15 @@ desired caching type, and specify the fast LV to use:
 .nf
 using dm-cache:
 
-  $ lvconvert --type cache --cachepool fast vg/main
+  $ lvconvert --type cache --cachevol fast vg/main
 
-or dm-writecache:
+using dm-writecache:
 
-  $ lvconvert --type writecache --cachepool fast vg/main
+  $ lvconvert --type writecache --cachevol fast vg/main
+
+using dm-cache with a cache pool:
+
+  $ lvconvert --type cache --cachepool fastpool vg/main
 .fi
 
 .B 4. Display LVs
@@ -82,7 +86,7 @@ using dm-cache:
   main         vg Cwi-a-C--- [main_corig] cache  main_corig(0) 
   [main_corig] vg owi-aoC---                     linear /dev/slow(0) 
 
-or dm-writecache:
+using dm-writecache:
 
   $ lvs -a -o name,vgname,lvattr,origin,segtype,devices vg
   LV            VG Attr       Origin        Type       Devices       
@@ -110,6 +114,32 @@ attached.
 
 \&
 
+.SS option args
+
+\&
+
+.B --cachevol
+.I LV
+.br
+
+Pass this option a standard LV.  With a cache vol, cache data and metadata
+are contained within the single LV.  This is used with dm-writecache or
+dm-cache.
+
+.B --cachepool
+.IR CachePoolLV | LV
+.br
+
+Pass this option a cache pool object.  With a cache pool, lvm places cache
+data and cache metadata on different LVs.  The two LVs together are called
+a cache pool.  This permits specific placement of data and metadata.  A
+cache pool is represented as a special type of LV that cannot be used
+directly.  (If a standard LV is passed to this option, lvm will first
+convert it to a cache pool by combining it with another LV to use for
+metadata.)  This can be used with dm-cache.
+
+\&
+
 .SS dm-writecache block size
 
 \&
@@ -145,7 +175,7 @@ Tunable parameters can be passed to the dm-writecache kernel module using
 the --cachesettings option when caching is started, e.g.
 
 .nf
-$ lvconvert --type writecache --cachepool fast \\
+$ lvconvert --type writecache --cachevol fast \\
 	--cachesettings 'high_watermark=N writeback_jobs=N' vg/main
 .fi
 
@@ -201,10 +231,10 @@ Applicable only to persistent memory.
 \&
 
 When using dm-cache, the cache metadata and cache data can be stored on
-separate LVs.  To do this, a "cache-pool LV" is created, which is a
-special LV that references two sub LVs, one for data and one for metadata.
+separate LVs.  To do this, a "cache pool" is created, which is a special
+LV that references two sub LVs, one for data and one for metadata.
 
-To create a cache-pool LV from two separate LVs:
+To create a cache pool from two separate LVs:
 
 .nf
 $ lvcreate -n fastpool -L DataSize vg /dev/fast1
@@ -212,17 +242,17 @@ $ lvcreate -n fastpoolmeta -L MetadataSize vg /dev/fast2
 $ lvconvert --type cache-pool --poolmetadata fastpoolmeta vg/fastpool
 .fi
 
-Then use the cache-pool LV to start caching the main LV:
+Then use the cache pool LV to start caching the main LV:
 
 .nf
 $ lvconvert --type cache --cachepool fastpool vg/main
 .fi
 
-A variation of the same procedure automatically creates a cache-pool when
+A variation of the same procedure automatically creates a cache pool when
 caching is started.  To do this, use a standard LV as the --cachepool
 (this will hold cache data), and use another standard LV as the
 --poolmetadata (this will hold cache metadata).  LVM will create a
-cache-pool LV from the two specified LVs, and use the cache-pool to start
+cache pool LV from the two specified LVs, and use the cache pool to start
 caching the main LV.
 
 .nf
@@ -257,7 +287,7 @@ mode can be displayed with the cache_mode reporting option:
 defines the default cache mode.
 
 .nf
-$ lvconvert --type cache --cachepool fast \\
+$ lvconvert --type cache --cachevol fast \\
 	--cachemode writethrough vg/main
 .nf
 
@@ -360,9 +390,36 @@ and metadata LVs, each of the sub-LVs can use raid1.)
 .nf
 $ lvcreate -n main -L Size vg /dev/slow
 $ lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/fast1 /dev/fast2
-$ lvconvert --type cache --cachepool fast vg/main
+$ lvconvert --type cache --cachevol fast vg/main
 .fi
 
+.SS dm-cache command shortcut
+
+\&
+
+A single command can be used to create a cache pool and attach that new
+cache pool to a main LV:
+
+.nf
+$ lvcreate --type cache --name Name --size Size VG/LV [PV]
+.fi
+
+In this command, the specified LV already exists, and is the main LV to be
+cached.  The command creates a new cache pool with the given name and
+size, using the optionally specified PV (typically an ssd).  Then it
+attaches the new cache pool to the existing main LV to begin caching.
+
+(Note: ensure that the specified main LV is a standard LV.  If a cache
+pool LV is mistakenly specified, then the command does something
+different.)
+
+(Note: the type option is interpreted differently by this command than by
+normal lvcreate commands in which --type specifies the type of the newly
+created LV.  In this case, an LV with type cache-pool is being created,
+and the existing main LV is being converted to type cache.)
+
+\&
+
 .SH SEE ALSO
 .BR lvm.conf (5),
 .BR lvchange (8),
diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index d33bc2e..da9cbba 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -69,13 +69,13 @@ mount_umount()
 #
 
 # 1 shouldn't be used any longer
-not lvconvert --cachemetadataformat 1 -y --type cache --cachepool $lv2 $vg/$lv1
+not lvconvert --cachemetadataformat 1 -y --type cache --cachevol $lv2 $vg/$lv1
 
 # 3 doesn't exist
-not lvconvert --cachemetadataformat 3 -y --type cache --cachepool $lv2 $vg/$lv1
+not lvconvert --cachemetadataformat 3 -y --type cache --cachevol $lv2 $vg/$lv1
 
 # 2 is used by default
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 cachemetadataformat "2"
 
@@ -84,14 +84,14 @@ check lv_field $vg/$lv1 segtype linear
 check lv_field $vg/$lv2 segtype linear
 
 # 2 can be set explicitly
-lvconvert --cachemetadataformat 2 -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert --cachemetadataformat 2 -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 cachemetadataformat "2"
 
 lvconvert --splitcache $vg/$lv1
 
 # "auto" means 2
-lvconvert --cachemetadataformat auto -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert --cachemetadataformat auto -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 cachemetadataformat "2"
 
@@ -107,7 +107,7 @@ mount_umount $lv1
 # Test --poolmetadatasize
 #
 
-lvconvert -y --type cache --cachepool $lv2 --poolmetadatasize 4m $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --poolmetadatasize 4m $vg/$lv1
 
 check lv_field $vg/$lv1 lv_metadata_size "4.00m"
 
@@ -123,7 +123,7 @@ mount_umount $lv1
 # Test --chunksize
 #
 
-lvconvert -y --type cache --cachepool $lv2 --chunksize 32k $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --chunksize 32k $vg/$lv1
 
 check lv_field $vg/$lv1 chunksize "32.00k"
 
@@ -139,7 +139,7 @@ mount_umount $lv1
 # Test --cachemode
 #
 
-lvconvert -y --type cache --cachepool $lv2 --cachemode writethrough $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
 
 check lv_field $vg/$lv1 cachemode "writethrough"
 
@@ -152,7 +152,7 @@ mount_umount $lv1
 
 # FIXME: kernel errors for other cache modes
 
-#lvconvert -y --type cache --cachepool $lv2 --cachemode passthrough $vg/$lv1
+#lvconvert -y --type cache --cachevol $lv2 --cachemode passthrough $vg/$lv1
 
 #check lv_field $vg/$lv1 cachemode "passthrough"
 
@@ -164,7 +164,7 @@ mount_umount $lv1
 #mount_umount $lv1
 
 
-lvconvert -y --type cache --cachepool $lv2 --cachemode writeback $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
 
 check lv_field $vg/$lv1 cachemode "writeback"
 
@@ -180,7 +180,7 @@ mount_umount $lv1
 # Test --cachepolicy
 #
 
-lvconvert -y --type cache --cachepool $lv2 --cachepolicy smq $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --cachepolicy smq $vg/$lv1
 
 check lv_field $vg/$lv1 cachepolicy "smq"
 
@@ -202,7 +202,7 @@ mount_umount $lv1
 # (only for mq policy, no settings for smq)
 #
 
-lvconvert -y --type cache --cachepool $lv2 --cachemode writethrough --cachepolicy mq --cachesettings 'migration_threshold = 233 sequential_threshold=13 random_threshold =1' $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough --cachepolicy mq --cachesettings 'migration_threshold = 233 sequential_threshold=13 random_threshold =1' $vg/$lv1
 
 check lv_field $vg/$lv1 cachemode "writethrough"
 check lv_field $vg/$lv1 cachepolicy "mq"
@@ -224,7 +224,7 @@ mount_umount $lv1
 # Test lvchange of --cachemode, --cachepolicy, --cachesettings
 #
 
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 lvchange -ay $vg/$lv1
 
diff --git a/test/shell/cache-single-thin.sh b/test/shell/cache-single-thin.sh
index 33097ca..2547502 100644
--- a/test/shell/cache-single-thin.sh
+++ b/test/shell/cache-single-thin.sh
@@ -30,7 +30,7 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvcreate -L10 -an -n $lv1 $vg "$dev1"
 lvcreate -L10 -an -n $lv2 $vg "$dev2"
 
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 lvconvert -y --type thin-pool $vg/$lv1
 
 lvcreate --type thin -V10 -n lvthin --thinpool $vg/$lv1
diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index e7c58e2..a973679 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -45,7 +45,7 @@ cp pattern1 "$mount_dir/pattern1"
 umount "$mount_dir"
 lvchange -an $vg/$lv1
 
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 63be718..09d5b10 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -48,7 +48,7 @@ cp pattern1 "$mount_dir/pattern1"
 umount "$mount_dir"
 lvchange -an $vg/$lv1
 
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
@@ -90,7 +90,7 @@ lvchange -an $vg/$lv2
 
 # test2: create fs on LV after cache is attached
 
-lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 42c864a..94fa459 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -48,7 +48,7 @@ cp pattern1 $mount_dir/pattern1
 umount $mount_dir
 lvchange -an $vg/$lv1
 
-lvconvert --yes --type writecache --cachepool $lv2 $vg/$lv1
+lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
@@ -90,7 +90,7 @@ lvchange -an $vg/$lv2
 
 # test2: create fs on LV after writecache is attached
 
-lvconvert --yes --type writecache --cachepool $lv2 $vg/$lv1
+lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
diff --git a/tools/args.h b/tools/args.h
index b3ba99e..3d72e8a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -121,7 +121,10 @@ arg(cachemode_ARG, '\0', "cachemode", cachemode_VAL, 0, 0,
     "block invalidates. See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0,
-    "The name of a cache pool LV.\n")
+    "The name of a cache pool.\n")
+
+arg(cachevol_ARG, '\0', "cachevol", lv_VAL, 0, 0,
+    "The name of a cache volume.\n")
 
 arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index eaa71ea..bf9d7df 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -453,30 +453,38 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
-ID: lvconvert_to_cache_vol
-DESC: Attach a cache to an LV, converts the LV to type cache.
+ID: lvconvert_to_cache_with_cachepool
+DESC: Attach a cache pool to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
-ID: lvconvert_to_cache_vol
-DESC: Attach a cache to an LV (infers --type cache).
+ID: lvconvert_to_cache_with_cachepool
+DESC: Attach a cache pool to an LV (infers --type cache).
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvconvert --type writecache --cachepool LV LV_linear_striped_raid
+lvconvert --type writecache --cachevol LV LV_linear_striped_raid
 OO: OO_LVCONVERT, --cachesettings String
-ID: lvconvert_to_writecache_vol
+ID: lvconvert_to_writecache
 DESC: Attach a writecache to an LV, converts the LV to type writecache.
 RULE: all and lv_is_visible
 
 ---
 
+lvconvert --type cache --cachevol LV LV_linear_striped_raid_thinpool
+OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chunksize SizeKB
+ID: lvconvert_to_cache_with_cachevol
+DESC: Attach a cache to an LV, converts the LV to type cache.
+RULE: all and lv_is_visible
+
+---
+
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
 --discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 975e24f..a40bfcf 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -621,7 +621,7 @@ static int _lvchange_cache(struct cmd_context *cmd,
 
 	seg = first_seg(lv);
 
-	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
 	else if (seg_is_cache_pool(seg))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9fa87c0..cd640ab 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1847,8 +1847,8 @@ static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
-	if (lv_is_cache_single(cache_seg->pool_lv)) {
-		if (!lv_detach_cache_single(lv))
+	if (lv_is_cache_vol(cache_seg->pool_lv)) {
+		if (!lv_detach_cache_vol(lv))
 			return_0;
 	} else {
 		if (!lv_cache_remove(lv))
@@ -2421,7 +2421,7 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 	struct logical_volume *pmslv;
 	struct logical_volume *mlv;
 
-	if (lv_is_cache(cache_lv) && lv_is_cache_single(first_seg(cache_lv)->pool_lv)) {
+	if (lv_is_cache(cache_lv) && lv_is_cache_vol(first_seg(cache_lv)->pool_lv)) {
 		log_error("Manual repair required.");
 		return 0;
 	}
@@ -3354,7 +3354,7 @@ revert_new_lv:
 #endif
 }
 
-static int _cache_single_attach(struct cmd_context *cmd,
+static int _cache_vol_attach(struct cmd_context *cmd,
 			        struct logical_volume *lv,
 			        struct logical_volume *lv_fast)
 {
@@ -3398,7 +3398,7 @@ static int _cache_single_attach(struct cmd_context *cmd,
 	if (arg_is_set(cmd, poolmetadatasize_ARG))
 		poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
 
-	if (!cache_single_set_params(cmd, cache_lv, lv_fast, poolmetadatasize, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
+	if (!cache_vol_set_params(cmd, cache_lv, lv_fast, poolmetadatasize, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
 		goto_out;
 
 	/*
@@ -4104,7 +4104,72 @@ int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_to_pool_single);
 }
 
-static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
+static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
+					  struct logical_volume *lv,
+					  struct processing_handle *handle)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *cachevol_lv;
+	const char *cachevol_name;
+
+	if (!(cachevol_name = arg_str_value(cmd, cachevol_ARG, NULL)))
+		goto_out;
+
+	if (!validate_lvname_param(cmd, &vg->name, &cachevol_name))
+		goto_out;
+
+	if (!(cachevol_lv = find_lv(vg, cachevol_name))) {
+		log_error("Cache single %s not found.", cachevol_name);
+		goto out;
+	}
+
+	/* Ensure the LV is not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		goto_out;
+
+	if (!dm_list_empty(&cachevol_lv->segs_using_this_lv)) {
+		log_error("LV %s is already in use.", display_lvname(cachevol_lv));
+		goto out;
+	}
+
+	if (!arg_is_set(cmd, yes_ARG) &&
+	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(cachevol_lv)) == 'n') {
+		log_error("Conversion aborted.");
+		goto out;
+	}
+
+	/* Ensure the LV is not active elsewhere. */
+	if (!lockd_lv(cmd, cachevol_lv, "ex", LDLV_PERSISTENT))
+		goto_out;
+
+	cachevol_lv->status |= LV_CACHE_VOL;
+
+	if (!wipe_cache_pool(cachevol_lv))
+		goto_out;
+
+	/* When the lv arg is a thinpool, redirect command to data sub lv. */
+
+	if (lv_is_thin_pool(lv)) {
+		lv = seg_lv(first_seg(lv), 0);
+		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
+	}
+
+	if (_raid_split_image_conversion(lv))
+		goto_out;
+
+	/* Attach the cache to the main LV. */
+
+	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
+		goto_out;
+
+	log_print_unless_silent("Logical volume %s is now cached.", display_lvname(lv));
+
+	return ECMD_PROCESSED;
+ out:
+	return ECMD_FAILED;
+}
+
+static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 					  struct logical_volume *lv,
 					  struct processing_handle *handle)
 {
@@ -4132,7 +4197,7 @@ static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
 	 * If using an existing cache pool, wipe it.
 	 */
 
-	if (!lv_is_cache_pool(cachepool_lv) && arg_is_set(cmd, poolmetadata_ARG)) {
+	if (!lv_is_cache_pool(cachepool_lv)) {
 		int lvt_enum = get_lvt_enum(cachepool_lv);
 		struct lv_type *lvtype = get_lv_type(lvt_enum);
 
@@ -4163,28 +4228,6 @@ static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
 			log_error("LV %s is not a cache pool.", display_lvname(cachepool_lv));
 			goto out;
 		}
-
-	} else if (!lv_is_cache_pool(cachepool_lv)) {
-
-		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
-			log_error("LV %s is already in use.", display_lvname(cachepool_lv));
-			goto out;
-		}
-
-		if (!arg_is_set(cmd, yes_ARG) &&
-		    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(cachepool_lv)) == 'n') {
-			log_error("Conversion aborted.");
-			goto out;
-		}
-
-		/* Ensure the LV is not active elsewhere. */
-		if (!lockd_lv(cmd, cachepool_lv, "ex", LDLV_PERSISTENT))
-			goto_out;
-
-		cachepool_lv->status |= LV_CACHE_SINGLE;
-
-		if (!wipe_cache_pool(cachepool_lv))
-			goto_out;
 	} else {
 		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
 			log_error("Cache pool %s is already in use.", cachepool_name);
@@ -4225,31 +4268,20 @@ static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
 
 	/* Attach the cache to the main LV. */
 
-	if (lv_is_cache_single(cachepool_lv)) {
-		if (!_cache_single_attach(cmd, lv, cachepool_lv))
-			goto_out;
-
-	} else if (lv_is_cache_pool(cachepool_lv)) {
-		if (!_cache_pool_attach(cmd, lv, cachepool_lv))
-			goto_out;
-
-	} else {
-		log_error(INTERNAL_ERROR "Invalid cache pool state for %s", cachepool_lv->name);
-		goto out;
-	}
+	if (!_cache_pool_attach(cmd, lv, cachepool_lv))
+		goto_out;
 
 	log_print_unless_silent("Logical volume %s is now cached.", display_lvname(lv));
 
 	return ECMD_PROCESSED;
-
  out:
 	return ECMD_FAILED;
 }
 
-int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv)
+int lvconvert_to_cache_with_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_cache_attach_single);
+			       NULL, NULL, &_lvconvert_cachepool_attach_single);
 }
 
 static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
@@ -4510,7 +4542,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast);
 
-static int _lvconvert_split_cache_single(struct cmd_context *cmd,
+static int _lvconvert_split_cache_vol(struct cmd_context *cmd,
 					 struct logical_volume *lv,
 					 struct processing_handle *handle)
 {
@@ -4565,7 +4597,7 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 
 	} else if (lv_is_cache(lv_main)) {
 		if ((cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) &&
-		    lv_is_cache_single(lv_fast)) {
+		    lv_is_cache_vol(lv_fast)) {
 			log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
 			log_error("The cache %s may then be removed with lvremove.", display_lvname(lv_fast));
 			return 0;
@@ -4600,7 +4632,7 @@ int lvconvert_split_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_split_cache_single);
+			       NULL, NULL, &_lvconvert_split_cache_vol);
 }
 
 static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -5453,7 +5485,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	char *lockd_fast_name = NULL;
 	struct id lockd_fast_id;
 
-	fast_name = arg_str_value(cmd, cachepool_ARG, "");
+	fast_name = arg_str_value(cmd, cachevol_ARG, "");
 
 	if (!(lv_fast = find_lv(vg, fast_name))) {
 		log_error("LV %s not found.", fast_name);
@@ -5559,7 +5591,7 @@ bad:
 
 }
 
-int lvconvert_to_writecache_vol_cmd(struct cmd_context *cmd, int argc, char **argv)
+int lvconvert_to_writecache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
 	struct lvconvert_result lr = { 0 };
@@ -5582,6 +5614,29 @@ int lvconvert_to_writecache_vol_cmd(struct cmd_context *cmd, int argc, char **ar
 	return ret;
 }
 
+int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
+	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE, handle, NULL,
+			      &_lvconvert_cachevol_attach_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
 /*
  * All lvconvert command defs have their own function,
  * so the generic function name is unused.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b2fb00d..44b7724 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -123,8 +123,9 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvconvert_to_thinpool_CMD,			lvconvert_to_pool_cmd },
 	{ lvconvert_to_cachepool_CMD,			lvconvert_to_pool_cmd },
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
-	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
-	{ lvconvert_to_writecache_vol_CMD,		lvconvert_to_writecache_vol_cmd },
+	{ lvconvert_to_cache_with_cachevol_CMD,		lvconvert_to_cache_with_cachevol_cmd },
+	{ lvconvert_to_cache_with_cachepool_CMD,	lvconvert_to_cache_with_cachepool_cmd },
+	{ lvconvert_to_writecache_CMD,			lvconvert_to_writecache_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
 	{ lvconvert_to_thinpool_or_swap_metadata_CMD,   lvconvert_to_pool_or_swap_metadata_cmd },
 	{ lvconvert_to_cachepool_or_swap_metadata_CMD,  lvconvert_to_pool_or_swap_metadata_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index ab9503e..69132a5 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -250,8 +250,9 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv);
-int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
-int lvconvert_to_writecache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_cache_with_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_writecache_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_pool_or_swap_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 87f48df..7150570 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -402,7 +402,7 @@ static int _move_cache(struct volume_group *vg_from,
 
 		/* NOTREACHED */
 
-		if (lv_is_cache(lv) && lv_is_cache_single(seg->pool_lv)) {
+		if (lv_is_cache(lv) && lv_is_cache_vol(seg->pool_lv)) {
 			log_error("Cannot split while LV %s has cache attached.", display_lvname(lv));
 			return 0;
 		} else if (lv_is_cache(lv)) {


