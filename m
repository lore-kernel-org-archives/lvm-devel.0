From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:17 -0400
Subject: master - lib: new vdo segment configurable options
Message-ID: <201807091334.w69DYHI3030597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d9a4c69896137f1b440ec6da187387f6394d1fb
Commit:        0d9a4c69896137f1b440ec6da187387f6394d1fb
Parent:        4a90b0c4c92564adb1569824f22dc0d9a1badf5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:09:03 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

lib: new vdo segment configurable options

Configurable for vdo segment with their default values.
Also specify their ranges with minimal and maximal values.
---
 conf/example.conf.in           |  154 ++++++++++++++++++++++++++++++++++++++++
 device_mapper/vdo/vdo_limits.h |   60 ++++++++++++++++
 lib/config/config_settings.h   |  115 +++++++++++++++++++++++++++++-
 lib/config/defaults.h          |   33 +++++++++
 4 files changed, 361 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 83f9f42..f2bb77b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -488,6 +488,149 @@ allocation {
 	# Default physical extent size in KiB to use for new VGs.
 	# This configuration option has an automatic default value.
 	# physical_extent_size = 4096
+
+	# Configuration option allocation/vdo_use_compression.
+	# Enables or disables compression when creating a VDO volume.
+	# Compression may be disabled if necessary to maximize performance
+	# or to speed processing of data that is unlikely to compress.
+	# This configuration option has an automatic default value.
+	# vdo_use_compression = 1
+
+	# Configuration option allocation/vdo_use_deduplication.
+	# Enables or disables deduplication when creating a VDO volume.
+	# Deduplication may be disabled in instances where data is not expected
+	# to have good deduplication rates but compression is still desired.
+	# This configuration option has an automatic default value.
+	# vdo_use_deduplication = 1
+
+	# Configuration option allocation/vdo_emulate_512_sectors.
+	# Specifies that the VDO volume is to emulate a 512 byte block device.
+	# This configuration option has an automatic default value.
+	# vdo_emulate_512_sectors = 0
+
+	# Configuration option allocation/vdo_block_map_cache_size_mb.
+	# Specifies the amount of memory in MiB allocated for caching block map
+	# pages for VDO volume. The value must be a multiple of 4096 and must be
+	# at least 128MiB and less than 16TiB. The cache must be at least 16MiB
+	# per logical thread. Note that there is a memory overhead of 15%.
+	# This configuration option has an automatic default value.
+	# vdo_block_map_cache_size_mb = 128
+
+	# Configuration option allocation/vdo_block_map_period.
+	# Tunes the quantity of block map updates that can accumulate
+	# before cache pages are flushed to disk. The value must be
+	# at least 1 and less then 16380.
+	# A lower value means shorter recovery time but lower performance.
+	# This configuration option has an automatic default value.
+	# vdo_block_map_period = 16380
+
+	# Configuration option allocation/vdo_check_point_frequency.
+	# The default check point frequency for VDO volume.
+	# This configuration option has an automatic default value.
+	# vdo_check_point_frequency = 0
+
+	# Configuration option allocation/vdo_use_sparse_index.
+	# Enables sparse indexing for VDO volume.
+	# This configuration option has an automatic default value.
+	# vdo_use_sparse_index = 0
+
+	# Configuration option allocation/vdo_index_memory_size_mb.
+	# Specifies the amount of index memory in MiB for VDO volume.
+	# The value must be at least 256MiB and at most 1TiB.
+	# This configuration option has an automatic default value.
+	# vdo_index_memory_size_mb = 256
+
+	# Configuration option allocation/vdo_use_read_cache.
+	# Enables or disables the read cache within the VDO volume.
+	# The cache should be enabled if write workloads are expected
+	# to have high levels of deduplication, or for read intensive
+	# workloads of highly compressible data.
+	# This configuration option has an automatic default value.
+	# vdo_use_read_cache = 0
+
+	# Configuration option allocation/vdo_read_cache_size_mb.
+	# Specifies the extra VDO volume read cache size in MiB.
+	# This space is in addition to a system-defined minimum.
+	# The value must be less then 16TiB and 1.12 MiB of memory
+	# will be used per MiB of read cache specified, per bio thread.
+	# This configuration option has an automatic default value.
+	# vdo_read_cache_size_mb = 0
+
+	# Configuration option allocation/vdo_slab_size_mb.
+	# Specifies the size in MiB of the increment by which a VDO is grown.
+	# Using a smaller size constrains the total maximum physical size
+	# that can be accommodated. Must be a power of two between 128MiB and 32GiB.
+	# This configuration option has an automatic default value.
+	# vdo_slab_size_mb = 2048
+
+	# Configuration option allocation/vdo_ack_threads.
+	# Specifies the number of threads to use for acknowledging
+	# completion of requested VDO I/O operations.
+	# The value must be at in range [0..100].
+	# This configuration option has an automatic default value.
+	# vdo_ack_threads = 1
+
+	# Configuration option allocation/vdo_bio_threads.
+	# Specifies the number of threads to use for submitting I/O
+	# operations to the storage device of VDO volume.
+	# The value must be in range [1..100]
+	# Each additional thread after the first will use an additional 18MiB of RAM,
+	# plus 1.12 MiB of RAM per megabyte of configured read cache size.
+	# This configuration option has an automatic default value.
+	# vdo_bio_threads = 1
+
+	# Configuration option allocation/vdo_bio_rotation.
+	# Specifies the number of I/O operations to enqueue for each bio-submission
+	# thread before directing work to the next. The value must be in range [1..1024].
+	# This configuration option has an automatic default value.
+	# vdo_bio_rotation = 64
+
+	# Configuration option allocation/vdo_cpu_threads.
+	# Specifies the number of threads to use for CPU-intensive work such as
+	# hashing or compression for VDO volume. The value must be in range [1..100]
+	# This configuration option has an automatic default value.
+	# vdo_cpu_threads = 2
+
+	# Configuration option allocation/vdo_hash_zone_threads.
+	# Specifies the number of threads across which to subdivide parts of the VDO
+	# processing based on the hash value computed from the block data.
+	# The value must be at in range [0..100].
+	# vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be
+	# either all zero or all non-zero.
+	# This configuration option has an automatic default value.
+	# vdo_hash_zone_threads = 1
+
+	# Configuration option allocation/vdo_logical_threads.
+	# Specifies the number of threads across which to subdivide parts of the VDO
+	# processing based on the hash value computed from the block data.
+	# A logical thread count of 9 or more will require explicitly specifying
+	# a sufficiently large block map cache size, as well.
+	# The value must be in range [0..100].
+	# vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be
+	# either all zero or all non-zero.
+	# This configuration option has an automatic default value.
+	# vdo_logical_threads = 1
+
+	# Configuration option allocation/vdo_physical_threads.
+	# Specifies the number of threads across which to subdivide parts of the VDO
+	# processing based on physical block addresses.
+	# Each additional thread after the first will use an additional 10MiB of RAM.
+	# The value must be in range [0..16].
+	# vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be
+	# either all zero or all non-zero.
+	# This configuration option has an automatic default value.
+	# vdo_physical_threads = 1
+
+	# Configuration option allocation/vdo_write_policy.
+	# Specifies the write policy:
+	# auto  - VDO will check the storage device and determine whether it supports flushes.
+	#         If it does, VDO will run in async mode, otherwise it will run in sync mode.
+	# sync  - Writes are acknowledged only after data is stably written.
+	#         This policy is not supported if the underlying storage is not also synchronous.
+	# async - Writes are acknowledged after data has been cached for writing to stable storage.
+	#         Data which has not been flushed is not guaranteed to persist in this mode.
+	# This configuration option has an automatic default value.
+	# vdo_write_policy = "auto"
 }
 
 # Configuration section log.
@@ -1006,6 +1149,17 @@ global {
 	# This configuration option has an automatic default value.
 	# cache_repair_options = [ "" ]
 
+	# Configuration option global/vdo_format_executable.
+	# The full path to the vdoformat command.
+	# LVM uses this command to initial data volume for VDO type logical volume
+	# This configuration option has an automatic default value.
+	# vdo_format_executable = "@VDO_FORMAT_CMD@"
+
+	# Configuration option global/vdo_format_options.
+	# List of options passed added to standard vdoformat command.
+	# This configuration option has an automatic default value.
+	# vdo_format_options = [ "" ]
+
 	# Configuration option global/fsadm_executable.
 	# The full path to the fsadm command.
 	# LVM uses this command to help with lvresize -r operations.
diff --git a/device_mapper/vdo/vdo_limits.h b/device_mapper/vdo/vdo_limits.h
new file mode 100644
index 0000000..40cf204
--- /dev/null
+++ b/device_mapper/vdo/vdo_limits.h
@@ -0,0 +1,60 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef DEVICE_MAPPER_VDO_LIMITS_H
+#define DEVICE_MAPPER_VDO_LIMITS_H
+
+#define DM_VDO_BLOCK_SIZE			UINT64_C(8)		// 4KiB in sectors
+
+#define DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB	(128)			// 128MiB
+#define DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB	(16 * 1024 * 1024 - 1)	// 16TiB - 1
+#define DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_PER_LOGICAL_THREAD  (4096 * DM_VDO_BLOCK_SIZE_KB)
+
+#define DM_VDO_BLOCK_MAP_PERIOD_MINIMUM		1
+#define DM_VDO_BLOCK_MAP_PERIOD_MAXIMUM		(16380)
+
+#define DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB	(256)			// 0.25 GiB
+#define DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB	(1024 * 1024 * 1024)	// 1TiB
+
+//#define DM_VDO_READ_CACHE_SIZE_MINIMUM_MB	(0)
+#define DM_VDO_READ_CACHE_SIZE_MAXIMUM_MB	(16 * 1024 * 1024 - 1)	// 16TiB - 1
+
+#define DM_VDO_SLAB_SIZE_MINIMUM_MB		(128)			// 128MiB
+#define DM_VDO_SLAB_SIZE_MAXIMUM_MB		(32 * 1024)		// 32GiB
+
+//#define DM_VDO_LOGICAL_SIZE_MINIMUM_MB	(0)
+#define DM_VDO_LOGICAL_SIZE_MAXIMUM_MB	(UINT64_C(4) * 1024 * 1024 * 1024) // 4PiB
+
+//#define DM_VDO_ACK_THREADS_MINIMUM		(0)
+#define DM_VDO_ACK_THREADS_MAXIMUM		(100)
+
+#define DM_VDO_BIO_THREADS_MINIMUM		(1)
+#define DM_VDO_BIO_THREADS_MAXIMUM		(100)
+
+#define DM_VDO_BIO_ROTATION_MINIMUM		(1)
+#define DM_VDO_BIO_ROTATION_MAXIMUM		(1024)
+
+#define DM_VDO_CPU_THREADS_MINIMUM		(1)
+#define DM_VDO_CPU_THREADS_MAXIMUM		(100)
+
+//#define DM_VDO_HASH_ZONE_THREADS_MINIMUM	(0)
+#define DM_VDO_HASH_ZONE_THREADS_MAXIMUM	(100)
+
+//#define DM_VDO_LOGICAL_THREADS_MINIMUM	(0)
+#define DM_VDO_LOGICAL_THREADS_MAXIMUM		(100)
+
+//#define DM_VDO_PHYSICAL_THREADS_MINIMUM	(0)
+#define DM_VDO_PHYSICAL_THREADS_MAXIMUM		(16)
+
+#endif // DEVICE_MAPPER_VDO_LIMITS_H
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7cb266c..9026c2d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2013-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -607,6 +607,112 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
+#define VDO_1ST_VSN vsn(3, 0, 0)
+cfg(allocation_vdo_use_compression_CFG, "vdo_use_compression", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_COMPRESSION, VDO_1ST_VSN, NULL, 0, NULL,
+	"Enables or disables compression when creating a VDO volume.\n"
+	"Compression may be disabled if necessary to maximize performance\n"
+	"or to speed processing of data that is unlikely to compress.\n")
+
+cfg(allocation_vdo_use_deduplication_CFG, "vdo_use_deduplication", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_DEDUPLICATION, VDO_1ST_VSN, NULL, 0, NULL,
+	"Enables or disables deduplication when creating a VDO volume.\n"
+	"Deduplication may be disabled in instances where data is not expected\n"
+	"to have good deduplication rates but compression is still desired.")
+
+cfg(allocation_vdo_emulate_512_sectors_CFG, "vdo_emulate_512_sectors", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_EMULATE_512_SECTORS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies that the VDO volume is to emulate a 512 byte block device.\n")
+
+cfg(allocation_vdo_block_map_cache_size_mb_CFG, "vdo_block_map_cache_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_CACHE_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the amount of memory in MiB allocated for caching block map\n"
+	"pages for VDO volume. The value must be a multiple of 4096 and must be\n"
+	"at least 128MiB and less than 16TiB. The cache must be at least 16MiB\n"
+	"per logical thread. Note that there is a memory overhead of 15%.\n")
+
+cfg(allocation_vdo_block_map_period_CFG, "vdo_block_map_period", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_PERIOD, VDO_1ST_VSN, NULL, 0, NULL,
+	"Tunes the quantity of block map updates that can accumulate\n"
+	"before cache pages are flushed to disk. The value must be\n"
+	"at least 1 and less then 16380.\n"
+	"A lower value means shorter recovery time but lower performance.\n")
+
+cfg(allocation_vdo_check_point_frequency_CFG, "vdo_check_point_frequency", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CHECK_POINT_FREQUENCY, VDO_1ST_VSN, NULL, 0, NULL,
+	"The default check point frequency for VDO volume.\n")
+
+cfg(allocation_vdo_use_sparse_index_CFG, "vdo_use_sparse_index", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_SPARSE_INDEX, VDO_1ST_VSN, NULL, 0, NULL,
+	"Enables sparse indexing for VDO volume.\n")
+
+cfg(allocation_vdo_index_memory_size_mb_CFG, "vdo_index_memory_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_INDEX_MEMORY_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the amount of index memory in MiB for VDO volume.\n"
+	"The value must be at least 256MiB and at most 1TiB.\n")
+
+cfg(allocation_vdo_use_read_cache_CFG, "vdo_use_read_cache", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_READ_CACHE, VDO_1ST_VSN, NULL, 0, NULL,
+	"Enables or disables the read cache within the VDO volume.\n"
+	"The cache should be enabled if write workloads are expected\n"
+	"to have high levels of deduplication, or for read intensive\n"
+	"workloads of highly compressible data.\n")
+
+cfg(allocation_vdo_read_cache_size_mb_CFG, "vdo_read_cache_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_READ_CACHE_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the extra VDO volume read cache size in MiB.\n"
+	"This space is in addition to a system-defined minimum.\n"
+	"The value must be less then 16TiB and 1.12 MiB of memory\n"
+	"will be used per MiB of read cache specified, per bio thread.\n")
+
+cfg(allocation_vdo_slab_size_mb_CFG, "vdo_slab_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_SLAB_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the size in MiB of the increment by which a VDO is grown.\n"
+	"Using a smaller size constrains the total maximum physical size\n"
+	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.\n")
+
+cfg(allocation_vdo_ack_threads_CFG, "vdo_ack_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_ACK_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads to use for acknowledging\n"
+	"completion of requested VDO I/O operations.\n"
+	"The value must be at in range [0..100].\n")
+
+cfg(allocation_vdo_bio_threads_CFG, "vdo_bio_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BIO_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads to use for submitting I/O\n"
+	"operations to the storage device of VDO volume.\n"
+	"The value must be in range [1..100]\n"
+	"Each additional thread after the first will use an additional 18MiB of RAM,\n"
+	"plus 1.12 MiB of RAM per megabyte of configured read cache size.\n")
+
+cfg(allocation_vdo_bio_rotation_CFG, "vdo_bio_rotation", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BIO_ROTATION, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of I/O operations to enqueue for each bio-submission\n"
+	"thread before directing work to the next. The value must be in range [1..1024].\n")
+
+cfg(allocation_vdo_cpu_threads_CFG, "vdo_cpu_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CPU_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads to use for CPU-intensive work such as\n"
+	"hashing or compression for VDO volume. The value must be in range [1..100]\n")
+
+cfg(allocation_vdo_hash_zone_threads_CFG, "vdo_hash_zone_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_HASH_ZONE_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads across which to subdivide parts of the VDO\n"
+	"processing based on the hash value computed from the block data.\n"
+	"The value must be at in range [0..100].\n"
+	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
+	"either all zero or all non-zero.")
+
+cfg(allocation_vdo_logical_threads_CFG, "vdo_logical_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_LOGICAL_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads across which to subdivide parts of the VDO\n"
+	"processing based on the hash value computed from the block data.\n"
+	"A logical thread count of 9 or more will require explicitly specifying\n"
+	"a sufficiently large block map cache size, as well.\n"
+	"The value must be in range [0..100].\n"
+	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
+	"either all zero or all non-zero.\n")
+
+cfg(allocation_vdo_physical_threads_CFG, "vdo_physical_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_PHYSICAL_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the number of threads across which to subdivide parts of the VDO\n"
+	"processing based on physical block addresses.\n"
+	"Each additional thread after the first will use an additional 10MiB of RAM.\n"
+	"The value must be in range [0..16].\n"
+	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
+	"either all zero or all non-zero.\n")
+
+cfg(allocation_vdo_write_policy_CFG, "vdo_write_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VDO_WRITE_POLICY, VDO_1ST_VSN, NULL, 0, NULL,
+	"Specifies the write policy:\n"
+	"auto  - VDO will check the storage device and determine whether it supports flushes.\n"
+	"        If it does, VDO will run in async mode, otherwise it will run in sync mode.\n"
+	"sync  - Writes are acknowledged only after data is stably written.\n"
+	"        This policy is not supported if the underlying storage is not also synchronous.\n"
+	"async - Writes are acknowledged after data has been cached for writing to stable storage.\n"
+	"        Data which has not been flushed is not guaranteed to persist in this mode.\n")
+
 cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Enable or disable LVM log reporting.\n"
 	"If enabled, LVM will collect a log of operations, messages,\n"
@@ -1019,6 +1125,13 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
+cfg(global_vdo_format_executable_CFG, "vdo_format_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, VDO_FORMAT_CMD, VDO_1ST_VSN, "@VDO_FORMAT_CMD@", 0, NULL,
+	"The full path to the vdoformat command.\n"
+	"LVM uses this command to initial data volume for VDO type logical volume\n")
+
+cfg_array(global_vdo_format_options_CFG, "vdo_format_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VDO_FORMAT_OPTIONS_CONFIG, VDO_1ST_VSN, NULL, 0, NULL,
+	"List of options passed added to standard vdoformat command.\n")
+
 cfg(global_fsadm_executable_CFG, "fsadm_executable", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FSADM_PATH, vsn(2, 2, 170), "@FSADM_PATH@", 0, NULL,
 	"The full path to the fsadm command.\n"
 	"LVM uses this command to help with lvresize -r operations.\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 084d365..2d70f53 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_DEFAULTS_H
 #define _LVM_DEFAULTS_H
 
+#include "device_mapper/vdo/vdo_limits.h"
+
 #define DEFAULT_PE_ALIGN 2048
 #define DEFAULT_PE_ALIGN_OLD 128
 
@@ -134,6 +136,37 @@
 #define DEFAULT_CACHE_METADATA_FORMAT CACHE_METADATA_FORMAT_UNSELECTED /* Autodetect */
 #define DEFAULT_CACHE_MODE "writethrough"
 
+
+/* VDO defaults */
+#define DEFAULT_VDO_USE_COMPRESSION	(true)
+#define DEFAULT_VDO_USE_DEDUPLICATION	(true)
+#define DEFAULT_VDO_EMULATE_512_SECTORS	(false)
+#define DEFAULT_VDO_BLOCK_MAP_CACHE_SIZE_MB	(DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB)
+#define DEFAULT_VDO_BLOCK_MAP_PERIOD	(DM_VDO_BLOCK_MAP_PERIOD_MAXIMUM)
+#define DEFAULT_VDO_USE_SPARSE_INDEX	(false)
+#define DEFAULT_VDO_CHECK_POINT_FREQUENCY	(0)
+#define DEFAULT_VDO_INDEX_MEMORY_SIZE_MB	(DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB)
+#define DEFAULT_VDO_USE_READ_CACHE	(false)
+#define DEFAULT_VDO_READ_CACHE_SIZE_MB	(0)
+#define DEFAULT_VDO_SLAB_SIZE_MB	(2 * 1024)  // 2GiB ... 19 slabbits
+#define DEFAULT_VDO_ACK_THREADS		(1)
+#define DEFAULT_VDO_BIO_THREADS		(1)
+#define DEFAULT_VDO_BIO_ROTATION	(64)
+#define DEFAULT_VDO_CPU_THREADS		(2)
+#define DEFAULT_VDO_HASH_ZONE_THREADS	(1)
+#define DEFAULT_VDO_LOGICAL_THREADS	(1)
+#define DEFAULT_VDO_PHYSICAL_THREADS	(1)
+#define DEFAULT_VDO_WRITE_POLICY	"auto"
+
+#define DEFAULT_VDO_FORMAT_OPTIONS_CONFIG "#S" ""
+/*
+ * VDO pool will reverve some sectors in the front and the back of pool device to avoid
+ * seeing same device twice in the system.
+ */
+#define DEFAULT_VDO_POOL_HEADER_SIZE  (1024)   // 512KiB
+
+
+
 #define DEFAULT_FSADM_PATH FSADM_PATH
 
 #define DEFAULT_UMASK 0077


