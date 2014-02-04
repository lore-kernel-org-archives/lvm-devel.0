From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  4 Feb 2014 18:00:29 +0000 (UTC)
Subject: master - cache: Code changes to allow creation of cache pools
Message-ID: <20140204180029.4953961119@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97be8b3482a0c566d5fa529321bd035526974c96
Commit:        97be8b3482a0c566d5fa529321bd035526974c96
Parent:        013cf27bff2d46f273505d6ee437085ad9cab5f2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 4 11:57:08 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 4 11:57:08 2014 -0600

cache: Code changes to allow creation of cache pools

This patch allows the creation and removal of cache pools.  Users are not
yet able to create cache LVs.  They are only able to define the space used
for the cache and its characteristics (chunk_size and cache mode ATM) by
creating the cache pool.
---
 lib/config/defaults.h            |    2 +-
 lib/format_text/flags.c          |    4 ++
 lib/metadata/lv_manip.c          |   73 +++++++++++++++++++++++++-------------
 lib/metadata/merge.c             |   49 ++++++++++++++++++-------
 lib/metadata/metadata-exported.h |    2 +
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++--
 tools/lvcreate.c                 |   42 ++++++++++++++++++++--
 8 files changed, 135 insertions(+), 45 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 437cec7..6820def 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -77,7 +77,7 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
-#define DEFAULT_POOL_METADATA_SPARE 1
+#define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
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
index 6139daa..e85b3ce 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -559,7 +559,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
-	    (seg_lv(seg, s)->status & THIN_POOL_DATA)) {
+	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
+	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
 			return_0; /* FIXME: any upper level reporting */
 		return 1;
@@ -2998,8 +2999,13 @@ int lv_extend(struct logical_volume *lv,
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
@@ -3012,10 +3018,10 @@ int lv_extend(struct logical_volume *lv,
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
@@ -4547,6 +4553,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int format1_reload_required = 0;
 	int visible;
 	struct logical_volume *pool_lv = NULL;
+	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
 
 	vg = lv->vg;
@@ -4591,6 +4598,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
+	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
+		log_error("Can't remove logical volume %s used by a cache_pool.",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
@@ -4819,12 +4832,14 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	if (lv_is_used_thin_pool(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
-
-	if (lv_is_thin_pool(lv) && lv->vg->pool_metadata_spare_lv) {
-		/* When removing last thin pool, remove also spare */
+	if ((lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) &&
+	    lv->vg->pool_metadata_spare_lv) {
+		/* When removing last pool, also remove the spare */
 		is_last_pool = 1;
 		dm_list_iterate_items(lvl, &lv->vg->lvs)
-			if (lv_is_thin_pool(lvl->lv) && lvl->lv != lv) {
+			if ((lv_is_thin_pool(lvl->lv) ||
+			     lv_is_cache_pool(lvl->lv)) &&
+			    lvl->lv != lv) {
 				is_last_pool = 0;
 				break;
 			}
@@ -4837,9 +4852,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 
 	if (lv_is_pool_metadata_spare(lv) &&
 	    (force == PROMPT) &&
-	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
-			   "disables automatic recovery attempts after damage "
-			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n'))
+	    (yes_no_prompt("Removal of pool metadata spare logical volume"
+			   " \"%s\" disables automatic recovery attempts"
+			   " after damage to a thin or cache pool."
+			   " Proceed? [y/n]: ", lv->name) == 'n'))
 		goto no_remove;
 
 	return lv_remove_single(cmd, lv, force, 0);
@@ -5703,7 +5719,7 @@ out:
 static int _should_wipe_lv(struct lvcreate_params *lp, struct logical_volume *lv) {
 	int r = lp->zero | lp->wipe_signatures;
 
-	if (!seg_is_thin(lp))
+	if (!seg_is_thin(lp) && !seg_is_cache_pool(lp))
 		return r;
 
 	if (lv_is_thin_volume(lv))
@@ -5872,10 +5888,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
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
@@ -5907,7 +5925,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!activation() &&
 	    (seg_is_mirrored(lp) ||
 	     seg_is_raid(lp) ||
-	     seg_is_thin_pool(lp))) {
+	     seg_is_thin_pool(lp) ||
+	     seg_is_cache_pool(lp))) {
 		/*
 		 * FIXME: For thin pool add some code to allow delayed
 		 * initialization of empty thin pool volume.
@@ -5916,9 +5935,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
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
 
@@ -6004,12 +6022,17 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
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
@@ -6115,7 +6138,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->temporary)
 		lv->status |= LV_TEMPORARY;
 
-	if (lv_is_thin_pool(lv)) {
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		if (is_change_activating(lp->activate)) {
 			if (vg_is_clustered(lv->vg)) {
 				if (!activate_lv_excl(cmd, lv)) {
@@ -6295,7 +6318,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
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
index b37d91a..1e16c34 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -794,6 +794,8 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
+	uint32_t feature_flags; /* cache */
+
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */
 
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
index 137c0a2..e14ce7a 100644
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
@@ -615,7 +615,39 @@ static int _read_raid_params(struct lvcreate_params *lp,
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
@@ -789,6 +821,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
 
+	if (seg_is_cache_pool(lp))
+		lp->create_pool = 1;
+
 	if (seg_is_thin_pool(lp)) {
 		if (lp->snapshot) {
 			log_error("Snapshots are incompatible with thin_pool segment_type.");
@@ -916,7 +951,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
-	    !_read_raid_params(lp, cmd))
+	    !_read_raid_params(lp, cmd) ||
+	    !_read_cache_pool_params(lp, cmd))
 		return_0;
 
 	if (lp->snapshot && (lp->extents || lcp->size)) {


