From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:32 +0000 (GMT)
Subject: main - thin: improve 16g support for thin pool metadata
Message-ID: <20210201114732.B25483836C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4212be2e7e8797bbf8f9a166347659cc39ba075
Commit:        b4212be2e7e8797bbf8f9a166347659cc39ba075
Parent:        b218a7cfe7179ced64047374af51a883c1611c4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 12 17:59:29 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:06:13 2021 +0100

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
 device_mapper/all.h              | 16 +++++--
 device_mapper/libdm-deptree.c    | 39 ++++++++++++-----
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
 17 files changed, 256 insertions(+), 55 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 8f6546165..fc0a16bf1 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -493,6 +493,13 @@ allocation {
 	# This configuration option has an automatic default value.
 	# thin_pool_metadata_require_separate_pvs = 0
 
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
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 1080d25ad..489ca1c69 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -1072,10 +1072,10 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 #define DM_THIN_MIN_DATA_BLOCK_SIZE (UINT32_C(128))
 #define DM_THIN_MAX_DATA_BLOCK_SIZE (UINT32_C(2097152))
 /*
- * Max supported size for thin pool  metadata device (17112760320 bytes)
- * Limitation is hardcoded into the kernel and bigger device size
- * is not accepted.
+ * Max supported size for thin pool metadata device (17045913600 bytes)
  * drivers/md/dm-thin-metadata.h THIN_METADATA_MAX_SECTORS
+ * But here DM_THIN_MAX_METADATA_SIZE got defined incorrectly
+ * Correct size is (UINT64_C(255) * ((1 << 14) - 64) * (4096 / (1 << 9)))
  */
 #define DM_THIN_MAX_METADATA_SIZE   (UINT64_C(255) * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024)
 
@@ -1088,6 +1088,16 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing);
 
+int dm_tree_node_add_thin_pool_target_v1(struct dm_tree_node *node,
+					 uint64_t size,
+					 uint64_t transaction_id,
+					 const char *metadata_uuid,
+					 const char *pool_uuid,
+					 uint32_t data_block_size,
+					 uint64_t low_water_mark,
+					 unsigned skip_block_zeroing,
+					 unsigned crop_metadata);
+
 /* Supported messages for thin provision target */
 typedef enum {
 	DM_THIN_MESSAGE_CREATE_SNAP,		/* device_id, origin_id */
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 6ce956fa2..5b60dc91a 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -3978,6 +3978,24 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint32_t data_block_size,
 				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing)
+{
+	return dm_tree_node_add_thin_pool_target_v1(node, size, transaction_id,
+						    metadata_uuid, pool_uuid,
+						    data_block_size,
+						    low_water_mark,
+						    skip_block_zeroing,
+						    1);
+}
+
+int dm_tree_node_add_thin_pool_target_v1(struct dm_tree_node *node,
+					 uint64_t size,
+					 uint64_t transaction_id,
+					 const char *metadata_uuid,
+					 const char *pool_uuid,
+					 uint32_t data_block_size,
+					 uint64_t low_water_mark,
+					 unsigned skip_block_zeroing,
+					 unsigned crop_metadata)
 {
 	struct load_segment *seg, *mseg;
 	uint64_t devsize = 0;
@@ -4005,17 +4023,18 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
-	/* FIXME: more complex target may need more tweaks */
-	dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
-		devsize += mseg->size;
-		if (devsize > DM_THIN_MAX_METADATA_SIZE) {
-			log_debug_activation("Ignoring %" PRIu64 " of device.",
-					     devsize - DM_THIN_MAX_METADATA_SIZE);
-			mseg->size -= (devsize - DM_THIN_MAX_METADATA_SIZE);
-			devsize = DM_THIN_MAX_METADATA_SIZE;
-			/* FIXME: drop remaining segs */
+	if (crop_metadata)
+		/* FIXME: more complex target may need more tweaks */
+		dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
+			devsize += mseg->size;
+			if (devsize > DM_THIN_MAX_METADATA_SIZE) {
+				log_debug_activation("Ignoring %" PRIu64 " of device.",
+						     devsize - DM_THIN_MAX_METADATA_SIZE);
+				mseg->size -= (devsize - DM_THIN_MAX_METADATA_SIZE);
+				devsize = DM_THIN_MAX_METADATA_SIZE;
+				/* FIXME: drop remaining segs */
+			}
 		}
-	}
 
 	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, pool_uuid))) {
 		log_error("Missing pool uuid %s.", pool_uuid);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8d27bd363..9a2548213 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -261,7 +261,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	int dmtask;
 	int with_flush; /* TODO: arg for _info_run */
 	void *target = NULL;
-	uint64_t target_start, target_length, start, length;
+	uint64_t target_start, target_length, start, length, length_crop = 0;
 	char *target_name, *target_params;
 	const char *devname;
 
@@ -297,7 +297,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		/* Uses max DM_THIN_MAX_METADATA_SIZE sectors for metadata device */
 		if (lv_is_thin_pool_metadata(seg_status->seg->lv) &&
 		    (length > DM_THIN_MAX_METADATA_SIZE))
-			length = DM_THIN_MAX_METADATA_SIZE;
+			length_crop = DM_THIN_MAX_METADATA_SIZE;
 
 		/* Uses virtual size with headers for VDO pool device */
 		if (lv_is_vdo_pool(seg_status->seg->lv))
@@ -310,7 +310,9 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
 
-			if ((start == target_start) && (length == target_length))
+			if ((start == target_start) &&
+			    ((length == target_length) ||
+			     (length_crop && (length_crop == target_length))))
 				break; /* Keep target_params when matching segment is found */
 
 			target_params = NULL; /* Marking this target_params unusable */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 5fc931de6..d61b707e9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -628,6 +628,11 @@ cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CF
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metadata and data will always use different PVs.\n")
 
+cfg(allocation_thin_pool_crop_metadata_CFG, "thin_pool_crop_metadata", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_CROP_METADATA, vsn(2, 3, 12), NULL, 0, NULL,
+	"Older version of lvm2 cropped pool's metadata size to 15.81 GiB.\n"
+	"This is slightly less then the actual maximum 15.88 GiB.\n"
+	"For compatibility with older version and use of cropped size set to 1.\n")
+
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
 	"Zeroing with a larger thin pool chunk size reduces performance.\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 708a57554..bcc20cc97 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -118,6 +118,8 @@
 #define DEFAULT_THIN_REPAIR_OPTION1 ""
 #define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_THIN_REPAIR_OPTION1
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
+#define DEFAULT_THIN_POOL_CROP_METADATA 0
+#define DEFAULT_THIN_POOL_MAX_METADATA_SIZE_V1_KB (UINT64_C(255) * ((1 << 14) - 64) * 4)  /* KB */ /* 0x3f8040 blocks */
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (DM_THIN_MAX_METADATA_SIZE / 2)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024) /* KB */
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index bc93a5dcf..4cee14aa7 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -72,6 +72,7 @@ static const struct flag _lv_flags[] = {
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
+	{LV_CROP_METADATA, "CROP_METADATA", SEGTYPE_FLAG},
 	{LV_CACHE_VOL, "CACHE_VOL", COMPATIBLE_FLAG},
 	{LV_CACHE_USES_CACHEVOL, "CACHE_USES_CACHEVOL", SEGTYPE_FLAG},
 	{LV_NOSCAN, NULL, 0},
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6c7126378..093cea464 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5416,6 +5416,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	uint32_t existing_extents;
 	uint32_t seg_size = 0;
 	uint32_t new_extents;
+	uint64_t max_metadata_size;
+	thin_crop_metadata_t crop;
 	int reducing = 0;
 
 	seg_last = last_seg(lv);
@@ -5576,6 +5578,33 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
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
@@ -8396,6 +8425,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero_new_blocks;
 		first_seg(lv)->discards = lp->discards;
+		if ((first_seg(lv)->crop_metadata = lp->crop_metadata) == THIN_CROP_METADATA_NO)
+			lv->status |= LV_CROP_METADATA;
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->thin_chunk_size_calc_policy)) {
 			stack;
 			goto revert_new_lv;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 0aa2293eb..eff59ae4b 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -495,6 +495,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("sets discards");
 		if (!dm_list_empty(&seg->thin_messages))
 			seg_error("sets thin_messages list");
+		if (seg->lv->status & LV_CROP_METADATA)
+			seg_error("sets CROP_METADATA flag");
 	}
 
 	if (seg_is_thin_volume(seg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bf58b9fb2..b15e3dea4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -144,6 +144,7 @@
 
 #define LV_REMOVE_AFTER_RESHAPE	UINT64_C(0x0400000000000000)	/* LV needs to be removed after a shrinking reshape */
 #define LV_METADATA_FORMAT	UINT64_C(0x0800000000000000)    /* LV has segments with metadata format */
+#define LV_CROP_METADATA	UINT64_C(0x0000000000000400)	/* LV - also VG CLUSTERED */
 
 #define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
 								   used as SEGTYPE_FLAG to prevent activation on old runtime */
@@ -326,6 +327,12 @@ typedef enum {
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
@@ -503,6 +510,7 @@ struct lv_segment {
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	thin_zero_t zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
+	thin_crop_metadata_t crop_metadata;	/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *external_lv;	/* For thin */
 	struct logical_volume *pool_lv;		/* For thin, cache */
@@ -886,6 +894,8 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			    unsigned attr,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
+			    struct logical_volume *metadata_lv,
+			    unsigned *crop_metadata,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
 
@@ -1012,6 +1022,7 @@ struct lvcreate_params {
 
 	uint64_t permission; /* all */
 	unsigned error_when_full; /* when segment supports it */
+	thin_crop_metadata_t crop_metadata;
 	uint32_t read_ahead; /* all */
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 2c224505a..0f230e441 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -512,8 +512,21 @@ int pool_below_threshold(const struct lv_segment *pool_seg);
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
index a9dc6116d..b67882ef2 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -742,6 +742,52 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
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
index 4591dd797..451c38260 100644
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
index ba0da712d..51bc269ae 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -86,6 +86,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
 	const char *discards_str = NULL;
 	uint32_t zero = 0;
+	uint32_t crop = 0;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -131,6 +132,13 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 
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
@@ -177,6 +185,9 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 		return 0;
 	}
 
+	if (seg->crop_metadata != THIN_CROP_METADATA_UNSELECTED)
+		outf(f, "crop_metadata = %u", (seg->crop_metadata == THIN_CROP_METADATA_YES) ? 1 : 0);
+
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		/* Extra validation */
 		switch (tmsg->type) {
@@ -307,11 +318,12 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
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
index e6f1d6342..3ce34a5ee 100644
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
index 7b74afbe2..ce902791c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3032,6 +3032,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
 	int pool_metadata_spare;
+	thin_crop_metadata_t crop_metadata;
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
 	int r = 0;
@@ -3196,6 +3197,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					     pool_segtype, target_attr,
 					     lv->le_count,
 					     &meta_extents,
+					     metadata_lv,
+					     &crop_metadata,
 					     &chunk_calc,
 					     &chunk_size,
 					     &discards, &zero_new_blocks))
@@ -3401,6 +3404,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			goto_bad;
 	} else {
 		seg->transaction_id = 0;
+		seg->crop_metadata = crop_metadata;
 		seg->chunk_size = chunk_size;
 		seg->discards = discards;
 		seg->zero_new_blocks = zero_new_blocks;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e384291ae..1ee9e14c9 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -391,6 +391,8 @@ static int _update_extents_params(struct volume_group *vg,
 						     lp->segtype, lp->target_attr,
 						     lp->extents,
 						     &lp->pool_metadata_extents,
+						     NULL,
+						     &lp->crop_metadata,
 						     &lp->thin_chunk_size_calc_policy,
 						     &lp->chunk_size,
 						     &lp->discards,


