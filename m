From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Dec 2018 07:27:24 -0500
Subject: master - lib: move towards v2 version of VDO format
Message-ID: <201812201227.wBKCROjK030652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3320ab8334794684b4d324bb78d0b293a27287a6
Commit:        3320ab8334794684b4d324bb78d0b293a27287a6
Parent:        9785e40b8d52fd87d7c451ed838f450aee41ba8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 20 13:17:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 20 13:26:55 2018 +0100

lib: move towards v2 version of VDO format

Drop very old original format of VDO target and focus on V2 version.
So some variables were renamed or replaced.
There is no compatibility preserved (with assumption so far this is
experimental feature and there is no real user).

Note - version currently VDO calls this version 6.2.
---
 WHATS_NEW                      |    1 +
 device_mapper/all.h            |    1 +
 device_mapper/libdm-deptree.c  |   16 +++++++----
 device_mapper/vdo/target.h     |   15 +++++------
 device_mapper/vdo/vdo_limits.h |    7 +++-
 device_mapper/vdo/vdo_target.c |   20 ++++++++++----
 lib/config/config_settings.h   |   54 +++++++++++++++++++++++-----------------
 lib/config/defaults.h          |    8 +++---
 lib/metadata/vdo_manip.c       |   16 ++++++------
 lib/vdo/vdo.c                  |   44 ++++++++++++++++----------------
 10 files changed, 103 insertions(+), 79 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b7f834..38525e3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Move VDO support towards V2 target (6.2) support.
   Fix missing proper initialization of pv_list struct when adding pv.
   Fix (de)activation of RaidLVs with visible SubLVs
   Prohibit mirrored 'mirror' log via lvcreate and lvconvert
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 8c17c09..9539442 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -976,6 +976,7 @@ int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
 				const char *data_uuid,
+				uint64_t data_size,
 				const struct dm_vdo_target_params *param);
 
 /*
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 7a7239e..91ccdd4 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -214,6 +214,7 @@ struct load_segment {
 	struct dm_tree_node *vdo_data;  /* VDO */
 	struct dm_vdo_target_params vdo_params; /* VDO */
 	const char *vdo_name;           /* VDO - device name is ALSO passed as table arg */
+	uint64_t vdo_data_size;		/* VDO - size of data storage device */
 
 	struct dm_tree_node *writecache_node;		/* writecache */
 	int writecache_pmem;				/* writecache, 1 if pmem, 0 if ssd */
@@ -2745,17 +2746,18 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		return 0;
 	}
 
-	EMIT_PARAMS(pos, "%s %u %s " FMTu64 " " FMTu64 " %u on %s %s "
-		    "ack=%u,bio=%u,bioRotationInterval=%u,cpu=%u,hash=%u,logical=%u,physical=%u",
+	EMIT_PARAMS(pos, "V2 %s " FMTu64 " %u " FMTu64 " %u %s %s %s "
+		    "maxDiscard %u ack %u bio %u bioRotationInterval %u cpu %u hash %u logical %u physical %u",
 		    data_dev,
-		    (seg->vdo_params.emulate_512_sectors == 0) ? 4096 : 512,
-		    seg->vdo_params.use_read_cache ? "enabled" : "disabled",
-		    seg->vdo_params.read_cache_size_mb * UINT64_C(256),		// 1MiB -> 4KiB units
+		    seg->vdo_data_size / 8, // this parameter is in 4K units
+		    seg->vdo_params.minimum_io_size,
 		    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
-		    seg->vdo_params.block_map_period,
+		    seg->vdo_params.block_map_era_length,
+		    seg->vdo_params.use_metadata_hints ? "on" : "off" ,
 		    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_SYNC) ? "sync" :
 			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" : "auto", // policy
 		    seg->vdo_name,
+		    seg->vdo_params.max_discard,
 		    seg->vdo_params.ack_threads,
 		    seg->vdo_params.bio_threads,
 		    seg->vdo_params.bio_rotation,
@@ -4185,6 +4187,7 @@ int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
 				const char *data_uuid,
+				uint64_t data_size,
 				const struct dm_vdo_target_params *vtp)
 {
 	struct load_segment *seg;
@@ -4205,6 +4208,7 @@ int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 
 	seg->vdo_params = *vtp;
 	seg->vdo_name = node->name;
+	seg->vdo_data_size = data_size;
 
 	node->props.send_messages = 2;
 
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index c597491..f83cffd 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -74,16 +74,16 @@ enum dm_vdo_write_policy {
 
 // FIXME: review whether we should use the createParams from the userlib
 struct dm_vdo_target_params {
+	uint32_t minimum_io_size;
 	uint32_t block_map_cache_size_mb;
-	uint32_t block_map_period;
+	uint32_t block_map_era_length;	// format period
 
 	uint32_t check_point_frequency;
-	uint32_t index_memory_size_mb;
+	uint32_t index_memory_size_mb;  // format
 
-	uint32_t read_cache_size_mb;
-
-	uint32_t slab_size_mb;
+	uint32_t slab_size_mb;          // format
 
+	uint32_t max_discard;
 	// threads
 	uint32_t ack_threads;
 	uint32_t bio_threads;
@@ -95,9 +95,8 @@ struct dm_vdo_target_params {
 
 	bool use_compression;
 	bool use_deduplication;
-	bool emulate_512_sectors;
-	bool use_sparse_index;
-	bool use_read_cache;
+	bool use_metadata_hints;
+	bool use_sparse_index;          // format
 
 	// write policy
 	enum dm_vdo_write_policy write_policy;
diff --git a/device_mapper/vdo/vdo_limits.h b/device_mapper/vdo/vdo_limits.h
index 40cf204..e145100 100644
--- a/device_mapper/vdo/vdo_limits.h
+++ b/device_mapper/vdo/vdo_limits.h
@@ -21,8 +21,8 @@
 #define DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB	(16 * 1024 * 1024 - 1)	// 16TiB - 1
 #define DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_PER_LOGICAL_THREAD  (4096 * DM_VDO_BLOCK_SIZE_KB)
 
-#define DM_VDO_BLOCK_MAP_PERIOD_MINIMUM		1
-#define DM_VDO_BLOCK_MAP_PERIOD_MAXIMUM		(16380)
+#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM	(1)
+#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM	(16380)
 
 #define DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB	(256)			// 0.25 GiB
 #define DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB	(1024 * 1024 * 1024)	// 1TiB
@@ -57,4 +57,7 @@
 //#define DM_VDO_PHYSICAL_THREADS_MINIMUM	(0)
 #define DM_VDO_PHYSICAL_THREADS_MAXIMUM		(16)
 
+#define DM_VDO_MAX_DISCARD_MINIMUM		(1)
+#define DM_VDO_MAX_DISCARD_MAXIMUM		(UINT32_MAX / 4096)
+
 #endif // DEVICE_MAPPER_VDO_LIMITS_H
diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index c488023..976d71a 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -23,6 +23,13 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 {
 	bool valid = true;
 
+	if ((vtp->minimum_io_size != 512) &&
+	    (vtp->minimum_io_size != 4096)) {
+		log_error("VDO minimum io size %u is unsupported.",
+			  vtp->minimum_io_size);
+		valid = false;
+	}
+
 	if ((vtp->block_map_cache_size_mb < DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB) ||
 	    (vtp->block_map_cache_size_mb > DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB)) {
 		log_error("VDO block map cache size %u out of range.",
@@ -37,12 +44,6 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 		valid = false;
 	}
 
-	if (vtp->read_cache_size_mb > DM_VDO_READ_CACHE_SIZE_MAXIMUM_MB) {
-		log_error("VDO read cache size %u out of range.",
-			  vtp->read_cache_size_mb);
-		valid = false;
-	}
-
 	if ((vtp->slab_size_mb < DM_VDO_SLAB_SIZE_MINIMUM_MB) ||
 	    (vtp->slab_size_mb > DM_VDO_SLAB_SIZE_MAXIMUM_MB)) {
 		log_error("VDO slab size %u out of range.",
@@ -50,6 +51,13 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 		valid = false;
 	}
 
+	if ((vtp->max_discard < DM_VDO_MAX_DISCARD_MINIMUM) ||
+	    (vtp->max_discard > DM_VDO_MAX_DISCARD_MAXIMUM)) {
+		log_error("VDO max discard %u out of range.",
+			  vtp->max_discard);
+		valid = false;
+	}
+
 	if (vtp->ack_threads > DM_VDO_ACK_THREADS_MAXIMUM) {
 		log_error("VDO ack threads %u out of range.", vtp->ack_threads);
 		valid = false;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b0fcf8a..21ea3b6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -625,10 +625,17 @@ cfg(allocation_vdo_use_compression_CFG, "vdo_use_compression", allocation_CFG_SE
 cfg(allocation_vdo_use_deduplication_CFG, "vdo_use_deduplication", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_DEDUPLICATION, VDO_1ST_VSN, NULL, 0, NULL,
 	"Enables or disables deduplication when creating a VDO volume.\n"
 	"Deduplication may be disabled in instances where data is not expected\n"
-	"to have good deduplication rates but compression is still desired.")
+	"to have good deduplication rates but compression is still desired.\n")
 
-cfg(allocation_vdo_emulate_512_sectors_CFG, "vdo_emulate_512_sectors", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_EMULATE_512_SECTORS, VDO_1ST_VSN, NULL, 0, NULL,
-	"Specifies that the VDO volume is to emulate a 512 byte block device.\n")
+cfg(allocation_vdo_use_metadata_hints_CFG, "vdo_use_metadata_hints", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_METADATA_HINTS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Enables or disables whether VDO volume should tag its latency-critical\n"
+	"writes with the REQ_SYNC flag. Some device mapper targets such as dm-raid5\n"
+	"process writes with this flag at a higher priority.\n"
+	"Default is enabled.\n")
+
+cfg(allocation_vdo_minimum_io_size_CFG, "vdo_minimum_io_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_MINIMUM_IO_SIZE, VDO_1ST_VSN, NULL, 0, NULL,
+	"The minimum IO size for VDO volume to accept, in bytes.\n"
+	"Valid values are 512 or 4096. The recommended and default value is 4096.\n")
 
 cfg(allocation_vdo_block_map_cache_size_mb_CFG, "vdo_block_map_cache_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_CACHE_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the amount of memory in MiB allocated for caching block map\n"
@@ -636,41 +643,32 @@ cfg(allocation_vdo_block_map_cache_size_mb_CFG, "vdo_block_map_cache_size_mb", a
 	"at least 128MiB and less than 16TiB. The cache must be at least 16MiB\n"
 	"per logical thread. Note that there is a memory overhead of 15%.\n")
 
-cfg(allocation_vdo_block_map_period_CFG, "vdo_block_map_period", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_PERIOD, VDO_1ST_VSN, NULL, 0, NULL,
-	"Tunes the quantity of block map updates that can accumulate\n"
-	"before cache pages are flushed to disk. The value must be\n"
-	"at least 1 and less then 16380.\n"
-	"A lower value means shorter recovery time but lower performance.\n")
+// vdo format --blockMapPeriod
+cfg(allocation_vdo_block_map_era_length_CFG, "vdo_block_map_period", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_ERA_LENGTH, VDO_1ST_VSN, NULL, 0, NULL,
+	"The speed with which the block map cache writes out modified block map pages.\n"
+	"A smaller era length is likely to reduce the amount time spent rebuilding,\n"
+	"at the cost of increased block map writes during normal operation.\n"
+	"The maximum and recommended value is 16380; the minimum value is 1.\n")
 
 cfg(allocation_vdo_check_point_frequency_CFG, "vdo_check_point_frequency", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CHECK_POINT_FREQUENCY, VDO_1ST_VSN, NULL, 0, NULL,
 	"The default check point frequency for VDO volume.\n")
 
+// vdo format
 cfg(allocation_vdo_use_sparse_index_CFG, "vdo_use_sparse_index", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_SPARSE_INDEX, VDO_1ST_VSN, NULL, 0, NULL,
 	"Enables sparse indexing for VDO volume.\n")
 
+// vdo format
 cfg(allocation_vdo_index_memory_size_mb_CFG, "vdo_index_memory_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_INDEX_MEMORY_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the amount of index memory in MiB for VDO volume.\n"
-	"The value must be at least 256MiB and at most 1TiB.\n")
-
-cfg(allocation_vdo_use_read_cache_CFG, "vdo_use_read_cache", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_READ_CACHE, VDO_1ST_VSN, NULL, 0, NULL,
-	"Enables or disables the read cache within the VDO volume.\n"
-	"The cache should be enabled if write workloads are expected\n"
-	"to have high levels of deduplication, or for read intensive\n"
-	"workloads of highly compressible data.\n")
-
-cfg(allocation_vdo_read_cache_size_mb_CFG, "vdo_read_cache_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_READ_CACHE_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
-	"Specifies the extra VDO volume read cache size in MiB.\n"
-	"This space is in addition to a system-defined minimum.\n"
-	"The value must be less then 16TiB and 1.12 MiB of memory\n"
-	"will be used per MiB of read cache specified, per bio thread.\n")
+	"The value must be at least 256MiB and at most 1TiB.")
 
 cfg(allocation_vdo_slab_size_mb_CFG, "vdo_slab_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_SLAB_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the size in MiB of the increment by which a VDO is grown.\n"
 	"Using a smaller size constrains the total maximum physical size\n"
-	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.\n")
+	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.")
 
 cfg(allocation_vdo_ack_threads_CFG, "vdo_ack_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_ACK_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
-	"Specifies the number of threads to use for acknowledging\n"
+	"Specifies the number of threads   to use for acknowledging\n"
 	"completion of requested VDO I/O operations.\n"
 	"The value must be at in range [0..100].\n")
 
@@ -722,6 +720,16 @@ cfg(allocation_vdo_write_policy_CFG, "vdo_write_policy", allocation_CFG_SECTION,
 	"async - Writes are acknowledged after data has been cached for writing to stable storage.\n"
 	"        Data which has not been flushed is not guaranteed to persist in this mode.\n")
 
+cfg(allocation_vdo_max_discard_CFG, "vdo_max_discard", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_MAX_DISCARD, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specified te maximum size of discard bio accepted, in 4096 byte blocks.\n"
+	"I/O requests to a VDO volume are normally split into 4096-byte blocks,\n"
+	"and processed up to 2048 at a time. However, discard requests to a VDO volume\n"
+	"can be automatically split to a larger size, up to <max discard> 4096-byte blocks\n"
+	"in a single bio, and are limited to 1500 at a time.\n"
+	"Increasing this value may provide better overall performance, at the cost of\n"
+	"increased latency for the individual discard requests.\n"
+	"The default and minimum is 1. The maximum is UINT_MAX / 4096.\n")
+
 cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Enable or disable LVM log reporting.\n"
 	"If enabled, LVM will collect a log of operations, messages,\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index fc12626..b45324b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -153,14 +153,13 @@
 /* VDO defaults */
 #define DEFAULT_VDO_USE_COMPRESSION	(true)
 #define DEFAULT_VDO_USE_DEDUPLICATION	(true)
-#define DEFAULT_VDO_EMULATE_512_SECTORS	(false)
+#define DEFAULT_VDO_USE_METADATA_HINTS	(true)
+#define DEFAULT_VDO_MINIMUM_IO_SIZE	(4096)
 #define DEFAULT_VDO_BLOCK_MAP_CACHE_SIZE_MB	(DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB)
-#define DEFAULT_VDO_BLOCK_MAP_PERIOD	(DM_VDO_BLOCK_MAP_PERIOD_MAXIMUM)
+#define DEFAULT_VDO_BLOCK_MAP_ERA_LENGTH (DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM)
 #define DEFAULT_VDO_USE_SPARSE_INDEX	(false)
 #define DEFAULT_VDO_CHECK_POINT_FREQUENCY	(0)
 #define DEFAULT_VDO_INDEX_MEMORY_SIZE_MB	(DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB)
-#define DEFAULT_VDO_USE_READ_CACHE	(false)
-#define DEFAULT_VDO_READ_CACHE_SIZE_MB	(0)
 #define DEFAULT_VDO_SLAB_SIZE_MB	(2 * 1024)  // 2GiB ... 19 slabbits
 #define DEFAULT_VDO_ACK_THREADS		(1)
 #define DEFAULT_VDO_BIO_THREADS		(1)
@@ -170,6 +169,7 @@
 #define DEFAULT_VDO_LOGICAL_THREADS	(1)
 #define DEFAULT_VDO_PHYSICAL_THREADS	(1)
 #define DEFAULT_VDO_WRITE_POLICY	"auto"
+#define DEFAULT_VDO_MAX_DISCARD		(DM_VDO_MAX_DISCARD_MINIMUM)
 
 #define DEFAULT_VDO_FORMAT_OPTIONS_CONFIG "#S" ""
 /*
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index b5bbbe2..04ab1ab 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -416,22 +416,20 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 		find_config_tree_int(cmd, allocation_vdo_use_compression_CFG, profile);
 	vtp->use_deduplication =
 		find_config_tree_int(cmd, allocation_vdo_use_deduplication_CFG, profile);
-	vtp->emulate_512_sectors =
-		find_config_tree_int(cmd, allocation_vdo_emulate_512_sectors_CFG, profile);
+	vtp->use_metadata_hints =
+		find_config_tree_int(cmd, allocation_vdo_use_metadata_hints_CFG, profile);
+	vtp->minimum_io_size =
+		find_config_tree_int(cmd, allocation_vdo_minimum_io_size_CFG, profile);
 	vtp->block_map_cache_size_mb =
 		find_config_tree_int64(cmd, allocation_vdo_block_map_cache_size_mb_CFG, profile);
-	vtp->block_map_period =
-		find_config_tree_int(cmd, allocation_vdo_block_map_period_CFG, profile);
+	vtp->block_map_era_length =
+		find_config_tree_int(cmd, allocation_vdo_block_map_era_length_CFG, profile);
 	vtp->check_point_frequency =
 		find_config_tree_int(cmd, allocation_vdo_check_point_frequency_CFG, profile);
 	vtp->use_sparse_index =
 		find_config_tree_int(cmd, allocation_vdo_use_sparse_index_CFG, profile);
 	vtp->index_memory_size_mb =
 		find_config_tree_int64(cmd, allocation_vdo_index_memory_size_mb_CFG, profile);
-	vtp->use_read_cache =
-		find_config_tree_int(cmd, allocation_vdo_use_read_cache_CFG, profile);
-	vtp->read_cache_size_mb =
-		find_config_tree_int64(cmd, allocation_vdo_read_cache_size_mb_CFG, profile);
 	vtp->slab_size_mb =
 		find_config_tree_int(cmd, allocation_vdo_slab_size_mb_CFG, profile);
 	vtp->ack_threads =
@@ -448,6 +446,8 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 		find_config_tree_int(cmd, allocation_vdo_logical_threads_CFG, profile);
 	vtp->physical_threads =
 		find_config_tree_int(cmd, allocation_vdo_physical_threads_CFG, profile);
+	vtp->max_discard =
+		find_config_tree_int(cmd, allocation_vdo_max_discard_CFG, profile);
 
 	policy = find_config_tree_str(cmd, allocation_vdo_write_policy_CFG, profile);
 	if (!get_vdo_write_policy(&vtp->write_policy, policy))
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 455ce5b..c34eb93 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -165,21 +165,19 @@ static void _vdo_pool_display(const struct lv_segment *seg)
 
 	_print_yes_no("Compression\t", vtp->use_compression);
 	_print_yes_no("Deduplication", vtp->use_deduplication);
-	_print_yes_no("Emulate 512 sectors", vtp->emulate_512_sectors);
+	_print_yes_no("Metadata hints", vtp->use_metadata_hints);
 
+	log_print("  Minimum IO size\t%s",
+		  display_size(cmd, vtp->minimum_io_size));
 	log_print("  Block map cache sz\t%s",
 		  display_size(cmd, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024)));
-	log_print("  Block map period\t%u", vtp->block_map_period);
+	log_print("  Block map era length\t%u", vtp->block_map_era_length);
 
 	_print_yes_no("Sparse index", vtp->use_sparse_index);
 
 	log_print("  Index memory size\t%s",
 		  display_size(cmd, vtp->index_memory_size_mb * UINT64_C(2 * 1024)));
 
-	_print_yes_no("Using read cache", vtp->use_read_cache);
-
-	log_print("  Read cache size\t%s",
-		  display_size(cmd, vtp->read_cache_size_mb * UINT64_C(2 * 1024)));
 	log_print("  Slab size\t\t%s",
 		  display_size(cmd, vtp->slab_size_mb * UINT64_C(2 * 1024)));
 
@@ -190,6 +188,7 @@ static void _vdo_pool_display(const struct lv_segment *seg)
 	log_print("  # Hash zone threads\t%u", (unsigned) vtp->hash_zone_threads);
 	log_print("  # Logical threads\t%u", (unsigned) vtp->logical_threads);
 	log_print("  # Physical threads\t%u", (unsigned) vtp->physical_threads);
+	log_print("  Max discard\t%u", (unsigned) vtp->max_discard);
 }
 
 /* reused as _vdo_text_import_area_count */
@@ -235,14 +234,17 @@ static int _vdo_pool_text_import(struct lv_segment *seg,
 	if (!_import_bool(n, "use_deduplication", &vtp->use_deduplication))
 		return_0;
 
-	if (!_import_bool(n, "emulate_512_sectors", &vtp->emulate_512_sectors))
+	if (!_import_bool(n, "use_metadata_hints", &vtp->use_metadata_hints))
 		return_0;
 
+	if (!dm_config_get_uint32(n, "minimum_io_size", &vtp->minimum_io_size))
+		return _bad_field("minimum_io_size");
+
 	if (!dm_config_get_uint32(n, "block_map_cache_size_mb", &vtp->block_map_cache_size_mb))
 		return _bad_field("block_map_cache_size_mb");
 
-	if (!dm_config_get_uint32(n, "block_map_period", &vtp->block_map_period))
-		return _bad_field("block_map_period");
+	if (!dm_config_get_uint32(n, "block_map_era_length", &vtp->block_map_era_length))
+		return _bad_field("block_map_era_length");
 
 	if (!_import_bool(n, "use_sparse_index", &vtp->use_sparse_index))
 		return_0;
@@ -250,11 +252,8 @@ static int _vdo_pool_text_import(struct lv_segment *seg,
 	if (!dm_config_get_uint32(n, "index_memory_size_mb", &vtp->index_memory_size_mb))
 		return _bad_field("index_memory_size_mb");
 
-	if (!_import_bool(n, "use_read_cache", &vtp->use_read_cache))
-		return_0;
-
-	if (!dm_config_get_uint32(n, "read_cache_size_mb", &vtp->read_cache_size_mb))
-		return _bad_field("read_cache_size_mb");
+	if (!dm_config_get_uint32(n, "max_discard", &vtp->max_discard))
+		return _bad_field("max_discard");
 
 	if (!dm_config_get_uint32(n, "slab_size_mb", &vtp->slab_size_mb))
 		return _bad_field("slab_size_mb");
@@ -306,12 +305,14 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 		outf(f, "use_compression = 1");
 	if (vtp->use_deduplication)
 		outf(f, "use_deduplication = 1");
-	if (vtp->emulate_512_sectors)
-		outf(f, "emulate_512_sectors = 1");
+	if (vtp->use_metadata_hints)
+		outf(f, "use_metadata_hints = 1");
+
+	outsize(f, vtp->minimum_io_size, "minimum_io_size = %u", vtp->minimum_io_size);
 
 	outsize(f, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024),
 		"block_map_cache_size_mb = %u", vtp->block_map_cache_size_mb);
-	outf(f, "block_map_period = %u", vtp->block_map_period);
+	outf(f, "block_map_era_length = %u", vtp->block_map_era_length);
 
 	if (vtp->use_sparse_index)
 		outf(f, "use_sparse_index = 1");
@@ -319,11 +320,9 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 	outsize(f, vtp->index_memory_size_mb * UINT64_C(2 * 1024),
 		"index_memory_size_mb = %u", vtp->index_memory_size_mb);
 
-	if (vtp->use_read_cache)
-		outf(f, "use_read_cache = 1");
+	outf(f, "max_discard = %u", vtp->max_discard);
+
 	// TODO - conditionally
-	outsize(f, vtp->read_cache_size_mb * UINT64_C(2 * 1024),
-		"read_cache_size_mb = %u", vtp->read_cache_size_mb);
 	outsize(f, vtp->slab_size_mb * UINT64_C(2 * 1024),
 		"slab_size_mb = %u", vtp->slab_size_mb);
 	outf(f, "ack_threads = %u", (unsigned) vtp->ack_threads);
@@ -364,7 +363,8 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 
 	/* VDO uses virtual size instead of its physical size */
 	if (!dm_tree_node_add_vdo_target(node, get_vdo_pool_virtual_size(seg),
-					 data_uuid, &seg->vdo_params))
+					 data_uuid, seg_lv(seg, 0)->size,
+					 &seg->vdo_params))
 		return_0;
 
 	return 1;


