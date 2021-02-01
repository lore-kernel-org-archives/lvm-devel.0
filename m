From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:20 +0000 (GMT)
Subject: stable-2.02 - thin: improve 16g support for thin pool metadata
Message-ID: <20210201133820.80D7C3834437@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=586bac0b10d3c1757708129433e8401a4797a7ee
Commit:        586bac0b10d3c1757708129433e8401a4797a7ee
Parent:        5196392bcd1522580f19992397b603cbac077ffb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 14:13:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

thin: improve 16g support for thin pool metadata

Initial support for thin-pool used slightly smaller max size 15.81GiB
for thin-pool metadata. However the real limit later settled at 15.88GiB
(difference is ~64MiB - 16448 4K blocks).

lvm2 could not simply increase the size as it has been using hard cropping
of the loaded metadata device to avoid warnings printing warning of kernel
when the size was bigger (i.e. due to bigger extent_size).

This patch adds the new lvm.conf configurable setting:
allocation/thin_pool_crop_metadata
which defaults to 0 -> no crop of metadata beyond 15.81GiB.
Only user with these sizes of metadata will be affected.

Without cropping lvm2 now limits metadata allocation size to 15.88GiB.
Any space beyond is currently not used by thin-pool target.
Even if i.e. bigger LV is used for metadata via lvconvert,
or allocated bigger because of to large extent size.

With cropping enabled (=1) lvm2 preserves the old limitation
15.81GiB and should allow to work in the evironement with
older lvm2 tools (i.e. older distribution).

Thin-pool metadata with size bigger then 15.81G is now using CROP_METADATA
flag within lvm2 metadata, so older lvm2 recognizes an
incompatible thin-pool and cannot activate such pool!

Users should use uncropped version as it is not suffering
from various issues between thin_repair results and allocated
metadata LV as thin_repair limit is 15.88GiB
Users should use cropping only when really needed!

Patch also better handles resize of thin-pool metadata and prevents resize
beoyond usable size 15.88GiB. Resize beyond 15.81GiB automatically
switches pool to no-crop version. Even with existing bigger thin-pool
metadata command 'lvextend -l+1 vg/pool_tmeta' does the change.

Patch gives better controls 'coverted' metadata LV and
reports less confusing message during conversion.

Patch set also moves the code for updating min/max into pool_manip.c
for better sharing with cache_pool code.
---
 conf/example.conf.in             |  7 +++
 lib/activate/dev_manager.c       |  8 ++--
 lib/config/config_settings.h     |  5 +++
 lib/config/defaults.h            |  2 +
 lib/format_text/flags.c          |  1 +
 lib/metadata/lv_manip.c          | 31 ++++++++++++++
 lib/metadata/merge.c             |  2 +
 lib/metadata/metadata-exported.h | 11 +++++
 lib/metadata/metadata.h          | 13 ++++++
 lib/metadata/pool_manip.c        | 46 ++++++++++++++++++++
 lib/metadata/thin_manip.c        | 92 ++++++++++++++++++++++++++--------------
 lib/thin/thin.c                  | 22 +++++++---
 man/lvmthin.7_main               | 10 ++++-
 tools/lvconvert.c                |  4 ++
 tools/lvcreate.c                 |  2 +
 15 files changed, 214 insertions(+), 42 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index a57c66e40..ee2b34c03 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -470,6 +470,13 @@ allocation {
 	# Thin pool metadata and data will always use different PVs.
 	thin_pool_metadata_require_separate_pvs = 0
 
+	# Configuration option allocation/thin_pool_crop_metadata.
+	# Older version of lvm2 cropped pool's metadata size to 15.81 GiB.
+	# This is slightly less then the actual maximum 15.88 GiB.
+	# For compatibility with older version and use of cropped size set to 1.
+	# This configuration option has an automatic default value.
+	# thin_pool_crop_metadata = 0
+
 	# Configuration option allocation/thin_pool_zero.
 	# Thin pool data chunks are zeroed before they are first used.
 	# Zeroing with a larger thin pool chunk size reduces performance.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7d9cb917e..370f90edd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -249,7 +249,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	int dmtask;
 	int with_flush; /* TODO: arg for _info_run */
 	void *target = NULL;
-	uint64_t target_start, target_length, start, length;
+	uint64_t target_start, target_length, start, length, length_crop = 0;
 	char *target_name, *target_params;
 	const char *devname;
 
@@ -285,13 +285,15 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		/* Uses max DM_THIN_MAX_METADATA_SIZE sectors for metadata device */
 		if (lv_is_thin_pool_metadata(seg_status->seg->lv) &&
 		    (length > DM_THIN_MAX_METADATA_SIZE))
-			length = DM_THIN_MAX_METADATA_SIZE;
+			length_crop = DM_THIN_MAX_METADATA_SIZE;
 
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
 
-			if ((start == target_start) && (length == target_length))
+			if ((start == target_start) &&
+			    ((length == target_length) ||
+			     (length_crop && (length_crop == target_length))))
 				break; /* Keep target_params when matching segment is found */
 
 			target_params = NULL; /* Marking this target_params unusable */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d23ae49ff..9795bde8e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -596,6 +596,11 @@ cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CF
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metadata and data will always use different PVs.\n")
 
+cfg(allocation_thin_pool_crop_metadata_CFG, "thin_pool_crop_metadata", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_CROP_METADATA, vsn(2, 2, 188), NULL, 0, NULL,
+	"Older version of lvm2 cropped pool's metadata size to 15.81 GiB.\n"
+	"This is slightly less then the actual maximum 15.88 GiB.\n"
+	"For compatibility with older version and use of cropped size set to 1.\n")
+
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
 	"Zeroing with a larger thin pool chunk size reduces performance.\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2ffad243e..d6735241f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -105,6 +105,8 @@
 #define DEFAULT_THIN_REPAIR_OPTION1 ""
 #define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_THIN_REPAIR_OPTION1
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
+#define DEFAULT_THIN_POOL_CROP_METADATA 0
+#define DEFAULT_THIN_POOL_MAX_METADATA_SIZE_V1_KB (UINT64_C(255) * ((1 << 14) - 64) * 4)  /* KB */ /* 0x3f8040 blocks */
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (DM_THIN_MAX_METADATA_SIZE / 2)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024) /* KB */
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 7e793b3d0..8f5e2b2e6 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -72,6 +72,7 @@ static const struct flag _lv_flags[] = {
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
+	{LV_CROP_METADATA, "CROP_METADATA", SEGTYPE_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 346ec9f77..8bfa33a0a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5061,6 +5061,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	uint32_t existing_extents;
 	uint32_t seg_size = 0;
 	uint32_t new_extents;
+	uint64_t max_metadata_size;
+	thin_crop_metadata_t crop;
 	int reducing = 0;
 
 	seg_last = last_seg(lv);
@@ -5200,6 +5202,33 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 					return 1;
 				}
 			}
+		} else if (lv_is_thin_pool_metadata(lv)) {
+			if (!(seg = get_only_segment_using_this_lv(lv)))
+				return_0;
+
+			max_metadata_size = get_thin_pool_max_metadata_size(cmd, vg->profile, &crop);
+
+			if (((uint64_t)lp->extents * vg->extent_size) > max_metadata_size) {
+				lp->extents = (max_metadata_size + vg->extent_size - 1) / vg->extent_size;
+				log_print_unless_silent("Reached maximum pool metadata size %s (%" PRIu32 " extents).",
+							display_size(vg->cmd, max_metadata_size), lp->extents);
+			}
+
+			if (existing_logical_extents >= lp->extents)
+				lp->extents = existing_logical_extents;
+
+			crop = get_thin_pool_crop_metadata(cmd, crop, (uint64_t)lp->extents * vg->extent_size);
+
+			if (seg->crop_metadata != crop) {
+				seg->crop_metadata = crop;
+				seg->lv->status |= LV_CROP_METADATA;
+				/* Crop change require reload even if there no size change */
+				lp->size_changed = 1;
+				log_print_unless_silent("Thin pool will use metadata without cropping.");
+			}
+
+			if (!(seg_size = lp->extents - existing_logical_extents))
+				return 1;  /* No change in metadata size */
 		}
 	} else {  /* If reducing, find stripes, stripesize & size of last segment */
 		if (lp->stripes || lp->stripe_size || lp->mirrors)
@@ -7941,6 +7970,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero_new_blocks;
 		first_seg(lv)->discards = lp->discards;
+		if ((first_seg(lv)->crop_metadata = lp->crop_metadata) == THIN_CROP_METADATA_NO)
+			lv->status |= LV_CROP_METADATA;
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->thin_chunk_size_calc_policy)) {
 			stack;
 			goto revert_new_lv;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 054f1855f..69d755aeb 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -478,6 +478,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("sets discards");
 		if (!dm_list_empty(&seg->thin_messages))
 			seg_error("sets thin_messages list");
+		if (seg->lv->status & LV_CROP_METADATA)
+			seg_error("sets CROP_METADATA flag");
 	}
 
 	if (seg_is_thin_volume(seg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 30ab47576..629b3a457 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -142,6 +142,7 @@
 
 #define LV_REMOVE_AFTER_RESHAPE	UINT64_C(0x0400000000000000)	/* LV needs to be removed after a shrinking reshape */
 #define LV_METADATA_FORMAT	UINT64_C(0x0800000000000000)    /* LV has segments with metadata format */
+#define LV_CROP_METADATA	UINT64_C(0x0000000000000400)	/* LV - also VG CLUSTERED */
 
 #define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
 								   used as SEGTYPE_FLAG to prevent activation on old runtime */
@@ -299,6 +300,12 @@ typedef enum {
 	THIN_DISCARDS_PASSDOWN,
 } thin_discards_t;
 
+typedef enum {
+	THIN_CROP_METADATA_UNSELECTED = 0,  /* 'auto' selects */
+	THIN_CROP_METADATA_NO,
+	THIN_CROP_METADATA_YES,
+} thin_crop_metadata_t;
+
 typedef enum {
 	CACHE_MODE_UNSELECTED = 0,
 	CACHE_MODE_WRITETHROUGH,
@@ -476,6 +483,7 @@ struct lv_segment {
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	thin_zero_t zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
+	thin_crop_metadata_t crop_metadata;	/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *external_lv;	/* For thin */
 	struct logical_volume *pool_lv;		/* For thin, cache */
@@ -861,6 +869,8 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			    unsigned attr,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
+			    struct logical_volume *metadata_lv,
+			    unsigned *crop_metadata,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
 
@@ -986,6 +996,7 @@ struct lvcreate_params {
 
 	uint64_t permission; /* all */
 	unsigned error_when_full; /* when segment supports it */
+	thin_crop_metadata_t crop_metadata;
 	uint32_t read_ahead; /* all */
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 96bbb5690..9aabafbc1 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -500,8 +500,21 @@ int pool_below_threshold(const struct lv_segment *pool_seg);
 int pool_check_overprovisioning(const struct logical_volume *lv);
 int create_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
+uint64_t get_thin_pool_max_metadata_size(struct cmd_context *cmd, struct profile *profile,
+					 thin_crop_metadata_t *crop);
+thin_crop_metadata_t get_thin_pool_crop_metadata(struct cmd_context *cmd,
+						  thin_crop_metadata_t crop,
+						  uint64_t metadata_size);
 uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size);
 
+int update_pool_metadata_min_max(struct cmd_context *cmd,
+				 uint32_t extent_size,
+				 uint64_t min_metadata_size,		/* required min */
+				 uint64_t max_metadata_size,		/* writable max */
+				 uint64_t *metadata_size,		/* current calculated */
+				 struct logical_volume *metadata_lv,	/* name of converted LV or NULL */
+				 uint32_t *metadata_extents);		/* resulting extent count */
+
 /*
  * Begin skeleton for external LVM library
  */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index a93e230be..ead302155 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -728,6 +728,52 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 	return 1;
 }
 
+int update_pool_metadata_min_max(struct cmd_context *cmd,
+				 uint32_t extent_size,
+				 uint64_t min_metadata_size,		/* required min */
+				 uint64_t max_metadata_size,		/* writable max */
+				 uint64_t *metadata_size,		/* current calculated */
+				 struct logical_volume *metadata_lv,	/* name of converted LV or NULL */
+				 uint32_t *metadata_extents)		/* resulting extent count */
+{
+	max_metadata_size = dm_round_up(max_metadata_size, extent_size);
+	min_metadata_size = dm_round_up(min_metadata_size, extent_size);
+
+	if (*metadata_size > max_metadata_size) {
+		if (metadata_lv) {
+			log_print_unless_silent("Size %s of pool metadata volume %s is bigger then maximum usable size %s.",
+						display_size(cmd, *metadata_size),
+						display_lvname(metadata_lv),
+						display_size(cmd, max_metadata_size));
+		} else {
+			if (*metadata_extents)
+				log_print_unless_silent("Reducing pool metadata size %s to maximum usable size %s.",
+							display_size(cmd, *metadata_size),
+							display_size(cmd, max_metadata_size));
+			*metadata_size = max_metadata_size;
+		}
+	} else if (*metadata_size < min_metadata_size) {
+		if (metadata_lv) {
+			log_error("Can't use volume %s with size %s as pool metadata. Minimal required size is %s.",
+				  display_lvname(metadata_lv),
+				  display_size(cmd, *metadata_size),
+				  display_size(cmd, min_metadata_size));
+			return 0;
+		} else {
+			if (*metadata_extents)
+				log_print_unless_silent("Extending pool metadata size %s to required minimal size %s.",
+							display_size(cmd, *metadata_size),
+							display_size(cmd, min_metadata_size));
+			*metadata_size = min_metadata_size;
+		}
+	}
+
+	if (!(*metadata_extents = extents_from_size(cmd, *metadata_size, extent_size)))
+		return_0;
+
+	return 1;
+}
+
 int vg_set_pool_metadata_spare(struct logical_volume *lv)
 {
 	char new_name[NAME_LEN];
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 695aff101..fc5b0e6fb 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -610,9 +610,9 @@ static uint64_t _estimate_metadata_size(uint32_t data_extents, uint32_t extent_s
 }
 
 /* Estimate maximal supportable thin pool data size for given chunk_size */
-static uint64_t _estimate_max_data_size(uint32_t chunk_size)
+static uint64_t _estimate_max_data_size(uint64_t max_metadata_size, uint32_t chunk_size)
 {
-	return  chunk_size * (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2) * SECTOR_SIZE / UINT64_C(64);
+	return  max_metadata_size * chunk_size * SECTOR_SIZE / UINT64_C(64);
 }
 
 /* Estimate thin pool chunk size from data and metadata size (in sector units) */
@@ -662,6 +662,38 @@ int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct
 	return 1;
 }
 
+/* Return max supported metadata size with selected cropping */
+uint64_t get_thin_pool_max_metadata_size(struct cmd_context *cmd, struct profile *profile,
+					 thin_crop_metadata_t *crop)
+{
+	*crop = find_config_tree_bool(cmd, allocation_thin_pool_crop_metadata_CFG, profile) ?
+		THIN_CROP_METADATA_YES : THIN_CROP_METADATA_NO;
+
+	return (*crop == THIN_CROP_METADATA_NO) ?
+		(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE_V1_KB) : (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE);
+}
+
+/*
+ * With existing crop method, check if the metadata_size would need cropping.
+ * If not, set UNSELECTED, otherwise print some verbose info about selected cropping
+ */
+thin_crop_metadata_t get_thin_pool_crop_metadata(struct cmd_context *cmd,
+						  thin_crop_metadata_t crop,
+						  uint64_t metadata_size)
+{
+	const uint64_t crop_size = (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE);
+
+	if (metadata_size > crop_size) {
+		if (crop == THIN_CROP_METADATA_NO)
+			log_verbose("Using metadata size without cropping.");
+		else
+			log_verbose("Cropping metadata size to %s.", display_size(cmd, crop_size));
+	} else
+		crop = THIN_CROP_METADATA_UNSELECTED;
+
+	return crop;
+}
+
 int update_thin_pool_params(struct cmd_context *cmd,
 			    struct profile *profile,
 			    uint32_t extent_size,
@@ -669,10 +701,13 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			    unsigned attr,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
+			    struct logical_volume *metadata_lv,
+			    thin_crop_metadata_t *crop_metadata,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks)
 {
-	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
+	uint64_t pool_metadata_size;
+	uint64_t max_metadata_size;
 	uint32_t estimate_chunk_size;
 	uint64_t max_pool_data_size;
 	const char *str;
@@ -702,7 +737,9 @@ int update_thin_pool_params(struct cmd_context *cmd,
 		*zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile)
 			? THIN_ZERO_YES : THIN_ZERO_NO;
 
-	if (!pool_metadata_size) {
+	max_metadata_size = get_thin_pool_max_metadata_size(cmd, profile, crop_metadata);
+
+	if (!*pool_metadata_extents) {
 		if (!*chunk_size) {
 			if (!get_default_allocation_thin_pool_chunk_size(cmd, profile,
 									 chunk_size,
@@ -723,20 +760,20 @@ int update_thin_pool_params(struct cmd_context *cmd,
 		} else {
 			pool_metadata_size = _estimate_metadata_size(pool_data_extents, extent_size, *chunk_size);
 
-			if (pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
+			if (pool_metadata_size > max_metadata_size) {
 				/* Suggest bigger chunk size */
 				estimate_chunk_size =
 					_estimate_chunk_size(pool_data_extents, extent_size,
-							     (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2), attr);
+							     max_metadata_size, attr);
 				log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
 					 display_size(cmd, estimate_chunk_size));
 			}
 		}
 
 		/* Round up to extent size silently */
-		if (pool_metadata_size % extent_size)
-			pool_metadata_size += extent_size - pool_metadata_size % extent_size;
+		pool_metadata_size = dm_round_up(pool_metadata_size, extent_size);
 	} else {
+		pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 		estimate_chunk_size = _estimate_chunk_size(pool_data_extents, extent_size,
 							   pool_metadata_size, attr);
 
@@ -751,7 +788,19 @@ int update_thin_pool_params(struct cmd_context *cmd,
 		}
 	}
 
-	max_pool_data_size = _estimate_max_data_size(*chunk_size);
+	/* Use not rounded max for data size */
+	max_pool_data_size = _estimate_max_data_size(max_metadata_size, *chunk_size);
+
+	if (!update_pool_metadata_min_max(cmd, extent_size,
+					  2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE,
+					  max_metadata_size,
+					  &pool_metadata_size,
+					  metadata_lv,
+					  pool_metadata_extents))
+		return_0;
+
+	*crop_metadata = get_thin_pool_crop_metadata(cmd, *crop_metadata, pool_metadata_size);
+
 	if ((max_pool_data_size / extent_size) < pool_data_extents) {
 		log_error("Selected chunk size %s cannot address more then %s of thin pool data space.",
 			  display_size(cmd, *chunk_size), display_size(cmd, max_pool_data_size));
@@ -764,22 +813,6 @@ int update_thin_pool_params(struct cmd_context *cmd,
 	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
 		return_0;
 
-	if (pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-		if (*pool_metadata_extents)
-			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(cmd, pool_metadata_size));
-	} else if (pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-		pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-		if (*pool_metadata_extents)
-			log_warn("WARNING: Minimum supported pool metadata size is %s.",
-				 display_size(cmd, pool_metadata_size));
-	}
-
-	if (!(*pool_metadata_extents =
-	      extents_from_size(cmd, pool_metadata_size, extent_size)))
-		return_0;
-
 	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * extent_size) {
 		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
 			  segtype->name, display_size(cmd, *chunk_size));
@@ -958,12 +991,5 @@ int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size)
 
 uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size)
 {
-	uint64_t sz = _estimate_metadata_size(data_extents, extent_size, chunk_size);
-
-	if (sz > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE))
-		sz = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-	else if (sz < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE))
-		sz = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-
-	return sz;
+	return _estimate_metadata_size(data_extents, extent_size, chunk_size);
 }
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index b7c80bcd2..8ab60ce1e 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -85,6 +85,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
 	const char *discards_str = NULL;
 	uint32_t zero = 0;
+	uint32_t crop = 0;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -130,6 +131,13 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 
 	seg->zero_new_blocks = (zero) ? THIN_ZERO_YES : THIN_ZERO_NO;
 
+	if (dm_config_has_node(sn, "crop_metadata")) {
+		if (!dm_config_get_uint32(sn, "crop_metadata", &crop))
+			return SEG_LOG_ERROR("Could not read crop_metadata for");
+		seg->crop_metadata = (crop) ? THIN_CROP_METADATA_YES : THIN_CROP_METADATA_NO;
+		seg->lv->status |= LV_CROP_METADATA;
+	}
+
 	/* Read messages */
 	for (; sn; sn = sn->sib)
 		if (!(sn->v) && !_thin_pool_add_message(seg, sn->key, sn->child))
@@ -176,6 +184,9 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 		return 0;
 	}
 
+	if (seg->crop_metadata != THIN_CROP_METADATA_UNSELECTED)
+		outf(f, "crop_metadata = %u", (seg->crop_metadata == THIN_CROP_METADATA_YES) ? 1 : 0);
+
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		/* Extra validation */
 		switch (tmsg->type) {
@@ -306,11 +317,12 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	else
 		low_water_mark = 0;
 
-	if (!dm_tree_node_add_thin_pool_target(node, len,
-					       seg->transaction_id,
-					       metadata_dlid, pool_dlid,
-					       seg->chunk_size, low_water_mark,
-					       (seg->zero_new_blocks == THIN_ZERO_YES) ? 0 : 1))
+	if (!dm_tree_node_add_thin_pool_target_v1(node, len,
+						  seg->transaction_id,
+						  metadata_dlid, pool_dlid,
+						  seg->chunk_size, low_water_mark,
+						  (seg->zero_new_blocks == THIN_ZERO_YES) ? 0 : 1,
+						  (seg->crop_metadata == THIN_CROP_METADATA_YES) ? 1 : 0))
 		return_0;
 
 	if (attr & THIN_FEATURE_DISCARDS) {
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 39dcdfedc..ebb0b610d 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -1104,7 +1104,7 @@ The default value is shown by:
 The amount of thin metadata depends on how many blocks are shared between
 thin LVs (i.e. through snapshots).  A thin pool with many snapshots may
 need a larger metadata LV.  Thin pool metadata LV sizes can be from 2MiB
-to 16GiB.
+to approximately 16GiB.
 
 When using lvcreate to create what will become a thin metadata LV, the
 size is specified with the -L|--size option.
@@ -1119,6 +1119,14 @@ needed, so it is recommended to start with a size of 1GiB which should be
 enough for all practical purposes.  A thin pool metadata LV can later be
 manually or automatically extended if needed.
 
+Configurable setting
+.BR lvm.conf (5)
+.BR allocation / thin_pool_crop_metadata
+gives control over cropping to 15.81GiB to stay backward compatible with older
+versions of lvm2. With enabled cropping there can be observed some problems when
+using volumes above this size with thin tools (i.e. thin_repair).
+Cropping should be enabled only when compatibility is required.
+
 
 .SS Create a thin snapshot of an external, read only LV
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fb33cc4e8..50f438672 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2937,6 +2937,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
 	int pool_metadata_spare;
+	thin_crop_metadata_t crop_metadata;
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
 	int r = 0;
@@ -3100,6 +3101,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					     pool_segtype, target_attr,
 					     lv->le_count,
 					     &meta_extents,
+					     metadata_lv,
+					     &crop_metadata,
 					     &chunk_calc,
 					     &chunk_size,
 					     &discards, &zero_new_blocks))
@@ -3305,6 +3308,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			goto_bad;
 	} else {
 		seg->transaction_id = 0;
+		seg->crop_metadata = crop_metadata;
 		seg->chunk_size = chunk_size;
 		seg->discards = discards;
 		seg->zero_new_blocks = zero_new_blocks;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 4be8e035f..d54f152a3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -390,6 +390,8 @@ static int _update_extents_params(struct volume_group *vg,
 						     lp->segtype, lp->target_attr,
 						     lp->extents,
 						     &lp->pool_metadata_extents,
+						     NULL,
+						     &lp->crop_metadata,
 						     &lp->thin_chunk_size_calc_policy,
 						     &lp->chunk_size,
 						     &lp->discards,


