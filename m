From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:09 -0600
Subject: [LVM PATCH 3/6] cache: Code changes to allow creation of cache pools
In-Reply-To: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
References: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1391212992-3439-4-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows the creation of cache pools.  Users are not yet able
to create cache LV.  They are only able to define the space used
for the cache and its characteristics (chunk_size and cache mode ATM) by
creating the cache pool.

I would still like to see the following generalized:
- update_pool_params
---
 lib/config/defaults.h            |    3 +-
 lib/format_text/flags.c          |    4 ++
 lib/metadata/lv_manip.c          |   46 ++++++++++------
 lib/metadata/merge.c             |   49 ++++++++++++-----
 lib/metadata/metadata-exported.h |    2 +
 libdm/libdevmapper.h             |    5 ++
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++-
 tools/lvcreate.c                 |  109 ++++++++++++++++++++++++++++++++++----
 9 files changed, 182 insertions(+), 44 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index a388e13..cb2b88c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -77,9 +77,10 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
-#define DEFAULT_POOL_METADATA_SPARE 1
+#define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
+#define DEFAULT_CACHE_POOL_CHUNK_SIZE DEFAULT_THIN_POOL_CHUNK_SIZE
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index e31429e..bc48952 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -83,6 +83,10 @@ static const struct flag _lv_flags[] = {
 	{THIN_POOL, NULL, 0},
 	{THIN_POOL_DATA, NULL, 0},
 	{THIN_POOL_METADATA, NULL, 0},
+	{CACHE, NULL, 0},
+	{CACHE_POOL, NULL, 0},
+	{CACHE_POOL_DATA, NULL, 0},
+	{CACHE_POOL_METADATA, NULL, 0},
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e95b7e5..7659c3d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2998,8 +2998,13 @@ int lv_extend(struct logical_volume *lv,
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
-	if (!lv->le_count && segtype_is_thin_pool(segtype)) {
-		/* Thin pool allocation treats its metadata device like a mirror log. */
+	if (!lv->le_count &&
+	    (segtype_is_thin_pool(segtype) ||
+	     segtype_is_cache_pool(segtype))) {
+		/*
+		 * Thinpool and cache_pool allocations treat the metadata
+		 * device like a mirror log.
+		 */
 		/* FIXME Allow pool and data on same device with NORMAL */
 		/* FIXME Support striped metadata pool */
 		log_count = 1;
@@ -3012,10 +3017,10 @@ int lv_extend(struct logical_volume *lv,
 				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (segtype_is_thin_pool(segtype)) {
+	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
 		if (lv->le_count) {
 			/* lv_resize abstracts properly _tdata */
-			log_error(INTERNAL_ERROR "Cannot lv_extend() the existing thin pool segment.");
+			log_error(INTERNAL_ERROR "Cannot lv_extend() the existing %s segment.", segtype->name);
 			return 0;
 		}
 		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
@@ -5702,7 +5707,7 @@ out:
 static int _should_wipe_lv(struct lvcreate_params *lp, struct logical_volume *lv) {
 	int r = lp->zero | lp->wipe_signatures;
 
-	if (!seg_is_thin(lp))
+	if (!seg_is_thin(lp) && !seg_is_cache_pool(lp))
 		return r;
 
 	if (lv_is_thin_volume(lv))
@@ -5871,10 +5876,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (seg_is_thin_pool(lp) &&
-	    ((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
-		log_error("Unable to create thin pool smaller than 1 chunk.");
-		return NULL;
+	if (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) {
+		if (((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
+			log_error("Unable to create %s smaller than 1 chunk.",
+				  lp->segtype->name);
+			return NULL;
+		}
 	}
 
 	if (lp->snapshot && !seg_is_thin(lp) &&
@@ -5906,7 +5913,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!activation() &&
 	    (seg_is_mirrored(lp) ||
 	     seg_is_raid(lp) ||
-	     seg_is_thin_pool(lp))) {
+	     seg_is_thin_pool(lp) ||
+	     seg_is_cache_pool(lp))) {
 		/*
 		 * FIXME: For thin pool add some code to allow delayed
 		 * initialization of empty thin pool volume.
@@ -5915,9 +5923,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 */
 		log_error("Can't create %s without using "
 			  "device-mapper kernel driver.",
-			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
-			  segtype_is_mirrored(lp->segtype) ?  "mirror" :
-			  "thin pool volume");
+			  seg_is_thin_pool(lp) ? "thin pool volume" :
+			  lp->segtype->name);
 		return NULL;
 	}
 
@@ -6003,12 +6010,17 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
-		       seg_is_thin_pool(lp) ? lp->poolmetadataextents : lp->region_size,
+		       (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) ?
+		       lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
 		       thin_name, lp->pvh, lp->alloc))
 		return_NULL;
 
-	if (seg_is_thin_pool(lp)) {
+	if (seg_is_cache_pool(lp)) {
+		if (!_recalculate_pool_chunk_size_with_dev_hints(lp, lv))
+			return_NULL;
+		first_seg(lv)->feature_flags = lp->feature_flags;
+	} else if (seg_is_thin_pool(lp)) {
 		if (!_recalculate_pool_chunk_size_with_dev_hints(lp, lv))
 			return_NULL;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
@@ -6114,7 +6126,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->temporary)
 		lv->status |= LV_TEMPORARY;
 
-	if (lv_is_thin_pool(lv)) {
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		if (is_change_activating(lp->activate)) {
 			if (vg_is_clustered(lv->vg)) {
 				if (!activate_lv_excl(cmd, lv)) {
@@ -6294,7 +6306,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 	struct logical_volume *lv;
 
 	/* Create thin pool first if necessary */
-	if (lp->create_pool) {
+	if (lp->create_pool && !seg_is_cache_pool(lp)) {
 		if (!seg_is_thin_pool(lp) &&
 		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 			return_0;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 93e4bfa..5ef2eea 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -190,31 +190,54 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					inc_error_count;
 				}
 
-				if (seg->area_count != 1 || seg_type(seg, 0) != AREA_LV) {
-					log_error("LV %s: thin pool segment %u is missing a pool data LV",
-						  lv->name, seg_count);
+			}
+			if (seg_is_thin_pool(seg) || seg_is_cache_pool(seg)) {
+				if (seg->area_count != 1 ||
+				    seg_type(seg, 0) != AREA_LV) {
+					log_error("LV %s: %spool segment %u is missing a pool data LV",
+						  lv->name,
+						  seg_is_thin_pool(seg) ?
+						  "thin " : "cache",
+						  seg_count);
 					inc_error_count;
 				} else if (!(seg2 = first_seg(seg_lv(seg, 0))) || find_pool_seg(seg2) != seg) {
-					log_error("LV %s: thin pool segment %u data LV does not refer back to pool LV",
-						  lv->name, seg_count);
+					log_error("LV %s: %spool segment %u data LV does not refer back to pool LV",
+						  lv->name,
+						  seg_is_thin_pool(seg) ?
+						  "thin " : "cache",
+						  seg_count);
 					inc_error_count;
 				}
 
 				if (!seg->metadata_lv) {
-					log_error("LV %s: thin pool segment %u is missing a pool metadata LV",
-						  lv->name, seg_count);
+					log_error("LV %s: %spool segment %u is missing a pool metadata LV",
+						  lv->name,
+						  seg_is_thin_pool(seg) ?
+						  "thin " : "cache",
+						  seg_count);
 					inc_error_count;
 				} else if (!(seg2 = first_seg(seg->metadata_lv)) ||
 					   find_pool_seg(seg2) != seg) {
-					log_error("LV %s: thin pool segment %u metadata LV does not refer back to pool LV",
-						  lv->name, seg_count);
+					log_error("LV %s: %spool segment %u metadata LV does not refer back to pool LV",
+						  lv->name,
+						  seg_is_thin_pool(seg) ?
+						  "thin " : "cache",
+						  seg_count);
 					inc_error_count;
 				}
 
-				if (seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
-				    seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-					log_error("LV %s: thin pool segment %u has chunk size %u out of range.",
-						  lv->name, seg_count, seg->chunk_size);
+				if ((seg_is_thin_pool(seg) &&
+				     (seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+				     (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) ||
+				    (seg_is_cache_pool(seg) &&
+				     (seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
+				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)))
+{
+					log_error("LV %s: %spool segment %u has chunk size %u out of range.",
+						  lv->name,
+						  seg_is_thin_pool(seg) ?
+						  "thin " : "cache",
+						  seg_count, seg->chunk_size);
 					inc_error_count;
 				}
 			} else {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d8eef2d..e296453 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -793,6 +793,8 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
+	uint32_t feature_flags; /* cache */
+
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 131bd3f..6c6ab2b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -820,6 +820,11 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
  */
 #define DM_THIN_MAX_METADATA_SIZE   (UINT64_C(255) * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024)
 
+/* Right now, cache parameters are the same as thin */
+#define DM_CACHE_MIN_DATA_BLOCK_SIZE DM_THIN_MIN_DATA_BLOCK_SIZE
+#define DM_CACHE_MAX_DATA_BLOCK_SIZE DM_THIN_MAX_DATA_BLOCK_SIZE
+#define DM_CACHE_MAX_METADATA_SIZE DM_THIN_MAX_METADATA_SIZE
+
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
 				      uint64_t transaction_id,
diff --git a/tools/args.h b/tools/args.h
index 1207189..5f26511 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -62,6 +62,7 @@ arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(cache_ARG, '\0', "cache", NULL, 0)
+arg(cachemode_ARG, '\0', "cachemode", string_arg, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index b4ae6de..dce5929 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -230,6 +230,7 @@ xx(lvcreate,
    "\t[-a|--activate [a|e|l]{y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[--cachemode CacheMode]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
@@ -296,9 +297,9 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
-   ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   mirrorlog_ARG, mirrors_ARG, monitor_ARG, minrecoveryrate_ARG,
+   cachemode_ARG, chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
+   extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
+   minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG, minrecoveryrate_ARG,
    maxrecoveryrate_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
    permission_ARG, persistent_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, readahead_ARG,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c8206ca..3210869 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -334,19 +334,72 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_pool) {
-		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
-					lp->extents, vg->extent_size,
-					&lp->thin_chunk_size_calc_policy,
-					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadatasize, &lp->zero))
+		/* FIXME: make 'update_pool_params' work for cache also */
+		/*
+		 * FIXME: better to use persistent-data package program to
+		 *        calculate hte necessary size.
+		 */
+		if (seg_is_cache_pool(lp)) {
+			uint64_t min_meta_size;
+
+			if ((lp->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
+			    (lp->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)) {
+				log_error("Chunk size must be in the range %s to %s.",
+					  display_size(vg->cmd, DM_CACHE_MIN_DATA_BLOCK_SIZE),
+					  display_size(vg->cmd, DM_CACHE_MAX_DATA_BLOCK_SIZE));
+				return 0;
+			}
+
+			if (lp->chunk_size & (DM_CACHE_MIN_DATA_BLOCK_SIZE - 1))
+			{
+				log_error("Chunk size must be a multiple of %u sectors.",
+					  DM_CACHE_MIN_DATA_BLOCK_SIZE);
+				return 0;
+			}
+
+			/*
+			 * Default meta size is:
+			 * (4MiB + (16 Bytes for each chunk-sized block))
+			 * ... plus a good amount of padding (2x) to cover any
+			 * policy hint data that may be added in the future.
+			 */
+			min_meta_size = 16 * (lp->extents * vg->extent_size);
+			min_meta_size /= lp->chunk_size; /* # of Bytes we need */
+			min_meta_size *= 2;              /* plus some padding */
+			min_meta_size /= 512;            /* in sectors */
+			min_meta_size += 4*1024*2;       /* plus 4MiB */
+
+			if (!lp->poolmetadatasize)
+				lp->poolmetadatasize = min_meta_size;
+
+			if (lp->poolmetadatasize < min_meta_size) {
+				lp->poolmetadatasize = min_meta_size;
+				log_print("Increasing metadata device size to %"
+					  PRIu64 " sectors",
+					  lp->poolmetadatasize);
+			}
+			if (lp->poolmetadatasize > DM_CACHE_MAX_METADATA_SIZE) {
+				lp->poolmetadatasize =
+					DM_CACHE_MAX_METADATA_SIZE;
+				log_print("Reducing metadata device size to %"
+					  PRIu64 " sectors",
+					  lp->poolmetadatasize);
+			}
+		} else if (!update_pool_params(vg, lp->target_attr,
+					       lp->passed_args,
+					       lp->extents, vg->extent_size,
+					       &lp->thin_chunk_size_calc_policy,
+					       &lp->chunk_size, &lp->discards,
+					       &lp->poolmetadatasize, &lp->zero))
 			return_0;
 
 		if (!(lp->poolmetadataextents =
-		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
+		      extents_from_size(vg->cmd, lp->poolmetadatasize,
+					vg->extent_size)))
 			return_0;
 		if (lcp->percent == PERCENT_FREE) {
 			if (lp->extents <= (2 * lp->poolmetadataextents)) {
-				log_error("Not enough space for thin pool creation.");
+				log_error("Not enough space for pool creation.");
 				return 0;
 			}
 			/* FIXME: persistent hidden space in VG wanted */
@@ -600,7 +653,39 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd,
+static int _read_cache_pool_params(struct lvcreate_params *lp,
+				  struct cmd_context *cmd)
+{
+	const char *str_arg;
+
+	if (!segtype_is_cache_pool(lp->segtype))
+		return 1;
+
+	if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Negative chunk size is invalid.");
+		return 0;
+	}
+
+	lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
+					DEFAULT_CACHE_POOL_CHUNK_SIZE * 2);
+
+	str_arg = arg_str_value(cmd, cachemode_ARG, NULL);
+	if (str_arg) {
+		if (!strcmp(str_arg, "writeback"))
+			lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+		else if (!strcmp(str_arg, "writethrough"))
+			lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+		else {
+			log_error("Unknown cachemode argument");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _read_activation_params(struct lvcreate_params *lp,
+				   struct cmd_context *cmd,
 				   struct volume_group *vg)
 {
 	unsigned pagesize;
@@ -774,6 +859,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
 
+	if (seg_is_cache_pool(lp))
+		lp->create_pool = 1;
+
 	if (seg_is_thin_pool(lp)) {
 		if (lp->snapshot) {
 			log_error("Snapshots are incompatible with thin_pool segment_type.");
@@ -901,7 +989,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
-	    !_read_raid_params(lp, cmd))
+	    !_read_raid_params(lp, cmd) ||
+	    !_read_cache_pool_params(lp, cmd))
 		return_0;
 
 	if (lp->snapshot && (lp->extents || lcp->size)) {
-- 
1.7.7.6


