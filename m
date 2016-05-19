From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 May 2016 16:41:34 +0000 (UTC)
Subject: master - lvchange: allow change of cache mode
Message-ID: <20160519164134.0C267602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=197066c863607a884c0eef2f16d969aa00adcab1
Commit:        197066c863607a884c0eef2f16d969aa00adcab1
Parent:        8fd886f735125de4b3e32fc0a188af0192a0d173
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 25 13:39:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 19 18:40:14 2016 +0200

lvchange: allow change of cache mode

Add support for active cache LV.
Handle --cachemode args validation during command line processing.
Rework some lvm2 internal to use lvm2 defined  CACHE_MODE  enums
indepently on libdm defines and use enum around the code instead
of passing and comparing strings.
---
 WHATS_NEW                        |    1 +
 lib/cache_segtype/cache.c        |   61 ++++++++++++------
 lib/metadata/cache_manip.c       |  132 ++++++++++++++++++++++---------------
 lib/metadata/merge.c             |   21 +++----
 lib/metadata/metadata-exported.h |   18 ++++--
 lib/report/report.c              |   13 +----
 man/lvchange.8.in                |   18 +++++
 test/shell/lvconvert-cache.sh    |    4 +-
 tools/args.h                     |    2 +-
 tools/commands.h                 |    4 +-
 tools/lvchange.c                 |   50 +++++++++++---
 tools/lvconvert.c                |    8 +-
 tools/lvmcmdline.c               |   13 ++++
 tools/toollib.c                  |    6 +-
 tools/toollib.h                  |    2 +-
 tools/tools.h                    |    1 +
 16 files changed, 227 insertions(+), 127 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9b9265c..645e87e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Add support for lvchange --cachemode for cached LV.
   Fix liblvm2app error handling when setting up context.
   Delay liblvm2app init in python code until it is needed.
   Simplify thread locking in lvmetad to fix locking problems.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 9d56f32..4fb06e7 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2013-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,6 +26,8 @@
 #include "defaults.h"
 
 static const char _cache_module[] = "cache";
+#define CACHE_POLICY_WHEN_MISSING   "mq"
+#define CACHE_MODE_WHEN_MISSING	    CACHE_MODE_WRITETHROUGH
 
 /* TODO: using static field here, maybe should be a part of segment_type */
 static unsigned _feature_mask;
@@ -41,24 +43,21 @@ static unsigned _feature_mask;
  *
  * Needs both segments cache and cache_pool to be loaded.
  */
-static int _fix_missing_defaults(struct lv_segment *cpool_seg)
+static void _fix_missing_defaults(struct lv_segment *cpool_seg)
 {
 	if (!cpool_seg->policy_name) {
-		cpool_seg->policy_name = "mq";
-		log_verbose("Cache is missing cache policy, using %s.",
+		cpool_seg->policy_name = CACHE_POLICY_WHEN_MISSING;
+		log_verbose("Cache pool %s is missing cache policy, using %s.",
+			    display_lvname(cpool_seg->lv),
 			    cpool_seg->policy_name);
 	}
 
-	if (!cache_mode_is_set(cpool_seg)) {
-		if (!cache_set_mode(cpool_seg, "writethrough")) {
-			log_error(INTERNAL_ERROR "Failed to writethrough cache mode.");
-			return 0;
-		}
-		log_verbose("Cache is missing cache mode, using %s.",
+	if (cpool_seg->cache_mode == CACHE_MODE_UNDEFINED) {
+		cpool_seg->cache_mode = CACHE_MODE_WHEN_MISSING;
+		log_verbose("Cache pool %s is missing cache mode, using %s.",
+			    display_lvname(cpool_seg->lv),
 			    get_cache_mode_name(cpool_seg));
 	}
-
-	return 1;
 }
 
 static int _cache_pool_text_import(struct lv_segment *seg,
@@ -97,7 +96,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (dm_config_has_node(sn, "cache_mode")) {
 		if (!(str = dm_config_find_str(sn, "cache_mode", NULL)))
 			return SEG_LOG_ERROR("cache_mode must be a string in");
-		if (!cache_set_mode(seg, str))
+		if (!set_cache_mode(&seg->cache_mode, str))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
 	}
 
@@ -141,9 +140,9 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (!attach_pool_metadata_lv(seg, meta_lv))
 		return_0;
 
-	if (!dm_list_empty(&seg->lv->segs_using_this_lv) &&
-	    !_fix_missing_defaults(seg))
-		return_0;
+	/* when cache pool is used, we require policy and mode to be defined */
+	if (!dm_list_empty(&seg->lv->segs_using_this_lv))
+		_fix_missing_defaults(seg);
 
 	return 1;
 }
@@ -170,7 +169,7 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	 * but not worth to break backward compatibility, by shifting
 	 * content to cache segment
 	 */
-	if (cache_mode_is_set(seg)) {
+	if (seg->cache_mode != CACHE_MODE_UNDEFINED) {
 		if (!(cache_mode = get_cache_mode_name(seg)))
 			return_0;
 		outf(f, "cache_mode = \"%s\"", cache_mode);
@@ -358,9 +357,9 @@ static int _cache_text_import(struct lv_segment *seg,
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_0;
 
-	if (!dm_list_empty(&pool_lv->segments) &&
-	    !_fix_missing_defaults(first_seg(pool_lv)))
-		return_0;
+	/* load order is unknown, could be cache origin or pool LV, so check for both */
+	if (!dm_list_empty(&pool_lv->segments))
+		_fix_missing_defaults(first_seg(pool_lv));
 
 	return 1;
 }
@@ -399,6 +398,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 {
 	struct lv_segment *cache_pool_seg;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
+	uint64_t feature_flags = 0;
 
 	if (!seg->pool_lv || !seg_is_cache(seg)) {
 		log_error(INTERNAL_ERROR "Passed segment is not cache.");
@@ -406,6 +406,25 @@ static int _cache_add_target_line(struct dev_manager *dm,
 	}
 
 	cache_pool_seg = first_seg(seg->pool_lv);
+	if (seg->cleaner_policy)
+		/* With cleaner policy always pass writethrough */
+		feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+	else
+		switch (cache_pool_seg->cache_mode) {
+		default:
+			log_error(INTERNAL_ERROR "LV %s has unknown cache mode %d.",
+				  display_lvname(seg->lv), cache_pool_seg->cache_mode);
+			/* Fall through */
+		case CACHE_MODE_WRITETHROUGH:
+			feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+			break;
+		case CACHE_MODE_WRITEBACK:
+			feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+			break;
+		case CACHE_MODE_PASSTHROUGH:
+			feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
+			break;
+		}
 
 	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
@@ -417,7 +436,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		return_0;
 
 	if (!dm_tree_node_add_cache_target(node, len,
-					   cache_pool_seg->feature_flags,
+					   feature_flags,
 					   metadata_uuid,
 					   data_uuid,
 					   origin_uuid,
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 27a716a..a39549d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -29,76 +29,91 @@
 #define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
 #define DM_MAX_HINT_WIDTH		(4+16)  /* bytes.  FIXME Configurable? */
 
-int cache_mode_is_set(const struct lv_segment *seg)
+const char *display_cache_mode(const struct lv_segment *seg)
 {
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 
-	return (seg->feature_flags & (DM_CACHE_FEATURE_WRITEBACK |
-				      DM_CACHE_FEATURE_WRITETHROUGH |
-				      DM_CACHE_FEATURE_PASSTHROUGH)) ? 1 : 0;
+	if (!seg_is_cache_pool(seg) ||
+	    (seg->cache_mode == CACHE_MODE_UNDEFINED))
+		return "";
+
+	return get_cache_mode_name(seg);
 }
 
-const char *get_cache_mode_name(const struct lv_segment *seg)
-{
-	if (seg->feature_flags & DM_CACHE_FEATURE_PASSTHROUGH)
-		return "passthrough";
 
-	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+const char *get_cache_mode_name(const struct lv_segment *pool_seg)
+{
+	switch (pool_seg->cache_mode) {
+	default:
+		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
+			  display_lvname(pool_seg->lv));
+		/* Fall through */
+	case CACHE_MODE_WRITETHROUGH:
+		return "writethrough";
+	case CACHE_MODE_WRITEBACK:
 		return "writeback";
+	case CACHE_MODE_PASSTHROUGH:
+		return "passthrough";
+	}
+}
 
-	if (!(seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
-		log_error(INTERNAL_ERROR "LV %s has uknown feature flags %" PRIu64 ", "
-			  "returning writethrough instead.",
-			  display_lvname(seg->lv), seg->feature_flags);
+int set_cache_mode(cache_mode_t *mode, const char *cache_mode)
+{
+	if (!strcasecmp(cache_mode, "writethrough"))
+		*mode = CACHE_MODE_WRITETHROUGH;
+	else if (!strcasecmp(cache_mode, "writeback"))
+		*mode = CACHE_MODE_WRITEBACK;
+	else if (!strcasecmp(cache_mode, "passthrough"))
+		*mode = CACHE_MODE_PASSTHROUGH;
+	else {
+		log_error("Unknown cache mode: %s.", cache_mode);
+		return 0;
+	}
 
-	return "writethrough";
+	return 1;
 }
 
-int cache_set_mode(struct lv_segment *seg, const char *str)
+int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
+	const char *str;
 	int id;
-	uint64_t mode;
-
-	if (!str && !seg_is_cache(seg))
-		return 1;			/* Defaults only for cache */
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
+	else if (seg_is_cache_pool(seg)) {
+		if (mode == CACHE_MODE_UNDEFINED)
+			return 1;	/* Defaults only for cache */
+	} else {
+		log_error(INTERNAL_ERROR "Cannot set cache mode for non cache volume %s.",
+			  display_lvname(seg->lv));
+		return 0;
+	}
 
-	if (!str) {
-		if (cache_mode_is_set(seg))
-			return 1;               /* Default already set in cache pool */
+	if (mode != CACHE_MODE_UNDEFINED) {
+		seg->cache_mode = mode;
+		return 1;
+	}
 
-		id = allocation_cache_mode_CFG;
+	if (seg->cache_mode != CACHE_MODE_UNDEFINED)
+		return 1;               /* Default already set in cache pool */
 
-		/* If present, check backward compatible settings */
-		if (!find_config_node(cmd, cmd->cft, id) &&
-		    find_config_node(cmd, cmd->cft, allocation_cache_pool_cachemode_CFG))
-			id = allocation_cache_pool_cachemode_CFG;
+	/* Figure default settings from config/profiles */
+	id = allocation_cache_mode_CFG;
 
-		if (!(str = find_config_tree_str(cmd, id, NULL))) {
-			log_error(INTERNAL_ERROR "Cache mode is not determined.");
-			return 0;
-		}
-	}
+	/* If present, check backward compatible settings */
+	if (!find_config_node(cmd, cmd->cft, id) &&
+	    find_config_node(cmd, cmd->cft, allocation_cache_pool_cachemode_CFG))
+		id = allocation_cache_pool_cachemode_CFG;
 
-	if (!strcmp(str, "writeback"))
-		mode = DM_CACHE_FEATURE_WRITEBACK;
-	else if (!strcmp(str, "writethrough"))
-		mode = DM_CACHE_FEATURE_WRITETHROUGH;
-	else if (!strcmp(str, "passthrough"))
-		mode = DM_CACHE_FEATURE_PASSTHROUGH;
-	else {
-		log_error("Cannot set unknown cache mode \"%s\".", str);
+	if (!(str = find_config_tree_str(cmd, id, NULL))) {
+		log_error(INTERNAL_ERROR "Cache mode is not determined.");
 		return 0;
 	}
 
-	seg->feature_flags &= ~(DM_CACHE_FEATURE_WRITEBACK |
-				DM_CACHE_FEATURE_WRITETHROUGH |
-				DM_CACHE_FEATURE_PASSTHROUGH);
-	seg->feature_flags |= mode;
+	if (!(set_cache_mode(&seg->cache_mode, str)))
+		return_0;
 
 	return 1;
 }
@@ -111,7 +126,7 @@ void cache_check_for_warns(const struct lv_segment *seg)
 	struct logical_volume *origin_lv = seg_lv(seg, 0);
 
 	if (lv_is_raid(origin_lv) &&
-	    first_seg(seg->pool_lv)->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+	    first_seg(seg->pool_lv)->cache_mode == CACHE_MODE_WRITEBACK)
 		log_warn("WARNING: Data redundancy is lost with writeback "
 			 "caching of raid logical volume!");
 
@@ -313,6 +328,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
  */
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 {
+	const struct logical_volume *lock_lv = lv_lock_holder(cache_lv);
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct lv_status_cache *status;
 	int cleaner_policy;
@@ -326,7 +342,8 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 			return_0;
 		if (status->cache->fail) {
 			dm_pool_destroy(status->mem);
-			log_warn("WARNING: Skippping flush for failed cache.");
+			log_warn("WARNING: Skippping flush for failed cache %s.",
+				 display_lvname(cache_lv));
 			return 1;
 		}
 
@@ -342,23 +359,31 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 		if (!dirty_blocks)
 			break;
 
+		log_print_unless_silent("Flushing " FMTu64 " blocks for cache %s.",
+					dirty_blocks, display_lvname(cache_lv));
 		if (cleaner_policy) {
-			log_print_unless_silent(FMTu64 " blocks must still be flushed.",
-						dirty_blocks);
 			/* TODO: Use centralized place */
 			usleep(500000);
 			continue;
 		}
 
 		/* Switch to cleaner policy to flush the cache */
-		log_print_unless_silent("Flushing cache for %s.",
-					display_lvname(cache_lv));
 		cache_seg->cleaner_policy = 1;
 		/* Reaload kernel with "cleaner" policy */
 		if (!lv_update_and_reload_origin(cache_lv))
 			return_0;
 	}
 
+	/*
+	 * TODO: add check if extra suspend resume is necessary
+	 * ATM this is workaround for missing cache sync when cache gets clean
+	 */
+	if (1) {
+		if (!lv_refresh_suspend_resume(lock_lv->vg->cmd, lock_lv))
+			return_0;
+	}
+
+	cache_seg->cleaner_policy = 0;
 	*is_clean = 1;
 
 	return 1;
@@ -401,8 +426,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 			return 0;
 		}
 		/* For inactive writethrough just drop cache layer */
-		if (first_seg(cache_seg->pool_lv)->feature_flags &
-		    DM_CACHE_FEATURE_WRITETHROUGH) {
+		if (first_seg(cache_seg->pool_lv)->cache_mode == CACHE_MODE_WRITETHROUGH) {
 			corigin_lv = seg_lv(cache_seg, 0);
 			if (!detach_pool_lv(cache_seg))
 				return_0;
@@ -636,14 +660,14 @@ out:
  * to update all commonly specified cache parameters
  */
 int cache_set_params(struct lv_segment *seg,
-		     const char *cache_mode,
+		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings,
 		     uint32_t chunk_size)
 {
 	struct lv_segment *pool_seg;
 
-	if (!cache_set_mode(seg, cache_mode))
+	if (!cache_set_cache_mode(seg, mode))
 		return_0;
 
 	if (!cache_set_policy(seg, policy_name, policy_settings))
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 17227c1..4f730e0 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -223,18 +223,15 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 			if (seg_is_cache_pool(seg) &&
 			    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
-				switch (seg->feature_flags &
-					(DM_CACHE_FEATURE_PASSTHROUGH |
-					 DM_CACHE_FEATURE_WRITETHROUGH |
-					 DM_CACHE_FEATURE_WRITEBACK)) {
-					 case DM_CACHE_FEATURE_PASSTHROUGH:
-					 case DM_CACHE_FEATURE_WRITETHROUGH:
-					 case DM_CACHE_FEATURE_WRITEBACK:
-						 break;
-					 default:
-						 log_error("LV %s has invalid cache's feature flag.",
-							   lv->name);
-						 inc_error_count;
+				switch (seg->cache_mode) {
+				case CACHE_MODE_WRITETHROUGH:
+				case CACHE_MODE_WRITEBACK:
+				case CACHE_MODE_PASSTHROUGH:
+					break;
+				default:
+					log_error("LV %s has invalid cache's feature flag.",
+						  lv->name);
+					inc_error_count;
 				}
 				if (!seg->policy_name) {
 					log_error("LV %s is missing cache policy name.", lv->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b3f450a..a850492 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -274,6 +274,13 @@ typedef enum {
 } thin_discards_t;
 
 typedef enum {
+	CACHE_MODE_UNDEFINED = 0,
+	CACHE_MODE_WRITETHROUGH,
+	CACHE_MODE_WRITEBACK,
+	CACHE_MODE_PASSTHROUGH,
+} cache_mode_t;
+
+typedef enum {
 	LOCK_TYPE_INVALID = -1,
 	LOCK_TYPE_NONE = 0,
 	LOCK_TYPE_CLVM = 1,
@@ -472,7 +479,7 @@ struct lv_segment {
 	struct logical_volume *pool_lv;		/* For thin, cache */
 	uint32_t device_id;			/* For thin, 24bit */
 
-	uint64_t feature_flags;			/* For cache_pool */
+	cache_mode_t cache_mode;		/* For cache_pool */
 	const char *policy_name;		/* For cache_pool */
 	struct dm_config_node *policy_settings;	/* For cache_pool */
 	unsigned cleaner_policy;		/* For cache */
@@ -948,7 +955,7 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
-	const char *cache_mode; /* cache */
+	cache_mode_t cache_mode; /* cache */
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */
 
@@ -1211,13 +1218,14 @@ struct lv_status_cache {
 	dm_percent_t dirty_usage;
 };
 
+const char *display_cache_mode(const struct lv_segment *seg);
 const char *get_cache_mode_name(const struct lv_segment *cache_seg);
-int cache_mode_is_set(const struct lv_segment *seg);
-int cache_set_mode(struct lv_segment *cache_seg, const char *str);
+int set_cache_mode(cache_mode_t *mode, const char *cache_mode);
+int cache_set_cache_mode(struct lv_segment *cache_seg, cache_mode_t mode);
 int cache_set_policy(struct lv_segment *cache_seg, const char *name,
 		     const struct dm_config_tree *settings);
 int cache_set_params(struct lv_segment *seg,
-		     const char *cache_mode,
+		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings,
 		     uint32_t chunk_size);
diff --git a/lib/report/report.c b/lib/report/report.c
index 3a58cee..92eb64c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2504,19 +2504,8 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	const char *cachemode_str;
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
-
-	if (seg_is_cache_pool(seg) && cache_mode_is_set(seg)) {
-		if (!(cachemode_str = get_cache_mode_name(seg)))
-			return_0;
-
-		return _field_string(rh, field, cachemode_str);
-	}
-
-	return _field_set_value(field, "", NULL);
+	return _field_string(rh, field, display_cache_mode(seg));
 }
 
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 34ce583..2bfe7c0 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -25,6 +25,8 @@ lvchange \(em change attributes of a logical volume
 .IR AllocationPolicy ]
 .RB [ \-A | \-\-autobackup
 .RB { y | n }]
+.RB [ \-\-cachemode
+.RB { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
 .IR Policy ]
 .RB [ \-\-cachesettings
@@ -186,6 +188,22 @@ the flag is attached, use \fBlvs\fP(8) command where the state
 of the flag is reported within \fBlv_attr\fP bits.
 .
 .HP
+.BR \-\-cachemode
+.RB { passthrough | writeback | writethrough }
+.br
+Specifying a cache mode determines when the writes to a cache LV
+are considered complete.  When \fBwriteback\fP is specified, a write is
+considered complete as soon as it is stored in the cache pool LV.
+If \fBwritethough\fP is specified, a write is considered complete only
+when it has been stored in the cache pool LV and on the origin LV.
+While \fBwritethrough\fP may be slower for writes, it is more
+resilient if something should happen to a device associated with the
+cache pool LV. With \fBpassthrough\fP mode, all reads are served
+from origin LV (all reads miss the cache) and all writes are
+forwarded to the origin LV; additionally, write hits cause cache
+block invalidates. See \fBlvmcache(7)\fP for more details.
+.
+.HP
 .BR  \-\-cachepolicy
 .IR Policy ,
 .BR \-\-cachesettings
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 8e38050..cab5964 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -39,7 +39,7 @@ lvcreate -an -Zn -L 8 -n $lv4 $vg
 lvcreate -an -Zn -L 16 -n $lv5 $vg
 
 # check validation of cachemode arg works
-fail lvconvert --yes --type cache-pool --cachemode writethroughX --cachepool $vg/$lv1
+invalid lvconvert --yes --type cache-pool --cachemode writethroughX --cachepool $vg/$lv1
 
 # by default no cache settings are attached to converted cache-pool
 lvconvert --yes --type cache-pool --chunksize 256 $vg/$lv1
diff --git a/tools/args.h b/tools/args.h
index ebddd2e..ef9dbc9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -27,7 +27,7 @@ arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(binary_ARG, '\0', "binary", NULL, 0)
 arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", size_mb_arg, 0)
 arg(cache_long_ARG, '\0', "cache", NULL, 0)
-arg(cachemode_ARG, '\0', "cachemode", string_arg, 0)
+arg(cachemode_ARG, '\0', "cachemode", cachemode_arg, 0)
 arg(cachepool_ARG, '\0', "cachepool", string_arg, 0)
 arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 7b32835..da432a7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -146,6 +146,7 @@ xx(lvchange,
    "\t[--addtag <Tag>]\n"
    "\t[--alloc <AllocationPolicy>]\n"
    "\t[-C|--contiguous {y|n}]\n"
+   "\t[--cachemode <CacheMode>]\n"
    "\t[--cachepolicy <policyname>] [--cachesettings <parameter=value>]\n"
    "\t[--commandprofile <ProfileName>]\n"
    "\t[-d|--debug]\n"
@@ -185,7 +186,8 @@ xx(lvchange,
    "\t<LogicalVolume[Path]> [<LogicalVolume[Path]>...]\n",
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
-   available_ARG, cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG,
+   available_ARG, cachemode_ARG, cachepolicy_ARG, cachesettings_ARG,
+   contiguous_ARG, deltag_ARG,
    discards_ARG, detachprofile_ARG, errorwhenfull_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 83da6bc..c37a597 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -678,24 +678,50 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 {
+	cache_mode_t mode;
 	const char *name;
 	struct dm_config_tree *settings = NULL;
-	int r = 0;
-
-	if (!lv_is_cache(lv) && !lv_is_cache_pool(lv)) {
-		log_error("LV %s is not a cache LV.", lv->name);
-		log_error("Only cache or cache pool devices can have --cachepolicy set.");
+	struct lv_segment *pool_seg = first_seg(lv);
+	int r = 0, is_clean;
+
+	if (lv_is_cache(lv))
+		pool_seg = first_seg(pool_seg->pool_lv);
+        else if (!lv_is_cache_pool(lv)) {
+		log_error("LV %s is not a cache LV.", display_lvname(lv));
+		(void) arg_from_list_is_set(cmd, "is supported only with cache or cache pool LVs",
+					    cachemode_ARG,
+					    cachepolicy_ARG,
+					    cachesettings_ARG,
+					    -1);
 		goto out;
 	}
 
-	if (!get_cache_params(cmd, NULL, &name, &settings))
+	if (!get_cache_params(cmd, &mode, &name, &settings))
+		goto_out;
+
+	if ((mode != CACHE_MODE_UNDEFINED) &&
+	    (mode != pool_seg->cache_mode)) {
+		if (!lv_cache_wait_for_clean(lv, &is_clean))
+			return_0;
+		if (!is_clean) {
+			log_error("Cache %s is not clean, refusing to switch cache mode.",
+				  display_lvname(lv));
+			return 0;
+		}
+	}
+
+	if (mode && !cache_set_cache_mode(first_seg(lv), mode))
 		goto_out;
-	if (!cache_set_policy(first_seg(lv), name, settings))
+
+	if ((name || settings) &&
+	    !cache_set_policy(first_seg(lv), name, settings))
 		goto_out;
+
 	if (!lv_update_and_reload(lv))
 		goto_out;
+
 	r = 1;
 out:
 	if (settings)
@@ -1135,15 +1161,16 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
-	if (arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) {
+	if (arg_is_set(cmd, cachemode_ARG) ||
+	    arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += _lvchange_cachepolicy(cmd, lv);
+		doit += _lvchange_cache(cmd, lv);
 		docmds++;
 	}
 
 	if (doit)
-		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
+		log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
 
 	if (arg_count(cmd, resync_ARG) &&
 	    !_lvchange_resync(cmd, lv))
@@ -1199,6 +1226,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	int update_partial_unsafe =
 		arg_from_list_is_set(cmd, NULL,
 				     alloc_ARG,
+				     cachemode_ARG,
 				     cachepolicy_ARG,
 				     cachesettings_ARG,
 				     discards_ARG,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c544e36..39ce759 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -51,7 +51,7 @@ struct lvconvert_params {
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
-	const char *cache_mode; /* cache */
+	cache_mode_t cache_mode; /* cache */
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */
 
@@ -2024,7 +2024,7 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 
 	/* TODO: Check for failed cache as well to get prompting? */
 	if (lv_is_partial(lv)) {
-		if (strcmp("writethrough", get_cache_mode_name(first_seg(seg->pool_lv)))) {
+		if (first_seg(seg->pool_lv)->cache_mode != CACHE_MODE_WRITETHROUGH) {
 			if (!lp->force) {
 				log_error("Conversion aborted.");
 				log_error("Cannot uncache writethrough cache volume %s without --force.",
@@ -3116,7 +3116,7 @@ mda_write:
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
 
 	if (lp->cache_mode &&
-	    !cache_set_mode(seg, lp->cache_mode))
+	    !cache_set_cache_mode(seg, lp->cache_mode))
 		return_0;
 
 	if ((lp->policy_name || lp->policy_settings) &&
@@ -3228,7 +3228,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
 		return_0;
 
-	if (!cache_set_mode(first_seg(cache_lv), lp->cache_mode))
+	if (!cache_set_cache_mode(first_seg(cache_lv), lp->cache_mode))
 		return_0;
 
 	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fa9cd8f..4009921 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -328,6 +328,19 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 	return 1;
 }
 
+int cachemode_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+{
+	cache_mode_t mode;
+
+	if (!set_cache_mode(&mode, av->value))
+		return_0;
+
+	av->i_value = mode;
+	av->ui_value = mode;
+
+	return 1;
+}
+
 int discards_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	thin_discards_t discards;
diff --git a/tools/toollib.c b/tools/toollib.c
index ab1361d..4859ec0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1334,7 +1334,7 @@ static int _validate_cachepool_params(const char *name,
 }
 
 int get_cache_params(struct cmd_context *cmd,
-		     const char **mode,
+		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings)
 {
@@ -1344,8 +1344,8 @@ int get_cache_params(struct cmd_context *cmd,
 	struct dm_config_node *cn;
 	int ok = 0;
 
-	if (mode)
-		*mode = arg_str_value(cmd, cachemode_ARG, NULL);
+	if (cache_mode)
+		*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNDEFINED);
 
 	if (name)
 		*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
diff --git a/tools/toollib.h b/tools/toollib.h
index 19f4dd0..2b3ca6e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -194,7 +194,7 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
 int get_cache_params(struct cmd_context *cmd,
-		     const char **mode,
+		     cache_mode_t *cache_mode,
 		     const char **name,
 		     struct dm_config_tree **settings);
 
diff --git a/tools/tools.h b/tools/tools.h
index cfb79de..2abc750 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -133,6 +133,7 @@ void usage(const char *name);
 /* the argument verify/normalise functions */
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
 int activation_arg(struct cmd_context *cmd, struct arg_values *av);
+int cachemode_arg(struct cmd_context *cmd, struct arg_values *av);
 int discards_arg(struct cmd_context *cmd, struct arg_values *av);
 int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);


